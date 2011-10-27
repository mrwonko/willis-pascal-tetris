(* @file UGeneralConstants.pas
 * @author Willi Schinmeyer
 * @date 2011-10-27
 * 
 * UGeneralConstants Unit
 * 
 * Contains constants e.g. regarding screen size, available colors etc.
 *)

unit UGeneralConstants;

interface
	uses crt;

	const
		(* Window size in characters *)
		SCREEN_WIDTH : integer = 80;
		SCREEN_HEIGHT : integer = 50;
		
		COLORS : array[0..3] of byte = (red, green, blue, yellow);

implementation

	begin
	end.
