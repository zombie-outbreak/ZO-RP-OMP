// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - SQL/DATABASE MODULE
// ============================================================================
/*
* MODULE: SQL
* PURPOSE: MySQL database connection and all SQL query handlers
* 
* DEPENDENCIES:
* - MySQL plugin (BlueG/pBlueG)
* - mysql.ini (database credentials configuration file)
* - core/player_data.pwn (player arrays)
* - bcrypt plugin (password hashing)
* 
* PUBLIC FUNCTIONS:
* DATABASE SETUP:
* - SetupDatabase() - Initialize MySQL connection with pool
* 
* ACCOUNT MANAGEMENT:
* - CheckPlayerAccountExists(playerid) - Check if account exists
* - OnAccountCheck(playerid, raceCheck) - Account existence callback
* - OnPasswordVerify(playerid, success) - Password verification callback
* - OnPlayerLogin(playerid, raceCheck) - Load player account data
* - OnUserPasswordChange(playerid) - Password change confirmation
* - OnPasswordChangeComplete(playerid) - Password change success/failure callback
* 
* CHARACTER MANAGEMENT:
* - OnCharacterDataReceived(playerid, raceCheck) - Load character data
* - OnCharacterListLoaded(playerid) - Load character selection menu
* - OnCharacterCountLoaded() - Count total characters on server
* 
* INTERIOR SYSTEM:
* - OnInteriorDataLoaded(interiorid) - Load interior data
* - OnInteriorCreated(playerid, intname) - Interior creation callback
* - OnInteriorCountUpdate(intid) - Update interior ID counter
* - OnShowInteriorsList(playerid) - Display interiors list
* - OnInteriorCountLoaded() - Count total interiors
* 
* SCAVENGING SYSTEM:
* - OnScavAreaLoaded(scavAreaId) - Load scavenge area data
* - OnScavAreaCreated(...) - Scavenge area creation callback
* - OnScavAreaCountLoaded() - Count total scav areas
* - ResetSearchZone(zoneid) - Reset search zone cooldown
* 
* ITEM/LOOT SYSTEM:
* - OnServerItemLoaded(item) - Load server item data
* - OnItemsCountLoaded() - Count total items
* - OnLootTableLoaded(lootTableId) - Load loot table
* - OnLootTableListLoaded(playerid) - Load loot table selection
* - OnLootTableChanceListLoaded(playerid) - Load loot spawn chances
* - OnLootTableCountLoaded() - Count total loot tables
* - OnCharacterInventoryLoaded(playerid, timeMs) - Load player inventory
* 
* FUEL SYSTEM:
* - OnFuelPumpCreated(...) - Fuel pump creation callback
* - OnFuelPumpLoaded(pumpId) - Load fuel pump data
* - OnFuelPumpCountLoaded() - Count total fuel pumps
* 
* SHOP SYSTEM:
* - LoadShops(shopid) - Load shop from database by ID
* - OnShopsLoaded(shopid) - Shop data load callback
* - SaveShopToDatabase(shopIndex) - Save/update shop to database
* - UpdateShopInventoryInDatabase(shopIndex, itemid) - Update single item in shop inventory
* - DeleteShopFromDatabase(shopid) - Delete shop from database
* 
* ADMIN/LOGGING:
* - OnAdminLogsRetrieved(adminid, limit) - Retrieve admin action logs
* 
* SERVER STATS:
* - OnAccountCountLoaded() - Count total accounts
* 
* DESCRIPTION:
* Handles all MySQL database operations including connection setup, account/character
* management, world data loading (interiors, scav areas, items, loot tables, fuel pumps),
* and admin logging. Uses connection pooling and prepared statements for performance.
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_SQL_INCLUDED
#define MODULE_SQL_INCLUDED

// ============================================================================
// DATABASE SETUP
// ============================================================================

SetupDatabase()
{
    // Connect to MySQL server using configuration file
    // This keeps sensitive credentials out of the source code
    database = mysql_connect_file("mysql.ini");
    
    if(database == MYSQL_INVALID_HANDLE || mysql_errno(database) != 0)
    {
        print("=====================================");
        print("ERROR: Could not connect to MySQL database!");
        print("ERROR: Make sure MySQL server is running and credentials are correct.");
        print("ERROR: Check mysql.ini file in the server root directory.");
        print("=====================================");
        SendRconCommand("exit"); // Shutdown server if database fails
    }
    else
    {
        print("=====================================");
        print("SUCCESS: Connected to MySQL database!");
        print("=====================================");
    }
}

// ============================================================================
// ACCOUNT MANAGEMENT
// ============================================================================

CheckPlayerAccountExists(playerid)
{
	new query[256];
    
    mysql_format(database, query, sizeof(query), 
        "SELECT `password`, `email_verified`, `isbanned` FROM `accounts` WHERE `username` = '%e' LIMIT 1", 
        player[playerid][Name]);
    
    mysql_tquery(database, query, "OnAccountCheck", "dd", playerid, mysqlRaceCheck[playerid]);
	return 1;
}

forward OnAccountCheck(playerid, raceCheck);
public OnAccountCheck(playerid, raceCheck)
{
    new string[128];

	if (raceCheck != mysqlRaceCheck[playerid]) 
	{
        Dialog_Show(playerid, MessageBoxKick, DIALOG_STYLE_MSGBOX, "No Account Exists", "An error occured. Please reconnect.", "OK", "");
        return 1;
    }

    if(cache_num_rows() > 0)
    {
        cache_get_value_name(0, "password", player[playerid][Password], BCRYPT_HASH_LENGTH);
        cache_get_value_name_bool(0, "email_verified", player[playerid][isEmailVerified]);
        cache_get_value_name_int(0, "isbanned", player[playerid][isBanned]);

        /*
        * If email is not verified
        */
        if(!player[playerid][isEmailVerified])
        {
            format(string, sizeof string, "Your email address for this account (%s) is not verified.\nPlease verify your email by visiting %s", player[playerid][Name], SERVER_WEBSITE);
            Dialog_Show(playerid, MessageBoxKick, DIALOG_STYLE_MSGBOX, "Email Not Verified", string, "OK", "");
            return 1;
        }

        /*
        * If the player is banned.
        */
        if(player[playerid][isBanned] >= 1)
        {
            format(string, sizeof string, "You are banned from this server. (Is this wrong? Go to %s)", SERVER_WEBSITE);
		    Dialog_Show(playerid, MessageBoxKick, DIALOG_STYLE_MSGBOX, "No Account Exists", string, "OK", "");
            return 1;
        }

        /*
        * Show player the login dialog
        */
        format(string, sizeof string, "This account (%s) is registered. Please login by entering your password in the field below:", player[playerid][Name]);
        Dialog_Show(playerid, LoginDialog, DIALOG_STYLE_PASSWORD, "Login", string, "Login", "Abort");
    }
    else
    {
        format(string, sizeof string, "No account found with the username '%s'.\nPlease create an account on %s.", player[playerid][Name], SERVER_WEBSITE);
		Dialog_Show(playerid, MessageBoxKick, DIALOG_STYLE_MSGBOX, "No Account Exists", string, "OK", "");
    }
	return 1;
}

forward OnPasswordVerify(playerid, bool:success);
public OnPasswordVerify(playerid, bool:success)
{
    if(success)
    {
        new query[256];
		mysql_format(database, query, sizeof(query), 
            "SELECT `id`, `admin`, `vip`, `isnew`, `regdate` FROM `accounts` WHERE `username` = '%e' LIMIT 1", 
            player[playerid][Name]);

        mysql_tquery(database, query, "OnPlayerLogin", "dd", playerid, mysqlRaceCheck[playerid]);
    } 
    else
    {
        player[playerid][LoginAttempts]++;

		if (player[playerid][LoginAttempts] >= 3)
		{
			SendClientMessage(playerid, COLOR_RED, "You have input the wrong password too many times.");
			DelayedKick(playerid, 500);
		}
		else 
		{
			Dialog_Show(playerid, LoginDialog, DIALOG_STYLE_PASSWORD, "Login", "Wrong password!\nPlease enter your password in the field below:", "Login", "Abort");
		}
    }
}

forward OnPlayerLogin(playerid, raceCheck);
public OnPlayerLogin(playerid, raceCheck)
{
	if (raceCheck != mysqlRaceCheck[playerid]) 
	{
        SendClientMessage(playerid, COLOR_RED, "An error occured. Please reconnect.");
        DelayedKick(playerid, 500);
        return 1;
    }

    if(cache_num_rows() > 0)
    {
        cache_get_value_name_int(0, "id", player[playerid][ID]);
        cache_get_value_name_int(0, "admin", player[playerid][admin]);
        cache_get_value_name_int(0, "vip", player[playerid][vip]);
        cache_get_value_name_int(0, "isnew", player[playerid][isNew]);
        cache_get_value_name_int(0, "regdate", player[playerid][regdate]);

		// update last login, IP, and Serial
		player[playerid][lastlogin] = gettime();
        
        new query[256];
        mysql_format(database, query, sizeof(query), 
            "UPDATE `accounts` SET `ip` = '%e', `serial` = '%e', `lastlogin` = %d WHERE `username` = '%e'", 
            player[playerid][ip], player[playerid][serial], player[playerid][lastlogin], player[playerid][Name]);
        mysql_tquery(database, query);

		/*
		* Player is now logged in
		*/
		KillTimer(player[playerid][LoginTimer]);
		player[playerid][LoginTimer] = 0;
		player[playerid][IsLoggedIn] = true;
		PopulateCharacterMenu(playerid);
    }
    else
    {
        Kick(playerid);
    }
    return 1;
}

forward OnUserPasswordChange(playerid);
public OnUserPasswordChange(playerid)
{
    new dest[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(dest);

    new query[256];
	mysql_format(database, query, sizeof(query), 
        "UPDATE `accounts` SET `password` = '%e' WHERE `username` = '%e'", 
        dest, player[playerid][Name]);
    mysql_tquery(database, query, "OnPasswordChangeComplete", "d", playerid);
}

forward OnPasswordChangeComplete(playerid);
public OnPasswordChangeComplete(playerid)
{
    if(!IsPlayerConnected(playerid))
        return 0;
    
    if(cache_affected_rows() > 0)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, "Your password has been successfully changed!");
    }
    else
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Failed to change password. Please try again or contact an administrator.");
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You can also try changing your password on the website if the problem persists.");
    }
    return 1;
}

// ============================================================================
// CHARACTER MANAGEMENT
// ============================================================================

OnPlayerCharacterDataLoaded(playerid)
{
	new query[256];
    mysql_format(database, query, sizeof(query), 
        "SELECT * FROM `characters` WHERE `name` = '%e' LIMIT 1", 
        player[playerid][chosenChar]);

    mysql_tquery(database, query, "OnCharacterDataReceived", "dd", playerid, mysqlRaceCheck[playerid]);
	return 1;
}

forward OnCharacterDataReceived(playerid, raceCheck);
public OnCharacterDataReceived(playerid, raceCheck)
{
	if (raceCheck != mysqlRaceCheck[playerid]) 
	{
        SendClientMessage(playerid, COLOR_RED, "An error occured. Please reconnect.");
        DelayedKick(playerid, 500);
        return 1;
    }

	if(cache_num_rows() > 0)
    {
		cache_get_value_name_int(0, "id", player[playerid][charid]);
		cache_get_value_name_int(0, "age", player[playerid][age]);
		cache_get_value_name(0, "description", player[playerid][description], 128);
		cache_get_value_name_int(0, "skin", player[playerid][skin]);
		cache_get_value_name_int(0, "iszombie", player[playerid][iszombie]);
		cache_get_value_name_float(0, "health", player[playerid][health]);
		cache_get_value_name_float(0, "maxhealth", player[playerid][maxHealth]);
		cache_get_value_name_int(0, "hunger", player[playerid][hunger]);
		cache_get_value_name_int(0, "maxhunger", player[playerid][maxHunger]);
		cache_get_value_name_int(0, "thirst", player[playerid][thirst]);
		cache_get_value_name_int(0, "maxthirst", player[playerid][maxThirst]);
		cache_get_value_name_int(0, "disease", player[playerid][disease]);
		cache_get_value_name_int(0, "maxdisease", player[playerid][maxDisease]);
		cache_get_value_name_int(0, "spawned", player[playerid][spawned]);
		cache_get_value_name_float(0, "px", player[playerid][pPos][0]);
		cache_get_value_name_float(0, "py", player[playerid][pPos][1]);
		cache_get_value_name_float(0, "pz", player[playerid][pPos][2]);
		cache_get_value_name_float(0, "pa", player[playerid][pPos][3]);
		cache_get_value_name_int(0, "interior", player[playerid][plrinterior]);
		cache_get_value_name_int(0, "virtualworld", player[playerid][world]);
		cache_get_value_name_int(0, "level", player[playerid][level]);
		cache_get_value_name_int(0, "exp", player[playerid][exp]);
		cache_get_value_name_int(0, "perkpoints", player[playerid][perkPoints]);
		cache_get_value_name_int(0, "fuelcanamount", playerInventoryResource[playerid][28]);

		// weapon slot data
		cache_get_value_name_int(0, "wepslot0", player[playerid][wepSlot][0]);
		cache_get_value_name_int(0, "wepslot1", player[playerid][wepSlot][1]);
		cache_get_value_name_int(0, "wepslot2", player[playerid][wepSlot][2]);
		cache_get_value_name_int(0, "wepslot3", player[playerid][wepSlot][3]);
		cache_get_value_name_int(0, "wepslot4", player[playerid][wepSlot][4]);
		cache_get_value_name_int(0, "wepslot5", player[playerid][wepSlot][5]);
		cache_get_value_name_int(0, "wepslot6", player[playerid][wepSlot][6]);
		cache_get_value_name_int(0, "wepslot7", player[playerid][wepSlot][7]);
		cache_get_value_name_int(0, "wepslot8", player[playerid][wepSlot][8]);
		cache_get_value_name_int(0, "wepslot9", player[playerid][wepSlot][9]);
		cache_get_value_name_int(0, "wepslot10", player[playerid][wepSlot][10]);
		cache_get_value_name_int(0, "wepslot11", player[playerid][wepSlot][11]);
		cache_get_value_name_int(0, "wepslot12", player[playerid][wepSlot][12]);
		
		// Load human skills
		cache_get_value_name_int(0, "tinkererskilllevel", player[playerid][tinkererSkillLevel]);
        cache_get_value_name_int(0, "mechanicskilllevel", player[playerid][mechanicSkillLevel]);
        cache_get_value_name_int(0, "medicskilllevel", player[playerid][medicSkillLevel]);
        cache_get_value_name_int(0, "gourmetskilllevel", player[playerid][gourmetSkillLevel]);

		// Load perks
        new tempInt;
		cache_get_value_name_int(0, "unlockedjump", tempInt);
        player[playerid][unlockedJumpSkill] = bool:tempInt;
		cache_get_value_name_int(0, "unlockedunarmed", player[playerid][unlockedUnarmedSkill]);
		cache_get_value_name_int(0, "unlockedbite", tempInt);
        player[playerid][unlockedBiteSkill] = bool:tempInt;
		cache_get_value_name_int(0, "unlockedcombust", tempInt);
        player[playerid][unlockedCombustSkill] = bool:tempInt;
		cache_get_value_name_int(0, "unlockedstun", tempInt);
        player[playerid][unlockedStunSkill] = bool:tempInt;
		cache_get_value_name_int(0, "unlockedgrab", tempInt);
        player[playerid][unlockedGrabSkill] = bool:tempInt;
		cache_get_value_name_int(0, "unlockedbstr", tempInt);
        player[playerid][unlockedBorrowedStrengthSkill] = bool:tempInt;
		cache_get_value_name_int(0, "unlockedsjump", tempInt);
        player[playerid][unlockedSuperJumpSkill] = bool:tempInt;
		cache_get_value_name_int(0, "unlockedcorn", tempInt);
        player[playerid][unlockedCorneredSkill] = bool:tempInt;
		cache_get_value_name_int(0, "unlockedhpinc", player[playerid][unlockedHpIncreaseSkill]);
		cache_get_value_name_int(0, "unlockedhunt", tempInt);
        player[playerid][unlockedHuntSkill] = bool:tempInt;
		
        /*
		* Set the character's spawn up
		*/
		new randSpawn = random(4);
		if(player[playerid][iszombie] == 0)
		{
			if(player[playerid][spawned] == 0)
			{
				SetSpawnInfo(playerid, NO_TEAM, player[playerid][skin], humanSpawns[randSpawn][0], humanSpawns[randSpawn][1], humanSpawns[randSpawn][2], humanSpawns[randSpawn][3], 0, 0, 0, 0, 0, 0);
			}
			else
			{
				SetSpawnInfo(playerid, NO_TEAM, player[playerid][skin], player[playerid][pPos][0], player[playerid][pPos][1], player[playerid][pPos][2], player[playerid][pPos][3], 0, 0, 0, 0, 0, 0);
			}
		}
		else
		{
			if(player[playerid][spawned] == 0)
			{
				SetSpawnInfo(playerid, TEAM_ZOMBIE, player[playerid][skin], zombieSpawns[randSpawn][0], zombieSpawns[randSpawn][1], zombieSpawns[randSpawn][2], zombieSpawns[randSpawn][3], 0, 0, 0, 0, 0, 0);
			}
			else
			{
				SetSpawnInfo(playerid, TEAM_ZOMBIE, player[playerid][skin], player[playerid][pPos][0], player[playerid][pPos][1], player[playerid][pPos][2], player[playerid][pPos][3], 0, 0, 0, 0, 0, 0);
			}
		}
		SetPlayerName(playerid, player[playerid][chosenChar]);
		SetPlayerScore(playerid, player[playerid][level]);
		
		/*
		* Now spawn the player
		*/
		TogglePlayerSpectating(playerid, false);
		player[playerid][isSpawned] = true;
		player[playerid][spawned] = 1;
		SetPlayerInterior(playerid, player[playerid][plrinterior]);
		SetPlayerVirtualWorld(playerid, player[playerid][world]);
        
        /*
        * Reset inventory variables to prevent data from previous character carrying over
        */
        for(new i = 0; i < MAX_ITEMS; i++)
        {
            playerInventory[playerid][i] = 0;
            playerInventoryResource[playerid][i] = 0;
        }
        
        /*
        * Load/Create player's inventory data file
        * As long as they are not a Zombie character
        */
        if(player[playerid][iszombie] == 0)
        {
            LoadCharacterInventory(playerid);
        }
        
        /*
        * Load player's faction data
        */
        LoadPlayerFaction(playerid, player[playerid][chosenChar]);

		/*
		* Small timer to freeze the player to stop them falling through maps
		*/
		TogglePlayerControllable(playerid, false);
		GameTextForPlayer(playerid, "...Spawning...", 1500, 3);
		SetTimerEx("SpawnTimer", 1500, false, "d", playerid);

		/*
		* Set health and HUD
		*/
		SetPlayerMaxHealth(playerid, player[playerid][maxHealth]);
		SetPlayerHealth(playerid, player[playerid][health]);
        UpdateHudElementForPlayer(playerid, HUD_HEALTH);

		/*
		* Specific actions depending on if character is a zombie or not
		*/
		if(player[playerid][iszombie] == 0)
		{
			UpdateHudElementForPlayer(playerid, HUD_HUNGER);
			UpdateHudElementForPlayer(playerid, HUD_THIRST);
			UpdateHudElementForPlayer(playerid, HUD_DISEASE);
			ShowHudForPlayer(playerid, HUD_ALL);
			player[playerid][hungerTimer] = SetTimerEx("HungerTimer", HUNGER_TIMER_DURATION, true, "d", playerid);
			player[playerid][thirstTimer] = SetTimerEx("ThirstTimer", THIRST_TIMER_DURATION, true, "d", playerid);
			player[playerid][diseaseTimer] = SetTimerEx("DiseaseTimer", DISEASE_TIMER_DURATION, true, "d", playerid);
			SetPlayerColor(playerid, COLOR_WHITE);
			
			/*
			* Make sure all /search text labels are visible for humans
			*/
			for(new i = 0; i < scavAreaCount; i++)
			{
				if(scavArea[i][areaActive])
				{
					Streamer_ToggleItem(playerid, STREAMER_TYPE_3D_TEXT_LABEL, scavTextLabel[i], true);
				}
			}
            
            // now give the player their weapons (if they have any equipped)
            GivePlayerWeapon(playerid, player[playerid][wepSlot][0], 1); // fist or brass knuckles
            GivePlayerWeapon(playerid, player[playerid][wepSlot][1], 1); // melee weapons
            GivePlayerWeapon(playerid, player[playerid][wepSlot][2], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][2])]); // pistols
            GivePlayerWeapon(playerid, player[playerid][wepSlot][3], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][3])]); // shotguns
            GivePlayerWeapon(playerid, player[playerid][wepSlot][4], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][4])]); // uzi/tec-9/mp5
            GivePlayerWeapon(playerid, player[playerid][wepSlot][5], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][5])]); // ak/m4
            GivePlayerWeapon(playerid, player[playerid][wepSlot][6], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][6])]); // rifles
		}
		else // is a zombie so only show health
		{
			ShowHudForPlayer(playerid, HUD_HEALTH);
			ShowHudForPlayer(playerid, HUD_CLOCK);
			SetPlayerColor(playerid, COLOR_YELLOW);
			
			/*
			* Hide all /search text labels for zombies since they can't search
			*/
			for(new i = 0; i < scavAreaCount; i++)
			{
				if(scavArea[i][areaActive])
				{
					Streamer_ToggleItem(playerid, STREAMER_TYPE_3D_TEXT_LABEL, scavTextLabel[i], false);
				}
			}
		}

		/*
		* Update the HUD_INFO so it shows the correct text depending on if the character is a zombie or not
		*/
		UpdateHudElementForPlayer(playerid, HUD_INFO);
	}
	else
	{
		/*
		* Some horrible error occured, kick the player.
		* This state should never be reached.
		*/
		Kick(playerid);
	}

	// start the timer to save player's location occasionally
	player[playerid][locationTimer] = SetTimerEx("TimedSavePlayerCharacterLocation", LOCATION_TIMER_DURATION, true, "d", playerid);
	return 1;
}

SavePlayerCharacterLocation(playerid, const currentCharacter[])
{
    /*
	* Get player's location data
	*/
	GetPlayerPos(playerid, player[playerid][pPos][0], player[playerid][pPos][1], player[playerid][pPos][2]);
	GetPlayerFacingAngle(playerid, player[playerid][pPos][3]);
	player[playerid][plrinterior] = GetPlayerInterior(playerid);
	player[playerid][world] = GetPlayerVirtualWorld(playerid);

	/*
	* Run the query to update the player character entry in the database
	*/
    new query[512];
	mysql_format(database, query, sizeof(query), 
        "UPDATE `characters` SET `px` = %f, `py` = %f, `pz` = %f, `pa` = %f, `interior` = %d, `virtualworld` = %d WHERE `name` = '%e'", 
        player[playerid][pPos][0], player[playerid][pPos][1], player[playerid][pPos][2], player[playerid][pPos][3], 
        player[playerid][plrinterior], player[playerid][world], currentCharacter);
    mysql_tquery(database, query);
    return 1;
}

SavePlayerCharacter(playerid, const currentCharacter[])
{
	/*
	* Get player's location data
	*/
	GetPlayerPos(playerid, player[playerid][pPos][0], player[playerid][pPos][1], player[playerid][pPos][2]);
	GetPlayerFacingAngle(playerid, player[playerid][pPos][3]);
	player[playerid][plrinterior] = GetPlayerInterior(playerid);
	player[playerid][world] = GetPlayerVirtualWorld(playerid);

	/*
	* Run the query to update the player character entry in the database
	*/
    new query[1024];
	mysql_format(database, query, sizeof(query), 
        "UPDATE `characters` SET `health` = %f, `maxhealth` = %f, `hunger` = %d, `maxhunger` = %d, `thirst` = %d, `maxthirst` = %d, \
        `disease` = %d, `maxdisease` = %d, `spawned` = %d, `px` = %f, `py` = %f, `pz` = %f, `pa` = %f, `interior` = %d, `virtualworld` = %d, \
        `level` = %d, `exp` = %d, `perkpoints` = %d, `fuelcanamount` = %d, `tinkererskilllevel` = %d, `mechanicskilllevel` = %d, \
        `medicskilllevel` = %d, `gourmetskilllevel` = %d WHERE `name` = '%e'", 
        player[playerid][health], player[playerid][maxHealth], player[playerid][hunger], player[playerid][maxHunger], player[playerid][thirst], 
        player[playerid][maxThirst], player[playerid][disease], player[playerid][maxDisease], player[playerid][spawned], player[playerid][pPos][0], 
        player[playerid][pPos][1], player[playerid][pPos][2], player[playerid][pPos][3], player[playerid][plrinterior], player[playerid][world], 
        player[playerid][level], player[playerid][exp], player[playerid][perkPoints], playerInventoryResource[playerid][28], player[playerid][tinkererSkillLevel], 
        player[playerid][mechanicSkillLevel], player[playerid][medicSkillLevel], player[playerid][gourmetSkillLevel], currentCharacter);
    mysql_tquery(database, query);

	/*
	* Kill the timers
	*/
	KillTimer(player[playerid][hungerTimer]);
    KillTimer(player[playerid][thirstTimer]);
	KillTimer(player[playerid][diseaseTimer]);
	KillTimer(player[playerid][fuelTimer]);
	KillTimer(player[playerid][fillVehicleTimer]);
	KillTimer(player[playerid][locationTimer]);
	return 1;
}

UpdatePlayerWepslotEntry(wepslotid, weaponid, const currentCharacter[])
{
    new query[256];
	mysql_format(database, query, sizeof(query), 
        "UPDATE `characters` SET `wepslot%d` = %d WHERE `name` = '%e'", 
        wepslotid, weaponid, currentCharacter);
    mysql_tquery(database, query);
	return 1;
}

// ============================================================================
// INTERIOR SYSTEM
// ============================================================================

/*
* Load Interior data
*/
LoadInteriorData(interiorid)
{
	new query[256];
    mysql_format(database, query, sizeof(query), 
        "SELECT * FROM `interiors` WHERE `id` = %d LIMIT 1", interiorid);
    
    mysql_tquery(database, query, "OnInteriorDataLoaded", "d", interiorid);
	return 1;
}

forward OnInteriorDataLoaded(interiorid);
public OnInteriorDataLoaded(interiorid)
{
	if(cache_num_rows() > 0)
    {
        cache_get_value_name(0, "name", srvInterior[interiorid][intName]);
		cache_get_value_name_int(0, "intworld", srvInterior[interiorid][intWorld]);
		cache_get_value_name_int(0, "virworld", srvInterior[interiorid][intVirWorld]);
		cache_get_value_name_int(0, "intworldexit", srvInterior[interiorid][intExitWorld]);
		cache_get_value_name_int(0, "virworldexit", srvInterior[interiorid][intExitVirWorld]);
		cache_get_value_name_int(0, "purchaseprice", srvInterior[interiorid][intPrice]);
		cache_get_value_name_int(0, "interiortype", srvInterior[interiorid][intType]);
		cache_get_value_name(0, "owner", srvInterior[interiorid][intOwner]);
		cache_get_value_name_int(0, "islocked", srvInterior[interiorid][intLocked]);
		cache_get_value_name_float(0, "penterx1", srvInterior[interiorid][intEnter][0]);
		cache_get_value_name_float(0, "pentery1", srvInterior[interiorid][intEnter][1]);
		cache_get_value_name_float(0, "penterz1", srvInterior[interiorid][intEnter][2]);
		cache_get_value_name_float(0, "penterx2", srvInterior[interiorid][intEnter][3]);
		cache_get_value_name_float(0, "pentery2", srvInterior[interiorid][intEnter][4]);
		cache_get_value_name_float(0, "penterz2", srvInterior[interiorid][intEnter][5]);
		cache_get_value_name_float(0, "pentera", srvInterior[interiorid][intEnter][6]);
		cache_get_value_name_float(0, "pexitx1", srvInterior[interiorid][intExit][0]);
		cache_get_value_name_float(0, "pexity1", srvInterior[interiorid][intExit][1]);
		cache_get_value_name_float(0, "pexitz1", srvInterior[interiorid][intExit][2]);
		cache_get_value_name_float(0, "pexitx2", srvInterior[interiorid][intExit][3]);
		cache_get_value_name_float(0, "pexity2", srvInterior[interiorid][intExit][4]);
		cache_get_value_name_float(0, "pexitz2", srvInterior[interiorid][intExit][5]);
		cache_get_value_name_float(0, "pexita", srvInterior[interiorid][intExit][6]);
        
        /*
        * Create and display the text above a pickup
        */
        CreateInteriorPickup(interiorid);
        
        // map icons
        srvInterior[interiorid][mapIcon] = CreateDynamicMapIcon(srvInterior[interiorid][intEnter][0], srvInterior[interiorid][intEnter][1], srvInterior[interiorid][intEnter][2], 0, COLOR_LIGHTGREEN, 0, 0);
    }
	return 1;
}

/*
* Populate the character menu
*/
PopulateCharacterMenu(playerid)
{
	/*
	* Show character menu
	*/
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "SELECT `name`, `skin` FROM `characters` WHERE `owner` = %d LIMIT %d", 
        player[playerid][ID], MAX_CHARACTERS);
    
    mysql_tquery(database, query, "OnCharacterListLoaded", "d", playerid);
	return 1;
}

forward OnCharacterListLoaded(playerid);
public OnCharacterListLoaded(playerid)
{
    new charName[MAX_PLAYER_NAME], tmpSkin, List:skins = list_new();
    
    AddModelMenuItem(skins, 18631, "Create New");
    
    if(cache_num_rows() > 0)
    {
        for(new i = 0; i < cache_num_rows(); i++)
        {
            cache_get_value_name(i, "name", charName, MAX_PLAYER_NAME);
            cache_get_value_name_int(i, "skin", tmpSkin);
            AddModelMenuItem(skins, tmpSkin, RemoveUnderscoreFromName(charName));
        }
    }
    
    player[playerid][characterCount] = list_size(skins);
    ShowModelSelectionMenu(playerid, "Select Your Character / Create A New One", CHARACTER_SELECTION_SKIN_MENU, skins);
    return 1;
}

// ============================================================================
// SCAVENGING SYSTEM
// ============================================================================

/*
* Scavenging Locations
*/
LoadScavArea(scavAreaId)
{
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "SELECT * FROM `scavareas` WHERE `id` = %d LIMIT 1", scavAreaId);
    mysql_tquery(database, query, "OnScavAreaLoaded", "d", scavAreaId);
    return 1;
}

forward OnScavAreaLoaded(scavAreaId);
public OnScavAreaLoaded(scavAreaId)
{
	if(cache_num_rows() > 0)
    {
        cache_get_value_name_float(0, "posx", scavArea[scavAreaId][scavPos][0]);
        cache_get_value_name_float(0, "posy", scavArea[scavAreaId][scavPos][1]);
        cache_get_value_name_float(0, "posz", scavArea[scavAreaId][scavPos][2]);
        cache_get_value_name_int(0, "interior", scavArea[scavAreaId][scavInterior]);
        cache_get_value_name_int(0, "world", scavArea[scavAreaId][scavWorld]);
        cache_get_value_name_int(0, "type", scavArea[scavAreaId][scavType]);
        scavArea[scavAreaId][areaActive] = true;
        
        // create the text label
        scavTextLabel[scavAreaId] = CreateDynamic3DTextLabel("/search", COLOR_GREEN, scavArea[scavAreaId][scavPos][0], scavArea[scavAreaId][scavPos][1], scavArea[scavAreaId][scavPos][2], 20.0, 
            .testlos = 1, .worldid = scavArea[scavAreaId][scavWorld], .interiorid = scavArea[scavAreaId][scavInterior]);
    }
    return 1;
}

CreateScavArea(Float:scavPosX, Float:scavPosY, Float:scavPosZ, scavIntWorld, scavVirWorld, areaType)
{
    new query[512];
    mysql_format(database, query, sizeof(query), 
        "INSERT INTO `scavareas` (`posx`, `posy`, `posz`, `interior`, `world`, `type`) VALUES (%f, %f, %f, %d, %d, %d)", 
        scavPosX, scavPosY, scavPosZ, scavIntWorld, scavVirWorld, areaType);
    mysql_tquery(database, query, "OnScavAreaCreated", "ffffdd", scavPosX, scavPosY, scavPosZ, scavIntWorld, scavVirWorld, areaType);
    return 1;
}

forward OnScavAreaCreated(Float:scavPosX, Float:scavPosY, Float:scavPosZ, scavIntWorld, scavVirWorld, areaType);
public OnScavAreaCreated(Float:scavPosX, Float:scavPosY, Float:scavPosZ, scavIntWorld, scavVirWorld, areaType)
{
    new tmpScavId = cache_insert_id();
    
    // update the array size
    scavAreaCount = scavAreaCount + 1;
    
    // set the data for this new scav area
    scavArea[tmpScavId][scavPos][0] = scavPosX;
    scavArea[tmpScavId][scavPos][1] = scavPosY;
    scavArea[tmpScavId][scavPos][2] = scavPosZ;
    scavArea[tmpScavId][scavInterior] = scavIntWorld;
    scavArea[tmpScavId][scavWorld] = scavVirWorld;
    scavArea[tmpScavId][scavType] = areaType;
    scavArea[tmpScavId][areaActive] = true;
    
    // create the text label
    scavTextLabel[tmpScavId] = CreateDynamic3DTextLabel("/search", COLOR_GREEN, scavPosX, scavPosY, scavPosZ, 20.0, 
        .testlos = 1, .worldid = scavVirWorld, .interiorid = scavIntWorld);
    return 1;
}

// ============================================================================
// ITEM/LOOT SYSTEM
// ============================================================================

/*
* Server items
*/
LoadServerItems(item)
{
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "SELECT * FROM `items` WHERE `id` = %d LIMIT 1", item);
    mysql_tquery(database, query, "OnServerItemLoaded", "d", item);
    return 1;
}

forward OnServerItemLoaded(item);
public OnServerItemLoaded(item)
{
	if(cache_num_rows() > 0)
    {
        inventoryItems[item][itemId] = item;
        cache_get_value_name(0, "sname", inventoryItems[item][itemNameSingular], 128);
        cache_get_value_name(0, "pname", inventoryItems[item][itemNamePlural], 128);
        cache_get_value_name(0, "description", inventoryItems[item][itemDescription], 128);
		cache_get_value_name_int(0, "category", inventoryItems[item][itemCategory]);
        cache_get_value_name_int(0, "healamount", inventoryItems[item][itemHealAmount]);
        cache_get_value_name_int(0, "wepid", inventoryItems[item][itemWepId]);
        cache_get_value_name_int(0, "ammoid", inventoryItems[item][itemAmmoId]);
        cache_get_value_name_int(0, "wepslot", inventoryItems[item][itemWepSlot]);
        
        new tempInt;
        cache_get_value_name_int(0, "isusable", tempInt);
        inventoryItems[item][isUsable] = bool:tempInt;
        
        cache_get_value_name_int(0, "maxresource", inventoryItems[item][itemMaxResource]);
        cache_get_value_name_int(0, "itemvalue", inventoryItems[item][itemValue]);
    }
    return 1;
}

CreateServerItem(const nameSingular[], const namePlural[], const itemDesc[], category, healamount, wepid, ammoid, wepslot, bool:isusable, maxresource)
{
    new query[512];
    mysql_format(database, query, sizeof(query), 
        "INSERT INTO `items` (`sname`, `pname`, `description`, `category`, `healamount`, `wepid`, `ammoid`, `wepslot`, `isusable`, `maxresource`) \
        VALUES ('%e', '%e', '%e', %d, %d, %d, %d, %d, %d, %d)", 
        nameSingular, namePlural, itemDesc, category, healamount, wepid, ammoid, wepslot, isusable, maxresource);
    mysql_tquery(database, query);

    // update the array size
    serverItemCount = serverItemCount + 1;
    return 1;
}

/*
 * ============================================================================
 * DEPRECATED LOOT TABLE FUNCTIONS
 * ============================================================================
 * These functions are no longer used as of the XML loot table system migration.
 * They have been commented out but preserved for reference.
 * The new system uses LoadLootTablesFromXML() in modules/systems/inventory.pwn
 * ============================================================================
 */

/*
LoadServerLootTable(lootTableId)
{
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "SELECT * FROM `loottable` WHERE `id` = %d LIMIT 1", lootTableId + 1);
    mysql_tquery(database, query, "OnLootTableLoaded", "d", lootTableId);
    return 1;
}

forward OnLootTableLoaded(lootTableId);
public OnLootTableLoaded(lootTableId)
{
    new fieldName[10];
	if(cache_num_rows() > 0)
    {
        cache_get_value_name(0, "name", lootTableName[lootTableId]);
        for(new i = 0; i < CHANCE; i++)
        {
            format(fieldName, sizeof(fieldName), "chance%d", i);
            cache_get_value_name_int(0, fieldName, lootTable[lootTableId][i]);
        }
    }
    return 1;
}

UpdateLootTableEntry(const tableName[], tableid, chanceNode, itemid)
{
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "UPDATE `loottable` SET `chance%d` = %d WHERE `name` = '%e'", 
        chanceNode, itemid, tableName);
    mysql_tquery(database, query);
    
    lootTable[tableid][chanceNode] = itemid;
    return 1;
}

PopulateLootTableList(playerid)
{
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "SELECT `name` FROM `loottable` LIMIT %d", lootTableCount);
    mysql_tquery(database, query, "OnLootTableListLoaded", "d", playerid);
	return 1;
}

forward OnLootTableListLoaded(playerid);
public OnLootTableListLoaded(playerid)
{
    new tmpTableName[32];
    
    if(cache_num_rows() > 0)
    {
        for(new i = 0; i < cache_num_rows(); i++)
        {
            cache_get_value_name(i, "name", tmpTableName, 32);
            AddDialogListitem(playerid, tmpTableName);
        }
    }
    
    ShowPlayerDialogPages(playerid, "ShowLootTableAdminList", DIALOG_STYLE_LIST, "Select a Loot Table", "Select", "Quit", 10);
    return 1;
}

PopulateLootTableChanceList(playerid, const chosenTable[])
{
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "SELECT * FROM `loottable` WHERE `name` = '%e' LIMIT 1", chosenTable);
    mysql_tquery(database, query, "OnLootTableChanceListLoaded", "d", playerid);
    return 1;
}

forward OnLootTableChanceListLoaded(playerid);
public OnLootTableChanceListLoaded(playerid)
{
    new tmpChance, fieldName[10], tmpChanceToString[5];
    
    if(cache_num_rows() > 0)
    {
        for(new i = 0; i < CHANCE; i++)
        {
            format(fieldName, sizeof(fieldName), "chance%d", i);
            cache_get_value_name_int(0, fieldName, tmpChance);
            format(tmpChanceToString, sizeof(tmpChanceToString), "%d", tmpChance);
            AddDialogListitem(playerid, tmpChanceToString);
        }
    }
    
    ShowPlayerDialogPages(playerid, "ShowLootTableChanceList", DIALOG_STYLE_LIST, "Select an Item ID to edit", "Select", "Quit", 10);
    return 1;
}
*/

/*
* Character Inventory
*/
CreateCharacterInventory(playerid)
{
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "INSERT INTO `inventory` (`character`) VALUES ('%e')", player[playerid][chosenChar]);
    mysql_tquery(database, query);
    return 1;
}

LoadCharacterInventory(playerid)
{
    new query[256], timeMs = GetTickCount();
    mysql_format(database, query, sizeof(query), 
        "SELECT * FROM `inventory` WHERE `character` = '%e' LIMIT 1", player[playerid][chosenChar]);
    mysql_tquery(database, query, "OnCharacterInventoryLoaded", "dd", playerid, timeMs);
    return 1;
}

forward OnCharacterInventoryLoaded(playerid, timeMs);
public OnCharacterInventoryLoaded(playerid, timeMs)
{
    new fieldName[10];
	if(cache_num_rows() > 0)
    {
        for(new i = 1; i < MAX_ITEMS; i++)
        {
            format(fieldName, sizeof(fieldName), "item%d", i);
            cache_get_value_name_int(0, fieldName, playerInventory[playerid][i]);
        }
    }
    printf("|-> %s Inventory Loaded in %d ms", player[playerid][chosenChar], GetTickCount() - timeMs);
    return 1;
}

UpdateCharacterInventoryEntry(playerid, itemid)
{
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "UPDATE `inventory` SET `item%d` = %d WHERE `character` = '%e'", 
        itemid, playerInventory[playerid][itemid], player[playerid][chosenChar]);
    mysql_tquery(database, query);
    return 1;
}

// ============================================================================
// FUEL SYSTEM
// ============================================================================

/*
* Fuel Pumps
*/
CreateFuelPump(Float:fuelPosX, Float:fuelPosY, Float:fuelPosZ)
{
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "INSERT INTO `fuelpump` (`posx`, `posy`, `posz`) VALUES (%f, %f, %f)", 
        fuelPosX, fuelPosY, fuelPosZ);
    mysql_tquery(database, query, "OnFuelPumpCreated", "fff", fuelPosX, fuelPosY, fuelPosZ);
    return 1;
}

forward OnFuelPumpCreated(Float:fuelPosX, Float:fuelPosY, Float:fuelPosZ);
public OnFuelPumpCreated(Float:fuelPosX, Float:fuelPosY, Float:fuelPosZ)
{
    new tmpPumpId = cache_insert_id() - 1;

    // update the array size
    fuelPumpCount = fuelPumpCount + 1;
    
    // set the data for this new scav area
    fuelPump[tmpPumpId][0] = fuelPosX;
    fuelPump[tmpPumpId][1] = fuelPosY;
    fuelPump[tmpPumpId][2] = fuelPosZ;
    
    // create the text label
    fillTextLabel[tmpPumpId] = CreateDynamic3DTextLabel("/fill", COLOR_YELLOW, fuelPosX, fuelPosY, fuelPosZ, 20.0, .testlos = 1);
    return 1;
}

LoadFuelPumps(pumpId)
{
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "SELECT * FROM `fuelpump` WHERE `id` = %d LIMIT 1", pumpId + 1);
    mysql_tquery(database, query, "OnFuelPumpLoaded", "d", pumpId);
    return 1;
}

forward OnFuelPumpLoaded(pumpId);
public OnFuelPumpLoaded(pumpId)
{
	if(cache_num_rows() > 0)
    {
        cache_get_value_name_float(0, "posx", fuelPump[pumpId][0]);
        cache_get_value_name_float(0, "posy", fuelPump[pumpId][1]);
        cache_get_value_name_float(0, "posz", fuelPump[pumpId][2]);
        
        // create the text label
        fillTextLabel[pumpId] = CreateDynamic3DTextLabel("/fill", COLOR_YELLOW, fuelPump[pumpId][0], fuelPump[pumpId][1], fuelPump[pumpId][2], 20.0, .testlos = 1);
    }
    return 1;
}

// ============================================================================
// SERVER STATS
// ============================================================================

/*
* Setup all of the server load stats
*/
GetServerLoadStats()
{
    // Run all count queries in parallel (non-blocking!)
    mysql_tquery(database, "SELECT COUNT(*) AS `total` FROM `accounts`", "OnAccountCountLoaded");
    mysql_tquery(database, "SELECT COUNT(*) AS `total` FROM `characters`", "OnCharacterCountLoaded");
    mysql_tquery(database, "SELECT COUNT(*) AS `total` FROM `interiors`", "OnInteriorCountLoaded");
    mysql_tquery(database, "SELECT COUNT(*) AS `total` FROM `scavareas`", "OnScavAreaCountLoaded");
    mysql_tquery(database, "SELECT COUNT(*) AS `total` FROM `items`", "OnItemsCountLoaded");
    mysql_tquery(database, "SELECT COUNT(*) AS `total` FROM `loottable`", "OnLootTableCountLoaded");
    mysql_tquery(database, "SELECT COUNT(*) AS `total` FROM `fuelpump`", "OnFuelPumpCountLoaded");
}

forward OnAccountCountLoaded();
public OnAccountCountLoaded()
{
    new count;
    cache_get_value_name_int(0, "total", count);
	print("-------------------------------------");
    printf("|-> Database has %d accounts", count);
    return 1;
}

forward OnCharacterCountLoaded();
public OnCharacterCountLoaded()
{
    new count;
    cache_get_value_name_int(0, "total", count);
    printf("|-> Database has %d characters", count);
    return 1;
}

forward OnInteriorCountLoaded();
public OnInteriorCountLoaded()
{
    cache_get_value_name_int(0, "total", serverInteriorCount);
	printf("|-> Database has %d interiors (MAX: %d)", serverInteriorCount, MAX_SERVER_INTERIORS);
    return 1;
}

forward OnScavAreaCountLoaded();
public OnScavAreaCountLoaded()
{
    cache_get_value_name_int(0, "total", scavAreaCount);
	printf("|-> Database has %d scav areas (MAX: %d)", scavAreaCount, MAX_SCAV_AREAS);
    return 1;
}

forward OnItemsCountLoaded();
public OnItemsCountLoaded()
{
    cache_get_value_name_int(0, "total", serverItemCount);
	printf("|-> Database has %d server items (MAX: %d)", serverItemCount, MAX_ITEMS);
    return 1;
}

forward OnLootTableCountLoaded();
public OnLootTableCountLoaded()
{
    cache_get_value_name_int(0, "total", lootTableCount);
	printf("|-> Database has %d loot tables (MAX: %d)", lootTableCount, MAX_LOOT_TABLES);
    return 1;
}

forward OnFuelPumpCountLoaded();
public OnFuelPumpCountLoaded()
{
    cache_get_value_name_int(0, "total", fuelPumpCount);
	printf("|-> Database has %d fuel pumps (MAX: %d)", fuelPumpCount, MAX_FUEL_PUMPS);
	print("-------------------------------------");
    return 1;
}

/*
* Log an admin command usage to the database
* 
* @param adminid - The player ID of the admin using the command
* @param command[] - The command name (without /)
* @param params[] - The parameters used with the command
* @param targetid - The target player ID (use INVALID_PLAYER_ID if no target)
*/
LogAdminCommand(adminid, const command[], const params[], targetid = INVALID_PLAYER_ID)
{
    new query[512];
    new tmpCharName[MAX_PLAYERS][MAX_PLAYER_NAME];

    if(player[adminid][isSpawned])
    {
        format(tmpCharName[adminid], MAX_PLAYER_NAME, "%s", player[adminid][chosenChar]);
    }
    else
    {
        format(tmpCharName[adminid], MAX_PLAYER_NAME, "N/A");
    }

    if(targetid != INVALID_PLAYER_ID)
    {
        if(player[targetid][isSpawned])
        {
            format(tmpCharName[targetid], MAX_PLAYER_NAME, "%s", player[targetid][chosenChar]);
        }
        else
        {
            format(tmpCharName[targetid], MAX_PLAYER_NAME, "N/A");
        }
    }
    else
    {
        format(tmpCharName[targetid], MAX_PLAYER_NAME, "N/A");
    }
    
    // Get target information if valid
    if(targetid != INVALID_PLAYER_ID)
    {
        mysql_format(database, query, sizeof(query),
            "INSERT INTO `admin_logs` \
            (`admin_account_id`, `admin_username`, `admin_character_name`, `admin_level`, \
            `command`, `params`, `target_playerid`, `target_username`, `target_character_name`, \
            `ip_address`, `timestamp`) \
            VALUES (%d, '%e', '%e', %d, '%e', '%e', %d, '%e', '%e', '%e', %d)",
            player[adminid][ID],
            player[adminid][Name],
            tmpCharName[adminid],
            player[adminid][admin],
            command,
            params,
            targetid,
            player[targetid][Name],
            tmpCharName[targetid],
            player[adminid][ip],
            gettime()
        );
    }
    else
    {
        // No target player
        mysql_format(database, query, sizeof(query),
            "INSERT INTO `admin_logs` \
            (`admin_account_id`, `admin_username`, `admin_character_name`, `admin_level`, \
            `command`, `params`, `ip_address`, `timestamp`) \
            VALUES (%d, '%e', '%e', %d, '%e', '%e', '%e', %d)",
            player[adminid][ID],
            player[adminid][Name],
            tmpCharName[adminid],
            player[adminid][admin],
            command,
            params,
            player[adminid][ip],
            gettime()
        );
    }
    
    // Execute the query asynchronously (non-blocking)
    mysql_tquery(database, query);
    return 1;
}

// ============================================================================
// ADMIN/LOGGING
// ============================================================================

/*
* Retrieve admin command logs from database
* This is a callback-based function for viewing logs in-game or web interface
*/
forward OnAdminLogsRetrieved(adminid, limit);
public OnAdminLogsRetrieved(adminid, limit)
{
    if(!IsPlayerConnected(adminid))
        return 0;
        
    new rows = cache_num_rows();
    
    if(rows == 0)
    {
        SendClientMessage(adminid, COLOR_SYSTEM, "No admin command logs found.");
        return 1;
    }
    
    SendClientMessage(adminid, COLOR_ADMINMSG, "=== Recent Admin Command Logs ===");
    
    for(new i = 0; i < rows; i++)
    {
        new admin_name[MAX_PLAYER_NAME];
        new command[64];
        new target_name[MAX_PLAYER_NAME];
        new timestamp;
        new dateStr[32];
        
        cache_get_value_name(i, "admin_username", admin_name, MAX_PLAYER_NAME);
        cache_get_value_name(i, "command", command, sizeof(command));
        cache_get_value_name(i, "target_username", target_name, MAX_PLAYER_NAME);
        cache_get_value_name_int(i, "timestamp", timestamp);
        
        // Format timestamp
        format(dateStr, sizeof(dateStr), "%s", FormatUnixTime(timestamp));
        
        if(strlen(target_name) > 0)
        {
            SendClientMessage(adminid, COLOR_WHITE, "[%s] %s used /%s on %s", dateStr, admin_name, command, target_name);
        }
        else
        {
            SendClientMessage(adminid, COLOR_WHITE, "[%s] %s used /%s", dateStr, admin_name, command);
        }
    }
    
    return 1;
}

/*
* Functions for interior creation and management
*/
forward OnInteriorCreated(playerid, const intname[]);
public OnInteriorCreated(playerid, const intname[])
{
    new newIntId = cache_insert_id();
    player[playerid][currentInterior] = newIntId;
    
    /*
    * Now we are ready to continue
    */
    player[playerid][createIntStep] = 1;
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Stand where the interior entrance is and use the command /icis");
    return 1;
}

forward OnInteriorCountUpdate(intid);
public OnInteriorCountUpdate(intid)
{
    if(cache_num_rows() > 0)
    {
        cache_get_value_name_int(0, "total", serverInteriorCount);
    }
    
    /*
    * Load the new interior data
    */
    LoadInteriorData(intid);
    return 1;
}

forward OnShowInteriorsList(playerid);
public OnShowInteriorsList(playerid)
{
    new rows = cache_num_rows();
    if(rows > 0)
    {
        new tmpIntString[64];
        for(new i = 0; i < rows; i++)
        {
            cache_get_value_name(i, "name", tmpIntString, sizeof(tmpIntString));
            AddDialogListitem(playerid, tmpIntString);
        }
    }
    
    ShowPlayerDialogPages(playerid, "ShowInteriorsDialog", DIALOG_STYLE_LIST, "Server Interiors", "Select", "Close", 15);
    return 1;
}

// ============================================================================
// SHOP DATABASE FUNCTIONS
// ============================================================================

/*
* Load shop from database by ID
*/
LoadShops(shopid)
{
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "SELECT * FROM `shops` WHERE `id` = %d LIMIT 1", shopid);
    mysql_tquery(database, query, "OnShopsLoaded", "d", shopid);
    return 1;
}

forward OnShopsLoaded(shopid);
public OnShopsLoaded(shopid)
{
    if(cache_num_rows() > 0)
    {
        cache_get_value_name_int(0, "id", shopInfo[shopid][shopId]);
        cache_get_value_name_int(0, "actor_skin", shopInfo[shopid][shopActorSkin]);
        cache_get_value_name_float(0, "shopx", shopInfo[shopid][shopX]);
        cache_get_value_name_float(0, "shopy", shopInfo[shopid][shopY]);
        cache_get_value_name_float(0, "shopz", shopInfo[shopid][shopZ]);
        cache_get_value_name_float(0, "shopa", shopInfo[shopid][shopA]);
        cache_get_value_name_int(0, "shopint", shopInfo[shopid][shopInterior]);
        cache_get_value_name_int(0, "shopworld", shopInfo[shopid][shopVirtualWorld]);
        
        // Load shop money (default to 1000 if column doesn't exist yet)
        new money;
        cache_get_value_name_int(0, "money", money);
        shopInfo[shopid][shopMoney] = (money > 0) ? money : 1000;
        
        // Load inventory for each item
        for(new j = 1; j < MAX_ITEMS; j++)
        {
            new fieldName[16];
            format(fieldName, sizeof(fieldName), "item%d", j);
            cache_get_value_name_int(0, fieldName, shopInfo[shopid][shopInventory][j]);
        }
        
        // Create actor for shop
        CreateShopActor(shopid);
        
        // Track total shops loaded
        if(shopid >= totalShops)
        {
            totalShops = shopid + 1;
        }
    }
    return 1;
}

/*
* Save shop to database
*/
SaveShopToDatabase(shopIndex)
{
    if(shopIndex < 0 || shopIndex >= MAX_SHOPS) return 0;
    
    new query[512];
    format(query, sizeof(query), 
        "INSERT INTO `shops` (`id`, `actor_skin`, `shopx`, `shopy`, `shopz`, `shopa`, `shopint`, `shopworld`, `money`) VALUES (%d, %d, %f, %f, %f, %f, %d, %d, %d)",
        shopInfo[shopIndex][shopId],
        shopInfo[shopIndex][shopActorSkin],
        shopInfo[shopIndex][shopX],
        shopInfo[shopIndex][shopY],
        shopInfo[shopIndex][shopZ],
        shopInfo[shopIndex][shopA],
        shopInfo[shopIndex][shopInterior],
        shopInfo[shopIndex][shopVirtualWorld],
        shopInfo[shopIndex][shopMoney]
    );
    
    mysql_tquery(database, query);
    return 1;
}

/*
* Update single item in shop inventory
* Only updates the specific item that changed, not all 149 items
*/
UpdateShopInventoryInDatabase(shopIndex, itemid)
{
    if(shopIndex < 0 || shopIndex >= totalShops) return 0;
    if(itemid < 1 || itemid >= MAX_ITEMS) return 0;
    
    new query[128];
    format(query, sizeof(query), 
        "UPDATE `shops` SET `item%d`=%d WHERE `id`=%d", 
        itemid, shopInfo[shopIndex][shopInventory][itemid], shopInfo[shopIndex][shopId]);
    
    mysql_tquery(database, query);
    return 1;
}

/*
* Update shop money in database
*/
UpdateShopMoneyInDatabase(shopIndex)
{
    if(shopIndex < 0 || shopIndex >= totalShops) return 0;
    
    new query[128];
    format(query, sizeof(query), 
        "UPDATE `shops` SET `money`=%d WHERE `id`=%d", 
        shopInfo[shopIndex][shopMoney], shopInfo[shopIndex][shopId]);
    
    mysql_tquery(database, query);
    return 1;
}

/*
* Delete shop from database
*/
DeleteShopFromDatabase(shopid)
{
    new query[128];
    format(query, sizeof(query), "DELETE FROM `shops` WHERE `id`=%d", shopid);
    mysql_tquery(database, query);
}


#endif // MODULE_SQL_INCLUDED