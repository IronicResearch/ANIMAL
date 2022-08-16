(* Time clock routines using real-time clock. *)

(* Originally for DOS time functions (GetTime) with Turbo Pascal. *)
(* Adapted to Mac OS time functions (TickCount) with CodeWarrior Pascal. *)

Unit TIMEX;

Interface

Uses Types, Events;

Function ThisTime : longint;
Function ThatTime : longint;
Function DeltaTime : longint;
Procedure MarkTime;

Function QThisTime : integer;
Function QThatTime : integer;
Function QDeltaTime : integer;
Procedure QMarkTime;

Implementation

(* Mac OS timer based on 1/60th-second ticks. *)

Var Time_Marker : longint;              (* complete time interval in 1/100th-seconds *)
    QTime_Marker : integer;             (* quick time interval in seconds *)

(* Return the current time as single value. *)
Function ThisTime : longint;
Begin
   ThisTime := TickCount * 60 DIV 100;
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
(* Return the current time in seconds. *)
Function QThisTime : integer;
Begin
   QThisTime := integer(TickCount) * 60;
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
      then delta := delta + MaxInt;
   QDeltaTime := delta;
End;


End.
