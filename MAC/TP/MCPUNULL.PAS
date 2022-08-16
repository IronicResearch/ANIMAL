
(* MCPU null communications interface. *)

Unit MCPU (102);

{$U-}
{$U TurboCrt}

Interface

Uses

    PasInOut,
    PasConsole;

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

(* Reset serial input / output interface. *)

Procedure ResetSIO;
Begin
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
End;

(* Check for Modem Input status. *)

Procedure InSIOst { (Var Status : Boolean) };

Begin

   Status := True;
   
End;

(* Input a 'single' character from the Modem port. *)
(* Get a single character from the Modem input port buffer. *)

Procedure InSIO { (Var Ch : Char) };

Begin

   Ch := 'R';
      
End;

(* OUTPUT COMMAND outputs an ASCII character command to the MCPU. *)
(* Note: OUTCMD passes by value, whereas OUTSIO passes by reference. *)

PROCEDURE OUTCMD { (CH : CHAR) };
BEGIN
END;

(* TIME-OUT MCPU times out the MCPU's response to the serial input port. *)

PROCEDURE TIMEOUT_MCPU { (VAR STATUS : BOOLEAN) };
BEGIN
END;

(* RESET MCPU resets the MCPU with null commands via the serial port. *)

PROCEDURE RESET_MCPU;
BEGIN
END;

(* INITIALIZE MCPU finds out if the MCPU is ready for communications
(* with the host desktop computer. *)

PROCEDURE INIT_MCPU;

BEGIN

   WRITELN ('MCPU Ready...');
   WRITELN;

END;   (* procedure INIT MCPU *)

(* READY MCPU loops until the MCPU is ready for command input. *)

PROCEDURE READYMCPU;
BEGIN
END;

(* SYNC MCPU synchronizes MCPU communications to be ready for a command. *)

PROCEDURE SYNC_MCPU;
BEGIN
END;

(* RE-SYNC MCPU re-syncronizes MCPU communications for an existing command. *)

PROCEDURE RESYNC_MCPU;
BEGIN
END;

(* IDLE MCPU syncronizes MCPU communications into idle. *)

PROCEDURE IDLE_MCPU;
BEGIN
END;

(* NULL MCPU nullifies an existing MCPU command sequence. *)

PROCEDURE NULL_MCPU;
BEGIN
END;

(* OVERHEAR commands the MCPU to not respond again until all axes are over. *)

PROCEDURE OVERHEAR;
BEGIN
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

(* DRIVEX drives an MCPU motor according to a step count, direction, and
(* overiding constant or ramping speed, for immediate operation. *)
(* For use in nested 'Drive' MCPU command block sequences. *)

PROCEDURE DRIVEX { (VAR M : MOTOR_TABLE) };
BEGIN

   If M.Dir = REV
      Then M.Count := M.Count - M.StepCnt
      Else M.Count := M.Count + M.StepCnt;
   
END;

(* INITX pre-initializes an MCPU motor for either constant speed
(* or ramped acceleration/deceleration operation. *)
(* For use in nested MCPU 'Initialize' command block sequences. *)

PROCEDURE INITX { (VAR M : MOTOR_TABLE) };
BEGIN
END;

(* RUNX post-runs a pre-initialized MCPU motor with the minimum stepping
(* information for synchronously activated motor axes. *)
(* For use in nested MCPU 'Drive' command block sequences. *)

PROCEDURE RUNX { (VAR M : MOTOR_TABLE) };
BEGIN

   If M.Dir = REV
      Then M.Count := M.Count - M.StepCnt
      Else M.Count := M.Count + M.StepCnt;

END;

(* 'KILL MOTOR' stops the specified motor in mid flight. *)
(* For use in nested MCPU 'Kill' command block sequences. *)

PROCEDURE KILLX { (VAR M : MOTOR_TABLE) };
BEGIN
END;

(* 'ZERO MOTOR' zeroes out an MCPU axis step position. *)
(* For use in nested MCPU 'Zero' command block sequences. *)

PROCEDURE ZEROX { (VAR M : MOTOR_TABLE) };
BEGIN

   M.Count := 0;

END;

(* GETX gets the status and position data from the MCPU, ready or not. *)

PROCEDURE GETX { (VAR M : MOTOR_TABLE) };
BEGIN
END;

(* 'STATUS MOTOR' gets the current status and step count of an MCPU axis. *)
(* For use in nested MCPU 'Status' command block sequences. *)

PROCEDURE STATX { (VAR M : MOTOR_TABLE) };
BEGIN
END;

(* 'DRIVE_MOTOR' drives the step count, step rate, and direction
(* for a specified MCPU motor. *)

PROCEDURE DRIVEM { (VAR M : MOTOR_TABLE)} ;

BEGIN

   DRIVEX (M);                (* Drive motor *)

END;

(* 'INITIALIZE_MOTOR' initializes the specified motor for
(* either constant speed or ramping speed operation. *)
(* Subsequent 'RUN_MOTOR' sequences would run the motor
(* at this particular set of speed characteristics. *)

PROCEDURE INITM { (VAR M : MOTOR_TABLE) };
BEGIN
END;

(* 'RUN_MOTOR' runs the step count and direction only for an MCPU motor. *)

PROCEDURE RUNM { (VAR M : MOTOR_TABLE) };

BEGIN

   RUNX (M);                 (* Drive motor *)

END;

(* 'KILL_MOTOR' stops an MCPU motor in mid flight. *)

PROCEDURE KILLM { (VAR M : MOTOR_TABLE) };
BEGIN
END;

(* 'ZERO_MOTOR' zeroes out the cummulative step count for an MCPU axis. *)

PROCEDURE ZEROM { (VAR M : MOTOR_TABLE) };

BEGIN

   ZEROX (M);
   
END;

(* 'PULSE_MOTOR' pulses the specified motor 1 single step. *)

PROCEDURE PULSEM { (VAR M : MOTOR_TABLE) };
BEGIN
END;

(* HOME_MOTOR homes the specified motor into its limit-switch position. *)
(* Homing occurs at constant speed according to pre-loaded MCPU speeds. *)

PROCEDURE HOMEM { (VAR M : MOTOR_TABLE) };
BEGIN
END;

(* NO LIMIT turns off the axis' switch mask for un-interrupted operation.*)

PROCEDURE NOLIMITM { (VAR M : MOTOR_TABLE) };
BEGIN
END;

(* GET_COUNT gets the current step count of an axis from the MCPU. *)

PROCEDURE GETCOUNT { (VAR M : MOTOR_TABLE) };
BEGIN
END;

(* GET_STAT gets the current motion status of an MCPU axis. *)

PROCEDURE GETSTAT { (VAR M : MOTOR_TABLE) };
BEGIN
END;

(*****)

(* VECTORM changes a running MCPU motor's vector speed in real-time. *)

PROCEDURE VECTORM { (VAR M : MOTOR_TABLE) };
BEGIN
END;

(* WHEREM samples a running MCPU motor's step count in real-time. *)

PROCEDURE WHEREM { (VAR M : MOTOR_TABLE) };
BEGIN
END;

(*****)

PROCEDURE GETCOUNT_Software { (VAR M : MOTOR_TABLE) };
Begin
End;

PROCEDURE GETCOUNT_Hardware { (VAR M : MOTOR_TABLE) };
Begin
End;

(*****)

End.
