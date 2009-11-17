program NPowN(input, output);

type integer = longint;

var a, minimized, muler, temp : integer;
	prime, power : integer;

function IsGood(n, a : integer) : boolean;
	var prime, powerA, powerN, number : integer;
begin
	IsGood := true;
	number := n;
	prime := 2;
	while a > 1 do begin
		if a mod prime = 0 then begin
			{ Counting prime power in A }
			powerA := 0;
			repeat 
				powerA := powerA + 1;
				a := a div prime;
			until a mod prime <> 0;
			{ Counting prime power in N }
			powerN := 0;
			while number mod prime = 0 do begin
				powerN := powerN + 1;
				number := number div prime;
			end;
			{ Comparing powers }
			if powerN*N < powerA then begin
				IsGood := false;
				break;
			end;
		end;
		if prime = 2
			then prime := 3
			else prime := prime + 2;
	end;
end;

begin

	{ Reading input }
	Read(a);
	
	{ Factorization of A }
	temp := a;
	minimized := 1;
	prime := 2;
	while temp > 1 do begin
		if temp mod prime = 0 then
		begin
			minimized := minimized * prime;
			power := 0;
			repeat
				power := power + 1;
				temp := temp div prime;
			until temp mod prime <> 0;
		end;
		if prime = 2
			then prime := 3
			else prime := prime + 2;
	end;
	
	{ Increasing N }
	muler := 1;
	while not IsGood(minimized*muler, a)
		do muler := muler + 1;
		
	{ Writing result }
	WriteLn(minimized*muler);
	
end.
