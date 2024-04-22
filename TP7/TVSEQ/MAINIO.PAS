
(* Main Processing *)

Unit MAINIO;

Interface

{$I SWITCHES.INC}       (* compiler switches *)

Uses
     SIO,               (* serial interface *)
     MCPU,              (* MCPU commands *)
     GLOBAL;            (* Animal Global declarations *)

Var
    Quitting_Time : boolean;

    Plot_Edited : boolean;
    Plot_Saved : boolean;

    Default_Plot : string;
    Default_Mapping : string;
    Default_Units : string;
    Default_Speeds : string;
    Default_Alignment : string;
    Default_Triggers : string;

    XYno : integer;

Procedure Signon;

Procedure Init_Animal;

Procedure Exit_Animal;

Procedure New_Plot;

Procedure Load_Plot_File;

Procedure Save_Plot_File;

Procedure Edit_Plot;

Procedure Run_Plot;

Procedure Overide;

Procedure Query_Save_File;

Procedure Quitting_Time_Query;

(************)

Implementation

(* private use for interaction back with user interface routines: *)
Uses
     TpCrt,             (* Turbo Pro console *)
     CONIO,             (* console user interface *)
     USERIO;            (* program user interface *)

(* Animal initialization stuff. *)

Procedure Init_Animal_Stuff;

Begin

   Quitting_Time := FALSE;

   Plot_Edited := FALSE;
   Plot_Saved := FALSE;

   Default_Plot := 'ANIMAL.KEY';
   Default_Mapping := 'ANIMAL.MAP';
   Default_Units := 'ANIMAL.UNT';
   Default_Speeds := 'ANIMAL.SPD';
   Default_Alignment := 'ANIMAL.ALN';
   Default_Triggers := 'ANIMAL.TRG';

   XYno := 1;

End;

(*************************************)

(* Animal program internal linkages. *)

Var McpuPort : integer;                 (* MCPU serial port # *)

(* Animal program signon. *)

Procedure Signon;

   var CmdParm, E : integer;

Begin

   (* 1st command line parameter selects MCPU serial port *)
   If (ParamCount >= 1)
      Then Val (ParamStr(1), CmdParm, E)
      Else CmdParm := -1;
   If CmdParm in [1..4]
      Then McpuPort := CmdParm          (* command line COM port ? *)
      Else McpuPort := MCPU_PortX;      (* default COM port *)
   MCPU_PortX := McpuPort;              (* re-set internal MCPU var *)

   Writeln ('Animal Professional / Animation Motion Control');
   Writeln ('Copyright 1992 Dave Milici / Penguin Associates');
   Writeln;
{$IFDEF REALTIME_MOTION}
   Writeln ('Installation for Pacific / Korty / Penguin');
   Writeln ('Compumotor MCPU for COM', McpuPort);
{$ELSE}
{$IFDEF RGB_CONTROL}
   Writeln ('Installation for Robomaster Industries');
   Writeln ('STD bus MCPU for COM', McpuPort);
{$ELSE}
   Writeln ('Installation for Guerrilla Opticals');
   Writeln ('ThingM MCPU for COM', McpuPort);
{$ENDIF}
{$ENDIF}
   Writeln;

End;

(* Initialize Animal software variables and MCPU hardware communications. *)

Procedure Init_Animal;

Begin

   SetSio (McpuPort);                   (* select MCPU serial COM port *)
   ResetSio;                            (* init serial port *)

   Init_Animal_Stuff;                   (* init general Animal axis data *)

End;

Procedure Exit_Animal;

Begin
End;

(* Start new plot from scratch. *)

Procedure New_Plot;

Begin
   Query_Save_File;
End;

(* Load plot from disk file into memory. *)

Procedure Load_Plot;
Begin
End;

Procedure Load_Plot_File;
Begin
   Query_Save_File;
End;

(* Save plot from memory onto disk file. *)

Procedure Save_Plot;
Begin
End;

Procedure Save_Plot_File;
Begin
End;

(* Edit the screen time of the output motion sequence. *)

Procedure Edit_Plot;

Begin
End;

(* Run the output motion sequence. *)

Procedure Run_Plot;

Begin
End;

Procedure Overide;

Begin
End;

(* Check if plot should be saved to disk. *)

Procedure Query_Save_File;

Var Answer : integer;
Begin

   If Plot_Edited And (Not Plot_Saved)
      Then begin
      Answer := Ask_User3('Save Current Plot?');
      If (Answer = 1)
         Then begin
         Save_File_Dialog;
         Plot_Edited := False;
         Plot_Saved  := True;
         end
      Else If (Answer = 0)
         Then Plot_Edited := False;
      end;
End;

(* Check if user really wants to quit program. *)

Procedure Quitting_Time_Query;

Var Answer : boolean;
Begin

   Answer := Ask_User('Quitting Time...for sure?');
   Quitting_Time := (Answer = TRUE);

   If Quitting_time
      Then Query_Save_File;

End;

(* Initialization *)

Begin

End.
