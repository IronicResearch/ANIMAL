(* Test Communications Terminal. *)

Program Test_Terminal;

Uses
    TPCRT,              (* TurboPro console extensions *)
    (* TERMIO,             (* Terminal IO emulator *)
    SIO;                (* Serial IO *)

Const
    Portx : integer = 2;        (* default COM port *)

Var
    CmdParm : integer;          (* command line parameter *)
    Error : integer;

Var
    Ch : char;
    SioStat : boolean;

Begin

    (* read command line for overiding COM port assignment *)
    if (ParamCount >= 1)
       then Val(ParamStr(1), CmdParm, Error);
    if (CmdParm IN [1..4])
       then Portx := CmdParm;
    Writeln ('Terminal Test for COM', Portx);
    Writeln ('Press ESCAPE key to exit.');

    TextColor(Green);
    BlockCursor;

    (* ExecTermio(Portx); *)
    SetSio(Portx);
    ResetSio;
    repeat
       repeat
          InSioSt(SioStat);
       until (SioStat or KeyPressed);
       if (SioStat)
          then InSio(Ch);
       if (KeyPressed)
          then begin
               Ch := ReadKey;
               OutSio(Ch);
               end;
       Write(Ch);
       if (Ch = ^M)
          then Writeln;
    until (Ch = ^[);
    Writeln;

    NormalCursor;
    NormVideo;
    Writeln('Exit Terminal mode.');

End.
