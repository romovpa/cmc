(*
 *	CMC Practice - Derivative of formula
 *	Student: Peter Romov
 *	Variant: 20
 *)
program Derivative;

uses Crt;

{ ========== EXPRESSIONS ========== }

const
	variableChar = 'x';
	arithmeticChars = ['+', '-', '*'];
	numberChars = ['0'..'9'];
	bracketChars = ['(', ')'];
	expressionChars = arithmeticChars + numberChars + bracketChars + [variableChar];

type 
	PExpression = ^TExpression;
	TExpression = record
		operation : char;
		left, right : PExpression;
	end;

{ Destroys expression tree }	
procedure DestroyExpression(var root : PExpression);
begin
	if root <> nil then 
	begin
		DestroyExpression(root^.left);
		DestroyExpression(root^.right);
		Dispose(root);
		root := nil;
	end;
end;

{ Parses expression from string }
{ err contains error char index or -1 if success }
procedure ParseExpression(s : string; var root : PExpression; var err : integer);

	var pos : integer;
	
	procedure Parse(var ptr : PExpression);	
	begin
		if pos > Length(s) then 
			err := pos
		else begin
			New(ptr);
			ptr^.left := nil;
			ptr^.right := nil;
			if s[pos] = '('	then begin
				pos := pos + 1;
				Parse(ptr^.left);
				if err = -1 then begin
					if s[pos] in arithmeticChars then begin
						ptr^.operation := s[pos];
						pos := pos + 1;
						Parse(ptr^.right);
						if err = -1 then begin
							if (pos <= Length(s)) and (s[pos] = ')') 
								then pos := pos + 1
								else err := pos;
						end;
					end
					else err := pos;					
				end;
			end
			else if s[pos] in [variableChar] + numberChars then begin
				ptr^.operation := s[pos];
				pos := pos + 1;
			end
			else 
				err := pos;
		end;		
	end;

begin
	err := -1;
	pos := 1;
	Parse(root);
	if pos <= Length(s)
		then err := pos;
	if err <> -1
		then DestroyExpression(root);
end;

{ ========== POLYNOMIAL ========== }

type 
	PPolyNode = ^TPolyNode;
	TPolyNode = record
		coeff : integer;
		next : PPolyNode;
	end;

function ZeroPoly(coeff : integer) : PPolyNode;
	var res : PPolyNode;
begin
	New(res);
	res^.coeff := coeff;
	res^.next := nil;
	ZeroPoly := res;
end;

function LinearPoly : PPolyNode;
	var res : PPolyNode;
begin
	New(res);
	res^.coeff := 0;
	New(res^.next);
	res^.next^.coeff := 1;
	res^.next^.next := nil;
	LinearPoly := res;
end;

function PolyToStr(p : PPolyNode) : string;
	var res, s : string;
		k : integer;
		first : boolean;
begin
	res := '';
	k := 0;
	first := true;
	while p <> nil do begin
		if p^.coeff <> 0 then begin
			if first 
				then first := false
				else res := res + ' + ';
			if (p^.coeff <> 1) or (k = 0) then begin
				Str(p^.coeff, s);
				res := res + s;
			end;
			if k > 0 then begin
				res := res + variableChar;
				if k > 1 then begin
					Str(k, s);
					res := res + '^' + s;
				end;
			end;
		end;
		p := p^.next;
		k := k + 1;
	end;
	if first 
		then res := '0';
	PolyToStr := res;
end;

procedure DestroyPoly(var p : PPolyNode);
	var t : PPolyNode;
begin
	while p <> nil do begin
		t := p;
		p := p^.next;
		Dispose(t);
	end;
end;

function SumPoly(p1, p2 : PPolyNode) : PPolyNode;
	var p : PPolyNode;
begin
	SumPoly := nil;
	p := nil;
	while (p1 <> nil) or (p2 <> nil) do begin
		if p = nil 
			then begin
				New(p);
				SumPoly := p;
			end
			else begin
				New(p^.next);
				p := p^.next;
			end;
		p^.next := nil;
		p^.coeff := 0;
		if p1 <> nil
			then p^.coeff := p^.coeff + p1^.coeff;
		if p2 <> nil
			then p^.coeff := p^.coeff + p2^.coeff;
		if p1 <> nil
			then p1 := p1^.next;
		if p2 <> nil
			then p2 := p2^.next;
	end;
end;

function MulPoly(p1, p2 : PPolyNode) : PPolyNode; 
	var i, j, p, t : PPolyNode;
begin
	i := p1;
	t := nil;
	while i <> nil do begin
		j := p2;
		if t = nil
			then begin
				New(t);
				MulPoly := t;
				t^.coeff := 0;
				t^.next := nil;
			end
			else begin
				if t^.next = nil
					then begin
						New(t^.next);
						t^.next^.next := nil;
						t^.next^.coeff := 0;
					end;
				t := t^.next;
			end;
		p := t;
		while j <> nil do begin
			p^.coeff := p^.coeff + i^.coeff * j^.coeff;
			j := j^.next;
			if (j <> nil) and (p^.next = nil)
				then begin
					New(p^.next);
					p^.next^.next := nil;
					p^.next^.coeff := 0;
				end;
			p := p^.next;
		end;
		i := i^.next;
	end;
end;

function ExpressionToPoly(root : PExpression) : PPolyNode;
	var p1, p2, p : PPolyNode;
		m : longint;
begin
	if root = nil
		then ExpressionToPoly := ZeroPoly(0)
	else if root^.operation in numberChars
		then ExpressionToPoly := ZeroPoly(ord(root^.operation) - ord('0'))
	else if root^.operation = variableChar
		then ExpressionToPoly := LinearPoly
	else if root^.operation in arithmeticChars
		then begin 
			p1 := ExpressionToPoly(root^.left);
			p2 := ExpressionToPoly(root^.right);
			if root^.operation = '+'
				then ExpressionToPoly := SumPoly(p1, p2)
			else if root^.operation = '-'
				then begin
					p := p2;
					while p <> nil do 
					begin
						p^.coeff := - p^.coeff;
						p := p^.next;
					end;
					ExpressionToPoly := SumPoly(p1, p2);
				end	
			else if root^.operation = '*'
				then ExpressionToPoly := MulPoly(p1, p2);
			DestroyPoly(p1);
			DestroyPoly(p2);
		end;
end;

function PolynomialDifferential(root : PExpression) : PPolyNode;
	var res, p : PPolyNode;
		k : integer;
begin
	res := ExpressionToPoly(root);
	p := res;
	k := 0;
	while p <> nil do begin
		p^.coeff := p^.coeff * k;
		k := k + 1;
		p := p^.next;
	end;
	PolynomialDifferential := res^.next;
	Dispose(res);
end;

{ ========== USER INTERFACE ========== }

{ Makes input bar on current line and read the expression }
procedure InputExpression(var root : PExpression);

	const 
		keyEnter = 13;
		keyReturn = 8;
		
		barBackground = LightGray;
		barTextColor = Black;
		barErrColor = Red;

	var y, leftX, rightX, barLength, err, shift : integer;
		key : char;
		s : string;

	procedure RefreshBar(active : boolean);
		var i : integer;
	begin
		if active then 
		begin
			DestroyExpression(root);
			ParseExpression(s, root, err);	
			TextColor(barTextColor);
			TextBackground(barBackground);
		end;
		for i := 1 to rightX - leftX + 1 do 
		begin
			GoToXY(leftX + i - 1, y);
			if i + shift <= Length(s)
				then begin
					if active and (err = i + shift) 
						then TextColor(barErrColor);
					Write(s[i + shift]);			
					if active	
						then TextColor(barTextColor);
				end
				else Write(' '); 
		end;		
	end;

begin
	{ Initialization of coordinates }
	y := WhereY;
	leftX := WhereX;
	rightX := Lo(WindMax);
	barLength := rightX - leftX;
	{ Initialization of bar }
	s := '';
	err := -1;
	shift := 0;
	RefreshBar(true);
	repeat
		key := ReadKey;
		if (ord(key) = keyReturn) and (Length(s) > 0)
			then begin
				Delete(s, Length(s), 1);
				if shift > 0
					then shift := shift - 1;
				RefreshBar(true);
			end
		else if (key in expressionChars) and ((err = -1) or (err > Length(s)))
			then begin
				s := s + key;
				if Length(s) - shift > barLength
					then shift := shift + 1;
				RefreshBar(true);
			end;
	until (ord(key) = keyEnter) and (err = -1);
	NormVideo;
	RefreshBar(false);
	Writeln;
end;

{ ========== MEMORY ========== }

var mav : longint;
	
procedure MemKeep;
begin
	{$IFDEF MEM}
	mav := MemAvail;
	{$ENDIF}
end;

function MemLeak : integer;
begin
	{$IFDEF MEM}
	MemLeak := mav - MemAvail;
	{$ENDIF}
end;

var e : PExpression;
	p : PPolyNode;
	m : longint;
	done : boolean;

begin
	repeat
		MemKeep;
		{ Reading function }
		Write('f(x) = ');
		InputExpression(e);
		{ Polynomial differentiation }
		p := PolynomialDifferential(e);
		Writeln('f''(x) = ', PolyToStr(p));
		DestroyPoly(p);
		{Writeln('leaked: ', MemLeak);}
		DestroyExpression(e);
		{ Memory leak }
		Writeln('Memory leaked: ', MemLeak);
		Write('Again? (y/n)');
		done := ReadKey = 'n';
		Writeln;
	until done;
end.
