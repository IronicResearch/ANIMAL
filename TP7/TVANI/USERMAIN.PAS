
(* Main User Interface with TVision objects. *)

(* USERMAIN: all TV object code *)
(* USERWRAP: some wrappers to selected objects *)
(* USERIO:   basic user IO routines *)
(* USERAUX:  most non-object routines *)
(* USERGRAF: BGI graphics routines *)

Unit USERMAIN;

{$I SWITCHES.INC}          (* compiler switches *)

Interface

Uses

     TpCrt,                (* TurboPro console extensions *)
     TpString,             (* TurboPro string extensions *)
     KEYBD,                (* Keyboard input filters *)
     GLOBAL ,              (* Animal Global declarations *)
     GLOBAL2,              (* TV Animal Point-Plotter *)
     MCPU ,                (* MCPU Communications *)
     MCPUIO,               (* MCPU Features *)
     TRIGIO,               (* Trigger IO *)
     FILEIO,               (* File IO *)
     MAINIO,               (* Main processing *)

{$IFDEF SPECIAL_FEATURE}
     TERMIO,               (* General Terminal Interface *)
     RGBIO,                (* RGB Light Source Interface *)
     RGBMAIN,              (* RGB Light Source main processing *)
{$ENDIF}

     USERIO,               (* User IO basic routines *)
     USERAUX,              (* User IO auxiliary helper routines *)
     USERGRAF,             (* User IO graphics routines *)

     Dos,                  (* MS-DOS function calls *)

     Objects,              (* Turbo Vision Object Library *)
     Drivers,              (* TV interface drivers *)
     Views,                (* TV view screens *)
     Menus,                (* TV menus *)
     Dialogs,              (* TV dialog boxes *)
     App,                  (* TV application framework *)
     StdDlg,               (* TV standard file dialogs *)
     MsgBox,               (* TV message boxes *)
     HelpFile,             (* TV help screens *)
     FViewer,              (* TV file viewer *)
     Puzzle,               (* TV puzzle desk accessory *)
     Gadgets,              (* TV clock gadget *)
     Calc;                 (* TV calculator desk accy *)

(* Turbo Vision interface definitions. *)

Const

  kbNul             = 0;
  cmNull            = 199;

  cmEmergencyKill   = 9910;
  cmEmergencyReset  = 9920;
  cmEmergencyOveride= 9930;
  cmEmergencyTerminal = 9940;

  cmAbout           = 1100;
  cmPuzzle          = 1200;
  cmCalendar        = 1300;
  cmCalculator      = 1400;
  cmMemory          = 1500;
  cmFileOpen        = 2100;
  cmFileNew         = 2200;
  cmFileSave        = 2300;
  cmEditPlot        = 3100;
  cmEditTime        = 3200;
  cmEditTaper       = 3300;
  cmEditDisplay     = 3400;
  cmEditGraphics    = 3500;
  cmRunPlot         = 4100;
  cmRunReal         = 4200;
  cmRunAlign        = 4300;
  cmOveride         = 4400;
  cmJoystick        = 4500;
  cmRunStop         = 4600;
  cmRunGoMo         = 4700;
  cmUtilAxis        = 5100;
  cmUtilUser        = 5200;
  cmUtilSpeed       = 5300;
  cmUtilTrig        = 5400;
  cmUtilAlign       = 5500;
  cmSpecTerm        = 6100;
  cmSpecLight       = 6200;
  cmSpecColor       = 6300;
  cmSpecMcpu        = 6400;
  cmSpecRgb         = 6500;
  cmConfMcpu        = 7100;
  cmConfRgb         = 7200;
  cmConfTrig        = 7300;
  cmConfJoystick    = 7400;
  cmConfAxis        = 7500;
  cmConfOptions     = 7600;

  hcDeskAccy        = 1000;
  hcAbout           = 1100;
  hcPuzzle          = 1200;
  hcCalendar        = 1300;
  hcCalculator      = 1400;
  hcMemory          = 1500;
  hcFileMenu        = 2000;
  hcFileOpen        = 2100;
  hcFOpen           = 2101;
  hcFView           = 2102;
  hcChDir           = 2103;
  hcFileNew         = 2200;
  hcFileSave        = 2300;
  hcFileDos         = 2800;
  hcFileQuit        = 2900;
  hcEditMenu        = 3000;
  hcEditPlot        = 3100;
  hcEditTime        = 3200;
  hcEditTaper       = 3300;
  hcEditDisplay     = 3400;
  hcEditGraphics    = 3500;
  hcRunMenu         = 4000;
  hcRunPlot         = 4100;
  hcRunReal         = 4200;
  hcRunAlign        = 4300;
  hcOveride         = 4400;
  hcJoystick        = 4500;
  hcRunStop         = 4600;
  hcRunGoMo         = 4700;
  hcUtilMenu        = 5000;
  hcUtilAxis        = 5100;
  hcUtilUser        = 5200;
  hcUtilSpeed       = 5300;
  hcUtilTrig        = 5400;
  hcUtilTrig1       = 5410;
  hcUtilAlign       = 5500;
  hcSpecMenu        = 6000;
  hcSpecTerm        = 6100;
  hcSpecTerm1       = 6110;
  hcSpecTerm2       = 6120;
  hcSpecLight       = 6200;
  hcSpecColor       = 6300;
  hcSpecMcpu        = 6400;
  hcSpecRgb         = 6500;
  hcConfMenu        = 7000;
  hcConfMcpu        = 7100;
  hcConfRgb         = 7200;
  hcConfTrig        = 7300;
  hcConfJoystick    = 7400;
  hcConfAxis        = 7500;
  hcConfOptions     = 7600;
  hcConfComPort     = hcSpecTerm1;
  hcConfLptPort     = hcUtilTrig1;

Type
  PTVApp = ^TVApp;
  TVApp = object(TApplication)
    Clock : PClockView;
    constructor Init;
    procedure FileOpen(WildCard: PathStr);
    procedure ViewFile(FileName: PathStr);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure OutOfMemory; virtual;
    procedure GetEvent (var Event : TEvent); virtual;
    procedure Idle; virtual;
    Function GetPalette: PPalette; virtual;
    Procedure InterceptHelp (var Event: TEvent);
    Procedure InterceptQuit (var Event: TEvent);
    Procedure UpdateAllWindows;
    Procedure NewDialog;
    Procedure SaveDialog;
    Procedure TimeDialog;
    Procedure EditDialog;
    Procedure PlotDialog;
    Procedure RunDialog;
    Procedure OverDialog;
    Procedure AlignDialog;
    Procedure GraphicsDialog;
    Procedure DisplayWindow;
    Procedure DisplayGraphics;
    Procedure HirezGraphics;
    Procedure AxisDialog;
    Procedure UserDialog;
    Procedure SpeedDialog;
    Procedure TriggerDialog;
    Procedure AlignmentDialog;
    Procedure OverJogDialog;
    Procedure RunStopDialog;
    Procedure RunGoMoDialog;
{$IFDEF SPECIAL_FEATURE}
    Procedure TerminalDialog;
    Procedure TerminalWindow;
    Procedure McpuDialog;
    Procedure McpuWindow;
    Procedure LightSourceDialog;
    Procedure LightSourceWindow;
    Procedure ColorTableDialog;
{$ENDIF}
    Procedure ComPortDialog;
    Procedure LptPortDialog;
    Procedure McpuConfigDialog;
    Procedure RgbConfigDialog;
    Procedure TrigConfigDialog;
    Procedure JoystickDialog;
    Procedure AxisConfigDialog;
    Procedure OptionsDialog;
  end;

Var
  AniApp: TVApp;                            (* global app object *)

Type
  TVUserStatusLine  = Object (TStatusLine)
    Function Hint (AHelpCtx : Word) : String; Virtual;
    end;

  PUserStatusLine = ^TVUserStatusLine;

  PEditDialog = ^TEditDialog;
  TEditDialog = object(TDialog)
    end;

Var
  FileName : String [128];
  FileExtn : String [3];                    (* active file name *)
                                            (* + extension *)
Var
  CmdBuf : Word;                            (* event command buffer *)
  DCmdBuf : Word;                           (* local dialog command buffer *)

Var
  Index : Integer;                          (* selected axis index *)

Procedure Main_Menu_Loop;

Procedure Save_File_Dialog;

Procedure Load_File_Dialog;

(***************************************)

Implementation

Const
  JoystickEnabled : boolean = true;
  JoystickTrigger : boolean = true;
  JoystickOveride : boolean = true;

Var
  StatusOveride : boolean;
  StatusString  : String;

Procedure Overide; Forward;

Procedure Enable_Joystick; Forward;

Procedure Disable_Joystick; Forward;

Procedure CheapStatus (S : String); Forward;

Procedure CheapStatusClear; Forward;

(* TV Object extensions. *)

{$I USERWIN.INC}        (* TV view window overides *)

(*****)

{$I USERFILE.INC}       (* File menu dialogs *)

(*****)

{$I USEREDIT.INC}       (* Edit menu dialogs *)

(*****)

{$I USERRUN.INC}        (* Run menu dialogs *)

(*****)

{$I USERUTIL.INC}       (* Utility menu dialogs *)

(*****)

(* Additional Special Features: *)

{$IFDEF SPECIAL_FEATURE}

{$I USERSPCL.INC}       (* Special feature menu dialogs *)

{$ENDIF}

(*****)

{$I USERCONF.INC}       (* Config menu dialogs *)

(*****)

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
  HelpName : PathStr = 'TVANIHLP.HLP';
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

(* Intercept main Event Handler. *)

Procedure TvApp.GetEvent (Var Event : TEvent);
Var Trigger_Status : Boolean;
Begin

   if (DRIVERS.CtrlBreakHit)
      then begin
           DRIVERS.CtrlBreakHit := FALSE;
           Handle_Control_Break;
           Exit;
           end;

   if (JoystickEnabled and JoystickTrigger)
      then Get_External_Status (Trigger_Status)
      else Trigger_Status := false;

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

Procedure TvApp.Idle;
Begin

   if (Clock <> nil)
      then Clock^.Update;
   TApplication.Idle;

End;

(* Main Loop Event Handler. *)

Procedure TVApp.HandleEvent(var Event: TEvent);

(* Pull down 'About' box. *)

procedure About;
var
  D: PEditDialog;
  Control: PView;
  R: TRect;
begin
  R.Assign(0, 0, 40, 11);
  D := New(PEditDialog, Init(R, 'About'));
  with D^ do
  begin
    HelpCtx := hcAbout;
    Options := Options or ofCentered;

    R.Grow(-1, -1);
    Dec(R.B.Y, 3);
    Insert(New(PStaticText, Init(R,
      #13 +
      ^C'Animal Professional'#13 +
      #13 +
      ^C'Copyright (c) 1982-2002'#13 +
      #13 +
      ^C'Dave Milici')));

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

(* Activate desktop puzzle. *)

procedure Puzzle;
var
  P: PPuzzleWindow;
begin
  P := New(PPuzzleWindow, Init);
  P^.HelpCtx := hcPuzzle;
  Desktop^.Insert(ValidView(P));
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

(*****)

Begin  (* TVApp.HandleEvent *)

  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    CmdBuf := Event.Command;
    case Event.Command of
      cmEmergencyKill  : Query_Emergency_Kill;
      cmEmergencyReset : Query_Emergency_Reset;
      cmEmergencyOveride : Query_Emergency_Overide;
      cmEmergencyTerminal: Query_Emergency_Terminal;
      cmAbout          : About;
      cmPuzzle         : Puzzle;
      cmCalculator     : Calculator;
      cmMemory         : HeapOMemory;
      cmFileNew        : NewDialog;
      cmFileOpen       : Load_File_Dialog;
      cmFileSave       : Save_File_Dialog;
      cmEditTime       : TimeDialog;
      cmEditTaper      : TimeDialog;
      cmEditPlot       : EditDialog;
      cmEditDisplay    : DisplayWindow;
      cmEditGraphics   : GraphicsDialog;
      cmRunPlot        : PlotDialog;
      cmRunReal        : RunDialog;
      cmRunStop        : RunStopDialog;
      cmRunGoMo        : RunGoMoDialog;
      cmRunAlign       : AlignDialog;
      cmOveride        : OverDialog;
      cmJoystick       : Overide;
      cmUtilAxis       : AxisDialog;
      cmUtilUser       : UserDialog;
      cmUtilSpeed      : SpeedDialog;
      cmUtilTrig       : TriggerDialog;
      cmUtilAlign      : AlignmentDialog;
{$IFDEF SPECIAL_FEATURE}
      cmSpecTerm       : TerminalDialog;
      cmSpecMcpu       : McpuDialog;
      cmSpecRgb        : LightSourceWindow;
      cmSpecLight      : LightSourceDialog;
      cmSpecLight+1    : LightSourceDialog;
      cmSpecColor      : ColorTableDialog;
{$ENDIF}
      cmConfMcpu       : McpuConfigDialog;
      cmConfRgb        : RgbConfigDialog;
      cmConfTrig       : TrigConfigDialog;
      cmConfJoystick   : JoystickDialog;
      cmConfAxis       : AxisConfigDialog;
      cmConfOptions    : OptionsDialog;
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
    NewSubMenu('~'#240'~', hcDeskAccy, NewMenu(
      NewItem('~A~bout', '', kbNoKey, cmAbout, hcAbout,
      NewLine(
      NewItem('~C~alculator', '', kbNoKey, cmCalculator, hcCalculator,
      NewItem('~M~emory', '', kbNoKey, cmMemory, hcMemory,
      NewItem('~G~adgets', '', kbNoKey, cmPuzzle, hcPuzzle,
      nil)))))),
    NewSubMenu('~F~ile' , hcFileMenu, NewMenu(
      NewItem('~N~ew'   , 'F4', kbF4, cmFileNew, hcFileNew,
      NewItem('~L~oad'  , 'F3', kbF3, cmFileOpen, hcFileOpen,
      NewItem('~S~ave'  , 'F2', kbF2, cmFileSave, hcFileSave,
      NewLine(
      NewItem('~D~OS' , '', kbNoKey, cmDosShell, hcFileDos,
      NewItem('~Q~uit', 'Alt-Q', kbAltQ, cmQuit, hcFileQuit,
      nil))))))),
    NewSubMenu('~E~dit' , hcEditMenu, NewMenu(
      NewItem('~S~creen Time'  , '', kbNul, cmEditTime, hcEditTime,
      NewItem('~T~apers In/Out', '', kbNul, cmEditTaper, hcEditTaper,
      NewItem('~K~ey Points'   , '', kbNul, cmEditPlot, hcEditPlot,
      NewItem('~D~isplay Points','', kbNul, cmEditDisplay, hcEditDisplay,
      NewItem('~G~raph Points' , '', kbNul, cmEditGraphics, hcEditGraphics,
      nil)))))),
    NewSubMenu('~R~un'  , hcRunMenu, NewMenu(
      NewItem('~O~veride'      , '', kbNul, cmOveride, hcOveride,
      NewItem('~A~lignment'    , '', kbNul, cmRunAlign, hcRunAlign,
      NewItem('~P~lot Points'  , '', kbNul, cmRunPlot, hcRunPlot,
      NewLine(
      NewItem('~R~un Real-Time', '', kbNul, cmRunReal, hcRunReal,
      NewItem('~S~top Motion'  , '', kbNul, cmRunStop, hcRunStop,
      NewItem('~G~o Motion/Streak', '', kbNul, cmRunGoMo, hcRunGoMo,
      nil)))))))),
    NewSubMenu('~U~tilities'   , hcUtilMenu, NewMenu(
      NewItem('~A~xis Mapping' , '', kbNul, cmUtilAxis, hcUtilAxis,
      NewItem('~U~ser Units'   , '', kbNul, cmUtilUser, hcUtilUser,
      NewItem('~M~otor Speeds' , '', kbNul, cmUtilSpeed, hcUtilSpeed,
      NewItem('~T~rigger Outputs','',kbNul, cmUtilTrig, hcUtilTrig,
      NewItem('~A~lignment Order','',kbNul, cmUtilAlign, hcUtilAlign,
      nil)))))),
    NewSubMenu('~C~onfigure'   , hcConfMenu, NewMenu(
      NewItem('~M~CPU Ports'   , '', kbNul, cmConfMcpu, hcConfMcpu,
      NewItem('~R~GB Port'     , '', kbNul, cmConfRgb, hcConfRgb,
      NewItem('~T~rigger Port' , '', kbNul, cmConfTrig, hcConfTrig,
      NewItem('~J~oystick'     , '', kbNul, cmConfJoystick, hcConfJoystick,
      NewItem('~A~xis Memory'  , '', kbNul, cmConfAxis, hcConfAxis,
      NewItem('Misc ~O~ptions' , '', kbNul, cmConfOptions, hcConfOptions,
      nil))))))),
{$IFDEF SPECIAL_FEATURE}
    NewSubMenu('~S~pecial'     , hcSpecMenu, NewMenu(
      NewItem('~T~erminal'     , '', kbNul, cmSpecTerm, hcSpecTerm,
      NewItem('~M~CPU Control' , '', kbNul, cmSpecMcpu, hcSpecMcpu,
      NewItem('~R~GB  Control' , '', kbNul, cmSpecRgb, hcSpecRgb,
      NewItem('~L~ight Source Pgm', '', kbNul, cmSpecLight, hcSpecLight,
      NewItem('~L~ight Source Run', '', kbNul, cmSpecLight+1, hcSpecLight,
      NewItem('~C~olor Table'     , '', kbNul, cmSpecColor, hcSpecColor,
      nil))))))),
    nil)))))))
{$ELSE}
    nil))))))
{$ENDIF}
  )));
end;

(* Custom initialize status line. *)
(* Use extended StatusLine object for quick-n-easy hints. *)
(* Note: Non-visible hot-keys for Kill and Reset commands. *)
(* 1 of 2 status lines will appear depending on whether
(* View or App HelpCtx is assigned or not (hcNoContext=0). *)

Procedure TVApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PUserStatusLine, Init(R,
    NewStatusDef(1, $FFFF,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      NewStatusKey('~F10~ Menu', kbF10, cmMenu,
      NewStatusKey('', kbAltJ, cmJoystick,
      NewStatusKey('', kbAltK, cmEmergencyKill,
      NewStatusKey('', kbAltZ, cmEmergencyReset,
      NewStatusKey('', kbAltO, cmEmergencyOveride,
      NewStatusKey('', kbAltT, cmEmergencyTerminal,
      nil))))))),
    NewStatusDef(0, 1,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~Alt-J~ Joystick', kbAltJ, cmJoystick,
      NewStatusKey('~Alt-K~ Kill', kbAltK, cmEmergencyKill,
      NewStatusKey('~Alt-Z~ Reset', kbAltZ, cmEmergencyReset,
      NewStatusKey('~Alt-O~ Overide', kbAltO, cmEmergencyOveride,
      NewStatusKey('~Alt-T~ Terminal', kbAltT, cmEmergencyTerminal,
      nil))))))),
    nil))
  ));
  StatusOveride := false;
  StatusString := '';
end;

(* Extend user StatusLine object with 'hard-wired' help hints. *)

Function TVUserStatusLine.Hint (AHelpCtx : Word) : String;
Var S : String;
Begin
  S := '';
  Case AHelpCtx of
  hcDeskAccy        : S := 'Desk Accessories';
  hcMemory          : S := 'Memory available';
  hcAbout           : S := 'About this program...';
  hcPuzzle          : S := 'The Puzzle...';
  hcCalculator      : S := 'Desktop Calculator';
  hcFileMenu        : S := 'File Menu';
  hcFileNew         : S := 'New Plot in Memory';
  hcFileOpen        : S := 'Load Plot File from Disk';
  hcFileSave        : S := 'Save Plot to File on Disk';
  hcFileDos         : S := 'MS-DOS command line';
  hcFileQuit        : S := 'Quit the program';
  hcEditMenu        : S := 'Edit Menu';
  hcEditPlot        : S := 'Edit Key-Frame Plot Points';
  hcEditTime        : S := 'Edit Screen Time Base';
  hcEditTaper       : S := 'Edit Tapering In/Out';
  hcEditDisplay     : S := 'Display Interpolated Points';
  hcEditGraphics    : S := 'Graph Interpolated Points';
  hcRunMenu         : S := 'Run Menu';
  hcRunPlot         : S := 'Plot Key-Frame Points to Memory';
  hcRunReal         : S := 'Run Interpolated Points in Real-Time';
  hcRunStop         : S := 'Run Interpolated Points in Stop Motion';
  hcRunGoMo         : S := 'Run Points with Go Motion / Streaking';
  hcRunAlign        : S := 'Run Alignment Procedure';
  hcOveride         : S := 'Overide Motion Control';
  hcJoystick        : S := 'Joystick Control';
  hcUtilMenu        : S := 'Utility Menu';
  hcUtilAxis        : S := 'Axis Mapping Utility';
  hcUtilUser        : S := 'User Units Conversions';
  hcUtilSpeed       : S := 'Motor Speed Profiles';
  hcUtilTrig        : S := 'Trigger Output Definitions';
  hcUtilAlign       : S := 'Alignment Procedure Order';
  hcSpecMenu        : S := 'Special Feature Menu';
  hcSpecTerm        : S := 'Terminal for Direct Serial IO';
  hcSpecMcpu        : S := 'MCPU Communications for Direct IO';
  hcSpecRgb         : S := 'RGB Light Source Control IO';
  hcSpecLight       : S := 'RGB Light Source Programming';
  hcSpecColor       : S := 'RGB Color Table Management';
  hcConfMenu        : S := 'Configure Menu';
  hcConfMcpu        : S := 'Configure MCPU Ports';
  hcConfRgb         : S := 'Configure RGB Light Source Port';
  hcConfTrig        : S := 'Configure Trigger Output Port';
  hcConfJoystick    : S := 'Configure Joystick Input Port';
  hcConfAxis        : S := 'Configure Axis Plot Memory';
  hcConfOptions     : S := 'Configure Miscellanous Options';
  Else                S := '';
  end;
  (* Overide Status Help string with custom status string? *)
  if (StatusOveride)
     then S := StatusString;
  Hint := S;
End;

(* Display Out-of-Memory message for low heap conditions. *)

procedure TvApp.OutOfMemory;
begin
  MessageBox('Not enough Memory',
    nil, mfError + mfOkButton);
end;

(* main app object *)

constructor TVApp.Init;
var R: TRect;
begin
  (* Default init *)
  TApplication.Init;

  (* Register TV objects memory *)
  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterApp;
  RegisterHelpFile;
  RegisterPuzzle;
  {RegisterCalendar;}
  {RegisterAsciiTab;}
  RegisterCalc;
  RegisterFViewer;

  (* Add clock view gadget to menu bar area (not actually part of menu bar) *)
  GetExtent(R);
  R.A.X := R.B.X - 9; R.B.Y := R.A.Y + 1;
  Clock := New(PClockView, Init(R));
  Insert(Clock);

  (* Init window vars *)
  WinCount := 0;
  Window := Nil;
  DWindowActive := False;

  For I := XX to RR Do
      begin
      GWindow [I] := Nil;
      GWindowActive [I] := False;
      end;

  (* Customize app init *)
  NewDialog;
  if (DCmdBuf = cmOk)
     then PlotDialog;
end;

(* Inter-dimensional calling routines: *)

(* Dialog shell for Saving File. *)

Procedure Save_File_Dialog;

Begin

  FileName := Default_Plot;
  FileExtn := 'KEY';

  AniApp.SaveDialog;

  If (DCmdBuf = cmOk)
     Then begin
     Default_Plot := FileName;
     CheapStatus ('...Saving Plot File ' + FileName + '...');
     Save_Plot_File;
     CheapStatusClear;
     end;

End;

(* File-Open dialog shell. *)

Procedure Load_File_Dialog;
Begin

   Query_Save_File;

   AniApp.FileOpen ('*.KEY');

   If (DCmdBuf = cmOk)
      Then begin
      Default_Plot := FileName;
      CheapStatus ('...Loading Plot File ' + FileName + '...');
      Load_Plot_File;
      Edit_Screen_Time;
      AniApp.ViewFile (FileName);
      CheapStatusClear;
      end;

End;

(* Overide command shell. *)

Procedure Overide;
Begin
   if (JoystickEnabled and JoystickOveride)
      then Go_Joystick_Overide
      else AniApp.OverJogDialog; {Go_Jog_Overide;}
End;

(* Joystick command shell. *)

Procedure Enable_Joystick;
Begin
   if (JoystickEnabled)
      then MCPUIO.Enable_Joystick;
End;

Procedure Disable_Joystick;
Begin
   if (JoystickEnabled)
      then MCPUIO.Disable_Joystick;
End;

(* Status line overide shell. *)

Procedure CheapStatus (S : String);
Begin
   StatusOveride := true;
   StatusString := S;
   StatusLine^.Update;
End;

Procedure CheapStatusClear;
Begin
   StatusOveride := false;
   StatusString := '';
   StatusLine^.Update;
End;


(* Init misc local vars. *)

Procedure Init_Local_Stuff;
begin
  FileName := 'ANIMAL.KEY';
  FileExtn := 'KEY';
end;

(* Main app loop. *)

Procedure Main_Menu_Loop;
Begin

  Init_Local_Stuff;

  AniApp.Init;
  AniApp.Run;
  AniApp.Done;

End;

End.
