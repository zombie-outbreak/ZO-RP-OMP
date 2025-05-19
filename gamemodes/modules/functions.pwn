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