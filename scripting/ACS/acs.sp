//////////////////////////////////////////
// Automatic Campaign Switcher for L4D2 //
// Version 2.0.0 (Nov 14, 2021)         //
// Developed by Chris Pringle           //
//////////////////////////////////////////

/*==================================================================================================

	This plugin was written in response to the server kicking everyone if the vote is not passed
	at the end of the campaign. It will automatically switch to the appropriate map at all the
	points a vote would be automatically called, by the game to go to the lobby or play again.
	ACS also includes a voting system in which people can vote for their favorite campaign/map. The 
	winning campaign/map will become the next map the server loads.

	ACS supports all of the stock Game Modes in Left 4 Dead 2. This includes:
	
		Coop
		Realism
		Versus
		Team Versus
		Scavenge
		Team Scavenge
		Mutation 1-20
		Community 1-5

	Change Log
		v2.0.0 (Nov 14, 2021)	- Overhauled most the code, rewriting many functions to be more generic and reusable
								- Changed to a single map list array with indexes that adjust based on gamemode
								- Added a map list config file thats plain text and can be easily configured
									- This file can be edited to set up any custom map for any game mode with any order
									- Just run the plugin and this file will generate itself with the default maps 
									  the first time ACS is ran.
								- Added Maps Listing in console output to help with configuring custom maps
								- Updated all the default maps for every stock game mode
								- Added hook for OnPZEndGamePanelMsg that intercepts and removes the vote at the 
								  end of a campaign where it asks to play with the group again. This is also used
								  as a better method for knowing its time to switch to next campaign.  This method
								  works without the need for a separate signatures file. It works for all modes 
								  except for Coop and Survival that will continue forever. These modes are handled
								  through event hooks.
								- Added file modified detection for Map List Config that will update ACS on map change.
								- Fixed config file not loading changes
								- Converted everything to new syntax

		v1.2.4 (Dec 31, 2020)	- Added new maps for the Last Stand Update
								- Added precache of witch models to fix bug in The Passing campaign transition crash
								- Made map comparisons case insensitive
								- Fixed several infinite loop bugs when on the last campaign
								- Changed Timer_AdvertiseNextMap to not have TIMER_REPEAT and TIMER_FLAG_NO_MAPCHANGE together
								- Removed FCVAR_PLUGIN
								- Removed global menu handle
								- Added the code from [L4D/L4D2] Return To Lobby Fix from MasterMind420. Thank you!
		
		v1.2.3 (Jan 8, 2012)	- Added the new L4D2 campaigns
		
		v1.2.2 (May 21, 2011)	- Added message for new vote winner when a player disconnects
								- Fixed the sound to play to all the players in the game
								- Added a max amount of coop finale map failures cvar
								- Changed the wait time for voting ad from round_start to the 
								  player_left_start_area event 
								- Added the voting sound when the vote menu pops up
		
		v1.2.1 (May 18, 2011)	- Fixed mutation 15 (Versus Survival)
		
		v1.2.0 (May 16, 2011)	- Changed some of the text to be more clear
								- Added timed notifications for the next map
								- Added a cvar for how to advertise the next map
								- Added a cvar for the next map advertisement interval
								- Added a sound to help notify players of a new vote winner
								- Added a cvar to enable/disable sound notification
								- Added a custom wait time for coop game modes
								
		v1.1.0 (May 12, 2011)	- Added a voting system
								- Added error checks if map is not found when switching
								- Added a cvar for enabling/disabling voting system
								- Added a cvar for how to advertise the voting system
								- Added a cvar for time to wait for voting advertisement
								- Added all current Mutation and Community game modes
								
		v1.0.0 (May 5, 2011)	- Initial Release

===================================================================================================*/

#define PLUGIN_VERSION	"v2.0.0"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#include "ACS/GlobalVariables.sp"
#include "ACS/MapNames.sp"
#include "ACS/Advertising.sp"
#include "ACS/ChangeMap.sp"
#include "ACS/ConsoleCommands.sp"
#include "ACS/CVars.sp"
#include "ACS/Events.sp"
#include "ACS/FileIO.sp"
#include "ACS/UtilityFunctions.sp"
#include "ACS/VoteSystem.sp"

/*======================================================================================
#####################             P L U G I N   I N F O             ####################
======================================================================================*/

public Plugin myinfo = 
{
	name = "Automatic Campaign Switcher (ACS)",
	author = "Chris Pringle",
	description = "Automatically switches to the next campaign when the previous campaign is over",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=156392"
}

public void OnPluginStart()
{
	// Create the map list file if there its not there already
	CreateNewMapListFileIfDoesNotExist();

	// Get the strings for all of the maps that are in rotation for every game mode
	SetupMapListArrayFromFile();
	
	// Set up all the ACS specific configurable variables
	SetUpCVars();
	
	// Hook all the events ACS needs
	SetUpEvents();
	
	// Set up the player input command listeners
	SetupConsoleCommands();

	//Repeating Timers
	CreateTimer(g_fNextMapAdInterval, Timer_AdvertiseNextMap, _, TIMER_REPEAT);
}
