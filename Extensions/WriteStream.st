WriteStream extend [

    jsonPrint: anObject [
	<category: '*json-printing'>
	anObject jsonWriteOn: self
    ]

]

