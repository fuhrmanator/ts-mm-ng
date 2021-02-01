Class {
	#name : #FamixTypeScriptGenerator,
	#superclass : #FamixBasicInfrastructureGenerator,
	#instVars : [
		'class',
		'method',
		'variable',
		'localVariable',
		'attribute'
	],
	#category : #'Famix-TypeScript-Generator'
}

{ #category : #accessing }
FamixTypeScriptGenerator class >> packageName [

    ^ #'Famix-TypeScript-Entities'
]

{ #category : #accessing }
FamixTypeScriptGenerator class >> prefix [

    ^ #'FamixTS'
]

{ #category : #definition }
FamixTypeScriptGenerator >> defineClasses [

    super defineClasses.
    entity := builder newClassNamed: #Entity.
    class := builder newClassNamed: #Class comment: 'I represent a TypeScript class'.
    method := builder newClassNamed: #Method.
    variable := builder newClassNamed: #Variable.
    localVariable := builder newClassNamed: #LocalVariable.
    attribute := builder newClassNamed: #Attribute.

]

{ #category : #definition }
FamixTypeScriptGenerator >> defineHierarchy [

    super defineHierarchy.
"    class --|> entity.
    method --|> entity."

    variable <|-- localVariable.
    variable <|-- attribute.
]

{ #category : #definition }
FamixTypeScriptGenerator >> defineProperties [

    super defineProperties.

   "(entity property: #name type: #String)
       comment: 'The name of the entity'."
]
