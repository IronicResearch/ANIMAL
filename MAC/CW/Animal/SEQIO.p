(* Sequencer processing *)

(* Adapted from Turbo Pascal for PC to CodeWarrior Pascal for Mac. *)
(* Partially restore originally Mac support routines, like TickCount and Button. *)
(* Flow control break not supported -- use break procedure instead. *)

{$I SWITCHES.p}

{$SETC USE_MAC_TOOLBOX = 1}
{$SETC THINGM_INSTALLED = 1}
{$SETC MCPU_INSTALLED = 0}

Unit SEQIO;

Interface

Uses
	TurboCrt,           (* Turbo Pascal style console extensions *)
	TurboStr,			(* Turbo Pascal style string routines *)
	SIO,                (* Serial IO *)
	TIMEX,              (* ThisTime clock *)
	THINGM,             (* ThingM Command IO *)
	MCPU,               (* MCPU Command IO *)
{$IFC USE_MAC_TOOLBOX}
	Types, 
	QuickDraw,
	QuickDrawText,
    Windows, 
	Controls,
    Dialogs,
    Events,
    RezId,				(* resource file IDs *)
    USERIO,				(* dialog window user interface routines *)
{$ELSEC}
	Events,				(* Mac OS Toolbox TickCount, Button *)
	CONIO,              (* console user interface routines *)
{$ENDC}
	GLOBAL;             (* Animal Sequencer variables *)

Const
   SEQIO_Tracered : boolean = TRUE;   (* tracer messages *)

procedure Get_Frame_Counts;
procedure Put_Frame_Counts;
procedure Trash_Frame_Counts;
procedure Edit_Frame_Counts;

procedure Get_Camera_Options;
procedure Get_Projector_Options;
procedure Get_Sequencer_Options;

Procedure Pre_Run_Camera (F : Integer);
Procedure Run_Camera (F : Integer);
Procedure Pre_Run_Projector (F : Integer);
Procedure Run_Projector (F : Integer);

Procedure Do_Frame_Counts;
Procedure Do_Camera;
Procedure Do_Projector;
Procedure Do_Sequencer;

Implementation


{$IFC USE_MAC_TOOLBOX}

(* Mac Turbo Pascal System support routines: *)
(* (equivalent to graphics window routines called by Mac Toolbox.) *)

Const
	Ok = 1;				(* OK button reply *)
	Cancel = 2;			(* Cancel button reply *)
	
Var
	The_Item : integer;	(* dialog item reply *)
	
(* Draw text string (for Mac graphics console). *)
Procedure DrawStr (S : string);
Begin
   if (SEQIO_Tracered)
      then Write(S);
End;

(* Draw End-of-Line character (for Mac graphics console). *)
Procedure DrawLn;
Begin
   if (SEQIO_Tracered)
      then Writeln;
End;

{$ENDC}		(* USE_MAC_TOOLBOX *)

(* If Pascal extension 'break' is not supported, then replace with this procedure. *)
procedure break;
begin
	The_Item := Cancel;
end;

(* Approximate camera delay time. *)
Function CAMERA_DELAY_TIME : real;
Begin
	CAMERA_DELAY_TIME := 0.25;
End;

{$IFC USE_MAC_TOOLBOX}

(********** Frame Counters display routines **********)
(* (cut-n-pasted from Macintosh Sequencer23.PAS) *)

(* Window for running Frame Counts. *)
(* Poll Status and Position updates from MCPU here. *)

(* Open dialog window with initial labels and counter data. *)

	procedure Get_Frame_Counts;

		const
			CS = 3;                   (* Camera string item *)
			CT = 4;                   (* Camera Total item *)
			PS = 5;                   (* Projector string item *)
			PT = 6;                   (* Projector Total item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)

	begin

		The_Dialog := GetNewDialog(FrmId, nil, Pointer(-1));

		The_Text := 'Camera Frame';
		GetDItem(The_Dialog, CS, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := IntToStr(Camera_Total);
		GetDItem(The_Dialog, CT, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := 'Projector Frame';
		GetDItem(The_Dialog, PS, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := IntToStr(Projector_Total);
		GetDItem(The_Dialog, PT, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);

		DoDefaultButton(The_Dialog);
		ShowWindow(WindowPtr(The_Dialog));

	end;

(* Update counter data in window. *)

	procedure Put_Frame_Counts;

		const
			CS = 3;                   (* Camera string item *)
			CT = 4;                   (* Camera Total item *)
			PS = 5;                   (* Projector string item *)
			PT = 6;                   (* Projector Total item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)
			The_Event: EventRecord;    (* user interruption event *)
			The_CtrlHdl: Handle;       (* Button control item handle *)

	begin

		if The_Dialog <> nil then
			begin

				The_Text := IntToStr(Camera_Total);
				GetDItem(The_Dialog, CT, The_Type, The_TextHdl, The_ItemBox);
				SetIText(The_TextHdl, The_Text);
				The_Text := IntToStr(Projector_Total);
				GetDItem(The_Dialog, PT, The_Type, The_TextHdl, The_ItemBox);
				SetIText(The_TextHdl, The_Text);

				DoDefaultButton(The_Dialog);
				ShowWindow(WindowPtr(The_Dialog));

				if KeyPressed or Button then
					begin
						GetDItem(The_Dialog, Ok, The_Type, The_CtrlHdl, The_ItemBox);
						HiliteControl(ControlHandle(The_CtrlHdl), 1);
						if KeyPressed then
							if (char(ReadKey) = char(CR)) then
								;
						if Button then
							TpReadMouse;
						GetDItem(The_Dialog, Ok, The_Type, The_CtrlHdl, The_ItemBox);
						SetCTitle(ControlHandle(The_CtrlHdl), 'Go');
						HiliteControl(ControlHandle(The_CtrlHdl), 0);
						DoDefaultButton(The_Dialog);
						repeat
							ModalDialog(nil, The_Item);
							GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
						until The_Type = BtnItem;
						GetDItem(The_Dialog, Ok, The_Type, The_CtrlHdl, The_ItemBox);
						SetCTitle(ControlHandle(The_CtrlHdl), 'Stop');
					end;

			end;     (* insure dialog box pointer has been created *)

	end;

(* Close window and release pointer. *)

	procedure Trash_Frame_Counts;

	begin

		DisposDialog(The_Dialog);

	end;

(* Edit cummulative Frame Counters. *)

	procedure Edit_Frame_Counts;

		const
			CS = 3;                   (* Camera string item *)
			CT = 4;                   (* Camera Total item *)
			PS = 5;                   (* Projector string item *)
			PT = 6;                   (* Projector Total item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)
			The_CtrlHdl: Handle;       (* control button handle *)

	begin

		The_Dialog := GetNewDialog(FrmId, nil, Pointer(-1));

		The_Text := IntToStr(Camera_Total);
		GetDItem(The_Dialog, CT, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelIText(The_Dialog, CT, 0, Length(The_Text));
		The_Text := IntToStr(Projector_Total);
		GetDItem(The_Dialog, PT, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);

		GetDItem(The_Dialog, Ok, The_Type, The_CtrlHdl, The_ItemBox);
		SetCTitle(ControlHandle(The_CtrlHdl), 'Ok');

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			if The_Type = TextItem then
				begin
					GetIText(The_ItemHdl, The_Text);
					case The_Item of
						CT: 
							Camera_Total := StrToInt(The_Text);
						PT: 
							Projector_Total := StrToInt(The_Text);
					end;
				end;
		until (The_Type = BtnItem);

		DisposDialog(The_Dialog);

	end;

(********** Sequencer operations **********)

(* Dialog for Camera Overide. *)

	procedure Get_Camera_Options;

		const
			CC = 4;                   (* Camera Count item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)

	begin

		The_Dialog := GetNewDialog(CamId, nil, Pointer(-1));

		The_Text := IntToStr(Camera_Count);
		GetDItem(The_Dialog, CC, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, CC, 0, Length(The_Text));

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			if The_Type = TextItem then
				GetIText(The_ItemHdl, The_Text);
		until The_Type = BtnItem;
		DisposDialog(The_Dialog);

		Camera_Count := StrToInt(The_Text);
		if The_Item = Ok then
			Frame_Count := Camera_Count
		else
			Frame_Count := 0;

	end;

(* Dialog for Projector Overide. *)

	procedure Get_Projector_Options;

		const
			PC = 4;                   (* Projector Count item *)

		var
			The_TextHdl: Handle;       (* Text item handle *)
			The_Text: Str255;          (* user text *)

	begin

		The_Dialog := GetNewDialog(PrjId, nil, Pointer(-1));

		The_Text := IntToStr(Projector_Count);
		GetDItem(The_Dialog, PC, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, PC, 0, Length(The_Text));

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			if The_Type = TextItem then
				GetIText(The_ItemHdl, The_Text);
		until The_Type = BtnItem;
		DisposDialog(The_Dialog);

		Projector_Count := StrToInt(The_Text);
		if The_Item = Ok then
			Frame_Count := Projector_Count
		else
			Frame_Count := 0;

	end;

(* Dialog for Sequencer options. *)

	procedure Get_Sequencer_Options;

		const
			B1 = 1;                   (* Ok button item *)
			B2 = 2;                   (* Cancel button item *)
			RA = 3;                   (* Alternate radio item *)
			RC = 4;                   (* Camera-Step radio item *)
			RP = 5;                   (* Projector-Skip radio item *)
			SC = 7;                   (* Camera Count string item *)
			SP = 9;                   (* Projector Count string item *)
			SS = 11;                  (* Sequencer Count string item *)

		var
			The_RadHdl: Handle;        (* radio button item handle *)
			The_TextHdl: Handle;       (* text item handle *)
			The_Text: Str255;          (* text string *)

	begin

		The_Dialog := GetNewDialog(SeqId, nil, Pointer(-1));

   (* init camera, projector, and sequencer count strings *)
		The_Text := IntToStr(Camera_Cycle);
		GetDItem(The_Dialog, SC, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := IntToStr(Projector_Cycle);
		GetDItem(The_Dialog, SP, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		The_Text := IntToStr(Sequencer_Count);
		GetDItem(The_Dialog, SS, The_Type, The_TextHdl, The_ItemBox);
		SetIText(The_TextHdl, The_Text);
		SelItext(The_Dialog, SS, 0, Length(The_Text));

   (* init 1st radio button = item #3 for sequencer mode *)
		case Sequencer of
			Alternate: 
				The_Item := RA;
			StepCamera: 
				The_Item := RC;
			SkipProjector: 
				The_Item := RP;
			otherwise
				The_Item := 0;
		end;
		GetDItem(The_Dialog, The_Item, The_Type, The_RadHdl, The_ItemBox);
		SetCtlValue(ControlHandle(The_RadHdl), 1);

		DoDefaultButton(The_Dialog);
		repeat
			ModalDialog(nil, The_Item);
			GetDItem(The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
			case The_Type of
				TextItem: 
					begin
						GetIText(The_ItemHdl, The_Text);
						case The_Item of
							SC: 
								Camera_Cycle := StrToInt(The_Text);
							SP: 
								Projector_Cycle := StrToInt(The_Text);
							SS: 
								Sequencer_Count := StrToInt(The_Text);
						end;
					end;
				RadItem: 
					begin
						SetCtlValue(ControlHandle(The_RadHdl), 0);
						SetCtlValue(ControlHandle(The_ItemHdl), 1);
						The_RadHdl := The_ItemHdl;
						case The_Item of
							RA: 
								Sequencer := Alternate;
							RC: 
								Sequencer := StepCamera;
							RP: 
								Sequencer := SkipProjector;
							otherwise
								Sequencer := None;
						end;
					end;
				BtnItem: 
					case The_Item of
						B1: 
							Frame_Count := Sequencer_Count;
						B2: 
							Frame_Count := 0;
					end;
			end;
		until The_Type = BtnItem;
		DisposDialog(The_Dialog);

	end;

{$ELSEC}	(* NOT USE_MAC_TOOLBOX *)

(* Mac Sequencer Windows and Dialogs. *)

(* Create modeless window to input frame counters. *)
Procedure Get_Frame_Counts;
Begin
End;

(* Update modeless window to display frame counters. *)
(* Allow for user interruption (like pressing Cancel button in Mac dialog box). *)
Procedure Put_Frame_Counts;
Begin
   if (SEQIO_Tracered)
      then Writeln('Camera = ', Camera_Total, ', Projector = ', Projector_Total);
   if (KeyPressed OR MousePressed)
      then if Ask_User('Kill running sequence?')
           then The_Item := Cancel;
End;

(* Dispose modeless window for frame counters. *)
Procedure Trash_Frame_Counts;
Begin
End;

(* Execute modal dialog window for editing frame counters. *)
Procedure Edit_Frame_Counts;
Begin
   The_Item := Ok;
End;

(* Execute modal dialog for selecting Camera options. *)
Procedure Get_Camera_Options;
Begin
   The_Item := Ok;
End;

(* Execute modal dialog for selecting Projector options. *)
Procedure Get_Projector_Options;
Begin
   The_Item := Ok;
End;

(* Execute modal dialog for selecting Sequencer options. *)
Procedure Get_Sequencer_Options;
Begin
   The_Item := Ok;
End;

{$ENDC}		(* USE_MAC_TOOLBOX *)

(********** Sequencer routines **********)
(* cut-n-pasted from Macintosh Sequencer23.PAS *)

(* Edit run-time frame counters. *)

Procedure Do_Frame_Counts;

Begin
{$IFC THINGM_INSTALLED}
   THINGM_Camera;
   THINGM_Counter(Camera_Total);
   THINGM_Projector;
   THINGM_Counter(Projector_Total);
{$ELSEC}
   DrawStr ('Edit Frame Counters...');
   Edit_Frame_Counts;
   If The_Item = Ok
      Then begin
           GetCount_Hardware (AA[CX].M);
           GetCount_Hardware (AA[PX].M);
           end;
{$ENDC}
End;

(* Run camera motor. *)
(* 1 camera frame = 400 half steps per revolution. *)

Procedure Pre_Run_Camera (F : Integer);

Begin
{$IFC THINGM_INSTALLED}
   THINGM_Camera;
   THINGM_FrameCount(F);
   WaitOver; (* for ThingM OK *)
{$ELSEC}
   With AA [CX] Do
        begin
        M.StepCnt := F * K.Kscale;
        PrepM (M);
        WaitOver;
        end;
{$ENDC}
End;

Procedure Run_Camera (F : Integer);

Begin
{$IFC THINGM_INSTALLED}
   THINGM_Camera;
   THINGM_Run;
   WaitOver; (* for ThingM OK *)
{$ELSEC}
   With AA [CX] Do
        RunM  (M);
{$ENDC}
End;

(* Run projector motor. *)
(* 1 projector frame = 200 full steps per revolution. *)

Procedure Pre_Run_Projector (F : Integer);

Begin
{$IFC THINGM_INSTALLED}
   THINGM_Projector;
   THINGM_FrameCount(F);
   WaitOver; (* for ThingM OK *)
{$ELSEC}
   With AA [PX] Do
        begin
        M.StepCnt := F * K.Kscale;
        PrepM (M);
        WaitOver;
        end;
{$ENDC}
End;

Procedure Run_Projector (F : Integer);

Begin
{$IFC THINGM_INSTALLED}
   THINGM_Projector;
   THINGM_Run;
   WaitOver; (* for ThingM OK *)
{$ELSEC}
   With AA [PX] Do
        RunM  (M);
{$ENDC}
End;

(* Run camera only *)

Procedure Do_Camera;

Var C : Integer;
    Single : Integer;
    Ticker : LongInt;

Begin

   DrawStr ('Camera Overide Frame Count = ');
   Get_Camera_Options;
   DrawStr (IntToStr (Frame_Count));
   DrawStr ('...');
   Drawln;

   If (The_Item = Ok)
      Then begin
      Get_Frame_Counts;
      If Frame_Count = 0
         Then Single := 0
         Else Single := Frame_Count DIV Abs (Frame_Count);
      Pre_Run_Camera (Frame_Count);
      Run_Camera (Frame_Count);
      Ticker := TickCount;
      For C := 1 to Abs (Frame_Count) do
          begin
          Camera_Total := Camera_Total + Single;
          Put_Frame_Counts;
          Repeat
          Until TickCount >= Ticker + C *
                Round (60.0 * CAMERA_DELAY_TIME);
          WaitOver; (* ThingM continuous run *)
          if (The_Item = Cancel)
             then break;
          end;
      WaitOver; (* MCPU or ThingM OK prompt *)
      Trash_Frame_Counts;
      end;
End;

(* Run projector overide. *)

Procedure Do_Projector;

Var P : Integer;
    Single : Integer;

Begin

   DrawStr ('Projector Overide Frame Count = ');
   Get_Projector_Options;
   DrawStr (IntToStr (Frame_Count));
   DrawStr ('...');
   Drawln;

   If (The_Item = Ok)
      Then begin
      Get_Frame_Counts;
      If Frame_Count = 0
         Then Single := 0
         Else Single := Frame_Count DIV Abs (Frame_Count);
      Pre_Run_Projector (Single);
      For P := 1 to Abs (Frame_Count) do
          begin
          If KeyPressed Or Button
             Then Put_Frame_Counts;
          If Not (The_Item = Cancel)
             Then begin
             Run_Projector (Single);
             Projector_Total := Projector_Total + Single;
             Put_Frame_Counts;
             WaitOver;
             {$IFC MCPU_INSTALLED}
             HomeM (AA[PX].M);      (* locate home switch *)
             {$ENDC}
             WaitOver; (* ThingM OK prompt *)
             if (The_Item = Cancel)
                then break;
             end;
          end;
      Trash_Frame_Counts;
      end;
End;

(* Run sequencer operation. *)

Procedure Do_Sequencer;

Var F : Integer;
    P : Integer;
    PSingle : Integer;
    C : Integer;
    CSingle : Integer;
    Ticker : LongInt;

Begin

   DrawStr ('Sequencer Frame Count = ');
   Get_Sequencer_Options;
   DrawStr (IntToStr (Frame_Count));
   DrawStr ('...');
   Drawln;

   If (The_Item = Ok) Then begin

   Case Sequencer of

   Alternate : begin

      Get_Frame_Counts;
      If Camera_Cycle = 0
         Then CSingle := 0
         Else CSingle := Camera_Cycle DIV Abs (Camera_Cycle);
      If Projector_Cycle = 0
         Then PSingle := 0
         Else PSingle := Projector_Cycle DIV Abs (Projector_Cycle);
      Pre_Run_Camera (Camera_Cycle);
      Pre_Run_Projector (PSingle);
      For F := 1 to Abs (Frame_Count) do
          begin
          If KeyPressed Or Button
             Then Put_Frame_Counts;
          If Not (The_Item = Cancel)
             Then begin
             Run_Camera (Camera_Cycle);
             Ticker := TickCount;
             For C := 1 to Abs (Camera_Cycle) Do
                 begin
                 Camera_Total := Camera_Total + CSingle;
                 Put_Frame_Counts;
                 Repeat
                 Until TickCount >= Ticker + C *
                   Round (60.0 * CAMERA_DELAY_TIME);
                 WaitOver; (* ThingM *)
                 end;
             WaitOver; (* MCPU or ThingM OK *)
             if (The_Item = Cancel)
                then break;

             For P := 1 to Abs (Projector_Cycle) do
                 begin
                 Run_Projector (PSingle);
                 Projector_Total := Projector_Total + PSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 {$IFC MCPU_INSTALLED}
                 HomeM (AA[PX].M);      (* locate home switch *)
                 {$ENDC}
                 WaitOver; (* ThingM OK *)
                 if (The_Item = Cancel)
                    then break;
                 end;
             end;
          end;
      Trash_Frame_Counts;
      end;      (* Alternate Sequencer *)

   StepCamera : begin

      Get_Frame_Counts;
      If Camera_Cycle = 0
         Then CSingle := 0
         Else CSingle := Camera_Cycle DIV Abs (Camera_Cycle);
      Pre_Run_Camera (CSingle);
      If Projector_Cycle = 0
         Then PSingle := 0
         Else PSingle := Projector_Cycle DIV Abs (Projector_Cycle);
      Pre_Run_Projector (PSingle);
      For F := 1 to Abs (Frame_Count) do
          begin
          If KeyPressed Or Button
             Then Put_Frame_Counts;
          If Not (The_Item = Cancel)
             Then begin
             For P := 1 to Abs (Projector_Cycle) do
                 begin
                 Run_Camera (CSingle);
                 WaitOver;
                 Camera_Total := Camera_Total + CSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 Run_Projector (PSingle);
                 WaitOver;
                 Projector_Total := Projector_Total + PSingle;
                 Put_Frame_Counts;
                 {$IFC MCPU_INSTALLED}
                 HomeM (AA[PX].M);      (* locate home switch *)
                 {$ENDC}
                 WaitOver;
                 if (The_Item = Cancel)
                    then break;
                 end;
             For C := 1 to Abs (Camera_Cycle - 1) do
                 begin
                 Run_Camera (CSingle);
                 WaitOver;
                 Camera_Total := Camera_Total + CSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 if (The_Item = Cancel)
                    then break;
                 end;
             end;
          end;
      Trash_Frame_Counts;
      end;      (* StepCamera Sequencer *)

   SkipProjector : begin

      Get_Frame_Counts;
      If Camera_Cycle = 0
         Then CSingle := 0
         Else CSingle := Camera_Cycle DIV Abs (Camera_Cycle);
      Pre_Run_Camera (CSingle);
      If Projector_Cycle = 0
         Then PSingle := 0
         Else PSingle := Projector_Cycle DIV Abs (Projector_Cycle);
      Pre_Run_Projector (PSingle);
      For F := 1 to Abs (Frame_Count) do
          begin
          If KeyPressed Or Button
             Then Put_Frame_Counts;
          If Not (The_Item = Cancel)
             Then begin
             For C := 1 to Abs (Camera_Cycle) do
                 begin
                 Run_Camera (CSingle);
                 WaitOver;
                 Camera_Total := Camera_Total + CSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 Run_Projector (PSingle);
                 WaitOver;
                 Projector_Total := Projector_Total + PSingle;
                 Put_Frame_Counts;
                 {$IFC MCPU_INSTALLED}
                 HomeM (AA[PX].M);      (* locate home switch *)
                 {$ENDC}
                 WaitOver;
                 if (The_Item = Cancel)
                    then break;
                 end;
             For P := 1 to Abs (Projector_Cycle - 1) do
                 begin
                 Run_Projector (PSingle);
                 WaitOver;
                 Projector_Total := Projector_Total + PSingle;
                 Put_Frame_Counts;
                 {$IFC MCPU_INSTALLED}
                 HomeM (AA[PX].M);      (* locate home switch *)
                 {$ENDC}
                 WaitOver;
                 if (The_Item = Cancel)
                    then break;
                 end;
             end;
          end;
      Trash_Frame_Counts;
      end;      (* SkipProjector Sequencer *)

   end;         (* case Sequencer *)
   end;         (* if Sequencer at all *)
End;

(*****************************************)

End.


