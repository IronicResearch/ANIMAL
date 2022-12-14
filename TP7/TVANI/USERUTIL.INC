(* Axis Mapping Dialog. *)

Procedure TVApp.AxisDialog;
var
  Dialog: PDialog;
  R: TRect;
  C: Word;
  The_Dialog : PView;
  XC, YC : Integer;
  XI, YI : Integer;
  AS : String [2];
  AxisData : Array [1..4] of Array [1..3] of String [20];
  RI, CI : Integer;
  Verror : Integer;
begin
  R.Assign(10, 6, 70, 19);
  Dialog := New (PDialog, Init(R, ' Axis Mapping Assignment Utility '));
  with Dialog^ do
  begin
    HelpCtx := hcUtilAxis;

    R.Assign (4, 2, 58, 3);
    Insert (New (PStaticText,
      Init (R, 'Axis    Label ID    Motor #       Description')));

    For YI := 1 to 4 Do
        begin
        YC := YI+3;
        Str (YI, AS);
        R.Assign (5, YC, 7, YC+1);
        Insert (New (PStaticText, Init (R, AS)));
        end;
        
    For YI := 1 to 4 Do
        begin
        For XI := 1 to 2 Do
            begin
            YC := YI+3;
            XC := 11*(XI-1) + 12;
            R.Assign (XC, YC, XC+8, YC+1);
            The_Dialog := New (PInputLine, Init (R, 20));
            Insert (The_Dialog);
            end;
        R.Assign (XC+11, YC, XC+31, YC+1);
        The_Dialog := New (PInputLine, Init (R, 20));
        Insert (The_Dialog);
        end;

    R.Assign(5, 10, 15, 12);
    Insert(New(PButton, Init(R, '~E~dit', cmOK, bfDefault)));
    R.Assign(18, 10, 28, 12);
    Insert(New(PButton, Init(R, '~S~ave', cmYes, bfNormal)));
    R.Assign(31, 10, 41, 12);
    Insert(New(PButton, Init(R, '~L~oad', cmNo, bfNormal)));
    R.Assign(45, 10, 55, 12);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;

  Repeat
    For RI := 1 to 4 Do
      begin
      If RI = 4
         Then I := RR
         Else I := RI;
      AxisData [RI][1] := AA [I].A.ID;
      Str (AA [I].A.No:3, AxisData [RI][2]);
      AxisData [RI][3] := AA [I].A.Name;
      end;

     Dialog^.SetData (AxisData);
     C := DeskTop^.ExecView(Dialog);
     Case C of
          cmOk,
          cmYes : begin
                  Dialog^.GetData (AxisData);
                  For RI := 1 to 4 Do
                      begin
                      If RI = 4
                         Then I := RR
                         Else I := RI;
                      AA [I].A.ID [1] := AxisData [RI][1][1];
                      AA [I].A.ID [2] := AxisData [RI][1][2];
                      Val (AxisData [RI][2], AA [I].A.No, Verror);
                      AA [I].A.Name := AxisData [RI][3];
                      end;
                  end;
          end;
     Case C of
          cmYes : begin
                  FileName := Default_Mapping;
                  FileExtn := 'MAP';
                  AniApp.SaveDialog;
                  If DCmdBuf = cmOk
                     Then begin
                     Default_Mapping := FileName;
                     CheapStatus ('...Saving Axis Map File ' + FileName + '...');
                     Save_Axis_File;
                     CheapStatusClear;
                     end;
                  end;

          cmNo  : begin
                  FileName := Default_Mapping;
                  AniApp.FileOpen ('*.MAP');
                  If DCmdBuf = cmOk
                     Then begin
                     Default_Mapping := FileName;
                     CheapStatus ('...Loading Axis Map File ' + FileName + '...');
                     Load_Axis_File;
                     CheapStatusClear;
                     end;
                  end;
          end;
  Until C = cmCancel;

  Dispose(Dialog, Done);
end;

(* User Units Dialog. *)

Procedure TVApp.UserDialog;
var
  Dialog: PDialog;
  R: TRect;
  C: Word;
  The_Dialog : PView;
  XC, YC : Integer;
  XI, YI : Integer;
  AS : String [2];
  UserData : Array [1..4] of Array [1..4] of String [20];
  RI, CI : Integer;
  Verror : Integer;
  Kunits : Real;
begin
  R.Assign(10, 6, 70, 19);
  Dialog := New (PDialog, Init(R, ' User Units Conversion Utility '));
  with Dialog^ do
  begin
    HelpCtx := hcUtilUser;

    R.Assign (4, 2, 58, 3);
    Insert (New (PStaticText,
      Init (R, 'Axis     Unit/Step  Step/Unit    Units     Dec Pt')));

    For YI := 1 to 4 Do
        begin
        YC := YI+3;
        Case YI of
             1 : AS := 'XX';
             2 : AS := 'YY';
             3 : AS := 'ZZ';
             4 : AS := 'RR';
             end;
        R.Assign (5, YC, 7, YC+1);
        Insert (New (PStaticText, Init (R, AS)));
        end;

    For YI := 1 to 4 Do
        For XI := 1 to 4 Do
        begin
        YC := YI+3;
        XC := 11*(XI-1) + 12;
        R.Assign (XC, YC, XC+10, YC+1);
        The_Dialog := New (PInputLine, Init (R, 20));
        Insert (The_Dialog);
        end;

    R.Assign(5, 10, 15, 12);
    Insert(New(PButton, Init(R, '~E~dit', cmOK, bfDefault)));
    R.Assign(18, 10, 28, 12);
    Insert(New(PButton, Init(R, '~S~ave', cmYes, bfNormal)));
    R.Assign(31, 10, 41, 12);
    Insert(New(PButton, Init(R, '~L~oad', cmNo, bfNormal)));
    R.Assign(45, 10, 55, 12);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;

  Repeat
    For RI := 1 to 4 Do
      begin
      If RI = 4
         Then I := RR
         Else I := RI;
      Str (AA [I].K.Kscale:8:AA[I].K.dp, UserData [RI][1]);
      If AA [I].K.Kscale = 0.0
         Then Kunits := 0.0
         Else Kunits := 1.0 / AA [I].K.Kscale;
      Str (Kunits:8:1, UserData [RI][2]);
      UserData [RI][3] := AA [I].K.Units;
      Str (AA [I].K.dp:8, UserData [RI][4]);
      end;

     Dialog^.SetData (UserData);
     C := DeskTop^.ExecView(Dialog);
     Case C of
          cmYes,
          cmOk  : begin
                  Dialog^.GetData (UserData);
                  For RI := 1 to 4 Do
                      begin
                      If RI = 4
                         Then I := RR
                         Else I := RI;
                      Val (UserData [RI][1], AA [I].K.Kscale, Verror);
                      AA [I].K.Units := UserData [RI][3];
                      Val (UserData [RI][4], AA [I].K.dp, Verror);
                      end;
                  end;
          end;
     Case C of
          cmYes : begin
                  FileName := Default_Units;
                  FileExtn := 'UNT';
                  AniApp.SaveDialog;
                  If DCmdBuf = cmOk
                     Then begin
                     Default_Units := FileName;
                     CheapStatus ('...Saving User Units File ' + FileName + '...');
                     Save_Units_File;
                     CheapStatusClear;
                     end;
                  end;

          cmNo  : begin
                  FileName := Default_Units;
                  AniApp.FileOpen ('*.UNT');
                  If DCmdBuf = cmOk
                     Then begin
                     Default_Units := FileName;
                     CheapStatus ('...Loading User Units File ' + FileName + '...');
                     Load_Units_File;
                     CheapStatusClear;
                     end;
                  end;
          end;
  Until C = cmCancel;

  Dispose(Dialog, Done);
end;

(* Motor Speeds Dialog. *)

Procedure TVApp.SpeedDialog;
var
  Dialog: PDialog;
  R: TRect;
  C: Word;
  The_Dialog : PView;
  XC, YC : Integer;
  XI, YI : Integer;
  AS : String [2];
  SpeedData : Array [1..4] of Array [1..3] of String [10];
  RI, CI : Integer;
  Verror : Integer;
begin
  R.Assign(10, 6, 70, 19);
  Dialog := New (PDialog, Init(R, ' Motor Speed Profile Utility '));
  with Dialog^ do
  begin
    HelpCtx := hcUtilSpeed;

    R.Assign (4, 2, 58, 3);
    Insert (New (PStaticText,
      Init (R, 'Axis      Low Speed    High Speed     Ramp')));

    For YI := 1 to 4 Do
        begin
        YC := YI+3;
        Case YI of
             1 : AS := 'XX';
             2 : AS := 'YY';
             3 : AS := 'ZZ';
             4 : AS := 'RR';
             end;
        R.Assign (5, YC, 7, YC+1);
        Insert (New (PStaticText, Init (R, AS)));
        end;

    For YI := 1 to 4 Do
        For XI := 1 to 3 Do
        begin
        YC := YI+3;
        XC := 13*(XI-1) + 12;
        R.Assign (XC, YC, XC+12, YC+1);
        The_Dialog := New (PInputLine, Init (R, 10));
        Insert (The_Dialog);
        end;

    R.Assign(5, 10, 15, 12);
    Insert(New(PButton, Init(R, '~E~dit', cmOK, bfDefault)));
    R.Assign(18, 10, 28, 12);
    Insert(New(PButton, Init(R, '~S~ave', cmYes, bfNormal)));
    R.Assign(31, 10, 41, 12);
    Insert(New(PButton, Init(R, '~L~oad', cmNo, bfNormal)));
    R.Assign(45, 10, 55, 12);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;

  Repeat
    For RI := 1 to 4 Do
      begin
      If RI = 4
         Then I := RR
         Else I := RI;
      Str (AA [I].R.Min_LowSpd:10, SpeedData [RI][1]);
      Str (AA [I].R.Max_HighSpd:10, SpeedData [RI][2]);
      Str (AA [I].R.Max_RampCnt:10, SpeedData [RI][3]);
      end;

     Dialog^.SetData (SpeedData);
     C := DeskTop^.ExecView(Dialog);
     Case C of
          cmYes,
          cmOk  : begin
                  Dialog^.GetData (SpeedData);
                  For RI := 1 to 4 Do
                      begin
                      If RI = 4
                         Then I := RR
                         Else I := RI;
                      Val (SpeedData[RI][1], AA[I].R.Min_LowSpd, Verror);
                      Val (SpeedData[RI][2], AA[I].R.Max_HighSpd, Verror);
                      Val (SpeedData[RI][3], AA[I].R.Max_RampCnt, Verror);
                      AA[I].R.Accel := TRUE;
                      end;
                  Fast_Speeds;
                  Init_Speeds;
                  end;
          end;
     Case C of
          cmYes : begin
                  FileName := Default_Speeds;
                  FileExtn := 'SPD';
                  AniApp.SaveDialog;
                  If DCmdBuf = cmOk
                     Then begin
                     Default_Speeds := FileName;
                     CheapStatus ('...Saving Motor Speed File ' + FileName + '...');
                     Save_Speed_File;
                     CheapStatusClear;
                     end;
                  end;

          cmNo  : begin
                  FileName := Default_Speeds;
                  AniApp.FileOpen ('*.SPD');
                  If DCmdBuf = cmOk
                     Then begin
                     Default_Speeds := FileName;
                     CheapStatus ('...Loading Motor Speed File ' + FileName + '...');
                     Load_Speed_File;
                     Fast_Speeds;
                     Init_Speeds;
                     CheapStatusClear;
                     end;
                  end;
          end;
  Until C = cmCancel;

  Dispose(Dialog, Done);
end;

(* Alignment Dialog. *)

Procedure TVApp.AlignmentDialog;
var
  Dialog: PDialog;
  R: TRect;
  C: Word;
  The_Dialog : PView;
  XC, YC : Integer;
  XI, YI : Integer;
  AS : String [2];
  AlignData : Array [1..4] of Array [1..4] of String [10];
  RI, CI : Integer;
  Verror : Integer;
begin
  R.Assign(10, 6, 70, 19);
  Dialog := New (PDialog, Init(R, ' Alignment Order Utility '));
  with Dialog^ do
  begin
    HelpCtx := hcUtilAlign;

    R.Assign (4, 2, 58, 3);
    Insert (New (PStaticText,
      Init (R, 'Axis     Order     Limit     Align     Zero Count')));

    For YI := 1 to 4 Do
        begin
        YC := YI+3;
        Case YI of
             1 : AS := 'XX';
             2 : AS := 'YY';
             3 : AS := 'ZZ';
             4 : AS := 'RR';
             end;
        R.Assign (5, YC, 7, YC+1);
        Insert (New (PStaticText, Init (R, AS)));
        end;
        
    For YI := 1 to 4 Do
        begin
        For XI := 1 to 3 Do
            begin
            YC := YI+3;
            XC := 10*(XI-1) + 13;
            R.Assign (XC, YC, XC+5, YC+1);
            The_Dialog := New (PInputLine, Init (R, 10));
            Insert (The_Dialog);
            end;
        R.Assign (XC+10, YC, XC+20, YC+1);
        The_Dialog := New (PInputLine, Init (R, 10));
        Insert (The_Dialog);
        end;

    R.Assign(5, 10, 15, 12);
    Insert(New(PButton, Init(R, '~E~dit', cmOK, bfDefault)));
    R.Assign(18, 10, 28, 12);
    Insert(New(PButton, Init(R, '~S~ave', cmYes, bfNormal)));
    R.Assign(31, 10, 41, 12);
    Insert(New(PButton, Init(R, '~L~oad', cmNo, bfNormal)));
    R.Assign(45, 10, 55, 12);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;

  Repeat
    For RI := 1 to 4 Do
      begin
      If RI = 4
         Then I := RR
         Else I := RI;
      Str (AA [I].H.Order, AlignData [RI][1]);
      If AA [I].H.Limit = REV
         Then AlignData [RI][2] := 'REV'
         Else AlignData [RI][2] := 'FWD';
      If AA [I].H.Align = REV
         Then AlignData [RI][3] := 'REV'
         Else AlignData [RI][3] := 'FWD';
      Str (AA [I].H.Count:8:0, AlignData [RI][4]);
      end;

     Dialog^.SetData (AlignData);
     C := DeskTop^.ExecView(Dialog);
     Case C of
          cmYes,
          cmOk  : begin
                  Dialog^.GetData (AlignData);
                  For RI := 1 to 4 Do
                      begin
                      If RI = 4
                         Then I := RR
                         Else I := RI;
                      Val (AlignData [RI][1], AA [I].H.Order, Verror);
                      If UpCase (AlignData [RI][2][1]) = 'R'
                         Then AA [I].H.Limit := REV
                         Else AA [I].H.Limit := FWD;
                      If UpCase (AlignData [RI][3][1]) = 'R'
                         Then AA [I].H.Align := REV
                         Else AA [I].H.Align := FWD;
                      Val (AlignData [RI][4], AA [I].H.Count, Verror);
                      end;
                  end;
          end;
     Case C of
          cmYes : begin
                  FileName := Default_Alignment;
                  FileExtn := 'ALN';
                  AniApp.SaveDialog;
                  If DCmdBuf = cmOk
                     Then begin
                     Default_Alignment:= FileName;
                     CheapStatus ('...Saving Alignment File ' + FileName + '...');
                     Save_Alignment_File;
                     CheapStatusClear;
                     end;
                  end;

          cmNo  : begin
                  FileName := Default_Alignment;
                  AniApp.FileOpen ('*.ALN');
                  If DCmdBuf = cmOk
                     Then begin
                     Default_Alignment := FileName;
                     CheapStatus ('...Loading Alignment File ' + FileName + '...');
                     Load_Alignment_File;
                     CheapStatusClear;
                     end;
                  end;
          end;
  Until C = cmCancel;

  Dispose(Dialog, Done);
end;

(* Output Triggers Dialog. *)

Procedure TVApp.TriggerDialog;
type
  TrigData_Record = Record
    Active : Array [1..5] of Word;
    TrigDef : Array [1..5] of Array [1..9] of Array [1..2] of String [10];
    end;
var
  Dialog: PDialog;
  R: TRect;
  C: Word;
  The_Dialog : PView;
  XC, YC : Integer;
  XI, YI : Integer;
  TS : String [20];
  TrigData : TrigData_Record;
  RI, CI : Integer;
  Verror : Integer;
  Vreal  : Real;
begin
  R.Assign(7, 1, 72, 23);
  Dialog := New (PDialog, Init(R, ' Trigger Output Definition Utility '));
  with Dialog^ do
  begin
    HelpCtx := hcUtilTrig;

    R.Assign (2, 2, 62, 4);
    Insert (New (PStaticText,
      Init (R, 'Trigger Phase         Output Lines 1-8         Time Interval' +
        + ^M + '                   1  2  3  4  5  6  7  8')));
    For YI := 1 to 5 Do
        begin
        YC := 3*(YI-1) + 4;
        Case YI of
             1 : TS := 'Pre-Exposure';
             2 : TS := 'Sync-Exposure';
             3 : TS := 'Post-Exposure';
             4 : TS := 'Pre-Increment';
             5 : TS := 'Post-Increment';
             end;
        R.Assign (2, YC, 18, YC+1);
        Insert (New (PStaticText, Init (R, TS)));
        R.Assign (2, YC+1, 16, YC+2);
        The_Dialog := New (PCheckBoxes, Init (R,
          NewSItem ('Active', nil)));
        Insert (The_Dialog);
        end;
        
    For YI := 1 to 5 Do
        begin
        For XI := 1 to 8 Do
            begin
            YC := 3*(YI-1) + 4;
            XC := 3*(XI-1) + 20;
            R.Assign (XC, YC, XC+3, YC+1);
            The_Dialog := New (PInputLine, Init (R, 10));
            Insert (The_Dialog);
            R.Assign (XC, YC+1, XC+3, YC+2);
            The_Dialog := New (PInputLine, Init (R, 10));
            Insert (The_Dialog);
            end;
        R.Assign (50, YC, 60, YC+1);
        The_Dialog := New (PInputLine, Init (R, 10));
        Insert (The_Dialog);
        R.Assign (50, YC+1, 60, YC+2);
        The_Dialog := New (PInputLine, Init (R, 10));
        Insert (The_Dialog);
        end;

    R.Assign(5, 19, 15, 21);
    Insert(New(PButton, Init(R, '~E~dit', cmOK, bfDefault)));
    R.Assign(20, 19, 30, 21);
    Insert(New(PButton, Init(R, '~S~ave', cmYes, bfNormal)));
    R.Assign(35, 19, 45, 21);
    Insert(New(PButton, Init(R, '~L~oad', cmNo, bfNormal)));
    R.Assign(50, 19, 60, 21);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;

  Repeat
    For RI := 1 to 5 Do
      begin
      If Trigger [RI].Spec
         Then TrigData.Active[RI] := $01
         Else TrigData.Active[RI] := $00;
      For CI := 1 to 8 Do
          begin
          If (Trigger[RI].Trig[CI] <> 0)
             Then TrigData.TrigDef[RI][CI][1] := '1'
             Else TrigData.TrigDef[RI][CI][1] := '0';
          If (Trigger[RI].Null[CI] <> 0)
             Then TrigData.TrigDef[RI][CI][2] := '1'
             Else TrigData.TrigDef[RI][CI][2] := '0';
          end;
      Str ((Trigger[RI].Time[1]/1000.0):8:3, TrigData.TrigDef[RI][9][1]);
      Str ((Trigger[RI].Wait[1]/1000.0):8:3, TrigData.TrigDef[RI][9][2]);
      end;

     Dialog^.SetData (TrigData);
     C := DeskTop^.ExecView(Dialog);
     Case C of
          cmYes,
          cmOk  : begin
                  Dialog^.GetData (TrigData);
                  For RI := 1 to 5 Do
                      begin
                      If (TrigData.Active [RI] AND $01) = $01
                         Then Trigger[RI].Spec := True
                         Else Trigger[RI].Spec := False;
                      For CI := 1 to 8 Do
                          begin
                          If TrigData.TrigDef[RI][CI][1] <> '0'
                             Then Trigger[RI].Trig [CI] := 1 SHL (CI-1)
                             Else Trigger[RI].Trig [CI] := 0;
                          If TrigData.TrigDef[RI][CI][2] <> '0'
                             Then Trigger[RI].Null [CI] := 1 SHL (CI-1)
                             Else Trigger[RI].Null [CI] := 0;
                          end;
                      Val (TrigData.TrigDef[RI][9][1], Vreal, Verror);
                      Trigger[RI].Time [1] := Round (Vreal * 1000.0);
                      Val (TrigData.TrigDef[RI][9][2], Vreal, Verror);
                      Trigger[RI].Wait [1] := Round (Vreal * 1000.0);
                      end;
                  end;
          end;
     Case C of
          cmYes : begin
                  FileName := Default_Triggers;
                  FileExtn := 'TRG';
                  AniApp.SaveDialog;
                  If DCmdBuf = cmOk
                     Then begin
                     Default_Triggers := FileName;
                     CheapStatus ('...Saving Trigger File ' + FileName + '...');
                     Save_Trigger_File;
                     CheapStatusClear;
                     end;
                  end;
          cmNo  : begin
                  FileName := Default_Triggers;
                  AniApp.FileOpen ('*.TRG');
                  If DCmdBuf = cmOk
                     Then begin
                     Default_Triggers := FileName;
                     CheapStatus ('...Loading Trigger File ' + FileName + '...');
                     Load_Trigger_File;
                     CheapStatusClear;
                     end;
                  end;
          end;
  Until C = cmCancel;

  Dispose(Dialog, Done);
end;

