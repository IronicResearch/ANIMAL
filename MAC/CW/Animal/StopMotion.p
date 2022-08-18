(* Stop-motion movement routines. *)

Unit StopMotion;

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
        SEQIO,				(* sequencer operations  *)
        USERIO;				(* user interface routines *)

	procedure Edit_Preset_Counts;
	procedure Get_Axis_Increments (var P: Parameter_Table);
	procedure Get_StopMotion_Options;
	procedure Do_Stop_Motion;
	procedure Do_Go_Motion;
	procedure Do_Continuous_Motion;

Implementation

(* Edit preset Frame Count. *)

	procedure Edit_Preset_Counts;

		const
			FS = 3;                   (* Frame string item *)
			FX = 4;                   (* Frame Count item *)
			TS = 5;                   (* Time string item *)
			TX = 6;                   (* Time Frame item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)
			The_CtrlHdl: Handle;       (* control button handle *)
			Screen_Time: Real;         (* frame count screen time *)

	begin

		The_Dialog := GetNewDialog(PFrmId, nil, Pointer(-1));

		The_Text := IntToStr(Preset_Count);
		GetDItem(The_Dialog, FX, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelIText(The_Dialog, FX, 0, Length(The_Text));
		Screen_Time := Preset_count / 24.0;
		The_Text := RealToStr(Screen_Time, 2);
		GetDItem(The_Dialog, TX, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			if The_Type = TextItem then
				begin
					GetIText(The_ItemHdl, The_Text);
					case The_Item of
						FX: 
							begin
								Preset_Count := StrToInt(The_Text);
								Screen_Time := Preset_Count / 24.0;
							end;
						TX: 
							begin
								Screen_Time := StrToReal(The_Text);
								Preset_Count := Round(Screen_Time * 24.0);
							end;
					end;
				end;
		until (The_Type = BtnItem);

		DisposDialog(The_Dialog);

		if (Preset_Count > Max_Points) then
			Preset_Count := Max_Points;

	end;

(* Dialog for Axis Position Cues. *)

	procedure Get_Axis_Increments (var P: Parameter_Table);

		const
			SF = 4;                   (* Start Frame item *)
			EF = 6;                   (* End Frame item *)
			SP = 8;                   (* Start Position *)
			EP = 10;                  (* End Position *)
			ST = 12;                  (* Start Taper In *)
			ET = 14;                  (* End Taper Out *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)

	begin

		The_Dialog := GetNewDialog(AxisId, nil, Pointer(-1));

		The_Text := IntToStr(P.StartFrame);
		GetDItem(The_Dialog, SF, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := IntToStr(P.EndFrame);
		GetDItem(The_Dialog, EF, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := RealToStr(P.StartPoint, 3);
		GetDItem(The_Dialog, SP, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, SP, 0, Length(The_Text));
		The_Text := RealToStr(P.EndPoint, 3);
		GetDItem(The_Dialog, EP, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := RealToStr(P.Accel, 1);
		GetDItem(The_Dialog, ST, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := RealToStr(P.Decel, 1);
		GetDItem(The_Dialog, ET, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			if The_Type = TextItem then
				begin
					GetIText(The_ItemHdl, The_Text);
					case The_Item of
						SF: 
							P.StartFrame := StrToInt(The_Text);
						EF: 
							P.EndFrame := StrToInt(The_Text);
						SP: 
							P.StartPoint := StrToReal(The_Text);
						EP: 
							P.EndPoint := StrToReal(The_Text);
						ST: 
							P.Accel := StrToReal(The_Text);
						ET: 
							P.Decel := StrToReal(The_Text);
					end;
					if P.EndFrame > Preset_Count then
						Preset_Count := P.EndFrame;
					P.Taper := (P.Accel + P.Decel > 0.0);
				end;
		until (The_Type = BtnItem);

		DisposDialog(The_Dialog);

	end;

(* Dialog for Stop Motion run-time options. *)

	procedure Get_StopMotion_Options;

		const
			B1 = 1;                   (* Ok button item *)
			B2 = 2;                   (* Cancel button item *)
			SS = 4;                   (* Start Frame item *)
			SE = 6;                   (* End Frame item *)
			RX = 7;                   (* Exposures On radio item *)
			RN = 8;                   (* Exposures Off radio item *)
			RF = 9;                   (* Forward Run radio item *)
			RR = 10;                  (* Reverse Run radio item *)
			RM = 11;                  (* Manual Run  radio item *)
			RA = 12;                  (* Automatic Run radio item *)

		var
			item: integer;
			The_RadHdl: Handle;        (* radio button item handle *)
			The_TextHdl: Handle;       (* text item handle *)
			The_Text: Str255;          (* text string *)
			Start_Run: Integer;        (* start run frame *)
			End_Run: Integer;          (* end run frame *)
			RHA: array[RX..RA] of Handle;      (* array of radio button handles *)

	begin

		The_Dialog := GetNewDialog(StopId, nil, Pointer(-1));

		Start_Run := 0;
		End_Run := Preset_Count;

		The_Text := '0';
		GetDItem(The_Dialog, SS, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := IntToStr(Preset_Count);
		GetDItem(The_Dialog, SE, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, SE, 0, Length(The_Text));

		for item := RX to RA do
			begin
				GetDItem(The_Dialog, item, The_Type, The_RadHdl, The_ItemBox);
				RHA[item] := The_RadHdl;
			end;
		if Exposured then
			SetCtlValue(ControlHandle(RHA[RX]), 1)
		else
			SetCtlValue(ControlHandle(RHA[RN]), 1);
		if not Reversed then
			SetCtlValue(ControlHandle(RHA[RF]), 1)
		else
			SetCtlValue(ControlHandle(RHA[RR]), 1);
		if SingleFramed then
			SetCtlValue(ControlHandle(RHA[RM]), 1)
		else
			SetCtlValue(ControlHandle(RHA[RA]), 1);

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			case The_Type of
				TextItem: 
					begin
						GetIText(The_ItemHdl, The_Text);
						case The_Item of
							SS: 
								Start_Run := StrToInt(The_Text);
							SE: 
								End_Run := StrToInt(The_Text);
						end;
					end;
				RadItem: 
					begin
						The_RadHdl := The_ItemHdl;
						SetCtlValue(ControlHandle(The_RadHdl), 1);
						case The_Item of
							RX: 
								Exposured := True;
							RN: 
								Exposured := False;
							RF: 
								Reversed := False;
							RR: 
								Reversed := True;
							RM: 
								SingleFramed := True;
							RA: 
								SingleFramed := False;
						end;
						case The_Item of
							RX: 
								SetCtlValue(ControlHandle(RHA[RN]), 0);
							RN: 
								SetCtlValue(ControlHandle(RHA[RX]), 0);
							RF: 
								SetCtlValue(ControlHandle(RHA[RR]), 0);
							RR: 
								SetCtlValue(ControlHandle(RHA[RF]), 0);
							RM: 
								SetCtlValue(ControlHandle(RHA[RA]), 0);
							RA: 
								SetCtlValue(ControlHandle(RHA[RM]), 0);
						end;
					end;
				BtnItem: 
					case The_Item of
						B1: 
							Frame_Count := End_Run - Start_Run;
						B2: 
							Frame_Count := 0;
					end;
			end;
		until The_Type = BtnItem;
		DisposDialog(The_Dialog);

	end;

(* Run Stop Motion sequence. *)

	procedure Do_Stop_Motion;

		var
			F: Integer;
			Increment: Real;
			Position: Real;
			Ch: Char;
	begin

		DrawStr('Run Stop Motion sequence...');
		Drawln;
		Get_StopMotion_Options;

		if The_Item = Ok then
			begin
				Pre_Run_Camera(1);
				Pre_Run_Projector(1);
				Index := 2;
				Position := AA[Index].Q[0];
				Projector_Total := Round(Position);
				Get_Frame_Counts;
				GetDItem(The_Dialog, 5, The_Type, The_TextHdl, The_ItemBox);
				SetIText(The_TextHdl, 'Step Count');

				for F := 1 to Preset_Count do
					begin
						if KeyPressed or Button then
							Put_Frame_Counts;
						if not (The_Item = Cancel) then
							begin
								if Exposured then
									begin
										Run_Camera(1);
										WaitOver;
										Camera_Total := Camera_Total + 1;
										Put_Frame_Counts;
										WaitOver;
									end;
								with AA[Index] do
									begin
										Increment := Q[F] - Q[F - 1];
										M.StepCnt := K.Kscale * Increment;
										M.StepCnt := Abs(M.StepCnt);
										if M.StepCnt < 8.0 then
											M.StepCnt := 8.0;
										DriveM(M);
										WaitOver;
										RunM(M);
										WaitOver;
										Position := Position + Increment;
										{$IFC DEBUG_CONSOLE}
										Writeln(F : 10, Increment : 10 : K.dp, Position : 10 : K.dp);
										{$ENDC}
										Projector_Total := Round(Position);
										Put_Frame_Counts;
										WaitOver;
										if SingleFramed then
											begin
												repeat
												until KeyPressed or Button;
												if KeyPressed then
													Ch := ReadKey;
												if Button then
													repeat
														TpDelay(15);
													until not Button;
											end;
									end;
							end;
					end;
				Trash_Frame_Counts;
			end;
	end;

(* Run Go Motion sequence. *)

	procedure Do_Go_Motion;

	begin

		Do_Stop_Motion;

	end;

(* Run Continuous Motion sequence. *)

	procedure Do_Continuous_Motion;

	begin

		SingleFramed := False;
		Do_Stop_Motion;

	end;

End.
