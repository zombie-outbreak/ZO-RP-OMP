/*
* Zombie Outbreak Roleplay
* (C) 2025 Zombie Outbreak Development Contributors
* GNU General Public License v3.0
*/

// ============================================================================
// CORE MODULES (Must be loaded first)
// ============================================================================
#include "modules/core/config.pwn"      // Server configuration
#include "modules/core/constants.pwn"   // Game constants
#include "modules/core/colors.pwn"      // Color definitions

// ============================================================================
// THIRD-PARTY LIBRARIES
// ============================================================================
#include <open.mp>
#include <a_mysql>
#include <xml>
#include <Pawn.CMD>
#include <easyDialog>
#include <samp_bcrypt>
#include <filemanager>
#include <streamer>
#include <sscanf2>
#include <weapon-config>
#include <ndialog-pages>
#include <eSelection>
#include <colandreas>
#include <textdraw-streamer> // Must be the final included library (as per https://github.com/nexquery/samp-textdraw-streamer)

// ============================================================================
// CORE DATA (After libraries, before systems)
// ============================================================================
#include "modules/core/database.pwn"    // MySQL connection handle
#include "modules/core/player_data.pwn" // Player data structures

// ============================================================================
// GAME SYSTEMS (Data structures must be loaded before utilities use them)
// ============================================================================
#include "modules/systems/inventory.pwn"    // Inventory and loot system
#include "modules/systems/vehicles.pwn"     // Vehicle management
#include "modules/systems/interiors.pwn"    // Property/interior system
#include "modules/systems/crafting.pwn"     // Crafting system
#include "modules/systems/factions.pwn"     // Faction and territory system
#include "modules/systems/perks.pwn"        // Perk system (human and zombie)

// ============================================================================
// UTILITY MODULES (Loaded after systems so they can access system data)
// ============================================================================
#include "modules/utilities/map.pwn"        // Map conversion and loading
#include "modules/utilities/messaging.pwn"  // Chat and messaging system
#include "modules/utilities/helpers.pwn"    // General helper functions
#include "modules/utilities/sql.pwn"        // Database setup
#include "modules/utilities/timers.pwn"     // Timer callbacks
#include "modules/utilities/textdraws.pwn"  // HUD and textdraw management
#include "modules/utilities/dialogs.pwn"    // Dialog handlers

// ============================================================================
// COMMANDS
// ============================================================================
#include "modules/commands/player_cmds.pwn" // Player commands
#include "modules/commands/admin_cmds.pwn"  // Admin commands

/*
* Start gamemode
*/
main()
{
    SendRconCommand("name "SERVER_NAME);
    SendRconCommand("rcon.password "SERVER_RCON);
    SendRconCommand("game.mode "SERVER_VERSION);
    SendRconCommand("game.map "SERVER_MAP);
    SendRconCommand("website "SERVER_WEBSITE);
    SendRconCommand("password "SERVER_PASSWORD);

    print("-------------------------------------");
    printf(""SERVER_NAME" ("SERVER_VERSION"), has been loaded successfully.");
    print("Zombie Outbreak Roleplay by the Zombie Outbreak Roleplay Contributors");
    print("-------------------------------------");
}

public OnGameModeInit()
{
	/*
	* Connect to database file and create tables if they don't exist.
	*/
	SetupDatabase();

	/*
    * Gamemode Settings
    */
	ManualVehicleEngineAndLights();
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	SetVehiclePassengerDamage(true);
    SetVehicleUnoccupiedDamage(true);
    SetDisableSyncBugs(true);
    SetDamageFeed(true);
    SetCustomVendingMachines(true);

	/*
	* Load custom zombie skins
	*/
	AddCustomSkinModels();

	/*
    * Get certain stats from the database
    */
    GetServerLoadStats();

	/*
    * Parse MTA Maps
    * This loads all map objects and vehicles
    */
    ParseMapFiles();

    /*
    * Now load all of the other server data such as interiors, items etc.
    */
	print("-------------------------------------");
    new timeMs = GetTickCount();
	for(new i = 0; i < MAX_SERVER_INTERIORS; i++)
    {
		LoadInteriorData(i);
	}
    printf("|-> Interiors loaded in %d ms", GetTickCount() - timeMs);
    
    timeMs = GetTickCount();
    for(new i = 0; i < MAX_SCAV_AREAS; i++)
    {
        LoadScavArea(i);
    }
    printf("|-> Scav Areas loaded in %d ms", GetTickCount() - timeMs);
    
    timeMs = GetTickCount();
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        LoadServerItems(i);
    }
    printf("|-> Items loaded in %d ms", GetTickCount() - timeMs);
    
    timeMs = GetTickCount();
    for(new i = 0; i < MAX_LOOT_TABLES; i++)
    {
        LoadServerLootTable(i);
    }
    printf("|-> Loot Tables loaded in %d ms", GetTickCount() - timeMs);
    
    timeMs = GetTickCount();
    for(new i = 0; i < MAX_FUEL_PUMPS; i++)
    {
        LoadFuelPumps(i);
    }
    printf("|-> Fuel Pumps loaded in %d ms", GetTickCount() - timeMs);
    print("-------------------------------------");
    
	/*
	* Server Textdraws
	*/
	CreateServerTextdraws();

	/*
	* Set default weather on server start (random)
	*/
	SetWeather(random(22)); // between 0 - 22

    /*
    * Initialize Game Time System
    */
    GameTimeStartTick = GetTickCount();
    GameTimeStartHour = random(24); // Random hour between 0-23
    GameTimeStartMinute = random(60); // Random minute between 0-59
    GameTimeHour = GameTimeStartHour;
    GameTimeMinute = GameTimeStartMinute;
    SetWorldTime(GameTimeHour);
    printf("Game Time System initialized: Starting at %02d:%02d with %dx multiplier", GameTimeHour, GameTimeMinute, SERVER_TIME_MULTIPLIER);

    /*
    * Timers
    */
    SetTimer("PlayerChecks", 500, true);
	SetTimer("ServerTime", 1000, true);
	SetTimer("ServerWeather", 3600000, true);
	
	/*
	* Initialize Crafting System
	*/
	InitializeCraftingSystem();
	
	/*
	* Initialize Faction System
	*/
	InitializeFactionSystem();
	return 1;
}

public OnGameModeExit()
{
	mysql_close(database);
	return 1;
}

public OnPlayerConnect(playerid)
{
    // check the user's client is an official SA-MP/OpenMP client
    // kick the player if not
    if(!IsPlayerUsingOmp(playerid))
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "We strongly advise use of the official OpenMP client to connect to this server.");
		SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "If you run into any issues we cannot provide support for unofficial clients.");
    }

	// increase the mysql race check
	mysqlRaceCheck[playerid] ++;
    
	/*
	* Reset player variables
	*/
	static const empty_player[E_PLAYERS];
	player[playerid] = empty_player;
	for(new i = 0; i < MAX_ITEMS; i++)
	{
		playerInventory[playerid][i] = 0;
	}

	/*
	* Clear all dialog list entries
	*/
	ClearDialogListitems(playerid);

	/*
	* Remove objects for the map.
	*/
	RemoveBuildings(playerid);

	/*
	* Get the player's connected name and toggle their spectating status.
	*/
	SetPlayerColor(playerid, COLOR_GREY);
	GetPlayerName(playerid, player[playerid][Name]);
	GetPlayerIp(playerid, player[playerid][ip]);
    gpci(playerid, player[playerid][serial]);
	TogglePlayerSpectating(playerid, true);
	SetPlayerVirtualWorld(playerid, playerid + 1);
	SetPlayerWeather(playerid, GetWeather()); // make sure player weather is synced upon connection

	/*
	* Create Needed Textdraws
	*/
	CreateDialogueTextdraw(playerid);
	CreatePlayerHud(playerid);

	/*
	* Setup login camera
	*/
	SetTimerEx("LoginCamera", 1500, false, "d", playerid);

	/*
	* Check account exists
	*/
	CheckPlayerAccountExists(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	// increase the mysql race check
	mysqlRaceCheck[playerid] ++;

	DestroyHudForPlayer(playerid);
	DestroyDialogueTextdraw(playerid);
	
	// Cancel any ongoing crafting
	CancelCrafting(playerid);

	/*
	* Save character data if the player is spawned as one.
	*/
	if(player[playerid][isSpawned])
	{
		SavePlayerCharacter(playerid, player[playerid][chosenChar]);
	}
	SetPlayerName(playerid, player[playerid][Name]);

	// if the player was kicked before the time expires then kill the timer
	if (player[playerid][LoginTimer])
	{
		KillTimer(player[playerid][LoginTimer]);
		player[playerid][LoginTimer] = 0;
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	player[playerid][hasDied] = false;
	
    // Set basic weapon skills to 1
    SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 1);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED, 1);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, 1);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, 1);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 1);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 1);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 1);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5, 1);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, 1);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, 1);
    SetPlayerSkillLevel(playerid, WEAPONSKILL_SNIPERRIFLE, 1);
    
    // Show faction territories
    ShowTerritoriesToPlayer(playerid);
    
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(player[playerid][hasDied])
		return 1;
	
	// Cancel any ongoing crafting
	CancelCrafting(playerid);
		
	//combustperkcheck
	if (player[playerid][iszombie] == 0)
	{
		if (player[playerid][unlockedCombustSkill])
		{
			Combust(playerid);
    	}
		if (player[playerid][huntActive])
		{
			SetPlayerMarkerForPlayer(playerid, player[playerid][huntTarget], (GetPlayerColor(player[playerid][huntTarget]) & 0xFFFFFF00));
			player[playerid][huntActive] = false;
			SendClientMessage(playerid, COLOR_RP_PURPLE, "You lost the scent.");
		}
		
	}
    
	if (killerid != INVALID_PLAYER_ID)
    {
		// Award EXP to zombie killers for killing humans
		if(player[killerid][iszombie] == 1 && player[playerid][iszombie] == 0)
		{
			GivePlayerExp(killerid, 15);
		}
		
		// Award EXP to humans for killing zombies
		if(player[killerid][iszombie] == 0 && player[playerid][iszombie] == 1)
		{
			GivePlayerExp(killerid, 10);
		}
		
		if(player[killerid][huntTarget] == playerid && player[killerid][huntActive])
		{
			SendClientMessage(killerid, COLOR_RP_PURPLE, "A successful hunt. You fill your voids with the life of your prey.");
			SetPlayerHealth(killerid, player[killerid][maxHealth]);
			UpdateHudElementForPlayer(killerid, HUD_HEALTH);
			SetPlayerMarkerForPlayer(killerid, player[killerid][huntTarget], (GetPlayerColor(player[killerid][huntTarget]) & 0xFFFFFF00));
			player[killerid][huntActive] = false;
			
			// Bonus EXP for successful hunt
			if(player[killerid][iszombie] == 1)
			{
				GivePlayerExp(killerid, 10);
			}
		}
	}
    
	new players[MAX_PLAYERS], length;
    length = GetPlayers(players, sizeof(players));

    for (new i = 0; i < length; i++) 
	{
        new pid = players[i];
        if (pid == killerid) 
			continue;

        if (player[pid][huntTarget] == playerid && player[pid][huntActive])
		{
            player[pid][huntActive] = false;
            SendClientMessage(pid, COLOR_RP_PURPLE, "Your prey has died. The trail fades cold.");
            SetPlayerMarkerForPlayer(pid, player[pid][huntTarget], (GetPlayerColor(pid) & 0xFFFFFF00)); // optional
        }
    }
    
	/*
	* Kill timers and reset spawned variable as well as hide the HUD
	*/
	player[playerid][spawned] = 0;
	if(player[playerid][hungerTimer])
	{
		KillTimer(player[playerid][hungerTimer]);
	}

	if(player[playerid][thirstTimer])
	{
		KillTimer(player[playerid][thirstTimer]);
	}

	if(player[playerid][diseaseTimer])
	{
		KillTimer(player[playerid][diseaseTimer]);
	}

	if(player[playerid][fuelTimer])
	{
		KillTimer(player[playerid][fuelTimer]);
	}

	if(player[playerid][fillVehicleTimer])
	{
		KillTimer(player[playerid][fillVehicleTimer]);
	}

	if(player[playerid][locationTimer])
	{
		KillTimer(player[playerid][locationTimer]);
	}

	HideHudForPlayer(playerid);
	
	// Set disease to 100
	player[playerid][disease] = 100;
	UpdateHudElementForPlayer(playerid, HUD_DISEASE);

	/*
	* Set the player to spectate mode and set the timer to respawn
	*/
	player[playerid][hasDied] = true;
	TogglePlayerSpectating(playerid, true);
	GameTextForPlayer(playerid, "...Respawning...", 3500, 3);
	SetTimerEx("RespawnAfterDeath", 3500, false, "d", playerid);
	return 1;
}


public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &WEAPON:weapon, &bodypart)
{
    // Check if issuerid is valid (not INVALID_PLAYER_ID for falling damage, etc.)
    new bool:validIssuer = (issuerid != INVALID_PLAYER_ID);
    
    if(weapon == 0){
        amount = 10;
    }
    
    // Only apply issuer-based modifiers if there's a valid issuer
    if(validIssuer)
    {
        //perks test 
        if(weapon == 0 && player[issuerid][unlockedUnarmedSkill]){
            //multiply 5 with unarmed skill level (max: 25dmg bonus)
            amount = amount + player[issuerid][unlockedUnarmedSkill] * 3;
        }
        if(weapon == 0 && player[issuerid][unlockedBorrowedStrengthSkillActive]){
            amount = amount + player[issuerid][unlockedBorrowedStrengthSkillDamage];
        }
        if(weapon == 0 && player[issuerid][unlockedCorneredSkill] && player[issuerid][health] < player[issuerid][maxHealth] * 0.3){
            SendProxMessage(issuerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER, "A near-death desperation feeds savage blows.");
            amount += 20;
        }
        //huntchecks
        if(player[issuerid][huntActive] && player[issuerid][huntTarget] == playerid){
            amount += 5;
        }
        if(player[issuerid][huntActive] && player[issuerid][huntTarget] != playerid){
            amount -= 5;
        }
        if(player[playerid][huntActive] && player[issuerid][huntTarget] == issuerid){
            amount -= 5;
        }
        if(player[playerid][huntActive] && player[issuerid][huntTarget] != issuerid){
            amount += 5;
        }
        //perks test
    }
    
    return 1;
}

public OnPlayerDamageDone(playerid, Float:amount, issuerid, WEAPON:weapon, bodypart)
{
    UpdateHudElementForPlayer(playerid, HUD_HEALTH);
    return 1;
}

public OnPlayerText(playerid, text[])
{
	if(player[playerid][iszombie] == 1)
	{
		SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER, "snarls and groans");
	}
	else
	{
		SendProxMessage(playerid, COLOR_WHITE, 30.0, PROXY_MSG_TYPE_CHAT, text);
	}
	return 0;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
	if(result == -1)
	{
		SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Command does not exist!");
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Use /commands to see a list of commands.");
		return 0; // command was handled
	}
    return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	for(new i = 0; i < MAX_SERVER_INTERIORS; i++)
    {
		if(player[playerid][createIntStep] >= 1) // if player is making an interior then don't call this script until they're done
            return 1;

		if(pickupid == interiorEnterPickup[i])
		{
			player[playerid][atProperty] = i; // used to determine which property someone is at (for purchasing etc)

			if(strcmp("Vacant", srvInterior[i][intOwner]) == 0)
			{
				if(srvInterior[i][intType] == INTERIOR_TYPE_PUBLIC)
				{
					// interior is unlocked so let them in
					SetPlayerWeather(playerid, 0);
					SetPlayerPos(playerid, srvInterior[i][intEnter][3], srvInterior[i][intEnter][4], srvInterior[i][intEnter][5]);
					SetPlayerFacingAngle(playerid, srvInterior[i][intEnter][6]);
					SetCameraBehindPlayer(playerid);
					SetPlayerInterior(playerid, srvInterior[i][intWorld]);
					SetPlayerVirtualWorld(playerid, srvInterior[i][intVirWorld]);
					GameTextForPlayer(playerid, "You entered %s", 5000, 3, srvInterior[i][intName]);
				}
				
				if(player[playerid][antiMessageSpam] != 1)
				{
					if(srvInterior[i][intType] != INTERIOR_TYPE_PUBLIC)
					{
						SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "To purchase this property please type /purchaseproperty.");
						player[playerid][antiMessageSpam] = 1;
						SetTimerEx("AntiMessageSpamTimer", 2500, false, "d", playerid);
					}
				}
			}
			else
			{
				if(srvInterior[i][intLocked] == 1)
				{
					if(player[playerid][antiMessageSpam] != 1)
					{
						SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You cannot enter this location as it has been locked.");
						player[playerid][antiMessageSpam] = 1;
						SetTimerEx("AntiMessageSpamTimer", 2500, false, "d", playerid);
					}

					// if the player is the owner of the property let them in anyway
					if(strcmp(player[playerid][chosenChar], srvInterior[i][intOwner]) == 0)
					{
						SetPlayerWeather(playerid, 0);
						SetPlayerPos(playerid, srvInterior[i][intEnter][3], srvInterior[i][intEnter][4], srvInterior[i][intEnter][5]);
						SetPlayerFacingAngle(playerid, srvInterior[i][intEnter][6]);
						SetCameraBehindPlayer(playerid);
						SetPlayerInterior(playerid, srvInterior[i][intWorld]);
						SetPlayerVirtualWorld(playerid, srvInterior[i][intVirWorld]);
						GameTextForPlayer(playerid, "You entered %s", 5000, 3, srvInterior[i][intName]);
					}
				}
				else
				{
					// interior is unlocked so let them in
					SetPlayerWeather(playerid, 0);
					SetPlayerPos(playerid, srvInterior[i][intEnter][3], srvInterior[i][intEnter][4], srvInterior[i][intEnter][5]);
					SetPlayerFacingAngle(playerid, srvInterior[i][intEnter][6]);
					SetCameraBehindPlayer(playerid);
					SetPlayerInterior(playerid, srvInterior[i][intWorld]);
					SetPlayerVirtualWorld(playerid, srvInterior[i][intVirWorld]);
					GameTextForPlayer(playerid, "You entered %s", 5000, 3, srvInterior[i][intName]);
				}
			}
		}
		else if(pickupid == interiorExitPickup[i])
		{
			// should always be allowed to leave regardless of interior status
			SetPlayerWeather(playerid, GetWeather());
			SetPlayerPos(playerid, srvInterior[i][intExit][3], srvInterior[i][intExit][4], srvInterior[i][intExit][5]);
			SetPlayerFacingAngle(playerid, srvInterior[i][intExit][6]);
			SetCameraBehindPlayer(playerid);
			SetPlayerInterior(playerid, srvInterior[i][intExitWorld]);
			SetPlayerVirtualWorld(playerid, srvInterior[i][intExitVirWorld]);
			GameTextForPlayer(playerid, "You exited %s", 5000, 3, srvInterior[i][intName]);
		}
	}
	return 1;
}

public OnPlayerWeaponShot(playerid, WEAPON:weaponid, BULLET_HIT_TYPE:hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	/*
	* Remove ammo from inventory when a weapon is shot
	*/
    switch(weaponid)
	{
		case WEAPON_COLT45, WEAPON_SILENCED, WEAPON_DEAGLE, WEAPON_UZI, WEAPON_TEC9:
		{
			new nineMMAmmoId = ReturnItemIdByName("9mm Round");
			playerInventory[playerid][nineMMAmmoId] = playerInventory[playerid][nineMMAmmoId] - 1;

			if(playerInventory[playerid][nineMMAmmoId] <= 0)
			{
				playerInventory[playerid][nineMMAmmoId] = 0;
			}
		}
		case WEAPON_SHOTGUN, WEAPON_SAWEDOFF, WEAPON_SHOTGSPA:
		{
			new shotgunAmmo = ReturnItemIdByName("12 Gauge Shell");
			playerInventory[playerid][shotgunAmmo] = playerInventory[playerid][shotgunAmmo] - 1;

			if(playerInventory[playerid][shotgunAmmo] <= 0)
			{
				playerInventory[playerid][shotgunAmmo] = 0;
			}
		}
	}
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new allowedWeapons[] = {WEAPON_COLT45, WEAPON_UZI, WEAPON_MP5, WEAPON_TEC9};
    if(player[playerid][iszombie] == 0)
    {
        if(newstate == PLAYER_STATE_DRIVER) 
        {
            SetPlayerArmedWeapon(playerid, WEAPON_FIST);
            player[playerid][lastInVehId] = GetPlayerVehicleID(playerid);
            if(serverVehicle[player[playerid][lastInVehId]][engine]) // vehicle engine is turned on so show HUD
            {
                // show the fuel hud and start the vehicle timer
                ShowHudForPlayer(playerid, HUD_VEHICLE);
                player[playerid][fuelTimer] = SetTimerEx("FuelTimer", FUEL_TIMER, true, "dd", playerid, player[playerid][lastInVehId]);
                SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "The engine is running.");
            }
            else
            {
                SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "The engine is off. Use /engine to attempt to start it.");
            }
        }
        else if(newstate == PLAYER_STATE_PASSENGER)
        {
            for(new i = 0; i < sizeof(allowedWeapons); i++) 
            {
                if(GetPlayerWeapon(playerid) != allowedWeapons[i])
                {
                    SetPlayerArmedWeapon(playerid, WEAPON_FIST);
                }
            }
            player[playerid][lastInVehId] = GetPlayerVehicleID(playerid);
        }

        /*
        * Hide the fuel HUD when the driver exits the vehicle
        */
        if(oldstate == PLAYER_STATE_DRIVER) 
        {
            SetPlayerArmedWeapon(playerid, WEAPON_FIST);
            HideHudElementForPlayer(playerid, HUD_VEHICLE);
            KillTimer(player[playerid][fuelTimer]);
        }
    }
    else if(player[playerid][iszombie] == 1) // zombies don't need fuel etc.
    {
        if(newstate == PLAYER_STATE_DRIVER)
        {
            player[playerid][lastInVehId] = GetPlayerVehicleID(playerid);
            SetVehicleEngineOn(player[playerid][lastInVehId]);
        }
        
        if(oldstate == PLAYER_STATE_DRIVER) 
        {
            SetVehicleEngineOff(player[playerid][lastInVehId]);
        }
    }
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	//zedperk hotkeys
	if (HOLDING( KEY_WALK | KEY_JUMP ))
	{
		if(player[playerid][iszombie] == 1 && player[playerid][unlockedSuperJumpSkill])
		{
            SuperJump(playerid);
		}
	}
	if (HOLDING( KEY_WALK | KEY_AIM))
	{
		if(player[playerid][iszombie]  == 1 && player[playerid][unlockedBiteSkill])
		{
            Bite(playerid);
		}
	}
	if (HOLDING( KEY_WALK | KEY_FIRE))
	{
		if(player[playerid][iszombie]  == 1 && player[playerid][unlockedStunSkill])
		{
            Stun(playerid);
		}
	}
	if (HOLDING( KEY_WALK | KEY_CROUCH))
	{
		if(player[playerid][iszombie]  == 1 && player[playerid][unlockedGrabSkill])
		{
            Grab(playerid);
		}
	}
	//zedperk hotkeys
	if(IsKeyJustDown(KEY_SPRINT, newkeys, oldkeys))
	{
	    StopLoopingAnim(playerid);
        TextDrawHideForPlayer(playerid, animhelper);
    }
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	SetupVehicleForSpawn(vehicleid);
	return 1;
}

public OnPlayerUseVendingMachine(playerid, &Float:health_given)
{
    health_given = 0; // don't give health
    
    if((GetTickCount() - player[playerid][vendingAntiSpam]) < VENDING_MACHINE_COOLDOWN) // guarentee no item found
        return SendClientMessage(playerid, COLOR_RP_PURPLE, "You shake the vending machine but can't get anything of use from it. ((Please wait 30 seconds between use.))");
    
    /*
    * Chance of getting an item from the vending machine
    */
    new candyBarId = ReturnItemIdByName("Candy Bar");
    new bottledWaterId = ReturnItemIdByName("Bottle of Water"); 
    new chance = random(CHANCE);
    
    switch(chance)
    {
        case 0 .. 24: // candy bar
        {
           playerInventory[playerid][candyBarId] = playerInventory[playerid][candyBarId] + 1;
           SendClientMessage(playerid, COLOR_RP_PURPLE, "You shake the vending machine and a candy bar drops out.");
        }
        case 25 .. 49: // bottled water
        {
            playerInventory[playerid][bottledWaterId] = playerInventory[playerid][bottledWaterId] + 1;
            SendClientMessage(playerid, COLOR_RP_PURPLE, "You shake the vending machine and a bottle of water drops out.");
        }
        default: SendClientMessage(playerid, COLOR_RP_PURPLE, "You shake the vending machine but can't get anything of use from it.");
    }
    
    /*
    * Stop being able to spam vending machines
    */
    player[playerid][vendingAntiSpam] = GetTickCount();
    return 1;
}

public OnPlayerFinishedDownloading(playerid, virtualworld)
{
    return 1;
}