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
	uses UGeneralTypes, USharedData;

	(* @brief Main Function - called when ingame State is entered.
	 * 
	 * Enters the game loop, you can treat it like a program, except for
	 * the return value.
	 * 
	 * @return The next state *)
	function main(var sharedData : TSharedData) : TGameState;


implementation

	uses
		UGamefield, //TGamefield
		UGamefieldRow, //TGamefieldRow - I need the isFull check.
		UTetromino, //TTetromino
		UVector2i, //TVector2i
		UGameplayConstants, //gamefield size
		UDisplayConstants, //screen size
		crt, //display stuff
		math, //max()
		UHelpers, //border drawing
		UKeyConstants, //codes of the keys (e.g. arrow keys)
		UTime; //time handling
	
	const
		//Maximum score that can be displayed - any longer number would
		//not fit into the box
		MAX_DISPLAY_SCORE = 9999;
		SCORE_STRING  = 'score: ';
		MAX_DISPLAY_LEVEL = 999;
		LEVEL_STRING = 'level: ';
		//length of string (7) + maximum number of digits (4)
		INFOBOX_WIDTH = 11;
		//level and score - two lines.
		INFOBOX_HEIGHT = 2;
	
	
	type
		(* @brief The data shared between game functions. *)
		TGameData = record
			//the gamefield
			gamefield : TGamefield;
			//the currently falling tetromino
			currentTetromino,
			//the Tetromino that will be next
			nextTetromino : TTetromino;
			//the gamefield's top left coordinates, excluding border
			gamefieldPosition,
			//The coordinates & size of the Tetromino Preview Box, excluding
			//border
			tetrominoPreviewBoxPosition,
			tetrominoPreviewBoxSize,
			//The info box's top left coordinates, excluding border
			infoboxPosition : TVector2i;
			//player's current score
			score : integer;
			//player's current level
			level : integer;
			//rows the player still has to remove to advance a level
			rowsToNextLevel : integer;
			//the time the last frame took place
			lastFrameTime : longint;
			//time until the current tetromino falls another block down
			timeToNextDrop : integer;
			//interval between tetromino drops (i.e. move 1 cell down),
			//decreases over time.
			dropTime : integer;
			//current state of the game - once it's no longer ingame,
			//we stop the game loop.
			currentState : TGameState;
		end;
	
	(* @brief Checks whether an integer will overflow through addition
	 *)
	function willSumOverflow(a, b : integer) : boolean;
	var
		sum : integer;
	begin
		sum := a + b;
		willSumOverflow := (a > sum);
	end;

		
	(* @brief Initializes everything that needs initializing *)
	procedure init(var data : TGameData);
	begin
		//init score & level
		data.score := 0;
		data.level := 1;
		
		//we're currently in the ingame state or we wouldn't be here.
		data.currentState := stateIngame;
		
		//calculate gamefield position
		data.gamefieldPosition.x := round((SCREEN_WIDTH - 
			GAMEFIELD_WIDTH) / 2);
		data.gamefieldPosition.y := round((SCREEN_HEIGHT -
			GAMEFIELD_HEIGHT) / 2);
		//make sure it's in printable space
		data.gamefieldPosition.x := math.max(1 + BORDER_SIZE,
			data.gamefieldPosition.x);
		data.gamefieldPosition.y := math.max(1 + BORDER_SIZE,
			data.gamefieldPosition.y);
		
		//calculate tetromino preview box position
		//it's to the right of the gamefield, with 1 char spacing.
		data.tetrominoPreviewBoxPosition := data.gamefieldPosition +
			UVector2i.new(GAMEFIELD_WIDTH + 2*BORDER_SIZE + 1, 0);
		//set tetromino preview box size
		data.tetrominoPreviewBoxSize.x := TETROMINO_MAX_X -
			TETROMINO_MIN_X + 1;
		data.tetrominoPreviewBoxSize.y := TETROMINO_MAX_Y -
			TETROMINO_MIN_Y + 1;
		
		//calculate the info box's position
		//it's below the tetromino preview  box, 1 char spacing.
		data.infoboxPosition := data.tetrominoPreviewBoxPosition +
			UVector2i.new(0, data.tetrominoPreviewBoxSize.y +
			2 * BORDER_SIZE + 1);
		
		//initialize gamefield & tetrominoes (includes shape setup)
		UGamefield.init(data.gamefield, data.gamefieldPosition);
		UTetromino.init(data.currentTetromino);
		UTetromino.init(data.nextTetromino);
		
		//initialize time
		data.lastFrameTime := UTime.getMillisecondsSinceMidnight();
		//remaining rows to levelup
		data.rowsToNextLevel := UGameplayConstants.ROWS_PER_LEVEL;
		//initial & current drop time
		data.dropTime := UGameplayConstants.TETROMINO_BASE_DROP_TIME;
		data.timeToNextDrop := data.dropTime;
	end;
	
	(* @brief Draws the content that doesn't change - the borders,
	 *        above all. *)
	procedure drawStaticContent(var data : TGameData);
	begin
		//set color to white - better safe than sorry
		crt.textcolor(WHITE);
		//draw gamefield box
		UHelpers.drawRectangleBorders(data.gamefieldPosition -
			UVector2i.new(1, 1), data.gamefieldPosition +
			UVector2i.new(GAMEFIELD_WIDTH, GAMEFIELD_HEIGHT));
		//draw tetromino preview box
		UHelpers.drawRectangleBorders(data.tetrominoPreviewBoxPosition -
			UVector2i.new(1, 1), data.tetrominoPreviewBoxPosition +
			data.tetrominoPreviewBoxSize);
		//draw info box
		UHelpers.drawRectangleBorders(data.infoboxPosition -
			UVector2i.new(1, 1), data.infoBoxPosition +
			UVector2i.new(INFOBOX_WIDTH, INFOBOX_HEIGHT));
		//draw score and level string (score top, level bottom)
		gotoxy(data.infoboxPosition.x, data.infoboxPosition.y);
		write(SCORE_STRING);
		gotoxy(data.infoboxPosition.x, data.infoboxPosition.y+1);
		write(LEVEL_STRING);
	end;
	
	(* @brief Updates the displayed next Tetromino, should be called
	 *        when it changes. *)
	procedure updateTetrominoPreview(var data : TGameData);
		procedure clearPreview();
		var
			i, curY : integer;
		begin
			//for each line:
			for curY := data.tetrominoPreviewBoxPosition.y to
				data.tetrominoPreviewBoxPosition.y +
				data.tetrominoPreviewBoxSize.y - 1 do
			begin
				//clear this line
				gotoxy(data.tetrominoPreviewBoxPosition.x, curY);
				for i := 1 to data.tetrominoPreviewBoxSize.x do
				begin
					write(' ');
				end;
			end;
		end;
		procedure drawPreview();
		var
			curPos : TVector2i;
		begin
			crt.textcolor(data.nextTetromino.color);
			for curPos in data.nextTetromino.shape do
			begin
				//offset enough so (0, 0) is new minimum
				curPos := curPos - UVector2i.new(TETROMINO_MIN_X,
					TETROMINO_MIN_Y);
				//put at correct location at screen
				curPos := curPos + data.tetrominoPreviewBoxPosition;
				//move cursor there
				gotoxy(curPos.x, curPos.y);
				//write!
				write(CELL_OCCUPIED_CHAR);
			end;
		end;
	begin
		clearPreview();
		drawPreview();
	end;
	
	(* @brief Updates the displayed current score, should be called
	 *        when it changes. *)
	procedure updateScoreDisplay(var data : TGameData);
	begin
		//no clearing necessary since score only gets higher, thus
		//overwrites.
		crt.textcolor(WHITE);
		gotoxy(data.infoboxPosition.x + length(SCORE_STRING),
			data.infoboxPosition.y);
		write(math.min(data.score, MAX_DISPLAY_SCORE));
	end;
	
	(* @brief Updates the displayed current level, should be called
	 *        when it changes. *)
	procedure updateLevelDisplay(var data : TGameData);
	begin
		//no clearing necessary since level only gets higher, thus
		//overwrites.
		crt.textcolor(WHITE);
		gotoxy(data.infoboxPosition.x + length(LEVEL_STRING),
			data.infoboxPosition.y + 1);
		write(math.min(data.level, MAX_DISPLAY_LEVEL));
	end;
	
	(* @brief Called when 1 or more rows have been deleted.
	 *        Calculates & applies score & level changes and other
	 *        consequences.
	 *)
	procedure onRowsDeleted(var data : TGameData; numRows : integer);
	var
		//by how much the score will increase
		deltaScore,
		i : integer;
	begin
		//increase level first, if necessary, so the player gets
		//maximum points
		data.rowsToNextLevel := data.rowsToNextLevel - numRows;
		while data.rowsToNextLevel < 0 do
		begin
			//increase level
			data.level := data.level + 1;
			//update level display
			updateLevelDisplay(data);
			
			//increase drop speed
			data.dropTime := math.max(TETROMINO_MIN_DROP_TIME,
				round(data.dropTime * TETROMINO_DROP_TIME_FACTOR));
			
			//reset row counter
			data.rowsToNextLevel := data.rowsToNextLevel +
				ROWS_PER_LEVEL;
		end;
		//base score: c * numRows
		deltaScore := UGameplayConstants.SCORE_PER_ROW * numRows;
		//extra score for each row > 1
		for i := 2 to numRows do
		begin
			deltaScore := round(deltaScore*SCORE_ROW_MULTIPLIER);
		end;
		//extra score for each level > 1
		for i := 2 to data.level do
		begin
			deltaScore := round(deltaScore*SCORE_LEVEL_MULTIPLIER);
		end;
		//prevent overflow - who knows how long the player survives...
		if not willSumOverflow(data.score, deltaScore) then
		begin
			//add additional score
			data.score := data.score + deltaScore;
			//update display
			updateScoreDisplay(data);
		end;
	end;
	
	(* @brief Called, when the current Tetromino has been moved.
	 *        Checks whether it's hit the floor and handles that. *)
	procedure onTetrominoMoved(var data : TGameData);
	var
		affectedRows : TRowIndexSet;
		procedure removeFullRows();
		var
			curRowIndex, numDeletedRows : integer;
		begin
			//check if any of the affected rows are now full.
			//since sets are ordered the check is from low to high,
			//i.e. top to bottom, thus the remaining indices stay
			//correct when we delete a row.
			numDeletedRows := 0;
			for curRowIndex in affectedRows do
			begin
				//is this row now full?
				if UGamefieldRow.isFull(
					data.gamefield.rows[curRowIndex])
					then
					begin
						//delete it and increase count
						UGamefield.removeRow(data.gamefield,
							curRowIndex);
						numDeletedRows := numDeletedRows + 1;
					end;
			end;
			//if any rows were deleted, award the score accordingly.
			if numDeletedRows > 0 then
			begin
				onRowsDeleted(data, numDeletedRows);
			end;
		end;
	begin
		//have we hit the floor?
		if UGamefield.doesTetrominoTouchFloor(data.gamefield,
			data.currentTetromino) then
		begin
			//put it into the gamefield
			UGamefield.placeTetromino(data.gamefield,
				data.currentTetromino);
			//save the rows that were affected
			affectedRows := UTetromino.getOccupiedRows(
				data.currentTetromino);
			//make next tetromino current and create a new next
			data.currentTetromino := data.nextTetromino;
			UTetromino.init(data.nextTetromino);
			//update display for next tetromino
			updateTetrominoPreview(data);
			
			removeFullRows();
			
			//draw the new current Tetromino
			UTetromino.drawWithOffset(data.currentTetromino,
				data.gamefieldPosition);
			//does it not fit? GAME OVER!
			if not UGamefield.doesTetrominoFit(data.gamefield,
				data.currentTetromino) then
			begin
				data.currentState := stateGameOver;
			end
			else
			begin
				//Tetromino might start touching the floor, so let's
				//do another check.
				onTetrominoMoved(data);
			end;
		end;
	end;
	
	(* @brief Moves the current Tetromino, clears its old position
	 *        and redraws it at the new one. Checks whether any more
	 *        actions need to be taken. *)
	procedure moveCurrentTetromino(var data : TGameData ;
		amount : TVector2i);
	begin
		UTetromino.clearWithOffset(data.currentTetromino,
			data.gamefieldPosition);
		UTetromino.move(data.currentTetromino, amount);
		UTetromino.drawWithOffset(data.currentTetromino,
			data.gamefieldPosition);
		onTetrominoMoved(data);
		//move cursor back to 1, 1 where the user shouldn't mind it
		gotoxy(1, 1);
	end;
	
	(* @brief Rotates the current Tetromino, clears its old position
	 *        and redraws it at the new one. Checks whether any more
	 *        actions need to be taken. *)
	procedure rotateCurrentTetromino(var data : TGameData);
	begin
		UTetromino.clearWithOffset(data.currentTetromino,
			data.gamefieldPosition);
		UTetromino.rotate90DegCCW(data.currentTetromino);
		UTetromino.drawWithOffset(data.currentTetromino,
			data.gamefieldPosition);
		onTetrominoMoved(data);
		//move cursor back to 1, 1 where the user shouldn't mind it
		gotoxy(1, 1);
	end;
	
	(* @brief Tries to move the falling tetromino 'amount' to the
	 *        right
	 *)
	procedure tryHorizontalTetrominoMove(var data : TGameData ;
		amount : integer);
	var
		temp : TTetromino;
	begin
		//move a copy and see if that worked
		temp := data.currentTetromino;
		UTetromino.move(temp, UVector2i.new(amount, 0));
		if UGamefield.doesTetrominoFit(data.gamefield, temp) then
		begin
			//it worked, so let's do it.
			moveCurrentTetromino(data, UVector2i.new(amount, 0));
		end;
		//if it didn't work, ignore.
	end;
	
	(* @brief Tries to rotate the falling tetromino 90 degrees ccw
	 *)
	procedure tryTetrominoRotation(var data : TGameData);
	var
		temp : TTetromino;
	begin
		//rotate a copy and see if that worked
		temp := data.currentTetromino;
		UTetromino.rotate90DegCCW(temp);
		if UGamefield.doesTetrominoFit(data.gamefield, temp) then
		begin
			//it worked, so let's do it.
			rotateCurrentTetromino(data);
		end;
		//if it didn't work, ignore.
	end;
	
	(* @brief Reads the pressed keys and handles them, i.e. calls
	 *        the correct procedures etc.
	 *)
	procedure processInput(var data : TGameData);
	var
		key : char;
	begin
		while keyPressed() do
		begin
			key := crt.readKey();
			case key of
			//extended key
				#0:
				begin
					//so we need to read again
					key := readKey();
					case key of
						//move left
						EXT_KEY_LEFT:
							tryHorizontalTetrominoMove(data, -1);
						//move right
						EXT_KEY_RIGHT:
							tryHorizontalTetrominoMove(data, 1);
						//move down
						EXT_KEY_DOWN:
							moveCurrentTetromino(data,
								UVector2i.new(0, 1));
						//rotate
						EXT_KEY_UP:
							tryTetrominoRotation(data);
					end;
				end;
			//Quit
			KEY_ESCAPE:
				data.currentState := stateMainMenu;
			end;
			
		end;
	end;
	
	procedure advanceGame(var data : TGameData);
	var
		frameTime, deltaT : longint;
	begin
		frameTime := UTime.getMillisecondsSinceMidnight();
		deltaT := UTime.getDifference(frameTime, data.lastFrameTime);
		data.lastFrameTime := frameTime;
		
		data.timeToNextDrop := data.timeToNextDrop - deltaT;
		//is it time to drop the tetromino further?
		//since this may happen multiple times (if deltaT is big),
		//we need to check if the game's been lost, too.
		while (data.timeToNextDrop <= 0) and
			(data.currentState = stateIngame) do
		begin
			//yes! Drop the Tetromino.
			moveCurrentTetromino(data, UVector2i.new(0, 1));
			//set the time to the next drop.
			//(do it after moving since drop time might've chagned)
			data.timeToNextDrop := data.timeToNextDrop + data.dropTime;
		end;
	end;
	
	function main(var sharedData : TSharedData) : TGameState;
	var
		data : TGameData;
	begin
		//initialization
		init(data);
		//clear screen
		clrscr();
		//draw the static content - due to its being static this only
		//needs to be done once.
		drawStaticContent(data);
		//the tetromino preview, score & level only update when it
		//changes so we manually call the display functions once for our
		//initial display.
		updateTetrominoPreview(data);
		updateScoreDisplay(data);
		updateLevelDisplay(data);
		//draw the first tetrominon
		UTetromino.drawWithOffset(data.currentTetromino,
			data.gamefieldPosition);
		//move cursor back to 1, 1 where the user shouldn't mind it
		gotoxy(1, 1);
		
		while data.currentState = stateIngame do
		begin
			processInput(data);
			advanceGame(data);
		end;
		
		//save score and level for Game Over screen
		sharedData.lastScore := data.score;
		sharedData.lastLevel := data.level;
		//set new state
		main := data.currentState;
	end;
	
	begin
	end.
