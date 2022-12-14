
(* File Interface *)

Unit FILEIO;

Interface

Uses

     TPCrt,                (* TurboPro input/output *)
     KEYBD,                (* Keyboard input filters *)
     GLOBAL,               (* Animal Global declarations *)
     GLOBAL2;

Procedure Save_Axis_File;

Procedure Load_Axis_File;

Procedure Save_Units_File;

Procedure Load_Units_File;

Procedure Save_Speed_File;

Procedure Load_Speed_File;

Procedure Save_Alignment_File;

Procedure Load_Alignment_File;

Procedure Save_Trigger_File;

Procedure Load_Trigger_File;

PROCEDURE CONVERT_ASCII;

PROCEDURE CONVERT_BINARY;

Procedure Save_Text_File (AscName : String; Var Save_Ok : Boolean);

Procedure Load_Text_File (AscName : String; Var Load_Ok : Boolean);

Implementation

(* Animal Editing routines. *)

(* {$I EDITCTR.EXT}        (* save/load total plot points *)
{$I EDITKEY.EXT}        (* save/load key frames only *)
{$I EDITOLD.EXT}        (* save/load utility files *)

End.
