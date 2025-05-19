/*
* Zombie Outbreak Roleplay
* (C) 2025 Zombie Outbreak Development Contributors
* GNU General Public License v3.0
*/
@cmd() ahelp(playerid, params[], help)
{
    switch(player[playerid][admin])
    {
        case 0: SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
        case 1: 
        {
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/a /asay /slap /akill /kick /mark /gotomark /goto /gethere");
        }
        case 2:
        {
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/a /asay /slap /akill /kick /mark /gotomark /goto /gethere");
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/aban");
        }
        case 3:
        {
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/a /asay /slap /akill /kick /mark /gotomark /goto /gethere");
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/aban");
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/ipban");
        }
        case 4:
        {
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/a /asay /slap /akill /kick /mark /gotomark /goto /gethere");
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/aban");
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/ipban");
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/rconbanip /unbanip /dsetpw");
        }
        case 5: 
        {
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/a /asay /slap /akill /kick /mark /gotomark /goto /gethere");
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/aban");
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/ipban");
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/rconbanip /unbanip /dsetpw");
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/fly /createinterior /icis /setintvirworld /showinteriors /cancelinterior /scavcreate /createloottable");
        }
    }
    return 1;
}

/*
* Moderator
* Level: 1
*/
@cmd() a(playerid, params[], help)
{
    if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(isnull(params))
		return SendClientMessage(playerid, COLOR_RED, "USAGE: /a [text]");

	SendAdminMessage(playerid, COLOR_PURPLE, params);
    return 1;
}

@cmd() asay(playerid, params[], help)
{
    if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	if(isnull(params))
		return SendClientMessage(playerid, COLOR_RED, "USAGE: /asay [text]");

	SendClientMessageToAll(COLOR_CYAN, "Admin %s: %s", player[playerid][Name], params);
    return 1;
}

@cmd() slap(playerid, params[], help)
{
    new id, reason[76], Float:tmpPPos[3];

    if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(sscanf(params, "ds[76]", id, reason))
		return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /slap [playerid] [reason]");

    if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "Invalid ID.");

    GetPlayerPos(id, tmpPPos[0], tmpPPos[1], tmpPPos[2]);
	SetPlayerPos(id, tmpPPos[0], tmpPPos[1], tmpPPos[2] + 10);
	PlayerPlaySound(id, 1130, 0.0, 0.0, 0.0);
	SendClientMessageToAll(COLOR_ADMINMSG, "Administrator %s has slapped %s [Reason: %s]", player[playerid][Name], player[id][Name], reason);
    return 1;
}

@cmd() akill(playerid, params[], help)
{
    new id, reason[76];

	if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	if(sscanf(params,"ds[76]",id, reason))
		return SendClientMessage(playerid,COLOR_YELLOW,"USAGE: /akill [playerid] [reason]");

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid,COLOR_RED,"Invalid player ID.");

	SetPlayerHealth(playerid, 0.0);
	SendClientMessageToAll(COLOR_ADMINMSG, "Administrator %s has killed %s [Reason: %s]", player[playerid][Name], player[id][Name], reason);
    return 1;
}

@cmd() kick(playerid, params[], help)
{
    new id, reason[76], string[128];

	if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	if(sscanf(params, "ds[76]", id, reason))
		return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /kick [playerid] [reason]");

    if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "Invalid ID.");

    SendClientMessageToAll(COLOR_ADMINMSG, "Administrator %s has kicked %s [Reason: %s]", player[playerid][Name], player[id][Name], reason);
    format(string, sizeof(string), "Administrator %s has kicked you! [Reason: %s]", player[playerid][Name], reason);
    KickWithMessage(id, COLOR_ADMINMSG, string);
	return 1;
}

@cmd() mark(playerid, params[], help)
{
	if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	GetPlayerPos(playerid, player[playerid][adminPos][0], player[playerid][adminPos][1], player[playerid][adminPos][2]);
	GetPlayerFacingAngle(playerid, player[playerid][adminPos][3]);

	PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
	SendClientMessage(playerid, COLOR_ADMINMSG, "Saved current location.");
	return 1;
}

@cmd() gotomark(playerid, params[], help)
{
	if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	SetPlayerPos(playerid, player[playerid][adminPos][0], player[playerid][adminPos][1], player[playerid][adminPos][2]);
	SetPlayerFacingAngle(playerid, player[playerid][adminPos][3]);
	PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
	SendClientMessage(playerid, COLOR_ADMINMSG, "You teleported to your last saved location.");
    return 1;
}

@cmd() goto(playerid, params[], help)
{
    new targetId = strval(params);

    if(player[playerid][admin] < 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(!IsPlayerConnected(targetId))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Invalid player ID given.");

    new Float:tmpPPos[3], tmpInt, tmpVirWorld;
    GetPlayerPos(targetId, tmpPPos[0], tmpPPos[1], tmpPPos[2]);
    tmpInt = GetPlayerInterior(targetId);
    tmpVirWorld = GetPlayerVirtualWorld(targetId);

    SetPlayerPos(playerid, tmpPPos[0], tmpPPos[1], tmpPPos[2]);
    SetPlayerInterior(playerid, tmpInt);
    SetPlayerVirtualWorld(playerid, tmpVirWorld);

    SendClientMessage(targetId, COLOR_ADMINMSG, "%s has teleported to you!", player[playerid][Name]);
	SendClientMessage(playerid, COLOR_ADMINMSG, "You teleported to %s's location!", player[targetId][Name]);
    return 1;
}

@cmd() gethere(playerid, params[], help)
{
    new targetId = strval(params);

    if(player[playerid][admin] < 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(!IsPlayerConnected(targetId))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Invalid player ID given.");

    new Float:tmpPPos[3], tmpInt, tmpVirWorld;
    GetPlayerPos(playerid, tmpPPos[0], tmpPPos[1], tmpPPos[2]);
    tmpInt = GetPlayerInterior(playerid);
    tmpVirWorld = GetPlayerVirtualWorld(playerid);

    SetPlayerPos(targetId, tmpPPos[0], tmpPPos[1], tmpPPos[2]);
    SetPlayerInterior(targetId, tmpInt);
    SetPlayerVirtualWorld(targetId, tmpVirWorld);

    SendClientMessage(targetId, COLOR_ADMINMSG, "%s has teleported you to them!", player[playerid][Name]);
	SendClientMessage(playerid, COLOR_ADMINMSG, "You teleported %s to your location!", player[targetId][Name]);
    return 1;
}

/*
* Junior Admin
* Level: 2
*/
@cmd() aban(playerid, params[], help) // account banning
{
    new id, reason[76];

	if(player[playerid][admin] < 2)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(sscanf(params, "ds[76]", id, reason))
		return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /aban [playerid] [reason]");

    if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "Invalid ID.");

	DB_ExecuteQuery(database, "UPDATE accounts SET isbanned = '1' WHERE username = '%q'", player[id][Name]);
	SendClientMessageToAll(COLOR_ADMINMSG, "Administrator %s has banned %s [Reason: %s]", player[playerid][Name], player[id][Name], reason);
	KickWithMessage(id, COLOR_ADMINMSG, "Administrator %s has banned you! [Reason: %s] (Is this wrong? Go to "SERVER_WEBSITE")", player[playerid][Name], reason);
	return 1;
}

/*
* Admin
* Level: 3
*/
@cmd() ipban(playerid, params[], help) // ip banning
{
    new id, reason[76];

	if(player[playerid][admin] < 3)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(sscanf(params, "ds[76]", id, reason))
		return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /ipban [playerid] [reason]");

    if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "Invalid ID.");

	SendClientMessageToAll(COLOR_ADMINMSG, "Administrator %s has banned %s [Reason: %s]", player[playerid][Name], player[id][Name], reason);
   	BanWithMessage(id, COLOR_ADMINMSG, "Administrator %s has banned you! [Reason: %s] (Is this wrong? Go to """SERVER_WEBSITE")", player[playerid][Name], reason);
	return 1;
}

/*
* Senior Admin
* Level: 4
*/
@cmd() rconbanip(playerid, params[], help)
{
    new tmpIP[16];

	if(player[playerid][admin] < 4)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	if(sscanf(params, "s[16]", tmpIP))
		return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /rconbanip [ip]");

    SendRconCommand("banip %s", tmpIP);
    SendClientMessage(playerid, COLOR_ADMINMSG, "You banned the IP: %s and added it to the ban database!", tmpIP);
    PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
    return 1;
}

@cmd() unbanip(playerid, params[], help)
{
    new tmpIP[16];

	if(player[playerid][admin] < 4)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	if(sscanf(params, "s[16]", tmpIP))
		return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /unbanip [ip]");

    SendRconCommand("unbanip %s", tmpIP);
    SendRconCommand("reloadbans");
    SendClientMessage(playerid, COLOR_ADMINMSG, "You unbanned the IP: %s from the ban database!", tmpIP);
    PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
    return 1;
}

@cmd() dsetpw(playerid, params[], help)
{
    new pw[128];

	if(player[playerid][admin] < 4)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	if(sscanf(params,"s[24]s[128]", params, pw))
		return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /dsetpw [Username] [password].");

    bcrypt_hash(playerid, "OnUserPasswordChange", pw, BCRYPT_COST);
    SendClientMessage(playerid, COLOR_ADMINMSG, "You've set %s's password.", params);
    return 1;
}

/*
* Server Management
* Level: 5
*/
@cmd() fly(playerid, params[], help)
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(player[playerid][isflying])
	{
		player[playerid][isflying] = false;
		SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "* Fly mode offline.");
		TogglePlayerControllable(playerid, true);
        KillTimer(player[playerid][flyTimer]);
	}
	else
	{
		player[playerid][isflying] = true;
		SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "* Fly mode online.");
		TogglePlayerControllable(playerid, false);
        player[playerid][flyTimer] = SetTimerEx("FlyTimer", 100, true, "d", playerid);
	}
	return 1;
}

/*
* Creating and editing interiors
*/
@cmd() createinterior(playerid, params[], help)
{
    new intname[64], DBResult:Result, newIntId;

    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(sscanf(params, "s[64]", intname)) 
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Syntax error. Correct usage: /createinterior [name]");
        
    if(serverInteriorCount >= MAX_SERVER_INTERIORS)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "The server has reached its maximum amount of interiors.");

    if(player[playerid][createIntStep] >= 1)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You are already in the middle of creating an interior.");
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Either finish creating the one you are doing or use /cancelinterior to cancel current task.");
        return 1;
    }

    /*
    * Create the interior into the database
    */
    DB_ExecuteQuery(database, "INSERT INTO interiors (name) VALUES ('%q')", intname);

    /*
    * Now set the new ID into the global array and into a Variable for use in other commands
    */
    Result = DB_ExecuteQuery(database, "SELECT id FROM interiors WHERE name = '%q'", intname);

	if(DB_GetFieldCount(Result) > 0)
    {
        newIntId = DB_GetFieldIntByName(Result, "id");
        player[playerid][currentInterior] = newIntId;
    }
    DB_FreeResultSet(Result);

    /*
    * Now we are ready to continue
    */
    player[playerid][createIntStep] = 1;
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Stand where the interior entrance is and use the command /icis");
    return 1;
}

@cmd() icis(playerid, params[], help) // icis = initiate create interior step
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    new Float:ppos[4];
    switch(player[playerid][createIntStep])
    {
        case 1:
        {
            GetPlayerPos(playerid, ppos[0], ppos[1], ppos[2]);
            
            DB_ExecuteQuery(database, "UPDATE interiors SET penterx1 = '%f', pentery1 = '%f', penterz1 = '%f' WHERE id = '%d'",
                ppos[0], ppos[1], ppos[2], player[playerid][currentInterior]);

            player[playerid][createIntStep] = 2;
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Stand where the player will be teleported to inside the interior then use /icis");
        }
        case 2:
        {
            GetPlayerPos(playerid, ppos[0], ppos[1], ppos[2]);
            GetPlayerFacingAngle(playerid, ppos[3]);

            DB_ExecuteQuery(database, "UPDATE interiors SET penterx2 = '%f', pentery2 = '%f', penterz2 = '%f', pentera = '%f' WHERE id = '%d'",
                ppos[0], ppos[1], ppos[2], ppos[3], player[playerid][currentInterior]);

            player[playerid][createIntStep] = 3;
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Stand where the player will go to leave the interior then use /icis");
        }
        case 3:
        {
            GetPlayerPos(playerid, ppos[0], ppos[1], ppos[2]);

            DB_ExecuteQuery(database, "UPDATE interiors SET pexitx1 = '%f', pexity1 = '%f', pexitz1 = '%f' WHERE id = '%d'",
                ppos[0], ppos[1], ppos[2], player[playerid][currentInterior]);

            player[playerid][createIntStep] = 4;
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Stand where the player will be teleported to outside the interior then use /icis");
        }
        case 4:
        {
            GetPlayerPos(playerid, ppos[0], ppos[1], ppos[2]);
            GetPlayerFacingAngle(playerid, ppos[3]);

            DB_ExecuteQuery(database, "UPDATE interiors SET pexitx2 = '%f', pexity2 = '%f', pexitz2 = '%f', pexita = '%f' WHERE id = '%d'",
                ppos[0], ppos[1], ppos[2], ppos[3], player[playerid][currentInterior]);

            player[playerid][createIntStep] = 5;
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Now set the interior's virtual world using /setintvirworld.");
        }
        default:
        {
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "ICIS used out of scope.");
            print("====ICIS ERROR====");
            print("Potentially used outside of scope?");
            printf("createintstep variable = %d", player[playerid][createIntStep]);
        }
    }
    return 1;
}

@cmd() setintvirworld(playerid, params[], help)
{
    new intvirworld;

    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(sscanf(params, "i", intvirworld)) 
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Syntax error. Correct usage: /setintvirworld [virtual world ID]");

    if(player[playerid][createIntStep] != 5)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You have not reached this stage in creating an interior or you are not creating one currently.");
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Either start a creation with /createinterior or use /icis at the relevant step.");
        return 1;
    }

    /*
    * Insert the interior virtual world
    */
    srvInterior[player[playerid][currentInterior]][intVirWorld] = intvirworld;
    DB_ExecuteQuery(database, "UPDATE interiors SET virworld = '%d' WHERE id = '%d'", 
        srvInterior[player[playerid][currentInterior]][intVirWorld], player[playerid][currentInterior]);

    /*
    * Give player confirmation of success
    */
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Interior created successfully.");
    player[playerid][createIntStep] = 0;

    /*
    * Update interior count
    */
    new DBResult:Result;
    Result = DB_ExecuteQuery(database, "SELECT COUNT(*) FROM interiors");
	serverInteriorCount = DB_GetFieldInt(Result);
	DB_FreeResultSet(Result);

    /*
    * Load the new interior data
    */
    LoadInteriorData(player[playerid][currentInterior]);
    player[playerid][currentInterior] = -1;
    return 1;
}

@cmd() showinteriors(playerid, params[], help)
{
    new tmpIntString[64], DBResult:Result;

    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    for(new i = 0; i < MAX_SERVER_INTERIORS; i++)
    {
        Result = DB_ExecuteQuery(database, "SELECT name FROM interiors WHERE id = '%d'", i);

        if(DB_GetFieldCount(Result) > 0)
        {
            DB_GetFieldStringByName(Result, "name", tmpIntString, 64);
            AddDialogListitem(playerid, tmpIntString);
        }
        DB_FreeResultSet(Result);
    }

    ShowPlayerDialogPages(playerid, "ShowInteriorsDialog", DIALOG_STYLE_LIST, "Server Interiors", "Select", "Close", 15);
    return 1;
}

@cmd() cancelinterior(playerid, params[], help)
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(player[playerid][createIntStep] < 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You are not currently creating an interior.");

    /*
    * Send DELETE FROM command to database to remove current interior from the database (stops bugged interiors hopefully)
    */
    new DBResult:Result = DB_ExecuteQuery(database, "DELETE FROM interiors WHERE id = '%d'", player[playerid][currentInterior]);
    DB_FreeResultSet(Result);

    /*
    * Cancel and confirm cancellation to player
    */
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You cancelled the create/edit interior task.");
    player[playerid][createIntStep] = 0;
    player[playerid][currentInterior] = -1;
    return 1;
}

@cmd() resetvworld(playerid, params[], help)
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    SetPlayerVirtualWorld(playerid, 0);
    SendClientMessage(playerid, COLOR_ADMINISTRATOR, "You reset your Virtual world to 0.");
    return 1;
}

@cmd() scavcreate(playerid, params[], help)
{
    new Float:tmpPos[3], tmpType;
    
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
    
    if(sscanf(params, "i", tmpType))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Syntax error. Correct usage: /scavcreate [type]");
        
    if(scavAreaCount >= MAX_SCAV_AREAS)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "The server has reached its maximum amount of scav areas.");
    
    // get the location data
    GetPlayerPos(playerid, tmpPos[0], tmpPos[1], tmpPos[2]);
    
    // create the scav area
    CreateScavArea(tmpPos[0], tmpPos[1], tmpPos[2], GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid), tmpType);
    return 1;
}

@cmd() createitem(playerid, params[], help)
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
        
    if(serverItemCount >= MAX_ITEMS)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "The server has reached its maximum amount of items.");
    
    Dialog_ShowCallback(playerid, using public CreateItemSName<iiiis>, DIALOG_STYLE_INPUT, "Create Item: Name (Singular)", "Enter the item's singular name.", "Confirm", "Back");
    return 1;
}

@cmd() createloottable(playerid, params[], help)
{
    new tmpTableName[32];
    
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
    
    if(sscanf(params, "s[32]", tmpTableName)) 
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Syntax error. Correct usage: /createloottable [name]");
        
    if(lootTableCount >= MAX_LOOT_TABLES)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "The server has reached its maximum amount of loot tables.");
    
    CreateServerLootTable(tmpTableName);
    return 1;
}

@cmd() loottables(playerid, params[], help)
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
        
    PopulateLootTableList(playerid);
    return 1;
}

@cmd() createpump(playerid, params[], help)
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
        
    if(fuelPumpCount >= MAX_FUEL_PUMPS)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "The server has reached its maximum amount of fuel pumps.");
        
    new Float:tmpPos[3];
    GetPlayerPos(playerid, tmpPos[0], tmpPos[1], tmpPos[2]);
    CreateFuelPump(tmpPos[0], tmpPos[1], tmpPos[2]);
    return 1;
}

/*
* TEST COMMAND TO BE REMOVED ONCE IT'S EASIER TO SURVIVE
*/
@cmd() heal(playerid, params[], help)
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
        
	SetPlayerHealth(playerid, player[playerid][maxHealth]);
	player[playerid][hunger] = 100;
	player[playerid][thirst] = 100;
    player[playerid][disease] = 100;
	
	UpdateHudElementForPlayer(playerid, HUD_HUNGER);
	UpdateHudElementForPlayer(playerid, HUD_THIRST);
	UpdateHudElementForPlayer(playerid, HUD_HEALTH);
    UpdateHudElementForPlayer(playerid, HUD_DISEASE);
	return 1;
}

@cmd() dam(playerid, params[], help)
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
        
	SetPlayerHealth(playerid, player[playerid][maxHealth]);
	player[playerid][hunger] = 0;
	player[playerid][thirst] = 0;
	
	UpdateHudElementForPlayer(playerid, HUD_HUNGER);
	UpdateHudElementForPlayer(playerid, HUD_THIRST);
	UpdateHudElementForPlayer(playerid, HUD_HEALTH);
	return 1;
}

@cmd() tut(playerid, params[], help)
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    new string[1024];
    format(string, sizeof(string), "This is a test dialogue for the tutorial. It tests how long a string can be shown (should be up to 1024 characters), \
    as well as showing how it displays to the user. I can check if I need to create something new for the tutorial and information boxes.");
    ShowDialogueTextDraw(playerid, string);
    SetTimerEx("HideInfoBox", 10000, false, "d", playerid);
    return 1;
}

@cmd() dis(playerid, params[], help)
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
        
    player[playerid][disease] = 0;
    UpdateHudElementForPlayer(playerid, HUD_DISEASE);
    return 1;
}