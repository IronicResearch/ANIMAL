(* Pop up File-Viewer window. *)

procedure TVApp.ViewFile(FileName: PathStr);
var
  W: PWindow;
begin
  W := New(PFileWindow,Init(FileName));
  W^.HelpCtx := hcFView;
  if ValidView(W) <> nil
     then Desktop^.Insert(W);
end;

(* Pop up File-Open dialog box. *)

procedure TVApp.FileOpen (WildCard: PathStr);
var
  D: PFileDialog;
  The_FileName: PathStr;
begin
  D := New(PFileDialog, Init(WildCard, ' Load File ',
    '~N~ame', fdOpenButton + fdHelpButton, 100));
  D^.HelpCtx := hcFOpen;
  if ValidView(D) <> nil
     then begin
     DCmdBuf := cmCancel;
     if Desktop^.ExecView(D) <> cmCancel
        then begin
        D^.GetFileName (The_FileName);
        FileName := The_FileName;
        DCmdBuf := cmOk;
        end;
      Dispose(D, Done);
      end;
end;

(* Dialog for Saving File. *)

Procedure TVApp.SaveDialog;
var
  The_Dialog: PView;
  Dialog: PDialog;
  R: TRect;
  C: Word;
  File_Ok : Boolean;
begin
  R.Assign(20, 5, 60, 15);
  Dialog := New(PDialog, Init(R, ' Save File '));
  with Dialog^ do
  begin
    HelpCtx := hcFileSave;

    R.Assign(5, 4, 35, 5);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(5, 2, 35, 3);
    Insert(New(PLabel, Init(R, 'File Name to Save:', The_Dialog)));

    R.Assign(5, 7, 15, 9);
    Insert(New(PButton, Init(R, '~S~ave', cmOK, bfDefault)));
    R.Assign(25, 7, 35, 9);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext (False);
  end;

  Repeat
     Dialog^.SetData (FileName);
     C := DeskTop^.ExecView(Dialog);
     DCmdBuf := C;
     If C = cmOk
        Then begin
             Dialog^.GetData (FileName);
             Query_File_Extension (FileName, FileExtn);
             If Query_File_Exists (FileName)
                Then begin
                     C := MessageBox ('File Already Exists...OverWrite?', Nil,
                          mfWarning + mfYesbutton + mfNobutton + mfCancelbutton);
                     Case C of
                          cmYes    : File_Ok := True;
                          cmNo     : File_Ok := False;
                          cmCancel : DCmdBuf := cmCancel;
                          end;
                     end
                Else File_Ok := True;
             end
        Else File_Ok := False;
  Until File_Ok OR (DCmdBuf = cmCancel);

  Dispose(Dialog, Done);
end;

(* Dialog box generation for New plot. *)
(* Note PLabels get inserted after the stuff they are labelling. *)

Type
  NewDialogDataType = record
    CheckBoxData: Word;
    RadioButtonData: Word;
    InputLineData: string[128];
    InputLineData2: string[128];
    end;

Var
  NewData : NewDialogDataType;

Procedure TVApp.NewDialog;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  Verror : Integer;
begin
  Query_Save_File;

  R.Assign(20, 6, 60, 19);
  Dialog := New(PEditDialog, Init(R, ' New Plot '));
  with Dialog^ do
  begin
    HelpCtx := hcFileNew;

    R.Assign(2, 3, 20, 6);
    The_Dialog := New(PCheckBoxes, Init(R,
      NewSItem('~K~ey Frames',
      NewSItem('~T~aper Frames',
      NewSItem('~I~nter Points',
      nil)))
    ));
    Insert(The_Dialog);
    R.Assign(2, 2, 10, 3);
    Insert(New(PLabel, Init(R, 'Options', The_Dialog)));

    R.Assign(21, 3, 37, 6);
    The_Dialog := New(PRadioButtons, Init(R,
      NewSItem('~S~top Motion',
      NewSItem('~G~o Motion',
      NewSItem('~R~eal-Time',
      nil)))
    ));
    Insert(The_Dialog);
    R.Assign(21, 2, 33, 3);
    Insert(New(PLabel, Init(R, 'Motion', The_Dialog)));

    R.Assign(3, 8, 17, 9);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(3, 7, 17, 8);
    Insert(New(PLabel, Init(R, 'Screen Time', The_Dialog)));

    R.Assign(21, 8, 37, 9);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(21, 7, 37, 8);
    Insert(New(PLabel, Init(R, 'Key Frames', The_Dialog)));

    R.Assign(15, 10, 25, 12);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(28, 10, 38, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;

  With NewData Do
       begin
       Str (Screen_Time:3:1, InputLineData);
       Str (KeyNo:2, InputLineData2);
       If KeyFrames_Saved
          Then CheckBoxData := CheckBoxData OR  $01
          Else CheckBoxData := CheckBoxData AND $FE;
       If Tapers_Saved
          Then CheckBoxData := CheckBoxData OR  $02
          Else CheckBoxData := CheckBoxData AND $FD;
       If Points_Saved
          Then CheckBoxData := CheckBoxData OR  $04
          Else CheckBoxData := CheckBoxData AND $FB;
       If Go_Motion
            Then RadioButtonData := 1
       Else If Stop_Motion
            Then RadioButtonData := 0
            Else RadioButtonData := 2;
       end;
  Dialog^.SetData(NewData);
  C := DeskTop^.ExecView(Dialog);
  DCmdBuf := C;
  if C <> cmCancel
     then begin
     Dialog^.GetData(NewData);
     New_Plot;
     With NewData Do
          begin
          Val (NewData.InputLineData, Screen_Time, Verror);
          Val (NewData.InputLineData2, KeyNo, Verror);
          KeyFrames_Saved := (CheckBoxData AND $01 = $01);
          Tapers_Saved := (CheckBoxData AND $02 = $02);
          Points_Saved := (CheckBoxData AND $04 = $04);
          end;
     Edit_Screen_Time;
     if (KeyNo > 0)
        then Compute_Time_Base;
     end;

  Dispose(Dialog, Done);
end;

