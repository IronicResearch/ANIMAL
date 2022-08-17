
(* General Terminal Interface *)

Unit TERMIO;

Interface

Uses TpCrt;     (* Turbo Pro library preferred *)

Procedure SetTermio (Portx : integer);
Procedure ResetTermio;
Procedure InTermioSt (Var Status : boolean);
Procedure InTermio (Var Byte : char);
Procedure OutTermioSt (Var Status : boolean);
Procedure OutTermio (Byte : char);
Procedure ExecTermio (Portx : integer);

(************)

Implementation

{$I SIOX.LIB}     (* privately recycled serial routines *)

Procedure SetTermio (Portx : integer);
Begin
   SetSio (Portx);
End;

Procedure ResetTermio;
Begin
   ResetSio;
End;

Procedure InTermioSt (Var Status : boolean);
Begin
   InSioSt (Status);
End;

Procedure InTermio (Var Byte : char);
Begin
   InSio (Byte);
End;

Procedure OutTermioSt (Var Status : boolean);
Begin
   OutSioSt (Status);
End;

Procedure OutTermio (Byte : char);
Begin
   OutSio (Byte);
End;

Procedure ExecTermio (Portx : integer);

Const
   QUIT = #$1B;

Var
   siostatus : boolean;
   ch : char;

Begin

   Writeln('Terminal Interface for COM', Portx);
   SetSio(Portx);
   ResetSio;
   Writeln;
   Repeat
      Repeat
         InSioSt(SioStatus);
      Until SioStatus OR KeyPressed;
      If SioStatus
         Then begin
            InSio (ch);
            Write (ch);
            If ch = ^M
               Then Writeln;
            end;
      If KeyPressed
         Then begin
              ch := ReadKey;
              OutSio (ch);
              Write (ch);
              If ch = ^M
                 Then Writeln;
              end;
   Until ch = QUIT;
   Writeln;

End;

End.





