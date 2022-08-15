
(* Test Drive MCPU. *)
(* Use STD bus MCPU. *)

Program Test_Drive;

Uses

   TpCrt,
   Keybd;

Const

   FWD = True;
   REV = False;

Type

   MOTOR_TABLE = RECORD
          MOTORNO : INTEGER;
          STEPCNT : REAL;
          DIR : BOOLEAN;
          SPEED : INTEGER;
          ACCELST : BOOLEAN;
          HIGHSPD : INTEGER;
          LOWSPD : INTEGER;
          RAMPCNT : INTEGER;
          RAMPK : INTEGER;

          COUNT : REAL;
          STAT : CHAR;
          ERROR : BOOLEAN;
          RUNCNT : REAL;
          COMPUMTR_2100 : BOOLEAN;
          END;

Var

   Ch : Char;
   M  : Motor_Table;

{$I SIO86-2.LIB}
{$I MCPUCOMM.STD}
{$I MCPUXSTD.LIB}
{$I MCPUMSTD.LIB}

Procedure Kill_Motor;

Begin

   Write ('Kill Motor # ');
   RdlnInt (M.MotorNo);
   KillM (M);

End;

Procedure Init_Motor;

Begin

   Write ('Initialize Motor # ');
   RdlnInt (M.MotorNo);
   M.AccelSt := True;
   Write ('Low Speed  = ');
   RdlnInt (M.LowSpd);
   Write ('High Speed = ');
   RdlnInt (M.HighSpd);
   Write ('Ramp Count = ');
   RdlnInt (M.RampCnt);
   M.RampK := 0;
   M.Compumtr_2100 := True;
   InitM (M);

End;

Procedure Run_Motor;

Begin

   Write ('Run Motor # ');
   RdlnInt (M.MotorNo);
   Write ('Step Count = ');
   RdlnReal (M.StepCnt);
   M.Compumtr_2100 := True;
   PrepM (M);
   RunM  (M);

End;

Procedure Status_Motor;

Begin

   Write ('Status for Motor # ');
   RdInt (M.MotorNo);
   M.Compumtr_2100 := True;
   GetStat (M);
   Writeln ('...', M.Stat);

End;

Procedure Position_Motor;

Begin

   Write ('Position for Motor # ');
   RdInt (M.MotorNo);
   M.Compumtr_2100 := True;
   GetCount (M);
   Writeln ('...', M.Count);

End;

Procedure Help_Menu;
Begin
   Writeln;
   Writeln('I : Init');
   Writeln('R : Run');
   Writeln('K : Kill');
   Writeln('S : Status');
   Writeln('P : Position');
   Writeln;
End;

Begin

   Writeln ('Test Drive MCPU...', ^M);
   Writeln ('STD bus MCPU for COM2', ^J);
   ResetSio;
   Init_Mcpu;
   Reset_Mcpu;
   Help_Menu;
   Repeat
      Write ('MCPU Command > ');
      RdKey (Ch);
      Case Ch Of
           'K' : Kill_Motor;
           'I' : Init_Motor;
           'R' : Run_Motor;
           'S' : Status_Motor;
           'P' : Position_Motor;
           '?' : Help_Menu;
           Else  Writeln;
           end;
   Until Ch = 'Q';
   Writeln;

End.
