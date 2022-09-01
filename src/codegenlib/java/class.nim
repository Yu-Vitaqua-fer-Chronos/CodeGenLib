import std/[sequtils]

import ./types


proc newJavaClass*(name: string, public: bool = true,
    final: bool = false): JavaClass =
  result = JavaClass()

  result.jpublic = public
  result.jfinal = final

  result.jname = name


proc addClassVariable*(cls:var JavaClass, clsvars:varargs[JavaBaseType]) =
  for clsvar in clsvars:
    cls.jclassvars.add clsvar
    clsvar.jparent = cls


proc addClassMethod*(cls:var JavaClass, methods:varargs[JavaBaseType]) =
  for jmethod in methods:
    cls.jclassmethods.add jmethod
    jmethod.jparent = cls


proc addJavaClass*(jf: var JavaFile, clsses: varargs[JavaClass]) =
  for cls in clsses:
    cls.jparent = jf
    jf.jclasses.add cls


proc extends*(cls: var JavaClass, class: string) =
  cls.jextends = class


proc implements*(cls: var JavaClass, implementClsses: varargs[string]) =
  cls.jimplements = implementClsses.toSeq()