Procedure Emergency_Overide;
Begin
  HideMouse;
    CRT.GotoXY(1,1);
    CRT.TextBackground(Black);
    CRT.TextColor(Green);
    CRT.ClrScr;
    TPCRT.BlockCursor;
    Writeln('Press ESCAPE key to exit MCPU Communications', ^J);
    MCPU_Overide;
    TPCRT.HiddenCursor;
  ShowMouse;
  MenuBar^.Draw;
  StatusLine^.Draw;
  DeskTop^.Draw;
  InitEvents;
End;

Procedure Emergency_Terminal;
var ch : char;
    comstat : boolean;
Begin
  HideMouse;
    CRT.GotoXY(1,1);
    CRT.TextBackground(Black);
    CRT.TextColor(Green);
    CRT.ClrScr;
    TPCRT.BlockCursor;
    Writeln('Press ESCAPE key to exit Terminal Communications', ^J);
    repeat
       repeat
          InSioSt(ComStat);
       until (ComStat) OR (KeyPressed);
       if (ComStat)
          then begin
          InSio(ch);
          Write(ch);
          if (ch = ^M) then Writeln;
          end;
       if (KeyPressed)
          then begin
          ch := ReadKey;
          OutSio(ch);
          Write(ch);
          if (ch = ^M) then Writeln;
          end;
    until (ch = ^[);
    TPCRT.HiddenCursor;
  ShowMouse;
  MenuBar^.Draw;
  StatusLine^.Draw;
  DeskTop^.Draw;
  InitEvents;
End;

