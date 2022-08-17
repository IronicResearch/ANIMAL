(* Test for Mikey's RGB light source. *)

Program Test_RGB;

Uses TPCRT,DOS,KEYBD;

{$I SIOX.LIB}       (* port-selectable serial IO library *)
{$I CMDLN.INC}      (* command line option *)

Const
   QUIT = #$1B;

Var
   Cmd : char;
   R, G, B : integer;
Const
   Portx : integer = 2;
   DeltaTime : integer = 10;

Procedure InitStuff;
Begin
   R := 0; G:= 0; B:= 0;
   DeltaTime := 10;
End;

(* serial support *)
Procedure OutCmd (C : char);
Begin
   OutSio (C);
End;

Procedure OutStr (S : string);
Var C : char;
    I : integer;
Begin
   For I := 1 to Length(S) Do
       if S[I] = ' '
          Then OutCmd ('0')
          Else OutCmd (S[I]);
End;

Function Bytewise (I : integer) : byte;
begin
   If I > 255
      Then Bytewise := 255
   Else If I < 0
      Then Bytewise := 0
   Else Bytewise := I;
End;

(* output RGB values to serial port *)
Procedure OutRed (I : integer);
Var S : String[3];
Begin
   OutCmd ('R');
   Str (Bytewise(I):3, S);
   OutStr (S);
   OutCmd (^M);
End;

Procedure OutGreen (I : integer);
Var S : String[3];
Begin
   OutCmd ('G');
   Str (Bytewise(I):3, S);
   OutStr (S);
   OutCmd (^M);
End;

Procedure OutBlue (I : integer);
Var S : String[3];
Begin
   OutCmd ('B');
   Str (Bytewise(I):3, S);
   OutStr (S);
   OutCmd (^M);
End;

(* select values for direct output *)
Procedure SetRed;
Begin
   Write ('Red   value = ');
   Rdlnint (R);
   OutRed (R);
End;

Procedure SetGreen;
Begin
   Write ('Green value = ');
   Rdlnint (G);
   OutGreen (G);
End;

Procedure SetBlue;
Begin
   Write ('Blue  value = ');
   Rdlnint (B);
   OutBlue (B);
End;

Procedure SetColor;
Begin
   Writeln ('Color Combination:');
   Write ('Red   value = ');
   Rdlnint (R);
   Write ('Green value = ');
   Rdlnint (G);
   Write ('Blue  value = ');
   Rdlnint (B);
   OutRed (R);
   OutGreen (G);
   OutBlue (B);
End;

Procedure SetDelay;
Var Time : real;
Begin
   Write ('Delay Time Increment = ');
   (* Rdlnint (DeltaTime); *)
   Rdlnreal (Time);
   DeltaTime := Round (Time * 1000.0);
End;

(* run transition over time *)
Procedure DoTransition;
Var Ri,Gi,Bi : integer;
    Rz,Gz,Bz : integer;
    T, IncrTime : longint;
    Time : real;
Begin
   Writeln ('Transition to Color:');
   Write ('Red   value = ');
   Rdlnint (Rz);
   Write ('Green value = ');
   Rdlnint (Gz);
   Write ('Blue  value = ');
   Rdlnint (Bz);
   Write ('Transition Time = ');
   Rdlnreal (Time);

   Ri := R; Gi := G; Bi := B;
   IncrTime := Round (Time * 1000.0 / DeltaTime);
   For T := 0 to IncrTime Do
       begin
       R := Round (Ri + (Rz - Ri) * T DIV IncrTime);
       G := Round (Gi + (Gz - Gi) * T DIV IncrTime);
       B := Round (Bi + (Bz - Bi) * T DIV IncrTime);
       OutRed (R);
       OutGreen (G);
       OutBlue (B);
       (* Write('.'); *)
       (* Write(R:4, G:4, B:4); *)
       Delay (DeltaTime);
       end;
   Writeln('*');
End;

Procedure Display_Menu;
Begin
   Writeln;
   Writeln ('R : Red value');
   Writeln ('G : Green value');
   Writeln ('B : Blue value');
   Writeln ('C : Color Composite');
   Writeln ('D : Delay Time');
   Writeln ('T : Timed Transition');
   Writeln;
End;

Begin

   Get_Command_Line;
   Parse_Command_Line;
   If CmdParm in [1..4]
      Then Portx := CmdParm
      Else Portx := 2;
   Writeln ('Test for RGB Light Source');
   Writeln ('Serial interface on COM', Portx);
   SetSio (Portx);
   ResetSio;

   OutRed(0);
   OutGreen(0);
   OutBlue(0);

   InitStuff;
   Display_Menu;
   Repeat
      Cmd := ReadKey;
      Cmd := Upcase (Cmd);
      Case Cmd of
      'R' : SetRed;
      'G' : SetGreen;
      'B' : SetBlue;
      'C' : SetColor;
      'D' : SetDelay;
      'T' : DoTransition;
      'H',
      '?' : Display_Menu;
      'Q' : Cmd := QUIT;
      end;
   Until Cmd = QUIT;

End.
