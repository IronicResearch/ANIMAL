
(* IBM Turbo Pascal compatible console routines. *)

Unit TurboCrt (100);

{$U-}

Interface

Uses

    PasInOut,
    PasConsole;

Function ReadKey : Char;

Procedure ClrScr;

Procedure TPDelay (DelayTime : LongInt);

Function UpCase (ch : char): char; 
{ Returns the upper case equivalent of ch } 
inline 
   $301F, { UpCase MOVE.W (SP)+,D0 ; GetCh }
   $0C40,
   $0061, { CMP.W #'a',D0 ; skip if not lower case }
   $6D0A, { BLT.S @1 }
   $0C40,
   $007A, { CMP.W #'z',D0 }
   $6E04, { BGT.S @1 }
   $0440, 
   $0020, { SUB.W #$20,D0 }
   $3E80; { @1 MOVE.W D0,(SP) }

Implementation

(* IBM Turbo Pascal 'ReadKey' function. *)

Function ReadKey { : Char };

Begin

   ReadKey := ReadChar;
   
End;

(* IBM Turbo Pascal 'ClrScr' procedure. *)

Procedure ClrScr;

Begin

   ClearScreen;
   
End;

(* IBM Turbo Pascal 'Delay' procedure. *)

Procedure TPDelay { (DelayTime : LongInt) };
{ Delays DelayTime # of milliseconds }

procedure DelayIt(ticks: Longint); inline $205F,$A03B;

begin { Delay }
  DelayTime := DelayTime div 17;
  if DelayTime > 0 then
    DelayIt(DelayTime);
end; { Delay }

(* IBM Turbo Pascal 'UpCase' function. *)
(* inline code already in interface section. *)

(*****)
    
End.
