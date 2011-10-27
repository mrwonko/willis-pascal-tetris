(* @file Test.pas
 * @author Willi Schinmeyer
 * @date 2011-10-27
 * 
 * Test Program
 * 
 * Contains various tests.
 *)

procedure writeLines(var lines : array of string);
var
	i : integer;
	dynArray : array of string;
begin
	dynArray := lines;
	for i := low(dynArray) to high(dynArray) do
		writeln(dynArray[i]);
end;

var
	lines : array[0..3] of string = ('hello,', 'beautiful', 'array', 'world!');
	nolines : array of string;
begin
	writeLines(lines);
	//writeLines(nolines);
end.
