
(* ANIMAL program for Swedish Guy's 20 MCPU axes *)
(* Copyright 1985 Dave Milici and JK Camera Engineering *)
(* Copyright 1986 Dave Milici and Animationsakademein *)

{$C-}     (* No CTRL-C detection --> intact input buffer *)

PROGRAM ANIMAL (INPUT, OUTPUT);

(* 09-23-85 *)

(* Turbo Pascal *)
(* IBM PC - MS DOS *)
(* Disk File Overlays *)
(* Input Error Filters *)
(* File Error Protection *)
(* Auto Loading Data Files *)
(* File Directory Listings *)
(* Compacted Axis Data Array *)
(* Independent Options Modules *)

(* 35mm Mitchell Camera *)
(* Start/End Frame Specs *)
(* Remote Switch-box Accessory *)
(* Extended 24-bit Step Counts *)
(* Expanded Point-Plotting Commands *)
(* Linear Interpolations for Plotted Points *)
(* Multi-Segment Program Sequences *)
(* Go Motion Streaking Time Exposure Options *)
(* Variable Shutter Fades and Dissolves *)
(* Phantom Follow Focus Feature *)
(* Sine Taper Option with Error Correction *)
(* Sequence Aligning and Reversing Options *)
(* Vectored Motion at Scaled Speeds *)
(* The Dreaded Triggers... *)
(* Sine Fades and Automatic-Rewind Dissolves *)

CONST FWD = TRUE;
      REV = FALSE;

      UP = TRUE;
      DN = FALSE;

      CR = #$0D;
      LF = #$0A;
      ESC = #$1B;
      BEL = #$07;

      PIOL = $0378;     (* IBM Parallel Port 1 *)
      PIOH = $03BC;

{     STD_EXP_TIME   = 0.25;}   (* ANICAM Exposure Time *)
{     STD_LAPSE_TIME = 0.32;}   (* ANICAM Lapse Cycle Time *)
{     STD_FRAME_TIME = 0.57;}   (* ANICAM Total Frame Cycle Time *)

{     STD_EXP_TIME   = 0.18;}   (* Bolex Exposure Time *)
{     STD_LAPSE_TIME = 0.32;}   (* Bolex Lapse Cycle Time *)
{     STD_FRAME_TIME = 0.50;}   (* Bolex Total Frame Cycle Time *)

      STD_EXP_TIME   = 0.24;    (* Mitchell Exposure Time *)
      STD_LAPSE_TIME = 0.26;    (* Mitchell Lapse Cycle Time *)
      STD_FRAME_TIME = 0.50;    (* Mitchell Total Frame Cycle Time *)

{     STD_EXP_TIME   = 1.20;}   (* JK DE Box Exposure Time *)
{     STD_LAPSE_TIME = 0.05;}   (* JK DE Box Lapse Cycle Time *)
{     STD_FRAME_TIME = 1.25;}   (* JK DE Box Total Frame Cycle Time *)

      MAX_ANGLE = 170.0;        (* Mitchell Shutter Angle *)

      MAX_AXES = 19;

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
          MULTI : BOOLEAN;
          SEGMENT : INTEGER;
          TOTAL : INTEGER;

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
          I : ARRAY [1..10] OF PARAMETER_TABLE;
          K : CONVERSION_TABLE;
          C : COUNT_TABLE;
          R : RUN_PROFILE;
          X : EXECUTION_TABLE;
          H : HOME_TABLE;
          END;

     CHAR2 = ARRAY [1..2] OF CHAR;
     CHAR3 = ARRAY [1..3] OF CHAR;
     CHAR4 = ARRAY [1..4] OF CHAR;

     BYTE_CHAR = 0..255;

     TRIGGER_TABLE = RECORD
        SPEC : BOOLEAN;
        MASK : BYTE_CHAR;
        TRIG : BYTE_CHAR;
        NULL : BYTE_CHAR;
        TIME : INTEGER;
        WAIT : INTEGER;
        END;

VAR CH : CHAR;
    BYTE : CHAR;
    ANSWER : CHAR;

    I : INTEGER;
    QUITTING_TIME : BOOLEAN;

    FRAME_COUNT : INTEGER;
    EXPOSURE_TIME : REAL;

    EXPOSURE : BOOLEAN;
    FRAME_STEP : INTEGER;
    PRESET_COUNT : INTEGER;
    TOTAL_COUNT : INTEGER;
    HOLD_FRAME : INTEGER;

    STREAK_TIME : REAL;
    STREAK_DELAY : REAL;
    STREAK_EXPOSURE : BOOLEAN;

    LAPSE_TIME : REAL;
    FRAME_TIME : REAL;
    TOTAL_TIME : REAL;

    SEQUENCE_TIME : REAL;
    MCPU_DELAY : INTEGER;
    SEQUENCED : BOOLEAN;
    SEQUENCE_OVER : BOOLEAN;
    REMOTE : BOOLEAN;
    DISPLAY : BOOLEAN;
    REVERSE : BOOLEAN;
    VECTORED : BOOLEAN;

    STOPMOTION : BOOLEAN;
    LIVEACTION : BOOLEAN;
    GOMOTION : BOOLEAN;

    FADE : BOOLEAN;
    ADVANCEONLY : BOOLEAN;
    ROTOSCOPING : BOOLEAN;

    FADE_LENGTH : INTEGER;
    FADEIN : BOOLEAN;
    FADELOG : BOOLEAN;
    FADESIN : BOOLEAN;
    DISSOLVE : BOOLEAN;

    FADE_EXP : BOOLEAN;
    FADE_SHTR : BOOLEAN;

    MAX_EXP : REAL;
    MIN_EXP : REAL;
    EXP_INCR : REAL;
    PHI_INCR : REAL;
    SHTR_INCR : REAL;
    SHUTTER_ANGLE : REAL;

    NSTOPS : REAL;
    FSTOPS : REAL;
    LOG_INCR : REAL;
    TAPERED_FADE : BOOLEAN;
    TAPERED_SINE : BOOLEAN;
    FADE_TAPER : REAL;
    FADE_COUNT : INTEGER;
    TAPER_COUNT : INTEGER;
    TAPER_EXPOSURE : REAL;

    FOLLOW_FOCUS : BOOLEAN;
    FOCAL_LENGTH : REAL;
    ZERO_FOCUS : REAL;
    FOCUS_REF : REAL;

    TRIGGER : ARRAY [1..4] OF TRIGGER_TABLE;

    E : AXIS_TABLE;       (* ANICAM Exposure with Advance *)
    A : AXIS_TABLE;       (* ANICAM Advance Only *)

    PN : AXIS_TABLE;       (* Pan *)
    TL : AXIS_TABLE;       (* Tilt *)
    BM : AXIS_TABLE;       (* Boom Arm *)
    HT : AXIS_TABLE;       (* Height *)
    TR : AXIS_TABLE;       (* Track *)
    RT : AXIS_TABLE;       (* Rotation *)
    LP : AXIS_TABLE;       (* Loop Lens *)
    GR : AXIS_TABLE;       (* Gir Lens *)
    RL : AXIS_TABLE;       (* Roll Lens *)
    LV : AXIS_TABLE;       (* Level *)
    FF : AXIS_TABLE;       (* Follow Focus *)
    ZM : AXIS_TABLE;       (* Zoom Lens *)
    XA : AXIS_TABLE;       (* Aux Line A *)
    XB : AXIS_TABLE;       (* Aux Line B *)
    XC : AXIS_TABLE;       (* Aux Line C *)
    XD : AXIS_TABLE;       (* Aux LIne D *)
    XE : AXIS_TABLE;       (* Aux Line E *)
    XF : AXIS_TABLE;       (* Aux Line F *)
    XG : AXIS_TABLE;       (* Aux Line G *)

    AA : ARRAY [1..MAX_AXES] OF AXIS_TABLE;

{$I SIO86.LIB}
{$I KEYBD.LIB}
{$I SCREEN.LIB}
{$I COMM.LIB}
{$I MCPUX.LIB}

{$I AXISIF.EXT}
{$I WAITOVER.EXT}
{$I MOREX.EXT}

{$I UPDATE83.EXT}
{$I STATUS83.EXT}
{$I FADE.EXT}
{$I CAMERA.EXT}
{$I OPTIONS.EXT}
{$I TRIGPULS.EXT}

{$I INITM.EXT}
OVERLAY {$I INIT83.EXT}
OVERLAY {$I FILEDIR.EXT}

{$I OVERUN.EXT}
{$I OVERID80.EXT}

OVERLAY {$I TRIGGER.EXT}
OVERLAY {$I FFFOCUS.EXT}

OVERLAY {$I SCALE83.EXT}
OVERLAY {$I MOTOR83.EXT}

OVERLAY {$I GOANML83.EXT}
OVERLAY {$I AXPLOT83.EXT}

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
      WRITELN ('   M : Motor Speed Profiles');
      WRITELN ('   U : User Units Assignments');
      WRITELN ('   F : Follow Focus Adjustment');
      WRITELN ('   T : Trigger Output Definitions');
      WRITELN ('   Q : Quit ANIMAL Program');
      WRITELN;

      RDCON (CH);

      CASE CH OF

           'S' : BEGIN
                 WRITELN ('top Motion Programming...');
                 STOPMOTION := TRUE;
                 GO_ANIMAL;
                 END;

           'G' : BEGIN
                 WRITELN ('o Motion Streak Programming...');
                 GOMOTION := TRUE;
                 GO_ANIMAL;
                 END;

           'L' : BEGIN
                 WRITELN ('ive Action Programming...');
                 LIVEACTION := TRUE;
                 GO_ANIMAL;
                 END;

           'P' : BEGIN
                 WRITELN ('oint Plotting for 7 Axes...');
                 GET_AXIS_ARRAY;
                 AXIS_PLOT;
                 END;

           'O' : BEGIN
                 CLRSCRN;
                 OVERIDE;
                 END;

           'M' : BEGIN
                 WRITELN ('otor Speeds...');
                 MOTOR_PROFILE;
                 GET_AXIS_ARRAY;
                 END;

           'U' : BEGIN
                 WRITELN ('ser Units...');
                 SCALE_FACTORS;
                 GET_AXIS_ARRAY;
                 END;

           'F' : BEGIN
                 WRITELN ('ollow Focus...');
                 FOLLOW_FOCUS_ADJUSTMENT;
                 PUT_AXIS_ARRAY;
                 END;

           'T' : BEGIN
                 WRITELN ('riggers... ');
                 TRIGGER_HAPPY;
                 END;

           'Q' : BEGIN
                 WRITE ('uitting time...for sure? (Y/N) ');
                 CLRKEY;
                 RDCON (ANSWER);
                 WRITELN;
                 WRITELN;
                 IF ANSWER = 'Y' THEN QUITTING_TIME := TRUE;
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