(* @file UGeneralTypes.pas
 * @author Willi Schinmeyer
 * @date 2010-10-26
 * 
 * UGeneralTypes Unit
 * 
 * Contains a some general Types: TLevel, TScore, TGameState,
 * TTetrominoShape, TRowIndices
 *)

unit UGeneralTypes;

interface

	uses UVector2i;

	type
		(* The score reached, e.g. the current score ingame or a
		 * hiscore entry. Makes changing it in case I e.g. find out it
		 * overflows because players are too god easier. But longint
		 * should really be enough. *)
		TScore = longint;
		
		(* The current level, as used ingame and displayed in the game
		 * over screen *)
		TLevel = integer;
		
		(* Represents the current state of the game. *)
		TGameState = (stateMainMenu, stateIngame, stateGameOver,
					  stateQuit);
		
		(* The shape of a Tetromino. By definition they are made out of
		 * 4 parts, hence the 4 element array. *)
		TTetrominoShape = array[0..3] of TVector2i;
		
		(* The indices of the rows occupied by a Tetromino *)
		//19 is GAMEFIELD_HEIGHT - 1, but sets cannot be based on
		//expressions
		TRowIndexSet = set of 0..19;

implementation
	begin
	end.
