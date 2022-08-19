
(* Test for trigger output from IBM parallel port. *)

PROGRAM TRIGGER_TEST;

CONST PIOL = $0378;     (* IBM Parallel Port 1 *)
      PIOH = $03BC;

TYPE BYTE = 0..255;

     TRIGGER_TABLE = RECORD
        SPEC : BOOLEAN;
        TRIG : BYTE;
        NULL : BYTE;
        TIME : INTEGER;
        WAIT : INTEGER;
        END;

VAR CH : CHAR;
    I : INTEGER;
    TRIGGER : ARRAY [1..4] OF TRIGGER_TABLE;

{$I KEYBD.LIB}

(* OUTPIO outputs a byte to the parallel interface port. *)

PROCEDURE OUTPIO (VAR B : BYTE);

BEGIN

   PORTW [PIOL] := B;
   PORTW [PIOH] := B;

END;

(* TRIGGER PULSE outputs a single trigger pulse (1 cycle). *)

PROCEDURE TRIGGER_PULSE (VAR T : TRIGGER_TABLE);

BEGIN

   OUTPIO (T.TRIG);
   DELAY (T.TIME);

   OUTPIO (T.NULL);
   DELAY (T.WAIT);

END;

(* INITIALIZE TRIGGER resets all triggers to 0. *)

PROCEDURE INIT_TRIGGER (VAR T : TRIGGER_TABLE);

BEGIN

   T.SPEC := FALSE;
   T.TRIG := $00;
   T.NULL := $00;
   T.TIME := 0;
   T.NULL := 0;

END;

(* DEFINE TRIGGER sets up the trigger definition and timing. *)

PROCEDURE DEFINE_TRIGGER (VAR T : TRIGGER_TABLE);

VAR BIT : INTEGER;
    MASK : BYTE;
    TIME : REAL;
    WAIT : REAL;
    STATE : INTEGER;

BEGIN

   WRITE ('Trigger # ');
   RDLNINT (BIT);
   WRITELN;
   CASE BIT OF
        1 : MASK := $01;
        2 : MASK := $02;
        3 : MASK := $04;
        4 : MASK := $08;
        5 : MASK := $10;
        6 : MASK := $20;
        7 : MASK := $40;
        8 : MASK := $80;
        ELSE MASK := $00;
        END;
   T.SPEC := (MASK <> $00);

   WRITE ('Active  State? (0/1) ');
   RDLNINT (STATE);
   IF STATE = 1
      THEN T.TRIG := (NOT MASK AND T.TRIG) OR (MASK AND $FF)
      ELSE T.TRIG := (NOT MASK AND T.TRIG) OR (MASK AND $00);

   WRITE ('Passive State? (0/1) ');
   RDLNINT (STATE);
   IF STATE = 1
      THEN T.NULL := (NOT MASK AND T.NULL) OR (MASK AND $FF)
      ELSE T.NULL := (NOT MASK AND T.NULL) OR (MASK AND $00);

   WRITE ('Trigger Time = ');
   RDLNREAL (TIME);
   T.TIME := ROUND (TIME * 1000);

   WRITE ('Delay   Time = ');
   RDLNREAL (WAIT);
   T.WAIT := ROUND (WAIT * 1000);
   WRITELN;

END;

(* SPECIFY TRIGGERS sets up the trigger sequencing. *)

PROCEDURE SPEC_TRIGGERS;

VAR SELECTION : CHAR;
    PHASE : INTEGER;

BEGIN

   WRITELN ('Trigger Phases of Operation:');
   WRITELN;
   WRITELN ('   1 : Phase 1 = Pre-Exposure');
   WRITELN ('   2 : Phase 2 = Sync-Exposure');
   WRITELN ('   3 : Phase 3 = Post-Exposure/Pre-Increment');
   WRITELN ('   4 : Phase 4 = Post-Increment');
   WRITELN;

   REPEAT
      WRITE ('Phase: ');
      RDCON (SELECTION);
      WRITELN;
      WRITELN;
      PHASE := ORD (SELECTION) - ORD ('0');
      IF PHASE IN [1..4]
         THEN DEFINE_TRIGGER (TRIGGER [PHASE]);
   UNTIL SELECTION = 'Q';
   WRITELN;

END;

(* GO TRIGGERS simulates a trigger run-time sequence. *)

PROCEDURE GO_TRIGGERS;

VAR FRAME_COUNT : INTEGER;

BEGIN

   WRITE ('Frame Count = ');
   RDLNINT (FRAME_COUNT);
   WRITELN;

   REPEAT

      IF TRIGGER [1].SPEC
         THEN TRIGGER_PULSE (TRIGGER [1]);
      WRITELN ('Camera Exposure...');
      IF TRIGGER [2].SPEC
         THEN TRIGGER_PULSE (TRIGGER [2]);
      DELAY (2000);
      WRITELN ('Camera Over');

      IF TRIGGER [3].SPEC
         THEN TRIGGER_PULSE (TRIGGER [3]);
      WRITELN ('Axes Moving...');
      DELAY (2000);
      WRITELN ('Axes Over');

      IF TRIGGER [4].SPEC
         THEN TRIGGER_PULSE (TRIGGER [4]);
      WRITELN ('Single Step...');
      DELAY (2000);
      WRITELN ('Continue');
      WRITELN;

      FRAME_COUNT := PRED (FRAME_COUNT);

   UNTIL FRAME_COUNT <= 0;

   WRITELN ('Scene Over');
   WRITELN;

END;

BEGIN

WRITELN;
WRITELN ('Trigger Output Test...');
WRITELN;

FOR I := 1 TO 3 DO
    INIT_TRIGGER (TRIGGER [I]);

REPEAT

   SPEC_TRIGGERS;
   GO_TRIGGERS;

   WRITE ('Continue? ');
   RDCON (CH);
   WRITELN;
   WRITELN;

UNTIL (CH = 'N') OR (CH = 'Q');

END.

