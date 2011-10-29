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
	uses UVector2i, UGeneralTypes;
	
	const
		//how wide the borders are - changing this does not change the
		//borders, it just messes calculations up.
		BORDER_SIZE : integer = 1;

	(*
	 * @brief draws 4 borders, creating a rectangle
	 * 
	 * point1 and point2 are the opposite points defining the rectangle.
	 *)
	procedure drawRectangleBorders(point1, point2 : 
	                               TVector2i);
	
	(*
	 * @brief Returns one of the colors defined in UGameplayConstants
	 *)
	function getRandomTetrominoColor() : byte;
	
	(*
	 * @brief Returns one of the shapes defined in UGameplayConstants
	 *)
	function getRandomTetrominoShape() : TTetrominoShape;
	
	(* @brief Swaps the content of a and b *)
	procedure swap(var a, b : integer);

implementation

	uses crt, UGameplayConstants;

	procedure drawRectangleBorders(point1, point2 : 
	                               TVector2i);
	                               
		(* @brief helper function for drawing a horizontal line like
		 * +---+ as long as the rect width *)
		procedure drawHorizontalLine();
		var
			i : integer;
		begin
			write('+');
			for i:= point1.x + 1 to point2.x - 1 do
			begin
				write('-');
			end;
			write('+');
		end;
	
	var
		y : integer;
	begin
		(* make sure point1 is upperLeft and point2 lowerRight *)
		if point1.x > point2.x then
			swap(point1.x, point2.x);
		if point1.y > point2.y then
			swap(point1.y, point2.y);
		(* draw the upper border including corners *)
		gotoxy(point1.x, point1.y);
		drawHorizontalLine();
		(* draw vertical borders, i.e. for every line do: *)
		for y := point1.y + 1 to point2.y - 1 do
		begin
			(* draw left border segment *)
			gotoxy(point1.x, y);
			write('|');
			(* draw right border segment *)
			gotoxy(point2.x, y);
			write('|');
		end;
		(* draw lower border including corners *)
		gotoxy(point1.x, point2.y);
		drawHorizontalLine();
	end;
	
	function getRandomTetrominoColor() : byte;
	begin
		//random(i) returns a random number in range [0, i[
		//I want one in range [low, high]
		//so I add low to random(high-low+1)
		getRandomTetrominoColor := TETROMINO_COLORS[
			low(TETROMINO_COLORS) + 
			random(high(TETROMINO_COLORS) - low(TETROMINO_COLORS) + 1)
		];
	end;
	
	function getRandomTetrominoShape() : TTetrominoShape;
	begin
		//random(i) returns a random number in range [0, i[
		//I want one in range [low, high]
		//so I add low to random(high-low+1)
		getRandomTetrominoShape := TETROMINO_SHAPES[
			low(TETROMINO_SHAPES) + 
			random(high(TETROMINO_SHAPES) - low(TETROMINO_SHAPES) + 1)
		];
	end;
	
	procedure swap(var a, b : integer);
	var
		temp : integer;
	begin
		temp := a;
		a := b;
		b := temp;
	end;
	
	begin
		//init random number generator
		randomize;
	end.
