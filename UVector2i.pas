(* @file UVector2i.pas
 * @author Willi Schinmeyer
 * @date 2011-10-26
 * 
 * UVector2i Unit
 * 
 * Unit for 2 dimensional integer vectors, called TVector2i or vec2i for
 * short. Only a limited set of functions are available since I don't
 * need any more.
 *)

unit UVector2i;

interface
	(*
	 * @brief 2 dimension integer vector type
	 *)
	type
		TVector2i = record
			(* @brief X coordinate *)
			x : integer;
			(* @brief Y coordinate *)
			y : integer;
		end;
	
	(*
	 * @brief Adds two vectors and returns the result.
	 * @param lhs (left hand side) first vector
	 * @param rhs (right hand side) second vector
	 * @return Sum of the two vectors. (i.e. (a.x + b.x, a.y + b.y) )
	 * @note The parameters are no vars although that would be cheaper
	 *       (no copies) so temporary values can be used.
	 *)
	operator + (lhs, rhs : TVector2i) result : TVector2i;
	
	(*
	 * @brief Rotates a vector 90 degrees counter-clockwise (=ccw)
	 * @param vec The vector
	 * @note If I'm not mistaken this assumes a coordinate system where
	 *       the Y axis is 90° CW from the X axis, otherwise it's a
	 *       clockwise rotation. (In my case: X = right, Y = down)
	 *)
	procedure rotate90DegCCW(var self : TVector2i);
	
	(* 
	 * @brief Creates a new Vector (especially useful for temporary
	 *        records)
	 * 
	 * @param x X coordinate
	 * @param y Y coordinate
	 *)
	function new(x, y : integer) : TVector2i;
	
implementation
	operator +(lhs, rhs : TVector2i) result : TVector2i;
	begin
		(* Vector's are added component-wise. That's how it's defined.*)
		result.x := lhs.x + rhs.x;
		result.y := lhs.y + rhs.y;
	end;
	
	procedure rotate90DegCCW(var self : TVector2i);
	var
		(* to switch the values I need a temporary value. *)
		newX : integer;
	begin
		(* look up rotation matrices for an explanation for why this
		 * rotates a vector. *)
		newX := self.y;
		self.y := -self.x;
		self.x := newX;
	end;
	
	function new(x, y : integer) : TVector2i;
	var
		tempVec : TVector2i;
	begin
		tempVec.x := x;
		tempVec.y := y;
		new := tempVec;
	end;

	begin
	end.
