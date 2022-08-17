{$UNDEF  SIO_DEBUG}                     (* for debug output *)

{$DEFINE SIO_INTERRUPT}                 (* for interrupt-driven input *)

{$DEFINE SIO_LOOPBACK_TEST}             (* for loopback test *)

(* TODO: Need to insure that COM port and interrupt setup for MCPUIO
(* does not get clobbbered by COM port setup for RGBIO or TERMIO. *)