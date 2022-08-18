(* RGB Light Source Interface. *)

(* Adapted for CodeWarrior Pascal. *)

{$SETC CODEWARRIOR_PASCAL = 1}
{$SETC THINK_PASCAL = 0}
{$SETC TURBO_PASCAL = 1}

(* Make sure CodeWarrior IDE Project Settings for Pascal Language has
(* Turbo Pascal input/output compatibility enabled. *)

unit RGBIO;

interface

	uses
{$IFC THINK_PASCAL}
		ThinkCrt,		(* Think Pascal console extensions *) 
		ThinkStr,		(* Think Pascal string extensions *) 
{$ELSEC}
		TurboCrt,		(* Turbo Pascal console extensions *) 
		TurboStr,		(* Turbo Pascal string extensions *) 
{$ENDC}
		SIO;			(* serial interface communications *)

	const
		RGB_Max_Color_Code = 20;

	type
		RGB_Color_Record = record
				Red: integer;
				Green: integer;
				Blue: integer;
				Name: string[20];
			end;
	
	var
		RGB_Color_Table: array[1..RGB_Max_Color_Code] of RGB_Color_Record;

	var
		RGB_Red: integer;
		RGB_Green: integer;
		RGB_Blue: integer;
		RGB_Color: integer;

	procedure InitRGB;
	procedure ExitRGB;
	procedure OutRed (I: integer);
	procedure OutGreen (I: integer);
	procedure OutBlue (I: integer);
	procedure OutRGB (R, G, B: integer);
	procedure OutColor (I: integer);
	procedure LoadColorTable (FileName: string);
	procedure SaveColorTable (FileName: string);
	function MaxByte (I: integer): integer;
	function MaxColor (I: integer): integer;

implementation

	const
		CR = chr($0D);

(* Init unit data. *)
	procedure Init_RGB_Data;
		var
			I: integer;
	begin
		RGB_Red := 0;
		RGB_Green := 0;
		RGB_Blue := 0;
		RGB_Color := 1;
		for I := 1 to RGB_Max_Color_Code do
			with RGB_Color_Table[I] do
				begin
					Red := 0;
					Green := 0;
					Blue := 0;
					Name := '';
				end;
	end;

(* Init RGB Light Source interface. *)
	procedure InitRGB;
	begin
		ResetSio;
		OutRGB(0, 0, 0);
		Init_RGB_Data;
		LoadColorTable('ANIMAL.RGB');
	end;

(* Exit RGB Light Source interface. *)
	procedure ExitRGB;
	begin
		OutRGB(0, 0, 0);
	end;

(* serial support *)
	procedure OutCmd (C: char);
	begin
		OutSio(C);
	end;

(* insure string is only 3 characters long *)
	procedure OutStr3 (S: string);
		var
			C: char;
			I: integer;
	begin
		if (Length(S) > 3) then
			Delete(S, 1, (Length(S) - 3));
		for I := 1 to Length(S) do
			if (S[I] = ' ') then
				OutCmd('0')
			else
				OutCmd(S[I]);
	end;

(* insure byte is in 0..255 range *)
	function MaxByte (I: integer): integer;
	begin
		if (I > 255) then
			MaxByte := 255
		else if (I < 0) then
			MaxByte := 0
		else
			MaxByte := I;
	end;

 (* output RGB values to serial port *)
	procedure OutRed (I: integer);
		var
			S: string;
	begin
		RGB_Red := MaxByte(I);
		OutCmd('R');
		Str(RGB_Red, S);
		OutStr3(S);
		OutCmd(CR);
	end;

	procedure OutGreen (I: integer);
		var
			S: string;
	begin
		RGB_Green := MaxByte(I);
		OutCmd('G');
		Str(RGB_Green, S);
		OutStr3(S);
		OutCmd(CR);
	end;

	procedure OutBlue (I: integer);
		var
			S: string;
	begin
		RGB_Blue := MaxByte(I);
		OutCmd('B');
		Str(RGB_Blue, S);
		OutStr3(S);
		OutCmd(CR);
	end;

	procedure OutRGB (R, G, B: integer);
	begin
		OutRed(R);
		OutGreen(G);
		OutBlue(B);
	end;

(* insure color index is in color table range *)
	function MaxColor (I: integer): integer;
	begin
		if (I > RGB_Max_Color_Code) then
			MaxColor := RGB_Max_Color_Code
		else if (I < 1) then
			MaxColor := 1
		else
			MaxColor := I;
	end;

(* Output RGB color indexed by color table. *)
	procedure OutColor (I: integer);
	begin
		RGB_Color := MaxColor(I);
		with RGB_Color_Table[RGB_Color] do
			OutRGB(Red, Green, Blue);
	end;

(* Save RGB color table. *)
	procedure SaveColorTable (FileName: string);
		var
			I: integer;
			F: text;	(* packed file of char *)
	begin
		{$IFC THINK_PASCAL}
		Open(F, FileName);
		{$ELSEC}
		Assign(F, FileName);
		{$ENDC}
		Rewrite(F);
		Writeln(F, RGB_Max_Color_Code : 10, 'Red' : 10, 'Green' : 10, 'Blue' : 10);
		Writeln(F);
		for I := 1 to RGB_Max_Color_Code do
			with RGB_Color_Table[I] do
				Writeln(F, I : 10, Red : 10, Green : 10, Blue : 10, Name : 20);
		Writeln(F);
		Close(F);
	end;

(* Load RGB color table. *)
	procedure LoadColorTable (FileName: string);
		var
			I, T: integer;
			F: text;	(* packed file of char *)
	begin
		{$IFC THINK_PASCAL}
		Open(F, FileName);
		{$ELSEC}
		Assign(F, FileName);
		{$ENDC}
		if (not EOF(F)) then
			begin
				Reset(F);
				Readln(F, T);
				Readln(F);
				if (T > RGB_Max_Color_Code) then
					T := RGB_Max_Color_Code;
				for I := 1 to T do
					with RGB_Color_Table[I] do
						Readln(F, I, Red, Green, Blue, Name);
			end;
		Close(F);
	end;

(* unit RGBIO *)

end.