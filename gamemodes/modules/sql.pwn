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
        * Load/Create player's inventory data file
        * As long as they are not a Zombie character
        */
        if(player[playerid][iszombie] == 0)
        {
            LoadCharacterInventory(playerid);
        }

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
        
        // now give the player their weapons (if they have any equipped)
        GivePlayerWeapon(playerid, player[playerid][wepSlot][0], 1); // fist or brass knuckles
        GivePlayerWeapon(playerid, player[playerid][wepSlot][1], 1); // melee weapons
        GivePlayerWeapon(playerid, player[playerid][wepSlot][2], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][2])]); // pistols
        GivePlayerWeapon(playerid, player[playerid][wepSlot][3], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][3])]); // shotguns
        GivePlayerWeapon(playerid, player[playerid][wepSlot][4], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][4])]); // uzi/tec-9/mp5
        GivePlayerWeapon(playerid, player[playerid][wepSlot][5], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][5])]); // ak/m4
        GivePlayerWeapon(playerid, player[playerid][wepSlot][6], playerInventory[playerid][ReturnWeaponAmmoId(player[playerid][wepSlot][6])]); // rifles
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
	* Kill the timers
	*/
	KillTimer(player[playerid][hungerTimer]);
    KillTimer(player[playerid][thirstTimer]);
	KillTimer(player[playerid][diseaseTimer]);
	KillTimer(player[playerid][fuelTimer]);
	KillTimer(player[playerid][fillVehicleTimer]);
	return 1;
}

UpdatePlayerWepslotEntry(wepslotid, weaponid, const currentCharacter[])
{
	DB_ExecuteQuery(database, "UPDATE characters SET wepslot%d = '%d' WHERE name = '%q'", wepslotid, weaponid, currentCharacter);
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

/*
* Scavenging Locations
*/
LoadScavArea(scavAreaId)
{
    new DBResult:Result;
    Result = DB_ExecuteQuery(database, "SELECT * FROM scavareas WHERE id = '%d'", scavAreaId);

	if(DB_GetFieldCount(Result) > 0)
    {
        scavArea[scavAreaId][scavPos][0] = DB_GetFieldFloatByName(Result, "posx");
        scavArea[scavAreaId][scavPos][1] = DB_GetFieldFloatByName(Result, "posy");
        scavArea[scavAreaId][scavPos][2] = DB_GetFieldFloatByName(Result, "posz");
        scavArea[scavAreaId][scavInterior] = DB_GetFieldIntByName(Result, "interior");
        scavArea[scavAreaId][scavWorld] = DB_GetFieldIntByName(Result, "world");
        scavArea[scavAreaId][scavType] = DB_GetFieldIntByName(Result, "type");
        scavArea[scavAreaId][areaActive] = true;
    }
    DB_FreeResultSet(Result);
    
    // create the text label
    scavTextLabel[scavAreaId] = CreateDynamic3DTextLabel("/search", COLOR_GREEN, scavArea[scavAreaId][scavPos][0], scavArea[scavAreaId][scavPos][1], scavArea[scavAreaId][scavPos][2], 20.0, 
        .testlos = 1, .worldid = scavArea[scavAreaId][scavWorld], .interiorid = scavArea[scavAreaId][scavInterior]);
    return 1;
}

CreateScavArea(Float:scavPosX, Float:scavPosY, Float:scavPosZ, scavIntWorld, scavVirWorld, areaType)
{
    new tmpScavId, DBResult:Result;
    DB_ExecuteQuery(database, "INSERT INTO scavareas (posx, posy, posz, interior, world, type) \
        VALUES ('%f', '%f', '%f', '%d', '%d', '%d')", scavPosX, scavPosY, scavPosZ, scavIntWorld, scavVirWorld, areaType);

    // get the ID of the scav area
    Result = DB_ExecuteQuery(database, "SELECT last_insert_rowid() FROM scavareas");
    tmpScavId = DB_GetFieldInt(Result);
    DB_FreeResultSet(Result);

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

/*
* Server items
*/
LoadServerItems(item)
{
    new DBResult:Result;
    Result = DB_ExecuteQuery(database, "SELECT * FROM items WHERE id = '%d'", item);

	if(DB_GetFieldCount(Result) > 0)
    {
        inventoryItems[item][itemId] = item;
        DB_GetFieldStringByName(Result, "sname", inventoryItems[item][itemNameSingular], 128);
        DB_GetFieldStringByName(Result, "pname", inventoryItems[item][itemNamePlural], 128);
        DB_GetFieldStringByName(Result, "description", inventoryItems[item][itemDescription], 128);
		inventoryItems[item][itemCategory] = DB_GetFieldIntByName(Result, "category");
        inventoryItems[item][itemHealAmount] = DB_GetFieldIntByName(Result, "healamount");
        inventoryItems[item][itemWepId] = DB_GetFieldIntByName(Result, "wepid");
        inventoryItems[item][itemAmmoId] = DB_GetFieldIntByName(Result, "ammoid");
        inventoryItems[item][itemWepSlot] = DB_GetFieldIntByName(Result, "wepslot");
        if(DB_GetFieldIntByName(Result, "isusable") == 1)
        {
            inventoryItems[item][isUsable] = true;
        }
        else if(DB_GetFieldIntByName(Result, "isusable") == 0)
        {
            inventoryItems[item][isUsable] = false;
        }
        inventoryItems[item][itemMaxResource] = DB_GetFieldIntByName(Result, "maxresource");
    }
    DB_FreeResultSet(Result);
    return 1;
}

CreateServerItem(itemid, const nameSingular[], const namePlural[], const itemDesc[], category, healamount, wepid, ammoid, wepslot, bool:isusable, maxresource)
{
    DB_ExecuteQuery(database, "INSERT INTO items (itemid, sname, pname, description, category, healamount, wepid, ammoid, wepslot, isusable, maxresource) \
        VALUES ('%d', '%q', '%q', '%q', '%d', '%d', '%d', '%d', '%d', '%d', '%d')", itemid, nameSingular, namePlural, itemDesc, category, healamount, 
        wepid, ammoid, wepslot, isusable, maxresource);

    // update the array size
    serverItemCount = serverItemCount + 1;
    return 1;
}

/*
* Loot Tables
*/
CreateServerLootTable(const tableName[])
{
    DB_ExecuteQuery(database, "INSERT INTO loottable (name) VALUES ('%q')", tableName);

    // update the array size
    lootTableCount = lootTableCount + 1;
    return 1;
}

LoadServerLootTable(lootTableId)
{
    new DBResult:Result, fieldName[10];
    Result = DB_ExecuteQuery(database, "SELECT * FROM loottable WHERE id = '%d'", lootTableId + 1);

	if(DB_GetFieldCount(Result) > 0)
    {
        DB_GetFieldStringByName(Result, "name", lootTableName[lootTableId]);
        for(new i = 0; i < CHANCE; i++)
        {
            format(fieldName, sizeof(fieldName), "chance%d", i);
            lootTable[lootTableId][i] = DB_GetFieldIntByName(Result, fieldName);
        }
    }
    DB_FreeResultSet(Result);
    return 1;
}

UpdateLootTableEntry(const tableName[], tableid, chanceNode, itemid)
{
    DB_ExecuteQuery(database, "UPDATE loottable SET chance%d = '%d' WHERE name = '%q'", chanceNode, itemid, tableName);
    lootTable[tableid][chanceNode] = itemid;
    return 1;
}

PopulateLootTableList(playerid)
{
	new tmpTableName[32], DBResult:Result;
	Result = DB_ExecuteQuery(database, "SELECT * FROM loottable LIMIT %d", lootTableCount);
    
    do
	{
		DB_GetFieldStringByName(Result, "name", tmpTableName, 32);
        AddDialogListitem(playerid, tmpTableName);
	}
	while(DB_SelectNextRow(Result));
    
    DB_FreeResultSet(Result);
    ShowPlayerDialogPages(playerid, "ShowLootTableAdminList", DIALOG_STYLE_LIST, "Select a Loot Table", "Select", "Quit", 10);
	return 1;
}

PopulateLootTableChanceList(playerid, const chosenTable[])
{
    new DBResult:Result, tmpChance, fieldName[10], tmpChanceToString[5];
	Result = DB_ExecuteQuery(database, "SELECT * FROM loottable WHERE name = '%q'", chosenTable);
    
    if(DB_GetFieldCount(Result) > 0)
    {
        for(new i = 0; i < CHANCE; i++)
        {
            format(fieldName, sizeof(fieldName), "chance%d", i);
            tmpChance = DB_GetFieldIntByName(Result, fieldName);
            format(tmpChanceToString, sizeof(tmpChanceToString), "%d", tmpChance); // AddDialogListitem only accepts strings in the 2nd param
            AddDialogListitem(playerid, tmpChanceToString);
        }
    }
    DB_FreeResultSet(Result);
    ShowPlayerDialogPages(playerid, "ShowLootTableChanceList", DIALOG_STYLE_LIST, "Select an Item ID to edit", "Select", "Quit", 10);
    return 1;
}

/*
* Character Inventory
*/
CreateCharacterInventory(playerid)
{
    DB_ExecuteQuery(database, "INSERT INTO inventory (character) VALUES ('%q')", player[playerid][chosenChar]);
    return 1;
}

LoadCharacterInventory(playerid)
{
    new DBResult:Result, fieldName[10], timeMs = GetTickCount();
    Result = DB_ExecuteQuery(database, "SELECT * FROM inventory WHERE character = '%q'", player[playerid][chosenChar]);

	if(DB_GetFieldCount(Result) > 0)
    {
        for(new i = 1; i < MAX_ITEMS; i++)
        {
            format(fieldName, sizeof(fieldName), "item%d", i);
            playerInventory[playerid][i] = DB_GetFieldIntByName(Result, fieldName);
        }
    }
    DB_FreeResultSet(Result);
    printf("|-> %s Inventory Loaded in %d ms", player[playerid][chosenChar], GetTickCount() - timeMs);
    return 1;
}

UpdateCharacterInventoryEntry(playerid, itemid)
{
    DB_ExecuteQuery(database, "UPDATE characters SET item%d = '%d' WHERE character = '%q'", itemid, playerInventory[playerid][itemid], player[playerid][chosenChar]);
    return 1;
}

/*
* Fuel Pumps
*/
CreateFuelPump(Float:fuelPosX, Float:fuelPosY, Float:fuelPosZ)
{
    new tmpPumpId, DBResult:Result;
    DB_ExecuteQuery(database, "INSERT INTO fuelpump (posx, posy, posz) VALUES ('%f', '%f', '%f')", fuelPosX, fuelPosY, fuelPosZ);

    // get the ID of the scav area
    Result = DB_ExecuteQuery(database, "SELECT last_insert_rowid() FROM scavareas");
    tmpPumpId = DB_GetFieldInt(Result) - 1;
    DB_FreeResultSet(Result);

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
    new DBResult:Result;
    Result = DB_ExecuteQuery(database, "SELECT * FROM fuelpump WHERE id = '%d'", pumpId + 1);

	if(DB_GetFieldCount(Result) > 0)
    {
        fuelPump[pumpId][0] = DB_GetFieldFloatByName(Result, "posx");
        fuelPump[pumpId][1] = DB_GetFieldFloatByName(Result, "posy");
        fuelPump[pumpId][2] = DB_GetFieldFloatByName(Result, "posz");
    }
    DB_FreeResultSet(Result);
    
    // create the text label
    fillTextLabel[pumpId] = CreateDynamic3DTextLabel("/fill", COLOR_YELLOW, fuelPump[pumpId][0], fuelPump[pumpId][1], fuelPump[pumpId][2], 20.0, .testlos = 1);
    return 1;
}

/*
* Setup all of the server load stats
*/
GetServerLoadStats()
{
    new DBResult:Result, tmpCount;
    
    /*
    * Count Accounts & Characters
    */
    print("-------------------------------------");
    Result = DB_ExecuteQuery(database, "SELECT COUNT(*) FROM accounts");
	tmpCount = DB_GetFieldInt(Result);
	DB_FreeResultSet(Result);
    printf("|-> Database has %d accounts", tmpCount);
    
    Result = DB_ExecuteQuery(database, "SELECT COUNT(*) FROM characters");
	tmpCount = DB_GetFieldInt(Result);
	DB_FreeResultSet(Result);
    printf("|-> Database has %d characters", tmpCount);
    print("-------------------------------------");
    
    /*
	* Get Interior count
	*/
    Result = DB_ExecuteQuery(database, "SELECT COUNT(*) FROM interiors");
	serverInteriorCount = DB_GetFieldInt(Result);
	DB_FreeResultSet(Result);
    
    /*
    * Get faction count
    */
    Result = DB_ExecuteQuery(database, "SELECT COUNT(*) FROM factions");
	serverFactionCount = DB_GetFieldInt(Result);
	DB_FreeResultSet(Result);
    
    /*
    * Get scav area count
    */
    Result = DB_ExecuteQuery(database, "SELECT COUNT(*) FROM scavareas");
    scavAreaCount = DB_GetFieldInt(Result);
    DB_FreeResultSet(Result);
    
    /*
    * Get items count
    */
    Result = DB_ExecuteQuery(database, "SELECT COUNT(*) FROM items");
	serverItemCount = DB_GetFieldInt(Result);
	DB_FreeResultSet(Result);
    
    /*
    * Get Loot Table count
    */
    Result = DB_ExecuteQuery(database, "SELECT COUNT(*) FROM loottable");
	lootTableCount = DB_GetFieldInt(Result);
	DB_FreeResultSet(Result);
    
    /*
    * Get Fuel Pump count
    */
    Result = DB_ExecuteQuery(database, "SELECT COUNT(*) FROM fuelpump");
	fuelPumpCount = DB_GetFieldInt(Result);
	DB_FreeResultSet(Result);
}