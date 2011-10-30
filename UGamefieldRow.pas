(* @file UGamefieldRow.pas
 * @author Willi Schinmeyer
 * @date 2011-10-28
 * 
 * UGamefieldRow Unit
 * 
 * Contains the TGamefieldRow type and functions/procedures operating on
 * it, as well as the TGamefieldCell type since it doesn't warrant its
 * own file. (TGAmefieldRow on the other hand does, since it has member
 * functions. Well, one.)
 *)

unit UGamefieldRow;

interface
	uses UGameplayConstants;

	type
		TGamefieldCell = record
			occupied : boolean;
			color : byte;
		end;
		
		TGamefieldRow = record
			cells : array[0..(GAMEFIELD_WIDTH-1)] of TGamefieldCell;
		end;
	
	(* @brief Checks whether a given row is full (i.e. filled from left
	 *        to right)
	 *)
	function isFull(var self : TGamefieldRow) : boolean;

implementation

	function isFull(var self : TGamefieldRow) : boolean;
	var
		currentCell : TGamefieldCell;
	begin
		//the row is full unless at least one cell is empty.
		isFull := true;
		//so I test all cells...
		for currentCell in self.cells do
			if not currentCell.occupied then
				isFull := false;
				//a break would be nice here, but since that's not
				//available I sacrifice speed for code clarity here.
				//(The alternative approach would be more obscure)
	end;
	
	begin
	end.
