TestCase subclass: JsonTests [
    
    <comment: 'I provide a number of test cases for class Json.'>
    <category: 'JSON'>

    json: aString equals: aValue [
	| readValue |
	readValue := self readFrom: aString.
	self assert: readValue = aValue
    ]

    readFrom: aString [
	^(Json newWithConstructors: {JsonDummyTestObject}) 
	    readFrom: aString readStream
    ]

    render: anObject equals: aString [
	self assert: (Json render: anObject) = aString
    ]

    simpleDummyObject [
	^(JsonDummyTestObject new)
	    a: 1;
	    b: 2;
	    c: 3;
	    yourself
    ]

    testAtomFalse [
	self json: 'false' equals: false.
	self json: '  false' equals: false.
	self json: 'false  ' equals: false.
	self json: '  false  ' equals: false
    ]

    testAtomNull [
	self json: 'null' equals: nil.
	self json: '  null' equals: nil.
	self json: 'null  ' equals: nil.
	self json: '  null  ' equals: nil
    ]

    testAtomNumber [
	self json: '1' equals: 1.
	self json: '0123' equals: 123.
	self json: '1.23e2' equals: 123.
	self json: '-1' equals: -1.
	self json: '-0' equals: 0.
	self json: '[-1.2]' equals: {1.2 negated}
    ]

    testAtomString [
	self json: '"hi"' equals: 'hi'.
	self json: '"\""' equals: '"'.
	self json: '"\\"' equals: '\'.
	self json: '""' equals: ''.
	self json: '"a\u0004b"'
	    equals: (String from: 
			{$a.
			Character value: 4.
			$b}).
	self json: '"a\nb"' equals: (String from: 
			{$a.
			Character lf.
			$b})
    ]

    testAtomTrue [
	self json: 'true' equals: true.
	self json: '  true' equals: true.
	self json: 'true  ' equals: true.
	self json: '  true  ' equals: true
    ]

    testCtor [
	self json: '@JsonDummyTestObject {"a": 1, "b": 2, "c": 3}'
	    equals: self simpleDummyObject.
	self json: (Json render: self simpleDummyObject)
	    equals: self simpleDummyObject
    ]

    testDictionary [
	self json: '{}' equals: JsonObject new.
	self json: '{"a": "a"}'
	    equals: ((JsonObject new)
		    at: 'a' put: 'a';
		    yourself).
	self json: '{"a": [[]]}'
	    equals: ((JsonObject new)
		    at: 'a' put: #(#());
		    yourself).
	self json: '{"a":"b", "b":"a"}'
	    equals: ((JsonObject new)
		    add: 'a' -> 'b';
		    add: 'b' -> 'a';
		    yourself)
    ]

    testMissingCtor [
	self should: [self readFrom: '@Missing[]'] raise: JsonSyntaxError
    ]

    testMissingCtorNoMap [
	self should: [Json new readFrom: '@Missing[]' readStream]
	    raise: JsonSyntaxError
    ]

    testStringWithUnicode [
	self json: '"\u263A"'
	    equals: (Character codePoint: 9786) asUnicodeString asString.
	self render: (Character codePoint: 9786) asUnicodeString asString
	    equals: '"\u263A"'
    ]

    testWriteAssociation [
	self render: 'key' -> 'value' equals: '"key": "value"'.
	self render: 'key' -> 2 equals: '"key": 2'.
	"keys should be strings"
	self render: 42 -> 2 equals: '"42": 2'.
	"try to do _something_ for more complex keys"
	self render: #(42 43 44) -> 2 equals: '"#(42 43 44)": 2'
    ]

    testWriteString [
	self render: '"' equals: '"\""'.
	self render: '\' equals: '"\\"'.
	self render: 'hi' equals: '"hi"'.
	self render: (String from: 
			{$a.
			Character lf.
			$b})
	    equals: '"a\nb"'.
	self render: (String from: 
			{$a.
			Character value: 4.
			$b})
	    equals: '"a\u0004b"'
    ]
]

