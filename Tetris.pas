(* @file Tetris.pas
 * @author Willi Schinmeyer
 * @date 2011-10-26
 *
 * Tetris Program
 *
 * Contains the "main function" of the Tetris game. Which is a simple
 * console based Tetris.
 * 
 * @note I could've used crt.window a couple of times, which effectively
 *       makes me draw only to a certain part of the console. However
 *       the Free Pascal documentation describes it as opening a new
 *       window, which is open enough for interpretation for me to not
 *       rely on it since its behaviour may be different on other
 *       platforms. (Unlikely, but possible?)
 *       That, and I didn't find out about it until pretty late into the
 *       project.
 *)

program Tetris;

uses
	//contains game state type
	UGeneralTypes,
	//data shared between states
	USharedData,
	//the different states
	UMainMenu,
	UIngame,
	UGameOver,
	//contains screen size constants
	UDisplayConstants,
	//for console i/o
	crt;

var
	(* This represents the game's current state. Starts in Main Menu. *)
	currentState : TGameState = stateMainMenu;

	(* Data shared across multiple states, e.g. last score (ingame ->
	 * game over) *)
	sharedData : TSharedData;
begin
	//set window size - we just assume this is right.
	window(1, 1, SCREEN_WIDTH, SCREEN_HEIGHT);
	while currentState <> stateQuit do
	begin
		(* Call the current state's function which returns the next
		 * state. *)
		case currentState of

			(* Quit has no function, of course, it just exits the loop.
			 * I just catch it here so it won't enter the else block
			 * which is supposed to catch invalid values. (Which
			 * shouldn't happen anyway, but better safe than sorry.) *)
			stateQuit: (* nothing *);

			(* Main Menu State *)
			stateMainMenu:
			begin
				currentState := UMainMenu.main(sharedData);
			end;

			(* Game State - handles all the actual gameplay. *)
			stateIngame:
			begin
				currentState := UIngame.main(sharedData);
			end;

			(* Game Over state - displays the score and level reached,
			 * could be expanded to include a hiscore. *)
			stateGameOver:
			begin
				currentState := UGameOver.main(sharedData);
			end;

			(* This could be expanded e.g. with a hiscore... *)

		(* I shouldn't ever have any unhandled values - if I do, that's
		 * and error and I should quit. (Or it'd be an infinite loop) *)
		else
			writeln('Error: Invalid Game State. Exiting...');
			currentState := stateQuit;
		end;
	end;
	//cursor could be anywhere, move it and clear screen
	gotoxy(1, 1);
	clrscr();
end.
