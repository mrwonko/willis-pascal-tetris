(* @file Test.pas
 * @author Willi Schinmeyer
 * @date 2011-10-27
 * 
 * Test Program
 * 
 * Contains various tests.
 *)

uses crt;

type
	TTest = record
		value : integer;
	end;

operator +(a, b : TTest) result : TTest;
begin
	result.value := a.value + b.value;
	while result.value > 9 do
		result.value := result.value - 10;
end;

var
	a, b, c : TTesT;
begin
	a.value := 9;
	b.value := 1;
	c := a + b;
	writeln(c.value);
end.
