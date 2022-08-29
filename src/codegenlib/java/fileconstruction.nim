import ../java
import ./keywords
import ./types


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


proc `$`*(jf: JavaFile): string =
  # Will be used to keep track of brackets, should always
  # be 0 at the end, if not, something went wrong!
  var blocksWithin = 0

  var constructed = PKG_STMT & jf.jnamespace

  if jf.jsubpackage != "":
    constructed &= DOT & jf.jsubpackage

  constructed &= LINE_SEP & NEWLINE


  for imprt in jf.jimportStatements:
    constructed &= IMPORT_STMT & imprt & LINE_SEP
  constructed &= NEWLINE


  for clss in jf.jclasses:
    if clss of JavaCodeEmission:
      constructed &= clss.JavaCodeEmission.jcode

    elif clss of JavaClass:
      let cls = JavaClass clss
      if cls.jpublic:
        constructed &= PUBLIC
      else:
        constructed &= PRIVATE

      if cls.jfinal:
        constructed &= FINAL

      constructed &= CLASS_DECL & cls.jname & SPACE


      if cls.jextends != "":
        constructed &= EXTENDS_KW & cls.jextends & SPACE


      if cls.jimplements.len != 0:
        constructed &= IMPLEMENTS_KW & cls.jimplements[0]
        cls.jimplements.del(0)

        if cls.jimplements.len != 0:
          for implement in cls.jimplements:
            constructed &= COMMA & implement
        constructed &= SPACE


      constructed &= OPEN_BRKT
      blocksWithin += 1


      for classvarr in cls.jclassvars:
        if classvarr of JavaVariableDeclaration:
          let classvar = JavaVariableDeclaration classvarr
          constructed &= INDENT

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
            echo "WARNING: The class `" & cls.jname & "` is static but with no value! This will error in javac!"

          if classvar.jvalue != "":
            constructed &= EQUALS & classvar.jvalue

          constructed &= LINE_SEP

        if classvarr of JavaCodeEmission:
          constructed &= classvarr.JavaCodeEmission.jcode

      constructed &= CLOSE_BRKT
      blocksWithin -= 1


  if blocksWithin != 0:
    echo "WARNING: The `blocksWithin` variable used internally to keep track of brackets, is not 0!"
    if jf.jsubpackage != "":
      echo "The faulty package is: " & jf.jnamespace & "." & jf.jsubpackage
    else:
      echo "The faulty package is: " & jf.jnamespace


  return constructed