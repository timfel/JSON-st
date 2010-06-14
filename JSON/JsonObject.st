Dictionary subclass: JsonObject [
    
    <category: 'JSON'>
    <comment: nil>

    JsonObject class >> fromAssociations: collectionOfAssociations [
	| result |
	result := self new.
	collectionOfAssociations do: [:each | result at: each key put: each value].
	^result
    ]

    at: aKey [
	"make it work more like javascript objects"

	<category: 'accessing'>
	^self at: aKey ifAbsent: [nil]
    ]

    name [
	"override 'cause Object defines this"

	<category: 'accessing'>
	^self at: 'name'
    ]

    value [
	"override 'cause Object defines this"

	<category: 'accessing'>
	^self at: 'value'
    ]

    doesNotUnderstand: aMessage [
	| key |
	key := aMessage selector.
	key isUnary ifTrue: [^self at: key ifAbsent: [nil]].
	^(key isKeyword and: [(key occurrencesOf: $:) = 1]) 
	    ifTrue: 
		[key := key allButLast asSymbol.
		self at: key put: aMessage arguments first]
	    ifFalse: [super doesNotUnderstand: aMessage]
    ]
]

