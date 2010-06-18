Object subclass: JsonObject [
    | dictionary |
    
    <category: 'JSON'>
    <comment: nil>

    JsonObject class >> fromAssociations: collectionOfAssociations [
	| result |
	result := Dictionary new.
	collectionOfAssociations do: [:each | result at: each key put: each value].
	^(self new)
	    dictionary: result;
	    yourself
    ]

    at: aKey [
	"make it work more like javascript objects"

	<category: 'accessing'>
	^self at: aKey ifAbsent: [nil]
    ]

    dictionary [
	<category: 'accessing'>
	dictionary ifNil: [dictionary := Dictionary new].
	^dictionary
    ]

    dictionary: aDictionary [
	<category: 'accessing'>
	aDictionary ifNotNil: [:foo | dictionary := aDictionary]
    ]

    = aJsonObject [
	<category: 'overrides-to-dictionary'>
	^aJsonObject dictionary = self dictionary
    ]

    at: aKey put: aValue [
	"override cause object defines this"

	<category: 'overrides-to-dictionary'>
	^self dictionary at: aKey put: aValue
    ]

    bindingOf: varName [
	<category: 'overrides-to-dictionary'>
	^self dictionary bindingOf: varName
    ]

    flattenOnStream: aStream [
	<category: 'overrides-to-dictionary'>
	^self dictionary flattenOnStream: aStream
    ]

    isDictionary [
	<category: 'overrides-to-dictionary'>
	^true
    ]

    javascriptOn: aStream [
	<category: 'overrides-to-dictionary'>
	self dictionary javascriptOn: aStream
    ]

    jsonOn: aStream [
	<category: 'overrides-to-dictionary'>
	self dictionary jsonOn: aStream
    ]

    name [
	"override 'cause Object defines this"

	<category: 'overrides-to-dictionary'>
	^self at: 'name'
    ]

    storeOn: aStream [
	<category: 'overrides-to-dictionary'>
	^self dictionary storeOn: aStream
    ]

    value [
	"override 'cause Object defines this"

	<category: 'overrides-to-dictionary'>
	^self at: 'value'
    ]

    doesNotUnderstand: aMessage [
	| key result |
	
	[result := aMessage sendTo: self dictionary.
	^result] 
		on: MessageNotUnderstood
		do: 
		    [key := aMessage selector.
		    key isUnary ifTrue: [^self at: key].
		    ^(key isKeyword and: [(key occurrencesOf: $:) = 1]) 
			ifTrue: 
			    [key := key allButLast asSymbol.
			    self dictionary at: key put: aMessage arguments first]
			ifFalse: [super doesNotUnderstand: aMessage]]
    ]

    initialize [
	super initialize.
	dictionary := Dictionary new
    ]
]

