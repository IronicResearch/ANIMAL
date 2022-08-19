
(* SPLINE COMPUTATION tests the Turbo Pascal Spline procedure
(* as an independently operating module. *)

PROGRAM SPLINE_COMPUTATION;

TYPE PLOTARRAY = ARRAY [1..100, 1..2] OF REAL;

VAR CH : CHAR;
    I : INTEGER;
    ND : INTEGER;
    NS : INTEGER;
    DP : PLOTARRAY;
    SP : PLOTARRAY;

PROCEDURE ERROR (PROC, CODE : INTEGER);

BEGIN

   WRITELN ('ERROR # ', CODE, ' in procerdure # ', PROC);

END;

{$I SPLINE.HGH}

BEGIN

WRITELN;
WRITELN ('Spline Computations ');
WRITELN;

REPEAT

   WRITE ('Number of Data Points = ');
   READLN (ND);
   WRITELN;
   FOR I := 1 TO ND DO
       BEGIN
       WRITE ('point # ', I, ' X = ');
       READ (DP [I,1]);
       WRITE ('   Y = ');
       READ (DP [I,2]);
       WRITELN;
       END;

   WRITELN;
   WRITE ('Number of Splined Points = ');
   READLN (NS);
   WRITELN;

   SPLINE (DP, ND, DP [2,1], DP [ND-1,1], SP, NS);

   FOR I := 1 TO NS DO
       WRITELN (I:10, SP [I,1]:10:3, SP [I,2]:10:3, (SP [I,2] - SP [I-1,2]):10:3);
   WRITELN;

   WRITE ('Continue Splining? ');
   READLN (CH);
   WRITELN;

UNTIL CH = 'N';

END.
