program Picture_Maker;

uses crt, pcutils, graph, tcoreg, choise, dos;

  const
       MTableSizeX  = 79;
       MTableSizeY  = 79;
       GCorsurSize  = 2;
       ColorBox     = 4;
       AutoMes      = 'Auto';
       Shade        = 20;
       SiBox        = 5;
       SpaceFromBox = 20;
       WriteHight   = 35;
       FarFlip      = 50;

  type
      PicFile = RECORD
                  detaile    : 1..2;
                  TabX, TabY : Byte;
                  picture    : Pointer;
                end;
      KeepPicture = array[1..MTableSizeX, 1..MTableSizeY] of Byte;
      FPicture = File of PicFile;

  var
     Color, BoxSize,
     FarX, FarY, PointSize,
     moveX, TableSizeX,
     moveY, TableSizeY      : Integer;
     keepPic                : KeepPicture;
     AutoPaint, saved       : Boolean;
     GetChar                : Char;
     PictureFile            : FPicture;
     FileName, DirecName    : String;

procedure Init;
  Forward;

procedure Auto(fy : Integer; var AutoP : Boolean);
  Forward;

procedure FileWindow(x, y, sizeX, SizeY : Integer; WType : Char);
  Forward;

procedure SaveFile(sizeX, a, b : Integer; var PictureFile : FPicture;
                                          var FName : String);
  Forward;

procedure LoadFile(sizeX, a, b : Integer; var PictureFile : FPicture;
                                          var FName : String;
                                          var pick : Byte);
  Forward;

procedure FlipWindow(x, y, sizeX, sizeY : Integer; var Table : KeepPicture);
  Forward;

procedure ChangeDirec(x, y, sizeX, sizeY : Integer;
                                       var DirecName : String);
  Forward;

{---------------------------------------------------------------------------}
procedure ScreenChoise(var PSize, TableX, TableY : Integer);
                                   { This procedure take teh sizes of the
                                     table and the level of Detailed from
                                     the user. }
   var
      at, tav,
      locX, locY, I, max : Integer;
      choose             : String;
      Ch                 : Char;
   begin
     TextMode(Co80);
     Delay(200);
     HeadLine;
     Detailes(choose, max, locX, locY);
     CorsurSize('C', 'N');
     repeat                               { Save the string in choose }
       for I := 0 to (20 - max) do
         begin
           GetChr(locX + I, locY, at, tav);
           choose := choose + (Chr(tav))
         end;
       gotoXY(locX, locY);
       TextAttr := Black + 16 * Lightgray; { Setting colors }
       Write(choose);
       TextAttr := Lightgray + 16 * Black;
       Ch := ReadKey;
       case Ch of
         #0      : begin
                     Ch := ReadKey;
                     gotoXY(locX, locY);
                     Write(choose);
                     choose := '';
                     case Ch of
                       KeyUp   : if locY > 5 then
                                   locY := locY - 1;
                       KeyDown : if locY < max then
                                   locY := locY + 1
                     end
                   end;
         Enter   : begin                    { Send the values }
                     Sizes(max, choose, PSize, TableX, TableY);
                     if max = 6 then
                       TableSize(choose, max)
                     else
                       Exit
                   end;
         Esc     : if max = 6 then          { Exit the exist screen }
                     Halt(1)
                   else
                     Detailes(choose, max, locX, locY);
         else
           choose := ''
       end { Case }
     until max = 12
  end; { End of procedure ScreenChoise }
{---------------------------------------------------------------------------}
procedure TableMaking(TableSizeX, TableSizeY : Integer;
                                                      var keep : KeepPicture;
                                                      var BoxSize : Integer);
  var
     counter,
     counter1 : Integer;
  function Box(TableX, TableY : Integer) : Integer;
    begin                           { Set the Box Size }
      case TableY of
        79          : Box := 6;
        65          : Box := 7;
        40          : if TableX = 65 then
                        Box := 7
                      else
                        Box := 8
      end
    end;
  begin         { Main procedure }
    ClearDevice;
    for counter := 1 to TableSizeX do         { Repare the array }
      for counter1 := 1 to TableSizeY do
        keep[counter, counter1] := 0;
    SetColor(White);                          { Painting the table }
    BoxSize := Box(TableSizeX, TableSizeY);
    SetLineStyle(SolidLn, SolidFill, NormWidth);
    for counter := 0 to TableSizeX do
      Line(counter * BoxSize, 0,
                           counter * BoxSize, TableSizeY * BoxSize);
    for counter := 0 to TableSizeY do
      Line(0, counter * BoxSize,
                           TableSizeX * BoxSize, counter * BoxSize);
    SetLineStyle(SolidLn, SolidFill, NormWidth);      { Painting the max size of the table }
    Rectangle(0, 0, MTableSizeX * 6, MTableSizeY * 6);
    if TableSizeX <> 79 then
      begin
        SetFillStyle(SolidFill, DarkGray);
        FloodFill(TableSizeX * BoxSize + 3, 10, White)
      end
  end;
{---------------------------------------------------------------------------}
procedure Paint(moveX, moveY, Color, BoxSize : Integer;
                ChGet : Char; var keep : KeepPicture );
  begin                                    { Paiting the box and the point }
     if (keep[moveX, moveY] = Color) OR (ChGet = #83) then
       Color := 0;
     keep[moveX, moveY] := Color;
     SetFillStyle(SolidFill, Color);
     saved := TRUE;
     Bar(moveX * BoxSize - BoxSize + 1 ,  { Bar in the table }
         moveY * BoxSize - BoxSize + 1,
         moveX * BoxSize - 1,
         moveY * BoxSize - 1);
     Bar(moveX * PointSize + FarX,            { Bar in the real }
         moveY * PointSize + FarY,
         moveX * PointSize + FarX + (PointSize - 1),
         moveY * PointSize + FarY + (PointSize - 1))
  end;
{---------------------------------------------------------------------------}
procedure Corsur(moveX, moveY, Color : Integer;
                 kind : Boolean; keep : KeepPicture);
  function CorsurColor(movX, movY : Integer; keep : KeepPicture) : Integer;
    begin                                 { Setting the corsur color }
      if keep[movX, movY] = Black then
        CorsurColor := White
      else
        CorsurColor := Black
    end;

  begin   { Main procedure }
    if kind = TRUE then                                 { Paints the corsur }
      SetFillStyle(SolidFill, CorsurColor(moveX, moveY, keep))
    else
      SetFillStyle(SolidFill, Keep[moveX, moveY]);
    Bar(moveX * BoxSize - BoxSize + GCorsurSize,
        moveY * BoxSize - BoxSize + GCorsurSize,
        moveX * BoxSize - GCorsurSize,
        moveY * BoxSize - GCorsurSize)
  end;
{---------------------------------------------------------------------------}
function ColorChanging(Color : Integer;
                         GetChar : Char) : Integer;
  begin
    if GetChar = Pos then                      { Changes the color }
      begin
        Color := Color + 1;
        if Color = 16 then
          ColorChanging := Black
        else
          ColorChanging := Color
      end
    else
      begin
        if Color = Black then
          ColorChanging := White
        else
          ColorChanging := Color - 1
      end
    end;
{---------------------------------------------------------------------------}
procedure Help(x, y, sizeX, SizeY : Integer);
  const                                      { Paints the help Window }
       MaxHelp = 15;
       Helps : array[1..MaxHelp] of String = ('Space - Erase / Draw',
                                              'Delete - Erase',
                                              'Arrow Key - ' + Chr(24) + ' up',
                                              '            ' + Chr(25) + ' down',
                                              '            ' + Chr(26) + ' left',
                                              '            ' + Chr(27) + ' right',
                                              'F9 - Automatic Painting',
                                              'F10 - Choises Screen',
                                              'Tab - Exit to dos',
                                              '-/+ - Change Color',
                                              'Esc - Erase the picture',
                                              'F2 - Save Picture',
                                              'F3 - Load Picture',
                                              'F4 - Flip Picture',
                                              'F5 - Change Directory');

  var
     ScreenPtr : Pointer;
     I         : Integer;
     Ch        : Char;
  begin
    ScreenPtr := NIL;
    GetMem(ScreenPtr, ImageSize(x, y, x + sizeX + Shade, y + sizeY + Shade));
    GetImage(x, y, x + sizeX + shade, y + sizeY + Shade, ScreenPtr^);
    SetFillStyle(EmptyFill, Black);
    Bar(x + Shade, y + Shade, x + sizeX + Shade, y + sizeY + Shade);
    SetFillStyle(SlashFill, Red);      { Paint the window }
    Bar(x, y, x + sizeX, y + sizeY);
    SetColor(LightGreen);
    for I := 1 to MaxHelp do           { Print the masseges }
      OutTextXY(x + 10, y + I * 15, Helps[I]);
    SetColor(LightCyan);
    GPauseXY(x + 5, y + sizeY - 15);
    PutImage(x, y, ScreenPtr^, NormalPut);
    FreeMem(ScreenPtr, ImageSize(x, y, x + sizeX + Shade, y + sizeY + Shade));
    ScreenPtr := NIL
  end;
{---------------------------------------------------------------------------}
procedure GettingKeys;
  begin
    GetChar := ReadKey;
    Corsur(moveX, moveY, Color, FALSE, keepPic);
    case getchar of
      KeyRight,
      KeyLeft,
      KeyUp,
      KeyDown      : begin
                       if AutoPaint = TRUE then
                         Paint(moveX, moveY, Color, BoxSize, GetChar, KeepPic);
                       case GetChar of
                         KeyRight    : if moveX < TableSizeX then
                                         moveX := moveX + 1;
                         KeyLeft     : if moveX > 1 then
                                         moveX := moveX - 1;
                         KeyUp       : if moveY > 1 then
                                         moveY := moveY - 1;
                         KeyDown     : if moveY < TableSizeY then
                                         moveY := moveY + 1
                       end
                     end;
       F10        : begin
                      CloseGraph;
                      Init
                    end;
      F9          : Auto(FarY, AutoPaint);
      F1          : Help(100, 100, 250, 320);
      F2          : FileWindow(200, 100, 150, 270, 'S');
      F3          : FileWindow(200, 100, 150, 270, 'L');
      F4          : FlipWindow(100, 150, 300, 100, keepPic);
      F5          : ChangeDirec(1, 1, 250, 50, DirecName);
      Delete      : Paint(moveX, moveY, Color, BoxSize, GetChar, KeepPic)
    end
  end;
{---------------------------------------------------------------------------}
procedure SecondInit;
  var
     x, y : Integer;
  begin
    AutoPaint := TRUE;
    TableMaking(TableSizeX, TableSizeY, keepPic, BoxSize);
    Auto(FarY, AutoPaint);
    FarX := GetMaxX - (TableSizeX + 1) * PointSize;
    SetLineStyle(DottedLn, SolidFill, NormWidth);
    Line(FarX, FarY - 2, GetMaxX, FarY - 2);       { Paint the picture borders }
    Line(FarX, FarY + (TableSizeY + 1) * PointSize + 2,
         GetMaxX, FarY + (TableSizeY + 1) * PointSize + 2);
    SetFillStyle(SolidFill, DarkGray);             { Paint the help scuare }
    Bar(GetMaxX - 80, GetMaxY - 12, GetMaxX, GetMaxY);
    SetColor(Yellow);
    x := GetMaxX - 40; y := GetMaxY - 10;
    GWrite(x, y, 'Help');
    x := GetMaxX - 75; y := GetMaxY - 10;
    GWrite(x, y, 'F1-');
    moveX := 34; moveY := 27;
  end;
{---------------------------------------------------------------------------}
procedure Init;
  begin
    ScreenChoise(PointSize, TableSizeX, TableSizeY);
    GFileLoc('A:\TURBO');
    DirecName := 'A:\';             { Initialize the variable }
    saved := FALSE;
    Color := White;
    FarY := 2;
    SecondInit
  end;
{---------------------------------------------------------------------------}
procedure Auto(fy : Integer; var autoP : Boolean);
  var                           { Set an automatic painting }
     x, y : Integer;
  begin
    autoP := TRUE XOR autoP;
    x := GetMaxX - Length(AutoMes) * 8;
    y := fy + (TableSizeY + 1) * PointSize + ColorBox + 10;
    SetFillStyle(EmptyFill, Black);
    Bar(x - 7, y,  GetMaxX, y + 20);
    if autoP = TRUE then
      begin
        SetFillStyle(SolidFill, Blue);
        SetColor(White);
        SetLineStyle(SolidLn, SolidFill, NormWidth);
        Bar3D(x - 7, y + 4, GetMaxX - 5, y + 16, 5, TopOn);
        SetColor(White);         { Print the auto massege }
        x := x - 5; y := y + 6;
        GWrite(x, y, AutoMes)
      end
    else
      begin                      { Erase the auto massege }
        SetFillStyle(SolidFill, Blue);
        SetColor(White);
        SetLineStyle(SolidLn, SolidFill, NormWidth);
        Bar3D(x - 2, y, GetMaxX, y + 12, 0 , TopOn);
        SetColor(White);         { Print the auto massege }
        y := y + 2;
        GWrite(x, y, AutoMes)
      end;
  end; { Auto }
{---------------------------------------------------------------------------}
procedure FileWindow(x, y, sizeX, SizeY : Integer; WType : Char);
  var
     pick      : Byte;
     WindowPtr : Pointer;
     size      : Word;
     Ch        : Char;
  begin
    WindowPtr := NIL;
    size := ImageSize(x, y, x + sizeX + Shade, y + sizeY + Shade);
    GetMem(WindowPtr, size);
    GetImage(x, y, x + sizeX + shade, y + sizeY + Shade, WindowPtr^);
    SetFillStyle(EmptyFill, Black);
    Bar(x + Shade, y + Shade, x + sizeX + Shade, y + sizeY + Shade);
    SetFillStyle(SolidFill, White);      { Paint the window }
    Bar(x, y, x + sizeX, y + sizeY);
    SetLineStyle(SolidLn, SolidFill, NormWidth);

    SetColor(Black);
{B} Rectangle(x + SiBox, y + SiBox, x + sizeX - SiBox, y + sizeY - SiBox);
{Up}Rectangle(x + SpaceFromBox, y + WriteHight,
              x + sizeX - SpaceFromBox, y + WriteHight + 15);
{P} Rectangle(x + SpaceFromBox, y + WriteHight + 40,
              x + sizeX - SpaceFromBox, y + sizeY - 20);
    OutTextXY(x + SpaceFromBox + 5, y + WriteHight + 30, 'Pictures');
    MoveTo(x + SiBox + 19, y + SiBox + 10);
    if WType = 'L' then
      begin
        OutText('Load Picture:');
        LoadFile(sizeX, x + SpaceFromBox, y + WriteHight, PictureFile, FileName, pick);
        if pick = 111 then
          PutImage(x, y, WindowPtr^, NormalPut)
      end
    else
      begin
        OutText('Save Picture:');
        SaveFile(sizeX, x + SpaceFromBox, y + WriteHight, PictureFile, FileName);
        PutImage(x, y, WindowPtr^, NormalPut)
      end;
    FreeMem(WindowPtr, size);
    WindowPtr := NIL
  end;
{---------------------------------------------------------------------------}
procedure OpenFile(FName : String; Etype : Char; var result : Integer;
                                                 var PictureFile : FPicture);
  var
     Ch : Char;
     FRec : SearchRec;

  procedure TellCheck;
    begin
      SetLineStyle(SolidLn, SolidFill, NormWidth);
      Rectangle(GetMaxX - 122, GetMaxY - 220,
                GetMaxX - 40, GetMaxY - 140);
      OutTextXY(GetMaxX - 115, GetMaxY - 210, 'The File:');
      OutTextXY(GetMaxX - 112, GetMaxY - 197, FName);
      OutTextXY(GetMaxX - 115, GetMaxY - 184, 'connot be');
      OutTextXY(GetMaxX - 100, GetMaxY - 171, 'open');
      OutTextXY(GetMaxX - 135, GetMaxY - 120, 'Press any key ...')
    end;

  begin
    Assign(PictureFile, DirecName + FName + '.MPC');
    if Etype = 'S' then
      begin
        FindFirst(DirecName + FName + '.MPC', AnyFile, FRec);
        if DosError = 0 then
          {$I-} Reset(PictureFile) {$I+}
        else
          {$I-} ReWrite(PictureFile) {$I+}
      end
    else
      {$I-} Reset(PictureFile); {$I+}
    result := IOresult;
    if result <> 0 then
      begin
        SetColor(White);
        TellCheck;
        repeat until KeyPressed;
        Ch := ReadKey;
        SetColor(Black);
        TellCheck;
      end
  end;
{---------------------------------------------------------------------------}
procedure LSPick(sizeX, z, w : Integer; picks : Byte; FName : String;
                 var pick : Byte);
  var
     Ch     : Char;
     number : String;
  begin
    pick := 0;
    repeat
      SetFillStyle(EmptyFill, Black);
      Bar(z - 1, w + pick * 10 - 1,
          z + sizeX - (SpaceFromBox * 2 + SiBox + 2), w + pick * 10 + 8);
      Str(pick + 1, number);
      SetColor(White);
      OutTextXY(z, w + pick * 10, FName + number);
      SetFillStyle(SolidFill, White);
      SetColor(Black);
      repeat
        Lock('C')
      until KeyPressed;
      Ch := ReadKey;
      case Ch of
        #0      : begin
                    Ch := ReadKey;
                    Bar(z - 1, w + pick * 10 - 1,
                        z + sizeX - (SpaceFromBox * 2 + SiBox + 2),
                                                          w + pick * 10 + 8);
                    OutTextXY(z, w + pick * 10, FName + number);
                    case Ch of
                      KeyUp   : if pick > 0 then
                                  pick := pick - 1;
                      KeyDown : if pick < picks then
                                  pick := pick + 1
                    end
                  end;
        Esc     : begin
                    pick := 111;
                    Exit
                  end
      end
    until Ch = Enter
  end;
{---------------------------------------------------------------------------}
procedure SaveFile(sizeX, a, b : Integer; var PictureFile : FPicture;
                                          var FName : String);
  var
     result,
     x, y, I : Integer;
     number  : String;
     fnum,
     pick    : Byte;
     size    : Word;
     visual  : PicFile;
  begin
    visual.picture := NIL;
    a := a + 3;
    b := b + 4;
    repeat
      FName := '';
      GRead(a, b, Black, White, 8, FName);
      if FName = '' then
        Exit
      else
        OpenFile(FName, 'S', result, PictureFile)
    until result = 0;
    x := a + 1;
    y := b + 40;
    if FileSize(PictureFile) = 12 then
      fnum := FileSize(PictureFile) - 1
    else
      fnum := FileSize(PictureFile);
    for I := 0 to fnum do
      begin
        Str(I + 1, number);
        OutTextXY(x, y + I * 10, FName + number)
      end;
    OutTextXY(x, y + (fnum + 1) * 10 + 4, '--File end--');
    LSPick(sizeX, x, y, fnum, FName, pick);
    if pick = 111 then
      Exit;
    if FileSize(PictureFile) <> 0 then
      if pick = FileSize(PictureFile) then
        begin
          New(visual.picture);
          Seek(PictureFile, FileSize(PictureFile) - 1);
          Read(PictureFile, visual);
          Dispose(visual.picture);
          visual.picture := NIL
        end
      else
        Seek(PictureFile, pick);
    visual.detaile := PointSize;
    visual.TabX := TableSizeX;
    visual.TabY := TableSizeY;
    size := ImageSize(FarX, FarY, GetMaxX - (PointSize - 1), FarY + TableSizeY * PointSize);
    GetMem(visual.picture, size);
    GetImage(FarX, FarY, GetMaxX - (PointSize - 1), FarY + TableSizeY * PointSize, visual.picture^);
    Write(PictureFile, visual);
    Close(PictureFile);
    FreeMem(visual.picture, size);
    visual.picture := NIL;
    saved := FALSE;
  end; { Save File }
{---------------------------------------------------------------------------}
procedure LoadFile(sizeX, a, b: Integer;var PictureFile : FPicture;
                                        var FName : String;
                                        var pick : Byte);
  var
     result, I : Integer;
     number    : String;
     counter,
     counter1  : Byte;
     visual    : PicFile;
     size      : Word;
  begin
    visual.picture := NIL;
    a := a + 3;
    b := b + 4;
    repeat
      FName := '';
      GRead(a, b, Black, White, 8, FName);
      if FName = '' then
        begin
          pick := 111;
          Exit
        end
      else
        OpenFile(FName, 'L', result, PictureFile)
    until result = 0;
    x := a + 1;
    y := b + 40;
    for I := 0 to FileSize(PictureFile) - 1 do
      begin
        if I <= 12 then
          begin
            Str(I + 1, number);
            OutTextXY(x, y + I * 10, FName + number)
          end
      end;
    LSPick(sizeX, x, y, FileSize(PictureFile) - 1, FName, pick);
    if pick = 111 then
      Exit;
    Seek(PictureFile, pick);
    Read(PictureFile, visual);
    PointSize := visual.detaile;
    TableSizeX := visual.TabX;
    TableSizeY := visual.TabY;
    SecondInit;
    size := ImageSize(FarX, FarY, GetMaxX - PointSize, FarY + TableSizeY * PointSize);
    GetMem(visual.picture, size);
    Seek(PictureFile, pick);
    Read(PictureFile, visual);
    PutImage(FarX, FarY, visual.picture^, NormalPut);
    Close(PictureFile);
    for counter := 1 to TableSizeX do
      for counter1 := 1 to TableSizeY do
         Paint(counter, counter1,
               GetPixel(counter * PointSize + FarX, counter1 * PointSize + FarY),
               BoxSize, GetChar, KeepPic);
    FreeMem(visual.picture, size);
    visual.picture := NIL;
    Sound(500);
    Delay(200);
    NoSound;
    saved := FALSE
  end; { Load File }
{---------------------------------------------------------------------------}
procedure FlipPick(x, y : Integer; var pick : Byte);
  var
     Ch : Char;
  begin
    pick := 1;
    repeat
      SetFillStyle(EmptyFill, Black);
      Bar(x + SpaceFromBox + 1, y + SiBox * 6 * pick + 1,
          x + SpaceFromBox + 6, y + SiBox * 6 * pick + 6);
      SetFillStyle(SolidFill, White);
      Ch := ReadKey;
      case Ch of
        #0      : begin
                    Ch := ReadKey;
                    Bar(x + SpaceFromBox + 1, y + SiBox * 6 * pick + 1,
                        x + SpaceFromBox + 6, y + SiBox * 6 * pick + 6);
                    case Ch of
                      KeyUp   : if pick > 1 then
                                  pick := pick - 1;
                      KeyDown : if pick < 2 then
                                  pick := pick + 1
                    end
                  end;
        Esc     : begin
                    pick := 111;
                    Exit
                  end
    end { case }
    until Ch = Enter
  end; { Flip pick }
{---------------------------------------------------------------------------}
procedure FlipAction(pick : Byte; var keep : KeepPicture);
  var
     counter,
     counter1 : Byte;
     Ch       : Char;
  begin
    for counter := 1 to TableSizeX do         { Repare the array }
      for counter1 := 1 to TableSizeY do
        keep[counter, counter1] := 0;
    for counter := 1 to TableSizeX do
      for counter1 := 1 to TableSizeY do
        if pick = 2 then
          Paint(TableSizeX - (counter - 1), counter1,
                 GetPixel(counter * PointSize + FarX, TableSizeY * PointSize + counter1 * PointSize + FarY + FarFlip),
                 BoxSize, Ch, Keep)
        else
          Paint(counter, TableSizeY - (counter1 - 1),
                 GetPixel(counter * PointSize + FarX, TableSizeY * PointSize + counter1 * PointSize + FarY + FarFlip),
                 BoxSize, Ch, Keep)
   end; { Flip Action }

{---------------------------------------------------------------------------}
procedure FlipWindow(x, y, sizeX, sizeY : Integer; var Table : KeepPicture);
  const
       F = 'Flip Picture';
  var
     FlipPtr : Pointer;
     size    : Word;
     counter,
     counter1: Integer;
     pick    : Byte;
  begin
    FlipPtr := NIL;
    size := ImageSize(x, y, x + sizeX + Shade, y + sizeY + Shade);
    GetMem(FlipPtr, size);
    GetImage(x, y, x + sizeX + Shade, y + sizeY + Shade, FlipPtr^);
    SetFillStyle(EmptyFill, Black);
    Bar(x + Shade, y + Shade, x + sizeX + Shade, y + sizeY + Shade);
    SetFillStyle(SolidFill, White);
    Bar(x, y, x + sizeX, y + sizeY);
    SetColor(Black);
    SetLineStyle(SolidLn, SolidFill, NormWidth);
    Rectangle(x + SiBox, y + SiBox,
              x + sizeX - SiBox, y + sizeY - SiBox);
    Rectangle(x + SpaceFromBox, y + SiBox * 6,
              x + SpaceFromBox + 7, y + SiBox * 6 + 7);
    Rectangle(x + SpaceFromBox, y + SiBox * 12,
              x + SpaceFromBox + 7, y + SiBox * 12 + 7);
    SetFillStyle(SolidFill, White);
    Bar(x + sizeX DIV 2 - (Length(F) DIV 2) * 8 - 2, y + 2,
        x + sizeX DIV 2 + (Length(F) DIV 2) * 8 + 2, y + 10);
    OutTextXY(x + sizeX DIV 2 - (Length(F) DIV 2) * 8, y + 2, F);
    OutTextXY(x + SiBox * 8, y + SiBox * 6,
              'Flip the picture up and down');
    OutTextXY(x + SiBox * 8, y + SiBox * 12,
              'Flip the picture left and right');
    FlipPick(x, y, pick);
    PutImage(x, y, FlipPtr^, NormalPut);
    FreeMem(FlipPtr, size);
    FlipPtr := NIL;
    if pick = 111 then
      Exit;
    size := ImageSize(FarX, FarY, GetMaxX - (PointSize - 1), FarY + TableSizeY * PointSize);
    GetMem(FlipPtr, size);
    GetImage(FarX, FarY, GetMaxX - (PointSize - 1), FarY + TableSizeY * PointSize, FLipPtr^);
    PutImage(FarX, FarFlip + FarY + PointSize * TableSizeY, FlipPtr^, NormalPut);
    FreeMem(FlipPtr, size);
    FlipPtr := NIL;
    FlipAction(pick, keepPic);
    SetFillStyle(EmptyFill, Black);
    Bar(FarX, FarFlip + FarY + PointSize * TableSizeY,
        GetMaxX - (PointSize - 1), FarY + 2 * (TableSizeY * PointSize) + FarFlip);
    Sound(500);
    Delay(200);
    NoSound
  end; { Flip Window }

procedure ChangeDirec(x, y, sizeX, sizeY : Integer;
                                     var DirecName : String);
  const
       F = 'Change Directory';
  var
     DirecPtr : Pointer;
     direc    : String;
     size     : Word;
     shadeD   : Byte;
     a, b     : Integer;
  begin
    DirecPtr := NIL;
    shadeD := Shade - 10;
    size := ImageSize(x, y, x + sizeX + shadeD, y + sizeY + shadeD);
    GetMem(DirecPtr, size);
    GetImage(x, y, x + sizeX + shadeD, y + sizeY + shadeD, DirecPtr^);
    SetFillStyle(EmptyFill, Black);
    Bar(x + shadeD, y + shadeD, x + sizeX + shadeD, y + sizeY + shadeD);
    SetFillStyle(SolidFill, Red);
    Bar(x, y, x + sizeX, y + sizeY);
    SetColor(White);
    SetLineStyle(SolidLn, SolidFill, NormWidth);
    Rectangle(x + SiBox, y + SiBox,
              x + sizeX - SiBox, y + sizeY - SiBox);
    SetFillStyle(EmptyFill, Black);
    Bar(x + 20, y + sizeY DIV 2 - 5, x + sizeX - 20, y + sizeY DIV 2 + 6);
    SetFillStyle(SolidFill, Red);
    Bar(x + sizeX DIV 2 - (Length(F) DIV 2) * 8 - 2, y + 2,
        x + sizeX DIV 2 + (Length(F) DIV 2) * 8 + 2, y + 10);
    OutTextXY(x + sizeX DIV 2 - (Length(F) DIV 2) * 8, y + 2, F);
    a := x + 21;
    b := y + sizeY DIV 2 - 3;
    direc := DirecName;
    GRead(a, b, White, Black, 25, DirecName);
    if DirecName = '' then
      DirecName := direc;
    PutImage(x, y, DirecPtr^, NormalPut);
    FreeMem(DirecPtr, size)
  end; { Change Directory }
{---------------------------------------------------------------------------}
procedure ExitProg(x, y, sizeX, sizeY : Integer; save : Boolean);
  var
     ExitPtr : Pointer;
     size    : Word;
  begin
    sizeX := sizeX * 2;
    sizeY := sizeY * 2;
    size := ImageSize(x, y, x + sizeX + Shade, y + sizeY + Shade);
    GetMem(ExitPtr, size);
    GetImage(x, y, x + sizeX + Shade, y + sizeY + Shade, ExitPtr^);
    sizeX := sizeX DIV 2;
    sizeY := sizeY DIV 2;
    SetColor(Black);
    SetFillStyle(EmptyFill, Black);
    Circle(x + Shade + sizeX DIV 2, y + Shade + sizeY DIV 2, sizeX);
    SetColor(Blue);
    SetFillStyle(cLOSEDotFill, Blue);
    Bar(x, y, x + sizeX, y + sizeY);
    SetColor(Yellow);
    if save = TRUE then
      begin
        OutTextXY(x + 20, (y + sizeY + Shade) DIV 2, 'Your picturehas not been saved');
        OutTextXY(x + 40, (y + sizeY + Shade) DIV 2 + 10, 'Save it now (Y/N)?')
      end
    else
      OutTextXY(x + 20, (y + sizeY + Shade) DIV 2, 'Do you realy want to exit (Y/N)?');
    repeat until KeyPressed;
    PutImage(x, y, ExitPtr^, NormalPut);
    FreeMem(ExitPtr, size)
  end;
{===========================================================================}
begin                   { M a i n  p r o g r a m }
  Init;
  repeat
    SetFillStyle(SolidFill, Color);            { Paint the color box }
    Bar(FarX, FarY + (TableSizeY + 1) * PointSize + ColorBox,
        GetMaxX, FarY + (TableSizeY + 1) * PointSize + ColorBox + 5);
    Corsur(moveX, moveY, Color, TRUE, keepPic);
    repeat
      Lock('C')
    until KeyPressed;
    getchar := ReadKey;  { Get the keys }
    case GetChar of
      #0          : GettingKeys;
      Tabs        : ExitProg(300, 200, 150, 60, saved);
      Space       : Paint(moveX, moveY, Color, BoxSize, GetChar, KeepPic);
      Pos, Neg    : Color := ColorChanging(Color, getchar);
      Esc         : SecondInit;
    end
  until GetChar = F8;
  CloseGraph
end.





