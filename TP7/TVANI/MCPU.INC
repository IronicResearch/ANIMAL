{$UNDEF  DEBUG}         (* debug tracer messages on screen *)

(* Which type of MCPU ? *)

{$UNDEF  MCPU_NULL}                     (* no MCPU *)
{$UNDEF  MCPU_STDBUS}                   (* STD bus MCPU *)
{$DEFINE MCPU_COMPUMTR}                 (* Compumotor MCPU *)

{$UNDEF  SIO_COM1}                      (* serial COM1 *)
{$UNDEF  SIO_COM2}                      (* serial COM2 *)
{$DEFINE SIO_COMX}                      (* serial COMx selectable *)

(* which type of Compumotor ? *)

{$IFDEF MCPU_COMPUMTR}

{$DEFINE MCPU_SIO}                      (* serial interface *)
{$DEFINE MCPU_PIO}                      (* PC bus interface *)
{$DEFINE MCPU_SIO_PIO}                  (* both serial + PC bus *)

{$UNDEF  COMPUMTR_1200}                 (* Compumotor 1200 *)
{$DEFINE COMPUMTR_2100}                 (* Compumotor 2100 *)
{$DEFINE COMPUMTR_PC23}                 (* Compumotor PC23 *)

{$ENDIF}

