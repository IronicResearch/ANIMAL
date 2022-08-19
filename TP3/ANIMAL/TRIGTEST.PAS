
(* Test for trigger output from IBM parallel port. *)

PROGRAM TRIGGER_TEST;

CONST PIO = $0378;     (* IBM Parallel Port 1 *)
      ON  = $01;
      OFF = $00;

VAR CH : CHAR;
    CODE : BYTE;
    TIME : INTEGER;
    WAIT : INTEGER;
    COUNT : INTEGER;
    I : INTEGER;

(* OUTPIO outputs a byte to the parallel interface port. *)

PROCEDURE OUTPIO (VAR B : BYTE);

BEGIN

   PORTW [PIO] := B;

END;

(* TRIGGER outputs a single trigger pulse (1 cycle). *)

PROCEDURE TRIGGER;

BEGIN

   CODE := ON;
   OUTPIO (CODE);
   DELAY (TIME);

   CODE := OFF;
   OUTPIO (CODE);
   DELAY (WAIT);

END;

PROCEDURE TRIGGER_MENU;

BEGIN

   WRITELN ('Trigger Menu:');
   WRITELN;
   WRITELN ('   0 : 0 --> Off...');
   WRITELN ('   1 : 1 --> On...');
   WRITELN ('   T : Trigger Time = ');
   WRITELN ('   L : Lapse Time = ');
   WRITELN ('   P : Pulse...');
   WRITELN ('   F : Frame Count = ');
   WRITELN ('   C : Continuous...');
   WRITELN ('   Q : Quit...');
   WRITELN;

END;

BEGIN

WRITELN;
WRITELN ('Trigger Output Test...');
WRITELN;

TIME := 100;
WAIT := 1000;
CODE := OFF;
OUTPIO (CODE);

TRIGGER_MENU;

REPEAT

   READ (KBD, CH);

   CASE CH OF

        '0' : BEGIN
              WRITE ('0 --> Off...');
              CODE := OFF;
              OUTPIO (CODE);
              WRITELN;
              END;

        '1' : BEGIN
              WRITE ('1 --> On...');
              CODE := ON;
              OUTPIO (CODE);
              WRITELN;
              END;

        'T' : BEGIN
              WRITE ('Trigger Time = ');
              READLN (TIME);
              END;

        'L' : BEGIN
              WRITE ('Lapse Time = ');
              READLN (WAIT);
              END;

        'P' : BEGIN
              WRITE ('Pulse...');
              TRIGGER;
              WRITELN;
              END;

        'F' : BEGIN
              WRITE ('Frame Count = ');
              READ (COUNT);
              FOR I := 1 TO COUNT DO
                  TRIGGER;
              WRITELN;
              END;

        'C' : BEGIN
              WRITE ('Continuous...');
              REPEAT
                 TRIGGER;
              UNTIL KEYPRESSED;
              WRITELN;
              END;

        '?' : TRIGGER_MENU;

        'Q' : WRITE ('Quit...');

        ELSE  WRITELN (CH);
        END;

UNTIL CH = 'Q';

CODE := OFF;
OUTPIO (CODE);

WRITELN;
WRITELN;

END.

