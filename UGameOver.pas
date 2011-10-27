(* @file UGameOver.pas
 * @author Willi Schinmeyer
 * @date 2011-10-27
 * 
 * UGameOver Unit
 * 
 * Contains the Game Over Menu code which is executed once the game over
 * state is entered.
 *)

unit UGameOver;

interface
	uses UGeneralTypes, USharedData, crt;

	(* @brief Main Function - called when Game Over Menu State is
	 *        entered.
	 * 
	 * Enters the game over menu loop, you can treat it like a program,
	 * except for the return value.
	 * 
	 * @return The next state *)
	function main(var sharedData : TSharedData) : TGameState;
	
implementation

	function main(var sharedData : TSharedData) : TGameState;
	begin
		clrscr;
		writeln('Game Over');
		main := stateMainMenu;
	end;
	
	begin
	end.
