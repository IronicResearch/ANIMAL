(* Test program for Sequencer file execution on ThingM. *)
Program Test_Sequencer;

(* USE_TURBO_VISION flag should be UNDEFined in SWITCHES.INC file
(* for text-based console operation. *)

{$I SWITCHES.INC}       (* compiler switches *)

Uses
    TPCRT,              (* TurboPro console extensions *)
    SIO,                (* Serial interface *)
    THINGM,             (* ThingM driver *)
    GLOBAL,             (* Sequencer vars *)
    SEQIO,              (* Sequencer functions *)
    SEQFILE;            (* Sequencer file *)

Const
    Portx : integer = 2;        (* default COM port *)

Var
    CmdParm : integer;          (* command line parameter *)
    Error : integer;

    FileName : string;          (* sequencer file name *)

Begin

    FileName := '';

    (* read command line for sequencer file name *)
    if (ParamCount >= 1)
       then FileName := ParamStr(1);
    (* read command line for overiding COM port assignment *)
    if (ParamCount >= 2)
       then Val(ParamStr(2), CmdParm, Error);
    if (CmdParm IN [1..4])
       then Portx := CmdParm;
    Writeln ('ThingM Sequencer for COM', Portx);

    (* select serial COM port *)
    SetSio(Portx);
    (* init serial interface *)
    ResetSio;

    (* if no command line file name, prompt user for it *)
    if (FileName = '')
       then begin
       Write('Sequencer File Name = ');
       Readln(FileName);
       end;
    Writeln('Running Sequencer File ', FileName);

    (* turn tracer messages on to text-based console *)
    SEQIO.Tracered := TRUE;

    (* load sequencer file *)
    Load_Script_File(FileName);

    (* run sequencer file *)
    Execute_Script;

End.
