(*
 *	CMC Practice - Derivative of formula
 *	Student: Peter Romov
 *	Variant: 20
 *)
program Derivative;

uses Crt;

{ ========== EXPRESSIONS ========== }

const
	variableChars = ['a'..'z', 'A'..'Z'];
	arithmeticChars = ['+', '-', '*'];
	numberChars = ['0'..'9'];
	bracketChars = ['(', ')'];
	expressionChars = variableChars + arithmeticChars + numberChars + bracketChars;

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
			else if s[pos] in variableChars + numberChars then begin
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

{ Makes derivative tree }
procedure DifferentiateExpression(root : PExpression; x : char; var res : PExpression);
	var t1, t2 : PExpression;
begin
	if root = nil
		then res := nil
		else if root^.operation in ['+', '-']
			then begin
				New(res);
				res^.operation := root^.operation;
				DifferentiateExpression(root^.left, x, res^.left);
				DifferentiateExpression(root^.right, x, res^.right);				
			end
			else if root^.operation = '*'
				then begin
					New(t1);
					New(t2);
					New(res);
					res^.operation := '+';
					res^.left := t1;
					res^.right := t2;
					t1^.operation := '*';
					DifferentiateExpression(root^.left, x, t1^.left);
					t1^.right := root^.right; { ACHTUNG! It linked to original tree }
					t2^.operation := '*';
					t2^.left := root^.left;
					DifferentiateExpression(root^.right, x, t2^.right);
				end
				else begin
					New(res);
					res^.left := nil;
					res^.right := nil;
					if root^.operation = x
						then res^.operation := '1'
						else res^.operation := '0';
				end;
end;

{ Returns infix expression record }
function ExpressionToStr(root : PExpression) : string;
begin
	if root = nil
		then ExpressionToStr := ''
		else if root^.operation in arithmeticChars
			then ExpressionToStr := '(' + ExpressionToStr(root^.left) + 
				root^.operation + ExpressionToStr(root^.right) + ')'
			else ExpressionToStr := root^.operation;
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
			ParseExpression(s, root, err);	
			TextColor(barTextColor);
			TextBackground(barBackground);
		end;
		for i := 1 to rightX - leftX + 1 do 
		begin
			GoToXY(leftX + i - 1, y);
			if i + shift <= Length(s)
				then begin
					if active and (err = i) 
						then TextColor(barErrColor);
					Write(s[i]);			
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

var e, d : PExpression;
	s : string;

begin
	Write('f(x) = ');
	InputExpression(e);
	DifferentiateExpression(e, 'x', d);
	Writeln('f''(x) = ', ExpressionToStr(d));
end.
