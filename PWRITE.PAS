program Picture_Saving;
uses graph, crt, pcutils;

  const
       MaxX = 65;
       MaxY = 79;

  var
     PicFile : File;
     x, y, I : Integer;
     size    : Word;
     picture : Pointer;

begin
  picture := NIL;
  GFileLoc('c:\bp7\bgi');
  Assign(PicFile, 'ELi.ttt');
  ReWrite(PicFile);
  Randomize;
 { for I := 1 to 10000 do
    begin
      x := Round(Random(100));
      y := Round(Random(100));
      PutPixel(x, y, Round(Random(15)) + 1)
    end;}
  Bar(0,0,100,100);
  size := ImageSize(0, 0, MaxX, MaxY);
  GetMem(picture, size);
  GetImage(0, 0, MaxX, MaxY, picture^);
  BlockWrite(PicFile, picture^, 26);
  FreeMem(picture, size);
  Close(PicFile);
  ReadLn;
  CloseGraph;
end.
