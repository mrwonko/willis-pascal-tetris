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
	uses UGeneralTypes, USharedData;

	(* @brief Main Function - called when Game Over Menu State is
	 *        entered.
	 * 
	 * Enters the game over menu loop, you can treat it like a program,
	 * except for the return value.
	 * 
	 * @return The next state *)
	function main(var sharedData : TSharedData) : TGameState;
	
implementation

	uses UMenu, UMenuLine, crt, math;
	
	function main(var sharedData : TSharedData) : TGameState;
	var
		menu : TMenu;
		//menu definition
		title : array [0..0] of TMenuLine =
		(
			(text: 'GAME OVER'; centered : true)
		);
		content : array[0..3] of TMenuLine =
		(
			(text: '<score>'; centered : true),
			(text: '<level>'; centered : true),
			(text: ''; centered : false),
			(text: 'Press any key to continue.'; centered : false)
		);
	begin
		//dynamically fill score and level
		writeStr(content[0].text, 'Score: ', sharedData.lastScore);
		writeStr(content[1].text, 'Level: ', sharedData.lastLevel);
		//initialize menu...
		UMenu.init(menu, title, content);
		//... and draw it
		UMenu.draw(menu);
		
		//move cursor outside of menu because it blinks
		gotoxy(1, 1);
		
		//prepare loop
		main := stateGameOver;
		// "main loop" - repeatedly poll input and handle it.
		repeat
		begin
			//was a key pressed?
			if keyPressed() then
			begin
				//if it was the 0, we need to read another time.
				if readKey() = #0 then
					readKey();
				//in any case we go to the main menu.
				main := stateMainMenu;
			end;
			//wait a little so we don't use the cpu unecessarily
			delay(5); //in ms
		end
		until main <> stateGameOver;
	end;
	
	begin
	end.
