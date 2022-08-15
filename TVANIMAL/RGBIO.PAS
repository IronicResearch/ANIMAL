
(* RGB Light Source Interface *)

Unit RGBIO;

Interface

{$I SWITCHES.INC}                       (* compiler switches *)

Const
   RGB_PortX : integer = 2;             (* serial port for RGB *)
Var
   RGB_Red : integer;                   (* for latched values *)
   RGB_Grn : integer;
   RGB_Blu : integer;
   RGB_Col : integer;

Const
   Max_Color_Code = 20;                 (* for color table *)
Type
   Color_Record = Record
      Red   : integer;
      Green : integer;
      Blue  : integer;
      Name  : string[20];
      end;
Var
   RGB_Color : Array [1..Max_Color_Code] of Color_Record;

Procedure InitRGB (Portx : integer);

Procedure OutRGB (C : char);

Procedure OutRed (I : integer);

Procedure OutGreen (I : integer);

Procedure OutBlue (I : integer);

Procedure OutColor (R, G, B : integer);

Procedure Save_Color_File (FileName : string);

Procedure Load_Color_File (FileName : string);

Procedure Init_RGB_Color;

(************)

Implementation

(* serial support for RGB interface: *)

{$I SIOX.LIB}     (* privately recycled serial routines *)

(* Select a serial port for RGB light source. *)
Procedure InitRGB (Portx : integer);
Begin
   SetSio(Portx);
   ResetSio;
End;

(* Output a byte to RGB serial port. *)
Procedure OutRGB (C : char);
Begin
   OutSio(C);
End;

(* Output number string, padded with leading zeros. *)
Procedure OutRGBStr (S : string);
Var C : char;
    I : integer;
Begin
   For I := 1 to Length(S) Do
       if S[I] = ' '
          Then OutRGB ('0')
          Else OutRGB (S[I]);
End;

(* Insure range 0..255 *)
Function Bytewise (I : integer) : byte;
begin
   If I > 255
      Then Bytewise := 255
   Else If I < 0
      Then Bytewise := 0
   Else Bytewise := I;
End;

(* Output RGB values to light source interface. *)
Procedure OutRed (I : integer);
Var S : String;
Begin
   OutRGB ('R');
   Str (Bytewise(I):3, S);
   OutRGBStr (S);
   OutRGB (^M);
   RGB_Red := Bytewise(I);
End;

Procedure OutGreen (I : integer);
Var S : String;
Begin
   OutRGB ('G');
   Str (Bytewise(I):3, S);
   OutRGBStr (S);
   OutRGB (^M);
   RGB_Grn := Bytewise(I);
End;

Procedure OutBlue (I : integer);
Var S : String;
Begin
   OutRGB ('B');
   Str (Bytewise(I):3, S);
   OutRGBStr (S);
   OutRGB (^M);
   RGB_Blu := Bytewise(I);
End;

Procedure OutColor (R, G, B : integer);
Begin
   OutRed   (R);
   OutGreen (G);
   OutBlue  (B);
End;

Procedure Init_RGB_Color;
Begin
   OutColor (0,0,0);
End;

(* Color Table file IO in text mode. *)
Procedure Save_Color_File (FileName : string);
Var I : integer;
    F : Text;
Begin
   {$I-}
   Assign(F, FileName);
   Rewrite(F);
   Write(F, Max_Color_Code:10);
   Write(F, 'Red':10);
   Write(F, 'Green':10);
   Write(F, 'Blue':10);
   Writeln(F);
   Writeln(F);
   For I := 1 to Max_Color_Code Do
       begin
       Write(F, I:10);
       Write(F, RGB_Color[I].Red:10);
       Write(F, RGB_Color[I].Green:10);
       Write(F, RGB_Color[I].Blue:10);
       Writeln(F, RGB_Color[I].Name);
       end;
   Writeln(F);
   Close(F);
   {$I+}
   if (IOResult <> 0)
      then Exit;
End;

Procedure Load_Color_File (FileName : string);
Var I, J, Total : integer;
    F : Text;
Begin
   {$I-}
   Assign(F, FileName);
   Reset(F);
   Read(F, Total);
   Readln(F);
   Readln(F);
   For I := 1 to Total Do
       begin
       Read(F, J);
       Read(F, RGB_Color[I].Red);
       Read(F, RGB_Color[I].Green);
       Read(F, RGB_Color[I].Blue);
       Readln(F, RGB_Color[I].Name);
       end;
   Close(F);
   {$I+}
   if (IOResult <> 0)
      then Exit;
End;

(* Initialization *)

Var I : integer;

Begin

   (* 2nd command line parameter selects RGB serial port *)
   If ParamCount >= 2
      Then Val (ParamStr(2), RGB_PortX, I);

   RGB_Red := 0;
   RGB_Grn := 0;
   RGB_Blu := 0;
   RGB_Col := 1;
   For I := 1 to Max_Color_Code Do
       With RGB_Color[I] Do
            begin
            Red  := 0;
            Green:= 0;
            Blue := 0;
            Name := '';
            end;
   (* select and init RGB serial port *)
   InitRGB (RGB_PortX);
   OutColor (0, 0, 0);

End.


