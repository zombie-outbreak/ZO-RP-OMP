// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - ADMIN COMMANDS
// ============================================================================
/*
* MODULE: Admin Commands
* PURPOSE: Administrative command implementations for server moderation
* 
* DEPENDENCIES:
* - core/config.pwn
* - core/constants.pwn
* - core/player_data.pwn
* - utilities/dialogs.pwn
* - utilities/helpers.pwn
* - utilities/messaging.pwn
* 
* PUBLIC FUNCTIONS:
* INFORMATION:
* - CMD:ahelp - Show admin commands by level (1-5)
* 
* LEVEL 1 - TRIAL ADMIN:
* - CMD:a - Admin chat
* - CMD:asay - Admin announcement
* - CMD:slap - Slap player
* - CMD:akill - Kill player
* - CMD:kick - Kick player from server
* 
* LEVEL 2 - MODERATOR:
* - CMD:freeze - Freeze player
* - CMD:unfreeze - Unfreeze player
* - CMD:mute - Mute player
* - CMD:unmute - Unmute player
* - CMD:goto - Teleport to player
* - CMD:gethere - Teleport player to you
* - CMD:aarmour - Set player armour
* - CMD:aheal - Heal player
* 
* LEVEL 3 - ADMIN:
* - CMD:ban - Ban player
* - CMD:unban - Unban account
* - CMD:setlevel - Set player level
* - CMD:givemoney - Give money to player
* - CMD:giveitem - Give items to player
* - CMD:setinterior - Change interior
* - CMD:setvirtualworld - Change virtual world
* 
* LEVEL 4 - SENIOR ADMIN:
* - CMD:spawnvehicle - Spawn temporary vehicle
* - CMD:deletevehicle - Delete spawned vehicle
* - CMD:setskin - Change player skin
* - CMD:setweather - Change weather
* - CMD:settime - Change time
* - CMD:createinterior - Create new interior
* - CMD:createvendor - Create vending machine
* 
* LEVEL 5 - LEAD ADMIN:
* - CMD:setadmin - Set admin level
* - CMD:makechar - Create character for player
* - CMD:deletechar - Delete player character
* - CMD:createitem - Create new server item
* - CMD:deleteitem - Delete server item
* - CMD:fly - Toggle flight mode
* 
* DESCRIPTION:
* Contains all administrative commands for server moderation and management.
* Commands are level-restricted and include extensive permission checks.
* All commands use ZCMD processor and log actions for accountability.
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_ADMIN_COMMANDS_INCLUDED
#define MODULE_ADMIN_COMMANDS_INCLUDED

// ============================================================================
// INFORMATION COMMANDS
// ============================================================================

CMD:ahelp(playerid, params[])
{
    if(player[playerid][admin] < 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
    
    new page = 0;
    if(sscanf(params, "D(0)", page))
    {
        // Show usage
        new string[256];
        format(string, sizeof(string), "Usage: /ahelp [level 1-5] - Shows commands for that admin level\nYour admin level: %d", player[playerid][admin]);
        ShowPlayerMessageBox(playerid, "Admin Help", string);
        return 1;
    }
    
    // Validate page number
    if(page < 1 || page > 5)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid level. Use /ahelp [1-5]");
        return 1;
    }
    
    // Check if player has access to that level
    if(page > player[playerid][admin])
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have access to that admin level.");
        return 1;
    }
    
    new message[2048], title[64];
    
    switch(page)
    {
        case 1: // Trial Admin
        {
            format(title, sizeof(title), "Admin Commands - Level 1: Trial Admin");
            strcat(message, "{FF0000}=== LEVEL 1 - TRIAL ADMIN ===\n\n");
            strcat(message, "{FFFFFF}COMMUNICATION:\n");
            strcat(message, "{CCCCCC}- /a [text] - Admin chat\n");
            strcat(message, "{CCCCCC}- /asay [text] - Admin announcement to all players\n\n");
            
            strcat(message, "{FFFFFF}MODERATION:\n");
            strcat(message, "{CCCCCC}- /slap [playerid] [reason] - Slap a player\n");
            strcat(message, "{CCCCCC}- /akill [playerid] [reason] - Kill a player\n");
            strcat(message, "{CCCCCC}- /kick [playerid] [reason] - Kick a player from server\n\n");
            
            strcat(message, "{FFFFFF}TELEPORTATION:\n");
            strcat(message, "{CCCCCC}- /mark - Save your current position\n");
            strcat(message, "{CCCCCC}- /gotomark - Teleport to saved position\n");
            strcat(message, "{CCCCCC}- /goto [playerid] - Teleport to a player\n");
            strcat(message, "{CCCCCC}- /gethere [playerid] - Teleport player to you\n");
        }
        case 2: // Admin
        {
            format(title, sizeof(title), "Admin Commands - Level 2: Admin");
            strcat(message, "{FF0000}=== LEVEL 2 - ADMIN ===\n\n");
            strcat(message, "{FFFFFF}BANNING:\n");
            strcat(message, "{CCCCCC}- /aban [playerid] [reason] - Ban player's account\n\n");
            
            strcat(message, "{AAAAAA}All Level 1 commands are also available.\n");
            strcat(message, "{AAAAAA}Use /ahelp 1 to view Level 1 commands.\n");
        }
        case 3: // Senior Admin
        {
            format(title, sizeof(title), "Admin Commands - Level 3: Senior Admin");
            strcat(message, "{FF0000}=== LEVEL 3 - SENIOR ADMIN ===\n\n");
            strcat(message, "{FFFFFF}BANNING:\n");
            strcat(message, "{CCCCCC}- /ipban [playerid] [reason] - Ban player's IP address\n\n");
            
            strcat(message, "{AAAAAA}All Level 1-2 commands are also available.\n");
            strcat(message, "{AAAAAA}Use /ahelp [1-2] to view those commands.\n");
        }
        case 4: // Head Admin
        {
            format(title, sizeof(title), "Admin Commands - Level 4: Head Admin");
            strcat(message, "{FF0000}=== LEVEL 4 - HEAD ADMIN ===\n\n");
            strcat(message, "{FFFFFF}BANNING:\n");
            strcat(message, "{CCCCCC}- /rconbanip [ip] - RCON ban an IP address\n");
            strcat(message, "{CCCCCC}- /unbanip [ip] - Unban an IP address\n\n");
            
            strcat(message, "{FFFFFF}ITEMS:\n");
            strcat(message, "{CCCCCC}- /giveplayeritem [id] [itemid] [amount] - Give item to player\n");
            strcat(message, "{CCCCCC}- /setplayeritem [id] [itemid] [amount] - Set item quantity\n\n");
            
            strcat(message, "{FFFFFF}LOGS:\n");
            strcat(message, "{CCCCCC}- /adminlogs - View recent admin action logs\n");
            strcat(message, "{CCCCCC}- /searchadminlogs [username] - Search admin logs by admin\n\n");
            
            strcat(message, "{AAAAAA}All Level 1-3 commands are also available.\n");
            strcat(message, "{AAAAAA}Use /ahelp [1-3] to view those commands.\n");
        }
        case 5: // Management
        {
            format(title, sizeof(title), "Admin Commands - Level 5: Management");
            strcat(message, "{FF0000}=== LEVEL 5 - MANAGEMENT ===\n\n");
            strcat(message, "{FFFFFF}UTILITY:\n");
            strcat(message, "{FFFF00}- /fly - Toggle fly mode\n");
            strcat(message, "{FFFF00}- /resetvworld - Reset your virtual world to 0\n");
            strcat(message, "{FFFF00}- /heal - Heal yourself (TEST COMMAND)\n\n");
            
            strcat(message, "{FFFFFF}INTERIORS:\n");
            strcat(message, "{FFFF00}- /createinterior [name] - Start interior creation\n");
            strcat(message, "{FFFF00}- /icis - Interior creation steps\n");
            strcat(message, "{FFFF00}- /setintvirworld [id] - Set interior virtual world\n");
            strcat(message, "{FFFF00}- /showinteriors - List all interiors\n");
            strcat(message, "{FFFF00}- /cancelinterior - Cancel interior creation\n\n");
            
            strcat(message, "{FFFFFF}WORLD CREATION:\n");
            strcat(message, "{FFFF00}- /scavcreate [type] - Create scavenge area\n");
            strcat(message, "{FFFF00}- /createpump - Create fuel pump at position\n\n");
            
            strcat(message, "{FFFFFF}ITEMS & CRAFTING:\n");
            strcat(message, "{FFFF00}- /createitem - Create a new item\n");
            strcat(message, "{FFFF00}- /addrecipe - Add crafting recipe\n");
            strcat(message, "{FFFF00}- /createloottable [name] - Create loot table\n");
            strcat(message, "{FFFF00}- /loottables - View all loot tables\n\n");
            
            strcat(message, "{FFFFFF}TERRITORIES:\n");
            strcat(message, "{FFFF00}- /createterritory [name] [coords] - Create territory\n");
            strcat(message, "{FFFF00}- /deleteterritory [name] - Delete territory\n");
            strcat(message, "{FFFF00}- /editterritory [name] [option] [value] - Edit territory\n");
            strcat(message, "{FFFF00}- /setterritoryowner [territory] [faction] - Set owner\n\n");
            
            strcat(message, "{AAAAAA}All Level 1-4 commands are also available.\n");
            strcat(message, "{AAAAAA}Use /ahelp [1-4] to view those commands.\n");
        }
    }
    
    // Show the dialog
    ShowPlayerMessageBox(playerid, title, message);
    return 1;
}

/*
* Moderator
* Level: 1
*/
CMD:a(playerid, params[])
{
    if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(isnull(params))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /a [text]");

	SendAdminMessage(playerid, COLOR_PURPLE, params);
    return 1;
}

CMD:asay(playerid, params[])
{
    if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	if(isnull(params))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /asay [text]");

	SendClientMessageToAll(COLOR_CYAN, "Admin %s: %s", player[playerid][Name], params);
    return 1;
}

CMD:slap(playerid, params[])
{
    new id, reason[76], Float:tmpPPos[3];

    if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(sscanf(params, "ds[76]", id, reason))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /slap [playerid] [reason]");

    if(!IsPlayerConnected(id))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid ID.");

    GetPlayerPos(id, tmpPPos[0], tmpPPos[1], tmpPPos[2]);
	SetPlayerPos(id, tmpPPos[0], tmpPPos[1], tmpPPos[2] + 10);
	PlayerPlaySound(id, 1130, 0.0, 0.0, 0.0);
	SendClientMessageToAll(COLOR_ADMINMSG, "Administrator %s has slapped %s [Reason: %s]", player[playerid][Name], player[id][Name], reason);
	LogAdminCommand(playerid, "slap", reason, id);
    return 1;
}

CMD:akill(playerid, params[])
{
    new id, reason[76];

	if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	if(sscanf(params,"ds[76]",id, reason))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /akill [playerid] [reason]");

	if(!IsPlayerConnected(id))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid player ID.");

	SetPlayerHealth(id, 0.0);
	SendClientMessageToAll(COLOR_ADMINMSG, "Administrator %s has killed %s [Reason: %s]", player[playerid][Name], player[id][Name], reason);
	LogAdminCommand(playerid, "akill", reason, id);
    return 1;
}

CMD:kick(playerid, params[])
{
    new id, reason[76], string[128];

	if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	if(sscanf(params, "ds[76]", id, reason))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /kick [playerid] [reason]");

    if(!IsPlayerConnected(id))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid ID.");

    SendClientMessageToAll(COLOR_ADMINMSG, "Administrator %s has kicked %s [Reason: %s]", player[playerid][Name], player[id][Name], reason);
    format(string, sizeof(string), "Administrator %s has kicked you! [Reason: %s]", player[playerid][Name], reason);
    LogAdminCommand(playerid, "kick", reason, id);
    KickWithMessage(id, COLOR_ADMINMSG, string);
	return 1;
}

CMD:mark(playerid, params[])
{
	if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	GetPlayerPos(playerid, player[playerid][adminPos][0], player[playerid][adminPos][1], player[playerid][adminPos][2]);
	GetPlayerFacingAngle(playerid, player[playerid][adminPos][3]);

	PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
	SendClientMessage(playerid, COLOR_ADMINMSG, "Saved current location.");
	return 1;
}

CMD:gotomark(playerid, params[])
{
	if(player[playerid][admin] < 1)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	SetPlayerPos(playerid, player[playerid][adminPos][0], player[playerid][adminPos][1], player[playerid][adminPos][2]);
	SetPlayerFacingAngle(playerid, player[playerid][adminPos][3]);
	PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
	SendClientMessage(playerid, COLOR_ADMINMSG, "You teleported to your last saved location.");
    return 1;
}

CMD:goto(playerid, params[])
{
    new targetId;

    if(player[playerid][admin] < 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
        
    if(sscanf(params, "d", targetId))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /goto [playerid]");

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
	LogAdminCommand(playerid, "goto", "N/A", targetId);
    return 1;
}

CMD:gethere(playerid, params[])
{
    new targetId;

    if(player[playerid][admin] < 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
        
    if(sscanf(params, "d", targetId))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /gethere [playerid]");

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
	LogAdminCommand(playerid, "gethere", "N/A", targetId);
    return 1;
}

/*
* Junior Admin
* Level: 2
*/
CMD:aban(playerid, params[]) // account banning
{
    new id, reason[76];

	if(player[playerid][admin] < 2)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(sscanf(params, "ds[76]", id, reason))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /aban [playerid] [reason]");

    if(!IsPlayerConnected(id))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid ID.");

    new query[256];
	mysql_format(database, query, sizeof(query), 
        "UPDATE `accounts` SET `isbanned` = 1 WHERE `username` = '%e'", player[id][Name]);
    mysql_tquery(database, query);
    
	SendClientMessageToAll(COLOR_ADMINMSG, "Administrator %s has banned %s [Reason: %s]", player[playerid][Name], player[id][Name], reason);
	LogAdminCommand(playerid, "aban", reason, id);
	KickWithMessage(id, COLOR_ADMINMSG, "Administrator %s has banned you! [Reason: %s] (Is this wrong? Go to "SERVER_WEBSITE")", player[playerid][Name], reason);
	return 1;
}

/*
* Admin
* Level: 3
*/
CMD:ipban(playerid, params[]) // ip banning
{
    new id, reason[76];

	if(player[playerid][admin] < 3)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(sscanf(params, "ds[76]", id, reason))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /ipban [playerid] [reason]");

    if(!IsPlayerConnected(id))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid ID.");

	SendClientMessageToAll(COLOR_ADMINMSG, "Administrator %s has banned %s [Reason: %s]", player[playerid][Name], player[id][Name], reason);
	LogAdminCommand(playerid, "ipban", reason, id);
   	BanWithMessage(id, COLOR_ADMINMSG, "Administrator %s has banned you! [Reason: %s] (Is this wrong? Go to """SERVER_WEBSITE")", player[playerid][Name], reason);
	return 1;
}

/*
* Senior Admin
* Level: 4
*/
CMD:rconbanip(playerid, params[])
{
    new tmpIP[16];

	if(player[playerid][admin] < 4)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	if(sscanf(params, "s[16]", tmpIP))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /rconbanip [ip]");

    SendRconCommand("banip %s", tmpIP);
    SendClientMessage(playerid, COLOR_ADMINMSG, "You banned the IP: %s and added it to the ban database!", tmpIP);
    PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
    return 1;
}

CMD:unbanip(playerid, params[])
{
    new tmpIP[16];

	if(player[playerid][admin] < 4)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	if(sscanf(params, "s[16]", tmpIP))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /unbanip [ip]");

    SendRconCommand("unbanip %s", tmpIP);
    SendRconCommand("reloadbans");
    SendClientMessage(playerid, COLOR_ADMINMSG, "You unbanned the IP: %s from the ban database!", tmpIP);
    PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
    return 1;
}

CMD:giveplayeritem(playerid, params[])
{
    new id, tmpItemId, amount;
    
    if(player[playerid][admin] < 4)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	if(sscanf(params,"ddd", id, tmpItemId, amount))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /giveplayeritem [playerid] [item id] [amount].");
    
    if(!IsPlayerConnected(id))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid player ID.");
    
    if(tmpItemId < 1 || tmpItemId > serverItemCount)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid item id.");

    playerInventory[id][tmpItemId] = playerInventory[id][tmpItemId] + amount;
    UpdateCharacterInventoryEntry(id, playerInventory[id][tmpItemId]);
    SendClientMessage(playerid, COLOR_ADMINMSG, "You've given %s %d %s.", player[id][chosenChar], amount, inventoryItems[tmpItemId][itemNamePlural]);
    LogAdminCommand(playerid, "giveplayeritem", params, id);
    return 1;
}

CMD:setplayeritem(playerid, params[])
{
    new id, tmpItemId, amount;
    
    if(player[playerid][admin] < 4)
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

	if(sscanf(params,"ddd", id, tmpItemId, amount))
		return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /setplayeritem [playerid] [item id] [amount].");
    
    if(!IsPlayerConnected(id))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid player ID.");
    
    if(tmpItemId < 1 || tmpItemId > serverItemCount)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid item id.");

    playerInventory[id][tmpItemId] = amount;
    UpdateCharacterInventoryEntry(id, playerInventory[id][tmpItemId]);
    SendClientMessage(playerid, COLOR_ADMINMSG, "You've set %s's %s to %d.", player[id][chosenChar], inventoryItems[tmpItemId][itemNamePlural], amount);
    return 1;
}

CMD:adminlogs(playerid, params[])
{
    if(player[playerid][admin] < 4)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
    
    new limit = 20;
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "SELECT * FROM `admin_logs` ORDER BY `timestamp` DESC LIMIT %d", limit);
    
    mysql_tquery(database, query, "OnAdminLogsRetrieved", "dd", playerid, limit);
    return 1;
}

CMD:searchadminlogs(playerid, params[])
{
    new adminName[MAX_PLAYER_NAME];
    
    if(player[playerid][admin] < 4)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
    
    if(sscanf(params, "s[24]", adminName))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "USAGE: /searchadminlogs [admin username]");
    
    new query[256];
    mysql_format(database, query, sizeof(query), "SELECT * FROM `admin_logs` WHERE `admin_username` = '%e' ORDER BY `timestamp` DESC LIMIT 20", adminName);
    mysql_tquery(database, query, "OnAdminLogsRetrieved", "dd", playerid, 20);
    return 1;
}

/*
* Server Management
* Level: 5
*/
CMD:fly(playerid, params[])
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
CMD:createinterior(playerid, params[])
{
    new intname[64];

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
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "INSERT INTO `interiors` (`name`) VALUES ('%e')", intname);
    mysql_tquery(database, query, "OnInteriorCreated", "ds", playerid, intname);
    return 1;
}

CMD:icis(playerid, params[]) // icis = initiate create interior step
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    new Float:ppos[4], query[512];
    switch(player[playerid][createIntStep])
    {
        case 1:
        {
            GetPlayerPos(playerid, ppos[0], ppos[1], ppos[2]);
            
            mysql_format(database, query, sizeof(query), 
                "UPDATE `interiors` SET `penterx1` = %f, `pentery1` = %f, `penterz1` = %f WHERE `id` = %d",
                ppos[0], ppos[1], ppos[2], player[playerid][currentInterior]);
            mysql_tquery(database, query);

            player[playerid][createIntStep] = 2;
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Stand where the player will be teleported to inside the interior then use /icis");
        }
        case 2:
        {
            GetPlayerPos(playerid, ppos[0], ppos[1], ppos[2]);
            GetPlayerFacingAngle(playerid, ppos[3]);

            mysql_format(database, query, sizeof(query), 
                "UPDATE `interiors` SET `penterx2` = %f, `pentery2` = %f, `penterz2` = %f, `pentera` = %f WHERE `id` = %d",
                ppos[0], ppos[1], ppos[2], ppos[3], player[playerid][currentInterior]);
            mysql_tquery(database, query);

            player[playerid][createIntStep] = 3;
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Stand where the player will go to leave the interior then use /icis");
        }
        case 3:
        {
            GetPlayerPos(playerid, ppos[0], ppos[1], ppos[2]);

            mysql_format(database, query, sizeof(query), 
                "UPDATE `interiors` SET `pexitx1` = %f, `pexity1` = %f, `pexitz1` = %f WHERE `id` = %d",
                ppos[0], ppos[1], ppos[2], player[playerid][currentInterior]);
            mysql_tquery(database, query);

            player[playerid][createIntStep] = 4;
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Stand where the player will be teleported to outside the interior then use /icis");
        }
        case 4:
        {
            GetPlayerPos(playerid, ppos[0], ppos[1], ppos[2]);
            GetPlayerFacingAngle(playerid, ppos[3]);

            mysql_format(database, query, sizeof(query), 
                "UPDATE `interiors` SET `pexitx2` = %f, `pexity2` = %f, `pexitz2` = %f, `pexita` = %f WHERE `id` = %d",
                ppos[0], ppos[1], ppos[2], ppos[3], player[playerid][currentInterior]);
            mysql_tquery(database, query);

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

CMD:setintvirworld(playerid, params[])
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
    
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "UPDATE `interiors` SET `virworld` = %d WHERE `id` = %d", 
        srvInterior[player[playerid][currentInterior]][intVirWorld], player[playerid][currentInterior]);
    mysql_tquery(database, query);

    /*
    * Give player confirmation of success
    */
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Interior created successfully.");
    player[playerid][createIntStep] = 0;

    /*
    * Update interior count and load the new interior data
    */
    new countQuery[128];
    mysql_format(database, countQuery, sizeof(countQuery), "SELECT COUNT(*) AS total FROM `interiors`");
    mysql_tquery(database, countQuery, "OnInteriorCountUpdate", "d", player[playerid][currentInterior]);
    
    player[playerid][currentInterior] = -1;
    return 1;
}

CMD:showinteriors(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    new query[128];
    mysql_format(database, query, sizeof(query), "SELECT `id`, `name` FROM `interiors` ORDER BY `id` ASC");
    mysql_tquery(database, query, "OnShowInteriorsList", "d", playerid);
    return 1;
}

CMD:cancelinterior(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    if(player[playerid][createIntStep] < 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You are not currently creating an interior.");

    /*
    * Send DELETE FROM command to database to remove current interior from the database (stops bugged interiors hopefully)
    */
    new query[256];
    mysql_format(database, query, sizeof(query), "DELETE FROM `interiors` WHERE `id` = %d", player[playerid][currentInterior]);
    mysql_tquery(database, query);

    /*
    * Cancel and confirm cancellation to player
    */
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You cancelled the create/edit interior task.");
    player[playerid][createIntStep] = 0;
    player[playerid][currentInterior] = -1;
    return 1;
}

CMD:resetvworld(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    SetPlayerVirtualWorld(playerid, 0);
    SendClientMessage(playerid, COLOR_ADMINISTRATOR, "You reset your Virtual world to 0.");
    return 1;
}

CMD:scavcreate(playerid, params[])
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

CMD:createitem(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
        
    if(serverItemCount >= MAX_ITEMS)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "The server has reached its maximum amount of items.");
    
    Dialog_Show(playerid, CreateItemSName, DIALOG_STYLE_INPUT, "Create Item: Name (Singular)", "Enter the item's singular name.", "Confirm", "Back");
    return 1;
}

CMD:createloottable(playerid, params[])
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

CMD:loottables(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
        
    PopulateLootTableList(playerid);
    return 1;
}

CMD:createpump(playerid, params[])
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
* TEST COMMAND TO BE REMOVED ONCE NO LONGER REQUIRED
*/
CMD:heal(playerid, params[])
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
#endif // MODULE_ADMIN_COMMANDS_INCLUDED
