(*
 *	CMC Practice - Curved triangle area
 *	Student: Peter Romov
 *	Variant: 10.2.1	
 *)
program FunctionalArea;

uses Crt;

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
	while Abs(F(c)) >= eps do 
	begin
		if F(a)*F(c) < 0
			then b := c
			else a := c;
		c := a - F(a)*(b - a)/(F(b) - F(a));	
	end;
end;

{ Integral function
	compute value of definite integral of function f on interval [a, b] 
	- requires: a < b, eps > 0
	- returns value of integral }
function Integral(f : TRealFunction; a, b, eps : real) : real;

	{ Optional }
	const 
		startN = 10;	
	
	var i, n : integer;
		cur, prev, h : real;
		
begin
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
		n := n * 2;
		h := h / 2;
		cur := 0;
		for i := 1 to n do
			cur := cur + f(a + h*(i + 0.5));
		cur := cur * h;
	until Abs(prev - cur) / 3 < eps;
	Integral := cur;
end;

{ ========== DEFINED FUNCTIONS ==========}

function F1(x : real) : real;
begin
	F1 := 1 + 4 / ( Sqr(x) + 1 );
end;

function F2(x : real) : real;
begin
	F2 := x*x*x;
end;

function F3(x : real) : real;
begin
	F3 := Exp( -x * Ln(2) );
end;

const
	defaultA = -2;
	defaultB = 2;
	defaultEps = 1e-3;

{ ========== AREA COMPUTING ========== }

procedure ComputeTriangleArea(f1, f2, f3 : TRealFunction; a, b, eps : real);

	var funcs : array[1..3, 1..2] of TRealFunction;
		absc : array[1..3] of real;
		i : integer;
		
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
	begin
		Area := Abs(Integral(f1, a, b, eps) - Integral(f2, a, b, eps));
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
		absc[i] := Root(funcs[i, 1], funcs[i, 2], a, b, eps);
	Sort;
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
	TextColor(White);
	Write('    S');
	TextColor(Cyan);
	Write(' = ');
	TextColor(Blue);
	Write(Area(funcs[1, 1], funcs[1, 2], absc[1], absc[2], eps/2) + 
		Area(funcs[3, 1], funcs[3, 2], absc[2], absc[3], eps/2) :5:5);
	Writeln;
end;

begin
	ComputeTriangleArea(@F1, @F2, @F3, defaultA, defaultB, defaultEps);
end.
