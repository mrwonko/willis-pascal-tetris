(* @file UFunctions.pas
 * @author Willi Schinmeyer
 * @date 2011-10-30
 * 
 * Contains all the methods and functions.
 *)

unit UFunctions;

interface
	(* @brief Displays the main menu. *)
	procedure showMainMenu();

	(* @brief Displays the help, i.e. how to play. *)
	procedure showHelp();

	(* @brief Starts the game. *)
	procedure runGame();

implementation
	uses
		crt, //for console i/o
		UConstants, //all the constants, duh
		UGameplayTypes, //most gameplay types, except for:
		UVector2i,      //- TVector2i
		UTetrominoShape,//- TTetrominoShape
		                //which have their own units to prevent cyclic dependencies (with constants)
		UTime, //Time handling
		math; //max()
	
	/////////////
	// HELPERS //
	/////////////
	
	procedure waitForAnyKey();
	begin
		//wait for key - but watch out for extended keys...
		if readKey() = #0 then
		begin
			//...because they mean we need to read again.
			readKey();
		end;
	end;
	
	
	procedure resetConsoleState();
	begin
		crt.window(1, 1, SCREEN_WIDTH, SCREEN_HEIGHT);
		crt.textbackground(BLACK);
		crt.textcolor(WHITE);
	end;
	
	////////////
	//  MENUS //
	////////////
	
	procedure showMainMenu();
	begin
		//well, just print it :D
		clrscr();
		writeln('TETRIS');
		writeln();
		writeln(NEWGAME_KEY, ') start');
		writeln(HELP_KEY, ') help');
		writeln(QUIT_KEY, ') quit');
	end;
	
	procedure showHelp();
	begin
		//Printing a help text is not exactly an art... Just write it.
		clrscr();
		writeln('How to play:');
		writeln();
		writeln('Move the block with ', LEFT_KEY, ' and ', RIGHT_KEY, ', rotate it with ', ROTATE_KEY, '.');
		writeln('Press Escape at any time to return to the main menu.');
		writeln();
		writeln('Press any key to continue.');
		waitForAnyKey();
	end;
	
	//////////////////
	//  GAME STUFF  //
	//////////////////
	
	(* @brief Calculates the time a block needs to fall 1 step from the current level. *)
	function calculateDropTime(level : integer) : integer;
	begin
		//0 would be bad (drop infinitely in one timestep, insta-lose), so we have a minimum of 1. (Which is still pretty much impossible to win, but it won't be reached until level 1333.)
		calculateDropTime := math.max(1, round(2/(level+1))) * BASE_DROP_TIME;
	end;
	
	procedure onRowRemoved(var state : TGameState);
	begin
		state.level := state.level + 1;
		state.score := state.score + 10;
	end;
	
	procedure initState(var state : TGameState);
	begin
		state.score := 0;
		state.level := 1;
		state.timeToDrop := calculateDropTime(state.level);
		state.running := true;
		state.lastFrameTime := UTime.getMillisecondsSinceMidnight();
	end;
	
	procedure showGameOverScreen();
	begin
		//create window for game over
		crt.window(GAMEOVER_WINDOW_POS_X, GAMEOVER_WINDOW_POS_Y, GAMEOVER_WINDOW_POS_X + GAMEOVER_WINDOW_WIDTH - 1, GAMEOVER_WINDOW_POS_Y + GAMEOVER_WINDOW_HEIGHT - 1);
		//set color/background
		crt.textbackground(RED);
		crt.textcolor(BLACK);
		//clear & write GAME OVER
		crt.clrscr();
		crt.gotoxy(GAMEOVER_TEXT_POS_X, GAMEOVER_TEXT_POS_Y);
		write(GAMEOVER_TEXT);
		//undo changes
		resetConsoleState();
		//wait for any key
		waitForAnyKey();
	end;
	
	procedure handleInput(var state : TGameState);
	var
		key : char;
	begin
		//read complete input buffer
		while keyPressed() do
			key := readKey();
			case key of
				//#0 means extended key -> read again (but ignore, they're not of interest to me.)
				#0:
				begin
					readKey();
				end;
				ESCAPE_KEY:
				begin
					state.running := false;
				end;
			end;
	end;
	
	procedure advanceFrame(var state : TGameState);
	var
		now : longint;
		deltaT : integer;
	begin
		//calculate time step (delta t)
		now := UTime.getMillisecondsSinceMidnight();
		deltaT := UTime.getDifference(now, state.lastFrameTime);
		//set last frame time so we'll be able to calculate this correctly next frame, too.
		state.lastFrameTime := now;
		
		//TODO
		state.running := false;
		showGameOverScreen();
	end;
	
	procedure render(var state : TGameState);
	begin
		//clear
		crt.clrscr();
		//  display gamefield
		//set window & background color accordingly
		crt.window(GAMEFIELD_POS_X, GAMEFIELD_POS_Y, GAMEFIELD_POS_X + GAMEFIELD_WIDTH - 1, GAMEFIELD_POS_Y + GAMEFIELD_HEIGHT - 1);
		crt.textbackground(crt.LIGHTGRAY);
		crt.clrscr();
		//render game field
		//TODO
		//  Display next Tetromino
		//set window accordingly (keep bg color)
		crt.window(PREVIEW_BOX_POS_X, PREVIEW_BOX_POS_Y, PREVIEW_BOX_POS_X + PREVIEW_BOX_WIDTH - 1, PREVIEW_BOX_POS_Y + PREVIEW_BOX_HEIGHT - 1);
		//display it
		crt.clrscr();
		//  Display score/points
		//set window accordingly (keep bg color)
		crt.window(INFO_BOX_POS_X, INFO_BOX_POS_Y, INFO_BOX_POS_X + INFO_BOX_WIDTH - 1, INFO_BOX_POS_Y + INFO_BOX_HEIGHT - 1);
		//display them
		crt.clrscr();
		crt.textcolor(crt.BLACK);
		crt.gotoxy(1, 1);
		write('score: ',state.score);
		crt.gotoxy(1, 2);
		write('level: ',state.level);
		//  Reset state
		resetConsoleState();
	end;
	
	procedure runGame();
	var
		state : TGameState;
	begin
		initState(state);
		while state.running do
		begin
			render(state); //do this first since handleInput or advanceFrame may overlay the Game Over screen.
			handleInput(state);
			advanceFrame(state);
		end;
	end;

	begin
	end.
