
(* LOAD ASCII converts an ASCII text file into a binary Point-Plotter file.*)

PROGRAM LOAD_ASCII;

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

PROCEDURE SAVE_PLOT;

VAR I : INTEGER;
    POINTS : REAL;

    XYNAME : STRING [14];
    XYPLOT : FILE OF REAL;

BEGIN

   WRITE ('XY file name: ');
   READLN (XYNAME);
   WRITELN;

   WRITELN ('Proceeding to save XY plot...');
   ASSIGN (XYPLOT, XYNAME);
   {$I-}
   REWRITE (XYPLOT);
   {$I+}

   IF IORESULT = 0 THEN BEGIN

   POINTS := XYNO;
   WRITE (XYPLOT, POINTS);

   FOR I := 1 TO XYNO DO
       BEGIN
       WRITE (XYPLOT, AX1P [I]);
       WRITE (XYPLOT, AX2P [I]);
       WRITE (XYPLOT, AX3P [I]);
       WRITE (XYPLOT, AX4P [I]);
       WRITE (XYPLOT, AX5P [I]);
       WRITE (XYPLOT, AX6P [I]);
       WRITE (XYPLOT, AX7P [I]);
       END;

   CLOSE (XYPLOT);
   WRITELN ('File saving completed.');
   WRITELN;

   END;

END;

(* CONVERT BINARY converts each plot point from the Point-Plotter's ASCII
(* screen display back into the binary (real) values. *)

PROCEDURE CONVERT_BINARY;

VAR I : INTEGER;
    S : STRING [20];
    S8 : STRING [8];
    S10 : STRING [10];
    E : INTEGER;
    P : REAL;

    ASCNAME : STRING [14];
    ASCPLOT : TEXT;

BEGIN

   WRITE ('XY file name: ');
   READLN (ASCNAME);
   WRITELN;

   WRITELN ('Proceeding to load ASCII file...');
   ASSIGN (ASCPLOT, ASCNAME);
   {$I-}
   RESET (ASCPLOT);
   {$I+}

   IF IORESULT = 0 THEN BEGIN

   READLN (ASCPLOT, S);
   VAL (S, P, E);
   XYNO := TRUNC (P);
   READLN (ASCPLOT);
   FOR I := 1 TO XYNO DO
       BEGIN
       READ (ASCPLOT, S8);
       READ (ASCPLOT, S10);
       VAL (S10, AX1P [I], E);
       READ (ASCPLOT, S10);
       VAL (S10, AX2P [I], E);
       READ (ASCPLOT, S10);
       VAL (S10, AX3P [I], E);
       READ (ASCPLOT, S10);
       VAL (S10, AX4P [I], E);
       READ (ASCPLOT, S10);
       VAL (S10, AX5P [I], E);
       READ (ASCPLOT, S10);
       VAL (S10, AX6P [I], E);
       READ (ASCPLOT, S10);
       VAL (S10, AX7P [I], E);
       READLN (ASCPLOT);
       END;
    READLN (ASCPLOT);
    CLOSE (ASCPLOT);
    WRITELN ('File loading completed.');
    WRITELN;

    END;

END;

BEGIN

   WRITELN;
   WRITELN ('ASCII --> Binary Plot Conversion');
   WRITELN;
   CONVERT_BINARY;
   SAVE_PLOT;

END.



