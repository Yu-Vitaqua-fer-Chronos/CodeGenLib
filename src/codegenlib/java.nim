import std/[
  strutils,
  sequtils,
  options,
  tables
]

var globalNamespace* = "example"  # Can be overridden by the user

import java/[keywords, types, class, fileconstruction]
export types, class, fileconstruction


proc newJavaFile*(subpackage: string = "", namespace: string = ""): JavaFile =
  ## Creates a `JavaFile`.
  result = JavaFile()

  if namespace == "":
    result.jnamespace = globalNamespace
  else:
    result.jnamespace = namespace

  result.jsubpackage = subpackage


proc imports*(jf: var JavaFile, importStmts: varargs[string]) =
  ## Allows you to import Java classes (in the generated Java code).
  for importStmt in importStmts:
    jf.jimportStatements.add importStmt


proc newJavaVariableDeclaration*(typ: string, name: string, value: string="", final: bool = false,
    public: bool = false, statik: bool = false): JavaVariableDeclaration =
  ## Creates a new variable declaration.
  result = JavaVariableDeclaration()

  result.jtyp = typ
  result.jname = name
  result.jvalue = value
  result.jpublic = public
  result.jstatic = statik
  result.jfinal = final


proc newJavaMethodDeclaration*(name:string, returnTyp:string="void",
    public: bool = false,
    statik: bool = false,
    final: bool = false): JavaMethodDeclaration =
  ## Creates a new method declaration.
  result = JavaMethodDeclaration()

  result.jname = name
  result.jreturnTyp = returnTyp
  result.jpublic = public
  result.jstatic = statik
  result.jfinal = final


proc newJavaBlock*(): JavaBlock =
  ## Creates an empty `JavaBlock`.
  return JavaBlock()


proc addMethodArgument*(jmethod: JavaMethodDeclaration, typ:string, name:string) =
  ## Adds an argument to a method, see `tests/test1.nim` as an example.
  jmethod.jarguments[name] = typ


proc addSnippetToMethodBody*(jmethod: JavaMethodDeclaration, body:varargs[JavaBaseType]) =
  ## Adds a Java snippet to a block, see `tests/test1.nim` as an example.
  for item in body:
    item.jparent = some[JavaBaseType](jmethod)
    jmethod.jbody.add item


proc setParent(jb:JavaBlock): proc =
  ## Internal proc
  return proc(snippet:JavaBaseType) =
    snippet.jparent = some[JavaBaseType](jb)


proc addSnippetToBlock*(jb: var JavaBlock, name:string, snippets:openArray[JavaBaseType]) =
  ## Adds a Java snippet to a block, see `tests/test1.nim` as an example.
  jb.jnames.add name

  snippets.apply setParent(jb)
  jb.jsnippets.add toSeq(snippets)

proc addSnippetToBlock*(jb: var JavaBlock, name:string, snippets:varargs[JavaBaseType]) =
  ## Adds a Java snippet to a block, see `tests/test1.nim` as an example.
  jb.jnames.add name

  toSeq(snippets).apply setParent(jb)
  jb.jsnippets.add toSeq(snippets)


proc jc*(code: string, suffix = ""): JavaCodeEmission =
  ## The raw Java code as a string, could be anything as long as it's valid
  JavaCodeEmission(jcode: code & suffix)

proc construct(jb: JavaBase): string = $jb # Internal only

proc constructMethodCall*(qualifiedMethodName:string, args:varargs[JavaBase]):string =
  ## A quick way to create a method call.
  runnableExamples:
    echo constructMethodCall("System.out.println", "Hello world!".jstring)

  result = qualifiedMethodName & "("

  var strargs = args.map(construct)
  result &= strargs.join(", ")

  result &=  ")"
  # Don't terminate the line automatically because it may be used in a nested function call

proc initialiseClass*(className: string, args: varargs[JavaBase]): string =
  ## A way to initialise classes known only as a string.
  runnableExamples:
    echo initialiseClass("String", "Woah!".jstring)

  result = NEW & SPACE & className & "("

  var strargs = args.map(construct)
  result &= strargs.join(", ")

  result &=  ")"