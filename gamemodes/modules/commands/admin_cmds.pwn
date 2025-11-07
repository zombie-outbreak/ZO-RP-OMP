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
* - CMD:aban - Ban player account
* 
* LEVEL 3 - SENIOR ADMIN:
* - CMD:ipban - Ban player by IP address
* 
* LEVEL 4 - HEAD ADMIN:
* - CMD:rconbanip - RCON ban an IP address
* - CMD:unbanip - Unban an IP address
* - CMD:giveplayeritem - Give items to player
* - CMD:setplayeritem - Set player item quantity
* - CMD:adminlogs - View recent admin action logs
* - CMD:searchadminlogs - Search admin logs by username
* - CMD:createshop - Create shop at your location
* - CMD:deleteshop - Delete nearest shop
* - CMD:editshop - Edit nearest shop's inventory
* - CMD:setshopstock - Set item stock in shop
* - CMD:listshops - List all shops
* - CMD:gotoshop - Teleport to shop
* 
* LEVEL 5 - MANAGEMENT:
* - CMD:fly - Toggle flight mode (optional speed 1-15, default 8)
* - CMD:createinterior - Create new interior
* - CMD:icis - Interior creation steps
* - CMD:setintvirworld - Set interior virtual world
* - CMD:showinteriors - List all interiors
* - CMD:cancelinterior - Cancel interior creation
* - CMD:resetvworld - Reset your virtual world to 0
* - CMD:scavcreate - Create scavenge area
* - CMD:scavdelete - Delete nearest scavenge area
* - CMD:createitem - Create new server item
* - CMD:reloadloottables - Reload loot tables from XML
* - CMD:createpump - Create fuel pump
* - CMD:reloadshops - Reload all shops from database
* - CMD:heal - Heal yourself (TEST COMMAND)
* 
* DESCRIPTION:
* Contains all administrative commands for server moderation and management.
* Commands are level-restricted and include extensive permission checks.
* All commands use Pawn.CMD processor and log actions for accountability.
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
            strcat(message, "{CCCCCC}- /kick [playerid] [reason] - Kick a player from server\n");
        }
        case 2: // Moderator
        {
            format(title, sizeof(title), "Admin Commands - Level 2: Moderator");
            strcat(message, "{FF0000}=== LEVEL 2 - MODERATOR ===\n\n");
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
            strcat(message, "{CCCCCC}- /giveplayeritem [playerid] [itemid] [amount] - Give item to player\n");
            strcat(message, "{CCCCCC}- /setplayeritem [playerid] [itemid] [amount] - Set item quantity\n\n");

            strcat(message, "{FFFFFF}LOGS:\n");
            strcat(message, "{CCCCCC}- /adminlogs - View recent admin action logs\n");
            strcat(message, "{CCCCCC}- /searchadminlogs [username] - Search admin logs by admin\n\n");
            
            strcat(message, "{FFFFFF}SHOPS:\n");
            strcat(message, "{CCCCCC}- /createshop [skin] - Create shop at your location\n");
            strcat(message, "{CCCCCC}- /deleteshop - Delete nearest shop\n");
            strcat(message, "{CCCCCC}- /editshop - Edit nearest shop's inventory\n");
            strcat(message, "{CCCCCC}- /setshopstock [itemname] [qty] - Set item stock\n");
            strcat(message, "{CCCCCC}- /listshops - List all shops\n");
            strcat(message, "{CCCCCC}- /gotoshop [id] - Teleport to shop\n\n");
            
            strcat(message, "{AAAAAA}All Level 1-3 commands are also available.\n");
            strcat(message, "{AAAAAA}Use /ahelp [1-3] to view those commands.\n");
        }
        case 5: // Management
        {
            format(title, sizeof(title), "Admin Commands - Level 5: Management");
            strcat(message, "{FF0000}=== LEVEL 5 - MANAGEMENT ===\n\n");
            strcat(message, "{FFFFFF}UTILITY:\n");
            strcat(message, "{FFFF00}- /fly [speed] - Toggle fly mode (speed 1-15, default 8)\n");
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
            strcat(message, "{FFFF00}- /scavdelete - Delete nearest scavenge area\n");
            strcat(message, "{FFFF00}- /createpump - Create fuel pump at position\n\n");
            
            strcat(message, "{FFFFFF}ITEMS & LOOT:\n");
            strcat(message, "{FFFF00}- /createitem - Create a new item\n");
            strcat(message, "{FFFF00}- /reloadloottables - Reload loot tables from XML\n\n");
            
            strcat(message, "{FFFFFF}SHOPS:\n");
            strcat(message, "{FFFF00}- /reloadshops - Reload all shops from database\n\n");
            
            strcat(message, "{AAAAAA}All Level 1-4 commands are also available.\n");
            strcat(message, "{AAAAAA}Use /ahelp [1-4] to view those commands.\n");
        }
    }
    
    // Show the dialog
    ShowPlayerMessageBox(playerid, title, message);
    return 1;
}

// ============================================================================
// LEVEL 1 - TRIAL ADMIN COMMANDS
// ============================================================================

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

// ============================================================================
// LEVEL 2 - MODERATOR COMMANDS
// ============================================================================

CMD:aban(playerid, params[])
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

// ============================================================================
// LEVEL 3 - SENIOR ADMIN COMMANDS
// ============================================================================

CMD:ipban(playerid, params[])
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

// ============================================================================
// LEVEL 4 - HEAD ADMIN COMMANDS
// ============================================================================

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

CMD:createshop(playerid, params[])
{
    if(player[playerid][admin] < 4)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to use this command.");
    
    new tmpSkin;
    if(sscanf(params, "d", tmpSkin))
        return SendClientMessage(playerid, COLOR_GREY, "USAGE: /createshop [skin]");
    
    if(tmpSkin < 0 || tmpSkin > 311)
        return SendClientMessage(playerid, COLOR_RED, "Invalid skin ID (0-311).");
    
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    new interior = GetPlayerInterior(playerid);
    new virtualworld = GetPlayerVirtualWorld(playerid);
    
    new shopIndex = CreateShop(x, y, z, a, interior, virtualworld, tmpSkin);
    
    if(shopIndex == INVALID_SHOP_ID)
    {
        SendClientMessage(playerid, COLOR_RED, "Failed to create shop. Shop limit may be reached.");
        return 1;
    }
    
    new message[128];
    format(message, sizeof(message), "Shop ID %d created successfully. Use /editshop to set inventory.", 
        shopInfo[shopIndex][shopId]);
    SendClientMessage(playerid, COLOR_GREEN, message);
    
    return 1;
}

CMD:deleteshop(playerid, params[])
{
    if(player[playerid][admin] < 4)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to use this command.");
    
    new shopIndex = GetNearestShop(playerid);
    
    if(shopIndex == INVALID_SHOP_ID)
        return SendClientMessage(playerid, COLOR_RED, "You are not near a shop.");
    
    new tmpShopId = shopInfo[shopIndex][shopId];
    
    if(DeleteShop(shopIndex))
    {
        new message[64];
        format(message, sizeof(message), "Shop ID %d deleted successfully.", tmpShopId);
        SendClientMessage(playerid, COLOR_GREEN, message);
    }
    else
    {
        SendClientMessage(playerid, COLOR_RED, "Failed to delete shop.");
    }
    
    return 1;
}

CMD:editshop(playerid, params[])
{
    if(player[playerid][admin] < 4)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to use this command.");
    
    new shopIndex = GetNearestShop(playerid);
    
    if(shopIndex == INVALID_SHOP_ID)
        return SendClientMessage(playerid, COLOR_RED, "You are not near a shop.");
    
    playerCurrentShop[playerid] = shopIndex;
    
    // Show edit menu
    ShowShopEditMenu(playerid, shopIndex);
    
    return 1;
}

/*
* Show shop edit menu to admin
*/
ShowShopEditMenu(playerid, shopIndex)
{
    if(shopIndex < 0 || shopIndex >= totalShops) return 0;
    
    new dialog[2048];
    new title[64];
    
    format(title, sizeof(title), "Edit Shop ID %d", shopInfo[shopIndex][shopId]);
    strcat(dialog, "{FFFFFF}Item\t{FFFF00}Current Stock\n");
    
    for(new i = 1; i < MAX_ITEMS; i++)
    {
        new line[128];
        format(line, sizeof(line), "%s\t{FFFF00}%d\n",
            inventoryItems[i][itemNameSingular],
            shopInfo[shopIndex][shopInventory][i]
        );
        strcat(dialog, line);
    }
    
    Dialog_Show(playerid, DIALOG_SHOP_EDIT, DIALOG_STYLE_TABLIST_HEADERS, title, dialog, "Edit", "Close");
    return 1;
}

CMD:setshopstock(playerid, params[])
{
    if(player[playerid][admin] < 4)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to use this command.");
    
    new itemName[64], quantity;
    if(sscanf(params, "s[64]d", itemName, quantity))
        return SendClientMessage(playerid, COLOR_GREY, "USAGE: /setshopstock [itemname] [quantity]");
    
    new shopIndex = GetNearestShop(playerid);
    
    if(shopIndex == INVALID_SHOP_ID)
        return SendClientMessage(playerid, COLOR_RED, "You are not near a shop.");
    
    new tmpItemId = ReturnItemIdByName(itemName);
    
    if(tmpItemId == 0)
        return SendClientMessage(playerid, COLOR_RED, "Invalid item name.");
    
    if(quantity < 0)
        return SendClientMessage(playerid, COLOR_RED, "Quantity must be 0 or greater.");
    
    shopInfo[shopIndex][shopInventory][tmpItemId] = quantity;
    UpdateShopInventoryInDatabase(shopIndex, tmpItemId);
    
    new message[128];
    format(message, sizeof(message), "Shop stock updated: %s = %d", 
        inventoryItems[tmpItemId][itemNameSingular], quantity);
    SendClientMessage(playerid, COLOR_GREEN, message);
    
    return 1;
}

CMD:listshops(playerid, params[])
{
    if(player[playerid][admin] < 4)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to use this command.");
    
    if(totalShops == 0)
    {
        SendClientMessage(playerid, COLOR_GREY, "No shops exist.");
        return 1;
    }
    
    new dialog[2048];
    format(dialog, sizeof(dialog), "{FFFFFF}ID\t{FFFF00}Location\t{00FF00}Interior/VW\n");
    
    for(new i = 0; i < totalShops; i++)
    {
        new line[128];
        format(line, sizeof(line), "{FFFFFF}%d\t{FFFF00}%.1f, %.1f, %.1f\t{00FF00}%d/%d\n",
            shopInfo[i][shopId],
            shopInfo[i][shopX],
            shopInfo[i][shopY],
            shopInfo[i][shopZ],
            shopInfo[i][shopInterior],
            shopInfo[i][shopVirtualWorld]
        );
        strcat(dialog, line);
    }
    
    Dialog_Show(playerid, DIALOG_SHOP_LIST, DIALOG_STYLE_TABLIST_HEADERS, "Shops List", dialog, "Teleport", "Close");
    
    return 1;
}

CMD:gotoshop(playerid, params[])
{
    if(player[playerid][admin] < 4)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to use this command.");
    
    new tmpShopId;
    if(sscanf(params, "d", tmpShopId))
        return SendClientMessage(playerid, COLOR_GREY, "USAGE: /gotoshop [id]");
    
    new shopIndex = GetShopIndexById(tmpShopId);
    
    if(shopIndex == INVALID_SHOP_ID)
        return SendClientMessage(playerid, COLOR_RED, "Invalid shop ID.");
    
    SetPlayerPos(playerid, shopInfo[shopIndex][shopX], shopInfo[shopIndex][shopY], shopInfo[shopIndex][shopZ]);
    SetPlayerInterior(playerid, shopInfo[shopIndex][shopInterior]);
    SetPlayerVirtualWorld(playerid, shopInfo[shopIndex][shopVirtualWorld]);
    
    new message[64];
    format(message, sizeof(message), "Teleported to shop ID %d.", tmpShopId);
    SendClientMessage(playerid, COLOR_GREEN, message);
    
    return 1;
}

// ============================================================================
// LEVEL 5 - MANAGEMENT COMMANDS
// ============================================================================

CMD:fly(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");

    new speed;
    
    // Check if a speed parameter was provided
    if(sscanf(params, "d", speed))
    {
        // No parameter given - toggle fly mode off if flying
        if(player[playerid][isflying])
        {
            player[playerid][isflying] = false;
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "* Fly mode offline.");
            TogglePlayerControllable(playerid, true);
            KillTimer(player[playerid][flyTimer]);
        }
        else
        {
            // Not flying and no speed given - use default speed of 8
            speed = 8;
            
            // Clamp speed between 1 and 15
            if(speed < 1) speed = 1;
            if(speed > 15) speed = 15;
            
            player[playerid][flySpeed] = speed;
            player[playerid][isflying] = true;
            
            new string[128];
            format(string, sizeof(string), "* Fly mode online (Speed: %d).", speed);
            SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, string);
            
            TogglePlayerControllable(playerid, false);
            player[playerid][flyTimer] = SetTimerEx("FlyTimer", 50, true, "d", playerid);
        }
    }
    else
    {
        // Speed parameter given - set fly speed (enable or update)
        // Clamp speed between 1 and 15
        if(speed < 1) speed = 1;
        if(speed > 15) speed = 15;
        
        player[playerid][flySpeed] = speed;
        
        if(!player[playerid][isflying])
        {
            player[playerid][isflying] = true;
            TogglePlayerControllable(playerid, false);
            player[playerid][flyTimer] = SetTimerEx("FlyTimer", 50, true, "d", playerid);
        }
        
        new string[128];
        format(string, sizeof(string), "* Fly mode speed set to %d.", speed);
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, string);
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

CMD:scavdelete(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
    
    new scavIndex = GetNearestScavArea(playerid);
    
    if(scavIndex == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not near any scav area.");
    
    new Float:distance = GetPlayerDistanceFromPoint(playerid, scavArea[scavIndex][scavPos][0], scavArea[scavIndex][scavPos][1], scavArea[scavIndex][scavPos][2]);
    
    if(distance > 5.0)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are too far from the nearest scav area. Get within 5 meters.");
    
    new tmpScavId = scavArea[scavIndex][scavId];
    
    if(DeleteScavArea(scavIndex))
    {
        new message[64];
        format(message, sizeof(message), "Scav area ID %d deleted successfully.", tmpScavId);
        SendClientMessage(playerid, COLOR_GREEN, message);
    }
    else
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Failed to delete scav area.");
    }
    
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

CMD:reloadloottables(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have a high enough admin rank to use this command.");
        
    new count = LoadLootTablesFromXML();
    SendClientMessageToAll(COLOR_SYSTEM, "Admin %s has reloaded %d loot tables from XML.", player[playerid][Name], count);
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

CMD:reloadshops(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to use this command.");
    
    // Destroy all current shops
    for(new i = 0; i < MAX_SHOPS; i++)
    {
        DestroyShopActor(i);
    }
    
    // Reload from database
    for(new i = 0; i < MAX_SHOPS; i++)
    {
        LoadShops(i);
    }

    SendClientMessage(playerid, COLOR_GREEN, "All shops reloaded from database.");
    
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
