(* Animal Global Variables and Data Types. *)

Unit GLOBAL;

Interface

Uses MCPU;								(* Motor_Table *)

	(* Think Pascal patches for Turbo Pascal definition extensions: *)
	const
		CR = char($0D);
		LF = char($0A);
		BS = char($08);
		TAB = char($09);
		ESC = char($1B);

	const
		Min_Axes = 2;       			(* min number of axes *)
		Max_Axes = 8;       			(* max number of axes *)

		Max_Points = 480;   			(* max number of points *)

	type
		Sequencer_Mode = (None, Alternate, StepCamera, SkipProjector);

		Map_Table = record
				ID: string[2];          (* axis ID tag *)
				No: Integer;            (* motor number *)
				Name: string;           (* axis name label *)
			end;

		Conversion_Table = record
				Kscale: Real;           (* scale factor *)
				DP: Integer;            (* decimal places *)
				Units: string;          (* user units label *)
				Cur_Step: Real;         (* current step count *)
				Cur_Posn: Real;         (* current step position *)
			end;

		Run_Profile = record
				AccelSt: Boolean;       (* acceleration status *)
				Max_Speed: Real;        (* max constant speed *)
				Min_LowSpd: Real;       (* min low speed *)
				Max_HighSpd: Real;      (* max high speed *)
				Max_RampCnt: Real;      (* max ramp count *)
			end;

		Parameter_Table = record
				Spec: Boolean;			(* axis selected *)
				StartFrame: Integer;	(* start frame *)
				EndFrame: Integer;		(* end frame *)
				StartPoint: Real;		(* start position *)
				EndPoint: Real;			(* end position *)
				Taper: Boolean;			(* tapered movement ? *)
				Accel: Real;			(* taper in % *)
				Decel: Real;			(* taper out % *)
				IncrMax: Real;			(* max increment per frame *)
				MoveType: string[3];	(* movement type *)
				Streak: Boolean;		(* streaked movement ? *)
				InitlSize: Real;		(* initial streak size *)
				FinalSize: Real;		(* final streak size *)
			end;

		Point_Table = array[0..Max_Points] of Real;

		Axis_Table = record
				Spec: Boolean;          (* specified ? *)
				A: Map_Table;           (* axis map *)
				M: Motor_Table;         (* MCPU motor stuff *)
				K: Conversion_Table;    (* user units stuff *)
				R: Run_Profile;         (* motor run profile stuff *)
				P: Parameter_Table;     (* program parameters *)
				Q: Point_Table;         (* point buffer *)
			end;

	var
		Frame_Count: Integer;           (* overall frame count *)
		Camera_Count: Integer;          (* camera frame count *)
		Projector_Count: Integer;       (* projector frame count *)
		Sequencer_Count: Integer;       (* sequencer frame count *)
		Sequencer: Sequencer_Mode;      (* sequencer operation *)
		Camera_Cycle: Integer;          (* camera cycle count *)
		Projector_Cycle: Integer;       (* projector cycle count *)
		Camera_Total: Integer;          (* camera total frames *)
		Projector_Total: Integer;       (* projector total frames *)
		Preset_Count: Integer;          (* preset frame count *)

		Exposured: Boolean;             (* exposures active ? *)
		Reversed: Boolean;              (* sequence reversed ? *)
		SingleFramed: Boolean;          (* sequence single-framed ? *)

		M: Motor_Table;                 (* general motor axis *)
										
		I: Integer;                     (* axis array index - general usage *)
		Index: Integer;                 (* axis array index - specific selection *)
		AA: array[1..Max_Axes] of Axis_Table;
		
	procedure GLOBAL_Init;
		
	procedure Case_Axis (S2: string; var OK: Boolean; var I: Integer);

Implementation

(* Check for axis ID. *)
	procedure Case_Axis (S2: string; var OK: Boolean; var I: Integer);
		var
			J: Integer;
	begin
		OK := False;
		for J := 1 to Max_Axes do
			if AA[J].A.Id = S2 then
				begin
					I := J;
					OK := True;
				end;
	end;

(* Initialize default axis table. *)
	procedure Init_Defaults;
		var
			I: integer;
	begin
		for I := 1 to Max_Axes do
			with AA[I] do
				begin
					Spec := True;
					with A do
						begin
							Id[0] := Chr(2);
							Id[1] := 'X';
							Id[2] := Chr(Ord('A') + I - 1);
							No := I;
							Name := '---';
						end;
					with M do
						begin
							MotorNo := I;
							StepCnt := 0.0;
							Dir := FWD;
							AccelSt := True;
							Speed := 500;
							LowSpd := 250;
							HighSpd := 1000;
							RampCnt := 200;
							RampK := 0;
							Stat := '?';
							Count := 0.0;
							Error := False;
						end;
					with K do
						begin
							Kscale := 1.0;
							DP := 1;
							Units := 'Steps';
							Cur_Step := 0.0;
							Cur_Posn := 0.0;
						end;
					with R do
						begin
							AccelSt := True;
							Max_Speed := 500;
							Min_LowSpd := 250;
							Max_HighSpd := 1000;
							Max_RampCnt := 200;
						end;
					with P do
						begin
							Spec := False;
							StartFrame := 0;
							EndFrame := 1;
							StartPoint := 0.0;
							EndPoint := 0.0;
							Taper := False;
							Accel := 0.0;
							Decel := 0.0;
							IncrMax := 0.0;
							MoveType := 'SIN';
							Streak := False;
							InitlSize := 0.0;
							FinalSize := 0.0;
						end;
					Q[1] := 0.0;
				end;
	end;

(* Unit Initialization *)
procedure GLOBAL_Init;
begin
		Frame_Count := 0;
		Camera_Count := 0;
		Projector_Count := 0;
		Sequencer_Count := 0;
		Sequencer := Alternate;
		Camera_Cycle := 1;
		Projector_Cycle := 1;
		Camera_Total := 0;
		Projector_Total := 0;
		Preset_Count := 1;

		Exposured := False;
		Reversed := False;
		SingleFramed := False;
		
		Init_Defaults;

		Index := 1;
		M := AA[1].M;
End;

End.


