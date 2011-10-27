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

	uses crt, UGeneralConstants, UHelpers, UVector2i;

	const
		// menu width = longestLine + offset*2 + borderSize*2
		// offset = 1, borderSize = 1, longestLine = 14, rounded.
		MENU_WIDTH : integer = 20;
		// menu height = numLines + offset*2 + borderSize * 2
		// offset = 1, borderSize = 1, numLines = 2
		MENU_HEIGHT : integer = 6;

	function main(var sharedData : TSharedData) : TGameState;
		var
			(* border points of the menu - cannot be constants since
			 * those can't be initialized from expressions -.- *)
			menuUpperLeft : TVector2i;
			menuLowerRight : TVector2i;
			// x position of menu entries
			textPosX : integer;
			// current y position of menu entries
			currentTextPosY : integer;
	begin
		//calculate menu position
		menuUpperLeft.x := round((SCREEN_WIDTH - MENU_WIDTH) / 2);
		menuUpperLeft.y := round((SCREEN_HEIGHT - MENU_HEIGHT) / 2);
		menuLowerRight.x := menuUpperLeft.x + MENU_WIDTH - 1;
		menuLowerRight.y := menuUpperLeft.y + MENU_HEIGHT - 1;
		//text is offset a little (borderSize + offset = 2)
		textPosX := menuUpperLeft.x + 2;
		currentTextPosY := menuUpperLeft.y + 2;
		
		//clear screen
		clrscr;
		//reset color in case it's been changed earlier
		textColor(white);
		
		//draw menu border
		UHelpers.drawRectangleBorders(menuUpperLeft, menuLowerRight);
		//write start game line
		gotoxy(textPosX, currentTextPosY);
		write(' S  Start Game');
		inc(currentTextPosY); //next line
		//write quit line
		gotoxy(textPosX, currentTextPosY);
		write('ESC Quit');
		inc(currentTextPosY); //next line
		
		main := stateQuit;
	end;
	
	begin
	end.
