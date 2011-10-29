(* @file UDisplayConstants.pas
 * @author Willi Schinmeyer
 * @date 2011-10-27
 * 
 * UDisplayConstants Unit
 * 
 * Contains constants e.g. regarding screen size, Tetromino display etc.
 *)

unit UDisplayConstants;

interface
	uses crt;

	const
		(* Window size in characters *)
		SCREEN_WIDTH : integer = 80;
		SCREEN_HEIGHT : integer = 50;
	
		//char representating a Tetromino part
		CELL_OCCUPIED_CHAR : char = '#';
		//the empty char must not be anything else than space because
		//otherwise I'd have to set the color, which I don't.
		CELL_EMPTY_CHAR : char = ' ';

implementation

	begin
	end.
