import std/[
  strutils,
  options,
  tables,
  sugar
]

import ./keywords
import ./types

proc construct*(jobj: JavaBaseType, blocksWithin: var int): string  # Forward declaration

proc construct(jcemission: JavaCodeEmission, blocksWithin: var int): string =
  # Won't work well for *all* code but, would be nice for prettifying
  result &= repeat(INDENT, blocksWithin) & jcemission.jcode


proc construct(variable: JavaVariableDeclaration, blocksWithin: var int): string =
  result &= repeat(INDENT, blocksWithin)

  if variable.jparent.isSome:
    if variable.jparent.get() of JavaMethodDeclaration:
      discard

    elif variable.jparent.get() of JavaBlock:
      discard

    else:
      if variable.jpublic:
        result &= PUBLIC & SPACE
      else:
        result &= PRIVATE & SPACE

      if variable.jstatic:
        result &= STATIC & SPACE


  if variable.jfinal:
    result &= FINAL & SPACE

  if variable.jtyp != "":
    result &= variable.jtyp & SPACE

  result &= variable.jname

  if variable.jstatic and variable.jvalue == "":
    echo "WARNING: The class variable `" & variable.jname &
      "` is static but with no value! This will error in javac!"

  if variable.jvalue != "":
    result &= EQUALS & variable.jvalue

  result &= SEMICOLON


proc construct(jmthd: JavaMethodDeclaration, blocksWithin: var int): string =
  result &= repeat(INDENT, blocksWithin)

  if jmthd.jpublic:
    result &= PUBLIC & SPACE
  else:
    result &= PRIVATE & SPACE

  if jmthd.jstatic:
    result &= STATIC & SPACE

  if jmthd.jfinal:
    result &= FINAL & SPACE

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

  let snippets = collect(newSeq):
    for snippet in jmthd.jbody:
      construct(snippet, blocksWithin)

  result &= snippets.join(NEWLINE)

  blocksWithin -= 1
  result &= NEWLINE & repeat(INDENT, blocksWithin) & CLOSE_BRKT


proc construct(cls: JavaClass, blocksWithin: var int): string =
  result &= NEWLINE & repeat(INDENT, blocksWithin)

  if cls.jpublic:
    result &= PUBLIC & SPACE
  else:
    result &= PRIVATE & SPACE

  if cls.jstatic:
    result &= STATIC & SPACE

  if cls.jfinal:
    result &= FINAL & SPACE

  result &= CLASS_DECL & SPACE & cls.jname

  if cls.jextends != "":
    result &= SPACE & EXTENDS_KW & SPACE & cls.jextends

  if cls.jimplements.len != 0:
    result &= SPACE & IMPLEMENTS_KW & SPACE & cls.jimplements.join(COMMA)

  result &= SPACE & OPEN_BRKT & NEWLINE
  blocksWithin += 1

  let vsnippets = collect(newSeq):
    for snippet in cls.jclassvars:
      construct(snippet, blocksWithin)

  result &= vsnippets.join(NEWLINE)

  if (cls.jclassmethods.len != 0) and (cls.jclassvars.len != 0):
    result &= NEWLINE

  let jsnippets = collect(newSeq):
    for snippet in cls.jclassmethods:
      construct(snippet, blocksWithin)

  result &= jsnippets.join(NEWLINE)

  result &= repeat(INDENT, blocksWithin) & NEWLINE & CLOSE_BRKT
  blocksWithin -= 1


proc construct(jf: JavaFile, blocksWithin: var int): string =
  result &= PKG_STMT & SPACE & jf.jnamespace

  if jf.jsubpackage != "":
    result &= DOT & jf.jsubpackage

  result &= SEMICOLON & repeat(NEWLINE, 2)


  for imprt in jf.jimportStatements:
    result &= IMPORT_STMT & SPACE & imprt & SEMICOLON & NEWLINE

  for clss in jf.jclasses:
    result &= clss.construct(blocksWithin)

  if blocksWithin != 0:
    echo "WARNING: The `blocksWithin` variable used internally to keep track of brackets, is not 0!"
    if jf.jsubpackage != "":
      echo "The faulty package is: " & jf.jnamespace & "." & jf.jsubpackage
    else:
      echo "The faulty package is: " & jf.jnamespace


proc construct(jb: JavaBlock, blocksWithin: var int): string =
  result &= repeat(INDENT, blocksWithin)

  for i in 0..min(jb.jnames.high, jb.jsnippets.high):
    if i != 0:
      result &= SPACE

    blocksWithin += 1
    result &= jb.jnames[i] & SPACE & OPEN_BRKT & NEWLINE

    let snippets = collect(newSeq):
      for snippet in jb.jsnippets[i]:
        construct(snippet, blocksWithin)

    result &= snippets.join(NEWLINE)

    blocksWithin -= 1
    result &= NEWLINE & repeat(INDENT, blocksWithin) & CLOSE_BRKT

    if i != 0:
      result &= SPACE


proc construct*(jobj: JavaBaseType, blocksWithin: var int): string =
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
    raise newException(UnconstructableTypeDefect, "We can't build this object! Please provide an accessible implementation!")

proc construct*[T: JavaBaseType](jobj: T, blocksWithin: var int = 0): string =
  var nestedBlocks = blocksWithin

  jobj.construct(nestedBlocks)

proc construct*[T: JavaBaseType](jobj: T, blocksWithin: int = 0): string =
  var nestedBlocks = blocksWithin

  jobj.construct(nestedBlocks)