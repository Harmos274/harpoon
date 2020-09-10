# Harpoon ⇌ Haskell driven package manager

Harpoon is a *just for fun* project made with Haskell language.
The goal of Harpoon is to request a database to download and install distant packages automatically.

It'll have to check what is your default package manager to automatically propose to download packages dependencies.

## Harpoon options

| Option                    | Description                                            |
|---------------------------|--------------------------------------------------------|
| help                      | Show help and version                                  |
| search *package*          | Search for a package                                   |
| get *package* *[version]* | Install a specific package optionally matching version |

**search** and **get** commands are online database requests which is hosted on *Github*.

## How looks the database ?
The database is a [JSON](https://fr.wikipedia.org/wiki/JavaScript_Object_Notation) file in a *Github* repo.

```JSON
{
	"packages": [
		{
			"name" : "package name",
			"description" : "package description",
			"locations" : [
				{ "version" : "package version", "url" : "package url" },
				{ "version" : "other version", "url" : "other package url" }
			]
		},
		{
			"name" : "package2 name",
			"description" : "package2 description",
			"locations" : [
				{ "version" : "package2 version", "url" : "package2 url" },
				{ "version" : "other p2 version", "url" : "other package2 url" }
			]
		}
	]
}
```

Packages are defined by their name, description and version. The location field is used to associate a version to a download link in order to compile the right version.


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
