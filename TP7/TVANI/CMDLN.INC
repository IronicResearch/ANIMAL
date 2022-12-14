(* Create custom command line support: *)
Type
  CharBuf = array [1..128] of char;
Var
  CmdLine : ^CharBuf;                   (* command line pointer *)
  CmdParm : integer;                    (* command parameter code *)

(* Get command line string from MS-DOS PSP buffer. *)
Procedure Get_Command_Line;
Var
   regs : Registers;
Begin
   regs.AH := $62;                       (* get MS-DOS PSP *)
   intr($21,regs);
   CmdLine := Ptr(regs.BX,$0082);        (* DTA address, xxxx:0080 *)
End;

(* Parse command line string. *)
Procedure Parse_Command_Line;
Begin
   If CmdLine <> NIL
      Then begin
           Case CmdLine^[1] of          (* first letter only *)
           '1' : CmdParm := 1;
           '2' : CmdParm := 2;
           '3' : CmdParm := 3;
           '4' : CmdParm := 4;
           end;
           end;
End;

