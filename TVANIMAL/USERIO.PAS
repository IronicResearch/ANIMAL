
(* User Interface *)

Unit USERIO;

{$I SWITCHES.INC}          (* compiler switches *)

Interface

Uses
     TpCrt,                (* TurboPro console extensions *)
     TpString,             (* TurboPro string extensions *)
     KEYBD,                (* Keyboard input filters *)

     Objects,              (* Turbo Vision Object Library *)
     Drivers,              (* TV interface drivers *)
     Views,                (* TV view screens *)
     Dialogs,              (* TV dialog boxes *)
     MsgBox;               (* TV message boxes *)


Function MousePressed : Boolean;

Function User_Interrupt : Boolean;

Function Ask_User (S : string) : boolean;

Procedure Notify_User (S : string);

Procedure Save_File_Dialog;

(******************************)

Implementation

Uses USERAUX;              (* private access to Save_File_Dialog *)

(* MousePressed detection adapted to Turbo Vision Drivers unit *)
Function MousePressed : Boolean;
Begin
   MousePressed := (MouseButtons AND (mbLeftButton + mbRightButton) <> 0);
End;

(* User_Interruption loops for user key or mouse action. *)
Function User_Interrupt : Boolean;
var Status : Boolean;
Begin
   Status := KeyPressed Or MousePressed;
   if (not Status)
      then Update_Idle;   (* update clock *)
   User_Interrupt := Status;
End;

(* Ask user a question with a Yes or No answer. *)
Function Ask_User (S : string) : boolean;
var Answer : word;
Begin
   Answer := MessageBox (S, Nil, mfWarning + mfYesbutton + mfNobutton);
   if (Answer = cmYes)
      then Ask_User := TRUE
      else Ask_User := FALSE;
End;

(* Notify user with a message. *)
Procedure Notify_User (S : string);
Begin
   MessageBox (S, Nil, mfWarning + mfOkbutton);
End;

(* Prompt user with Save File dialog (used in MAINIO). *)
Procedure Save_File_Dialog;
Begin
   USERAUX.Save_File_Dialog;
End;

End.
