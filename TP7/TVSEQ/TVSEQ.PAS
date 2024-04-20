(* Animal Professional -- JUL 23 95 DaveM *)

Program TVSequencer;

(* Animal Sequencer for remote ThingM control. *)
(* Turbo Vision object library user interface. *)

{$I SWITCHES.INC}          (* compiler switches *)

Uses

     TpCrt,                (* TurboPro console extensions *)
     Dos,                  (* MS-DOS function calls *)

     GLOBAL,               (* Animal Global declarations *)
     CONIO,                (* console user interface *)
     TIMEX,                (* ThisTime clock *)
     SIO,                  (* Serial Interface *)
     MCPU,                 (* Motion Control features *)
     TERMIO,               (* General Terminal Interface *)
     THINGM,               (* ThingM Interface *)
     SEQIO,                (* Sequencer functions *)
     SEQFILE,              (* Sequencer file IO *)
     MAINIO,               (* Main Processing *)
     USERIO,               (* User Interface *)

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
     Calc;                 (* TV calculator desk accy *)

(*****)

Begin

   Signon;

   Init_Animal;

   Main_Menu_Loop;

   Exit_Animal;

End.
