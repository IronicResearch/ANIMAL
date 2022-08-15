(* Dialog for Editing Time base. *)

Type
  EditDataType = Record
    Time : String [128];
    Frames : String [128];
    TaperIn : String [128];
    TaperOut : String [128];
    end;

Var
  EditData : EditDataType;

Procedure TVApp.TimeDialog;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  Verror : Integer;
  S : String;
  OldFrameTime, NewFrameTime : Integer;
begin
  R.Assign(20, 6, 60, 17);
  Dialog := New(PEditDialog, Init(R, ' Edit Time Frame '));
  with Dialog^ do
  begin
    HelpCtx := hcEditTime;

    R.Assign(20, 2, 35, 3);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 2, 15, 3);
    Insert(New(PLabel, Init(R, 'Screen Time', The_Dialog)));

    R.Assign(20, 3, 35, 4);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 3, 15, 4);
{$IFDEF VIDEO_INSTALLED}
    Insert(New(PLabel, Init(R, 'Video Frames', The_Dialog)));
{$ELSE}
    Insert(New(PLabel, Init(R, 'Film Frames', The_Dialog)));
{$ENDIF}

    (* TODO: option to select 24 FPS vs 30 FPS time base *)

    R.Assign(20, 5, 35, 6);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 5, 15, 6);
    Insert(New(PLabel, Init(R, 'Taper In %', The_Dialog)));

    R.Assign(20, 6, 35, 7);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 6, 15, 7);
    Insert(New(PLabel, Init(R, 'Taper Out %', The_Dialog)));

    R.Assign(5, 8, 15, 10);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(25, 8, 35, 10);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext (False);
    If CmdBuf = cmEditTaper
       Then begin
       SelectNext (False);
       SelectNext (False);
       end;
  end;

  With EditData Do
     begin
     Str (Screen_Time:5:3, Time);
     Str (Preset_Count, Frames);
     Str (Taper_In:3:1, TaperIn);
     Str (Taper_Out:3:1, TaperOut);
     end;
  OldFrameTime := Preset_Count;
  Dialog^.SetData (EditData);
  C := DeskTop^.ExecView (Dialog);
  if C <> cmCancel
     then begin
     Dialog^.GetData (EditData);
     (* TODO: option to compute time from frames *)
     Val (EditData.Time, Screen_Time, Verror);
     Val (EditData.Frames, NewFrameTime, Verror);
     if (OldFrameTime <> NewFrameTime)
         then Screen_Time := NewFrameTime / Frame_Rate;
     Edit_Screen_Time;
     Str (Preset_Count, EditData.Frames);
     Val (EditData.TaperIn, Taper_In, Verror);
     Val (EditData.TaperOut, Taper_Out, Verror);
     Edit_Tapers;
     Str (Preset_Count, S);
     CheapStatus ('...Computing ' + S + ' Inbetween Points...');
     Compute_Time_Base;
     Compute_Spline_Curves;
     Compute_Interpolated_Points;
{$IFDEF RGB_CONTROL}
     Compute_RGB_Color;
{$ENDIF}
     CheapStatusClear;
     end;

  Dispose(Dialog, Done);
end;

(* Dialog for Editing Key-Frame Points. *)

Type
  KeyDataType = record
    FreezeData : Word;
    PlotData : Array [1..10] of Array [1..2] of String [128];
    end;

Var
  KeyData : KeyDataType;

Procedure TVApp.EditDialog;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  K : Integer;
  S : String;
  Verror : Integer;
  Yabs, Yrel, Ymin, Ymax : Byte;
  AS, PS, XS, YS, ZS, RS : String;
Begin
  Yabs := 12;
  If KeyNo <= 3
     Then Yrel := 10
     Else Yrel := 7 + KeyNo;
  Ymin := Yabs - Yrel DIV 2;
  Ymax := Ymin + Yrel;
  R.Assign (5, Ymin, 75, Ymax);
  Dialog := New (PEditDialog, Init (R, ' Edit Key-Frame Points '));
  with Dialog^ do
  begin
    HelpCtx := hcEditPlot;

    R.Assign (25, Yrel-3, 45, Yrel-2);
    The_Dialog := New (PCheckBoxes, Init (R,
      NewSItem ('Freeze Frames', nil)));
    Insert (The_Dialog);

    Yrel := 3;
    For K := 1 to 10 Do
        If (K <= 3) Or (K <= KeyNo)
           Then begin
           R.Assign (2, Yrel, 12, Yrel+1);
           The_Dialog := New (PInputLine, Init (R, 128));
           Insert (The_Dialog);
           R.Assign (14, Yrel, 67, Yrel+1);
           The_Dialog := New (PInputLine, Init (R, 128));
           Insert (The_Dialog);
           Inc (Yrel);
           end;
    R.Assign (2, 2, 12, 3);
    Insert (New (PLabel, Init (R, '  Time  ', The_Dialog)));
    R.Assign (14, 2, 67, 3);
    Insert (New (PLabel, Init (R,
      'Point     Axis XX   Axis YY   Axis ZZ   Axis RR', The_Dialog)));

    Inc (Yrel);
    R.Assign (10, Yrel, 20, Yrel+2);
    Insert (New (PButton, Init (R, '~E~dit', cmOK, bfDefault)));
    R.Assign (50, Yrel, 60, Yrel+2);
    Insert (New (PButton, Init (R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
  end;

  For K := 1 to 10 Do
      If K <= KeyNo
         Then Str (Time_Key [K]:6:2, KeyData.PlotData [K][1])
         Else KeyData.PlotData [K][1] := '';
  For K := 1 to 10 Do
      If K <= KeyNo
         Then begin
         Str (K:5, PS);
         Str (AA [XX].Key [K]:10:AA[XX].K.dp, XS);
         Str (AA [YY].Key [K]:10:AA[YY].K.dp, YS);
         Str (AA [ZZ].Key [K]:10:AA[ZZ].K.dp, ZS);
         Str (AA [RR].Key [K]:10:AA[RR].K.dp, RS);
         KeyData.PlotData [K][2] := PS + XS + YS + ZS + RS;
         end
         Else KeyData.PlotData [K][2] := '';
  If Frozen_Fresh
     Then KeyData.FreezeData := 1
     Else KeyData.FreezeData := 0;

  Repeat
     Dialog^.SetData (KeyData);
     C := DeskTop^.ExecView (Dialog);
     If C = cmOK
        then begin
        Dialog^.GetData (KeyData);
        For K := 1 to KeyNo Do
            Val (KeyData.PlotData [K][1], Time_Key [K], Verror);
        For K := 1 to KeyNo Do
            Extract_Points (KeyData.PlotData [K][2], K);
        Frozen_Fresh := (KeyData.FreezeData <> 0);
        Edit_Key_Points;
        Str (Preset_Count, S);
        CheapStatus ('...Re-Computing ' + S + ' Inbetween Points...');
        (* Compute_Time_Base; *)
        Compute_Spline_Curves;
        Compute_Interpolated_Points;
        CheapStatusClear;
        end;
  Until C = cmCancel;

  Dispose(Dialog, Done);
End;

