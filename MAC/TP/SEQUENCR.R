Sequencr.Rsrc

Type SEQ1 = STR 
  ,0
Sequencer Demo Program  Version 2.3 -- 11 Apr 92

TYPE STR
  ,1000(4)
           Turbo Animal Professional for the MacIntosh
  ,1001(4)
              Copyright c 1991 by Penguin Associates
  ,1002(4)             
          Best-Dressed Diners of Fine Fish Food Anywhere

Type BNDL
  ,1100
DM01 0
ICN#
0 1100
FREF
0 1100

Type FREF
  ,1100
APPL 0

Type ICN# = GNRL
,1100
.H
FFFFFFFF
80000001
80000001
80000001
FFFFFFFF
80000001
80000001
80000001
FFFFFFFF
80000001
80000001
80000001
FFFFFFFF
80000001
80000001
80000001
FFFFFFFF
80000001
80000001
80000001
FFFFFFFF
80000001
80000001
80000001
FFFFFFFF
80000001
80000001
80000001
FFFFFFFF
80000001
80000001
80000001
* below is the mask
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF
FFFFFFFF

TYPE MENU
  ,1000
\14
About Animal...
(-

  ,1001
File
New
Open
(-
Save
Save As
Close
(-
Quit/Q

  ,1002
Edit
Undo
(-
Cut
Copy
Paste
Clear
(-
Counters

  ,1003
Run
Camera
Projector
Sequencer

  ,1004
Overide
Init
Run
Kill/K
Status
Position
(-
Move
Goto
Jog/J
Limit
Zero

  ,1005
Utility
Axis Mapping
User Units
Motor Speeds


TYPE WIND
    ,1000
SEQUENCER
44 7 335 505
Visible GoAway
0
0

Type DLOG
  ,1000(4)
About Animal
90 50 180 460
Visible NoGoAway
16
0
1000

  ,1031
Camera Run
100 50 170 450
Visible NoGoAway
0
0
1031

  ,1032
Projector Run
100 50 170 450
Visible NoGoAway
0
0
1032

  ,1033
Sequencer Run
100 50 270 450
Visible NoGoAway
0
0
1033

  ,1034
Frame Counter
100 50 170 450
Visible NoGoAway
0
0
1034

  ,1041
Initialize Overide
100 50 230 450
Visible NoGoAway
0
0
1041

  ,1042
Run Overide
100 50 170 450
Visible NoGoAway
0
0
1042

  ,1044
Status Overide
100 50 170 450
Visible NoGoAway
0
0
1044

  ,1045
Position Overide
100 50 170 450
Visible NoGoAway
0
0
1045

,1046
Move Overide
100 50 170 450
Visible NoGoAway
0
0
1046

,1047
Goto Overide
100 50 170 450
Visible NoGoAway
0
0
1047

,1048
Jog Overide
100 50 230 450
Visible NoGoAway
0
0
1048

,1049
Limit Overide
100 50 170 450
Visible NoGoAway
0
0
1049

,1140
Zero Overide
100 50 170 450
Visible NoGoAway
0
0
1140

,1051
Axis Mapping Utility
100 50 170 450
Visible NoGoAway
0
0
1051

,1052
User Units Utility
100 50 230 450
Visible NoGoAway
0
0
1052

,1053
Motor Speeds Utility
100 50 230 450
Visible NoGoAway
0
0
1053


Type DITL
  ,1000(36)
2

BtnItem Enabled
60 167 81 244
OK

StatText Disabled
5 10 60 400
^0 \0D ^1 \0D ^2

  ,1031
4

Button
10 300 30 370
Ok

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 250
Camera Overide Frame Count

EditText Enabled
40 10 55 250
0

  ,1032
4

Button
10 300 30 370
Ok

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 250
Projector Overide Frame Count

EditText Enabled
40 10 55 250
0

  ,1033
11

Button
10 300 30 370
Ok

Button
70 300 90 370
Cancel

RadioItem Enabled
10 10 30 250
Alternate Camera + Projector

RadioItem Enabled
40 10 60 250
Step Camera per Projector Cycle

RadioItem Enabled
70 10 90 250
Skip Projector per Camera Cycle

StatText Enabled
100 10 120 70
Camera

EditText Enabled
100 80 115 120
1

StatText Enabled
100 140 120 210
Projector

EditText Enabled
100 220 115 260
1

StatText Enabled
135 10 155 100
Total Cycles

EditText Enabled
135 110 150 260
0

  ,1034
6

Button
10 300 30 370
Stop/Go

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 130
Camera Frame

EditText Enabled
40 10 55 130
0

StatText Enabled
10 150 30 270
Projector Frame

EditText Enabled
40 150 55 270
0

  ,1041
10

Button
10 300 30 370
Ok

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 120
Motor Number

EditText Enabled
10 150 25 250
1

StatText Enabled
40 10 60 120
Low Speed

EditText Enabled
40 150 55 250
0

StatText Enabled
70 10 90 120
High Speed

EditText Enabled
70 150 85 250
0

StatText Enabled
100 10 120 120
Ramp Count

EditText Enabled
100 150 115 250
0

  ,1042
6

Button
10 300 30 370
Ok

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 120
Motor Number

EditText Enabled
10 150 25 250
1

StatText Enabled
40 10 60 120
Step Count

EditText Enabled
40 150 55 250
0

  ,1044
6

Button
10 300 30 370
Update

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 120
Motor Number

EditText Enabled
10 130 25 270
1

StatText Enabled
40 10 60 120
Motor Status

EditText Enabled
40 130 55 270
?

  ,1045
6

Button
10 300 30 370
Update

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 120
Motor Number

EditText Enabled
10 130 25 270
1

StatText Enabled
40 10 60 120
Motor Position

EditText Enabled
40 130 55 270
?

  ,1046
6

Button
10 300 30 370
Ok

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 120
Motor Number

EditText Enabled
10 130 25 270
1

StatText Enabled
40 10 60 120
Move Distance

EditText Enabled
40 130 55 270
0

  ,1047
6

Button
10 300 30 370
Ok

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 120
Motor Number

EditText Enabled
10 130 25 270
1

StatText Enabled
40 10 60 120
Goto Position

EditText Enabled
40 130 55 270
0

  ,1048
8

Button
10 300 30 370
Ok

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 120
Motor Number

EditText Enabled
10 150 25 250
1

RadioItem Enabled
40 10 60 290
Incremental single step per Keystroke

RadioItem Enabled
70 10 90 300
Continual Stop/Go motion per Keystroke

Button
100 40 120 110
<--

Button
100 180 120 250
-->

  ,1049
5

Button
10 300 30 370
Ok

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 270
Run Motor to Limit Switch Position

StatText Enabled
40 10 60 120
Motor Number

EditText Enabled
40 130 55 270
1

  ,1140
5

Button
10 300 30 370
Ok

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 270
Zero Motor Counter at this Position

StatText Enabled
40 10 60 120
Motor Number

EditText Enabled
40 130 55 270
1

  ,1051
8

Button
10 300 30 370
Ok

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 80
Axis Label

EditText Enabled
10 95 25 125
XA

StatText Enabled
10 140 30 240
Motor Number

EditText Enabled
10 250 25 280
1

StatText Enabled
40 10 60 120
Axis Description

EditText Enabled
40 130 55 280
---

  ,1052
10

Button
10 300 30 370
Ok

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 120
Motor Axis

EditText Enabled
10 150 25 250
XA

StatText Enabled
40 10 60 120
User Units

EditText Enabled
40 150 55 250
Steps

StatText Enabled
70 10 90 120
1 Unit = 

EditText Enabled
70 150 85 250
1.0 (steps)

StatText Enabled
100 10 120 120
1 Step = 

EditText Enabled
100 150 115 250
1.0 (units)

  ,1053
10

Button
10 300 30 370
Ok

Button
40 300 60 370
Cancel

StatText Enabled
10 10 30 120
Motor Axis

EditText Enabled
10 150 25 250
XA

StatText Enabled
40 10 60 120
Low Speed

EditText Enabled
40 150 55 250
0

StatText Enabled
70 10 90 120
High Speed

EditText Enabled
70 150 85 250
0

StatText Enabled
100 10 120 120
Ramp Count

EditText Enabled
100 150 115 250
0


