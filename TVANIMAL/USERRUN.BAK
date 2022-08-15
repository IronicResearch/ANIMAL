(* Dialog for Plotting Points. *)
(* Modified to explicity select Overide command. *)

Type
  RunDataType = record
    StatLine1 : String [128];
    StatLine2 : String [128];
    StatLine3 : String [128];
    RadioBoxData : Word;
    CheckBoxData : Word;
    PreRollData : String [128];
    PlotData : Array [1..10] of String [128];
    end;

Var
  RunData : RunDataType;

Procedure TVApp.PlotDialog;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  AS, PS, XS, YS, ZS, RS : String;
  K : Integer;
  S : String;
Begin
  Query_Save_File;

  R.Assign(10, 7, 70, 17);
  Dialog := New(PEditDialog, Init(R, ' Plot Key-Frame Points '));
  with Dialog^ do
  begin
    HelpCtx := hcRunPlot;

    R.Assign(2, 3, 58, 4);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 4, 58, 5);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 5, 58, 6);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 2, 58, 3);
    Insert (New (PLabel, Init (R,
    'Point     Axis XX   Axis YY   Axis ZZ   Axis RR', The_Dialog)));

    R.Assign (9, 7, 20, 9);
    Insert(New(PButton, Init(R, '~O~veride', cmYes, bfNormal)));
    R.Assign (25, 7, 35, 9);
    Insert(New(PButton, Init(R, '~P~lot', cmOK, bfDefault)));
    R.Assign (40, 7, 50, 9);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
  end;

  Get_Axis_Updates;
{$IFDEF JOYSTICK_CONTROL}
  Enable_Joystick;
{$ENDIF}
  KeyNo := 0;
  With RunData Do
       begin
       StatLine1 := '';
       StatLine2 := '';
       StatLine3 := '';
       For K := 1 to 10 Do
           PlotData [K] := '';
       end;
  Repeat
     Dialog^.SetData (RunData);
     C := DeskTop^.ExecView (Dialog);
     If C = cmYes
        Then Overide;
     If C = cmOK
        Then begin
        Dialog^.GetData (RunData);
        KeyNo := KeyNo + 1;
        If KeyNo > 10 Then KeyNo := 10;
{$IFDEF JOYSTICK_CONTROL}
        Disable_Joystick;
{$ENDIF}
        Delay (100);
        Get_Axis_Updates;
        Str (KeyNo:5, PS);
        Str (AA [XX].K.Cur_Posn:10:AA[XX].K.dp, XS);
        Str (AA [YY].K.Cur_Posn:10:AA[YY].K.dp, YS);
        Str (AA [ZZ].K.Cur_Posn:10:AA[ZZ].K.dp, ZS);
        Str (AA [RR].K.Cur_Posn:10:AA[RR].K.dp, RS);
        AS := PS + '  ' + XS + YS + ZS + RS;
        RunData.PlotData [KeyNo] := AS;
        If KeyNo = 1
           Then RunData.StatLine1 := AS
        Else If KeyNo = 2
           Then RunData.StatLine2 := AS
        Else If KeyNo = 3
           Then RunData.StatLine3 := AS
        Else If KeyNo > 3
           Then begin
                RunData.StatLine1 := RunData.StatLine2;
                RunData.StatLine2 := RunData.StatLine3;
                RunData.StatLine3 := AS;
                end;
{$IFDEF JOYSTICK_CONTROL}
        Enable_Joystick;
{$ENDIF}
        end;
  Until C = cmCancel;
  Delay (100);
{$IFDEF JOYSTICK_CONTROL}
  Disable_Joystick;
{$ENDIF}

  If KeyNo > 1
     Then begin
     For K := 1 to KeyNo Do
         Extract_Points (RunData.PlotData [K], K);
     Edit_Key_Points;
     Str (Preset_Count, S);
     CheapStatus ('...Computing ' + S + ' Inbetween Points...');
     Compute_Time_Base;
     Compute_Spline_Curves;
     Compute_Interpolated_Points;
     Plot_Ended := True;
     Frame_Count := XYno;
     CheapStatusClear;
     end;
  For K := 1 to 10 Do
      If K <= KeyNo
         Then KeyData.PlotData [K][2] := RunData.PlotData [K]
         Else KeyData.PlotData [K][2] := '';
  Dispose(Dialog, Done);
End;

(* Dialog for Run Plot options. *)

Procedure TVApp.RunDialog;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  S : String;
  Verror : Integer;
  XS, YS, ZS, RS : String;

Begin
If XYno <= 1
  Then MessageBox ('No plot points in memory',Nil, mfInformation + mfOkButton )
  Else begin
  R.Assign(10, 6, 70, 19);
  Dialog := New(PEditDialog, Init(R, ' Run Real-Time Points '));
  with Dialog^ do
  begin
    HelpCtx := hcRunReal;

    R.Assign(2, 3, 58, 4);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 4, 58, 5);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 5, 58, 6);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 2, 58, 3);
    Insert (New (PLabel, Init (R,
    'Point     Axis XX   Axis YY   Axis ZZ   Axis RR', The_Dialog)));

    R.Assign(2, 7, 15, 9);
    Insert(New(PButton, Init(R, '~R~un', cmYes, bfDefault)));
    R.Assign (20, 7, 33, 9);
    The_Dialog := New (PRadioButtons, Init (R,
      NewSItem ('Forward',
      NewSItem ('Reverse',
      nil))
      ));
    Insert (The_Dialog);
    R.Assign (35, 7, 53, 9);
    The_Dialog := New (PRadioButtons, Init (R,
      NewSItem ('Continuous',
      NewSItem ('Stop Motion',
      nil))
      ));
    Insert (The_Dialog);

    R.Assign (2, 10, 15, 12);
    Insert (New (PButton, Init (R, '~A~lign', cmNo, bfNOrmal)));
    R.Assign(23, 10, 38, 12);
    Insert (New (PButton, Init (R, '~O~veride', cmOk, bfNormal)));
    R.Assign (46, 10, 58, 12);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;

  RunData.StatLine1 := RunData.PlotData [1];
  RunData.StatLine2 := '';
  If KeyNo > 0
     Then RunData.StatLine3 := RunData.PlotData [KeyNo]
     Else RunData.StatLine3 := '';

  Str (AA [XX].Key [1]:10:AA[XX].K.dp, XS);
  Str (AA [YY].Key [1]:10:AA[YY].K.dp, YS);
  Str (AA [ZZ].Key [1]:10:AA[ZZ].K.dp, ZS);
  Str (AA [RR].Key [1]:10:AA[RR].K.dp, RS);
  RunData.StatLine1 := 'StartPt' + XS + YS + ZS + RS;
  RunData.StatLine2 := '';
  Str (AA [XX].Key [KeyNo]:10:AA[XX].K.dp, XS);
  Str (AA [YY].Key [KeyNo]:10:AA[YY].K.dp, YS);
  Str (AA [ZZ].Key [KeyNo]:10:AA[ZZ].K.dp, ZS);
  Str (AA [RR].Key [KeyNo]:10:AA[RR].K.dp, RS);
  RunData.StatLine3 := 'End  Pt' + XS + YS + ZS + RS;

  If Frame_Count >= XYno
     Then Plot_Ended := True
     Else Plot_Ended := False;

  Repeat
     Get_Axis_Updates;
     Str (AA [XX].K.Cur_Posn:10:AA[XX].K.dp, XS);
     Str (AA [YY].K.Cur_Posn:10:AA[YY].K.dp, YS);
     Str (AA [ZZ].K.Cur_Posn:10:AA[ZZ].K.dp, ZS);
     Str (AA [RR].K.Cur_Posn:10:AA[RR].K.dp, RS);
     RunData.StatLine2 := 'Current' + XS + YS + ZS + RS;
     If Plot_Ended
        Then RunData.RadioBoxData := 1
        Else RunData.RadioBoxData := 0;
     Dialog^.SetData(RunData);

     C := DeskTop^.ExecView(Dialog);

        Dialog^.GetData(RunData);
        With RunData Do
             begin
             Plot_Ended := (RadioBoxData = 1);
             Stop_Motion := (CheckBoxData = 1);
             Single_Framed := (CheckBoxData = 1);
             end;
        If Plot_Ended
           Then begin
                StartPt := XYno;
                EndPt := 0;
                end
           Else begin
                StartPt := 0;
                EndPt := XYno;
                end;
        Frame_Count := StartPt;

        Case C of
             cmOk     : Overide;
             cmNo     : If Plot_Ended
                           Then Align_Plot (KeyNo)
                           Else Align_Plot (1);
             cmYes    : If Plot_Ended
                           Then Reverse_Plot
                           Else Forward_Plot;
             end;

  Until C = cmCancel;

  Dispose(Dialog, Done);
  end;
End;

(* Dialog for Run Stop Motion options. *)

Procedure TVApp.RunStopDialog;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  S : String;
  Verror : Integer;
  XS, YS, ZS, RS : String;

Begin
If XYno <= 1
  Then MessageBox ('No plot points in memory',Nil, mfInformation + mfOkButton )
  Else begin
  R.Assign(10, 6, 70, 19);
  Dialog := New(PEditDialog, Init(R, ' Run Stop Motion Points '));
  with Dialog^ do
  begin
    HelpCtx := hcRunStop;

    R.Assign(2, 3, 58, 4);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 4, 58, 5);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 5, 58, 6);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 2, 58, 3);
    Insert (New (PLabel, Init (R,
    'Point     Axis XX   Axis YY   Axis ZZ   Axis RR', The_Dialog)));

    R.Assign(2, 7, 15, 9);
    Insert(New(PButton, Init(R, '~R~un', cmYes, bfDefault)));
    R.Assign (20, 7, 33, 9);
    The_Dialog := New (PRadioButtons, Init (R,
      NewSItem ('Forward',
      NewSItem ('Reverse',
      nil))
      ));
    Insert (The_Dialog);
    R.Assign (35, 7, 55, 9);
    The_Dialog := New (PRadioButtons, Init (R,
      NewSItem ('Automatic',
      NewSItem ('Single-Frame',
      nil))
      ));
    Insert (The_Dialog);

    R.Assign (2, 10, 15, 12);
    Insert (New (PButton, Init (R, '~A~lign', cmNo, bfNormal)));
    R.Assign(23, 10, 38, 12);
    Insert (New (PButton, Init (R, '~O~veride', cmOk, bfNormal)));
    R.Assign (46, 10, 58, 12);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;

  RunData.StatLine1 := RunData.PlotData [1];
  RunData.StatLine2 := '';
  If KeyNo > 0
     Then RunData.StatLine3 := RunData.PlotData [KeyNo]
     Else RunData.StatLine3 := '';

  Str (AA [XX].Key [1]:10:AA[XX].K.dp, XS);
  Str (AA [YY].Key [1]:10:AA[YY].K.dp, YS);
  Str (AA [ZZ].Key [1]:10:AA[ZZ].K.dp, ZS);
  Str (AA [RR].Key [1]:10:AA[RR].K.dp, RS);
  RunData.StatLine1 := 'StartPt' + XS + YS + ZS + RS;
  RunData.StatLine2 := '';
  Str (AA [XX].Key [KeyNo]:10:AA[XX].K.dp, XS);
  Str (AA [YY].Key [KeyNo]:10:AA[YY].K.dp, YS);
  Str (AA [ZZ].Key [KeyNo]:10:AA[ZZ].K.dp, ZS);
  Str (AA [RR].Key [KeyNo]:10:AA[RR].K.dp, RS);
  RunData.StatLine3 := 'End  Pt' + XS + YS + ZS + RS;

  Plot_Ended := False;
  StartPt := 0;
  EndPt := XYno;
  Frame_Count := 0;

  Repeat
     Get_Axis_Updates;
     Str (AA [XX].K.Cur_Posn:10:AA[XX].K.dp, XS);
     Str (AA [YY].K.Cur_Posn:10:AA[YY].K.dp, YS);
     Str (AA [ZZ].K.Cur_Posn:10:AA[ZZ].K.dp, ZS);
     Str (AA [RR].K.Cur_Posn:10:AA[RR].K.dp, RS);
     RunData.StatLine2 := 'Current' + XS + YS + ZS + RS;
     If Plot_Ended
        Then RunData.RadioBoxData := 1
        Else RunData.RadioBoxData := 0;
     If Single_Framed
        Then RunData.CheckBoxData := 1
        Else RunData.CheckBoxData := 0;
     Dialog^.SetData(RunData);

     C := DeskTop^.ExecView(Dialog);

        Dialog^.GetData(RunData);
        With RunData Do
             begin
             Plot_Ended := (RadioBoxData = 1);
             Stop_Motion := True;
             Go_Motion := False;
             Single_Framed := (CheckBoxData = 1);
             end;
        If Plot_Ended
           Then begin
                StartPt := XYno;
                EndPt := 0;
                end
           Else begin
                StartPt := 0;
                EndPt := XYno;
                end;
        Frame_Count := StartPt;

        Case C of
             cmOk     : Overide;
             cmNo     : If Plot_Ended
                           Then Align_Plot (KeyNo)
                           Else Align_Plot (1);
{$IFDEF GOMOTION_CONTROL}
             cmYes    : Run_Go_Motion;
{$ELSE}
             cmYes    : Run_Plot;
{$ENDIF}
             end;

  Until C = cmCancel;

  Dispose(Dialog, Done);
  end;
End;

(*****)

{$IFDEF GOMOTION_CONTROL}

(* Dialog for Run Go Motion Streaking options. *)

Type
  GoMoDataType = record
    StatLine1 : String [128];
    StatLine2 : String [128];
    StatLine3 : String [128];
    FrameLine1 : String [10];
    FrameLine2 : String [10];
    RadioBoxData : Word;
    CheckBoxData : Word;
    CheckBoxData2 : Word;
    ExpLine1 : String [10];
    ExpLine2 : String [10];
    end;

Var
  GoMoData : GoMoDataType;

Procedure TVApp.RunGoMoDialog;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  S : String;
  Verror : Integer;
  XS, YS, ZS, RS : String;

Begin
If XYno <= 1
  Then MessageBox ('No plot points in memory',Nil, mfInformation + mfOkButton )
  Else begin
  R.Assign(10, 4, 70, 20);
  Dialog := New(PEditDialog, Init(R, ' Run Go Motion Points '));
  with Dialog^ do
  begin
    HelpCtx := hcRunGoMo;

    R.Assign(2, 3, 58, 4);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 4, 58, 5);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 5, 58, 6);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 2, 58, 3);
    Insert (New (PLabel, Init (R,
    'Point     Axis XX   Axis YY   Axis ZZ   Axis RR', The_Dialog)));

    R.Assign(14, 7, 21, 8);
    The_Dialog := New(PInputLine, Init(R, 10));
    Insert(The_Dialog);
    R.Assign(2, 7, 13, 8);
    Insert (New (PLabel, Init (R, 'StartFrame', The_Dialog)));
    R.Assign(14, 8, 21, 9);
    The_Dialog := New(PInputLine, Init(R, 10));
    Insert(The_Dialog);
    R.Assign(2, 8, 13, 9);
    Insert (New (PLabel, Init (R, 'End  Frame', The_Dialog)));
    R.Assign (23, 7, 36, 9);
    The_Dialog := New (PRadioButtons, Init (R,
      NewSItem ('Forward',
      NewSItem ('Reverse',
      nil))
      ));
    Insert (The_Dialog);
    R.Assign (38, 7, 58, 9);
    The_Dialog := New (PRadioButtons, Init (R,
      NewSItem ('Auto Sequence',
      NewSItem ('Single Frame ',
      nil))
      ));
    Insert (The_Dialog);
    R.Assign (2, 10, 36, 12);
    The_Dialog := New (PCheckBoxes, Init (R,
      NewSItem ('Streak Sizes = Increment Sizes',
      NewSItem ('Streak Times = Exposure Times',
      nil))
      ));
    Insert (The_Dialog);
    R.Assign(48, 11, 58, 12);
    The_Dialog := New(PInputLine, Init(R, 10));
    Insert(The_Dialog);
    R.Assign(38, 11, 48, 12);
    Insert (New (PLabel, Init (R, 'Exp Time', The_Dialog)));

    R.Assign (2, 13, 13, 15);
    Insert(New(PButton, Init(R, '~R~un', cmYes, bfDefault)));
    R.Assign (16, 13, 27, 15);
    Insert (New (PButton, Init (R, '~A~lign', cmNo, bfNOrmal)));
    R.Assign(30, 13, 43, 15);
    Insert (New (PButton, Init (R, '~O~veride', cmOk, bfNormal)));
    R.Assign (48, 13, 58, 15);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;

  Str (AA [XX].Key [1]:10:AA[XX].K.dp, XS);
  Str (AA [YY].Key [1]:10:AA[YY].K.dp, YS);
  Str (AA [ZZ].Key [1]:10:AA[ZZ].K.dp, ZS);
  Str (AA [RR].Key [1]:10:AA[RR].K.dp, RS);
  GomoData.StatLine1 := 'StartPt' + XS + YS + ZS + RS;
  GomoData.StatLine2 := '';
  Str (AA [XX].Key [KeyNo]:10:AA[XX].K.dp, XS);
  Str (AA [YY].Key [KeyNo]:10:AA[YY].K.dp, YS);
  Str (AA [ZZ].Key [KeyNo]:10:AA[ZZ].K.dp, ZS);
  Str (AA [RR].Key [KeyNo]:10:AA[RR].K.dp, RS);
  GomoData.StatLine3 := 'End  Pt' + XS + YS + ZS + RS;

  Plot_Ended := False;
  Reverse_Runned := False;
  StartPt := 0;
  EndPt := XYno;
  Frame_Count := 0;
  GomoData.CheckBoxData2 := 0;

  Repeat
     Get_Axis_Updates;
     Str (AA [XX].K.Cur_Posn:10:AA[XX].K.dp, XS);
     Str (AA [YY].K.Cur_Posn:10:AA[YY].K.dp, YS);
     Str (AA [ZZ].K.Cur_Posn:10:AA[ZZ].K.dp, ZS);
     Str (AA [RR].K.Cur_Posn:10:AA[RR].K.dp, RS);
     GomoData.StatLine2 := 'Current' + XS + YS + ZS + RS;
     If Reverse_Runned
        Then GomoData.RadioBoxData := 1
        Else GomoData.RadioBoxData := 0;
     If Single_Framed
        Then GomoData.CheckBoxData := 1
        Else GomoData.CheckBoxData := 0;
     If Streaked_Increments
        Then GomoData.CheckBoxData2 := GomoData.CheckBoxData2 OR $01
        Else GomoData.CheckBoxData2 := GomoData.CheckBoxData2 AND $FE;
     If Streaked_Exposures
        Then GomoData.CheckBoxData2 := GomoData.CheckBoxData2 OR $02
        Else GomoData.CheckBoxData2 := GomoData.CheckBoxData2 AND $FD;
     Str (StartPt:4, GomoData.FrameLine1);
     Str (EndPt:4,   GomoData.FrameLine2);
     Str (Exposure_Time:5:2, GomoData.ExpLine1);
     Dialog^.SetData (GomoData);

     C := DeskTop^.ExecView(Dialog);

        Dialog^.GetData (GomoData);
        With GomoData Do
             begin
             Reverse_Runned := (RadioBoxData = 1);
             Stop_Motion := True;
             Go_Motion := True;
             Single_Framed := (CheckBoxData = 1);
             Streaked_Increments := (CheckBoxData2 AND $01 = $01);
             Streaked_Exposures := (CheckBoxData2 AND $02 = $02);
             Val (FrameLine1, StartPt, Verror);
             If StartPt > XYno
                Then StartPt := XYno
             Else If StartPt < 0
                Then StartPt := 0;
             Val (ExpLine1, Exposure_Time, Verror);
             If Exposure_Time <= 0.0
                Then Exposure_Time := 0.001;
             end;
        If Reverse_Runned
           Then EndPt := 0
           Else EndPt := XYno;
        If Reverse_Runned
           Then If StartPt = 0
                Then StartPt := XYno
                Else
           Else If StartPt = XYno
                Then StartPt := 0
                Else;
        Frame_Count := StartPt;

        Case C of
             cmOk     : Overide;
             cmNo     : Align_Point (StartPt);
             cmYes    : begin
                        Run_Go_Motion;
                        If Reverse_Runned
                           Then If Frame_Count > 0
                                Then StartPt := Frame_Count
                                Else StartPt := XYno
                           Else If Frame_Count < XYno
                                Then StartPt := Frame_Count
                                Else StartPt := 0;
                        end;
             end;
  Until C = cmCancel;

  Dispose(Dialog, Done);
  end;
End;

{$ELSE}

Procedure TVApp.RunGoMoDialog;
Begin
   MessageBox ('Go Motion is Not Available', Nil,
      mfInformation + mfOkButton);
End;

{$ENDIF}


(*****)

(* Dialog for joystick overide. *)

Type
  OverDataType = Record
    Axes : Word;
    Positions : String [128];
    end;

Var
  OverData : OverDataType;

Procedure TVApp.OverDialog;
var
  The_Dialog: PView;
  Dialog: PDialog;
  R: TRect;
  C: Word;
  XS, YS, ZS, RS : String;
  Mask : Word;
begin
  R.Assign(10, 6, 70, 19);
  Dialog := New (PDialog, Init (R, ' Overide Motion Control '));
  with Dialog^ do
  begin
    HelpCtx := hcOveride;

    R.Assign (12, 7, 25, 11);
    The_Dialog := New (PCheckBoxes, Init (R,
      NewSItem ('~XX~ Axis',
      NewSItem ('~YY~ Axis',
      NewSItem ('~ZZ~ Axis',
      NewSItem ('~RR~ Axis',
      nil))))
    ));
    Insert(The_Dialog);
    R.Assign (12, 6, 25, 7);
    Insert (New (PLabel, Init (R, 'Active Axes', The_Dialog)));

    R.Assign (9, 4, 54, 5);
    The_Dialog := New (PInputLine, Init (R, 128));
    Insert(The_Dialog);
    R.Assign (12, 2, 51, 3);
    Insert (New (PLabel, Init (R,
      'Axis XX   Axis YY   Axis ZZ   Axis RR', The_Dialog)));

    R.Assign (39, 6, 51, 8);
    Insert (New (PButton, Init (R, '~O~veride', cmOK, bfDefault)));
    R.Assign (39, 8, 51, 10);
    Insert (New (PButton, Init (R, '~Z~ero', cmYes, bfNormal)));
    R.Assign (39, 10, 51, 12);
    Insert (New (PButton, Init (R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
  end;

  Mask := $00;
  If AA [XX].Spec Then Mask := Mask OR $01;
  If AA [YY].Spec Then Mask := Mask OR $02;
  If AA [ZZ].Spec Then Mask := Mask OR $04;
  If AA [RR].Spec Then Mask := Mask OR $08;
  OverData.Axes := Mask;

  Repeat
     Get_Axis_Updates;
     Str (AA [XX].K.Cur_Posn:10:AA[XX].K.dp, XS);
     Str (AA [YY].K.Cur_Posn:10:AA[YY].K.dp, YS);
     Str (AA [ZZ].K.Cur_Posn:10:AA[ZZ].K.dp, ZS);
     Str (AA [RR].K.Cur_Posn:10:AA[RR].K.dp, RS);
     OverData.Positions := XS + YS + ZS + RS;
     Dialog^.SetData(OverData);

     C := DeskTop^.ExecView(Dialog);

     Dialog^.GetData(OverData);
     AA [XX].Spec := (OverData.Axes AND $01 = $01);
     AA [YY].Spec := (OverData.Axes AND $02 = $02);
     AA [ZZ].Spec := (OverData.Axes AND $04 = $04);
     AA [RR].Spec := (OverData.Axes AND $08 = $08);

     If C = cmOK
        Then Overide;

     If C = cmYes
        Then ZeroM_All;

  Until C = cmCancel;

  Dispose(Dialog, Done);
end;

(* Dialog for Jog overide. *)

Procedure TVApp.OverJogDialog;
type
  JogData_Record = Record
    Position : String [20];
    JogType : Word;
    Increment : String [20];
    Active : Word;
    end;
var
  The_Dialog: PView;
  Dialog: PDialog;
  R: TRect;
  C: Word;
  JogData : JogData_Record;
  Verror : Integer;
  IX : Integer;
  Distance : Real;
  Jogging : Boolean;
  Inching : Boolean;
const
  LotsOsteps = 999000.0;
  KillingTime = 100;
begin
  R.Assign(20, 2, 60, 21);
  Dialog := New (PDialog, Init (R, ' Jog Axis Overide '));
  with Dialog^ do
  begin
    HelpCtx := hcOveride;

    R.Assign (23, 2, 36, 3);
    The_Dialog := New (PInputLine, Init (R, 20));
    Insert(The_Dialog);
    R.Assign (2, 2, 22, 3);
    Insert (New (PLabel, Init (R, 'Position for Axis = ', The_Dialog)));

    R.Assign (7, 5, 18, 7);
    Insert (New (PButton, Init (R, 'Jog ~-~', cmNo, bfNormal)));
    R.Assign (21, 5, 32, 7);
    Insert (New (PButton, Init (R, 'Jog ~+~', cmYes, bfNormal)));

    R.Assign (3, 9, 21, 11);
    The_Dialog := New (PRadioButtons, Init (R,
      NewSItem ('~S~top-and-Go',
      NewSItem ('~I~ncremental',
      nil))
    ));
    Insert(The_Dialog);
    R.Assign (3, 8, 21, 9);
    Insert (New (PLabel, Init (R, 'Jog Technique', The_Dialog)));
    R.Assign (23, 10, 36, 11);
    The_Dialog := New (PInputLine, Init (R, 20));
    Insert(The_Dialog);

    R.Assign (3, 13, 16, 17);
    The_Dialog := New (PRadioButtons, Init (R,
      NewSItem ('~XX~ Axis',
      NewSItem ('~YY~ Axis',
      NewSItem ('~ZZ~ Axis',
      NewSItem ('~RR~ Axis',
      nil))))
    ));
    Insert(The_Dialog);
    R.Assign (3, 12, 16, 13);
    Insert (New (PLabel, Init (R, 'Active Axis', The_Dialog)));

    R.Assign (27, 13, 37, 15);
    Insert (New (PButton, Init (R, '~K~ill', cmOK, bfDefault)));
    R.Assign (27, 16, 37, 18);
    Insert (New (PButton, Init (R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (False);
    SelectNext (False);
    SelectNext (False);
  end;

  With JogData Do
       begin
       IX := 1;
       Active := $00;
       Str (AA [IX].K.Cur_Posn:10:AA[IX].K.DP, Position);
       JogType := $00;
       Distance := 1.0;
       Increment := '1.0';
       end;

  Jogging := False;
  Inching := False;

  Repeat
     If NOT Jogging
        Then begin
        Get_Axis_Updates;
        Str (AA [IX].K.Cur_Posn:10:AA[IX].K.DP, JogData.Position);
        end;

     Dialog^.SetData (JogData);
     C := DeskTop^.ExecView(Dialog);
     Dialog^.GetData (JogData);

     With JogData Do
          begin
          Case Active of
               $00 : IX := XX;
               $01 : IX := YY;
               $02 : IX := ZZ;
               $03 : IX := RR;
               Else  IX := XX;
               end;
          If JogType >= $01
             Then Inching := True
             Else Inching := False;
          Val (Increment, Distance, Verror);
          Convert (Distance, AA [IX].K.Kscale, Distance);
          end;
     Case C of
          cmYes : begin
                  If Inching
                     Then begin
                          AA [IX].M.StepCnt := Distance;
                          AA [IX].M.Dir := FWD;
                          RunM (AA [IX].M);
                          Jogging := False;
                          end
                  Else If NOT Jogging
                     Then begin
                          AA [IX].M.StepCnt := LotsOsteps;
                          AA [IX].M.Dir := FWD;
                          RunM (AA [IX].M);
                          Jogging := True;
                          end
                     Else begin
                          KillM (AA [IX].M);
                          Delay (KillingTime);
                          Local_WaitOver;
                          Jogging := False;
                          end;
                  end;
          cmNo  : begin
                  If Inching
                     Then begin
                          AA [IX].M.StepCnt := Distance;
                          AA [IX].M.Dir := REV;
                          RunM (AA [IX].M);
                          Jogging := False;
                          end
                  Else If NOT Jogging
                     Then begin
                          AA [IX].M.StepCnt := LotsOsteps;
                          AA [IX].M.Dir := REV;
                          RunM (AA [IX].M);
                          Jogging := True;
                          end
                     Else begin
                          KillM (AA [IX].M);
                          Delay (KillingTime);
                          Local_WaitOver;
                          Jogging := False;
                          end;
                  end;
          cmOk  : begin
                  (* Emergency_Reset; *)
                  KillM (AA [IX].M);
                  Delay (KillingTime);
                  (* Emergency_Kill; *)
                  Local_WaitOver;
                  Jogging := False;
                  end;
          end;
  Until C = cmCancel;

  Dispose(Dialog, Done);
end;

(* Dialog for alignment procedure. *)

Procedure TVApp.AlignDialog;
var
  The_Dialog: PView;
  Dialog: PDialog;
  R: TRect;
  C: Word;
  XS, YS, ZS, RS : String;
  Mask : Word;
begin
  R.Assign(10, 6, 70, 19);
  Dialog := New (PDialog, Init (R, ' Alignment Procedure '));
  with Dialog^ do
  begin
    HelpCtx := hcRunAlign;

    R.Assign (12, 7, 25, 11);
    The_Dialog := New (PCheckBoxes, Init (R,
      NewSItem ('~XX~ Axis',
      NewSItem ('~YY~ Axis',
      NewSItem ('~ZZ~ Axis',
      NewSItem ('~RR~ Axis',
      nil))))
    ));
    Insert(The_Dialog);
    R.Assign (12, 6, 25, 7);
    Insert (New (PLabel, Init (R, 'Active Axes', The_Dialog)));

    R.Assign (9, 4, 54, 5);
    The_Dialog := New (PInputLine, Init (R, 128));
    Insert(The_Dialog);
    R.Assign (12, 2, 51, 3);
    Insert (New (PLabel, Init (R,
      'Axis XX   Axis YY   Axis ZZ   Axis RR', The_Dialog)));

    R.Assign (39, 6, 51, 8);
    Insert (New (PButton, Init (R, '~A~lign', cmOK, bfDefault)));
    R.Assign (39, 8, 51, 10);
    Insert (New (PButton, Init (R, '~Z~ero', cmYes, bfNormal)));
    R.Assign (39, 10, 51, 12);
    Insert (New (PButton, Init (R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
  end;

  Mask := $00;
  If AA [XX].H.Spec Then Mask := Mask OR $01;
  If AA [YY].H.Spec Then Mask := Mask OR $02;
  If AA [ZZ].H.Spec Then Mask := Mask OR $04;
  If AA [RR].H.Spec Then Mask := Mask OR $08;
  OverData.Axes := Mask;

  Repeat
     Get_Axis_Updates;
     Str (AA [XX].K.Cur_Posn:10:AA[XX].K.dp, XS);
     Str (AA [YY].K.Cur_Posn:10:AA[YY].K.dp, YS);
     Str (AA [ZZ].K.Cur_Posn:10:AA[ZZ].K.dp, ZS);
     Str (AA [RR].K.Cur_Posn:10:AA[RR].K.dp, RS);
     OverData.Positions := XS + YS + ZS + RS;
     Dialog^.SetData(OverData);

     C := DeskTop^.ExecView(Dialog);

     Dialog^.GetData(OverData);
     AA [XX].H.Spec := (OverData.Axes AND $01 = $01);
     AA [YY].H.Spec := (OverData.Axes AND $02 = $02);
     AA [ZZ].H.Spec := (OverData.Axes AND $04 = $04);
     AA [RR].H.Spec := (OverData.Axes AND $08 = $08);

     If C = cmOK
        Then Run_Alignment;

     If C = cmYes
        Then (* ZeroM_All; *) Zero_Alignment;

  Until C = cmCancel;

  Dispose(Dialog, Done);
end;

