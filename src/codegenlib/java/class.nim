import std/[
  sequtils,
  options
]

import ./types

proc newJavaClass*(name: string, public: bool = true,
    statik: bool = false, final: bool = false): JavaClass =
  result = JavaClass()

  result.jpublic = public
  result.jstatic = statik
  result.jfinal = final

  result.jname = name


proc addClassVariable*(cls: var JavaClass, clsvars: varargs[JavaBaseType]) =
  for clsvar in clsvars:
    cls.jclassvars.add clsvar
    clsvar.jparent = some[JavaBaseType](cls)


proc addClassMethod*(cls: var JavaClass, methods: varargs[JavaBaseType]) =
  for jmethod in methods:
    cls.jclassmethods.add jmethod
    jmethod.jparent = some[JavaBaseType](cls)


proc addJavaClass*(jf: var JavaFile, clsses: varargs[JavaClass]) =
  for cls in clsses:
    cls.jparent = some[JavaBaseType](cls)
    jf.jclasses.add cls


proc extends*(cls: var JavaClass, class: string) =
  cls.jextends = class


proc implements*(cls: var JavaClass, implementClsses: varargs[string]) =
  cls.jimplements = implementClsses.toSeq()