(* @file UGameplayConstants.pas
 * @author Willi Schinmeyer
 * @date 2011-10-27
 * 
 * UGameplayConstants Unit
 * 
 * Contains various constants regarding gameplay.
 *)

unit UGameplayConstants;

interface
uses crt, UTetrominoShape;

const
	(* @brief Possible Tetromino colors
	 * @note Strictly speaking not gameplay relevant, but it fits here
	 *)
	TETROMINO_COLORS : array[0..3] of byte = (
		RED,
		GREEN,
		BLUE,
		YELLOW
	);
	
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
	
	//keep in sync with shape definitions above
	TETROMINO_MIN_X = -1;
	TETROMINO_MIN_Y = -2;
	TETROMINO_MAX_X = 1;
	TETROMINO_MAX_Y = 1;
	
	GAMEFIELD_WIDTH = 10;
	GAMEFIELD_HEIGHT = 20;
	
	
	//time a tetromino initially needs to drop one step (in ms)
	TETROMINO_BASE_DROP_TIME : integer = 1000;
	//factor by which the drop time is multiplied every level
	TETROMINO_DROP_TIME_FACTOR : real = 0.8;
	//minimum drop time (0 might cause infinite loops)
	TETROMINO_MIN_DROP_TIME : integer = 1;
	//score you get per complete row
	SCORE_PER_ROW : integer = 10;
	//bonus score multiplier applied for every row > 1
	SCORE_ROW_MULTIPLIER : real = 1.5;
	//bonus score multiplier applied for every level > 1
	SCORE_LEVEL_MULTIPLIER : real = 1.2;
	//Rows that need to be removed to advance to the next level
	ROWS_PER_LEVEL : integer = 10;

implementation
	begin
	end.
