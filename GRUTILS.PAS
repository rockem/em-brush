unit GrUtils;

INTERFACE
{==========================================================================}

uses crt, graph;

  const
       BackSpace = #8;
       Enter     = #13;
       ESC       = #27;

       x         : Integer = 0;
       y         : Integer = 0;
       lmargin   = 0;

       RightKeys : Set of Char = ['/'..'9', 'A'..'z', Enter, BackSpace, #32];

  procedure GFileLoc(GPath : String);

  procedure HomeCorsur(var x, y : Integer);

  procedure GWrite(var x, y : Integer; gtext : String);

  procedure GWriteLn(var x, y : Integer; gtext : String);

  procedure Gpause;

  procedure GpauseXY(var x, y : Integer);

  procedure GRead(x, y : Integer;
                                   var gtext : String);

  procedure GLocate(x, y : Integer);

IMPLEMENTATION
{==========================================================================}

  var
     maxX, maxY : Integer;
     gtext : String;

  procedure GFileLoc(GPath : String);
                     { Procedure to locate the path of BGI files }
    var
       GDriver,
       GMode,
       gerror : Integer;
    begin
      ClrScr;
      repeat
        GDriver := Detect;
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

  procedure HomeCorsur(var x, y : Integer);
    begin
      x := 0;
      y := 0
    end;

  procedure GWrite(var x, y : Integer; gtext : String);
                   { Corresponds to Write }
    begin
      OutTextXY(x, y, gtext);
      x := x + TextWidth(gtext)
    end;

  procedure GWriteLn(var x, y : Integer; gtext : String);
                     { Corresponds to WriteLn }
    begin
      OutTextXY(x, y, gtext);
      y := y + TextHeight('M');
      x := lmargin
    end;

  procedure Gpause;
    var
       Ch : Char;
    begin
      SetTextJustify(LeftText, TopText);
      GWriteLn(x, y, '');
      GWriteLn(x, y, 'Press any key ...');
      repeat until KeyPressed;
      Ch := ReadKey;
      GWriteLn(x, y,'')
    end;  { End of Gpause }

  procedure GpauseXY(var x, y : Integer);
    var
       Ch : Char;
    begin
      SetLineStyle(TriplexFont, HorizDir, 2);
      SetTextJustify(LeftText, TopText);
      GWriteLn(x, y, '');
      GWriteLn(x, y, 'Press any key ...');
      repeat until KeyPressed;
      Ch := ReadKey;
      GWriteLn(x, y, '')
    end;    { End of GpauseXY }

  procedure GRead(x, y : Integer;
                                      var gtext : String);
    const
         long = 8;
         color = White;
         bkcolor = Black;

    var
       Ch : Char;
    begin
      SetFillStyle(SolidFill, bkcolor);
      Bar(x, y, x + 8 * long, y + 8);
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
      until ch = Enter;
      SetFillStyle(SolidFill, bkcolor);
      Bar(x, y, x + 8, y + 8)
    end;    { End of GRead }

  procedure GLocate(x, y : Integer);
    begin
      MoveTo(x * 8 - 8, y * 8 - 8)
    end;


end. { End of GraphUtils }