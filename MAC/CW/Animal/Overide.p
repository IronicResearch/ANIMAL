(********* Overide command operations **********)

Unit Overide;

{$I switches.p}

Interface

	uses
		Types, 
		QuickDraw,
		QuickDrawText,
        Windows, 
		Controls,
        Dialogs,
        Events,
        TurboCrt,			(* Turbo Pascal style console extensions *)
        TurboStr,			(* Turbo Pascal style string extensions *)
        GLOBAL,				(* global vars *)
        RezId,				(* resource file IDs *)
        MCPU,				(* MCPU operations *)
        USERIO;				(* user interface routines *)

	procedure Get_Init_Options;
	procedure Get_Run_Options;
	procedure Get_Status_Update;
	procedure Get_Position_Update;
	procedure Get_Move_Options;
	procedure Get_Goto_Options;
	procedure Put_Jog_Keys;
	procedure Get_Limit_Options;
	procedure Get_Zero_Options;

	procedure Do_Init_Motor;
	procedure Do_Run_Motor;
	procedure Do_Kill_Motor;
	procedure Do_Status_Motor;
	procedure Do_Position_Motor;
	procedure Do_Move_Motor;
	procedure Do_Goto_Motor;
	procedure Do_Jog_Motor;
	procedure Do_Limit_Motor;
	procedure Do_Zero_Motor;

Implementation

(********** overide command dialogs **********)

(* Dialog for Initialize Motor *)

	procedure Get_Init_Options;

		const
			IM = 4;                   (* Init Motor item *)
			IL = 6;                   (* Init Low Speed item *)
			IH = 8;                   (* Init High Speed item *)
			IR = 10;                  (* Init Ramp Count item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)

	begin

		The_Dialog := GetNewDialog(InitId, nil, Pointer(-1));

		The_Text := IntToStr(M.MotorNo);
		GetDItem(The_Dialog, IM, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := IntToStr(M.LowSpd);
		GetDItem(The_Dialog, IL, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := IntToStr(M.HighSpd);
		GetDItem(The_Dialog, IH, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, IH, 0, Length(The_Text));
		The_Text := IntToStr(M.RampCnt);
		GetDItem(The_Dialog, IR, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			if The_Type = TextItem then
				begin
					GetIText(The_ItemHdl, The_Text);
					case The_Item of
						IM: 
							M.MotorNo := StrToInt(The_Text);
						IL: 
							M.LowSpd := StrToInt(The_Text);
						IH: 
							M.HighSpd := StrToInt(The_Text);
						IR: 
							M.RampCnt := StrToInt(The_Text);
					end;
				end;
		until The_Type = BtnItem;
		DisposDialog(The_Dialog);

	end;

(* Dialog for Run Motor *)

	procedure Get_Run_Options;

		const
			RM = 4;                   (* Run Motor item *)
			RR = 6;                   (* Run Run item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)

	begin

		The_Dialog := GetNewDialog(RunId, nil, Pointer(-1));

		The_Text := IntToStr(M.MotorNo);
		GetDItem(The_Dialog, RM, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := RealToStr(M.StepCnt, 0);
		GetDItem(The_Dialog, RR, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, RR, 0, Length(The_Text));

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			if The_Type = TextItem then
				begin
					GetIText(The_ItemHdl, The_Text);
					case The_Item of
						RM: 
							M.MotorNo := StrToInt(The_Text);
						RR: 
							M.StepCnt := StrToReal(The_Text);
					end;
				end;
		until The_Type = BtnItem;
		DisposDialog(The_Dialog);

	end;

(* Dialog for Status Update *)
(* Status is sampled from MCPU here. *)

	procedure Get_Status_Update;

		const
			SM = 4;                   (* Status Motor item *)
			SS = 6;                   (* Status Status item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)

	begin

		The_Dialog := GetNewDialog(StatId, nil, Pointer(-1));

		The_Text := IntToStr(M.MotorNo);
		GetDItem(The_Dialog, SM, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, SM, 0, Length(The_Text));
		The_Text := '';
		GetDItem(The_Dialog, SS, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			case The_Type of
				TextItem: 
					begin
						GetIText(The_ItemHdl, The_Text);
						if The_Item = SM then
							M.MotorNo := StrToInt(The_Text);
					end;
				BtnItem: 
					if The_Item = Ok then
						begin
							GetStat(M);
{$IFC THINK_PASCAL}
							The_Text := Concat(M.Stat, '...', Decode_Status(M));
{$ELSEC}
							The_Text := M.Stat + '...' + Decode_Status(M);
{$ENDC}
							GetDItem(The_Dialog, SS, The_Type, The_TextHdl, The_ItemBox);
							SetIText(The_TextHdl, The_Text);
						end;
			end;
		until (The_Type = BtnItem) and (The_Item = Cancel);
		DisposDialog(The_Dialog);

	end;

(* Dialog for Position Update *)
(* Position is sampled from MCPU here. *)

	procedure Get_Position_Update;

		const
			PM = 4;                   (* Position Motor # item *)
			PP = 6;                   (* Position Position item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)

	begin

		The_Dialog := GetNewDialog(PosnId, nil, Pointer(-1));

		The_Text := IntToStr(M.MotorNo);
		GetDItem(The_Dialog, PM, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, PM, 0, Length(The_Text));
		The_Text := '';
		GetDItem(The_Dialog, PP, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			case The_Type of
				TextItem: 
					begin
						GetIText(The_ItemHdl, The_Text);
						if The_Item = PM then
							M.MotorNo := StrToInt(The_Text);
					end;
				BtnItem: 
					if The_Item = Ok then
						begin
							GetCount(M);
							The_Text := RealToStr(M.Count, 0);
							GetDItem(The_Dialog, PP, The_Type, The_TextHdl, The_ItemBox);
							SetIText(The_TextHdl, The_Text);
						end;
			end;
		until (The_Type = BtnItem) and (The_Item = Cancel);
		DisposDialog(The_Dialog);

	end;

(* Dialog for Jogging motor. *)
(* MCPU operations here. *)

	procedure Put_Jog_Keys;

		const
			JM = 4;                   (* Jog Motor item *)
			JI = 5;                   (* Jog Incremental item *)
			JC = 6;                   (* Jog Continuous item *)
			JF = 8;                   (* Jog Forward item *)
			JR = 7;                   (* Jog Reverse item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)
			The_RadHdl: Handle;        (* Radio button item handle *)

			Incremental_Jogging: Boolean;      (* Increment per keystroke *)
			Continual_Running: Boolean;        (* Stop/Go status per keystroke *)
			Quit_Jogging: Boolean;             (* Quit jog dialog status *)

	begin

		Incremental_Jogging := True;
		Continual_Running := False;

		The_Dialog := GetNewDialog(JogId, nil, Pointer(-1));

		The_Text := IntToStr(M.MotorNo);
		GetDItem(The_Dialog, JM, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, JM, 0, Length(The_Text));

		if Incremental_Jogging then
			The_Item := JI
		else
			The_Item := JC;
		GetDItem(The_Dialog, The_Item, The_Type, The_RadHdl, The_ItemBox);
		SetCtlValue(ControlHandle(The_RadHdl), 1);

		DoDefaultButton(The_Dialog);
		Quit_Jogging := False;
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			case The_Type of
				TextItem: 
					begin
						GetIText(The_ItemHdl, The_Text);
						if The_Item = JM then
							M.MotorNo := StrToInt(The_Text);
					end;
				RadItem: 
					begin
						SetCtlValue(ControlHandle(The_RadHdl), 0);
						SetCtlValue(ControlHandle(The_ItemHdl), 1);
						The_RadHdl := The_ItemHdl;
						case The_Item of
							JI: 
								Incremental_Jogging := True;
							JC: 
								Incremental_Jogging := False;
						end;
					end;
				BtnItem: 
					begin
						case The_Item of
							JF: 
								M.Dir := FWD;
							JR: 
								M.Dir := REV;
							OK: 
								Quit_Jogging := False;
							Cancel: 
								Quit_Jogging := True;
						end;
						if not Quit_Jogging then
							if Incremental_Jogging then
								PulseM(M)
							else
								begin
									if Continual_Running then
										KillM(M)
									else
										RunM(M);
									Continual_Running := not Continual_Running;
								end;
					end;
			end;
		until Quit_Jogging;

		KillM(M);
		DisposDialog(The_Dialog);

	end;

(* Dialog for Move Motor Distance by user units. *)

	procedure Get_Move_Options;

		const
			RM = 4;                   (* Run Motor item *)
			RR = 6;                   (* Run Run item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)
			Distance: Real;            (* move distance *)

	begin

		Distance := 0.0;

		The_Dialog := GetNewDialog(MoveId, nil, Pointer(-1));

		The_Text := IntToStr(Index);
		GetDItem(The_Dialog, RM, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := RealToStr(Distance, AA[Index].K.dp);
		GetDItem(The_Dialog, RR, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, RR, 0, Length(The_Text));

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			if The_Type = TextItem then
				begin
					GetIText(The_ItemHdl, The_Text);
					case The_Item of
						RM: 
							if StrToInt(The_Text) in [1..Max_Axes] then
								Index := StrToInt(The_Text);
						RR: 
							Distance := StrToReal(The_Text);
					end;
				end;
		until The_Type = BtnItem;
		DisposDialog(The_Dialog);

		with AA[Index] do
			begin
				if The_Item = Ok then
					M.StepCnt := Distance * K.Kscale
				else
					M.StepCnt := 0;
				PrepM(M);
			end;
	end;

(* Dialog for Goto Motor Position by user units. *)

	procedure Get_Goto_Options;

		const
			RM = 4;                   (* Run Motor item *)
			RR = 6;                   (* Run Run item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)
			Destination: Real;         (* Goto Destination *)

	begin

		with AA[Index] do
			begin
				GetCount(M);
				Destination := M.Count / K.Kscale;
			end;

		The_Dialog := GetNewDialog(GotoId, nil, Pointer(-1));

		The_Text := IntToStr(Index);
		GetDItem(The_Dialog, RM, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := RealToStr(Destination, AA[Index].K.dp);
		GetDItem(The_Dialog, RR, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, RR, 0, Length(The_Text));

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			if The_Type = TextItem then
				begin
					GetIText(The_ItemHdl, The_Text);
					case The_Item of
						RM: 
							if StrToInt(The_Text) in [1..Max_Axes] then
								Index := StrToInt(The_Text);
						RR: 
							Destination := StrToReal(The_Text);
					end;
				end;
		until The_Type = BtnItem;
		DisposDialog(The_Dialog);

		with AA[Index] do
			begin
				GetCount(M);
				if The_Item = OK then
					M.StepCnt := Destination * K.Kscale - M.Count
				else
					M.StepCnt := 0;
				PrepM(M);
			end;
	end;

(* Dialog for Limit Motor *)

	procedure Get_Limit_Options;

		const
			LM = 5;                   (* Limit Motor item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)

	begin

		The_Dialog := GetNewDialog(LimId, nil, Pointer(-1));

		The_Text := IntToStr(Index);
		GetDItem(The_Dialog, LM, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, LM, 0, Length(The_Text));

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			if The_Type = TextItem then
				begin
					GetIText(The_ItemHdl, The_Text);
					case The_Item of
						LM: 
							if StrToInt(The_Text) in [1..Max_Axes] then
								Index := StrToInt(The_Text);
					end;
				end;
		until The_Type = BtnItem;
		DisposDialog(The_Dialog);

	end;

(* Dialog for Zero Motor Position. *)

	procedure Get_Zero_Options;

		const
			ZM = 5;                   (* Zero Motor item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)

	begin

		The_Dialog := GetNewDialog(ZeroId, nil, Pointer(-1));

		The_Text := IntToStr(Index);
		GetDItem(The_Dialog, ZM, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, ZM, 0, Length(The_Text));

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			if The_Type = TextItem then
				begin
					GetIText(The_ItemHdl, The_Text);
					case The_Item of
						ZM: 
							if StrToInt(The_Text) in [1..Max_Axes] then
								Index := StrToInt(The_Text);
					end;
				end;
		until The_Type = BtnItem;
		DisposDialog(The_Dialog);

	end;

(********** overide motion control routines **********)

(* Initialize motor speed. *)

	procedure Do_Init_Motor;

	begin

		DrawStr('Initialize Motor...');
		Get_Init_Options;
		if The_Item = Ok then
			InitM(AA[Index].M);

	end;

(* Run motor. *)

	procedure Do_Run_Motor;

	begin

		DrawStr('Run Motor...');
		Get_Run_Options;
		if The_Item = Ok then
			with AA[Index] do
				begin
					PrepM(M);
					WaitOver;
					RunM(M);
				end;

	end;

(* Kill both motors, running or not. *)

	procedure Do_Kill_Motor;
		var
			I: integer;
	begin

		DrawStr('Kill Motor...');
		for I := 1 to Max_Axes do
			KillM(AA[I].M);
		Drawln;

	end;

(* Get motor running status. *)

	procedure Do_Status_Motor;

	begin

		DrawStr('Status for Motor...');
		Get_Status_Update;

	end;

(* Get motor position. *)

	procedure Do_Position_Motor;

	begin

		DrawStr('Position for Motor...');
		Get_Position_Update;

	end;

(* Move motor by user units. *)

	procedure Do_Move_Motor;

	begin

		DrawStr('Move Motor...');
		Get_Move_Options;
		if The_Item = OK then
			RunM(AA[Index].M);

	end;

(* Goto motor position by user units. *)

	procedure Do_Goto_Motor;

	begin

		DrawStr('Goto Motor Position...');
		Get_Goto_Options;
		if The_Item = OK then
			RunM(AA[Index].M);

	end;

(* Jog motor using keyboard arrow keys. *)

	procedure Do_Jog_Motor;

	begin

		DrawStr('Jog Motor...');
		Drawln;
		Put_Jog_Keys;

	end;

(* Run motor into limit switch position. *)

	procedure Do_Limit_Motor;

	begin

		DrawStr('Limit Switch Run Motor...');
		Get_Limit_Options;
		if The_Item = Ok then
			HomeM(AA[Index].M);

	end;

(* Zero motor stepping position. *)

	procedure Do_Zero_Motor;

	begin

		DrawStr('Zero Motor Position...');
		Get_Zero_Options;
		if The_Item = OK then
			ZeroM(AA[Index].M);

	end;

End.

