(* @file UIngame.pas
 * @author Willi Schinmeyer
 * @date 2011-10-27
 * 
 * UIngame Unit
 * 
 * Contains the actual game code which is executed once the ingame
 * state is entered.
 *)

unit UIngame;

interface
	uses UGeneralTypes, USharedData, crt;

	(* @brief Main Function - called when ingame State is entered.
	 * 
	 * Enters the game loop, you can treat it like a program, except for
	 * the return value.
	 * 
	 * @return The next state *)
	function main(var sharedData : TSharedData) : TGameState;
	
implementation

	function main(var sharedData : TSharedData) : TGameState;
	begin
		clrscr;
		writeln('Ingame');
		main := stateGameOver;
	end;
	
	begin
	end.
