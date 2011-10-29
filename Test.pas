(* @file Test.pas
 * @author Willi Schinmeyer
 * @date 2011-10-27
 * 
 * Test Program
 * 
 * Contains various tests.
 *)

uses crt;

var
	key : char;
begin
	key := readkey();
	if key = #0 then
		writeln('ext key ',ord(key))
	else
		writeln('key ',ord(key))
end.
