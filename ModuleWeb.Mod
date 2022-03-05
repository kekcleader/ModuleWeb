MODULE ModuleWeb;
IMPORT Out;
BEGIN
  Out.String('Content-Type: text/html'); Out.Ln;
  Out.Ln;
  Out.String('<!DOCTYPE html>'); Out.Ln;
  Out.String('<meta charset="utf8">'); Out.Ln;
  Out.String('<h1>Hello world! Привет!</h1>'); Out.Ln
END ModuleWeb.