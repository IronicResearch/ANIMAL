
(* RGB Light Source Main Processing *)

Unit RGBMAIN;

Interface

{$I SWITCHES.INC}       (* compiler switches *)

{$DEFINE DELAY_VIDEO}   (* for video sync delay *)

Uses
  DOS,
  TPCRT,                (* TurboPro console *)
  RGBIO,                (* RGB IO routines *)
  GLOBAL,               (* so many points... *)
  GLOBAL2;              (* so many points... *)

Const
  RGB_DeltaTime : integer = 42;        (* RGB time resolution *)

Var
  RGB_Key : Array[0..Max_Points] of Array[0..3] of Integer;
  RGB_Buf : Array[0..Max_Spline] of Array[1..3] of Integer;

Procedure Compute_RGB_Color;
Procedure Run_RGB_Color;
Procedure Incr_RGB_Color(F : integer);
Procedure Save_Lightransit_File (FileName : string);
Procedure Load_Lightransit_File (FileName : string);

Implementation

{$IFDEF DELAY_VIDEO}
(* Use IBM PC Video sync for time delay. *)
Const VSTAT = $03DA;                    (* video status reg VGA/EGA/CGA *)
      VSYNC = $08;                      (* vertical retrace sync *)

(* Get vertical sync status from video card. *)
Function VideoSync : boolean;
Begin
    VideoSync := ((port[VSTAT] AND VSYNC) = VSYNC);
End;

(* Wait for the next complete video sync interval. *)
Procedure Wait_Video_Sync;
Begin
    while (VideoSync)
          do;
    while NOT (VideoSync)
          do;
End;

(* Delay the equivalent of real-time frame interval. *)
Procedure Delay_Real_Frame;
Begin
{$IFDEF VIDEO_INSTALLED}
    Wait_Video_Sync;                    (* 2 video fields *)
    Wait_Video_Sync;
{$ELSE}
    Wait_Video_Sync;                    (* approx 3 video fields *)
    Wait_Video_Sync;
    Wait_Video_Sync;
{$ENDIF}
End;
{$ENDIF}

(* Compute Color Transition over time.*)
Procedure Compute_RGB_Color;
Var T, IncrTime : longint;
    R, G, B : integer;
    Time : real;
    Ri, Gi, Bi, Rf, Gf, Bf : integer;
    K, F : integer; (* for frames *)
Begin
   Time := Screen_Time;
   IncrTime := Round (Time * Frame_Rate);
   F := 0;
   For T := 0 to IncrTime Do
       begin
       RGB_Buf[F][1] := 0;
       RGB_Buf[F][2] := 0;
       RGB_Buf[F][3] := 0;
       Inc(F);
       end;
   F := 0;
   If KeyNo > 1 Then
     For K := 1 to KeyNo-1 Do
       begin
       Ri := RGB_Key[K][1];
       Gi := RGB_Key[K][2];
       Bi := RGB_Key[K][3];
       Rf := RGB_Key[K+1][1];
       Gf := RGB_Key[K+1][2];
       Bf := RGB_Key[K+1][3];
       Time := Time_Key[K+1] - Time_Key[K];
       IncrTime := Round (Time * Frame_Rate);
       If IncrTime > 0 Then
          For T := 0 to IncrTime Do
          begin
          R := Round (Ri + (Rf - Ri) * T/IncrTime);
          G := Round (Gi + (Gf - Gi) * T/IncrTime);
          B := Round (Bi + (Bf - Bi) * T/IncrTime);
          RGB_Buf[F][1] := R;
          RGB_Buf[F][2] := G;
          RGB_Buf[F][3] := B;
          Inc(F);
          end;
       end;
End;

(* Run color transition according to pre-computed color increments. *)
Procedure Run_RGB_Color;
Var T, IncrTime : longint;
    R, G, B : integer;
Begin
   IncrTime := Round (Screen_Time * Frame_Rate);
   If IncrTime > 0 Then
     For T := 0 to IncrTime Do
       begin
       R := RGB_Buf[T][1];
       G := RGB_Buf[T][2];
       B := RGB_Buf[T][3];
       OutColor (R, G, B);
{$IFDEF DELAY_VIDEO}
       Delay_Real_Frame;
{$ELSE}
       Delay (RGB_DeltaTime);
{$ENDIF}
       if (KeyPressed)
          then break;
       end;
End;

(* Output color transition increment at selected time frame. *)
Procedure Incr_RGB_Color(F : integer);
Begin
   If F <= 0
      Then F := 1;
   If F >= Preset_Count
      Then F := Preset_Count;
   OutColor(RGB_Buf[F][1], RGB_Buf[F][2], RGB_Buf[F][3]);
End;

(* Color Program file IO in text mode. *)
Procedure Save_Lightransit_File (FileName : string);
Var I : integer;
    F : Text;
Begin
   {$I-}
   Assign(F, FileName);
   Rewrite(F);
   Write(F, KeyNo:10);
   Write(F, 'Color':10);
   Write(F, 'Red':10);
   Write(F, 'Green':10);
   Write(F, 'Blue':10);
   Writeln(F);
   Writeln(F);
   For I := 1 to KeyNo Do
       begin
       Write(F, I:10);
       Write(F, RGB_Key[I][0]:10);
       Write(F, RGB_Key[I][1]:10);
       Write(F, RGB_Key[I][2]:10);
       Write(F, RGB_Key[I][3]:10);
       Writeln(F);
       end;
   Writeln(F);
   Close(F);
   {$I+}
   if (IOResult <> 0)
      then Exit;
End;

Procedure Load_Lightransit_File (FileName : string);
Var I, J, Total : integer;
    F : Text;
Begin
   {$I-}
   Assign(F, FileName);
   Reset(F);
   Read(F, Total);
   if (KeyNo <> Total)
      then if (Total <= Max_Points)
           then KeyNo := Total
           else KeyNo := Max_Points;
   Readln(F);
   Readln(F);
   For I := 1 to Total Do
       begin
       Read(F, J);
       if (J <= Max_Points)
          then begin
          Read(F, RGB_Key[J][0]);
          Read(F, RGB_Key[J][1]);
          Read(F, RGB_Key[J][2]);
          Read(F, RGB_Key[J][3]);
          end;
       Readln(F);
       end;
   Close(F);
   {$I+}
   if (IOResult <> 0)
      then Exit;
End;

(* Initialization *)
(* RGB_DeltaTime needs calibration adjustment for Delay() call. *)

Var I,J : integer;
    hour,min,sec,frac : word;
    time, counter : longint;
    delayerror : real;

Begin

   For I := 1 to Max_Points Do
       For J := 0 to 3 Do
       RGB_Key[I][J] := 0;
   For I := 1 to Max_Spline Do
       For J := 1 to 3 Do
       RGB_Buf[I][J] := 0;

{$IFDEF DELAY_CALIBRATION}
   (* Delay() time calibration *)
   GetTime(hour,min,sec,frac);
   time := 100*sec + frac;
   Repeat
     GetTime(hour,min,sec,frac);
   Until (100*sec + frac > time);
   counter := 0;
   GetTime(hour,min,sec,frac);
   time := 100*sec + frac;
   Repeat
     GetTime(hour,min,sec,frac);
     Delay(1);
     Inc(counter);
   Until (100*sec + frac) > (time + 54); (* 1/18.2 = 0.0549 *)
   time := 100*sec + frac - time;
   if (time < 0)
      then time := time + 6000;
   delayerror := (10.0 * time) / counter;
   RGB_DeltaTime := Round (delayerror * 1000.0 / Frame_Rate);
   if (RGB_DeltaTime < 42)
      then RGB_DeltaTime := 42;
{$ENDIF}

End.
