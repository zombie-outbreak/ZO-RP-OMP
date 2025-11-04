// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - VEHICLE SYSTEM
// ============================================================================
/*
* MODULE: Vehicles
* PURPOSE: Vehicle management and storage system
* 
* DEPENDENCIES:
* - core/config.pwn
* - core/constants.pwn
* - core/player_data.pwn
* - core/database.pwn
* 
* PUBLIC FUNCTIONS:
* - LoadVehicles() - Load all vehicles from database
* - GetVehicleFuel(vehicleid) - Get vehicle's fuel level
* - SetVehicleFuel(vehicleid, amount) - Set vehicle fuel
* - ToggleVehicleEngine(vehicleid) - Turn engine on/off
* 
* DESCRIPTION:
* Manages all vehicle-related functionality including:
* - Vehicle spawning and despawning
* - Vehicle fuel system
* - Vehicle damage tracking
* - Vehicle ownership
* - Engine states
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_VEHICLES_INCLUDED
#define MODULE_VEHICLES_INCLUDED

// ============================================================================
// DATA STRUCTURES
// ============================================================================

/*
* Vehicle Data Enum
*/
enum E_VEHICLES
{
    vehId,
    vehOwner[64],
    vehPos[4],
    Float:vehHealth,
    vehFuel,
    maxFuel,
    panels,
    doors,
    lights,
    tires,
    bool:engine, // true for on, false for off
    bool:isBeingFilled,
}

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

new serverVehicle[MAX_VEHICLES][E_VEHICLES];

// ============================================================================
// FORWARD DECLARATIONS
// ============================================================================

// Add your vehicle system forward declarations here
// forward OnVehicleLoad();
// forward OnVehicleEngineToggle(vehicleid, engine);

// ============================================================================
// VEHICLE CONTROL FUNCTIONS
// ============================================================================

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

// ============================================================================
// VEHICLE DAMAGE ENCODING/DECODING
// ============================================================================

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

// ============================================================================
// VEHICLE SETUP & MANAGEMENT
// ============================================================================

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

    // Apply mechanic skill discount (5% per level)
    new mechanicLevel = player[playerid][mechanicSkillLevel];
    if (mechanicLevel > 0)
    {
        new Float:discount = 1.0 - (mechanicLevel * 0.05);
        scrapRequired = floatround(scrapRequired * discount);
    }
    
    return scrapRequired;
}

StartVehicleAttempt(playerid)
{
    new tmpVehicleId = GetPlayerVehicleID(playerid);
    new chanceToStart = RandomRange(1, 100);
    
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

#endif // MODULE_VEHICLES_INCLUDED
