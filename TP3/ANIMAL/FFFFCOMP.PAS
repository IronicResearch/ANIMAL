
(* PHANTOM FOLLOW FOCUS is the program for coordinating a lens assembly F-axis
(* to a non-existant focussing distance Z-axis for follow focus control. *)

(* This program is based upon the Gaussian Lens Equation (for ideal lenses):
(*      1/O + 1/I = 1/F
(*      O = object distance from object to lens
(*      I = image distance from lens to image
(*      F = focal length of lens
(* This relation becomes exact for real lenses when using the principal planes
(* technique. (The principal planes happen to be located where the relation
(* is meant to hold true.) *)

(* When a reference image is created, all subsequent focussing is computed
(* relative to this reference image. Therefore many physical parameters,
(* including the locations of the pricipal planes themselves, drop out
(* of the computations. *)

PROGRAM FOLLOW_FOCUS_LISTING;

PROCEDURE FOLLOW_FOCUS_COMPUTATION;

CONST K_Z = 1.0;                  (* Z axis units --> steps conversion *)
      K_F = 1.0;                  (* F axis units --> steps conversion *)
      MIN_d_O = 0.5;              (* Z axis minimum resolution *)
      MIN_d_I = 0.5;              (* F axis minimum resolution *)

VAR FF : REAL;                    (* focal length *)

    O_REF : REAL;                 (* object reference position *)
    I_REF : REAL;                 (* image reference position *)
    M_REF : REAL;                 (* magnification reference ratio *)
    Z_REF : REAL;                 (* Z axis reference focussing distance *)
    F_REF : REAL;                 (* F axis reference lens distance *)

    O : REAL;                     (* object distance *)
    I : REAL;                     (* image distance *)
    M : REAL;                     (* magnification *)
    Z : REAL;                     (* Z axis focussing distance *)
    F : REAL;                     (* F axis lens distance *)

    d_O : REAL;                   (* delta object distance *)
    d_I : REAL;                   (* delta image distance *)
    d_Z : REAL;                   (* delta Z axis distance *)
    d_F : REAL;                   (* delta F axis distance *)

    CH : CHAR;
    ANSWER : CHAR;

    Z_INITL : REAL;
    Z_FINAL : REAL;
    Z_INCR : REAL;
    N : INTEGER;
    L : INTEGER;

(* This section initializes the follow focus reference parameters. *)

PROCEDURE REFERENCE_FOLLOW_FOCUS_PARAMETERS;

BEGIN

   WRITE ('Lens Focal Length  = ');
   READLN (FF);

   WRITE ('Reference Focussing Distance = ');
   READLN (Z_REF);
   WRITELN;

   F_REF := 0.0;

   I_REF := (Z_REF - SQRT (SQR (Z_REF) - 4 * Z_REF * FF)) / 2;

   O_REF := (FF * I_REF) / (I_REF - FF);

   M_REF := -1.0 * I_REF / O_REF;

   WRITELN ('Reference object distance = ', O_REF:8:3, ' mm');
   WRITELN ('Reference image distance  = ', I_REF:8:3, ' mm');
   WRITELN ('Reference magnification   = ', M_REF:8:3);
   WRITELN;

END;

(* This section computes the Z and F axes into follow-focus positions according
(* to the operator's input focussing specifications. *)

PROCEDURE COMPUTE_FOLLOW_FOCUS_POSITIONS;

BEGIN

   IF Z < 4 * FF
      THEN I := 2 * FF
      ELSE I := (Z - SQRT (SQR (Z) - 4 * Z * FF)) / 2;

   O := (FF * I) / (I - FF);

   d_O := O - O_REF;
   d_I := I - I_REF;

   d_Z := Z - Z_REF;
   d_F := -1.0 * K_F * (d_I);

END;

BEGIN

REFERENCE_FOLLOW_FOCUS_PARAMETERS;

REPEAT

   WRITE ('Initial Focussing Distance = ');
   READLN (Z_INITL);
   WRITE ('Final   Focussing Distance = ');
   READLN (Z_FINAL);
   WRITE ('Number of Intermediate Points = ');
   READLN (N);
   WRITELN;

   WRITELN ('Distance':10,'delta-Z':10,'Object':10,'delta-O':10,'Image':10,'delta-I':10,'delta-F':10);
   WRITELN;
   Z_INCR := (Z_FINAL - Z_INITL) / (N - 1);
   Z := Z_INITL;
   FOR L := 1 TO N DO
       BEGIN
       COMPUTE_FOLLOW_FOCUS_POSITIONS;
       WRITELN (Z:10:3, d_Z:10:3, O:10:3, d_O:10:3, I:10:3, d_I:10:3, d_F:10:3);
       Z := Z + Z_INCR;
       END;
   WRITELN;

   WRITE ('Continue Focus Points? ');
   READLN (ANSWER);
   WRITELN;
   WRITELN;

UNTIL ANSWER = 'N';

END;

BEGIN

   WRITELN;
   WRITELN ('Follow Focus Computations');
   WRITELN;

   FOLLOW_FOCUS_COMPUTATION;

END.
