String extend [

    jsonWriteOn: aStream [
	<category: '*JSON-writing'>
	| replacement |
	aStream nextPut: $".
	self do: 
		[:ch | 
		replacement := (Json escapeForCharacter: ch) asString.
		aStream nextPutAll: replacement].
	aStream nextPut: $"
    ]

]

