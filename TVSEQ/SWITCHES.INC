
(* Compiler switches for TVAnimal. *)

{$UNDEF DEBUG}                  (* for debugging version *)

{$IFDEF DEBUG}
{$R+}                           (* range checking on *)
{$S+}                           (* stack checking on *)

{$D+}                           (* debugging on *)
{$L+}                           (* local symbol list on *)

{$ELSE}
{$R-}                           (* range checking off *)
{$S-}                           (* stack checking off *)

{$D-}                           (* debugging off *)
{$L-}                           (* local symbol list off *)
{$ENDIF}

{$X+}                           (* extend functions as procedures *)
{$V-}                           (* variable string type checking off *)

{$M 65520,65536,655360}         (* max stack, min heap, max heap *)

(* Feature switches for installed devices. *)

{$UNDEF  USE_TURBO_VISION}      (* for Turbo Vision user interface *)

{$UNDEF  MCPU_INSTALLED}        (* real STD-bus MCPU connected ? *)

{$DEFINE THINGM_INSTALLED}      (* ThingM controller ? *)

{$UNDEF  COMPUMOTOR_2100}       (* CompuMotor 2100 motion controller ? *)

{$UNDEF  COMPUMOTOR_PC23}       (* CompuMotor PC23 motion controller ? *)

{$UNDEF  VIDEO_INSTALLED}       (* Video Frame Rate (vs Film) *)

{$UNDEF  REALTIME_MOTION}       (* Real-time motion control with PC23 *)

{$UNDEF  GOMOTION_CONTROL}      (* Go-Motion control options *)

{$UNDEF  JOYSTICK_CONTROL}      (* Joystick motion control with PC23 *)

{$UNDEF  SPECIAL_FEATURE}       (* for special feature additions *)

{$UNDEF  RGB_CONTROL}           (* for RGB Light Source control *)

