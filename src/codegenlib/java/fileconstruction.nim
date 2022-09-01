import std/[strutils, tables]

import ./keywords
import ./types


when defined(minimised):
  const NINDENT = ""
else:
  template NINDENT():string = (repeat(INDENT, blocksWithin))


proc constructionHelper(jobj:JavaBaseType, blocksWithin:var int):string  # Forward declaration


proc construct(jcemission:JavaCodeEmission, blocksWithin:var int):string =
  result &= jcemission.jcode


proc construct(variable:JavaVariableDeclaration, blocksWithin:var int):string =
  result &= NINDENT

  if not (variable.jparent of JavaMethodDeclaration) or not (variable.jparent of JavaBlock):
    if variable.jpublic:
      result &= PUBLIC
    else:
      result &= PRIVATE

    if variable.jstatik:
      result &= STATIC

  if variable.jfinal:
    result &= FINAL

  if variable.jtyp != "":
    result &= variable.jtyp & SPACE

  result &= variable.jname

  if variable.jstatik and variable.jvalue == "":
    echo "WARNING: The class `" & JavaClass(variable.jparent).jname & "` is static but with no value! This will error in javac!"

  if variable.jvalue != "":
    result &= EQUALS & variable.jvalue

  result &= LINE_SEP


proc construct(jmthd:JavaMethodDeclaration, blocksWithin:var int): string =
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
    result &= constructionHelper(item, blocksWithin)

  blocksWithin -= 1
  result &= NEWLINE & NINDENT & CLOSE_BRKT


proc construct(cls:JavaClass, blocksWithin:var int):string =
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
    result &= classvar.constructionHelper(blocksWithin)

  for jmethod in cls.jclassmethods:
    result &= jmethod.constructionHelper(blocksWithin)

  result &= NINDENT & NEWLINE & CLOSE_BRKT
  blocksWithin -= 1


proc construct(jf:JavaFile, blocksWithin:var int):string =
  result &= PKG_STMT & jf.jnamespace

  if jf.jsubpackage != "":
    result &= DOT & jf.jsubpackage

  result &= LINE_SEP & NEWLINE


  for imprt in jf.jimportStatements:
    result &= IMPORT_STMT & imprt & LINE_SEP
  result &= NEWLINE


  for clss in jf.jclasses:
    result &= clss.constructionHelper(blocksWithin)

  if blocksWithin != 0:
    echo "WARNING: The `blocksWithin` variable used internally to keep track of brackets, is not 0!"
    if jf.jsubpackage != "":
      echo "The faulty package is: " & jf.jnamespace & "." & jf.jsubpackage
    else:
      echo "The faulty package is: " & jf.jnamespace


proc construct(jb:JavaBlock, blocksWithin:var int):string =
  result &= NEWLINE & NINDENT

  for i in 0..min(jb.jnames.high, jb.jsnippets.high):
    if i != 0:
      result &= PSPACE

    blocksWithin += 1
    result &= jb.jnames[i] & PSPACE & OPEN_BRKT

    for snippet in jb.jsnippets[i]:
      result &= NEWLINE & NINDENT & snippet.constructionHelper(blocksWithin)

    blocksWithin -= 1
    result &= NEWLINE & NINDENT & CLOSE_BRKT

    if i != 0:
      result &= PSPACE

  result &= NEWLINE


proc constructionHelper(jobj:JavaBaseType, blocksWithin:var int):string =
  if jobj of JavaFile:
    result &= JavaFile(jobj).construct(blocksWithin)

  elif jobj of JavaClass:
    result &= JavaClass(jobj).construct(blocksWithin)

  elif jobj of JavaVariableDeclaration:
    result &= JavaVariableDeclaration(jobj).construct(blocksWithin)

  elif jobj of JavaMethodDeclaration:
    result &= JavaMethodDeclaration(jobj).construct(blocksWithin)

  elif jobj of JavaBlock:
    result &= JavaBlock(jobj).construct(blocksWithin)

  elif jobj of JavaCodeEmission:
    result &= JavaCodeEmission(jobj).construct(blocksWithin)

  else:
    raise newException(UnconstructableTypeDefect, "We can't build this object! Has the construction method been implemented in `fileconstruction.constructionHelper`?")

proc `$`*(javafile: JavaFile): string =
  # Will be used to keep track of brackets, should always
  # be 0 at the end, if not, something went wrong!
  var blocksWithin = 0

  return javafile.constructionHelper(blocksWithin)
