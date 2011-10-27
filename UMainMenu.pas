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
		
		// = numLines + offset*2
		// numLines = 4, offset = 2
		TITLE_HEIGHT : integer = 8;
		// (TITLE_WIDTH = MENU_WIDTH)
		
		// = longestLine + offset*2
		// offset = 2, longestLine = 18 (YET ANOTHER TETRIS)
		MENU_WIDTH : integer = 22;
		
		// = numLines + offset*2
		// offset = 2, numLines = 2
		MENU_HEIGHT : integer = 6;
		
		// = space (1) + borderSize (1)
		MENU_TEXT_OFFSET : integer = 2;
	
	procedure drawMainMenu();
	var
		(* border points of the menu rectangles - cannot be constants
		 * since those can't be initialized from expressions -.- *)
		menuUpperLeft,
		menuMiddleRight,
		menuLowerLeft : TVector2i;
		// current y position of menu entries
		currentTextPosY : integer;
		
		(* \brief Writes a menu text left aligned *)
		procedure writeMenuLine(text : string);
		begin
			gotoxy(menuUpperLeft.x + MENU_TEXT_OFFSET, currentTextPosY);
			write(text);
			inc(currentTextPosY);
		end;
		
		(* \brief Writes a menu text centered *)
		procedure writeCenteredMenuLine(text : string);
		begin
			//since the offset is on both sides, I can ignore it
			gotoxy(menuUpperLeft.x +
			       round((MENU_WIDTH - length(text)) / 2),
			       currentTextPosY);
			write(text);
			inc(currentTextPosY);
		end;
	begin
		//calculate menu position
		menuUpperLeft.x := round((SCREEN_WIDTH - MENU_WIDTH) / 2);
		menuUpperLeft.y := round((SCREEN_HEIGHT - MENU_HEIGHT -
		                          TITLE_HEIGHT) / 2);
		//assertion: x > 0 and y > 0
		
		menuMiddleRight.x := menuUpperLeft.x + MENU_WIDTH - 1;
		menuMiddleRight.y := menuUpperLeft.y + TITLE_HEIGHT - 1;
		
		menuLowerLeft.x := menuUpperLeft.x;
		menuLowerLeft.y := menuMiddleRight.y + MENU_HEIGHT - 1;
		
		//clear screen
		clrscr();
		
		//reset color in case it's been changed earlier
		textColor(white);
		                               
		//draw top border
		UHelpers.drawRectangleBorders(menuUpperLeft, menuMiddleRight);
		//draw bottom border
		UHelpers.drawRectangleBorders(menuLowerLeft, menuMiddleRight);
		
		//set current text Y position to in title rect
		currentTextPosY := menuUpperLeft.y + MENU_TEXT_OFFSET;
		
		//draw title / author (me!)
		writeCenteredMenuLine('YET ANOTHER TETRIS');
		writeMenuLine(''); //empty line
		writeCenteredMenuLine('by Willi');
		writeCenteredMenuLine('Schinmeyer');
		
		//set current text Y position to in main rect
		currentTextPosY := menuMiddleRight.y + MENU_TEXT_OFFSET;
		
		writeMenuLine('S   - Start Game');
		writeMenuLine('ESC - Quit');
	end;

	function main(var sharedData : TSharedData) : TGameState;
	begin
		drawMainMenu();
		gotoxy(1, 1); //move cursor outside of menu because it blinks
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
