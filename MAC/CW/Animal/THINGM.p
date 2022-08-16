(* ThingM command interface. *)

(* Originally from Turbo Pascal PC version of Animal. *)
(* Adapted to CodeWarrior Pascal for Mac. *) 

Unit THINGM;

{$SETC CALCULATOR_KEYPAD = 0}             (* original calculator-style layout *)

{$SETC THINGM_NULL = 0}                   (* for no serial communications *)

Interface

Uses
     TurboCRT,							(* Turbo Pascal style console extensions *)
     TurboStr,							(* Turbo Pascal style string conversions *)
     SIO,								(* serial interface *)
     MCPU;								(* MCPU communications *)

Procedure THINGM_Program;
Procedure THINGM_Run;
Procedure THINGM_Camera;
Procedure THINGM_Projector;
Procedure THINGM_Sequencer (B : boolean);
Procedure THINGM_FrameCount (N : integer);
Procedure THINGM_Direction (B : boolean);
Procedure THINGM_Counter (N : integer);
Procedure THINGM_OutFrame (N : integer);
Procedure THINGM_ExposureTime (X : real);
Procedure THINGM_LapseTime (X : real);
Procedure THINGM_Speed (X : real);
Procedure THINGM_Ramp (X : real);

Implementation

Const
    KEY_PGM = 'P';
    KEY_RUN = 'R';
    KEY_ENTER = char(CR);
    KEY_CLEAR = char(BS);
{$IFC CALCULATOR_KEYPAD}
    KEY_CAM = '7';
    KEY_SEQ = '8';
    KEY_PRJ = '9';
    KEY_FRM = '1';
    KEY_EXP = '2';
    KEY_LPS = '3';
    KEY_CTR = '4';
    KEY_SPD = '5';
    KEY_RMP = '6';
    KEY_OUT = '0';
{$ELSEC}
    KEY_CAM = '1';
    KEY_SEQ = '0';
    KEY_PRJ = '3';
    KEY_FRM = '4';
    KEY_CTR = '5';
    KEY_OUT = '6';
    KEY_EXP = '.1';
    KEY_LPS = '.2';
    KEY_SPD = '.7';
    KEY_RMP = '.8';
{$ENDC}
    KEY_DIR = '-';
    KEY_INT = '.';

    THINGM_DELAY = 50; (* millisec delay for LCD output *)

(* Wait for Response string from THINGM. *)
Procedure WaitResponse;
var S : string;
Begin
{$IFC NOT THINGM_NULL}
   TpDelay(THINGM_DELAY);
   InStr(S);
{$ENDC}
End;

Procedure THINGM_Program;
Begin
   OutCmd(KEY_PGM); WaitResponse;
End;

Procedure THINGM_Run;
Begin
   OutCmd(KEY_RUN);
End;

Procedure THINGM_Camera;
Begin
   OutCmd(KEY_PGM); WaitResponse;
   OutCmd(KEY_CAM); WaitResponse;
End;

Procedure THINGM_Projector;
Begin
   OutCmd(KEY_PGM); WaitResponse;
   OutCmd(KEY_PRJ); WaitResponse;
End;

Procedure THINGM_Sequencer (B : boolean);
var S : string;
Begin
   OutCmd(KEY_PGM); WaitResponse;
   OutCmd(KEY_SEQ); WaitResponse;
{$IFC NOT THINGM_NULL}
   InStr(S);
   if (B = TRUE) AND (S[Length(S)-1] = '-')
      then OutCmd(KEY_DIR);
   if (B = FALSE) AND (S[Length(S)-1] = '+')
      then OutCmd(KEY_DIR);
{$ENDC}
   OutCmd(KEY_ENTER); WaitResponse;
End;

Procedure THINGM_FrameCount (N : integer);
var S : string;
Begin
   OutCmd(KEY_PGM); WaitResponse;
   OutCmd(KEY_FRM); WaitResponse;
   Str(N,S);
   OutStr(S);
   OutCmd(KEY_ENTER); WaitResponse;
End;

Procedure THINGM_Direction (B : boolean);
var S : string;
Begin
   OutCmd(KEY_PGM); WaitResponse;
   OutCmd(KEY_DIR); WaitResponse;
{$IFC NOT THINGM_NULL}
   InStr(S);
   if (B = FWD) AND (S[Length(S)-1] = '-')
      then OutCmd(KEY_DIR);
   if (B = REV) AND (S[Length(S)-1] = '+')
      then OutCmd(KEY_DIR);
{$ENDC}
   OutCmd(KEY_ENTER); WaitResponse;
End;

Procedure THINGM_Counter (N : integer);
var S : string;
Begin
   OutCmd(KEY_PGM); WaitResponse;
   OutCmd(KEY_CTR); WaitResponse;
   Str(N,S);
   OutStr(S);
   OutCmd(KEY_ENTER); WaitResponse;
End;

Procedure THINGM_OutFrame (N : integer);
var S : string;
Begin
   OutCmd(KEY_PGM); WaitResponse;
   OutCmd(KEY_OUT); WaitResponse;
   Str(N,S);
   OutStr(S);
   OutCmd(KEY_ENTER); WaitResponse;
End;

Procedure THINGM_ExposureTime (X : real);
var S : string;
Begin
   OutCmd(KEY_PGM); WaitResponse;
   OutCmdStr(KEY_EXP); WaitResponse;
   S := StringOf(X:3:2);
   OutStr(S);
   OutCmd(KEY_ENTER); WaitResponse;
End;

Procedure THINGM_LapseTime (X : real);
var S : string;
Begin
   OutCmd(KEY_PGM); WaitResponse;
   OutCmdStr(KEY_LPS); WaitResponse;
   S := StringOf(X:3:2);
   OutStr(S);
   OutCmd(KEY_ENTER); WaitResponse;
End;

Procedure THINGM_Speed (X : real);
var S : string;
Begin
   OutCmd(KEY_PGM); WaitResponse;
   OutCmdStr(KEY_SPD); WaitResponse;
   S := StringOf(X:3:2);
   OutStr(S);
   OutCmd(KEY_ENTER); WaitResponse;
End;

Procedure THINGM_Ramp (X : real);
var S : string;
Begin
   OutCmd(KEY_PGM); WaitResponse;
   OutCmdStr(KEY_RMP); WaitResponse;
   S := StringOf(X:3:2);
   OutStr(S);
   OutCmd(KEY_ENTER); WaitResponse;
End;

End.

