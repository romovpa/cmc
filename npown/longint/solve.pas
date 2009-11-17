(*
	Solve of Problem N^N
	Author: Peter Romov
	Group: 102
	Algorithm: O(sqrt(A))
*)

program NPowerN;

	{ ******************** }
	{ * Long Numbers API * }
	{ ******************** }

	const
		LongSize = 10000;
		LongBase = 10000;

	type
		TLong = array[0..LongSize] of integer;

	{ Returns true, if c is char }
	function IsDigit(c : char) : boolean;
	begin
		IsDigit := (c >= '0') and (c <= '9');
	end;

	{ Reset A to zero }
	procedure LongInit(var A : TLong);
	begin
		A[0] := 0;
	end;

	{ Returns A = k }
	function LongEqualsDigit(const A : TLong; k : integer) : boolean;
	begin
		if k = 0
			then LongEqualsDigit := A[0] = 0
			else LongEqualsDigit := (A[0] = 1) and (A[1] = k);
	end;

	{ A := k }
	procedure LongFromInteger(var A : TLong; k : integer);
	begin
		A[0] := 0;
		while k > 0 do begin
			A[0] := A[0] + 1;
			A[A[0]] := k mod LongBase;
			k := k div LongBase;
		end;
	end;

	{ Assign B to A }
	procedure LongAssign(var A : TLong; const B : TLong);
		var i : integer;
	begin
		for i := 0 to B[0] do
			A[i] := B[i];
	end;

	{ Get k-th digit of number A }
	function LongGetDigit(const A : TLong; k : integer) : integer;
	begin
		if (k <= A[0]) and (k > 0)
			then LongGetDigit := A[k]
			else LongGetDigit := 0;
	end;

	{ Reads A from input }
	procedure LongRead(var A : TLong);
		var c : char;
			i : integer;
	begin
		LongInit(A);
		repeat Read(c) until IsDigit(c);
		while IsDigit(c) do
		begin
			A[A[0]+1] := 0;
			for i := A[0] downto 1 do
			begin
				A[i+1] := A[i+1] + A[i]*10 div LongBase;
				A[i] := A[i]*10 mod LongBase;
			end;
			A[1] := A[1] + ord(c) - ord('0');
			if A[A[0]+1] > 0
				then A[0] := A[0] + 1;
			Read(c);
		end;
	end;

	{ Writes A to output }
	procedure LongWrite(const A : TLong);
		var i, d : integer;
	begin
		Write(A[A[0]]);

		for i := A[0]-1 downto 1 do
		begin
			d := LongBase div 10;
			while d > 0 do
			begin
				Write((A[i] div d) mod 10);
				d := d div 10;
			end;
		end;
	end;

	{ Result := A >= B * Base^shift }
	function LongMoreEqWithShift(const A, B : TLong; shift : integer) : boolean;
		var i : integer;
	begin
		LongMoreEqWithShift := A[0] >= B[0]+shift;
		if A[0] = B[0]+shift then
			for i := A[0] downto 1 do
			begin
				if A[i] > LongGetDigit(B, i-shift)
					then break
					else if A[i] < LongGetDigit(B, i-shift)
						then begin
							LongMoreEqWithShift := false;
							break;
						end;
			end;
	end;

	{ Result := A >= B }
	function LongMoreEq(const A, B : TLong) : boolean;
	begin
		LongMoreEq := LongMoreEqWithShift(A, B, 0);
	end;
	
	function LongLess(const A, B : TLong) : boolean;
		var i : integer;
	begin
		LongLess := A[0] < B[0];
		if A[0] = B[0] then begin
			for i := A[0] downto 1 do
				if A[i] < B[i] 
					then begin 
						LongLess := true;
						break;
					end
					else if A[i] > B[i] 
						then break;
		end;
	end;

	{ A := A * Base^shift }
	procedure LongShift(var A : TLong; shift : integer);
		var i : integer;
	begin
		for i := A[0] downto 1 do
			A[i+shift] := A[i];
		for i := 1 to shift do
			A[i] := 0;
		A[0] := A[0] + shift;
		while (A[0] > 0) and (A[A[0]] = 0)
			do A[0] := A[0] - 1;
	end;

	{ C := A + B }
	procedure LongAdd(var C : TLong; const A, B : TLong);
		var i, modulo : integer;
	begin
		if A[0] > B[0]
			then C[0] := A[0]
			else C[0] := B[0];
		modulo := 0;
		for i := 1 to C[0] do
		begin
			C[i] := LongInt(LongGetDigit(A, i)+LongGetDigit(B, i)+modulo)
				mod LongBase;
			modulo := LongInt(LongGetDigit(A, i)+LongGetDigit(B, i)+modulo)
				div LongBase;
		end;
		if modulo > 0
			then begin
				C[0] := C[0]+1;
				C[C[0]] := modulo;
			end;
	end;

	{ C := A * k }
	procedure LongMulToDigit(var C : TLong; const A : TLong; k : integer);
		var i, modulo : integer;
	begin
		C[0] := A[0];
		modulo := 0;
		for i := 1 to C[0] do
		begin
			C[i] := LongInt(LongGetDigit(A, i)*k+modulo) mod LongBase;
			modulo := LongInt(LongGetDigit(A, i)*k+modulo) div LongBase;
		end;
		if modulo > 0
			then begin
				C[0] := C[0] + 1;
				C[C[0]] := modulo;
			end;
	end;

	{ C := A * B }
	procedure LongMul(var C : TLong; const A, B : TLong);
		var i : integer;
			T, S : TLong;
	begin
		LongInit(C);
		for i := 1 to B[0] do
		begin
			LongMulToDigit(T, A, B[i]);
			LongShift(T, i-1);
			LongAdd(S, C, T);
			LongAssign(C, S);
		end;
	end;

	{ A := A + k }
	procedure LongIncrement(var A : TLong; k : integer);
		var i, t : integer;
	begin
		for i := 1 to A[0] do
		begin
			if k = 0
				then break;
			t := A[i];
			A[i] := (t + k) mod LongBase;
			k := (t + k) div LongBase;
		end;
		A[A[0]+1] := k;
		if A[A[0]+1] > 0
			then A[0] := A[0] + 1;
	end;

	{ C := A - B * Base^shift }
	procedure LongSubWithShift(var C : TLong; const A, B : TLong; shift : integer);
		var i, deposit : integer;
	begin
		C[0] := A[0];
		deposit := 0;
		for i := 1 to C[0] do begin
			if i <= shift
				then C[i] := A[i]
				else begin
					if A[i] - deposit >= LongGetDigit(B, i-shift)
						then C[i] := A[i] - deposit - LongGetDigit(B, i-shift)
						else begin
							C[i] := A[i] + LongBase - deposit -
								LongGetDigit(B, i-shift);
							deposit := deposit + LongBase;
						end;
					deposit := deposit div LongBase;
				end;
		end;
		while (C[0] > 0) and (C[C[0]] = 0)
			do C[0] := C[0] - 1;
	end;

	{ C := A - B }
	procedure LongSub(var C : TLong; const A, B : TLong);
	begin
		LongSubWithShift(C, A, B, 0);
	end;

	{ Q := A div B (quotient)
	  M := A mod B (modulous) }
	procedure LongDiv(var Q, M : TLong; const A, B : TLong);
		var shift, digit : integer;
			T, S : TLong;
	begin
		LongAssign(M, A);
		LongInit(Q);
		for shift := M[0] - B[0] downto 0 do
		begin
			{ OPTIMIZATION: binary search of digit instead of linear }
			digit := 0;
			repeat
				LongMulToDigit(T, B, digit+1);
				if LongMoreEqWithShift(M, T, shift)
					then digit := digit + 1
					else break;
			until digit+1 = LongBase;
			{ Decreasing M }
			LongMulToDigit(T, B, digit);
			LongSubWithShift(S, M, T, shift);
			LongAssign(M, S);
			{ Adding digit }
			LongShift(Q, 1);
			Q[1] := digit;
			if Q[0] = 0
				then Q[0] := 1;
		end;
	end;

	{ ******************** }
	{ * Solve of problem * }
	{ ******************** }

	procedure PrimeFactorsProduct(var R : TLong; A : TLong);
		var P, T, M : TLong;
			two : boolean;
	begin
		{ R := 1 }
		LongInit(R);
		LongIncrement(R, 1);
		{ P := 2 }
		LongInit(P);
		LongIncrement(P, 2);
		two := true;
		{ Factorization }
		while (2*P[0] <= A[0]+1) and not ((A[0] = 1) and (A[1] = 1)) do
		begin
			LongDiv(T, M, A, P);
			if LongEqualsDigit(M, 0) then
			begin
				repeat
					LongAssign(A, T);
					LongDiv(T, M, A, P);
				until not LongEqualsDigit(M, 0);
				LongMul(T, R, P);
				LongAssign(R, T);
			end;
			if two
				then begin
					LongIncrement(P, 1);
					two := false;
				end
				else LongIncrement(P, 2);
		end;
		if not LongEqualsDigit(A, 1) 
			then begin
				LongMul(T, R, A);
				LongAssign(R, T);
			end;
	end;

	function IsGood(const N : TLong; A : TLong) : boolean;
		var number, temp, modulo, prime, longPowerA, longPowerN : TLong;
			powerA, powerN : integer;
			two : boolean;
	begin
		IsGood := true;
		LongAssign(number, N);
		LongFromInteger(prime, 2);
		two := true;
		while not LongEqualsDigit(A, 1) do begin
			LongDiv(temp, modulo, A, prime);
			if LongEqualsDigit(modulo, 0) then begin
				{ Counting prime power in A }
				powerA := 1;
				LongAssign(A, temp);
				while true do begin 
					LongDiv(temp, modulo, A, prime);
					if LongEqualsDigit(modulo, 0)
						then begin
							powerA := powerA + 1;
							LongAssign(A, temp);
						end
						else break;
				end;
				{ Counting prime power in N }
				powerN := 0;
				repeat 
					LongDiv(temp, modulo, number, prime);
					if LongEqualsDigit(modulo, 0) 
						then begin
							powerN := powerN + 1;
							LongAssign(number, temp);
						end;
				until not LongEqualsDigit(modulo, 0);
				{ Comparing powers }
				LongFromInteger(longPowerA, powerA);
				LongFromInteger(longPowerN, powerN);
				LongMul(temp, N, longPowerN);
				if LongLess(temp, longPowerA) then begin
					IsGood := false;
					break;
				end;
			end;
			if two 
				then begin
					two := false;
					LongIncrement(prime, 1);
				end
				else LongIncrement(prime, 2);
		end;
	end;

	procedure FindMinimalN(var Res : TLong; const A : TLong);
		var minimized, muler : TLong;
	begin
		PrimeFactorsProduct(minimized, A);
		LongFromInteger(muler, 0);
		repeat
			LongIncrement(muler, 1);
			LongMul(Res, minimized, muler);
		until IsGood(Res, A);
	end;	

var	A, R : TLong;

begin
	LongRead(A);
	FindMinimalN(R, A);
	LongWrite(R);
end.
