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
	uses UMenuPart, UVector2i, UMenuLine;
	
	type
		(* @brief Represents a menu with a header/title and a 
		 *        body/content area.
		 * 
		 * It is centered on the screen and does not change after
		 * creation. The text in it may be centered and the menu will
		 * be big enough to make all members fit in.
		 * 
		 * @note Members starting with an underscore should be
		 *       considered an implementation detail and are subject to
		 *       change. Use the functions and methods in this file to
		 *       interact with them.
		 *)
		TMenu = record
			(* "private" members *)
			_head, _body : TMenuPart;
			_position : TVector2i; //doesn't change -> cache it
			_width : integer; //doesn't change -> cache it
		end;
	
	(* @brief Initializes the Menu. Call this first!
	 * 
	 * @param headerLines The lines that should be displayed in the
	 *                    head area.
	 * @param bodyLines The lines that should be displayed in the body
	 *                  area.
	 *)
	procedure init(var self : TMenu; headerLines, bodyLines : array of
	               TMenuLine);
	
	(* @brief Clears the console and draws the Menu.
	 *)
	procedure draw(var self : TMenu);

implementation

	uses
		math, //for max()
		UGeneralConstants, //screen size
		crt; //screen clearing

	procedure init(var self : TMenu; headerLines, bodyLines : array of
	               TMenuLine);
	begin
		UMenuPart.init(self._body, bodyLines);
		UMenuPart.init(self._head, headerLines);
		self._width := math.max(UMenuPart.getSize(self._head).x,
		                        UMenuPart.getSize(self._body).x);
		//the console's coordinate system starts at 1, 1, hence the +1s
		//make it centered, but make sure it's in the printable space!
		self._position.x := math.max(1, round((SCREEN_WIDTH - 
		                                       self._width) / 2)+1);
		//Body and Head overlap partially, hence -1.
		self._position.y := math.max(1, trunc((SCREEN_HEIGHT -
			(UMenuPart.getSize(self._head).y +
			UMenuPart.getSize(self._body).y - 1)) / 2)+1);
	end;
	
	
	
	procedure draw(var self : TMenu);
	begin
		//clear screen
		clrscr;
		//draw head
		UMenuPart.draw(self._head, self._position, self._width);
		//draw body at correct offset - none at X, obviously, while Y
		//is offset by the head's height - 1 (for overlap)
		UMenuPart.draw(self._body, self._position + 
			UVector2i.new(0, UMenuPart.getSize(self._head).y - 1),
			self._width);
	end;
	
	begin
	end.
