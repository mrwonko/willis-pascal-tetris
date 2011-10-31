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
	
	(* @brief Waits for any key to be pressed (and handles extended keys correctly) *)
	procedure waitForAnyKey();
	begin
		//wait for key - but watch out for extended keys...
		if readKey() = #0 then
		begin
			//...because they mean we need to read again.
			readKey();
		end;
	end;
	
	(* @brief Sets the console state back to the default - white on black, full size *)
	procedure resetConsoleState();
	begin
		crt.window(1, 1, SCREEN_WIDTH, SCREEN_HEIGHT);
		crt.textbackground(BLACK);
		crt.textcolor(WHITE);
	end;
	
	(* @brief Returns a random index in range [low, high] *)
	function getRandomIndex(low, high : integer) : integer;
	begin
		//random returns a number in [0, n[
		getRandomIndex := low + random(high - low + 1);
	end;
	
	(* @brief Whether a given index is outside of the bounds - more verbose than rewriting the check. *)
	function isOutOfBounds(lowerBound, upperBound, index : integer) : boolean;
	begin
		isOutOfBounds := (index < lowerBound) or (index > upperBound);
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
		writeln('Move the block with ', LEFT_KEY, ' and ', RIGHT_KEY, ', rotate it with ', ROTATE_KEY, ' and speed it up with ', SPEED_KEY,'.');
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
	
	(* @brief Awards points and increases the level, called for each row that's removed. *)
	procedure onRowRemoved(var state : TGameState);
	begin
		state.level := state.level + 1;
		state.score := state.score + 10;
	end;
	
	(* @brief Randomizes shape & color of a tetromino. *)
	procedure randomizeTetromino(var tet : TTetromino);
	begin
		tet.shape := TETROMINO_SHAPES[getRandomIndex(low(TETROMINO_SHAPES), high(TETROMINO_SHAPES))];
		//tet.shape := TETROMINO_SHAPES[getRandomIndex(0, 3)];
		tet.color := TETROMINO_COLORS[getRandomIndex(low(TETROMINO_COLORS), high(TETROMINO_COLORS))];
		//tet.color := TETROMINO_COLORS[getRandomIndex(0, 3)];
	end;
	
	(* @brief Moves a given Tetromino to the top center of the gamefield where it can begin its fall. *)
	procedure moveToTopCenter(var tet : TTetromino);
	var
		//minimum Y value - want to make sure it's directly at the top.
		minY : integer = 99;
		pos : TVector2i;
	begin
		tet.position.x := round(GAMEFIELD_WIDTH / 2);
		for pos in tet.shape do
		begin
			minY := math.min(minY, pos.y);
		end;
		tet.position.y := -minY + 1; //offset by 1 since y coordinates start at 1
	end;
	
	(* @brief Moves a given tetromino in the right position to be displayed in the preview. *)
	procedure moveToPreviewPosition(var tet : TTetromino);
	begin
		//offset by 1 since coordinates start with (1, 1)
		tet.position.x := -TETROMINO_MIN_X + 1;
		tet.position.y := -TETROMINO_MIN_Y + 1;
	end;
	
	(* @brief Renders a given tetromino. *)
	procedure renderTet(var tet : TTetromino);
	var
		pos : TVector2i;
	begin
		//set color
		crt.textcolor(tet.color);
		//draw parts of shape
		for pos in tet.shape do
		begin
			pos += tet.position;
			crt.gotoxy(pos.x, pos.y);
			write(TETROMINO_CHAR);
		end;
	end;
	
	(* @brief Initializes the Game State (i.e. all the game variables) *)
	procedure initState(var state : TGameState);
	var
		x, y : integer;
	begin
		state.score := 0;
		state.level := 1;
		state.timeToDrop := calculateDropTime(state.level);
		state.running := true;
		state.lastFrameTime := UTime.getMillisecondsSinceMidnight();
		//init cells
		for y := low(state.gamefield) to high(state.gamefield) do
		begin
			for x := low(state.gamefield[y]) to high(state.gamefield[y])  do
			begin
				state.gamefield[y][x].occupied := false;
			end;
		end;
		//init tetrominoes
		randomizeTetromino(state.nextTetromino);
		moveToPreviewPosition(state.nextTetromino);
		randomizeTetromino(state.currentTetromino);
		moveToTopCenter(state.currentTetromino);
	end;
	
	(* @brief Rotates the given tetromino 90 degrees counterclockwise. *)
	procedure rotateCCW(var tet : TTetromino);
	var
		i, temp : integer;
	begin
		//rotate each part
		for i := low(tet.shape) to high(tet.shape) do
		begin
			//see: rotation matrix, inverted due to Y-Down-Coordinate System.
			temp := tet.shape[i].y;
			tet.shape[i].y := tet.shape[i].x;
			tet.shape[i].x := - temp;
		end;
	end;
	
	(* @brief Whether a given Tetronimo fits on the gamefield, i.e. not ouf of bounds or on occupied cells. *)
	function doesTetrominoFit(var gamefield : TGamefield; var tet : TTetromino) : boolean;
	var
		curPos : TVector2i;
	begin
		//it fits...
		doesTetrominoFit := true;
		//...unless any parts of it don't.
		for curPos in tet.shape do
		begin
			curPos := curPos + tet.position;
			//is Y out of range?
			if isOutOfBounds(low(gamefield), high(gamefield), curPos.y) then
			begin
				doesTetrominoFit := false;
			end
			//is X out of range?
			else if isOutOfBounds(low(gamefield[curPos.y]), high(gamefield[curPos.y]), curPos.x) then
			begin
				doesTetrominoFit := false;
			end
			//is it occupied?
			else if gamefield[curPos.y][curPos.x].occupied then
			begin
				doesTetrominoFit := false;
			end;
		end;
	end;
	
	(* @brief Whether a Tetromino is one the floor, i.e. would not fit one block below. *)
	function isTetrominoOnFloor(var gamefield : TGamefield; var tet : TTetromino) : boolean;
	var
		tempTet : TTetromino;
	begin
		tempTet := tet;
		tempTet.position.y += 1;
		isTetrominoOnFloor := not doesTetrominoFit(gamefield, tempTet);
	end;
	
	(* @brief Creates a Game Over overlay and waits for the user to press any key. *)
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
	
	(* @brief Displays everything. Only clears first if initial is true (thus sets the background), only overwrites otherwise (makes missing double buffering less obvious) *)
	procedure render(var state : TGameState; initial : boolean);
	var
		x, y, i : integer;
		curPos : TVector2i;
		//current tetromino shape in absolute coordinates
		curTetShapeAbs : TTetrominoShape;
	begin
		//calculate absolute position of the current tetromino's parts so we can print them in the gamefield render loop
		for i := low(state.currentTetromino.shape) to high(state.currentTetromino.shape) do
		begin
			curTetShapeAbs[i] := state.currentTetromino.position + state.currentTetromino.shape[i];
		end;
		
		//clear
		if initial then crt.clrscr();
		//all windows have gray background.
		crt.textbackground(crt.LIGHTGRAY);
		//  display gamefield
		//set window & background color accordingly
		crt.window(GAMEFIELD_POS_X, GAMEFIELD_POS_Y, GAMEFIELD_POS_X + GAMEFIELD_WIDTH - 1, GAMEFIELD_POS_Y + GAMEFIELD_HEIGHT - 1);
		if initial then crt.clrscr();
		//make actual window 1 longer, since writing at the very end would otherwise result in scrolling since the cursor enters the next line
		crt.window(GAMEFIELD_POS_X, GAMEFIELD_POS_Y, GAMEFIELD_POS_X + GAMEFIELD_WIDTH - 1, GAMEFIELD_POS_Y + GAMEFIELD_HEIGHT);
		//render game field
		gotoxy(1, 1);
		for y := low(state.gamefield) to high(state.gamefield) do
		begin
			for x := low(state.gamefield[y]) to high(state.gamefield[y]) do
			begin
				//is a "dropped" tetromino part here?
				if state.gamefield[y][x].occupied then
				begin
					crt.textcolor(state.gamefield[y][x].color);
					write(TETROMINO_CHAR);
				end
				//is the current tetromino here?
				else
				begin
					for curPos in curTetShapeAbs do
					begin
						if (curPos.x = x) and (curPos.y = y) then
						begin
							crt.textcolor(state.currentTetromino.color);
							write(TETROMINO_CHAR);
						end;
					end;
				end;
				//nope, nothing here (i.e. old cursor position)
				if crt.whereX() = x then
				begin
					write(' ');
				end;
			end;
			//lines automatically wrap thanks to crt.window()
		end;
		//render current tetromino
		renderTet(state.currentTetromino);
		
		//  Display next Tetromino
		//set window accordingly (keep bg color)
		crt.window(PREVIEW_BOX_POS_X, PREVIEW_BOX_POS_Y, PREVIEW_BOX_POS_X + PREVIEW_BOX_WIDTH - 1, PREVIEW_BOX_POS_Y + PREVIEW_BOX_HEIGHT - 1);
		//always clear, checking's too much of a hassle.
		crt.clrscr();
		//make actual window 1 longer, since writing at the very end would otherwise result in scrolling since the cursor enters the next line
		crt.window(PREVIEW_BOX_POS_X, PREVIEW_BOX_POS_Y, PREVIEW_BOX_POS_X + PREVIEW_BOX_WIDTH - 1, PREVIEW_BOX_POS_Y + PREVIEW_BOX_HEIGHT);
		//display it
		renderTet(state.nextTetromino);
		
		//  Display score/points
		//set window accordingly (keep bg color)
		crt.window(INFO_BOX_POS_X, INFO_BOX_POS_Y, INFO_BOX_POS_X + INFO_BOX_WIDTH - 1, INFO_BOX_POS_Y + INFO_BOX_HEIGHT - 1);
		if initial then crt.clrscr();
		//make actual window 1 longer, since writing at the very end would otherwise result in scrolling since the cursor enters the next line
		crt.window(INFO_BOX_POS_X, INFO_BOX_POS_Y, INFO_BOX_POS_X + INFO_BOX_WIDTH - 1, INFO_BOX_POS_Y + INFO_BOX_HEIGHT);
		//display them
		crt.textcolor(crt.BLACK);
		crt.gotoxy(1, 1);
		write('score: ',state.score);
		crt.gotoxy(1, 2);
		write('level: ',state.level);
		//  Reset state
		resetConsoleState();
	end;
	
	procedure removeFullRows(var state : TGameState);
	var
		curRowIndex, i : integer;
		
		function isCurrentRowFull() : boolean;
		var
			curCellIndex : integer;
		begin
			isCurrentRowFull := true;
			//when any cell is not occupied, the row's not full. duh.
			for curCellIndex := low(state.gamefield[curRowIndex]) to high(state.gamefield[curRowIndex]) do
			begin
				if not state.gamefield[curRowIndex][curCellIndex].occupied then
				begin
					isCurrentRowFull := false;
				end;
			end;
		end;
	begin
		//there's no down-counting for loop, I think. I do it myself.
		curRowIndex := high(state.gamefield);
		while curRowIndex >= low(state.gamefield) do
		begin
			//if the row is full...
			if isCurrentRowFull() then
			begin
				onRowRemoved(state);
				//move all above down.
				i := curRowIndex;
				while i > low(state.gamefield) do
				begin
					state.gamefield[i] := state.gamefield[i-1];
					i -= 1;
				end;
				//and empty the top one
				for i := low(state.gamefield[low(state.gamefield)]) to high(state.gamefield[low(state.gamefield)]) do
				begin
					state.gamefield[low(state.gamefield)][i].occupied := false;
				end;
			end;
			curRowIndex -= 1;
		end;
	end;
	
	(* @brief Called whenever the current Tet has been moved. Checks whether it's at the bottom and locks it if necessary. *)
	procedure onCurTetMoved(var state : TGameState);
	var
		pos : TVector2i;
	begin
		if isTetrominoOnFloor(state.gamefield, state.currentTetromino) then
		begin
			//we hit the floor.
			//so we need to embed this on the gamefield.
			//since we only ever move stuff within the gamefield we don't have to check the array bounds.
			for pos in state.currentTetromino.shape do
			begin
				pos += state.currentTetromino.position;
				state.gamefield[pos.y][pos.x].occupied := true;
				state.gamefield[pos.y][pos.x].color := state.currentTetromino.color;
			end;
			//remove filled rows
			removeFullRows(state);
			//now we need a new tetromino.
			state.currentTetromino := state.nextTetromino;
			moveToTopCenter(state.currentTetromino);
			randomizeTetromino(state.nextTetromino);
			//since the state changed, we need to re-render. But before any possible game over overlay.
			render(state, false);
			//which may already be hitting the blocks below, in which case the player's lost.
			if isTetrominoOnFloor(state.gamefield, state.currentTetromino) or not doesTetrominoFit(state.gamefield, state.currentTetromino) then
			begin
				state.running := false;
				showGameOverScreen();
			end;
		end
		else
		begin
			//since the state changed, we need to re-render.
			render(state, false);
		end;
	end;
	
	(* @brief Tries moving the current Tetromino as requested by player (input) *)
	procedure tryMove(var state : TGameState; requestedMove : TRequestedMove);
	var
		tempTet : TTetromino;
	begin
		//create copy...
		tempTet := state.currentTetromino;
		//...and do the requested move on it.
		case requestedMove of
			mvRight:
				tempTet.position.x += 1;
			mvLeft:
				tempTet.position.x -= 1;
			mvDown:
				tempTet.position.y += 1;
			mvRotate:
				rotateCCW(tempTet);
		end;
		//is it possible?
		if doesTetrominoFit(state.gamefield, tempTet) then
		begin
			//if so: apply to actual tetromino.
			state.currentTetromino := tempTet;
			onCurTetMoved(state);
		end;
	end;
	
	(* @brief Handles input, i.e. block moving and quitting. *)
	procedure handleInput(var state : TGameState);
	var
		key : char;
	begin
		//read complete input buffer
		while keyPressed() do
		begin
			key := readKey();
			case key of
				//#0 means extended key -> read again (but ignore, they're not of interest to me.)
				#0:
				begin
					readKey();
				end;
				//QUIT?
				ESCAPE_KEY:
				begin
					state.running := false;
				end;
				//MOVE LEFT
				LEFT_KEY,
				LEFT_KEY_ALT:
				begin
					tryMove(state, mvLeft);
				end;
				//MOVE RIGHT
				RIGHT_KEY,
				RIGHT_KEY_ALT:
				begin
					tryMove(state, mvRight);
				end;
				//MOVE DOWN
				SPEED_KEY,
				SPEED_KEY_ALT:
				begin
					tryMove(state, mvDown);
				end;
				//ROTATE (why am I writing in caps?)
				ROTATE_KEY,
				ROTATE_KEY_ALT:
				begin
					tryMove(state, mvRotate);
				end;
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
		
		//see if we need to drop the current tet
		state.timeToDrop -= deltaT;
		while (state.timeToDrop < 0) and state.running do //check for running, too, since this might cause a game over
		begin
			//yes, we need to. do it.
			state.currentTetromino.position.y += 1;
			//check if we hit the floor
			onCurTetMoved(state);
			//and set time to next drop (which may be in the past, hence while not if)
			state.timeToDrop += calculateDropTime(state.level);
		end;
	end;
	
	procedure runGame();
	var
		state : TGameState;
	begin
		randomize(); //init random number generation
		initState(state);
		render(state, true); //do initial rendering, i.e. draw background
		while state.running do
		begin
			//render(state, false); //now I only call render when a tetromino's been moved.
			handleInput(state);
			advanceFrame(state);
		end;
	end;

	begin
	end.
