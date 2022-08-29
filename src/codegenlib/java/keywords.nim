when defined(minimised): # Purely here for generating readable output
  const
    NEWLINE* = ""
    INDENT* = ""
else:
  const
    NEWLINE* = "\n"
    INDENT* = "    "

const
  LINE_SEP* = ";" & NEWLINE
  DOT* = "."
  OPEN_BRKT* = "{"
  CLOSE_BRKT* = "}"
  OPEN_PAREN* = "("
  CLOSE_PAREN* = ")"
  PUBLIC* = "public "
  PRIVATE* = "private "
  STATIC* = "static "
  FINAL* = "final "
  SPACE* = " " # Would be preferred not to use this
  PKG_STMT* = "package "
  IMPORT_STMT* = "import "
  CLASS_DECL* = "class "
  EXTENDS_KW* = "extends "
  IMPLEMENTS_KW* = "implements "

when defined(minimised):
  const
    EQUALS* = "="
    COMMA* = ","
else:
  const
    EQUALS* = " = "
    COMMA* = ", "