/*
* Zombie Outbreak Roleplay
* (C) 2025 Zombie Outbreak Development Contributors
* GNU General Public License v3.0
*/

/*
* Function Forwards
*/

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

/*
* Timer Functions
*/
public ServerTime()
{
	new string[64];
    new hour, minute, second;
    gettime(hour, minute, second);

    format(string,sizeof(string),"%02d:%02d:%02d", hour, minute, second);
    TextDrawSetString(Clock, string);
    SetWorldTime(hour);

    foreach(new i : Player)
	{
        if(player[i][spawned] == 0)
            return 1;

	    if(IsPlayerConnected(i) && GetPlayerState(i) != PLAYER_STATE_NONE)
		{
  			SetPlayerTime(i, hour, minute);
	 	}
	}
    return 1;
}

public ServerWeather()
{
    SetWeather(random(22));
    foreach(new i : Player)
	{
	    if(IsPlayerConnected(i) && GetPlayerState(i) != PLAYER_STATE_NONE)
		{
            SetPlayerWeather(i, GetWeather());
        }
    }
    return 1;
}

public SpawnTimer(playerid)
{
    TogglePlayerControllable(playerid, true);
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
    new keys, updown, leftright;

    if(IsPlayerConnected(playerid))
	{
        if(player[playerid][isflying])
		{
            GetPlayerKeys(playerid, keys, updown, leftright);
            if(updown == KEY_UP)
			{
                if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
				{
                    GetPlayerPos(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
                    GetXYInFrontOfPlayer(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], 5.0);
                    SetPlayerPos(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
                    SetCameraBehindPlayer(playerid);
                }
                else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
				{
                    new playerVehicle = GetPlayerVehicleID(playerid);
                    GetVehiclePos(playerVehicle,player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
                    GetXYInFrontOfPlayer(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], 5.0);
                    SetVehiclePos(playerVehicle, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
                }
            }
            else if(updown == KEY_DOWN)
			{
                if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
				{
                    GetPlayerPos(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
                    GetXYBehindPlayer(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], 5.0);
                    SetPlayerPos(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
                    SetCameraBehindPlayer(playerid);
                }
                else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
				{
                    new playerVehicle = GetPlayerVehicleID(playerid);
                    GetVehiclePos(playerVehicle, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
                    GetXYBehindPlayer(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], 5.0);
                    SetVehiclePos(playerVehicle, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
                }
            }
            if(leftright == KEY_LEFT)
			{
                if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
				{
                    GetPlayerFacingAngle(playerid, player[playerid][flyPos][3]);
                    SetPlayerFacingAngle(playerid, player[playerid][flyPos][3]+10);
                    SetCameraBehindPlayer(playerid);
                }
                else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
				{
                    new playerVehicle = GetPlayerVehicleID(playerid);
                    GetVehicleZAngle(playerVehicle, player[playerid][flyPos][3]);
                    SetVehicleZAngle(playerVehicle, player[playerid][flyPos][3]+10);
                }
            }
            else if(leftright == KEY_RIGHT)
			{
                if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
				{
                    GetPlayerFacingAngle(playerid, player[playerid][flyPos][3]);
                    SetPlayerFacingAngle(playerid, player[playerid][flyPos][3]-10);
                    SetCameraBehindPlayer(playerid);
                }
                else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
				{
                    new playerVehicle = GetPlayerVehicleID(playerid);
                    GetVehicleZAngle(playerVehicle, player[playerid][flyPos][3]);
                    SetVehicleZAngle(playerVehicle, player[playerid][flyPos][3]-10);
                }
            }
            if(keys == KEY_JUMP)
			{
                if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
				{
                    GetPlayerPos(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
                    SetPlayerPos(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]+5);
                    SetCameraBehindPlayer(playerid);
                }
                else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
				{
                    new playerVehicle = GetPlayerVehicleID(playerid);
                    GetVehiclePos(playerVehicle, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
                    SetVehiclePos(playerVehicle, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]+5);
                }
            }
            else if(keys == KEY_SPRINT)
			{
                if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
				{
                    GetPlayerPos(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
                    SetPlayerPos(playerid, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]-5);
                    SetCameraBehindPlayer(playerid);
                }
                else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
				{
                    new playerVehicle = GetPlayerVehicleID(playerid);
                    GetVehiclePos(playerVehicle, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]);
                    SetVehiclePos(playerVehicle, player[playerid][flyPos][0], player[playerid][flyPos][1], player[playerid][flyPos][2]-5);
                }
            }
        }
    }
    return 1;
}

public PlayerChecks()
{
    foreach(new i : Player)
    {
        if(player[i][spawned] == 0)
            return 1;

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
    if(player[playerid][disease] == 0)
    {
        UpdateHudElementForPlayer(playerid, HUD_DISEASE);
        player[playerid][health] = player[playerid][health] - 3;
        SetPlayerHealth(playerid, player[playerid][health]);
        UpdateHudElementForPlayer(playerid, HUD_HEALTH);

        ClearAnimations(playerid);
	    OnePlayAnim(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0);

        SendClientMessage(playerid, COLOR_RED, "You are very sick, you should find some medicine soon.");
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
		SetSpawnInfo(playerid, TEAM_ZOMBIE, player[playerid][skin], zombieSpawns[randSpawn][0], zombieSpawns[randSpawn][1], zombieSpawns[randSpawn][2], zombieSpawns[randSpawn][3], 9, 1, 0, 0, 0, 0);
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
        ShowHudForPlayer(playerid, HUD_ALL);
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