
(* Point-Plotter Spliner. *)

Unit SPLINE;

Interface

Const

   Max_Points = 11;
   Max_Spline = 2001;

Type

   TnVector = Array [0..Max_Points] of Real;
   Real_Array = Array [0..Max_Spline] of Real;

(* Var for Coef0, Coef1, Coef2, Coef3 deleted. *)

procedure CubicSplineFree(NumPoints : integer;
                      var XData     : TNvector;
                      var YData     : TNvector;
                          NumInter  : integer;
                      var XInter    : Real_Array;
                      var YInter    : Real_Array;
                      var Error     : integer);

Implementation

(* CUBIC SPLINE FREE computes free cubic splines for XY arrays. *)
(* Copyright Borland International. Used with permission under license. *)

procedure CubicSplineFree(NumPoints : integer;
                      var XData     : TNvector;
                      var YData     : TNvector;
                   (* var Coef0     : TNvector; *)
                   (* var Coef1     : TNvector; *)
                   (* var Coef2     : TNvector; *)
                   (* var Coef3     : TNvector; *)
                          NumInter  : integer;
                      var XInter    : Real_Array;
                      var YInter    : Real_Array;
                      var Error     : integer);


{----------------------------------------------------------------------------}
{-    Input:  NumPoints, XData, YData, NumInter, XInter                     -}
{-    Output: Coef0, Coef1, Coef2, Coef3, YInter, Error                     -}
{-                                                                          -}
{-              Errors: 0: No error                                         -}
{-                      1: X-coordinate points not unique                   -}
{-                      2: X-coordinate points not in increasing order      -}
{-                      3: NumPoints < 2                                    -}
{----------------------------------------------------------------------------}

{$R-}                        { Range checking }

const
  TNNearlyZero = 1E-07;      { Turbo Pascal syntax error?               }
                             { TNNearlyZero = 1E-015 for 8087 Turbo-87  }
                             { TNNearlyZero = 1E-07  for non-8087 Turbo }
type
  TNcoefficients = record
                     A, B, C, D : TNvector;
                   end;

var
  Interval : TNvector;        { Intervals between adjacent points }
  Spline : TNcoefficients;    { All the cubics }


procedure CalculateIntervals(NumPoints : integer;
                         var XData     : TNvector;
                         var Interval  : TNvector;
                         var Error     : integer);

{----------------------------------------------------------}
{- Input: NumPoints, XData                                -}
{- Output: Interval, Error                                -}
{-                                                        -}
{- This procedure calculates the length of the interval   -}
{- between two adjacent X values, contained in XData. If  -}
{- the X values are not sequential, Error = 2 is returned -}
{- and if the X values are not unique, then Error = 1 is  -}
{- returned.                                              -}
{----------------------------------------------------------}

var
  Index : integer;

begin
  Error := 0;
  for Index := 1 to NumPoints - 1 do
  begin
    Interval[Index] := XData[Index+1] - XData[Index];
    if ABS(Interval[Index]) < TNNearlyZero then
      Error := 1;     { Data not unique }
    if Interval[Index] < 0 then
      Error := 2;     { Data not in increasing order }
  end;
end; { procedure CalculateIntervals }

procedure CalculateCoefficients(NumPoints : integer;
                            var XData     : TNvector;
                            var YData     : TNvector;
                            var Interval  : TNvector;
                            var Spline    : TNcoefficients);

{---------------------------------------------------------------}
{- Input: NumPoints, XData, YData, Interval                    -}
{- Output: Spline                                              -}
{-                                                             -}
{- This procedure calculates the coefficients of each cubic    -}
{- in the interpolating spline. A separate cubic is calculated -}
{- for every interval between data points.  The coefficients   -}
{- are returned in the variable Spline.                        -}
{---------------------------------------------------------------}

procedure CalculateAs(NumPoints : integer;
                  var YData     : TNvector;
                  var Spline    : TNcoefficients);

{------------------------------------------}
{- Input: NumPoints, YData                -}
{- Ouput: Spline                          -}
{-                                        -}
{- This procedure calculates the constant -}
{- Term in each cubic.                    -}
{------------------------------------------}

var
  Index : integer;
begin
  for Index := 1 to NumPoints do
    Spline.A[Index] := YData[Index];
end; { procedure CalculateAs }

procedure CalculateCs(NumPoints : integer;
                  var XData     : TNvector;
                  var Interval  : TNvector;
                  var Spline    : TNcoefficients);

{---------------------------------------------}
{- Input: NumPoints, XData, Interval         -}
{- Ouput: Spline                             -}
{-                                           -}
{- This procedure calculates the coefficient -}
{- of the squared Term in each cubic.        -}
{---------------------------------------------}

var
  Alpha, L, Mu, Z : TNvector;
  Index : integer;
begin
  with Spline do
  begin
    { The next few lines solve a tridiagonal matrix }
    for Index := 2 to NumPoints - 1 do
      Alpha[Index] := 3 * ((A[Index+1] * Interval[Index-1])
                         - (A[Index] * (XData[Index+1] - XData[Index-1]))
                         + (A[Index-1] * Interval[Index]))
                         / (Interval[Index-1] * Interval[Index]);
    L[1] := 0;
    Mu[1] := 0;
    Z[1] := 0;
    for Index := 2 to NumPoints - 1 do
    begin
      L[Index] := 2 * (XData[Index+1] - XData[Index-1])
                    - Interval[Index-1] * Mu[Index-1];
      Mu[Index] := Interval[Index]/L[Index];
      Z[Index] := (Alpha[Index] - Interval[Index-1] * Z[Index-1]) / L[Index];
    end;
    { Now calculate the C's }
    C[NumPoints] := 0;
    for Index := NumPoints - 1 downto 1 do
      C[Index] := Z[Index] - Mu[Index] * C[Index+1];
  end; { with }
end; { procedure CalculateCs }

procedure CalculateBandDs(NumPoints : integer;
                      var Interval  : TNvector;
                      var Spline    : TNcoefficients);

{------------------------------------------------}
{- Input: NumPoints, Interval                   -}
{- Ouput: Spline                                -}
{-                                              -}
{- This procedure calculates the coefficient of -}
{- the linear and cubic terms in each cubic.    -}
{------------------------------------------------}

var
  Index : integer;
begin
  with Spline do
    for Index := NumPoints - 1 downto 1 do
    begin
      B[Index] := (A[Index+1] - A[Index]) / Interval[Index]
                   - Interval[Index] * (C[Index+1] + 2 * C[Index]) / 3;
      D[Index] := (C[Index+1] - C[Index]) / (3 * Interval[Index]);
    end;
end; { procedure CalculateDs }

begin { procedure CalculateCoefficients }
  CalculateAs(NumPoints, YData, Spline);
  CalculateCs(NumPoints, XData, Interval, Spline);
  CalculateBandDs(NumPoints, Interval, Spline);
end; { procedure CalculateCoefficients }

procedure Interpolate(NumPoints : integer;
                  var XData     : TNvector;
                  var Spline    : TNcoefficients;
                      NumInter  : integer;
                  var XInter    : Real_Array;
                  var YInter    : Real_Array);

{---------------------------------------------------------------}
{- Input: NumPoints, XData, Spline, NumInter, XInter           -}
{- Output: YInter                                              -}
{-                                                             -}
{- This procedure uses the interpolating cubic spline (Spline) -}
{- to interpolate values for the X positions contained         -}
{- in XInter.  The interpolated values are returned in YInter. -}
{---------------------------------------------------------------}

var
  Index, Location, Term : integer;
  X : real;

begin
  for Index := 1 to NumInter do
  begin
    Location := 1;
    for Term := 1 to NumPoints - 1 do
      if XInter[Index] > XData[Term] then
        Location := Term;
    X := XInter[Index] - XData[Location];
    with Spline do
      YInter[Index] := ((D[Location] * X + C[Location]) * X +
                         B[Location]) * X + A[Location];
  end;
end; { procedure Interpolate }

begin { procedure CubicSplineFree }
  Error := 0;
  if NumPoints < 2 then
    Error := 3
  else
    CalculateIntervals(NumPoints, XData, Interval, Error);
  if Error = 0 then
  begin
    CalculateCoefficients(NumPoints, XData, YData, Interval, Spline);
    (* Coef0 := Spline.A;
    (* Coef1 := Spline.B;
    (* Coef2 := Spline.C;
    (* Coef3 := Spline.D; *)
    Interpolate(NumPoints, XData, Spline, NumInter, XInter, YInter);
  end;


end; { procedure CubicSplineFree }

End.
