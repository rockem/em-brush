program Pictures_Maker;
uses crt, graph, dos, Emtool, pcutils;

  const
       MTableSizeX  = 79;
       MTableSizeY  = 79;
       GCorsurSize  = 2;
       ColorBox     = 4;
       SpaceFromBox = 20;
       WriteHight   = 35;
       FarFlip      = 50;
       AutoMes      = 'Auto';
       LoadMes      = 'Load Picture';
       SaveMes      = 'Save Picture';
       FlipMes      = 'Flip Picture';
       SizeMes      = 'Picture Size';
       DirecMes     = 'Change Directory';

  type
      KeepPicture = array[1..MTableSizeX, 1..MTableSizeY] of Integer;
      PFile = File of Integer;

  var
     Color, BoxSize,
     FarX, FarY, PointSize,
     moveX, TableSizeX,
     moveY, TableSizeY      : Integer;
     keepPic                : KeepPicture;
     AutoPaint,
     saved, YesNo           : Boolean;
     GetChar                : Char;
     PictureFile            : PFile;
     FileName,
     DirecName              : String;

procedure Init;
  Forward;

procedure WriteTitle(var FileName : String);
  Forward;

procedure Auto(fy : Integer; var AutoP : Boolean);
  Forward;

procedure go_on(x, y, sizeX, sizeY : Integer);
  Forward;

{============================================================================}
procedure beep;
  begin
    Sound(500);
    Delay(200);
    NoSound
  end;
{----------------------------------------------------------------------------}
procedure TableMaking(TableSizeX, TableSizeY : Integer;
                                                      var keep : KeepPicture;
                                                      var BoxSize : Integer);
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

  var
     counter,
     counter1 : Integer;
  begin         { Main procedure }
    ClearDevice;
    for counter := 1 to TableSizeX do         { Repare the array }
      for counter1 := 1 to TableSizeY do
        keep[counter, counter1] := 0;
    BoxSize := Box(TableSizeX, TableSizeY);
    TableDoering(TableSizeX, TableSizeY, BoxSize, White);
    SetLineStyle(SolidLn, SolidFill, NormWidth);      { Painting the max size of the table }
    Rectangle(0, 0, MTableSizeX * 6, MTableSizeY * 6);
    if TableSizeX <> 79 then
      begin
        SetFillStyle(SolidFill, DarkGray);
        FloodFill(TableSizeX * BoxSize + 3, 10, White)
      end
  end; { Table Making }
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
  end; { Paint }
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
  end; { Corsur }
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
    end;  { Color Changing }
{---------------------------------------------------------------------------}
procedure Help(x, y, sizeX, SizeY : Integer);
  const                                      { Paints the help Window }
       MaxHelp = 16;
       Helps : array[1..MaxHelp] of String = ('Space - Erase / Draw',
                                              'Delete - Erase',
                                              'Arrow Key - ' + Chr(24) + ' up',
                                              '            ' + Chr(25) + ' down',
                                              '            ' + Chr(26) + ' left',
                                              '            ' + Chr(27) + ' right',
                                              '-/+ - Change Color',
                                              'Esc - Erase the picture',
                                              'F2 - Save Picture',
                                              'F3 - Load Picture',
                                              'F4 - Flip Picture',
                                              'F5 - Change Directory',
                                              'F6 - Picture Size',
                                              'F7 - Automatic Painting',
                                              'F8 - Net Color',
                                              'F10 - Exit to dos');

  var
     WinPtr    : Pointer;
     size      : Word;
     I         : Integer;
     Ch        : Char;
  begin
    SetWindow(x, y, sizeX, sizeY, Red, SlashFill, WinPtr, size);
    SetColor(LightGreen);
    for I := 1 to MaxHelp do           { Print the masseges }
      OutTextXY(x + 10, y + I * 15, Helps[I]);
    SetColor(LightCyan);
    GPauseXY(x + 5, y + sizeY - 15);
    DisWindow(x, y, WinPtr, size)
  end; { Help }
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
    WriteTitle(FileName);
    SetFillStyle(SolidFill, DarkGray);             { Paint the help scuare }
    Bar(GetMaxX - 80, GetMaxY - 12, GetMaxX, GetMaxY);
    SetColor(Yellow);
    x := GetMaxX - 40; y := GetMaxY - 10;
    GWrite(x, y, 'Help');
    x := GetMaxX - 75; y := GetMaxY - 10;
    GWrite(x, y, 'F1-');
    moveX := 34; moveY := 27;
  end; { Second Init }
{---------------------------------------------------------------------------}
procedure Init;
  begin
    PointSize := 2; TableSizeX := 79; TableSizeY := 79;
    GetDir(0, DirecName);              { Initialize the variable }
    GFileLoc('c:\bp7\bgi');
    FileName := '';
    saved := FALSE;
    Color := White;
    FarY := 2;
    SecondInit
  end; { Init }
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
function TableColor : Integer;
  var
     x : Integer;
  begin
    x := GetPixel(0, 0);
    if x <> White then
      TableColor := White
    else
      TableColor := DarkGray
  end;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=S=I=Z=E=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
procedure SizePick(x, y : Integer; var pick, pick1 : Byte);
  var
     Ch : Char;
  begin
    pick := 1;
    repeat
      SetFillStyle(SolidFill, White);
      Bar(x + SpaceFromBox + 1, y + Far * pick * 4 + 6,
          x + SpaceFromBox + 6, y + Far * pick * 4 + 11);
      SetFillStyle(SolidFill, Red);
      Ch := ReadKey;
      case Ch of
        #0      : begin
                    Ch := ReadKey;
                    Bar(x + SpaceFromBox + 1, y + Far * pick * 4 + 6,
                        x + SpaceFromBox + 6, y + Far * pick * 4 + 11);
                    case Ch of
                      KeyUp   : if pick > 1 then
                                  pick := pick - 1
                                else
                                  pick := 7;
                      KeyDown : if pick < 7 then
                                  pick := pick + 1
                                else
                                  pick := 1;
                    end
                  end;
        Esc     : begin
                    pick := 111;
                    Exit
                  end
    end { case }
    until Ch = Enter;
    pick1 := 8;
    repeat
      SetFillStyle(SolidFill, White);
      Bar(x + SpaceFromBox + 1, y + Far * pick1 * 4 + 16,
          x + SpaceFromBox + 6, y + Far * pick1 * 4 + 21);
      SetFillStyle(SolidFill, Red);
      Ch := ReadKey;
      case Ch of
        #0      : begin
                    Ch := ReadKey;
                    Bar(x + SpaceFromBox + 1, y + Far * pick1 * 4 + 16,
                        x + SpaceFromBox + 6, y + Far * pick1 * 4 + 21);
                    case Ch of
                      KeyUp   : if pick1 > 8 then
                                  pick1 := pick1 - 1
                                else
                                  pick1 := 9;
                      KeyDown : if pick1 < 9 then
                                  pick1 := pick1 + 1
                                else
                                  pick1 := 8;
                    end
                  end;
        Esc     : begin
                    pick := 111;
                    Exit
                  end
      end { case }
    until Ch = Enter;
  end; { Size pick }
{----------------------------------------------------------------------------}
procedure SizeAction(pick, pick1 : Byte);
  begin
    case pick of
      1         : begin
                    TableSizeX := 79;
                    TableSizeY := 79;
                  end;
      2         : begin
                    TableSizeX := 55;
                    TableSizeY := 79;
                  end;
      3         : begin
                    TableSizeX := 65;
                    TableSizeY := 79;
                  end;
      4         : begin
                    TableSizeX := 65;
                    TableSizeY := 65;
                  end;
      5         : begin
                    TableSizeX := 65;
                    TableSizeY := 40;
                  end;
      6         : begin
                    TableSizeX := 40;
                    TableSizeY := 65;
                  end;
      7         : begin
                    TableSizeX := 40;
                    TableSizeY := 40;
                  end;
    end; { case }
    case pick1 of
      8          : PointSize := 2;
      9          : PointSize := 1;
    end; { case }
    if saved = TRUE then
      go_on(150, 200, 250, 70);
    SecondInit;
  end; { Size Action }
{----------------------------------------------------------------------------}
procedure SizeWindow(x, y, sizeX, sizeY : Integer);
  const
       Sizes : array[1..9] of string = ('79 X 79',
                                        '55 X 79',
                                        '65 X 79',
                                        '65 X 65',
                                        '65 X 40',
                                        '40 X 65',
                                        '40 X 40',
                                        'Low Detaile',
                                        'High Detaile');


  var
     WinPtr : Pointer;
     size   : Word;
     I      : Integer;
     pick,
     pick1  : byte;
  begin
    SetWindow(x, y, sizeX, sizeY, Red, Frame, WinPtr, size);
    SetColor(White);
    SetLineStyle(SolidLn, SolidFill, NormWidth);
    for I :=  1 to 7 do
      begin
        Rectangle(x + SpaceFromBox, y + Far * I * 4 + 5,
                  x + SpaceFromBox + 7, y + Far * I * 4 + 12);
        OutTextXY(x + Far * 8, y + Far * I * 4 + 5, Sizes[I]);
      end;
    for I := 8 to 9 do
     begin
       Rectangle(x + SpaceFromBox, y + Far * I * 4 + 15,
                 x + SpaceFromBox + 7, y + Far * I * 4 + 22);
       OutTextXY(x + Far * 8, y + Far * I * 4 + 15, Sizes[I]);
     end;
    PrintTopMessage(x, y, sizeX, White, Red, SizeMes);
    SizePick(x, y, pick, pick1);
    DisWindow(x, y, WinPtr, size);
    if pick <> 111 then
      SizeAction(pick, pick1);
  end;
{-=-=-=-=-=-=-=-=-=-=-=-=-F-I-L-E-S-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-}
procedure OpenFile(FName : String; Etype : Char; var result : Integer;
                                                 var PictureFile : PFile);
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

  procedure TellCheckControl;
    begin
      SetColor(White);
      TellCheck;
      repeat until KeyPressed;
      Ch := ReadKey;
      SetColor(Black);
      TellCheck;
    end;

  begin
    Assign(PictureFile, FName + '.MPC');
    if Etype = 'S' then
      begin
        FindFirst(DirecName + FName + '.MPC', AnyFile, FRec);
        if DosError = 0 then
          {$I-} Reset(PictureFile) {$I+}
        else
          {$I-} ReWrite(PictureFile) {$I+}
      end
    else
      begin
        {$I-} Reset(PictureFile); {$I+}
        result := IOresult;
        if result <> 0 then
          TellCheckControl
      end
  end; { Open File }
{---------------------------------------------------------------------------}
procedure SaveFile(sizeX, a, b : Integer; var PictureFile : PFile;
                                          var FName : String);
  var
     result,I,Z  : Integer;
     size    : Word;
     picture : Pointer;

  begin
    picture := NIL;
    a := a + 3;
    b := b + 4;
    GRead(a, b, Black, White, 8, FName);
    if FName = '' then
      Exit
    else
      OpenFile(FName, 'S', result, PictureFile);
    Write(PictureFile, TableSizeX, TableSizeY, PointSize);
    for I := 1 to TableSizeY do
      for Z := 1 to TableSizeX do
        Write(PictureFile, KeepPic[Z, I]);
    Close(PictureFile);
    saved:= FALSE;
    beep;
  end; { Save File }
{---------------------------------------------------------------------------}
procedure LoadFile(sizeX, a, b, x, y: Integer;var PictureFile : PFile;
                                              var FName : String;
                                              var pick : Byte;
                                              WinPtr : Pointer;
                                              size : Word);
  var
     result, I,Z,C : Integer;
     number,
     picknum   : String;
  begin
    pick := 0;
    a := a + 3;
    b := b + 4;
    repeat
      GRead(a, b, Black, White, 8, FName);
      if FName = '' then
        begin
          pick := 111;
          Exit
        end
      else
        OpenFile(FName, 'L', result, PictureFile)
    until (result = 0);
    if saved = TRUE then
      go_on(150, 200, 250, 70);
    Read(PictureFile, TableSizeX);
    Read(PictureFile, TableSizeY);
    Read(PictureFile, PointSize);
    DisWindow(x, y, WinPtr, size);
    SecondInit;
    for I := 1 to TableSizeY do
      for Z := 1 to TableSizeX do
        begin
          Read(PictureFile, C);
          Paint(Z, I, C, BoxSize, GetChar, keepPic);
        end;
    Close(PictureFile);
    saved := FALSE;
    beep;
  end; { Load File }
{---------------------------------------------------------------------------}
procedure FileWindow(x, y, sizeX, sizeY : Integer; WType : Char);
  var
     WinPtr : Pointer;
     size   : Word;
     pick   : Byte;
  begin
    SetWindow(x, y, sizeX, sizeY, White, Frame, WinPtr, size);
    SetLineStyle(SolidLn, SolidFill, NormWidth);
    SetColor(Black);
{Up}Rectangle(x + SpaceFromBox, y + WriteHight,
              x + sizeX - SpaceFromBox, y + WriteHight + 15);
    MoveTo(x + SpaceFromBox, y + WriteHight + 30);
    OutText(DirecName);
    MoveTo(x + sizeX DIV 2 - (Length(LoadMes) DIV 2) * 8, y + Far + 10);
    if WType = 'L' then
      begin
        OutText(LoadMes);
        LoadFile(sizeX, x + SpaceFromBox, y + WriteHight, x, y,
                                                PictureFile, FileName, pick, WinPtr, size);
        if pick = 111 then
          DisWindow(x, y, WinPtr, size);
        WriteTitle(FileName)
      end
    else
      begin
        OutText(SaveMes);
        SaveFile(sizeX, x + SpaceFromBox, y + WriteHight,
                                                PictureFile, FileName);
        DisWindow(x, y, WinPtr, size);
        WriteTitle(FileName)
      end;
  end; { File Windows }
{-=-=-=-=-=-=-=-=-=-=-=-=-=-F-L-I-P-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-}
procedure FlipPick(x, y : Integer; var pick : Byte);
  var
     Ch : Char;
  begin
    pick := 1;
    repeat
      SetFillStyle(EmptyFill, Black);
      Bar(x + SpaceFromBox + 1, y + Far * 6 * pick + 1,
          x + SpaceFromBox + 6, y + Far * 6 * pick + 6);
      SetFillStyle(SolidFill, White);
      Ch := ReadKey;
      case Ch of
        #0      : begin
                    Ch := ReadKey;
                    Bar(x + SpaceFromBox + 1, y + Far * 6 * pick + 1,
                        x + SpaceFromBox + 6, y + Far * 6 * pick + 6);
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
procedure Flip(pick : Byte; var keepP : KeepPicture);
  var
     FlipPtr  : Pointer;
     size     : Word;
     counter,
     counter1 : Integer;
  begin
    size := ImageSize(FarX, FarY, GetMaxX - (PointSize - 1), FarY + TableSizeY * PointSize);
    GetMem(FlipPtr, size);
    GetImage(FarX, FarY, GetMaxX - (PointSize - 1), FarY + TableSizeY * PointSize, FLipPtr^);
    PutImage(FarX, FarFlip + FarY + PointSize * TableSizeY, FlipPtr^, NormalPut);
    FreeMem(FlipPtr, size);
    FlipPtr := NIL;
    FlipAction(pick, keepP);
    SetFillStyle(EmptyFill, Black);
    Bar(FarX, FarFlip + FarY + PointSize * TableSizeY,
        GetMaxX - (PointSize - 1), FarY + 2 * (TableSizeY * PointSize) + FarFlip);

  end; { Flip }
{---------------------------------------------------------------------------}
procedure FlipWindow(x, y, sizeX, sizeY : Integer);
  var
     WinPtr : Pointer;
     size   : Word;
     pick   : Byte;
  begin
    SetWindow(x, y, sizeX, sizeY, White, Frame, WinPtr, size);
    SetColor(Black);
    SetLineStyle(SolidLn, SolidFill, NormWidth);
    Rectangle(x + SpaceFromBox, y + Far * 6,
              x + SpaceFromBox + 7, y + Far * 6 + 7);
    Rectangle(x + SpaceFromBox, y + Far * 12,
              x + SpaceFromBox + 7, y + Far * 12 + 7);
    PrintTopMessage(x, y, sizeX, Black, White, FlipMes);
    OutTextXY(x + Far * 8, y + Far * 6,
              'Flip the picture up and down');
    OutTextXY(x + Far * 8, y + Far * 12,
              'Flip the picture left and right');
    FlipPick(x, y, pick);
    DisWindow(x, y, WinPtr, size);
    if pick <> 111 then
      begin
        if saved = TRUE then
          go_on(100, 100, 250, 70);
        Flip(pick, keepPic);
        beep;
      end;
  end; { Flip Window }
{---------------------------------------------------------------------------}
procedure ChangeDirec(x, y, sizeX, sizeY : Integer;
                                                  var DirecName : String);
  var
     WinPtr   : Pointer;
     size     : Word;
     direc    : String;
     a, b     : Integer;
  begin
    Shade := 10;
    SetWindow(x, y, sizeX, sizeY, Red, Frame, WinPtr, size);
    SetFillStyle(EmptyFill, Black);
    Bar(x + 20, y + sizeY DIV 2 - 5, x + sizeX - 20, y + sizeY DIV 2 + 6);
    SetFillStyle(SolidFill, Red);
    Bar(x + sizeX DIV 2 - (Length(DirecMes) DIV 2) * 8 - 2, y + 2,
        x + sizeX DIV 2 + (Length(DirecMes) DIV 2) * 8 + 2, y + 10);
    OutTextXY(x + sizeX DIV 2 - (Length(DirecMes) DIV 2) * 8, y + 2, DirecMes);
    a := x + 21;
    b := y + sizeY DIV 2 - 3;
    direc := DirecName;
    GRead(a, b, White, Black, 25, DirecName);
    {$I-} ChDir(DirecName); {$I-}
    if (DirecName = '') OR (IOResult<>0) then
      DirecName := direc;
    DisWindow(x, y, WinPtr, size);
    Shade := 20
  end; { Change Directory }
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=E=X=I=T=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
procedure ExitProgram(WPtr : Pointer; size : Word);
  var
     I : Integer;
  begin
    FreePointer(WPtr, size);
    if saved = TRUE then
      go_on(100, 100, 250, 70);
    SetFillStyle(EmptyFill, Black);
    SetColor(Black);
    for I := 80 downto 1 do
      Circle(GetMaxX DIV 2, GetMaxY DIV 2, I * 5);
    ClearDevice;
    CloseGraph;
    NumLock;
    ClrScr;
    Halt(1)
  end;
{---------------------------------------------------------------------------}
procedure ExitWindow(x, y, sizeX, sizeY : Integer);
  const
       Ask = 'Do you realy want to exit';
       cho = '(Y / N)';
  var
     WinPtr : Pointer;
     size   : Word;
     Ch     : Char;
  begin
    SetWindow(x, y, sizeX, sizeY, Red, SolidFill, WinPtr, size);
    SetColor(LightGray);
    SetLineStyle(SolidLn, SolidFill, NormWidth);
    Rectangle(x, y, x + sizeX, y + sizeY);
    SetColor(DarkGray);
    SetLineStyle(SolidLn, SolidFill, ThickWidth);
    Rectangle(x + 2, y + 2, x + sizeX - 2, y + sizeY - 2);
    SetColor(White);
    OutTextXY(x + sizeX DIV 2 - (Length(Ask) DIV 2) * 8 - 4, y + sizeY DIV 2 - 24, Ask);
    OutTextXY(x + sizeX DIV 2 - (Length(cho) DIV 2) * 8 - 4, y + sizeY DIV 2 - 10, cho);
    OutTextXY(x + sizeX DIV 2 - 4, y + sizeY DIV 2 + 10, '?');
    repeat
      Ch := upcase(ReadKey);
      if Ch = 'Y' then
        ExitProgram(WinPtr, size)
    until Ch = 'N';
    DisWindow(x, y, WinPtr, size)
  end; { Exit Window }
{=-=-=-=-=-=-=-=-=-=-=-=-K-=E=-Y-=S=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
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
      F7          : Auto(FarY, AutoPaint);
      F1          : Help(100, 100, 250, 320);
      F2          : FileWindow(200, 100, 250, 100, 'S');
      F3          : FileWindow(200, 100, 250, 100, 'L');
      F4          : FlipWindow(100, 150, 300, 100);
      F5          : ChangeDirec(1, 1, 250, 50, DirecName);
      F6          : SizeWindow(150, 100, 170, 240);
      F8          : TableDoering(TableSizeX, TableSizeY, BoxSize, TableColor);
      F10         : ExitWindow(150, 150, 250, 100);
      Delete      : Paint(moveX, moveY, Color, BoxSize, GetChar, KeepPic)
    end
  end; { Getting Keys }
{---------------------------------------------------------------------------}
procedure go_on(x, y, sizeX, sizeY : Integer);
  const
       sen1 = 'Your picture was''nt saved';
       sen2 = 'save it now ?';
  var
     WinPtr : Pointer;
     size   : Word;
     ch     : Char;
  begin
    SetWindow(x, y, sizeX, sizeY, Yellow, Frame, WinPtr, size);
    SetColor(Black);
    OutTextXY(x + sizeX DIV 2 - (Length(sen1) DIV 2) * 8 - 4, y + sizeY DIV 2 - 18, sen1);
    OutTextXY(x + sizeX DIV 2 - (Length(sen2) DIV 2) * 8 - 4, y + sizeY DIV 2 + 10, sen2);
    repeat
      ch := ReadKey;
      ch := upcase(ch);
    until (ch = 'Y') OR (ch = 'N');
    if ch = 'Y' then
      FileWindow(200, 100, 250, 100, 'S');
    DisWindow(x, y, WinPtr, size);
  end;
{---------------------------------------------------------------------------}
procedure WriteTitle(var FileName : String);
  var
     x, y, I : Integer;
  begin
    if FileName = '' then
      FileName := 'UnTilted';
    x := MTableSizeX * 6 + 10;
    y := GetMaxY - 250;
    SetFillStyle(EmptyFill, Black);
    Bar(MTableSizeX * 6 + 10, y, x + 8, y + 9 * 12);
    SetColor(White);
    for I := 1 to Length(FileName) do
      OutTextXY(x, y + I * 12, FileName[I])
  end; { Write Title }
{---------------------------------------------------------------------------}
procedure Title;
  var
     ch : Char;
  begin
    TextMode(co80);
    Textcolor(White);
    gotoXY(31, 5);
    Write('EM_BRUSH Ver 2.0');
    TextColor(LightBlue);
    gotoXY(29, 6);
    Write('--------------------');
    TextColor(White);
    gotoXY(29, 10);
    Write('Written by Eli Segal');
    TextColor(DarkGray);
    gotoXY(1, 22);
    Write('Thanks to : meytal, moshe, omri, eli, and all who I know');
    TextColor(White);
    gotoXY(1, 15);
    Write('Press any key . . .');
    while KeyPressed do
      ch := ReadKey;
    repeat until KeyPressed;
  end;
{===========================================================================}
begin                   { M a i n  p r o g r a m }
  Title;
  Init;
  repeat
    SetFillStyle(SolidFill, Color);            { Paint the color box }
    Bar(FarX, FarY + (TableSizeY + 1) * PointSize + ColorBox,
        GetMaxX, FarY + (TableSizeY + 1) * PointSize + ColorBox + 5);
    Corsur(moveX, moveY, Color, TRUE, keepPic);
    repeat
      CapsLock;
    until KeyPressed;
    getchar := ReadKey;  { Get the keys }
    case GetChar of
      #0          : GettingKeys;
      Space       : Paint(moveX, moveY, Color, BoxSize, GetChar, KeepPic);
      Pos, Neg    : Color := ColorChanging(Color, getchar);
      Esc         : begin
                      if saved = TRUE then
                        go_on(100, 100, 250, 70);
                      SecondInit;
                    end
    end
  until GetChar = Chr(1);
end. { Main Program }





