unit PcUtils;

INTERFACE
{==========================================================================}

uses crt, graph;

  const
       BackSpace = #8;
       Enter     = #13;
       ESC       = #27;

       x         : Integer = 0;
       y         : Integer = 0;
       RightKeys : Set of Char = ['/'..':', '@'..'z', Enter, BackSpace, #32];

  procedure GFileLoc(GPath : String);

  procedure GWrite(var x, y : Integer; gtext : String);

  procedure GpauseXY(x, y : Integer);

  procedure GRead(x, y, color, bkcolor, long : Integer;
                                 var gtext : String);

IMPLEMENTATION
{==========================================================================}

  var
     GDriver,
     GMode,
     maxX, maxY : Integer;

     gtext : String;


  procedure GFileLoc(GPath : String);
                     { Procedure to locate the path of BGI files }
    var
       GDriver, GMode,
       gerror         : Integer;

    begin
      ClrScr;
      repeat
        GDriver := Vga; GMode := VgaHi;
        InitGraph(GDriver, GMode, GPath);
        gerror := GraphResult;
        if gerror <> grOK then
          begin
            WriteLn('Graphics error: ',GraphErrorMsg(gerror));
            if gerror = GrFileNotFound then
              begin
                WriteLn(' Can''t find graphics driver. Please');
                Write('enter directory path for the driver: ');
                ReadLn(GPath);
                WriteLn
              end
            else
              Halt(1)
          end
      until gerror = grOK;
    end;  { End of GFileLoc }

  procedure GWrite(var x, y : Integer; gtext : String);
                   { Corresponds to Write }
    begin
      OutTextXY(x, y, gtext);
      x := x + TextWidth(gtext)
    end;

  procedure GpauseXY(x, y : Integer);
    var
       Ch : Char;
    begin
      SetLineStyle(TriplexFont, HorizDir, 2);
      GWrite(x, y, 'Press any key ...');
      repeat until KeyPressed;
      Ch := ReadKey;
    end;    { End of GpauseXY }

  procedure GRead(x, y, color, bkcolor, long : Integer;
                                   var gtext : String);
    var
       Ch : Char;
    begin
      SetFillStyle(SolidFill, bkcolor);
      Bar(x, y, x + 8 * long, y + 8);
      SetColor(color);
      GWrite(x, y, gtext);
      repeat
        SetColor(color);
        OutTextXY(x, y, 'Û');
        Ch := ReadKey;
        if ch = Esc then
          begin
            gtext := '';
            Exit
          end;
        if (ch <> Enter) AND (ch IN RightKeys) then
          begin
            if (Ch = BackSpace) AND (gtext <> '') then
              begin
                x := x - 8;
                SetFillStyle(SolidFill, bkcolor);
                Bar(x, y, x + 16, y + 8);
                Delete(gtext, Length(gtext), 1)
              end
            else
              if (ch <> BackSpace) AND (Length(gtext) < long) then
                begin
                  SetFillStyle(SolidFill, bkcolor);
                  Bar(x, y, x + 8, y + 8);
                  SetColor(color);
                  gtext := gtext + ch;
                  GWrite(x, y, ch)
                end;
          end
      until ch = Enter
    end;    { End of GRead }

end. { End of GraphUtils }