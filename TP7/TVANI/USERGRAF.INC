(* High-resolution BGI graphics. *)

(*********************************)

Var
   GraphDriver : Integer;
   GraphMode   : Integer;
   ErrorCode   : Integer;

(* Switch screen over to BGI Graphics Interface. *)

Procedure Go_Graphics;

Const Flicker_Time = 500;                      (* screen flicker delay *)

(* adapt world coordinate scaling from Cheap Graphics Interface *)
(* determine screen coordinate system at run-time. *)

Procedure Draw_Graphics_Plot;

(* Const XGres = 720;                               (* X axis resolution *)
(*       YGres = 348;                               (* Y axis resolution *)

Var  XGres : Integer;                           (* X axis resolution *)
     YGres : Integer;                           (* Y axis resolution *)
     ZGres : Integer;                           (* Z axis intensity *)

Var  X : Integer;
     Y : Integer;
     Xmin, Xmax, Xscale : Real;                 (* Integer : Real scale *)
     Ymin, Ymax, Yscale : Real;
     Yzero : Integer;
     P : Integer;
     Pt : Real_Array;

(* Transfer the selected axis plot values into a graph plot buffer. *)

Begin

   XGres := GetMaxX;      (* graphics device driver dependent *)
   YGres := GetMaxY;
   ZGres := GetMaxColor;
   SetColor(ZGres);       (* different for CGA, VGA, Hercules *)

   If Delta_Graphics
      Then begin
           Pt [1] := 0.0;
           For P := 2 to XYno Do
               Pt [P] := Get_Pt (Index, P) - Get_Pt (Index, P-1);
           end
      Else For P := 1 to XYno Do
               Pt [P] := Get_Pt (Index, P);

(* Scale the real-number plot to fit into integer XY coordinates. *)

    Xmin := (* 1; *) 0;
    Xmax := XYno;
    Ymin := 0.0;
    Ymax := 0.0;
    For P := 1 to XYno Do
        If Pt [P] > Ymax
           Then Ymax := Pt [P]
        Else If Pt [P] < Ymin
           Then Ymin := Pt [P];
    Xscale := XGres / Abs (Xmax - Xmin);
    If Ymax <> Ymin
       Then Yscale := Abs (YGres / (Ymax - Ymin))
    Else If Ymax <> 0.0
       Then Yscale := YGres / Ymax
       Else Yscale := 0.0;

(* Map the XY real-number coordinates into XY integer-number coordinates. *)
(* Display the XY integer coordinates as graphics pixels on screen. *)

   If Delta_Graphics
      Then begin
           For P := 2 to XYno Do
               begin
               X := Round (P * Xscale);
               If (Ymax > 0.0) And (Ymin = 0.0)
                  Then Yzero := YGres - 1
               Else If (Ymax = 0.0) And (Ymin < 0.0)
                  Then Yzero := YGres - Round (+0.68 * YGres) - 1
               Else If (Ymax > 0.0) And (Ymin < 0.0)
                  Then Yzero := YGres - Round (+0.68 * Abs(Ymin/(Ymax-Ymin)) * YGres) - 1
                  Else Yzero := YGres - 1;
               Y := YGres - Round (+0.68 * (Pt [P] - Ymin) * Yscale) - 1;
               If (X >= 0) And (X <= XGres)
               And (Y >= 0) And (Y <= YGres)
                   Then Line (X, Yzero, X, Y);
               end;
           end

      Else begin
           For P := 1 to XYno Do
               begin
               X := Round (P * Xscale);
               Y := YGres - Round (+0.98 * (Pt [P] - Ymin) * Yscale) - 1;
               If (X >= 0) And (X <= XGres)
               And (Y >= 0) And (Y <= YGres)
                   Then PutPixel (X, Y, ZGres);  (* max color = white *)
               end;
           end;
End;

Begin

   If NOT Graphics_Loaded
      Then begin
      GraphDriver := Detect;
      InitGraph (GraphDriver, GraphMode, 'C:\Pascal\BGI');
      ErrorCode := GraphResult;
      Graphics_Loaded := True;
      end;

   If Graphics_Loaded AND (ErrorCode = GrOk)
      Then begin
           If GraphDriver = CGA
              Then Delay (Flicker_Time);
           SetGraphMode (GraphMode);
           Draw_Graphics_Plot;
           Repeat Until User_Interrupt;
           RestoreCrtMode;
           (* CloseGraph; *)
           Delay (Flicker_Time);
           end

      Else MessageBox ('Graphics Toolbox Error:'+^M + GraphErrorMsg (ErrorCode),
                      Nil, mfError + mfOkButton );
End;

