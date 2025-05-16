/*
* Zombie Outbreak Roleplay
* (C) 2025 Zombie Outbreak Development Contributors
* GNU General Public License v3.0
*/

@cmd() commands(playerid, params[], help)
{
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/changepass /menu /inv /search /purchaseproperty /myproperties /faction /finvite /facceptinvite /fdenyinvite");
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "/s /me /do /b /g");
    return 1;
}

@cmd() changepass(playerid, params[], help)
{
    Dialog_ShowCallback(playerid, using public ChangePasswordDialog<iiiis>, DIALOG_STYLE_PASSWORD, "Change Password", "Please enter a new password below:", "Confirm", "Close");
    return 1;
}

@cmd() menu(playerid, params[], help)
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
    KillTimer(player[playerid][hungerTimer]);
	KillTimer(player[playerid][thirstTimer]);
	KillTimer(player[playerid][diseaseTimer]);
    KillTimer(player[playerid][fuelTimer]);

    /*
    * Show the character menu
    */
    PopulateCharacterMenu(playerid);
    return 1;
}

/*
* Inventory
*/
@cmd() inv(playerid, params[], help)
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");

    Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
    return 1;
}

@cmd() search(playerid, params[], help)
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

/*
* Faction System
*/
@cmd() faction(playerid, params[], help)
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");

    if(player[playerid][plrFaction] > 0) // player is already in a faction
    {
        if(player[playerid][factionrank] >= 9) // is the faction leader/creator or the co-leader
        {
            Dialog_ShowCallback(playerid, using public FactionMain_Leader<iiiis>, DIALOG_STYLE_LIST, "Manage Faction", "Edit Faction Name\nManage Ranks\nManage Members", "Select", "Close");
        }
        else // anyone else within the faction
        {
            Dialog_ShowCallback(playerid, using public FactionMain_Member<iiiis>, DIALOG_STYLE_LIST, "Faction Options", "Leave Faction", "Select", "Close");
        }
    }
    else // not in a faction 
    {
        Dialog_ShowCallback(playerid, using public CreateFactionQuestion<iiiis>, DIALOG_STYLE_MSGBOX, "Create a Faction?", "You are not in a faction. Would you like to create one?", "Yes", "No");
    }
    return 1;
}

@cmd() finvite(playerid, params[], help)
{
    new target;

    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");

    if(player[playerid][factionrank] < 9)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You are not in the faction leadership so cannot invite new members.");

    if(sscanf(params, "i", target)) 
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Syntax error. Correct usage: /finvite [playerid]");

    if(target == playerid)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot invite yourself.");

    if(player[target][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot invite zombies to your faction.");

    if(player[target][plrFaction] > 0)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "That person is already in a faction.");

    player[target][facInviteId] = player[playerid][plrFaction];
    format(player[target][facInvitedBy], MAX_PLAYER_NAME, "%s", player[playerid][chosenChar]);
    SendClientMessage(target, COLOR_YELLOW, "You have been invited to join %s's faction.", player[playerid][chosenChar]);
    SendClientMessage(target, COLOR_GREEN, "Use /facceptinvite to accept.");
    SendClientMessage(target, COLOR_RED, "Use /fdenyinvite to refuse.");
    SendClientMessage(playerid, COLOR_YELLOW, "You have invited %s to join your faction.", player[target][chosenChar]);
    return 1;
}

@cmd() facceptinvite(playerid, params[], help)
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");

    if(player[playerid][facInviteId] <= 0)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You do not have an active faction invite.");

    player[playerid][plrFaction] = player[playerid][facInviteId];
	player[playerid][factionrank] = 1; // set to lowest rank

	DB_ExecuteQuery(database, "UPDATE characters SET faction = '%d', factionrank = '1' WHERE name = '%q'", player[playerid][plrFaction], player[playerid][chosenChar]);
    SendClientMessage(playerid, COLOR_GREEN, "You accepted %s's invite to join their faction.", player[playerid][facInvitedBy]);
    SendClientMessage(GetPlayerIdFromName(player[playerid][facInvitedBy]), COLOR_GREEN, "%s accepted your faction invite.", player[playerid][chosenChar]);
    return 1;
}

@cmd() fdenyinvite(playerid, params[], help)
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");

    if(player[playerid][facInviteId] <= 0)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You do not have an active faction invite.");

    SendClientMessage(playerid, COLOR_RED, "You denied %s's invite to join their faction.", player[playerid][facInvitedBy]);
    SendClientMessage(GetPlayerIdFromName(player[playerid][facInvitedBy]), COLOR_RED, "%s denied your faction invite.", player[playerid][chosenChar]);
    return 1;
}

/*
* Vehicle commands
*/
@cmd() engine(playerid, params[], help)
{
    new tmpVehicleId = GetPlayerVehicleID(playerid);
    new chanceToStart = RandomRange(1, 100);

    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You have to be in the driver's seat of a vehicle to use this command.");

    if((GetTickCount() - player[playerid][engineAntiSpam]) < 5000)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 5 seconds between uses of this command.");

    if(serverVehicle[tmpVehicleId][engine])
    {
        SendClientMessage(playerid, COLOR_RED, "Vehicle stopped.");
        SetVehicleEngineOff(tmpVehicleId);
        HideHudElementForPlayer(playerid, HUD_VEHICLE);
        KillTimer(player[playerid][fuelTimer]);
        serverVehicle[tmpVehicleId][engine] = false;

        /*
        * Stop the command being used too often
        */
        player[playerid][engineAntiSpam] = GetTickCount();
        return 1;
    }

    switch(floatround(serverVehicle[tmpVehicleId][vehHealth]))
    {
        case 250 .. 350:
        {
            switch(chanceToStart)
            {
                case 1 .. 85: // 85% chance to fail
                {
                    SendClientMessage(playerid, COLOR_RED, "Failed to start the vehicle.");
                }
                case 86 .. 100:
                {
                    SendClientMessage(playerid, COLOR_RED, "Vehicle started.");
                    SetVehicleEngineOn(tmpVehicleId);
                    ShowHudForPlayer(playerid, HUD_VEHICLE);
                    UpdateHudElementForPlayer(playerid, HUD_VEHICLE);
                    player[playerid][fuelTimer] = SetTimerEx("FuelTimer", 25000, true, "dd", playerid, tmpVehicleId);
                    serverVehicle[tmpVehicleId][engine] = true;
                }
            }
        }
        case 351 .. 500:
        {
            switch(chanceToStart)
            {
                case 1 .. 65: // 65% chance to fail
                {
                    SendClientMessage(playerid, COLOR_RED, "Failed to start the vehicle.");
                }
                case 66 .. 100:
                {
                    SendClientMessage(playerid, COLOR_RED, "Vehicle started.");
                    SetVehicleEngineOn(tmpVehicleId);
                    ShowHudForPlayer(playerid, HUD_VEHICLE);
                    UpdateHudElementForPlayer(playerid, HUD_VEHICLE);
                    player[playerid][fuelTimer] = SetTimerEx("FuelTimer", 25000, true, "dd", playerid, tmpVehicleId);
                    serverVehicle[tmpVehicleId][engine] = true;
                }
            }
        }
        case 501 .. 700:
        {
            switch(chanceToStart)
            {
                case 1 .. 45: // 45% chance to fail
                {
                    SendClientMessage(playerid, COLOR_RED, "Failed to start the vehicle.");
                }
                case 46 .. 100:
                {
                    SendClientMessage(playerid, COLOR_RED, "Vehicle started.");
                    SetVehicleEngineOn(tmpVehicleId);
                    ShowHudForPlayer(playerid, HUD_VEHICLE);
                    UpdateHudElementForPlayer(playerid, HUD_VEHICLE);
                    player[playerid][fuelTimer] = SetTimerEx("FuelTimer", 25000, true, "dd", playerid, tmpVehicleId);
                    serverVehicle[tmpVehicleId][engine] = true;
                }
            }
        }
        case 701 .. 850:
        {
            switch(chanceToStart)
            {
                case 1 .. 25: // 25% chance to fail
                {
                    SendClientMessage(playerid, COLOR_RED, "Failed to start the vehicle.");
                }
                case 26 .. 100:
                {
                    SendClientMessage(playerid, COLOR_RED, "Vehicle started.");
                    SetVehicleEngineOn(tmpVehicleId);
                    ShowHudForPlayer(playerid, HUD_VEHICLE);
                    UpdateHudElementForPlayer(playerid, HUD_VEHICLE);
                    player[playerid][fuelTimer] = SetTimerEx("FuelTimer", 25000, true, "dd", playerid, tmpVehicleId);
                    serverVehicle[tmpVehicleId][engine] = true;
                }
            }
        }
        case 851 .. 1000:
        {
            switch(chanceToStart)
            {
                case 1 .. 5: // 5% chance to fail
                {
                    SendClientMessage(playerid, COLOR_RED, "Failed to start the vehicle.");
                }
                case 6 .. 100:
                {
                    SendClientMessage(playerid, COLOR_RED, "Vehicle started.");
                    SetVehicleEngineOn(tmpVehicleId);
                    ShowHudForPlayer(playerid, HUD_VEHICLE);
                    UpdateHudElementForPlayer(playerid, HUD_VEHICLE);
                    player[playerid][fuelTimer] = SetTimerEx("FuelTimer", 25000, true, "dd", playerid, tmpVehicleId);
                    serverVehicle[tmpVehicleId][engine] = true;
                }
            }
        }
    }

    /*
    * Stop the command being used too often
    */
    player[playerid][engineAntiSpam] = GetTickCount();
    return 1;
}

@cmd() fill(playerid, params[], help)
{
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

/*
* Roleplay Chat Commands
*/
@cmd() s(playerid, params[], help)
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

@cmd() me(playerid, params[], help)
{
    if(isnull(params))
        SendClientMessage(playerid, -1, "USAGE: /me [action]");

    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_ME, params);
    return 1;
}

@cmd() do(playerid, params[], help)
{
    if(isnull(params))
        SendClientMessage(playerid, -1, "USAGE: /do [action]");

    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_DO, params);
    return 1;
}

@cmd() b(playerid, params[], help)
{
    if(isnull(params))
        SendClientMessage(playerid, -1, "USAGE: /b [message]");

    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    SendProxMessage(playerid, COLOR_GREY, 30.0, PROXY_MSG_TYPE_CHAT, params);
    return 1;
}

@cmd() g(playerid, params[], help)
{
    if(isnull(params))
        SendClientMessage(playerid, -1, "USAGE: /g [message]");

    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this command if you are not spawned as a character.");

    SendClientMessageToAll(COLOR_WHITE, "((%s says: %s))", player[playerid][chosenChar], params);
    return 1;
}

/*
* Animation commands
*/
@cmd() animlist(playerid, params[], help)
{
	SendClientMessage(playerid, 0xAFAFAFAA, "Available Animations:");
  	SendClientMessage(playerid, 0xAFAFAFAA, "/handsup /drunk /bomb /getarrested /laugh /lookout /robman");
    SendClientMessage(playerid, 0xAFAFAFAA, "/crossarms /lay /hide /vomit /eat /wave /taichi");
    SendClientMessage(playerid, 0xAFAFAFAA, "/deal /crack /smokem /smokef /groundsit /chat /dance /fucku");
    return 1;
}

// HANDSUP
@cmd() handsup(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_HANDSUP);
	return 1;
}

// CELLPHONE IN
@cmd() cellin(playerid, params[], help)
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);
	return 1;
}

// CELLPHONE OUT
@cmd() cellout(playerid, params[], help)
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
	return 1;
}

// Drunk
@cmd() drunk(playerid, params[], help)
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"PED","WALK_DRUNK",4.0,1,1,1,1,0);
	return 1;
}

// Place a Bomb
@cmd() bomb(playerid, params[], help)
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	ClearAnimations(playerid);
	OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0); // Place Bomb
	return 1;
}

// Police Arrest
@cmd() getarrested(playerid, params[], help)
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"ped", "ARRESTgun", 4.0, 0, 1, 1, 1, -1); // Gun Arrest
	return 1;
}

// Laugh
@cmd() laugh(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid, "RAPPING", "Laugh_01", 4.0, 0, 0, 0, 0, 0); // Laugh
	return 1;
}

// Rob Lookout
@cmd() lookout(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid, "SHOP", "ROB_Shifty", 4.0, 0, 0, 0, 0, 0); // Rob Lookout
	return 1;
}

// Rob Threat
@cmd() robman(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid, "SHOP", "ROB_Loop_Threat", 4.0, 1, 0, 0, 0, 0); // Rob
	return 1;
}

// Arms crossed
@cmd() crossarms(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 0, 1, 1, 1, -1); // Arms crossed
	return 1;
}

// Lay Down
@cmd() lay(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"BEACH", "bather", 4.0, 1, 0, 0, 0, 0); // Lay down
	return 1;
}

// Take Cover
@cmd() hide(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid, "ped", "cower", 3.0, 1, 0, 0, 0, 0); // Taking Cover
	return 1;
}

// Vomit
@cmd() vomit(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0); // Vomit BAH!
	return 1;
}

// Eat
@cmd() eat(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0); // Eat Burger
	return 1;
}

// Wave
@cmd() wave(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid, "ON_LOOKERS", "wave_loop", 4.0, 1, 0, 0, 0, 0); // Wave
	return 1;
}

// Slap Ass
@cmd() slapass(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid, "SWEET", "sweet_ass_slap", 4.0, 0, 0, 0, 0, 0); // Ass Slapping
	return 1;
}

// Dealer
@cmd() deal(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid, "DEALER", "DEALER_DEAL", 4.0, 0, 0, 0, 0, 0); // Deal Drugs
	return 1;
}

// Crack Dieing
@cmd() crack(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0); // Dieing of Crack
	return 1;
}

// Male Smoking
@cmd() smokem(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"SMOKING", "M_smklean_loop", 4.0, 1, 0, 0, 0, 0); // Smoke
	return 1;
}

// Female Smoking
@cmd() smokef(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid, "SMOKING", "F_smklean_loop", 4.0, 1, 0, 0, 0, 0); // Female Smoking
	return 1;
}

// Sit
@cmd() groundsit(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 0, 0); // Sit
	return 1;
}

// Idle Chat
@cmd() chat(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid,"PED","IDLE_CHAT",4.0,0,0,0,0,0);
	return 1;
}

// Fucku
@cmd() fucku(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	OnePlayAnim(playerid,"PED","fucku",4.0,0,0,0,0,0);
	return 1;
}

// TaiChi
@cmd() taichi(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"PARK","Tai_Chi_Loop",4.0,1,0,0,0,0);
	return 1;
}

// ChairSit
@cmd() chairsit(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"BAR","dnk_stndF_loop",4.0,1,0,0,0,0);
	return 1;
}

// Would allow people to troll... but would be cool as a script controlled function - hence why they are not on the commands list
// Bed Sleep R
@cmd() inbedright(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"INT_HOUSE","BED_Loop_R",4.0,1,0,0,0,0);
	return 1;
}

// Bed Sleep L
@cmd() inbedleft(playerid, params[], help)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
        return SendClientMessage(playerid, 0xAFAFAFAA, "You cannot use anims in the vehicles");

	LoopingAnim(playerid,"INT_HOUSE","BED_Loop_L",4.0,1,0,0,0,0);
	return 1;
}

// START DANCING
@cmd() dance(playerid, params[], help)
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
