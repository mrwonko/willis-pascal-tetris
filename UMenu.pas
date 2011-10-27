(* @file UMenu.pas
 * @author Willi Schinmeyer
 * @date 2011-10-27
 * 
 * UMenu Unit
 * 
 * This unit contains the TMenu type and functions/procedures operating
 * on it.
 *)

unit UMenu;

interface
	type
		(* @brief Represents a line of text in a menu title or body.
		 * 
		 * It can be centered.
		 *)
		TMenuLine = record
			text : string;
			centered : boolean;
		end;
		(* @brief Represents a menu with a header/title and a 
		 *        body/content area.
		 * 
		 * @note Members starting with an underscore should be
		 *       considered an implementation detail and are subject to
		 *       change. Use the functions and methods in this file to
		 *       interact with them.
		 * 
		 * @todo Head/Body are conceptually similar so I should create a
		 *       new class for them. I'll need to think of some way of
		 *       sharing the maximum line length but I'll figure it out.
		 *)
		TMenu = record
			(* "private" members *)
			_headerLines : array of TMenuLine;
			_bodyLines : array of TMenuLine;
			_maxLineLength : integer;
			_minWidth : integer;
			_padding : integer;
		end;
	
	(* @brief Initializes the Menu. Call this first! *)
	procedure init(var self : TMenu);
	
	(* @brief Changes how much space there is around the text. Defaults
	 *        to 1. Optionally redraws the menu with new padding.
	 * @note May clear!
	 *)
	procedure setPadding(var self : TMenu; padding : integer;
	                     redraw : boolean);
	
	(* @brief Sets a minimum width. Defaults to 0, i.e. as wide as
	 *        necessary. Optionally redraws the menu if necessary.
	 * @note May clear!
	 *)
	procedure setMinWidth(var self : TMenu; minWidth : integer;
	                      redraw: boolean);
	
	(* @brief Returns the number of lines in the header *)
	function numHeaderLines(var self : TMenu) : integer;
	
	(* @brief Returns the number of lines in the body *)
	function numBodyLines(var self : TMenu) : integer;
	
	(* @brief Sets the lines in the header and optionally redraws them.
	 * @note May clear! (If the maximum line length is different and
	 *       minWidth makes it necessary or the number of lines changed)
	 *)
	procedure setHeaderLines(var self : TMenu; var lines : array of
	                         TMenuLine; redraw : boolean);
	
	(* @brief Sets the lines in the body and optionally redraws them.
	 * @note May clear! (If the maximum line length is different and
	 *       minWidth makes it necessary or the number of lines changed)
	 *)
	procedure setBodyLines(var self : TMenu; var lines : array of
	                         TMenuLine; redraw : boolean);
	
	(* @brief Changes a given line in the header and optionally redraws
	 *        it.
	 * @note Invalid indices are silently ignored.
	 * @note If the maximum line length has changed and redraw is true,
	 *       the whole menu is redrawn.
	 * @note May clear! (If the maximum line length is different and
	 *       minWidth makes it necessary.)
	 *)
	procedure changeHeaderLine(var self : TMenu; index : integer;
	                           line : TMenuLine; redraw : boolean);
	
	(* @brief Changes a given line in the body and optionally redraws
	 *        it.
	 * @note Invalid indices are silently ignored.
	 * @note If the maximum line length has changed and redraw is true,
	 *       the whole menu is redrawn.
	 * @note May clear! (If the maximum line length is different and
	 *       minWidth makes it necessary.)
	 *)
	procedure changeBodyLine(var self : TMenu; index : integer;
	                           line : TMenuLine; redraw : boolean);
	
	(* @brief Draws the Menu to the console.
	 * @note Will clear first!
	 *)
	procedure draw(var self : TMenu);

implementation

	uses UVector2i, crt;
	
	function arrayLength(var lines : array of TMenuLine) : integer;
	begin
		arrayLength := high(lines) - low(lines) + 1;
	end;
	
	function maxLineLength(var lines : array of TMenuLine) : integer;
	var
		i : integer;
	begin
		maxLineLength := 0;
		for i := low(lines) to high(lines) do
		begin
			if length(lines[i].text) > maxLineLength then
				maxLineLength := length(lines[i].text);
		end;
	end;
	
	function maxLineLength(var lines1, lines2 : array of TMenuLine) : 
		integer;
	var
		max1, max2 : integer;
	begin
		max1 := maxLineLength(lines1);
		max2 := maxLineLength(lines2);
		if max1 > max2 then
			maxLineLength := max1
		else
			maxLineLength := max2;
	end;
	
	(* Returns whether a given set of new values makes a redraw
 	 * necessary because the layout changed. *)
	function willRedrawBeNecessary(var self : TMenu; padding, minWidth,
	                               maxLineLength : integer) : boolean;
	var
		//whether the window's width was [/will be] determined by the
		//length of the longest line (as opposed to minWidth)
		lineLengthDominated,
		lineLengthWillDominate : boolean;
	begin
		lineLengthDominated := self._maxLineLength > self._minWidth;
		lineLengthWillDominate := maxLineLength > minWidth;
		
		willRedrawBeNecessary :=
		//padding changes always make a redraw necessary (except if
		//there's only centered text and the minWidth dominates, but
		//I'll ignore that rare case - testing if there's only centered
		//text is too much of a hassle to be worth it imho)
		(padding <> self._padding) or
		//the minimum width only matters if it used to or will decide
		//the actual width
		((minWidth <> self._minWidth) and (
			not lineLengthDominated or not lineLengthWillDominate)) or
		//the same is true for the lineLength
		((maxLineLength <> self._maxLineLength) and (
			lineLengthDominated or lineLengthWillDominate));
	end;
	
	procedure init(var self : TMenu);
	begin
		//since there are no lines yet, the longest line is 0 long.
		self._maxLineLength := 0;
		self._padding := 1;
		self._minWidth := 0;
	end;
	
	procedure setPadding(var self : TMenu; padding : integer;
	                     redraw : boolean);
	var
		redrawNecessary : boolean;
	begin
		//only redraw if the menu's shape changed and the user requested
		//it.
		redrawNecessary := willRedrawBeNecessary(self, padding,
		                   self._minWidth, self._maxLineLength) and 
		                   redraw;
		self._padding := padding;
		if redrawNecessary then
			draw(self);
	end;
	
	procedure setMinWidth(var self : TMenu; minWidth : integer;
	                      redraw: boolean);
	var
		redrawNecessary : boolean;
	begin
		//only redraw if the menu's shape changed and the user requested
		//it.
		redrawNecessary := willRedrawBeNecessary(self, self._padding,
		                   minWidth, self._maxLineLength) and redraw;
		self._minWidth := minWidth;
		if redrawNecessary then
			draw(self);
	end;
	
	function numHeaderLines(var self : TMenu) : integer;
	begin
		//numIndices = maxIndex - minIndex + 1, hence:
		numHeaderLines := arrayLength(self._headerLines);
	end;
	
	function numBodyLines(var self : TMenu) : integer;
	begin
		//numIndices = maxIndex - minIndex + 1, hence:
		numBodyLines := arrayLength(self._bodyLines);
	end;
	
	//this code is quite similar for setBodyLines(), but a lot of
	//variables are switched and the amount of variables for an extra
	//function would be enormous. Should I still create one?
	procedure setHeaderLines(var self : TMenu; var lines : array of
	                         TMenuLine; redraw : boolean);
	var
		redrawNecessary : boolean;
		newMaxLineLength : integer;
		numLinesChanged : boolean;
	begin
		//has the number of lines changed? In that case we'll need a
		//complete redraw later
		numLinesChanged := arrayLength(lines) <>
		                   arrayLength(self._headerLines);
		newMaxLineLength := maxLineLength(self._bodyLines, lines);
		//even if the number of lines has not changed, we may still need
		//a redraw because the maximum line length could've changed.
		redrawNecessary := redraw and willRedrawBeNecessary(self,
		                   self._padding, self._minWidth,
		                   newMaxLineLength);
		//assign the new values
		self._maxLineLength := newMaxLineLength;
		self._headerLines := lines; //o.O
		//did the user allow redraws? (Maybe the menu is not currently
		//being displayed...)
		if redraw then
		begin
			//complete redraw necessary?
			if redrawNecessary or numLineschanged then
				draw(self)
			//otherwise we can get away with only changing the changed
			//lines, which is good because there's no double buffering
			//in the console.
			else
			begin
				//TODO
				//clearHeaderLines(self)
				//drawHeaderLines(self);
			end;
		end;
	end;
	
	procedure setBodyLines(var self : TMenu; var lines : array of 
	                       TMenuLine; redraw : boolean);
	begin
	end;
	
	procedure changeHeaderLine(var self : TMenu; index : integer;
	                           line : TMenuLine; redraw : boolean);
	begin
	end;
	
	procedure changeBodyLine(var self : TMenu; index : integer;
	                           line : TMenuLine; redraw : boolean);
	begin
	end;
	
	procedure draw(var self : TMenu);
	begin
		clrscr;
		//todo: draw
	end;
	
	begin
	end.
