import strutils

proc quote*(s:string):string =
  result = s

  result = "\"" & s.replace("\"", "\\\"") & "\""