(* @file UGeneralTypes.pas
 * @author Willi Schinmeyer
 * @date 2010-10-26
 * 
 * UGeneralTypes Unit
 * 
 * Contains a some general Types: TLevel, TScore, TGameState
 *)

unit UGeneralTypes;

interface

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

implementation
	begin
	end.
