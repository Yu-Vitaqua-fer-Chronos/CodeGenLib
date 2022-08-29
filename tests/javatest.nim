import codegenlib/java

java.globalNamespace = "com.foc.codegen.example"

var javaFile:JavaFile = newJavaFile()
var javaClass:JavaClass = newJavaClass("CodeGen")

# Don't strictly *need* to import a class, but lets you do `Object`
# instead of `java.lang.Object`
javaclass.imprts("java.lang.Object")

javaclass.extnds("Object")



echo javafile.construct()
