(* @file UGameplayTypes.pas
 * @author Willi Schinmeyer
 * @date 2011-10-30
 * 
 * Most types relevant to gameplay, except for TVector2i TTetrominoShape which have their own units to prevent cyclic dependencies.
 *)

unit UGameplayTypes;

interface
	uses UConstants, UVector2i, UTetrominoShape;

	type
		(* @brief A cell in the gamefield. *)
		TCell = record
			occupied : boolean; //whether there's a block here
			color : byte; //of what color the block, if any, is.
		end;
		
		(* @brief Tetrominoes are the falling blocks. *)
		TTetromino = record
			position : TVector2i;
			shape : TTetrominoShape;
			color : byte;
		end;
		
		(* @brief For iterating over TGameState.gamefield *)
		TGamefieldRow = array[1..GAMEFIELD_WIDTH] of TCell;
		
		TGamefield = array[1..GAMEFIELD_HEIGHT] of TGamefieldRow;
		
		(* @brief The current state of the game, i.e. all variables that need to be shared between the gameplay functions. *)
		TGameState = record
			gamefield : TGamefield; //addressed as gamefield[y][x]
			currentTetromino, nextTetromino : TTetromino;
			lastFrameTime : longint; //timestamp of the last frame
			score,
			level, //how long a  needs to fall down 1 step is directly calculated from the level.
			timeToDrop : integer; //how long until the /current/ block falls down 1 step
			running : boolean; //whether the game's still running - once it's over, we return to the main menu.
		end;
		
		(* @brief Which kind of move the player requested. *)
		TRequestedMove = (mvLeft, mvRight, mvDown, mvRotate);

implementation

	begin
	end.
