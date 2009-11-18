{ 
  ****************************************************************
  *                  Practice work                               *
  *  Problem: AVL trees                                          *
  *  Author: Peter Romov <romovpa@gmail.com> (102 group)         *
  *  This file published under GNU/GPL (Version 2, June 1991)    *
  *  Repository: git://github.com/romovpa/cmc.git/practice/tree  *
  ****************************************************************
}

program AVLTreeDemo(input, output);

{ ========== STUDENT STRUCTURE ========== }

type
	TStudent = record
		name : string;
		score : real;
	end;
	
function StudentLess(a, b : TStudent) : boolean;
begin
	if a.name = b.name
		then StudentLess := a.score < b.score
		else StudentLess := a.name < b.name;
end;

procedure StudentPrint(data : TStudent);
begin
	Write(data.name, ' (', data.score:0:2, ')');
end;

{ ========== TREE STRUCTURE ========== }

type
	PTreeNode = ^TTreeNode;
	PPTreeNode = ^PTreeNode;
	TTreeNode = record
		data : TStudent;
		height : integer;
		left, right, parent : PTreeNode;
	end;

procedure TreeInit(var root : PTreeNode);
begin
	root := nil;
end;

function TreeGetPointer(var root : PTreeNode; p : PTreeNode) : PPTreeNode;
begin
	if p^.parent = nil 
		then TreeGetPointer := @root
		else if p^.parent^.left = p
			then TreeGetPointer := @p^.parent^.left
			else TreeGetPointer := @p^.parent^.right;
end;

function TreeHeight(p : PTreeNode) : integer;
begin
	if p = nil 
		then TreeHeight := 0
		else TreeHeight := p^.height + 1;
end;

procedure TreeUpdateHeight(p : PTreeNode);
begin
	p^.height := 0;
	if TreeHeight(p^.left) > p^.height
		then p^.height := TreeHeight(p^.left);
	if TreeHeight(p^.right) > p^.height
		then p^.height := TreeHeight(p^.right);
end;

procedure TreeBalance(var root : PTreeNode; p : PTreeNode);

	procedure LeftLeftRotate(p : PPTreeNode);
		var a, b, t : PTreeNode;
	begin
		a := p^;
		b := a^.left;
		t := b^.right;
		b^.right := a;
		b^.parent := a^.parent;
		b^.right^.parent := b;
		a^.left := t;
		a^.parent := b;
		if a^.left <> nil
			then a^.left^.parent := a;
		p^ := b;
		TreeUpdateHeight(a);
		TreeUpdateHeight(b);
	end;
	
	procedure RightRightRotate(p : PPTreeNode);
		var a, b, t : PTreeNode;
	begin
		a := p^;
		b := a^.right;
		t := b^.left;
		b^.left := a;
		b^.parent := a^.parent;
		b^.left^.parent := b;
		a^.right := t;
		a^.parent := b;
		if a^.right <> nil 
			then a^.right^.parent := a;
		p^ := b;
		TreeUpdateHeight(a);
		TreeUpdateHeight(b);
	end;
	
	procedure LeftRightRotate(p : PPTreeNode);
		var a, b, c : PTreeNode;
	begin
		a := p^;
		b := a^.left;
		c := b^.right;
		c^.parent := a^.parent;
		b^.right := c^.left;
		b^.parent := c;
		if b^.right <> nil
			then b^.right^.parent := b;
		a^.left := c^.right;
		a^.parent := c;
		if a^.left <> nil
			then a^.left^.parent := a;
		c^.left := b;
		c^.right := a;
		p^ := c;
		TreeUpdateHeight(a);
		TreeUpdateHeight(b);
		TreeUpdateHeight(c);
	end;
	
	procedure RightLeftRotate(p : PPTreeNode);
		var a, b, c : PTreeNode;
	begin
		a := p^;
		b := a^.right;
		c := b^.left;
		c^.parent := a^.parent;
		b^.left := c^.right;
		b^.parent := c;
		if b^.left <> nil
			then b^.left^.parent := b;
		a^.right := c^.left;
		a^.parent := c;
		if a^.right <> nil
			then a^.right^.parent := a;
		c^.left := a;
		c^.right := b;
		p^ := c;
		TreeUpdateHeight(a);
		TreeUpdateHeight(b);
		TreeUpdateHeight(c);
	end;

begin
	if p <> nil then begin
		{ Updating height }
		TreeUpdateHeight(p);
		{ Handle cases }
		if abs(TreeHeight(p^.left) - TreeHeight(p^.right)) = 2 then begin
			if TreeHeight(p^.left) > TreeHeight(p^.right) then begin
				{ Left disbalance }
				if TreeHeight(p^.left^.left) > TreeHeight(p^.left^.right)
					then LeftLeftRotate(TreeGetPointer(root, p))
					else LeftRightRotate(TreeGetPointer(root, p));
			end
			else begin
				{ Right disbalance }
				if TreeHeight(p^.right^.left) > TreeHeight(p^.right^.right)
					then RightLeftRotate(TreeGetPointer(root, p))
					else RightRightRotate(TreeGetPointer(root, p));
			end;
		end;	
		{ Balance parent }
		if p^.parent <> nil
			then TreeBalance(root, p^.parent);
	end;
end;

procedure TreeInsert(var root : PTreeNode; data : TStudent);
	var t, p, q : PTreeNode;
begin
	{ Creating new node }
	new(t);
	t^.data := data;
	t^.height := 0;
	t^.left := nil;
	t^.right := nil;
	{ Finding place to insert }
	p := nil;
	q := root;
	while q <> nil do begin
		p := q;
		if StudentLess(data, q^.data)
			then q := q^.left
			else q := q^.right;
	end;
	{ Inserting }
	if p = nil 
		then begin
			root := t;
			t^.parent := nil;
		end
		else begin
			if StudentLess(data, p^.data)
				then p^.left := t
				else p^.right := t;
			t^.parent := p;
			TreeBalance(root, p);
		end;
end;

function TreeSuccessor(p : PTreeNode) : PTreeNode;
begin
	if p = nil 
		then TreeSuccessor := nil
		else begin
			if p^.right <> nil then begin
				p := p^.right;
				while p^.left <> nil do
					p := p^.left;
				TreeSuccessor := p;
			end
			else begin
				while (p^.parent <> nil) and (p^.parent^.right = p) do
					p := p^.parent;
				TreeSuccessor := p^.parent;
			end;
		end;
end;

function TreePredictor(p : PTreeNode) : PTreeNode;
begin
	if p = nil 
		then TreePredictor := nil
		else begin
			if p^.left <> nil then begin
				p := p^.left;
				while p^.right <> nil do 
					p := p^.right;
				TreePredictor := p;
			end
			else begin
				while (p^.parent <> nil) and (p^.parent^.left = p) do
					p := p^.parent;
				TreePredictor := p^.parent;
			end;
		end;
end;

procedure TreeRemove(var root : PTreeNode; p : PTreeNode);
	var t : PTreeNode;
begin
	if p <> nil then 
		if (p^.left = nil) and (p^.right = nil) then begin
			{ Remove leaf }
			TreeGetPointer(root, p)^ := nil;
			TreeBalance(root, p^.parent);
			dispose(p);
		end 
		else if p^.left <> nil then begin
			{ Remove left }
			t := p^.left;
			while t^.right <> nil do
				t := t^.right;
			p^.data := t^.data;
			TreeRemove(root, t);
		end
		else begin
			{ Remove right }
			t := p^.right;
			while t^.left <> nil do
				t := t^.left;
			p^.data := t^.data;
			TreeRemove(root, t);
		end;
end;

procedure TreePrint(p : PTreeNode);

	procedure Print(p : PTreeNode; tab : integer);
		var i : integer;
	begin
		if p <> nil then begin
			for i := 1 to tab do
				Write('..');
			Write('<', p^.height, '> ');
			StudentPrint(p^.data);
			Writeln;
			Print(p^.left, tab+1);
			Print(p^.right, tab+1);
		end;
	end;

begin
	Print(p, 0);
end;

procedure TreeLinePrint(p : PTreeNode; direction : boolean);

	procedure Print(p : PTreeNode);
	begin
		if p <> nil then begin
			if direction then begin
				Print(p^.left);
				if p^.left <> nil
					then Write(', ');
			end
			else begin
				Print(p^.right);
				if p^.right <> nil
					then Write(', ');
			end;
			StudentPrint(p^.data);
			if direction then begin
				if p^.right <> nil
					then Write(', ');
				Print(p^.right);
			end
			else begin
				if p^.left <> nil
					then Write(', ');
				Print(p^.left);
			end;
		end;
	end;

begin
	Write('{');
	Print(p);
	Write('}');
end;

function TreeSearch(var root : PTreeNode; key : TStudent) : PTreeNode;
	var p : PTreeNode;
begin
	p := root;
	while p <> nil do begin
		if key.name = p^.data.name then begin
			if (p^.left <> nil) and (p^.left^.data.name = key.name)
				then p := p^.left
				else break;
		end	
		else if StudentLess(key, p^.data)
			then p := p^.left
			else p := p^.right;
	end;
	TreeSearch := p;
end;

{ ========== DOUBLE-LINKED LIST STRUCTURE ========== }

type
	PListNode = ^TListNode;
	TListNode = record
		data : TStudent;
		next, prev : PListNode;
	end;

{ Generates double-linked list from tree }
procedure TreeToList(root : PTreeNode; var head : PListNode);
	
	var last : PListNode;
	
	{ Add nodes from root subtree after last list node }
	procedure AddToList(root : PTreeNode);
	begin
		if root <> nil then begin
			{ Adding left subtree }
			if root^.left <> nil 
				then AddToList(root^.left);
			{ Adding middle node }
			if last = nil then begin
				new(last);
				head := last;
				last^.prev := nil;
				last^.next := nil;
				last^.data := root^.data;
			end
			else begin
				new(last^.next);
				last^.next^.data := root^.data;
				last^.next^.prev := last;
				last^.next^.next := nil;
				last := last^.next;
			end;
			{ Adding right subtree }
			if root^.right <> nil
				then AddToList(root^.right);
		end;
	end;
	
begin
	last := nil;
	AddToList(root);
end;

procedure ListPrint(p : PListNode);
begin
	Write('{');
	while p <> nil do begin
		StudentPrint(p^.data);
		if p^.next <> nil
			then Write(', ');
		p := p^.next;
	end;
	Write('}');
end;

{ ========== INPUT/OUTPUT FUNCTIONS ========== }

const 
	StudentsFileName = 'students.txt';
	SetOfNameFirstChars : set of char = ['A'..'Z'];
	SetOfNameChars : set of char = ['a'..'z'];
	SetOfFirstDigits : set of char = ['1'..'5'];
	SetOfDigits : set of char = ['0'..'9'];
	CharOfSeparator : char = ' ';

function ParseLine(var student : TStudent; str : string) : boolean;
	var i : integer;
		muler : real;
begin
	ParseLine := false;
	{ Parsing name }
	if (Length(str) < 1) or not (str[1] in SetOfNameFirstChars) 
		then exit
		else student.name := str[1];
	i := 2;
	while (i <= Length(str)) and (str[i] in SetOfNameChars) do begin
		student.name := student.name + str[i];
		i := i + 1;
	end;
	{ Parsing space }
	if (i > Length(str)) or (str[i] <> CharOfSeparator)
		then exit
		else i := i + 1;
	{ Parsing score }
	if (i <= Length(str)) and (str[i] in SetOfFirstDigits) 
		then begin
			student.score := ord(str[i]) - ord('0');
			i := i + 1;
		end
		else exit;
	if (i <= Length(str)) and (str[i] = '.')
		then i := i + 1
		else exit;
	muler := 0.1;
	while (i <= Length(str)) and (str[i] in SetOfDigits) do begin
		student.score := student.score + muler * (ord(str[i]) - ord('0'));
		muler := muler / 10;
		i := i + 1;
	end; 
	{ Well! }
	ParseLine := (i > Length(str)) and (muler < 0.1);
end;

procedure InputData(var root : PTreeNode);
	var inputFile : Text;
		student : TStudent;
		line : string;
		lineNo : integer;
begin
	TreeInit(root);
	Assign(inputFile, StudentsFileName);
	Reset(inputFile);
	lineNo := 0;
	while not Eof(inputFile) do begin
		Readln(inputFile, line);
		lineNo := lineNo + 1;
		if not ParseLine(student, line)
			then Writeln('Error in line: ', lineNo)
			else TreeInsert(root, student);
	end;
	Close(inputFile);
end;

procedure OutputData(root : PTreeNode);
	var head : PListNode;
		outputFile : Text;
begin
	Assign(outputFile, StudentsFileName);
	Rewrite(outputFile);
	TreeToList(root, head);
	while head <> nil do begin
		Writeln(outputFile, head^.data.name, CharOfSeparator, 
			head^.data.score:0:5);
		if head^.next <> nil
			then begin
				head := head^.next;
				dispose(head^.prev);
			end
			else begin 
				dispose(head); 
				break;
			end;
	end;
	Close(outputFile);
end;

{ ========== USER INTERFACE ========== }

const 
	UserPrompt = '> ';
	WellcomeMessage = 'AVL Tree Demonstration';
	ShortHelpMessage = 'Enter ''help'' for more information';

procedure UserConsole;
	var root : PTreeNode;
		cmd : string;

	procedure CommandHelp;
	begin
		Writeln('Available commands: ');
		Writeln('  1  printf  -  print tree forwards');
		Writeln('  2  printb  -  print tree backwards');
		Writeln('  3  print   -  print tree graph');
		Writeln('  4  lookup  -  show students by name');
		Writeln('  5  insert  -  insert student to tree');
		Writeln('  6  remove  -  remove student from tree');
		Writeln('  7  list    -  generate double-linked list and print it');
		Writeln('  8  save    -  output current tree state to students file');
		Writeln('  ?  help    -  print this help');
		Writeln('  0  quit    -  quit application');
	end;

	procedure CommandLookup;
		var student : TStudent;
			p, t : PTreeNode;
	begin
		Write('Students name: ');
		Readln(student.name);
		p := TreeSearch(root, student);
		Writeln('Found:');
		if p = nil 
			then Writeln('  nothing');
		t := p;
		repeat 
			p := t;
			t := TreePredictor(p);
		until (t = nil) or (t^.data.name <> student.name);
		while (p <> nil) and (p^.data.name = student.name) do begin
			Write('  ');
			StudentPrint(p^.data);
			Writeln;
			p := TreeSuccessor(p);
		end;
	end;
	
	procedure CommandInsert;
		var student : TStudent;
	begin
		Write('New student name: ');
		Readln(student.name);
		Write('New student score: ');
		Readln(student.score);
		TreeInsert(root, student);
	end;
	
	procedure CommandRemove;
		var student : TStudent;
			p : PTreeNode;
	begin
		Write('Student name: ');
		Readln(student.name);
		p := TreeSearch(root, student);
		if p = nil
			then Writeln('  no student to remove')
			else TreeRemove(root, p);
	end;
	
	procedure CommandList;
		var head : PListNode;
	begin
		TreeToList(root, head);
		Writeln('  doble-linked list generated');
		ListPrint(head);
		Writeln;
	end;

begin
	Writeln(WellcomeMessage);
	Writeln(ShortHelpMessage);
	InputData(root);
	while true do begin
		{ Reading command }
		Write(UserPrompt);
		Readln(cmd);
		{ Handle command }
		if (cmd = 'printf') or (cmd = '1') then 
			begin
				TreeLinePrint(root, true);
				Writeln;
			end
		else if (cmd = 'printb') or (cmd = '2') then
			begin
				TreeLinePrint(root, false);
				Writeln;
			end
		else if (cmd = 'print') or (cmd = '3') then
			TreePrint(root)
		else if (cmd = 'lookup') or (cmd = '4') then 
			CommandLookup
		else if (cmd = 'insert') or (cmd = '5') then 
			CommandInsert
		else if (cmd = 'remove') or (cmd = '6') then 
			CommandRemove
		else if (cmd = 'list') or (cmd = '7') then 
			CommandList
		else if (cmd = 'save') or (cmd = '8') then
			OutputData(root)
		else if (cmd = 'help') or (cmd = '?') then 
			CommandHelp
		else if (cmd = 'quit') or (cmd = '0') then
			break
		else if cmd <> '' 
			then Writeln('Unknown command ''', cmd, '''');
	end;
end;

{ ========== IMPLEMENTATION ========== }

begin
	UserConsole;
end.
