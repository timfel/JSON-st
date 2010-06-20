Association extend [

    jsonWriteOn: aStream [
	<category: '*JSON-writing'>
	((self key isCollection and: [self key isString not]) 
            ifTrue: ['#', self key printString]
	    ifFalse: [self key asString]) jsonWriteOn: aStream.
	aStream
	    nextPut: $:;
	    space.
	self value jsonWriteOn: aStream
    ]

]

