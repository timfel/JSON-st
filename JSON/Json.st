Object subclass: Json [
    | stream ctorMap |
    
    <category: 'JSON'>
    <comment: 'This class reads and writes JSON format data - strings, numbers, boolean, nil, arrays and dictionaries. See http://www.crockford.com/JSON/index.html. It has been extended with syntax for invoking a prearranged list of constructors on read objects.'>

    Json class [
	| escapeArray |
	
    ]

    Json class >> escapeForCharacter: c [
	| index |
	^(index := c asciiValue + 1) <= escapeArray size 
	    ifTrue: [escapeArray at: index]
	    ifFalse: [c]
    ]

    Json class >> initialize [
	"Json initialize."

	| tmpStr |
	escapeArray := (1 to: 128) collect: [:i | Character value: i - 1].
	(0 to: 31) , #(127) do: 
		[:each | 
		tmpStr := String streamContents: [:str | each printOn: str base: 16].
		escapeArray at: each + 1
		    put: '\u' , (String new: (4 - tmpStr size max: 0) withAll: $0) , tmpStr].
	
	{$" -> '\"'.
	$\ -> '\\'.
	Character backspace -> '\b'.
	Character lf -> '\n'.
	Character newPage -> '\f'.
	Character cr -> '\r'.
	Character tab -> '\t'} 
		do: [:each | escapeArray at: each key asciiValue + 1 put: each value]
    ]

    Json class >> mimeType [
	^'application/x-json'
    ]

    Json class >> newWithConstructors: aCollection [
	| m |
	m := Dictionary new.
	aCollection do: 
		[:each | 
		(each isKindOf: Association) 
		    ifTrue: [m add: each]
		    ifFalse: [m at: each name asString put: each]].
	^(self new)
	    ctorMap: m;
	    yourself
    ]

    Json class >> numbersMayContain: aChar [
	^aChar isDigit or: [#($- $+ $. $e $E) includes: aChar]
    ]

    Json class >> readFrom: aStream [
	^self new readFrom: aStream
    ]

    Json class >> render: anObject [
	| s |
	s := WriteStream on: String new.
	anObject jsonWriteOn: s.
	^s contents
    ]

    Json class >> render: anObject withConstructor: aConstructorName on: aStream [
	aStream nextPutAll: '@' , aConstructorName.
	anObject jsonWriteOn: aStream
    ]

    Json class >> renderInstanceVariables: aCollection of: anObject on: aStream [
	| map |
	map := Dictionary new.
	aCollection 
	    do: [:ivarName | map at: ivarName put: (anObject instVarNamed: ivarName)].
	self 
	    render: map
	    withConstructor: anObject class name asString
	    on: aStream
    ]

    consume: aString returning: anObject [
	<category: 'private'>
	aString do: 
		[:c | 
		stream next == c 
		    ifFalse: [JsonSyntaxError signal: 'Expected ''' , aString , '''']].
	^anObject
    ]

    interpretStringEscape [
	<category: 'private'>
	| c |
	c := stream next.
	c == $b ifTrue: [^Character backspace].
	c == $n ifTrue: [^Character lf].
	c == $f ifTrue: [^Character newPage].
	c == $r ifTrue: [^Character cr].
	c == $t ifTrue: [^Character tab].
	c == $u ifTrue: [^self unescapeUnicode].
	^c
    ]

    readArray [
	<category: 'private'>
	| a |
	a := OrderedCollection new.
	self skipWhitespace.
	(stream peekFor: $]) ifTrue: [^#()].
	
	[a add: self readAny.
	self skipWhitespace.
	(stream peekFor: $]) ifTrue: [^a asArray].
	(stream peekFor: $,) ifFalse: [JsonSyntaxError signal: 'Missing comma']] 
		repeat
    ]

    readConstructor [
	<category: 'private'>
	| s c v ctor |
	s := WriteStream on: ''.
	
	[c := stream peek.
	c 
	    ifNil: [JsonSyntaxError signal: 'Premature EOF reading constructor name'].
	(c == $. or: [c isLetter]) 
	    ifTrue: 
		[s nextPut: c.
		stream next]
	    ifFalse: 
		[v := self readAny.
		s := s contents.
		ctor := ctorMap ifNotNil: [:foo | ctor := ctorMap at: s ifAbsent: [nil]].
		ctor ifNil: [JsonSyntaxError signal: 'Unknown ctor ' , s].
		^ctor constructFromJson: v]] 
		repeat
    ]

    readDictionary [
	<category: 'private'>
	| m k v needComma |
	m := JsonObject new.
	needComma := false.
	
	[self skipWhitespace.
	(stream peekFor: $}) ifTrue: [^m].
	needComma 
	    ifTrue: 
		[(stream peekFor: $,) ifFalse: [JsonSyntaxError signal: 'Missing comma'].
		self skipWhitespace]
	    ifFalse: [needComma := true].
	"k := self readAny."
	(stream peekFor: $") 
	    ifFalse: [JsonSyntaxError signal: 'Key in dictionary must be string'].
	k := self readString.
	self skipWhitespace.
	(stream peekFor: $:) ifFalse: [JsonSyntaxError signal: 'Missing colon'].
	v := self readAny.
	m at: k put: v] 
		repeat
    ]

    readNumber [
	<category: 'private'>
	| acc c |
	acc := WriteStream on: ''.
	
	[c := stream peek.
	(c isNil not and: [Json numbersMayContain: c]) 
	    ifFalse: 
		[[^acc contents asNumber] on: Error
		    do: [JsonSyntaxError signal: 'Invalid number']].
	acc nextPut: c.
	stream next] 
		repeat
    ]

    readString [
	<category: 'private'>
	| s c |
	s := WriteStream on: ''.
	
	[c := stream next.
	c == $\ 
	    ifTrue: [s nextPut: self interpretStringEscape]
	    ifFalse: 
		[c == $" ifTrue: [^s contents].
		s nextPut: c]] 
		repeat
    ]

    skipComment [
	<category: 'private'>
	stream peek == $/ 
	    ifTrue: 
		[stream next.
		stream peek == $/ 
		    ifTrue: [self skipToEndOfLine]
		    ifFalse: 
			[stream peek == $* 
			    ifTrue: 
				[stream next.
				self skipCommentBody]
			    ifFalse: [JsonSyntaxError signal: 'Invalid comment syntax']]]
    ]

    skipCommentBody [
	<category: 'private'>
	
	[[stream next == $*] whileFalse.
	stream peek == $/] whileFalse.
	stream next.	"skip that last slash"
	self skipWhitespace
    ]

    skipToEndOfLine [
	<category: 'private'>
	| cr lf |
	cr := Character cr.
	lf := Character lf.
	
	[| c |
	(c := stream peek) == cr or: [c == lf]] whileFalse: [stream next].
	self skipWhitespace
    ]

    skipWhitespace [
	<category: 'private'>
	[stream peek isSeparator] whileTrue: [stream next].
	self skipComment
    ]

    unescapeUnicode [
	<category: 'private'>
	| string |
	string := (String 
		    with: stream next
		    with: stream next
		    with: stream next
		    with: stream next) asUppercase.
	^Character codePoint: (Integer readFrom: string readStream radix: 16)
    ]

    ctorMap [
	<category: 'accessing'>
	^ctorMap
    ]

    ctorMap: m [
	<category: 'accessing'>
	ctorMap := m
    ]

    stream [
	"Answer the value of stream"

	<category: 'accessing'>
	^stream
    ]

    stream: anObject [
	"Set the value of stream"

	<category: 'accessing'>
	stream := anObject.
	(stream respondsTo: #reset) ifTrue: [stream reset]
    ]

    readAny [
	"This is the main entry point for the JSON parser. See also readFrom: on the class side."

	<category: 'parsing'>
	| c |
	self skipWhitespace.
	c := stream peek asLowercase.
	c == ${ 
	    ifTrue: 
		[stream next.
		^self readDictionary].
	c == $[ 
	    ifTrue: 
		[stream next.
		^self readArray].
	c == $" 
	    ifTrue: 
		[stream next.
		^self readString].
	c == $t ifTrue: [^self consume: 'true' returning: true].
	c == $f ifTrue: [^self consume: 'false' returning: false].
	c == $n ifTrue: [^self consume: 'null' returning: nil].
	c == $@ 
	    ifTrue: 
		[stream next.
		^self readConstructor].
	(Json numbersMayContain: c) ifTrue: [^self readNumber].
	JsonSyntaxError signal: 'Unknown Json input'
    ]

    readFrom: aStream [
	<category: 'parsing'>
	self stream: aStream.
	^self readAny
    ]
]



Eval [
    Json initialize
]

