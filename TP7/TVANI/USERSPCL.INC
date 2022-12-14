(* Additional Special Features: *)

Const PortX : integer = 2;              (* for terminal on COM2 *)

(* Terminal for direct serial IO. *)
Procedure TVApp.TerminalWindow;
var
  Window: PWindow;
  R: TRect;
  CmdStr : string;
Begin
  R.Assign(0, 0, 80, 23);
  Window := New (PWindow, Init (R, '', wnNoNumber));
  HideMouse;
  DeskTop^.Insert (Window);
    CRT.GotoXY(1,1);
    CRT.TextBackground(Black);
    CRT.TextColor(Green);
    CRT.ClrScr;
    TPCRT.BlockCursor;
    Writeln('Press ESCAPE key to exit Terminal', ^J);
{$IFDEF EXEC_SHELL}
    Str(PortX:2, CmdStr);       (* leading space parameter *)
    SwapVectors;
    Exec('TESTSIOX.EXE', CmdStr); (* requires share of heap in $M setting *)
    SwapVectors;
{$ELSE}
    ExecTermio(PortX);          (* generic SIOX module *)
{$ENDIF}
    TPCRT.HiddenCursor;
  DeskTop^.Delete (Window);
  ShowMouse;
  MenuBar^.Draw;
  InitEvents;
End;

Procedure TVApp.TerminalDialog;
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
Begin
  R.Assign(25, 6, 55, 17);
  Dialog := New(PEditDialog, Init(R, ' Terminal Interface '));
  with Dialog^ do
  begin
    HelpCtx := hcSpecTerm;

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
    SelectNext (True);
    SelectNext (True);
  end;

  With ComData Do
       begin
       If PortX in [1..4]
            Then RadioButtonData := PortX - 1
            Else RadioButtonData := 1; (* COM2 *)
       end;
  Dialog^.SetData(ComData);
  C := DeskTop^.ExecView(Dialog);
  if C = cmOK
     then begin
     Dialog^.GetData(ComData);
     With ComData Do
          begin
          PortX := RadioButtonData + 1;
          end;
     end;
  Dispose(Dialog, Done);

  If C = cmOK
     Then AniApp.TerminalWindow;
end;

(* MCPU direct IO. *)
Procedure TVApp.McpuWindow;
var
  Window: PWindow;
  R: TRect;
Begin
  R.Assign(0, 0, 80, 23);
  Window := New (PWindow, Init (R, '', wnNoNumber));
  HideMouse;
  DeskTop^.Insert (Window);
    CRT.GotoXY(1,1);
    CRT.TextBackground(Black);
    CRT.TextColor(Green);
    CRT.ClrScr;
    TPCRT.BlockCursor;
    Writeln('Press ESCAPE key to exit MCPU Communications', ^J);
{$IFDEF EXEC_SHELL}
    SwapVectors;
    Exec('TESTDRIV.EXE', '');   (* requires share of heap in $M setting *)
    SwapVectors;
{$ELSE}
    MCPU_Overide;
{$ENDIF}
    TPCRT.HiddenCursor;
  DeskTop^.Delete (Window);
  ShowMouse;
  MenuBar^.Draw;
  InitEvents;
End;

Procedure TVApp.McpuDialog;
Begin
    AniApp.McpuWindow;
End;

(* RGB Light Source direct IO. *)
{$IFDEF RGB_CONTROL}
Procedure TVApp.LightSourceWindow;
type
  ComDataType = Record
     RadioButtonData : word;
     RedData, GreenData, BlueData : string[20];
     ColorData, RedValue, GreenValue, BlueValue : string[20];
     end;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  Ri, Gi, Bi, Ci : integer;
  Verror : integer;
  ComData : ComDataType;
Begin
  R.Assign(10, 6, 70, 17);
  Dialog := New(PEditDialog, Init(R, ' RGB Light Source Interface '));
  with Dialog^ do
  begin
    HelpCtx := hcSpecRgb;

    R.Assign(5, 4, 22, 6);
    The_Dialog := New(PRadioButtons, Init(R,
      NewSItem('~D~irect RGB',
      NewSItem('~C~olor Table',
      nil))
    ));
    Insert(The_Dialog);
    R.Assign(5, 2, 22, 3);
    Insert(New(PLabel, Init(R, 'RGB Value', The_Dialog)));

    R.Assign (24, 2, 58, 3);
    Insert (New (PStaticText,
      Init (R, ' Color   Red     Green   Blue ')));
    R.Assign (32, 4, 39, 5);
    The_Dialog := New (PInputLine, Init (R, 20));
    Insert (The_Dialog);
    R.Assign (40, 4, 47, 5);
    The_Dialog := New (PInputLine, Init (R, 20));
    Insert (The_Dialog);
    R.Assign (48, 4, 55, 5);
    The_Dialog := New (PInputLine, Init (R, 20));
    Insert (The_Dialog);
    R.Assign (24, 5, 31, 6);
    The_Dialog := New (PInputLine, Init (R, 20));
    Insert (The_Dialog);
    R.Assign (32, 5, 39, 6);
    The_Dialog := New (PInputLine, Init (R, 20));
    Insert (The_Dialog);
    R.Assign (40, 5, 47, 6);
    The_Dialog := New (PInputLine, Init (R, 20));
    Insert (The_Dialog);
    R.Assign (48, 5, 55, 6);
    The_Dialog := New (PInputLine, Init (R, 20));
    Insert (The_Dialog);

    R.Assign(10, 8, 21, 10);
    Insert(New(PButton, Init(R, '~L~ight', cmOK, bfDefault)));
    R.Assign(25, 8, 35, 10);
    Insert(New(PButton, Init(R, '~K~ill', cmNo, bfNormal)));
    R.Assign(40, 8, 50, 10);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));
    SelectNext (False);
  end;

  Repeat
  with ComData do
       begin
       RadioButtonData := 0;
       Str(RGB_Red, RedData);
       Str(RGB_Grn, GreenData);
       Str(RGB_Blu, BlueData);
       Str(RGB_Col, ColorData);
       Str(RGB_Color[RGB_Col].Red  ,RedValue);
       Str(RGB_Color[RGB_Col].Green,GreenValue);
       Str(RGB_Color[RGB_Col].Blue ,BlueValue);
       end;
  Dialog^.SetData(ComData);
  C := DeskTop^.ExecView(Dialog);
  if C = cmNo
     then OutColor(0, 0, 0);
  if C = cmOK
     then begin
     Dialog^.GetData(ComData);
     with ComData do
          begin
          if (RadioButtonData = 1)
             then begin
             Val(ColorData, Ci, Verror);
             if (Ci in [1..Max_Color_Code])
                then RGB_Col := Ci;
             Ri := RGB_Color[RGB_Col].Red;
             Gi := RGB_Color[RGB_Col].Green;
             Bi := RGB_Color[RGB_Col].Blue;
             end
             else begin
             Val(RedData  , Ri, Verror);
             Val(GreenData, Gi, Verror);
             Val(BlueData , Bi, Verror);
             end;
          end;
     OutColor(Ri, Gi, Bi);
     end;
  Until C = cmCancel;
  Dispose(Dialog, Done);
end;
{$ELSE}
Procedure TVApp.LightSourceWindow;
Begin
   MessageBox ('RGB Light Source Not Installed', Nil,
      mfWarning + mfOkButton);
End;
{$ENDIF}


(* RGB Light Source programming. *)
{$IFDEF RGB_CONTROL}
Procedure TVApp.LightSourceDialog;
var
  The_Dialog: PView;
  Dialog: PEditDialog;
  R: TRect;
  C: Word;
  K : Integer;
  S : String;
  Verror : Integer;
  Yabs, Yrel, Ymin, Ymax : Byte;
  RI, CI : byte;
  I, J : integer;
  change_dialog : boolean;
  LightData : Array[1..10] of Array[1..5] of String[20];
Begin
  change_dialog := FALSE;
  Yabs := 12;
  If KeyNo <= 3
     Then Yrel := 10
     Else Yrel := 7 + KeyNo;
  Ymin := Yabs - Yrel DIV 2;
  Ymax := Ymin + Yrel;
  R.Assign (5, Ymin, 75, Ymax);
  Dialog := New (PEditDialog, Init (R, ' RGB Light Source Programming '));
  with Dialog^ do
  begin
    HelpCtx := hcSpecLight;

    Yrel := 3;
    For K := 1 to 10 Do
        If (K <= 3) Or (K <= KeyNo)
           Then begin
           R.Assign (5, Yrel, 15, Yrel+1);
           The_Dialog := New (PInputLine, Init (R, 20));
           Insert (The_Dialog);
           R.Assign (16, Yrel, 19, Yrel+1);
           if (K <= KeyNo)
              then Str (K:2, S)
              else S := '';
           Insert (New (PStaticText, Init (R, S)));
           R.Assign (20, Yrel, 30, Yrel+1);
           The_Dialog := New (PInputLine, Init (R, 20));
           Insert (The_Dialog);
           R.Assign (31, Yrel, 41, Yrel+1);
           The_Dialog := New (PInputLine, Init (R, 20));
           Insert (The_Dialog);
           R.Assign (42, Yrel, 52, Yrel+1);
           The_Dialog := New (PInputLine, Init (R, 20));
           Insert (The_Dialog);
           R.Assign (53, Yrel, 63, Yrel+1);
           The_Dialog := New (PInputLine, Init (R, 20));
           Insert (The_Dialog);
           Inc (Yrel);
           end;
    R.Assign (5, 2, 15, 3);
    Insert (New (PLabel, Init (R, '  Time  ', The_Dialog)));
    R.Assign (20, 2, 67, 3);
    Insert (New (PLabel, Init (R,
      'Color:     Red        Green      Blue', The_Dialog)));

    Inc (Yrel);
    R.Assign (10, Yrel, 20, Yrel+2);
    Insert (New (PButton, Init (R, '~E~dit', cmOK, bfDefault)));
    R.Assign(23, Yrel, 33, Yrel+2);
    if (CmdBuf = cmSpecLight)
    then Insert(New(PButton, Init(R, '~S~ave', cmYes, bfNormal)))
    else Insert(New(PButton, Init(R, '~R~un ', cmYes, bfNormal)));
    R.Assign(37, Yrel, 47, Yrel+2);
    if (CmdBuf = cmSpecLight)
    then Insert(New(PButton, Init(R, '~L~oad', cmNo, bfNormal)))
    else Insert(New(PButton, Init(R, '~T~est', cmNo, bfNormal)));
    R.Assign (50, Yrel, 60, Yrel+2);
    Insert (New (PButton, Init (R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;

  For K := 1 to 10 Do
      For J := 1 to 5 Do
         LightData[K][J] := '';

  Compute_RGB_Color;
  Repeat
     For K := 1 to KeyNo Do
         begin
         Str (Time_Key [K]:6:2, LightData[K][1]);
         Str (RGB_Key[K][0], LightData[K][2]);
         Str (RGB_Key[K][1], LightData[K][3]);
         Str (RGB_Key[K][2], LightData[K][4]);
         Str (RGB_Key[K][3], LightData[K][5]);
         end;
     Dialog^.SetData (LightData);
     C := DeskTop^.ExecView (Dialog);
     If C <> cmCancel
          Then begin
                 Dialog^.GetData (LightData);
                 For K := 1 to KeyNo Do
                     begin
                     Val (LightData[K][2], I, Verror);
                     If I in [1..Max_Color_Code]
                        Then begin
                             RGB_Key[K][0] := I;
                             RGB_Key[K][1] := RGB_Color[I].Red;
                             RGB_Key[K][2] := RGB_Color[I].Green;
                             RGB_Key[K][3] := RGB_Color[I].Blue;
                             end
                        Else begin
                             RGB_Key[K][0] := 0;
                             Val (LightData[K][3], RGB_Key[K][1], Verror);
                             Val (LightData[K][4], RGB_Key[K][2], Verror);
                             Val (LightData[K][5], RGB_Key[K][3], Verror);
                             end
                     end;
                 end;
     Case C of
          cmOK : Compute_RGB_Color;

          cmYes: if (CmdBuf = cmSpecLight)
                 then begin
                  FileName := 'ANIMAL.LIT';
                  FileExtn := 'LIT';
                  AniApp.SaveDialog;
                  If DCmdBuf = cmOk
                     Then begin
                     CheapStatus ('...Saving Light Transition File ' + FileName + '...');
                     Save_Lightransit_File (FileName);
                     CheapStatusClear;
                     end;
                 end

                 else begin
                 Compute_RGB_Color;
                 Run_RGB_Color;
                 end;

          cmNo : if (CmdBuf = cmSpecLight)
                 then begin
                  FileName := 'ANIMAL.LIT';
                  AniApp.FileOpen ('*.LIT');
                  If DCmdBuf = cmOk
                     Then begin
                     CheapStatus ('...Loading Light Transition File ' + FileName + '...');
                     Load_Lightransit_File (FileName);
                     AniApp.ViewFile (FileName);
                     Compute_RGB_Color;
                     CheapStatusClear;
                     change_dialog := TRUE;
                     C := cmCancel;
                     CmdBuf := cmSpecLight+1;
                     end;
                 end

                 else begin
                 AniApp.LightSourceWindow;
                 end;
          end;
  Until C = cmCancel;

  Dispose(Dialog, Done);

  if (change_dialog)
     then AniApp.LightSourceDialog;
End;
{$ELSE}
Procedure TVApp.LightSourceDialog;
Begin
   MessageBox ('RGB Light Source Not Installed', Nil,
      mfWarning + mfOkButton);
End;
{$ENDIF}

(* RGB Color Table management. *)
{$IFDEF RGB_CONTROL}
Procedure TVApp.ColorTableDialog;
var
  Dialog: PDialog;
  R: TRect;
  C: Word;
  The_Dialog : PView;
  XC, YC : Integer;
  XI, YI : Integer;
  AS : String [2];
  ColorData : Array [1..20] of Array [1..4] of String [20];
  RI, CI : Integer;
  Verror : Integer;
Begin
  R.Assign(10, 3, 70, 21);
  Dialog := New (PDialog, Init(R, ' RGB Color Table Assignment '));
  with Dialog^ do
  begin
    HelpCtx := hcSpecColor;

    R.Assign (8, 2, 58, 3);
    Insert (New (PStaticText,
      Init (R, ' Color:     Red        Green      Blue ')));
    For YI := 1 to 10 Do    (* only 10 entries fit *)
        For XI := 1 to 4 Do
        begin
        YC := YI+3;
        XC := 11*(XI-1) + 8;
        R.Assign (XC, YC, XC+10, YC+1);
        The_Dialog := New (PInputLine, Init (R, 20));
        Insert (The_Dialog);
        end;
    Inc(YC);
    Inc(YC);
    R.Assign(5, YC, 15, YC+2);
    Insert(New(PButton, Init(R, '~E~dit', cmOK, bfDefault)));
    R.Assign(18, YC, 28, YC+2);
    Insert(New(PButton, Init(R, '~S~ave', cmYes, bfNormal)));
    R.Assign(31, YC, 41, YC+2);
    Insert(New(PButton, Init(R, '~L~oad', cmNo, bfNormal)));
    R.Assign(45, YC, 55, YC+2);
    Insert(New(PButton, Init(R, '~Q~uit', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;

  Repeat
    For RI := 1 to 10 (* 20 *) Do
      begin
      Str (RI, ColorData [RI][1]);
      Str (RGB_Color[RI].Red,   ColorData[RI][2]);
      Str (RGB_Color[RI].Green, ColorData[RI][3]);
      Str (RGB_Color[RI].Blue,  ColorData[RI][4]);
      end;

     Dialog^.SetData (ColorData);
     C := DeskTop^.ExecView(Dialog);
     Case C of
          cmYes,
          cmOk  : begin
                  Dialog^.GetData (ColorData);
                  For RI := 1 to 10 (* 20 *) Do
                      begin
                      Val (ColorData[RI][1], CI, Verror);
                      if NOT (CI in [1..Max_Color_Code])
                         then CI := 1;
                      Val (ColorData[RI][2], RGB_Color[CI].Red, Verror);
                      Val (ColorData[RI][3], RGB_Color[CI].Green, Verror);
                      Val (ColorData[RI][4], RGB_Color[CI].Blue, Verror);
                      end;
                  end;
          end;
     Case C of
          cmYes : begin
                  FileName := 'ANIMAL.RGB';
                  FileExtn := 'RGB';
                  AniApp.SaveDialog;
                  If DCmdBuf = cmOk
                     Then begin
                     CheapStatus ('...Saving Color Table File ' + FileName + '...');
                     Save_Color_File (FileName);
                     CheapStatusClear;
                     end;
                  end;

          cmNo  : begin
                  FileName := 'ANIMAL.RGB';
                  AniApp.FileOpen ('*.RGB');
                  If DCmdBuf = cmOk
                     Then begin
                     CheapStatus ('...Loading Color Table File ' + FileName + '...');
                     Load_Color_File (FileName);
                     AniApp.ViewFile (FileName);
                     CheapStatusClear;
                     end;
                  end;
          end;
  Until C = cmCancel;

  Dispose(Dialog, Done);
End;
{$ELSE}
Procedure TVApp.ColorTableDialog;
Begin
   MessageBox ('RGB Light Source Not Installed', Nil,
      mfWarning + mfOkButton);
End;
{$ENDIF}

