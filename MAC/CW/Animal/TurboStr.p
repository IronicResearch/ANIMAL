(* String to Number conversion routines. *)
(* Uses Mac OS Toolbox for IEEE standard number conversion, SANE. (originally) *)

(* Adapted for CodeWarrior Pascal. *)

{$SETC CODEWARRIOR_PASCAL = 1}
{$SETC SYSTEM75_MATH = 1}

(* Uses "new" FP Unit instead of "old" SANE Unit for System 7.5 aware apps. *)
(* SANE is only for 68000-based apps, and must be linked in separately. *)
(* SANE LIB was not pre-compiled on CodeWarrior v11 CD, so is probably considered obsolete. *) 

(* Instead uses Apple MPW Pascal ReadString and StringOf extensions for number conversions. *)
(* Must have MSL_C.68K.LIB and MSL_Runtime.68K.LIB in project to complete linking. *)
(* MSL = Metrowerks Standard Libraries, which include Pascal wrappers to ANSI C functions. *)

Unit TurboStr;

Interface

Uses
{$IFC CODEWARRIOR_PASCAL}
	Types,
	{$IFC SYSTEM75_MATH}
	fp;					(* "new" floating point library *)
	{$ELSEC} 
	SANE;				(* "old" floating point library *)
	{$ENDC}
{$ELSEC}
	Types;
{$ENDC}
	
Const
	Pi = 3.1415926535898;
	
Type
	Real_Or_Integer = (* Extended; *) integer;
	
function StrToInt(S : Str255) : integer;
function StrToReal(S : Str255) : real;
function IntToStr(I : integer) : Str255;
function RealToStr(R : real; N : integer) : Str255;

{$IFC CODEWARRIOR_PASCAL}
procedure Str(var X : Real_Or_Integer; var S : Str255);
procedure Val(var S : Str255; var X : Real_Or_Integer; var N : integer);
{$ENDC}

Implementation

{$IFC CODEWARRIOR_PASCAL}

(* Convert real or integer number to string. *)
(* Equivalent to PC Turbo Pascal string conversion extension. *)
procedure Str(var X : Real_Or_Integer; var S : Str255);
begin
	S := StringOf(X);
end;

(* Convert string to real or integer number. *)
(* Equivalent to PC Turbo Pascal string conversion extension. *)
procedure Val(var S : Str255; var X : Real_Or_Integer; var N : integer);
begin
	ReadString(S, X);
end;

{$ENDC}

{$IFC SYSTEM75_MATH}
(* Uses MPW Pascal number string conversion routines. *)

(* Convert string to integer number. *)
function StrToInt(S : Str255) : integer;
var I : integer;
begin
	I := 0;
	ReadString(S, I);
	StrToInt := I;
end;

(* Convert string to real number. *)
function StrToReal(S : Str255) : real;
var R : real;
begin
	R := 0.0;
	ReadString(S, R);
	StrToReal := R;
end;

(* Convert integer number to string. *)
function IntToStr(I : integer) : Str255;
var S : Str255;
begin
	S := '0';
	S := StringOf(I);
	IntToStr := S;
end;

(* Convert real number to string with N decimal places. *)
function RealToStr(R : real; N : integer) : Str255;
var S : Str255;
begin
	S := '0.0';
	if (N = 0) then N := 1;		(* min decimal places for CodeWarrior Pascal *)
	S := StringOf(R:1:N);
	RealToStr := S;
end;

{$ELSEC}
(* Uses "old" SANE 68000 math library routines. *)

(* Convert string to integer number. *)
function StrToInt(S : Str255) : integer;
var x : Extended;
begin
	x := Str2Num(S);
	StrToInt := Num2Integer(x);
end;

(* Convert string to real number. *)
function StrToReal(S : Str255) : real;
var x : Extended;
begin
	x := Str2Num(S);
	StrToReal := Num2Real(x);
end;

(* Convert integer number to string. *)
function IntToStr(I : integer) : Str255;
var x : Extended;
	s : DecStr;
	df : DecForm;
begin
	x := Num2Extended(I);
	df.Style := FixedDecimal;
	df.Digits := 0;
	Num2Str(df, x, s);
	IntToStr := s;
end;

(* Convert real number to string with N decimal places. *)
function RealToStr(R : real; N : integer) : Str255;
var x : Extended;
	s : DecStr;
	df : DecForm;
begin
	x := Num2Extended(R);
	df.Style := FixedDecimal;
	df.Digits := N;
	Num2Str(df, x, s);
	RealToStr := s;
end;

{$ENDC}		(* SYSTEM75_MATH *)

End.
