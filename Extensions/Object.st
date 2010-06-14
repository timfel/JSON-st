Object extend [

    asJsonString [
	<category: '*JSON'>
	^String streamContents: [:str | self jsonWriteOn: str]
    ]

]

