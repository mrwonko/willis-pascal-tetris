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
uses crt, UGeneralTypes;

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
	TETROMINO_MIN_X : integer = -1;
	TETROMINO_MIN_Y : integer = -2;
	TETROMINO_MAX_X : integer = 1;
	TETROMINO_MAX_Y : integer = 1;
	
	//keep in sync with UGamefield.TGamefield.cells
	GAMEFIELD_WIDTH : integer = 10;
	//keep in sync with UGeneralTypes.TRowIndices & see above!
	GAMEFIELD_HEIGHT : integer = 20;
	
	//char representating a Tetromino part
	CELL_OCCUPIED_CHAR : char = '#';
	//the empty char must not be anything else than space because
	//otherwise I'd have to set the color, which I don't.
	CELL_EMPTY_CHAR : char = ' ';

implementation
	begin
	end.
