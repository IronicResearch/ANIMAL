(* Serial Input / Output Interface *)

{$I SIO.INC}                            (* SIO compilation switches *)

Unit SIO;

Interface


{$IFDEF SIO_INTERRUPT}
Uses    TpInt,
        TpCrt;
{$ENDIF}

Procedure SetSio (Portx : integer);
Procedure ResetSio;
Procedure InSioSt (Var Status : boolean);
Procedure InSio (Var Byte : char);
Procedure OutSioSt (Var Status : boolean);
Procedure OutSio (Var Byte : char);

(************)

Implementation

{$IFDEF SIO_DEBUG}
Uses    TpCrt;
{$ENDIF}

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

        OUT1=$04;                       (* general output 1 *)
        OUT2=$08;                       (* general output 2 = board IRQ enable *)
        LOOP=$10;                       (* loopback output to input *)

        RXEN=$01;                       (* receiver data interrupt enable *)
        IRQN=OUT2;                      (* board IRQ enable *)

        FIFO=$C0;                       (* FIFO status *)
        FFEN=$01;                       (* FIFO enable *)

Const
        COMX : integer = COM2;		(* whichever base address *)
        COMDATA : integer = COM2+0;	(* serial data port *)
        COMCTRL : integer = COM2+3;	(* serial control port *)
        COMSTAT : integer = COM2+5;	(* serial status port *)
        COMIER	: integer = COM2+1;	(* interrupt enable register *)
        COMIIR	: integer = COM2+2;	(* interrupt ID register *)
        COMMCR	: integer = COM2+4;	(* modem control register *)
        COMMSR	: integer = COM2+6;	(* modem status register *)

Var
        IRQEnabled : boolean;           (* IRQ enabled ? *)
        IRQDetected : boolean;          (* IRQ detected ? *)
        FIFOEnabled : boolean;          (* FIFO enabled ? *)

{$IFDEF SIO_INTERRUPT}
Const
        IRQ : integer = 3;              (* IRQx interrupt request *)

        TPINT3 = 16;                    (* TPINT ISR handle for IRQ3 *)
        TPINT4 = 17;                    (* TPINT ISR handle for IRQ4 *)
        TPINT0 = 18;                    (* TPINT ISR handle for IRQ0 *)
Var
        iIntr : integer;                (* buffer index for interrupt routine *)
        iRead : integer;                (* buffer index for read routine *)
        SioInBuf : array [0..255] of char; (* serial input buffer *)

(* {$F+} *)
(* Interrupt handler for IRQ3. *)
Procedure IntIrq3(BP : Word); interrupt;
var
   Regs : IntRegisters absolute BP;
begin
   if ((port[COMSTAT] AND RXD) = RXD)           (* received byte ? *)
      then begin
      repeat
      SioInBuf[iIntr] := char(port[COMDATA]);   (* input into buffer *)
      iIntr := iIntr+1;                         (* update buffer index *)
      if (iIntr > 255)                          (* account for wrap-around *)
         then iIntr := 0;
      until ((port[COMSTAT] AND RXD) <> RXD);   (* no more received bytes ? *)
      SendEOI;                                  (* clear IRQ *)
      end
   else
   ChainInt(Regs, ISR_Array[TPINT3].OrigAddr);  (* call original ISR *)
end;

(* Interrupt handler for IRQ4 (identical to IRQ3). *)
Procedure IntIrq4(BP : Word); interrupt;
var
   Regs : IntRegisters absolute BP;
begin
   if ((port[COMSTAT] AND RXD) = RXD)           (* received byte ? *)
      then begin
      repeat
      SioInBuf[iIntr] := char(port[COMDATA]);   (* input into buffer *)
      iIntr := iIntr+1;                         (* update buffer index *)
      if (iIntr > 255)                          (* account for wrap-around *)
         then iIntr := 0;
      until ((port[COMSTAT] AND RXD) <> RXD);   (* no more received bytes ? *)
      SendEOI;                                  (* clear IRQ *)
      end
   else
   ChainInt(Regs, ISR_Array[TPINT4].OrigAddr);  (* call original ISR *)
end;

(* Interrupt handler for IRQ0 (almost identical to IRQ3). *)
Procedure IntIrq0(BP : Word); interrupt;
var
   Regs : IntRegisters absolute BP;
begin
   if ((port[COMSTAT] AND RXD) = RXD)           (* received byte ? *)
      then begin
      repeat
      SioInBuf[iIntr] := char(port[COMDATA]);   (* input into buffer *)
      iIntr := iIntr+1;                         (* update buffer index *)
      if (iIntr > 255)                          (* account for wrap-around *)
         then iIntr := 0;
      until ((port[COMSTAT] AND RXD) <> RXD);   (* no more received bytes ? *)
      SendEOI;                                  (* clear IRQ *)
      end;
   (* Timer interrupt always must be handled to update clock *)
   ChainInt(Regs, ISR_Array[TPINT0].OrigAddr);  (* call original ISR *)
end;
{$ENDIF}

(* Select serial port by base address. *)

Procedure SetSio (portx : integer);
Begin
        (* Assign base port address *)
        Case portx of
        1 : COMX := COM1;
        2 : COMX := COM2;
        3 : COMX := COM3;
        4 : COMX := COM4;
        (* else COMX := COM1;      (* base address *)
        end;

        (* Re-Assign UART register addresses *)
        COMDATA := COMX+0;	(* serial data port *)
        COMCTRL := COMX+3;	(* serial control port *)
        COMSTAT := COMX+5;	(* serial status port *)
        COMIER	:= COMX+1;	(* interrupt enable register *)
        COMIIR	:= COMX+2;	(* interrupt ID register *)
        COMMCR	:= COMX+4;	(* modem control register *)
        COMMSR	:= COMX+6;	(* modem status register *)

{$IFDEF SIO_INTERRUPT}
        (* Assign default IRQ *)
        Case (COMX) of
        COM1: IRQ := 4;
        COM2: IRQ := 3;
        COM3: IRQ := 4;
        COM4: IRQ := 3;
        end;
{$ENDIF}
End;

(* Reset serial port for baud rate and serial format. *)

Procedure ResetSio;
Var IRQMask : byte;
    B : byte;
    C : char;
    R : boolean;
Begin
{$IFDEF SIO_INTERRUPT}
        (* Init input buffer indexes for both interrupt and read routines *)
        iIntr := 0;
        iRead := 0;

        (* TODO: Need foolproof scheme to auto-detect and confirm IRQ lines *)

        (* Init interrupt handlers using TPINT *)
        case (IRQ) of
        3: R := InitVector($0B, TPINT3, @IntIrq3);   (* IRQ3 uses INT 0B hex *)
        4: R := InitVector($0C, TPINT4, @IntIrq4);   (* IRQ4 uses INT 0C hex *)
        0: R := InitVector($08, TPINT0, @IntIrq0);   (* IRQ0 uses INT 08 hex *)
        end;
{$ENDIF}

        (* Init 8250 UART for 9600 baud, 8 data bits, 1 stop bit, no parity *)
	port[COMCTRL] :=  BAUD_81N;		(* set serial format *)
	port[COMIER] :=  0;			(* no interrupts *)
	port[COMCTRL] :=  DLAB OR BAUD_81N;     (* access clock divisor *)
	port[COMDATA] :=  BAUD9600;		(* set clock low byte *)
	port[COMDATA+1] :=  0;			(* set clock high byte *)
	port[COMCTRL] :=  BAUD_81N;		(* set serial format *)
	port[COMMCR] :=  RTS OR DTR;		(* handshake DTR + RTS ready *)
	port[COMIER] :=  0;			(* no interrupts *)

        (* Enable 16550 UART FIFOs, if detected *)
        port[COMIIR] := FFEN;
        B := port[COMIIR];
        FIFOEnabled := ((B and FIFO) = FIFO);

{$IFDEF SIO_INTERRUPT}
        InterruptsOff;
        (* Unmask IRQ bus line in main PIC *)
        IRQMask := port[$21];
        case (IRQ) of
        3: IRQMask := IRQMask and $F7;          (* unmask IRQ3 = $08 *)
        4: IRQMask := IRQMask and $EF;          (* unmask IRQ4 = $10 *)
        0: IRQMask := IRQMask and $FE;          (* unmask IRQ0 = $01 *)
        end;
        port[$21] := IRQMask;
        IRQMask := port[$21];
        (* Clear all status and input ports *)
        B := port[COMMSR];
        B := port[COMSTAT];
        B := port[COMDATA];
        (* Enable serial interrupts *)
	port[COMIER] :=  RXEN;			(* receiver interrupts *)
	port[COMMCR] :=  RTS or DTR or IRQN;    (* enable board IRQ *)
        InterruptsOn;
        (* TODO: Confirm that interrupts are actually working *)
        IRQEnabled := true;
        IRQDetected := true;
{$IFDEF SIO_LOOPBACK_TEST}
        (* Test if byte gets received by ISR in loopback mode *)
        port[COMMCR] :=  RTS or DTR or IRQN or LOOP;   (* enable loopback *)
        C := '!';
        OutSio(C);                              (* output byte *)
        Delay(10);                              (* wait for loopback *)
        port[COMMCR] :=  RTS or DTR or IRQN;    (* disable loopback *)
        IRQDetected := (iIntr > iRead);         (* ISR buffer advance ? *)
        iRead := iIntr;
        (* Note: Apparently the interrupt won't be handled until after
        (* ResetSio returns, so check again in 1st InSioSt call... *)
{$ENDIF}
{$ENDIF}
End;

(* Get serial input status. *)

Procedure InSioSt (Var Status : boolean);
Begin
{$IFDEF SIO_INTERRUPT}
{$IFDEF SIO_LOOPBACK_TEST}
        (* Check if loopback test worked in ISR afterall *)
        if ((not IRQDetected) and (iIntr > iRead) and (SioInBuf[0] = '!'))
           then begin
                IRQDetected := true;
                iRead := iIntr;
                end;
{$ENDIF}
        (* Let interrupt rountines handle all received bytes *)
        if (IRQEnabled and IRQDetected)
           then Status := (iIntr <> iRead)      (* has interrupt index advanced ? *)
        (* Fallback to polling scheme if interrupts not working *)
           else begin
                Status := ((port[COMSTAT] AND RXD) = RXD);   (* received byte ? *)
                (* Emulate interrupt routine to buffer received bytes *)
                if (Status)
                   then begin
                   repeat
                   SioInBuf[iIntr] := char(port[COMDATA]);   (* input into buffer *)
                   Inc(iIntr);                               (* update buffer index *)
                   if (iIntr > 255)                          (* account for wrap-around *)
                      then iIntr := 0;
                   until ((port[COMSTAT] AND RXD) <> RXD);   (* no more received bytes ? *)
                   end;
                (* Emulate input status for receiver buffer filling up *)
                Status := Status or (iIntr <> iRead);        (* buffer status *)
                end;
{$ELSE}
	Status := ((port[COMSTAT] AND RXD) = RXD);
{$ENDIF}
End;

(* Input serial byte. *)

Procedure InSio (Var Byte : char);
Var Status : boolean;
Begin
{$IFDEF SIO_INTERRUPT}
        repeat
           InSioSt(Status);
        until (Status);                 (* wait for new interrupt input *)
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
        write(Byte);
{$ENDIF}
End;

(* Initialization *)

Begin

End.





