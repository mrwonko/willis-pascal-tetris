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
		UTetromino, //TTetromino
		UVector2i, //TVector2i
		UGameplayConstants, //gamefield size
		UGeneralConstants, //screen size
		crt, //display stuff
		math, //max()
		UHelpers, //border drawing
		UKeyConstants; //codes of the keys (e.g. arrow keys)
	
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
		
		(* @brief Initializes everything that needs initializing
		 *)
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
		end;
		
		(* @brief Draws the content that doesn't change - the borders.
		 *)
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
		
		procedure updateScoreDisplay();
		begin
			//no clearing necessary since score only gets higher, thus
			//overwrites.
			crt.textcolor(WHITE);
			gotoxy(infoboxPosition.x + length(SCORE_STRING),
				infoboxPosition.y);
			write(score);
		end;
		
		procedure updateLevelDisplay();
		begin
			//no clearing necessary since level only gets higher, thus
			//overwrites.
			crt.textcolor(WHITE);
			gotoxy(infoboxPosition.x + length(LEVEL_STRING),
				infoboxPosition.y + 1);
			write(level);
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
		
		main := stateIngame;
		while main = stateIngame do
		begin
			processInput();
			advanceGame();
		end;
	end;
	
	begin
	end.
