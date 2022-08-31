import std/[tables, strutils, sequtils]

var globalNamespace* = "example"  # Can be overridden by the user

import java/[keywords, types, class, fileconstruction, miscutils]
export java.keywords, java.types, java.class, java.fileconstruction


proc newJavaFile*(subpackage: string = "", namespace: string = ""): JavaFile =
  result = JavaFile()

  result.jparent = nil  # Can't have a parent for a Java file!

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


proc newJavaVariableDeclaration*(typ: string, name: string, value:string="", final: bool = false,
    public: bool = false,
    statik: bool = false): JavaVariableDeclaration =
  result = JavaVariableDeclaration()

  result.jtyp = typ
  result.jname = name
  result.jvalue = value
  result.jpublic = public
  result.jstatik = statik
  result.jfinal = final


proc newJavaMethodDeclaration*(name:string, returnTyp:string="void",
    public: bool = false,
    statik: bool = false,
    final: bool = false): JavaMethodDeclaration =
  result = JavaMethodDeclaration()

  result.jname = name
  result.jreturnTyp = returnTyp
  result.jpublic = public
  result.jstatik = statik
  result.jfinal = final


proc addMethodArgument*(jmethod:var JavaMethodDeclaration, typ:string, name:string) =
  jmethod.jarguments[name] = typ


proc addSnippetToMethodBody*(jmethod:var JavaMethodDeclaration, body:varargs[JavaBaseType]) =
  for item in body:
    item.jparent = jmethod
    jmethod.jbody.add item


proc javacode*(code:string):JavaCodeEmission = JavaCodeEmission(jcode:code)


proc newJavaMethodWrapper*(jcw:JavaClassWrapper, name:string,
  arguments:seq[OrderedTable[string, string]]=newSeq[OrderedTable[string, string]](0)): JavaMethodWrapper =
  result = JavaMethodWrapper()

  jcw.jmethods.add result  # Register the method automatically

  result.jparent = jcw
  result.jname = name
  result.jarguments = arguments


proc newJavaClassWrapper*(parent:JavaBaseType, name:string): JavaClassWrapper =
  result = JavaClassWrapper()

  result.jname = name
  result.jparent = parent

  if parent of JavaClassWrapper:
    JavaClassWrapper(parent).jclasses.add result

proc newJavaClassWrapper*(name:string): JavaClassWrapper =
  result = JavaClassWrapper()

  result.jname = name


proc call*(jmw:JavaMethodWrapper, args:varargs[string]):JavaCodeEmission =
  var quotedArgs:seq[string] = @[]

  for i in args:
    qot

  var jc = jmw.jname & OPEN_PAREN & args.join(COMMA) & CLOSE_PAREN

  return jc.javacode