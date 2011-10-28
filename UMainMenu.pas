(* @file UMainMenu.pas
 * @author Willi Schinmeyer
 * @date 2011-10-27
 * 
 * UMainMenu Unit
 * 
 * Contains the Main Menu code which is executed once the main menu
 * state is entered.
 *)

unit UMainMenu;

interface
	uses USharedData, UGeneralTypes;

	(* @brief Main Function - called when Main Menu State is entered.
	 * 
	 * Enters the main menu loop, you can treat it like a program,
	 * except for the return value.
	 * 
	 * @return The next state *)
	function main(var sharedData : TSharedData) : TGameState;
	
implementation

	uses UMenu, UMenuLine, crt;

	function main(var sharedData : TSharedData) : TGameState;
	var
		menu : TMenu;
		//menu definition
		title : array [0..3] of TMenuLine =
		(
			(text: 'YET ANOTHER TETRIS'; centered : true),
			(text: ''; centered : true), //empty line
			(text: 'by Willi'; centered : true),
			(text: 'Schinmeyer'; centered : true)
		);
		content : array[0..1] of TMenuLine =
		(
			(text: 'S   - Start Game'; centered : false),
			(text: 'ESC - Quit'; centered : false)
		);
	begin
		//initialize menu...
		UMenu.init(menu, title, content);
		//... and draw it
		UMenu.draw(menu);
		
		//move cursor outside of menu because it blinks
		gotoxy(1, 1);
		
		//prepare loop
		main := stateMainMenu;
		// "main loop" - repeatedly poll input and handle it.
		repeat
		begin
			//was a key pressed?
			if keyPressed() then
			begin
				//was an important key pressed?
				case readKey() of
					#0: //#0 = key was outside ASCII range, read again
						readKey(); //ignore those keys
					#27: //Escape
						main := stateQuit; //quit game
					's', 'S': //shift is applied to s, not reported
						main := stateIngame; //start new game
				//else: do nothing
				end;
			end;
			//wait a little so we don't use the cpu unecessarily
			delay(5); //in ms
		end
		until main <> stateMainMenu;
	end;
	
	begin
	end.
