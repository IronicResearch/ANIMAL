(* ThingM Communications Terminal. *)

Program ThingM_Terminal;

Uses
    TPCRT,              (* TurboPro console extensions *)
    TERMIO;             (* Terminal IO emulator *)

Const
    Portx : integer = 2;        (* default COM port *)

Var
    CmdParm : integer;          (* command line parameter *)
    Error : integer;

Procedure ThingM_Help;
Begin
    Writeln;
    Writeln ('[ P ] Program       [   ENTER   ] Enter');
    Writeln ('[ R ] Run/Stop      [ BACKSPACE ] Clear');
    Writeln;
    Writeln ('[ 1 ] Camera        [ 2 ] Projector   [ 3 ] Projector');
    Writeln ('[ 4 ] Frame Count   [ 5 ] Counter     [ 6 ] End Frame');
    Writeln ('[ 7 ] Step Camera   [ 8 ] Alternate   [ 9 ] Skip Proj');
    Writeln ('[ - ] Direction     [ 0 ] Sequencer   [ . ] Internal');
    Writeln;
End;

Begin

    (* read command line for overiding COM port assignment *)
    if (ParamCount >= 1)
       then Val(ParamStr(1), CmdParm, Error);
    if (CmdParm IN [1..4])
       then Portx := CmdParm;
    Writeln ('ThingM Terminal for COM', Portx);
    Writeln ('Press ESCAPE key to exit.');

    TextColor(Red);
    ThingM_Help;

    TextColor(Green);
    BlockCursor;
    ExecTermio(Portx);

    NormalCursor;
    NormVideo;
    Writeln('Exit Terminal mode.');

End.
