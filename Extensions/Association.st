Association extend [

    jsonWriteOn: aStream [
	<category: '*JSON-writing'>
	self key asString jsonWriteOn: aStream.
	aStream
	    nextPut: $:;
	    space.
	self value jsonWriteOn: aStream
    ]

]

