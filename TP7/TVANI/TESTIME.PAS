
Program Test_Realtime_Clock;

Uses DOS,CRT;


(* ThisTime returns the real-time clock in cummulative ticks. *)

Function ThisTime : Longint;

var hour, min, sec, hund : word;
Begin
   GetTime (hour, min, sec, hund);
   ThisTime := hund + 100*sec + 6000*min;
End;

var time : longint;

Begin

   Repeat
      time := ThisTime;
      writeln ('time = ', time);
   Until Keypressed;


End.



