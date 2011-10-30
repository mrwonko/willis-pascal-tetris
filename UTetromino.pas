(* @file UTetromino.pas
 * @author Willi Schinmeyer
 * @date 2011-10-29
 * 
 * UTetromino Unit
 * 
 * Contains the TTetronimo type and funcions/procedures operating on it.
 *)

unit UTetromino;

interface
	uses
		UVector2i, //vectors, obviously
		UTetrominoShape, //TTetrominoShape
		UGeneralTypes; //TRowIndexSet
	
	type
		TTetromino = record
			shape : TTetrominoShape;
			position : TVector2i;
			color : byte;
		end;
	
	(* @brief Initializes the Tetromino with a random shape & color.
	 * 
	 * It will be moved so the highest part is at x = 1 and it's in the
	 * middle of the gamefield.
	 *)
	procedure init(var self : TTetromino);
	
	(* @brief Rotates the Tetromino 90° counter-clockwise.
	 *)
	procedure rotateCCW(var self : TTetromino);
	
	(* @brief Moves the Tetromino a given offset.
	 *)
	procedure move(var self : TTetromino; offset : TVector2i);
	
	(* @brief Rotates the Tetromino 90 degrees counterclockwise
	 *)
	procedure rotate90DegCCW(var self : TTetromino);
	
	(* @brief Returns the rows this Tetromino occupies.
	 *)
	function getOccupiedRows(var self : TTetromino) : TRowIndexSet;
	
	(* @brief Draws the Tetromino centered at the given position.
	 * 
	 * @note Used to draw the Preview.
	 *)
	procedure drawIgnoringPosition(var self : TTetromino; position : 
		TVector2i);
	
	(* @brief Draws the Tetromino at its current position with offset.
	 * 
	 * @note Used to draw the currently falling Tetromino, in which case
	 *       offset is the gamefield's absolute position
	 *)
	procedure drawWithOffset(var self: TTetromino; offset : TVector2i);
	
	(* @brief Clears the Tetromino's current position with offset.
	 * 
	 * @note Used to clear the currently falling Tetromino, in which
	 *       case offset is the gamefield's absolute position
	 *)
	procedure clearWithOffset(var self: TTetromino; offset : TVector2i);

implementation

	uses
		UGameplayConstants, //gamefield size
		UDisplayConstants, //gamefield size
		UHelpers, //Random Color & Shape generation
		crt;
	
	procedure init(var self : TTetromino);
	var
		minY : integer = 9999; //no shape should be this tall
		pos : TVector2i;
	begin
		//choose a random color
		self.color := getRandomTetrominoColor();
		//choose a random shape
		self.shape := getRandomTetrominoShape();
		for pos in self.shape do
			if (pos.y < minY) then
				minY := pos.y;
		//set Y position so the highest part is at 0.
		self.position.y := - minY;
		//center X position
		self.position.x := round(GAMEFIELD_WIDTH / 2);
	end;
	
	procedure rotateCCW(var self : TTetromino);
	var
		i : integer;
	begin
		//rotate each part of the shape, thus rotating the whole thing
		//"for pos in self.shape do" doesn't work since pos is a copy(?)
		for i := low(self.shape) to high(self.shape) do
		begin
			UVector2i.rotate90DegCCW(self.shape[i]);
		end;
	end;
	
	procedure move(var self : TTetromino; offset : TVector2i);
	begin
		self.position := self.position + offset;
	end;
	
	procedure rotate90DegCCW(var self : TTetromino);
	var
		i : integer;
	begin
		for i := low(self.shape) to high(self.shape) do
		begin
			UVector2i.rotate90DegCCW(self.shape[i]);
		end;
	end;
	
	function getOccupiedRows(var self : TTetromino) : TRowIndexSet;
	var
		pos : TVector2i;
	begin
		//initialize as empty set
		getOccupiedRows := [];
		//insert all rows - no need to care about duplicate insertions
		//or order, values in sets are unique & ordered (order doesn't
		//matter anyway...)
		for pos in self.shape do
			getOccupiedRows := getOccupiedRows +
				[pos.y + self.position.y];
	end;
	
	
	procedure drawIgnoringPosition(var self : TTetromino; position : 
		TVector2i);
	var
		curPos : TVector2i;
	begin
		crt.textcolor(self.color);
		for curPos in self.shape do
		begin
			curPos := curPos + position;
			gotoxy(curPos.x, curPos.y);
			write(CELL_OCCUPIED_CHAR);
		end;
	end;
	
	
	procedure drawWithOffset(var self: TTetromino; offset : TVector2i);
	begin
		drawIgnoringPosition(self, self.position + offset);
	end;
	
	procedure clearWithOffset(var self: TTetromino; offset : TVector2i);
	var
		curPos : TVector2i;
	begin
		for curPos in self.shape do
		begin
			curPos := curPos + offset + self.position;
			gotoxy(curPos.x, curPos.y);
			write(CELL_EMPTY_CHAR);
		end;
	end;
	
	
	begin
	end.
