// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - PLAYER COMMANDS
// ============================================================================
/*
* MODULE: Player Commands
* PURPOSE: General player command implementations
* 
* DEPENDENCIES:
* - core/config.pwn
* - core/constants.pwn
* - core/player_data.pwn
* - systems/inventory.pwn
* - utilities/dialogs.pwn
* - utilities/helpers.pwn
* - utilities/messaging.pwn
* 
* PUBLIC FUNCTIONS:
* GENERAL:
* - CMD:commands - Display available commands (4 pages)
* - CMD:changepass - Change account password
* - CMD:menu - Return to character selection
* 
 * INVENTORY & INTERACTION:
* - CMD:inv - Open inventory dialog
* - CMD:search - Search nearby loot areas
* - CMD:shop - Open shop menu (when near a shop)
* - CMD:perks - Open perk menu
* 
* VEHICLE:
* - CMD:engine - Toggle vehicle engine
* - CMD:fill - Refuel vehicle with gas can
* 
* COMMUNICATION:
* - CMD:s - Shout message (60 unit radius)
* - CMD:me - Roleplay action message (30 unit radius)
* - CMD:do - Environmental description (30 unit radius)
* - CMD:b - Out-of-character chat (30 unit radius)
* - CMD:g - Global chat
* 
* ANIMATIONS:
* - CMD:handsup, wave, crossarms, laugh, lookout, fucku, slapass
* - CMD:groundsit, chairsit, lay, inbedright, inbedleft
* - CMD:cellin, cellout
* - CMD:eat, smokem, smokef, chat, dance, taichi
* - CMD:rob, getarrested, graffiti, koface, kofront, koback
* 
* ZOMBIE ABILITIES:
* - CMD:bstr - Toggle borrowed strength
* - CMD:hunt - Mark target for hunt
* 
* DESCRIPTION:
* Contains all player-accessible commands including:
* - Information and help commands
* - Inventory management
* - Vehicle interactions
* - Communication systems
* - Roleplay animations
* - Zombie special abilities
*
* All commands use Pawn.CMD processor and include appropriate permission checks.
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_PLAYER_COMMANDS_INCLUDED
#define MODULE_PLAYER_COMMANDS_INCLUDED

// ============================================================================
// GENERAL COMMANDS
// ============================================================================

/*
* INFORMATION & HELP
*/
CMD:commands(playerid, params[])
{
    new message[2048];
    
    // Check if player wants to see animations list - Page 1
    if(!isnull(params) && !strcmp(params, "anims", true))
    {
        strcat(message, "{FF6B00}=== ROLEPLAY ANIMATIONS (Page 1/2) ===\n\n");
        strcat(message, "{FFFFFF}GESTURES & ACTIONS:\n");
        strcat(message, "{CCCCCC}- /handsup - Put hands up\n");
        strcat(message, "{CCCCCC}- /wave - Wave at someone\n");
        strcat(message, "{CCCCCC}- /crossarms - Cross arms\n");
        strcat(message, "{CCCCCC}- /laugh - Laugh animation\n");
        strcat(message, "{CCCCCC}- /lookout - Look around\n");
        strcat(message, "{CCCCCC}- /fucku - Middle finger gesture\n");
        strcat(message, "{CCCCCC}- /slapass - Slap ass animation\n\n");
        
        strcat(message, "{FFFFFF}SITTING & LAYING:\n");
        strcat(message, "{CCCCCC}- /groundsit - Sit on ground\n");
        strcat(message, "{CCCCCC}- /chairsit - Sit on chair\n");
        strcat(message, "{CCCCCC}- /lay - Lay down\n");
        strcat(message, "{CCCCCC}- /inbedright - Lay in bed (right side)\n");
        strcat(message, "{CCCCCC}- /inbedleft - Lay in bed (left side)\n\n");
        
        strcat(message, "{FFFFFF}PHONE & ITEMS:\n");
        strcat(message, "{CCCCCC}- /cellin - Take out cell phone\n");
        strcat(message, "{CCCCCC}- /cellout - Put away cell phone\n\n");
        
        strcat(message, "{FFFFFF}ACTIVITIES:\n");
        strcat(message, "{CCCCCC}- /eat - Eating animation\n");
        strcat(message, "{CCCCCC}- /smokem - Smoke (male style)\n");
        strcat(message, "{CCCCCC}- /smokef - Smoke (female style)\n");
        strcat(message, "{CCCCCC}- /chat - Chatting animation\n");
        strcat(message, "{CCCCCC}- /dance [1-4] - Dance styles\n");
        strcat(message, "{CCCCCC}- /taichi - Tai chi exercise\n\n");
        
        strcat(message, "{AAAAAA}Use /commands anims2 to view more animations (Page 2)\n");
        strcat(message, "{AAAAAA}Tip: Press SPRINT key to stop any looping animation.\n");
        
        ShowPlayerMessageBox(playerid, "Animation Commands - Page 1", message);
        return 1;
    }
    
    // Check if player wants to see animations list - Page 2
    if(!isnull(params) && !strcmp(params, "anims2", true))
    {
        strcat(message, "{FF6B00}=== ROLEPLAY ANIMATIONS (Page 2/2) ===\n\n");
        
        strcat(message, "{FFFFFF}SPECIAL/CRIMINAL:\n");
        strcat(message, "{CCCCCC}- /drunk - Drunk stumbling\n");
        strcat(message, "{CCCCCC}- /vomit - Vomit animation\n");
        strcat(message, "{CCCCCC}- /hide - Hide/duck down\n");
        strcat(message, "{CCCCCC}- /robman - Robbing animation\n");
        strcat(message, "{CCCCCC}- /getarrested - Get arrested pose\n");
        strcat(message, "{CCCCCC}- /bomb - Place bomb animation\n");
        strcat(message, "{CCCCCC}- /deal - Drug dealing gesture\n");
        strcat(message, "{CCCCCC}- /crack - Using drugs animation\n\n");
        
        strcat(message, "{AAAAAA}Use /commands anims to view Page 1 animations\n");
        strcat(message, "{AAAAAA}Use /commands to see all server commands.\n");
        strcat(message, "{AAAAAA}Tip: Press SPRINT key to stop any looping animation.\n");
        
        ShowPlayerMessageBox(playerid, "Animation Commands - Page 2", message);
        return 1;
    }
    
    // Commands list - Page 2
    if(!isnull(params) && !strcmp(params, "2", true))
    {
        strcat(message, "{FF6B00}=== SERVER COMMANDS (Page 2/2) ===\n\n");
        
        strcat(message, "{FFFFFF}ANIMATIONS:\n");
        strcat(message, "{CCCCCC}- /commands anims - View animation commands (Page 1)\n");
        strcat(message, "{CCCCCC}- /commands anims2 - View animation commands (Page 2)\n");
        strcat(message, "{CCCCCC}- Popular: /handsup /wave /sit /lay /eat /dance\n\n");
        
        strcat(message, "{FFFFFF}ZOMBIE ABILITIES:\n");
        strcat(message, "{CCCCCC}- /bstr - Toggle Borrowed Strength perk\n");
        strcat(message, "{CCCCCC}- /hunt [playerid] - Mark target for Hunt perk\n");
        strcat(message, "{CCCCCC}- {FFFF00}KEY_FIRE{CCCCCC} - Bite attack (unlockable)\n");
        strcat(message, "{CCCCCC}- {FFFF00}KEY_ACTION{CCCCCC} - Stun attack (unlockable)\n");
        strcat(message, "{CCCCCC}- {FFFF00}KEY_CROUCH{CCCCCC} - Grab/pull attack (unlockable)\n");
        strcat(message, "{CCCCCC}- {FFFF00}KEY_JUMP{CCCCCC} - Super jump (unlockable)\n\n");
        
        strcat(message, "{AAAAAA}Use /commands to view Page 1\n");
        strcat(message, "{AAAAAA}Tip: Press SPRINT key to stop any looping animation.\n");
        
        ShowPlayerMessageBox(playerid, "Server Commands - Page 2", message);
        return 1;
    }
    
    // Default commands list - Page 1
    strcat(message, "{FF6B00}=== SERVER COMMANDS (Page 1/2) ===\n\n");
    
    strcat(message, "{FFFFFF}ESSENTIAL:\n");
    strcat(message, "{CCCCCC}- /commands - Show this command list (Page 1)\n");
    strcat(message, "{CCCCCC}- /commands 2 - Show more commands (Page 2)\n");
    strcat(message, "{CCCCCC}- /changepass - Change your account password\n");
    strcat(message, "{CCCCCC}- /menu - Return to character selection menu\n\n");
    
    strcat(message, "{FFFFFF}INVENTORY & INTERACTION:\n");
    strcat(message, "{CCCCCC}- /inv - Open your inventory\n");
    strcat(message, "{CCCCCC}- /search - Search nearby area for items\n");
    strcat(message, "{CCCCCC}- /shop - Open shop menu (when near a shop)\n");
    strcat(message, "{CCCCCC}- /perks - Open perks menu to upgrade abilities\n\n");
    
    strcat(message, "{FFFFFF}VEHICLE:\n");
    strcat(message, "{CCCCCC}- /engine - Toggle vehicle engine on/off\n");
    strcat(message, "{CCCCCC}- /fill - Refuel vehicle or fill water canteen\n\n");
    
    strcat(message, "{FFFFFF}COMMUNICATION:\n");
    strcat(message, "{CCCCCC}- /s [text] - Shout (40 meter range)\n");
    strcat(message, "{CCCCCC}- /me [action] - Roleplay action (15 meter range)\n");
    strcat(message, "{CCCCCC}- /do [description] - Describe environment (15 meter range)\n");
    strcat(message, "{CCCCCC}- /b [text] - Out of character chat (15 meter range)\n");
    strcat(message, "{CCCCCC}- /g [text] - Global OOC chat (server-wide)\n\n");
    
    strcat(message, "{AAAAAA}Use /commands 2 to view animations & zombie abilities\n");
    
    ShowPlayerMessageBox(playerid, "Server Commands - Page 1", message);
    return 1;
}

/*
* ACCOUNT MANAGEMENT
*/
CMD:changepass(playerid, params[])
{
    Dialog_Show(playerid, ChangePasswordDialog, DIALOG_STYLE_PASSWORD, "Change Password", "Please enter a new password below:", "Confirm", "Close");
    return 1;
}

/*
* CHARACTER MENU
*/
CMD:menu(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    /*
    * Save the player's current player character data
    */
    SavePlayerCharacter(playerid, player[playerid][chosenChar]);

    /*
    * Set up the character menu Camera
    */
    SetPlayerColor(playerid, COLOR_GREY);
    HideHudForPlayer(playerid);
    player[playerid][isSpawned] = false;
    SetPlayerVirtualWorld(playerid, playerid + 1);
    TogglePlayerSpectating(playerid, true);
    InterpolateCameraPos(playerid, 2574.970214, 1117.667358, 19.598237, 2574.886230, 1092.619506, 11.116436, 3500);
	InterpolateCameraLookAt(playerid, 2574.863037, 1113.223510, 17.309003, 2574.867675, 1087.620971, 10.997186, 3500);
    SetPlayerName(playerid, player[playerid][Name]);

    /*
    * Kill the timers
    */
    if(player[playerid][fillVehicleTimer])
    {
        KillTimer(player[playerid][fillVehicleTimer]);
    }

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

    if(player[playerid][locationTimer])
    {
        KillTimer(player[playerid][locationTimer]);
    }

    /*
    * Show the character menu
    */
    PopulateCharacterMenu(playerid);
    return 1;
}

// ============================================================================
// INVENTORY & INTERACTION COMMANDS
// ============================================================================

CMD:inv(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");

    Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
    return 1;
}

CMD:search(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");

    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You can only use this command while on foot.");

    OnPlayerSearchNode(playerid);
    return 1;
}

CMD:shop(playerid, params[])
{
    if(!player[playerid][spawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You must be spawned to use this command.");
    
    new shopIndex = GetNearestShop(playerid);
    
    if(shopIndex == INVALID_SHOP_ID)
        return SendClientMessage(playerid, COLOR_RED, "You are not near a shop. Look for the green 'Shop' text label.");
    
    ShowShopMenu(playerid, shopIndex);
    return 1;
}

CMD:perks(playerid, params[])
{
    if(player[playerid][iszombie] == 1)
    {
        // Show zombie skill menu
        new skillListZombie[256];

        for (new i = 0; i < sizeof(zombieSkills); i++)
        {
            strcat(skillListZombie, zombieSkills[i]);
            strcat(skillListZombie, "\n");
        }

        Dialog_Show(playerid, PerkMenu, DIALOG_STYLE_LIST, "Zombie Perks", skillListZombie, "Select", "Close");
    }
    else
    {
        // Show human skill menu
        new skillListHuman[256];
        for (new i = 0; i < sizeof(humanSkills); i++)
        {
            strcat(skillListHuman, humanSkills[i]);
            strcat(skillListHuman, "\n");
        }
        Dialog_Show(playerid, PerkMenu, DIALOG_STYLE_LIST, "Human Perks", skillListHuman, "Select", "Close");
    }
    return 1;
}

// ============================================================================
// VEHICLE COMMANDS
// ============================================================================

CMD:engine(playerid, params[])
{
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");

    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You have to be in the driver's seat of a vehicle to use this command.");

    if((GetTickCount() - player[playerid][engineAntiSpam]) < 5000)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 5 seconds between uses of this command.");
    
    /*
    * Attempt to start the vehicle
    */
    StartVehicleAttempt(playerid);
    return 1;
}

CMD:fill(playerid, params[])
{
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");
        
    // check if player is close enough to a valid fuel pump
    if(!IsPlayerAtFuelPump(playerid))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You are not close enough to a fuel pump.");

    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You can only use this command on foot.");

    // get pos of vehicle the player was last in
    GetVehiclePos(player[playerid][lastInVehId], player[playerid][tmpVehPos][0], player[playerid][tmpVehPos][1], player[playerid][tmpVehPos][2]);

    if(!IsPlayerInRangeOfPoint(playerid, 5.0, player[playerid][tmpVehPos][0], player[playerid][tmpVehPos][1], player[playerid][tmpVehPos][2]))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You are not close enough to your vehicle.");

    if(serverVehicle[player[playerid][lastInVehId]][isBeingFilled])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "That vehicle is already being filled.");

    serverVehicle[player[playerid][lastInVehId]][isBeingFilled] = true;
    ShowHudForPlayer(playerid, HUD_VEHICLE);
    player[playerid][fillVehicleTimer] = SetTimerEx("FillVehicleTimer", 1000, true, "ddd", playerid, player[playerid][lastInVehId], FILL_TYPE_FUELPUMP);
    return 1;
}

// ============================================================================
// COMMUNICATION COMMANDS
// ============================================================================

CMD:s(playerid, params[])
{
    if(isnull(params))
        SendClientMessage(playerid, -1, "USAGE: /s(hout) [message]");

    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    if(player[playerid][iszombie] == 1)
	{
        SendProxMessage(playerid, COLOR_RP_PURPLE, 50.0, PROXY_MSG_TYPE_OTHER, "snarls and groans");
    }
    else
    {
        SendProxMessage(playerid, COLOR_WHITE, 50.0, PROXY_MSG_TYPE_SHOUT, params);
    }
    return 1;
}

CMD:me(playerid, params[])
{
    if(isnull(params))
        SendClientMessage(playerid, -1, "USAGE: /me [action]");

    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_ME, params);
    return 1;
}

CMD:do(playerid, params[])
{
    if(isnull(params))
        SendClientMessage(playerid, -1, "USAGE: /do [action]");

    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_DO, params);
    return 1;
}

CMD:b(playerid, params[])
{
    if(isnull(params))
        SendClientMessage(playerid, -1, "USAGE: /b [message]");

    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    SendProxMessage(playerid, COLOR_GREY, 30.0, PROXY_MSG_TYPE_CHAT, params);
    return 1;
}

CMD:g(playerid, params[])
{
    if(isnull(params))
        SendClientMessage(playerid, -1, "USAGE: /g [message]");

    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    SendClientMessageToAll(COLOR_WHITE, "((%s says: %s))", player[playerid][chosenChar], params);
    return 1;
}

// ============================================================================
// ANIMATION COMMANDS
// ============================================================================

/*
* GESTURES & ACTIONS
*/
CMD:handsup(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_HANDSUP);
	return 1;
}

CMD:wave(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid, "ON_LOOKERS", "wave_loop", 4.0, 1, 0, 0, 0, 0); // Wave
	return 1;
}

CMD:crossarms(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 0, 1, 1, 1, -1); // Arms crossed
	return 1;
}

CMD:laugh(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid, "RAPPING", "Laugh_01", 4.0, 0, 0, 0, 0, 0); // Laugh
	return 1;
}

CMD:lookout(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid, "SHOP", "ROB_Shifty", 4.0, 0, 0, 0, 0, 0); // Rob Lookout
	return 1;
}

CMD:fucku(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid,"PED","fucku",4.0,0,0,0,0,0);
	return 1;
}

CMD:slapass(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid, "SWEET", "sweet_ass_slap", 4.0, 0, 0, 0, 0, 0); // Ass Slapping
	return 1;
}

/*
* SITTING & LAYING
*/
CMD:groundsit(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 0, 0); // Sit
	return 1;
}

CMD:chairsit(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"BAR","dnk_stndF_loop",4.0,1,0,0,0,0);
	return 1;
}

CMD:lay(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"BEACH", "bather", 4.0, 1, 0, 0, 0, 0); // Lay down
	return 1;
}

CMD:inbedright(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"INT_HOUSE","BED_Loop_R",4.0,1,0,0,0,0);
	return 1;
}

CMD:inbedleft(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"INT_HOUSE","BED_Loop_L",4.0,1,0,0,0,0);
	return 1;
}

/*
* PHONE & ITEMS
*/
CMD:cellin(playerid, params[])
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);
	return 1;
}

// CELLPHONE OUT
CMD:cellout(playerid, params[])
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
	return 1;
}

/*
* ACTIVITIES
*/
CMD:eat(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0); // Eat Burger
	return 1;
}

CMD:smokem(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"SMOKING", "M_smklean_loop", 4.0, 1, 0, 0, 0, 0); // Smoke
	return 1;
}

CMD:smokef(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid, "SMOKING", "F_smklean_loop", 4.0, 1, 0, 0, 0, 0); // Female Smoking
	return 1;
}

CMD:chat(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid,"PED","IDLE_CHAT",4.0,0,0,0,0,0);
	return 1;
}

CMD:dance(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	new danceid = strval(params);

	if(isnull(params))
        return SendClientMessage(playerid, 0xAFAFAFAA, "USAGE: /dance [1-4]");

	if(danceid < 1 || danceid > 4)
        return SendClientMessage(playerid,0xFF0000FF,"USAGE: /dance [1-4]");

	switch(danceid)
	{
		case 1: SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE1);
		case 2: SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE2);
		case 3: SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE3);
		case 4: SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE4);
 	}
	return 1;
}

CMD:taichi(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"PARK","Tai_Chi_Loop",4.0,1,0,0,0,0);
	return 1;
}

/*
* SPECIAL/CRIMINAL
*/
CMD:robman(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid, "SHOP", "ROB_Loop_Threat", 4.0, 1, 0, 0, 0, 0); // Rob
	return 1;
}

CMD:getarrested(playerid, params[])
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"ped", "ARRESTgun", 4.0, 0, 1, 1, 1, -1); // Gun Arrest
	return 1;
}

CMD:graffiti(playerid, params[])
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"GRAFFITI","spraycan_fire",4.0,1,0,0,0,0);
	return 1;
}

CMD:koface(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"PED","KO_shot_face",4.0,0,1,1,1,-1);
	return 1;
}

CMD:kofront(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"PED","KO_shot_front",4.0,0,1,1,1,-1);
	return 1;
}

CMD:koback(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"PED","KO_shot_stom",4.0,0,1,1,1,-1);
	return 1;
}

CMD:drunk(playerid, params[])
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"PED","WALK_DRUNK",4.0,1,1,1,1,0);
	return 1;
}

CMD:vomit(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0); // Vomit BAH!
	return 1;
}

CMD:hide(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid, "ped", "cower", 3.0, 1, 0, 0, 0, 0); // Taking Cover
	return 1;
}

CMD:bomb(playerid, params[])
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	ClearAnimations(playerid);
	OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0); // Place Bomb
	return 1;
}

CMD:deal(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid, "DEALER", "DEALER_DEAL", 4.0, 0, 0, 0, 0, 0); // Deal Drugs
	return 1;
}

CMD:crack(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0); // Dieing of Crack
	return 1;
}

// ============================================================================
// ZOMBIE ABILITIES COMMANDS
// ============================================================================

CMD:bstr(playerid, params[])
{
    if (player[playerid][iszombie] && player[playerid][unlockedBorrowedStrengthSkill])
    {
        if ((GetTickCount() - player[playerid][borrowedStrengthAntiSpam]) < 30000)
            return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 30 seconds between uses of this command.");

        new Float:damage;

        if(sscanf(params, "d", damage))
            return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Usage: /bstr [amount]");

        if(damage <= 0 || damage >= player[playerid][health])
            return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Invalid health amount.");

        SetTimerEx("unlockedBorrowedStrengthSkillActiveTimer", 30000, false, "d", playerid); // One-time timer
        player[playerid][health] -= damage;
        player[playerid][unlockedBorrowedStrengthSkillDamage] = damage * 0.25;
        player[playerid][unlockedBorrowedStrengthSkillActive] = true;

        SetPlayerHealth(playerid, player[playerid][health]);
        UpdateHudElementForPlayer(playerid, HUD_HEALTH);
        player[playerid][borrowedStrengthAntiSpam] = GetTickCount();
        SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER, "channels their strength through blood sacrifice, becoming momentarily stronger.");
        return 1;
    }

    SendClientMessage(playerid, COLOR_RED, "You can't do that!");
    return 0;
}

CMD:hunt(playerid, params[])
{
    if (player[playerid][iszombie] && player[playerid][unlockedHuntSkill])
    {
        new target;

        if(sscanf(params, "d", target))
		    return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Usage: /hunt [id]");

        new Float:targetX, Float:targetY, Float:targetZ;
        GetPlayerPos(target, targetX, targetY, targetZ);

        if (IsPlayerInRangeOfPoint(playerid, 60.0, targetX, targetY, targetZ))
        {
            SendClientMessage(playerid, COLOR_RP_PURPLE, "Your senses flare up. Every distraction fades away into a red haze, only your prey remains.");
            SendClientMessage(target, COLOR_RP_PURPLE, "Something makes the hairs stand up on your back neck");
            SetPlayerMarkerForPlayer(playerid, target, 0xFF0000FF);
            player[playerid][huntActive]=true;
            player[playerid][huntTarget]=target;
        }
        else
        {
            return SendClientMessage(playerid, COLOR_RP_PURPLE, "The target is too far.");
        }
        return 1;
    }

    SendClientMessage(playerid, COLOR_RED, "You can't do that!");
    return 0;
}
#endif // MODULE_PLAYER_COMMANDS_INCLUDED
