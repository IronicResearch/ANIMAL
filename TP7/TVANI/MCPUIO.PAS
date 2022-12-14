
(* Motion Control Interface *)

Unit MCPUIO;

Interface

{$I MCPU.INC}           (* MCPU switches *)

{$I SWITCHES.INC}       (* compiler switches *)

Uses
     TpCrt,                (* TurboPro console extensions *)
     TpString,             (* TurboPro string extensions *)
     KEYBD,                (* Keyboard input filters *)
     GLOBAL,               (* Animal Global declarations *)
     GLOBAL2,
{$IFDEF RGB_CONTROL}
     RGBIO,                (* RGB Light Source IO *)
     RGBMAIN,              (* RGB Light Source processing *)
{$ENDIF}
     TIMEX,                (* time clock *)
     TRIGIO,               (* Trigger Outputs *)
     MCPU;                 (* MCPU Communications *)

PROCEDURE CONVERT (VAR X : REAL; VAR K : REAL; VAR Y : REAL);

PROCEDURE RECONVERT (VAR X : REAL; VAR K : REAL; VAR Y : REAL);

PROCEDURE CONVERT_ALL;

PROCEDURE RECONVERT_ALL;

PROCEDURE GETALL;

PROCEDURE RUNALL;

Procedure Get_Axis_Updates;

Procedure Local_WaitOver;

{Procedure Get_Trigger (Var Status : Boolean);}

Procedure Init_PC23;

Procedure Enable_Joystick;

Procedure Disable_Joystick;

Procedure Enable_Zoom_Lens;

Procedure Overide_Zoom_Lens;

Procedure Disable_Zoom_Lens;

Procedure Align_Plot (P : Integer);

Procedure Pre_Run_Plot;

Procedure Real_Time_Plot;

Procedure Run_Stop_Motion;

Procedure Init_Speeds;

Procedure Fast_Speeds;

{$IFDEF GOMOTION_CONTROL}
Procedure Align_Point (P : Integer);
{$ENDIF}

Procedure Run_Go_Motion;

Procedure Run_Alignment;

Procedure Zero_Alignment;

Procedure Emergency_Kill;

Procedure Emergency_Reset;

Procedure MCPU_Overide;

Procedure MCPU_Error_Stats;

(************)

Implementation

Uses Crt,                  (* Turbo Pascal default console -- used by TV *)
     Objects,              (* Turbo Vision Object Library *)
     Views,
     Dialogs,
     App,
     MsgBox,
     USERIO;               (* refer back to user interface *)

(* Animal Motion Control routines. *)

(* CONVERT converts user defined units into steps. *)
PROCEDURE CONVERT (VAR X : REAL; VAR K : REAL; VAR Y : REAL);
BEGIN
   Y := X / K;
END;

(* RECONVERT reconverts steps into user-defined units. *)
PROCEDURE RECONVERT (VAR X : REAL; VAR K : REAL; VAR Y : REAL);
BEGIN
   Y := K * X;
END;

(* CONVERT ALL converts all axes from user units to steps for output. *)
PROCEDURE CONVERT_ALL;
BEGIN
   FOR I := 1 TO Min_Axes DO
       WITH AA [I] DO
            IF SPEC
               THEN CONVERT (K.CUR_POSN, K.KSCALE, M.STEPCNT);
END;

(* RECOVERT ALL reconverts all axes from steps to user units for input. *)
PROCEDURE RECONVERT_ALL;
BEGIN
   FOR I := 1 TO Min_Axes DO
       WITH AA [I] DO
            IF SPEC
               THEN RECONVERT (M.COUNT, K.KSCALE, K.CUR_POSN);
END;

(* Get updated positions from MCPU axes. *)
Procedure Get_Axis_Updates;
Begin
   GetAll;
   Reconvert_All;
End;

(* Emergency Kill command to all motors. *)
Procedure Emergency_Kill;
Begin
   KillM_All;
End;

(* Emergency Reset command to motion control system. *)
Procedure Emergency_Reset;
Begin
   ResetSio;            (* includes hardware reset of PC23 *)
   Reset_Mcpu;          (* includes software reset of 2100 *)
   ReSync_Mcpu;         (* re-enables serial communication *)
End;

(* Transfer max speeds for all axes. *)
Procedure Fast_Speeds;
Begin
    Init_All_Motor;
End;

(* Init speeds for all axes. *)
Procedure Init_Speeds;
Begin
    InitM_All;
End;

{$IFDEF REALTIME_MOTION}
{$I MCPUCTR.EXT}        (* motion control with contour support *)
Procedure Local_WaitOver_Delay;
    Begin End;
{$ELSE}
 {$IFDEF MCPU_STDBUS}
{$I MCPUSTD.EXT}        (* STD bus MCPU *)
 {$ELSE}
{$I MCPUOLD.EXT}        (* stop-motion only for old Compumotor *)
 {$ENDIF}
{$ENDIF}

{$IFDEF GOMOTION_CONTROL}
{$I MCPUGOMO.EXT}        (* go-motion control support *)
{$ELSE}
Procedure Run_Go_Motion;
    Begin
    Run_Stop_Motion;
    End;
{$ENDIF}

(* MCPU Overide from console *)
{$I OVERIDE.EXT}        (* MCPU overide commands *)

(* Zero alignment adjustment *)
Procedure Zero_Alignment;
Begin
   For I := 1 to Max_Axes Do
       With AA[I] Do
            If Spec AND H.Spec
               Then begin
                    GetCount (M);
                    If H.Align = FWD
                       Then H.Count := H.Count + M.Count
                       Else H.Count := H.Count - M.Count;
                    ZeroM (M);
                    end;
End;

(* Display MCPU error statistics. *)
Procedure MCPU_Error_Stats;
Begin
   Writeln;
   Writeln('SIO Timeout Errors = ', SIO_Timeouts);
   Writeln('PIO Timeout Errors = ', PIO_Timeouts);
   Writeln('COM Timeout Errors = ', COM_Timeouts);
   Writeln;
End;

(* Initialization *)

Begin

End.
