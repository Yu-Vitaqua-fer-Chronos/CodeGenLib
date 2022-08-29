import codegenlib/java

java.globalNamespace = "com.foc.codegen"

var
  javafile:JavaFile = newJavaFile("example")
  javaclass:JavaClass = newJavaClass("CodeGen")
  javavardecl:JavaVariableDeclaration = newJavaVariableDeclaration("String", "myVar", "\"Wow\"", true, true, true)

# Don't strictly *need* to import a class, but lets you do `Object`
# instead of `java.lang.Object`
javafile.imports("java.lang.Object")

javaclass.extends("Object")
javaclass.addClassVariable(javavardecl)
javaclass.addClassVariable(javacode "    public static final emittedVar = \"DON'T DO THIS PLEASE!\";\n")

javafile.addJavaClass(javaclass)

echo $javafile