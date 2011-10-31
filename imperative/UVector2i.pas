(* @file UVector2i.pas
 * @author Willi Schinmeyer
 * @date 2011-10-30
 * 
 * The TVector2i type. I put it in its own unit to prevent cyclic dependencies.
 *)

unit UVector2i;

interface
	type
		(* @brief a 2 dimensional integer vector *)
		TVector2i = record
			x, y : integer;
		end;

		(* @brief Vector additin *)
	operator +(lhs, rhs : TVector2i) result : TVector2i;

implementation

	operator +(lhs, rhs : TVector2i) result : TVector2i;
	begin
		result.x := lhs.x + rhs.x;
		result.y := lhs.y + rhs.y;
	end;

	begin
	end.
