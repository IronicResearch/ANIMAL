
(* Test Drive MCPU. *)
(* Use Compumotor PC23 MCPU. *)

Program Test_Drive;

Uses

   TpCrt,
   Keybd,
   Dos;

Const

   FWD = True;
   REV = False;

(* Constants for Compumotor MCPU. *)

      STEPS_PER_REV = 1000.0;           (* steps per revolution *)

      MIN_STEPS = 1.0;                  (* steps *)
      MAX_STEPS = 999999.0;

      MIN_REVS  = 0.001;                (* revolutions *)
      MAX_REVS  = 999.999;

      MIN_SPEED = 0.001;                (* revolutions per second *)
      MAX_SPEED = 20.000;

      MIN_ACCEL = 0.1;                  (* revolutions per second per second *)
      MAX_ACCEL = 590.0;

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

{$I PIOSIO2.LIB}    (* PC bus PIO + COM2 SIO *)
{$I MCPUCOMM.LIB}
{$I MCPUX23.LIB}
{$I MCPUM23.LIB}

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
   Writeln ('Compumotor PC23 + 2100 for COM2', ^J);
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
