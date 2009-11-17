program AVLTree(input, output);

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

type
	PTreeNode = ^TTreeNode;
	TTreeNode = record
		data : TStudent;
		height : integer;
		left, right, parent : PTreeNode;
	end;

procedure TreeInit(var root : PTreeNode);
begin
	root := nil;
end;

procedure TreeBalance(p : PTreeNode);
begin
	{ Updating height }
	p^.height := 0;
	if (p^.left <> nil) and (p^.left^.height + 1 > p^.height)
		then p^.height := p^.left^.height + 1;
	if (p^.right <> nil) and (p^.right^.height + 1 > p^.height)
		then p^.height := p^.right^.height + 1;
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
			TreeBalance(p);
		end;
end;

begin

end.
