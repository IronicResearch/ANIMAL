(* Animal Sequencer Global variables *)

Unit GLOBAL;

Interface

(* cut-n-pasted from Macintosh Sequencer23.PAS *)

(* Sequencer stuff *)
  
Const   CamId = 1031;       (* Camera dialog resource ID *)
        PrjId = 1032;       (* Projector dialog *)
        SeqId = 1033;       (* Sequencer dialog *)
        FrmId = 1034;       (* Frame Count dialog *)
        
        InitId = 1041;      (* Init dialog res ID *)
        RunId  = 1042;      (* Run dialog *)
        KillId = 1043;      (* Kill dialog *)
        StatId = 1044;      (* Status dialog *)
        PosnId = 1045;      (* Position dialog *)
        MoveId = 1046;      (* Move dialog *)
        GotoId = 1047;      (* Goto dialog *)
        JogId  = 1048;      (* Jog dialog *)
        LimId  = 1049;      (* Limit switch dialog *)
        ZeroId = 1140;      (* Zero position dialog *)        
        
        AmapId = 1051;      (* Axis Map dialog *)
        UnitId = 1052;      (* User Units dialog *)
        MspdId = 1053;      (* Motor Speeds dialog *)
        
Const   FWD = True;         (* forward motor direction *)
        REV = False;        (* reverse motor direction *)
        
        Min_Axes = 2;       (* min number of axes *)
        Max_Axes = 8;       (* max number of axes *)

Type    Sequencer_Mode = (None, Alternate, StepCamera, SkipProjector);

        Motor_Table = Record
            MotorNo : Integer;              (* motor number *)
            StepCnt : Real;                 (* step count *)
            Dir     : Boolean;              (* step direction *)
            AccelSt : Boolean;              (* acceleration status *)
            Speed   : Integer;              (* constant speed *)
            LowSpd  : Integer;              (* low speed *)
            HighSpd : Integer;              (* high speed *)
            RampCnt : Integer;              (* ramp count *)
            RampK   : Integer;              (* ramp constant *)
            Stat    : Char;                 (* axis status *)
            Count   : Real;                 (* axis position *)
            Error   : Boolean;              (* error status *)
            end;
            
        Map_Table = Record
            ID      : String [2];           (* axis ID tag *)
            No      : Integer;              (* motor number *)
            Name    : String;               (* axis name label *)
            end;

        Conversion_Table = Record
            Kscale  : Real;                 (* scale factor *)
            DP      : Integer;              (* decimal places *)
            Units   : String;               (* user units label *)
            Cur_Step: Real;                 (* current step count *)
            Cur_Posn: Real;                 (* current step position *)
            end;
            
        Run_Profile = Record
            AccelSt     : Boolean;          (* acceleration status *)
            Max_Speed   : Real;             (* max constant speed *)
            Min_LowSpd  : Real;             (* min low speed *)
            Max_HighSpd : Real;             (* max high speed *)
            Max_RampCnt : Real;             (* max ramp count *)
            end;
            
        Axis_Table = Record
            Spec    : Boolean;              (* specified ? *)
            A       : Map_Table;            (* axis map *)
            M       : Motor_Table;          (* MCPU motor stuff *)
            K       : Conversion_Table;     (* user units stuff *)
            R       : Run_Profile;          (* motor run profile stuff *)
            end;            

Var     Frame_Count   : Integer;            (* overall frame count *)
        Camera_Count  : Integer;            (* camera frame count *)
        Projector_Count : Integer;          (* projector frame count *)
        Sequencer_Count : Integer;          (* sequencer frame count *)
        Sequencer : Sequencer_Mode;         (* sequencer operation *)
        Camera_Cycle : Integer;             (* camera cycle count *)
        Projector_Cycle : Integer;          (* projector cycle count *)
        Camera_Total : Integer;             (* camera total frames *)
        Projector_Total : Integer;          (* projector total frames *)

Const   CX = 1;                             (* camera axis *)
        PX = 2;                             (* projector axis *)
        
Var     I : Integer;                        (* axis array index - general *)
        Index : Integer;                    (* axis array index - specific *)
        AA : Array [1..Max_Axes] of Axis_Table;

Var     Exposure_Time : Real;               (* camera exposure time *)
        Film_Speed : Real;                  (* projector advance speed *)

Implementation

(* Initialize default axis table. *)

Procedure Init_Defaults;

Begin

   For I := 1 to Max_Axes Do
       With AA [I] Do
            begin
            Spec := True;
            With A Do
                 begin
                 Id [0] := Chr (2);
                 Id [1] := 'X';
                 Id [2] := Chr (Ord ('A') + I-1);
                 No     := I;
                 Name   := '---';
                 end;
            With M Do
                 begin
                 MotorNo:= I;
                 StepCnt:= 0.0;
                 Dir    := FWD;
                 AccelSt:= True;
                 Speed  := 500;
                 LowSpd := 250;
                 HighSpd:= 1000;
                 RampCnt:= 200;
                 RampK  := 0;
                 Stat   := '?';
                 Count  := 0.0;
                 Error  := False;
                 end;
            With K Do
                 begin
                 Kscale := 1.0;
                 DP     := 1;
                 Units  := 'Steps';
                 Cur_Step   := 0.0;
                 Cur_Posn   := 0.0;
                 end;
            With R Do
                 begin
                 AccelSt    := True;
                 Max_Speed  := 500;
                 Min_LowSpd := 250;
                 Max_HighSpd:= 1000;
                 Max_RampCnt:= 200;
                 end;
            end;
End;

(* Initialization *)

Begin

  (***** init default axis array data *****)
    
  Init_Defaults;

  (***** initialize sequencer variables here *****)
  
  Index := 1;
  
  Frame_Count := 0;
  Camera_Count := 0;
  Projector_Count := 0;
  Sequencer_Count := 0;
  Sequencer := Alternate;
  Camera_Cycle := 1;
  Projector_Cycle := 1;
  Camera_Total := 0;
  Projector_Total := 0;
  
  With AA [CX] Do                        (* camera axis *)
       begin
       A.Name := 'Camera';
       M.AccelSt := True;
       M.LowSpd  := 0;
       M.HighSpd := 334;
       M.RampCnt := 50;
       K.Kscale  := 1.0;
       K.DP      := 1;
       K.Units   := 'Frames';
       R.AccelSt := True;
       R.Min_LowSpd  := 0;
       R.Max_HighSpd := 3.34;
       R.Max_RampCnt := 50;
       end;
       
  With AA [PX] Do                        (* projector axis *)
       begin
       A.Name := 'Projector';
       M.AccelSt := True;
       M.LowSpd  := 0;
       M.HighSpd := 334;
       M.RampCnt := 50;
       K.Kscale  := 1.0;
       K.DP      := 1;
       K.Units   := 'Frames';
       R.AccelSt := True;
       R.Min_LowSpd  := 0;
       R.Max_HighSpd := 3.34;
       R.Max_RampCnt := 50;
       end;

End.
