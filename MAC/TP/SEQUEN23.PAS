
(* Optical Printer Sequencer. *)
(* Copyright 1991 Dave Milici and Penguin Associates. *)

Program SEQUENCER;

{$R-}               { Turn off range checking               }
{$I-}               { Turn off I/O error checking           }
{$B+}               { Set bundle bit (for icon, etc.)       }
{$R Sequencr.Rsrc}  { Identify resource file                }
{$T APPLSEQ1}       { Set application ID                    }
{$U-}               { Turn off auto link to runtime units   }
{$U TurboCrt}       { Turbo Pascal for IBM library unit     }
{$U MCPU}           { Motion Control interface unit         }
{$S+}               { Segmentation on                       }

Uses 

    PasInOut,       (* Pascal basic Input / Output routines *)   
    Memtypes,       (* Mac OS memory data types             *)
    QuickDraw,      (* Mac OS QuickDraw library             *)
    OSIntf,         (* Mac OS interface routines            *)
    ToolIntf,       (* Mac OS toolbox routines              *)
    PackIntf,       (* Mac OS packaged functions            *)
    PasConsole,     (* Pascal Read / Write console routines *) 
    Sane,           (* Standard Apple Numeric Environment   *)
    {$S Segment1}
    TurboCrt,       (* Turbo Pascal for IBM routines        *) 
    {$S Segment2}
    Mcpu;           (* Motion Control interface routines    *)
    {$S Segment3}

Const

  MenuCnt       =     6;    { total # of menus                   }
  ApplMenu      =  1000;    { resource ID of Apple Menu          }
  FileMenu      =  1001;    { File Menu                          }
  EditMenu      =  1002;    { Edit Menu                          }
  RunnMenu      =  1003;    { Run Menu                           }
  OverMenu      =  1004;    { Overide Menu                       }
  UtilMenu      =  1005;    { Utilities Menu                     }
  
  AM            =     1;    { index into MenuList for Apple Menu }
  FM            =     2;    { File Menu                          }
  EM            =     3;    { Edit Menu                          }
  RM            =     4;    { Run Menu                           }
  OM            =     5;    { Overide Menu                       }
  UM            =     6;    { Utilities Menu                     }
  
  MainID        =  1000;    { resource ID for MainWindow         }
  AboutID       =  1000;    { resource ID for dialog box         }
  Text1ID       =  1000;    { resource IDs for 'About...' text   }
  Text2ID       =  1001;
  Text3ID       =  1002;
  
  BSize         =   512;    { buffer size for DiskI/O           }
  BCount        =   256;    { buffer count for Disk I/O         }

Type
  Buffer	       = packed array[1..BSize] of Char;   { used for DiskI/O }
  BufFile       = file of Buffer;                   { ditto }
  CursorList    = array[iBeamCursor..WatchCursor] of CursHandle;
  PtrInteger    = ^integer;
  PtrString     = ^str255;
  
Var
  F             : file of Buffer;   { used in I/O routines }
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

(* Sequencer stuff *)
  
Const   CamId = 1031;       (* Camera dialog resource ID *)
        PrjId = 1032;       (* Projector dialog *)
        SeqId = 1033;       (* Sequencer dialog *)
        FrmId = 1034;       (* Frame Count dialog *)
        
        InitId = 1041;      (* Init dialog res ID *)
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
        UnitId = 1052;      (* User Units dialog *)
        MspdId = 1053;      (* Motor Speeds dialog *)
        
Const   FWD = True;         (* forward motor direction *)
        REV = False;        (* reverse motor direction *)
        
        Min_Axes = 2;       (* min number of axes *)
        Max_Axes = 8;       (* max number of axes *)

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
            
        Axis_Table = Record
            Spec    : Boolean;              (* specified ? *)
            A       : Map_Table;            (* axis map *)
            M       : Motor_Table;          (* MCPU motor stuff *)
            K       : Conversion_Table;     (* user units stuff *)
            R       : Run_Profile;          (* motor run profile stuff *)
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

Const   CX = 1;                             (* camera axis *)
        PX = 2;                             (* projector axis *)
        
Var     I : Integer;                        (* axis array index - general *)
        Index : Integer;                    (* axis array index - specific *)
        AA : Array [1..Max_Axes] of Axis_Table;

(***** MCPU motion control routines *****)

Var Debugged : Boolean;     (* debugging flag *)

(* Pass along echoed input debugging status to MCPU library routines. *)

Procedure SetSioEcho;

Begin

   OutSioSt (Debugged);
   
End;

(******************************)

(* Input a character from ThingM and optionally echo out the Mac console. *)

Procedure InSioEcho (Var Ch : Char);

Begin

   InSio (Ch);
   If Debugged 
      Then Write (Ch);
End;

(* Get special event as input from ThingM to serial port. *)
(* If a character is input, and debugging is active, 
(* then echo output the character to the console screen. *)

Procedure GetSpecialEvent;

Var InStatus : Boolean;
    Ch : Char;
Begin

   InSioSt (InStatus);
   If InStatus
      Then InSioEcho (Ch);
End;

(***** Program specifics *****)

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
            end;
End;

(* Initialize all Animal stuff. *)

Procedure Init_Program_Stuff;

Begin

  (* Debugged := TRUE;                 (* debug display *)
  Debugged := FALSE;                (* no debug display *)
  SetSioEcho;

  (***** init MCPU system *****)
  
  ResetSIO;                         (* reset serial port *)

  Init_MCPU;                        (* init MCPU communications *)
  
  (***** init default axis array data *****)
    
  Init_Defaults;

  (***** initialize sequencer variables here *****)
  
  Index := 1;
  
  Frame_Count := 0;
  Camera_Count := 0;
  Projector_Count := 0;
  Sequencer_Count := 0;
  Sequencer := Alternate;
  Camera_Cycle := 1;
  Projector_Cycle := 1;
  Camera_Total := 0;
  Projector_Total := 0;
  
  With AA [CX] Do                        (* camera axis *)
       begin
       A.Name := 'Camera';
       M.AccelSt := True;
       M.LowSpd  := 0;
       M.HighSpd := 334;
       M.RampCnt := 50;
       K.Kscale  := 1.0;
       K.DP      := 1;
       K.Units   := 'Frames';
       R.AccelSt := True;
       R.Min_LowSpd  := 0;
       R.Max_HighSpd := 3.34;
       R.Max_RampCnt := 50;
       end;
       
  With AA [PX] Do                        (* projector axis *)
       begin
       A.Name := 'Projector';
       M.AccelSt := True;
       M.LowSpd  := 0;
       M.HighSpd := 334;
       M.RampCnt := 50;
       K.Kscale  := 1.0;
       K.DP      := 1;
       K.Units   := 'Frames';
       R.AccelSt := True;
       R.Min_LowSpd  := 0;
       R.Max_HighSpd := 3.34;
       R.Max_RampCnt := 50;
       end;
         
  (*****)
    
  InitM (AA[CX].M);                       (* init camera motor speed *)
  WaitOver;
  InitM (AA[PX].M);                       (* init projector motor speed *)
  WaitOver;
    
  If Debugged
     Then AA[1].A.Name := 'DEBUG';
End;

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

(*****)

(***** screen support routines *****)

(* clears window, draws grow stuff, sets location. *)

procedure ClearWindow(WPtr : WindowPtr);

var
  TRect			: Rect;
begin
  if (WPtr = MainPtr) and (Wptr = FrontWindow ) then begin
    EraseRect(WPtr^.portRect);            { clear rect area of window   }
    DrawGrowIcon(WPtr);                   { draw grow icon              }
    TextFont (Monaco);                    { select even-spaced font     }
    TextSize (9);    
    TH := 5; TV := 12                     { set text loc to upper left  }
  end
end; { of proc ClearWindow }

(* moves to text location and writes out Str. *)

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
    FpsSpeed : Real;
    
Begin

   The_Dialog := GetNewDialog (InitId, Nil, Pointer (-1));
   
   With AA [Index] Do
        begin
        The_Text := IntToStr (M.MotorNo);
        GetDItem (The_Dialog, IM, The_Type, The_TextHdl, The_ItemBox);
        SetIText (The_TextHdl, The_Text);
        The_Text := IntToStr (M.LowSpd);
        GetDItem (The_Dialog, IL, The_Type, The_TextHdl, The_ItemBox);
        SetIText (The_TextHdl, The_Text);
        The_Text := IntToStr (M.HighSpd);
        FpsSpeed := M.HighSpd / 100.0;
        The_Text := RealToStr (FpsSpeed, 2);
        GetDItem (The_Dialog, IH, The_Type, The_TextHdl, The_ItemBox);
        SetIText (The_TextHdl, The_Text);
        SelItext (The_Dialog, IH, 0, Length (The_Text));
        The_Text := IntToStr (M.RampCnt);
        GetDItem (The_Dialog, IR, The_Type, The_TextHdl, The_ItemBox);
        SetIText (The_TextHdl, The_Text);
        end;
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then begin
             GetIText (The_ItemHdl, The_Text);
             With AA [Index] Do
             Case The_Item of
                  IM : If StrToInt (The_Text) in [1..Max_Axes]
                          Then Index := StrToInt (The_Text);
                  IL : M.LowSpd  := StrToInt (The_Text);
                  IH : M.HighSpd := (* StrToInt (The_Text); *)
                         Round (100.0 * StrToReal (The_Text));
                  IR : M.RampCnt := StrToInt (The_Text);
                  end;
             end;
   Until The_Type = BtnItem;
   DisposDialog (The_Dialog);
   
end;
  
(* Dialog for Run Motor *)

Procedure Get_Run_Options;

Const RM = 4;                   (* Run Motor item *)
      RR = 6;                   (* Run Run item *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    
Begin

   The_Dialog := GetNewDialog (RunId, Nil, Pointer (-1));
   
   With AA [Index] Do
        begin
        The_Text := IntToStr (M.MotorNo);
        GetDItem (The_Dialog, RM, The_Type, The_TextHdl, The_ItemBox);
        SetIText (The_TextHdl, The_Text);
        The_Text := RealToStr (M.StepCnt, 0);
        GetDItem (The_Dialog, RR, The_Type, The_TextHdl, The_ItemBox);
        SetIText (The_TextHdl, The_Text);
        SelItext (The_Dialog, RR, 0, Length (The_Text));
        end;
   
   Repeat
     ModalDialog (Nil, The_Item);
     GetDItem (The_Dialog, The_Item, The_Type, The_ItemHdl, The_ItemBox);
     If The_Type = TextItem
        Then begin
             GetIText (The_ItemHdl, The_Text);
             Case The_Item of
                  RM : If StrToInt (The_Text) in [1..Max_Axes]
                          Then Index := StrToInt (The_Text);
                  RR : AA[Index].M.StepCnt := StrToReal (The_Text);
                  end;
             end;
   Until The_Type = BtnItem;
   DisposDialog (The_Dialog);
   
end;

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

(* Dialog for Status Update *)
(* Status is sampled from MCPU here. *)

Procedure Get_Status_Update;

Const SM = 4;                   (* Status Motor item *)
      SS = 6;                   (* Status Status item *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    
Begin

   The_Dialog := GetNewDialog (StatId, Nil, Pointer (-1));
   
   The_Text := IntToStr (Index);
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
                   Then If StrToInt (The_Text) in [1..Max_Axes]
                        Then Index := StrToInt (The_Text);
                end;
     BtnItem  : If The_Item = Ok
                   Then begin
                   With AA [Index] Do begin
                        GetStat (M);
                        The_Text := M.Stat + '...' + Decode_Status (M);
                        end;
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
   
   The_Text := IntToStr (Index);
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
                   Then If StrToInt (The_Text) in [1..Max_Axes]
                        Then Index := StrToInt (The_Text);
                end;
     BtnItem  : If The_Item = Ok
                   Then With AA [Index] Do begin
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
   
   The_Text := IntToStr (Index);
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
                If The_Item = JM
                   Then If StrToInt (The_Text) in [1..Max_Axes]
                        Then Index := StrToInt (The_Text);
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
     BtnItem  : With AA [Index] Do begin
                Case The_Item of
                  JF : M.Dir := FWD;
                  JR : M.Dir := REV;
                  OK : Quit_Jogging := False;
                  Cancel : Quit_Jogging := True;
                  end;
                (* If NOT Quit_Jogging 
                   Then If Incremental_Jogging
                             Then PulseM (M)
                        Else begin
                             If Continual_Running
                                Then KillM (M)
                                Else RunM (M);
                             Continual_Running := NOT Continual_Running;
                             end; *)
                If (The_Item = JF) Or (The_Item = JR)
                   Then PulseM (M);
                end;
                end;
   Until Quit_Jogging;
   
   KillM (AA [Index].M);
   DisposDialog (The_Dialog);
   
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

(*****)

(* Dialog for Axis Mapping. *)

Procedure Get_Axis_Map_Options;

Const AI = 4;                   (* Axis ID item *)
      AM = 6;                   (* Axis Motor item *)
      AN = 8;                   (* Axis Name *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    The_CtrlHdl : Handle;       (* Button item handle *)
    QQ : String [2];            (* axis Id *)
    Axis_Okay : Boolean;        (* axis Id okay *)
    J : Integer;                (* temp axis index *)
    
Begin

   The_Dialog := GetNewDialog (AmapId, Nil, Pointer (-1));
   
   GetDItem (The_Dialog, Ok, The_Type, The_CtrlHdl, The_ItemBox);
   SetCTitle (ControlHandle(The_CtrlHdl), 'Select');
      
   I := 1;
   QQ := AA[I].A.Id;
   Axis_Okay := True;   
   Repeat
      If Axis_Okay Then With AA [I] Do
         begin
         The_Text := A.Id;
         GetDItem (The_Dialog, AI, The_Type, The_TextHdl, The_ItemBox);
         SetIText (The_TextHdl, The_Text);
         SelItext (The_Dialog, AI, 0, Length (The_Text));
         The_Text := IntToStr (A.No);
         GetDItem (The_Dialog, AM, The_Type, The_TextHdl, The_ItemBox);
         SetIText (The_TextHdl, The_Text);
         The_Text := A.Name;
         GetDItem (The_Dialog, AN, The_Type, The_TextHdl, The_ItemBox);
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
                  AI : QQ := The_Text;
                  AM : A.No := StrToInt (The_Text);
                  AN : A.Name := The_Text;
                  end;
             end;
      If (The_Type = BtnItem) AND (The_Item = Ok)
         Then begin
              Case_Axis (QQ, Axis_Okay, J);
              If Axis_Okay Then I := J;
              If Axis_Okay Then AA[I].A.Id := QQ;
              end;
   Until (The_Type = BtnItem) AND (The_Item = Cancel);
   DisposDialog (The_Dialog);
End;

(* Dialog for User Units. *)

Procedure Get_User_Units_Options;

Const UX = 4;                   (* User Axis item *)
      UU = 6;                   (* User Unit item *)
      UK = 8;                   (* User K-scaler item *)
      UD = 10;                  (* User 1/K-scaler item *)
      
Var The_TextHdl : Handle;       (* Text item handle *)
    The_Text : Str255;          (* user text *)
    The_CtrlHdl : Handle;       (* Button item handle *)
    QQ : String [2];            (* axis Id *)
    Axis_Okay : Boolean;        (* axis Id okay *)
    J : Integer;                (* temp axis index *)
    Multiple : Real;            (* decimal place multiple *)
    
Begin

   The_Dialog := GetNewDialog (UnitId, Nil, Pointer (-1));

   GetDItem (The_Dialog, Ok, The_Type, The_CtrlHdl, The_ItemBox);
   SetCTitle (ControlHandle(The_CtrlHdl), 'Select');
      
   I := 1;
   QQ := AA[I].A.Id;
   Axis_Okay := True;   
   Repeat
      If Axis_Okay Then With AA [I] Do
           begin
           The_Text := A.Id;
           GetDItem (The_Dialog, UX, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           SelItext (The_Dialog, UX, 0, Length (The_Text));
           The_Text := K.Units;
           GetDItem (The_Dialog, UU, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
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
        Then With AA [I] Do begin
             GetIText (The_ItemHdl, The_Text);
             Case The_Item of
                  UU : K.Units := The_Text;
                  UK : If StrToReal (The_Text) = 0.0
                          Then K.Kscale := 1.0
                          Else K.Kscale := StrToReal (The_Text);
                  UD : If StrToReal (The_Text) = 0.0
                          Then K.Kscale := 1.0
                          Else K.Kscale := 1.0 / StrToReal (The_Text);
                  UX : QQ := The_Text;
                  end;
             K.DP := 1;
             Multiple := 1.0;
             Repeat
                K.DP := K.DP + 1;
                Multiple := Multiple * 10.0;
             Until Multiple >= K.Kscale;
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
    The_CtrlHdl : Handle;       (* Button item handle *)
    QQ : String [2];            (* axis Id *)
    Axis_Okay : Boolean;        (* axis Id okay *)
    J : Integer;                (* temp axis index *)
    FpsSpeed : Real;
    
Begin

   The_Dialog := GetNewDialog (MspdId, Nil, Pointer (-1));

   GetDItem (The_Dialog, Ok, The_Type, The_CtrlHdl, The_ItemBox);
   SetCTitle (ControlHandle(The_CtrlHdl), 'Select');
      
   I := 1;
   QQ := AA[I].A.Id;
   Axis_Okay := True;   
   Repeat
      If Axis_Okay Then With AA [I] Do
           begin
           The_Text := A.Id;
           GetDItem (The_Dialog, MX, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           SelItext (The_Dialog, MX, 0, Length (The_Text));
           The_Text := RealToStr (R.Min_LowSpd, 0);
           GetDItem (The_Dialog, ML, The_Type, The_TextHdl, The_ItemBox);
           SetIText (The_TextHdl, The_Text);
           The_Text := RealToStr (R.Max_HighSpd, 2);
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

(***** Installation Utilities. *****)

(* Install axis mapping to MCPU motor numbers. *)

Procedure Do_Axis_Map;

Begin

   DrawStr ('Axis Map Installation...');
   Get_Axis_Map_Options;
   Debugged := (AA[1].A.Name = 'DEBUG')
            Or (AA[1].A.Name = 'debug')
            Or (AA[1].A.Name = 'Debug');
   SetSioEcho;
   
End;

(* Install user units and conversion factors. *)

Procedure Do_User_Units;

Begin

   DrawStr ('User Units Conversion....');
   Get_User_Units_Options;
   
End;

(* Install optimum motor speed profiles. *)

Procedure Do_Motor_Profiles;

Begin

   DrawStr ('Motor Speed Profiles....');
   Get_Motor_Profile_Options;
   
End;

(***** Sequencer routines *****)

(* Edit run-time frame counters. *)

Procedure Do_Frame_Counts;

Begin

   DrawStr ('Edit Frame Counters...');
   Edit_Frame_Counts;
   If The_Item = Ok
      Then begin
           GetCount_Hardware (AA[CX].M);
           GetCount_Hardware (AA[PX].M);
           end;
End;

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

(* Run camera only *)

Procedure Do_Camera;

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

(* Run projector overide. *)

Procedure Do_Projector;

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

(* Run sequencer operation. *)

Procedure Do_Sequencer;

Var F : Integer;
    P : Integer;
    PSingle : Integer;
    C : Integer;
    CSingle : Integer;
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

{   *********   items in Apple Menu   *********** }

(* bring up 'About...' box using a dialog box. *)

procedure DoAbout;

var
  theItem       : Integer;    
  AboutPtr      : DialogPtr;
  S1,S2,S3      : StringHandle;
begin 
  SetCursor(CursList[PlusCursor]^^);      { set to my cursor              }
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

(* start up desk accessory from Apple menu. *)

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

(* checks or de-checks item Indx in menu Mndx *)

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

(* if true, enables item Indx of menu Mndx; else disables. *)

procedure SetItemState(Mndx,Indx : Integer; Flag : Boolean);

begin
  if Flag
    then EnableItem (MenuList[Mndx],Indx)
    else DisableItem(MenuList[Mndx],Indx)
end; { of proc SetItemState }

(* enable or disable items in I/O menu as needed. *)

procedure UpdateMenu;

begin
end; { of proc UpdateMenu }

(* decode MenuInfo and carry out command. *)

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
                    8 : Finished := True;   { Quit command              }
                  end;    
                    
      EditMenu  : case Item of              
               1,3..6 : if not SystemEdit(Item-1) { pass to desk acc    }
                           then { do nothing };
                    8 : Do_Frame_Counts; 
                  end;
                  
      RunnMenu  : case Item of              { Run Menu                  }
                    1 :	Do_Camera;
                    2 :	Do_Projector;
                    3 : Do_Sequencer;
                  end;

      OverMenu  : case Item of              { Overide menu              }
                    1 :	Do_Init_Motor;
                    2 :	Do_Run_Motor;
                    3 : Do_Kill_Motor;
                    4 : Do_Status_Motor;
                    5 : Do_Position_Motor;
                    7 : Do_Move_Motor;
                    8 : Do_Goto_Motor;
                    9 : Do_Jog_Motor;
                   10 : Do_Limit_Motor;
                   11 : Do_Zero_Motor;
                  end;
                  
      UtilMenu : Case Item of
                    1 : Do_Axis_Map;
                    2 : Do_User_Units;
                    3 : Do_Motor_Profiles;
                    end;
                  
    end;{case of Menu}
    HiliteMenu(0);                          { reset menu bar            }
    UpdateMenu;                             { make any changes needed   }
  end
end; {of proc HandleMenu}

(* handle mouse click within window. *)

procedure HandleClick(WPtr : WindowPtr; MLoc : Point);

begin       
  if WPtr = MainPtr                         { if this is our window...  }
    then if WPtr <> FrontWindow             { and it's not in front...  }
      then SelectWindow(WPtr)               { ...then make it active    }
end; { of proc HandleClick }

(* handle mouse click in go-away box. *)

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

(* handle mouse click in grow box. *)

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

(* identify where mouse was clicked and handle it. *)

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

(* handles keypress (keyDown, autoKey) event. *)

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

(* handles window update event. *)

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

(* handles window activation event. *)

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
      For I := 1 to 7 do
        If I in [1..2, 4..7]
           Then SetItemState (FM,I,False);
      SetItemState(FM,8,AFlag);                 {   update Quit command }
      SetItemState(EM,1,not AFlag);             {   update Edit cmds    }
      for I := 3 to 6 do
        SetItemState(EM,I,not AFlag);
      SetItemState (EM,8,AFlag);                 {   update Edit-Counter }  
      for I := RM to UM do                      {   update other menus  }
        SetItemState(I,0,AFlag);
      DrawMenuBar                               {   update menu bar     }
    end
  end
end; { of proc DoActivate }

(* initialize everything for the program *)

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

  { get four standard system cursors, plus one custom one               }
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

  { program-specific initialization }
  Init_Program_Stuff;
  
  UpdateMenu;                       { update menu as needed             }
  Finished := False                 { set program terminator to false   }  
end; { of proc Initialize }

(* to do whatever's needed before returning to Finder *)

procedure CleanUp;

begin
  DisposeWindow(MainPtr)            { get rid of the main window        }
end; { of proc CleanUp }

(* change cursors depending upon location *)

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

(* decodes event and handles it *)

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
