
(* Global declarations. *)

Unit GLOBAL;

Interface

Uses TpRarray;                (* TurboPro RAM-based extended arrays *)

CONST FWD = TRUE;
      REV = FALSE;
      UP = TRUE;
      DN = FALSE;

      CR = #$0D;
      LF = #$0A;
      ESC = #$1B;
      BEL = #$07;

(* Constants for 10-axis MCPU. *)

      XX = 1;
      YY = 2;
      ZZ = 3;
      FF = 4;
      RR = 5;
      UU = 6;
      LL = 7;
      PP = 8;
      VV = 9;
      EE = 10;

      MAX_AXES = 10;                    (* Max Animal Axes *)
      MIN_AXES = 8;                     (* Min General Axes *)

(* Constants for Compumotor MCPU. *)

      STEPS_PER_REV = 1000.0;           (* steps per revolution *)

      MIN_STEPS = 1.0;                  (* steps *)
      MAX_STEPS = 999999.0;

      MIN_REVS  = 0.001;                (* revolutions *)
      MAX_REVS  = 999.999;

      MIN_SPEED = 0.001;                (* revolutions per second *)
      MAX_SPEED = 20.000;

      MIN_ACCEL = 0.1;                  (* revolutions per second per second *)
      MAX_ACCEL = 590.0;

TYPE BYTE_CHAR = 0..255;

     CHAR2 = ARRAY [1..2] OF CHAR;

     MAP_TABLE = RECORD
          ID : ARRAY [1..2] OF CHAR;
          NO : INTEGER;
          NAME : STRING [20];
          END;

     MOTOR_TABLE = RECORD
          MOTORNO : INTEGER;
          STEPCNT : REAL;
          DIR : BOOLEAN;
          SPEED : INTEGER;
          ACCELST : BOOLEAN;
          HIGHSPD : INTEGER;
          LOWSPD : INTEGER;
          RAMPCNT : INTEGER;
          RAMPK : INTEGER;
          COUNT : REAL;
          STAT : CHAR;
          ERROR : BOOLEAN;
          RUNCNT : REAL;
          COMPUMTR_2100 : BOOLEAN;
          END;

     CONVERSION_TABLE = RECORD
          KSCALE : REAL;
          DP : INTEGER;
          CUR_STEP : REAL;
          CUR_POSN : REAL;
          UNITS : STRING [15];
          END;

     RUN_PROFILE = RECORD
          ACCEL : BOOLEAN;
          MIN_SPEED : INTEGER;
          MAX_SPEED : INTEGER;
          MIN_LOWSPD : INTEGER;
          MAX_HIGHSPD : INTEGER;
          MAX_RAMPCNT : INTEGER;
          END;

     HOME_TABLE = RECORD
          SPEC : BOOLEAN;
          ORDER : INTEGER;
          LIMIT : BOOLEAN;
          SPEED : INTEGER;
          ALIGN : BOOLEAN;
          STEPS : INTEGER;
          COUNT : REAL;
          END;

     BACKLASH_TABLE = RECORD
          SPEC : BOOLEAN;
          COMPDIR : BOOLEAN;
          COMPCNT : REAL;
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

(* Point-Plotter *)

Const

   Max_Points = 11;                     (* Max Plotter Points *)

   Max_Spline = 2001;                   (* Max Spline Points *)

Type

   POINT_TABLE = ARRAY [0..MAX_POINTS] OF REAL;

   REAL_ARRAY = ARRAY [0..MAX_SPLINE] OF REAL;

   TnVector = Array [0..Max_Points] of Real;

Procedure Put_Pt (I : Integer; P : Integer; R : Real);

Function Get_Pt (I : Integer; P : Integer) : Real;

(* the return of the dreaded triggers... *)

Const

   MAX_TRIG = 5;          (* Max Trigger Phases *)

Type

   TRIGGER_TABLE = RECORD
        SPEC : BOOLEAN;
        MASK : BYTE_CHAR;
        TRIG : ARRAY [1..8] OF BYTE_CHAR;
        NULL : ARRAY [1..8] OF BYTE_CHAR;
        TIME : ARRAY [1..8] OF INTEGER;
        WAIT : ARRAY [1..8] OF INTEGER;
        SKIP : INTEGER;
        STEP : INTEGER;
        CNTR : INTEGER;
        END;

Var

   TRIGGER : ARRAY [1..MAX_TRIG] OF TRIGGER_TABLE;

(* complete axis array data record *)

Type

     AXIS_TABLE = RECORD
          SPEC : BOOLEAN;
          ID : ARRAY [1..2] OF CHAR;
          A : MAP_TABLE;
          M : MOTOR_TABLE;
          K : CONVERSION_TABLE;
          R : RUN_PROFILE;
          H : HOME_TABLE;
          B : BACKLASH_TABLE;
          Pt : TpArray;
          Key : Point_Table;
          AX0 : TnVector;
          BX1 : TnVector;
          CX2 : TnVector;
          DX3 : TnVector;
          END;

VAR I : INTEGER;
    QUITTING_TIME : BOOLEAN;

    MCPU_DELAY : Integer;
    SEQUENCE_OVER : Boolean;

    Max_Array : LongInt;
    AA : ARRAY [1..MAX_AXES] OF AXIS_TABLE;

Implementation

(*****)

(* Put a real point into an extended array. *)

Procedure Put_Pt (I : Integer; P : Integer; R : Real);

Begin

   SetA (AA [I].Pt, P, 0, R);

End;

(* Get a real point out of an extended array. *)

Function Get_Pt (I : Integer; P : Integer) : Real;

Var R : Real;

Begin

   RetA (AA [I].Pt, P, 0, R);
   Get_Pt := R;

End;

(*****)

(* Initialization *)

Var Zero : Byte;

Begin

   MCPU_DELAY := 333;
   SEQUENCE_OVER := FALSE;

{$IFOPT R+}

   TpRarray.WriteError  := True;
   TpRarray.HaltOnError := True;
   TpRarray.RangeCheck  := True;

{$ELSE}

   TpRarray.WriteError  := True;
   TpRarray.HaltOnError := False;
   TpRarray.RangeCheck  := False;

{$ENDIF}

   For I := 1 to Max_Axes Do
       AA [I].Pt := Nil;

   Max_Array := 2000;
   While (Max_Axes * Max_Array * SizeOf (Real) > MemAvail)
         Or (Max_Array * SizeOf (Real) > MaxAvail) Do
         Max_Array := Max_Array DIV 2;

   Zero := 0;
   For I := 1 to Max_Axes Do
       If I in [XX,YY,ZZ,RR]
          Then begin
          MakeA (AA [I].Pt, Max_Array+1, 1, SizeOf (Real));
          If ErrorA = 0
             Then ClearA (AA [I].Pt, Zero, TpRarray.FastInit)
             Else AA [I].Pt := Nil;
          end;

End.
