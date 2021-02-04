# Create a TypeScript Meta-model (FamixNG: since Moose 7) <!-- omit in toc -->

> MGL843: This readme was modified (temporarily) from [this Moose wiki page](https://moosetechnology.github.io/moose-wiki/Developers/CreateNewMetamodel.html) with some quick-start help for people less familiar with Pharo. This is not a reason to avoid learning how to use Pharo properly (see the Pharo MOOC referred to in the course's project description).
> Also, some of the links are relative to the original wiki, and will be broken here.

To analyse a system in a given programming language, Moose must have a meta-model for that language.
For example for Java, the meta-model defines that Java programs have classes, containing methods, invoking other methods, etc.
The meta-model describes the entities that compose a program in the given language and how they are related.

In the following, we describe how to create a new meta-model or extend an existing one.
Moose being more specifically dedicated to source code analysis, there are a number of pre-set entities/traits that should help one define new meta-models for a given programming language.
These are described in [another page](predefinedEntities.md) ![Unfinished](https://img.shields.io/badge/Progress-Unfinished-yellow.svg?style=flat).


- [Set up](#set-up)
- [Basic meta-model](#basic-meta-model)
  - [Define entities](#define-entities)
  - [Define hierarchy](#define-hierarchy)
  - [Define relations](#define-relations)
  - [Define properties](#define-properties)
  - [Generate](#generate)
- [FIN DU TUTORIEL](#fin-du-tutoriel)
- [Introducing traits](#introducing-traits)
- [Introducing submetamodels TODO](#introducing-submetamodels-todo)
  - [Set up submetamodels](#set-up-submetamodels)
  - [Define remote entities and traits](#define-remote-entities-and-traits)
  - [Define remote hierarchy](#define-remote-hierarchy)
  - [Define remote relations](#define-remote-relations)
  - [Complementary information](#complementary-information)
- [Thanks](#thanks)

## Set up

First of all, we need to [download Moose](../Beginners/InstallMoose.md) version 7 or higher.

The first step is to create a FamixMetamodelGenerator.
It will describe our meta-model.

> MGL843: To create a new class in Pharo, type <kbd>CTRL</kbd>-<kbd>O</kbd>-<kbd>B</kbd> to open a class browser in Moose. In the **+ New class** tab, paste the following, and type <kbd>CTRL</kbd>-<kbd>S</kbd>.

```st
FamixBasicInfrastructureGenerator subclass: #FamixTypeScriptGenerator
    slots: { }
    classVariables: { }
    package: 'Famix-TypeScript-Generator'
```

> MGL843: To verify we have created a sub-class of `FamixBasicInfrastructureGenerator`, select the **Hier.** radio button on the bar that starts with **All Packages**.

Then we need to configure the generator.
We have to specify the package in which the meta-model will be generated (not the same package as the Generator!).

```st
FamixTypeScriptGenerator class >> #packageName

    ^ #'Famix-TypeScript-Entities'
```

> MGL843: In Pharo documentation, [there is a convention for how methods are defined](http://rmod-pharo-mooc.lille.inria.fr/MOOC/PharoMOOC/Week1/C019-W1S06-ClassAndMethodDefinition.pdf#page=7). The text `FamixTypeScriptGenerator class >> #` **is not part of the method's definition**. It means "here is the definition of a class-side method in the `FamixTypeScriptGenerator` class." A class-side method is like a "static" method in Java. To add the `packageName` method:
> * click the **Class side** radio button in the browser window to change the browser to the class-side methods (as opposed to instance side).
> * select the **+ Class side method** tab to see an editor that allows creating the method.
> * select all the text in the editor, then paste everything *after* the `FamixTypeScriptGenerator class >> #`.
> * type <kbd>CTRL</kbd>-<kbd>S</kbd> to accept (save) the method. 

By default the package name will be used as a prefix for the generated classes.
But we can specify a custom prefix by defining the method `#prefix`.

```st
FamixTypeScriptGenerator class >> #prefix

    ^ #'FamixTypeScript'
```

> MGL843: Verify the new class-side methods `packageName` and `prefix` in the methods column for `FamixTypeScriptGenerator` class.

## Basic meta-model

In this section, we will see how to create a simple meta-model.

To design a meta-model, we need to specify its entities, their relations and their properties.

You may also consult a [presentation of Famix generator](https://www.slideshare.net/JulienDelp/famix-nextgeneration) from Julien Delplanque.

> MGL843: to follow the structure of the other metamodels (e.g., `FamixJava`), we have defined a sub-metamodel. `FamixTypeScriptGenerator` will inherit certain elements from `FamixBasicInfrastructureGenerator`, so we can reuse them later. It's not important for the basic model we are doing now.

### Define entities

A meta-model is composed of entities.
These entities represent the elements of the model we will manipulate.
To define entities in the generator, we extend the method `#defineClasses`.
Each entity is defined using the generator builder (provided by `FamixMetamodelGenerator`) to which we send the the message `#newClassNamed:`.

> MGL843: Before this step, look at the entities already defined by `FamixBasicInfrastructureGenerator>>#defineClasses`. Click the **Inst. side** radio button to view these methods--they are methods available to each object (instance of a class). For example, you should see `sourceAnchor`, `sourceLanguage`, `comment`, `namedEntity`, `sourceTextAnchor`, etc. These entities are common to many languages. Since the TypeScript meta-model is a subclass of this infrastructure, we won't need to define them again. 

> MGL843: As before, find the tab to add a new **+ Inst. side method**, and type everything *after* the `FamixTypeScriptGenerator>>#`. You will notice that several variables are in red in the editor, meaning they're not defined. When you attempt to save the new method, Pharo will offer a button to **Declare new instance variable**. Be careful which button you choose (if you choose the wrong one, you will have to undo this by hand).

```st
FamixTypeScriptGenerator>>#defineClasses

	super defineClasses.
	
	class := builder
		newClassNamed: #Class
		comment: 'I represent a TypeScript class or interface'.
	containerEntity := builder newClassNamed: #ContainerEntity.
	method := builder
		newClassNamed: #Method
		comment: 'I represent a method in a TypeScript class'.
	type := builder newClassNamed: #Type.
```

It is important to comment the entities to help other developers understand our meta-model.
This can be done with the `#newClassNamed:comment:` method.

> MGL843: See the definitions of the `class` and `method` above.

It is also possible to use entities that are already defined in a [library of predefined entities](predefinedEntities.md) or in another meta-model (see [submetamodels](#introducing-submetamodels)).

### Define hierarchy

Once the entities are defined, the next step is to specify their hierarchy.

| binary |             definition             |
| :----: | :--------------------------------: |
| <code>--&#124;></code> | Left entity extends (inherits from) the right one |
| <code><&#124;--</code> | Right entity extends (inherits from) the left one |

Note that these symbols are actually Pharo binary methods.
One can also use a Pharo keyword method: `#generalization:` defining that the receiver extends the parameter (i.e., similar to <code>--&#124;></code>).

The hierarchy is defined in the generator with the method `#defineHierarchy`.

```st
FamixTypeScriptGenerator>>#defineHierarchy

	super defineHierarchy.

	class --|> type.
	class --|> #TClass.
	class --|> #TLCOMMetrics.

	method --|> containerEntity.
	method --|> #TMethod.
	
	type --|> containerEntity.
	type --|> #TType.
	type --|> #TWithMethods.
```

### Define relations

Then we will define the relations between the entities.
Multiple relations are available in Famix.
In the following we present the relations and the keywords to define them.

|      method       | binary |
| :---------------: | :----: |
|   `#oneToOne:`    |  `-`   |
|   `#oneToMany:`   |  `-*`  |
|   `#manyToOne:`   |  `*-`  |
|  `#manyToMany:`   | `*-*`  |
|  `#containsOne:`  | `<>-`  |
| `#containsMany:`  | `<>-*` |
| `#oneBelongsTo:`  | `-<>`  |
| `#manyBelongsTo:` | `*-<>` |

We can now define the relations between the entities of our meta-model in the method `#defineRelations`.

> MGL843: For now, we won't define any relations.

### Define properties

The last step before generating the model is the definition of the properties of the entities.
A property can be of any type.
It is also possible to define a comment for each property.
Let's create the method `#defineProperties` in our generator:

```st
FamixTypeScriptGenerator>>#defineProperties

    super defineProperties.

```

> MGL843: The definition above is actually empty. For TypeScript it may be necessary to define properties (and relations) later.

### Generate

We have described our meta-model.
The last step is to actually generate it with: `FamixTypeScriptGenerator generate`.

> MGL843: The command above is executed in a Playground. It will generate many new Pharo classes that correspond to the meta-model we defined using the DSL above. Each time you change the meta-model, this step is necessary to re-generate the code.

> MGL843: Generated code is in the package specified by the `packageName` class-side method (`Famix-TypeScript-Entities` normally). You can right-click on this package to delete it and its classes if you want to re-generate the meta-model from scratch.

Later, if the description of the meta-model is modified, the generation will only regenerate the modified elements and remove the old ones.
It is possible to force a full (clean) generation of the model with: `FamixTypeScriptGenerator generateWithCleaning  "Instance of FamixTypeScriptGenerator class did not understand #generateWithCleaning"`.


## FIN DU TUTORIEL


## Introducing traits

(ne pas faire cette étape pour le tuto)

In addition to the entities, we can use traits to add information to the meta-model.
Traits are a flexible tool to avoid problems with multiple inheritance.
Traits are defined in the same way as entities.
In our previous example, classes are inside a package.
However, we forgot that a package can also contain another package, and we need to model that.

First of all, we need to define the traits to create the containment relation of a package.
We declare the trait in the method `#defineTraits`.

**NOTE:** (Modifier cette partie pour supporter les Modules/Namespaces en TypeScript? )

```st
defineTraits

    super defineTraits.

    tPackageable := builder newTraitNamed: #TPackageable comment: 'I can be inside a Package'.
    tWithPackages := builder newTraitNamed: #TWithPackages comment: 'I can contains packageable elements'.
```

Then, we have to change the hierarchy of our entity to add the traits.

```st
FamixTypeScriptGenerator>>#defineHierarchy

    super defineHierarchy.

    package --|> entity.
    package --|> tWithPackages.
    package --|> tPackageable.

    class --|> entity.
    class --|> tPackageable.

    method --|> entity.

    variable <|-- localVariable.
    variable <|-- attribute.
```

Finally, we define the relations between the traits.

```st
FamixTypeScriptGenerator>>#defineRelations
    super defineRelations.
    package <>-* class.
    package <>-* package.
    tWithPackages <>-* tPackageable.
    class <>-* attribute.
    class <>-* method.
    method <>-* localVariable
```

It is also possible to use traits that are already defined in another meta-model (see [submetamodels](#introducing-submetamodels)).

## Introducing submetamodels TODO

One powerful feature of Famix is the possibility to use submetamodels.
It allows one to extend or compose several meta-models.

There are two way of extending of meta-model:

1. Create a generator that extends the first one.
2. Create a separate generator that declares another as submetamodel.

Although the first one can be used, when the meta-model is generated, the entities that come from the extended generator will be created two times, in the new generator and in the old one.
So, the best way to extend a meta-model is to use the submetamodels.
In the following, we present how to configure a generator for submetamodels.

### Set up submetamodels

In this example, we will create a new generator that will add the interface entity that will be use to represent an interface.
The interface is packageable and contain methods.

> Note that it is done in an example. The best way in this case would be to modify the previous generator.

First of all, we create a new generator:

```st
FamixMetamodelGenerator subclass: #DemoInterfaceMetamodelGenerator
    slots: { }
    classVariables: { }
    package: 'Demo-InterfaceModel-Generator'
```

Then we declare our previous generator as submetamodel:

```st
DemoInterfaceMetamodelGenerator class >> #submetamodels

    ^ { DemoMetamodelGenerator }
```

> We also have to define the `#prefix` and the `#packageName`.

### Define remote entities and traits

Once the generator is configured we can define the entities of the AST meta-model and the entities that come from the Demo meta-model.
To define an entity of another meta-model we used the method `#remoteEntity:withPrefix:`.
The prefix is then the prefix defined for the submetamodel.

```st
DemoInterfaceMetamodelGenerator>>#defineEntities

    super defineEntities.
    interface := builder newClassNamed: #Interface.

    method := self remoteEntity: #Method withPrefix: #Demo.
```

> In some cases, it may be necessary to define remote traits. Use the method `#remoteTrait:withPrefix:` on the generator.

### Define remote hierarchy

To represent the relation of containment of a package on an interface, we use the trait `#TPackageable` (see [Introducing traits](#introducing-traits)).
Because there is only one trait with this name in the submetamodels, we can use the notation with the symbol instead of defining it in a variable in the "defineEntities" section:

```st
DemoInterfaceMetamodelGenerator>>#defineHierarchy

    super defineHierarchy.
    "use the trait of the other metamodel"
    interface --|> #TPackageable.
```

### Define remote relations

Finally, we create the relations between the interface and the methods:

```st
DemoInterfaceMetamodelGenerator>>#defineRelations
    super defineRelations.

    ((interface property: #methods) comment: 'The methods of the interface')
        <>-*
    ((method property: #interface) comment: 'The interface that own me').
```

### Complementary information

In our example, an interface contains methods and a class contains methods, too.
However, it is not possible to have *two* main containers for an entity (see [Define relations](#define-relations)).
In this case, we can either declare the relation "interface <>-* method" without a primary container, or define
two Traits in the first meta-model.
One would be `#TMethod` and the other `#TWithMethods`.

## Thanks

This wiki page is inspired by [the FamixNG booklet](https://github.com/SquareBracketAssociates/Booklet-FamixNG).
