MODULE ModuleWeb;
IMPORT Out, Env;

PROCEDURE WriteHeaders;
BEGIN
  Out.String('Status: 404 Not Found'); Out.Ln;
  Out.String('Content-Type: text/html'); Out.Ln;
  Out.Ln
END WriteHeaders;

(*
PROCEDURE HandleForm;
BEGIN
  WriteHeaders;
  Out.String('<!DOCTYPE html>'); Out.Ln;
  Out.String('<meta charset="utf8">'); Out.Ln;
  Out.String('<h1>СТРАНИЦА НЕ НАЙДЕНА. Hello world! Danilus, привет!</h1>'); Out.Ln
END HandleForm;

PROCEDURE ShowForm;
BEGIN
  WriteHeaders;
  Out.String('<!DOCTYPE html>'); Out.Ln;
  Out.String('<meta charset="utf8">'); Out.Ln;
  Out.String('<h1>Заполните форму</h1>'); Out.Ln;
  Out.String('<form method="GET" action="/handle-form">'); Out.Ln;
  Out.String('Имя: <input type="text" name="name"><br><br>'); Out.Ln;
  Out.String('Рост: <input type="text" name="height"><br><br>'); Out.Ln;
  Out.String('<input type="submit" value="Отправить">'); Out.Ln;
  Out.String('</form>'); Out.Ln
END ShowForm;
*)

PROCEDURE TestEnv;
VAR count, i: INTEGER;
  s: ARRAY 2000 OF CHAR;
BEGIN
  WriteHeaders;

  Env.GetByName('REQUEST_URI', s);
  Out.String('THE VALUE OF REQUEST_URI IS "');
  Out.String(s);
  Out.String('"<br>'); Out.Ln;

  count := Env.Count();
  Out.String('env count = ');
  Out.Int(count, 0);
  Out.String('<br>'); Out.Ln;

  FOR i := 0 TO count - 1 DO
    Env.Get(i, s);
    Out.Int(i, 2);
    Out.String(') "');
    Out.String(s);
    Out.String('"<br>'); Out.Ln
  END;
END TestEnv;

PROCEDURE Do;
BEGIN
  TestEnv
  (*ShowForm*)
END Do;

BEGIN
  Do
END ModuleWeb.
