import std/[
  strutils
]

import codegenlib/java

java.globalNamespace = "io.github.yu_vitaqua_fer_chronos.codegen"

var
  javafile = newJavaFile("example")
  javaclass = newJavaClass("CodeGen")
  javavardecl = newJavaVariableDeclaration("String", "myVar", "Wow".escape, true, true, true)
  newvardecl = newJavaVariableDeclaration("String", "methodVar", "This is just a placeholder!".escape, true)
  javamethod = newJavaMethodDeclaration("main", "void", true, true)
  javablock = newJavaBlock()

# Don't strictly *need* to import a class, but lets you do `Object`
# instead of `java.lang.Object` (doesn't apply to classes in `java.lang`, example.)
javafile.imports("java.lang.Object")
javafile.imports("java.lang.String")

javaclass.extends("Object")
javaclass.addClassVariable(javavardecl)
javaclass.addClassVariable("public static final String emittedVar = \"DON'T DO MANUAL CODE EMISSION UNLESS NEEDED!\"".jc(suffix=";\n"))

javamethod.addMethodArgument "String[]", "example"

javamethod.addSnippetToMethodBody newvardecl

template SystemOutPrintln(args:varargs[JavaBase]):JavaCodeEmission =
  constructMethodCall("System.out.println", args).jc(suffix=";")


javamethod.addSnippetToMethodBody(
  SystemOutPrintln "CodeGen.myVar".jc,
  SystemOutPrintln "CodeGen.emittedVar".jc,
  SystemOutPrintln "AUTOMATED JAVA CODE WRAPPING *WILL* BE DONE AT SOME POINT".jstring,
  SystemOutPrintln "methodVar".jc
)


javablock.addSnippetToBlock(
  "if (CodeGen.myVar == \"Wow\")",
  "System.out.println(\"`myVar` = \\\"Wow\\\"\");".jc
)

javablock.addSnippetToBlock(
  "else",
  "System.out.println(\"`myVar` is different from normal!\");".jc
)

javamethod.addSnippetToMethodBody javablock

javaclass.addClassMethod(javamethod)

javafile.addJavaClass(javaclass)

echo javafile.construct(0)