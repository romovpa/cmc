program FunctionalArea;

uses 
	Graph, Crt;

const
	BGI_PATH = 'A:\TP\BGI';	

procedure InitGraphMode;
	var graphicsDriver, graphicsMode : integer;
begin
	InitGraph(graphicsDriver, graphicsMode, BGI_PATH);
end;

begin
	InitGraphMode;
	
	CloseGraph;
end.
