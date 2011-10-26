(* @file Tetris.pas
 * @author Willi Schinmeyer
 * @date 2011-10-26
 * 
 * Tetris Program
 * 
 * Contains the "main function" of the Tetris game.
 *)

program Tetris;

uses UGeneralTypes, USharedData;

var
	(* This represents the game's current state. Starts in Main Menu. *)
	currentState : TGameState = stateMainMenu;
	
	(* Data shared across multiple states, e.g. last score (ingame ->
	 * game over) *)
	sharedData : TSharedData;
begin
	while currentState <> stateQuit do
	begin
		(* Call the current state's function which returns the next
		 * state. *)
		case currentState of
		
			(* Quit has no function, of course, it just exits the loop.
			 * I just catch it here so it won't enter the else block
			 * which is supposed to catch invalid values. *)
			stateQuit: (* nothing *);
			
			(* Main Menu State - displays the main menu, waits for
			 * input and sets the new state accordingly. *)
			stateMainMenu:
			begin
				(* not yet written... Just quit. *)
				writeln('Main Menu');
				currentState := stateQuit;
			end;
			
			(* Game State - handles all the actual gameplay including
			 * the game over screen. *)
			stateIngame:
			begin
				(* not yet written... Just quit. *)
				writeln('Ingame');
				currentState := stateQuit;
			end;
			
			(* Game Over state - displays the score and level reached,
			 * could be expanded to include a hiscore. *)
			stateGameOver:
			begin
				(* not yet written... Just quit. *)
				writeln('Game Over');
				currentState := stateQuit;
			end;
			
			(* This could be expanded e.g. with a hiscore... *)
			
		(* I shouldn't ever have any unhandled values - if I do, that's
		 * and error and I should quit. (Or it'd be an infinite loop) *)
		else
			writeln('Error: Invalid Game State. Exiting...');
			currentState := stateQuit;
		end;
	end;
end.
