/*
* Zombie Outbreak Roleplay
* (C) 2025 Zombie Outbreak Development Contributors
* GNU General Public License v3.0
*/

/*
* Server Message Functions - Using PawnPlus
*/
native PlayerServerMessage(playerid, color, AmxString:message) = SendClientMessage;
native AdminMessage(playerid, color, AmxString:message) = SendClientMessage;
native ProxMessage(playerid, color, AmxString:message) = SendClientMessage;

SendPlayerServerMessage(playerid, color, msgType, const text[])
{
	new String:chatMsg;
	new String:inputText = str_new(text);

	switch(msgType)
	{
		case PLR_SERVER_MSG_TYPE_INFO:
		{
			chatMsg = str_new_static(COL_YELLOW"[INFO]: "COL_SYSTEM) + inputText;
			PlayerServerMessage(playerid, color, chatMsg);
		}
		case PLR_SERVER_MSG_TYPE_ERROR:
		{
			chatMsg = str_new_static(COL_RED"[ERROR]: "COL_SYSTEM) + inputText;
			PlayerServerMessage(playerid, color, chatMsg);
		}
		case PLR_SERVER_MSG_TYPE_DENIED:
		{
			chatMsg = str_new_static(COL_RED"[DENIED]: "COL_SYSTEM) + inputText;
			PlayerServerMessage(playerid, color, chatMsg);
		}
	}
	return 1;
}

SendAdminMessage(playerid, color, const text[])
{
	new String:chatMsg;
	new String:plrName = str_new(player[playerid][chosenChar]);
	new String:inputText = str_new(text);

	foreach(new i : Player)
	{
		if(!IsPlayerConnected(i))
			return 1;
			
		if(player[i][admin] > 0)
		{
			chatMsg = str_new_static("ADMIN: ") + plrName + str_new_static(" ") + inputText;
			AdminMessage(i, color, chatMsg);
		}
	}
	return 1;
}

SendProxMessage(playerid, color, Float:radi, msgType, const text[])
{
    new Float:x, Float:y, Float:z;
	new String:chatMsg;
	new String:plrName = str_new(player[playerid][chosenChar]);
	new String:inputText = str_new(text);
    GetPlayerPos(playerid, x, y, z);

    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, radi, x, y, z))
        {
			switch(msgType)
			{
				case PROXY_MSG_TYPE_ME: 
				{
					chatMsg = str_new_static("* ") + plrName + str_new_static(" ") + inputText;
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_INVENTORY_EQUIP: 
				{
					chatMsg = str_new_static("* ") + plrName + str_new_static(" equips their ") + inputText;
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_INVENTORY_UNEQUIP: 
				{
					chatMsg = str_new_static("* ") + plrName + str_new_static(" unequips their ") + inputText;
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_DO: 
				{
					chatMsg = str_new_static("* ") + plrName + str_new_static(" (( ") + inputText + str_new_static(" ))");
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_OOCCHAT: 
				{
					chatMsg = str_new_static("((") + plrName + str_new_static(" says: ") + inputText + str_new_static("))");
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_SHOUT: 
				{
					chatMsg = str_new_static("((") + plrName + str_new_static(" shouts: ") + inputText + str_new_static("))");
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_CHAT: 
				{
					chatMsg = plrName + str_new_static(" says: ") + inputText;
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_OTHER: 
				{
					chatMsg = str_new_static("* ") + plrName + str_new_static(" ") + inputText;
					ProxMessage(i, color, chatMsg);
				}
			}
        }
    }
	return 1;
}

KickWithMessage(playerid, color, const message[], {Float, _}:...)
{
    SendClientMessage(playerid, color, message);
    SetTimerEx("TimedKick", 500, false, "d", playerid); // Delay of 500 miliseconds before kicking the player so he recieves the message
    return 1;
}

BanWithMessage(playerid, color, const message[], {Float, _}:...)
{
    SendClientMessage(playerid, color, message);
    SetTimerEx("TimedBan", 500, false, "d", playerid); 	// Delay of 500 miliseconds before banning the player so he recieves the message
    return 1;
}

/*
* Player Coordinate Functions
*/
GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
    new Float:a;
    GetPlayerPos(playerid, x, y, a);
    GetPlayerFacingAngle(playerid, a);
    if (GetPlayerVehicleID(playerid))
    {
      GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
    }
    x += (distance * floatsin(-a, degrees));
    y += (distance * floatcos(-a, degrees));
}

GetXYBehindPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
    new Float:a;
    GetPlayerPos(playerid, x, y, a);
    GetPlayerFacingAngle(playerid, a);
    if (GetPlayerVehicleID(playerid))
    {
    	GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
    }
    x += (distance * floatsin(-a+180, degrees));
    y += (distance * floatcos(-a+180, degrees));
}

/*
* Animation functions
*/
OnePlayAnim(playerid,const animlib[],const animname[], Float:Speed, looping, lockx, locky, lockz, lp)
{
	ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);
}

LoopingAnim(playerid,const animlib[],const animname[], Float:Speed, looping, lockx, locky, lockz, lp)
{
    player[playerid][usingloopinganim] = true;
    ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);
    TextDrawShowForPlayer(playerid, animhelper);
}

StopLoopingAnim(playerid)
{
    ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
}

IsKeyJustDown(key, newkeys, oldkeys)
{
	if((newkeys & key) && !(oldkeys & key)) return true;
	return false;
}

/*
* Inventory functionality
*/
RefillWaterCanteen(playerid, dirtyWaterCanteenId)
{
	ClearAnimations(playerid);
	OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 3.0, 0, 0, 0, 0, 0);
	SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER, "fills their canteen with dirty water.");

	playerInventory[playerid][player[playerid][chosenItemId]] = playerInventory[playerid][player[playerid][chosenItemId]] - 1;
	playerInventory[playerid][dirtyWaterCanteenId] = playerInventory[playerid][dirtyWaterCanteenId] + 1;
	return 1;
}

/*
* Vehicle Functions
*/
SetVehicleEngineOn(vehicleid)
{
	new engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2;
	GetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2);
	SetVehicleParamsEx(vehicleid,VEHICLE_PARAMS_ON,lights2,alarm2,doors2,bonnet2,boot2,objective2);
}

SetVehicleEngineOff(vehicleid)
{
	new engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2;
	GetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2);
	SetVehicleParamsEx(vehicleid,VEHICLE_PARAMS_OFF,lights2,alarm2,doors2,bonnet2,boot2,objective2);
}

stock SetVehicleLightsOn(vehicleid)
{
	new engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2;
	GetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2);
	SetVehicleParamsEx(vehicleid,engine2,VEHICLE_PARAMS_ON,alarm2,doors2,bonnet2,boot2,objective2);
}

stock SetVehicleLightsOff(vehicleid)
{
	new engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2;
	GetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2);
	SetVehicleParamsEx(vehicleid,engine2,VEHICLE_PARAMS_OFF,alarm2,doors2,bonnet2,boot2,objective2);
}

stock OpenVehicleBonnet(vehicleid)
{
	new engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2;
	GetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2);
	SetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,VEHICLE_PARAMS_ON,boot2,objective2);
}

stock CloseVehicleBonnet(vehicleid)
{
	new engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2;
	GetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2);
	SetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,VEHICLE_PARAMS_OFF,boot2,objective2);
}

stock OpenVehicleBoot(vehicleid)
{
	new engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2;
	GetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2);
	SetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,bonnet2,VEHICLE_PARAMS_ON,objective2);
}

stock CloseVehicleBoot(vehicleid)
{
	new engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2;
	GetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2);
	SetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,bonnet2,VEHICLE_PARAMS_OFF,objective2);
}

stock UnLockVehicleDoors(vehicleid)
{
	new engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2;
	GetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2);
	SetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,VEHICLE_PARAMS_ON,bonnet2,boot2,objective2);
}

stock LockVehicleDoors(vehicleid)
{
	new engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2;
	GetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,doors2,bonnet2,boot2,objective2);
	SetVehicleParamsEx(vehicleid,engine2,lights2,alarm2,VEHICLE_PARAMS_OFF,bonnet2,boot2,objective2);
}

decode_lights(lightsParam, &front_left_light, &front_right_light, &back_lights)
{
    front_left_light = lightsParam & 1;
    front_right_light = lightsParam >> 2 & 1;
    back_lights = lightsParam >> 6 & 1;
}

encode_lights(light1, light2, light3, light4)
{
	return light1 | (light2 << 1) | (light3 << 2) | (light4 << 3);
}

decode_tires(tiresParam, &rear_right_tire, &front_right_tire, &rear_left_tire, &front_left_tire)
{
    rear_right_tire = tiresParam & 1;
    front_right_tire = tiresParam >> 1 & 1;
    rear_left_tire = tiresParam >> 2 & 1;
    front_left_tire = tiresParam >> 3 & 1;
}

encode_tires(tire1, tire2, tire3, tire4)
{
	return tire1 | (tire2 << 1) | (tire3 << 2) | (tire4 << 3);
}

stock encode_tires_bike(rear, front)
{
	return rear | (front << 1);
}

decode_doors(doorsParam, &bonnet, &boot, &driver_door, &passenger_door)
{
    bonnet = doorsParam & 7;
    boot = doorsParam >> 8 & 7;
    driver_door = doorsParam >> 16 & 7;
    passenger_door = doorsParam >> 24 & 7;
}

encode_doors(bonnet2, boot2, driver_door, passenger_door, behind_driver_door, behind_passenger_door)
{
	// the back doors are not currently synced in SA-MP/OpenMP
	#pragma unused behind_driver_door
	#pragma unused behind_passenger_door

	// will be modified once again, when rear doors are synced.
	return bonnet2 | (boot2 << 8) | (driver_door << 16) | (passenger_door << 24);
}

decode_panels(panelParam, &front_left_panel, &front_right_panel, &rear_left_panel, &rear_right_panel, &windshield, &front_bumper, &rear_bumper)
{
    front_left_panel = panelParam & 15;
    front_right_panel = panelParam >> 4 & 15;
    rear_left_panel = panelParam >> 8 & 15;
    rear_right_panel = panelParam >> 12 & 15;
    windshield = panelParam >> 16 & 15;
    front_bumper = panelParam >> 20 & 15;
    rear_bumper = panelParam >> 24 & 15;
}

encode_panels(flp, frp, rlp, rrp, windshield, front_bumper, rear_bumper)
{
	return flp | (frp << 4) | (rlp << 8) | (rrp << 12) | (windshield << 16) | (front_bumper << 20) | (rear_bumper << 24);
}
// https://wiki.sa-mp.com/wiki/DamageStatus

SetupVehicleForSpawn(vehicleid)
{
	/*
	* Setup visual damage of the vehicle
	*/
	GetVehicleDamageStatus(vehicleid, serverVehicle[vehicleid][panels], serverVehicle[vehicleid][doors], serverVehicle[vehicleid][lights], serverVehicle[vehicleid][tires]);

	serverVehicle[vehicleid][panels] = encode_panels(random(2), random(2), random(2), random(2), RandomRange(1,3), RandomRange(1,3), RandomRange(1,3));
	serverVehicle[vehicleid][doors] = encode_doors(RandomRange(1,4), RandomRange(1,4), RandomRange(1,4), RandomRange(1,4), 0, 0); // back doors aren't synced as of yet... maybe one day
	serverVehicle[vehicleid][lights] = encode_lights(random(2), random(2), random(2), random(2));
	serverVehicle[vehicleid][tires] = encode_tires(random(2), random(2), random(2), random(2));

	UpdateVehicleDamageStatus(vehicleid, serverVehicle[vehicleid][panels], serverVehicle[vehicleid][doors], serverVehicle[vehicleid][lights], serverVehicle[vehicleid][tires]);

	/*
	* Setup fuel
	*/
	serverVehicle[vehicleid][vehFuel] = random(50) + 1;
	serverVehicle[vehicleid][maxFuel] = 100;

	/*
	* Setup vehicle health
	*/
	serverVehicle[vehicleid][vehHealth] = RandomRange(300, 1000);
	SetVehicleHealth(vehicleid, serverVehicle[vehicleid][vehHealth]);
	return 1;
}

bool:IsPlayerAtFuelPump(playerid)
{
	for (new i = 0; i < MAX_FUEL_PUMPS; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, FUEL_PUMP_RANGE, fuelPump[i][0], fuelPump[i][1], fuelPump[i][2]))
			return true;
	}
    return false;
}

ScrapRequiredToRepairVeh(playerid)
{
    new scrapRequired;
    new front_left_panel, front_right_panel, rear_left_panel, rear_right_panel, windshield, front_bumper, rear_bumper;
    new bonnet, boot, driver_door, passenger_door;
    new front_left_light, front_right_light, back_lights;
    new rear_right_tire, front_right_tire, rear_left_tire, front_left_tire;
    
    GetVehicleDamageStatus(player[playerid][lastInVehId], serverVehicle[player[playerid][lastInVehId]][panels], serverVehicle[player[playerid][lastInVehId]][doors], serverVehicle[player[playerid][lastInVehId]][lights], serverVehicle[player[playerid][lastInVehId]][tires]);
    decode_panels(serverVehicle[player[playerid][lastInVehId]][panels], front_left_panel, front_right_panel, rear_left_panel, rear_right_panel, windshield, front_bumper, rear_bumper);
    decode_doors(serverVehicle[player[playerid][lastInVehId]][doors], bonnet, boot, driver_door, passenger_door);
    decode_lights(serverVehicle[player[playerid][lastInVehId]][lights], front_left_light, front_right_light, back_lights);
    decode_tires(serverVehicle[player[playerid][lastInVehId]][tires], rear_right_tire, front_right_tire, rear_left_tire, front_left_tire);
    
    scrapRequired = (front_left_panel + front_right_panel + rear_left_panel + rear_right_panel + windshield + front_bumper + rear_bumper +
        bonnet + boot + driver_door + passenger_door + front_left_light + front_right_light + back_lights + rear_right_tire + front_right_tire +
        rear_left_tire + front_left_tire) * 25;
    return scrapRequired;
}

/*
* Misc
*/
RandomRange(min, max)
{
    new rand = random(max-min)+min;    
    return rand;
}

GetPlayerIdFromName(const playerName[])
{
	foreach(new i : Player)
	{
		if(IsPlayerConnected(i))
		{
			new tmpPlayerName[MAX_PLAYER_NAME];
			GetPlayerName(i, tmpPlayerName, sizeof(tmpPlayerName));

			if(strcmp(tmpPlayerName, playerName, true, strlen(playerName)) == 0)
			{
				return i;
			}
		}
	}
	return INVALID_PLAYER_ID;
}

RemoveWeaponFromSlot(playerid, slot)
{
    new weapons[13][2];
    for(new i = 0; i < 13; i++)
	{
        GetPlayerWeaponData(playerid, i, weapons[i][0], weapons[i][1]);
	}

    weapons[slot][0] = 0;

    ResetPlayerWeapons(playerid);
    
    for(new i = 0; i < 13; i++)
	{
        GivePlayerWeapon(playerid, weapons[i][0], weapons[i][1]);
	}
    return 1;
}

ReturnWeaponAmmoId(wepid)
{
    for(new i = 1; i < MAX_ITEMS; i++)
	{
		if(inventoryItems[i][itemWepId] == wepid) // a match was found
		{
            return inventoryItems[i][itemAmmoId];
        }
    }
    return 0; // if this is reached then an error has occured, such as no item name given to the function matched the list of items in the server.
}

ReturnItemIdByName(const itemName[])
{
    for(new i = 1; i < MAX_ITEMS; i++)
	{
        if(strcmp(itemName, inventoryItems[i][itemNameSingular]) == 0) // a match was found
		{
            return i;
        }
    }
    return 0; // if this is reached then an error has occured, such as no item name given to the function matched the list of items in the server.
}

CreateInteriorPickup(interiorid)
{
    /*
    * Create the arrows to show where the entrances are
    */
    interiorEnterPickup[interiorid] = CreateDynamicPickup(ENTER_EXIT_INTERIOR_PICKUP, 1, srvInterior[interiorid][intEnter][0], srvInterior[interiorid][intEnter][1], srvInterior[interiorid][intEnter][2], 
		srvInterior[interiorid][intExitVirWorld], srvInterior[interiorid][intExitWorld]);

	// every interior has an arrow for the exit point
	interiorExitPickup[interiorid] = CreateDynamicPickup(ENTER_EXIT_INTERIOR_PICKUP, 1, srvInterior[interiorid][intExit][0], srvInterior[interiorid][intExit][1], srvInterior[interiorid][intExit][2], 
		srvInterior[interiorid][intVirWorld], srvInterior[interiorid][intWorld]);
	return 1;
}
// Perk related functions
TryUpgradeBiteSkill(playerid)
{
    if(player[playerid][unlockedBiteSkill] >= 5)
	{
		SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the maximum level of this skill.");
        return 0;
	}
    DB_ExecuteQuery(database,
		"UPDATE characters SET unlockedbite = unlockedbite +1 WHERE owner = '%d' AND name = '%q'",
		player[playerid][ID], player[playerid][chosenChar]);
    switch (player[playerid][unlockedBiteSkill])
    {
        case 0: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your bite carries a faint trace of sickness, leaving victims weak and weary."),
                SendClientMessage(playerid, COLOR_GREEN, "Bite upgrade 1/5. Hold Alt+Aim near a human to bite them.");
        case 1: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your jaws infect flesh, sowing festering sores that drain the life slowly."),
                SendClientMessage(playerid, COLOR_GREEN, "Bite upgrade 2/5. Hold Alt+Aim near a human to bite them.");
        case 2: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your bite spreads vile disease, twisting flesh and mind alike with creeping rot."),
                SendClientMessage(playerid, COLOR_GREEN, "Bite upgrade 3/5. Hold Alt+Aim near a human to bite them.");
        case 3: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your teeth inject a venomous plague, corrupting flesh and bone with agonizing speed."),
                SendClientMessage(playerid, COLOR_GREEN, "Bite upgrade 4/5. Hold Alt+Aim near a human to bite them.");
        case 4: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your savage bite spreads unstoppable contagion, dooming victims to a gruesome, agonizing death."),
                SendClientMessage(playerid, COLOR_GREEN, "Bite upgrade 5/5. Hold Alt+Aim near a human to bite them.");
    }
    player[playerid][unlockedBiteSkill]++;
    return 1;
}
stock TryUpgradeUnarmedSkill(playerid)
{
    if (player[playerid][unlockedUnarmedSkill] >= 5)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the maximum level of this skill.");
        return 0;
    }
    DB_ExecuteQuery(database,
		"UPDATE characters SET unlockedunarmed = unlockedunarmed + 1 WHERE owner = '%d' AND name = '%q'",
		player[playerid][ID], player[playerid][chosenChar]);

    switch (player[playerid][unlockedUnarmedSkill])
    {
        case 0: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your claws scrape with more bite, tearing flesh just a little deeper."),
                SendClientMessage(playerid, COLOR_GREEN, "Unarmed upgrade 1/5");
        case 1: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your strikes rend sinew and bone with growing hunger."),
                SendClientMessage(playerid, COLOR_GREEN, "Unarmed upgrade 2/5");
        case 2: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your blows now crush and shatter, like the dead rising relentless."),
                SendClientMessage(playerid, COLOR_GREEN, "Unarmed upgrade 3/5");
        case 3: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your claws rend through armor and flesh, driven by unholy fury."),
                SendClientMessage(playerid, COLOR_GREEN, "Unarmed upgrade 4/5");
        case 4: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your hands become weapons of decay, pulverizing all in your ravenous path."),
                SendClientMessage(playerid, COLOR_GREEN, "Unarmed upgrade 5/5");
    }
    player[playerid][unlockedUnarmedSkill]++;
    return 1;
}
stock TryUpgradeHpSkill(playerid)
{
    if (player[playerid][unlockedHpIncreaseSkill] >= 5)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the maximum level of this skill.");
        return 0;
    }

    // Increase max health by 10% of initial max health
    player[playerid][maxHealth] += INITIAL_MAX_HEALTH_ZED * 0.10;

    // Set current health to new max health
    player[playerid][health] = player[playerid][maxHealth];

    // Update the max health, health and skillcount in the database
    DB_ExecuteQuery(database,
        "UPDATE characters SET maxhealth = '%f', health = '%f', unlockedhpinc = unlockedhpinc + 1 WHERE owner = '%d' AND name = '%q'",
        player[playerid][maxHealth], player[playerid][health], player[playerid][ID], player[playerid][chosenChar]);

    // Apply the changes in-game
    SetPlayerMaxHealth(playerid, player[playerid][maxHealth]);
    SetPlayerHealth(playerid, player[playerid][health]);

    // Update HUD
    UpdateHudElementForPlayer(playerid, HUD_HEALTH);

    switch (player[playerid][unlockedHpIncreaseSkill])
    {
        case 0: SendClientMessage(playerid, COLOR_RP_PURPLE, "A faint pulse of strength returns to your limbs."),
                SendClientMessage(playerid, COLOR_GREEN, "HP increase 1/5");
        case 1: SendClientMessage(playerid, COLOR_RP_PURPLE, "You steady yourself, feeling less fragile."),
                SendClientMessage(playerid, COLOR_GREEN, "HP increase 2/5");
        case 2: SendClientMessage(playerid, COLOR_RP_PURPLE, "A dark vigor spreads through your decaying form."),
                SendClientMessage(playerid, COLOR_GREEN, "HP increase 3/5");
        case 3: SendClientMessage(playerid, COLOR_RP_PURPLE, "You stand taller, the rot no longer slowing you."),
                SendClientMessage(playerid, COLOR_GREEN, "HP increase 4/5");
        case 4: SendClientMessage(playerid, COLOR_RP_PURPLE, "You are reborn in death - relentless, unbreakable."),
                SendClientMessage(playerid, COLOR_GREEN, "HP increase 5/5");
    }

    player[playerid][unlockedHpIncreaseSkill]++;

    return 1;
}

stock TryUpgradeJumpSkill(playerid)
{
    if(player[playerid][unlockedJumpSkill])
	{
	    SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the Jump skill.");
        return 0;
	}
	
    player[playerid][unlockedJumpSkill] = true;

	// Lower gravity for higher jumps (default: 0.008, less = more jump)
	SetPlayerGravity(playerid, 0.005); // Adjust value to fit game balance

	// Save skill unlock to DB
	DB_ExecuteQuery(database,
		"UPDATE characters SET unlockedjump = '1' WHERE owner = '%d' AND name = '%q'",
		player[playerid][ID], player[playerid][chosenChar]);

	SendClientMessage(playerid, COLOR_RP_PURPLE, "Rotting muscles shift and tighten - your body learns to spring forward..");
    SendClientMessage(playerid, COLOR_GREEN, "You have unlocked the jump skill! You can now now jump higher.");
    return 1;
}

stock TryUnlockCombustSkill(playerid)
{
    if(player[playerid][unlockedCombustSkill])
	{
		SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the combust skill.");
        return 0;
	}

	player[playerid][unlockedCombustSkill] = true;
	DB_ExecuteQuery(database,
		"UPDATE characters SET unlockedcombust = '1' WHERE owner = '%d' AND name = '%q'",
		player[playerid][ID], player[playerid][chosenChar]);

	SendClientMessage(playerid, COLOR_RP_PURPLE, "A volatile change brews within you... your final moments will not go unnoticed.");
    SendClientMessage(playerid, COLOR_GREEN, "On Death: Deal damage to players around you");
    return 1;
}
TryUnlockStunSkill(playerid)
{
    if(player[playerid][unlockedStunSkill])
    {
	SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the stun skill.");
    return 0;
    }
    player[playerid][unlockedStunSkill] = true;
    DB_ExecuteQuery(database,
	    "UPDATE characters SET unlockedstun = '1' WHERE owner = '%d' AND name = '%q'",
	    player[playerid][ID], player[playerid][chosenChar]);
    SendClientMessage(playerid, COLOR_RP_PURPLE, "The infection mutates. Newfound strength in your arms. Snap Impact - halting prey with a brutal, staggering blow.");
    SendClientMessage(playerid, COLOR_GREEN, "alt+fire, 30s cooldown");
    return 1;
}
TryUnlockGrabSkill(playerid)
{
    if(player[playerid][unlockedGrabSkill])
	{
		SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the grab skill.");
        return 0;
	}
	player[playerid][unlockedGrabSkill] = true;
	DB_ExecuteQuery(database,
		"UPDATE characters SET unlockedgrab = '1' WHERE owner = '%d' AND name = '%q'",
		player[playerid][ID], player[playerid][chosenChar]);
	SendClientMessage(playerid, COLOR_RP_PURPLE, "Twisted tendrils writhe from your flesh, hunting prey beyond your reach. (alt+crouch)");
    SendClientMessage(playerid, COLOR_GREEN, "alt+crouch to pull the furthest player to you from a max range of 10. 30s cooldown");
    return 1;
}
TryUnlockBorrowedStrengthSkill(playerid)
{
    if(player[playerid][unlockedBorrowedStrengthSkill])
    {
    SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the Borrowed Strength skill.");
    return 0;
    }
    player[playerid][unlockedBorrowedStrengthSkill] = true;
    DB_ExecuteQuery(database,
	    "UPDATE characters SET unlockedbstr = '1' WHERE owner = '%d' AND name = '%q'",
        player[playerid][ID], player[playerid][chosenChar]);
    
    SendClientMessage(playerid, COLOR_RP_PURPLE, "Rip life from your veins to fuel savage blows, but dont push past your limits. ");
    SendClientMessage(playerid, COLOR_GREEN, "/bstr (amount of hp) to gain gain damage equal to 25 percent of health lost.");
    return 1;
}
TryUnlockSuperJumpSkill(playerid)
{
    if(player[playerid][unlockedSuperJumpSkill])
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the Super Jump skill.");
        return 0;
    }
    player[playerid][unlockedSuperJumpSkill] = true;
    DB_ExecuteQuery(database,
	    "UPDATE characters SET unlockedsjump = '1' WHERE owner = '%d' AND name = '%q'",
    player[playerid][ID], player[playerid][chosenChar]);
    SendClientMessage(playerid, COLOR_RP_PURPLE, "A new instinct awakens within you: the ability to defy gravity itself. ");
    SendClientMessage(playerid, COLOR_GREEN, "alt+shift to sacrifice 50hp for a very strong jump");
    return 1;
}
TryUnlockCorneredSkill(playerid)
{
    if(player[playerid][unlockedCorneredSkill])
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked cornered skill.");
        return 0;
    }
    player[playerid][unlockedCorneredSkill] = true;
    DB_ExecuteQuery(database,
	    "UPDATE characters SET unlockedcorn = '1' WHERE owner = '%d' AND name = '%q'",
    player[playerid][ID], player[playerid][chosenChar]);
    SendClientMessage(playerid, COLOR_RP_PURPLE, "Near deaths grasp, your desperation fuels a deadly, relentless assault.");
    SendClientMessage(playerid, COLOR_GREEN, "Damage boost when below 30 percent HP");
    return 1;
}
stock Grab(playerid)
{
    if ((GetTickCount() - player[playerid][grabAntiSpam]) < 30000)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 30 seconds between uses of this command.");
    }
    if ((GetTickCount() - player[playerid][generalAntiSpam]) < 2000){
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 2 seconds between active ability uses");
    }
    if ((GetTickCount() - player[playerid][grabbedRecently]) < 8000){
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "This player has already been grabbed in the past 8 seconds.");
    }

    new players[MAX_PLAYERS], length;
    new Float:grabberX, Float:grabberY, Float:grabberZ;
    GetPlayerPos(playerid, grabberX, grabberY, grabberZ);

    length = GetPlayers(players, sizeof(players));

    new furthestCandidates[MAX_PLAYERS];
    new candidateCount = 0;
    new Float:maxDistance = 0.0;

    for (new i = 0; i < length; i++)
    {
        new target = players[i];
        if (target == playerid || !IsPlayerConnected(target) || player[target][iszombie] == 1) continue;

        new Float:targetX, Float:targetY, Float:targetZ;
        GetPlayerPos(target, targetX, targetY, targetZ);

        new Float:distance = floatsqroot(
            floatpower(grabberX - targetX, 2.0) +
            floatpower(grabberY - targetY, 2.0) +
            floatpower(grabberZ - targetZ, 2.0)
        );

        if (distance <= 10.0)
        {
            if (floatcmp(distance, maxDistance) > 0)
            {
                // Found new furthest
                maxDistance = distance;
                candidateCount = 1;
                furthestCandidates[0] = target;
            }
            else if (floatcmp(distance, maxDistance) == 0)
            {
                // Same distance as furthest, add to pool
                furthestCandidates[candidateCount++] = target;
            }
        }
    }

    if (candidateCount == 0)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "No valid targets to grab within 10 units.");
    }

    new target = furthestCandidates[random(candidateCount)];

    // Pull the target to the grabber's position
    SetPlayerPos(target, grabberX, grabberY+1, grabberZ);
    SendPlayerServerMessage(target, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You have been grabbed!");
    SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER, "Tendrils burst out of the infected, pulling in their prey.");
    // Anti-spam timer
    SetTimerEx("grabCooldownTimer", 30000, false, "d", playerid);
    player[playerid][grabAntiSpam] = GetTickCount();
    player[playerid][generalAntiSpam] = GetTickCount();
    player[playerid][grabbedRecently] = GetTickCount();
    return 1;
}    

stock Stun(playerid)
{
    if((GetTickCount() - player[playerid][stunnedRecently]) < 8000)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "This player has already been stunned in the past 8 seconds.");
    }
    if ((GetTickCount() - player[playerid][stunAntiSpam]) < 30000)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 30 seconds between uses of this command.");
    }
    if ((GetTickCount() - player[playerid][generalAntiSpam]) < 2000){
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 2 seconds between active ability uses");
    }

    new players[MAX_PLAYERS], length;
    new Float:zombieX, Float:zombieY, Float:zombieZ;
    GetPlayerPos(playerid, zombieX, zombieY, zombieZ);

    length = GetPlayers(players, sizeof(players));

    new closestCandidates[MAX_PLAYERS];
    new candidateCount = 0;
    new Float:closestDistance = 99999.0;

    for (new i = 0; i < length; i++)
    {
        new target = players[i];
        if (target == playerid || !IsPlayerConnected(target) || player[target][iszombie] == 1) continue;

        new Float:targetX, Float:targetY, Float:targetZ;
        GetPlayerPos(target, targetX, targetY, targetZ);

        //blackmagic
        new Float:distance = floatsqroot( floatpower(zombieX - targetX, 2.0) + floatpower(zombieY - targetY, 2.0) + floatpower(zombieZ - targetZ, 2.0) );

        if (distance <= 3.0)
        {
            if (floatcmp(distance, closestDistance) < 0)
            {
                // Found closer target
                closestDistance = distance;
                candidateCount = 1;
                closestCandidates[0] = target;
            }
            else if (floatcmp(distance, closestDistance) == 0)
            {
                // Same distance as closest, add to pool
                closestCandidates[candidateCount++] = target;
            }
        }
    }

    if (candidateCount == 0)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "No valid targets nearby to stun.");
    }
    new target = closestCandidates[random(candidateCount)];

    // Stun logic
    player[target][health] -= 10;
    SetPlayerHealth(target, player[target][health]);
    UpdateHudElementForPlayer(target, HUD_HEALTH);
    SetTimerEx("SpawnTimer", 1000, false, "d", target);
    TogglePlayerControllable(target, false);
    SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER, "The infected crashes into their victim with overwhelming force, leaving them dazed.");
    SendPlayerServerMessage(target, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You have been stunned!");
    SetTimerEx("stunCooldownTimer", 30000, false, "d", playerid);
    // Update anti-spam timer
    player[playerid][stunAntiSpam] = GetTickCount();
    player[playerid][generalAntiSpam] = GetTickCount();
    player[playerid][stunnedRecently] = GetTickCount();
    return 1;
}

stock Combust(playerid)
{
new players[MAX_PLAYERS];
new length;
new Float:zombieX, Float:zombieY, Float:zombieZ;

GetPlayerPos(playerid, zombieX, zombieY, zombieZ);

length = GetPlayers(players, sizeof(players));
    
for (new i = 0; i < length; i++)
    {
        new target = players[i];

        // Skip self
        if (target == playerid || !IsPlayerConnected(target)) continue;

        new Float:targetX, Float:targetY, Float:targetZ;
        GetPlayerPos(target, targetX, targetY, targetZ);

        if (IsPlayerInRangeOfPoint(playerid, 6.0, targetX, targetY, targetZ))
        {
            //player[target][disease] = 0;
            player[target][health] -= 20;

            SetPlayerHealth(target, player[target][health]);

            UpdateHudElementForPlayer(target, HUD_HEALTH);
            //UpdateHudElementForPlayer(target, HUD_DISEASE);

            SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER, "The infected erupts in a grotesque explosion of acidic bile and razor-sharp bone fragments.");
        }
    }
}

Bite(playerid)
{
    if ((GetTickCount() - player[playerid][biteAntiSpam]) < 15000)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 15 seconds between uses of this command.");
    }
    if ((GetTickCount() - player[playerid][generalAntiSpam]) < 2000){
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 2 seconds between active ability uses");
    }
    new players[MAX_PLAYERS], length;
    new Float:zombieX, Float:zombieY, Float:zombieZ;
    GetPlayerPos(playerid, zombieX, zombieY, zombieZ);

    length = GetPlayers(players, sizeof(players));

    new closestCandidates[MAX_PLAYERS];
    new candidateCount = 0;
    new Float:closestDistance = 99999.0;

    for (new i = 0; i < length; i++)
    {
        new target = players[i];
        if (target == playerid || !IsPlayerConnected(target) || player[target][iszombie] == 1) continue;

        new Float:targetX, Float:targetY, Float:targetZ;
        GetPlayerPos(target, targetX, targetY, targetZ);

        //blackmagic
        new Float:distance = floatsqroot( floatpower(zombieX - targetX, 2.0) + floatpower(zombieY - targetY, 2.0) + floatpower(zombieZ - targetZ, 2.0) );

        if (distance <= 3.0)
        {
            if (floatcmp(distance, closestDistance) < 0)
            {
                // Found closer target
                closestDistance = distance;
                candidateCount = 1;
                closestCandidates[0] = target;
            }
            else if (floatcmp(distance, closestDistance) == 0)
            {
                // Same distance as closest, add to pool
                closestCandidates[candidateCount++] = target;
            }
        }
    }

    if (candidateCount == 0)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "No valid targets nearby to bite.");
    }

    new target = closestCandidates[random(candidateCount)];

    // Bite logic
    player[target][disease] -= (10 * player[playerid][unlockedBiteSkill]);
    if(player[target][disease]<0){
        player[target][disease]=0;
    }
    player[target][health] -= 10;

    SetPlayerHealth(target, player[target][health]);

    UpdateHudElementForPlayer(target, HUD_HEALTH);
    UpdateHudElementForPlayer(target, HUD_DISEASE);
    SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER,
        "Fractured teeth pierce flesh and inoculate disease.");

    SendPlayerServerMessage(target, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Something rips a chunk out of you!");
    // Update anti-spam timer
    SetTimerEx("biteCooldownTimer", 15000, false, "d", playerid);
    player[playerid][biteAntiSpam] = GetTickCount();
    player[playerid][generalAntiSpam] = GetTickCount();
    
    return 1;
}

SuperJump(playerid)
{
    if ((GetTickCount() - player[playerid][borrowedSuperJumpAntiSpam]) < 5000)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED,
        "Please wait 5 seconds between uses of this command.");
    }
    
    new Float:damage = 50;
    player[playerid][health] -= damage;
    SetPlayerHealth(playerid, player[playerid][health]);
    UpdateHudElementForPlayer(playerid, HUD_HEALTH);

    player[playerid][borrowedSuperJumpAntiSpam] = GetTickCount();
    SetPlayerVelocity(playerid, 0.0, 0.0, 5); 
    SetTimerEx("superJumpCooldownTimer", 5000, false, "d", playerid);
    SendProxMessage(playerid, COLOR_RED, 30.0, PROXY_MSG_TYPE_OTHER,
        "Bones crack, tendons shred, the earth breaks beneath their leap");

    return 1;
}
/*
* Punishment for dying
*/
ReducePlayerInventoryAndExp(playerid)
{
    // EXP reduction (both human and zombie)
    player[playerid][exp] = floatround(player[playerid][exp] * 0.8, floatround_floor);

    // Zombie check
    if (player[playerid][iszombie] == 1)
    {
        new zombieMessages[][] = {
            "You jolt back to unlife. Hunger gnaws at what's left of you.",
            "Your corpse stirs. There's no pain. Only hunger.",
            "The rot deepens. Your limbs twitch with borrowed strength.",
            "Your vision returns in a haze of red. Something inside you screams for flesh.",
            "Death spits you back out. Again."
        };

        new zmsg = random(sizeof(zombieMessages));
        SendClientMessage(playerid, COLOR_RP_PURPLE, zombieMessages[zmsg]);
        return;
    }

    // Human: reduce inventory
    new keysToReduce[] = {
        1, 2, 3, 4, 7, 9,
        10, 11, 12, 13, 14,
        18, 19, 20, 21, 22,
        26, 27
    };

    for (new i = 0; i < sizeof(keysToReduce); i++)
    {
        new slot = keysToReduce[i];
        playerInventory[playerid][slot] = floatround(playerInventory[playerid][slot] * 0.8, floatround_floor);
    }

    // Human messages
    new humanMessages[][] = {
        "You regain consciousness. You feel weakened and your backpack feels lighter.",
        "You wake up gasping, everything aches - something's missing.",
        "You stumble back to your feet, disoriented. Some of your supplies are gone.",
        "Your vision swims. You're alive, but not unscathed.",
        "Pain brings you back. Cold sweat. Lighter load."
    };

    new hmsg = random(sizeof(humanMessages));
    SendClientMessage(playerid, COLOR_RP_PURPLE, humanMessages[hmsg]);
}

/*
* Search command logic
*/
OnPlayerSearchNode(playerid)
{
    new string[128], itemIdFound, amountFound;
    
    for(new i = 0; i < MAX_SCAV_AREAS; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 1.0, scavArea[i][scavPos][0], scavArea[i][scavPos][1], scavArea[i][scavPos][2]))
        {
            if(!scavArea[i][areaActive])
                return SendClientMessage(playerid, COLOR_RED, "This location is not currently active.");

            switch(scavArea[i][scavType])
            {
                case SCAV_AREA_SCRAP:
                {
                    ClearAnimations(playerid);
	                OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 3.0, 0, 0, 0, 0, 0);

                    itemIdFound = lootTable[SCAV_AREA_SCRAP][random(CHANCE)];
                    if(itemIdFound != INVALID_ITEM) // item found
                    {
                        amountFound = random(30) + 1;
                        playerInventory[playerid][itemIdFound] = playerInventory[playerid][itemIdFound] + amountFound;

                        if(amountFound <= 1)
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNameSingular]);
                        }
                        else
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNamePlural]);
                        }
                        SendClientMessage(playerid, COLOR_RP_PURPLE, string);

                        //UpdatePlayerInventoryEntry(playerid, itemIdFound, player[playerid][chosenChar]);
                    }
                    else
                    {
                        SendClientMessage(playerid, COLOR_RP_PURPLE, "You search the area and cannot find anything of use.");
                    }
                }
                case SCAV_AREA_BODY:
                {
                    ClearAnimations(playerid);
	                OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 3.0, 0, 0, 0, 0, 0);

                    itemIdFound = lootTable[SCAV_AREA_BODY][random(CHANCE)];
                    new scrapItemId = ReturnItemIdByName("Scrap");
                    new moneyItemId = ReturnItemIdByName("Money");
                    if(itemIdFound != INVALID_ITEM) // item found
                    {
                        if(itemIdFound == scrapItemId || itemIdFound == moneyItemId)
                        {
                            amountFound = random(25) + 1; // 1 - 25
                        }
                        else
                        {
                            amountFound = 1;
                        }
                        playerInventory[playerid][itemIdFound] = playerInventory[playerid][itemIdFound] + amountFound;
                        
                        if(amountFound <= 1)
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNameSingular]);
                        }
                        else
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNamePlural]);
                        }
                        SendClientMessage(playerid, COLOR_RP_PURPLE, string);

                        //UpdatePlayerInventoryEntry(playerid, itemIdFound, player[playerid][chosenChar]);
                    }
                    else
                    {
                        SendClientMessage(playerid, COLOR_RP_PURPLE, "You search the area and cannot find anything of use.");
                    }
                }
                case SCAV_AREA_WEAPONS:
                {
                    ClearAnimations(playerid);
	                OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 3.0, 0, 0, 0, 0, 0);

                    itemIdFound = lootTable[SCAV_AREA_WEAPONS][random(CHANCE)];
                    if(itemIdFound != INVALID_ITEM) // item found
                    {
                        if(inventoryItems[itemIdFound][itemCategory] == CATEGORY_WEAPONS)
                        {
                            amountFound = 1;
                        }
                        else if(inventoryItems[itemIdFound][itemCategory] == CATEGORY_AMMO)
                        {
                            amountFound = random(30) + 1;
                        }

                        playerInventory[playerid][itemIdFound] = playerInventory[playerid][itemIdFound] + amountFound;
                        
                        if(amountFound <= 1)
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNameSingular]);
                        }
                        else
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNamePlural]);
                        }
                        SendClientMessage(playerid, COLOR_RP_PURPLE, string);

                        //UpdatePlayerInventoryEntry(playerid, itemIdFound, player[playerid][chosenChar]);
                    }
                    else
                    {
                        SendClientMessage(playerid, COLOR_RP_PURPLE, "You search the area and cannot find anything of use.");
                    }
                }
                case SCAV_AREA_FOODDRINK:
                {
                    ClearAnimations(playerid);
	                OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 3.0, 0, 0, 0, 0, 0);

                    itemIdFound = lootTable[SCAV_AREA_FOODDRINK][random(CHANCE)];
                    if(itemIdFound != INVALID_ITEM) // item found
                    {
                        amountFound = random(3) + 1;
                        playerInventory[playerid][itemIdFound] = playerInventory[playerid][itemIdFound] + amountFound;
                        
                        if(amountFound <= 1)
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNameSingular]);
                        }
                        else
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNamePlural]);
                        }
                        SendClientMessage(playerid, COLOR_RP_PURPLE, string);

                        //UpdatePlayerInventoryEntry(playerid, itemIdFound, player[playerid][chosenChar]);
                    }
                    else
                    {
                        SendClientMessage(playerid, COLOR_RP_PURPLE, "You search the area and cannot find anything of use.");
                    }
                }
                case SCAV_AREA_MEDICAL:
                {
                    ClearAnimations(playerid);
	                OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 3.0, 0, 0, 0, 0, 0);

                    itemIdFound = lootTable[SCAV_AREA_MEDICAL][random(CHANCE)];
                    if(itemIdFound != INVALID_ITEM) // item found
                    {
                        amountFound = random(3) + 1;
                        playerInventory[playerid][itemIdFound] = playerInventory[playerid][itemIdFound] + amountFound;
                        
                        if(amountFound <= 1)
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNameSingular]);
                        }
                        else
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNamePlural]);
                        }
                        SendClientMessage(playerid, COLOR_RP_PURPLE, string);

                        //UpdatePlayerInventoryEntry(playerid, itemIdFound, player[playerid][chosenChar]);
                    }
                    else
                    {
                        SendClientMessage(playerid, COLOR_RP_PURPLE, "You search the area and cannot find anything of use.");
                    }
                }
                case SCAV_AREA_MONEY:
                {
                    ClearAnimations(playerid);
	                OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 3.0, 0, 0, 0, 0, 0);

                    itemIdFound = lootTable[SCAV_AREA_MONEY][random(CHANCE)];
                    if(itemIdFound != INVALID_ITEM) // item found
                    {
                        amountFound = random(150) + 1;
                        playerInventory[playerid][itemIdFound] = playerInventory[playerid][itemIdFound] + amountFound;

                        if(amountFound <= 1)
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNameSingular]);
                        }
                        else
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNamePlural]);
                        }
                        SendClientMessage(playerid, COLOR_RP_PURPLE, string);

                        //UpdatePlayerInventoryEntry(playerid, itemIdFound, player[playerid][chosenChar]);
                    }
                    else
                    {
                        SendClientMessage(playerid, COLOR_RP_PURPLE, "You search the area and cannot find anything of use.");
                    }
                }
                case SCAV_AREA_GASSTATION:
                {
                    ClearAnimations(playerid);
	                OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 3.0, 0, 0, 0, 0, 0);

                    itemIdFound = lootTable[SCAV_AREA_GASSTATION][random(CHANCE)];
                    if(itemIdFound != INVALID_ITEM) // item found
                    {
                        new fuelcanItemId = ReturnItemIdByName("Fuel Can");

                        if(itemIdFound == fuelcanItemId)
                        {
                            if(playerInventory[playerid][fuelcanItemId] >= 1)
                            {
                                amountFound = 0;
                                SendClientMessage(playerid, COLOR_RP_PURPLE, "You search the area and cannot find anything of use.");
                                return 1;
                            }
                            else
                            {
                                amountFound = 1;
                            }
                        }
                        else
                        {
                            amountFound = random(3) + 1;
                        }

                        playerInventory[playerid][itemIdFound] = playerInventory[playerid][itemIdFound] + amountFound;

                        if(amountFound <= 1)
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNameSingular]);
                        }
                        else
                        {
                            format(string, sizeof(string), "You search the area and find %d %s.", amountFound, inventoryItems[itemIdFound][itemNamePlural]);
                        }
                        SendClientMessage(playerid, COLOR_RP_PURPLE, string);

                        //UpdatePlayerInventoryEntry(playerid, itemIdFound, player[playerid][chosenChar]);
                    }
                    else
                    {
                        SendClientMessage(playerid, COLOR_RP_PURPLE, "You search the area and cannot find anything of use.");
                    }
                }
            }
            
            /*
            * Give the player some EXP
            */
            if(amountFound > 0)
            {
                new expEarned = random(3) + 1; // 1 - 3
                player[playerid][exp] = player[playerid][exp] + expEarned;
                UpdateHudElementForPlayer(playerid, HUD_INFO);
            }

            /*
            * Set location's active to false so it cannot be searched again for X amount of time.
            */
            UpdateDynamic3DTextLabelText(scavTextLabel[i], COLOR_RED, "Looted");
            scavArea[i][areaActive] = false;
            SetTimerEx("ResetSearchZone", SEARCH_NODE_RESET_TIME, false, "d", i);
        }
    }
    return 1;
}