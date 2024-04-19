**ANIMAL**

ANIMAL Animation Applications Language was a motion control application originally created for the JK Animation Camera Stand. It provided motion control functions for communicating with multi-axis stepper motor system retrofitted for the JK Animation stands’ compound table (for XY motion + Rotation) and camera carriage (for Zoom + Follow Focus), plus camera exposure control. It was later adapted to a custom mutil-axis motion control rig at Animationsakademien in Stockholm, and Korty Films custom animation stand in San Francisco.

The name ANIMAL was coined after an existing JK Camera Optical Printer application called OPAL, Optical Printing Applications Language. OPAL was coded entirely in 8080 assembly language and ran on an S100-bus CP/M system, and featured a command-line interface using 3-letter commands. ANIMAL was coded in Pascal compiled for both CP/M and IBM PC-DOS systems with similar command-line interface. Support for external scripting was added later using 3-letter command syntax. Subsequent ANIMAL versions used more sophisticated text-based user interface libraries for Turbo Pascal, like TurboPower Professional Toolkits and Borland Turbo Vision libraries.

Basic animation movements were created with start and end points and incrementally calculated tapers. Stop-motion mode alternated camera exposures with incremental axis motion. Go-motion mode added axis motion during camera exposures for streak effects used in motion graphics. Live-action mode ran all axes concurrently with camera running, though originally only useful for preview purposes for simple linear movements. More complex curvilinear real-time motion became possible when ANIMAL was adapted to CompuMotor motion controllers.

The Point-Plotter feature was added to ANIMAL after being used in a more general machine tool application at JK machine shop for shaping sailboard hulls. The Point-Plotter function became more useful when adding splined curve-smoothing with the Borland Numerical Methods Toolkit and graphical plots with Borland Graphics Toolkit libraries.

There was also a Follow-Focus feature for correlating camera zoom motion and camera lens follow focus motion. The implementation used calculations based on the camera lens focal length and the classic Gaussian lens equation for image distance vs object distance.

Utility options included Overide for arbitrary motion, User units for converting mechanical dimensions to stepper motor steps, Backlash compensation for mechanical adjustments to lead screw movements, and Alignment procedure for locating zero axis positions from mechanical home or limit sensors.

The ANIMAL implementations for the JK Animation Stand communicated with an MCPU motion control system via RS232 serial interface for remotely dispatching motion commands. These were deployed to JK customers in San Francisco (Studio M, RoboMaster Industries), University of Hawaii Film Department in Honolulu, Animationsakademien in Stockholm, and animation studios in HongKong and Bombay.

The ANIMAL implementation for the Korty Films Animation Stand communicated with a CompuMotor motion control system via external RS232 serial interface and internal IBM PC ISA bus adapter. The Korty Animation stand was initially deployed at Interformat in San Francisco for 35mm film camera, then relocated to Pacific Video Resources for a real-time video camera adaptation.

**Links to Video Clips**

ANIMAL Go-Motion Streak Exposures on JK Animation Stand with 16mm Bolex Camera at RoboMaster Industries, San Francisco, 1984.

https://youtu.be/AXyDjjjlqxc

ANIMAL Splined Interpolation Follow Focus moves on multi-axis 35mm Mitchell Camera rig at Animationsakademien, Stockholm, 1986.

https://youtu.be/nHXvqUvt5N8

ANIMAL Stop-Motion moves with Fades + Dissolves on Korty animation stand with 35mm Mitchell at Interformat, San Francisco, 1988.

https://youtu.be/hZHaedQFkSQ

ANIMAL Live-Action curvilinear moves on Korty stand with Sony Pro video camera at Pacific Video Resources, San Francisco, 1991.

https://youtu.be/zpPCAsAT_iw

**Build Notes**

ANIMAL was originally developed for TurboPascal 2/3 with simple console I/O and single-letter command menus.
This early version TurboPascal compiler was just called `TURBO.EXE` and loaded the main `ANIMAL.PAS` file 
into a text-based IDE for compiling a .COM executable plus TP3-optional overlay binaries.

```
cd TP3
cd ANIMAL
turbo ANIMAL.PAS
dir ANIMAL.COM
```

For 20-axis custom animation stand rig at Animationsakademien:

```
cd ANISAK
turbo ANIMAL.PAS
dir ANIMAL.COM
```

Later versions of TurboPascal 5/6/7 used text-based UI called TurboVision and linked with TPU library components (TurboPascal Units).
Need to unpack TPU ZIPs for TurboVision library, TurboProfessional Toolkit libraries, and default TurboPascal Unit libraries to link.
Refer to `TPMAKE.BAT` batch file for TP7 command line options.

```
cd TPU
unzip *.ZIP
cd ..
cd TP7
cd TVANI
tpc TVANI47.PAS /U..\..\TPU /L /$G+ /M
dir TVANI47.EXE
```

For optical printer sequencer, with options for console I/O vs TurboVision interface in `SWITCHES.INC`:

```
cd TVSEQ
tpc TESTSEQ.PAS /U..\..\TPU /L /$G+ /M
dir TESTSEQ.EXE
```

```
copy TESTSEQ.PAS TVSEQ.PAS
echo "{$DEFINE USE_TURBO_VISION}" >> SWITCHES.INC
edit SWITCHES.INC
tpc TVSEQ.PAS /U..\..\TPU /L /$G+ /M
dir TVSEQ.EXE
```



Macintosh versions of TurboPascal and CodeWarrior used primitive Mac Toolbox dialogs and menus which predominated each ANIMAL port.
So only the most basic MCPU motion control commands for ANIMAL stop-motion sequences were ever implemented. (Primarily intended as
a learning experience for Macintosh programming.) AFAIR, either IDE loaded the main ANIMAL.PAS file and built via Command-B menu.
Refer to `MAC/TP` or `MAC/CW` folders for TurboPascal or CodeWarrior projects respectively, which only work on Classic Mac OS. 
