(* @file UGamefield.pas
 * @author Willi Schinmeyer
 * @date 2011-10-28
 * 
 * UGamefield unit
 * 
 * Contains the TGamefield, TGamefieldRow and TGamefieldCell type and
 * procedures/functions operating on them.
 *)

unit UGamefield;

interface
	uses
		UTetromino,
		UGameplayConstants, //Fieldsize, char for displaying tetrominos
		UVector2i,
		UGamefieldRow;
	
	type
		
		TGamefield = record
			//19 = GAMEFIELD_HEIGHT - 1
			//cannot be set from expression, again :(
			rows : array[0..19] of TGamefieldRow;
			//offset of the gamefield on the screen
			offset : TVector2i;
		end;
	
	(* @brief Initializes the Gamefield.
	 *)
	procedure init(var self : TGamefield; offset : TVector2i);
	
	(* @brief Removes the given row from the cells of the Gamefield,
	 *        making those above it "fall down". Redraws as well.
	 * 
	 * @note Assumes row 0 cell 0 = (1, 1) on the screen.
	 *)
	procedure removeRow(var self : TGamefield; rowIndex : integer);
	
	(* @brief Returns whether the given Tetromino would be completely in
	 *        empty cells.
	 *)
	function doesTetrominoFit(var self : TGamefield; tet : TTetromino) :
		boolean;
	
	(* @brief Returns whether the given Tetromino touches the floor
	 *        (i.e. dropped Tetrominos or the actual bottom)
	 *)
	function doesTetrominoTouchFloor(var self : TGamefield;
		tet : TTetromino) : boolean;
	
	(* @brief Places the given Tetromino in the Gamefield and draws it.
	 * 
	 * @note It is assumed that the Tetromino fits, i.e. indices aren't
	 *       out of bounds. There's no check!
	 * @note Assumes row 0 cell 0 = (1, 1) on the screen.
	 *)
	procedure placeTetromino(var self : TGamefield; tet : TTetromino);
	
implementation

	uses
		crt, //drawing
		UDisplayConstants; //Tetromino display


	procedure init(var self : TGamefield; offset : TVector2i);
	var
		curRowIndex, curCellIndex : integer;
	begin
		self.offset := offset;
		for curRowIndex := low(self.rows) to high(self.rows) do
		begin
			for curCellIndex := low(self.rows[curRowIndex].cells) to
				high(self.rows[curRowIndex].cells) do
			begin
				self.rows[curRowIndex].cells[curCellIndex].occupied :=
					false;
			end;
		end;
	end;
	
	
	procedure removeRow(var self : TGamefield; rowIndex : integer);
		//helper functions to make code cleaner
		procedure emptyTopRow();
		var
			curCellIndex : integer;
		begin;
			//set all the cells in the topmost row to empty
			for curCellIndex := low(self.rows[0].cells) to
				high(self.rows[0].cells) do
			begin
				//erase if necessary
				if self.rows[0].cells[curCellIndex].occupied then
				begin
					gotoxy(self.offset.x + 1 + curCellIndex,
						self.offset.y + 1);
					write(CELL_EMPTY_CHAR);
				end;
				self.rows[0].cells[curCellIndex].occupied := false;
			end;
		end;
		
		procedure moveNextRowDown(curRowIndex : integer);
		var
			curCellIndex : integer;
			oldCell, newCell : TGamefieldCell;
		begin
			//do the drawing...
			for curCellIndex := low(self.rows[curRowIndex].cells) to
				high(self.rows[curRowIndex].cells) do
			begin
				//previous state of this cell
				oldCell := self.rows[curRowIndex].cells[curCellIndex];
				//new state for this cell
				newCell := self.rows[curRowIndex-1].cells[curCellIndex];
				//redraw, if necessary - i.e. either:
				   //not the same occupied state as before
				if (oldCell.occupied <> newCell.occupied) or
				   //or the color changed in an occupied cell
				   ((oldCell.color <> newCell.color) and oldCell.occupied)
				   then
				begin
					//rows/cells start at 0, screen coordinates at 1
					gotoxy(self.offset.x + curRowIndex + 1, 
						self.offset.y + curCellIndex + 1);
					
					if newCell.occupied then
					begin
						textcolor(newCell.color);
						write(CELL_OCCUPIED_CHAR);
					end
					else
					begin
						//now empty
						write(CELL_EMPTY_CHAR);
					end
				end;
			end;
			//and copy the values
			self.rows[curRowIndex] := self.rows[curRowIndex-1];
		end;
	var
		curRowIndex : integer;
	begin
		//move all rows 1 down, starting with rowIndex (bottom to top)
		curRowIndex := rowIndex;
		while curRowIndex > 0 do
		begin
			moveNextRowDown(curRowIndex);
			curRowIndex := curRowIndex - 1;
		end;
		emptyTopRow();
	end;
	
	function doesTetrominoFit(var self : TGamefield; tet : TTetromino) :
		boolean;
	var
		//position to be checked for occupiedness
		pos : TVector2i;
	begin
		//I check whether it doesn't fit, so if none of my checks
		//succeeds, it fits. Thus that's the default value.
		doesTetrominoFit := true;
		
		for pos in tet.shape do
		begin	
			pos := pos + tet.position;
			//Is the position outside the gamefield? -> doesn't fit.
			if (pos.y > (GAMEFIELD_HEIGHT - 1)) or
		       (pos.y < 0) or
		       (pos.x > (GAMEFIELD_WIDTH - 1)) or
		       (pos.x < 0) then
		    begin
				doesTetrominoFit := false;
				//break would be nice here... alas I don't have it.
			end
			else
			begin
				//Inside the gamefield, but already occupied?
				if self.rows[pos.y].cells[pos.x].occupied then
				begin
					doesTetrominoFit := false;
					//break would be nice here... I still don't have it.
				end;
			end;
		end;
	end;
	
	function doesTetrominoTouchFloor(var self : TGamefield;
		tet : TTetromino) : boolean;
	var
		temp : TTetromino;
	begin
		//copy tetromino
		temp := tet;
		//move it down
		temp.position.y := temp.position.y + 1;
		//if it doesn't fit there, there must be floor.
		doesTetrominoTouchFloor := not doesTetrominoFit(self, temp);
	end;
	
	procedure placeTetromino(var self : TGamefield; tet : TTetromino);
	var
		pos : TVector2i;
	begin
		//set text color - only do it once
		textcolor(tet.color);
		//place each part of the shape...
		for pos in tet.shape do
		begin
			//...offset by its position, of course.
			pos := pos + tet.position;
			//note: no bounds check! Since this procedure is only called
			//if doesTetrominoFit() returns true, that's no problem.
			self.rows[pos.y].cells[pos.x].occupied := true;
			self.rows[pos.y].cells[pos.x].color := tet.color;
			//draw it
			gotoxy(self.offset.x+ pos.x + 1, self.offset.y + pos.y + 1);
			write(CELL_OCCUPIED_CHAR);
		end;
	end;

	begin
	end.
