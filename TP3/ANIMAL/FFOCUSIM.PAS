
(* FOLLOW FOCUS SIMULATION performs the Follow Focus conversion formulas
(* used in the ANIMAL Stop Motion program sequencing. *)

PROGRAM FOLLOW_FOCUS_SIMULATION;

VAR CH : CHAR;
    ANSWER : CHAR;

    FOCAL_LENGTH : REAL;
    ZERO_FOCUS : REAL;
    FF_K_KSCALE : REAL;
    FOLLOW_FOCUS : BOOLEAN;

    Z_REF : REAL;
    I_REF : REAL;
    FF : REAL;
    KF : REAL;

    Z_INITL : REAL;
    Z_FINAL : REAL;
    Z_INCR : REAL;

    Z : REAL;
    F : REAL;
    Z_PRIME : REAL;
    F_PRIME : REAL;

    N : INTEGER;
    L : INTEGER;

(* CONVERT FOLLOW FOCUS computes the Follow Focus conversion for FF. *)

PROCEDURE CONVERT_FOLLOW_FOCUS (VAR Z : REAL; VAR L : REAL);

VAR I : REAL;
    I_REF : REAL;
    K : REAL;
    F : REAL;

BEGIN

   I_REF := ZERO_FOCUS;
   K := FF_K_KSCALE;
   F := FOCAL_LENGTH;

   IF Z < 4 * F
      THEN I := 2 * F
      ELSE I := (Z - SQRT (SQR (Z) - 4 * Z * F)) / 2;

   L := -1.0 * K * (I - I_REF);

END;

(* CONVERT converts user defined units into steps. *)

PROCEDURE CONVERT (VAR X : REAL; K : REAL; VAR Y : REAL);

VAR T : REAL;

BEGIN

   IF FOLLOW_FOCUS AND (K = FF_K_KSCALE)
      THEN CONVERT_FOLLOW_FOCUS (X, Y)
      ELSE Y := X / K;

END;

(* RECONVERT FOLLOW FOCUS reconverts FF. *)

PROCEDURE RECONVERT_FOLLOW_FOCUS (VAR L : REAL; VAR Z : REAL);

VAR I : REAL;
    d_I : REAL;
    I_REF : REAL;
    K : REAL;
    F : REAL;

BEGIN

   I_REF := ZERO_FOCUS;
   K := FF_K_KSCALE;
   F := FOCAL_LENGTH;

   d_I := -1.0 * L / K;
   I := d_I + I_REF;

   Z := I + (F * I) / (I - F);

END;

(* RECONVERT reconverts steps into user-defined units. *)

PROCEDURE RECONVERT (VAR X : REAL; K : REAL; VAR Y : REAL);

BEGIN

   IF FOLLOW_FOCUS AND (K = FF_K_KSCALE)
      THEN RECONVERT_FOLLOW_FOCUS (X, Y)
      ELSE Y := K * X;

END;

BEGIN

WRITELN;
WRITELN ('Follow Focus Simulation...');
WRITELN;

   WRITE ('Lens Focal Length  = ');
   READLN (FF);

   WRITE ('Lens Axis Conversion Factor = ');
   READLN (KF);

   WRITE ('Reference Focussing Distance = ');
   READLN (Z_REF);
   WRITELN;

   I_REF := (Z_REF - SQRT (SQR (Z_REF) - 4 * Z_REF * FF)) / 2;

   ZERO_FOCUS := I_REF;
   FF_K_KSCALE := KF;
   FOCAL_LENGTH := FF;
   FOLLOW_FOCUS := TRUE;

REPEAT

   WRITE ('Initial Focussing Distance = ');
   READLN (Z_INITL);
   WRITE ('Final   Focussing Distance = ');
   READLN (Z_FINAL);
   WRITE ('Number of Intermediate Points = ');
   READLN (N);
   WRITELN;

   WRITELN ('Increment':10, 'Distance':15, 'Focus':15, 'Focus''':15, 'Distance''':15);
   WRITELN;
   Z_INCR := (Z_FINAL - Z_INITL) / (N - 1);
   Z := Z_INITL;
   FOR L := 1 TO N DO
       BEGIN
       CONVERT (Z, FF_K_KSCALE, F);
       WRITE (L:10, Z:15:3, F:15:3);
       F_PRIME := TRUNC (F);
       RECONVERT (F_PRIME, FF_K_KSCALE, Z_PRIME);
       WRITELN (F_PRIME:15:3, Z_PRIME:15:3);
       Z := Z + Z_INCR;
       END;
   WRITELN;

   WRITE ('Continue? ');
   READLN (ANSWER);
   WRITELN;

UNTIL ANSWER = 'N';

END.
