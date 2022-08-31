import tables

import codegenlib/java

java.globalNamespace = "com.foc.codegen"

var
  javafile:JavaFile = newJavaFile("example")
  javaclass:JavaClass = newJavaClass("CodeGen")
  javavardecl:JavaVariableDeclaration = newJavaVariableDeclaration("String", "myVar", "\"Wow\"", true, true, true)
  newvardecl:JavaVariableDeclaration = newJavaVariableDeclaration("String", "methodVar", "\"This is just a placeholder!\"", true)
  javamethod:JavaMethodDeclaration = newJavaMethodDeclaration("main", "void", true, true)

var printlnArg = initOrderedTable[string, string]()
printlnArg["x"] = "String"

var printlnArgs = @[printlnArg]

var
  System = newJavaClassWrapper("System")
  `out` = System.newJavaClassWrapper("out") # I know this is a field, but I want a quick and easy test
  println = `out`.newJavaMethodWrapper("println", printlnArgs)

# Don't strictly *need* to import a class, but lets you do `Object`
# instead of `java.lang.Object`
javafile.imports("java.lang.Object")

javaclass.extends("Object")
javaclass.addClassVariable(javavardecl)
javaclass.addClassVariable(javacode "    public static final String emittedVar = \"DON'T DO MANUAL CODE EMISSION UNLESS NEEDED!\";\n")

javamethod.addMethodArgument "String", "example"

javamethod.addSnippetToMethodBody newvardecl

javamethod.addSnippetToMethodBody "\nSystem.out.println(CodeGen.myVar);\n".javacode
javamethod.addSnippetToMethodBody "System.out.println(CodeGen.emittedVar);\n".javacode
javamethod.addSnippetToMethodBody "System.out.println(\"AUTOMATED JAVA CODE WRAPPING *WILL* BE DONE AT SOME POINT\");\n".javacode
javamethod.addSnippetToMethodBody "System.out.println(methodVar);\n\n".javacode

javamethod.addSnippetToMethodBody println.call("Test")

javaclass.addClassMethod(javamethod)

javafile.addJavaClass(javaclass)

echo $javafile