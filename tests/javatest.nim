import codegenlib/java

java.globalNamespace = "com.foc.codegen"

var
  javafile:JavaFile = newJavaFile("example")
  javaclass:JavaClass = newJavaClass("CodeGen")
  javavardecl:JavaVariableDeclaration = newJavaVariableDeclaration("String", "myVar", "\"Wow\"", true, true, true)
  javamethod:JavaMethodDeclaration = newJavaMethodDeclaration("main", "void", true, true)

# Don't strictly *need* to import a class, but lets you do `Object`
# instead of `java.lang.Object`
javafile.imports("java.lang.Object")

javaclass.extends("Object")
javaclass.addClassVariable(javavardecl)
javaclass.addClassVariable(javacode "    public static final String emittedVar = \"DON'T DO MANUAL CODE EMISSION UNLESS NEEDED!\";\n")

javamethod.addMethodArgument "String", "example"

javamethod.addSnippetToMethodBody "System.out.println(CodeGen.myVar);\n".javacode
javamethod.addSnippetToMethodBody "System.out.println(CodeGen.emittedVar);\n".javacode
javamethod.addSnippetToMethodBody "System.out.println(\"AUTOMATED JAVA CODE WRAPPING *WILL* BE DONE AT SOME POINT\");\n".javacode

javaclass.addClassMethod(javamethod)

javafile.addJavaClass(javaclass)

echo $javafile