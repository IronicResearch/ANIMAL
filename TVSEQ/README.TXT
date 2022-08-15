Read-Me notes for TVSeq -- 
ThingM Sequencer Script program for IBM PC clones

------------
About TVSeq
------------
TVSeq is a simple PC application which allows the user to create 
or edit scripts for running custom optical printer sequences with a 
ThingM-II dual-motor camera control. Typically, a JK optical printer 
is used, though it may be used with any camera and auxiliary motor setup. 

TVSeq uses a familiar Mac-style or Windows-style user interface (called
Turbo Vision -- hence the name TV). It is an MS-DOS program which can run
on any 100% IBM-compatible PC, no matter how old or new. It will even
run under Windows95 as an MS-DOS full-screen exclusive-mode application. 

This demo version of TVSeq does not require a ThingM motor controller 
to use. The release version of TVSeq contains the complete interface 
support for ThingM and ThingM-II (though it can also be run when ThingM 
is not connected).

The PC interface used for communicating with the ThingM controller 
is the COM Serial port. A TestTerm application is included in the release 
version to verify that communications with the ThingM controller can be 
established. (Any modem communications application will also suffice to 
connect to ThingM for testing.)

----------------------------
Scripting Sequencer Commands
----------------------------
When launching TVSeq, a text window is opened on the desktop to begin 
recording a new sequencer script. You may record sequencer commands to 
the script by either running actual sequencer operations, or manually 
editing script text.

To run actual sequencer operations, use the 'Run' menu to select 'Camera', 
'Projector', or 'Sequencer'. After entering entering Frame Count 
information and clicking OK, TVSeq will update the current text window 
with the equivalent ThingM commands.

The cummulative Frame Counters for both camera and projector will also 
be scripted when you use the 'Edit' menu to select 'Frame Counters'.

If you wish to run sequencer operations without adding script commands 
to the text window, use the 'Edit' menu to toggle 'Script Recording' off.

------------------------
Editing Scripts Manually
------------------------
Alternatively you could edit sequencer script manually using the 
built-in standard text editor. Each script command uses the same 
3-letter acronyms as used for ThingM functions, like 'CAM', 'PRJ', 
and 'SEQ'. 

ThingM commands supported are:          

	CAM             for camera selections           
	PRJ             for projector selections                
	FRM             for preset frame count          
	CTR             for cummulative frame counter           
	SEQ             for sequencer mode              
	ALT             for alternate camera:projector sequence         
	STP             for step-frame camera sequence          
	SKP             for skip-frame projector sequence               
	EXP             for camera exposure time                
	SPD             for projector advance speed

You may even add your own notations or comments in the script anywhere 
before or after lines containing ThingM script commands. It is recommended 
to begin each comment with an asterisk '*', though any piece of text that 
does not begin with ThingM acronyms will be interpreted as a comment.

-------------------------
Running Sequencer Scripts
-------------------------
When a script contains valid ThingM commands, it may be run by selecting 
'Run Script' from the 'Run' menu. Only the currently active text window 
is used as the script. 

The cummulative Frame Counters window will update with each executed 
ThingM command, just as it did with a Camera, Projector, or Sequencer 
menu command. You have the option to pause any running sequence by 
clicking on the 'Stop/Go' button, or hitting the default 'Return/Enter' 
key. 

Of course, you may also save and load scripts with the standard 'File' 
menu 'Save' and 'Open' commands. Take a look at the example scripts 
included with the TVSeq program. These script files are designated with
the '.SEQ' file suffix, though the files themselves are ordinary text
documents, compatible with MS-DOS Edit and Windows Notepad applications.

------------
Contact Info
------------
For more information, contact Dave Milici at Ironic Research Labs in 
San Francisco:

415-621-2769
mailto:davem77@well.com
http://www.well.com/~davem77/ironic.html

