(* @file UTetrominoShape.pas
 * @author Willi Schinmeyer
 * @date 2011-10-30
 * 
 * UTetrominoShape unit
 * 
 * Contains definition of the TTetrominoShape type, which would in
 * theory fit into UGeneralTypes but that would create a circular
 * dependency.
 *)


unit UTetrominoShape;
interface
	uses UVector2i;
	type
		(* The shape of a Tetromino. By definition they are made out of
		 * 4 parts, hence the 4 element array. *)
		TTetrominoShape = array[0..3] of TVector2i;

implementation
	begin
	end.
