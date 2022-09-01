import std/tables

type
  JavaBaseType* = ref object of RootObj
    jparent*:JavaBaseType

  JavaCodeEmission* = ref object of JavaBaseType
    jcode*:string # The raw Java code as a string, could be anything as long as it's valid

  JavaWrapperObject* = ref object of JavaBaseType
    jname*:string # The name of the Java object we're referencing

  JavaMethodWrapper* = ref object of JavaWrapperObject
    jarguments*:seq[OrderedTable[string, string]] # The arguments of the Java method, as a sequence of tables

  JavaClassWrapper* = ref object of JavaWrapperObject
    jmethods*:seq[JavaMethodWrapper] # Methods that a class owns
    jclasses*:seq[JavaClassWrapper]  # For nested classes (that are public)

  JavaVariableDeclaration* = ref object of JavaBaseType
    jtyp*: string         # The type of the variable
    jname*: string        # The name of the variable
    jvalue*: string       # The value of the variable, this can be empty *if* it's static
    jpublic*: bool        # Allows you to declare a public variable
    jstatik*: bool        # Have to use a stupid name, but declares a field as static
    jfinal*: bool         # Declares the variable as final, making it unchangeable

  JavaMethodDeclaration* = ref object of JavaBaseType
    jreturnTyp*: string                # The return type of the method
    jname*: string                     # The name of the method
    jarguments*: OrderedTable[string, string] # The name-type table
    jpublic*: bool                     # Allows you to declare a public variable
    jstatik*: bool                     # Have to use a stupid name, but declares a field as static
    jfinal*: bool                      # Declares the variable as final, making it unchangeable
    jbody*: seq[JavaBaseType]          # Allows for us to give different object types (such as variable declaration)

  JavaBlock* = ref object of JavaBaseType # Used for representing if statements, for example
    jnames*: seq[string]               # Name of the blocks
    jsnippets*: seq[seq[JavaBaseType]] # The block of code that should be generated for each name

  JavaClass* = ref object of JavaBaseType # Allows empty initialisation
    jname*: string            # The package name for the outputted Java file
    jpublic*: bool            # This just defines the classes visibility, by default this is true
    jfinal*: bool             # This defines if the class is final, by default this is false
    jextends*: string         # Not all classes extend, so this can be nil
    jimplements*: seq[string] # All classes that the class extends, can be nil
    jclassvars*: seq[JavaBaseType]  # All class variables
    jclassmethods*: seq[JavaBaseType] # All class functions (static or otherwise)

  JavaFile* = ref object of JavaBaseType
    jnamespace*: string             # So a custom namespace can be added for some weird reason
    jsubpackage*: string            # Allows a subpackage to be added, such as "example"
    jclasses*: seq[JavaBaseType]       # Classes stored as a sequence to be built
    jimportStatements*: seq[string] # Just collects all package imports


type
  UnconstructableTypeDefect* = object of Defect