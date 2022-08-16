
(* Console interface for simple interaction with user. *)

Unit CONIO;

{$I SWITCHES.INC}               (* compiler switches *)

Interface

Uses

{$IFDEF USE_TURBO_VISION}
        Objects,                (* Turbo Vision Object Library *)
        Drivers,                (* TV interface drivers *)
        Views,                  (* TV view screens *)
        MsgBox,                 (* TV message boxes *)
{$ELSE}
        TpMouse,                (* TurboPro Mouse library *)
{$ENDIF}
        TpCrt;                  (* TurboPro CRT console extensions *)

Function MousePressed : Boolean;

Function User_Interrupt : Boolean;

Procedure Get_Trigger (Var Status : boolean);

Function Ask_User (S : string) : boolean;

Function Ask_User3 (S : string) : integer;

Procedure Notify_User (S : string);

Implementation

{$IFDEF USE_TURBO_VISION}
(* MousePressed detection adapted to Turbo Vision Drivers unit *)
Function MousePressed : Boolean;
Begin
   MousePressed := (MouseButtons AND (mbLeftButton + mbRightButton) <> 0);
End;
{$ELSE}
(* MousePressed detected from TurboPro Mouse library. *)
Function MousePressed : Boolean;
Begin
   MousePressed := TPMOUSE.MousePressed;
End;
{$ENDIF}

(* User_Interruption loops for user key or mouse action. *)
Function User_Interrupt : Boolean;
Begin
   User_Interrupt := KeyPressed OR MousePressed;
End;

(* Get status of external trigger signal. *)
(* (Typically connected to one of PC printer ports.) *)
Procedure Get_Trigger (Var Status : boolean);
Begin
   Status := FALSE;
End;

(* Ask user a question with a Yes or No answer. *)
Function Ask_User (S : string) : boolean;
{$IFDEF USE_TURBO_VISION}
var Answer : word;
Begin
   Answer := MessageBox (S, Nil, mfWarning + mfYesbutton + mfNobutton);
   if (Answer = cmYes)
      then Ask_User := TRUE
      else Ask_User := FALSE;
End;
{$ELSE}
var Answer : char;
Begin
   Write(S);
   Write(' (Yes/No) ');
   Readln(Answer);
   if (UpCase(Answer) = 'Y')
      then Ask_User := TRUE
      else Ask_User := FALSE;
End;
{$ENDIF}

(* Ask user a 3-state question with a Yes, No, or Cancel answer. *)
Function Ask_User3 (S : string) : integer;
{$IFDEF USE_TURBO_VISION}
var Answer : word;
Begin
   Answer := MessageBox (S, Nil, mfWarning + mfYesbutton + mfNobutton + mfCancelbutton);
   case (Answer) of
        cmYes    : Ask_User3 := 1;
        cmNo     : Ask_User3 := 0;
        cmCancel : Ask_User3 := -1;
        else       Ask_User3 := -1;
        end;
End;
{$ELSE}
var Answer : char;
Begin
   Write(S);
   Write(' (Yes/No/Cancel) ');
   Readln(Answer);
   case (UpCase(Answer)) of
        'Y' : Ask_User3 := 1;
        'N' : Ask_User3 := 0;
        else  Ask_User3 := -1;
        end;
End;
{$ENDIF}

(* Notify user with a message. *)
Procedure Notify_User (S : string);
Begin
{$IFDEF USE_TURBO_VISION}
   MessageBox (S, Nil, mfWarning + mfOkbutton);
{$ELSE}
   Write(S);
   Write(' (Press any Key) ');
   Readln;
{$ENDIF}
End;


(* Initialization *)

Begin

End.
