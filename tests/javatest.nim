import codegenlib/java
import strutils, sequtils

java.globalNamespace = "com.foc.codegen"

var
  javafile:JavaFile = newJavaFile("example")
  javaclass:JavaClass = newJavaClass("CodeGen")
  javavardecl:JavaVariableDeclaration = newJavaVariableDeclaration("String", "myVar", "Wow".escape, true, true, true)
  newvardecl:JavaVariableDeclaration = newJavaVariableDeclaration("String", "methodVar", "This is just a placeholder!".escape, true)
  javamethod:JavaMethodDeclaration = newJavaMethodDeclaration("main", "void", true, true)
  javablock:JavaBlock = newJavaBlock()

# Don't strictly *need* to import a class, but lets you do `Object`
# instead of `java.lang.Object`
javafile.imports("java.lang.Object")

javaclass.extends("Object")
javaclass.addClassVariable(javavardecl)
javaclass.addClassVariable("public static final String emittedVar = \"DON'T DO MANUAL CODE EMISSION UNLESS NEEDED!\"".jc(suffix=";\n"))

javamethod.addMethodArgument "String", "example"

javamethod.addSnippetToMethodBody newvardecl

template SystemOutPrintln(args:varargs[JavaBase]):JavaCodeEmission =
  constructMethodCall("System.out.println", args).javacode(suffix=";")


javamethod.addSnippetToMethodBody(
  SystemOutPrintln "CodeGen.myVar".jc,
  SystemOutPrintln "CodeGen.emittedVar".jc,
  SystemOutPrintln "AUTOMATED JAVA CODE WRAPPING *WILL* BE DONE AT SOME POINT".jstring,
  SystemOutPrintln "methodVar".jc
)


javablock.addSnippetToBlock(
  "if (CodeGen.myVar == \"Wow\")",
  "System.out.println(\"`myVar` = \\\"Wow\\\"\");".javacode
)

javablock.addSnippetToBlock(
  "else",
  "System.out.println(\"`myVar` is different from normal!\");".javacode
)

javamethod.addSnippetToMethodBody javablock

javaclass.addClassMethod(javamethod)

javafile.addJavaClass(javaclass)

echo $javafile