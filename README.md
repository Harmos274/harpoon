# Harpoon ⇌ Haskell driven package manager

Harpoon is a *just for fun* project made with Haskell langage.
The goal of Harpoon is to request a database to download and install distant packages automatically.

It'll have to check what is your default package manager to automatically propose to download packages dependencies.

## How to create a harpoon file ?

In order to indicate how your package has to be installed you have to indicate some information to Harpoon with the help of a `.harpoon` file.

This is how a `.harpoon` is composed :

```
# comment
Name : package_name
Version : package_version
Type : dll / bin
InnerDeps : harpoon_dependency
OuterDeps : extern_dependency
TempInnerDeps : building_dependency
TempOuterDeps : building_dependency
CompilationBackend : cmake / make / ninja / scripts ...
```
note : Deps fields are optional and accepts multiple dependencies, just report them space delimited.

## How to publish a Harpoon package ?

Todo.
