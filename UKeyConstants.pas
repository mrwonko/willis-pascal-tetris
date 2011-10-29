(* @file UKeyConstants.pas
 * @author Willi Schinmeyer
 * @date 2011-10-24
 * 
 * UKeyConstants Unit
 * 
 * Defines constants for keyboard key ASCII codes as returned by
 * readkey. *)

unit UKeyConstants;

interface
	const
		(* Extended Keys: Keys beyond usual ASCII codes, return 0 on
		 * first readkey call *)
		(* Arrow Keys *)
		EXT_KEY_UP = #72;
		EXT_KEY_DOWN = #80;
		EXT_KEY_LEFT = #75;
		EXT_KEY_RIGHT = #77;
		(* Escape *)
		KEY_ESCAPE = #27;
		(* Return *)
		KEY_RETURN = #13;

implementation

	begin
	end.
