
(* Keyboard input routines. *)

Unit KEYBD;

Interface

Uses TPCrt;
     (* TPMouse; *)

(* KEYBD.LIB *)

PROCEDURE RDKEYST (VAR KEYSTAT : BOOLEAN);

PROCEDURE RDKEY (VAR KEY : CHAR);

PROCEDURE RDCON (VAR CH : CHAR);

PROCEDURE WRCON (VAR CH : CHAR);

PROCEDURE CLRKEY;

FUNCTION SCROLL_KEYED : BOOLEAN;

PROCEDURE RDREAL (VAR R : REAL);

PROCEDURE RDLNREAL (VAR R : REAL);

PROCEDURE RDINT (VAR I : INTEGER);

PROCEDURE RDLNINT (VAR I : INTEGER);

Procedure RdlnStr (Var S : String);

Implementation

Const MouseKeyWord = 0;
      MouseLft = 0;
      MouseRt  = 0;
      MouseBoth = 0;

Function MouseInstalled : Boolean;
Begin
   MouseInstalled := False;
End;

Function MousePressed : Boolean;
Begin
   MousePressed := False;
End;

Procedure EnableEventHandling;
Begin
End;

{$I KEYBD.LIB}

End.

