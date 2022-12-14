(* Animal Professional -- Aug 23 2002 DaveM *)

Program TVAnimal;

(* Compumotor PC23 Real-time motion control hardware. *)
(* Turbo Vision object library user interface. *)
(* Graphics displays use BGI routines and primatives. *)
(* Separate array for tapering Time axis, as used by all other axes. *)
(* 2-step Interpolation procedures re-implements Coefficient arrays
(* for minimum stack usage and faster re-computations. *)

{$I SWITCHES.INC}          (* compiler switches *)

{$I MCPU.INC}              (* MCPU switches *)

Uses

     TpCrt,                (* TurboPro console extensions *)
     KEYBD,                (* Keyboard input filters *)
     GLOBAL,               (* Animal Global declarations *)
     MCPU,                 (* MCPU Communications *)
     INIT,                 (* Initialization *)
     SPLINE,               (* Spline curve interpolation *)

     GLOBAL2,              (* TV Animal points *)
     MCPUIO,               (* Motion Control features *)
     TRIGIO,               (* Trigger Outputs *)
     FILEIO,               (* File IO *)
     USERIO,               (* User Interface *)
     MAINIO,               (* Main Processing *)

     USERAUX,              (* Auxilary Helper routines *)
     USERGRAF,             (* BGI Graphics routines *)
     USERWRAP,             (* Wrapper routines to main app objects *)
     USERMAIN,             (* Main TV application *)

{$IFDEF SPECIAL_FEATURE}
     TERMIO,               (* General Terminal Interface *)
     RGBIO,                (* RGB Light Source Interface *)
     RGBMAIN,              (* RGB Light Source main processing *)
{$ENDIF}

     Dos,                  (* MS-DOS function calls *)
     Graph,                (* Turbo Pascal BGI Library *)

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
     Calc;                 (* TV calculator desk accy *)

(*****)

Procedure Assign_Ports;
Var E : integer;
Begin
   (* Defaults are already set in unit modules loaded first *)
   MCPU_PortX := 2;        (* COMx *)
{$IFDEF RGB_CONTROL}
   RGB_PortX := 3;         (* COMx *)
{$ENDIF}
   TRG_PortX := 2;         (* LPTx *)
   (* 1st command line parameter selects MCPU serial port *)
   If (ParamCount >= 1)
      Then Val (ParamStr(1), MCPU_PortX, E);
{$IFDEF RGB_CONTROL}
   (* 2nd command line parameter selects RGB serial port *)
   If (ParamCount >= 2)
      Then Val (ParamStr(2), RGB_PortX, E);
{$ENDIF}
   (* 3rd command line parameter selects Trigger parallel port *)
   If (ParamCount >= 3)
      Then Val (ParamStr(3), TRG_PortX, E);
End;

Procedure Signon;
Begin
   Writeln ('Animal Professional / Animation Motion Control');
   Writeln ('Copyright 1982-2002 Dave Milici / Ironic Research Labs');
   Writeln;
   Writeln ('Installation for Rock Ross & Penguin Associates');
{$IFDEF MCPU_COMPUMTR}
   Writeln ('Compumotor MCPU for COM', MCPU_PortX);
{$ELSE}
   Writeln ('STD bus MCPU for COM', MCPU_PortX);
{$ENDIF}
{$IFDEF RGB_CONTROL}
   Writeln ('RGB Light control for COM', RGB_PortX);
{$ENDIF}
   Writeln ('Trigger Output for LPT', TRG_PortX);
   Writeln;
End;

(* Main *)

Begin

   Assign_Ports;

   Signon;

   Init_Animal;

   Main_Menu_Loop;

   Exit_Animal;

End.
