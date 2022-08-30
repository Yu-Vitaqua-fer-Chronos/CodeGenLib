# CodeGenLib
A code generation library for other programming languages, in Nim! This is really made for projects such as [Nimpiler](https://github.com/Mythical-Forest-Collective/Nimpiler), but it can be used in anything really! If you're using CodeGenLib in your own project, make a github issue to let us know and we can add it to the list here!

## How To Install
To install CodeGenLib, just do `nimble install CodeGenLib`!

## Currently Implemented Languages
* Java
  * Mostly complete, just need to implement a way to create 'bindings' to Java modules so they can be used near seamlessly within the code.

## Languages To Implement
* Lua 5.1
  * Reason why we want to implement Lua 5.1 specifically is so we can find ways around gotos, so more of Nim's semantics can be translated more accurately to Lua (though not against adding things such as `goto`s, or other features from future versions).
* Python 3.8
  * Python 3.8 EoL is in 2 years approx (as of the time writing this) and I think it'd be one of the more common versions for a while, meaning it just makes sense to support this instead of anything newer (for now).