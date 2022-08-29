import std/[sequtils]

when defined(minimised): # Purely here for generating readable output
  const
    NEWLINE = ""
    INDENT = ""
else:
  const
    NEWLINE = "\n"
    INDENT = "    "

const
  LINE_SEP = ";" & NEWLINE
  OPEN_BRKT = "{" & NEWLINE
  CLOSE_BRKT = NEWLINE & "}"
  PUBLIC = "public "
  PRIVATE = "private "
  STATIC = "static "
  FINAL = "final "
  SPACE = " " # Would be preferred not to use this
  PKG_STMT = "package "
  IMPORT_STMT = "import "
  CLASS_DECL = "class "
  EXTENDS_KW = "extends "
  IMPLEMENTS_KW = "implements "

when defined(minimised):
  const
    EQUALS = "="
    COMMA = ","
else:
  const
    EQUALS = " = "
    COMMA = ", "


var globalNamespace* = "example"


type
  JavaVariableDeclaration* = ref object
    typ: string   # The type of the variable
    name: string  # The name of the variable
    value: string # The value of the variable, this can be empty *if* it's static
    public: bool  # Allows you to declare a public variable
    statik: bool  # Have to use a stupid name, but declares a field as static
    final: bool   # Declares the variable as final, making it unchangeable

  JavaClass* = ref object   # Allows empty initialisation
    name: string            # The package name for the outputted Java file
    public: bool            # This just defines the classes visibility, by default this is true
    final: bool             # This defines if the class is final, by default this is false
    extends: string         # Not all classes extend, so this can be nil
    implements: seq[string] # All classes that the class extends, can be nil
    classvars: seq[JavaVariableDeclaration] # All class variables

  JavaFile* = ref object
    namespace: string             # So a custom namespace can be added for some weird reason
    subpackage: string            # Allows a subpackage to be added, such as "example"
    classes: seq[JavaClass]       # Classes stored as a sequence to be built
    importStatements: seq[string] # Just collects all package imports


proc newJavaFile*(subpackage: string = "", namespace: string = ""): JavaFile =
  result = JavaFile()

  if namespace == "":
    result.namespace = globalNamespace
  else:
    result.namespace = namespace

  result.subpackage = subpackage


proc newJavaClass*(name: string, public: bool = true,
    final: bool = false): JavaClass =
  result = JavaClass()

  result.public = public
  result.final = final

  result.name = name


proc newJavaVariableDeclaration*(typ: string, name: string, value:string="", public: bool = false,
    statik: bool = false,
    final: bool = false): JavaVariableDeclaration =
  result = JavaVariableDeclaration()

  result.typ = typ
  result.name = name
  result.value = value
  result.public = public
  result.statik = statik
  result.final = final


proc addClassVariable*(cls:var JavaClass, clsvars:varargs[JavaVariableDeclaration]) =
  for clsvar in clsvars:
    cls.classvars.add clsvar


proc addJavaClass*(jf: var JavaFile, clsses: varargs[JavaClass]) =
  for cls in clsses:
    jf.classes.add cls


proc imports*(jf: var JavaFile, importStmts: varargs[string]) =
  jf.importStatements = importStmts.toSeq()


proc extends*(cls: var JavaClass, class: string) =
  cls.extends = class


proc implements*(cls: var JavaClass, implementClsses: varargs[string]) =
  cls.implements = implementClsses.toSeq()


proc construct*(jf: JavaFile): string =
  # Will be used to keep track of brackets, should always
  # be 0 at the end, if not, something went wrong!
  var blocksWithin = 0

  var constructed = PKG_STMT & jf.namespace & LINE_SEP
  constructed &= NEWLINE


  for imprt in jf.importStatements:
    constructed &= IMPORT_STMT & imprt & LINE_SEP
  constructed &= NEWLINE


  for cls in jf.classes:
    if cls.public:
      constructed &= PUBLIC
    else:
      constructed &= PRIVATE

    if cls.final:
      constructed &= FINAL

    constructed &= CLASS_DECL & cls.name & SPACE


    if cls.extends != "":
      constructed &= EXTENDS_KW & cls.extends & SPACE


    if cls.implements.len != 0:
      constructed &= IMPLEMENTS_KW & cls.implements[0]
      cls.implements.del(0)

      if cls.implements.len != 0:
        for implement in cls.implements:
          constructed &= COMMA & implement
      constructed &= SPACE


    constructed &= OPEN_BRKT
    blocksWithin += 1


    for classvar in cls.classvars:
      constructed &= INDENT

      if classvar.public:
        constructed &= PUBLIC
      else:
        constructed &= PRIVATE

      if classvar.statik:
        constructed &= STATIC

      if classvar.final:
        constructed &= FINAL

      constructed &= classvar.typ & SPACE & classvar.name

      if classvar.statik and classvar.value == "":
        echo "WARNING: The class `" & cls.name & "` is static but with no value! This will error in javac!"

      if classvar.value != "":
        constructed &= EQUALS & classvar.value

      constructed &= LINE_SEP


    constructed &= CLOSE_BRKT
    blocksWithin -= 1


  if blocksWithin != 0:
    echo "WARNING: The `blocksWithin` variable used internally to keep track of brackets, is not 0!"
    if jf.subpackage != "":
      echo "The faulty package is: " & jf.namespace & "." & jf.subpackage
    else:
      echo "The faulty package is: " & jf.namespace


  return constructed
