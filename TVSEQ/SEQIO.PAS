(* Sequencer processing *)

Unit SEQIO;

{$I SWITCHES.INC}       (* compiler switches *)

Interface

Uses
   Dos,                 (* for DOS GetTime *)
   TpCrt,               (* TurboPro console extensions *)
   SIO,                 (* Serial IO *)
   TIMEX,               (* ThisTime clock *)
{$IFDEF THINGM_INSTALLED}
   THINGM,              (* ThingM Command IO *)
{$ELSE}
   MCPU,                (* MCPU Command IO *)
{$ENDIF}
   CONIO,               (* console user interface *)
   GLOBAL;              (* Animal Sequencer variables *)

Const
{$IFDEF USE_TURBO_VISION}
   Tracered : boolean = FALSE;  (* no tracer messages *)
{$ELSE}
   Tracered : boolean = TRUE;   (* tracer messages *)
{$ENDIF}

Procedure Do_Frame_Counts;
Procedure Do_Camera;
Procedure Do_Projector;
Procedure Do_Sequencer;

Implementation

{$IFDEF USE_TURBO_VISION}
Uses
   USERIO;              (* refer back to program user interface *)
{$ENDIF}

(* cut-n-pasted from Macintosh Sequencer23.PAS *)

(* Mac Turbo Pascal System support routines: *)

(* Convert integer to string. *)
Function IntToStr (I : integer) : string;
var S : string;
Begin
   Str(I,S);
   IntToStr := S;
End;

(* Draw text string (for Mac graphics console). *)
Procedure DrawStr (S : string);
Begin
   if (Tracered)
      then Write(S);
End;

(* Draw End-of-Line character (for Mac graphics console). *)
Procedure DrawLn;
Begin
   if (Tracered)
      then Writeln;
End;

(* Return Mac mouse button state. *)
Function Button : boolean;
Begin
   Button := MousePressed;
End;

(* Return Mac 1/60-second clock tick. *)
Function TickCount : longint;
Begin
   TickCount := (ThisTime)              (* MS-DOS in 1/100s *)
                * 60 DIV 100;           (* MAC OS in 1/60s *)
End;

(* Return Mac dialog box exit state. *)
Const
   Ok = 1;
   Cancel = 0;
Var
   The_Item : word;

(* Mac Turbo Pascal Sequencer patch routines: *)

(* Wait until current external command is over. *)
Procedure WaitOver;
var status : boolean;
    timeout : integer;
    response : char;
Begin
   timeout := 1000;
   repeat
      InSioSt(status);
      if (status)
         then InSio(response)
         else Delay(1);
      Dec(timeout);
      status := status AND (response = ^M);
   until (status) OR (timeout <= 0) OR (User_Interrupt);
   if (KeyPressed OR MousePressed)
      then if Ask_User('Kill running sequence?')
           then The_Item := Cancel;
End;

(* Approximate camera delay time. *)
Function CAMERA_DELAY_TIME : real;
Begin
   if (Exposure_Time > 1.0)
      then CAMERA_DELAY_TIME := Exposure_Time + 0.50
      else CAMERA_DELAY_TIME := 2 * Exposure_Time + 0.10;
End;

(* Mac Sequencer Windows and Dialogs. *)

(* Create modeless window to input frame counters. *)
Procedure Get_Frame_Counts;
Begin
{$IFDEF USE_TURBO_VISION}
   Init_Status_Display;
{$ENDIF}
End;

(* Update modeless window to display frame counters. *)
Procedure Put_Frame_Counts;
Begin
{$IFDEF USE_TURBO_VISION}
   Update_Status_Display;
{$ELSE}
   if (Tracered)
      then Writeln('Camera = ', Camera_Total, ', Projector = ', Projector_Total);
{$ENDIF}
End;

(* Dispose modeless window for frame counters. *)
Procedure Trash_Frame_Counts;
Begin
{$IFDEF USE_TURBO_VISION}
   Exit_Status_Display;
{$ENDIF}
End;

(* Execute modal dialog window for editing frame counters. *)
Procedure Edit_Frame_Counts;
Begin
   The_Item := Ok;
End;

(* Execute modal dialog for selecting Camera options. *)
Procedure Get_Camera_Options;
Begin
   The_Item := Ok;
End;

(* Execute modal dialog for selecting Projector options. *)
Procedure Get_Projector_Options;
Begin
   The_Item := Ok;
End;

(* Execute modal dialog for selecting Sequencer options. *)
Procedure Get_Sequencer_Options;
Begin
   The_Item := Ok;
End;

(* cut-n-pasted from Macintosh Sequencer23.PAS *)

(***** Sequencer routines *****)

(* Edit run-time frame counters. *)

Procedure Do_Frame_Counts;

Begin
{$IFDEF THINGM_INSTALLED}
   THINGM_Camera;
   THINGM_Counter(Camera_Total);
   THINGM_Projector;
   THINGM_Counter(Projector_Total);
{$ELSE}
   DrawStr ('Edit Frame Counters...');
   Edit_Frame_Counts;
   If The_Item = Ok
      Then begin
           GetCount_Hardware (AA[CX].M);
           GetCount_Hardware (AA[PX].M);
           end;
{$ENDIF}
End;

(* Run camera motor. *)
(* 1 camera frame = 400 half steps per revolution. *)

Procedure Pre_Run_Camera (F : Integer);

Begin
{$IFDEF THINGM_INSTALLED}
   THINGM_Camera;
   THINGM_FrameCount(F);
   WaitOver; (* for ThingM OK *)
{$ELSE}
   With AA [CX] Do
        begin
        M.StepCnt := F * K.Kscale;
        PrepM (M);
        WaitOver;
        end;
{$ENDIF}
End;

Procedure Run_Camera (F : Integer);

Begin
{$IFDEF THINGM_INSTALLED}
   THINGM_Camera;
   THINGM_Run;
   WaitOver; (* for ThingM OK *)
{$ELSE}
   With AA [CX] Do
        RunM  (M);
{$ENDIF}
End;

(* Run projector motor. *)
(* 1 projector frame = 200 full steps per revolution. *)

Procedure Pre_Run_Projector (F : Integer);

Begin
{$IFDEF THINGM_INSTALLED}
   THINGM_Projector;
   THINGM_FrameCount(F);
   WaitOver; (* for ThingM OK *)
{$ELSE}
   With AA [PX] Do
        begin
        M.StepCnt := F * K.Kscale;
        PrepM (M);
        WaitOver;
        end;
{$ENDIF}
End;

Procedure Run_Projector (F : Integer);

Begin
{$IFDEF THINGM_INSTALLED}
   THINGM_Projector;
   THINGM_Run;
   WaitOver; (* for ThingM OK *)
{$ELSE}
   With AA [PX] Do
        RunM  (M);
{$ENDIF}
End;

(* Run camera only *)

Procedure Do_Camera;

Var C : Integer;
    Single : Integer;
    Ticker : LongInt;

Begin

   DrawStr ('Camera Overide Frame Count = ');
   Get_Camera_Options;
   DrawStr (IntToStr (Frame_Count));
   DrawStr ('...');
   Drawln;

   If (The_Item = Ok)
      Then begin
      Get_Frame_Counts;
      If Frame_Count = 0
         Then Single := 0
         Else Single := Frame_Count DIV Abs (Frame_Count);
      Pre_Run_Camera (Frame_Count);
      Run_Camera (Frame_Count);
      Ticker := TickCount;
      For C := 1 to Abs (Frame_Count) do
          begin
          Camera_Total := Camera_Total + Single;
          Put_Frame_Counts;
          Repeat
          Until TickCount >= Ticker + C *
                Round (60.0 * CAMERA_DELAY_TIME);
          WaitOver; (* ThingM continuous run *)
          if (The_Item = Cancel)
             then break;
          end;
      WaitOver; (* MCPU or ThingM OK prompt *)
      Trash_Frame_Counts;
      end;
End;

(* Run projector overide. *)

Procedure Do_Projector;

Var P : Integer;
    Single : Integer;

Begin

   DrawStr ('Projector Overide Frame Count = ');
   Get_Projector_Options;
   DrawStr (IntToStr (Frame_Count));
   DrawStr ('...');
   Drawln;

   If (The_Item = Ok)
      Then begin
      Get_Frame_Counts;
      If Frame_Count = 0
         Then Single := 0
         Else Single := Frame_Count DIV Abs (Frame_Count);
      Pre_Run_Projector (Single);
      For P := 1 to Abs (Frame_Count) do
          begin
          If KeyPressed Or Button
             Then Put_Frame_Counts;
          If Not (The_Item = Cancel)
             Then begin
             Run_Projector (Single);
             Projector_Total := Projector_Total + Single;
             Put_Frame_Counts;
             WaitOver;
             {$IFDEF MCPU_INSTALLED}
             HomeM (AA[PX].M);      (* locate home switch *)
             {$ENDIF}
             WaitOver; (* ThingM OK prompt *)
             if (The_Item = Cancel)
                then break;
             end;
          end;
      Trash_Frame_Counts;
      end;
End;

(* Run sequencer operation. *)

Procedure Do_Sequencer;

Var F : Integer;
    P : Integer;
    PSingle : Integer;
    C : Integer;
    CSingle : Integer;
    Ticker : LongInt;

Begin

   DrawStr ('Sequencer Frame Count = ');
   Get_Sequencer_Options;
   DrawStr (IntToStr (Frame_Count));
   DrawStr ('...');
   Drawln;

   If The_Item = Ok Then begin

   Case Sequencer of

   Alternate : begin

      Get_Frame_Counts;
      If Camera_Cycle = 0
         Then CSingle := 0
         Else CSingle := Camera_Cycle DIV Abs (Camera_Cycle);
      If Projector_Cycle = 0
         Then PSingle := 0
         Else PSingle := Projector_Cycle DIV Abs (Projector_Cycle);
      Pre_Run_Camera (Camera_Cycle);
      Pre_Run_Projector (PSingle);
      For F := 1 to Abs (Frame_Count) do
          begin
          If KeyPressed Or Button
             Then Put_Frame_Counts;
          If Not (The_Item = Cancel)
             Then begin
             Run_Camera (Camera_Cycle);
             Ticker := TickCount;
             For C := 1 to Abs (Camera_Cycle) Do
                 begin
                 Camera_Total := Camera_Total + CSingle;
                 Put_Frame_Counts;
                 Repeat
                 Until TickCount >= Ticker + C *
                   Round (60.0 * CAMERA_DELAY_TIME);
                 WaitOver; (* ThingM *)
                 end;
             WaitOver; (* MCPU or ThingM OK *)
             if (The_Item = Cancel)
                then break;

             For P := 1 to Abs (Projector_Cycle) do
                 begin
                 Run_Projector (PSingle);
                 Projector_Total := Projector_Total + PSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 {$IFDEF MCPU_INSTALLED}
                 HomeM (AA[PX].M);      (* locate home switch *)
                 {$ENDIF}
                 WaitOver; (* ThingM OK *)
                 if (The_Item = Cancel)
                    then break;
                 end;
             end;
          end;
      Trash_Frame_Counts;
      end;      (* Alternate Sequencer *)

   StepCamera : begin

      Get_Frame_Counts;
      If Camera_Cycle = 0
         Then CSingle := 0
         Else CSingle := Camera_Cycle DIV Abs (Camera_Cycle);
      Pre_Run_Camera (CSingle);
      If Projector_Cycle = 0
         Then PSingle := 0
         Else PSingle := Projector_Cycle DIV Abs (Projector_Cycle);
      Pre_Run_Projector (PSingle);
      For F := 1 to Abs (Frame_Count) do
          begin
          If KeyPressed Or Button
             Then Put_Frame_Counts;
          If Not (The_Item = Cancel)
             Then begin
             For P := 1 to Abs (Projector_Cycle) do
                 begin
                 Run_Camera (CSingle);
                 WaitOver;
                 Camera_Total := Camera_Total + CSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 Run_Projector (PSingle);
                 WaitOver;
                 Projector_Total := Projector_Total + PSingle;
                 Put_Frame_Counts;
                 {$IFDEF MCPU_INSTALLED}
                 HomeM (AA[PX].M);      (* locate home switch *)
                 {$ENDIF}
                 WaitOver;
                 if (The_Item = Cancel)
                    then break;
                 end;
             For C := 1 to Abs (Camera_Cycle - 1) do
                 begin
                 Run_Camera (CSingle);
                 WaitOver;
                 Camera_Total := Camera_Total + CSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 if (The_Item = Cancel)
                    then break;
                 end;
             end;
          end;
      Trash_Frame_Counts;
      end;      (* StepCamera Sequencer *)

   SkipProjector : begin

      Get_Frame_Counts;
      If Camera_Cycle = 0
         Then CSingle := 0
         Else CSingle := Camera_Cycle DIV Abs (Camera_Cycle);
      Pre_Run_Camera (CSingle);
      If Projector_Cycle = 0
         Then PSingle := 0
         Else PSingle := Projector_Cycle DIV Abs (Projector_Cycle);
      Pre_Run_Projector (PSingle);
      For F := 1 to Abs (Frame_Count) do
          begin
          If KeyPressed Or Button
             Then Put_Frame_Counts;
          If Not (The_Item = Cancel)
             Then begin
             For C := 1 to Abs (Camera_Cycle) do
                 begin
                 Run_Camera (CSingle);
                 WaitOver;
                 Camera_Total := Camera_Total + CSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 Run_Projector (PSingle);
                 WaitOver;
                 Projector_Total := Projector_Total + PSingle;
                 Put_Frame_Counts;
                 {$IFDEF MCPU_INSTALLED}
                 HomeM (AA[PX].M);      (* locate home switch *)
                 {$ENDIF}
                 WaitOver;
                 if (The_Item = Cancel)
                    then break;
                 end;
             For P := 1 to Abs (Projector_Cycle - 1) do
                 begin
                 Run_Projector (PSingle);
                 WaitOver;
                 Projector_Total := Projector_Total + PSingle;
                 Put_Frame_Counts;
                 {$IFDEF MCPU_INSTALLED}
                 HomeM (AA[PX].M);      (* locate home switch *)
                 {$ENDIF}
                 WaitOver;
                 if (The_Item = Cancel)
                    then break;
                 end;
             end;
          end;
      Trash_Frame_Counts;
      end;      (* SkipProjector Sequencer *)

   end;         (* case Sequencer *)
   end;         (* if Sequencer at all *)
End;

(* Initialization *)

Begin

End.


