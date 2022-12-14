(* Config Menu dialogs: *)

(* COM Serial port assignment.*)
Procedure TVApp.ComPortDialog;
type
  ComDataType = Record
     RadioButtonData : word;
     end;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  ComData : ComDataType;
  PortX: integer;
Begin
  R.Assign(25, 6, 55, 17);
  Dialog := New(PEditDialog, Init(R, ' Serial Interface '));
  with Dialog^ do
  begin
    HelpCtx := hcConfComPort;

    R.Assign(5, 3, 25, 7);
    The_Dialog := New(PRadioButtons, Init(R,
      NewSItem('COM~1~ (03F8)',
      NewSItem('COM~2~ (02F8)',
      NewSItem('COM~3~ (03E8)',
      NewSItem('COM~4~ (02E8)',
      nil))))
    ));
    Insert(The_Dialog);
    R.Assign(5, 2, 25, 3);
    Insert(New(PLabel, Init(R, 'Serial Port', The_Dialog)));

    R.Assign(3, 8, 13, 10);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(17, 8, 27, 10);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
    SelectNext(true);
  end;

  With ComData Do
       begin
       RadioButtonData := MCPU_PortX - 1;
       end;
  Dialog^.SetData(ComData);
  C := DeskTop^.ExecView(Dialog);
  if (C = cmOK)
     then begin
     Dialog^.GetData(ComData);
     With ComData Do
          begin
          MCPU_PortX := RadioButtonData + 1;
          end;
     end;

  Dispose(Dialog, Done);
  DCmdBuf := C;
End;

(* LPT Parrallel port assignment. *)
Procedure TVApp.LptPortDialog;
type
  ComDataType = Record
     RadioButtonData : word;
     end;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  ComData : ComDataType;
  PortX: integer;
Begin
  R.Assign(25, 6, 55, 17);
  Dialog := New(PEditDialog, Init(R, ' Parallel Interface '));
  with Dialog^ do
  begin
    HelpCtx := hcConfLptPort;

    R.Assign(5, 3, 25, 6);
    The_Dialog := New(PRadioButtons, Init(R,
      NewSItem('LPT~1~ (03BC)',
      NewSItem('LPT~2~ (0378)',
      NewSItem('LPT~3~ (0278)',
      nil)))
    ));
    Insert(The_Dialog);
    R.Assign(5, 2, 25, 3);
    Insert(New(PLabel, Init(R, 'Parallel Port', The_Dialog)));

    R.Assign(3, 8, 13, 10);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(17, 8, 27, 10);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
    SelectNext(true);
  end;

  With ComData Do
       begin
       RadioButtonData := TRG_PortX - 1
       end;
  Dialog^.SetData(ComData);
  C := DeskTop^.ExecView(Dialog);
  if (C = cmOK)
     then begin
     Dialog^.GetData(ComData);
     With ComData Do
          begin
          TRG_PortX := RadioButtonData + 1;
          end;
     end;

  Dispose(Dialog, Done);
  DCmdBuf := C;
End;

(* MCPU configuration. *)
Procedure TVApp.McpuConfigDialog;
type
  ConfigDataType = record
    CheckBoxData: Word;
    InputLineData: string[128];
    end;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  ConfigData : ConfigDataType;
  V, E: integer;
Begin
  R.Assign(20, 6, 55, 19);
  Dialog := New(PEditDialog, Init(R, ' MCPU Configuration '));
  with Dialog^ do
  begin
    HelpCtx := hcConfMcpu;

    R.Assign(2, 3, 20, 6);
    The_Dialog := New(PCheckBoxes, Init(R,
      NewSItem('~M~CPU Enabled',
      NewSItem('~P~IO Enabled',
      NewSItem('~S~IO Enabled',
      nil)))
    ));
    Insert(The_Dialog);
    R.Assign(2, 2, 20, 3);
    Insert(New(PLabel, Init(R, 'Interface', The_Dialog)));

    R.Assign(2, 8, 20, 9);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(2, 7, 20, 8);
    Insert(New(PLabel, Init(R, 'Poll Time', The_Dialog)));

    R.Assign(22, 5, 32, 7);
    Insert(New(PButton, Init(R, '~P~ort', cmYes, bfNormal)));
    R.Assign(3, 10, 13, 12);
    Insert(New(PButton, Init(R, '~T~est', cmOk, bfDefault)));
    R.Assign(22, 10, 32, 12);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext(true);
  end;

  repeat

  With ConfigData Do
       begin
       Str ((MCPU_Delay/1000.0):5:3, InputLineData);
       CheckBoxData := $00;
       If (MCPU_Installed)
          Then CheckBoxData := CheckBoxData OR  $01;
       If (PIO_Enabled)
          Then CheckBoxData := CheckBoxData OR  $02;
       If (SIO_Enabled)
          Then CheckBoxData := CheckBoxData OR  $04;
       end;
  Dialog^.SetData(ConfigData);
  C := DeskTop^.ExecView(Dialog);
  if (C <> cmCancel)
     then begin
     Dialog^.GetData(ConfigData);
     With ConfigData Do
          begin
          Val (InputLineData, V, E);
          if (E = 0)
             then MCPU_Delay := V*1000;
          MCPU_Installed := (CheckBoxData AND $01 = $01);
          PIO_Enabled    := (CheckBoxData AND $02 = $02);
          SIO_Enabled    := (CheckBoxData AND $04 = $04);
          end;
     end;
  case (C) of
       cmOk:    Emergency_Terminal;
       cmYes:   ComPortDialog;
       cmNo:    ;
       cmCancel:;
       end;

  until (C = cmCancel);

  Dispose(Dialog, Done);
  DCmdBuf := C;
End;

(* RGB Light Source configuration. *)
Procedure TVApp.RgbConfigDialog;
Begin
   MessageBox ('RGB Light Source Not Installed', Nil,
      mfWarning + mfOkButton);
End;

(* Trigger Output configuration. *)
Procedure TVApp.TrigConfigDialog;
type
  ConfigDataType = record
    RadioButtonData: Word;
    end;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  ConfigData : ConfigDataType;
Begin
  R.Assign(20, 6, 50, 16);
  Dialog := New(PEditDialog, Init(R, ' Trigger Config '));
  with Dialog^ do
  begin
    HelpCtx := hcConfTrig;

    R.Assign(2, 3, 15, 6);
    The_Dialog := New(PRadioButtons, Init(R,
      NewSItem('~L~ow',
      NewSItem('~H~igh',
      NewSItem('~P~ulse',
      nil)))
    ));
    Insert(The_Dialog);
    R.Assign(2, 2, 10, 3);
    Insert(New(PLabel, Init(R, 'Output', The_Dialog)));

    R.Assign(17, 3, 27, 5);
    Insert(New(PButton, Init(R, '~P~ort', cmYes, bfNormal)));
    R.Assign(3, 7, 13, 9);
    Insert(New(PButton, Init(R, '~T~est', cmOk, bfDefault)));
    R.Assign(17, 7, 27, 9);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext(true);
  end;

  ConfigData.RadioButtonData := 0;

  repeat

  Dialog^.SetData(ConfigData);
  C := DeskTop^.ExecView(Dialog);
  case (C) of
       cmOk:    begin
                Dialog^.GetData(ConfigData);
                case (ConfigData.RadioButtonData) of
                     0: OutTrigger($00);
                     1: OutTrigger($FF);
                     2: begin
                        OutTrigger($00);
                        Delay(500);
                        OutTrigger($FF);
                        Delay(500);
                        end;
                     end;
                end;
       cmYes:   begin
                LptPortDialog;
                if (C = cmOk)
                   then Init_Trigger;
                end;
       cmNo:    ;
       cmCancel:;
       end;

  until (C = cmCancel);

  Dispose(Dialog, Done);
  DCmdBuf := C;
End;

(* Joystick Input configuration. *)
Procedure TVApp.JoystickDialog;
type
  ConfigDataType = record
    CheckBoxData: Word;
    end;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  ConfigData : ConfigDataType;
Begin
  R.Assign(20, 6, 55, 16);
  Dialog := New(PEditDialog, Init(R, ' Joystick Configuration '));
  with Dialog^ do
  begin
    HelpCtx := hcConfJoystick;

    R.Assign(2, 3, 30, 6);
    The_Dialog := New(PCheckBoxes, Init(R,
      NewSItem('~J~oystick Enabled',
      NewSItem('~I~nput Trigger Enabled',
      NewSItem('~O~veride Command Enabled',
      nil)))
    ));
    Insert(The_Dialog);
    R.Assign(2, 2, 20, 3);
    Insert(New(PLabel, Init(R, 'Interface', The_Dialog)));

    R.Assign(3, 7, 13, 9);
    Insert(New(PButton, Init(R, '~T~est', cmOk, bfDefault)));
    R.Assign(22, 7, 32, 9);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext(true);
  end;

  repeat

  With ConfigData Do
       begin
       CheckBoxData := $00;
       If (JoystickEnabled)
          Then CheckBoxData := CheckBoxData OR  $01;
       If (JoystickTrigger)
          Then CheckBoxData := CheckBoxData OR  $02;
       If (JoystickOveride)
          Then CheckBoxData := CheckBoxData OR  $04;
       end;
  Dialog^.SetData(ConfigData);
  C := DeskTop^.ExecView(Dialog);
  if (C <> cmCancel)
     then begin
     Dialog^.GetData(ConfigData);
     With ConfigData Do
          begin
          JoystickEnabled := (CheckBoxData AND $01 = $01);
          JoystickTrigger := (CheckBoxData AND $02 = $02);
          JoystickOveride := (CheckBoxData AND $04 = $04);
          end;
     end;
  case (C) of
       cmOk:    Overide;
       cmYes:   ;
       cmNo:    ;
       cmCancel:;
       end;

  until (C = cmCancel);

  Dispose(Dialog, Done);
  DCmdBuf := C;
End;

(* Axis Point Array Memory configuration. *)
Procedure TVApp.AxisConfigDialog;
Begin
   MessageBox ('AxisConfigDialog Not Installed', Nil,
      mfWarning + mfOkButton);
End;

(* Misc Options configuration. *)
Procedure TVApp.OptionsDialog;
type
  ConfigDataType = record
    RadioButtonData: Word;
    InputLineData: string[128];
    end;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  ConfigData : ConfigDataType;
  V, E: integer;
  X: Real;
Begin
  R.Assign(20, 6, 55, 16);
  Dialog := New(PEditDialog, Init(R, ' Misc Options '));
  with Dialog^ do
  begin
    HelpCtx := hcConfOptions;

    R.Assign(2, 3, 20, 6);
    The_Dialog := New(PRadioButtons, Init(R,
      NewSItem('~F~ilm Rate',
      NewSItem('~V~ideo Rate',
      NewSItem('~C~ustom Rate',
      nil)))
    ));
    Insert(The_Dialog);
    R.Assign(2, 2, 20, 3);
    Insert(New(PLabel, Init(R, 'Time Base', The_Dialog)));

    R.Assign(22, 5, 32, 6);
    The_Dialog := New(PInputLine, Init(R, 128));
    Insert(The_Dialog);
    R.Assign(22, 2, 32, 3);
    Insert(New(PLabel, Init(R, 'FPS', The_Dialog)));

    R.Assign(3, 7, 13, 9);
    Insert(New(PButton, Init(R, '~O~k', cmOk, bfDefault)));
    R.Assign(21, 7, 31, 9);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(true);
  end;

  With ConfigData Do
       begin
       Str (Frame_Rate:5:2, InputLineData);
       if (Frame_Rate = 24.0)
          then RadioButtonData := 0
       else if (Frame_Rate = 30.0)
          then RadioButtonData := 1
          else RadioButtonData := 2;
       end;
  Dialog^.SetData(ConfigData);
  C := DeskTop^.ExecView(Dialog);
  if (C <> cmCancel)
     then begin
     Dialog^.GetData(ConfigData);
     With ConfigData Do
          begin
          case (ConfigData.RadioButtonData) of
               0: X := 24.0;
               1: X := 30.0;
               2: Val (InputLineData, X, E);
               end;
          end;
     Frame_Rate := X; (* typed const *)
     end;

  Dispose(Dialog, Done);
  DCmdBuf := C;
End;
