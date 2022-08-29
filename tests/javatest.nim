import codegenlib/java

java.globalNamespace = "com.foc.codegen.example"

var
  javafile:JavaFile = newJavaFile()
  javaclass:JavaClass = newJavaClass("CodeGen")
  javavardecl:JavaVariableDeclaration = newJavaVariableDeclaration("String", "myVar", "\"Wow\"", true, true, true)

# Don't strictly *need* to import a class, but lets you do `Object`
# instead of `java.lang.Object`
javafile.imports("java.lang.Object")

javaclass.extends("Object")
javaclass.addClassVariable(javavardecl)

javafile.addJavaClass(javaclass)

echo javafile.construct()