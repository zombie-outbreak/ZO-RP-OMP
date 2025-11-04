// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - TIMERS MODULE
// ============================================================================
/*
* MODULE: Timers
* PURPOSE: All timer callbacks and repeating functions
* 
* DEPENDENCIES:
* - core/player_data.pwn (player arrays)
* - core/config.pwn (timer intervals)
* - systems/vehicles.pwn (fuel system)
* - utilities/textdraws.pwn (HUD updates)
* 
* PUBLIC FUNCTIONS:
* - ServerTime() - Updates server time and world time
* - ServerWeather() - Updates server weather
* - SpawnTimer(playerid) - Handles spawn countdown
* - TimedKick(playerid) - Delayed kick
* - TimedBan(playerid) - Delayed ban
* - FlyTimer(playerid) - Fly mode camera updates
* - PlayerChecks() - Anti-cheat checks for all players
* - DelayedKick(playerid, time) - Kick with delay
* - OnLoginTimeout(playerid) - Login timeout handler
* - ResetSearchZone(zoneid) - Resets search zone loot
* - HungerTimer(playerid) - Hunger decay timer
* - ThirstTimer(playerid) - Thirst decay timer
* - DiseaseTimer(playerid) - Disease damage timer
* - FuelTimer(playerid, vehicleid) - Vehicle fuel consumption
* - FillVehicleTimer(playerid, vehicleid, fillType) - Vehicle refuel timer
* - AntiMessageSpamTimer(playerid) - Message spam cooldown
* - LoginCamera(playerid) - Login screen camera rotation
* - HideInfoBox(playerid) - Hides info box after delay
* - RespawnAfterDeath(playerid) - Respawn delay after death
* - stunCooldownTimer(playerid) - Stun ability cooldown
* - biteCooldownTimer(playerid) - Bite ability cooldown
* - grabCooldownTimer(playerid) - Grab ability cooldown
* - superJumpCooldownTimer(playerid) - Super jump cooldown
* - unlockedBorrowedStrengthSkillActiveTimer(playerid) - Borrowed strength duration
* - DelayedShowCharacterMenu(playerid) - Character menu delay
* - TimedSavePlayerCharacterLocation(playerid) - Auto-save location
* 
* DESCRIPTION:
* Manages all game timers including server time, weather, player stats decay,
* vehicle fuel, cooldown timers for zombie abilities, and various delayed actions.
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_TIMERS_INCLUDED
#define MODULE_TIMERS_INCLUDED

// ============================================================================
// TIMER FORWARD DECLARATIONS
// ============================================================================

forward ServerTime();
forward ServerWeather();
forward SpawnTimer(playerid);
forward TimedKick(playerid);
forward TimedBan(playerid);
forward FlyTimer(playerid);
forward PlayerChecks();
forward DelayedKick(playerid, time);
forward DelayedKickPlayer(playerid);
forward OnLoginTimeout(playerid);
forward ResetSearchZone(zoneid);
forward HungerTimer(playerid);
forward ThirstTimer(playerid);
forward DiseaseTimer(playerid);
forward FuelTimer(playerid, vehicleid);
forward FillVehicleTimer(playerid, vehicleid, fillType);
forward AntiMessageSpamTimer(playerid);
forward LoginCamera(playerid);
forward HideInfoBox(playerid);
forward RespawnAfterDeath(playerid);
forward unlockedBorrowedStrengthSkillActiveTimer(playerid);
forward stunCooldownTimer(playerid);
forward biteCooldownTimer(playerid);
forward grabCooldownTimer(playerid);
forward superJumpCooldownTimer(playerid);
forward DelayedShowCharacterMenu(playerid);
forward TimedSavePlayerCharacterLocation(playerid);

// ============================================================================
// TIMER IMPLEMENTATIONS
// ============================================================================

public ServerTime()
{
	new string[64];
    new hour, minute, second;
    gettime(hour, minute, second);

    format(string,sizeof(string),"%02d:%02d:%02d", hour, minute, second);
    TextDrawSetString(Clock, string);
    SetWorldTime(hour);

    for(new i = 0; i < MAX_PLAYERS; i++)
	{
        if(IsPlayerConnected(i))
        {
            if(player[i][spawned] == 0)
                continue;

            if(IsPlayerNPC(i)) // skip NPCs
                continue;

            if(GetPlayerState(i) != PLAYER_STATE_NONE)
            {
                SetPlayerTime(i, hour, minute);
            }
            
            // daily restart warnings at 30, 15, 10, 5, and 1 minutes
            if(hour == 5 && minute == 30)
            {
                SendPlayerServerMessage(i, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Server is restarting in 30 minutes.");
            }
            else if(hour == 5 && minute == 45)
            {
                SendPlayerServerMessage(i, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Server is restarting in 15 minutes.");
            }
            else if(hour == 5 && minute == 50)
            {
                SendPlayerServerMessage(i, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Server is restarting in 10 minutes.");
            }
            else if(hour == 5 && minute == 55)
            {
                SendPlayerServerMessage(i, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Server is restarting in 5 minutes.");
            }
            else if(hour == 5 && minute == 59)
            {
                SendPlayerServerMessage(i, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Server is restarting in 1 minute.");
            }
            
            // final message
            if(hour == 5 && minute == 59 && second == 50)
            {
                SendPlayerServerMessage(i, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Server restarting imminently.");
            }
        }
	}
    return 1;
}

public ServerWeather()
{
    SetWeather(random(22));
    for(new i = 0; i < MAX_PLAYERS; i++)
	{
        if(IsPlayerNPC(i)) // skip NPCs
            continue;

	    if(IsPlayerConnected(i) && GetPlayerState(i) != PLAYER_STATE_NONE)
		{
            SetPlayerWeather(i, GetWeather());
        }
    }
    return 1;
}

public SpawnTimer(playerid)
{
    // Check and correct gravity
	SetPlayerSkin(playerid, player[playerid][skin]);
    
    // Set the player's gravity if they have the jump skill
    if(player[playerid][unlockedJumpSkill])
    {
        SetPlayerGravity(playerid, JUMP_SKILL_GRAVITY);
    }
    else
    {
        SetPlayerGravity(playerid, DEFAULT_SERVER_GRAVITY);
    }
    
    // Now allow the player to move
    TogglePlayerControllable(playerid, true);
}

public stunCooldownTimer(playerid)
{
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Stun cooldown expired.");
}

public biteCooldownTimer(playerid)
{
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Bite cooldown expired.");
}

public grabCooldownTimer(playerid)
{
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Grab cooldown expired.");
}

public unlockedBorrowedStrengthSkillActiveTimer(playerid)
{
    player[playerid][unlockedBorrowedStrengthSkillActive] = false;
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Borrowed strength cooldown expired.");
}

public superJumpCooldownTimer(playerid)
{
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Super jump cooldown expired.");
}

public TimedKick(playerid)
{
	Kick(playerid);
}

public TimedBan(playerid)
{
	Ban(playerid);
}

public FlyTimer(playerid)
{
    if(!IsPlayerConnected(playerid) || !player[playerid][isflying])
        return 1;
    
    new keys, updown, leftright;
    new Float:moveSpeed = float(player[playerid][flySpeed]); // Use player's chosen speed
    new Float:verticalSpeed = float(player[playerid][flySpeed]); // Use player's chosen speed
    new Float:turnSpeed = 15.0; // Turn speed remains constant
    new bool:needsCameraUpdate = false;
    new playerState = GetPlayerState(playerid);
    
    GetPlayerKeys(playerid, keys, updown, leftright);
    
    // Early exit if no keys pressed
    if(updown == 0 && leftright == 0 && keys != KEY_JUMP && keys != KEY_SPRINT)
        return 1;
    
    if(playerState == PLAYER_STATE_ONFOOT)
    {
        GetPlayerPos(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
        
        // Forward/Backward movement
        if(updown == KEY_UP)
        {
            GetXYInFrontOfPlayer(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], moveSpeed);
            needsCameraUpdate = true;
        }
        else if(updown == KEY_DOWN)
        {
            GetXYBehindPlayer(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], moveSpeed);
            needsCameraUpdate = true;
        }
        
        // Turning
        if(leftright == KEY_LEFT)
        {
            GetPlayerFacingAngle(playerid, player[playerid][flyPos][3]);
            SetPlayerFacingAngle(playerid, player[playerid][flyPos][3] + turnSpeed);
            needsCameraUpdate = true;
        }
        else if(leftright == KEY_RIGHT)
        {
            GetPlayerFacingAngle(playerid, player[playerid][flyPos][3]);
            SetPlayerFacingAngle(playerid, player[playerid][flyPos][3] - turnSpeed);
            needsCameraUpdate = true;
        }
        
        // Vertical movement
        if(keys == KEY_JUMP)
        {
            player[playerid][flyPos][2] += verticalSpeed;
            needsCameraUpdate = true;
        }
        else if(keys == KEY_SPRINT)
        {
            player[playerid][flyPos][2] -= verticalSpeed;
            needsCameraUpdate = true;
        }
        
        // Apply position changes
        if(updown != 0 || keys == KEY_JUMP || keys == KEY_SPRINT)
        {
            SetPlayerPos(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
        }
        
        // Only update camera when needed
        if(needsCameraUpdate)
            SetCameraBehindPlayer(playerid);
    }
    else if(playerState == PLAYER_STATE_DRIVER)
    {
        new playerVehicle = GetPlayerVehicleID(playerid);
        GetVehiclePos(playerVehicle, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
        
        // Forward/Backward movement
        if(updown == KEY_UP)
        {
            GetXYInFrontOfPlayer(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], moveSpeed);
        }
        else if(updown == KEY_DOWN)
        {
            GetXYBehindPlayer(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], moveSpeed);
        }
        
        // Turning
        if(leftright == KEY_LEFT)
        {
            GetVehicleZAngle(playerVehicle, player[playerid][flyPos][3]);
            SetVehicleZAngle(playerVehicle, player[playerid][flyPos][3] + turnSpeed);
        }
        else if(leftright == KEY_RIGHT)
        {
            GetVehicleZAngle(playerVehicle, player[playerid][flyPos][3]);
            SetVehicleZAngle(playerVehicle, player[playerid][flyPos][3] - turnSpeed);
        }
        
        // Vertical movement
        if(keys == KEY_JUMP)
        {
            player[playerid][flyPos][2] += verticalSpeed;
        }
        else if(keys == KEY_SPRINT)
        {
            player[playerid][flyPos][2] -= verticalSpeed;
        }
        
        // Apply position changes
        if(updown != 0 || keys == KEY_JUMP || keys == KEY_SPRINT)
        {
            SetVehiclePos(playerVehicle, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
        }
    }
    
    return 1;
}

public PlayerChecks()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(player[i][spawned] == 0)
            continue;

        if(IsPlayerNPC(i)) // skip NPCs
            continue;
            
        /*
        * Zombie map markers
        */
        for(new p = 0; p < MAX_PLAYERS; p++)
        {
            if(player[p][spawned] == 0)
                continue;

            if(player[p][iszombie] == 0)
                continue;

            if(IsPlayerNPC(p)) // skip NPCs
                continue;

            if(player[p][huntTarget] != i || !player[p][huntActive])
            {
                SetPlayerMarkerForPlayer(p, i, (GetPlayerColor(i) & 0xFFFFFF00)); // make the player markers invisible unless being hunted
            }
        }

        /*
        * Sync the player HUD
        */
        if(GetPlayerMoney(i) != playerInventory[i][4])
        {
            ResetPlayerMoney(i);
            GivePlayerMoney(i, playerInventory[i][4]);
        }

        if(GetPlayerScore(i) != player[i][level])
        {
            SetPlayerScore(i, player[i][level]);
        }
        
        // player level up!
        if(player[i][exp] >= expForNextLevel[player[i][level]])
        {
            player[i][exp] = player[i][exp] - expForNextLevel[player[i][level]];
            player[i][level] = player[i][level] + 1;
            player[i][perkPoints] = player[i][perkPoints] + 1;
            UpdateHudElementForPlayer(i, HUD_INFO);
        }
    }
    return 1;
}

public DelayedKick(playerid, time)
{
    SetTimerEx("DelayedKickPlayer", time, false, "d", playerid);
    return 1;
}

public DelayedKickPlayer(playerid)
{
    Kick(playerid);
    return 1;
}

public OnLoginTimeout(playerid)
{
	// reset the variable that stores the timerid
	player[playerid][LoginTimer] = 0;

	SendClientMessage(playerid, COLOR_RED, "You have run out time to login, please reconnect to try logging in again.");
	DelayedKick(playerid, 500);
	return 1;
}

public ResetSearchZone(zoneid)
{
    UpdateDynamic3DTextLabelText(scavTextLabel[zoneid], COLOR_GREEN, "/search");
    scavArea[zoneid][areaActive] = true;
    return 1;
}

public HungerTimer(playerid)
{
    if(player[playerid][hunger] == 0)
    {
        UpdateHudElementForPlayer(playerid, HUD_HUNGER);
        player[playerid][health] = player[playerid][health] - 3;
        SetPlayerHealth(playerid, player[playerid][health]);
        UpdateHudElementForPlayer(playerid, HUD_HEALTH);

        SendClientMessage(playerid, COLOR_RED, "You are starving, you should eat something soon.");
    }
    else
    {
        player[playerid][hunger] = player[playerid][hunger] - 1;
        UpdateHudElementForPlayer(playerid, HUD_HUNGER);
    }
    return 1;
}

public ThirstTimer(playerid)
{
    if(player[playerid][thirst] == 0)
    {
        UpdateHudElementForPlayer(playerid, HUD_THIRST);
        player[playerid][health] = player[playerid][health] - 3;
        SetPlayerHealth(playerid, player[playerid][health]);
        UpdateHudElementForPlayer(playerid, HUD_HEALTH);

        SendClientMessage(playerid, COLOR_RED, "You are dehydrating, you should drink something soon.");
    }
    else
    {
        player[playerid][thirst] = player[playerid][thirst] - 1;
        UpdateHudElementForPlayer(playerid, HUD_THIRST);
    }
    return 1;
}

public DiseaseTimer(playerid)
{
    new Float:diseaseLevel = float(player[playerid][disease]);

    if (diseaseLevel < 90.0)
    {
        new Float:damageFloat = 25.0 * ((90.0 - diseaseLevel) / 90.0);
        new damage = floatround(damageFloat, floatround_floor);

        if (damage > 0)
        {
            player[playerid][health] -= damage;
            if (player[playerid][health] < 0)
                player[playerid][health] = 0;
            SetPlayerHealth(playerid, player[playerid][health]);
        }

        UpdateHudElementForPlayer(playerid, HUD_DISEASE);
        UpdateHudElementForPlayer(playerid, HUD_HEALTH);

        ClearAnimations(playerid);
        OnePlayAnim(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0);
        SendClientMessage(playerid, COLOR_RED, "You are sick, you should find some medicine soon.");
    }
    return 1;
}


public FuelTimer(playerid, vehicleid)
{
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    {
        KillTimer(player[playerid][fuelTimer]);
        return 1;
    }

    serverVehicle[vehicleid][vehFuel] = serverVehicle[vehicleid][vehFuel] - 1;
    UpdateHudElementForPlayer(playerid, HUD_VEHICLE);

    if(serverVehicle[vehicleid][vehFuel] <= 0) // vehicle's run out of fuel
    {
        serverVehicle[vehicleid][vehFuel] = 0;
        SetVehicleEngineOff(vehicleid);
        SendClientMessage(playerid, COLOR_RED, "Your vehicle has run out of fuel!");
        KillTimer(player[playerid][fuelTimer]);
    }
    return 1;
}

public FillVehicleTimer(playerid, vehicleid, fillType)
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
    {
        serverVehicle[vehicleid][isBeingFilled] = false;
        KillTimer(player[playerid][fillVehicleTimer]);
        return 1;
    }

    if(!serverVehicle[vehicleid][isBeingFilled])
    {
        serverVehicle[vehicleid][isBeingFilled] = false;
        KillTimer(player[playerid][fillVehicleTimer]);
        return 1;
    }

    if(!IsPlayerInRangeOfPoint(playerid, 5.0, player[playerid][tmpVehPos][0], player[playerid][tmpVehPos][1], player[playerid][tmpVehPos][2]))
    {
        serverVehicle[vehicleid][isBeingFilled] = false;
        HideHudElementForPlayer(playerid, HUD_VEHICLE);
        KillTimer(player[playerid][fillVehicleTimer]);
        return 1;
    }

    serverVehicle[vehicleid][vehFuel] = serverVehicle[vehicleid][vehFuel] + 1;
    UpdateHudElementForPlayer(playerid, HUD_VEHICLE);

    if(fillType == FILL_TYPE_FUELCAN)
    {
        if(playerInventoryResource[playerid][28] <= 0)
        {
            SendClientMessage(playerid, COLOR_GREEN, "You have run out of fuel in your fuel can.");
            serverVehicle[vehicleid][isBeingFilled] = false;
            HideHudElementForPlayer(playerid, HUD_VEHICLE);
            KillTimer(player[playerid][fillVehicleTimer]);
            return 1;
        }

        playerInventoryResource[playerid][28] = playerInventoryResource[playerid][28] - 1;
    }

    if(serverVehicle[vehicleid][vehFuel] >= serverVehicle[vehicleid][maxFuel]) // vehicle's full
    {
        serverVehicle[vehicleid][vehFuel] = serverVehicle[vehicleid][maxFuel];
        SendClientMessage(playerid, COLOR_GREEN, "You have filled your vehicle");
        serverVehicle[vehicleid][isBeingFilled] = false;
        HideHudElementForPlayer(playerid, HUD_VEHICLE);
        KillTimer(player[playerid][fillVehicleTimer]);
        return 1;
    }
    return 1;
}

public AntiMessageSpamTimer(playerid)
{
    player[playerid][antiMessageSpam] = 0;
    player[playerid][atProperty] = -1;
    return 1;
}

public LoginCamera(playerid)
{
    InterpolateCameraPos(playerid, 2126.743164, 2168.231445, 14.560400, 2036.888549, 1208.774780, 65.079353, 5000);
    InterpolateCameraLookAt(playerid, 2126.709960, 2163.232177, 14.479414, 2038.346801, 1205.110107, 62.006362, 5000);
    return 1;
}

public HideInfoBox(playerid)
{
    HideDialogueTextdraw(playerid);
    return 1;
}

public RespawnAfterDeath(playerid)
{
    new randSpawn = random(4);
	if(player[playerid][iszombie] == 0)
	{
		SetSpawnInfo(playerid, NO_TEAM, player[playerid][skin], humanSpawns[randSpawn][0], humanSpawns[randSpawn][1], humanSpawns[randSpawn][2], humanSpawns[randSpawn][3], 0, 0, 0, 0, 0, 0);
	}
	else
	{
		SetSpawnInfo(playerid, TEAM_ZOMBIE, player[playerid][skin], zombieSpawns[randSpawn][0], zombieSpawns[randSpawn][1], zombieSpawns[randSpawn][2], zombieSpawns[randSpawn][3], 0, 0, 0, 0, 0, 0);
	}

    /*
    * Now respawn the player
    */
    TogglePlayerSpectating(playerid, false);
    player[playerid][spawned] = 1;
    SetPlayerHealth(playerid, player[playerid][maxHealth]);
    UpdateHudElementForPlayer(playerid, HUD_HEALTH);

    if(player[playerid][iszombie] == 0)
    {
        player[playerid][hungerTimer] = SetTimerEx("HungerTimer", HUNGER_TIMER_DURATION, true, "d", playerid);
		player[playerid][thirstTimer] = SetTimerEx("ThirstTimer", THIRST_TIMER_DURATION, true, "d", playerid);
        player[playerid][diseaseTimer] = SetTimerEx("DiseaseTimer", DISEASE_TIMER_DURATION, true, "d", playerid);
        player[playerid][locationTimer] = SetTimerEx("TimedSavePlayerCharacterLocation", LOCATION_TIMER_DURATION, true, "d", playerid);
        ShowHudForPlayer(playerid, HUD_ALL);
        
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
    }

    // just in case of lag or some other issue which causes the CJ skin to be applied to a user force set their skin
    SetPlayerSkin(playerid, player[playerid][skin]);
    
    /*Reduce the xp and inv items by 20% with the exception for weapons and key items. Send on-death message*/
	ReducePlayerInventoryAndExp(playerid);
    UpdateHudElementForPlayer(playerid, HUD_INFO);
    return 1;
}

public DelayedShowCharacterMenu(playerid)
{
    PopulateCharacterMenu(playerid);
    return 1;
}

public TimedSavePlayerCharacterLocation(playerid)
{
    SavePlayerCharacterLocation(playerid, player[playerid][chosenChar]);
    return 1;
}

#endif // MODULE_TIMERS_INCLUDED