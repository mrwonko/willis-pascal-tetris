(* @file UMenuLine.pas
 * @author Willi Schinmeyer
 * @date 2011-10-28
 * 
 * UMenuLine Unit
 * 
 * Contains the TMenuLine type.
 *)


unit UMenuLine;

interface
	type
		(* @brief Represents a line of text in a menu part.
		 * 
		 * Can be centered.
		 *)
		TMenuLine = record
			text : string;
			centered : boolean;
		end;

implementation
	begin
	end.
