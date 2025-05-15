/*
* Zombie Outbreak Roleplay
* (C) 2025 Zombie Outbreak Development Contributors
* GNU General Public License v3.0
*/

SetupDatabase()
{
    database = DB_Open("zorp.db");
}

CheckPlayerAccountExists(playerid)
{
	new DBResult:Result, string[128];
    Result = DB_ExecuteQuery(database, "SELECT password, isbanned FROM accounts WHERE username = '%q'", player[playerid][Name]);

	if(DB_GetFieldCount(Result) > 0)
    {
		DB_GetFieldStringByName(Result, "password", player[playerid][Password], BCRYPT_HASH_LENGTH);
        player[playerid][isBanned] = DB_GetFieldIntByName(Result, "isbanned");

        /*
        * Check if the player is banned.
        */
        if(player[playerid][isBanned] >= 1)
        {
            KickWithMessage(playerid, COLOR_ADMINMSG, "You are banned from this server. (Is this wrong? Go to """SERVER_WEBSITE")");
        }
        else
        {
            format(string, sizeof string, "This account (%s) is registered. Please login by entering your password in the field below:", player[playerid][Name]);
			Dialog_ShowCallback(playerid, using public LoginDialog<iiiis>, DIALOG_STYLE_PASSWORD, "Login", string, "Login", "Abort");
        }
    }
    else
    {
        format(string, sizeof string, "Welcome %s, you can register by entering your password in the field below:", player[playerid][Name]);
		Dialog_ShowCallback(playerid, using public RegisterDialog<iiiis>, DIALOG_STYLE_PASSWORD, "Registration", string, "Register", "Abort");
    }
    DB_FreeResultSet(Result);
	return 1;
}

forward OnPasswordVerify(playerid, bool:success);
public OnPasswordVerify(playerid, bool:success)
{
    if(success)
    {
        new DBResult:Result;
		Result = DB_ExecuteQuery(database, "SELECT * FROM accounts WHERE username = '%q'", player[playerid][Name]);

		if(DB_GetFieldCount(Result) > 0)
		{
			player[playerid][ID] = DB_GetFieldIntByName(Result, "id");
			player[playerid][admin] = DB_GetFieldIntByName(Result, "admin");
			player[playerid][vip] = DB_GetFieldIntByName(Result, "vip");
			player[playerid][isNew] = DB_GetFieldIntByName(Result, "isnew");
			player[playerid][regdate] = DB_GetFieldIntByName(Result, "regdate");
		}
		else
		{
			Kick(playerid);
		}
		DB_FreeResultSet(Result);

		// update last login, IP, and Serial
		player[playerid][lastlogin] = gettime();
        DB_ExecuteQuery(database, "UPDATE `accounts` SET `ip` = '%q', `serial` = '%q', `lastlogin` = '%d' WHERE `username` = '%q'", 
            player[playerid][ip], player[playerid][serial], player[playerid][lastlogin], player[playerid][Name]);

		/*
		* Player is now logged in
		*/
		KillTimer(player[playerid][LoginTimer]);
		player[playerid][LoginTimer] = 0;
		player[playerid][IsLoggedIn] = true;

		/*
		* Show Character Menu
		*/
		PopulateCharacterMenu(playerid);
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
			Dialog_ShowCallback(playerid, using public LoginDialog<iiiis>, DIALOG_STYLE_PASSWORD, "Login", "Wrong password!\nPlease enter your password in the field below:", "Login", "Abort");
		}
    }
}

forward OnRegisterPasswordHash(playerid);
public OnRegisterPasswordHash(playerid)
{
    new dest[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(dest);

    /*
    * Insert player data and create their entry into the database
    */
    DB_ExecuteQuery(database, "INSERT INTO accounts (username, password, ip, serial, regdate, lastlogin) VALUES ('%q', '%q', '%q', '%q', '%d', '%d')", 
        player[playerid][Name], dest, player[playerid][ip], player[playerid][serial], gettime(), gettime());

	/*
	* Registration complete!
	*/
	SendClientMessage(playerid, COLOR_GREEN, "You have registered successfully! Please login to continue.");
	CheckPlayerAccountExists(playerid);
}

forward OnUserPasswordChange(playerid);
public OnUserPasswordChange(playerid)
{
    new dest[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(dest);

	DB_ExecuteQuery(database, "UPDATE accounts SET password = '%q' WHERE username = '%q'", dest, player[playerid][Name]);
}

OnPlayerCharacterDataLoaded(playerid)
{
	new DBResult:Result;
    Result = DB_ExecuteQuery(database, "SELECT * FROM characters WHERE name = '%q'", player[playerid][chosenChar]);

	if(DB_GetFieldCount(Result) > 0)
    {
		player[playerid][charid] = DB_GetFieldIntByName(Result, "id");
		player[playerid][age] = DB_GetFieldIntByName(Result, "age");
		DB_GetFieldStringByName(Result, "description", player[playerid][description], 128);
		player[playerid][skin] = DB_GetFieldIntByName(Result, "skin");
		player[playerid][iszombie] = DB_GetFieldIntByName(Result, "iszombie");
		player[playerid][health] = DB_GetFieldFloatByName(Result, "health");
		player[playerid][maxHealth] = DB_GetFieldFloatByName(Result, "maxhealth");
		player[playerid][hunger] = DB_GetFieldIntByName(Result, "hunger");
		player[playerid][maxHunger] = DB_GetFieldIntByName(Result, "maxhunger");
		player[playerid][thirst] = DB_GetFieldIntByName(Result, "thirst");
		player[playerid][maxThirst] = DB_GetFieldIntByName(Result, "maxthirst");
		player[playerid][disease] = DB_GetFieldIntByName(Result, "disease");
		player[playerid][maxDisease] = DB_GetFieldIntByName(Result, "maxdisease");
		player[playerid][spawned] = DB_GetFieldIntByName(Result, "spawned");
		player[playerid][pPos][0] = DB_GetFieldFloatByName(Result, "px");
		player[playerid][pPos][1] = DB_GetFieldFloatByName(Result, "py");
		player[playerid][pPos][2] = DB_GetFieldFloatByName(Result, "pz");
		player[playerid][pPos][3] = DB_GetFieldFloatByName(Result, "pa");
		player[playerid][plrinterior] = DB_GetFieldIntByName(Result, "interior");
		player[playerid][world] = DB_GetFieldIntByName(Result, "virtualworld");
		player[playerid][level] = DB_GetFieldIntByName(Result, "level");
		player[playerid][exp] = DB_GetFieldIntByName(Result, "exp");
		player[playerid][perkPoints] = DB_GetFieldIntByName(Result, "perkpoints");
		player[playerid][plrFaction] = DB_GetFieldIntByName(Result, "faction");
		player[playerid][factionrank] = DB_GetFieldIntByName(Result, "factionrank");
		playerInventoryResource[playerid][28] = DB_GetFieldIntByName(Result, "fuelcanamount");

		// weapon slot data
		player[playerid][wepSlot][0] = DB_GetFieldIntByName(Result, "wepslot0");
		player[playerid][wepSlot][1] = DB_GetFieldIntByName(Result, "wepslot1");
		player[playerid][wepSlot][2] = DB_GetFieldIntByName(Result, "wepslot2");
		player[playerid][wepSlot][3] = DB_GetFieldIntByName(Result, "wepslot3");
		player[playerid][wepSlot][4] = DB_GetFieldIntByName(Result, "wepslot4");
		player[playerid][wepSlot][5] = DB_GetFieldIntByName(Result, "wepslot5");
		player[playerid][wepSlot][6] = DB_GetFieldIntByName(Result, "wepslot6");
		player[playerid][wepSlot][7] = DB_GetFieldIntByName(Result, "wepslot7");
		player[playerid][wepSlot][8] = DB_GetFieldIntByName(Result, "wepslot8");
		player[playerid][wepSlot][9] = DB_GetFieldIntByName(Result, "wepslot9");
		player[playerid][wepSlot][10] = DB_GetFieldIntByName(Result, "wepslot10");
		player[playerid][wepSlot][11] = DB_GetFieldIntByName(Result, "wepslot11");
		player[playerid][wepSlot][12] = DB_GetFieldIntByName(Result, "wepslot12");

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
				SetSpawnInfo(playerid, TEAM_ZOMBIE, player[playerid][skin], zombieSpawns[randSpawn][0], zombieSpawns[randSpawn][1], zombieSpawns[randSpawn][2], zombieSpawns[randSpawn][3], 9, 1, 0, 0, 0, 0);
			}
			else
			{
				SetSpawnInfo(playerid, TEAM_ZOMBIE, player[playerid][skin], player[playerid][pPos][0], player[playerid][pPos][1], player[playerid][pPos][2], player[playerid][pPos][3], 9, 1, 0, 0, 0, 0);
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
		}
		else // is a zombie so only show health
		{
			ShowHudForPlayer(playerid, HUD_HEALTH);
			ShowHudForPlayer(playerid, HUD_CLOCK);
			SetPlayerColor(playerid, COLOR_YELLOW);
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
	DB_FreeResultSet(Result);
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
	DB_ExecuteQuery(database, "UPDATE characters SET health = '%f', maxhealth = '%f', hunger = '%d', maxhunger = '%d', thirst = '%d', maxthirst = '%d', \
	disease = '%d', maxdisease = '%d', spawned = '%d', px = '%f', py = '%f', pz = '%f', pa = '%f', interior = '%d', virtualworld = '%d', level = '%d', \
	exp = '%d', perkpoints = '%d', faction = '%d', factionrank = '%d', fuelcanamount = '%d' WHERE name = '%q'", 
	player[playerid][health], player[playerid][maxHealth], player[playerid][hunger], player[playerid][maxHunger], player[playerid][thirst], 
	player[playerid][maxThirst], player[playerid][disease], player[playerid][maxDisease], player[playerid][spawned], player[playerid][pPos][0], 
	player[playerid][pPos][1], player[playerid][pPos][2], player[playerid][pPos][3], player[playerid][plrinterior], player[playerid][world], player[playerid][level], 
	player[playerid][exp], player[playerid][perkPoints], player[playerid][plrFaction], player[playerid][factionrank], playerInventoryResource[playerid][28], currentCharacter);

	/*
	* Should do a full save on the player's inventory as well, just in case anything has been missed during normal play
	*/
	DB_ExecuteQuery(database, "UPDATE inventories SET item1 = '%d', item2 = '%d', item3 = '%d', item4 = '%d', item5 = '%d', item6 = '%d', \
	item7 = '%d', item8 = '%d', item9 = '%d', item10 = '%d', item11 = '%d', item12 = '%d', item13 = '%d', item14 = '%d', item15 = '%d', item16 = '%d', \
	item17 = '%d', item18 = '%d', item19 = '%d', item20 = '%d', item21 = '%d', item22 = '%d', item23 = '%d', item24 = '%d', item25 = '%d', item26 = '%d', \
	item27 = '%d', item28 = '%d', item29 = '%d' WHERE name = '%q'", playerInventory[playerid][1], playerInventory[playerid][2], playerInventory[playerid][3],
	playerInventory[playerid][4], playerInventory[playerid][5], playerInventory[playerid][6], playerInventory[playerid][7], playerInventory[playerid][8],
	playerInventory[playerid][9], playerInventory[playerid][10], playerInventory[playerid][11], playerInventory[playerid][12], playerInventory[playerid][13],
	playerInventory[playerid][14], playerInventory[playerid][15], playerInventory[playerid][16], playerInventory[playerid][17], playerInventory[playerid][18],
	playerInventory[playerid][19], playerInventory[playerid][20], playerInventory[playerid][21], playerInventory[playerid][22], playerInventory[playerid][23],
	playerInventory[playerid][24], playerInventory[playerid][25], playerInventory[playerid][26], playerInventory[playerid][27], playerInventory[playerid][28],
	playerInventory[playerid][29], currentCharacter);

	/*
	* Kill the timers
	*/
	KillTimer(player[playerid][hungerTimer]);
    KillTimer(player[playerid][thirstTimer]);
	KillTimer(player[playerid][diseaseTimer]);
	KillTimer(player[playerid][fuelTimer]);
	KillTimer(player[playerid][fillVehicleTimer]);
	return 1;
}

OnPlayerInventoryDataLoaded(playerid)
{
	new DBResult:Result;
    Result = DB_ExecuteQuery(database, "SELECT * FROM inventories WHERE name = '%q'", player[playerid][chosenChar]);

	if(DB_GetFieldCount(Result) > 0)
    {
		playerInventory[playerid][1] = DB_GetFieldIntByName(Result, "item1");
		playerInventory[playerid][2] = DB_GetFieldIntByName(Result, "item2");
		playerInventory[playerid][3] = DB_GetFieldIntByName(Result, "item3");
		playerInventory[playerid][4] = DB_GetFieldIntByName(Result, "item4");
		playerInventory[playerid][5] = DB_GetFieldIntByName(Result, "item5");
		playerInventory[playerid][6] = DB_GetFieldIntByName(Result, "item6");
		playerInventory[playerid][7] = DB_GetFieldIntByName(Result, "item7");
		playerInventory[playerid][8] = DB_GetFieldIntByName(Result, "item8");
		playerInventory[playerid][9] = DB_GetFieldIntByName(Result, "item9");
		playerInventory[playerid][10] = DB_GetFieldIntByName(Result, "item10");
		playerInventory[playerid][11] = DB_GetFieldIntByName(Result, "item11");
		playerInventory[playerid][12] = DB_GetFieldIntByName(Result, "item12");
		playerInventory[playerid][13] = DB_GetFieldIntByName(Result, "item13");
		playerInventory[playerid][14] = DB_GetFieldIntByName(Result, "item14");
		playerInventory[playerid][15] = DB_GetFieldIntByName(Result, "item15");
		playerInventory[playerid][16] = DB_GetFieldIntByName(Result, "item16");
		playerInventory[playerid][17] = DB_GetFieldIntByName(Result, "item17");
		playerInventory[playerid][18] = DB_GetFieldIntByName(Result, "item18");
		playerInventory[playerid][19] = DB_GetFieldIntByName(Result, "item19");
		playerInventory[playerid][20] = DB_GetFieldIntByName(Result, "item20");
		playerInventory[playerid][21] = DB_GetFieldIntByName(Result, "item21");
		playerInventory[playerid][22] = DB_GetFieldIntByName(Result, "item22");
		playerInventory[playerid][23] = DB_GetFieldIntByName(Result, "item23");
		playerInventory[playerid][24] = DB_GetFieldIntByName(Result, "item24");
		playerInventory[playerid][25] = DB_GetFieldIntByName(Result, "item25");
		playerInventory[playerid][26] = DB_GetFieldIntByName(Result, "item26");
		playerInventory[playerid][27] = DB_GetFieldIntByName(Result, "item27");
		playerInventory[playerid][28] = DB_GetFieldIntByName(Result, "item28");
		playerInventory[playerid][29] = DB_GetFieldIntByName(Result, "item29");
	}
	else
	{
		/*
		* Create inventory entry since it doesn't exist
		*/
		DB_ExecuteQuery(database, "INSERT INTO inventories (name) VALUES ('%q')", player[playerid][chosenChar]);
	}
	DB_FreeResultSet(Result);

	// now give the player their weapons (if they have any equipped)
	GivePlayerWeapon(playerid, player[playerid][wepSlot][0], 1); // fist or brass knuckles
	GivePlayerWeapon(playerid, player[playerid][wepSlot][1], 1); // melee weapons
	GivePlayerWeapon(playerid, player[playerid][wepSlot][2], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][2])]); // pistols
	GivePlayerWeapon(playerid, player[playerid][wepSlot][3], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][3])]); // shotguns
	GivePlayerWeapon(playerid, player[playerid][wepSlot][4], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][4])]); // uzi/tec-9/mp5
	GivePlayerWeapon(playerid, player[playerid][wepSlot][5], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][5])]); // ak/m4
	GivePlayerWeapon(playerid, player[playerid][wepSlot][6], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][6])]); // rifles
	return 1;
}

UpdatePlayerInventoryEntry(playerid, itemid, const currentCharacter[])
{
	DB_ExecuteQuery(database, "UPDATE inventories SET item%d = '%d' WHERE name = '%q'", itemid, playerInventory[playerid][itemid], currentCharacter);
	return 1;
}

UpdatePlayerWepslotEntry(wepslotid, weaponid, const currentCharacter[])
{
	DB_ExecuteQuery(database, "UPDATE characters SET wepslot%d = '%d' WHERE name = '%q'", wepslotid, weaponid, currentCharacter);
	return 1;
}

OnPlayerLockerDataLoaded(playerid)
{
	new DBResult:Result;
    Result = DB_ExecuteQuery(database, "SELECT * FROM lockers WHERE name = '%q'", player[playerid][chosenChar]);

	if(DB_GetFieldCount(Result) > 0)
    {
		lockerInventory[playerid][1] = DB_GetFieldIntByName(Result, "item1");
		lockerInventory[playerid][2] = DB_GetFieldIntByName(Result, "item2");
		lockerInventory[playerid][3] = DB_GetFieldIntByName(Result, "item3");
		lockerInventory[playerid][4] = DB_GetFieldIntByName(Result, "item4");
		lockerInventory[playerid][5] = DB_GetFieldIntByName(Result, "item5");
		lockerInventory[playerid][6] = DB_GetFieldIntByName(Result, "item6");
		lockerInventory[playerid][7] = DB_GetFieldIntByName(Result, "item7");
		lockerInventory[playerid][8] = DB_GetFieldIntByName(Result, "item8");
		lockerInventory[playerid][9] = DB_GetFieldIntByName(Result, "item9");
		lockerInventory[playerid][10] = DB_GetFieldIntByName(Result, "item10");
		lockerInventory[playerid][11] = DB_GetFieldIntByName(Result, "item11");
		lockerInventory[playerid][12] = DB_GetFieldIntByName(Result, "item12");
		lockerInventory[playerid][13] = DB_GetFieldIntByName(Result, "item13");
		lockerInventory[playerid][14] = DB_GetFieldIntByName(Result, "item14");
		lockerInventory[playerid][15] = DB_GetFieldIntByName(Result, "item15");
		lockerInventory[playerid][16] = DB_GetFieldIntByName(Result, "item16");
		lockerInventory[playerid][17] = DB_GetFieldIntByName(Result, "item17");
		lockerInventory[playerid][18] = DB_GetFieldIntByName(Result, "item18");
		lockerInventory[playerid][19] = DB_GetFieldIntByName(Result, "item19");
		lockerInventory[playerid][20] = DB_GetFieldIntByName(Result, "item20");
		lockerInventory[playerid][21] = DB_GetFieldIntByName(Result, "item21");
		lockerInventory[playerid][22] = DB_GetFieldIntByName(Result, "item22");
		lockerInventory[playerid][23] = DB_GetFieldIntByName(Result, "item23");
		lockerInventory[playerid][24] = DB_GetFieldIntByName(Result, "item24");
		lockerInventory[playerid][25] = DB_GetFieldIntByName(Result, "item25");
		lockerInventory[playerid][26] = DB_GetFieldIntByName(Result, "item26");
		lockerInventory[playerid][27] = DB_GetFieldIntByName(Result, "item27");
		lockerInventory[playerid][28] = DB_GetFieldIntByName(Result, "item28");
		lockerInventory[playerid][29] = DB_GetFieldIntByName(Result, "item29");
	}
	else
	{
		/*
		* Create locker entry since it doesn't exist
		*/
		DB_ExecuteQuery(database, "INSERT INTO lockers (name) VALUES ('%q')", player[playerid][chosenChar]);
	}
	DB_FreeResultSet(Result);
	return 1;
}

stock UpdatePlayerLockerEntry(playerid, itemid, const currentCharacter[])
{
	DB_ExecuteQuery(database, "UPDATE lockers SET item%d = '%d' WHERE name = '%q'", itemid, lockerInventory[playerid][itemid], currentCharacter);
	return 1;
}

/*
* Load Interior data
*/
LoadInteriorData(interiorid)
{
	new DBResult:Result;
    Result = DB_ExecuteQuery(database, "SELECT * FROM interiors WHERE id = '%d'", interiorid);

	if(DB_GetFieldCount(Result) > 0)
    {
        DB_GetFieldStringByName(Result, "name", srvInterior[interiorid][intName]);
		srvInterior[interiorid][intWorld] = DB_GetFieldIntByName(Result, "intworld");
		srvInterior[interiorid][intVirWorld] = DB_GetFieldIntByName(Result, "virworld");
		srvInterior[interiorid][intExitWorld] = DB_GetFieldIntByName(Result, "intworldexit");
		srvInterior[interiorid][intExitVirWorld] = DB_GetFieldIntByName(Result, "virworldexit");
		srvInterior[interiorid][intPrice] = DB_GetFieldIntByName(Result, "purchaseprice");
		srvInterior[interiorid][intType] = DB_GetFieldIntByName(Result, "interiortype");
		DB_GetFieldStringByName(Result, "owner", srvInterior[interiorid][intOwner]);
		srvInterior[interiorid][intLocked] = DB_GetFieldIntByName(Result, "islocked");
		srvInterior[interiorid][intEnter][0] = DB_GetFieldFloatByName(Result, "penterx1");
		srvInterior[interiorid][intEnter][1] = DB_GetFieldFloatByName(Result, "pentery1");
		srvInterior[interiorid][intEnter][2] = DB_GetFieldFloatByName(Result, "penterz1");
		srvInterior[interiorid][intEnter][3] = DB_GetFieldFloatByName(Result, "penterx2");
		srvInterior[interiorid][intEnter][4] = DB_GetFieldFloatByName(Result, "pentery2");
		srvInterior[interiorid][intEnter][5] = DB_GetFieldFloatByName(Result, "penterz2");
		srvInterior[interiorid][intEnter][6] = DB_GetFieldFloatByName(Result, "pentera");
		srvInterior[interiorid][intExit][0] = DB_GetFieldFloatByName(Result, "pexitx1");
		srvInterior[interiorid][intExit][1] = DB_GetFieldFloatByName(Result, "pexity1");
		srvInterior[interiorid][intExit][2] = DB_GetFieldFloatByName(Result, "pexitz1");
		srvInterior[interiorid][intExit][3] = DB_GetFieldFloatByName(Result, "pexitx2");
		srvInterior[interiorid][intExit][4] = DB_GetFieldFloatByName(Result, "pexity2");
		srvInterior[interiorid][intExit][5] = DB_GetFieldFloatByName(Result, "pexitz2");
		srvInterior[interiorid][intExit][6] = DB_GetFieldFloatByName(Result, "pexita");
    }
    DB_FreeResultSet(Result);

	/*
	* Create and display the text above a pickup
	*/
	CreateInteriorPickup(interiorid);
    
    // map icons
    srvInterior[interiorid][mapIcon] = CreateDynamicMapIcon(srvInterior[interiorid][intEnter][0], srvInterior[interiorid][intEnter][1], srvInterior[interiorid][intEnter][2], 0, COLOR_LIGHTGREEN, 0, 0);
	return 1;
}

/*
* Load Faction Data
*/
LoadFactionData(factionid)
{
	new DBResult:Result;
    Result = DB_ExecuteQuery(database, "SELECT * FROM factions WHERE id = '%d'", factionid);

	if(DB_GetFieldCount(Result) > 0)
    {
        DB_GetFieldStringByName(Result, "name", faction[factionid][facName]);
		DB_GetFieldStringByName(Result, "creator", faction[factionid][facCreator]);
		DB_GetFieldStringByName(Result, "rank0", factionRankName[factionid][0]);
		DB_GetFieldStringByName(Result, "rank1", factionRankName[factionid][1]);
		DB_GetFieldStringByName(Result, "rank2", factionRankName[factionid][2]);
		DB_GetFieldStringByName(Result, "rank3", factionRankName[factionid][3]);
		DB_GetFieldStringByName(Result, "rank4", factionRankName[factionid][4]);
		DB_GetFieldStringByName(Result, "rank5", factionRankName[factionid][5]);
		DB_GetFieldStringByName(Result, "rank6", factionRankName[factionid][6]);
		DB_GetFieldStringByName(Result, "rank7", factionRankName[factionid][7]);
		DB_GetFieldStringByName(Result, "rank8", factionRankName[factionid][8]);
		DB_GetFieldStringByName(Result, "rank9", factionRankName[factionid][9]);
		faction[factionid][facMoney] = DB_GetFieldIntByName(Result, "money");
    }
    DB_FreeResultSet(Result);
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
	new charName[MAX_PLAYER_NAME], DBResult:Result;
	Result = DB_ExecuteQuery(database, "SELECT name FROM characters WHERE owner = '%d' LIMIT 50", player[playerid][ID]);

	AddDialogListitem(playerid, "Create New");
	do
	{
		DB_GetFieldStringByName(Result, "name", charName, MAX_PLAYER_NAME);
		AddDialogListitem(playerid, charName);
	}
	while(DB_SelectNextRow(Result));

	DB_FreeResultSet(Result);
	ShowPlayerDialogPages(playerid, "ShowPlayerCharacterMenu", DIALOG_STYLE_LIST, "Select a Character", "Select", "Quit", 15);
	return 1;
}

/*
* Populate the faction members list
*/
PopulateFactionMembersList(playerid, factionId)
{
	/*
	* Show character menu
	*/
	new charName[MAX_PLAYER_NAME], DBResult:Result;
	Result = DB_ExecuteQuery(database, "SELECT name FROM characters WHERE faction = %d LIMIT 500", factionId);

	do
	{
		DB_GetFieldStringByName(Result, "name", charName, MAX_PLAYER_NAME);
		AddDialogListitem(playerid, charName);
	}
	while(DB_SelectNextRow(Result));

	DB_FreeResultSet(Result);
	ShowPlayerDialogPages(playerid, "ShowFactionMemberList", DIALOG_STYLE_LIST, "Select a Member", "Select", "Close", 20);
	return 1;
}