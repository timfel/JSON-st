UndefinedObject extend [

    jsonWriteOn: aWriteStream [
	<category: '*JSON-writing'>
	aWriteStream nextPutAll: 'null'
    ]

]

