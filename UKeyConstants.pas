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
		EXT_KEY_ESCAPE = #27;

implementation

	begin
	end.
