(* Resource file IDs used by Animal application. *)

Unit RezId;

Interface

const
		ApplMenu = 1000;    { resource ID of Apple Menu          }
		FileMenu = 1010;    { resource ID of File Menu           }
		EditMenu = 1020;    { resource ID of Edit Menu           }
		RunnMenu = 1030;    { Run Menu                           }
		OverMenu = 1040;    { Overide Menu                       }
		UtilMenu = 1050;    { Utilities Menu                     }
		SpecMenu = 1060;    { Special Menu                       }

		MainID = 1000;    	{ resource ID for MainWindow         }
		AboutID = 1000;     { resource ID for dialog box         }
		Text1ID = 1000;     { resource IDs for 'About...' text   }
		Text2ID = 1001;
		Text3ID = 1002;

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

		RgbId = 3010;		(* RGB direct IO dialog *)
		RgbPgmId = 3020;	(* RGB program dialog *)
		RgbRunId = 3030;	(* RGB run dialog *)
		ColorId = 3040;		(* RGB color table dialog *)

End.
