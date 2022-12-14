(* Time clock routines using real-time clock. *)

Unit TIMEX;

Interface

Uses DOS;

Function ThisTime : longint;
Function ThatTime : longint;
Function DeltaTime : longint;
Procedure MarkTime;

Function QThisTime : integer;
Function QThatTime : integer;
Function QDeltaTime : integer;
Procedure QMarkTime;

Implementation

(* PC 18Hz timer updates real-time clock variable every 55 millisec. *)
(* The time is accurate, but the update resolution is coarse. *)

Var Time_Marker : longint;              (* complete time interval *)
    QTime_Marker : integer;             (* quick time interval *)

var hour,min,sec,frac : word;           (* MS-DOS in 1/100s *)

(* Return the current time as single value. *)
Function ThisTime : longint;
Begin
   GetTime(hour, min, sec, frac);
   ThisTime := (360000*longint(hour) + 6000*longint(min)
                + 100*longint(sec) + longint(frac));
End;

(* Mark the current time. *)
Procedure MarkTime;
Begin
   Time_Marker := ThisTime;
End;

(* Return the last marked time value. *)
Function ThatTime : longint;
Begin
   ThatTime := Time_Marker;
End;

(* Compute the difference between the current time and the marked time. *)
Function DeltaTime : longint;
Begin
   DeltaTime := ThisTime - ThatTime;
End;

(* Quick time routines only in seconds. *)
(* Return the current time as single value. *)
Function QThisTime : integer;
Begin
   GetTime(hour, min, sec, frac);
   QThisTime := 100*(sec) + (frac);
End;

(* Mark the current time. *)
Procedure QMarkTime;
Begin
   QTime_Marker := QThisTime;
End;

(* Return the last marked time value. *)
Function QThatTime : integer;
Begin
   QThatTime := QTime_Marker;
End;

(* Compute the difference between the current time and the marked time. *)
Function QDeltaTime : integer;
var delta : integer;
Begin
   delta := QThisTime - QTime_Marker;
   if (delta < 0)
      then delta := delta + 6000;
   QDeltaTime := delta;
End;

(* Initialization *)

Begin

   Time_Marker := 0;
   QTime_Marker := 0;

End.
