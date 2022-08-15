
(* Motion Control Interface *)

Unit MCPU;

Interface

Uses
    Dos,                (* for GetTime *)
    TIMEX,              (* for ThisTime *)
    SIO;                (* Serial IO *)

Const MCPU_PortX : integer = 2;          (* default COM port *)

Procedure OutCmd (Byte : char);
Procedure OutCmdStr (S : string);
Procedure OutStr (Var S : string);
Procedure InStr (Var S : string);
Procedure InStrX (Var S : string; N : integer);

(************)

Implementation

(* Output a command byte. (pass by value) *)
Procedure OutCmd (Byte : char);
Begin
   OutSio (Byte);
End;

(* Output a command string. (pass by value) *)
Procedure OutCmdStr (S : string);
var i : integer;
Begin
   for i := 1 to Length(S) do
       OutSio (S[i]);
End;

(* Output a command string. (pass by reference) *)
Procedure OutStr (Var S : string);
var i : integer;
Begin
   for i := 1 to Length(S) do
       OutSio (S[i]);
End;

(* Input a response string, with terminator character. *)
Procedure InStr (Var S : string);
const TIMEOUT_DELAY = 100;              (* for 1 sec *)
var i : integer;
    ch : char;
    status : boolean;
    time, timeout : longint;
Begin
   S := '';
   i := 1;
   timeout := ThisTime + TIMEOUT_DELAY;
   repeat
      InSioSt(status);
      if (status)
         then begin
         InSio(ch);
         S[i] := ch;
         S[0] := char(i);
         Inc(i);
         end;
      time := ThisTime;
   until (ch = ^M) OR (time >= timeout);
End;

(* Input a response string, in series of so many characters. *)
Procedure InStrX (Var S : string; N : integer);
const TIMEOUT_DELAY = 100;              (* for 1 sec *)
var i : integer;
    ch : char;
    status : boolean;
    time, timeout : longint;
Begin
   if (N < 1)
      then Exit;
   S := '';
   i := 1;
   timeout := ThisTime + TIMEOUT_DELAY;
   repeat
      InSioSt(status);
      if (status)
         then begin
         InSio(ch);
         S[i] := ch;
         S[0] := char (i);
         Inc(i);
         end;
      time := ThisTime;
   until (i > N) OR (time >= timeout);
End;

(* Initialization *)

Begin

End.





