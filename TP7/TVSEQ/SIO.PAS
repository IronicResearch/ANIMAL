(* Serial Input / Output Interface *)

{$DEFINE SIO_DEBUG}                     (* for debug output *)
{$UNDEF  SIO_DEBUG}

{$DEFINE SIO_INTERRUPT}                 (* for interrupt-driven input *)
{$UNDEF  SIO_INTERRUPT}

Unit SIO;

Interface


{$IFDEF SIO_INTERRUPT}
Uses
{$IFDEF SIO_DEBUG}
        TpCrt,
{$ENDIF}
        TpInt;
{$ELSE}
{$IFDEF SIO_DEBUG}
Uses    TpCrt;
{$ENDIF}
{$ENDIF}

Procedure SetSio (Portx : integer);
Procedure ResetSio;
Procedure InSioSt (Var Status : boolean);
Procedure InSio (Var Byte : char);
Procedure OutSioSt (Var Status : boolean);
Procedure OutSio (Var Byte : char);

(************)

Implementation

(* {$I SIOX.LIB} *)
(* Serial IO routines, for selectable COM port. *)

Const
        COM1 =$03F8;                    (* COM1: base address *)
        COM2 =$02F8;			(* COM2: base address *)
        COM3 =$03E8;			(* COM3: base address *)
        COM4 =$02E8;			(* COM4: base address *)

        RXD =$01;			(* receiver data ready *)
        TXD =$20;			(* transmitter data ready *)
        DTR =$01;			(* data terminal ready *)
        RTS =$02;			(* request to send *)
        DLAB=$80;			(* divisor latch access bit *)
        BAUD9600=12;			(* divisor value for 9600 baud *)
        BAUD_81N=$03;			(* format for 8 data, 1 stop, no parity *)

Const
        COMX : integer = COM1;		(* whichever base address *)
        COMDATA : integer = COM1+0;	(* serial data port *)
        COMCTRL : integer = COM1+3;	(* serial control port *)
        COMSTAT : integer = COM1+5;	(* serial status port *)
        COMIER	: integer = COM1+1;	(* interrupt enable register *)
        COMMCR	: integer = COM1+4;	(* modem control register *)

{$IFDEF SIO_INTERRUPT}
Const
        TPINT3 = MaxISRs;               (* TPINT ISR handle for IRQ3 *)
        TPINT4 = MaxISRs-1;             (* TPINT ISR handle for IRQ4 *)
Var
        iIntr : integer;                (* buffer index for interrupt routine *)
        iRead : integer;                (* buffer index for read routine *)
        SioInBuf : array [0..255] of char; (* serial input buffer *)

(* Interrupt handler for IRQ3. *)
Procedure IntIrq3(BP : Word); interrupt;
var
   Regs : IntRegisters absolute BP;
begin
   if ((port[COMSTAT] AND RXD) = RXD)   (* received byte ? *)
      then begin
      SioInBuf[iIntr] := char(port[COMDATA]);   (* input into buffer *)
      iIntr := iIntr+1;                         (* update buffer index *)
      if (iIntr > 255)                          (* account for wrap-around *)
         then iIntr := 0;
      SendEOI;                                  (* clear IRQ *)
      end;
   ChainInt(Regs, ISR_Array[TPINT3].OrigAddr);  (* call original ISR *)
end;

(* Interrupt handler for IRQ4 (indentical to IRQ3). *)
Procedure IntIrq4(BP : Word); interrupt;
var
   Regs : IntRegisters absolute BP;
begin
   if ((port[COMSTAT] AND RXD) = RXD)   (* received byte ? *)
      then begin
      SioInBuf[iIntr] := char(port[COMDATA]);   (* input into buffer *)
      iIntr := iIntr+1;                         (* update buffer index *)
      if (iIntr > 255)                          (* account for wrap-around *)
         then iIntr := 0;
      SendEOI;                                  (* clear IRQ *)
      end;
   ChainInt(Regs, ISR_Array[TPINT4].OrigAddr);  (* call original ISR *)
end;
{$ENDIF}

(* Select serial port by base address. *)

Procedure SetSio (portx : integer);
Begin
        Case portx of
        1 : COMX := COM1;
        2 : COMX := COM2;
        3 : COMX := COM3;
        4 : COMX := COM4;
        else COMX := COM1;      (* base address *)
        end;

        COMDATA := COMX+0;	(* serial data port *)
        COMCTRL := COMX+3;	(* serial control port *)
        COMSTAT := COMX+5;	(* serial status port *)
        COMIER	:= COMX+1;	(* interrupt enable register *)
        COMMCR	:= COMX+4;	(* modem control register *)
End;

(* Reset serial port for baud rate and serial format. *)

Procedure ResetSio;
Begin
{$IFDEF SIO_INTERRUPT}
        (* init input buffer indexes for both interrupt and read routines *)
        iIntr := 0;
        iRead := 0;
        (* init interrupt handlers using TPINT *)
        InitVector($0B, TPINT3, @IntIrq3);      (* IRQ3 uses INT 0B hex *)
        InitVector($0C, TPINT4, @IntIrq4);      (* IRQ4 uses INT 0C hex *)
{$ENDIF}
        (* init 8250 UART for 9600 baud, 8 data bits, 1 stop bit, no parity *)
	port[COMCTRL] :=  DLAB OR BAUD_81N;     (* access clock divisor *)
	port[COMDATA] :=  BAUD9600;		(* set clock low byte *)
	port[COMDATA+1] :=  0;			(* set clock high byte *)
	port[COMCTRL] :=  BAUD_81N;		(* set serial format *)
{$IFDEF SIO_INTERRUPT}
	port[COMIER] :=  $01;			(* receiver interrupts *)
{$ELSE}
	port[COMIER] :=  0;			(* no interrupts *)
{$ENDIF}
	port[COMMCR] :=  RTS OR DTR;		(* handshake DTR + RTS ready *)
End;

(* Get serial input status. *)

Procedure InsioSt (Var Status : boolean);
Begin
{$IFDEF SIO_INTERRUPT}
        Status := (iIntr <> iRead);     (* has interrupt index advanced ? *)
{$ELSE}
	Status := ((port[COMSTAT] AND RXD) = RXD);
{$ENDIF}
End;

(* Input serial byte. *)

Procedure InSio (Var Byte : char);
Begin
{$IFDEF SIO_INTERRUPT}
        repeat
        until (iIntr <> iRead);         (* wait for new interrupt input *)
        Byte := SioInBuf[iRead];        (* read it from the input buffer *)
        Inc(iRead);                     (* update read buffer index *)
        if (iRead > 255)                (* account for wrap-around *)
           then iRead := 0;
{$ELSE}
	repeat
	until ((port[COMSTAT] AND RXD) = RXD);
	Byte := char (port[COMDATA]);
{$ENDIF}
{$IFDEF SIO_DEBUG}
        write(Byte);
{$ENDIF}
End;

(* Get serial output status. *)

Procedure OutsioSt (Var Status : boolean);
Begin
        Status := ((port[COMSTAT] AND TXD) = TXD);
End;

(* Output serial byte. *)

Procedure OutSio (Var Byte : char);
Begin
	repeat
	until ((port[COMSTAT] AND TXD) = TXD);
	port[COMDATA] := integer (Byte);
{$IFDEF SIO_DEBUG}
        delay(0);
        write(Byte);
{$ENDIF}
End;

(* Initialization *)

Begin

End.





