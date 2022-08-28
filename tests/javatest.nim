import CodeGenLib/java

java.globalNamespace = "com.foc.codegen.example"

var javafile:JavaFile = newJavaFile("CodeGen")

# Don't strictly *need* to import a class, but lets you do `Object`
# instead of `java.lang.Object`
javafile.imprts("java.lang.Object")

javafile.extnds("Object")

echo javafile.construct()