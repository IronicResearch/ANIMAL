
(* User Interface *)

Unit USERIO;

{$I SWITCHES.INC}          (* compiler switches *)

{$DEFINE USE_EDITOR}       (* use file editor instead of file viewer *)

Interface

Uses

     Crt,                  (* standard console *)
     TpCrt,                (* TurboPro console extensions *)
     Dos,                  (* MS-DOS function calls *)

     CONIO,                (* console user interface *)
     GLOBAL,               (* Animal Global declarations *)
     MAINIO,               (* Main processing *)
     TERMIO,               (* General Terminal Interface *)
     MCPU,                 (* MCPU Interface *)
     THINGM,               (* ThingM Interface *)
     SEQIO,                (* Sequencer functions *)
     SEQFILE,              (* Sequencer file IO *)

     Objects,              (* Turbo Vision Object Library *)
     Drivers,              (* TV interface drivers *)
     Memory,               (* TV memory management *)
     Views,                (* TV view screens *)
     Menus,                (* TV menus *)
     Dialogs,              (* TV dialog boxes *)
     App,                  (* TV application framework *)
     StdDlg,               (* TV standard file dialogs *)
     MsgBox,               (* TV message boxes *)
     HelpFile,             (* TV help screens *)
     FViewer,              (* TV file viewer *)
     Editors,              (* TV file editor *)
     Calc,                 (* TV calculator desk accy *)
     TVSeqHlp;             (* TV Sequencer help constants *)

Procedure Main_Menu_Loop;

Procedure Save_File_Dialog;

Procedure Init_Status_Display;

Procedure Update_Status_Display;

Procedure Exit_Status_Display;

(******************************)

Implementation

(* TV-style Display routines. *)
Const
   CON_MAX_X = 80;                      (* console max X *)
   CON_MAX_Y = 25;                      (* console max Y *)
   CON_STAT_X = 10;                     (* start X of status info *)
   CON_STAT_LEN = CON_MAX_X - CON_STAT_X;  (* length of status info *)

(* Display a single line string over the TV Status Line. *)
Procedure CheapStatus (S : String);
Begin
   If (Length (S) > CON_STAT_LEN)
      Then S[0] := Chr (CON_STAT_LEN);
   GotoXYabs (CON_STAT_X, CON_MAX_Y);
   Write (S);
End;

(* Clear the single line string over the TV Status Line. *)
Procedure CheapStatusClear;
Begin
   GotoXYabs (CON_STAT_X, CON_MAX_Y);
   ClrEol;
End;

(***************************************)

(* Turbo Vision interface definitions. *)

Const

  cmEmergencyKill   = 9910;
  cmEmergencyReset  = 9920;

  cmAbout           = 1100;
  cmCalendar        = 1300;
  cmCalculator      = 1400;
  cmMemory          = 1500;

{$IFNDEF USE_EDITOR}
  cmFileOpen        = 2100;
  cmFileNew         = 2200;
  cmFileSave        = 2300;
{$ENDIF}

  cmEditCount       = hcEditCount;
  cmRunCam          = hcRunCam;
  cmRunProj         = hcRunProj;
  cmRunSeq          = hcRunSeq;
  cmRunScript       = hcRunScript;
  cmSpecTerm        = hcSpecTerm;

const
  HeapSize = 48 * (1024 div 16);  { Save 48k heap for main program }

var
  ClipWindow: PEditWindow;              (* editor clipboard *)

Type
  PTVApp = ^TVApp;
  TVApp = object(TApplication)
    constructor Init;
    procedure FileOpen(WildCard: PathStr);
    procedure ViewFile(FileName: PathStr);
    function  OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure OutOfMemory; virtual;
    procedure GetEvent (var Event : TEvent); virtual;
    procedure Idle; virtual;
    Function  GetPalette: PPalette; virtual;
    Procedure InterceptHelp (var Event: TEvent);
    Procedure InterceptQuit (var Event: TEvent);
    Procedure UpdateAllWindows;
    Procedure TerminalWindow;
    Procedure TerminalDialog;
    Procedure InitCountersWindow;
    Procedure ExitCountersWindow;
    Procedure PutCountersWindow;
    Procedure GetCountersWindow;
    Procedure EditCountersDialog;
    Procedure RunCameraDialog;
    Procedure RunProjectorDialog;
    Procedure RunSequencerDialog;
  end;

  TVUserStatusLine  = Object (TStatusLine)
    Function Hint (AHelpCtx : Word) : String; Virtual;
    end;
  PUserStatusLine = ^TVUserStatusLine;

Var
  AniApp: TVApp;                        (* current application object *)

Var
  PScript : PEditWindow;                (* current editor script file *)

Var
  CmdBuf : Word;                        (* event command buffer *)
  DCmdBuf : Word;                       (* local dialog command buffer *)

Var
  FileName : String [128];
  FileExtn : String [3];

Var
  Loaded : boolean;                     (* script file loaded ? *)
  Scripted : boolean;                   (* for capturing script file *)
  Default_Script : string;              (* working script file name *)

(* Init these variables. *)
Procedure Init_Local_Stuff;
begin
  FileName := 'ANIMAL.SEQ';
  FileExtn := 'SEQ';

  Loaded := FALSE;
  Scripted := FALSE;
  Default_Script := FileName;
end;

(* Turbo Vision user interface extension routines. *)

(* Insert string into editor file. *)
Procedure InsertScript(S : string);
begin
    S := S + #13; (* append End-of-Line *)
    PScript^.Editor^.InsertText(@S[1], Length(S), FALSE);
end;

(* Copy strings from script buffer into editor file. *)
Procedure CopyScript(I : integer);
var S : string;
begin
    S := ScriptBuf[I];
    S := S + #13; (* append End-of-Line *)
    PScript^.Editor^.InsertText(@S[1], Length(S), FALSE);
end;

(* Create text 'Find' dialog for editor. *)
function CreateFindDialog: PDialog;
var
  D: PDialog;
  Control: PView;
  R: TRect;
begin
  R.Assign(0, 0, 38, 12);
  D := New(PDialog, Init(R, 'Find'));
  with D^ do
  begin
    HelpCtx := hcFind;
    Options := Options or ofCentered;

    R.Assign(3, 3, 32, 4);
    Control := New(PInputLine, Init(R, 80));
    Insert(Control);
    R.Assign(2, 2, 15, 3);
    Insert(New(PLabel, Init(R, '~T~ext to find', Control)));
    R.Assign(32, 3, 35, 4);
    Insert(New(PHistory, Init(R, PInputLine(Control), 10)));

    R.Assign(3, 5, 35, 7);
    Insert(New(PCheckBoxes, Init(R,
      NewSItem('~C~ase sensitive',
      NewSItem('~W~hole words only', nil)))));

    R.Assign(14, 9, 24, 11);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;
  CreateFindDialog := D;
end;

(* Create text 'replace' dialog for editor. *)
function CreateReplaceDialog: PDialog;
var
  D: PDialog;
  Control: PView;
  R: TRect;
begin
  R.Assign(0, 0, 40, 16);
  D := New(PDialog, Init(R, 'Replace'));
  with D^ do
  begin
    HelpCtx := hcReplace;
    Options := Options or ofCentered;

    R.Assign(3, 3, 34, 4);
    Control := New(PInputLine, Init(R, 80));
    Insert(Control);
    R.Assign(2, 2, 15, 3);
    Insert(New(PLabel, Init(R, '~T~ext to find', Control)));
    R.Assign(34, 3, 37, 4);
    Insert(New(PHistory, Init(R, PInputLine(Control), 10)));

    R.Assign(3, 6, 34, 7);
    Control := New(PInputLine, Init(R, 80));
    Insert(Control);
    R.Assign(2, 5, 12, 6);
    Insert(New(PLabel, Init(R, '~N~ew text', Control)));
    R.Assign(34, 6, 37, 7);
    Insert(New(PHistory, Init(R, PInputLine(Control), 11)));

    R.Assign(3, 8, 37, 12);
    Insert(New(PCheckBoxes, Init(R,
      NewSItem('~C~ase sensitive',
      NewSItem('~W~hole words only',
      NewSItem('~P~rompt on replace',
      NewSItem('~R~eplace all', nil)))))));

    R.Assign(17, 13, 27, 15);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    R.Assign(28, 13, 38, 15);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;
  CreateReplaceDialog := D;
end;

(* Execute file editor operations. *)
function DoEditDialog(Dialog: Integer; Info: Pointer): Word; far;
var
  R: TRect;
  T: TPoint;
  D: PFileDialog;
begin
  case Dialog of
    edOutOfMemory:
      DoEditDialog := MessageBox('Not enough memory for this operation.',
        nil, mfError + mfOkButton);
    edReadError:
      DoEditDialog := MessageBox('Error reading file %s.',
        @Info, mfError + mfOkButton);
    edWriteError:
      DoEditDialog := MessageBox('Error writing file %s.',
        @Info, mfError + mfOkButton);
    edCreateError:
      DoEditDialog := MessageBox('Error creating file %s.',
        @Info, mfError + mfOkButton);
    edSaveModify:
      DoEditDialog := MessageBox('%s has been modified. Save?',
        @Info, mfInformation + mfYesNoCancel);
    edSaveUntitled:
      DoEditDialog := MessageBox('Save untitled file?',
        nil, mfInformation + mfYesNoCancel);
    edSaveAs:
      begin (* interception point for file save operations *)
      D := New(PFileDialog, Init('*.SEQ',
        'Save file as', '~N~ame', fdOkButton, 101));
      D^.HelpCtx := hcFOFileOpenDBox;
      DoEditDialog := Application^.ExecuteDialog(D, Info);
      D^.GetFileName(FileName);
      end;
    edFind:
      DoEditDialog := Application^.ExecuteDialog(CreateFindDialog, Info);
    edSearchFailed:
      DoEditDialog := MessageBox('Search string not found.',
        nil, mfError + mfOkButton);
    edReplace:
      DoEditDialog := Application^.ExecuteDialog(CreateReplaceDialog, Info);
    edReplacePrompt:
      begin
        { Avoid placing the dialog on the same line as the cursor }
        R.Assign(0, 1, 40, 8);
        R.Move((Desktop^.Size.X - R.B.X) div 2, 0);
        Desktop^.MakeGlobal(R.B, T);
        Inc(T.Y);
        if TPoint(Info).Y <= T.Y then
          R.Move(0, Desktop^.Size.Y - R.B.Y - 2);
        DoEditDialog := MessageBoxRect(R, 'Replace this occurence?',
          nil, mfYesNoCancel + mfInformation);
      end;
  end;
end;

(* Init TVApp constructor to jump-start editor. *)
constructor TVApp.Init;
var
  R: TRect;
  I: Integer;
  FileName: PathStr;
begin
  MaxHeapSize := HeapSize;
  inherited Init;

(* (not necessary to register objects since no desktop save/restore)
  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterApp;
  RegisterHelpFile;
  RegisterCalc;
  RegisterEditors;
*)

  DisableCommands([cmSave, cmSaveAs, cmCut, cmCopy, cmPaste, cmClear,
    cmUndo, cmFind, cmReplace, cmSearchAgain, cmCloseAll]);
  EditorDialog := DoEditDialog;
  ClipWindow := OpenEditor('', False);
  if ClipWindow <> nil then
  begin
    Clipboard := ClipWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;

(* (dont look for file name on command line to load as 1st editor file)
  for I := 1 to ParamCount do
  begin
    FileName := ParamStr(I);
    if FileName[Length(FileName)] = '\' then
      FileName := FileName + '*.*';
    if (Pos('?', FileName) = 0) and (Pos('*', FileName) = 0) then
      OpenEditor(FExpand(FileName), True)
    else FileOpen(FileName);
  end;
*)

End;

(* Update any/all active windows open on desktop. *)
Procedure TVApp.UpdateAllWindows;
Begin
End;

(* Pop up File-Viewer window. *)
procedure TVApp.ViewFile(FileName: PathStr);
var
  W: PWindow;
begin
  W := New(PFileWindow,Init(FileName));
  W^.HelpCtx := hcViewer;
  if ValidView(W) <> nil
     then Desktop^.Insert(W);
end;

(* Pop up File-Editor window. *)
function TVApp.OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow;
var
  P: PView;
  R: TRect;
begin
  DeskTop^.GetExtent(R);
  P := Application^.ValidView(New(PEditWindow,
    Init(R, FileName, wnNoNumber)));
  if not Visible then P^.Hide;
  DeskTop^.Insert(P);
  OpenEditor := PEditWindow(P);
end;

(* Pop up standard File-Open dialog box for opening file. *)
{$IFDEF USE_EDITOR}     (* opens editable file *)
procedure TVApp.FileOpen(WildCard: PathStr);
var
  LocalFileName: FNameStr;
  D : PFileDialog;
begin
  LocalFileName := WildCard;
  D := New(PFileDialog, Init(WildCard, 'Open a file',
    '~N~ame', fdOpenButton + fdHelpButton, 100));
  D^.HelpCtx := hcFOFileOpenDBox;
  DCmdBuf := ExecuteDialog(D, @LocalFileName);
  if (DCmdBuf <> cmCancel)
    then begin
    OpenEditor(LocalFileName, True);
    FileName := LocalFileName;
    DCmdBuf := cmOk;
    end;
end;
{$ELSE}                 (* opens view-only file *)
procedure TVApp.FileOpen (WildCard: PathStr);
var
  D: PFileDialog;
  LocalFileName: PathStr;
begin
  D := New(PFileDialog, Init(WildCard, ' Load File ',
    '~N~ame', fdOpenButton + fdHelpButton, 100));
  D^.HelpCtx := hcFileOpen;
  if (ValidView(D) <> nil)
     then begin
     DCmdBuf := cmCancel;
     if (Desktop^.ExecView(D) <> cmCancel)
        then begin
        D^.GetFileName (LocalFileName);
        FileName := LocalFileName;
        DCmdBuf := cmOk;
        end;
     Dispose(D, Done);
     (* open the file on the desktop for viewing *)
     if (DCmdBuf = cmOk)
        then ViewFile(FileName);
     end;
end;
{$ENDIF}

(* File-Open dialog shell. *)
Procedure Load_File_Dialog;

Begin

   Query_Save_File;

   AniApp.FileOpen ('*.SEQ');

   If (DCmdBuf = cmOk)
      Then begin
      Default_Script := FileName;
      CheapStatus ('...Loading Script File ' + FileName + '...');
      Load_Script_File(FileName);
      CheapStatusClear;
      Loaded := TRUE;
      end;

End;

(* Run Script. *)
Procedure RunScriptFile;
Begin
   if ((NOT Loaded) AND (ScriptNum = 0))
      then Load_File_Dialog;

   If (Loaded OR (ScriptNum > 0))
      Then begin
      CheapStatus ('...Executing Script File ' + FileName + '...');
      Execute_Script;
      CheapStatusClear;
      end;
End;

(* Scan file name for extension, and append if missing. *)
Procedure Query_File_Extension (Var The_File_Name : String; Extension : String);

Var C : Integer;
    Extn_Ok : Boolean;
Begin
   Extn_Ok := False;
   For C := 1 to Length (The_File_Name) Do
       If The_File_Name [C] = '.'
          Then Extn_Ok := True;
   If Not Extn_Ok
      Then The_File_Name := The_File_Name + '.' + Extension;
End;

(* Search for file if it already exists. *)
Function Query_File_Exists (Var The_File_Name : String) : Boolean;

Var F : File;
    File_Exists : Boolean;
Begin
   Assign (F, The_File_Name);
   {$I-}
   Reset (F);
   {$I+}
   File_Exists := (IoResult = 0);
   If File_Exists
      Then Close (F);
   Query_File_Exists := File_Exists;
End;

(* Dialog for Saving File. *)
Procedure SaveDialog;
var
  ViewItem: PView;
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
    ViewItem := New(PInputLine, Init(R, 128));
    Insert(ViewItem);
    R.Assign(5, 2, 35, 3);
    Insert(New(PLabel, Init(R, 'File Name to Save:', ViewItem)));

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

(* Dialog shell for Saving File. *)
Procedure Save_File_Dialog;

Begin

  FileName := Default_Script;
  FileExtn := 'SEQ';

  SaveDialog;

  If DCmdBuf = cmOk
     Then begin
     Default_Script := FileName;
     CheapStatus ('...Saving Script File ' + FileName + '...');
     Save_Script_File(FileName);
     CheapStatusClear;
     end;

End;

(* Dialog box generation for New Sequencer file. *)
Procedure New_File_Dialog;
begin
  Query_Save_File;
  if (Ask_User('Record New Script File?'))
     then Scripted := TRUE      (* enable capturing script to file *)
     else Scripted := FALSE;
  if (Scripted)
     then begin
     Init_Write_Script;         (* reset file buffer for new script *)
     PScript := AniApp.OpenEditor('', True); (* create new editor file on desktop *)
     InsertScript('ThingM Sequencer Script (ver 1.0)'); (* mimic header *)
     InsertScript('');
     end;
end;

(***** Terminal *****)

Const PortX : integer = 0;              (* for terminal on unknown COM port *)

(* Terminal for direct serial IO. *)
Procedure TVApp.TerminalWindow;
var
  Window: PWindow;
  R: TRect;
  CmdStr : string;
Begin
  if (PortX = 0)
     then PortX := MCPU_PortX;          (* default to MCPU port *)

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

(* Terminal COM port selection dialog. *)
Procedure TVApp.TerminalDialog;
type
  ComDataType = Record
     RadioButtonData : word;
     end;
var
  ViewItem: PView;
  Dialog: PDialog;
  R: TRect;
  C: Word;
  ComData : ComDataType;
Begin
  R.Assign(25, 6, 55, 17);
  Dialog := New(PDialog, Init(R, ' Terminal Interface '));
  with Dialog^ do
  begin
    HelpCtx := hcSpecTerm;

    R.Assign(5, 3, 25, 7);
    ViewItem := New(PRadioButtons, Init(R,
      NewSItem('COM~1~ (03F8)',
      NewSItem('COM~2~ (02F8)',
      NewSItem('COM~3~ (03E8)',
      NewSItem('COM~4~ (02E8)',
      nil))))
    ));
    Insert(ViewItem);
    R.Assign(5, 2, 25, 3);
    Insert(New(PLabel, Init(R, 'Serial Port', ViewItem)));

    R.Assign(3, 8, 13, 10);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(17, 8, 27, 10);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
    SelectNext (True);
    SelectNext (True);
  end;

  if (PortX = 0)
     then PortX := MCPU_PortX;          (* default to MCPU port *)
  With ComData Do
       begin
       If PortX in [1..4]
            Then RadioButtonData := PortX - 1
            Else RadioButtonData := 1;  (* COM2 *)
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

(***** Sequencer *****)

(* Edit Frame Counter Dialog. *)
(* Allow for either modeless window or modal dialog. *)
const
  STRLEN = 20;
type
  CounterDialogDataType = record
    InputLineData1: string[STRLEN];
    InputLineData2: string[STRLEN];
    end;
var
  CounterDialog: PDialog;
  CounterEditData : CounterDialogDataType;

(* Construct the display window object. *)
Procedure TVApp.InitCountersWindow;
var
  ViewItem: PView;
  R: TRect;
  C: Word;
  Verror : Integer;
begin
  R.Assign(15, 7, 65, 17);
  CounterDialog := New(PDialog, Init(R, ' Frame Counters '));
  with CounterDialog^ do
  begin
    HelpCtx := hcEditCount;

    R.Assign(3, 4, 23, 5);
    ViewItem := New(PInputLine, Init(R, STRLEN));
    Insert(ViewItem);
    R.Assign(3, 3, 23, 4);
    Insert(New(PLabel, Init(R, 'Camera Counter', ViewItem)));

    R.Assign(27, 4, 47, 5);
    ViewItem := New(PInputLine, Init(R, STRLEN));
    Insert(ViewItem);
    R.Assign(27, 3, 47, 4);
    Insert(New(PLabel, Init(R, 'Projector Counter', ViewItem)));

    R.Assign(10, 7, 20, 9);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(30, 7, 40, 9);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;
End;

(* Destruct display window object. *)
Procedure TVApp.ExitCountersWindow;
Begin
  Dispose(CounterDialog, Done);
End;

(* Put program data into window object. *)
Procedure TVApp.PutCountersWindow;
Begin
  With CounterEditData Do
       begin
       Str (Camera_Total, InputLineData1);
       Str (Projector_Total, InputLineData2);
       end;
  CounterDialog^.SetData(CounterEditData);
End;

(* Get program data out of window object. *)
Procedure TVApp.GetCountersWindow;
var Verror : integer;
Begin
     CounterDialog^.GetData(CounterEditData);
     With CounterEditData Do
          begin
          Val (InputLineData1, Camera_Total, Verror);
          Val (InputLineData2, Projector_Total, Verror);
          end;
End;

(* Use window object constructs for modal dialog. *)
Procedure TVApp.EditCountersDialog;
var C : word;
Begin
  AniApp.InitCountersWindow;
  AniApp.PutCountersWindow;
  C := DeskTop^.ExecView(CounterDialog);
  if (C <> cmCancel)
     then AniApp.GetCountersWindow;
  AniApp.ExitCountersWindow;
  if (C = cmOk)
     then begin
     if (Scripted)
        then begin
        Write_Script_Counters(Camera_Total, Projector_Total);
        CopyScript(ScriptNum-1); (* 2-liner *)
        CopyScript(ScriptNum);
        end;
     Do_Frame_Counts;
     end;
End;

(* External program wrappers for managing modeless display window. *)

(* Create modeless window for displaying frame counters. *)
Procedure Init_Status_Display;
Begin
  AniApp.InitCountersWindow;
  CounterDialog^.SelectNext(TRUE);
  DeskTop^.Insert(CounterDialog);
End;

(* Update modeless window with current frame counter values. *)
Procedure Update_Status_Display;
Begin
  AniApp.PutCountersWindow;
  CounterDialog^.Draw;
End;

(* Dispose modeless window for frame counters. *)
Procedure Exit_Status_Display;
Begin
  DeskTop^.Delete(CounterDialog);
  AniApp.ExitCountersWindow;
End;

(* Run Camera Overide dialog. *)
Procedure TVApp.RunCameraDialog;
const
  STRLEN = 20;
type
  DialogDataType = record
    InputLineData1: string[STRLEN];
    InputLineData2: string[STRLEN];
    end;
var
  ViewItem: PView;
  Dialog: PDialog;
  R: TRect;
  C: Word;
  Verror : Integer;
  EditData : DialogDataType;
begin
  R.Assign(15, 7, 65, 17);
  Dialog := New(PDialog, Init(R, ' Run Camera Overide '));
  with Dialog^ do
  begin
    HelpCtx := hcRunCam;

    R.Assign(3, 4, 23, 5);
    ViewItem := New(PInputLine, Init(R, STRLEN));
    Insert(ViewItem);
    R.Assign(3, 3, 23, 4);
    Insert(New(PLabel, Init(R, 'Camera Frames', ViewItem)));

    R.Assign(27, 4, 47, 5);
    ViewItem := New(PInputLine, Init(R, STRLEN));
    Insert(ViewItem);
    R.Assign(27, 3, 47, 4);
    Insert(New(PLabel, Init(R, 'Exposure Time', ViewItem)));

    R.Assign(10, 7, 20, 9);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(30, 7, 40, 9);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;

  With EditData Do
       begin
       Str (Camera_Count, InputLineData1);
       Str (Exposure_Time:3:2, InputLineData2);
       end;
  Dialog^.SetData(EditData);
  C := DeskTop^.ExecView(Dialog);
  if (C <> cmCancel)
     then begin
     Dialog^.GetData(EditData);
     With EditData Do
          begin
          Val (InputLineData1, Camera_Count, Verror);
          Val (InputLineData2, Exposure_Time, Verror);
          Frame_Count := Camera_Count;
          end;
     if (Scripted)
        then begin
        Write_Script_Camera(Camera_Count);
        CopyScript(ScriptNum);
        end;
     end;

  Dispose(Dialog, Done);

  if (C = cmOk)
     then Do_Camera;
end;

(* Run Projector Overide dialog. *)
Procedure TVApp.RunProjectorDialog;
const
  STRLEN = 20;
type
  DialogDataType = record
    InputLineData1: string[STRLEN];
    InputLineData2: string[STRLEN];
    end;
var
  ViewItem: PView;
  Dialog: PDialog;
  R: TRect;
  C: Word;
  Verror : Integer;
  EditData : DialogDataType;
begin
  R.Assign(15, 7, 65, 17);
  Dialog := New(PDialog, Init(R, ' Run Projector Overide '));
  with Dialog^ do
  begin
    HelpCtx := hcRunProj;

    R.Assign(3, 4, 23, 5);
    ViewItem := New(PInputLine, Init(R, STRLEN));
    Insert(ViewItem);
    R.Assign(3, 3, 23, 4);
    Insert(New(PLabel, Init(R, 'Projector Frames', ViewItem)));

    R.Assign(27, 4, 47, 5);
    ViewItem := New(PInputLine, Init(R, STRLEN));
    Insert(ViewItem);
    R.Assign(27, 3, 47, 4);
    Insert(New(PLabel, Init(R, 'Advance Speed', ViewItem)));

    R.Assign(10, 7, 20, 9);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(30, 7, 40, 9);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
    SelectNext (True);
  end;

  With EditData Do
       begin
       Str (Projector_Count, InputLineData1);
       Str (Film_Speed:3:2, InputLineData2);
       end;
  Dialog^.SetData(EditData);
  C := DeskTop^.ExecView(Dialog);
  if (C <> cmCancel)
     then begin
     Dialog^.GetData(EditData);
     With EditData Do
          begin
          Val (InputLineData1, Projector_Count, Verror);
          Val (InputLineData2, Film_Speed, Verror);
          Frame_Count := Projector_Count;
          end;
     if (Scripted)
        then begin
        Write_Script_Projector(Projector_Count);
        CopyScript(ScriptNum);
        end;
     end;

  Dispose(Dialog, Done);

  if (C = cmOk)
     then Do_Projector;
end;

(* Run Sequencer dialog. *)
Procedure TVApp.RunSequencerDialog;
const
  STRLEN = 20;
type
  DialogDataType = record
    RadioButton1: word;
    InputLineData1: string[STRLEN];
    InputLineData2: string[STRLEN];
    InputLineData3: string[STRLEN];
    end;
var
  ViewItem: PView;
  Dialog: PDialog;
  R: TRect;
  C: Word;
  Verror : Integer;
  EditData : DialogDataType;
begin
  R.Assign(15, 4, 65, 19);
  Dialog := New(PDialog, Init(R, ' Run Sequencer '));
  with Dialog^ do
  begin
    HelpCtx := hcRunSeq;

    R.Assign(3, 3, 47, 6);
    ViewItem := New(PRadioButtons, Init(R,
      NewSItem('~A~lternate Camera to Projector',
      NewSItem('Step ~C~amera per Projector Cycle',
      NewSItem('Skip ~P~rojector per Camera Cycle',
      nil)))
    ));
    Insert(ViewItem);
    R.Assign(3, 2, 47, 3);
    Insert(New(PLabel, Init(R, 'Sequencer', ViewItem)));

    R.Assign(3, 8, 23, 9);
    ViewItem := New(PInputLine, Init(R, STRLEN));
    Insert(ViewItem);
    R.Assign(3, 7, 23, 8);
    Insert(New(PLabel, Init(R, 'Camera', ViewItem)));

    R.Assign(27, 8, 47, 9);
    ViewItem := New(PInputLine, Init(R, STRLEN));
    Insert(ViewItem);
    R.Assign(27, 7, 47, 8);
    Insert(New(PLabel, Init(R, 'Projector', ViewItem)));

    R.Assign(3, 10, 47, 11);
    ViewItem := New(PInputLine, Init(R, STRLEN));
    Insert(ViewItem);
    R.Assign(3, 9, 47, 10);
    Insert(New(PLabel, Init(R, 'Sequencer Frames', ViewItem)));

    R.Assign(10, 12, 20, 14);
    Insert(New(PButton, Init(R, '~O~k', cmOK, bfDefault)));
    R.Assign(30, 12, 40, 14);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext (True);
    SelectNext (True);
  end;

  With EditData Do
       begin
       case (Sequencer) of
            Alternate     : RadioButton1 := $00;
            StepCamera    : RadioButton1 := $01;
            SkipProjector : RadioButton1 := $02;
            else            RadioButton1 := $00;
            end;
       Str (Camera_Cycle, InputLineData1);
       Str (Projector_Cycle, InputLineData2);
       Str (Sequencer_Count, InputLineData3);
       end;
  Dialog^.SetData(EditData);
  C := DeskTop^.ExecView(Dialog);
  if (C <> cmCancel)
     then begin
     Dialog^.GetData(EditData);
     With EditData Do
          begin
          case (RadioButton1) of
               $00 : Sequencer := Alternate;
               $01 : Sequencer := StepCamera;
               $02 : Sequencer := SkipProjector;
               else  Sequencer := Alternate;
               end;
          Val (InputLineData1, Camera_Cycle, Verror);
          Val (InputLineData2, Projector_Cycle, Verror);
          Val (InputLineData3, Sequencer_Count, Verror);
          Frame_Count := Sequencer_Count;
          end;
     if (Scripted)
        then begin
        Write_Script_Sequencer
             (Sequencer_Count, Camera_Cycle, Projector_Cycle, integer(Sequencer));
        CopyScript(ScriptNum-1); (* 2-liner *)
        CopyScript(ScriptNum);
        end;
     end;

  Dispose(Dialog, Done);

  if (C = cmOk)
     then Do_Sequencer;
end;

(******************************)

(* TV application extensions. *)

(* GetPalette extension is necessary for correct Help palette selection. *)
(* (TVHelp adds on its own palette triplet, so TVApp needs to know that.) *)
Function TVApp.GetPalette: PPalette;
const
{$IFDEF VER70}          (* for TV 2.0 *)
  CNewColor = CAppColor + CHelpColor;
  CNewBlackWhite = CAppBlackWhite + CHelpBlackWhite;
  CNewMonochrome = CAppMonochrome + CHelpMonochrome;
{$ELSE}                 (* for TV 1.0 *)
  CNewColor = CColor + CHelpColor;
  CNewBlackWhite = CBlackWhite + CHelpBlackWhite;
  CNewMonochrome = CMonochrome + CHelpMonochrome;
{$ENDIF}
  P: array[apColor..apMonochrome] of string[Length(CNewColor)] =
    (CNewColor, CNewBlackWhite, CNewMonochrome);
begin
  GetPalette := @P[AppPalette];
end;

(* GetEvent extension for intercepting Help commands. *)
Procedure TVApp.InterceptHelp (var Event: TEvent);
var
  W: PWindow;
  HFile: PHelpFile;
  HelpStrm: PDosStream;
  QuitEvent : TEvent;
const
  HelpInUse: Boolean = False;
  HelpName : PathStr = 'TVSEQHLP.HLP';
begin
   if (Event.Command = cmHelp) and not HelpInUse then
      begin
        HelpInUse := True;
        HelpStrm := New(PDosStream, Init(HelpName, stOpenRead));
        HFile := New(PHelpFile, Init(HelpStrm));
        if HelpStrm^.Status <> stOk then
        begin
          MessageBox('Could not open help file.', nil, mfError + mfOkButton);
          Dispose(HFile, Done);
        end
        else
        begin
          W := New(PHelpWindow,Init(HFile, GetHelpCtx));
          if ValidView(W) <> nil then
          begin
            ExecView(W);
            Dispose(W, Done);
            If MouseButtons AND mbLeftButton = mbLeftButton
               Then begin
               Delay (250);
               GetEvent (QuitEvent);
               ClearEvent (QuitEvent);
               end
          end;
          ClearEvent(Event);
        end;
        HelpInUse := False;
      end;
end;

(* GetEvent extension for intercepting Quit commands. *)
Procedure TVApp.InterceptQuit (var Event: TEvent);

Begin

   If Event.Command = cmQuit
      Then begin
      Quitting_Time_Query;
      If NOT Quitting_Time
         Then ClearEvent (Event);
      end;
End;

(*****)

(* Special Trigger Input routines. *)
Procedure Get_External_Status (Var Status : Boolean);

Begin
   Get_Trigger (Status);
End;

Procedure Get_External_Input;

Const Sample_Time = 50;
Var Trigger_Status : Boolean;
Begin

   Write (^G);
   Repeat
      Delay (Sample_Time);
      Get_Trigger (Trigger_Status);
   Until (Not Trigger_Status) Or KeyPressed Or MousePressed;

End;

(* Special Control-Break handler. *)
Function Handle_Control_Break : boolean;
var A : word;
Begin
   A := MessageBox('CONTROL-BREAK key detected.', nil, mfWarning + mfOkButton);
   Handle_Control_Break := TRUE;
End;

(* Intercept main Event Handler. *)
Procedure TVApp.GetEvent (Var Event : TEvent);

Var Trigger_Status : Boolean;
Begin

   if (DRIVERS.CtrlBreakHit)
      then begin
           DRIVERS.CtrlBreakHit := FALSE;
           Handle_Control_Break;
           Exit;
           end;

   Get_External_Status (Trigger_Status);
   If Trigger_Status
      Then begin
           Get_External_Input;
           Event.What := evCommand;
           Event.Command := cmOK;
           end

      Else begin
           TApplication.GetEvent (Event);
           If Event.What = evCommand
              Then Case Event.Command of
                   cmHelp : InterceptHelp (Event);
                   cmQuit : InterceptQuit (Event);
                   end;
           end;
End;

(* Intercept main Event Idler. *)
Procedure TVApp.Idle;

Begin

   TApplication.Idle;

End;

(* Main Loop Event Handler. *)
Procedure TVApp.HandleEvent(var Event: TEvent);

(* Pull down 'About' box. *)
procedure About;
var
  D: PDialog;
  Control: PView;
  R: TRect;
begin
  R.Assign(0, 0, 40, 11);
  D := New(PDialog, Init(R, 'About'));
  with D^ do
  begin
    HelpCtx := hcSAbout;
    Options := Options or ofCentered;

    R.Grow(-1, -1);
    Dec(R.B.Y, 3);
    Insert(New(PStaticText, Init(R,
      #13 +
      ^C'Animal Professional'#13 +
      #13 +
      ^C'Copyright (c) 1982-92'#13 +
      #13 +
      ^C'Penguin Associates')));

    R.Assign(15, 8, 25, 10);
    Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));
  end;
  if ValidView(D) <> nil then
  begin
    Desktop^.ExecView(D);
    Dispose(D, Done);
  end;
end;

(* Activate desktop calculator. *)
procedure Calculator;
var
  P: PCalculator;
begin
  P := New(PCalculator, Init);
  P^.HelpCtx := hcCalculator;
  if ValidView(P) <> nil then
    Desktop^.Insert(P);
end;

(* Display heap memory info. *)
Procedure HeapOMemory;

Var HS, MS, TS : String;
Begin
   Str (MemAvail, HS);
   Str (MaxAvail, MS);
   TS := 'Total Memory  = ' + HS + ' bytes' + ^M +
         'Largest Chunk = ' + MS + ' bytes';
   MessageBox(TS, Nil, mfInformation + mfOkButton );
End;

(* Change Directory Dialog. *)
procedure ChangeDir;
var
  D: PChDirDialog;
begin
  D := New(PChDirDialog, Init(cdNormal + cdHelpButton, 101));
  D^.HelpCtx := hcFCChDirDBox;
  ExecuteDialog(D, nil);
end;

(* TVApp.HandleEvent *)
Begin

  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    CmdBuf := Event.Command;
    case Event.Command of
      cmEmergencyKill  : ;
      cmEmergencyReset : ;
      cmAbout          : About;
      cmCalculator     : Calculator;
      cmMemory         : HeapOMemory;

{$IFDEF USE_EDITOR}
      cmNew            : New_File_Dialog;
      cmOpen           : Load_File_Dialog;
      (* Save commands already intercepted by editor ? *)
      cmSave           : ;
      cmSaveAs         : ;
      cmChangeDir      : ChangeDir;
{$ELSE}
      cmFileNew        : New_File_Dialog;
      cmFileOpen       : Load_File_Dialog;
      cmFileSave       : Save_File_Dialog;
{$ENDIF}

      cmEditCount      : EditCountersDialog;
      cmRunCam         : RunCameraDialog;
      cmRunProj        : RunProjectorDialog;
      cmRunSeq         : RunSequencerDialog;
      cmRunScript      : RunScriptFile;
      cmSpecTerm       : TerminalDialog;
      cmDosShell       : DosShell;
      cmQuit           : Quitting_Time_Query;
      cmOK             : Overide;
      else               Exit;
      end;
    ClearEvent(Event);
    UpdateAllWindows;
  end;
end;

(* Custom initialize menu bar. *)
Procedure TVApp.InitMenuBar;
var R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~'#240'~', hcNoContext, NewMenu(
      NewItem('~A~bout', '', kbNoKey, cmAbout, hcSAbout,
      NewLine(
      NewItem('~C~alculator', '', kbNoKey, cmCalculator, hcCalculator,
      NewItem('~M~emory', '', kbNoKey, cmMemory, hcMemory,
      NewItem('~T~erminal', '', kbNoKey, cmSpecTerm, hcSpecTerm,
      nil)))))),
{$IFDEF USE_EDITOR}
    NewSubMenu('~F~ile', hcFile, NewMenu(
      StdFileMenuItems(nil)),
{$ELSE}
    NewSubMenu('~F~ile' , hcNoContext, NewMenu(
      NewItem('~N~ew'   , 'F4', kbF4, cmFileNew, hcFileNew,
      NewItem('~L~oad'  , 'F3', kbF3, cmFileOpen, hcFileOpen,
      NewItem('~S~ave'  , 'F2', kbF2, cmFileSave, hcFileSave,
      NewLine(
      NewItem('~D~OS' , '', kbNoKey, cmDosShell, hcFileDos,
      NewItem('~Q~uit', 'Alt-Q', kbAltQ, cmQuit, hcFileQuit,
      nil))))))),
{$ENDIF}
    NewSubMenu('~E~dit' , hcNoContext, NewMenu(
      StdEditMenuItems(
      NewLine(
      NewItem('~F~rame Counters'  , '', kbNoKey, cmEditCount   , hcEditCount   ,
      nil)))),
    NewSubMenu('~R~un'  , hcNoContext, NewMenu(
      NewItem('~C~amera only',    '', kbNoKey, cmRunCam, hcRunCam,
      NewItem('~P~rojector only', '', kbNoKey, cmRunProj, hcRunProj,
      NewItem('~S~equencer mode', '', kbNoKey, cmRunSeq, hcRunSeq,
      NewLine(
      NewItem('~F~ile Script'  , '', kbNoKey, cmRunScript, hcRunScript,
      nil)))))),
    nil))))
  )));
end;

(* Custom initialize status line. *)
(* Use extended StatusLine object for quick-n-easy hints. *)
(* Note: Non-visible hot-keys for Kill and Reset commands. *)
Procedure TVApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PUserStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('', kbAltK, cmEmergencyKill,
      NewStatusKey('', kbAltZ, cmEmergencyReset,
      nil)))),
    nil)
  ));
end;

(* Extend user StatusLine object with 'hard-wired' help hints. *)
Function TVUserStatusLine.Hint (AHelpCtx : Word) : String;

Begin

Case AHelpCtx of
  hcSAbout          : Hint := 'About this program';
  hcCalculator      : Hint := 'Desktop Calculator';
  hcMemory          : Hint := 'Memory available';
  hcSpecTerm        : Hint := 'Terminal for Direct Serial IO';

  hcFileNew         : Hint := 'New Sequencer Script File';
  hcFileOpen        : Hint := 'Load Sequencer Script File from Disk';
  hcFileSave        : Hint := 'Save Sequencer Script to File on Disk';
  hcFileDos         : Hint := 'MS-DOS command line shell';
  hcFileQuit        : Hint := 'Quit the program';

  hcEditCount       : Hint := 'Edit Total Counters';
  hcRunCam          : Hint := 'Camera Overide';
  hcRunProj         : Hint := 'Projector Overide';
  hcRunSeq          : Hint := 'Camera + Projector Sequencer operation';
  hcRunScript       : Hint := 'Run Sequencer Script File';

  Else                Hint := '';
  end;
End;

(* Display Out-of-Memory message for low heap conditions. *)
procedure TVApp.OutOfMemory;
begin
  MessageBox('Not enough Memory',
    nil, mfError + mfOkButton);
end;

(* Here it is: the Main Menu Loop. *)
Procedure Main_Menu_Loop;

Begin

  Init_Local_Stuff;

  AniApp.Init;
  HelpFile.RegisterHelpFile;
  AniApp.Run;
  AniApp.Done;

End;

(* Initialization *)

Begin

End.
