
(* User Interface Wrapper to USERMAIN AniApp object. *)

Unit USERWRAP;

{$I SWITCHES.INC}          (* compiler switches *)

Interface

Uses USERMAIN;             (* AniApp object *)

Function  Index : Integer;
Procedure Init;
Procedure Run;
Procedure Done;
Procedure Idle;
Procedure SaveDialog;
Procedure FileOpen (Var FileName : String);
Procedure ViewFile (Var FileName : String);
Procedure OverJogDialog;
Procedure Load_File_Dialog;
Procedure Save_File_Dialog;

(******************************)

Implementation

Function Index : Integer;
Begin
  Index := USERMAIN.Index;
End;

Procedure Init;
Begin
  AniApp.Init;
End;

Procedure Run;
Begin
  AniApp.Run;
End;

Procedure Done;
Begin
  AniApp.Done;
End;

Procedure Idle;
Begin
   AniApp.Idle;
End;

Procedure SaveDialog;
Begin
  AniApp.SaveDialog;
End;

Procedure FileOpen(Var FileName : String);
Begin
  AniApp.FileOpen (FileName);
End;

Procedure ViewFile(Var FileName : String);
Begin
  AniApp.ViewFile (FileName);
End;

Procedure OverJogDialog;
Begin
  AniApp.OverJogDialog;
End;

Procedure Load_File_Dialog;
Begin
  USERMAIN.Load_File_Dialog;
End;

Procedure Save_File_Dialog;
Begin
  USERMAIN.Save_File_Dialog;
End;

End.
