
(* User Interface Auxiliary routines for USERMAIN support. *)

Unit USERAUX;

{$I SWITCHES.INC}          (* compiler switches *)

Interface

Uses
     TpCrt,                (* TurboPro console extensions *)
     TpString,             (* TurboPro string extensions *)
     KEYBD,                (* Keyboard input filters *)
     GLOBAL ,              (* Animal Global declarations *)
     GLOBAL2,              (* TV Animal Point-Plotter *)
     MCPU ,                (* MCPU Communications *)
     MCPUIO,               (* MCPU Features *)
     FILEIO,               (* File IO *)
     MAINIO,               (* Main processing *)

{$IFDEF SPECIAL_FEATURE}
     TERMIO,               (* General Terminal Interface *)
     RGBIO,                (* RGB Light Source Interface *)
     RGBMAIN,              (* RGB Light Source main processing *)
{$ENDIF}

     Dos,                  (* MS-DOS function calls *)
     Graph,                (* Turbo Pascal BGI Library *)

     Objects,              (* Turbo Vision Object Library *)
     Drivers,              (* TV interface drivers *)
     Views,                (* TV view screens *)
     Dialogs,              (* TV dialog boxes *)
     App,                  (* TV application framework *)
     MsgBox;               (* TV message boxes *)

Const Xres = 78;                                (* X axis resolution *)
      Yres = 19;                                (* Y axis resolution *)

Type  XYscreen = Array [0..Yres] of String [Xres];  (* XY screen buffer *)

Procedure Save_File_Dialog;

Procedure Load_File_Dialog;

Procedure Query_File_Extension (Var The_File_Name : String; Extension : String);

Function  Query_File_Exists (Var The_File_Name : String) : Boolean;

Procedure Get_External_Status (Var Status : Boolean);

Procedure Get_External_Input;

Function  Handle_Control_Break : boolean;

Procedure Update_Idle;

Procedure Emergency_Overide;

Procedure Emergency_Terminal;

Procedure Query_Emergency_Kill;

Procedure Query_Emergency_Reset;

Procedure Query_Emergency_Overide;

Procedure Query_Emergency_Terminal;

Procedure CheapStatus (S : String);

Procedure CheapStatusClear;

Procedure Display_Point_Line (L : Integer; Var S : String);

Procedure Extract_Points (Var S : String; P : Integer);

Procedure Buffer_Graphics_Plot (Index : Integer; Var XYbuf : XYscreen);

Procedure Graph_Point_Line (Var XYbuf : XYscreen; L : Integer; Var S : String);

(******************************)

Implementation

Uses CRT,                  (* default cursor routines *)
     USERIO,               (* private access to user IO *)
     USERWRAP;             (* private access to AniApp object wrappers *)

(* Update app clock. *)
Procedure Update_Idle;
Begin
   USERWRAP.Idle;
End;

(* Dialog shell for Saving File. *)
Procedure Save_File_Dialog;

Begin
  USERWRAP.Save_File_Dialog;
End;

(* File-Open dialog shell. *)
Procedure Load_File_Dialog;
Begin
  USERWRAP.Load_File_Dialog;
End;

(* Scan file name for extension, and append if missing. *)
Procedure Query_File_Extension (Var The_File_Name : String; Extension : String);
Var C : Integer;
    Extn_Ok : Boolean;
Begin
   Extn_Ok := False;
   For C := 1 to Length (The_File_Name) Do
       If The_File_Name [C] = '.'
          Then Extn_Ok := True;
   If Not Extn_Ok
      Then The_File_Name := The_File_Name + '.' + Extension;
End;

(* Search for file if it already exists. *)
Function Query_File_Exists (Var The_File_Name : String) : Boolean;
Var F : File;
    File_Exists : Boolean;
Begin
   Assign (F, The_File_Name);
   {$I-}
   Reset (F);
   {$I+}
   File_Exists := (IoResult = 0);
   If File_Exists
      Then Close (F);
   Query_File_Exists := File_Exists;
End;

(*****)

(* External Trigger Input routines. *)
Procedure Get_External_Status (Var Status : Boolean);
Begin
   Get_Trigger (Status);
End;

Procedure Get_External_Input;
Const Sample_Time = 50;
Var Trigger_Status : Boolean;
Begin

   Write (^G);
   Repeat
      Delay (Sample_Time);
      Get_Trigger (Trigger_Status);
   Until (Not Trigger_Status) Or KeyPressed Or MousePressed;

End;

(* Special Control-Break handler. *)
Function Handle_Control_Break : boolean;
var A : word;
Begin
   if Ask_User('CONTROL-BREAK key detected' + ^M + ^M + 'Reset Motion Controller?')
      then Emergency_Reset;
   Handle_Control_Break := TRUE;
End;

(*****)

(* {$I USEROVER.INC}       (* user IO overide routines *)

(* Emergency MCPU Overide screen. (Suspends TV desktop display.) *)
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

(* Emergency SIO Terminal screen. (Suspends TV desktop display.) *)
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

(*****)

(* Query user for Emergency actions. *)
Procedure Query_Emergency_Kill;
Begin
   if (Ask_User('Emergency Kill all Motors?'))
      then Emergency_Kill;
End;

Procedure Query_Emergency_Reset;
Begin
   if (Ask_User('Emergency Reset Motion Controllers?'))
      then Emergency_Reset;
End;

Procedure Query_Emergency_Overide;
Begin
   if (Ask_User('Emergency MCPU Overide?'))
      then Emergency_Overide;
End;

Procedure Query_Emergency_Terminal;
Begin
   if (Ask_User('Emergency Terminal Interface?'))
      then Emergency_Terminal;
End;

(* TV-style Display routines. *)

(* Display a single line string over the TV Status Line. *)
Procedure CheapStatus (S : String);
Begin
   If Length (S) > 50
      Then S[0] := Chr (50);
   GotoXYabs (30, 25);
   Write (S);
End;

(* Clear the single line string over the TV Status Line. *)
Procedure CheapStatusClear;
Begin
   GotoXYabs (30, 25);
   ClrEol;
End;

(*****)

(* {$I USERGRBF.INC}       (* graphics display routines *)

(* Data display routines prepared for Turbo Vision screen strings. *)

(* Display individual line of axis plot points. *)

Procedure Display_Point_Line (L : Integer; Var S : String);
Var I : Integer;
    SX : String;
Begin
    Str (L:4, SX);
    S := SX;
    For I := 1 to Max_Axes Do
        With AA [I] Do
             If Spec
                Then begin
                Str ((Get_Pt (I, L)):10:K.dp, SX);
                S := S + SX;
                end;
end;

(* Extract individual axis point values from data string. *)

Procedure Extract_Points (Var S : String; P : Integer);
var
   C, D : Integer;
   X : String;
   Verror : Integer;

procedure Scan_For_Blanks;
Begin
   While S [C] = ' ' Do
      C := Succ (C);
End;

procedure Scan_For_Numbers;
Begin
   D := 1;
   While (C <= Length (S))
   And (S [C] <> ' ') Do
       begin
       X [D] := S [C];
       C := Succ (C);
       D := Succ (D);
       end;
   X [0] := Chr (Pred (D));
End;

Begin
   C := 1;
   Scan_For_Blanks;
   Scan_For_Numbers;
   For I := 1 to Max_Axes Do
       With AA [I] Do
       If Spec
          Then If I In [1..Min_Axes]
               Then begin
               Scan_For_Blanks;
               Scan_For_Numbers;
               Val (X, Key [P], Verror);
               end;
End;

(* Graphics routines prepared for Turbo Vision screen strings. *)

(* Prepare integer graphics coordinates from real-number plot. *)
(* Buffer XY graphics plot in screen-compatible text-string buffer. *)

Procedure Buffer_Graphics_Plot (Index : Integer; Var XYbuf : XYscreen);

Var  Xmin, Xmax, Xscale : Real;                 (* Integer : Real scale *)
     Ymin, Ymax, Yscale : Real;
     XYmap : Array [1..Xres] of Integer;        (* XY integer coordinates *)
     XYkey : Array [1..Xres] of Integer;

Var  X : Integer;
     Y : Integer;

(* Scale the real-number plot to fit into integer XY coordinates. *)

Var P : Integer;
    Pt : Real;
    K : Integer;

Begin

    Xmin := (* 1; *) 0;
    Xmax := XYno;
    Ymin := 0.0;
    Ymax := 0.0;
    For P := 1 to XYno Do
        begin
        Pt := Get_Pt (Index, P);
        If Pt > Ymax
           Then Ymax := Pt
        Else If Pt < Ymin
           Then Ymin := Pt;
        end;
    Xscale := Xres / (Xmax - Xmin);
    If Ymax <> Ymin
       Then Yscale := Yres / (Ymax - Ymin)
    Else If Ymax <> 0.0
       Then Yscale := Yres / Ymax
       Else Yscale := 0.0;

(* Map the XY real-number coordinates into XY integer-number coordinates. *)
(* Map key-frame points onto same XY scale. *)

   For X := 1 to Xres Do
       XYmap [X] := -1;

   For P := 1 to XYno Do
       begin
       X := Round (P * Xscale);
       Y := Yres - Round (+1.0 * (Get_Pt (Index, P) - Ymin) * Yscale);
       If X in [1..Xres]
          Then XYmap [X] := Y;
       end;

   For X := 1 to Xres Do
       XYkey [X] := -1;

   If KeyNo > 0
       Then For K := 1 to KeyNo Do
       begin
       If K = 1
          Then X := 1
          Else X := Round (Time_Key [K] / Screen_Time * Xres);
       Y := Yres - Round (+1.0 * (AA [Index].Key [K] - Ymin) * Yscale);
       If X in [1..Xres]
          Then XYkey [X] := Y;
       end;

(* Buffer the XY integer coordinates as text characters on screen. *)
(* Complete text strings are buffered for each horizontal line. *)
(* Transfer key-frame point characters into same screen buffer. *)

   For Y := 0 to Yres Do
       begin
       XYbuf [Y][0] := Chr (Xres);
       For X := 1 to Xres Do
           XYbuf [Y][X] := ' ';
       end;

   For X := 1 to Xres Do
       begin
       Y := XYmap [X];
       If Y in [0..Yres]
          Then XYbuf [Y][X] := '�';
       end;

   For X := 1 to Xres Do
       begin
       Y := XYkey [X];
       If Y in [0..Yres]
          Then XYbuf [Y][X] := '*';     (* {$R+} error *)
       end;
End;

(* Provide a single horizontal line of the graph display buffer. *)

Procedure Graph_Point_Line (Var XYbuf : XYscreen; L : Integer; Var S : String);

Begin

   If L in [0..Yres]
      Then S := XYbuf [L]
      Else S := '';
End;

(*****)

End.
