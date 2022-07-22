MODULE WebGet;
IMPORT Dicts, Out, Web, Env;

VAR
  D: Dicts.Dict;

PROCEDURE Exists*(key: ARRAY OF CHAR): BOOLEAN;
RETURN Dicts.Exists(D, key) END Exists;

PROCEDURE Get*(key: ARRAY OF CHAR; VAR val: ARRAY OF CHAR);
BEGIN Dicts.Get(D, key, val)
END Get;

PROCEDURE GetInt*(key: ARRAY OF CHAR; VAR val: INTEGER);
BEGIN Dicts.GetInt(D, key, val)
END GetInt;

PROCEDURE Init;
VAR s: ARRAY 4096 OF CHAR;
BEGIN
  D := Dicts.NewDict();

  Env.GetByName('REQUEST_URI', s);
(*  Out.String('(Будем разбирать строку "'); Out.String(s);
  Out.String('".)'); Out.Ln;*)

  Dicts.Set(D, 'name', s);
  Dicts.SetInt(D, 'height', 54)
END Init;

BEGIN
  Init
END WebGet.