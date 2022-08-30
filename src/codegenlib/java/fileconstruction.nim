import std/[strutils, tables]

import ../java
import ./keywords
import ./types


when defined(minimised):
  const NINDENT = ""
else:
  template NINDENT():string = (repeat(INDENT, blocksWithin))


proc newJavaFile*(subpackage: string = "", namespace: string = ""): JavaFile =
  result = JavaFile()

  if namespace == "":
    result.jnamespace = globalNamespace
  else:
    result.jnamespace = namespace

  result.jsubpackage = subpackage


proc addJavaClass*(jf: var JavaFile, clsses: varargs[JavaClass]) =
  for cls in clsses:
    cls.jparent = jf
    jf.jclasses.add cls


proc imports*(jf: var JavaFile, importStmts: varargs[string]) =
  for importStmt in importStmts:
    jf.jimportStatements.add importStmt


proc classVarConstruction(jobj:JavaBaseType, blocksWithin:var int):string =
  var constructed = ""

  if jobj of JavaCodeEmission:
    constructed &= jobj.JavaCodeEmission.jcode

  elif jobj of JavaVariableDeclaration:
    let classvar = JavaVariableDeclaration jobj
    constructed &= NINDENT

    if classvar.jpublic:
      constructed &= PUBLIC
    else:
      constructed &= PRIVATE

    if classvar.jstatik:
      constructed &= STATIC

    if classvar.jfinal:
      constructed &= FINAL

    constructed &= classvar.jtyp & SPACE & classvar.jname

    if classvar.jstatik and classvar.jvalue == "":
      echo "WARNING: The class `" & JavaClass(classvar.jparent).jname & "` is static but with no value! This will error in javac!"

    if classvar.jvalue != "":
      constructed &= EQUALS & classvar.jvalue

    constructed &= LINE_SEP

  return constructed


proc methodConstruction(jobj:JavaBaseType, blocksWithin:var int): string =
  if jobj of JavaCodeEmission:
    result &= jobj.JavaCodeEmission.jcode
  elif jobj of JavaMethodDeclaration:
    let jmthd = JavaMethodDeclaration jobj

    result &= NEWLINE & NINDENT

    if jmthd.jpublic:
      result &= PUBLIC
    else:
      result &= PRIVATE

    if jmthd.jstatik:
      result &= STATIC

    if jmthd.jfinal:
      result &= FINAL

    result &= jmthd.jreturnTyp & SPACE

    result &= jmthd.jname & OPEN_PAREN

    var firstarg = true
    for name, typ in jmthd.jarguments.pairs:
      if firstarg:
        result &= typ & SPACE & name
        firstarg = false
      else:
        result &= COMMA & typ & SPACE & name

    result &= CLOSE_PAREN

    blocksWithin += 1
    result &= SPACE & OPEN_BRKT & NEWLINE

    for item in jmthd.jbody:
      result &= item.JavaCodeEmission.jcode

    blocksWithin -= 1
    result &= NEWLINE & NINDENT & CLOSE_BRKT


proc classConstruction(jobj:JavaBaseType, blocksWithin:var int):string =
  if jobj of JavaCodeEmission:
    result &= jobj.JavaCodeEmission.jcode

  elif jobj of JavaClass:
    let cls = JavaClass jobj
    if cls.jpublic:
      result &= PUBLIC
    else:
      result &= PRIVATE

    if cls.jfinal:
      result &= FINAL

    result &= CLASS_DECL & cls.jname & SPACE


    if cls.jextends != "":
      result &= EXTENDS_KW & cls.jextends & SPACE


    if cls.jimplements.len != 0:
      result &= IMPLEMENTS_KW & cls.jimplements[0]
      cls.jimplements.del(0)

      if cls.jimplements.len != 0:
        for implement in cls.jimplements:
          result &= COMMA & implement
      result &= SPACE


    result &= NINDENT & OPEN_BRKT & NEWLINE
    blocksWithin += 1

    for classvar in cls.jclassvars:
      result &= classvar.classVarConstruction(blocksWithin)

    for jmethod in cls.jclassmethods:
      result &= jmethod.methodConstruction(blocksWithin)

    result &= NINDENT & NEWLINE & CLOSE_BRKT
    blocksWithin -= 1


proc `$`*(jf: JavaFile): string =
  # Will be used to keep track of brackets, should always
  # be 0 at the end, if not, something went wrong!
  var blocksWithin = 0

  result &= PKG_STMT & jf.jnamespace

  if jf.jsubpackage != "":
    result &= DOT & jf.jsubpackage

  result &= LINE_SEP & NEWLINE


  for imprt in jf.jimportStatements:
    result &= IMPORT_STMT & imprt & LINE_SEP
  result &= NEWLINE


  for clss in jf.jclasses:
    result &= clss.classConstruction(blocksWithin)

  if blocksWithin != 0:
    echo "WARNING: The `blocksWithin` variable used internally to keep track of brackets, is not 0!"
    if jf.jsubpackage != "":
      echo "The faulty package is: " & jf.jnamespace & "." & jf.jsubpackage
    else:
      echo "The faulty package is: " & jf.jnamespace