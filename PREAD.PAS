program Picture_Loading;
uses graph, crt, pcutils;

  const
       MaxX = 65;
       MaxY = 79;

  var
     PicFile : File;
     x, y, I : Integer;
     size,
     Fsize   : Word;
     picture,
     picture1: Pointer;

begin
  picture := NIL;
  picture1 := NIL;
  GFileLoc('c:\bp7\bgi');
  Assign(PicFile, 'ELi.ttt');
  Rectangle(200, 200, 200 + MaxX, 200 + MaxY);
  SetColor(11);
  Rectangle(199, 199, 199 + MaxX + 2, 199 + MaxY + 2);
  Reset(PicFile);
  Fsize := FileSize(PicFile);
  size := ImageSize(0, 0, MaxX, MaxY);
  GetMem(picture1, size);
  GetImage(0, 0, MaxX, MaxY, picture1^);
  BlockRead(Picfile, picture1^, 23);
  PutImage(200, 200, picture1^, NormalPut);
  FreeMem(picture1, size);
  Close(PicFile);
  ReadLn;
  CloseGraph;
end.
