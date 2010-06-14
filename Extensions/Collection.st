Collection extend [

    jsonWriteOn: aStream [
	"By default, use array braces"

	<category: '*json'>
	aStream nextPut: $[.
	self do: [:each | each jsonWriteOn: aStream]
	    separatedBy: [aStream nextPut: $,].
	aStream nextPut: $]
    ]

]

