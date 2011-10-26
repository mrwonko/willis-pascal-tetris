(* @file UTime.pas
 * @author Willi Schinmeyer
 * @date 2011-10-24
 * 
 * UTime Unit
 * 
 * Functions for dealing with time.
 *)

Unit UTime;

interface
	(*
	 * @brief Returns the milliseconds since midnight.
	 * 
	 * It's most useful for timestamping purposes to return the
	 * milliseconds since midnight the day the program was started,
	 * but that requires the use of a global to store the day the
	 * program was started. This behaviour can be enabled by defining
	 * GLOBALS_ALLOWED, but for this assignment globals are <i>not</i>
	 * enabled, hence it's not defined. In that case it returns the
	 * milliseconds since midnight of the current day instead.
	 * 
	 * @note Either overflows after 24.8 days (globals enabled) or at
	 *       midnight.
	 * 
	 * @todo Find a better name to correctly reflect the changed
	 *       behaviour when GLOBALS_ALLOWED is defined. Or put that in
	 *       its own function. getMillisecondsSinceMidnightOfSomeDay()?
	 *)
	function getMillisecondsSinceMidnight() : longint;



implementation

	(* There's a better (in my opinion, mind!) implementation for
	 * getMillisecondsSinceMidnight() that doesn't reset at midnight,
	 * but it requires use of globals. They are not allowed.
	 * If they were, this could be uncommented and the better
	 * implementation would be used. *)
	//{$define GLOBALS_ALLOWED}

	(* Sysutils contains some useful cross-platform time functions,
	 * amongst others *)
	uses sysutils;
	
	(* I may not use globals so they need to be spefically enabled.
	 * If enabled, one stores the day this program was first started
	 * so the milliseconds it's been running can be adjusted
	 * accordingly. *)
	{$ifdef GLOBALS_ALLOWED}
		var
			(* the day on which the program was started *)
			startDay : smallint;
	
	const
		MILLISECONDS_PER_DAY : longint = 24*60*60*1000;
	{$endif}
	
	function getMillisecondsSinceMidnight() : longint;
	var
		{$ifdef GLOBALS_ALLOWED}
			(* days this program's been running *)
			elapsedDays : smallint;
		{$endif}
		
		(* returned by the function I use to get the current time *)
		timestamp : TTimeStamp;
	begin
		(* get current time in days since 1970 and ms since midnight *)
		timestamp := DateTimeToTimeStamp(Now);
		
		(* if globals are allowed: time since midnight, startday *)
		{$ifdef GLOBALS_ALLOWED}
		
			(* get number of elapsed days *)
			elapsedDays := timestamp.Date - startDay;
			(* add elapsed days in ms to milliseconds since midnight,
			 * return the result *)
			getMillisecondsSinceMidnight := elapsedDays *
			                                MILLISECONDS_PER_DAY +
							                timestamp.Time;
		
		(* otherwise: time since midnight today *)
		{$else}
		
			getMillisecondsSinceMidnight := timestamp.Time;
		
		{$endif}
	end;

	(* the initialization is only necessary if I need to fill the
	 * global variable in the beginning, so the same is true for this
	 * variable. *)
	{$ifdef GLOBALS_ALLOWED}
		var
			(* returned by the function I use to get the current time *)
			timestamp : TTimeStamp;
	{$endif}
	(* Initialization *)
	begin
		{$ifdef GLOBALS_ALLOWED}
			(* retrieve current time (i.e. when program started) *)
			timestamp := DateTimeToTimeStamp(Now);
			(* save the day it started for later use *)
			startDay := timestamp.Date;
		{$endif}
	end.
