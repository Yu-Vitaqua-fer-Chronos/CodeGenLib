import std/[sequtils]

when defined(minimised):  # Purely here for generating readable output
  const NEWLINE = ""
else:
  const NEWLINE = "\n"

const
  LINE_SEP = ";" & NEWLINE
  OPEN_BRKT = "{" & NEWLINE
  CLOSE_BRKT = NEWLINE & "}"
  PUBLIC = "public "
  PRIVATE = "private "
  STATIC = "static "
  FINAL = "final "
  COMMA = ", "
  SPACE = " "  # Would be preferred not to use this
  PKG_STMT = "package "
  IMPORT_STMT = "import "
  CLASS_DECL = "class "
  EXTENDS_KW = "extends "
  IMPLEMENTS_KW = "implements "


var globalNamespace* = "example"


type JavaClass* = ref object  # Allows empty initialisation
  name:string  # The package name for the outputted Java file
  public:bool  # This just defines the classes visibility, by default this is true
  final:bool  # This defines if the class is final, by default this is false
  importStatements:seq[string]  # Just collects all package imports
  extends:string  # Not all classes extend, so this can be nil
  implements:seq[string]  # All classes that the class extends, can be nil


type JavaFile* = ref object
  namespace:string  # So a custom namespace can be added for some weird reason
  subpackage:string  # Allows a subpackage to be added, such as "example"
  classes:seq[JavaClass]


proc newJavaFile*(subpackage:string="", namespace:string=""):JavaFile =
  result = JavaFile()

  if namespace == "":
    result.namespace = globalNamespace
  else:
    result.namespace = namespace

  result.subpackage = subpackage


proc newJavaClass*(name:string, public:bool=true, final:bool=false):JavaClass =
  result = JavaClass()

  result.public = public
  result.final = final

  result.name = name


proc addJavaClass(jf:var JavaFile, clsses:varargs[JavaClass]) =
  for cls in clsses:
    jf.classes.add cls


proc imports*(jf:var JavaClass, importStmts:varargs[string]) =
  jf.importStatements = importStmts.toSeq()


proc extends*(jf:var JavaClass, class:string) =
  jf.extends = class


proc implements*(jf:var JavaClass, implementClsses:varargs[string]) =
  jf.implements = implementClsses.toSeq()


proc construct*(jf:JavaFile):string =
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



    constructed &= CLOSE_BRKT
    blocksWithin -= 1


  if blocksWithin != 0:
    echo "WARNING: The `blocksWithin` variable used internally to keep track of brackets, is not 0!"
    if jf.subpackage != "":
      echo "The faulty package is: " & jf.namespace & "." & jf.subpackage
    else:
      echo "The faulty package is: " & jf.namespace


  return constructed
