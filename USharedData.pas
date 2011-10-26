(* @file USharedData.pas
 * @author Willi Schinmeyer
 * @date 2010-10-26
 * 
 * USharedData Unit
 * 
 * Contains definition of the TSharedData Type.
 *)

unit USharedData;

interface
	uses UGeneralTypes;

	type
		(* @brief Data shared across different game states
		 * 
		 * Could be expanded to include e.g. a hiscore list. *)
		TSharedData = record
			
			(* Points scored in the last game, set by ingame state,
			 * read by game over state *)
			lastScore : TScore;
			
			(* Level reached in the last game, set by ingame state,
			 * read by game over state *)
			lastLevel : TLevel;
		end;

implementation
	begin
	end.
