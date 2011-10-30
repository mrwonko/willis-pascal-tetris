(* @file Tetris.pas
 * @author Willi Schinmeyer
 * @date 2011-10-30
 * 
 * This is my second take on a simple Tetris game. This time with no OOP. (And no hard line breaks, but that's a different story.)
 *)

program Tetris;

uses crt, UConstants, UFunctions;

var
	running : boolean = true;
	key : char;
begin
	//initial menu display
	showMainMenu();
	while running do
	begin
		key := readKey();
		case key of
			//extended key? we need to read again.
			#0:
			begin
				readKey(); //but discard it, we don't care.
			end;
			
			//New game key pressed?
			NEWGAME_KEY:
			begin
				runGame();
				//game's done now, show menu again.
				showMainMenu();
			end;
			
			//Help key pressed?
			HELP_KEY:
			begin
				showHelp();
				//help done being shown, show main menu again
				showMainMenu();
			end;
			
			//Quit game pressed?
			QUIT_KEY:
			begin
				running := false;
			end;
		end;
	end;
end.
