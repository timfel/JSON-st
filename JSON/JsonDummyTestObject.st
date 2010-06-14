Object subclass: JsonDummyTestObject [
    | a b c |
    
    <category: 'JSON'>
    <comment: nil>

    JsonDummyTestObject class >> constructFromJson: j [
	^(self new)
	    a: (j at: 'a');
	    b: (j at: 'b');
	    c: (j at: 'c');
	    yourself
    ]

    = other [
	^other class == self class 
	    and: [a = other a and: [b = other b and: [c = other c]]]
    ]

    jsonWriteOn: s [
	Json 
	    renderInstanceVariables: 
		{#a.
		#b.
		#c}
	    of: self
	    on: s
    ]

    a [
	"Answer the value of a"

	<category: 'accessing'>
	^a
    ]

    a: anObject [
	"Set the value of a"

	<category: 'accessing'>
	a := anObject
    ]

    b [
	"Answer the value of b"

	<category: 'accessing'>
	^b
    ]

    b: anObject [
	"Set the value of b"

	<category: 'accessing'>
	b := anObject
    ]

    c [
	"Answer the value of c"

	<category: 'accessing'>
	^c
    ]

    c: anObject [
	"Set the value of c"

	<category: 'accessing'>
	c := anObject
    ]
]

