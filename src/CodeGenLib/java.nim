import std/[sequtils]

when defined(minimised):
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

type JavaFile* = ref object  # Allows empty initialisation
  namespace*:string  # So a custom namespace can be added for some weird reason
  className*:string  # The package name for the outputted Java file
  public*:bool  # This just defines the classes visibility, by default this is true
  final*:bool  # This defines if the class is final, by default this is false
  importStatements*:seq[string]  # Just collects all package imports
  extends*:string  # Not all classes extend, so this can be nil
  implements*:seq[string]  # All classes that the class extends, can be nil


proc newJavaFile*(className:string, namespace:string="", public:bool=true, final:bool=false):JavaFile =
  result = JavaFile()
  if namespace == "":
    result.namespace = globalNamespace
  else:
    result.namespace = namespace

  result.public = public
  result.final = final

  result.className = className


proc imprts*(jf:var JavaFile, importStmts:varargs[string]) =
  jf.importStatements = importStmts.toSeq()


proc extnds*(jf:var JavaFile, class:string) =
  jf.extends = class


proc impl*(jf:var JavaFile, implementClsses:varargs[string]) =
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

  if jf.public:
    constructed &= PUBLIC
  else:
    constructed &= PRIVATE

  if jf.final:
    constructed &= FINAL

  constructed &= CLASS_DECL & jf.className & SPACE

  if jf.extends != "":
    constructed &= EXTENDS_KW & jf.extends & SPACE

  if jf.implements.len != 0:
    constructed &= IMPLEMENTS_KW & jf.implements[0]
    jf.implements.del(0)

    if jf.implements.len != 0:
      for implement in jf.implements:
        constructed &= COMMA & implement

    constructed &= SPACE

  constructed &= OPEN_BRKT
  blocksWithin += 1



  constructed &= CLOSE_BRKT
  blocksWithin -= 1

  if blocksWithin != 0:
    echo "WARNING: The `blocksWithin` variable used internally to keep track of bracket level is not 0!"
    echo "The faulty class' package name is: " & jf.className

  return constructed