
(* TAPER TEST performs a simulation of ANIMAL tapers. *)

(* Error compensation is performed by summing through the tapered intervals.
(* Therefore either linear or sinusoidal tapering may be corrected. *)

PROGRAM TAPER_TEST;

CONST FWD = TRUE;
      REV = FALSE;

TYPE AXIS = RECORD
        MOTORNO : INTEGER;
        STEPCNT : REAL;
        DIR : BOOLEAN;
        SPEED : INTEGER;
        ACCELST : BOOLEAN;
        HIGHSPD : INTEGER;
        LOWSPD : INTEGER;
        RAMPCNT : INTEGER;
        RAMPK : INTEGER;
        END;

     PARAMETER_TABLE = RECORD
          SPEC : BOOLEAN;
          START_FRAME : INTEGER;
          END_FRAME : INTEGER;

          START_PT : REAL;
          END_PT : REAL;
          INCR_PT : REAL;
          CUR_PT : REAL;

          TAPER : BOOLEAN;
          MOVETYPE : ARRAY [1..3] OF CHAR;
          ACCEL : REAL;
          KONST : REAL;
          DECEL : REAL;

          STREAK : BOOLEAN;
          INITL_SIZE : REAL;
          FINAL_SIZE : REAL;
          DELTA_SIZE : REAL;
          CUR_SIZE : REAL;
          END;

     CONVERSION_TABLE = RECORD
          KSCALE : REAL;
          DP : INTEGER;
          CUR_STEP : REAL;
          CUR_POSN : REAL;
          UNITS : STRING [15];
          END;

     COUNT_TABLE = RECORD
          AXISNO : INTEGER;
          COUNT : REAL;
          STAT : CHAR;
          ERROR : BOOLEAN;
          END;

     RUN_PROFILE = RECORD
          ACCEL : BOOLEAN;
          MIN_SPEED : INTEGER;
          MAX_SPEED : INTEGER;
          MIN_LOWSPD : INTEGER;
          MAX_HIGHSPD : INTEGER;
          MAX_RAMPCNT : INTEGER;
          END;

     EXECUTION_TABLE = RECORD
          START_STP : REAL;
          END_STP : REAL;
          INCR_STP : REAL;
          CUR_STP : REAL;

          FRAME_COUNT : INTEGER;
          ACCEL_FRAME : INTEGER;
          KONST_FRAME : INTEGER;
          DECEL_FRAME : INTEGER;
          INCR_MAX : REAL;

          INITL_CNT : REAL;
          FINAL_CNT : REAL;
          DELTA_CNT : REAL;
          CUR_CNT : REAL;
          END;

     HOME_TABLE = RECORD
          DIR : BOOLEAN;
          HOMECNT : INTEGER;
          MIN_CNT : INTEGER;
          MAX_CNT : INTEGER;
          END;

     AXIS_TABLE = RECORD
          SPEC : BOOLEAN;
          ID : ARRAY [1..2] OF CHAR;
          M : AXIS;
          P : PARAMETER_TABLE;
          K : CONVERSION_TABLE;
          C : COUNT_TABLE;
          R : RUN_PROFILE;
          X : EXECUTION_TABLE;
          H : HOME_TABLE;
          END;

VAR CH : CHAR;
    I : INTEGER;
    XYNO : INTEGER;

    FRAME_COUNT : INTEGER;
    EXPOSURE_TIME : REAL;
    PRESET_COUNT : INTEGER;
    FRAME_STEP : INTEGER;

    AX1X : AXIS_TABLE;

    AX1P : ARRAY [1..1024] OF REAL;

(* RDCON reads a character from the console (with echo). *)

PROCEDURE RDCON (VAR CH : CHAR);

BEGIN

   READ (TRM, CH);

END;

(* CONVERT converts user defined units into steps. *)

PROCEDURE CONVERT (VAR X : REAL; K : REAL; VAR Y : REAL);

VAR T : REAL;

BEGIN

   Y := X / K;

END;

(* RECONVERT reconverts steps into user-defined units. *)

PROCEDURE RECONVERT (VAR X : REAL; K : REAL; VAR Y : REAL);

BEGIN

   Y := K * X;

END;

(* UPDATE updates the current MCPU axis step count into the
(* corresponding ANIMAL parameter. *)

PROCEDURE UPDATE (VAR A : AXIS_TABLE);

BEGIN

   A.K.CUR_STEP := A.C.COUNT;
   RECONVERT (A.K.CUR_STEP, A.K.KSCALE, A.K.CUR_POSN);

END;

(* PREPM prepares a motor step count for output to the MCPU. *)

PROCEDURE PREPM (VAR M : AXIS);

BEGIN

   IF M.STEPCNT < 0
      THEN M.DIR := REV
      ELSE M.DIR := FWD;

   M.STEPCNT := ABS (M.STEPCNT);

END;

(* ASSIGN DATA assigns the desired ANIMAL Stop Motion parameters. *)

PROCEDURE ASSIGN_DATA (VAR A : AXIS_TABLE);

BEGIN

   WRITE ('Frame Count = ');
   READLN (FRAME_COUNT);
   WRITELN;
   PRESET_COUNT := FRAME_COUNT;
   FRAME_STEP := 1;

   A.P.SPEC := TRUE;
   WRITE ('Start Frame = ');
   READLN (A.P.START_FRAME);
   WRITE ('End Frame = ');
   READLN (A.P.END_FRAME);
   WRITELN;

   WRITE ('Start Position = ');
   READLN (A.P.START_PT);
   WRITE ('End Position = ');
   READLN (A.P.END_PT);
   WRITELN;

   WRITE ('% Taper In = ');
   READLN (A.P.ACCEL);
   WRITE ('% Taper Out = ');
   READLN (A.P.DECEL);
   WRITELN;
   A.P.KONST := 100.0 - (A.P.ACCEL + A.P.DECEL);
   A.P.TAPER := (A.P.KONST < 100.0);

END;

(* INIT DATA initializes ANIMAL data records for effecting
(* the conversion process (by way of simulation). *)

PROCEDURE INIT_DATA (VAR A : AXIS_TABLE);

BEGIN

   A.K.KSCALE := 1.0;
   IF A.SPEC
      THEN A.K.CUR_POSN := A.P.START_PT
      ELSE A.K.CUR_POSN := 0.0;
   CONVERT (A.K.CUR_POSN, A.K.KSCALE, A.K.CUR_STEP);

   A.M.STEPCNT := 0.0;
   A.C.COUNT := A.K.CUR_STEP;

END;

(* SIMULATE simulates the ANIMAL run-time activity as if it were
(* sequencing moves through an MCPU, by updating MCPU step counts. *)

PROCEDURE SIMULATE (VAR A : AXIS_TABLE);

BEGIN

   IF A.M.DIR = FWD
      THEN A.C.COUNT := A.C.COUNT + A.M.STEPCNT
      ELSE A.C.COUNT := A.C.COUNT - A.M.STEPCNT;

END;

(* PRE-COMPUTE pre-computes the initial incremental step count
(* for the first frame of a Stop Motion sequence. *)

PROCEDURE PRE_COMPUTE (VAR A : AXIS_TABLE);

VAR AXIS_INCR : INTEGER;
    AXIS_FRAME : INTEGER;
    AREA : REAL;
    AREA_ACCEL : REAL;
    AREA_KONST : REAL;
    AREA_DECEL : REAL;
    AREA_TOTAL : REAL;
    N : INTEGER;

BEGIN

   AXIS_FRAME := A.P.END_FRAME - A.P.START_FRAME;
   AXIS_INCR := AXIS_FRAME DIV FRAME_STEP;
   IF AXIS_INCR =  0
      THEN A.P.INCR_PT := 0.0
      ELSE A.P.INCR_PT := (A.P.END_PT - A.P.START_PT) / (AXIS_INCR);
   CONVERT (A.P.INCR_PT, A.K.KSCALE, A.X.INCR_STP);

   IF A.P.TAPER
      THEN BEGIN
           A.X.FRAME_COUNT := A.P.END_FRAME - A.P.START_FRAME;
           A.X.ACCEL_FRAME := ROUND (A.P.ACCEL * A.X.FRAME_COUNT / 100);
           A.X.DECEL_FRAME := ROUND (A.P.DECEL * A.X.FRAME_COUNT / 100);
           A.X.KONST_FRAME := A.X.FRAME_COUNT - (A.X.ACCEL_FRAME + A.X.DECEL_FRAME);

           AREA_ACCEL := 0.0;
           IF A.X.ACCEL_FRAME > 0
              THEN FOR N := 1 TO A.X.ACCEL_FRAME DO
                       AREA_ACCEL := AREA_ACCEL + N / A.X.ACCEL_FRAME;
           AREA_DECEL := 0.0;
           IF A.X.DECEL_FRAME > 0
              THEN FOR N := 1 TO A.X.DECEL_FRAME DO
                       AREA_DECEL := AREA_DECEL + N / A.X.DECEL_FRAME;
           AREA_KONST := A.X.KONST_FRAME;
           AREA_TOTAL := AREA_ACCEL + AREA_KONST + AREA_DECEL;

           A.X.INCR_MAX := (A.P.END_PT - A.P.START_PT) / AREA_TOTAL;

           IF A.X.ACCEL_FRAME = 0
              THEN A.P.INCR_PT := A.X.INCR_MAX
              ELSE A.P.INCR_PT := (1 / A.X.ACCEL_FRAME) * A.X.INCR_MAX;
           CONVERT (A.P.INCR_PT, A.K.KSCALE, A.X.INCR_STP);
           END;

   A.M.STEPCNT := A.X.INCR_STP;
   PREPM (A.M);

   A.P.CUR_PT := A.P.START_PT;
   CONVERT (A.P.CUR_PT, A.K.KSCALE, A.X.CUR_STP);

END;

(* COMPUTE computes the incremental step count for the current frame. *)

PROCEDURE COMPUTE (VAR A : AXIS_TABLE);

VAR INCR_REMAINING : INTEGER;
    AXIS_FRAME_COUNT : INTEGER;

(* COMPUTE TAPER computes the current tapered increment. *)
(* Error compensation occurs during the constant incrementation phase. *)
(* Increased accuracy available from Max Increment Size as real number. *)

PROCEDURE COMPUTE_TAPER;

VAR TAPER_COUNT : INTEGER;
    TAPER_FRAME : INTEGER;
    EFF_INCR_PT : REAL;
    EFF_END_PT : REAL;
    EFF_INCR_REMAINING : INTEGER;
    ADJ_AREA : REAL;
    ADJ_INCR : REAL;
    N : INTEGER;

BEGIN

IF AXIS_FRAME_COUNT > (A.X.FRAME_COUNT - A.X.ACCEL_FRAME)
   THEN BEGIN
        TAPER_COUNT := AXIS_FRAME_COUNT - (A.X.FRAME_COUNT - A.X.ACCEL_FRAME);
        TAPER_FRAME := A.X.ACCEL_FRAME - TAPER_COUNT + 1;
        IF A.X.ACCEL_FRAME = 0
           THEN A.P.INCR_PT := A.X.INCR_MAX
           ELSE A.P.INCR_PT := (TAPER_FRAME / A.X.ACCEL_FRAME) * A.X.INCR_MAX;
        END   (* acceleration taper in *)

ELSE IF AXIS_FRAME_COUNT <= A.X.DECEL_FRAME
   THEN BEGIN
        TAPER_FRAME := AXIS_FRAME_COUNT;
        IF A.X.DECEL_FRAME = 0
           THEN A.P.INCR_PT := A.X.INCR_MAX
           ELSE A.P.INCR_PT := (TAPER_FRAME / A.X.DECEL_FRAME) * A.X.INCR_MAX;
        END   (* deceleration taper out *)

{ELSE A.P.INCR_PT := A.X.INCR_MAX;}

ELSE BEGIN
     ADJ_AREA := 0.0;
     IF A.X.DECEL_FRAME > 0
        THEN FOR N := 1 TO A.X.DECEL_FRAME DO
                 ADJ_AREA := ADJ_AREA + N / A.X.DECEL_FRAME;
     EFF_END_PT := A.P.END_PT - (ADJ_AREA * A.X.INCR_MAX);

     TAPER_COUNT := AXIS_FRAME_COUNT - A.X.DECEL_FRAME;
     EFF_INCR_REMAINING := TAPER_COUNT DIV FRAME_STEP;
     IF EFF_INCR_REMAINING = 0
        THEN EFF_INCR_PT := A.X.INCR_MAX
        ELSE EFF_INCR_PT := (EFF_END_PT - A.P.CUR_PT) / EFF_INCR_REMAINING;
     A.P.INCR_PT := EFF_INCR_PT;
     END;   (* constant incrementation *)

END;

BEGIN

A.P.CUR_PT := A.K.CUR_POSN;

IF (FRAME_COUNT < A.P.START_FRAME)
OR (FRAME_COUNT > A.P.END_FRAME)
   THEN A.P.INCR_PT := 0
   ELSE BEGIN
        AXIS_FRAME_COUNT := A.P.END_FRAME - FRAME_COUNT;
        INCR_REMAINING := AXIS_FRAME_COUNT DIV FRAME_STEP;
        IF INCR_REMAINING = 0
           THEN A.P.INCR_PT := 0
           ELSE IF A.P.TAPER
                   THEN COMPUTE_TAPER
                   ELSE A.P.INCR_PT := (A.P.END_PT - A.P.CUR_PT) / INCR_REMAINING;
        END;

{CONVERT (A.P.INCR_PT, A.K.KSCALE, A.X.INCR_STP);}
{A.M.STEPCNT := A.X.INCR_STP;}

A.P.CUR_PT := A.P.CUR_PT + A.P.INCR_PT;
CONVERT (A.P.CUR_PT, A.K.KSCALE, A.X.CUR_STP);

A.M.STEPCNT := A.X.CUR_STP - A.K.CUR_STEP;
PREPM (A.M);

END;


BEGIN     (* TAPER TEST *)

WRITELN;
WRITELN ('ANIMAL Taper Simulation...');
WRITELN;

REPEAT

   ASSIGN_DATA (AX1X);

   INIT_DATA (AX1X);

   AX1P [1] := AX1X.K.CUR_STEP;

   PRE_COMPUTE (AX1X);

   WRITELN (0:10, AX1P [1]:20:3);

   I := 2;
   FRAME_COUNT := 0;
   REPEAT

      COMPUTE (AX1X);

      SIMULATE (AX1X);

      UPDATE (AX1X);

      AX1P [I] := AX1X.K.CUR_STEP;

      WRITELN ((I-1):10, AX1P [I]:20:3, (AX1P [I] - AX1P [I-1]):20:3);

      I := SUCC (I);
      FRAME_COUNT := FRAME_COUNT + FRAME_STEP;

   UNTIL FRAME_COUNT >= PRESET_COUNT;
   XYNO := PRED (I);

   WRITELN;
   WRITE ('Continue? ');
   READLN (CH);
   WRITELN;

UNTIL CH = 'N';

END.
