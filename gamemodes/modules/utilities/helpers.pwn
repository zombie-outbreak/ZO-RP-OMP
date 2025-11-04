// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - HELPER UTILITIES
// ============================================================================
/*
* MODULE: Helpers
* PURPOSE: General utility and helper functions
* 
* DEPENDENCIES:
* - core/config.pwn
* - core/constants.pwn
* - core/player_data.pwn
* - systems/inventory.pwn (for item lookups)
* - systems/interiors.pwn (for interior pickups)
* 
* PUBLIC FUNCTIONS:
* - RemoveUnderscoreFromName() - Convert underscore to space in names
* - GetXYInFrontOfPlayer() - Get coordinates in front of player
* - GetXYBehindPlayer() - Get coordinates behind player
* - OnePlayAnim() - Play animation once
* - LoopingAnim() - Play looping animation
* - StopLoopingAnim() - Stop looping animation
* - IsKeyJustDown() - Check if key was just pressed
* - RandomRange() - Generate random number in range
* - RemoveWeaponFromSlot() - Remove weapon from specific slot
* - ReturnWeaponAmmoId() - Get ammo item ID for weapon
* - ReturnItemIdByName() - Get item ID by name lookup
* - CreateInteriorPickup() - Create interior entrance/exit arrows
* - FormatUnixTime() - Convert timestamp to readable format
* - GivePlayerExp() - Award experience points to player
* 
* DESCRIPTION:
* Provides general utility functions used across the gamemode including:
* - String manipulation
* - Player position calculations
* - Animation helpers
* - Weapon management
* - Item lookups
* - Time formatting
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_HELPERS_INCLUDED
#define MODULE_HELPERS_INCLUDED

// ============================================================================
// STRING MANIPULATION
// ============================================================================

RemoveUnderscoreFromName(const tmpName[])
{
    new passedName[MAX_PLAYER_NAME];
    format(passedName, sizeof(passedName), "%s", tmpName);
    
    for(new i; i < MAX_PLAYER_NAME; i++)
    {
        if(passedName[i] == '_')
            passedName[i] = ' ';
    }
    return passedName;
}

// ============================================================================
// POSITION HELPERS
// ============================================================================

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

// ============================================================================
// ANIMATION HELPERS
// ============================================================================

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

// ============================================================================
// WEAPON MANAGEMENT
// ============================================================================

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

// ============================================================================
// ITEM/WEAPON LOOKUPS
// ============================================================================

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

// ============================================================================
// INTERIOR SYSTEM HELPERS
// ============================================================================

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

// ============================================================================
// MATH & MISC UTILITIES
// ============================================================================

RandomRange(min, max)
{
    new rand = random(max-min)+min;    
    return rand;
}

FormatUnixTime(timestamp)
{
    new dateStr[32];
    
    // Convert timestamp to date components
    // This is a simplified version - you may want to use a more robust date library
    new currentTime = gettime();
    new diff = currentTime - timestamp;
    
    if(diff < 60)
        format(dateStr, sizeof(dateStr), "%d sec ago", diff);
    else if(diff < 3600)
        format(dateStr, sizeof(dateStr), "%d min ago", diff / 60);
    else if(diff < 86400)
        format(dateStr, sizeof(dateStr), "%d hours ago", diff / 3600);
    else
        format(dateStr, sizeof(dateStr), "%d days ago", diff / 86400);
    
    return dateStr;
}

// ============================================================================
// EXPERIENCE SYSTEM
// ============================================================================

GivePlayerExp(playerid, amount)
{
    if(!IsPlayerConnected(playerid))
        return 0;
    
    if(amount <= 0)
        return 0;
    
    // Update player experience
    player[playerid][exp] += amount;
    
    // Update HUD to reflect new experience
    UpdateHudElementForPlayer(playerid, HUD_INFO);
    
    // Save to database
    new query[128];
    format(query, sizeof(query), "UPDATE `players` SET `exp` = %d WHERE `id` = %d", player[playerid][exp], player[playerid][ID]);
    mysql_tquery(database, query);
    return 1;
}

#endif // MODULE_HELPERS_INCLUDED
