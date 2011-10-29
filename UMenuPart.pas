(* @file UMenuPart.pas
 * @author Willi Schinmeyer
 * @date 2011-10-28
 * 
 * UMenuPart Unit
 * 
 * Contains the TMenuPart type and functions/procedures operating on it
 * and the TMenuLine type.
 *)

unit UMenuPart;

interface
	uses UVector2i, UMenuLine;
	
	type
		
		(* @brief A part of a menu, enclosed in borders.
		 * 
		 * My menus consist of two parts which are conceptually similar,
		 * hence this generalization to prevent duplicate code.
		 * 
		 * The borders are 1 char wide/high, and there's 1 char padding
		 * at every size. So the size is 4 wider than the longest line
		 * and 4 higher than the number of lines.
		 *)
		TMenuPart = record
			(* "private" members *)
			_lines : array of TMenuLine;
			_size : TVector2i; //size doesn't change -> cache it.
		end;
		
		(* @brief Initializes the Menu Part.
		 * 
		 * Called by UMenu.init()
		 *)
		procedure init(var self : TMenuPart; lines: array of TMenuLine);
		
		(* @brief Draws the Menu Part at the given position with the
		 *        given width (since all parts should be equally wide)
		 *)
		procedure draw(var self : TMenuPart; position : TVector2i;
	                   width : integer);
		
		(* @brief Returns the size of the Menu Part (in characters)
		 *)
		function getSize(var self : TMenuPart) : TVector2i;

implementation

	uses UHelpers, crt;

	const
		//how far away from the borders the text is
		PADDING : integer = 1;



	procedure init(var self : TMenuPart; lines : array of TMenuLine);
	var
		numLines, i : integer;
		//default value for longest line is 0 (in case there are none).
		maxLineLength : integer = 0;
	begin
		//set array size
		numLines := high(lines) - low(lines) + 1;
		setLength(self._lines, numLines);
		//copy the values, check longest line
		for i := 0 to numLines - 1 do
		begin
			self._lines[i] := lines[i + low(lines)];
			//longest line (so far)?
			if length(self._lines[i].text) > maxLineLength then
			begin
				maxLineLength := length(self._lines[i].text);
			end;
		end;
		//calculate size
		self._size.x := maxLineLength + 2 * (PADDING + BORDER_SIZE);
		self._size.y := numLines + 2 * (PADDING + BORDER_SIZE);
	end;
	
	
	
	procedure draw(var self : TMenuPart; position : TVector2i; width :
	               integer);
	var
		currentIndex, posX, posY : integer;
	begin
		//draw borders
		UHelpers.drawRectangleBorders(position, position + 
			UVector2i.new(width - 1, self._size.y -1));
		//draw lines
		for currentIndex := 0 to high(self._lines) do
		begin
			//calculate position
			posY := position.y + PADDING + BORDER_SIZE + currentIndex;
			//X Position depends on whether it's centered or not.
			if self._lines[currentIndex].centered then
			begin //it's centered
				//padding and border are on both sides, thus irrelevant
				posX := position.x + trunc((width - length(
				        self._lines[currentIndex].text)) / 2);
			end
			else //not centered
			begin
				posX := position.x + PADDING + BORDER_SIZE;
			end;
			gotoxy(posX, posY);
			write(self._lines[currentIndex].text);
		end;
	end;
	
	
	
	function getSize(var self : TMenuPart) : TVector2i;
	begin
		getSize := self._size;
	end;
	
	
	
	begin
	end.
