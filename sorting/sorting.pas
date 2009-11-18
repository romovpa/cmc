program DatesSorting(input, output);

{ DATE STRUCTURE }

type
	TDate = record
		day, month : byte;
		year : integer;
	end;
	
{ Returns true, if date1 is lesser or eq than date2 }
function DateLessEq(date1, date2 : TDate) : boolean;
begin
	DateLessEq := date1.year < date2.year;
	if date1.year = date2.year then 
	begin
		DateLessEq := date1.month < date2.month;
		if date1.month = date2.month then
			DateLessEq := date1.day <= date2.day;
	end;
end;

{ Parse date from string, returns true if success }
function ParseDate(var date : TDate; str : string) : boolean;
	var i : integer;
		state : byte;
begin
	ParseDate := false;
	i := 1;
	{ Parsing day }
	date.day := 0;
	while (i <= Length(str)) and (str[i] in ['0'..'9']) do
	begin
		date.day := date.day * 10 + ord(str[i]) - ord('0');
		i := i + 1;
	end;
	{ Parsing month }
	date.month := 0;
	if i > Length(str) 
		then exit;
	if str[i] = '.' then begin
		i := i + 1;
		while (i <= Length(str)) and (str[i] in ['0'..'9']) do
		begin
			date.month := date.month * 10 + ord(str[i]) - ord('0');
			i := i + 1;
		end;
		if (i > Length(str)) or (str[i] <> '.')
			then exit;
	end
	else if str[i] = '/' then begin
		i := i + 1;
		state := 0;
		while (i <= Length(str)) and (str[i] in ['I', 'V', 'X']) do begin
			case str[i] of
				'I' : 
					begin
						date.month := date.month + 1;
						if state = 0
							then state := 1;
					end;
				'V' : 
					if state = 0 then begin
						state := 5;
						date.month := date.month + 5;
					end
					else if state = 1 then begin
						state := 5;
						date.month := 5 - date.month;
					end
					else exit;
				'X':
					if state = 0 then begin 
						state := 10;
						date.month := date.month + 10;
					end
					else if state = 1 then begin
						state := 10;
						date.month := 10 - date.month;
					end 
					else exit;
			end;
			i := i + 1;
		end;
		if (i > Length(str)) or (str[i] <> '/')
			then exit;
	end
	else exit;
	{ Parsing year }
	i := i + 1;
	if i > Length(str) 
		then exit;
	date.year := 0;
	while (i <= Length(str)) and (str[i] in ['0'..'9']) do
	begin
		date.year := date.year * 10 + ord(str[i]) - ord('0');
		i := i + 1;
	end;
	if date.year < 1000
		then date.year := date.year + 2000;
	if i <= Length(str) 
		then exit;
	{ Done }
	ParseDate := true;
end;

function DateToString(date : TDate) : string;
	var res, temp : string;
begin
	Str(date.day, temp);
	while Length(temp) < 2 do
		temp := '0' + temp;
	res := temp + '.';
	Str(date.month, temp);
	while Length(temp) < 2 do
		temp := '0' + temp;
	res := res + temp + '.';
	Str(date.year, temp);
	while Length(temp) < 4 do
		temp := '0' + temp;
	res := res + temp;
	DateToString := res;
end;

{ ARRAY OF DATES }

const MaxDatesCount = 1000;

var dates : array[1..MaxDatesCount] of TDate;
	datesCount, comparingCount, swapCount : integer;

{ Initialization of program }
procedure Init;
begin
	datesCount := 0;
	comparingCount := 0;
	swapCount := 0;
end;

{ Swap two elements in array }
procedure Swap(i, j : integer);
	var t : TDate;
begin
	t := dates[i];
	dates[i] := dates[j];
	dates[j] := t;
	swapCount := swapCount + 1;
end;

{ Sort of the array }
procedure Sort;

	function Split(l, r : integer) : integer;
		var i, j : integer;
			middle : TDate;
	begin
		middle := dates[l];
		i := l - 1;
		j := r + 1;
		while true do begin
			repeat 
				j := j - 1;
				comparingCount := comparingCount + 1;
			until DateLessEq(dates[j], middle);
			repeat 
				i := i + 1;
				comparingCount := comparingCount + 1;
			until DateLessEq(middle, dates[i]);
			if i < j
				then Swap(i, j)
				else begin
					Split := j;
					exit;
				end;
		end;
	end;

	procedure QSort(l, r : integer);
		var q : integer;
	begin
		if l >= r
			then exit;
		q := Split(l, r);
		QSort(l, q);
		QSort(q+1, r);
	end;

begin
	QSort(1, datesCount);
end;

{ DATA INPUT }

const 
	InputFileName = 'input.txt';
	OutputFileName = 'output.txt';

var inputFile, outputFile : Text;
	line : string;
	lineNo, i : integer;
	
begin
	{ Openning files }
	Assign(inputFile, InputFileName);
	Assign(outputFile, OutputFileName);
	Reset(inputFile);
	Rewrite(outputFile);
	{ Reading data }
	Init;
	lineNo := 0;
	while not Eof(inputFile) do
	begin
		Readln(inputFile, line);
		lineNo := lineNo + 1;
		if ParseDate(dates[datesCount+1], line) 
			then datesCount := datesCount + 1
			else Writeln('Syntax error in line ', lineNo);
	end;
	{ Sorting and printing statistics }
	Sort;
	Writeln('Dates: ', datesCount);
	Writeln('Comparings: ', comparingCount);
	Writeln('Swaps: ', swapCount);
	{ Writing data }
	for i := 1 to datesCount do
		Writeln(outputFile, DateToString(dates[i]));
	{ Closing files }
	Close(inputFile);
	Close(outputFile);
end.
