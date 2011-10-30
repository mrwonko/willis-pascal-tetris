(* @file UFunctions.pas
 * @author Willi Schinmeyer
 * @date 2011-10-30
 * 
 * Contains all the methods and functions.
 *)

unit UFunctions;

interface
	(* @brief Displays the main menu. *)
	procedure showMainMenu();

	(* @brief Displays the help, i.e. how to play. *)
	procedure showHelp();

	(* @brief Starts the game. *)
	procedure runGame();

implementation
	uses
		crt, //for console i/o
		UConstants; //all the constants, duh
	
	procedure showMainMenu();
	begin
		//well, just print it :D
		clrscr();
		writeln('TETRIS');
		writeln();
		writeln(NEWGAME_KEY, ') start');
		writeln(HELP_KEY, ') help');
		writeln(QUIT_KEY, ') quit');
	end;
	
	procedure showHelp();
	begin
		//Printing a help text is not exactly an art... Just write it.
		clrscr();
		writeln('How to play:');
		writeln();
		writeln('Move the block with ', LEFT_KEY, ' and ', RIGHT_KEY, ', rotate it with ', ROTATE_KEY, '.');
		writeln('Press Escape at any time to return to the main menu.');
		writeln();
		writeln('Press any key to continue.');
		//And wait for any key - but watch out for extended keys.
		if readKey() = #0 then
		begin
			//because they mean we need to read again.
			readKey();
		end;
	end;
	
	procedure runGame();
	begin
		clrscr();
		writeln('ingame! (TODO)');
		readKey();
	end;

	begin
	end.
