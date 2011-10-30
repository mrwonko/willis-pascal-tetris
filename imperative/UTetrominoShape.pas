(* @file UTetrominoShape.pas
 * @author Willi Schinmeyer
 * @date 2011-10-30
 * 
 * The TTetrominoShape type. I put it in its own unit to prevent cyclic dependencies.
 *)

unit UTetrominoShape;

interface
	uses UVector2i;

	type
		(* @brief Shape of a tetromino - they always consist of 4 squares, hence the name. *)
		TTetrominoShape = array[0..3] of TVector2i;

implementation

	begin
	end.
