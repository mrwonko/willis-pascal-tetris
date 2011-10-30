(* @file UConstants.pas
 * @author Willi Schinmeyer
 * @date 2011-10-30
 * 
 * All the constants used in the program.
 *)

unit UConstants;

interface
	const
		//  Main Menu Keys
		
		//key for starting the game - must be printable!
		NEWGAME_KEY = '1';
		//key for displaying help - must be printable!
		HELP_KEY = '2';
		//key for quitting the game - must be printable!
		QUIT_KEY = '3';
		
		//  Ingame Keys
		//moving the Tetromino to the left
		LEFT_KEY = 'A';
		LEFT_KEY_ALT = 'a'; //alternative key - since shift is applied.
		//moving the Tetromino to the right
		RIGHT_KEY = 'D';
		RIGHT_KEY_ALT = 'd';
		//rotating the Tetromino
		ROTATE_KEY = 'W';
		ROTATE_KEY_ALT = 'w';
		//escape - for leaving
		ESCAPE_KEY = #27;

implementation

	begin
	end.
 
