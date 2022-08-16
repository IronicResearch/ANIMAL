
(* MCPU communications interface. *)

Unit MCPU (102);

{$U-}
{$U TurboCrt}

Interface

Uses

    PasInOut,
    PasConsole,
    TurboCrt,
    MemTypes,
    QuickDraw,
    OSIntf;

Const

    FWD = True;
    REV = False;

Type
    
    Motor_Table = Record
    MotorNo : Integer;              (* motor number *)
    StepCnt : Real;                 (* step count *)
    Dir     : Boolean;              (* step direction *)
    AccelSt : Boolean;              (* acceleration status *)
    Speed   : Integer;              (* constant speed *)
    LowSpd  : Integer;              (* low speed *)
    HighSpd : Integer;              (* high speed *)
    RampCnt : Integer;              (* ramp count *)
    RampK   : Integer;              (* ramp constant *)
    Stat    : Char;                 (* axis status *)
    Count   : Real;                 (* axis position *)
    Error   : Boolean;              (* error status *)
    end;
    



(* {$I SIO.LIB} *)

PROCEDURE RESETSIO;

PROCEDURE INSIOST (VAR STATUS : BOOLEAN);

PROCEDURE INSIO (VAR CH : CHAR);

PROCEDURE OUTSIOST (VAR STATUS : BOOLEAN);

PROCEDURE OUTSIO (VAR CH : CHAR);



(* {$I MCPUCOMM.LIB} *)

PROCEDURE OUTCMD (CH : CHAR);

PROCEDURE TIMEOUT_MCPU (VAR STATUS : BOOLEAN);

PROCEDURE RESET_MCPU;

PROCEDURE INIT_MCPU;

PROCEDURE READYMCPU;

PROCEDURE SYNC_MCPU;

PROCEDURE RESYNC_MCPU;

PROCEDURE IDLE_MCPU;

PROCEDURE NULL_MCPU;

PROCEDURE OVERHEAR;

PROCEDURE PREPM (VAR M : MOTOR_TABLE);

PROCEDURE INTBYTE (VAR INTVAL : INTEGER; VAR BYTE_L, BYTE_H : CHAR);

PROCEDURE BYTEINT (VAR BYTE_L, BYTE_H : CHAR; VAR INTVAL : INTEGER);

PROCEDURE REALBYTE (VAR REALVAL : REAL; VAR BYTE_L, BYTE_H, BYTE_X : CHAR);

PROCEDURE BYTEREAL (VAR BYTE_L, BYTE_H, BYTE_X : CHAR; VAR REALVAL : REAL);

PROCEDURE OUTSTR (VAR S : STRING);

PROCEDURE INTSTR (VAR INTVAL : INTEGER; VAR BYTESTR : STRING);

PROCEDURE REALSTR (VAR REALVAL : REAL; VAR BYTESTR : STRING);

PROCEDURE STRINT (VAR BYTESTR : STRING; VAR INTVAL : INTEGER);

PROCEDURE STREAL (VAR BYTESTR : STRING; VAR REALVAL : REAL);




(* {$I MCPUX.LIB} *)

PROCEDURE DRIVEX (VAR M : MOTOR_TABLE);

PROCEDURE INITX (VAR M : MOTOR_TABLE);

PROCEDURE RUNX (VAR M : MOTOR_TABLE);

PROCEDURE KILLX (VAR M : MOTOR_TABLE);

PROCEDURE ZEROX (VAR M : MOTOR_TABLE);

PROCEDURE GETSTAT (VAR M : MOTOR_TABLE);

PROCEDURE GETCOUNT_Software (VAR M : MOTOR_TABLE);

PROCEDURE GETCOUNT_Hardware (VAR M : MOTOR_TABLE);

PROCEDURE GETCOUNT (VAR M : MOTOR_TABLE);

PROCEDURE GETX (VAR M : MOTOR_TABLE);

PROCEDURE STATX (VAR M : MOTOR_TABLE);



(* {$I MCPUM.LIB} *)

PROCEDURE DRIVEM (VAR M : MOTOR_TABLE);

PROCEDURE INITM (VAR M : MOTOR_TABLE);

PROCEDURE RUNM (VAR M : MOTOR_TABLE);

PROCEDURE KILLM (VAR M : MOTOR_TABLE);

PROCEDURE ZEROM (VAR M : MOTOR_TABLE);

PROCEDURE PULSEM (VAR M : MOTOR_TABLE);

PROCEDURE HOMEM (VAR M : MOTOR_TABLE);

PROCEDURE NOLIMITM (VAR M : MOTOR_TABLE);

PROCEDURE VECTORM (VAR M : MOTOR_TABLE);

PROCEDURE WHEREM (VAR M : MOTOR_TABLE);




Implementation

(* {$I SIOMAC.LIB} *)

(* Serial Interface Input / Output via Turbo Pascal calls to Mac OS. *)

Const Modem_Port_Input = -6;
      Modem_Port_Output = -7;
      Modem_Port_Name_In = '.AIn';
      Modem_Port_Name_Out = '.AOut';

Var OS_Result : OSErr;
    Device_Ref_In : Integer;
    Device_Ref_Out : Integer;

Var Num_Bytes : LongInt;
    Buf_Pntr : Ptr;

(* Initialize the Modem port. *)
(* Open the serial port device driver in ROM. *)
(* Reset the serial port for 9600 baud communication. *)

Procedure ResetSIO;

Var Reset_Code : Integer;

Begin

   OS_Result := OpenDriver (Modem_Port_Name_In, Device_Ref_In);
   OS_Result := OpenDriver (Modem_Port_Name_Out, Device_Ref_Out);
   
   Reset_Code := Baud9600 + Data8 + Stop10 + NoParity;
   OS_Result := SerReset (Device_Ref_In, Reset_Code);
   OS_Result := SerReset (Device_Ref_Out, Reset_Code);
      
End;

(* Check for output port status. *)

Procedure OutSioSt { (Var Status : Boolean) };

Begin

   Status := True;
   
End;

(* Output a single character to the Modem port. *)
(* Character is passed as single byte in buffer. *)

Procedure OutSIO { (Var Ch : Char)} ;

Begin

   Buf_Pntr := NewPtr (SizeOf (Ch));
      
   Num_Bytes := 1;
   
   Buf_Pntr^ := SignedByte (Ch);                                    (* OK *)
   
   OS_Result := FSWrite (Device_Ref_Out, Num_Bytes, Buf_Pntr);
   
   DisposPtr (Buf_Pntr);

End;

(* Check for Modem Input status. *)

Procedure InSIOst { (Var Status : Boolean) };

Begin

   OS_Result := SerGetBuf (Device_Ref_In, Num_Bytes);
   Status := (Num_Bytes <> 0);                                 (* OK *)

End;

(* Input a 'single' character from the Modem port. *)
(* Get a single character from the Modem input port buffer. *)

Procedure InSIO { (Var Ch : Char) };

Begin

   Buf_Pntr := NewPtr (SizeOf (Ch));
   
   Num_Bytes := 1;
   
   OS_Result := FSRead (Device_Ref_In, Num_Bytes, Buf_Pntr);
   
   If Num_Bytes <> 0
      Then Ch := Char (Buf_Pntr^)
      Else Ch := Chr (0);                                           (* OK *)
   
   DisposPtr (Buf_Pntr);
   
End;

(* {$I MCPUCOMM.STD.LIB} *)

(* MCPU Communications routines. *)

(* OUTPUT COMMAND outputs an ASCII character command to the MCPU. *)
(* Note: OUTCMD passes by value, whereas OUTSIO passes by reference. *)

PROCEDURE OUTCMD { (CH : CHAR) };

BEGIN

   OUTSIO (CH);

END;

(* TIME-OUT MCPU times out the MCPU's response to the serial input port. *)

PROCEDURE TIMEOUT_MCPU { (VAR STATUS : BOOLEAN) };

CONST TIME = 10;                        (* 10 millisecond *)
      TIMEOUT = 1000;                   (* 1000 milliseconds *)

VAR T : INTEGER;

BEGIN

   T := 0;
   REPEAT
      OUTSIOST (STATUS);                (* 'Ready' MCPU hardware ? *)
      T := SUCC (T);
      IF NOT STATUS
         THEN TpDELAY (TIME);
   UNTIL (STATUS) OR (T >= TIMEOUT);

END;

(* RESET MCPU resets the MCPU with null commands via the serial port. *)

PROCEDURE RESET_MCPU;

BEGIN

   OUTCMD ('Z');         (* Zzzzz *)

END;

(*****)

(* INITIALIZE MCPU finds out if the MCPU is ready for communications
(* with the host desktop computer. *)

PROCEDURE INIT_MCPU;

VAR CH : CHAR;
    SIOST : BOOLEAN;

BEGIN

   REPEAT

      RESET_MCPU;                       (* reset MCPU output *)

      TIMEOUT_MCPU (SIOST);             (* time-out MCPU input *)

      IF NOT SIOST
         THEN BEGIN
              WRITELN ('MCPU Not Ready Yet');
              WRITELN ('--Either Reset MCPU');
              WRITE   ('--Or Abort Program Here (^C) > ');
              Ch := ReadKey;
              If Ch = ^C
                 Then Write ('^C')
                 Else Write (Ch);
              WRITELN;
              WRITELN;
              IF CH = ^C
                 THEN HALT;
              END;

   UNTIL SIOST;

   WRITELN ('MCPU Ready...');
   WRITELN;

END;   (* procedure INIT MCPU *)

(*****)

(* READY MCPU loops until the MCPU is ready for command input. *)

PROCEDURE READYMCPU;

VAR BYTE : CHAR;
    SIOST : BOOLEAN;

BEGIN

   REPEAT

      REPEAT
         OUTSIOST (SIOST);              (* 'Ready' MCPU hardware ? *)
      UNTIL SIOST;

      OUTCMD ('W');                     (* 'Wake up' MCPU *)
      INSIO (BYTE);

   UNTIL BYTE = 'R';                    (* 'Ready' MCPU software ? *)

END;

(* SYNC MCPU synchronizes MCPU communications to be ready for a command. *)

PROCEDURE SYNC_MCPU;

BEGIN

   OUTCMD ('Z');         (* Zzzzz *)

   READYMCPU;            (* Ready ? *)

END;

(* RE-SYNC MCPU re-syncronizes MCPU communications for an existing command. *)

PROCEDURE RESYNC_MCPU;

BEGIN

   WRITELN ('MCPU Synchronization Error');

   OUTCMD ('Z');         (* Zzzzz end *)

   READYMCPU;            (* Ready again ? *)

   OUTCMD ('W');         (* Wake up again ! *)

END;

(* IDLE MCPU syncronizes MCPU communications into idle. *)

PROCEDURE IDLE_MCPU;

BEGIN

   OUTCMD ('Z');         (* Zzzzz ? *)

   READYMCPU;            (* Ready ? *)

   OUTCMD ('Z');         (* Zzzzz ! *)

END;

(* NULL MCPU nullifies an existing MCPU command sequence. *)

PROCEDURE NULL_MCPU;

BEGIN

   OUTCMD ('Z');         (* Zzzzz *)

END;

(* OVERHEAR commands the MCPU to not respond again until all axes are over. *)

PROCEDURE OVERHEAR;

BEGIN

   READYMCPU;            (* Ready ? *)

   OUTCMD ('W');         (* Wake Up *)

   OUTCMD ('O');         (* Overhear *)

   OUTCMD ('Z');         (* Zzzzz *)

END;

(* PREPM prepares the step count and direction for an MCPU motor. *)

PROCEDURE PREPM { (VAR M : MOTOR_TABLE) };

BEGIN

   IF M.STEPCNT < 0
      THEN M.DIR := REV
      ELSE M.DIR := FWD;

   M.STEPCNT := ABS (M.STEPCNT);

END;

(* INTBYTE converts a 16-bit Pascal integer into its corresponding
(* two 8-bit bytes for output to the serial interface. *)

PROCEDURE INTBYTE { (VAR INTVAL : INTEGER; VAR BYTE_L, BYTE_H : CHAR) };

BEGIN

   BYTE_H := CHR (INTVAL DIV 256);
   BYTE_L := CHR (INTVAL MOD 256);

END;

(* BYTEINT converts two 8-bit bytes back into a 16-bit Pascal integer
(* for input from the serial interface. *)

PROCEDURE BYTEINT { (VAR BYTE_L, BYTE_H : CHAR; VAR INTVAL : INTEGER) };

BEGIN

   INTVAL := ORD (BYTE_H) * 256 + ORD (BYTE_L);

END;

(* REALBYTE converts a 24-bit Pascal real into its corresponding
(* three 8-bit bytes for output to the serial interface. *)

PROCEDURE REALBYTE { (VAR REALVAL : REAL; VAR BYTE_L, BYTE_H, BYTE_X : CHAR) };

VAR XX : INTEGER;
    HH : INTEGER;
    LL : INTEGER;
    HHLL : REAL;
    XXHHLL : REAL;

BEGIN

   IF REALVAL > 16777215.0
      THEN XXHHLL := 16777215.0         (* max 24-bit real value *)
      ELSE XXHHLL := REALVAL + 0.5;     (* real number round up *)

   XX := TRUNC (XXHHLL / 65536.0);

   HHLL := XXHHLL - XX * 65536.0;

   HH := TRUNC (HHLL / 256.0);

   LL := TRUNC (HHLL - HH * 256.0);

   BYTE_X := CHR (XX);
   BYTE_H := CHR (HH);
   BYTE_L := CHR (LL);

END;

(* BYTEREAL converts three 8-bit bytes back into a 24-bit Pascal real
(* for input from the serial interface. *)

PROCEDURE BYTEREAL { (VAR BYTE_L, BYTE_H, BYTE_X : CHAR; VAR REALVAL : REAL) };

BEGIN

   REALVAL := ORD (BYTE_X) * 65536.0 + ORD (BYTE_H) * 256.0 + ORD (BYTE_L);

   IF REALVAL > 8388607.0
      THEN REALVAL := REALVAL - 16777216.0;     (* 2s complement wraparound *)

END;

(*****)

PROCEDURE OUTSTR { (VAR S : STRING) };

Begin
End;

PROCEDURE INTSTR { (VAR INTVAL : INTEGER; VAR BYTESTR : STRING) };

Begin
End;

PROCEDURE REALSTR { (VAR REALVAL : REAL; VAR BYTESTR : STRING) };

Begin
End;

PROCEDURE STRINT { (VAR BYTESTR : STRING; VAR INTVAL : INTEGER) };

Begin
End;

PROCEDURE STREAL { (VAR BYTESTR : STRING; VAR REALVAL : REAL) };

Begin
End;

(*****)

(* {$I MCPUX.STD.LIB} *)

(* Common core MCPU sub-commands. *)
(* For use in nested MCPU command block sequences. *)
(* Uses extended 24-bit step counts. *)

(* DRIVEX drives an MCPU motor according to a step count, direction, and
(* overiding constant or ramping speed, for immediate operation. *)
(* For use in nested 'Drive' MCPU command block sequences. *)

PROCEDURE DRIVEX { (VAR M : MOTOR_TABLE) };

VAR MN : CHAR;
    COUNT_L : CHAR;
    COUNT_H : CHAR;
    COUNT_X : CHAR;
    RATE_L : CHAR;
    RATE_H : CHAR;

BEGIN

   OUTCMD ('D');              (* time to Drive... *)

   OUTCMD ('M');              (* Motor # *)
   MN := CHR (M.MOTORNO);
   OUTSIO (MN);

   OUTCMD ('N');              (* Number step count *)
   REALBYTE (M.STEPCNT, COUNT_L, COUNT_H, COUNT_X);
   OUTSIO (COUNT_L);
   OUTSIO (COUNT_H);

   OUTCMD ('X');              (* EXtra step count *)
   OUTSIO (COUNT_X);

   IF NOT M.ACCELST

      THEN BEGIN
           OUTCMD ('V');           (* Velocity *)
           INTBYTE (M.SPEED, RATE_L, RATE_H);
           OUTSIO (RATE_L);
           OUTSIO (RATE_H);
           END

      ELSE BEGIN
           OUTCMD ('A');           (* Acceleration *)
           INTBYTE (M.LOWSPD, RATE_L, RATE_H);
           OUTSIO (RATE_L);
           OUTSIO (RATE_H);        (* Low Speed *)

           INTBYTE (M.HIGHSPD, RATE_L, RATE_H);
           OUTSIO (RATE_L);
           OUTSIO (RATE_H);        (* High Speed *)

           INTBYTE (M.RAMPCNT, COUNT_L, COUNT_H);
           OUTSIO (COUNT_L);
           OUTSIO (COUNT_H);       (* Ramp Count *)

           INTBYTE (M.RAMPK, COUNT_L, COUNT_H);
           OUTSIO (COUNT_L);
           OUTSIO (COUNT_H);       (* Ramping Constant *)
           END;


   IF M.DIR = FWD
      THEN OUTCMD ('F')       (* Forward direction *)
      ELSE OUTCMD ('R');      (* Reverse direction *)

END;

(* INITX pre-initializes an MCPU motor for either constant speed
(* or ramped acceleration/deceleration operation. *)
(* For use in nested MCPU 'Initialize' command block sequences. *)

PROCEDURE INITX { (VAR M : MOTOR_TABLE) };

VAR MN : CHAR;
    COUNT_L : CHAR;
    COUNT_H : CHAR;
    RATE_L : CHAR;
    RATE_H : CHAR;

BEGIN

   OUTCMD ('I');             (* Initialize... *)

   OUTCMD ('M');             (* Motor # *)
   MN := CHR (M.MOTORNO);
   OUTSIO (MN);

   IF NOT M.ACCELST

      THEN BEGIN
           OUTCMD ('V');           (* Velocity *)
           INTBYTE (M.SPEED, RATE_L, RATE_H);
           OUTSIO (RATE_L);
           OUTSIO (RATE_H);
           END

      ELSE BEGIN
           OUTCMD ('A');           (* Acceleration *)
           INTBYTE (M.LOWSPD, RATE_L, RATE_H);
           OUTSIO (RATE_L);
           OUTSIO (RATE_H);        (* Low Speed *)

           INTBYTE (M.HIGHSPD, RATE_L, RATE_H);
           OUTSIO (RATE_L);
           OUTSIO (RATE_H);        (* High Speed *)

           INTBYTE (M.RAMPCNT, COUNT_L, COUNT_H);
           OUTSIO (COUNT_L);
           OUTSIO (COUNT_H);       (* Ramp Count *)

           INTBYTE (M.RAMPK, COUNT_L, COUNT_H);
           OUTSIO (COUNT_L);
           OUTSIO (COUNT_H);       (* Ramping Constant *)
           END;

END;

(* RUNX post-runs a pre-initialized MCPU motor with the minimum stepping
(* information for synchronously activated motor axes. *)
(* For use in nested MCPU 'Drive' command block sequences. *)

PROCEDURE RUNX { (VAR M : MOTOR_TABLE) };

VAR MN : CHAR;
    BYTE_L : CHAR;
    BYTE_H : CHAR;
    BYTE_X : CHAR;

BEGIN

   OUTCMD ('D');        (* 'Drive' *)

   OUTCMD ('M');        (* 'Motor #' *)
   MN := CHR (M.MOTORNO);
   OUTSIO (MN);

   OUTCMD ('N');        (* 'Step Count' *)
   REALBYTE (M.STEPCNT, BYTE_L, BYTE_H, BYTE_X);
   OUTSIO (BYTE_L);
   OUTSIO (BYTE_H);

   OUTCMD ('X');
   OUTSIO (BYTE_X);

   IF M.DIR = FWD       (* 'Fwd/Rev' *)
      THEN OUTCMD ('F')
      ELSE OUTCMD ('R');

END;

(* 'KILL MOTOR' stops the specified motor in mid flight. *)
(* For use in nested MCPU 'Kill' command block sequences. *)

PROCEDURE KILLX { (VAR M : MOTOR_TABLE) };

VAR MN : CHAR;

BEGIN

   OUTCMD ('K');             (* Kill... *)

   OUTCMD ('M');             (* Motor # *)
   MN := CHR (M.MOTORNO);
   OUTSIO (MN);

END;

(* 'ZERO MOTOR' zeroes out an MCPU axis step position. *)
(* For use in nested MCPU 'Zero' command block sequences. *)

PROCEDURE ZEROX { (VAR M : MOTOR_TABLE) };

VAR MN : CHAR;

BEGIN

   OUTCMD ('0');             (* Zero... *)

   OUTCMD ('M');             (* Motor # *)
   MN := CHR (M.MOTORNO);
   OUTSIO (MN);

END;

(* GETX gets the status and position data from the MCPU, ready or not. *)

PROCEDURE GETX { (VAR M : MOTOR_TABLE) };

VAR MN : CHAR;
    COUNT_L : CHAR;
    COUNT_H : CHAR;
    COUNT_X : CHAR;
    COUNT : REAL;
    BYTE : CHAR;
    STAT : CHAR;

BEGIN

   OUTCMD ('?');     (* Inquiry *)

   OUTCMD ('M');     (* Motor # *)
   MN := CHR (M.MOTORNO);
   OUTSIO (MN);

   OUTCMD ('S');     (* get Status byte *)
   INSIO (STAT);

   M.STAT := STAT;
   M.ERROR := (STAT = 'E');           (* Error ? *)

   IF STAT IN ['D','M','S','E']
      THEN BEGIN
           OUTCMD ('L');              (* get Low byte *)
           INSIO (COUNT_L);

           OUTCMD ('H');              (* get High byte *)
           INSIO (COUNT_H);

           OUTCMD ('X');              (* get Extra byte *)
           INSIO (COUNT_X);

           BYTEREAL (COUNT_L, COUNT_H, COUNT_X, COUNT);
           M.COUNT := COUNT;
           END;

END;

(* 'STATUS MOTOR' gets the current status and step count of an MCPU axis. *)
(* For use in nested MCPU 'Status' command block sequences. *)

(* Includes valid status verification loop with MCPU. *)
(* Includes MCPU interrogation breakpoint by user. *)

PROCEDURE STATX { (VAR M : MOTOR_TABLE) };

BEGIN

   GETX (M);

   IF NOT (M.STAT IN ['D','M','S','E'])
      THEN REPEAT
              RESYNC_MCPU;
              GETX (M);
           UNTIL (M.STAT IN ['D','M','S','E']);

END;

(* {$I MCPUM.STD.LIB} *)

(* MCPU Serial Command Sequences for communications between
(* the system's desktop computer and the Motion Control Processor Unit. *)

(* MCPU = DM STD bus motion control system. *)

(* Includes expanded 24-bit step count processing. *)
(* Compatible with original 16-bit step count processing. *)

(* 'DRIVE_MOTOR' drives the step count, step rate, and direction
(* for a specified MCPU motor. *)

PROCEDURE DRIVEM { (VAR M : MOTOR_TABLE)} ;

BEGIN

   READYMCPU;                 (* Ready? *)

   OUTCMD ('W');              (* Wake up... *)

   DRIVEX (M);                (* Drive motor *)

   OUTCMD ('Z');              (* Zzzzz *)

END;

(* 'INITIALIZE_MOTOR' initializes the specified motor for
(* either constant speed or ramping speed operation. *)
(* Subsequent 'RUN_MOTOR' sequences would run the motor
(* at this particular set of speed characteristics. *)

PROCEDURE INITM { (VAR M : MOTOR_TABLE) };

BEGIN

   READYMCPU;                (* Ready? *)

   OUTCMD ('W');             (* Wake up... *)

   INITX (M);                (* Initialize motor *)

   OUTCMD ('Z');             (* Zzzzz *)

END;

(* 'RUN_MOTOR' runs the step count and direction only for an MCPU motor. *)

PROCEDURE RUNM { (VAR M : MOTOR_TABLE) };

BEGIN

   READYMCPU;                (* Ready? *)

   OUTCMD ('W');             (* Wake up... *)

   RUNX (M);                 (* Drive motor *)

   OUTCMD ('Z');             (* Zzzzz *)

END;

(* 'KILL_MOTOR' stops an MCPU motor in mid flight. *)

PROCEDURE KILLM { (VAR M : MOTOR_TABLE) };

BEGIN

   READYMCPU;                (* Ready? *)

   OUTCMD ('W');             (* Wake up *)

   KILLX (M);                (* Kill motor *)

   OUTCMD ('Z');             (* Zzzzz *)

END;

(* 'ZERO_MOTOR' zeroes out the cummulative step count for an MCPU axis. *)

PROCEDURE ZEROM { (VAR M : MOTOR_TABLE) };

BEGIN

   READYMCPU;                (* Ready? *)

   OUTCMD ('W');             (* Wake up *)

   ZEROX (M);                (* Zero... *)

   OUTCMD ('Z');             (* Zzzzz *)

END;

(* 'PULSE_MOTOR' pulses the specified motor 1 single step. *)

PROCEDURE PULSEM { (VAR M : MOTOR_TABLE) };

VAR MN : CHAR;

BEGIN

   READYMCPU;                 (* Ready? *)

   OUTCMD ('W');              (* Wake up... *)

   OUTCMD ('D');              (* Drive... *)

   OUTCMD ('M');              (* Motor # *)
   MN := CHR (M.MOTORNO);
   OUTSIO (MN);

   OUTCMD ('P');              (* Pulse single step *)

   IF M.DIR = FWD
      THEN OUTCMD ('F')       (* Forward *)
      ELSE OUTCMD ('R');      (* Reverse *)

   OUTCMD ('Z');              (* Zzzzz *)

END;

(* HOME_MOTOR homes the specified motor into its limit-switch position. *)
(* Homing occurs at constant speed according to pre-loaded MCPU speeds. *)

PROCEDURE HOMEM { (VAR M : MOTOR_TABLE) };

VAR MN : CHAR;

BEGIN

   READYMCPU;                 (* Ready? *)

   OUTCMD ('W');              (* Wake up... *)

   OUTCMD ('D');              (* Drive... *)

   OUTCMD ('M');              (* Motor # *)
   MN := CHR (M.MOTORNO);
   OUTSIO (MN);

   OUTCMD ('H');              (* Home it home... *)

   IF M.DIR = FWD
      THEN OUTCMD ('F')       (* Forward *)
      ELSE OUTCMD ('R');      (* Reverse *)

   OUTCMD ('Z');              (* Zzzzz... *)

END;

(* NO LIMIT turns off the axis' switch mask for un-interrupted operation.*)

PROCEDURE NOLIMITM { (VAR M : MOTOR_TABLE) };

VAR MN : CHAR;
    SPEED : CHAR;

BEGIN

   READYMCPU;                 (* Ready ? *)

   OUTCMD ('W');              (* Wake Up *)

   OUTCMD ('D');              (* Drive *)

   OUTCMD ('M');              (* Motor # *)
   MN := CHR (M.MOTORNO);
   OUTSIO (MN);

   OUTCMD ('H');              (* Home *)

   OUTCMD ('V');              (* Velocity 0 --> Mask Off *)
   SPEED := CHR (0);
   OUTSIO (SPEED);
   OUTSIO (SPEED);

   OUTCMD ('Z');              (* Zzzzz *)

END;

(* GET_COUNT gets the current step count of an axis from the MCPU. *)

PROCEDURE GETCOUNT { (VAR M : MOTOR_TABLE) };

VAR MN : CHAR;
    COUNT_L : CHAR;
    COUNT_H : CHAR;
    COUNT_X : CHAR;
    COUNT : REAL;

BEGIN

   READYMCPU;                 (* Ready ? *)

   OUTCMD ('W');              (* Wake-up *)

   OUTCMD ('?');              (* Inquiry *)

   OUTCMD ('M');              (* Motor # *)
   MN := CHR (M.MOTORNO);
   OUTSIO (MN);

   OUTCMD ('L');              (* get Low byte *)
   INSIO (COUNT_L);

   OUTCMD ('H');              (* get High byte *)
   INSIO (COUNT_H);

   OUTCMD ('X');              (* get Extra byte *)
   INSIO (COUNT_X);

   OUTCMD ('Z');              (* Zzzzz *)

   BYTEREAL (COUNT_L, COUNT_H, COUNT_X, COUNT);
   M.COUNT := COUNT;

END;

(* GET_STAT gets the current motion status of an MCPU axis. *)

PROCEDURE GETSTAT { (VAR M : MOTOR_TABLE) };

VAR MN : CHAR;
    STAT : CHAR;

BEGIN

   READYMCPU;                 (* Ready ? *)

   OUTCMD ('W');              (* Wake-up *)

   OUTCMD ('?');              (* Inquiry *)

   OUTCMD ('M');              (* Motor # *)
   MN := CHR (M.MOTORNO);
   OUTSIO (MN);

   OUTCMD ('S');              (* get Status byte *)
   INSIO (STAT);

   OUTCMD ('Z');              (* Zzzzz *)

   M.STAT := STAT;
   M.ERROR := (STAT = 'E');   (* Error ? *)

END;

(*****)

(* VECTORM changes a running MCPU motor's vector speed in real-time. *)

PROCEDURE VECTORM { (VAR M : MOTOR_TABLE) };

VAR BYTEL, BYTEH : CHAR;

BEGIN

   READYMCPU;                           (* Ready ? *)

   OUTCMD ('W');                        (* Wake up *)

   OUTCMD ('V');                        (* Vector Motion *)

   OUTCMD ('M');                        (* Motor # *)
   BYTEL := CHR (M.MOTORNO);
   OUTSIO (BYTEL);

   IF M.RAMPK < 0
      THEN OUTCMD ('D')                 (* Deceleration Count *)
      ELSE OUTCMD ('A');                (* Acceleration Count *)
   INTBYTE (M.RAMPCNT, BYTEL, BYTEH);
   OUTSIO (BYTEL);
   OUTSIO (BYTEH);

   OUTCMD ('Z');                        (* Zzzzz *)

END;

(* WHEREM samples a running MCPU motor's step count in real-time. *)

PROCEDURE WHEREM { (VAR M : MOTOR_TABLE) };

VAR BYTEL, BYTEH, BYTEX : CHAR;

BEGIN

   READYMCPU;                           (* Ready ? *)

   OUTCMD ('W');                        (* Wake up *)

   OUTCMD ('V');                        (* Vector Motion *)

   OUTCMD ('M');                        (* Motor # *)
   BYTEL := CHR (M.MOTORNO);
   OUTSIO (BYTEL);

   OUTCMD ('P');                        (* Position report *)

   OUTCMD ('L');                        (* Low byte *)
   INSIO (BYTEL);
   OUTCMD ('H');                        (* High byte *)
   INSIO (BYTEH);
   OUTCMD ('X');                        (* Extra byte *)
   INSIO (BYTEX);

   OUTCMD ('Z');                        (* Zzzzz *)

   BYTEREAL (BYTEL, BYTEH, BYTEX, M.COUNT);

END;

(*****)

PROCEDURE GETCOUNT_Software { (VAR M : MOTOR_TABLE) };

Begin

   GetCount (M);

End;

PROCEDURE GETCOUNT_Hardware { (VAR M : MOTOR_TABLE) };

Begin

   GetCount (M);

End;

(*****)

End.
