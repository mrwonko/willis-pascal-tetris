(* @file Test.pas
 * @author Willi Schinmeyer
 * @date 2011-10-27
 * 
 * Test Program
 * 
 * Contains various tests.
 *)

uses crt, UVector2i;

var
	arr : array[0..0] of TVector2i = ((x:1;y:1));
	vec : TVector2i;
begin
	for vec in arr do
		UVector2i.rotate90DegCCW(vec); //doesn't work (copy)
	UVector2i.rotate90DegCCW(arr[0]); //works
	for vec in arr do
		writeln(vec.x, ', ', vec.y);
end.
