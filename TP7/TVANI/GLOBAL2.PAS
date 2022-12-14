
(* Global declarations. *)

Unit GLOBAL2;

Interface

{$I SWITCHES.INC}                           (* compiler switches *)

Uses GLOBAL;

(* Animal Motion Control definitions. *)

(* Minimal Motion Control program for Compumotor PC23 and Joystick. *)

Const PIOD = $0300;                    (* PC23 Data reg *)
      PIOC = $0301;                    (* PC23 Control reg *)
      PIOS = $0301;                    (* PC23 Status reg *)

Const LPT1 = $03BC;                    (* IBM parallel ports *)
      LPT2 = $0378;
      LPT3 = $0278;

Const COM1 = $03F8;                    (* COM1: base address *)
      COM2 = $02F8;                    (* COM2: base address *)
      COM3 = $03E8;		       (* COM3: base address *)
      COM4 = $02E8;		       (* COM4: base address *)

{$IFDEF VIDEO_INSTALLED}
Const Frame_Rate : Real = 30.0;        (* 30 frames / second *)
{$ELSE}
Const Frame_Rate : Real = 24.0;        (* 24 frames / second *)
{$ENDIF}

Var   Frame_Count : Integer;           (* frame counter *)
      Preset_Count : Integer;          (* preset total count *)
      Screen_Time : Real;              (* screen time duration *)

      XYno : Integer;                  (* motion sequence plot total *)
      StartPt : Integer;               (* motion sequence start point *)
      EndPt : Integer;                 (* motion sequence end point *)

      KeyNo : Integer;                 (* number of key frame points *)
      StartKeyPt : Integer;            (* start key frame point *)
      EndKeyPt : Integer;              (* end key frame point *)

      Taper_In : Real;                 (* global user tapers *)
      Taper_Out : Real;

      Zoom_Overide : Boolean;          (* overide for zoom joystick *)

      Plot_Edited : Boolean;           (* has the plot been edited? *)
      Plot_Saved  : Boolean;           (* has the plot been saved? *)
      Plot_Ended : Boolean;            (* at plot's end ? *)

      Default_Plot : String;           (* default plot file name *)
      Default_Text : String;           (* default text file name *)
      Default_Mapping : String;        (* default axis map file name *)
      Default_Units : String;          (* default user units file name *)
      Default_Speeds : String;         (* default motor speed file name *)
      Default_Alignment : String;      (* default alignment file name *)
      Default_Triggers : String;       (* default trigger file name *)

      Displayed : Boolean;             (* display lines for debug *)

      Time_Key : Point_Table;          (* time base for key frames *)
      Time_Base : Real_Array;          (* time base for interpolations *)

      Pre_Roll : Real;                 (* pre-roll time delay *)
      Pre_Rolled : Boolean;            (* pre-roll active ? *)

      Frozen_Fresh : Boolean;          (* freeze frames within plot ? *)

      Really_Graphics : Boolean;       (* high-resolution graphics ? *)
      Delta_Graphics : Boolean;        (* increments on display ? *)

      Stop_Motion : Boolean;           (* stop motion sequence ? *)
      Go_Motion : Boolean;             (* go motion streaking ? *)
      Single_Framed : Boolean;         (* single frame at a time ? *)
      Reverse_Runned : Boolean;        (* reverse running ? *)

      Exposure_Time : Real;            (* exposure time for Go Motion *)
      Streaked_Exposures : Boolean;    (* exposure times = streak times ? *)
      Streaked_Increments : Boolean;   (* streak sizes = increment sizes ? *)

      KeyFrames_Saved : Boolean;       (* key frames saved ? *)
      Tapers_Saved : Boolean;          (* tapers saved ? *)
      Points_Saved : Boolean;          (* all points saved ? *)

      Graphics_Loaded : Boolean;       (* graphics driver file loaded ? *)

Implementation

Begin

{$IFDEF VIDEO_INSTALLED}
      Frame_Rate := 30.0;               (* 30 frames / second *)
{$ELSE}
      Frame_Rate := 24.0;               (* 24 frames / second *)
{$ENDIF}


End.
