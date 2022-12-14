
(* Compiler switches for TVAnimal. *)

(* {$R+}   (* range checking on *)
(* {$S+}   (* stack checking on *)

{$D-}   (* debugging off *)
{$L-}   (* local symbol list off *)

{$X+}   (* extend functions as procedures *)
{$V-}   (* variable string type checking off *)

{$M 36000,64000,655360}                (* max stack and some heap *)

{$DEFINE MCPU_INSTALLED}               (* real MCPU connected ? *)

{$UNDEF  VIDEO_INSTALLED}              (* Video Frame Rate *)

{$DEFINE REALTIME_MOTION}              (* Real-time motion control with PC23 *)

{$DEFINE GOMOTION_CONTROL}             (* Go-Motion control options *)

{$DEFINE JOYSTICK_CONTROL}             (* Joystick motion control with PC23 *)

{$DEFINE JOYSTICK_TRIGGER}             (* Joystick trigger input with PC23 *)

{$UNDEF  SPECIAL_FEATURE}              (* for special feature additions *)

{$UNDEF  RGB_CONTROL}                  (* for RGB Light Source control *)
