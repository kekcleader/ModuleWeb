MODULE Dicts;
IMPORT Out, Strings;

CONST
  keyLen* = 128;
  strLen* = 1024;

TYPE
  Item* = POINTER TO ItemDesc;
  ItemDesc* = RECORD
    key*: ARRAY keyLen OF CHAR;
    prev, next: Item
  END;

  Lock = POINTER TO LockDesc;
  LockDesc = RECORD(ItemDesc)
    parent: Item
  END;

  Str* = POINTER TO StrDesc;
  StrDesc* = RECORD(ItemDesc)
    val*: ARRAY strLen OF CHAR
  END;

  Int* = POINTER TO IntDesc;
  IntDesc* = RECORD(ItemDesc)
    val*: INTEGER
  END;
      (* аищщё REAL и BOOLEAN *)

  Array* = POINTER TO ArrayDesc;
  ArrayDesc* = RECORD(ItemDesc)
    len: INTEGER; (* Get this using Len *)
    body: Lock
  END;

  Dict* = POINTER TO DictDesc;
  DictDesc* = RECORD(ItemDesc)
    len: INTEGER; (* Get this using Len *)
    body: Lock
  END;

PROCEDURE Copy(s: ARRAY OF CHAR; VAR to: ARRAY OF CHAR);
VAR i, len: INTEGER;
BEGIN
  len := LEN(s);
  IF len > LEN(to) THEN len := LEN(to) END;
  DEC(len);
  i := 0;
  WHILE (i < len) & (s[i] # 0X) DO to[i] := s[i]; INC(i) END;
  to[i] := 0X
END Copy;

PROCEDURE Len*(item: Item): INTEGER;
VAR n: INTEGER;
BEGIN
  IF item IS Array THEN n := item(Array).len
  ELSIF item IS Dict THEN n := item(Dict).len
  ELSE ASSERT(FALSE)
  END
RETURN n END Len;

PROCEDURE NewStr*(val: ARRAY OF CHAR): Str;
VAR s: Str;
BEGIN NEW(s); s.key := ''; s.val := val
RETURN s END NewStr;

PROCEDURE NewInt*(val: INTEGER): Int;
VAR i: Int;
BEGIN NEW(i); i.key := ''; i.val := val
RETURN i END NewInt;

PROCEDURE NewArray*(): Array;
VAR a: Array;
BEGIN NEW(a); a.key := ''; a.len := 0; NEW(a.body);
  a.body.prev := a.body; a.body.next := a.body; a.body.parent := a
RETURN a END NewArray;

PROCEDURE NewDict*(): Dict;
VAR d: Dict;
BEGIN NEW(d); d.key := ''; d.len := 0; NEW(d.body);
  d.body.prev := d.body; d.body.next := d.body; d.body.parent := d
RETURN d END NewDict;

PROCEDURE GetParent*(v: Item): Item;
BEGIN
  IF v.prev # NIL THEN
    REPEAT v := v.next UNTIL v IS Lock;
    v := v(Lock).parent
  ELSE v := NIL
  END
RETURN v END GetParent;

(** Removes v from its collection (if any) *)
PROCEDURE Remove(v: Item);
VAR p: Item;
BEGIN
  p := GetParent(v);
  IF p # NIL THEN
    IF p IS Array THEN DEC(p(Array).len)
    ELSIF p IS Dict THEN DEC(p(Dict).len)
    END;

    v.prev.next := v.next;
    v.next.prev := v.prev;
    v.prev := NIL;
    v.next := NIL
  END
END Remove;

(** Appends v to the end of a *)
PROCEDURE Append(a: Array; v: Item);
BEGIN
  Remove(v);
  v.prev := a.body.prev;
  v.next := a.body;
  v.prev.next := v;
  v.next.prev := v;
  INC(a.len)
END Append;

(** Sets item v for the given key inside d,
    replaces the previous item. *)
PROCEDURE SetItem*(d: Dict; key: ARRAY OF CHAR; v: Item);
VAR p: Item;
BEGIN
  Remove(v);
  v.key := key;
  p := d.body.next;
  WHILE (p # d.body) & (p.key # key) DO p := p.next END;
  IF p # d.body THEN
    v.next := p.next;
    v.prev := p.prev;
    v.prev.next := v;
    v.next.prev := v;
    p.prev := NIL;
    p.next := NIL
  ELSE
    INC(d.len);
    v.prev := d.body.prev;
    v.next := d.body;
    v.prev.next := v;
    v.next.prev := v
  END
END SetItem;

PROCEDURE Set*(d: Dict; key, val: ARRAY OF CHAR);
BEGIN SetItem(d, key, NewStr(val))
END Set;

PROCEDURE SetInt*(d: Dict; key: ARRAY OF CHAR; val: INTEGER);
BEGIN SetItem(d, key, NewInt(val))
END SetInt;

(** Returns nth item of array a *)
PROCEDURE ArrayGet(a: Array; n: INTEGER): Item;
VAR v: Item;
BEGIN
  IF (0 <= n) & (n < a.len) THEN
    v := a.body.next;
    WHILE n # 0 DO v := v.next; DEC(n) END
  ELSE v := NIL
  END
RETURN v END ArrayGet;

(** Returns nth item of dict d *)
PROCEDURE DictGet(d: Dict; n: INTEGER): Item;
VAR v: Item;
BEGIN
  IF (0 <= n) & (n < d.len) THEN
    v := d.body.next;
    WHILE n # 0 DO v := v.next; DEC(n) END
  ELSE v := NIL
  END
RETURN v END DictGet;

PROCEDURE GetNthItem*(coll: Item; n: INTEGER): Item;
VAR v: Item;
BEGIN
  IF coll IS Array THEN v := ArrayGet(coll(Array), n)
  ELSIF coll IS Dict THEN v := DictGet(coll(Dict), n)
  ELSE ASSERT(FALSE)
  END
RETURN v END GetNthItem;

PROCEDURE GetItem*(d: Dict; key: ARRAY OF CHAR): Item;
VAR p: Item;
BEGIN
  p := d.body.next;
  WHILE (p # d.body) & (p.key # key) DO p := p.next END;
  IF p = d.body THEN p := NIL END
RETURN p END GetItem;

PROCEDURE Exists*(d: Dict; key: ARRAY OF CHAR): BOOLEAN;
RETURN GetItem(d, key) # NIL END Exists;

PROCEDURE Get*(d: Dict; key: ARRAY OF CHAR; VAR val: ARRAY OF CHAR);
VAR item: Item;
BEGIN
  item := GetItem(d, key);
  IF (item # NIL) & (item IS Str) THEN
    Copy(item(Str).val, val) (*!FIXME convert other values to str *)
  ELSE
    val[0] := 0X
  END
END Get;

PROCEDURE GetInt*(d: Dict; key: ARRAY OF CHAR; VAR val: INTEGER);
VAR item: Item;
BEGIN
  item := GetItem(d, key);
  IF (item # NIL) & (item IS Int) THEN
    val := item(Int).val (*!FIXME Переделать str в int, если там-таки str*)
  ELSE
    val := -1
  END
END GetInt;

PROCEDURE^ PrintEx(v: Item; format: BOOLEAN; indent: INTEGER);

PROCEDURE Indent(n: INTEGER);
BEGIN
  WHILE n > 0 DO Out.Char(' '); DEC(n) END
END Indent;

PROCEDURE ArrayPrint(a: Array; format: BOOLEAN; indent: INTEGER);
VAR v: Item;
BEGIN
  Out.Char('[');
  IF format & (a.len > 1) THEN Out.Ln; Indent(indent + 2) END;
  v := a.body.next;
  WHILE v # a.body DO
    IF v # a.body.next THEN
      Out.Char(',');
      IF format THEN Out.Ln; Indent(indent + 2) ELSE Out.Char(' ') END
    END;
    PrintEx(v, format, indent + 2);
    v := v.next
  END;
  IF format & (a.len > 1) THEN Out.Ln; Indent(indent) END;
  Out.Char(']')
END ArrayPrint;

PROCEDURE DictPrint(d: Dict; format: BOOLEAN; indent: INTEGER);
VAR v: Item;
BEGIN
  Out.Char('{');
  IF format & (d.len > 1) THEN Out.Ln; Indent(indent + 2) END;
  v := d.body.next;
  WHILE v # d.body DO
    IF v # d.body.next THEN
      Out.Char(',');
      IF format THEN Out.Ln; Indent(indent + 2) ELSE Out.Char(' ') END
    END;
    Out.Char('"'); Out.String(v.key); Out.String('": ');
    PrintEx(v, format, indent + 2);
    v := v.next
  END;
  IF format & (d.len > 1) THEN Out.Ln; Indent(indent) END;
  Out.Char('}')
END DictPrint;

PROCEDURE PrintEx(v: Item; format: BOOLEAN; indent: INTEGER);
BEGIN
  IF v = NIL THEN Out.String('#NIL#')
  ELSIF v IS Int THEN Out.Int(v(Int).val, 0)
  ELSIF v IS Str THEN Out.Char('"'); Out.String(v(Str).val); Out.Char('"')
  ELSIF v IS Array THEN ArrayPrint(v(Array), format, indent)
  ELSIF v IS Dict THEN DictPrint(v(Dict), format, indent)
  ELSE Out.String('#ERRORITEM#')
  END
END PrintEx;

PROCEDURE Print*(v: Item);
BEGIN PrintEx(v, FALSE, 0)
END Print;

PROCEDURE PrintF*(v: Item);
BEGIN PrintEx(v, TRUE, 0)
END PrintF;

PROCEDURE Test;
VAR x, z: Int;
  s: Str;
  a: Array;
  d, d2: Dict;
  i: INTEGER;
  v: Item;
BEGIN
  x := NewInt(421);
  z := x;
  s := NewStr('Привет');
  a := NewArray();
  Append(a, x);
  Append(a, s);

  d := NewDict();
  x := NewInt(5);
  SetItem(d, 'рост', x);
  x := NewInt(15);
  SetItem(d, 'возраст', x);
  Set(d, 'Какая-нибудь', 'дуа');
  s := NewStr('дуачок');
  SetItem(d, 'или', s);
  Out.Ln;


  Print(a);
  Out.Ln;
  Out.Ln;

  SetItem(d, 'массиу', a);

  Print(d);
  Out.Ln;
  Out.Ln;

  s := NewStr('турачок');
  SetItem(d, 'или', s);

  a := NewArray();
  SetItem(d, 'пустота1', a);

  d2 := NewDict();
  SetItem(d, 'пустота2', d2);

  a := NewArray();
  Append(a, NewInt(7));
  SetItem(d, 'одно1', a);

  d2 := NewDict();
  a := NewArray();
  SetItem(d2, 'ключ', NewStr('значение'));
  Append(a, d2);
  SetItem(d, 'одно2', a);

  d2 := NewDict();
  SetItem(d2, 'а', NewStr('ищщё'));
  SetItem(d2, 'Айван', NewStr('Зэтэрибл'));
  SetItem(d, 'два2', d2);

  SetItem(d, 'z', z);

  PrintF(d);
  Out.Ln;
  Out.Ln
END Test;

PROCEDURE Test2;
VAR
  a: Array;
  m: Array;
  x, y: Int;
BEGIN
  x := NewInt(7);
  a := NewArray();
  Append(a, x);
  m := NewArray();
  Append(m, x);
  Print(a); Out.Ln; Out.Ln;
  Print(m); Out.Ln; Out.Ln
END Test2;

(*BEGIN
  Test*)
END Dicts.


(*    ПРИМЕР ИСПОЛЬЗОВАНИЯ
      VAR a: Dicts.Array;
        v: Dicts.Item;
        i: INTEGER;
      BEGIN
        a := Post.GetAll();
        FOR i := 0 TO Dicts.Len(a) DO
          v := Dicts.Get(a, i);
          Dicts.Out(v)
        END
      END
*)