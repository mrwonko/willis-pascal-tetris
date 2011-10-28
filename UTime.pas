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
	 *)
	function getMillisecondsSinceMidnight() : longint;
	
	(*
	 * @brief Returns the difference between two times, assuming a
	 *        "midnight overflow" happened if the earlierTime is later.
	 *)
	function getDifference(laterTime, earlierTime : longint) : longint;


implementation

	(* Sysutils contains some useful cross-platform time functions,
	 * amongst others *)
	uses sysutils;
	
	const
		MILLISECONDS_PER_DAY : longint = 1000*60*60*24;
	
	function getMillisecondsSinceMidnight() : longint;
	var
		(* returned by the function I use to get the current time *)
		timestamp : TTimeStamp;
	begin
		(* get current time in days since 1970 and ms since midnight *)
		timestamp := DateTimeToTimeStamp(Now);
		
		getMillisecondsSinceMidnight := timestamp.Time;
	end;
	
	function getDifference(laterTime, earlierTime : longint) : longint;
	begin
		//this happens at midnight
		if earlierTime > laterTime then
			//milliseconds per day - 
			getDifference := laterTime + MILLISECONDS_PER_DAY -
			                 earlierTime
		else
			getDifference := laterTime - earlierTime;
	end;

	begin
	end.
