
(* COMPUTE PLOT uses good old high school math to compute plots. *)
(* Computed plots may be saved and loaded by ANIMAL Point-Plotter. *)

PROGRAM COMPUTE_PLOT;

CONST MX = 7;
      MAXPOINTS = 1024;
      MAXSPLINE = 512;

TYPE POINT_TABLE = ARRAY [1..MAXPOINTS] OF REAL;

     PLOT_TABLE = RECORD
        SPEC : BOOLEAN;
        PT : ARRAY [1..MAXPOINTS] OF REAL;
        END;

VAR CH : CHAR;
    ANSWER : CHAR;

    I : INTEGER;
    N : INTEGER;
    STARTPT : INTEGER;
    ENDPT : INTEGER;
    XYNO : INTEGER;
    FRAME_COUNT : INTEGER;

    AP : POINT_TABLE;

    AX : ARRAY [1..MX] OF PLOT_TABLE;

PROCEDURE RDCON (VAR CH : CHAR);

BEGIN

   READ (KBD, CH);
   WRITE (CH);

END;

PROCEDURE RDKEY (VAR CH : CHAR);

BEGIN

   READ (KBD, CH);

END;

(* READ REAL reads a real number with Input checking toggled off. *)

PROCEDURE RDREAL (VAR R : REAL);

VAR REAL_NUMBER : BOOLEAN;

BEGIN

   REPEAT

      {$I-}
      READ (R);
      {$I+}
      REAL_NUMBER := (IORESULT = 0);
      IF NOT REAL_NUMBER
         THEN WRITE (^G, ' ...ERROR -- Number only: ');

   UNTIL REAL_NUMBER;

END;

(* READLN REAL reads a real number and ends the line. *)

PROCEDURE RDLNREAL (VAR R : REAL);

VAR REAL_NUMBER : BOOLEAN;

BEGIN

   REPEAT

      {$I-}
      READLN (R);
      {$I+}
      REAL_NUMBER := (IORESULT = 0);
      IF NOT REAL_NUMBER
         THEN WRITE (^G, 'ERROR -- Please enter a number only: ');

   UNTIL REAL_NUMBER;

END;

(* READ INTEGER reads an integer number with Input checking toggled off. *)
(* Uses READ REAL for input and scales into integer range accordingly. *)

PROCEDURE RDINT (VAR I : INTEGER);

VAR R : REAL;

BEGIN

   R := I;
   RDREAL (R);
   IF R > MAXINT
        THEN I := MAXINT
   ELSE IF R < -1 * MAXINT
        THEN I := -1 * MAXINT
   ELSE I := ROUND (R);

END;

(* READLN INTEGER reads an integer number and ends the line. *)

PROCEDURE RDLNINT (VAR I : INTEGER);

VAR R : REAL;

BEGIN

   R := I;
   RDLNREAL (R);
   IF R > MAXINT
        THEN I := MAXINT
   ELSE IF R < -1 * MAXINT
        THEN I := -1 * MAXINT
   ELSE I := ROUND (R);

END;

(* ACTIVE AXES selects which axes are to be active for computing. *)

PROCEDURE ACTIVE_AXES;

VAR N : INTEGER;

BEGIN

   WRITELN ('Active Axis Selections...');
   WRITELN;
   FOR N := 1 TO MX DO
       BEGIN
       WRITE ('Axis # ', N, ' active? ');
       RDCON (ANSWER);
       WRITELN;
       AX [N].SPEC := (ANSWER = 'Y');
       END;
   WRITELN;

END;

(* INIT_PLOT initializes the entire array of plot points. *)

PROCEDURE INIT_PLOT;

VAR I : INTEGER;
    N : INTEGER;

BEGIN

   XYNO := 1;

   FOR I := 1 TO MAXPOINTS DO
       FOR N := 1 TO MX DO
           AX [N].PT [I] := 0.0;

END;

(* ASSEMBLE PLOT assembles the computed plot into the array. *)

PROCEDURE ASSEMBLE_PLOT;

VAR I : INTEGER;
    N : INTEGER;
    AXNO : CHAR;
    S : INTEGER;
    E : INTEGER;
    T : INTEGER;

BEGIN

   WRITELN ('Assemble Plot');
   WRITELN;
   WRITE ('Selected Axis # ');
   READLN (AXNO);
   S := 1;
   WRITE ('start at point # ');
   RDLNINT (S);
   WRITELN;
   T := FRAME_COUNT + 1;
   S := S - 1;
   E := S + T;

   CASE AXNO OF
        '1' : FOR I := 1 TO T DO AX [1].PT [I+S] := AP [I];
        '2' : FOR I := 1 TO T DO AX [2].PT [I+S] := AP [I];
        '3' : FOR I := 1 TO T DO AX [3].PT [I+S] := AP [I];
        '4' : FOR I := 1 TO T DO AX [4].PT [I+S] := AP [I];
        '5' : FOR I := 1 TO T DO AX [5].PT [I+S] := AP [I];
        '6' : FOR I := 1 TO T DO AX [6].PT [I+S] := AP [I];
        '7' : FOR I := 1 TO T DO AX [7].PT [I+S] := AP [I];
        END;

   IF XYNO < E
      THEN XYNO := E;

END;

(* DISPLAY PLOT displays the array of plot points computed so far. *)

PROCEDURE DISPLAY_PLOT;

VAR I : INTEGER;
    N : INTEGER;

BEGIN

   WRITELN ('Display XY points...');
   WRITELN;
   {WRITE ('Display all XY points logged so far? (Y/N) ');
   RDCON (ANSWER);
   WRITELN;
   WRITELN;}

   STARTPT := 1;
   ENDPT := XYNO;
   {IF ANSWER = 'N'
      THEN BEGIN
           WRITE ('start listing at point # ');
           RDLNINT (STARTPT);
           WRITE ('end listing at point   # ');
           RDLNINT (ENDPT);
           WRITELN;
           END;}

    WRITE ('Point':8);
    FOR N := 1 TO MX DO
        IF AX [N].SPEC
           THEN WRITE ('Axis #':9, N:1);
    WRITELN;
    WRITELN;

    FOR I := STARTPT TO ENDPT DO
        BEGIN
        WRITE (I:8);
        FOR N := 1 TO MX DO
            IF AX [N].SPEC
               THEN WRITE (AX [N].PT [I]:10:0);
        WRITELN;
        END;
    WRITELN;

END;

(* SAVE_PLOT saves the set of plotted XY points onto a disk file. *)

PROCEDURE SAVE_PLOT;

VAR I : INTEGER;
    N : INTEGER;
    POINTS : REAL;

    XYNAME : STRING [14];
    XYPLOT : FILE OF REAL;

    NAME_OK : BOOLEAN;
    SAVE_OK : BOOLEAN;
    ANSWER : CHAR;

BEGIN

REPEAT

   WRITE ('Save XY file name: ');
   READLN (XYNAME);
   WRITELN;

   WRITELN ('Proceeding to save XY plot...');
   ASSIGN (XYPLOT, XYNAME);
   {$I-}
   REWRITE (XYPLOT);
   {$I+}

   IF IORESULT = 0
      THEN SAVE_OK := TRUE
      ELSE BEGIN
           SAVE_OK := FALSE;
           WRITE ('File Saving Error -- Try again? (Y/N) ');
           RDCON (ANSWER);
           WRITELN;
           WRITELN;
           IF ANSWER = 'Y'
              THEN NAME_OK := FALSE
              ELSE NAME_OK := TRUE;
           END;

UNTIL NAME_OK OR SAVE_OK;

IF SAVE_OK
   THEN BEGIN

   POINTS := XYNO;
   WRITE (XYPLOT, POINTS);

   FOR I := 1 TO XYNO DO
       FOR N := 1 TO MX DO
           WRITE (XYPLOT, AX [N].PT [I]);

   CLOSE (XYPLOT);
   WRITELN ('File saving completed');
   WRITELN;

   END;  (* IF File Saving ok *)

END;     (* procedure SAVE_PLOT *)

(* LOAD_PLOT loads a previously saved XY plot
(* from disk into memory for processing. *)

PROCEDURE LOAD_PLOT;

VAR I : INTEGER;
    N : INTEGER;
    POINTS : REAL;

    XYNAME : STRING [14];
    XYPLOT : FILE OF REAL;

    LOAD_OK : BOOLEAN;
    NAME_OK : BOOLEAN;
    ANSWER : CHAR;

BEGIN

REPEAT

   WRITE ('Load XY file name: ');
   READLN (XYNAME);
   WRITELN;

   WRITELN ('Proceeding to load XY plot...');
   ASSIGN (XYPLOT, XYNAME);
   {$I-}
   RESET (XYPLOT);
   {$I+}

   IF IORESULT = 0
      THEN LOAD_OK := TRUE
      ELSE BEGIN
           LOAD_OK := FALSE;
           WRITE ('File Not Found -- Try again? (Y/N) ');
           RDCON (ANSWER);
           WRITELN;
           WRITELN;
           IF ANSWER = 'Y'
              THEN NAME_OK := FALSE
              ELSE NAME_OK := TRUE;
           END;

UNTIL LOAD_OK OR NAME_OK;

IF LOAD_OK
   THEN BEGIN

   READ (XYPLOT, POINTS);
   XYNO := TRUNC (POINTS);

   FOR I := 1 TO XYNO DO
       FOR N := 1 TO MX DO
           READ (XYPLOT, AX [N].PT [I]);

   CLOSE (XYPLOT);
   WRITELN ('File loading completed');
   WRITELN;

   END;       (* IF loading ok *)

END;      (* CASE procedure LOAD_PLOT *)

(* EDIT PLOT allows the user to manually edit an XY plot. *)

PROCEDURE EDIT_PLOT;

VAR I : INTEGER;
    N : INTEGER;
    CH : CHAR;
    KEY : CHAR;
    ANSWER : CHAR;
    QUIT_EDITING : BOOLEAN;

    STARTPT : INTEGER;
    ENDPT : INTEGER;
    DESTN : INTEGER;
    EXTRA : INTEGER;

    ADD : ARRAY [1..MX] OF REAL;
    SCALE : ARRAY [1..MX] OF REAL;
    INCR : ARRAY [1..MX] OF REAL;

PROCEDURE DISPLAY_HELP;

BEGIN

WRITELN ('Manual Plot Editing Menu:');
WRITELN;
WRITELN ('     E : Enter initial XY points');
WRITELN ('     C : Change existing XY points');
WRITELN ('     I : Insert inbetween XY points');
WRITELN ('     T : Throw away undesired XY points');
WRITELN;
WRITELN ('     D : Display current XY points');
WRITELN ('     M : Move XY points around (for more)');
WRITELN ('     O : Offset XY points by +/- amount');
WRITELN ('     S : Scale XY points by +/- factor');
WRITELN;
WRITELN ('     H : Help -- display this editing menu');
WRITELN ('     Q : Quit the current editing session');
WRITELN;

END;

BEGIN     (* EDIT PLOT *)

WRITELN ('Edit Plot...');
WRITELN;

DISPLAY_HELP;

QUIT_EDITING := FALSE;

REPEAT

   WRITE ('Editing Command > ');

   RDCON (KEY);

   CASE KEY OF

     'D' : BEGIN
           WRITELN ('isplay XY points...');
           WRITELN;
           WRITE ('Display all XY points so far? (Y/N) ');
           RDCON (ANSWER);
           WRITELN;
           WRITELN;

           STARTPT := 1;
           ENDPT := XYNO;
           IF ANSWER = 'N'
              THEN BEGIN
                   WRITE ('start listing at point # ');
                   RDLNINT (STARTPT);
                   WRITE ('end listing at point   # ');
                   RDLNINT (ENDPT);
                   WRITELN;
                   END;

           WRITE ('Point':8);
           FOR N := 1 TO MX DO
               IF AX [N].SPEC
                  THEN WRITE ('Axis #':9, N:1);
           WRITELN;
           WRITELN;

           FOR I := STARTPT TO ENDPT DO
               BEGIN
               WRITE (I:8);
               FOR N := 1 TO MX DO
                   IF AX [N].SPEC
                      THEN WRITE (AX [N].PT [I]:10:0);
               WRITELN;
               END;
           WRITELN;
           END;     (* CASE Listing *)

     'E' : BEGIN
           WRITELN ('nter points...');
           WRITELN;
           STARTPT := XYNO;
           ENDPT := XYNO + 1;
           WRITE ('enter points starting at # ');
           RDLNINT (STARTPT);
           WRITE ('up to points ending at   # ');
           RDLNINT (ENDPT);
           WRITELN;

           FOR I := STARTPT TO ENDPT DO
               BEGIN
               FOR N := 1 TO MX DO
                   IF AX [N].SPEC
                      THEN BEGIN
                           AX [N].PT [I] := AX [N].PT [I-1];
                           WRITE ('at point # ', I:4, '   Axis #', N:1, ' = ');
                           RDLNREAL (AX [N].PT [I]);
                           END;
               WRITELN;
               END;
           IF XYNO < ENDPT
              THEN XYNO := ENDPT;
           END;  (* CASE Enter *)

     'C' : BEGIN
           WRITELN ('hange points...');
           WRITELN;
           STARTPT := 1;
           ENDPT := XYNO;
           WRITE ('change points starting at # ');
           RDLNINT (STARTPT);
           WRITE ('up to points ending at pt # ');
           RDLNINT (ENDPT);
           WRITELN;

           FOR I := STARTPT TO ENDPT DO
               BEGIN
               FOR N := 1 TO MX DO
                   IF AX [N].SPEC
                      THEN BEGIN
                           WRITE ('at point # ', I:4, '   change Axis #', N:1, ' = ', AX [N].PT [I]:10:0, ' --> ');
                           RDLNREAL (AX [N].PT [I]);
                           END;
               WRITELN;
               END;  (* FOR changing points *)
           IF XYNO < ENDPT
              THEN XYNO := ENDPT;
           END;  (* CASE Change *)

     'I' : BEGIN
           WRITELN ('nsert points inbetween...');
           WRITELN;
           EXTRA := 1;
           STARTPT := XYNO;
           WRITE ('# of new points to insert = ');
           RDLNINT (EXTRA);
           WRITE ('insert points starting at # ');
           RDLNINT (STARTPT);
           WRITELN;

           FOR I := XYNO DOWNTO STARTPT DO
               FOR N := 1 TO MX DO
                   AX [N].PT [I+EXTRA] := AX [N].PT [I];
           ENDPT := STARTPT + EXTRA - 1;

           WRITE ('Automatically compute increments? (Y/N) ');
           RDCON (ANSWER);
           WRITELN;
           WRITELN;

           IF ANSWER = 'N' THEN BEGIN

           FOR I := STARTPT TO ENDPT DO
               BEGIN
               FOR N := 1 TO MX DO
                   IF AX [N].SPEC
                      THEN BEGIN
                           AX [N].PT [I] := AX [N].PT [I-1];
                           WRITE ('at new point # ', I:4, '   Axis # ', N:1, ' = ');
                           RDLNREAL (AX [N].PT [I]);
                           END;
               WRITELN;
               END;

           END    (* THEN manual inbetween *)

           ELSE BEGIN

           FOR N := 1 TO MX DO
               INCR [N] := (AX [N].PT [ENDPT+1] - AX [N].PT [STARTPT-1]) / (EXTRA+1);

           FOR I := STARTPT TO ENDPT DO
               FOR N := 1 TO MX DO
                   IF AX [N].SPEC
                      THEN AX [N].PT [I] := AX [N].PT [I-1] + INCR [N];

           END;   (* ELSE auto inbetween *)

           XYNO := XYNO + EXTRA;
           END;  (* CASE Insert *)

     'T' : BEGIN
           WRITELN ('hrow away points...');
           WRITELN;
           STARTPT := XYNO;
           ENDPT := XYNO;
           WRITE ('remove points starting at # ');
           RDLNINT (STARTPT);
           WRITE ('up to points ending at pt # ');
           RDLNINT (ENDPT);
           WRITELN;

           IF ENDPT > XYNO
              THEN ENDPT := XYNO;
           EXTRA := ENDPT - STARTPT + 1;
           FOR I := STARTPT TO (XYNO - EXTRA) DO
               FOR N := 1 TO MX DO
                   IF AX [N].SPEC
                      THEN AX [N].PT [I] := AX [N].PT [I+EXTRA];
           XYNO := XYNO - EXTRA;
           WRITELN ('Removal completed');
           WRITELN;
           END;  (* CASE Remove *)

     'M' : BEGIN
           WRITELN ('ove points around...');
           WRITELN;
           STARTPT := 1;
           ENDPT := XYNO;
           DESTN := XYNO + 1;
           WRITE ('move points starting at # ');
           RDLNINT (STARTPT);
           WRITE ('up to points ending at  # ');
           RDLNINT (ENDPT);
           WRITE ('into destination at pt  # ');
           RDLNINT (DESTN);
           WRITELN;

           IF ENDPT < STARTPT
              THEN FOR I := STARTPT DOWNTO ENDPT DO
                       BEGIN
                       FOR N := 1 TO MX DO
                           IF AX [N].SPEC
                              THEN AX [N].PT [DESTN] := AX [N].PT [I];
                       DESTN := SUCC (DESTN);
                       END
              ELSE FOR I := STARTPT TO ENDPT DO
                       BEGIN
                       FOR N := 1 TO MX DO
                           IF AX [N].SPEC
                              THEN AX [N].PT [DESTN] := AX [N].PT [I];
                       DESTN := SUCC (DESTN);
                       END;
           IF DESTN > XYNO
              THEN XYNO := PRED (DESTN);
           WRITELN ('Move completed');
           WRITELN;
           END;  (* CASE Move *)

     'O' : BEGIN
           WRITELN ('ffset existing points...');
           WRITELN;
           STARTPT := 1;
           ENDPT := XYNO;
           WRITE ('add offset to points starting at # ');
           RDLNINT (STARTPT);
           WRITE ('up to and including points at pt # ');
           RDLNINT (ENDPT);
           WRITELN;

           FOR N := 1 TO MX DO
               IF AX [N].SPEC
                  THEN BEGIN
                       ADD [N] := 0.0;
                       WRITE ('+/- Axis #', N:1, ' offset = ');
                       RDLNREAL (ADD [N]);
                       END;
           WRITELN;

           FOR I := STARTPT TO ENDPT DO
               FOR N := 1 TO MX DO
                   IF AX [N].SPEC
                      THEN AX [N].PT [I] := AX [N].PT [I] + ADD [N];

           WRITELN ('Offset completed');
           WRITELN;
           END;  (* CASE Offset *)

     'S' : BEGIN
           WRITELN ('cale existing points...');
           WRITELN;
           STARTPT := 1;
           ENDPT := XYNO;
           WRITE ('scale points starting at  # ');
           RDLNINT (STARTPT);
           WRITE ('up to and including at pt # ');
           RDLNINT (ENDPT);
           WRITELN;

           FOR N := 1 TO MX DO
               IF AX [N].SPEC
                  THEN BEGIN
                       SCALE [N] := 1.0;
                       WRITE ('+/- Axis #', N:1, ' factor = ');
                       RDLNREAL (SCALE [N]);
                       END;
           WRITELN;

           FOR I := STARTPT TO ENDPT DO
               FOR N := 1 TO MX DO
                   IF AX [N].SPEC
                      THEN AX [N].PT [I] := AX [N].PT [I] * SCALE [N];

           WRITELN ('Scaling completed');
           WRITELN;
           END;  (* CASE Scaling *)

     'H' : BEGIN
           WRITELN ('elp...');
           WRITELN;
           DISPLAY_HELP;
           END;  (* CASE Help *)

     '?' : BEGIN
           WRITELN (' -- Help...');
           WRITELN;
           DISPLAY_HELP;
           END;  (* CASE Help *)

     'Q' : BEGIN
           WRITELN ('uit Editing...');
           WRITELN;
           QUIT_EDITING := TRUE;
           END;  (* CASE Quit *)

     ELSE WRITELN;

     END;     (* CASE key input *)

UNTIL QUIT_EDITING;

END;     (* procedure EDIT PLOT *)

(* COMPUTE INCREMENT computes constant increments. *)

PROCEDURE COMPUTE_INCR;

VAR I : INTEGER;
    P : REAL;
    P_INCR : REAL;
    START_POSN : REAL;
    END_POSN : REAL;

BEGIN

   WRITELN ('Constant Increments...');
   WRITELN;

   WRITE ('Start Position = ');
   RDLNREAL (START_POSN);
   WRITE ('End   Position = ');
   RDLNREAL (END_POSN);
   WRITE ('Frame Count = ');
   RDLNINT (FRAME_COUNT);
   WRITELN;

   P_INCR := (END_POSN - START_POSN) / FRAME_COUNT;
   P := START_POSN;
   FOR I := 1 TO FRAME_COUNT+1 DO
       BEGIN
       AP [I] := P;
       P := P + P_INCR;
       END;

END;

(* COMPUTE SINE computes the sine function. *)

PROCEDURE COMPUTE_SINE;

VAR I : INTEGER;
    A : REAL;
    PHI : REAL;
    PHI_INITL : REAL;
    PHI_FINAL : REAL;
    PHI_INCR : REAL;
    RAD : REAL;

BEGIN

   WRITELN ('Sine Function...');
   WRITELN;
   WRITE ('Amplitude = ');
   RDLNREAL (A);
   WRITE ('Start Phase Angle = ');
   RDLNREAL (PHI_INITL);
   WRITE ('End   Phase Angle = ');
   RDLNREAL (PHI_FINAL);
   WRITE ('Frame Count = ');
   RDLNINT (FRAME_COUNT);
   WRITELN;

   PHI_INCR := (PHI_FINAL - PHI_INITL) / (FRAME_COUNT);
   PHI := PHI_INITL;
   FOR I := 1 TO FRAME_COUNT+1 DO
       BEGIN
       RAD := 2 * PI * (PHI / 360);
       AP [I] := A * SIN (RAD);
       PHI := PHI + PHI_INCR;
       END;

END;

(* COMPUTE EXP computes the natural exponential function. *)

PROCEDURE COMPUTE_EXP;

VAR I : INTEGER;
    K : REAL;
    A : REAL;
    T : REAL;
    T_INITL : REAL;
    T_FINAL : REAL;
    T_INCR : REAL;
    P_INITL : REAL;
    P_FINAL : REAL;
    START_POSN : REAL;
    END_POSN : REAL;

BEGIN

   WRITELN ('Exponential Function...');
   WRITELN;
   WRITE ('Start Position = ');
   RDLNREAL (START_POSN);
   WRITE ('End   Position = ');
   RDLNREAL (END_POSN);
   WRITE ('Frame Count = ');
   RDLNINT (FRAME_COUNT);
   WRITELN;

   IF START_POSN <= 0.0
      THEN P_INITL := 0.1
      ELSE P_INITL := START_POSN;
   IF END_POSN <= 0.0
      THEN P_FINAL := 0.1
      ELSE P_FINAL := END_POSN;
   T_INITL := LN (P_INITL);
   T_FINAL := LN (P_FINAL);

   T_INCR := (T_FINAL - T_INITL) / (FRAME_COUNT);
   T := T_INITL;
   FOR I := 1 TO FRAME_COUNT+1 DO
       BEGIN
       AP [I] := EXP (T);
       T := T + T_INCR;
       END;

END;

(* COMPUTE LN does Not compute the natural logarithmic function. *)
(* Instead it computes the inverse exponential function for symmetry. *)

PROCEDURE COMPUTE_LN;

VAR I : INTEGER;
    K : REAL;
    A : REAL;
    T : REAL;
    T_INITL : REAL;
    T_FINAL : REAL;
    T_INCR : REAL;
    P_INITL : REAL;
    P_FINAL : REAL;
    START_POSN : REAL;
    END_POSN : REAL;

BEGIN

   WRITELN ('Logarithmic Function...');
   WRITELN;
   WRITE ('Start Position = ');
   RDLNREAL (START_POSN);
   WRITE ('End   Position = ');
   RDLNREAL (END_POSN);
   WRITE ('Frame Count = ');
   RDLNINT (FRAME_COUNT);
   WRITELN;

   IF START_POSN <= 0.0
      THEN P_INITL := 0.1
      ELSE P_INITL := START_POSN;
   IF END_POSN <= 0.0
      THEN P_FINAL := 0.1
      ELSE P_FINAL := END_POSN;
   T_INITL := LN (P_INITL);
   T_FINAL := LN (P_FINAL);
   A := P_INITL + P_FINAL;

   T_INCR := (T_FINAL - T_INITL) / (FRAME_COUNT);
   T := T_FINAL;
   FOR I := 1 TO FRAME_COUNT+1 DO
       BEGIN
       AP [I] := A - EXP (T);
       T := T - T_INCR;
       END;

END;

PROCEDURE FUNCTION_MENU;

BEGIN

WRITELN ('Function Computation Menu:');
WRITELN;
WRITELN ('   C : Constant Increments');
WRITELN ('   S : Sine Function');
WRITELN ('   E : Exponential Function');
WRITELN ('   L : Logarithmic Function');
WRITELN ('   A : Assemble Plot');
WRITELN ('   D : Display Plot');
WRITELN ('   Q : Quit Computation');
WRITELN;

END;

PROCEDURE COMPUTE_PLOT;

VAR CH : CHAR;

BEGIN

WRITELN ('Compute Plot...');
WRITELN;

FUNCTION_MENU;

REPEAT

   WRITE ('Computing Command > ');
   RDKEY (CH);
   CASE CH OF
        'C' : COMPUTE_INCR;
        'S' : COMPUTE_SINE;
        'E' : COMPUTE_EXP;
        'L' : COMPUTE_LN;
        'A' : ASSEMBLE_PLOT;
        'D' : DISPLAY_PLOT;
        '?' : FUNCTION_MENU;
        'H' : FUNCTION_MENU;
        'Q' : WRITELN ('Quit Computing...');
        ELSE  WRITELN (CH);
        END;

UNTIL CH = 'Q';
WRITELN;

END;

(* SPLINED INTERPOLATION uses cubic splining to interpolate the existing plot. *)

PROCEDURE SPLINED_INTERPOLATION;

TYPE PLOTARRAY = ARRAY [1..MAXSPLINE, 1..2] OF REAL;

VAR CH : CHAR;
    I : INTEGER;
    N : INTEGER;
    ND : INTEGER;
    NS : INTEGER;
    DP : PLOTARRAY;
    SP : PLOTARRAY;

PROCEDURE ERROR (PROC, CODE : INTEGER);

BEGIN

   WRITELN ('ERROR # ', CODE, ' in procedure # ', PROC);

END;

procedure spline(A:PlotArray;
                 N:integer;
                 X1,XM:real;
                 var B:PlotArray;
                 M:integer);
  (* const MaxSpline=50; *)
  type Vector = array [1..MaxSpline] of real;
  var x,y,z:Vector;
      i:integer;
      DeltaX:real;

  procedure stg(Vector1,Vector2,Vector3:Vector;
                var Vector4:Vector;
                NPts:integer);
    var i:integer;
        Factor:real;

    begin
      for i:=2 to NPts do
       begin
        Factor:=Vector1[i-1]/Vector2[i-1];
        Vector2[i]:=Vector2[i]-Factor*Vector3[i-1];
        Vector4[i]:=Vector4[i]-Factor*Vector4[i-1];
       end;
      Vector4[NPts]:=Vector4[NPts]/Vector2[NPts];
      for i:=1 to NPts-1 do
        Vector4[NPts-i]:=(Vector4[NPts-i]-Vector3[NPts-i]*Vector4[NPts-i+1]) /
                         Vector2[NPts-i];
    end;

  procedure sc(X,Y:Vector;
               var Z:Vector;
               NPts:integer);
    var i:integer;
        D,C:Vector;

    begin
      D[1]:=1.0;
      C[1]:=0.5;
      Z[1]:=0.5;
      for i:=2 to NPts-1 do
       begin
        D[i]:=2.0*(X[i+1]-X[i-1]);
        C[i]:=X[i+1]-X[i];
        Z[i]:=6.0*((Y[i+1]-Y[i])/(X[i+1]-X[i])-(Y[i]-Y[i-1])/(X[i]-X[i-1]));
       end;
      D[NPts]:=1.0;
      C[NPts-1]:=0.0;
      C[NPts]:=0.0;
      Z[NPts]:=0.0;
      stg(C,D,C,Z,NPts);
    end;

  function si(V:real;
              X,Y,Z:Vector;
              NPts:integer):real;
    var i,j:integer;
        dummy,ai,hi:real;

    begin
      if (V>X[1]) and (V<X[NPts]) then
       begin
        j:=1;
        repeat
          j:=j+1;
          i:=NPts-j;
          dummy:=V-X[i];
        until (dummy>=0.0) or (i=2);
        hi:=X[i+1]-X[i];
        ai:=dummy*(Z[i+1]-Z[i])/(6.0*hi)+0.5*Z[i];
        ai:=dummy*ai+(Y[i+1]-Y[i])/hi-hi*(2.0*Z[i]+Z[i+1])/6.0;
        si:=dummy*ai+Y[i];
       end
      else if V=X[1] then si:=Y[1]
      else si:=Y[NPts];
    end;

  procedure sia(X,Y:Vector;
                NPts:integer;
                XInt:Vector;
                var YInt:Vector;
                N:integer);
    var i:integer;
        V3:Vector;

    begin
      sc(X,Y,V3,NPts);
      for i:=1 to N do YInt[i]:=si(XInt[i],X,Y,V3,NPts);
    end;

  begin { Spline }
    if (abs(N)>=2) and (abs(M)>=2) then
     begin
      if ((X1>=A[1,1]) and (XM<=A[N,1])) and (M>=2) then
       begin
        DeltaX:=(XM-X1)/(M-1);
        for i:=1 to N do
         begin
          X[i]:=A[i,1];
          Y[i]:=A[i,2];
         end;
        for i:=2 to M-1 do Z[i]:=X1+(i-1)*DeltaX;
        Z[1]:=X1;
        Z[M]:=XM;
        sia(X,Y,N,Z,Y,M);
        for i:=1 to M do
         begin
          B[i,1]:=Z[i];
          B[i,2]:=Y[i];
         end;
       end
      else error(20,7);
     end
    else error(20,4);
  end;

PROCEDURE SPLINE_AXIS;

BEGIN

   FOR I := 2 TO ND-1 DO
       BEGIN
       DP [I,1] := I;
       DP [I,2] := AP [I-1];
       END;

   DP [1,1] := 1;
   DP [1,2] := AP [1] - (AP [2] - AP [1]);

   DP [ND,1] := ND;
   DP [ND,2] := AP [ND-2] + (AP [ND-2] - AP [ND-3]);

   SPLINE (DP, ND, DP [2,1], DP [ND-1,1], SP, NS);

   FOR I := 1 TO NS DO
       AP [I] := SP [I,2];

END;

BEGIN

   WRITELN ('Splined Interpolations...');
   WRITELN;

   ND := XYNO + 2;
   WRITE ('Number of Splined Points = ');
   RDLNINT (NS);
   WRITELN;

   IF NS > 0
      THEN BEGIN
      FOR N := 1 TO MX DO
          IF AX [N].SPEC
             THEN BEGIN
                  FOR I := 1 TO ND-2 DO
                      AP [I] := AX [N].PT [I];
                  SPLINE_AXIS;
                  FOR I := 1 TO NS DO
                      AX [N].PT [I] := AP [I];
                  END;

      XYNO := NS;
      END;

END;

(* LINEAR INTERPOLATION linearly interpolates an integral number of points. *)

PROCEDURE LINEAR_INTERPOLATION;

VAR N : INTEGER;
    I : INTEGER;
    J : INTEGER;
    K : INTEGER;
    INCR : REAL;

BEGIN

   WRITELN ('Linear Interpolations...');
   WRITELN;

   WRITE ('Frame Count Multiplier = ');
   RDLNINT (K);
   WRITELN;

   FOR N := 1 TO MX DO
       IF AX [N].SPEC
          THEN BEGIN
               AP [1] := AX [N].PT [1];
               FOR I := 1 TO (XYNO-1) DO
                   BEGIN
                   INCR := (AX [N].PT [I+1] - AX [N].PT [I]) / K;
                   FOR J := 1 TO K DO
                       AP [K*(I-1) + J + 1] := AX [N].PT [I] + J*INCR;
                   END;
               AP [K*(XYNO-1)+1] := AX [N].PT [XYNO];
               FOR I := 1 TO (K*(XYNO-1)+1) DO
                   AX [N].PT [I] := AP [I];
               END;

   XYNO := K * (XYNO - 1) + 1;

END;

(* LINEAR REDUCTION linearly reduces the plot by an integral number. *)

PROCEDURE LINEAR_REDUCTION;

VAR N : INTEGER;
    I : INTEGER;
    K : INTEGER;

BEGIN

   WRITELN ('Reduced Plot...');
   WRITELN;

   WRITE ('Frame Count Reduction Factor = ');
   RDLNINT (K);
   WRITELN;

   FOR N := 1 TO MX DO
       IF AX [N].SPEC
          THEN BEGIN
               AP [1] := AX [N].PT [1];
               FOR I := 1 TO (XYNO DIV K) DO
                   AP [I+1] := AX [N].PT [(K*I)+1];
               AP [(XYNO DIV K)+1] := AX [N].PT [XYNO];
               FOR I := 1 TO ((XYNO DIV K)+1) DO
                   AX [N].PT [I] := AP [I];
               END;

   XYNO := (XYNO DIV K) + 1;

END;

(* TAPERED INTERPOLATION computes sinusoidal tapering at the plot's ends. *)

PROCEDURE TAPERED_INTERPOLATION;

VAR N : INTEGER;
    I : INTEGER;
    J : INTEGER;
    S : INTEGER;
    E : INTEGER;

    PHI : REAL;
    RAD : REAL;
    PHI_INCR : REAL;
    INITL_INCR_MAX : REAL;
    FINAL_INCR_MAX : REAL;
    DELTA : REAL;
    SCALE : REAL;
    INITL_PT : REAL;
    FINAL_PT : REAL;
    INITL_OFFSET : REAL;
    FINAL_OFFSET : REAL;

BEGIN

   WRITELN ('Tapered Interpolations...');
   WRITELN;

   WRITE ('Taper-In Frame Count = ');
   RDLNINT (S);
   IF S >= XYNO
      THEN S := XYNO - 1;
   WRITE ('Taper-Out Frame Count = ');
   RDLNINT (E);
   IF (S + E) >= XYNO
      THEN E := XYNO - S;
   WRITELN;

   FOR N := 1 TO MX DO
       IF AX [N].SPEC
          THEN BEGIN
               FOR I := 1 TO XYNO DO
                   AP [I] := AX [N].PT [I];
               INITL_PT := AP [1];
               FINAL_PT := AP [XYNO];

               PHI_INCR := 90.0 / (S+1);
               PHI := 90.0 - PHI_INCR;
               FOR J := S DOWNTO 1 DO
                   BEGIN
                   RAD := 2 * PI * (PHI / 360);
                   DELTA := AP [J+1] - AP [J];
                   AP [J] := AP [J+1] - (DELTA * SIN (RAD));
                   PHI := PHI - PHI_INCR;
                   END;

               PHI_INCR := 90.0 / (E+1);
               PHI := 90.0 - PHI_INCR;
               FOR J := (XYNO-E+1) TO (XYNO) DO
                   BEGIN
                   RAD := 2 * PI * (PHI / 360);
                   DELTA := AP [J] - AP [J-1];
                   AP [J] := AP [J-1] + (DELTA * SIN (RAD));
                   PHI := PHI - PHI_INCR;
                   END;

               INITL_OFFSET := AP [1];
               FOR I := 1 TO XYNO DO
                   AP [I] := AP [I] - INITL_OFFSET;
               SCALE := (FINAL_PT - INITL_PT) / AP [XYNO];
               FOR I := 1 TO XYNO DO
                   AP [I] := AP [I] * SCALE;
               FINAL_OFFSET := INITL_PT;
               FOR I := 1 TO XYNO DO
                   AP [I] := AP [I] + FINAL_OFFSET;

               FOR I := 1 TO XYNO DO
                   AX [N].PT [I] := AP [I];
               END;

END;

(* INTERPOLATE POINTS allows for different interpolated point values. *)

PROCEDURE INTERPOLATE_POINTS;

VAR CH : CHAR;

PROCEDURE INTERPOLATION_MENU;

BEGIN

   WRITELN ('Interpolation Menu:');
   WRITELN;
   WRITELN ('   L : Linear Interpolations');
   WRITELN ('   S : Splined Interpolations');
   WRITELN ('   T : Tapered Interpolations');
   WRITELN ('   R : Reduced Plot');
   WRITELN ('   D : Display Plot');
   WRITELN ('   Q : Quit Interpolation');
   WRITELN;

END;

BEGIN

   WRITELN ('Interpolate Points...');
   WRITELN;
   INTERPOLATION_MENU;

   REPEAT

   WRITE ('Interpolation Command > ');
   RDKEY (CH);
   CASE CH OF
        'L' : LINEAR_INTERPOLATION;
        'S' : SPLINED_INTERPOLATION;
        'T' : TAPERED_INTERPOLATION;
        'R' : LINEAR_REDUCTION;
        'D' : DISPLAY_PLOT;
        '?' : INTERPOLATION_MENU;
        'H' : INTERPOLATION_MENU;
        'Q' : WRITELN ('Quit Interpolating...');
        ELSE  WRITELN (CH);
        END;

   UNTIL CH = 'Q';
   WRITELN;

END;

(* FOLLOW FOCUS CONVERSION computes the follow-focus conversion for a
(* selected axis originally specified in terms of focussing distances. *)

PROCEDURE FOLLOW_FOCUS_CONVERSION;

VAR FF : REAL;                    (* focal length *)
    K_F : REAL;                   (* F axis units --> steps conversion *)

    O_REF : REAL;                 (* object reference position *)
    I_REF : REAL;                 (* image reference position *)
    M_REF : REAL;                 (* magnification reference ratio *)
    Z_REF : REAL;                 (* Z axis reference focussing distance *)
    F_REF : REAL;                 (* F axis reference lens distance *)

    Z : REAL;                     (* Z axis focussing distance *)
    F : REAL;                     (* F axis lens distance *)

    I : INTEGER;
    N : INTEGER;

PROCEDURE COMPUTE_FOLLOW_FOCUS;

VAR I : REAL;

BEGIN

   IF Z < 4 * FF
      THEN I := 2 * FF
      ELSE I := (Z - SQRT (SQR (Z) - 4 * Z * FF)) / 2;

   F := -1.0 * K_F * (I - I_REF);

END;

BEGIN

   WRITELN ('Follow Focus Conversion...');
   WRITELN;

   FF := 50.0;
   WRITE ('Lens Focal Length  = ');
   READLN (FF);

   K_F := 1.0;
   WRITE ('Lens Conversion Units = ');
   READLN (K_F);

   Z_REF := 1000.0;
   WRITE ('Reference Focussing Distance = ');
   READLN (Z_REF);
   WRITELN;

   IF Z_REF < 4 * FF
      THEN I_REF := 2 * FF
      ELSE I_REF := (Z_REF - SQRT (SQR (Z_REF) - 4 * Z_REF * FF)) / 2;

   WRITE ('convert axis # ');
   RDLNINT (N);
   WRITELN;

   IF N IN [1..MX]
      THEN FOR I := 1 TO XYNO DO
               BEGIN
               Z := AX [N].PT [I];
               COMPUTE_FOLLOW_FOCUS;
               AX [N].PT [I] := F;
               END;

END;

PROCEDURE PROGRAM_MENU;

BEGIN

WRITELN ('Plotter Program Menu:');
WRITELN;
WRITELN ('   C : Compute Functions');
WRITELN ('   I : Interpolate Points');
WRITELN ('   F : Follow Focus');
WRITELN ('   E : Edit plot');
WRITELN ('   D : Display plot');
WRITELN ('   S : Save plot onto disk');
WRITELN ('   L : Load plot from disk');
WRITELN ('   A : Active Axes');
WRITELN ('   Q : Quit program');
WRITELN;

END;

BEGIN

WRITELN;
WRITELN ('Point Plotter Function Computations');
WRITELN;

ACTIVE_AXES;

INIT_PLOT;

PROGRAM_MENU;

REPEAT

   WRITE ('Plotting Command > ');
   RDKEY (CH);
   CASE CH OF
        'C' : COMPUTE_PLOT;
        'I' : INTERPOLATE_POINTS;
        'F' : FOLLOW_FOCUS_CONVERSION;
        'E' : EDIT_PLOT;
        'D' : DISPLAY_PLOT;
        'S' : SAVE_PLOT;
        'L' : LOAD_PLOT;
        'A' : ACTIVE_AXES;
        '?' : PROGRAM_MENU;
        'H' : PROGRAM_MENU;
        'Q' : WRITE ('Quitting time...');
        ELSE  WRITELN (CH);
        END;

   IF CH = 'Q'
      THEN BEGIN
           WRITE ('for sure? ');
           RDCON (CH);
           WRITELN;
           WRITELN;
           IF CH = 'Y' THEN CH := 'Q';
           END;

UNTIL CH = 'Q';

END.
