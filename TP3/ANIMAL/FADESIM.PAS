
(* FADE SIMULATION performs a simulation of ANIMAL fades. *)

PROGRAM FADE_SIMULATION;

CONST FWD = TRUE;
      REV = FALSE;

      MAX_ANGLE = 170.0;
      STD_EXP_TIME = 0.24;

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
    DISPLAY : BOOLEAN;

    FRAME_COUNT : INTEGER;
    EXPOSURE_TIME : REAL;
    PRESET_COUNT : INTEGER;
    FRAME_STEP : INTEGER;

    FADE : BOOLEAN;
    FADE_LENGTH : INTEGER;
    FADEIN : BOOLEAN;
    FADELOG : BOOLEAN;
    FADE_EXP : BOOLEAN;
    FADE_SHTR : BOOLEAN;
    MIN_EXP : REAL;
    MAX_EXP : REAL;
    EXP_INCR : REAL;
    SHTR_INCR : REAL;
    EXP_COUNT : INTEGER;
    SHTR_COUNT : INTEGER;
    SHUTTER_ANGLE : REAL;
    FADE_COUNT : INTEGER;
    LOG_INCR : REAL;
    FSTOPS : REAL;
    NSTOPS : REAL;

    XC : AXIS_TABLE;

(* RDCON reads a character from the console (with echo). *)

PROCEDURE RDCON (VAR CH : CHAR);

BEGIN

   READ (KBD, CH);
   WRITE (CH);

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

(* SIMULATE simulates the ANIMAL run-time activity as if it were
(* sequencing moves through an MCPU, by updating MCPU step counts. *)

PROCEDURE SIMULATE (VAR A : AXIS_TABLE);

BEGIN

   IF A.M.DIR = FWD
      THEN A.C.COUNT := A.C.COUNT + A.M.STEPCNT
      ELSE A.C.COUNT := A.C.COUNT - A.M.STEPCNT;

END;

(* RUNM simulates running the variable shutter axis. *)

PROCEDURE RUNM (VAR A : AXIS);

BEGIN

   SIMULATE (XC);

END;

(* GETCOUNT simulates getting the variable shutter axis step count. *)

PROCEDURE GETCOUNT (VAR C : COUNT_TABLE);

BEGIN

END;

PROCEDURE WAITOVER;

BEGIN

END;

(* ASSIGN DATA assigns the desired ANIMAL Stop Motion parameters. *)

PROCEDURE ASSIGN_DATA (VAR A : AXIS_TABLE);

BEGIN

   WRITE ('Frame Count = ');
   READLN (FRAME_COUNT);
   PRESET_COUNT := FRAME_COUNT;
   FRAME_STEP := 1;
   FADE_LENGTH := FRAME_COUNT;

   WRITE ('Exposure Time = ');
   READLN (EXPOSURE_TIME);

   WRITE ('Fade In / Out ? ');
   RDCON (CH);
   WRITELN;
   FADEIN := (CH = 'I');

   WRITE ('Linear or Log ? ');
   RDCON (CH);
   WRITELN;
   FADELOG := (CH = 'G');
   IF FADELOG
      THEN BEGIN
           WRITE ('Number of f/stops = ');
           READLN (NSTOPS);
           END;
   WRITELN;

END;

(* INIT DATA initializes ANIMAL data records for effecting
(* the conversion process (by way of simulation). *)

PROCEDURE INIT_DATA (VAR A : AXIS_TABLE);

BEGIN

   A.K.KSCALE := 1.0;
   A.K.CUR_POSN := 0.0;
   CONVERT (A.K.CUR_POSN, A.K.KSCALE, A.K.CUR_STEP);

   A.M.STEPCNT := 0.0;
   A.C.COUNT := A.K.CUR_STEP;

END;

(****)

(* LOG 2 computes the logarithm to the base of 2. *)

PROCEDURE LOG_2 (VAR X : REAL; VAR Y : REAL);

BEGIN

   Y := LN (X) / LN (2.0);

END;

(* POWER 2 computes the power of the base of 2. *)

PROCEDURE POWER_2 (VAR X : REAL; VAR Y : REAL);

BEGIN

   Y := EXP (X * LN (2.0));

END;

(* VARIABLE SHUTTER runs the variable shutter to the selected angle. *)

PROCEDURE VARIABLE_SHUTTER (ANGLE : REAL);

VAR STEPS : REAL;

BEGIN

   IF ANGLE < 0.0
      THEN ANGLE := 0.0
   ELSE IF ANGLE > MAX_ANGLE
      THEN ANGLE := MAX_ANGLE;

   CONVERT (ANGLE, XC.K.KSCALE, STEPS);
   GETCOUNT (XC.C);

   XC.M.STEPCNT := STEPS - XC.C.COUNT;
   PREPM (XC.M);
   RUNM (XC.M);

END;

(* COMPUTE ANGLE computes the variable shutter angle for an exposure time. *)

PROCEDURE COMPUTE_SHUTTER_ANGLE;

BEGIN

   SHUTTER_ANGLE := 360.0 * (EXPOSURE_TIME / 0.5);

END;

(* COMPUTE EXPOSURE computes the incremental exposure time during a fade. *)

PROCEDURE COMPUTE_EXPOSURE_TIME;

BEGIN

   IF FADELOG
      THEN BEGIN
           FADE_COUNT := FADE_COUNT + FRAME_STEP;
           IF FADEIN
              THEN EXP_INCR := FADE_COUNT / FADE_LENGTH
              ELSE EXP_INCR := 1.0 - FADE_COUNT / FADE_LENGTH;
           EXP_INCR := EXP_INCR * NSTOPS;
           POWER_2 (EXP_INCR, LOG_INCR);
           POWER_2 (NSTOPS, FSTOPS);
           LOG_INCR := LOG_INCR / FSTOPS;
           IF FADEIN
              THEN EXPOSURE_TIME := MAX_EXP * LOG_INCR
              ELSE EXPOSURE_TIME := MAX_EXP * LOG_INCR;
           IF (FADE_COUNT = FADE_LENGTH) AND NOT FADEIN
              THEN EXPOSURE_TIME := 0.0;
           END

      ELSE IF FADEIN
              THEN EXPOSURE_TIME := EXPOSURE_TIME + EXP_INCR
              ELSE EXPOSURE_TIME := EXPOSURE_TIME - EXP_INCR;

END;

(* PRE-COMPUTE FADE pre-computes the exposure time and shutter angle data
(* for either the desired fade-in or fade-out sequence, and initializes
(* the variable shutter position accordingly. *)

PROCEDURE PRE_COMPUTE_FADE;

VAR STEPS : REAL;

BEGIN

   MAX_EXP := EXPOSURE_TIME;
   MIN_EXP := STD_EXP_TIME;

   EXP_INCR := MAX_EXP / FADE_LENGTH;
   FADE_COUNT := 0;

   IF FADEIN
      THEN BEGIN
           FADE_EXP := FALSE;
           FADE_SHTR := TRUE;

           EXPOSURE_TIME := 0.0;
           SHUTTER_ANGLE := 0.0;

           VARIABLE_SHUTTER (0.0);

           IF DISPLAY THEN WRITELN ('Closing Variable Shutter...');
           IF DISPLAY THEN WRITELN;
           END         (* Fade In *)

      ELSE BEGIN
           FADE_EXP := TRUE;
           FADE_SHTR := FALSE;

           EXPOSURE_TIME := MAX_EXP;
           SHUTTER_ANGLE := MAX_ANGLE;

           VARIABLE_SHUTTER (MAX_ANGLE);

           IF DISPLAY THEN WRITELN ('Opening Variable Shutter...');
           IF DISPLAY THEN WRITELN;
           END;        (* Fade Out *)

END;

(* FADE IT runs through the fade-in or fade-out sequence, incrementing
(* either the exposure time or shutter angle according to frame number. *)

PROCEDURE FADEIT;

VAR STEPS : REAL;

BEGIN

   IF FADEIN
      THEN BEGIN
           COMPUTE_EXPOSURE_TIME;

           IF FADE_SHTR
              THEN BEGIN
                   COMPUTE_SHUTTER_ANGLE;

                   IF SHUTTER_ANGLE > MAX_ANGLE
                      THEN BEGIN
                           SHUTTER_ANGLE := MAX_ANGLE;
                           FADE_SHTR := FALSE;
                           FADE_EXP := TRUE;
                           END;

                   VARIABLE_SHUTTER (SHUTTER_ANGLE);

                   IF DISPLAY THEN WRITELN ('Fading In Variable Shutter...');
                   IF DISPLAY THEN WRITELN;
                   WAITOVER;
                   END;     (* Fade In Shutter *)

           IF FADE_EXP
              THEN BEGIN
                   IF EXPOSURE_TIME > MAX_EXP
                      THEN BEGIN
                           EXPOSURE_TIME := MAX_EXP;
                           FADE_EXP := FALSE;
                           FADE := FALSE;
                           END;
                   END;    (* Fade In Exposure *)

           END     (* IF Fade In *)

      ELSE BEGIN
           COMPUTE_EXPOSURE_TIME;

           IF FADE_EXP
              THEN BEGIN
                   IF EXPOSURE_TIME < MIN_EXP
                      THEN BEGIN
                           FADE_EXP := FALSE;
                           FADE_SHTR := TRUE;
                           END;
                    END;   (* Fade Out Exposure *)

            IF FADE_SHTR
               THEN BEGIN
                    COMPUTE_SHUTTER_ANGLE;

                    IF SHUTTER_ANGLE < 0.0
                       THEN BEGIN
                            SHUTTER_ANGLE := 0.0;
                            FADE_SHTR := FALSE;
                            FADE := FALSE;
                            END;

                    VARIABLE_SHUTTER (SHUTTER_ANGLE);

                    IF DISPLAY THEN WRITELN ('Fading Out Variable Shutter...');
                    IF DISPLAY THEN WRITELN;
                    WAITOVER;
                    END;     (* Fade Out Shutter *)

            END;    (* ELSE Fade Out *)

   IF DISPLAY THEN WRITELN ('Exposure Time = ', EXPOSURE_TIME:5:2);
   IF DISPLAY THEN WRITELN ('Shutter Angle = ', SHUTTER_ANGLE:5:2);
   IF DISPLAY THEN WRITELN;

END;

(*****)

BEGIN     (* FADE SIMULATION *)

WRITELN;
WRITELN ('ANIMAL Fade Simulation...');
WRITELN;

WRITE ('Trace Display? ');
RDCON (CH);
WRITELN;
WRITELN;
DISPLAY := (CH = 'Y');

REPEAT

   INIT_DATA (XC);

   ASSIGN_DATA (XC);

   PRE_COMPUTE_FADE;

   WRITELN (0:10, EXPOSURE_TIME:20:3, XC.C.COUNT:20:3);

   FRAME_COUNT := 0;
   REPEAT

      FADEIT;

      WRITELN (FRAME_COUNT+1:10, EXPOSURE_TIME :20:3, XC.C.COUNT:20:3);

      FRAME_COUNT := FRAME_COUNT + FRAME_STEP;

   UNTIL FRAME_COUNT >= PRESET_COUNT;

   WRITELN;
   WRITE ('Continue? ');
   RDCON (CH);
   WRITELN;
   WRITELN;

UNTIL CH = 'N';

END.
