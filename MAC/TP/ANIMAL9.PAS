
(* ANIMAL for the Macintosh. *)
(* Copyright 1991 Dave Milici and Penguin Associates. *)

Program ANIMAL;

{$R-}               { Turn off range checking               }
{$I-}               { Turn off I/O error checking           }
{$B+}               { Set bundle bit (for icon, etc.)       }
{$R Animal.Rsrc}    { Identify resource file                }
{$T APPLANM1}       { Set application ID                    }
{$U-}               { Turn off auto link to runtime units   }
{$U TurboCrt}       { Turbo Pascal for IBM library unit     }
{$U Mcpu}           { MCPU communications interface         }
{$S+}               { Turn on code Segmentation             }

Uses 

    PasInOut,       { Pascal basic input / output system    } 
    Memtypes,       { Mac OS memory types                   }
    QuickDraw,      { Mac OS QuickDraw graphics             }
    OSIntf,         { Mac OS interface routines             }
    ToolIntf,       { Mac OS toolbox routines               }
    PackIntf,       { Mac OS file package manager           }
    PasConsole,     { Pascal console Read / Write library   }
    Sane,           { Standard Apple Numeric Environment    }

    TurboCrt,       (* Turbo Pascal for IBM routines        *)
    Mcpu;           (* MCPU Communications interface        *) 

Const

  MenuCnt       =     7;    { total # of menus                   }
  ApplMenu      =  1000;    { resource ID of Apple Menu          }
  FileMenu      =  1010;    { resource ID of File Menu           }
  EditMenu      =  1020;    { resource ID of Edit Menu           }
  RunnMenu      =  1030;    { Run Menu                           }
  OverMenu      =  1040;    { Overide Menu                       }
  UtilMenu      =  1050;    { Utilities Menu                     }
  SpecMenu      =  1060;    { Special Menu                       }
  
  AM            =     1;    { index into MenuList for Apple Menu }
  FM            =     2;    { File Menu                          }
  EM            =     3;    { Edit Menu                          }
  RM            =     4;    { Run Menu                           }
  OM            =     5;    { Overide Menu                       }
  UM            =     6;    { Utilities Menu                     }
  SM            =     7;    { Special Menu                       }
  
  MainID        =  1000;    { resource ID for MainWindow         }
  AboutID       =  1000;    { resource ID for dialog box         }
  Text1ID       =  1000;    { resource IDs for 'About...' text   }
  Text2ID       =  1001;
  Text3ID       =  1002;
  
Type

  PtrInteger    = ^integer;
  PtrString     = ^str255;
  CursorList    = array[IBeamCursor..WatchCursor] of CursHandle;
  
Var

  Finished      : Boolean;	         { used to terminate the program }
  Ticks         : Longint;	         { keeps track of time }
  TV,TH         : Integer;	         { location of text }
  theEvent      : EventRecord;      { event passed from operating system }
 
  { Screen stuff}
  DragArea	     : Rect;	{ defines area where window can be dragged in }
  GrowArea	     : Rect;	{ defines area to which a window's size can change }
  ScreenArea    : Rect;	{ defines screen dimensions }
  CursList      : CursorList;   { used to hold cursor handles }

  { Menu stuff}
  MenuList	     : array[1..MenuCnt] of MenuHandle;  { holds menu info }
  
  { Window stuff }
  MainPtr	      : WindowPtr;        { pointer to main window        }
  MainRec	      : WindowRecord;     { holds data for main window    }
  MainPeek      : WindowPeek;       { pointer to MainRec            }
  ScreenPort    : GrafPtr;          { pointer to entire screen      }
  FrontWindow   : WindowPtr;        { pointer to active window      }

(* Animal stuff *)
  
Const   MFN = 1;            (* File New menu *)
        MFO = 2;            (* File Open *)
        MFS = 4;            (* File Save *)
        MFA = 5;            (* File Save As *)
        MFC = 6;            (* File Close *)
        MFQ = 8;            (* File Quit *)
        
        MEU = 1;            (* Edit Undo menu *)
        MEX = 3;            (* Edit Cut *)
        MEC = 4;            (* Edit Copy *)
        MEV = 5;            (* Edit Paste *)
        MED = 6;            (* Edit Clear *)
        MEF = 8;            (* Edit Frame Count *)
        MEA = 9;            (* Edit Axis Positions *)
        MET = 10;           (* Edit Total Counters *)
        
        MRC = 1;            (* Run Camera menu *)
        MRP = 2;            (* Run Projector *)
        MRS = 3;            (* Run Sequencer *)
        MRM = 5;            (* Run Stop Motion *)
        MRG = 6;            (* Run Go Motion *)
        MRL = 7;            (* Run Continuous Motion *)
        
        MOI = 1;            (* Overide Init menu *)
        MOR = 2;            (* Overide Run *)
        MOK = 3;            (* Overide Kill *)
        MOS = 4;            (* Overide Status *)
        MOP = 5;            (* Overide Position *)
        MOM = 7;            (* Overide Move *)
        MOG = 8;            (* Overide Goto *)
        MOJ = 9;            (* Overide Jog *)
        MOL = 10;           (* Overide Limit *)
        MOZ = 11;           (* Overide Zero *)
        
        MUI = 1;            (* Utility Install *)
        MUM = 2;            (* Utility Motor Speed *)
        MUU = 3;            (* Utility User Units *)
        
        MSP = 1;            (* Special Point-Plotter *)
        MSI = 2;            (* Special Interpolation *)
        MSC = 3;            (* Special CAD Import *)
        MST = 4;            (* Special Text Export *)
        
        PFrmId = 1021;      (* Preset Frame Count dialog *)
        AxisId = 1022;      (* Axis Position dialog *)

        CamId = 1031;       (* Camera dialog resource ID *)
        PrjId = 1032;       (* Projector dialog *)
        SeqId = 1033;       (* Sequencer dialog *)
        FrmId = 1034;       (* Frame Count dialog *)
        StopId = 1035;      (* Stop Motion dialog *)
        
        InitId = 1041;      (* Init dialog *)
        RunId  = 1042;      (* Run dialog *)
        KillId = 1043;      (* Kill dialog *)
        StatId = 1044;      (* Status dialog *)
        PosnId = 1045;      (* Position dialog *)
        MoveId = 1046;      (* Move dialog *)
        GotoId = 1047;      (* Goto dialog *)
        JogId  = 1048;      (* Jog dialog *)
        LimId  = 1049;      (* Limit switch dialog *)
        ZeroId = 1140;      (* Zero position dialog *)
        
        AmapId = 1051;      (* Axis Map dialog *)
        MspdId = 1052;      (* Motor Speeds dialog *)
        UnitId = 1053;      (* User Units dialog *)
        
Const   FWD = True;         (* forward motor direction *)
        REV = False;        (* reverse motor direction *)
        
        Min_Axes = 2;       (* min number of axes *)
        Max_Axes = 8;       (* max number of axes *)
        
        Max_Points = 100;   (* max number of points *)

Type    Sequencer_Mode = (None, Alternate, StepCamera, SkipProjector);

        { Motor_Table = Record
            MotorNo : Integer;              (* motor number *)
            StepCnt : Real;                 (* step count *)
            Dir     : Boolean;              (* step direction *)
            AccelSt : Boolean;              (* acceleration status *)
            Speed   : Integer;              (* constant speed *)
            LowSpd  : Integer;              (* low speed *)
            HighSpd : Integer;              (* high speed *)
            RampCnt : Integer;              (* ramp count *)
            RampK   : Integer;              (* ramp constant *)
            Stat    : Char;                 (* axis status *)
            Count   : Real;                 (* axis position *)
            Error   : Boolean;              (* error status *)
            end; }
            
        Map_Table = Record
            ID      : String [2];           (* axis ID tag *)
            No      : Integer;              (* motor number *)
            Name    : String;               (* axis name label *)
            end;

        Conversion_Table = Record
            Kscale  : Real;                 (* scale factor *)
            DP      : Integer;              (* decimal places *)
            Units   : String;               (* user units label *)
            Cur_Step: Real;                 (* current step count *)
            Cur_Posn: Real;                 (* current step position *)
            end;
            
        Run_Profile = Record
            AccelSt     : Boolean;          (* acceleration status *)
            Max_Speed   : Real;             (* max constant speed *)
            Min_LowSpd  : Real;             (* min low speed *)
            Max_HighSpd : Real;             (* max high speed *)
            Max_RampCnt : Real;             (* max ramp count *)
            end;
            
        Parameter_Table = Record
            Spec        : Boolean;
            StartFrame  : Integer;
            EndFrame    : Integer;
            StartPoint  : Real;
            EndPoint    : Real;
            Taper       : Boolean;
            Accel       : Real;
            Decel       : Real;
            IncrMax     : Real;
            MoveType    : String [3];
            Streak      : Boolean;
            InitlSize   : Real;
            FinalSize   : Real;
            end;
            
        Point_Table = Array [0..Max_Points] of Real;

        Axis_Table = Record
            Spec    : Boolean;              (* specified ? *)
            A       : Map_Table;            (* axis map *)
            M       : Motor_Table;          (* MCPU motor stuff *)
            K       : Conversion_Table;     (* user units stuff *)
            R       : Run_Profile;          (* motor run profile stuff *)
            P       : Parameter_Table;      (* program parameters *)
            Q       : Point_Table;          (* point buffer *)
            end;            

Var     Frame_Count   : Integer;            (* overall frame count *)
        Camera_Count  : Integer;            (* camera frame count *)
        Projector_Count : Integer;          (* projector frame count *)
        Sequencer_Count : Integer;          (* sequencer frame count *)
        Sequencer : Sequencer_Mode;         (* sequencer operation *)
        Camera_Cycle : Integer;             (* camera cycle count *)
        Projector_Cycle : Integer;          (* projector cycle count *)
        Camera_Total : Integer;             (* camera total frames *)
        Projector_Total : Integer;          (* projector total frames *)
        Preset_Count : Integer;             (* preset frame count *)

Var     Exposured : Boolean;                  (* exposures active ? *)
        Reversed : Boolean;                 (* sequence reversed ? *)
        SingleFramed : Boolean;             (* sequence single-framed ? *)
    
        M : Motor_Table;                    (* general motor axis *)

        I : Integer;                        (* axis array index *)
        Index : Integer;                    (* axis array index - specific *)
        AA : Array [1..Max_Axes] of Axis_Table;

Const   CX = 1;                             (* camera axis *)
        PX = 2;                             (* projector axis *)
        
(***** MCPU motion control routines *****)

Var Debugged : Boolean;     (* debugging flag *)

(* Pass along echoed input debugging status to MCPU library routines. *)

Procedure SetSioEcho;

Begin

   OutSioSt (Debugged);
   
End;

(***************************)

(* Input a character from ThingM and optionally echo out the Mac console. *)

Procedure InSioEcho (Var Ch : Char);

Begin

   InSio (Ch);
   If Debugged 
      Then Write (Ch);
End;

(* Get special event as input from ThingM to serial port. *)

Procedure GetSpecialEvent;

Var InStatus : Boolean;
    Ch : Char;
Begin

   InSioSt (InStatus);
   If InStatus
      Then InSioEcho (Ch);
End;

(***** Program specifics *****)

{$S InitSeg}

(* Check for axis ID. *)

Procedure Case_Axis (S2 : String; Var OK : Boolean; Var I : Integer);

Var J : Integer;

Begin

   OK := False;
   For J := 1 to Max_Axes Do
       If AA[J].A.Id = S2
          Then begin
               I := J;
               OK := True;
               end;
End; 

(* Initialize default axis table. *)

Procedure Init_Defaults;

Begin

   For I := 1 to Max_Axes Do
       With AA [I] Do
            begin
            Spec := True;
            With A Do
                 begin
                 Id [0] := Chr (2);
                 Id [1] := 'X';
                 Id [2] := Chr (Ord ('A') + I-1);
                 No     := I;
                 Name   := '---';
                 end;
            With M Do
                 begin
                 MotorNo:= I;
                 StepCnt:= 0.0;
                 Dir    := FWD;
                 AccelSt:= True;
                 Speed  := 500;
                 LowSpd := 250;
                 HighSpd:= 1000;
                 RampCnt:= 200;
                 RampK  := 0;
                 Stat   := '?';
                 Count  := 0.0;
                 Error  := False;
                 end;
            With K Do
                 begin
                 Kscale := 1.0;
                 DP     := 1;
                 Units  := 'Steps';
                 Cur_Step   := 0.0;
                 Cur_Posn   := 0.0;
                 end;
            With R Do
                 begin
                 AccelSt    := True;
                 Max_Speed  := 500;
                 Min_LowSpd := 250;
                 Max_HighSpd:= 1000;
                 Max_RampCnt:= 200;
                 end;
            With P Do
                 begin
                 Spec        := False;
                 StartFrame  := 0;
                 EndFrame    := 1;
                 StartPoint  := 0.0;
                 EndPoint    := 0.0;
                 Taper       := False;
                 Accel       := 0.0;
                 Decel       := 0.0;
                 IncrMax     := 0.0;
                 MoveType    := 'SIN';
                 Streak      := False;
                 InitlSize   := 0.0;
                 FinalSize   := 0.0;
                 end;
            Q [1] := 0.0;
            end;
End;

(* Initialize all Animal stuff. *)

Procedure Init_Program_Stuff;

Begin

  Frame_Count := 0;
  Camera_Count := 0;
  Projector_Count := 0;
  Sequencer_Count := 0;
  Sequencer := Alternate;
  Camera_Cycle := 1;
  Projector_Cycle := 1;
  Camera_Total := 0;
  Projector_Total := 0;
  Preset_Count := 1;
  
  Exposured := False;
  Reversed := False;
  SingleFramed := False;
    
  M.MotorNo := 1;
  M.StepCnt := 0.0;
  M.Dir     := FWD;
  M.AccelSt := True;
  M.Speed   := 800;
  M.LowSpd  := 400;
  M.HighSpd := 1600;
  M.RampCnt := 100;
  M.RampK   := 0;
  M.Stat    := '?';
  M.Count   := 0.0;
  M.Error   := False;
  
  Init_Defaults;
  
  Index := 1;
  
  (* Debugged := True; *)
  Debugged := False;
  SetSioEcho;
  
  ResetSio;
  
End;

(***** Screen support routines. *****)

{$S WindSeg}

(* ClearWindow clears window, draws grow stuff, sets location *)

procedure ClearWindow(WPtr : WindowPtr);
var
  TRect			: Rect;
begin
  if (WPtr = MainPtr) and (Wptr = FrontWindow ) then begin
    EraseRect(WPtr^.portRect);            { clear rect area of window   }
    DrawGrowIcon(WPtr);                   { draw grow icon              }
    TH := 5; TV := 12;                    { set text loc to upper left  }
    TextFont (Monaco);                    { select even-spaced font     }
    TextSize (9);
  end
end; { of proc ClearWindow }

(* DrawStr moves to text location and writes out Str *)

procedure DrawStr (Str : String);

begin
  MoveTo(TH,TV);                        { move to current text location }
  DrawString(Str);                      { write on screen               }
  TH := TH + StringWidth(Str)           { advance location to end of str}
end; { of proc DrawStart }

(* 'Draw' end of line, as in Writeln. *)

Procedure Drawln;

Begin

   TH := 5;                             (* 1st column for X *)
   TV := TV + 12;                       (* next row for Y *)
   MoveTo (TH, TV);                     (* move cursor there *)
   
End;
 
{   *********   items in User Menus      *********** }

Const BtnItem = 4;      (* button item type *)
      ChkItem = 5;      (* check box item type *)
      RadItem = 6;      (* radio button item type *)
      TextItem = 16;    (* edit text item type *)

Var The_Dialog : DialogPtr;         (* dialog box *)
    The_Item : Integer;             (* dialog item *)
    The_Type : Integer;             (* item type *)
    The_ItemHdl : Handle;           (* general item handle *)
    The_ItemBox : Rect;             (* item location coordinates *)
    The_BtnHdl,                     (* button item handle *)
    The_ChkHdl,                     (* check box handle *)
    The_RadHdl,                     (* radio button handle *)
    The_TextHdl : Handle;           (* text item handle *)    

(* Dialog for Initialize Motor *)

Procedure Get_Init_Options;

Const IM = 4;                   (* Init Motor item *)
      IL = 6;                   (* Init Low Speed item *)
      IH = 8;                   (* Init High Speed item *)
      IR = 10;                  (* Init Ramp Count item *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    
Begin

   The_Dialog := GetNewDialog (InitId, Nil, Pointer (-1));
   
   The_Text := IntToStr (M.MotorNo);
   GetDItem (The_Dialog, IM, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := IntToStr (M.LowSpd);
   GetDItem (The_Dialog, IL, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := IntToStr (M.HighSpd);
   GetDItem (The_Dialog, IH, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, IH, 0, Length (The_Text));
   The_Text := IntToStr (M.RampCnt);
   GetDItem (The_Dialog, IR, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then begin
             GetIText (The_ItemHdl, The_Text);
             Case The_Item of
                  IM : M.MotorNo := StrToInt (The_Text);
                  IL : M.LowSpd  := StrToInt (The_Text);
                  IH : M.HighSpd := StrToInt (The_Text);
                  IR : M.RampCnt := StrToInt (The_Text);
                  end;
             end;
   Until The_Type = BtnItem;
   DisposDialog (The_Dialog);
   
End;
  
(* Dialog for Run Motor *)

Procedure Get_Run_Options;

Const RM = 4;                   (* Run Motor item *)
      RR = 6;                   (* Run Run item *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    
Begin

   The_Dialog := GetNewDialog (RunId, Nil, Pointer (-1));
   
   The_Text := IntToStr (M.MotorNo);
   GetDItem (The_Dialog, RM, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := RealToStr (M.StepCnt, 0);
   GetDItem (The_Dialog, RR, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, RR, 0, Length (The_Text));
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then begin
             GetIText (The_ItemHdl, The_Text);
             Case The_Item of
                  RM : M.MotorNo := StrToInt (The_Text);
                  RR : M.StepCnt := StrToReal (The_Text);
                  end;
             end;
   Until The_Type = BtnItem;
   DisposDialog (The_Dialog);
   
End;

(* Dialog for Status Update *)
(* Status is sampled from MCPU here. *)

Procedure Get_Status_Update;

Const SM = 4;                   (* Status Motor item *)
      SS = 6;                   (* Status Status item *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    
Begin

   The_Dialog := GetNewDialog (StatId, Nil, Pointer (-1));
   
   The_Text := IntToStr (M.MotorNo);
   GetDItem (The_Dialog, SM, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, SM, 0, Length (The_Text));
   The_Text := '';
   GetDItem (The_Dialog, SS, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     Case The_Type of
     TextItem : begin
                GetIText (The_ItemHdl, The_Text);
                If The_Item = SM
                   Then M.MotorNo := StrToInt (The_Text);
                end;
     BtnItem  : If The_Item = Ok
                   Then begin
                   GetStat (M);
                   The_Text := M.Stat + '...' + Decode_Status (M);
                   GetDItem (The_Dialog, SS, The_Type, The_TextHdl, The_ItemBox);
                   SetIText (The_TextHdl, The_Text);
                   end;
                end;
   Until (The_Type = BtnItem) AND (The_Item = Cancel);
   DisposDialog (The_Dialog);
   
end;

(* Dialog for Position Update *)
(* Position is sampled from MCPU here. *)

Procedure Get_Position_Update;

Const PM = 4;                   (* Position Motor # item *)
      PP = 6;                   (* Position Position item *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    
Begin

   The_Dialog := GetNewDialog (PosnId, Nil, Pointer (-1));
   
   The_Text := IntToStr (M.MotorNo);
   GetDItem (The_Dialog, PM, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, PM, 0, Length (The_Text));
   The_Text := '';
   GetDItem (The_Dialog, PP, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     Case The_Type of
     TextItem : begin
                GetIText (The_ItemHdl, The_Text);
                If The_Item = PM
                   Then M.MotorNo := StrToInt (The_Text);
                end;
     BtnItem  : If The_Item = Ok
                   Then begin
                   GetCount (M);
                   The_Text := RealToStr (M.Count, 0);
                   GetDItem (The_Dialog, PP, The_Type, The_TextHdl, The_ItemBox);
                   SetIText (The_TextHdl, The_Text);
                   end;
                end;
   Until (The_Type = BtnItem) AND (The_Item = Cancel);
   DisposDialog (The_Dialog);
   
End;

(* Dialog for Jogging motor. *)
(* MCPU operations here. *)

Procedure Put_Jog_Keys;

Const JM = 4;                   (* Jog Motor item *)
      JI = 5;                   (* Jog Incremental item *)
      JC = 6;                   (* Jog Continuous item *)
      JF = 8;                   (* Jog Forward item *)
      JR = 7;                   (* Jog Reverse item *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    The_RadHdl : Handle;        (* Radio button item handle *)
    
    Incremental_Jogging : Boolean;      (* Increment per keystroke *)
    Continual_Running : Boolean;        (* Stop/Go status per keystroke *)
    Quit_Jogging : Boolean;             (* Quit jog dialog status *)
    
Begin

   Incremental_Jogging := True;
   Continual_Running := False;

   The_Dialog := GetNewDialog (JogId, Nil, Pointer (-1));
   
   The_Text := IntToStr (M.MotorNo);
   GetDItem (The_Dialog, JM, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, JM, 0, Length (The_Text));

   If Incremental_Jogging
      Then The_Item := JI
      Else The_Item := JC;
   GetDItem (The_Dialog, The_Item, The_Type, The_RadHdl, The_ItemBox);
   SetCtlValue (ControlHandle (The_RadHdl), 1);

   Quit_Jogging := False;
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     Case The_Type of
     TextItem : begin
                GetIText (The_ItemHdl, The_Text);
                If The_Item = SM
                   Then M.MotorNo := StrToInt (The_Text);
                end;
     RadItem  : begin
                SetCtlValue (ControlHandle (The_RadHdl), 0);
                SetCtlValue (ControlHandle (The_ItemHdl), 1);
                The_RadHdl := The_ItemHdl;
                Case The_Item of
                  JI : Incremental_Jogging := True;
                  JC : Incremental_Jogging := False;
                  end;
                end;
     BtnItem  : begin
                Case The_Item of
                  JF : M.Dir := FWD;
                  JR : M.Dir := REV;
                  OK : Quit_Jogging := False;
                  Cancel : Quit_Jogging := True;
                  end;
                If NOT Quit_Jogging 
                   Then If Incremental_Jogging
                             Then PulseM (M)
                        Else begin
                             If Continual_Running
                                Then KillM (M)
                                Else RunM (M);
                             Continual_Running := NOT Continual_Running;
                             end;
                end;
                end;
   Until Quit_Jogging;
   
   KillM (M);
   DisposDialog (The_Dialog);
   
end;

(*****)

(* Dialog for Move Motor Distance by user units. *)

Procedure Get_Move_Options;

Const RM = 4;                   (* Run Motor item *)
      RR = 6;                   (* Run Run item *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    Distance : Real;            (* move distance *)
    
Begin

   Distance := 0.0;

   The_Dialog := GetNewDialog (MoveId, Nil, Pointer (-1));
   
   The_Text := IntToStr (Index);
   GetDItem (The_Dialog, RM, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := RealToStr (Distance, AA[Index].K.dp);
   GetDItem (The_Dialog, RR, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, RR, 0, Length (The_Text));
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then begin
             GetIText (The_ItemHdl, The_Text);
             Case The_Item of
                  RM : If StrToInt (The_Text) in [1..Max_Axes]
                          Then Index := StrToInt (The_Text);
                  RR : Distance := StrToReal (The_Text);
                  end;
             end;
   Until The_Type = BtnItem;
   DisposDialog (The_Dialog);
   
   With AA [Index] Do
        begin
        If The_Item = Ok
           Then M.StepCnt := Distance * K.Kscale
           Else M.StepCnt := 0;
        PrepM (M);
        end;   
end;

(* Dialog for Goto Motor Position by user units. *)

Procedure Get_Goto_Options;

Const RM = 4;                   (* Run Motor item *)
      RR = 6;                   (* Run Run item *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    Destination : Real;         (* Goto Destination *)
    
Begin

   With AA [Index] Do
        begin
        GetCount (M);
        Destination := M.Count / K.Kscale;
        end;
        
   The_Dialog := GetNewDialog (GotoId, Nil, Pointer (-1));
   
   The_Text := IntToStr (Index);
   GetDItem (The_Dialog, RM, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := RealToStr (Destination, AA [Index].K.dp);
   GetDItem (The_Dialog, RR, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, RR, 0, Length (The_Text));
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then begin
             GetIText (The_ItemHdl, The_Text);
             Case The_Item of
                  RM : If StrToInt (The_Text) in [1..Max_Axes]
                          Then Index := StrToInt (The_Text);
                  RR : Destination := StrToReal (The_Text);
                  end;
             end;
   Until The_Type = BtnItem;
   DisposDialog (The_Dialog);

   With AA [Index] Do
        begin   
        GetCount (M);
        If The_Item = OK
           Then M.StepCnt := Destination * K.Kscale - M.Count
           Else M.StepCnt := 0;
        PrepM (M);
        end;   
end;

(* Dialog for Limit Motor *)

Procedure Get_Limit_Options;

Const LM = 5;                   (* Limit Motor item *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    
Begin

   The_Dialog := GetNewDialog (LimId, Nil, Pointer (-1));
   
   The_Text := IntToStr (Index);
   GetDItem (The_Dialog, LM, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, LM, 0, Length (The_Text));
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then begin
             GetIText (The_ItemHdl, The_Text);
             Case The_Item of
                  LM : If StrToInt (The_Text) in [1..Max_Axes]
                          Then Index := StrToInt (The_Text);
                  end;
             end;
   Until The_Type = BtnItem;
   DisposDialog (The_Dialog);
   
end;

(* Dialog for Zero Motor Position. *)

Procedure Get_Zero_Options;

Const ZM = 5;                   (* Zero Motor item *)
     
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    
Begin

   The_Dialog := GetNewDialog (ZeroId, Nil, Pointer (-1));
   
   The_Text := IntToStr (Index);
   GetDItem (The_Dialog, ZM, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, ZM, 0, Length (The_Text));
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then begin
             GetIText (The_ItemHdl, The_Text);
             Case The_Item of
                  ZM : If StrToInt (The_Text) in [1..Max_Axes]
                          Then Index := StrToInt (The_Text);
                  end;
             end;
   Until The_Type = BtnItem;
   DisposDialog (The_Dialog);
   
end;

(*****)

(* Window for running Frame Counts. *)
(* Poll Status and Position updates from MCPU here. *)

(* Open dialog window with initial labels and counter data. *)

Procedure Get_Frame_Counts;

Const CS = 3;                   (* Camera string item *)
      CT = 4;                   (* Camera Total item *)
      PS = 5;                   (* Projector string item *)
      PT = 6;                   (* Projector Total item *)

Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    
Begin

   The_Dialog := GetNewDialog (FrmId, Nil, Pointer (-1));

   The_Text := 'Camera Frame';
   GetDItem (The_Dialog, CS, The_Type, The_TextHdl, The_ItemBox);   
   SetIText (The_TextHdl, The_Text);
   The_Text := IntToStr (Camera_Total);
   GetDItem (The_Dialog, CT, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := 'Projector Frame';
   GetDItem (The_Dialog, PS, The_Type, The_TextHdl, The_ItemBox);   
   SetIText (The_TextHdl, The_Text);
   The_Text := IntToStr (Projector_Total);
   GetDItem (The_Dialog, PT, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);

   ShowWindow (WindowPtr (The_Dialog));
   
End;

(* Update counter data in window. *)

Procedure Put_Frame_Counts;

Const CS = 3;                   (* Camera string item *)
      CT = 4;                   (* Camera Total item *)
      PS = 5;                   (* Projector string item *)
      PT = 6;                   (* Projector Total item *)

Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    The_Event : EventRecord;    (* user interruption event *)
    The_CtrlHdl : Handle;       (* Button control item handle *)
    
Begin

   If The_Dialog <> NIL Then begin

   The_Text := IntToStr (Camera_Total);
   GetDItem (The_Dialog, CT, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := IntToStr (Projector_Total);
   GetDItem (The_Dialog, PT, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
      
   ShowWindow (WindowPtr (The_Dialog));
   
   If KeyPressed Or Button 
      Then begin
      GetDItem (The_Dialog, Ok, The_Type, The_CtrlHdl, The_ItemBox);
      HiliteControl (ControlHandle (The_CtrlHdl), 1);
      If KeyPressed
         Then If ReadChar = ^M
              Then;
      GetDItem (The_Dialog, Ok, The_Type, The_CtrlHdl, The_ItemBox);
      SetCTitle (ControlHandle(The_CtrlHdl), 'Go');
      HiliteControl (ControlHandle (The_CtrlHdl), 0);
      Repeat
        ModalDialog (Nil, The_Item);
        GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
      Until The_Type = BtnItem;
      GetDItem (The_Dialog, Ok, The_Type, The_CtrlHdl, The_ItemBox);
      SetCTitle (ControlHandle(The_CtrlHdl), 'Stop');
      end;
      
   end;     (* insure dialog box pointer has been created *)
   
End;

(* Close window and release pointer. *)

Procedure Trash_Frame_Counts;

Begin
   
   DisposDialog (The_Dialog);
   
End;

(* Edit cummulative Frame Counters. *)

Procedure Edit_Frame_Counts;

Const CS = 3;                   (* Camera string item *)
      CT = 4;                   (* Camera Total item *)
      PS = 5;                   (* Projector string item *)
      PT = 6;                   (* Projector Total item *)

Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    The_CtrlHdl : Handle;       (* control button handle *)
    
Begin

   The_Dialog := GetNewDialog (FrmId, Nil, Pointer (-1));

   The_Text := IntToStr (Camera_Total);
   GetDItem (The_Dialog, CT, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelIText (The_Dialog, CT, 0, Length (The_Text));
   The_Text := IntToStr (Projector_Total);
   GetDItem (The_Dialog, PT, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   
   GetDItem (The_Dialog, Ok, The_Type, The_CtrlHdl, The_ItemBox);
   SetCTitle (ControlHandle(The_CtrlHdl), 'Ok');
      
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then begin
             GetIText (The_ItemHdl, The_Text);
             Case The_Item of
             CT : Camera_Total := StrToInt (The_Text);
             PT : Projector_Total := StrToInt (The_Text);
             end;
             end;
   Until (The_Type = BtnItem);
   
   DisposDialog (The_Dialog);
         
End;

(*****)

(* Edit preset Frame Count. *)

Procedure Edit_Preset_Counts;

Const FS = 3;                   (* Frame string item *)
      FX = 4;                   (* Frame Count item *)
      TS = 5;                   (* Time string item *)
      TX = 6;                   (* Time Frame item *)

Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    The_CtrlHdl : Handle;       (* control button handle *)
    Screen_Time : Real;         (* frame count screen time *)
    
Begin

   The_Dialog := GetNewDialog (PFrmId, Nil, Pointer (-1));

   The_Text := IntToStr (Preset_Count);
   GetDItem (The_Dialog, FX, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelIText (The_Dialog, FX, 0, Length (The_Text));
   Screen_Time := Preset_count / 24.0;
   The_Text := RealToStr (Screen_Time, 2);
   GetDItem (The_Dialog, TX, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then begin
             GetIText (The_ItemHdl, The_Text);
             Case The_Item of
             FX : begin 
                  Preset_Count := StrToInt (The_Text);
                  Screen_Time := Preset_Count / 24.0;
                  end;
             TX : begin
                  Screen_Time := StrToReal (The_Text);
                  Preset_Count := Round (Screen_Time * 24.0);
                  end;
             end;
             end;
   Until (The_Type = BtnItem);
   
   DisposDialog (The_Dialog);
         
End;

(* Dialog for Axis Position Cues. *)

Procedure Get_Axis_Increments (Var P : Parameter_Table);

Const SF = 4;                   (* Start Frame item *)
      EF = 6;                   (* End Frame item *)
      SP = 8;                   (* Start Position *)
      EP = 10;                  (* End Position *)
      ST = 12;                  (* Start Taper In *)
      ET = 14;                  (* End Taper Out *)

Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    
Begin

   The_Dialog := GetNewDialog (AxisId, Nil, Pointer (-1));
   
   The_Text := IntToStr (P.StartFrame);
   GetDItem (The_Dialog, SF, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := IntToStr (P.EndFrame);
   GetDItem (The_Dialog, EF, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := RealToStr (P.StartPoint, 3);
   GetDItem (The_Dialog, SP, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, SP, 0, Length (The_Text));
   The_Text := RealToStr (P.EndPoint, 3);
   GetDItem (The_Dialog, EP, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := RealToStr (P.Accel, 1);
   GetDItem (The_Dialog, ST, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := RealToStr (P.Decel, 1);
   GetDItem (The_Dialog, ET, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then begin
             GetIText (The_ItemHdl, The_Text);
             Case The_Item of
                  SF : P.StartFrame := StrToInt (The_Text); 
                  EF : P.EndFrame := StrToInt (The_Text);
                  SP : P.StartPoint := StrToReal (The_Text);
                  EP : P.EndPoint := StrToReal (The_Text);
                  ST : P.Accel := StrToReal (The_Text);
                  ET : P.Decel := StrToReal (The_Text);
                  end;
             If P.EndFrame > Preset_Count
                Then Preset_Count := P.EndFrame;
             P.Taper := (P.Accel + P.Decel > 0.0);
             end;
   Until (The_Type = BtnItem);
   
   DisposDialog (The_Dialog);
   
End;

(*****)

(* Dialog for Camera Overide. *)

Procedure Get_Camera_Options;

Const CC = 4;                   (* Camera Count item *)

Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    
Begin

   The_Dialog := GetNewDialog (CamId, Nil, Pointer (-1));
   
   The_Text := IntToStr (Camera_Count);
   GetDItem (The_Dialog, CC, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, CC, 0, Length (The_Text));
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then GetIText (The_ItemHdl, The_Text);
   Until The_Type = BtnItem;
   DisposDialog (The_Dialog);
   
   Camera_Count := StrToInt (The_Text);
   If The_Item = Ok
      Then Frame_Count := Camera_Count
      Else Frame_Count := 0;

End;

(* Dialog for Projector Overide. *)

Procedure Get_Projector_Options;

Const PC = 4;                   (* Projector Count item *)

Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    
Begin

   The_Dialog := GetNewDialog (PrjId, Nil, Pointer (-1));
   
   The_Text := IntToStr (Projector_Count);
   GetDItem (The_Dialog, PC, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, PC, 0, Length (The_Text));
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then GetIText (The_ItemHdl, The_Text);
   Until The_Type = BtnItem;
   DisposDialog (The_Dialog);
   
   Projector_Count := StrToInt (The_Text);
   If The_Item = Ok
      Then Frame_Count := Projector_Count
      Else Frame_Count := 0;

End;

(* Dialog for Sequencer options. *)

Procedure Get_Sequencer_Options;

Const B1 = 1;                   (* Ok button item *)
      B2 = 2;                   (* Cancel button item *)
      RA = 3;                   (* Alternate radio item *)
      RC = 4;                   (* Camera-Step radio item *)
      RP = 5;                   (* Projector-Skip radio item *)
      SC = 7;                   (* Camera Count string item *)
      SP = 9;                   (* Projector Count string item *)
      SS = 11;                  (* Sequencer Count string item *)
      
Var The_RadHdl : Handle;        (* radio button item handle *)
    The_TextHdl : Handle;       (* text item handle *)
    The_Text : Str255;          (* text string *)
    
Begin

   The_Dialog := GetNewDialog (SeqId, Nil, Pointer (-1));

   (* init camera, projector, and sequencer count strings *)
   The_Text := IntToStr (Camera_Cycle);
   GetDItem (The_Dialog, SC, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := IntToStr (Projector_Cycle);
   GetDItem (The_Dialog, SP, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := IntToStr (Sequencer_Count);
   GetDItem (The_Dialog, SS, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, SS, 0, Length (The_Text));
   
   (* init 1st radio button = item #3 for sequencer mode *)
   Case Sequencer of
        Alternate       : The_Item := RA;
        StepCamera      : The_Item := RC;
        SkipProjector   : The_Item := RP;
        Otherwise         The_Item := 0;
        end; 
   GetDItem (The_Dialog, The_Item, The_Type, The_RadHdl, The_ItemBox);
   SetCtlValue (ControlHandle (The_RadHdl), 1);
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     Case The_Type Of
       TextItem : begin
                  GetIText (The_ItemHdl, The_Text);
                  Case The_Item Of
                       SC : Camera_Cycle := StrToInt (The_Text);
                       SP : Projector_Cycle := StrToInt (The_Text);
                       SS : Sequencer_Count := StrToInt (The_Text);
                       end;
                  end;
        RadItem : begin
                  SetCtlValue (ControlHandle (The_RadHdl), 0);
                  SetCtlValue (ControlHandle (The_ItemHdl), 1);
                  The_RadHdl := The_ItemHdl;
                  Case The_Item Of
                       RA : Sequencer := Alternate;
                       RC : Sequencer := StepCamera;
                       RP : Sequencer := SkipProjector;
                       Otherwise Sequencer := None;
                       end;
                  end;
        BtnItem : Case The_Item Of
                       B1 : Frame_Count := Sequencer_Count;
                       B2 : Frame_Count := 0;
                       end;
        end;
   Until The_Type = BtnItem;
   DisposDialog (The_Dialog);

End;

(* Dialog for Stop Motion run-time options. *)

Procedure Get_StopMotion_Options;

Const B1 = 1;                   (* Ok button item *)
      B2 = 2;                   (* Cancel button item *)
      SS = 4;                   (* Start Frame item *)
      SE = 6;                   (* End Frame item *)
      RX = 7;                   (* Exposures On radio item *)
      RN = 8;                   (* Exposures Off radio item *)
      RF = 9;                   (* Forward Run radio item *)
      RR = 10;                  (* Reverse Run radio item *)
      RM = 11;                  (* Manual Run  radio item *)
      RA = 12;                  (* Automatic Run radio item *)
      
Var The_RadHdl : Handle;        (* radio button item handle *)
    The_TextHdl : Handle;       (* text item handle *)
    The_Text : Str255;          (* text string *)
    Start_Run : Integer;        (* start run frame *)
    End_Run : Integer;          (* end run frame *)
    RHA : Array [RX..RA] of Handle;      (* array of radio button handles *)
    
Begin

   The_Dialog := GetNewDialog (StopId, Nil, Pointer (-1));

   Start_Run := 0;
   End_Run := Preset_Count;
   
   The_Text := '0';
   GetDItem (The_Dialog, SS, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   The_Text := IntToStr (Preset_Count);
   GetDItem (The_Dialog, SE, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelItext (The_Dialog, SE, 0, Length (The_Text));

   For The_Item := RX to RA Do
       begin
       GetDItem (The_Dialog, The_Item, The_Type, The_RadHdl, The_ItemBox);
       RHA [The_Item] := The_RadHdl;
       end;
   If Exposured
      Then SetCtlValue (ControlHandle (RHA [RX]), 1)
      Else SetCtlValue (ControlHandle (RHA [RN]), 1);
   If NOT Reversed
      Then SetCtlValue (ControlHandle (RHA [RF]), 1)
      Else SetCtlValue (ControlHandle (RHA [RR]), 1);
   If SingleFramed
      Then SetCtlValue (ControlHandle (RHA [RM]), 1)
      Else SetCtlValue (ControlHandle (RHA [RA]), 1);
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     Case The_Type Of
       TextItem : begin
                  GetIText (The_ItemHdl, The_Text);
                  Case The_Item Of
                       SS : Start_Run := StrToInt (The_Text);
                       SE : End_Run := StrToInt (The_Text);
                       end;
                  end;
        RadItem : begin
                  The_RadHdl := The_ItemHdl;
                  SetCtlValue (ControlHandle (The_RadHdl), 1);
                  Case The_Item Of
                       RX : Exposured := True;
                       RN : Exposured := False;
                       RF : Reversed := False;
                       RR : Reversed := True;
                       RM : SingleFramed := True;
                       RA : SingleFramed := False;
                       end;
                  Case The_Item Of
                       RX : SetCtlValue (ControlHandle (RHA [RN]), 0);
                       RN : SetCtlValue (ControlHandle (RHA [RX]), 0);
                       RF : SetCtlValue (ControlHandle (RHA [RR]), 0);
                       RR : SetCtlValue (ControlHandle (RHA [RF]), 0);
                       RM : SetCtlValue (ControlHandle (RHA [RA]), 0);
                       RA : SetCtlValue (ControlHandle (RHA [RM]), 0);
                       end;
                  end;
        BtnItem : Case The_Item Of
                       B1 : Frame_Count := End_Run - Start_Run;
                       B2 : Frame_Count := 0;
                       end;
        end;
   Until The_Type = BtnItem;
   DisposDialog (The_Dialog);

End;

(*****)

(* Dialog for Axis Mapping. *)

Procedure Get_Axis_Map_Options;

Const AI = 4;                   (* Axis ID item *)
      AM = 6;                   (* Axis Motor item *)
      AN = 8;                   (* Axis Name *)
      AmapId2 = 2051;           (* nested dialog box Id *)
      MaxCh = 30;               (* max string width *)
      
Type  StringX = String [MaxCh]; (* pick list string type *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    Init_Dialog : DialogPtr;    (* nested dialog box for selections *)
    PS : Array [1..Max_Axes] of StringX;    (* pick list string *)
    Mouse_Pt : Point;                       (* mouse click location *)
    Yes_Box : Rect;                         (* Okay button location *)
    No_Box  : Rect;                         (* Cancel button loaction *)
    Mouse_Event : EventRecord;              (* mouse click event *)

Begin

   Init_Dialog := GetNewDialog (AmapId, Nil, Pointer (-1));
   SetPort (Init_Dialog);                   (* for local coordinates *)
   
   GetDItem (Init_DIalog, Ok, The_Type, The_ItemHdl, Yes_Box);
   GetDItem (Init_Dialog, Cancel, The_Type, The_ItemHdl, No_Box);
   
   GetDItem (Init_Dialog, AI-1, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, 'AXIS    ID     DESCRIPTION');
   
   The_Text := '';
   For I := 1 to Max_Axes Do
       With AA[I].A Do
            PS[I] := Id + '       ' + IntToStr (No) + '       ' + Name;
   For I := 1 to Max_Axes Do
       begin
       While Length (PS[I]) < MaxCh Do
          PS[I] := PS[I] + ' ';
       PS[I][MaxCh] := ^M;
       The_Text := The_Text + PS[I];
       end;
   GetDItem (Init_Dialog, AI, The_Type, The_TextHdl, The_ItemBox);
   SetIText (The_TextHdl, The_Text);
   SelIText (Init_Dialog, AI, 0, Length (PS[1]));
   ShowWindow (WindowPtr(Init_Dialog));

   I := 1;   
   Repeat
      Repeat
         Repeat 
         Until GetNextEvent (mDownMask, Mouse_Event);
      Until Mouse_Event.What = MouseDown;
      SelIText (Init_Dialog, AI, 0, 0);
      ShowWindow (Init_Dialog);
      GlobalToLocal (Mouse_Event.Where);        (* for local coordinates *)
      Mouse_Pt := Mouse_Event.Where;
      If PtInRect (Mouse_Pt, The_ItemBox)
         Then I := Round (0.5 + 8.0 * (Mouse_Pt.V - The_ItemBox.Top)
                          / (The_ItemBox.Bottom - The_ItemBox.Top));
      If I < 1 
         Then I := 1
      Else If I > Max_Axes
         Then I := Max_Axes;
      SelIText (Init_Dialog, AI, (I-1)*Length (PS[I]), I*Length (PS[I]));
      ShowWindow (Init_Dialog);
   Until (PtInRect (Mouse_Pt, Yes_Box)) Or (PtInRect (Mouse_Pt, No_Box)); 

   If PtInRect (Mouse_Pt, Yes_Box)
      Then begin
      The_Dialog := GetNewDialog (AmapId2, Nil, Pointer (-1));
      With AA [I] Do
           begin
           The_Text := A.Id;
           GetDItem (The_Dialog, AI, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           The_Text := IntToStr (A.No);
           GetDItem (The_Dialog, AM, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           The_Text := A.Name;
           GetDItem (The_Dialog, AN, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           SelItext (The_Dialog, AN, 0, Length (The_Text));
           end;
      Repeat
        ModalDialog (Nil, The_Item);
        GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
        If The_Type = TextItem
           Then begin
                GetIText (The_ItemHdl, The_Text);
                With AA [I] Do
                Case The_Item of
                     AI : A.Id := The_Text;
                     AM : A.No := StrToInt (The_Text);
                     AN : A.Name := The_Text;
                     end;
                end;
      Until (The_Type = BtnItem);
      DisposDialog (The_Dialog);
      end;
      
   DisposDialog (Init_Dialog);
End;

(* Dialog for User Units. *)

Procedure Get_User_Units_Options;

Const UX = 4;                   (* User Axis item *)
      UU = 6;                   (* User Unit item *)
      UK = 8;                   (* User K-scaler item *)
      UD = 10;                  (* User 1/K-scaler item *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    QQ : String [2];            (* axis Id *)
    Axis_Okay : Boolean;        (* axis Id okay *)
    J : Integer;                (* temp axis index *)
    
Begin

   The_Dialog := GetNewDialog (UnitId, Nil, Pointer (-1));

   I := 1;
   QQ := AA[I].A.Id;
   Axis_Okay := True;   
   Repeat
      If Axis_Okay Then With AA [I] Do
           begin
           The_Text := A.Id;
           GetDItem (The_Dialog, UX, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           The_Text := K.Units;
           GetDItem (The_Dialog, UU, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           SelItext (The_Dialog, UU, 0, Length (The_Text));
           The_Text := RealToStr (K.Kscale, K.DP);
           GetDItem (The_Dialog, UK, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           The_Text := RealToStr (1.0 / K.Kscale, K.DP);
           GetDItem (The_Dialog, UD, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           Axis_Okay := False;
           end;
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then begin
             GetIText (The_ItemHdl, The_Text);
             With AA [I] Do
             Case The_Item of
                  UU : K.Units := The_Text;
                  UK : K.Kscale := StrToReal (The_Text);
                  UD : K.Kscale := 1.0 / StrToReal (The_Text);
                  UX : QQ := The_Text;
                  end;
             end;
      If (The_Type = BtnItem) AND (The_Item = Ok)
         Then begin
              Case_Axis (QQ, Axis_Okay, J);
              If Axis_Okay Then I := J;
              end;
   Until (The_Type = BtnItem) AND (The_Item = Cancel);
   DisposDialog (The_Dialog);
   
End;

(* Dialog for Motor Speeds. *)

Procedure Get_Motor_Profile_Options;

Const MX = 4;                   (* Motor item *)
      ML = 6;                   (* Low Speed item *)
      MH = 8;                   (* High Speed item *)
      MR = 10;                  (* Ramp Count item *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    QQ : String [2];            (* axis Id *)
    Axis_Okay : Boolean;        (* axis Id okay *)
    J : Integer;                (* temp axis index *)
    
Begin

   The_Dialog := GetNewDialog (MspdId, Nil, Pointer (-1));

   I := 1;
   QQ := AA[I].A.Id;
   Axis_Okay := True;   
   Repeat
      If Axis_Okay Then With AA [I] Do
           begin
           The_Text := A.Id;
           GetDItem (The_Dialog, MX, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           The_Text := RealToStr (R.Min_LowSpd, 0);
           GetDItem (The_Dialog, ML, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           SelItext (The_Dialog, ML, 0, Length (The_Text));
           The_Text := RealToStr (R.Max_HighSpd, 0);
           GetDItem (The_Dialog, MH, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           The_Text := RealToStr (R.Max_RampCnt, 0);
           GetDItem (The_Dialog, MR, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           Axis_Okay := False;
           end;
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then begin
             GetIText (The_ItemHdl, The_Text);
             With AA [I] Do
             Case The_Item of
                  ML : R.Min_LowSpd  := StrToReal (The_Text);
                  MH : R.Max_HighSpd := StrToReal (The_Text);
                  MR : R.Max_RampCnt := StrToReal (The_Text);
                  MX : QQ := The_Text;
                  end;
             end;
      If (The_Type = BtnItem) AND (The_Item = Ok)
         Then begin
              Case_Axis (QQ, Axis_Okay, J);
              If Axis_Okay Then I := J;
              end;
   Until (The_Type = BtnItem) AND (The_Item = Cancel);
   DisposDialog (The_Dialog);
   
End;

(***** Overide routines *****)

(* Initialize motor speed. *)

Procedure Do_Init_Motor;

Begin

   DrawStr ('Initialize Motor...');
   Get_Init_Options;
   If The_Item = Ok 
      Then InitM (AA [Index].M);
   
End;

(* Run motor. *)

Procedure Do_Run_Motor;

Begin
   
   DrawStr ('Run Motor...');
   Get_Run_Options;
   If The_Item = Ok 
      Then With AA [Index] Do 
           begin 
           PrepM (M);
           WaitOver;
           RunM (M);
           end;

End;

(* Kill both motors, running or not. *)

Procedure Do_Kill_Motor;

Begin

   DrawStr ('Kill Motor...');
   For I := 1 to Max_Axes Do
       KillM (AA[I].M);
   Drawln;

End;

(* Get motor running status. *)

Procedure Do_Status_Motor;

Begin

   DrawStr ('Status for Motor...');
   Get_Status_Update;

End;

(* Get motor position. *)

Procedure Do_Position_Motor;

Begin

   DrawStr ('Position for Motor...');
   Get_Position_Update;
   
End;

(* Run motor into limit switch position. *)

Procedure Do_Limit_Motor;

Begin

   DrawStr ('Limit Switch Run Motor...');
   Get_Limit_Options;
   If The_Item = Ok 
      Then HomeM (AA [Index].M);
   
End;

(* Move motor by user units. *)

Procedure Do_Move_Motor;

Begin

   DrawStr ('Move Motor...');
   Get_Move_Options;
   If The_Item = OK 
      Then RunM (AA [Index].M);
   
End;

(* Goto motor position by user units. *)

Procedure Do_Goto_Motor;

Begin

   DrawStr ('Goto Motor Position...');
   Get_Goto_Options;
   If The_Item = OK 
      Then RunM (AA [Index].M);
   
End;

(* Jog motor using keyboard arrow keys. *)

Procedure Do_Jog_Motor;

Begin

   DrawStr ('Jog Motor...');
   Drawln;
   Put_Jog_Keys;

End;

(* Zero motor stepping position. *)

Procedure Do_Zero_Motor;

Begin

   DrawStr ('Zero Motor Position...');
   Get_Zero_Options;
   If The_Item = OK 
      Then ZeroM (AA [Index].M);
   
End;

(***** Sequencer routines *****)


(* Run camera motor. *)
(* 1 camera frame = 400 half steps per revolution. *)

Procedure Pre_Run_Camera (F : Integer);

Begin

   With AA [CX] Do 
        begin
        M.StepCnt := F * K.Kscale;
        PrepM (M);
        WaitOver;
        end;   
End;

Procedure Run_Camera (F : Integer);

Begin

   With AA [CX] Do 
        RunM  (M);
End;

(* Run projector motor. *)
(* 1 projector frame = 200 full steps per revolution. *)

Procedure Pre_Run_Projector (F : Integer);

Begin

   With AA [PX] Do
        begin
        M.StepCnt := F * K.Kscale;
        PrepM (M);
        WaitOver;
        end;   
End;

Procedure Run_Projector (F : Integer);

Begin

   With AA [PX] Do
        RunM  (M);
End;

(* Run Camera only. *)

Procedure Do_Camera;

Var F : Integer;
Var C : Integer;
    Single : Integer;
    Ticker : LongInt;
Begin

   DrawStr ('Camera...');
   Get_Camera_Options;
   DrawStr (IntToStr (Frame_Count));
   Drawln;

   If The_Item = Ok
      Then begin
      Get_Frame_Counts;
      If Frame_Count = 0
         Then Single := 0
         Else Single := Frame_Count DIV Abs (Frame_Count);
      Pre_Run_Camera (Frame_Count);
      Run_Camera (Frame_Count);
      Ticker := TickCount;
      WaitOver;
      For C := 1 to Abs (Frame_Count) do
          begin
          Camera_Total := Camera_Total + Single;
          Put_Frame_Counts;
          Repeat 
          Until TickCount >= Ticker + C * 
                (* Round (60.0 * AA[CX].K.Kscale / AA[CX].M.HighSpd); *)
                Round (60.0 * AA[CX].K.Kscale / (AA[CX].M.HighSpd/100.0));
          end;
      WaitOver;
      Trash_Frame_Counts;
      end;
End;

(* Run Projector only. *)

Procedure Do_Projector;

Var F : Integer;
Var P : Integer;
    Single : Integer;
Begin

   DrawStr ('Projector...');
   Get_Projector_Options;
   DrawStr (IntToStr (Frame_Count));
   Drawln;
   
   If The_Item = Ok
      Then begin
      Get_Frame_Counts;
      If Frame_Count = 0
         Then Single := 0
         Else Single := Frame_Count DIV Abs (Frame_Count);
      Pre_Run_Projector (Single);
      For P := 1 to Abs (Frame_Count) do
          begin
          If KeyPressed Or Button
             Then Put_Frame_Counts;
          If Not (The_Item = Cancel)
             Then begin
             Run_Projector (Single);
             WaitOver;
             Projector_Total := Projector_Total + Single;
             Put_Frame_Counts;
             WaitOver;
             (* HomeM (AA[PX].M);
             (* WaitOver;         (* locate home switch *)
             end;
          end;
      Trash_Frame_Counts;
      end;
End;

(* Run Sequencer between camera and projector. *)

Procedure Do_Sequencer;

Var F : Integer;
    C, P : Integer;
    CSingle, PSingle : Integer;
    Ticker : LongInt;
Begin

   DrawStr ('Sequencer...');
   Get_Sequencer_Options;
   DrawStr (IntToStr (Frame_Count));
   Drawln;

   If The_Item = Ok Then begin
      
   Case Sequencer of
      
   Alternate : begin
      
      Get_Frame_Counts;
      If Camera_Cycle = 0
         Then CSingle := 0
         Else CSingle := Camera_Cycle DIV Abs (Camera_Cycle);
      If Projector_Cycle = 0
         Then PSingle := 0
         Else PSingle := Projector_Cycle DIV Abs (Projector_Cycle);
      Pre_Run_Camera (Camera_Cycle);
      Pre_Run_Projector (PSingle);
      For F := 1 to Abs (Frame_Count) do
          begin
          If KeyPressed Or Button
             Then Put_Frame_Counts;
          If Not (The_Item = Cancel)
             Then begin
             Run_Camera (Camera_Cycle);
             Ticker := TickCount;
             WaitOver;
             For C := 1 to Abs (Camera_Cycle) Do
                 begin
                 Camera_Total := Camera_Total + CSingle;
                 Put_Frame_Counts;
                 Repeat 
                 Until TickCount >= Ticker + C *
                   (* Round (60.0 * AA[CX].K.Kscale / AA[CX].M.Highspd);*)
                   Round (60.0 * AA[CX].K.Kscale / (AA[CX].M.Highspd/100.0));
                 end;
             WaitOver;
             
             For P := 1 to Abs (Projector_Cycle) do
                 begin
                 Run_Projector (PSingle);
                 WaitOver;
                 Projector_Total := Projector_Total + PSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 (* HomeM (AA[PX].M);
                 (* WaitOver;         (* locate home switch *)
                 end;
             end;
          end;
      Trash_Frame_Counts;
      end;      (* Alternate Sequencer *)
      
   StepCamera : begin
   
      Get_Frame_Counts;
      If Camera_Cycle = 0
         Then CSingle := 0
         Else CSingle := Camera_Cycle DIV Abs (Camera_Cycle);
      Pre_Run_Camera (CSingle);
      If Projector_Cycle = 0
         Then PSingle := 0
         Else PSingle := Projector_Cycle DIV Abs (Projector_Cycle);
      Pre_Run_Projector (PSingle);
      For F := 1 to Abs (Frame_Count) do
          begin
          If KeyPressed Or Button
             Then Put_Frame_Counts;
          If Not (The_Item = Cancel)
             Then begin
             For P := 1 to Abs (Projector_Cycle) do
                 begin
                 Run_Camera (CSingle);
                 WaitOver;
                 Camera_Total := Camera_Total + CSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 Run_Projector (PSingle);
                 WaitOver;
                 Projector_Total := Projector_Total + PSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 end;
             For C := 1 to Abs (Camera_Cycle - 1) do
                 begin
                 Run_Camera (CSingle);
                 WaitOver;
                 Camera_Total := Camera_Total + CSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 end;
             end;
          end;
      Trash_Frame_Counts;
      end;      (* StepCamera Sequencer *)
      
   SkipProjector : begin
   
      Get_Frame_Counts;
      If Camera_Cycle = 0
         Then CSingle := 0
         Else CSingle := Camera_Cycle DIV Abs (Camera_Cycle);
      Pre_Run_Camera (CSingle);
      If Projector_Cycle = 0
         Then PSingle := 0
         Else PSingle := Projector_Cycle DIV Abs (Projector_Cycle);
      Pre_Run_Projector (PSingle);
      For F := 1 to Abs (Frame_Count) do
          begin
          If KeyPressed Or Button
             Then Put_Frame_Counts;
          If Not (The_Item = Cancel)
             Then begin
             For C := 1 to Abs (Camera_Cycle) do
                 begin
                 Run_Camera (CSingle);
                 WaitOver;
                 Camera_Total := Camera_Total + CSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 Run_Projector (PSingle);
                 WaitOver;
                 Projector_Total := Projector_Total + PSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 end;
             For P := 1 to Abs (Projector_Cycle - 1) do
                 begin
                 Run_Projector (PSingle);
                 WaitOver;
                 Projector_Total := Projector_Total + PSingle;
                 Put_Frame_Counts;
                 WaitOver;
                 end;
             end;
          end;
      Trash_Frame_Counts;
      end;      (* SkipProjector Sequencer *)
      
   end;         (* case Sequencer *)
   end;         (* if Sequencer at all *)   
End;

(* Run Stop Motion sequence. *)

Procedure Do_Stop_Motion;

Var F : Integer;
    Increment : Real;
    Position  : Real;
    Ch : Char;
Begin

   DrawStr ('Run Stop Motion sequence...');
   Drawln;
   Get_StopMotion_Options;

   If The_Item = Ok
      Then begin
      Writeln;
      Pre_Run_Camera (1);
      Pre_Run_Projector (1);
      Index := 2;
      Position := AA [Index].Q[0];
      Projector_Total := Round (Position);
      Get_Frame_Counts;
      GetDItem (The_Dialog, 5, The_Type, The_TextHdl, The_ItemBox);
      SetIText (The_TextHdl, 'Step Count');

      For F := 1 to Preset_Count Do
          begin
          If KeyPressed Or Button
             Then Put_Frame_Counts;
          If Not (The_Item = Cancel)
             Then begin
             If Exposured
                Then begin
                Run_Camera (1);
                WaitOver;
                Camera_Total := Camera_Total + 1;
                Put_Frame_Counts;
                WaitOver;
                end;
             With AA [Index] Do
                begin
                Increment := Q [F] - Q [F-1];
                M.StepCnt := K.Kscale * Increment;
                M.StepCnt := Abs (M.StepCnt);
                If M.StepCnt < 8.0
                   Then M.StepCnt := 8.0;
                DriveM (M);
                WaitOver;
                RunM (M);
                WaitOver;
                Position := Position + Increment;
                Writeln (F:10, Increment:10:K.dp, Position:10:K.dp);
                Projector_Total := Round (Position);
                Put_Frame_Counts;
                WaitOver;
                If SingleFramed
                   Then begin
                   Repeat Until KeyPressed Or Button;
                   If KeyPressed
                      Then Ch := ReadChar;
                   If Button
                      Then Repeat
                         TpDelay (15); 
                      Until Not Button;
                   end;
                end;
             end;
          end;
      Trash_Frame_Counts;
      end;
End;

(* Run Go Motion sequence. *)

Procedure Do_Go_Motion;

Begin

   Do_Stop_Motion;
   
End;

(* Run Continuous Motion sequence. *)

Procedure Do_Continuous_Motion;

Begin

   SingleFramed := False;
   Do_Stop_Motion;
   
End;

(***** Utilities *****)

(* Install Axis Map. *)

Procedure Do_Axis_Map;

Var S : String;

Begin

   DrawStr ('Axis Map...');
   Drawln;
   Drawln;
   For I := 1 to Max_Axes Do
       With AA [I].A Do
            begin
            S := Id + ' ' + IntToStr (No) + ' ' + Name;
            DrawStr (S);
            Drawln;
            end;
   Get_Axis_Map_Options;
   
End;

(* Install User Units. *)

Procedure Do_User_Units;

Var S : Str255;

Begin

   DrawStr ('User Units...');
   Drawln;
   Drawln;
   For I := 1 to Max_Axes Do
       With AA [I].K Do
            begin
            S := AA [I].A.Id + ' ';
            S := S + RealToStr (Kscale, DP) + ' ' + IntToStr (DP) + ' ' + Units;
            DrawStr (S);
            Drawln;
            end;
   Get_User_Units_Options;
   
End;

(* Install Motor Speed Profiles. *)

Procedure Do_Motor_Profiles;

Var S : Str255;

Begin

   DrawStr ('Motor Speeds...');
   Drawln;
   Drawln;
   For I := 1 to Max_Axes Do
       With AA [I].R Do
            begin
            S := AA [I].A.Id + ' ';
            If AccelSt
               Then S := S + 'Accel / Decel  '
               Else S := S + 'Constant Speed ';
            S := S + RealToStr (Max_Speed, 0) + ' ' 
                 + RealToStr (Min_LowSpd, 0) + ' '
                 + RealToStr (Max_HighSpd, 0) + ' '
                 + RealToStr (Max_RampCnt, 0);
            DrawStr (S);
            Drawln;
            end;
   Get_Motor_Profile_Options;
   
End;

(***** Special routines *****)

(* Test 2-point taper routines. *)

Procedure Compute_Increments (Var PX : Parameter_Table; Var QX : Point_Table);

Var     F : Integer;
        A : Integer;
        C : Integer;
        D : Integer;
        Frame_Count : Integer;
        Accel_Count : Integer;
        Const_Count : Integer;
        Decel_Count : Integer;
        Area_Accel : Real;
        Area_Const : Real;
        Area_Decel : Real;
        Area_Total : Real;
        Position : Real;
        Increment : Real;

Begin

   With PX Do begin

   IncrMax := (EndPoint - StartPoint) / (EndFrame - StartFrame);
   If Taper
      Then begin
      Frame_Count := EndFrame - StartFrame;
      Accel_Count := Round (Accel / 100.0 * Frame_Count);
      Decel_Count := Round (Decel / 100.0 * Frame_Count);
      Const_Count := Frame_Count - (Accel_Count + Decel_Count);
      Area_Accel := 0.0;
      If Accel_Count > 0 Then
         For A := 1 to Accel_Count Do
             Area_Accel := Area_Accel + Sin (Pi/2 * A/Accel_Count);
      Area_Decel := 0.0;
      If Decel_Count > 0 Then
         For D := Decel_Count downto 1 Do
             Area_Decel := Area_Decel + Sin (Pi/2 * D/Decel_Count);
      Area_Const := 1.0 * Const_Count;
      Area_Total := Area_Accel + Area_Const + Area_Decel;
      IncrMax := (EndPoint - StartPoint) / Area_Total;
      end;

   Position := StartPoint;
   For F := 0 to Preset_Count Do
       begin
       If F <= StartFrame
            Then Position := StartPoint
       Else If F >= EndFrame
            Then Position := EndPoint
       Else begin
            Increment := IncrMax;
            If Taper
               Then begin
               A := F - StartFrame;
               D := EndFrame - F + 1;
               If F < StartFrame + Accel_Count
                  Then Increment := IncrMax * Sin (Pi/2 * A/Accel_Count) 
               Else If F > EndFrame - Decel_Count
                  Then Increment := IncrMax * Sin (Pi/2 * D/Decel_Count)
               Else Increment := IncrMax;
               end;
            Position := Position + Increment;
            end;
       QX [F] := Position;
       end;
   end;
End;

Procedure Do_Axis_Increments;

Begin

   DrawStr ('Axis Positioning Cues...');
   Index := 2;
   With AA[Index] Do
        If NOT P.Spec
           Then begin
           P.Spec := True;
           If P.EndFrame < Preset_Count
              Then P.EndFrame := Preset_Count;
           end;
   Get_Axis_Increments (AA[Index].P);
   Drawln;
   Writeln;
   
   If The_Item = Ok
      Then begin
      Compute_Increments (AA[Index].P, AA[Index].Q);
      For I := 1 to Preset_Count Do
          Writeln (I:10, AA[Index].Q[I]:10:3);
      end;
End;

(*****)

(* Test Graphics routines. *)

(* Cheap N Quick display of tapered array. *)

Procedure Do_Point_Plotter;

Var Xscale : Real;
    Yscale : Real;
Begin

   DrawStr ('Point Plotting...');
   Drawln;

   If Preset_Count > 1
      Then begin
      Index := 2;   
      Xscale := 470.0 / Preset_Count;
      Yscale := 270.0 / (AA[Index].Q[Preset_Count] - AA[Index].Q[1]);
      MoveTo (Round (Xscale), Round (Yscale * AA[Index].Q[1])); 
      For I := 1 to Preset_Count Do
          LineTo (Round (Xscale * I), Round (Yscale * AA[Index].Q[I]));
      end;
End;

(* Spline routines from Turbo Graphics Toolbox. *)

Const   MaxPlotGlb = 100;    (* max points *)

Type    Float = Real;
        PlotArray = Array [1..MaxPlotGlb] of Array [1..2] of Float;
        
Var     IA : PlotArray;
        OA : PlotArray;

(* Display Turbo Graphics Error Codes. *)
        
Procedure Error (Code1, Code2 : Integer);

Begin

   DrawStr ('Error ');
   DrawStr (IntToStr (Code1));
   DrawStr (' , ');
   DrawStr (IntToStr (Code2));
   Drawln;
   
End;

(* Compute spline of input array into output array. *)   

procedure Spline (var AA : PlotArray; N : integer; X1, Xm : Float;
                 var BB : PlotArray; M : integer);

type
  Vector = array[1..MaxPlotGlb] of Float;

var
  I, K    : integer;
  Dx, T   : Float;
  B, C, D : Vector;

function SplineEval( T : Float; var I : integer) : Float;
var
  J, K : integer;
  Dx   : Float;
begin
  if I >= N then
    I := 1;
  if (T < AA[I, 1]) or (T > AA[I+1, 1]) then
  begin
    I := 1;
    J := N + 1;
    repeat
      K := (I + J) div 2;
      if T < AA[K, 1] then
        J := K;
      if T >= AA[K, 1] then
        I := K;
    until J <= (I + 1);
  end;
  Dx := T - AA[I, 1];
  SplineEval := AA[I, 2] + Dx * (B[I] + Dx * (C[I] + Dx * D[I]));
end; { SplineEval }

begin { Spline }
  if N >= 3 then
    begin
      D[1] := AA[2, 1] - AA[1, 1];
      C[2] := (AA[2, 2] - AA[1, 2]) / D[1];
      for I := 2 to N-1 do
      begin
        D[I] := AA[I+1, 1] - AA[I, 1];
        B[I] := 2.0 * (D[I-1] + D[I]);
        C[I+1] := (AA[I+1, 2] - AA[I, 2]) / D[I];
        C[I] := C[I+1] - C[I];
      end;
      B[1] := -D[1];
      B[N] := -D[N-1];
      C[1] := 0.0;
      C[N] := 0.0;
      if N > 3 then
      begin
        C[1] := C[3] / (AA[4, 1] - AA[2, 1]) - C[2] / (AA[3, 1] - AA[1, 1]);
        C[N] := C[N-1] / (AA[N, 1] - AA[N-2, 1])
                - C[N-2] / (AA[N-1, 1] - AA[N-3, 1]);
        C[1] := C[1] * Sqr(D[1]) / (AA[4, 1] - AA[1, 1]);
        C[N] := -C[N] * Sqr(D[N-1]) / (AA[N, 1] - AA[N-3, 1]);
      end;
      for I := 2 to N do
      begin
        T := D[I-1] / B[I-1];
        B[I] := B[I] - T * D[I-1];
        C[I] := C[I] - T * C[I-1];
      end;
      C[N] := C[N] / B[N];
      for I := N-1 downto 1 do
        C[I] := (C[I] - D[I] * C[I+1]) / B[I];
      B[N] := (AA[N, 2] - AA[N-1, 2]) / D[N-1] + D[N-1] * (C[N-1] + 2.0 * C[N]);
      for I := 1 to N-1 do
      begin
        B[I] := (AA[I+1, 2] - AA[I, 2]) / D[I] - D[I] * (C[I+1] + 2.0 * C[I]);
        D[I] := (C[I+1] - C[I]) / D[I];
        C[I] := 3.0 * C[I];
      end;
      C[N] := 3.0 * C[N];
      D[N] := D[N-1];
    end
  else
    if N = 2 then
    begin
      B[1] := (AA[2, 2] - AA[1, 2]) / (AA[2, 1] - AA[1, 1]);
      C[1] := 0.0;
      D[1] := 0.0;
      B[2] := B[1];
      C[2] := 0.0;
      D[2] := 0.0;
    end;
  if (N >= 2) and (M >= 2) then
    if (X1 >= AA[1, 1])  and (Xm <= AA[N, 1]) then
      begin
        Dx := (Xm - X1) / (M - 1);
        K := 1;
        for I := 1 to M do
        begin
          BB[I, 1] := X1 + (I - 1) * Dx;
          BB[I, 2] := SplineEval(BB[I, 1], K);
        end;
      end
    else
      Error(20, 7)
  else
    Error(20, 4);
end; { Spline }

(* Interpolate points with display graphics. *)

Procedure Do_Interpolation;

Var Mouse_Pt : Point;
    P : Integer;
    S : Integer;

Begin

   DrawStr ('Interpolation Graphics...');
   Drawln;
   
   P := 0;
   SetCursor (CursList [CrossCursor]^^);
   Repeat
      Repeat
      Until Button Or KeyPressed;
      If NOT KeyPressed
         Then begin
         SetCursor (CursList [PlusCursor]^^);
         For S := 1 to MaxInt do;
         Repeat
         Until NOT (* StillDown *) WaitMouseUp;
         GetMouse (Mouse_Pt);
         P := P + 1;
         IA [P,1] := Mouse_Pt.H;
         IA [P,2] := Mouse_Pt.V;
         SetCursor (CursList [CrossCursor]^^);
         If P <= 1
            Then MoveTo (Mouse_Pt.H, Mouse_Pt.V)
            Else LineTo (Mouse_Pt.H, Mouse_Pt.V);
         end;
   Until KeyPressed;

   SetCursor (CursList [WatchCursor]^^);   
   Spline (IA, P, IA [1,1], IA [P,1], OA, 100);
   MoveTo (Round (OA [1,1]), Round (OA [1,2]));
   For S := 1 to 100 do
       LineTo (Round (OA [S,1]), Round (OA [S,2]));
   SetCursor (Arrow);
   
End;

(*****)

(* Brings up Standard Open-File Dialog Box and Opens a File. *)

Procedure Do_Open_File;

Var The_FileName    : Str255;       { file name by string               }
    VolRefNum       : Integer;      { volume refernce by number         }
    FileRefNum      : Integer;      { file reference number             }
    FileErr         : OSErr;        { Mac OS calling error              }

var
  topLeft      : Point;         { location for standard dialog box  }
  FileFilter   : SFTypeList;    { list of standard file types       }
  Reply        : SFReply;       { standard file package reply record}

begin

  DrawStr ('Open File...');

  topLeft.h := 90;             { top left horiz point for Get File dialog }
  topLeft.v := 80;             { top left vert    "    "   "    "    "    }
  FileFilter[0] := 'TEXT';     { file filter for text files               }

  (* Standard File-Open dialog box *)
  SFGetFile(topLeft,'',nil,+1,FileFilter,nil,Reply);

  if Reply.Good then
     begin
     VolRefNum := Reply.vRefNum;
     The_FileName := Reply.fName;
     DrawStr (The_FileName);
     end;
end;

(*****)

{   *********   items in Apple Menu   *********** }

(* DoAbout bring up 'About...' box using a dialog box *)

procedure DoAbout;

var
  theItem       : Integer;    
  AboutPtr      : DialogPtr;
  S1,S2,S3      : StringHandle;
begin 
  SetCursor(Arrow);                     { set cursor                    }
  ShowCursor;                           { and turn it back on           }
  S1 := GetString(Text1ID);             { get text from resource file   } 
  S2 := GetString(Text2ID);
  S3 := GetString(Text3ID); 
  ParamText(S1^^,S2^^,S3^^,'');         { and set up as parameter text  }
  AboutPtr := getNewDialog(AboutID,NIL,Pointer(-1));    { get dialog box}    
  ModalDialog(NIL,theItem);             { put dialog box up; get result }
  DisposDialog(AboutPtr);               { get rid of dialog box         }
  SetCursor(Arrow)
end; { of proc DoAbout }

(* DoDeskAcc start up desk accessory from Apple menu *)

procedure DoDeskAcc(Item : Integer);

var
  SavePort          : GrafPtr;
  RefNum            : Integer;
  DName             : String;
begin
  GetPort(SavePort);                    { save port before starting it  }
  GetItem(MenuList[AM],Item,DName);     { get name of desk accessory    }
  refNum := OpenDeskAcc(DName);         { and start that sucker up!     }
  SetPort(SavePort);                    { restore grafport and continue }
end; { of proc DoDeskAcc }

{   *********   event handling routines   *********** }

(* ToggleFlag checks or de-checks item Indx in menu Mndx *)

procedure ToggleFlag(var Flag : Boolean; Mndx,Indx : Integer);

var
  Ch            : Char;
begin
  Flag := not Flag;                     { toggle flag (for you)         }
  if Flag                               { if flag is True...            }
    then Ch := Chr(CheckMark)           {   then check item in menu     }
    else Ch := Chr(NoMark);             {   else clear any checkmark    }
  SetItemMark(MenuList[Mndx],Indx,Ch)   { put char by item in menu      }
end; { of proc ToggleFlag }

(* SetItemState if true, enables item Indx of menu Mndx; else disables *)

procedure SetItemState(Mndx,Indx : Integer; Flag : Boolean);

begin
  if Flag
    then EnableItem (MenuList[Mndx],Indx)
    else DisableItem(MenuList[Mndx],Indx)
end; { of proc SetItemState }

(* UpdateMenu enable or disable items in I/O menu as needed *)

procedure UpdateMenu;

begin
end; { of proc UpdateMenu }

(* HandleMenu decode MenuInfo and carry out command *)

procedure HandleMenu(MenuInfo : LongInt);

var
  Menu          : Integer;          { menu number that was selected     }
  Item          : Integer;          { item in menu that was selected    }
  B             : Boolean;          { dummy flag for SystemEdit call    }
begin
  if MenuInfo <> 0 then begin
    ClearWindow(MainPtr);           { we're clearing the window         }
    PenNormal;                      { set the pen back to normal        }
    Menu := HiWord(MenuInfo);       { find which menu the command is in }
    Item := LoWord(MenuInfo);       { get the command number            }
    case Menu of                    { and carry it out                  }
    
      ApplMenu  : if Item = 1
                    then DoAbout            { bring up "About..." window}
                    else DoDeskAcc(Item);   { start desk accessory      }
      
      FileMenu  : case Item of
                   MFO : Do_Open_File;              
                   MFQ : Finished := True;  { Quit command              }
                  end;    
                    
      EditMenu  : case Item of              
          MEU,MEX..MED : if not SystemEdit(Item-1) { pass to desk acc    }
                           then { do nothing };
                   MEF : Edit_Preset_Counts;
                   MEA : Do_Axis_Increments;
                   MET : Edit_Frame_Counts; 
                  end;
                  
      RunnMenu  : Case Item of              { Run Menu                  }
                   MRC :	Do_Camera;
                   MRP :	Do_Projector;
                   MRS : Do_Sequencer;
                   MRM : Do_Stop_Motion;
                   MRG : Do_Go_Motion;
                   MRL : Do_Continuous_Motion;
                  end;

      OverMenu  : Case Item of              { Overide menu              }
                   MOI :	Do_Init_Motor;
                   MOR :	Do_Run_Motor;
                   MOK : Do_Kill_Motor;
                   MOS : Do_Status_Motor;
                   MOP : Do_Position_Motor;
                   MOM : Do_Move_Motor;
                   MOG : Do_Goto_Motor;
                   MOJ : Do_Jog_Motor;
                   MOL : Do_Limit_Motor;
                   MOZ : Do_Zero_Motor;
                  end;
                  
      UtilMenu  : Case Item of              { Utilities menu            }
                   MUI : Do_Axis_Map;
                   MUM : Do_Motor_Profiles;
                   MUU : Do_User_Units;
                  end;
                  
      SpecMenu  : Case Item of              { Special menu              }
                   MSP : Do_Point_Plotter;
                   MSI : Do_Interpolation;
                   MSC : ;
                   MST : ;
                  end;
                  
    end;{case of Menu}
    HiliteMenu(0);                          { reset menu bar            }
    UpdateMenu;                             { make any changes needed   }
  end
end; {of proc HandleMenu}

(* HandleClick handle mouse click within window *)

procedure HandleClick(WPtr : WindowPtr; MLoc : Point);

begin       
  if WPtr = MainPtr                         { if this is our window...  }
    then if WPtr <> FrontWindow             { and it's not in front...  }
      then SelectWindow(WPtr)               { ...then make it active    }
end; { of proc HandleClick }

(* HandleGoAway handle mouse click in go-away box *)

procedure HandleGoAway(WPtr : WindowPtr; MLoc : Point);

var
  WPeek             : WindowPeek;           { for looking at windows    }
begin
  if WPtr = FrontWindow then begin          { if it's the active window }
    WPeek := WindowPeek(WPtr);              { peek at the window        }
    if TrackGoAway(WPtr,MLoc) then begin    {   and the box is clicked  } 
      if WPeek^.WindowKind = userKind       {     if it's our window    }   
        then Finished := True               {       then time to stop   }
        else CloseDeskAcc(WPeek^.WindowKind){       else close DeskAcc  }
    end   
  end
  else SelectWindow(WPtr)                   { else make it active       }
end; { of proc HandleGoAway }

(* HandleGrow handle mouse click in grow box *)

procedure HandleGrow(WPtr : WindowPtr; MLoc : Point);

type
  GrowRec           =
    record
      case Integer of
        0           : (Result       : LongInt);
        1           : (Height,Width : Integer)
    end;
var
  GrowInfo          : GrowRec;
begin
  if WPtr = MainPtr then with GrowInfo do begin { if it's our window    }
    Result := GrowWindow(WPtr,MLoc,GrowArea);   {   get amt of growth   }
    SizeWindow(WPtr,Width,Height,True);         {   resize window       }
    InvalRect(WPtr^.portRect)                   {   set up for update   }
  end
end; { of proc HandleGrow }

(* DoMouseDown identify where mouse was clicked and handle it *)

procedure DoMouseDown(theEvent:EventRecord);

var
  Location      : Integer;
  theWindow     :	WindowPtr;
  MLoc          :	Point;
  WLoc          :	Integer;
begin
  MLoc  := theEvent.Where;              { get mouse position            }
  WLoc := FindWindow(MLoc,theWindow);   { get window, loc in window     }
  case WLoc of                          { handle window locations       }
    InMenuBar   : HandleMenu(MenuSelect(MLoc));     { in the menu       }
    InContent   : HandleClick(theWindow,MLoc);      { inside the window }
    InGoAway    : HandleGoAway(theWindow,MLoc);     { in the go away box}
    InGrow      : HandleGrow(theWindow,MLoc);       { in the grow box   }
    InDrag	     : DragWindow(theWindow,MLoc,DragArea); { in the drag bar}
    InSysWindow : SystemClick(theEvent,theWindow)   { in a DA window    }
  end
end; { of proc DoMouseDown }

(* DoKeypress handles keypress (keyDown, autoKey) event *)

procedure DoKeypress(theEvent : EventRecord);

var
  KeyCh             : Char;
begin
  if (theEvent.modifiers and cmdKey) <> 0 then begin { menu key command }
    KeyCh := Chr(theEvent.Message and charCodeMask); { decode character }
    HandleMenu(MenuKey(KeyCh))                       { get menu and item}
  end
  else SysBeep(1)                                     { do *something*  }
end; { of proc DoKeypress }

(* DoUpdate handles window update event *)

procedure DoUpdate(theEvent : EventRecord);

var
  SavePort,theWindow    : WindowPtr;
begin
  theWindow := WindowPtr(theEvent.Message);     { find which window     }
  if theWindow = MainPtr then begin             { only update ours      }
    SetCursor(CursList[watchCursor]^^);         { set cursor to watch   }
    GetPort(SavePort);                          { save current grafport }
    SetPort(theWindow);                         { set as current port   }
    BeginUpdate(theWindow);                     { signal start of update}
    
  { and here's the update stuff! }
    ClearWindow(theWindow);                     { do update stuff       }
  { now, back to our program...}

    EndUpdate(theWindow);                       { signal end of update  }
    SetPort(SavePort);                          { restore grafport      }
    SetCursor(Arrow)                            { restore cursor        }
  end
end; { of proc DoUpdate }

(* DoActivate handles window activation event *)
(* Note: Menu specific updates here. *)

procedure DoActivate(theEvent : EventRecord);

var
  I         : Integer;
  AFlag     : Boolean;
  theWindow : WindowPtr;
begin
  with theEvent do begin
    theWindow := WindowPtr(Message);            { get the window        }
    AFlag := Odd(Modifiers);                    { get activate/deactive }
    if AFlag then begin                         { if it's activated...  }
      SetPort(theWindow);                       {   make it the port    }
      FrontWindow := theWindow;                 {   know it's in front  }
      DrawGrowIcon(theWindow);                  {   set size box        }
    end
    else begin
      SetPort(ScreenPort);                      { else reassign port    }
      if theWindow = FrontWindow                { if it's in front      }
        then FrontWindow := NIL                 { ...then forget that   }
    end;
    if theWindow = MainPtr then begin           { if it's our window    }
      SetItemState(FM,1,not AFlag);             {   update File cmds    }
      For I := MFN to MFC do
        SetItemState (FM,I,AFlag);
      SetItemState(FM,MFQ,AFlag);               {   update Quit command }
      for I := MEU to MED do                    {   update Edit cmds    }
        SetItemState(EM,I,not AFlag);  
      for I := RM to SM do                      {   update other menus  }
        SetItemState(I,0,AFlag);
      DrawMenuBar                               {   update menu bar     }
    end
  end
end; { of proc DoActivate }

(* Initialize everything for the program *)
(* Note: Program specific stuff in separate procedure (above). *)

procedure Initialize;

var
  Indx		        : Integer;
  Result        : Real;
begin
  { initialize all the different managers                               }
  InitGraf(@thePort);               { create a grafport for the screen  }
  InitFonts;                        { start up the font manager         }
  InitWindows;                      { start up the window manager       }
  InitMenus;                        { start up the menu manager         }
  TEInit;                           { start up the text manager for DAs }
  InitDialogs(NIL);                 { start up the dialog manager       }
  FlushEvents(everyEvent,0);        { clear events from previous state  }

  { get four standard system cursors only                               }
  for Indx := iBeamCursor to watchCursor do begin
    CursList[Indx]:=GetCursor(Indx); { read in from system resource     }
    HLock(Handle(CursList[Indx]))    { lock the handle down             }
  end;
  SetCursor(CursList[watchCursor]^^);{ bring up watch cursor            }
  
  { set up menus }
  MenuList[AM] := GetMenu(ApplMenu);{ read menus in from resource fork  }
  MenuList[FM] := GetMenu(FileMenu);
  MenuList[EM] := GetMenu(EditMenu);
  MenuList[RM] := GetMenu(RunnMenu);
  MenuList[OM] := GetMenu(OverMenu);
  MenuList[UM] := GetMenu(UtilMenu);
  MenuList[SM] := GetMenu(SpecMenu);
  AddResMenu(MenuList[AM],'DRVR');  { pull in all desk accessories      }
  for Indx := 1 to MenuCnt do       { place menus in menu bar           }
    InsertMenu(MenuList[Indx],0);
  DrawMenuBar;                      { draw updated menu bar to screen   }

  { set up window stuff }
  GetWMgrPort(ScreenPort);          { get grafport for all windows      }
  SetPort(ScreenPort);              { and keep hand just in case        }
  MainPtr := GetNewWindow(MainID,@MainRec,Pointer(-1));    { get window }
  SetPort(MainPtr);                 { set window to current graf port   }
  SelectWindow(MainPtr);            { and make window active            }
  FrontWindow := MainPtr;           { remember that it's in front       }
  DrawGrowIcon(MainPtr);            { draw the grow box in the corner   }
  MainPeek := WindowPeek(MainPtr);  { get pointer to window record      }
  MainPeek^.windowKind := UserKind; { set window type = user kind (ID=8)}
  ScreenArea := screenBits.Bounds;  { get size of screen (don't assume) }
  with ScreenArea do begin
    SetRect(DragArea,5,25,Right-5,Bottom-10);   { set drag region       }
    SetRect(GrowArea,50,20,Right-5,Bottom-10)   { set grow region       }
  end;

  TextFont (Monaco);                { select even-spaced font           }
  TextSize (9);

  { program specifics }  
  Init_Program_Stuff;               { init all program-specific stuff   }
  
  UpdateMenu;                       { update menu as needed             }
  Finished := False                 { set program terminator to false   }  
end; { of proc Initialize }

(* CleanUp to do whatever's needed before returning to Finder *)

procedure CleanUp;

begin
  DisposeWindow(MainPtr)            { get rid of the main window        }
end; { of proc CleanUp }

(* CursorAdjust change cursors depending upon location *)

procedure CursorAdjust;

var
  MousePt		 : Point;
begin
  if MainPtr = FrontWindow then with MainPeek^ do begin
    GetMouse(MousePt);                          {  find where mouse is  }
    if PtInRect(MousePt,port.portRect) then     {  if over window then  }
      if Button                                 {   if button down...   }
        then SetCursor(CursList[plusCursor]^^)  {    then make a plus   }
        else  SetCursor(CursList[crossCursor]^^){    else make a cross  }
      else SetCursor(Arrow)                     {   else make an arrow  }
  end
end; { of proc CursorAdjust }

(* HandleEvent decodes event and handles it *)

procedure HandleEvent(theEvent : EventRecord);

begin
  case theEvent.What of
    mouseDown	    : DoMouseDown(theEvent);      { mouse button pushed   }
    keyDown       : DoKeyPress(theEvent);       { key pressed down      }
    autoKey       : DoKeyPress(theEvent);       { key held down         }
    updateEvt     : DoUpdate(theEvent);         { window need updating  }
    activateEvt   : DoActivate(theEvent)        { window made act/inact }
  end
end; { of proc HandleEvent }

Begin { main body of program }
   Initialize;                              { set everything up         }
   repeat                                   { keep doing the following  }              
     SystemTask;                            { update desk accessories   }
     CursorAdjust;                          { update which cursor       }
     if GetNextEvent(everyEvent,theEvent)   {   if there's an event...  }
       then HandleEvent(theEvent);          {     ...then handle it     }
     GetSpecialEvent;                       {   get special event too...}
   until Finished;                          { until user is done        }
   Cleanup;                                 { clean everything up       }
End. { of program }
