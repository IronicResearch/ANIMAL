
(* Main Processing *)

Unit MAINIO;

Interface

{$I SWITCHES.INC}                           (* compiler switches *)

Uses
     Dos,
     TpCrt,                (* TurboPro input/output *)
     KEYBD,                (* Keyboard input filters *)
     Drivers,              (* Turbo Vision *)
     Views,
     MsgBox,
     GLOBAL,               (* Animal Global declarations *)
     GLOBAL2,
     SPLINE,
     INIT,
     MCPU,
     MCPUIO,
     TRIGIO,
{$IFDEF RGB_CONTROL}
     RGBIO,
     RGBMAIN,              (* RGB Light Source processing *)
{$ENDIF}
     FILEIO;

Procedure Signon;

Procedure Init_Animal;

Procedure Exit_Animal;

Procedure New_Plot;

Procedure Load_Plot_File;

Procedure Save_Plot_File;

Procedure Plot_Key_Points;

Procedure Edit_Key_Points;

Procedure Edit_Screen_Time;

Procedure Edit_Tapers;

Procedure Compute_Time_Base;

Procedure Compute_Spline_Curves;

Procedure Compute_Interpolated_Points;

Procedure Display_Point_Numbers;

Procedure Display_Point_Graphics;

Procedure Run_Plot;

Procedure Forward_Plot;

Procedure Reverse_Plot;

{Procedure Go_Jog_Overide;}

Procedure Go_Joystick_Overide;

Procedure Overide;

Procedure Query_Save_File;

Procedure Quitting_Time_Query;

(************)

Implementation

(* private use for interaction back with user interface routines: *)
Uses USERIO;    (* User interface *)

(* Animal initialization stuff. *)

Procedure Init_Animal_Stuff;

Begin

   Displayed := FALSE;

   Taper_In := 10.0;
   Taper_Out := 10.0;

   Zoom_Overide := False;

   Pre_Roll := 0.0;
   Pre_Rolled := False;

   Frozen_Fresh := False;

   Really_Graphics := False;
   Delta_Graphics := False;

   Stop_Motion := True;
   Go_Motion := False;
   Single_Framed := False;
   Reverse_Runned := False;

   Exposure_Time := 0.0;
   Exposure_Time := 1.0 / Frame_Rate;
   Streaked_Exposures := False;
   Streaked_Increments := True;

   KeyFrames_Saved := True;
   Tapers_Saved := True;
   Points_Saved := False;

   Graphics_Loaded := False;

   Default_Plot := 'ANIMAL.KEY';
   Default_Text := 'ANIMAL.KEY';

   Default_Mapping := 'ANIMAL.MAP';
   Default_Units := 'ANIMAL.UNT';
   Default_Speeds := 'ANIMAL.SPD';
   Default_Alignment := 'ANIMAL.ALN';
   Default_Triggers := 'ANIMAL.TRG';

   For I := 1 to Max_Axes Do
       AA [I].Spec := False;

   AA [XX].Spec := True;
   AA [YY].Spec := True;
   AA [ZZ].Spec := True;
   AA [RR].Spec := True;

End;

(* Initialize point-plotter memory. *)

Procedure Init_Point_Plotter;

Var P : Integer;

Begin

   Frame_Count := 0;
   Preset_Count := 0;
   Screen_Time := 0.0;

   StartKeyPt := 1;
   EndKeyPt := 1;
   KeyNo := 0;

   StartPt := 0;
   EndPt := 0;
   XYno := 0;

   Plot_Ended := False;
   Plot_Edited := False;
   Plot_Saved  := False;

   For I := 1 to Max_Axes Do
       With AA [I] Do
            If Spec
               Then For P := 0 to Max_Points Do
                    Key [P] := 0.0;

   For P := 1 to Max_Points Do
       Time_Key [P] := 0.0;
End;

(*************************)

(* Computation routines. *)

(* Compute Tapers computes a tapered time base. *)
(* Time base is subsequently used for input to interpolations. *)
(* (Taper algorithm adapted from Animal Stop Motion parameters.) *)
(* Normalize time base axis from 0..1 for either linear or splines. *)

Procedure Compute_Tapers;

Var StartFrame, EndFrame : Integer;
    StartPoint, EndPoint : Real;
    Accel, Decel, IncrMax : Real;

Var F, A, C, D : Integer;
    Frame_Count, Accel_Count, Const_Count, Decel_Count : Integer;
    Area_Total, Area_Accel, Area_Const, Area_Decel  : Real;
    Position : Real;
    Increment : Real;

Begin

   StartFrame := (* 0 *) 1;
   EndFrame   := Preset_Count;
   StartPoint := 0.0;
   EndPoint   := 1.0;
   Accel      := Taper_In;
   Decel      := Taper_Out;

   IncrMax := (EndPoint - StartPoint) / (EndFrame - StartFrame);
   Frame_Count := EndFrame - StartFrame;
   Accel_Count := Round (Accel / 100.0 * Frame_Count);
   Decel_Count := Round (Decel / 100.0 * Frame_Count);
   Const_Count := Frame_Count - (Accel_Count + Decel_Count);
   Area_Accel := 0.0;
   If Accel_Count > 0
      Then For A := 1 to Accel_Count Do
           Area_Accel := Area_Accel + Sin (Pi/2 * A/Accel_Count);
   Area_Decel := 0.0;
   If Decel_Count > 0
      Then For D := Decel_Count downto 1 Do
           Area_Decel := Area_Decel + Sin (Pi/2 * D/Decel_Count);
   Area_Const := 1.0 * Const_Count;
   Area_Total := Area_Accel + Area_Const + Area_Decel;
   IncrMax := (EndPoint - StartPoint) / Area_Total;

   Position := StartPoint;
   For F := 1 to Preset_Count Do
       begin
       Increment := 0.0;
       If F <= StartFrame
          Then Position := StartPoint
       Else If F >= EndFrame
          Then Position := EndPoint
       Else begin
          A := F - StartFrame;
          D := EndFrame - F + 1;
          If F < StartFrame + Accel_Count
             Then Increment := IncrMax * Sin (Pi/2 * A/Accel_Count)
          Else If F > EndFrame - Decel_Count
             Then Increment := IncrMax * Sin (Pi/2 * D/Decel_Count)
          Else Increment := IncrMax;
          Position := Position + Increment;
          end;
       Time_Base [F] := Position;
       end;
End;

(* SPLINED INTERPOLATION uses cubic splining to interpolate the existing plot. *)
(* Note: Point-Plotter procedures index points 1..XYno. *)
(* Duplicate points are stuffed into indexes 0..XYno+1. *)
(* Output X values are pre-tapered Time Base intervals. *)
(* Output Y values are pre-zeroed in case of Spline Error. *)

PROCEDURE SPLINED_INTERPOLATION;

VAR I : INTEGER;
    P : INTEGER;
    NI : INTEGER;
    NO : INTEGER;
    XI : TNVECTOR;
    YI : TNVECTOR;
    XO : Real_Array;
    YO : Real_Array;
    Error : Integer;

BEGIN     (* Spline Interpolation *)

   NI := KeyNo;
   NO := XYno;

   If NO > Max_Array
      Then NO := Max_Array;
   IF NO > MAX_SPLINE
      THEN NO := MAX_SPLINE;

   IF NO > NI
      THEN BEGIN
      FOR I := 1 TO Max_Axes DO
          IF AA [I].SPEC
             THEN BEGIN
             FOR P := 1 TO NI DO
                 begin
                 XI [P] := Time_Key [P];
                 YI [P] := AA [I].Key [P];
                 end;
             For P := 1 to NO Do
                 begin
                 XO [P] := Time_Base [P] * Screen_Time;
                 YO [P] := 0.0;
                 end;
             CUBICSPLINEFREE (NI,XI,YI,NO,XO,YO,ERROR);
             FOR P := 1 TO NO DO
                 Put_Pt (I, P, YO [P]);
             Put_Pt (I, 0, YO [1]);
             Put_Pt (I, NO+1, YO [NO]);
             END;
      XYno := NO;
      END;
END;

(* Linear_Interpolation computes equal increments between 2 key points. *)
(* Use normalized time base axis for scaling by pre-computed tapers. *)

Procedure Linear_Interpolation;

Var P : Integer;
    Origin : Real;
    Increment : Real;
    Position : Real;

Begin

   For I := 1 to Max_Axes Do
       With AA [I] Do
            If Spec
               Then begin
               Origin := Key [1];
               Increment := Key [KeyNo] - Key [1];
               For P := 1 to XYno Do
                   begin
                   Position := Origin + Time_Base [P] * Increment;
                   Put_Pt (I, P, Position);
                   end;
               Put_Pt (I, 0, Key [1]);
               Put_Pt (I, XYno+1, Key [KeyNo]);
               end;
End;

(* Freeze_Frames scans a 3+ key-frame plot for duplicate points,
(* and freezes the interpolated spline plot between those points. *)
(* Compute tapers at each of the starting and ending freeze points. *)

Procedure Compute_Freeze_Frames;

Var F : Integer;
    P : Integer;
    StartFreeze, EndFreeze, TaperFreeze : Integer;
    TaperInitl, TaperFinal, TaperCount : Integer;
    Position, Increment : Real;
    MaxDistance, MaxIncrement : Real;
    Point : Real_Array;
    Delta : Real_Array;
Begin
If (KeyNo > 2) And (XYno > 1)
   Then For I := 1 to Max_Axes Do
   With AA [I] Do
   If Spec
      Then For F := 1 to KeyNo-1 Do
      If Key [F+1] = Key [F]
         Then begin
         (* freeze the points between the duplicate key frames *)
         StartFreeze := 1;
         EndFreeze := 1;
         For P := 1 to XYno Do
             begin
             If (Screen_Time*Time_Base [P] < Time_Key [F])
                Then StartFreeze := P;
             If (Screen_Time*Time_Base [P] >= Time_Key [F])
             And (Screen_Time*Time_Base [P] <= Time_Key [F+1])
                 Then begin
                 Put_Pt (I, P, Key [F]);
                 EndFreeze := P;
                 end;
             end;
         TaperFreeze := Round (0.10 * (EndFreeze - StartFreeze));

         If (F > 1) And (F+1 < KeyNo) Then begin

         (* scan points around the starting freeze frame for increments *)
         TaperInitl := StartFreeze - TaperFreeze;
         If TaperInitl < 1
            Then TaperInitl := 1;
         TaperFinal := StartFreeze + TaperFreeze;
         If TaperFinal > Xyno
            Then TaperFinal := Xyno;
         TaperCount := TaperFinal - TaperInitl;
         MaxDistance := 0.0;
         For P := TaperInitl to TaperFinal Do
             If (P > 1) And (P < XYno)
                Then begin
                Point [P] := Get_Pt (I, P);
                If P <= TaperInitl
                   Then Increment := 0.0
                   Else Increment := Get_Pt (I, P) - Get_Pt (I, P-1);
                Delta [P] := Increment;
                MaxDistance := MaxDistance + Increment;
                end;
         (* taper out the 1st half of the points by 0-45 degree sines *)
         MaxIncrement := MaxDistance / (TaperCount-1) / Sin(Pi/4.0);
         Position := Point [TaperInitl];
         For P := TaperInitl+1 to StartFreeze Do
             If (P > 1) And (P < XYno)
                Then begin
                If (P <= StartFreeze) And (Delta [P] <> 0.0)
                   Then Increment := Delta [P] *
                        Cos (Pi/2.0 * (P-TaperInitl)/(TaperCount-1))
                   Else Increment := MaxIncrement *
                        Cos (Pi/2.0 * (P-TaperInitl)/(TaperCount-1));
                Position := Position + Increment;
                Put_Pt (I, P, Position);
                end;
         (* taper out the 2nd half of the points by whatever is left to go *)
         For P := StartFreeze+1 to TaperFinal Do
             If (P > 1) And (P < XYno)
                Then begin
                Increment := 0.707 * Increment;
                If (Increment > 0.0) And (Position + Increment > Key [F])
                Or (Increment < 0.0) And (Position + Increment < Key [F])
                   Then Increment := Key [F] - Position;
                Position := Position + Increment;
                Put_Pt (I, P, Position);
                end;
         (* accumulate any remaining intervals with constants. *)
         P := TaperFinal+1;
         If (Increment > 0.0)
            Then While (Position + Increment < Key [F])
                 And (P <= EndFreeze)
                 Do begin
                 Position := Position + Increment;
                 Put_Pt (I, P, Position);
                 P := P+1;
                 end
         Else If (Increment < 0.0)
            Then While (Position + Increment > Key [F])
                 And (P <= EndFreeze)
                 Do begin
                 Position := Position + Increment;
                 Put_Pt (I, P, Position);
                 P := P+1;
                 end;

         (* scan points around the ending freeze frame for increments *)
         TaperInitl := EndFreeze + TaperFreeze;
         If TaperInitl > Xyno
            Then TaperInitl := Xyno;
         TaperFinal := EndFreeze - TaperFreeze;
         If TaperFinal < 1
            Then TaperFinal := 1;
         TaperCount := Abs (TaperFinal - TaperInitl);
         MaxDistance := 0.0;
         For P := TaperInitl downto TaperFinal Do
             If (P > 1) And (P < XYno)
                Then begin
                Point [P] := Get_Pt (I, P);
                If P >= TaperInitl
                   Then Increment := 0.0
                   Else Increment := Get_Pt (I, P+1) - Get_Pt (I, P);
                Delta [P] := Increment;
                MaxDistance := MaxDistance + Increment;
                end;
         (* taper out the 1st half in reverse order by 0-45 degree sines *)
         MaxIncrement := MaxDistance / (TaperCount-1) / Sin(Pi/4.0);
         Position := Point [TaperInitl];
         For P := TaperInitl-1 downto EndFreeze+1 Do
             If (P > 1) And (P < XYno)
                Then begin
                If (P >= EndFreeze+1) And (Delta [P] <> 0.0)
                   Then Increment := Delta [P] *
                        Cos (Pi/2.0 * (TaperInitl-P)/(TaperCount-1))
                   Else Increment := MaxIncrement *
                        Cos (Pi/2.0 * (TaperInitl-P)/(TaperCount-1));
                Position := Position - Increment;
                Put_Pt (I, P, Position);
                end;
         (* taper out the 2nd half in reverse by whatever is left to go *)
         For P := EndFreeze-0 downto TaperFinal Do
             If (P > 1) And (P < XYno)
                Then begin
                Increment := 0.707 * Increment;
                If (Increment > 0.0) And (Position - Increment < Key [F])
                Or (Increment < 0.0) And (Position - Increment > Key [F])
                   Then Increment := Position - Key [F];
                Position := Position - Increment;
                Put_Pt (I, P, Position);
                end;
         (* accumulate any remaining intervals with constants. *)
         P := TaperFinal+1;
         If (Increment > 0.0)
            Then While (Position - Increment > Key [F])
                 And (P >= StartFreeze)
                 Do begin
                 Position := Position - Increment;
                 Put_Pt (I, P, Position);
                 P := P-1;
                 end
         Else If (Increment < 0.0)
            Then While (Position - Increment < Key [F])
                 And (P >= StartFreeze)
                 Do begin
                 Position := Position - Increment;
                 Put_Pt (I, P, Position);
                 P := P-1;
                 end;
         end;    (* if tapered freeze frames *)
         end;    (* if freeze frames at all *)
End;

(* Compute_Frames interpolates the key-frame points into real-time points. *)

Procedure Compute_Frames;

Begin

   If (KeyNo > 1) And (Preset_Count > 1)
      Then begin
           XYno := Preset_Count;
           Compute_Tapers;

           If KeyNo > 2
              Then Splined_Interpolation
              Else Linear_Interpolation;

           (* StartPt := 1; *)
           (* EndPt := XYno; *)
           Plot_Edited := True;
           end;
End;

(*************************************)

(* Animal program internal linkages. *)

(* Animal program signon. *)

Var McpuPort : integer;                 (* MCPU serial port # *)

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

   Writeln ('Animal Professional / Animation Motion Control');
   Writeln ('Copyright 1992 Dave Milici / Penguin Associates');
   Writeln;
{$IFDEF REALTIME_MOTION}
   Writeln ('Installation for Pacific / Korty / Penguin');
   Writeln ('Compumotor MCPU for COM', McpuPort);
{$ELSE}
   Writeln ('Installation for Robomaster Industries');
   Writeln ('STD bus MCPU for COM', McpuPort);
{$ENDIF}
   Writeln;

End;

(* Initialize Animal software variables and MCPU hardware communications. *)

Procedure Init_Animal;

Begin

   SetSio (McpuPort);                   (* select MCPU serial COM port *)
   ResetSio;                            (* init serial port *)
   Init_Mcpu;                           (* init MCPU communications *)
   Init_PC23;                           (* init Compumotor PC23 features *)
   Init_Trigger;                        (* init trigger port output *)
{$IFDEF RGB_CONTROL}
   Init_RGB_Color;                      (* init RGB Light Source *)
   Load_Color_File('ANIMAL.RGB');       (* load default color table file *)
{$ENDIF}

   Init_Load;                           (* load default Animal data files *)
   Init_Animal_Stuff;                   (* init general Animal axis data *)
   Init_Point_Plotter;                  (* init point-plotter data *)

   Disable_Joystick;                    (* custom joystick peripheral *)
   Disable_Zoom_Lens;                   (* special ZZ axis multiplexer signal *)
   Init_Axes;                           (* re-init all Animal axis data *)

End;

Procedure Exit_Animal;

Begin
   MCPU_Error_Stats;                    (* timeout error stats *)
End;

(* Ask if user wants to save plot onto file before proceeding. *)

{Procedure Query_Save_File;
Forward;}

(* Start new plot from scratch. *)

Procedure New_Plot;

Begin

   Query_Save_File;
   Init_Point_Plotter;

End;

(* Load plot from disk file into memory. *)

Procedure Load_Plot;
Begin
   Default_Text := Default_Plot;
   Convert_Binary;
   Default_Plot := Default_Text;
End;

{Procedure Compute_Time_Base;
Forward;}

{Procedure Compute_Interpolated_Points;
Forward;}

Procedure Load_Plot_File;
Var Point : Real;
Begin

   Query_Save_File;
   Init_Point_Plotter;

   Load_Plot;

   If KeyFrames_Saved
      Then begin
      Screen_Time := Time_Key [KeyNo];
      Preset_Count := Round (Screen_Time * Frame_Rate);
      XYno := Preset_Count;
      Compute_Interpolated_Points;
      end;

   If Points_Saved
      Then begin
      Preset_Count := XYno;
      Screen_Time := Preset_Count / Frame_Rate;
      Compute_Time_Base;
      end;

   (* Plot_Ended := False; *)
   (* StartPt := 1; *)
   (* EndPt := XYno; *)
   (* Frame_Count := 1; *)

   For I := 1 to Max_Axes Do
       With AA [I] Do
            If Spec
               Then begin
               Point := Get_Pt (I, 1);
               Put_Pt (I, 0, Point);
               Point := Get_Pt (I, XYno);
               Put_Pt (I, XYno+1, Point);
               end;
End;

(* Save plot from memory onto disk file. *)

Procedure Save_Plot;
Begin
   Default_Text := Default_Plot;
   Convert_Ascii;
   Default_Plot := Default_Text;
End;

Procedure Save_Plot_File;

Begin

   Save_Plot;
   Plot_Saved := True;

End;

(* Plot the key frame points into memory. *)

Procedure Plot_Key_Points;

Begin
End;

(* Edit the key-frame points in memory. *)

Procedure Edit_Key_Points;

Begin
   Plot_Edited := True;
End;

(* Edit the screen time of the output motion sequence. *)

Procedure Edit_Screen_Time;

Begin
   Preset_Count := Round (Screen_Time * Frame_Rate);
   If Preset_Count > Max_Array
      Then Preset_Count := Max_Array;
   If Preset_Count > Max_Spline
      Then Preset_Count := Max_Spline;
   Screen_Time := Preset_Count / Frame_Rate;
End;

(* Edit the taper-in and taper-out percentages of the motion sequence. *)

Procedure Edit_Tapers;

Begin
End;

(* Compute the time base (X-axis) for all motion axes. *)

Procedure Compute_Time_Base;

Var P : Integer;
Begin
   if (KeyNo > Max_Points-1)
      then KeyNo := Max_Points-1;
   If KeyNo > 1
      Then For P := 1 to KeyNo Do
           Time_Key [P] := (P-1)/(KeyNo-1) * Screen_Time;
End;

(* Compute the cubic spline curves between the key-frame points. *)

Procedure Compute_Spline_Curves;

Begin
End;

(* Compute interpolated points using the cubic spline curves. *)

Procedure Compute_Interpolated_Points;

Begin

   Compute_Frames;
   If Frozen_Fresh
      Then Compute_Freeze_Frames;
End;

(* Display the complete motion sequence points using numerical values. *)

Procedure Display_Point_Numbers;

Begin
End;

(* Display the motion sequence points using graphics. *)

Procedure Display_Point_Graphics;

Begin
End;

(* Run the output motion sequence. *)

Procedure Run_Plot;

Begin

   If Stop_Motion
      Then If Go_Motion
           Then Run_Go_Motion
           Else Run_Stop_Motion

      Else begin
           If Pre_Rolled
              Then Delay (Round (Pre_Roll * 1000.0));
           Pre_Run_Plot;
           Real_Time_Plot;
           Plot_Ended := NOT Plot_Ended;
           end;
End;

Procedure Forward_Plot;

Begin

   (* Frame_Count := 1; *)
   (* StartPt := 1; *)
   (* EndPt := XYno; *)

   If (XYno > 1)
      Then Run_Plot;
   (* Plot_Ended := True; *)

End;

Procedure Reverse_Plot;

Begin

   (* Frame_Count := XYno; *)
   (* StartPt := XYno; *)
   (* EndPt := 1; *)

   If (XYno > 1)
       Then Run_Plot;
   (* Plot_Ended := False; *)

End;

(* Overide the motion control axes via the joystick. *)

{Procedure Go_Jog_Overide;
Forward;}

Procedure Go_Joystick_Overide;

Begin

   Enable_Joystick;
   MessageBox ('Continue after Joystick Overide...', Nil, mfInformation + mfOkButton );
   Disable_Joystick;

End;

Procedure Overide;

Begin

{$IFDEF JOYSTICK_CONTROL}
   Go_Joystick_Overide;
{$ELSE}
   Go_Jog_Overide; 
{$ENDIF}

End;

(* Loop for main menu selections. *)

{Procedure Main_Menu_Loop;
Forward;}

(* Get name of file to save. *)

{Procedure Get_Save_File_Name;
Forward;}

{Procedure Save_File_Dialog;
Forward;}

(* Check if plot should be saved to disk. *)

Procedure Query_Save_File;

Var Answer : Word;
Begin

   If Plot_Edited And (Not Plot_Saved)
      Then begin
      Answer := MessageBox ('Save Current Plot?', Nil,
         mfWarning + mfYesbutton + mfNobutton + mfCancelbutton);
      If Answer = cmYes
         Then begin
         (* Get_Save_File_Name; *)
         Save_File_Dialog;
         Plot_Edited := False;
         Plot_Saved  := True;
         end
      Else If Answer = cmNo
         Then Plot_Edited := False;
      end;
End;

(* Check if user really wants to quit program. *)

Procedure Quitting_Time_Query;

Var Answer : Word;

Begin

   Answer := MessageBox ('Quitting Time...for sure?', Nil,
      mfWarning + mfYesButton + mfNoButton);
   Quitting_Time := (Answer = cmYes);

   If Quitting_time
      Then Query_Save_File;

End;

End.
