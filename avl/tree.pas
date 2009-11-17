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

procedure TreeBalance(var root : PTreeNode; p : PTreeNode);
	
	function Height(p : PTreeNode) : integer;
	begin
		if p = nil 
			then Height := 0
			else Height := p^.height + 1;
	end;
	
	procedure UpdateHeight(p : PTreeNode);
	begin
		p^.height := 0;
		if Height(p^.left) > p^.height
			then p^.height := Height(p^.left);
		if Height(p^.right) > p^.height
			then p^.height := Height(p^.right);
	end;

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
		UpdateHeight(a);
		UpdateHeight(b);
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
		UpdateHeight(a);
		UpdateHeight(b);
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
		UpdateHeight(a);
		UpdateHeight(b);
		UpdateHeight(c);
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
		UpdateHeight(a);
		UpdateHeight(b);
		UpdateHeight(c);
	end;

begin
	{ Updating height }
	UpdateHeight(p);
	{ Handle cases }
	if abs(Height(p^.left) - Height(p^.right)) = 2 then begin
		if Height(p^.left) > Height(p^.right) then begin
			{ Left disbalance }
			if Height(p^.left^.left) > Height(p^.left^.right)
				then LeftLeftRotate(TreeGetPointer(root, p))
				else LeftRightRotate(TreeGetPointer(root, p));
		end
		else begin
			{ Right disbalance }
			if Height(p^.right^.left) > Height(p^.right^.right)
				then RightLeftRotate(TreeGetPointer(root, p))
				else RightRightRotate(TreeGetPointer(root, p));
		end;
	end;	
	{ Balance parent }
	if p^.parent <> nil
		then TreeBalance(root, p^.parent);
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

procedure TreeRemove(var root : PTreeNode; p : PTreeNode);
	
begin
	if p <> nil then begin
		if (p^.left = nil) and (p^.right = nil) then begin
			
		end
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
	var p, t : PTreeNode;
begin
	t := nil;
	p := root;
	while p <> nil do begin
		if StudentLess(key, p^.data)
			then p := p^.left
			else p := p^.right;
	end;
	TreeSearch := t;
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
	
	{ Add nodes from root subtree after last list node, returns new last list node }
	function AddToList(root : PTreeNode; last : PListNode) : PListNode;
	begin
		if root <> nil then begin
			{ Adding left subtree }
			last := AddToList(root^.left, last);
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
			last := AddToList(root^.right, last);
		end
		else AddToList := last;
	end;
	
begin
	AddToList(root, nil);
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
			else dispose(head); // May Be BUG!!!!!
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
		Writeln('  4  show    -  show students by name');
		Writeln('  5  insert  -  insert student to tree');
		Writeln('  6  remove  -  remove student from tree');
		Writeln('  7  list    -  generate double-linked list and print it');
		Writeln('  8  save    -  output current tree state to students file');
		Writeln('  ?  help    -  print this help');
		Writeln('  0  quit    -  quit application');
	end;

	procedure CommandShow;
		var student : TStudent;
			p : PTreeNode;
	begin
		Write('Students name: ');
		Readln(student.name);
		p := TreeSearch(root, student);
		Writeln('Found:');
		if p = nil 
			then Writeln('  nothing');
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
		else if (cmd = 'show') or (cmd = '4') then 
			CommandShow
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
			break;
	end;
end;

{ ========== IMPLEMENTATION ========== }

begin
	UserConsole;
end.
