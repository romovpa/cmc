(*
 *	CMC Practice - Curved triangle area
 *	Student: Peter Romov
 *	Variant: 10.2.1	
 *)
program FunctionalArea;

{$IFNDEF FPC}
{$F+}
{$ENDIF}

uses Crt {$IFDEF GRAPH}, Graph{$ENDIF};

{ ========== NUMERICAL METHODS ========== }

{ Real function type definition }
type 
	TRealFunction = function(x : real) : real;

{ Root function
	find cross point of functions f1 and f2 on interval [a, b]
	- requires: a < b, eps > 0, presence of cross point
	- returns result absciss in x }
function Root(f1, f2 : TRealFunction; a, b, eps : real) : real;

	function F(x : real) : real;
	begin
		F := f1(x) - f2(x);
	end;

	var c : real;

begin
	c := a - F(a)*(b - a)/(F(b) - F(a));
	while (Abs(c - a) >= eps) and (Abs(c - b) >= eps) do 
	begin
		if F(a)*F(c) > 0
			then a := c
			else b := c;
		c := a - F(a)*(b - a)/(F(b) - F(a));
	end;
	Root := c;
end;

{ Integral function
	compute value of definite integral of function f on interval [a, b] 
	- requires: eps > 0
	- returns value of integral }
function Integral(f : TRealFunction; a, b, eps : real; var err : boolean) : real;

	{ Optional }
	const 
		startN = 2;	
	
	var i, n : integer;
		cur, prev, h, muler : real;
		
begin
	err := false;
	if a > b
		then muler := -1
		else muler := 1;
	{ First iteration }
	n := startN;
	h := (b - a) / n;
	cur := 0;	
	for i := 1 to n do
		cur := cur + f(a + h*(i + 0.5));
	cur := cur * h;
	{ Next iterations }
	repeat 
		prev := cur;
		if LongInt(n) * 2 > MaxInt
			then err := true
			else begin 
				n := n * 2;
				h := h / 2;
				cur := 0;
				for i := 1 to n do
					cur := cur + f(a + h*(i + 0.5));
				cur := cur * h;
			end;
	until err or (Abs(prev - cur) / 3 < eps);
	Integral := cur * muler;
end;

{ ========== DEFINED FUNCTIONS ==========}

function F1(x : real) : real;
begin
	F1 := 1 + 4 / ( Sqr(x) + 1 );
	{F1 := Exp(x * Ln(2)) + 1;	
	F1 := 3 * (0.5 / (x + 1) + 1);
	F1 := Exp(-x) + 3;
	F1 := 1 / (x + 2);}
end;

function F2(x : real) : real;
begin
	F2 := x*x*x;
	{F2 := x*x*x*x*x;
	F2 := 2.5*x - 9.5;
	F2 := 2 * x - 2;
	F2 := 0.35 * Sqr(x) - 0.95 * x + 2.7;}
end;

function F3(x : real) : real;
begin
	F3 := Exp( -x * Ln(2) );
	{F3 := (1 - x) / 3;
	F3 := 5 / x;
	F3 := 1 / x;
	F3 := Exp(x * Ln(3)) + 1;}
end;

const
	defaultA = -2;
	defaultB = 2;
	defaultPointEps = 1e-5;
	defaultIntegralEps = 1e-3;

{ ========== AREA COMPUTING ========== }

type 
	TPoint = record
		x, y : real;
	end;

procedure ComputeTriangleArea(
	f1, f2, f3 : TRealFunction; 
	a, b, pEps, iEps : real; 
	var p1, p2, p3 : TPoint; 
	var square : real);

	var funcs : array[1..3, 1..2] of TRealFunction;
		absc : array[1..3] of real;
		i : integer;
		err : boolean;
		
	procedure Sort;
		var i, j : integer;
			f : TRealFunction;
			t : real;
	begin
		for i := 3 downto 1 do
			for j := 1 to i-1 do
				if absc[j] > absc[i] then
				begin
					t := absc[i];
					absc[i] := absc[j];
					absc[j] := t;
					f := funcs[i, 1];
					funcs[i, 1] := funcs[j, 1];
					funcs[j, 1] := f;
					f := funcs[i, 2];
					funcs[i, 2] := funcs[j, 2];
					funcs[j, 2] := f;					
				end;
	end;
		
	function Area(f1, f2 : TRealFunction; a, b, eps : real) : real;
		var e1, e2 : boolean;
	begin
		Area := Abs(Integral(f1, a, b, eps, e1) - Integral(f2, a, b, eps, e2));
		err := err or e1 or e2;
	end;
		
begin
	{ Preparing points }
	funcs[1, 1] := f1;
	funcs[1, 2] := f2;
	funcs[2, 1] := f2;
	funcs[2, 2] := f3;
	funcs[3, 1] := f1;
	funcs[3, 2] := f3;
	for i := 1 to 3 do
		absc[i] := Root(funcs[i, 1], funcs[i, 2], a, b, pEps);
	Sort;
	{ Filling points }
	p1.x := absc[1];
	p2.x := absc[2];
	p3.x := absc[3];
	p1.y := funcs[1, 1](p1.x);
	p2.y := funcs[2, 1](p2.x);
	p3.y := funcs[3, 1](p3.x);
	{ Printing points }
	TextColor(LightRed);
	Writeln('Triangle points:');
	for i := 1 to 3 do 
	begin
		TextColor(White);
		Write('    x', i);
		TextColor(Cyan);
		Write(' = ');
		TextColor(Blue);
		Write(absc[i]:5:5);
		TextColor(0);
		Writeln;
	end;
	{ Printing area }
	TextColor(LightRed);
	Writeln('Area:');
	err := false;
	square := Area(funcs[1, 1], funcs[1, 2], absc[1], absc[2], iEps/2) + 
		Area(funcs[3, 1], funcs[3, 2], absc[2], absc[3], iEps/2);
	if err 
		then begin
			TextColor(Red);
			Writeln('    Cannot achieve adjusted precision!');
		end;
	TextColor(White);
	Write('    S');
	TextColor(Cyan);
	Write(' = ');
	TextColor(Blue);
	Write(square:5:5);
	Writeln;
end;

{ ========== VISUALIZATION ========== }
{$IFDEF GRAPH}

const BGI_PATH = 'A:\tp\bgi';

procedure ShowVisualization(p1, p2, p3 : TPoint; area : real);
	
	const partsCount = 50;
	
	var driver, mode : integer;
		minTop, maxTop, minLeft, maxLeft : integer;
		minX, maxX, minY, maxY : real;
		inter : TPoint;
		err : boolean;
			
	function GetLeft(x : real) : integer;
	begin
		GetLeft := minLeft + round((x-minX)*(maxLeft-minLeft+1)/(maxX-minX));
	end;
	
	function GetTop(y : real) : integer;
	begin
		GetTop := maxTop - round((y-minY)*(maxTop-minTop+1)/(maxY-minY));
	end;
	
	procedure DrawAxes;
		var i : integer;
	begin
		Line(GetLeft(0), minTop, GetLeft(0), maxTop);
		Line(minLeft, GetTop(0), maxLeft, GetTop(0));
		Line(GetLeft(0), minTop, GetLeft(0)-5, minTop+20);
		Line(GetLeft(0), minTop, GetLeft(0)+5, minTop+20);
		Line(maxLeft, GetTop(0), maxLeft-20, GetTop(0)+5);
		Line(maxLeft, GetTop(0), maxLeft-20, GetTop(0)-5);
		{ Buttons }
		i := 1;
		while GetTop(i) > minTop do
		begin
			Line(GetLeft(0)-3, GetTop(i), GetLeft(0)+3, GetTop(i));
			OutTextXY(GetLeft(0)+7, GetTop(i)-3, chr(ord('0')+i));
			Line(GetLeft(0)-3, GetTop(-i), GetLeft(0)+3, GetTop(-i));
			OutTextXY(GetLeft(0)+7, GetTop(-i)-3, '-'+chr(ord('0')+i));
			i := i + 1;
		end; 
		i := 1;
		while GetTop(i) > minTop do
		begin
			Line(GetLeft(i), GetTop(0)+3, GetLeft(i), GetTop(0)-3);
			OutTextXY(GetLeft(i)-3, GetTop(0)+7, chr(ord('0')+i));
			Line(GetLeft(-i), GetTop(0)+3, GetLeft(-i), GetTop(0)-3);
			OutTextXY(GetLeft(-i)-3, GetTop(0)+7, '-'+chr(ord('0')+i));
			i := i + 1;
		end; 
	end;
	
	procedure DrawFunction(f : TRealFunction; color : integer);
		var k : integer;
			x1, x2, y1, y2: real;
	begin
		SetColor(color);
		for k := 1 to partsCount do
		begin
			x1 := minX + (k-1)*(maxX-minX)/partsCount;
			y1 := f(x1);
			x2 := minX + k*(maxX-minX)/partsCount;
			y2 := f(x2);
			Line(GetLeft(x1), GetTop(y1), GetLeft(x2), GetTop(y2));
		end;
	end;
	
	procedure ExtendYRange(f : TRealFunction; var min, max : real; 
		minX, maxX : real);
		var k : integer;
			x: real;
	begin
		for k := 1 to partsCount do
		begin
			x := minX + k*(maxX-minX)/partsCount;
			if f(x) < min 
				then min := f(x);
			if f(x) > max
				then max := f(x);
		end;
	end;
	
	procedure FindInternalPoint(var p : TPoint);
	begin
		p.x := (p2.x + p3.x) / 2;
		p.y := (p2.y + p3.y) / 2;
		p.x := (p.x - p1.x) * 2/3 + p1.x;
		p.y := (p.y - p1.y) * 2/3 + p1.y;
	end;
	
	function RealToStr(x : real) : string;
		var res : string;
	begin
		Str(x:3:3, res);
		RealToStr := res;
	end;
	
begin
	{ Initialization }
	minTop := 5;
	maxTop := 475;
	minLeft := 5;
	maxLeft := 635;
	minX := p1.x - 1;
	maxX := p3.x + 1;
	{minY := F1(x1);
	maxY := F1(x2);	
	ExtendYRange(F1, minY, maxY, x1, x2);
	ExtendYRange(F2, minY, maxY, x1, x2);
	ExtendYRange(F3, minY, maxY, x1, x2);
	minY := minY - 1;
	maxY := maxY + 1;}
	minY := -2;
	maxY := 6;
	{ Graphical mode }
	TextColor(Brown);
	Writeln('Press ENTER to show visualization');
	Readln;
	driver := Detect;
	InitGraph(driver, mode, BGI_PATH);
	{ Filling area }
	DrawFunction(F1, Red);
	DrawFunction(F2, Red);
	DrawFunction(F3, Red);
	SetFillStyle(10, Red);
	FindInternalPoint(inter);
	FloodFill(GetLeft(inter.x), GetTop(inter.y), Red);
	SetLineStyle(0, 0, 3);
	{ Drawing functions }
	DrawFunction(F1, LightGreen);
	DrawFunction(F2, LightBlue);
	DrawFunction(F3, LightCyan);
	SetColor(White);
	SetLineStyle(0, 0, 1);
	{ Drawing axes }
	DrawAxes;	
	{ Draw text }
	SetColor(Yellow);
	OutTextXY(GetLeft(inter.x), GetTop(inter.y), 'S='+RealToStr(area));
	{ DEBUG: drawing right triangle 
	Circle(GetLeft(inter.x), GetTop(inter.y), 5);
	Line(GetLeft(p1.x), GetTop(p1.y), GetLeft(p2.x), GetTop(p2.y));
	Line(GetLeft(p1.x), GetTop(p1.y), GetLeft(p3.x), GetTop(p3.y));
	Line(GetLeft(p3.x), GetTop(p3.y), GetLeft(p2.x), GetTop(p2.y));}
	{ Waiting for enter }
	Readln;
	CloseGraph;
end;

{$ENDIF}

var a, b, c : TPoint;
	area : real;

begin
	{$IFDEF FPC}
	ComputeTriangleArea(
		@F1, 
		@F2, 
		@F3, 
		defaultA, 
		defaultB, 
		defaultPointEps, 
		defaultIntegralEps, 
		a, b, c, area);
	{$ELSE}
	ComputeTriangleArea(
		F1, 
		F2, 
		F3, 
		defaultA, 
		defaultB, 
		defaultPointEps, 
		defaultIntegralEps, 
		a, b, c, area);
	{$ENDIF}
	{$IFDEF GRAPH}
	Writeln;
	ShowVisualization(a, b, c, area);
	{$ENDIF}
end.
