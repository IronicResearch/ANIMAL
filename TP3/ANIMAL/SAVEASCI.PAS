
(* SAVE ASCII converts a binary Point-Plotter file to ASCII text. *)

PROGRAM SAVE_ASCII;

VAR XYNO : INTEGER;
    AX1P : ARRAY [1..1024] OF REAL;
    AX2P : ARRAY [1..1024] OF REAL;
    AX3P : ARRAY [1..1024] OF REAL;
    AX4P : ARRAY [1..1024] OF REAL;
    AX5P : ARRAY [1..1024] OF REAL;
    AX6P : ARRAY [1..1024] OF REAL;
    AX7P : ARRAY [1..1024] OF REAL;

(* LOAD_PLOT loads a previously saved XY plot
(* from disk into memory for processing. *)

PROCEDURE LOAD_PLOT;

VAR I : INTEGER;
    POINTS : REAL;

   XYNAME : STRING [14];
   XYPLOT : FILE OF REAL;

BEGIN

   WRITE ('XY file name: ');
   READLN (XYNAME);
   WRITELN;

   WRITELN ('Proceeding to load XY plot...');
   ASSIGN (XYPLOT, XYNAME);
   {$I-}
   RESET (XYPLOT);
   {$I+}

   IF IORESULT = 0 THEN BEGIN

   READ (XYPLOT, POINTS);
   XYNO := TRUNC (POINTS);

   FOR I := 1 TO XYNO DO
       BEGIN
       READ (XYPLOT, AX1P [I]);
       READ (XYPLOT, AX2P [I]);
       READ (XYPLOT, AX3P [I]);
       READ (XYPLOT, AX4P [I]);
       READ (XYPLOT, AX5P [I]);
       READ (XYPLOT, AX6P [I]);
       READ (XYPLOT, AX7P [I]);
       END;

   CLOSE (XYPLOT);
   WRITELN ('File loading completed.');
   WRITELN;

   END;       (* IF loading ok *)

END;      (* CASE procedure LOAD_PLOT *)

(* CONVERT ASCII converts each plot point to the Point-Plotter's ASCII
(* screen display, and saves it into a text file. *)

PROCEDURE CONVERT_ASCII;

VAR I : INTEGER;
    S : STRING [20];
    ASCNAME : STRING [14];
    ASCPLOT : TEXT;

BEGIN

   WRITE ('XY file name: ');
   READLN (ASCNAME);
   WRITELN;

   WRITELN ('Proceeding to save ASCII file...');
   ASSIGN (ASCPLOT, ASCNAME);
   {$I-}
   REWRITE (ASCPLOT);
   {$I+}

   IF IORESULT = 0 THEN BEGIN

   STR (XYNO, S);
   WRITELN (ASCPLOT, S);
   WRITELN (ASCPLOT);
   FOR I := 1 TO XYNO DO
       BEGIN
       STR (I:8, S);
       WRITE (ASCPLOT, S);
       STR (AX1P [I]:10:0, S);
       WRITE (ASCPLOT, S);
       STR (AX2P [I]:10:0, S);
       WRITE (ASCPLOT, S);
       STR (AX3P [I]:10:0, S);
       WRITE (ASCPLOT, S);
       STR (AX4P [I]:10:0, S);
       WRITE (ASCPLOT, S);
       STR (AX5P [I]:10:0, S);
       WRITE (ASCPLOT, S);
       STR (AX6P [I]:10:0, S);
       WRITE (ASCPLOT, S);
       STR (AX7P [I]:10:0, S);
       WRITE (ASCPLOT, S);
       WRITELN (ASCPLOT);
       END;
    WRITELN (ASCPLOT);
    CLOSE (ASCPLOT);
    WRITELN ('File saving completed.');
    WRITELN;

    END;

END;

BEGIN

   WRITELN;
   WRITELN ('Binary --> ASCII Plot Conversion');
   WRITELN;
   LOAD_PLOT;
   CONVERT_ASCII;

END.



