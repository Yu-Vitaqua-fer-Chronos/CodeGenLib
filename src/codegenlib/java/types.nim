import std/[
  strutils,
  options,
  tables
]

type
  JavaBase* = ref object of RootObj

  JavaBaseType* = ref object of JavaBase
    jparent*: Option[JavaBaseType]

  JavaCodeEmission* = ref object of JavaBaseType
    ## The raw Java code as a string, could be anything as long as it's valid
    jcode*: string

  JavaVariableDeclaration* = ref object of JavaBaseType
    jtyp*: string         ## The type of the variable
    jname*: string        ## The name of the variable
    jvalue*: string       ## The value of the variable, this can be empty *if* it's static
    jpublic*: bool        ## Allows you to declare a public variable
    jstatic*: bool        ## Have to use a stupid name, but declares a field as static
    jfinal*: bool         ## Declares the variable as final, making it unchangeable

  JavaMethodDeclaration* = ref object of JavaBaseType
    jreturnTyp*: string                ## The return type of the method
    jname*: string                     ## The name of the method
    jarguments*: OrderedTable[string, string] ## The name-type table
    jpublic*: bool                     ## Allows you to declare a public variable
    jstatic*: bool                     ## Declares a field as static
    jfinal*: bool                      ## Declares the variable as final, making it unchangeable
    jbody*: seq[JavaBaseType]          ## Allows for us to give different object types (such as variable declaration)

  JavaBlock* = ref object of JavaBaseType
    ## Used for representing if statements, for example
    jnames*: seq[string]               ## Name of the blocks
    jsnippets*: seq[seq[JavaBaseType]] ## The block of code that should be generated for each name

  JavaClass* = ref object of JavaBaseType
    ## Allows empty initialisation
    jname*: string            ## The package name for the outputted Java file
    jpublic*: bool            ## This just defines the classes visibility, by default this is true
    jstatic*: bool            ## Allows you to declare (inner) classes as static.
    jfinal*: bool             ## This defines if the class is final, by default this is false
    jextends*: string         ## Not all classes extend, so this can be nil
    jimplements*: seq[string] ## All classes that the class extends, can be nil
    jclassvars*: seq[JavaBaseType]    ## All class variables
    jclassmethods*: seq[JavaBaseType] ## All class functions (static or otherwise)

  JavaFile* = ref object of JavaBaseType
    jnamespace*: string             ## So a custom namespace can be added.
    jsubpackage*: string            ## Allows a subpackage to be added, such as "example"
    # jmainClass*: JavaClass          ## All files must have a public main class # TODO: Implement this.
    jclasses*: seq[JavaBaseType]    ## Classes stored as a sequence to be built
    jimportStatements*: seq[string] ## Just collects all package imports

  JavaBaseObject* = ref object of JavaBase

  JString* = ref object of JavaBaseObject
    value*: string

  CodeGenDefect* = object of Defect

  UnconstructableTypeDefect* = object of CodeGenDefect
  UncastableDefect* = object of CodeGenDefect

proc jstring*(str: string): JString = JString(value: str)

proc `$`*(str: JString): string =
  return str.value.escape()

proc `$`*(jce: JavaCodeEmission): string =
  return jce.jcode

proc `$`*(jb: JavaBase): string =
  if jb of JavaCodeEmission:
    return $JavaCodeEmission(jb)

  elif jb of JString:
    return $JString(jb)

  else:
    raise UncastableDefect.newException("Can't cast JavaBase!")