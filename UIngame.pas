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
		MAX_DISPLAY_SCORE = 99999;
		SCORE_STRING  = 'score: ';
		MAX_DISPLAY_LEVEL = 999;
		LEVEL_STRING = 'level: ';
		//length of string (7) + maximum number of digits (5)
		INFOBOX_WIDTH = 12;
		//level and score - two lines.
		INFOBOX_HEIGHT = 2;

	function main(var sharedData : TSharedData) : TGameState;
	var
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
		score : integer = 0;
		//player's current level
		level : integer = 1;
		//rows the player still has to remove to advance a level
		rowsToNextLevel : integer;
		//the time the last frame took place
		lastFrameTime : longint;
		//time until the current tetromino falls another block down
		timeToNextDrop : integer;
		//interval between tetromino drops (i.e. move 1 cell down),
		//decreases over time.
		dropTime : integer;
		
		(* @brief Initializes everything that needs initializing *)
		procedure init();
		begin
			//calculate gamefield position
			gamefieldPosition.x := round((SCREEN_WIDTH - 
				GAMEFIELD_WIDTH) / 2);
			gamefieldPosition.y := round((SCREEN_HEIGHT -
				GAMEFIELD_HEIGHT) / 2);
			//make sure it's in printable space
			gamefieldPosition.x := math.max(1 + BORDER_SIZE,
				gamefieldPosition.x);
			gamefieldPosition.y := math.max(1 + BORDER_SIZE,
				gamefieldPosition.y);
			
			//calculate tetromino preview box position
			//it's to the right of the gamefield, with 1 char spacing.
			tetrominoPreviewBoxPosition := gamefieldPosition +
				UVector2i.new(GAMEFIELD_WIDTH + 2*BORDER_SIZE + 1, 0);
			//set tetromino preview box size
			tetrominoPreviewBoxSize.x := TETROMINO_MAX_X -
				TETROMINO_MIN_X + 1;
			tetrominoPreviewBoxSize.y := TETROMINO_MAX_Y -
				TETROMINO_MIN_Y + 1;
			
			//calculate the info box's position
			//it's below the tetromino preview  box, 1 char spacing.
			infoboxPosition := tetrominoPreviewBoxPosition +
				UVector2i.new(0, tetrominoPreviewBoxSize.y +
				2 * BORDER_SIZE + 1);
			
			//initialize gamefield & tetrominoes (includes shape setup)
			UGamefield.init(gamefield, gamefieldPosition);
			UTetromino.init(currentTetromino);
			UTetromino.init(nextTetromino);
			
			lastFrameTime := UTime.getMillisecondsSinceMidnight();
			rowsToNextLevel := UGameplayConstants.ROWS_PER_LEVEL;
			dropTime := UGameplayConstants.TETROMINO_BASE_DROP_TIME;
			timeToNextDrop := dropTime;
		end;
		
		(* @brief Draws the content that doesn't change - the borders,
		 *        above all. *)
		procedure drawStaticContent();
		begin
			//set color to white - better safe than sorry
			crt.textcolor(WHITE);
			//draw gamefield box
			UHelpers.drawRectangleBorders(gamefieldPosition -
				UVector2i.new(1, 1), gamefieldPosition +
				UVector2i.new(GAMEFIELD_WIDTH, GAMEFIELD_HEIGHT));
			//draw tetromino preview box
			UHelpers.drawRectangleBorders(tetrominoPreviewBoxPosition -
				UVector2i.new(1, 1), tetrominoPreviewBoxPosition +
				tetrominoPreviewBoxSize);
			//draw info box
			UHelpers.drawRectangleBorders(infoboxPosition -
				UVector2i.new(1, 1), infoBoxPosition +
				UVector2i.new(INFOBOX_WIDTH, INFOBOX_HEIGHT));
			//draw score and level string (score top, level bottom)
			gotoxy(infoboxPosition.x, infoboxPosition.y);
			write(SCORE_STRING);
			gotoxy(infoboxPosition.x, infoboxPosition.y+1);
			write(LEVEL_STRING);
		end;
		
		(* @brief Updates the displayed next Tetromino, should be called
		 *        when it changes. *)
		procedure updateTetrominoPreview();
			procedure clearPreview();
			var
				i, curY : integer;
			begin
				//for each line:
				for curY := tetrominoPreviewBoxPosition.y to
					tetrominoPreviewBoxPosition.y +
					tetrominoPreviewBoxSize.y - 1 do
				begin
					//clear this line
					gotoxy(tetrominoPreviewBoxPosition.x, curY);
					for i := 1 to tetrominoPreviewBoxSize.x do
					begin
						write(' ');
					end;
				end;
			end;
			procedure drawPreview();
			var
				curPos : TVector2i;
			begin
				crt.textcolor(nextTetromino.color);
				for curPos in nextTetromino.shape do
				begin
					//offset enough so (0, 0) is new minimum
					curPos := curPos - UVector2i.new(TETROMINO_MIN_X,
						TETROMINO_MIN_Y);
					//put at correct location at screen
					curPos := curPos + tetrominoPreviewBoxPosition;
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
		procedure updateScoreDisplay();
		begin
			//no clearing necessary since score only gets higher, thus
			//overwrites.
			crt.textcolor(WHITE);
			gotoxy(infoboxPosition.x + length(SCORE_STRING),
				infoboxPosition.y);
			write(score);
		end;
		
		(* @brief Updates the displayed current level, should be called
		 *        when it changes. *)
		procedure updateLevelDisplay();
		begin
			//no clearing necessary since level only gets higher, thus
			//overwrites.
			crt.textcolor(WHITE);
			gotoxy(infoboxPosition.x + length(LEVEL_STRING),
				infoboxPosition.y + 1);
			write(level);
		end;
		
		(* @brief Called when 1 or more rows have been deleted.
		 *        Calculates & applies score & level changes and other
		 *        consequences.
		 *)
		procedure onRowsDeleted(numRows : integer);
		var
			//by how much the score will increase
			deltaScore,
			i : integer;
		begin
			//increase level first, if necessary, so the player gets
			//maximum points
			rowsToNextLevel := rowsToNextLevel - numRows;
			while rowsToNextLevel < 0 do
			begin
				//increase level
				level := level + 1;
				//update level display
				updateLevelDisplay();
				
				//increase drop speed
				dropTime := math.max(TETROMINO_MIN_DROP_TIME,
					round(dropTime * TETROMINO_DROP_TIME_FACTOR));
				
				//reset row counter
				rowsToNextLevel := rowsToNextLevel + ROWS_PER_LEVEL;
			end;
			//base score: c * numRows
			deltaScore := UGameplayConstants.SCORE_PER_ROW * numRows;
			//extra score for each row > 1
			for i := 2 to numRows do
			begin
				deltaScore := round(deltaScore*SCORE_ROW_MULTIPLIER);
			end;
			//extra score for each level > 1
			for i := 2 to level do
			begin
				deltaScore := round(deltaScore*SCORE_LEVEL_MULTIPLIER);
			end;
			//add additional score
			score := score + deltaScore;
			//update display
			updateScoreDisplay();
		end;
		
		(* @brief Called, when the current Tetromino has been moved.
		 *        Checks whether it's hit the floor and handles that. *)
		procedure onTetrominoMoved();
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
					if UGamefieldRow.isFull(gamefield.rows[curRowIndex])
						then
						begin
							//delete it and increase count
							UGamefield.removeRow(gamefield,
								curRowIndex);
							numDeletedRows := numDeletedRows + 1;
						end;
				end;
				//if any rows were deleted, award the score accordingly.
				if numDeletedRows > 0 then
				begin
					onRowsDeleted(numDeletedRows);
				end;
			end;
		begin
			//have we hit the floor?
			if UGamefield.doesTetrominoTouchFloor(gamefield,
				currentTetromino) then
			begin
				//put it into the gamefield
				UGamefield.placeTetromino(gamefield, currentTetromino);
				//save the rows that were affected
				affectedRows := UTetromino.getOccupiedRows(
					currentTetromino);
				//make next tetromino current and create a new next
				currentTetromino := nextTetromino;
				UTetromino.init(nextTetromino);
				//update display for next tetromino
				updateTetrominoPreview();
				
				removeFullRows();
				
				//draw the new current Tetromino
				UTetromino.drawWithOffset(currentTetromino,
					gamefieldPosition);
				//does it not fit? GAME OVER!
				if not UGamefield.doesTetrominoFit(gamefield,
					currentTetromino) then
				begin
					main := stateGameOver;
				end
				else
				begin
					//Tetromino might start touching the floor, so let's
					//do another check.
					onTetrominoMoved();
				end;
			end;
		end;
		
		(* @brief Moves the current Tetromino, clears its old position
		 *        and redraws it at the new one. Checks whether any more
		 *        actions need to be taken. *)
		procedure moveCurrentTetromino(amount : TVector2i);
		begin
			UTetromino.clearWithOffset(currentTetromino,
				gamefieldPosition);
			UTetromino.move(currentTetromino, amount);
			UTetromino.drawWithOffset(currentTetromino,
				gamefieldPosition);
			onTetrominoMoved();
			//move cursor back to 1, 1 where the user shouldn't mind it
			gotoxy(1, 1);
		end;
		
		(* @brief Rotates the current Tetromino, clears its old position
		 *        and redraws it at the new one. Checks whether any more
		 *        actions need to be taken. *)
		procedure rotateCurrentTetromino();
		begin
			UTetromino.clearWithOffset(currentTetromino,
				gamefieldPosition);
			UTetromino.rotate90DegCCW(currentTetromino);
			UTetromino.drawWithOffset(currentTetromino,
				gamefieldPosition);
			onTetrominoMoved();
			//move cursor back to 1, 1 where the user shouldn't mind it
			gotoxy(1, 1);
		end;
		
		(* @brief Tries to move the falling tetromino 'amount' to the
		 *        right
		 *)
		procedure tryHorizontalTetrominoMove(amount : integer);
		var
			temp : TTetromino;
		begin
			//move a copy and see if that worked
			temp := currentTetromino;
			UTetromino.move(temp, UVector2i.new(amount, 0));
			if UGamefield.doesTetrominoFit(gamefield, temp) then
			begin
				//it worked, so let's do it.
				moveCurrentTetromino(UVector2i.new(amount, 0));
			end;
			//if it didn't work, ignore.
		end;
		
		(* @brief Tries to rotate the falling tetromino 90 degrees ccw
		 *)
		procedure tryTetrominoRotation();
		var
			temp : TTetromino;
		begin
			//rotate a copy and see if that worked
			temp := currentTetromino;
			UTetromino.rotate90DegCCW(temp);
			if UGamefield.doesTetrominoFit(gamefield, temp) then
			begin
				//it worked, so let's do it.
				rotateCurrentTetromino();
			end;
			//if it didn't work, ignore.
		end;
		
		(* @brief Reads the pressed keys and handles them, i.e. calls
		 *        the correct procedures etc.
		 *)
		procedure processInput();
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
								tryHorizontalTetrominoMove(-1);
							//move right
							EXT_KEY_RIGHT:
								tryHorizontalTetrominoMove(1);
							//move down
							EXT_KEY_DOWN:
								moveCurrentTetromino(
									UVector2i.new(0, 1));
							//rotate
							EXT_KEY_UP:
								tryTetrominoRotation();
						end;
					end;
				//Quit
				KEY_ESCAPE:
					main := stateMainMenu;
				end;
				
			end;
		end;
		
		procedure advanceGame();
		var
			frameTime, deltaT : longint;
		begin
			frameTime := UTime.getMillisecondsSinceMidnight();
			deltaT := UTime.getDifference(frameTime, lastFrameTime);
			lastFrameTime := frameTime;
			
			timeToNextDrop := timeToNextDrop - deltaT;
			//is it time to drop the tetromino further?
			//since this may happen multiple times (if deltaT is big),
			//we need to check if the game's been lost, too.
			while (timeToNextDrop <= 0) and (main = stateIngame) do
			begin
				//yes! Drop the Tetromino.
				moveCurrentTetromino(UVector2i.new(0, 1));
				//set the time to the next drop.
				//(do it after moving since drop time might've chagned)
				timeToNextDrop := timeToNextDrop + dropTime;
			end;
		end;
		
	begin
		//initialization
		init();
		//clear screen
		clrscr();
		//draw the static content - due to its being static this only
		//needs to be done once.
		drawStaticContent();
		//the tetromino preview, score & level only update when it
		//changes so we manually call the display functions once for our
		//initial display.
		updateTetrominoPreview();
		updateScoreDisplay();
		updateLevelDisplay();
		//draw the first tetrominon
		UTetromino.drawWithOffset(currentTetromino, gamefieldPosition);
		//move cursor back to 1, 1 where the user shouldn't mind it
		gotoxy(1, 1);
		
		main := stateIngame;
		while main = stateIngame do
		begin
			processInput();
			advanceGame();
		end;
		
		//save score and level for Game Over screen
		sharedData.lastScore := score;
		sharedData.lastLevel := level;
	end;
	
	begin
	end.
