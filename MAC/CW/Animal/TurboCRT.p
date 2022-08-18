
(* Turbo Pascal compatible console extensions. *)
(* Equivalent to CRT unit supplied with Turbo Pascal. *)

(* Adapted for CodeWarrior Pascal. *)

Unit TurboCRT;

Interface

Uses
	Types, 
	Events, 
	OSUtils,		(* Delay *) 
	ToolUtils;		(* BitAnd *)

function KeyPressed : boolean;
function ReadKey : char;
procedure TpDelay(N : integer);
function TpMousePressed : boolean;
procedure TpReadMouse;

Implementation

(* Detect if key has been pressed without getting key character. *)
(* Use Mac OS to get keyboard status. *)
(* Replaces Turbo Pascal extension KeyPressed. *)
function KeyPressed : boolean;
	var
		thisEvent: EventRecord;
	begin
		if EventAvail(keyDownMask, thisEvent) then
			KeyPressed := TRUE
		else
			KeyPressed := FALSE;
	end;

(* Read key character from keyboard without echo to console display. *)
(* Use Mac OS to read keyboard. *)
(* Replaces Turbo Pascal extension ReadKey/ReadChar. *)
function ReadKey : char;
	var
		thisEvent: EventRecord;
		Ch : char;
	begin
		if EventAvail(keyDownMask, thisEvent) then
			begin
				if GetNextEvent(keyDownMask, thisEvent) then
					Ch := Chr(BitAnd(thisEvent.message, charCodeMask));
			end;
		ReadKey := Ch;
	end;

(* Wait delay for N milliseconds. *)
(* Uses Mac OS Toolbox function Delay for 1/60th-second ticks. *)
(* Replaces Turbo Pascal extension Delay. *)
procedure TpDelay(N : integer);
	var
		DelayTicks : longint;
		FinalTicks : longint;
	begin
		DelayTicks := longint(N) * 60 DIV 1000;
		Delay(DelayTicks, FinalTicks);
	end;
	
(* Detect mouse click. *)
(* Uses Mac OS Toolbox function Button. *)
(* Replaces TurboPro library extension MousePressed. *)
function TpMousePressed : boolean;
	begin
		TpMousePressed := Button;
	end;
	
(* Read mouse record out of Mac OS event buffer. *)
procedure TpReadMouse;
	var
		thisEvent: EventRecord;
	begin
		if EventAvail(mDownMask, thisEvent) then
			begin
				if GetNextEvent(keyDownMask, thisEvent) then
					;
			end;
	end;


End.

