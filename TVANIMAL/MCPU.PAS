
(* MCPU communications interface. *)

Unit MCPU;

Interface

{$I MCPU.INC}           (* MCPU switches *)

Uses

   TPCrt,
{$IFDEF MCPU_STDBUS}
   TPMenu,
{$ENDIF}
   Dos,
   KEYBD,
   GLOBAL;

Const

{$IFDEF MCPU_NULL}
   MCPU_Installed : boolean = FALSE;    (* nothing there... *)
{$ELSE}
   MCPU_Installed : boolean = TRUE;     (* if there's a there there... *)
{$ENDIF}

{$IFDEF SIO_COMX}
   MCPU_PortX : integer = 2;            (* for COM2 *)
{$ELSE}
{$IFDEF SIO_COM2}
   MCPU_PortX : integer = 2;            (* for COM2 *)
{$ELSE}
   MCPU_PortX : integer = 1;            (* for COM1 *)
{$ENDIF}
{$ENDIF}

   SIO_Enabled : boolean = true;
   PIO_Enabled : boolean = true;

Var

   SIO_Timeouts : longint;              (* serial timeout counter *)
   PIO_Timeouts : longint;              (* PC bus timeout counter *)
   COM_Timeouts : longint;              (* non-specific timeout counter *)

(* {$I SIO86.LIB} *)

Procedure SetSio (portx : integer);

PROCEDURE RESETSIO;

PROCEDURE INSIOST (VAR STATUS : BOOLEAN);

PROCEDURE INSIO (VAR BYTE : CHAR);

PROCEDURE OUTSIOST (VAR STATUS : BOOLEAN);

PROCEDURE OUTSIO (VAR BYTE : CHAR);

(* {$I COMM.LIB} *)

PROCEDURE OUTCMD (BYTE : CHAR);

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

(* {$I DECODE.EXT} *)

FUNCTION DECODE_STATUS (VAR M : MOTOR_TABLE) : STRING;

FUNCTION DECODE_QUICK (VAR M : MOTOR_TABLE) : STRING;

FUNCTION DECODE_MOTION (VAR M : MOTOR_TABLE) : BOOLEAN;

(* {$I WAITOVER.EXT} *)

PROCEDURE CLEAR_SEQUENCE;

PROCEDURE KILL_SEQUENCE;

PROCEDURE NMIOVER;

PROCEDURE WAITBACK;

PROCEDURE WAITOVER;

PROCEDURE REMOTE_TRIGGER (VAR CMD : CHAR);

(* {$I MCPUX.LIB} *)

PROCEDURE DRIVEX (VAR M : MOTOR_TABLE);

PROCEDURE INITX (VAR M : MOTOR_TABLE);

PROCEDURE RUNX (VAR M : MOTOR_TABLE);

PROCEDURE KILLX (VAR M : MOTOR_TABLE);

PROCEDURE ZEROX (VAR M : MOTOR_TABLE);

PROCEDURE GETSTAT (VAR M : MOTOR_TABLE);

PROCEDURE GETCOUNT_1200 (VAR M : MOTOR_TABLE);

PROCEDURE GETCOUNT_2100 (VAR M : MOTOR_TABLE);

PROCEDURE GETCOUNT (VAR M : MOTOR_TABLE);

PROCEDURE GETX (VAR M : MOTOR_TABLE);

PROCEDURE STATX (VAR M : MOTOR_TABLE);

Procedure Get_Trigger (Var Status : Boolean);

{Procedure TimeOutSio (var TimeStat : boolean);}

{Procedure TimeOutPio (var TimeStat : boolean);}

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

(* {$I MCPUK.LIB} *)

PROCEDURE INITM_ALL;

PROCEDURE RUNM_ALL;

PROCEDURE KILLM_ALL;

PROCEDURE ZEROM_ALL;

PROCEDURE STATM_ALL;

(* {$I INITM.EXT} *)

PROCEDURE INIT_MOTOR (VAR A : AXIS_TABLE);

PROCEDURE INIT_ALL_MOTOR;

PROCEDURE INIT_AXES;

(************)

Implementation

(* Null communications patch for PC23 port. *)

{$IFNDEF MCPU_PIO}
Procedure InPioSt_86 (Var Stat : Boolean);
Begin
   Stat := False;
End;

Procedure InPio_86 (Var Ch : Char);
Begin
   Ch := Chr (0);
End;

Procedure InSioSt_86 (Var Stat : Boolean);
Begin
   InSioSt(Stat);
End;

Procedure InSio_86 (Var Ch : Char);
Begin
   InSio(Ch);
End;
{$ENDIF}

{$IFNDEF SIO_COMX}
Procedure SetSio (portx : integer);
Begin
End;
{$ENDIF}

(* pick only one include file for each block below -- DaveM *)

{$IFDEF MCPU_NULL}      (* for null motion control *)

   {$I NOSIO86.LIB}     (* for null communications *)

   {$I MCPUCOMM.LIB}

   {$I MCPUSTAT.EXT}

   {$I MCPUWAIT.EXT}

   {$I NOMCPUX.LIB}     (* for null motion control *)

   {$I NOMCPUM.LIB}     (* for null motion control *)

   {$I MCPUK.LIB}

{$ENDIF}

{$IFDEF MCPU_STDBUS}    (* for STD bus MCPU commands *)

  {$IFDEF SIO_COMX}
   {$I SIOX.LIB}        (* for COMx selectable port *)
  {$ELSE}
  {$IFDEF SIO_COM2}
   {$I SIO86-2.LIB}     (* for COM2 (no handshake) *)
  {$ELSE}
   {$I SIO86.LIB}       (* for COM1 with handshake (STD bus system) *)
  {$ENDIF}
  {$ENDIF}

   {$I MCPUCOMM.STD}

   {$I MCPUSTAT.STD}

   {$I MCPUWAIT.STD}

   {$I MCPUXSTD.LIB}

   {$I MCPUMSTD.LIB}

   {$I MCPUKSTD.LIB}

{$ENDIF}

{$IFDEF MCPU_COMPUMTR}  (* for Compumotor MCPU commands *)

 {$IFDEF MCPU_SIO_PIO}
  {$IFDEF SIO_COMX}
   {$I PIOSIOX.LIB}     (* for COMx Compumotor 2100 + PC23 *)
  {$ELSE}
  {$IFDEF SIO_COM2}
   {$I PIOSIO2.LIB}     (* for COM2 Compumotor 2100 + PC23 *)
  {$ELSE}
   {$I PIOSIO1.LIB}     (* for COM1 Compumotor 2100 + PC23 *)
  {$ENDIF}
  {$ENDIF}
 {$ELSE}
 {$IFDEF MCPU_SIO}
  {$IFDEF SIO_COMX}
   {$I SIOX.LIB}        (* for COMx selectable port *)
  {$ELSE}
  {$IFDEF SIO_COM2}
   {$I SIO86-2.LIB}     (* for COM2 (no handshake) *)
  {$ELSE}
   {$I SIO86-1.LIB}     (* for COM1 (no handshake) *)
  {$ENDIF}
  {$ENDIF}
 {$ELSE}
   {$I PIO86.LIB}       (* for Compumotor PC23 only *)
 {$ENDIF}
 {$ENDIF}

   {$I MCPUCOMM.LIB}

   {$I MCPUSTAT.EXT}

   {$I MCPUWAIT.EXT}

 {$IFDEF COMPUMTR_PC23}

   {$I MCPUX23.LIB}     (* for Compumotor PC23 *)

   {$I MCPUM23.LIB}     (* for Compumotor PC23 *)

   {$I MCPUK23.LIB}     (* for Compumotor PC23 *)

 {$ELSE}

  {$IFDEF COMPUMTR_1200}
   {$I MCPUX12.LIB}     (* for Compumotor 1200 only *)
  {$ELSE}
   {$I MCPUX.LIB}       (* for Compumotor 2100 *)
  {$ENDIF}
   {$I MCPUM.LIB}       (* for Compumotor 2100 *)

   {$I MCPUK.LIB}       (* for Compumotor 2100 *)

 {$ENDIF}

{$ENDIF}

{$I INITM.EXT}

(* Initialization *)

var E : integer;
Begin

   SIO_Timeouts := 0;
   PIO_Timeouts := 0;
   COM_Timeouts := 0;

   (* 1st command line parameter selects MCPU serial port *)
   If (ParamCount >= 1)
      Then Val (ParamStr(1), MCPU_PortX, E);
   If (MCPU_PortX = 0)
      Then MCPU_Installed := FALSE;
   If (MCPU_PortX IN [1,2,3,4])
      Then SetSio (MCPU_PortX);
   If (MCPU_Installed)
      Then ResetSio;

End.
