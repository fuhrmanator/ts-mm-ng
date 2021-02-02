Class {
	#name : #FamixTypeScriptGenerator,
	#superclass : #FamixBasicInfrastructureGenerator,
	#instVars : [
		'class',
		'method',
		'type',
		'containerEntity',
		'rootEntity'
	],
	#category : #'Famix-TypeScript-Generator'
}

{ #category : #accessing }
FamixTypeScriptGenerator class >> packageName [

    ^ #'Famix-TypeScript-Entities'
]

{ #category : #accessing }
FamixTypeScriptGenerator class >> prefix [

    ^ #'FamixTypeScript'
]

{ #category : #definition }
FamixTypeScriptGenerator >> defineClasses [
	super defineClasses.
	rootEntity := builder ensureClassNamed: #Entity.
	class := builder
		newClassNamed: #Class
		comment: 'I represent a TypeScript class or interface'.
	containerEntity := builder newClassNamed: #ContainerEntity.
	method := builder
		newClassNamed: #Method
		comment: 'I represent a method in a TypeScript class'.
	type := builder newClassNamed: #Type.
]

{ #category : #definition }
FamixTypeScriptGenerator >> defineHierarchy [
	super defineHierarchy.

	class --|> type.
	class --|> #TClass.
	class --|> #TLCOMMetrics.

	method --|> containerEntity.
	method --|> #TMethod.
	
	type --|> containerEntity.
	type --|> #TType.
	type --|> #TWithMethods.

]

{ #category : #definition }
FamixTypeScriptGenerator >> defineProperties [

    super defineProperties.

   (rootEntity property: #name type: #String)
       comment: 'The name of the entity'.
]
