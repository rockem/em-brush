unit EmTool;

INTERFACE
{===========================================================================}
uses crt, graph;

  const
       ESC        = #27;   F1 = #59;     { Keys define }
       KeyUp      = #72;   F2 = #60;
       KeyDown    = #80;   F3 = #61;
       KeyRight   = #77;   F4 = #62;
       KeyLeft    = #75;   F5 = #63;
       Space      = #32;   F6 = #64;
       Pos        = #43;   F7 = #65;
       Neg        = #45;   F8 = #66;
       Enter      = #13;   F9 = #67;
       Quit       = #9;    F10 = #68;
       Delete     = #83;   Tabs = #9;

       Frame       = 13;
       ThickFrame  = 14;

       Shade : Integer = 20;
       Farr   : Integer = 5;

  procedure SetWindow(x, y, sizeX, sizeY, WinColor, WinType : Integer;
                                var WinPointer : Pointer; var WinSize : Word);

  procedure DisWindow(x, y : Integer; var WinPointer : Pointer;
                                                             WinSize : Word);

  procedure FreePointer(var WinPointer : Pointer; WinSize : Word);

  procedure TableDoering(TableX, TableY, Box, Color : Integer);

  procedure PrintTopMessage(x, y, sizeX, F, B : Integer; message : String);

  procedure LWrite(x, y : Integer; massege : String);

  procedure PSpace(x, y, Bk, Lengths : Integer);

  procedure CapsLock;

  procedure NumLock;

IMPLEMENTATION
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
  const
       MaxDefTypes = 12;


  procedure CapsLock;
    begin
      asm
        mov bx, 0
        mov es, bx
        or byte ptr es:[417h], 40h
        and byte ptr es:[417h], 04Bh
      end
    end;

  procedure NumLock;
    begin
      asm
        mov bx, 0
        mov es, bx
        or byte ptr es:[417h], 20h
        and byte ptr es:[417h], 02Bh
      end
    end;

  procedure FreePointer(var WinPointer : Pointer; WinSize : Word);
    begin
      if WinPointer = NIL then
        Exit;
      FreeMem(WinPointer, WinSize);
      WinPointer := NIL
    end;

  procedure SetWindow(x, y, sizeX, sizeY, WinColor, WinType : Integer;
                                var WinPointer : Pointer; var WinSize : Word);
    begin
      if WinPointer <> NIL then
        WinPointer := NIL;
      WinSize := ImageSize(x, y, x + sizeX + Shade, y + sizeY + Shade);
      GetMem(WinPointer, WinSize);
      GetImage(x, y, x + sizeX + Shade, y + sizeY + Shade, WinPointer^);
      if WinColor <> Black then
        SetFillStyle(EmptyFill, Black)
      else
        SetFillStyle(SolidFill, LightGray);
      Bar(x + Shade, y + Shade, x + sizeX + Shade, y + sizeY + Shade);
      if WinType > MaxDefTypes then
        SetFillStyle(SolidFill, WinColor)
      else
        SetFillStyle(WinType, WinColor);
      Bar(x, y, x + sizeX, y + sizeY);
      if WinType > MaxDefTypes then
        begin
          if (WinColor <> Black) AND (WinColor <> Red) then
            SetColor(Black)
          else
            SetColor(White);
          case WinType of
            Frame          : SetLineStyle(SolidLn, SolidFill, NormWidth);
            ThickFrame     : SetLineStyle(SolidLn, SolidFill, ThickWidth)
          end;
          Rectangle(x + Farr, y + Farr, x + sizeX - Farr, y + sizeY - Farr)
        end
    end; { SetWindow proc}

  procedure DisWindow(x, y : Integer; var WinPointer : Pointer;
                                                         WinSize : Word);
    begin
      if WinPointer = NIL then
        Exit;
      PutImage(x, y, WinPointer^, NormalPut);
      FreePointer(WinPointer, WinSize)
    end;

  procedure TableDoering(TableX, TableY, Box, Color : Integer);
    var
       counter : Integer;
    begin
      SetColor(Color);
      SetLineStyle(SolidLn, SolidFill, NormWidth);
      for counter := 0 to TableX do
        Line(counter * Box, 0, counter * Box, TableY * Box);
      for counter := 0 to TableY do
        Line(0, counter * Box, TableX * Box, counter * Box)
    end;

  procedure PrintTopMessage(x, y, sizeX, F, B : Integer; message : String);
    begin
      SetFillStyle(SolidFill, B);
      Bar(x + sizeX DIV 2 - (Length(message) DIV 2) * 8 - 2, y + 2,
          x + sizeX DIV 2 + (Length(message) DIV 2) * 8 + 2, y + 10);
      SetColor(F);
      OutTextXY(x + sizeX DIV 2 - (Length(message) DIV 2) * 8, y + 2, message)
    end;

  procedure LWrite(x, y : Integer; massege : String);
    begin
      OutTextXY(x * 8, y * 8, massege)
    end;

  procedure PSpace(x, y, Bk, Lengths : Integer);
    begin
      SetFillStyle(SolidFill, Bk);
      x := x * 8;
      y := y * 8;
      Bar(x, y, x + Lengths * 8, y + 8)
    end;

end.


