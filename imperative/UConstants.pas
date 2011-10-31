(* @file UConstants.pas
 * @author Willi Schinmeyer
 * @date 2011-10-30
 * 
 * All the constants used in the program.
 *)

unit UConstants;

interface
	uses
		crt, //colors
		UTetrominoShape; //TTetrominoShape

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
		//speeding the Tetromino up
		SPEED_KEY = 'S';
		SPEED_KEY_ALT = 's';
		//escape - for leaving
		ESCAPE_KEY = #27;
		
		
		//  Gameplay-related
		//how long a tetromino initially needs to drop one step.
		BASE_DROP_TIME = 1000;
		
		//possible colors for tetrominoes
		TETROMINO_COLORS : array[0..3] of byte = (
			RED,
			GREEN,
			BLUE,
			YELLOW
		);
		
		//possible shapes for tetrominoes
		TETROMINO_SHAPES : array[0..6] of TTetrominoShape =
		(
			//O
			( (x:-1; y:-1), (x:-1;y:0), (x:0; y:0), (x:0; y:-1) ),
			//L
			( (x:-1; y:-1), (x:-1;y:0), (x:-1; y:1), (x:0; y:-1) ),
			//J
			( (x:0; y:-1), (x:0;y:0), (x:0; y:1), (x:-1; y:-1) ),
			//T
			( (x:-1; y:0), (x:0;y:0), (x:1; y:0), (x:0; y:-1) ),
			//I
			( (x:0; y:-2), (x:0;y:-1), (x:0; y:0), (x:0; y:1) ),
			//S
			( (x:-1; y:-1), (x:-1;y:0), (x:0; y:0), (x:0; y:1) ),
			//Z
			( (x:-1; y:1), (x:-1;y:0), (x:0; y:0), (x:0; y:-1) )
		);
		
		//keep in sync with shape definitions above - bounds of tetrominoes, for preview box.
		TETROMINO_MIN_X = -1;
		TETROMINO_MIN_Y = -2;
		TETROMINO_MAX_X = 1;
		TETROMINO_MAX_Y = 1;
		
		//Character representing Tetrominoes
		TETROMINO_CHAR = '#';
		
		//  UI Definitions, i.e. which window is where and how big.
		//screen size, used for many calculations and for resetting the window.
		SCREEN_WIDTH = 80;
		SCREEN_HEIGHT = 50;
		
		//game over screen definitions
		GAMEOVER_WINDOW_WIDTH = 12; //so it's evenly outside gamefield
		GAMEOVER_WINDOW_HEIGHT = 3;
		GAMEOVER_WINDOW_POS_X = round( (SCREEN_WIDTH - GAMEOVER_WINDOW_WIDTH) / 2);
		GAMEOVER_WINDOW_POS_Y = round( (SCREEN_HEIGHT - GAMEOVER_WINDOW_HEIGHT) / 2);
		GAMEOVER_TEXT = 'GAME OVER';
		//position relative to window
		GAMEOVER_TEXT_POS_X = 2;
		GAMEOVER_TEXT_POS_Y = 2;
		
		//game field
		GAMEFIELD_WIDTH = 10;
		GAMEFIELD_HEIGHT = 20;
		GAMEFIELD_POS_X = round((SCREEN_WIDTH - GAMEFIELD_WIDTH)/2);
		GAMEFIELD_POS_Y = round((SCREEN_HEIGHT - GAMEFIELD_HEIGHT)/2);
		
		//tetromino preview box definitions
		PREVIEW_BOX_POS_X  = GAMEFIELD_POS_X + GAMEFIELD_WIDTH + 1;
		PREVIEW_BOX_POS_Y  = GAMEFIELD_POS_Y;
		PREVIEW_BOX_WIDTH  = TETROMINO_MAX_X - TETROMINO_MIN_X + 1;
		PREVIEW_BOX_HEIGHT = TETROMINO_MAX_Y - TETROMINO_MIN_Y + 1;
		
		//score/level info box definitions
		INFO_BOX_POS_X = PREVIEW_BOX_POS_X;
		INFO_BOX_POS_Y = PREVIEW_BOX_POS_Y + PREVIEW_BOX_HEIGHT + 1;
		INFO_BOX_HEIGHT = 2; //2 lines: score and level
		INFO_BOX_WIDTH = 12; //there are 7 chars in 'score: ' and since score = 10*(level-1) and level 1333+ means 1ms block fall time, they certainly won't get over 13320 points (5 digits). 7+5=12

implementation

	begin
	end.
 
