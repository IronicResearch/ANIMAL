(* Data display routines prepared for Turbo Vision screen strings. *)

(* Display individual line of axis plot points. *)

Procedure Display_Point_Line (L : Integer; Var S : String);
Var I : Integer;
    SX : String;
Begin
    Str (L:4, SX);
    S := SX;
    For I := 1 to Max_Axes Do
        With AA [I] Do
             If Spec
                Then begin
                Str ((Get_Pt (I, L)):10:K.dp, SX);
                S := S + SX;
                end;
end;

(* Extract individual axis point values from data string. *)

Procedure Extract_Points (Var S : String; P : Integer);
var
   C, D : Integer;
   X : String;
   Verror : Integer;

procedure Scan_For_Blanks;
Begin
   While S [C] = ' ' Do
      C := Succ (C);
End;

procedure Scan_For_Numbers;
Begin
   D := 1;
   While (C <= Length (S))
   And (S [C] <> ' ') Do
       begin
       X [D] := S [C];
       C := Succ (C);
       D := Succ (D);
       end;
   X [0] := Chr (Pred (D));
End;

Begin
   C := 1;
   Scan_For_Blanks;
   Scan_For_Numbers;
   For I := 1 to Max_Axes Do
       With AA [I] Do
       If Spec
          Then If I In [1..Min_Axes]
               Then begin
               Scan_For_Blanks;
               Scan_For_Numbers;
               Val (X, Key [P], Verror);
               end;
End;

(* Graphics routines prepared for Turbo Vision screen strings. *)

Var   Index : Integer;                          (* selected axis index *)

Const Xres = 78;                                (* X axis resolution *)
      Yres = 19;                                (* Y axis resolution *)

Type  XYscreen = Array [0..Yres] of String [Xres];  (* XY screen buffer *)

(* Prepare integer graphics coordinates from real-number plot. *)
(* Buffer XY graphics plot in screen-compatible text-string buffer. *)

Procedure Buffer_Graphics_Plot (Index : Integer; Var XYbuf : XYscreen);

Var  Xmin, Xmax, Xscale : Real;                 (* Integer : Real scale *)
     Ymin, Ymax, Yscale : Real;
     XYmap : Array [1..Xres] of Integer;        (* XY integer coordinates *)
     XYkey : Array [1..Xres] of Integer;

Var  X : Integer;
     Y : Integer;

(* Scale the real-number plot to fit into integer XY coordinates. *)

Var P : Integer;
    Pt : Real;
    K : Integer;

Begin

    Xmin := (* 1; *) 0;
    Xmax := XYno;
    Ymin := 0.0;
    Ymax := 0.0;
    For P := 1 to XYno Do
        begin
        Pt := Get_Pt (Index, P);
        If Pt > Ymax
           Then Ymax := Pt
        Else If Pt < Ymin
           Then Ymin := Pt;
        end;
    Xscale := Xres / (Xmax - Xmin);
    If Ymax <> Ymin
       Then Yscale := Yres / (Ymax - Ymin)
    Else If Ymax <> 0.0
       Then Yscale := Yres / Ymax
       Else Yscale := 0.0;

(* Map the XY real-number coordinates into XY integer-number coordinates. *)
(* Map key-frame points onto same XY scale. *)

   For X := 1 to Xres Do
       XYmap [X] := -1;

   For P := 1 to XYno Do
       begin
       X := Round (P * Xscale);
       Y := Yres - Round (+1.0 * (Get_Pt (Index, P) - Ymin) * Yscale);
       If X in [1..Xres]
          Then XYmap [X] := Y;
       end;

   For X := 1 to Xres Do
       XYkey [X] := -1;

   If KeyNo > 0
       Then For K := 1 to KeyNo Do
       begin
       If K = 1
          Then X := 1
          Else X := Round (Time_Key [K] / Screen_Time * Xres);
       Y := Yres - Round (+1.0 * (AA [Index].Key [K] - Ymin) * Yscale);
       If X in [1..Xres]
          Then XYkey [X] := Y;
       end;

(* Buffer the XY integer coordinates as text characters on screen. *)
(* Complete text strings are buffered for each horizontal line. *)
(* Transfer key-frame point characters into same screen buffer. *)

   For Y := 0 to Yres Do
       begin
       XYbuf [Y][0] := Chr (Xres);
       For X := 1 to Xres Do
           XYbuf [Y][X] := ' ';
       end;

   For X := 1 to Xres Do
       begin
       Y := XYmap [X];
       If Y in [0..Yres]
          Then XYbuf [Y][X] := '�';
       end;

   For X := 1 to Xres Do
       begin
       Y := XYkey [X];
       If Y in [0..Yres]
          Then XYbuf [Y][X] := '*';     (* {$R+} error *)
       end;
End;

(* Provide a single horizontal line of the graph display buffer. *)

Procedure Graph_Point_Line (Var XYbuf : XYscreen; L : Integer; Var S : String);

Begin

   If L in [0..Yres]
      Then S := XYbuf [L]
      Else S := '';
End;

