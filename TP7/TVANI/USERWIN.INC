(* TGInterior extensions *)

Const
  MaxLines = Max_Spline;

Type
  PInterior = ^TInterior;
  TInterior = object(TScroller)
    LineCount : Integer;
    Lines : array [0..MaxLines] of PString;
    constructor Init(var Bounds: TRect; AHScrollBar,
      AVScrollBar: PScrollBar);
    procedure Draw; virtual;
    Destructor Done; Virtual;
    Procedure LoadBuffer;
    Procedure UnloadBuffer;
  end;

  PDisplayWindow = ^TDisplayWindow;
  TDisplayWindow = object(TWindow)
    Active : Boolean;
    constructor Init(Bounds: TRect; WinTitle: String; WindowNo: Word);
    procedure MakeInterior(Bounds: TRect);
    Destructor Done; Virtual;
  end;

  PGInterior = ^TGInterior;
  TGInterior = Object (TInterior)
    AxIn : Integer;
    GLineCount : Integer;
    GLines : Array [0..Yres] of PString;
    Constructor Init(var Bounds: TRect; AHScrollBar,
      AVScrollBar: PScrollBar);
    Procedure Draw; Virtual;
    Destructor Done; Virtual;
    Procedure LoadBuffer;
    Procedure UnloadBuffer;
  end;

  PGWindow = ^TGWindow;
  TGWindow = Object (TWindow)
    Active : Boolean;
    AxIn : Integer;
    Constructor Init (Bounds: TRect; WinTitle: String; WindowNo: Word);
    Procedure MakeInterior (Bounds: TRect);
    Destructor Done; Virtual;
  end;

Var
  WinCount : Integer;

  Window : PDisplayWindow;                  (* display window pointer *)
  GWindow : Array [XX..RR] of PGWindow;     (* graphics window pointer *)

  DWindowActive : Boolean;                  (* external window flag *)
  GWIndowActive : Array [XX..RR] of Boolean;(* ext graphics window flags *)

(* Extend window interior constructor for graphics displays. *)
(* Also extend for creating display point buffer in heap. *)
(* Initialize extended fields after Ancestor Init. *)

Constructor TGInterior.Init (var Bounds: TRect; AHScrollBar,
  AVScrollBar: PScrollBar);
begin
  TScroller.Init(Bounds, AHScrollBar, AVScrollBar);
  GrowMode := gfGrowHiX + gfGrowHiY;
  Options := Options or ofFramed;
  SetLimit (Xres, Yres+1);
  Self.AxIn := Index;
  TGInterior.LoadBuffer;
end;

(* Extend window interior draw-er to completely write out string lines. *)

procedure TGInterior.Draw;
var
  Color: Byte;
  I, Y: Integer;
  B: TDrawBuffer;
begin
  Color := GetColor(1);
  for Y := 0 to Size.Y - 1 do
    begin
    MoveChar(B, ' ', Color, Size.X);
    I := Delta.Y + Y;
    if (I < GLineCount) and (GLines [I] <> nil) then
      MoveStr (B, Copy (GLines [I]^, Delta.X + 1, Size.X), Color);
    WriteLine (0, Y, Size.X, 1, B);
    end;
end;

(* Extend window interior destructor to dispose of display point buffer. *)

Destructor TGInterior.Done;
Begin
   TGInterior.UnloadBuffer;
   TScroller.Done;
End;

(* Load graphics display buffer of points as strings in heap memory. *)

Procedure TGInterior.LoadBuffer;
var
  S : String;
  P : Integer;
  A : Integer;
  XYbuf : XYscreen;             (* XY screen buffer *)
Begin
  A := Self.AxIn;
  Buffer_Graphics_Plot (A, XYbuf);
  GLineCount := 0;
  For P := 0 to Yres Do
      If GLineCount <= Yres
         Then begin
         Graph_Point_Line (XYbuf, P, S);
         GLines [GLineCount] := NewStr (S);
         Inc (GLineCount);
         end;
End;

(* Unload graphics display buffer from heap memory. *)

Procedure TGInterior.UnloadBuffer;
var
  I: Integer;
Begin
  for I := 0 to GLineCount-1 do
    if GLines [I] <> nil then DisposeStr (GLines [I]);
  GLineCount := 0;
End;

(* Extend window constructor for size, title, and number. *)
(* Also extend for creating display point buffer in heap. *)

Constructor TGWindow.Init (Bounds: TRect; WinTitle: String;
  WindowNo: Word);
begin
  TWindow.Init (Bounds, WinTitle, WindowNo);
  Self.Active := True;
  Self.AxIn := Index;
  GWindowActive [Self.AxIn] := True;
  TGWindow.MakeInterior (Bounds);
end;

(* Extend window interior-maker to draw full interior with scroll bars. *)

Procedure TGWindow.MakeInterior (Bounds: TRect);
var
  HScrollBar, VScrollBar: PScrollBar;
  Interior: PGInterior;
  R: TRect;
begin
  VScrollBar := StandardScrollBar(sbVertical + sbHandleKeyboard);
  HScrollBar := StandardScrollBar(sbHorizontal + sbHandleKeyboard);
  GetExtent(Bounds);
  Bounds.Grow(-1,-1);
  Interior := New (PGInterior, Init (Bounds, HScrollBar, VScrollBar));
  Insert (Interior);
end;

(* Extend window destructor just because. (Virtual always extended? - YES) *)

Destructor TGWindow.Done;
Begin
   Self.Active := False;
   GWindowActive [Self.AxIn] := False;
   TWindow.Done;
End;

(*****)

(* TDisplayWindow extensions *)

(* Extend window constructor for size, title, and number. *)
(* Also extend for creating display point buffer in heap. *)

constructor TDisplayWindow.Init(Bounds: TRect; WinTitle: String;
  WindowNo: Word);
var
  S: string[3];
begin
  Str (WindowNo, S);
  TWindow.Init(Bounds, WinTitle, WindowNo);
  Self.Active := True;
  DWindowActive := True;
  MakeInterior(Bounds);
end;

(* Extend window interior-maker to draw full interior with scroll bars. *)

procedure TDisplayWindow.MakeInterior(Bounds: TRect);
var
  HScrollBar, VScrollBar: PScrollBar;
  Interior: PInterior;
  R: TRect;
begin
  VScrollBar := StandardScrollBar(sbVertical + sbHandleKeyboard);
  HScrollBar := StandardScrollBar(sbHorizontal + sbHandleKeyboard);
  GetExtent(Bounds);
  Bounds.Grow(-1,-1);
  Interior := New(PInterior, Init(Bounds, HScrollBar, VScrollBar));
  Insert (Interior);
end;

(* Extend window destructor to dispose of display point buffer. *)

Destructor TDisplayWindow.Done;
Begin
   Self.Active := False;
   DWindowActive := False;
   TWindow.Done;
End;

(* TInterior extensions *)

(* Extend window interior constructor to include scroll bars. *)
(* Also extend for creating display point buffer in heap. *)

Constructor TInterior.Init (var Bounds: TRect; AHScrollBar,
  AVScrollBar: PScrollBar);
begin
  TScroller.Init(Bounds, AHScrollBar, AVScrollBar);
  GrowMode := gfGrowHiX + gfGrowHiY;
  Options := Options or ofFramed;
  TInterior.LoadBuffer;
  SetLimit (128, LineCount);
end;

(* Extend window interior draw-er to completely write out string lines. *)

procedure TInterior.Draw;
var
  Color: Byte;
  I, Y: Integer;
  B: TDrawBuffer;
begin
  Color := GetColor(1);
  for Y := 0 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', Color, Size.X);
    I := Delta.Y + Y;
    if (I < LineCount) and (Lines[I] <> nil) then
      MoveStr (B, Copy (Lines[I]^, Delta.X + 1, Size.X), Color);
    WriteLine (0, Y, Size.X, 1, B);
  end;
end;

(* Extend window interior destructor to dispose of display point buffer. *)

Destructor TInterior.Done;
Begin
   TInterior.UnloadBuffer;
   TScroller.Done;
End;

(* Load display buffer of points as strings in heap memory. *)

Procedure TInterior.LoadBuffer;
var
  S : String;
  P : Integer;
Begin
  LineCount := 0;
  For P := 1 to XYno Do
      If LineCount < MaxLines
         Then begin
         Display_Point_Line (P, S);
         Lines [LineCount] := NewStr(S);
         Inc (LineCount);
         end;
End;

(* Unload display buffer from heap memory. *)

Procedure TInterior.UnloadBuffer;
var
  I: Integer;
Begin
  for I := 0 to LineCount-1 do
    if Lines[I] <> nil then DisposeStr (Lines[I]);
  LineCount := 0;
End;

(*****************************************)

(* Turbo Vision user interface routines. *)

(* Open a window to display points. *)

Procedure TVApp.DisplayWindow;
var
  R: TRect;
  S : String;
begin
  If DWindowActive                       (* external window flag ? *)
     Then If Window <> Nil               (* pointer exist at all ? *)
          Then begin
          Window^.Close;                 (* close + dispose *)
          Window := Nil;                 (* nullify *)
          DWindowActive := False;        (* un-flag *)
          end;
  Inc(WinCount);
  If WinCount > 9
     Then WinCount := 1;
  R.Assign(10, 0, 70, 23);
  Str (XYno, S);
  CheapStatus ('...Displaying ' + S + ' Points...');
  Window := New(PDisplayWindow, Init(R, 'Display ' + S + ' Points', WinCount));
  Window^.HelpCtx := hcEditDisplay;
  If ValidView (Window) <> Nil
     Then DeskTop^.Insert (Window);
  CheapStatusClear;
end;

(* Open a window to display points with graphics. *)

Procedure TVApp.DisplayGraphics;
var
  R : TRect;
  S : String;
  T : String;
begin
If Index in [XX, YY, ZZ, RR]
  Then begin
  If GWindowActive [Index]                       (* flag ? *)
     Then If GWindow [Index] <> Nil              (* pointer ? *)
          Then begin
          GWindow [Index]^.Close;                (* close + dispose *)
          GWindow [Index] := Nil;                (* nullify *)
          GWindowActive [Index] := False;        (* un-flag *)
          end;
  Inc (WinCount);
  If WinCount > 9
     Then WinCount := 1;
  Case Index of
       XX : R.Assign (0, 0, 80, 22);
       YY : R.Assign (1, 1, 80, 23);
       ZZ : R.Assign (2, 2, 80, 23);
       RR : R.Assign (3, 3, 80, 23);
       end;
  Str (XYno, S);
  CheapStatus ('...Graphing ' + S + ' Points...');
  T := 'Graph ' + S + ' Points for Axis ' + AA [Index].Id;
  GWindow [Index] := New (PGWindow, Init (R, T, WinCount));
  If ValidView (GWindow [Index]) <> Nil
     Then DeskTop^.Insert (GWindow [Index]);
  CheapStatusClear;
  end;
end;

(* Update any/all active windows open on desktop. *)

Procedure TvApp.UpdateAllWindows;

Begin
End;

(* Display dummy window at full screen size to cover desktop area,
(* then switch to Hercules Graphics routine,
(* and finally unload dummy window to redraw desktop area. *)
(* Re-enable menu bar and mouse event handler too. *)

Type
  PDemoHGraph = ^TDemoHGraph;               (* high-resolution graphics *)
  TDemoHGraph = object(TWindow)
  end;

Procedure TvApp.HirezGraphics;
var
  Window: PDemoHGraph;
  R: TRect;
begin
  R.Assign(0, 0, 80, 23);
  Window := New (PDemoHGraph, Init (R, '', wnNoNumber));
  HideMouse;
  DeskTop^.Insert (Window);
  Go_Graphics;
  DeskTop^.Delete (Window);
  ShowMouse;
  MenuBar^.Draw;
  InitEvents;
end;

(* Dialog for selecting axis to graph points. *)

Type
  GraphOptionsType = Record
    Yaxis : Word;
    Xaxis : Word;
    HiRez : Word;
    end;

Var
  Graph_Options : GraphOptionsType;

Type
  PGraphDialog = ^TGraphDialog;
  TGraphDialog = Object (TDialog)
    end;

Procedure TVApp.GraphicsDialog;
var
  The_Dialog: PView;
  Dialog: PGraphDialog;
  R: TRect;
  C: Word;
begin
If XYno <= 1
  Then MessageBox ('No plot points in memory',Nil, mfInformation + mfOkButton )
  Else begin
  R.Assign(20, 5, 60, 17);
  Dialog := New (PGraphDialog, Init(R, ' Graph Points '));
  with Dialog^ do
  begin
    HelpCtx := hcEditGraphics;

    R.Assign (3, 3, 19, 7);
    The_Dialog := New (PRadioButtons, Init (R,
      NewSItem ('Axis ~XX~',
      NewSItem ('Axis ~YY~',
      NewSItem ('Axis ~ZZ~',
      NewSItem ('Axis ~RR~',
      nil))))
    ));
    Insert (The_Dialog);
    R.Assign (3, 2, 19, 3);
    Insert (New (PLabel, Init (R, 'Vertical', The_Dialog)));

    R.Assign (21, 3, 37, 5);
    The_Dialog := New (PRadioButtons, Init (R,
      NewSItem ('~P~ositions',
      NewSItem ('~I~ncrements',
      nil))
    ));
    Insert (The_Dialog);
    R.Assign (21, 2, 37, 3);
    Insert (New (PLabel, Init (R, 'Horizontal', The_Dialog)));

    R.Assign (21, 6, 37, 7);
    The_Dialog := New (PCheckBoxes, Init (R,
      NewSItem ('~H~igh Res', nil)));
    Insert (The_Dialog);

    R.Assign (6, 9, 16, 11);
    Insert (New (PButton, Init (R, '~G~raph', cmOK, bfDefault)));
    R.Assign (24, 9, 34, 11);
    Insert (New (PButton, Init (R, 'Cancel', cmCancel, bfNormal)));

    SelectNext (False);
  end;

  if (not Graphics_Loaded) and (GWindow[XX] = nil)
  then
  With Graph_Options Do
    begin
    Yaxis := 0;
    Xaxis := 0;
    HiRez := 0;
    end;

  repeat

  Dialog^.SetData (Graph_Options);
  C := DeskTop^.ExecView(Dialog);
  if C = cmOk
     then begin
     Dialog^.GetData (Graph_Options);
     Case Graph_Options.Yaxis of
          0 : Index := XX;
          1 : Index := YY;
          2 : Index := ZZ;
          3 : Index := RR;
          Else Index := XX;
          end;
     Delta_Graphics := (Graph_Options.Xaxis <> 0);
     Really_Graphics := (Graph_Options.HiRez <> 0);
     If Index in [XX, YY, ZZ, RR]
        Then If Really_Graphics
             Then HirezGraphics
             Else DisplayGraphics;
     end;

  until (C = cmCancel);

  Dispose(Dialog, Done);
  end; (* if graphics dialog at all *)
end;

