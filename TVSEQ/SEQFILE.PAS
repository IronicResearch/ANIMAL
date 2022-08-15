(* ThingM Script File processing. *)

Unit SEQFILE;

Interface

Uses
   THINGM,              (* ThingM driver *)
   GLOBAL,              (* Sequencer vars *)
   SEQIO;               (* Sequencer functions *)

Const
   ScriptMAX = 100;                     (* max number of script strings *)

Var
   ScriptNum : integer;                 (* index to string in ScriptBuf[] *)
   ScriptBuf : array [1..ScriptMAX] of string[80];

Type ScriptCmd =
   (NUL,CAM,PRJ,SEQ,CTR,FRM,OUT,EXP,LPS,SPD,RMP,ALT,STP,SKP);

Var
   Sequencer_Overide : boolean;         (* sequencer or cam/proj ? *)
   Absolute_Counting : boolean;         (* out-frame counting ? *)
   Projector_Counting : boolean;        (* camera or projector ? *)

Procedure Save_Script_File (FileName : string);
Procedure Load_Script_File (FileName : string);
Procedure Init_Write_Script;
Procedure Write_Script_Line(S : string);
Procedure Write_Script_Counters(C, P : integer);
Procedure Write_Script_Camera(F : integer);
Procedure Write_Script_Projector(F : integer);
Procedure Write_Script_Sequencer(F, C, P : integer; M : integer);
Procedure Execute_Script;

Implementation

(* file IO in text mode. *)
Procedure Save_Script_File (FileName : string);
Var I : integer;
    F : Text;
Begin
   {$I-}
   Assign(F, FileName);
   Rewrite(F);
   Writeln(F, 'ThingM Sequencer Script (ver 1.0)');
   Writeln(F);
   if (ScriptNum > 0) then
   for I := 1 to ScriptNum do
       begin
       Write(F, ScriptBuf[I]);
       Writeln(F);
       end;
   Writeln(F);
   Close(F);
   {$I+}
   if (IOResult <> 0)
      then Exit;
End;

Procedure Load_Script_File (FileName : string);
Var I : integer;
    F : Text;
Begin
   {$I-}
   Assign(F, FileName);
   Reset(F);
   Readln(F);
   Readln(F);
   I := 0;
   while (NOT EOF(F)) do
       begin
       Inc(I);
       if (I > ScriptMAX)
          then break;
       Readln(F, ScriptBuf[I]);
       end;
   ScriptNum := I;
   Close(F);
   {$I+}
   if (IOResult <> 0)
      then Exit;
End;

(* Write script for file saving. *)
Procedure Init_Write_Script;
Begin
   ScriptNum := 0;      (* for pre-incrementing *)
End;

Procedure Write_Script_Line(S : string);
Begin
   if (ScriptNum < ScriptMAX)
      then Inc(ScriptNum);
   ScriptBuf[ScriptNum] := S;
End;

Procedure Write_Script_Counters(C, P : integer);
var S : string;
Begin
   Str(C:10,S);
   Write_Script_Line('CAM    CTR ' + S);
   Str(P:10,S);
   Write_Script_Line('PRJ    CTR ' + S);
End;

Procedure Write_Script_Camera(F : integer);
var S : string;
Begin
   Str(F:10,S);
   Write_Script_Line('CAM    FRM ' + S);
End;

Procedure Write_Script_Projector(F : integer);
var S : string;
Begin
   Str(F:10,S);
   Write_Script_Line('PRJ    FRM ' + S);
End;

Procedure Write_Script_Sequencer(F, C, P : integer; M : integer);
var S, S1, S2 : string;
Begin
   Str(C:10,S1);
   Str(P:10,S2);
   case (Sequencer_Mode(M)) of
        Alternate :     S := 'ALT ';
        StepCamera :    S := 'STP ';
        SkipProjector : S := 'SKP ';
        else            S := 'ALT ';
        end;
   Write_Script_Line('SEQ    ' + S + S1 + S2);
   Str(F:10,S);
   Write_Script_Line('PRJ    FRM ' + S);
End;

(* Read script for processing. *)
Procedure Execute_Script;
var I : integer;
    Linestr : string[40];               (* copy of script line *)
    Prestr : string[3];                 (* prefix *)
    Cmdstr : string[3];                 (* command *)
    Datastr : string[10];               (* data *)
    Datastr2 : string[10];              (* data *)
    IData : integer;
    IData2 : integer;
    RData : real;
    Error : integer;
    CmdId : ScriptCmd;
    PreId : ScriptCmd;
Begin
   for I := 1 to ScriptNum do
       begin
       (* scan string fields for each line *)
       Linestr := '';
       Linestr := Copy(ScriptBuf[I],1,40);
       if (Length(Linestr) = 0)
          then continue;                (* empty line *)
       if (Pos('*',Linestr) = 1)
          then continue;                (* comments *)
       while (Pos(' ',Linestr) = 1) do
             Delete(Linestr,1,1);       (* blanks *)
       Prestr := '';
       Prestr := Copy(Linestr,1,3);     (* prefix *)
       Delete(Linestr,1,3);
       while (Pos(' ',Linestr) = 1) do
             Delete(Linestr,1,1);       (* blanks *)
       Cmdstr := '';
       Cmdstr := Copy(Linestr,1,3);     (* command *)
       Delete(Linestr,1,3);
       while (Pos(' ',Linestr) = 1) do
             Delete(Linestr,1,1);       (* blanks *)
       Datastr := '';
       Datastr := Copy(Linestr,1,10);   (* data *)
       while (Pos(' ',Linestr) > 1) AND (Length(Linestr) > 0) do
             Delete(Linestr,1,1);       (* non-blanks *)
       while (Pos(' ',Linestr) = 1) AND (Length(Linestr) > 0) do
             Delete(Linestr,1,1);       (* blanks *)
       Datastr2 := '';
       Datastr2 := Copy(Linestr,1,10);  (* data field #2 *)
       (* interpret field strings *)
       PreId := NUL;
       if (Pos('CAM',Prestr) <> 0)
          then PreId := CAM else
       if (Pos('PRJ',Prestr) <> 0)
          then PreId := PRJ else
       if (Pos('SEQ',Prestr) <> 0)
          then PreId := SEQ;
       CmdId := NUL;
       if (Pos('CTR',Cmdstr) <> 0)
          then CmdId := CTR else
       if (Pos('FRM',Cmdstr) <> 0)
          then CmdId := FRM else
       if (Pos('OUT',Cmdstr) <> 0)
          then CmdId := OUT else
       if (Pos('ALT',Cmdstr) <> 0)
          then CmdId := ALT else
       if (Pos('STP',Cmdstr) <> 0)
          then CmdId := STP else
       if (Pos('SKP',Cmdstr) <> 0)
          then CmdId := SKP;
       IData := 0; IData2 := 0;
       RData := 0.0;
       case (CmdId) of
            FRM ,
            OUT ,
            CTR : Val(Datastr, IData, Error);
            EXP ,
            LPS ,
            SPD ,
            RMP : Val(Datastr, RData, Error);
            ALT ,
            STP ,
            SKP : begin
                  Val(Datastr, IData, Error);
                  if (Error > 0)
                     then begin
                     Delete(Datastr,Error,Length(Datastr));
                     Val(Datastr, IData, Error);
                     end;
                  Val(Datastr2, IData2, Error);
                  end;
            end;
       (* execute ThingM overide commands *)
       case (CmdId) of
            CTR : THINGM_Counter(IData);
            EXP : THINGM_ExposureTime(RData);
            LPS : THINGM_LapseTime(RData);
            SPD : THINGM_Speed(RData);
            RMP : THINGM_Ramp(RData);
            end;
       (* setup TV-Sequencer data *)
       case (PreId) of
            CAM : Projector_Counting := FALSE;
            PRJ : Projector_Counting := TRUE;
            SEQ : Sequencer_Overide := TRUE;
            end;
       case (CmdId) of
            FRM : Absolute_Counting := FALSE;
            OUT : Absolute_Counting := TRUE;
            end;
       case (CmdId) of
            CTR : begin
                  if (Projector_Counting)
                     then Projector_Total := IData
                     else Camera_Total := IData;
                  end;
            FRM : begin
                  Frame_Count := IData;
                  if (NOT Sequencer_Overide)
                     then if (Projector_Counting)
                          then Projector_Count := Frame_Count
                          else Camera_Count := Frame_Count
                     else Sequencer_Count := Frame_Count;
                  end;
            OUT : begin
                  if (Absolute_Counting)
                     then if (Projector_Counting)
                          then Frame_Count := IData - Projector_Total
                          else Frame_Count := IData - Camera_Total
                     else Frame_Count := IData;
                  if (NOT Sequencer_Overide)
                     then if (Projector_Counting)
                          then Projector_Count := Frame_Count
                          else Camera_Count := Frame_Count
                     else Sequencer_Count := Frame_Count;
                  end;
            ALT : begin
                  Sequencer := Alternate;
                  Camera_Cycle := IData;
                  Projector_Cycle := IData2;
                  end;
            STP : begin
                  Sequencer := StepCamera;
                  Camera_Cycle := IData;
                  Projector_Cycle := IData2;
                  end;
            SKP : begin
                  Sequencer := SkipProjector;
                  Camera_Cycle := IData;
                  Projector_Cycle := IData2;
                  end;
            end;
       (* execute TV-Sequencer operations *)
       case (CmdId) of
            CTR : Do_Frame_Counts;
            OUT ,
            FRM : begin
                  if (Sequencer_Overide)
                     then begin
                          Do_Sequencer;
                          Sequencer_Overide := FALSE;
                          end
                     else if (Projector_Counting)
                          then Do_Projector
                          else Do_Camera;
                  end;
            end;
       end;
End;

(* Initialization *)

Var I : integer;

Begin

   ScriptNum := 0;
   for I := 1 to ScriptMAX do
       ScriptBuf[I] := '';

   Sequencer_Overide := FALSE;
   Absolute_Counting := FALSE;
   Projector_Counting := FALSE;

End.
