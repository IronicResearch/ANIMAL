(* Serial communications interface. *)

(* Adapted for CodeWarrior Pascal. *)
(* Compatible for SIO library routines for PC Turbo Pascal. *)

Unit SIO;

Interface

Uses
	Types,
	Memory,			(* NewPtr, DisposePtr *)
	Devices,		(* OpenDriver, CloseDriver *)
	Files,			(* FSRead, FSWrite *)
	Serial;			(* SerReset *)

procedure SIO_Init;
procedure SIO_Exit;

PROCEDURE RESETSIO;
PROCEDURE INSIOST (VAR STATUS : BOOLEAN);
PROCEDURE INSIO (VAR CH : CHAR);
PROCEDURE OUTSIOST (VAR STATUS : BOOLEAN);
PROCEDURE OUTSIO (VAR CH : CHAR);

Implementation

	const
		Modem_Port_Input = -6;
		Modem_Port_Output = -7;
		Modem_Port_Name_In = '.AIn';
		Modem_Port_Name_Out = '.AOut';

	var
		OS_Result: OSErr;
		Device_Ref_In: Integer;
		Device_Ref_Out: Integer;
		Num_Bytes: LongInt;
		Buf_Pntr: Ptr;

(* Init routine SIO unit. *)
(* Open the serial port device drivers here. *)
	procedure SIO_Init;
	begin
		Buf_Pntr := NewPtr(SizeOf(char));
		OS_Result := OpenDriver(Modem_Port_Name_Out, Device_Ref_Out);
		OS_Result := OpenDriver(Modem_Port_Name_In, Device_Ref_In);
		(* if OS_Result <> 0 then error *)
	end;
	
(* Exit routine for SIO unit. *)
(* Close the Modem device drivers. *)
	procedure SIO_Exit;
	begin
		OS_Result := KillIO(Device_Ref_Out);
		OS_Result := CloseDriver(Device_Ref_In);
		OS_Result := CloseDriver(Device_Ref_Out);
		DisposePtr(Buf_Pntr);
	end;

(* Reset the serial port for 9600 baud communication. *)
(* OpenDriver routine moved to SIO_Init for better modularity. *)
(* ResetSio checks for open driver, in case of older apps unaware of SIO_Init/Exit. *)
	PROCEDURE RESETSIO;
	var
		Reset_Code: Integer;
		Handshake_Flags: SerShk;
		received: boolean;
		ch: char;
	begin
		(* insure serial driver is open *)
		if (Device_Ref_Out <> Modem_Port_Output)
			then SIO_Init;
		with Handshake_Flags do
			begin
			fXon := 0;
			fCTS := 0;
			errs := 0;
			evts := 0;
			fInX := 0;
			fDTR := 0;
			end;
		OS_Result := SerHShake(Device_Ref_Out, Handshake_Flags);
		Reset_Code := Baud9600 + Data8 + Stop10 + NoParity;
		OS_Result := SerReset(Device_Ref_Out, Reset_Code);
		(* drain receiver buffer of extraneous chars *)
		repeat
			InSioSt(received);
			if (received)
				then InSio(ch);
		until (not received);
	end;

(* Check for Modem Input status. *)
	PROCEDURE INSIOST (VAR STATUS : BOOLEAN);
	begin
		Num_Bytes := 0;
		OS_Result := SerGetBuf(Device_Ref_In, Num_Bytes);
		(* if OS_Result <> 0 then error *)
		STATUS := (Num_Bytes <> 0);
	end;

(* Input a 'single' character from the Modem port. *)
(* Get a single character from the Modem input port buffer. *)
	PROCEDURE INSIO (VAR CH : CHAR);
	var	Buf_Pending: boolean;
	begin
		CH := char(0);
		InSioSt(Buf_Pending);
		if (Buf_Pending)
			then begin
			Num_Bytes := 1;
			OS_Result := FSRead(Device_Ref_In, Num_Bytes, Buf_Pntr);
			(* if OS_Result <> 0 then error *)
			if (Num_Bytes <> 0) 
			    then CH := char(Buf_Pntr^)
			    else CH := char(0);
			end;
	end;

(* Check for Modem Output status. *)
(* Nothing to do -- for compatibility with PC Turbo Pascal routines. *)
	PROCEDURE OUTSIOST (VAR STATUS : BOOLEAN);
	Begin
		STATUS := TRUE;
	End;

(* Output a single character to the Modem port. *)
(* Character is passed as single byte in buffer. *)
	PROCEDURE OUTSIO (VAR CH : CHAR);
	begin
		Num_Bytes := 1;
		Buf_Pntr^ := SignedByte(CH);
		OS_Result := FSWrite(Device_Ref_Out, Num_Bytes, Buf_Pntr);
		(* if OS_Result <> 0 then error *)
	end;

End.
