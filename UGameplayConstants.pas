(* @file UGameplayConstants.pas
 * @author Willi Schinmeyer
 * @date 2011-10-27
 * 
 * UGameplayConstants Unit
 * 
 * Contains various constants regarding gameplay
 *)

unit UGameplayConstants;

interface
uses crt;

const
	(* @brief Possible Tetromino colors
	 * @note Strictly speaking not gameplay relevant, but it fits here
	 *)
	TETROMINO_COLORS : array[0..3] of byte = (
		red,
		green,
		blue,
		yellow
	);

implementation
	begin
	end.
