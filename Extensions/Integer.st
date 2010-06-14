Integer extend [

    jsonWriteOn: aWriteStream [
	<category: '*JSON-writing'>
	^self printOn: aWriteStream base: 10
    ]

]

