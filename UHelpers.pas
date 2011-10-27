(* @file UWriteHelpers.pas
 * @author Willi Schinmeyer
 * @date 2011-10-27
 * 
 * UWriteHelpers Unit
 * 
 * Contains helper functions/procedures and initializes the random
 * number generation on load.
 *)

unit UHelpers;

interface
	uses UVector2i;

	(*
	 * @brief draws 4 borders, creating a rectangle
	 * 
	 * @param upperLeft Vector of upper left point (X+ = right, Y+ = 
	 * down)
	 * @param lowerRight Vector of lower right point
	 *)
	procedure drawRectangleBorders(upperLeft, lowerRight : 
	                               TVector2i);
	
	(*
	 * @brief Returns one of the colors defined in UGeneralConstants.pas
	 *)
	function getRandomColor() : byte;

implementation

	uses crt, UGeneralConstants;

	procedure drawRectangleBorders(upperLeft, lowerRight : 
	                               TVector2i);
	                               
		(* @brief helper function for drawing a horizontal line like
		 * +---+ as long as the rect width *)
		procedure drawHorizontalLine();
		var
			i : integer;
		begin
			write('+');
			for i:= upperLeft.x + 1 to lowerRight.x - 1 do
			begin
				write('-');
			end;
			write('+');
		end;
	
	var
		y : integer;
	begin
		(* draw the upper border including corners *)
		gotoxy(upperLeft.x, upperLeft.y);
		drawHorizontalLine();
		(* draw vertical borders, i.e. for every line do: *)
		for y := upperLeft.y + 1 to lowerRight.y - 1 do
		begin
			(* draw left border segment *)
			gotoxy(upperLeft.x, y);
			write('|');
			(* draw right border segment *)
			gotoxy(lowerRight.x, y);
			write('|');
		end;
		(* draw lower border including corners *)
		gotoxy(upperLeft.x, lowerRight.y);
		drawHorizontalLine();
	end;
	
	function getRandomColor() : byte;
	begin
		//random(i) returns a random number in range [0, i[
		//I want one in range [low, high]
		//so I add low to random(high-low+1)
		getRandomColor := COLORS[low(COLORS) + 
		                         random(high(colors) - low(colors) + 1)
		                        ];
	end;
	
	begin
		//init random number generator
		randomize;
	end.
