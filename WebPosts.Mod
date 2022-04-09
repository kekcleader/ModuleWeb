MODULE WebPost;
IMPORT Dicts, Out;

VAR
  dict: Dicts.Dict;
  loaded: BOOLEAN;

PROCEDURE Load;
BEGIN
  dict := Dicts.NewDict();
  ......
    Dicts.Set(ket, value)
  ...

END Load;

PROCEDURE Get*(key: ARRAY OF CHAR; VAR val: ARRAY OF CHAR);
BEGIN
  IF dict = NIL THEN Load END;

END Get;

END WebPost.