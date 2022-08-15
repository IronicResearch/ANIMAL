(* The Dreaded Triggers... *)
(* Output selectable on a parallel port near you. *)

Unit TRIGIO;

Interface

Uses  TPCRT,
      GLOBAL;

Const LPT1 = $03BC;               (* IBM parallel ports *)
      LPT2 = $0378;
      LPT3 = $0278;

Const TRG_PortX : integer = 2;         (* selected port # *)
Const Trigger_Port : integer = LPT2;   (* selected port address *)

Procedure OutTrigger (B : byte);
Procedure Init_Trigger;
Procedure Trigger_Pulse (The_Trigger : Trigger_Table);

Implementation

(* OutTrigger outputs a byte to the trigger port. *)
Procedure OutTrigger (B : byte);
Begin
    Port[Trigger_Port] := B;
End;

(* Initializes Trigger port in case of system reset. *)
Procedure Init_Trigger;
Begin
   (* in case of port re-assignment *)
   Case TRG_PortX of
        1 : Trigger_Port := LPT1;
        2 : Trigger_Port := LPT2;
        3 : Trigger_Port := LPT3;
        end;
   (* init trigger port output *)
   OutTrigger($FF);     (* for active low triggers *)
End;

(* Trigger_Pulse fires a timed trigger pulse out the trigger port. *)
Procedure Trigger_Pulse (The_Trigger : Trigger_Table);

Var Trigger_Byte : Byte;
    Trigger_Time : Integer;
    Trigger_Line : Integer;

Begin

If The_Trigger.Spec
   Then begin
{$IFDEF TRIGGER1_ONLY}
   Trigger_Byte := The_Trigger.Trig[1];
{$ELSE}
   Trigger_Byte := $00;
   For Trigger_Line := 1 to 8 Do
       Trigger_Byte := Trigger_Byte OR The_Trigger.Trig[Trigger_Line];
{$ENDIF}
   OutTrigger(Trigger_Byte);
   Trigger_Time := The_Trigger.Time[1];
   Delay (Trigger_Time);

{$IFDEF TRIGGER1_ONLY}
   Trigger_Byte := The_Trigger.Null[1];
{$ELSE}
   Trigger_Byte := $00;
   For Trigger_Line := 1 to 8 Do
       Trigger_Byte := Trigger_Byte OR The_Trigger.Null[Trigger_Line];
{$ENDIF}
   OutTrigger(Trigger_Byte);
   Trigger_Time := The_Trigger.Wait[1];
   Delay (Trigger_Time);
   end;

End;

(* Initialization *)

Var E : integer;
Begin

   (* 3rd command line parameter selects Trigger parallel port *)
   If ParamCount >= 3
      Then Val (ParamStr(3), TRG_PortX, E);

   Case TRG_PortX of
        1 : Trigger_Port := LPT1;
        2 : Trigger_Port := LPT2;
        3 : Trigger_Port := LPT3;
        end;

   Init_Trigger;

End.




