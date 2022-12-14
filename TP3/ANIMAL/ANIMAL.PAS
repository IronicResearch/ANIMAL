
{$C+}   (* Ctrl-C console break enable *)
{$U+}   (* Ctrl-C runtime break enable *)

(* ANIMAL program for Extended X,Y,Z,R,F,U,L,P MCPU axes *)
(* Copyright 1985 Dave Milici and JK Camera Engineering *)

PROGRAM ANIMAL (INPUT, OUTPUT);

(* 06-02-86 *)
(* Turbo Pascal *)
(* IBM PC - MS DOS *)
(* Follow Focus Option *)
(* Disk File Overlays *)
(* Input Protection Filters *)
(* Automatic Data File Loading *)
(* File Directory Listings *)

(* Robomaster Guy *)
(* Bolex Camera Installation *)
(* Chain Drive on Z Axis *)
(* Up is Up... (F and Z Axes) *)
(* Exposure Time Expansion Streaking *)
(* Follow Focus Streaking (Constant) *)
(* Point Plotting for X,Y,Z,F,R Axes *)

CONST FWD = TRUE;
      REV = FALSE;

      UP = TRUE;
      DN = FALSE;

      CR = $0D;
      LF = $0A;
      ESC = $1B;
      BEL = $07;

{     STD_EXP_TIME   = 0.25;}   (* ANICAM Exposure Time *)
{     STD_LAPSE_TIME = 0.47;}   (* ANICAM Lapse Cycle Time *)
{     STD_FRAME_TIME = 0.72;}   (* ANICAM Total Frame Cycle Time *)

      STD_EXP_TIME   = 0.18;    (* Bolex Exposure Time *)
      STD_LAPSE_TIME = 0.32;    (* Bolex Lapse Cycle Time *)
      STD_FRAME_TIME = 0.50;    (* Bolex Total Frame Cycle Time *)

      MM_IN = 25.4;             (* mm / in *)
      IN_MM = 0.03937;          (* in / mm *)

      O_WIDTH_1 = 1.000;        (* 1-field size (in) *)
      O_WIDTH_6 = 6.000;        (* 6-field size (in) *)
      O_WIDTH_12 = 12.000;      (* 12-field size (in) *)

      APERTURE_16 = 0.404;      (* 16mm aperture width (in) *)
      APERTURE_35 = 0.980;      (* 35mm aperture width (in) *)
      APERTURE_70 = 1.470;      (* 70mm aperture width (in) *)
                                (* = 35mm 8-perf VistaVision format *)

(* Modified Robomaster stand:
(* Z Axis = chain drive with 10:1 gear box
(* F Axis = lead screw with 1mm / turn pitch *)

      K_Z = 17.4978;            (* Z steps / mm *)
      K_F = 200.0;              (* F steps / mm *)

      MIN_D_O = 0.02875;        (* minimum Z mm / half-step *)
      MIN_D_I = 0.0025;         (* minimum F mm / half-step *)

TYPE AXIS = RECORD
        MOTORNO : INTEGER;
        STEPCNT : REAL;         (* LONGINT ? *)
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
          MULTI : BOOLEAN;
          TOTAL : INTEGER;
          SEGMENT : INTEGER;
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
          CUR_STEP : REAL;      (* LONGINT ? *)
          CUR_POSN : REAL;
          UNITS : STRING [15];
          END;

     COUNT_TABLE = RECORD
          AXISNO : INTEGER;
          COUNT : REAL;         (* LONGINT ? *)
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
          KONST_FRAME :INTEGER;
          DECEL_FRAME : INTEGER;
          INCR_MAX : REAL;

          INITL_CNT : REAL;
          FINAL_CNT : REAL;
          DELTA_CNT : REAL;
          CUR_CNT : REAL;

          ACCEL : BOOLEAN;
          SPEED : INTEGER;
          LOWSPD : INTEGER;
          HIGHSPD : INTEGER;
          RAMPCNT : INTEGER;
          END;

     HOME_TABLE = RECORD
          SPEC : BOOLEAN;
          ORDER : INTEGER;
          LIMIT : BOOLEAN;
          ALIGN : BOOLEAN;
          STEPS : INTEGER;
          COUNT : INTEGER;
          DIR : BOOLEAN;
          END;

     AXIS_TABLE = RECORD
          SPEC : BOOLEAN;
          ID : ARRAY [1..2] OF CHAR;
          M : AXIS;
          P : PARAMETER_TABLE;
          I : ARRAY [1..10] OF PARAMETER_TABLE;
          K : CONVERSION_TABLE;
          C : COUNT_TABLE;
          R : RUN_PROFILE;
          X : EXECUTION_TABLE;
          H : HOME_TABLE;
          END;

VAR CH : CHAR;
    KEY : CHAR;
    BYTE : CHAR;
    ANSWER : CHAR;

    QUITTING_TIME : BOOLEAN;
    DATA : INTEGER;

    EXPOSURE : BOOLEAN;
    SEQUENCE_OVER : BOOLEAN;

    MCPU_DELAY : INTEGER;
    TIME_DELAY : REAL;
    SEQUENCED : BOOLEAN;

    FRAME_COUNT : INTEGER;
    EXPOSURE_TIME : REAL;

    FRAME_STEP : INTEGER;
    INCRCNT : INTEGER;
    PRESET_COUNT : INTEGER;
    TOTAL_COUNT : INTEGER;

    LAPSE_TIME : REAL;
    FRAME_TIME : REAL;
    TOTAL_TIME : REAL;

    STOPMOTION : BOOLEAN;
    LIVEACTION : BOOLEAN;
    GOMOTION : BOOLEAN;

    FADE : BOOLEAN;
    ADVANCEONLY : BOOLEAN;
    ROTOSCOPING : BOOLEAN;
    PLAT_STAT : BOOLEAN;
    FOLLOW_FOCUS : BOOLEAN;
{
    X : AXIS_TABLE;       (* X Compound *)
    Y : AXIS_TABLE;       (* Y Compound *)
    Z : AXIS_TABLE;       (* Z Camera Carriage *)
    F : AXIS_TABLE;       (* Follow Focus *)
    R : AXIS_TABLE;       (* Rotation -- Compound *)
    U : AXIS_TABLE;       (* Upper Pegbars *)
    L : AXIS_TABLE;       (* Lower Pegbars *)
    P : AXIS_TABLE;       (* Platen Lifter *)

    E : AXIS_TABLE;       (* ANICAM Exposure with Advance *)
    A : AXIS_TABLE;       (* ANICAM Advance Only *)
    Q : AXIS_TABLE;       (* ANICAM Torque Motors *)
}

CONST MAX_AXES = 10;

VAR I : INTEGER;
    AA : ARRAY [1..MAX_AXES] OF AXIS_TABLE;

TYPE CHAR2 = ARRAY [1..2] OF CHAR;

CONST   XX = 1;                 (* X axis index, Pan *)
        YY = 2;                 (* Y axis index, Tilt *)
        ZZ = 3;                 (* Z axis index, Zoom *)
        FF = 4;                 (* F axis index, Follow Focus *)
        RR = 5;                 (* R axis index, Rotation *)
        UU = 6;                 (* U axis index, Upper Pegbars *)
        LL = 7;                 (* L axis index, Lower Pegbars *)
        PP = 8;                 (* P axis index, Platen Lifter *)
        EE = 9;                 (* E axis index, Exposure Advance *)
        VV = 10;                (* V axis index, Variable Shutter *)

{$I SIO86.LIB}
{$I TERM.LIB}
{$I COMM.LIB}
(* {$I MCPUM.LIB}               (* 16-bit step counts *)
{$I MCPUX.LIB}                  (* 24-bit step counts *)

{$I AXISX.EXT}                  (* axis array indexing *)
{$I MOREX.EXT}
{$I WAITOVER.EXT}

{$I CONVERT.EXT}
{$I FADE.EXT}
{$I STATUS.EXT}
{$I UPDATE.EXT}

{$I INITM.EXT}
{$I INIT8.EXT}
{$I FILEDIR.EXT}

{$I OVERUN.EXT}
{$I OVERIDE8.EXT}

{$I GOANML8.EXT}
{$I FFOCUS.EXT}

{$I MOTOR8.EXT}
{$I SCALE8.EXT}

{$I ALIGNX.EXT}
{$I XYZRFPLT.EXT}

(* MAIN MENU is the main menu for selecting the various programmed and
(* manual options of ANIMAL. *)

PROCEDURE MAIN_MENU;

BEGIN

   QUITTING_TIME := FALSE;

   REPEAT

      STOPMOTION := FALSE;
      GOMOTION := FALSE;
      LIVEACTION := FALSE;

      CLRSCRN;
      TITLE;

      WRITELN;
      WRITELN ('ANIMAL Program Selections:');
      WRITELN;
      WRITELN ('   S : Stop Motion Sequences');
      WRITELN ('   G : Go Motion Streaking Sequences');
      WRITELN ('   L : Live Action Sequences');
      WRITELN ('   P : Point Plotting Sequences');
      WRITELN ('   O : Overide Motion Options');
      WRITELN;
      WRITELN ('   A : Alignment Sequence');
      WRITELN ('   F : Follow Focus Adjustment');
      WRITELN ('   M : Motor Speed Profiles');
      WRITELN ('   U : User Units Assignments');
      WRITELN ('   Q : Quit ANIMAL Program');
      WRITELN;

      RDCON (CH);

      CASE CH OF

           'S' : BEGIN
                 WRITELN ('top Motion Sequences...');
                 STOPMOTION := TRUE;
                 GO_ANIMAL;
                 END;

           'G' : BEGIN
                 WRITELN ('o Motion Streaking Sequences...');
                 GOMOTION := TRUE;
                 GO_ANIMAL;
                 END;

           'L' : BEGIN
                 WRITELN ('ive Action Sequences...');
                 LIVEACTION := TRUE;
                 GO_ANIMAL;
                 END;

           'P' : BEGIN
                 WRITELN ('oint-Plotting Sequences...');
                 AXIS_PLOT;
                 END;

           'O' : BEGIN
                 CLRSCRN;
                 OVERIDE;
                 END;

           'M' : BEGIN
                 WRITELN ('otor Speed Profiles...');
                 MOTOR_PROFILE;
                 END;

           'A' : BEGIN
                 WRITELN ('lignment Procedure...');
                 ALIGNMENT;
                 END;

           'F' : BEGIN
                 WRITELN ('ollow Focus Procedure...');
                 FOLLOW_FOCUS_ADJUSTMENT;
                 END;

           'U' : BEGIN
                 WRITELN ('ser Units Assignments...');
                 SCALE_FACTORS;
                 END;

           'Q' : BEGIN
                 WRITE ('uitting time...for sure? (Y/N) ');
                 RDCON (ANSWER);
                 IF ANSWER = 'Y'
                    THEN QUITTING_TIME := TRUE;
                 END;

           END; (* CASE Animal Selections *)

   UNTIL QUITTING_TIME;

END;

BEGIN (* ANIMAL *)

   TITLE;

   RESETSIO;

   INIT_LOAD;

   UPDATE_EM_ALL;

   MAIN_MENU;

END.






