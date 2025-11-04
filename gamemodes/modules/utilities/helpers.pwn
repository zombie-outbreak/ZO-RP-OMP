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
* - AddCustomSkinModels() - Load custom zombie skins
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

// ===========================================================================
// CUSTOM SKINS
// ============================================================================
AddCustomSkinModels()
{
    AddCharModel(0, 20001, "zombie2.dff", "zombie2.txd");
    AddCharModel(0, 20002, "zombie3.dff", "zombie3.txd");
    AddCharModel(0, 20003, "zombie4.dff", "zombie4.txd");
    AddCharModel(0, 20004, "zombie5.dff", "zombie5.txd");
    AddCharModel(0, 20005, "zombie6.dff", "zombie6.txd");
    AddCharModel(0, 20006, "zombie7.dff", "zombie7.txd");
    AddCharModel(0, 20007, "zombie8.dff", "zombie8.txd");
    AddCharModel(0, 20008, "zombie9.dff", "zombie9.txd");
    AddCharModel(0, 20009, "zombie10.dff", "zombie10.txd");
    AddCharModel(0, 20010, "zombie11.dff", "zombie11.txd");
    AddCharModel(0, 20011, "zombie12.dff", "zombie12.txd");
    AddCharModel(0, 20012, "zombie13.dff", "zombie13.txd");
    AddCharModel(0, 20013, "zombie14.dff", "zombie14.txd");
    AddCharModel(0, 20014, "zombie15.dff", "zombie15.txd");
    AddCharModel(0, 20015, "zombie16.dff", "zombie16.txd");
    AddCharModel(0, 20016, "zombie17.dff", "zombie17.txd");
    AddCharModel(0, 20017, "zombie18.dff", "zombie18.txd");
    AddCharModel(0, 20018, "zombie19.dff", "zombie19.txd");
    AddCharModel(0, 20019, "zombie20.dff", "zombie20.txd");
    AddCharModel(0, 20020, "zombie21.dff", "zombie21.txd");
    AddCharModel(0, 20021, "zombie22.dff", "zombie22.txd");
    AddCharModel(0, 20022, "zombie23.dff", "zombie23.txd");
    AddCharModel(0, 20023, "zombie24.dff", "zombie24.txd");
    AddCharModel(0, 20024, "zombie25.dff", "zombie25.txd");
    AddCharModel(0, 20025, "zombie26.dff", "zombie26.txd");
    AddCharModel(0, 20026, "zombie27.dff", "zombie27.txd");
    AddCharModel(0, 20027, "zombie28.dff", "zombie28.txd");
    AddCharModel(0, 20028, "zombie29.dff", "zombie29.txd");
    AddCharModel(0, 20029, "zombie30.dff", "zombie30.txd");
    AddCharModel(0, 20030, "zombie31.dff", "zombie31.txd");
    AddCharModel(0, 20031, "zombie32.dff", "zombie32.txd");
    AddCharModel(0, 20032, "zombie33.dff", "zombie33.txd");
    AddCharModel(0, 20033, "zombie34.dff", "zombie34.txd");
    AddCharModel(0, 20034, "zombie35.dff", "zombie35.txd");
    AddCharModel(0, 20035, "zombie36.dff", "zombie36.txd");
    AddCharModel(0, 20036, "zombie37.dff", "zombie37.txd");
    AddCharModel(0, 20037, "zombie38.dff", "zombie38.txd");
    AddCharModel(0, 20038, "zombie39.dff", "zombie39.txd");
    AddCharModel(0, 20039, "zombie40.dff", "zombie40.txd");
    AddCharModel(0, 20040, "zombie41.dff", "zombie41.txd");
    AddCharModel(0, 20041, "zombie42.dff", "zombie42.txd");
    AddCharModel(0, 20042, "zombie43.dff", "zombie43.txd");
    AddCharModel(0, 20043, "zombie44.dff", "zombie44.txd");
    AddCharModel(0, 20044, "zombie45.dff", "zombie45.txd");
    AddCharModel(0, 20045, "zombie46.dff", "zombie46.txd");
    AddCharModel(0, 20046, "zombie47.dff", "zombie47.txd");
    AddCharModel(0, 20047, "zombie48.dff", "zombie48.txd");
    AddCharModel(0, 20048, "zombie49.dff", "zombie49.txd");
    AddCharModel(0, 20049, "zombie50.dff", "zombie50.txd");
    AddCharModel(0, 20050, "zombie51.dff", "zombie51.txd");
    AddCharModel(0, 20051, "zombie52.dff", "zombie52.txd");
    AddCharModel(0, 20052, "zombie53.dff", "zombie53.txd");
    AddCharModel(0, 20053, "zombie54.dff", "zombie54.txd");
    AddCharModel(0, 20054, "zombie55.dff", "zombie55.txd");
    AddCharModel(0, 20055, "zombie56.dff", "zombie56.txd");
    AddCharModel(0, 20056, "zombie57.dff", "zombie57.txd");
    AddCharModel(0, 20057, "zombie58.dff", "zombie58.txd");
    AddCharModel(0, 20058, "zombie59.dff", "zombie59.txd");
    AddCharModel(0, 20059, "zombie60.dff", "zombie60.txd");
    AddCharModel(0, 20060, "zombie61.dff", "zombie61.txd");
    AddCharModel(0, 20061, "zombie62.dff", "zombie62.txd");
    AddCharModel(0, 20062, "zombie63.dff", "zombie63.txd");
    AddCharModel(0, 20063, "zombie64.dff", "zombie64.txd");
    AddCharModel(0, 20064, "zombie65.dff", "zombie65.txd");
    AddCharModel(0, 20065, "zombie66.dff", "zombie66.txd");
    AddCharModel(0, 20066, "zombie67.dff", "zombie67.txd");
    AddCharModel(0, 20067, "zombie68.dff", "zombie68.txd");
    AddCharModel(0, 20068, "zombie69.dff", "zombie69.txd");
    AddCharModel(0, 20069, "zombie70.dff", "zombie70.txd");
    AddCharModel(0, 20070, "zombie71.dff", "zombie71.txd");
    AddCharModel(0, 20071, "zombie72.dff", "zombie72.txd");
    AddCharModel(0, 20072, "zombie73.dff", "zombie73.txd");
    AddCharModel(0, 20073, "zombie74.dff", "zombie74.txd");
    AddCharModel(0, 20074, "zombie75.dff", "zombie75.txd");
    AddCharModel(0, 20075, "zombie76.dff", "zombie76.txd");
    AddCharModel(0, 20076, "zombie77.dff", "zombie77.txd");
    AddCharModel(0, 20077, "zombie78.dff", "zombie78.txd");
    AddCharModel(0, 20078, "zombie79.dff", "zombie79.txd");
    AddCharModel(0, 20079, "zombie80.dff", "zombie80.txd");
    AddCharModel(0, 20080, "zombie81.dff", "zombie81.txd");
    AddCharModel(0, 20081, "zombie82.dff", "zombie82.txd");
    AddCharModel(0, 20082, "zombie83.dff", "zombie83.txd");
    AddCharModel(0, 20083, "zombie84.dff", "zombie84.txd");
    AddCharModel(0, 20084, "zombie85.dff", "zombie85.txd");
    AddCharModel(0, 20085, "zombie86.dff", "zombie86.txd");
    AddCharModel(0, 20086, "zombie87.dff", "zombie87.txd");
    AddCharModel(0, 20087, "zombie88.dff", "zombie88.txd");
    AddCharModel(0, 20088, "zombie89.dff", "zombie89.txd");
    AddCharModel(0, 20089, "zombie90.dff", "zombie90.txd");
    AddCharModel(0, 20090, "zombie91.dff", "zombie91.txd");
    AddCharModel(0, 20091, "zombie92.dff", "zombie92.txd");
    AddCharModel(0, 20092, "zombie93.dff", "zombie93.txd");
    AddCharModel(0, 20093, "zombie94.dff", "zombie94.txd");
    AddCharModel(0, 20094, "zombie95.dff", "zombie95.txd");
    AddCharModel(0, 20095, "zombie96.dff", "zombie96.txd");
    AddCharModel(0, 20096, "zombie97.dff", "zombie97.txd");
    AddCharModel(0, 20097, "zombie98.dff", "zombie98.txd");
    AddCharModel(0, 20098, "zombie99.dff", "zombie99.txd");
    AddCharModel(0, 20099, "zombie100.dff", "zombie100.txd");
    AddCharModel(0, 20100, "zombie101.dff", "zombie101.txd");
    AddCharModel(0, 20101, "zombie102.dff", "zombie102.txd");
    AddCharModel(0, 20102, "zombie103.dff", "zombie103.txd");
    AddCharModel(0, 20103, "zombie104.dff", "zombie104.txd");
    AddCharModel(0, 20104, "zombie105.dff", "zombie105.txd");
    AddCharModel(0, 20105, "zombie106.dff", "zombie106.txd");
    AddCharModel(0, 20106, "zombie107.dff", "zombie107.txd");
    AddCharModel(0, 20107, "zombie108.dff", "zombie108.txd");
    AddCharModel(0, 20108, "zombie109.dff", "zombie109.txd");
    AddCharModel(0, 20109, "zombie110.dff", "zombie110.txd");
    AddCharModel(0, 20110, "zombie111.dff", "zombie111.txd");
    AddCharModel(0, 20111, "zombie112.dff", "zombie112.txd");
    AddCharModel(0, 20112, "zombie113.dff", "zombie113.txd");
    AddCharModel(0, 20113, "zombie114.dff", "zombie114.txd");
    AddCharModel(0, 20114, "zombie115.dff", "zombie115.txd");
    AddCharModel(0, 20115, "zombie116.dff", "zombie116.txd");
    AddCharModel(0, 20116, "zombie117.dff", "zombie117.txd");
    AddCharModel(0, 20117, "zombie118.dff", "zombie118.txd");
    AddCharModel(0, 20118, "zombie119.dff", "zombie119.txd");
    AddCharModel(0, 20119, "zombie120.dff", "zombie120.txd");
    AddCharModel(0, 20120, "zombie121.dff", "zombie121.txd");
    AddCharModel(0, 20121, "zombie122.dff", "zombie122.txd");
    AddCharModel(0, 20122, "zombie123.dff", "zombie123.txd");
    AddCharModel(0, 20123, "zombie124.dff", "zombie124.txd");
    AddCharModel(0, 20124, "zombie125.dff", "zombie125.txd");
    AddCharModel(0, 20125, "zombie126.dff", "zombie126.txd");
    AddCharModel(0, 20126, "zombie127.dff", "zombie127.txd");
    AddCharModel(0, 20127, "zombie128.dff", "zombie128.txd");
    AddCharModel(0, 20128, "zombie129.dff", "zombie129.txd");
    AddCharModel(0, 20129, "zombie130.dff", "zombie130.txd");
    AddCharModel(0, 20130, "zombie131.dff", "zombie131.txd");
    AddCharModel(0, 20131, "zombie132.dff", "zombie132.txd");
    AddCharModel(0, 20132, "zombie133.dff", "zombie133.txd");
    AddCharModel(0, 20133, "zombie134.dff", "zombie134.txd");
    AddCharModel(0, 20134, "zombie135.dff", "zombie135.txd");
    AddCharModel(0, 20135, "zombie136.dff", "zombie136.txd");
    AddCharModel(0, 20136, "zombie137.dff", "zombie137.txd");
    AddCharModel(0, 20137, "zombie138.dff", "zombie138.txd");
    AddCharModel(0, 20138, "zombie139.dff", "zombie139.txd");
    AddCharModel(0, 20139, "zombie140.dff", "zombie140.txd");
    AddCharModel(0, 20140, "zombie141.dff", "zombie141.txd");
    AddCharModel(0, 20141, "zombie142.dff", "zombie142.txd");
    AddCharModel(0, 20142, "zombie143.dff", "zombie143.txd");
    AddCharModel(0, 20143, "zombie144.dff", "zombie144.txd");
    AddCharModel(0, 20144, "zombie145.dff", "zombie145.txd");
    AddCharModel(0, 20145, "zombie146.dff", "zombie146.txd");
    AddCharModel(0, 20146, "zombie147.dff", "zombie147.txd");
    AddCharModel(0, 20147, "zombie148.dff", "zombie148.txd");
    AddCharModel(0, 20148, "zombie149.dff", "zombie149.txd");
    AddCharModel(0, 20149, "zombie150.dff", "zombie150.txd");
    AddCharModel(0, 20150, "zombie151.dff", "zombie151.txd");
    AddCharModel(0, 20151, "zombie152.dff", "zombie152.txd");
    AddCharModel(0, 20152, "zombie153.dff", "zombie153.txd");
    AddCharModel(0, 20153, "zombie154.dff", "zombie154.txd");
    AddCharModel(0, 20154, "zombie155.dff", "zombie155.txd");
    AddCharModel(0, 20155, "zombie156.dff", "zombie156.txd");
    AddCharModel(0, 20156, "zombie157.dff", "zombie157.txd");
    AddCharModel(0, 20157, "zombie158.dff", "zombie158.txd");
    AddCharModel(0, 20158, "zombie159.dff", "zombie159.txd");
    AddCharModel(0, 20159, "zombie160.dff", "zombie160.txd");
    AddCharModel(0, 20160, "zombie161.dff", "zombie161.txd");
    AddCharModel(0, 20161, "zombie162.dff", "zombie162.txd");
    AddCharModel(0, 20162, "zombie163.dff", "zombie163.txd");
    AddCharModel(0, 20163, "zombie164.dff", "zombie164.txd");
    AddCharModel(0, 20164, "zombie165.dff", "zombie165.txd");
    AddCharModel(0, 20165, "zombie166.dff", "zombie166.txd");
    AddCharModel(0, 20166, "zombie167.dff", "zombie167.txd");
    AddCharModel(0, 20167, "zombie168.dff", "zombie168.txd");
    AddCharModel(0, 20168, "zombie169.dff", "zombie169.txd");
    AddCharModel(0, 20169, "zombie170.dff", "zombie170.txd");
    AddCharModel(0, 20170, "zombie171.dff", "zombie171.txd");
    AddCharModel(0, 20171, "zombie172.dff", "zombie172.txd");
    AddCharModel(0, 20172, "zombie173.dff", "zombie173.txd");
    AddCharModel(0, 20173, "zombie174.dff", "zombie174.txd");
    AddCharModel(0, 20174, "zombie175.dff", "zombie175.txd");
    AddCharModel(0, 20175, "zombie176.dff", "zombie176.txd");
    AddCharModel(0, 20176, "zombie177.dff", "zombie177.txd");
    AddCharModel(0, 20177, "zombie178.dff", "zombie178.txd");
    AddCharModel(0, 20178, "zombie179.dff", "zombie179.txd");
    AddCharModel(0, 20179, "zombie180.dff", "zombie180.txd");
    AddCharModel(0, 20180, "zombie181.dff", "zombie181.txd");
    AddCharModel(0, 20181, "zombie182.dff", "zombie182.txd");
    AddCharModel(0, 20182, "zombie183.dff", "zombie183.txd");
    AddCharModel(0, 20183, "zombie184.dff", "zombie184.txd");
    AddCharModel(0, 20184, "zombie185.dff", "zombie185.txd");
    AddCharModel(0, 20185, "zombie186.dff", "zombie186.txd");
    AddCharModel(0, 20186, "zombie187.dff", "zombie187.txd");
    AddCharModel(0, 20187, "zombie188.dff", "zombie188.txd");
    AddCharModel(0, 20188, "zombie189.dff", "zombie189.txd");
    AddCharModel(0, 20189, "zombie190.dff", "zombie190.txd");
    AddCharModel(0, 20190, "zombie191.dff", "zombie191.txd");
    AddCharModel(0, 20191, "zombie192.dff", "zombie192.txd");
    AddCharModel(0, 20192, "zombie193.dff", "zombie193.txd");
    AddCharModel(0, 20193, "zombie194.dff", "zombie194.txd");
    AddCharModel(0, 20194, "zombie195.dff", "zombie195.txd");
    AddCharModel(0, 20195, "zombie196.dff", "zombie196.txd");
    AddCharModel(0, 20196, "zombie197.dff", "zombie197.txd");
    AddCharModel(0, 20197, "zombie198.dff", "zombie198.txd");
    AddCharModel(0, 20198, "zombie199.dff", "zombie199.txd");
    AddCharModel(0, 20199, "zombie200.dff", "zombie200.txd");
    AddCharModel(0, 20200, "zombie201.dff", "zombie201.txd");
    AddCharModel(0, 20201, "zombie202.dff", "zombie202.txd");
    AddCharModel(0, 20202, "zombie203.dff", "zombie203.txd");
    AddCharModel(0, 20203, "zombie204.dff", "zombie204.txd");
    AddCharModel(0, 20204, "zombie205.dff", "zombie205.txd");
    AddCharModel(0, 20205, "zombie206.dff", "zombie206.txd");
    AddCharModel(0, 20206, "zombie207.dff", "zombie207.txd");
    AddCharModel(0, 20207, "zombie208.dff", "zombie208.txd");
    AddCharModel(0, 20208, "zombie209.dff", "zombie209.txd");
    AddCharModel(0, 20209, "zombie210.dff", "zombie210.txd");
    AddCharModel(0, 20210, "zombie211.dff", "zombie211.txd");
    AddCharModel(0, 20211, "zombie212.dff", "zombie212.txd");
    AddCharModel(0, 20212, "zombie213.dff", "zombie213.txd");
    AddCharModel(0, 20213, "zombie214.dff", "zombie214.txd");
    AddCharModel(0, 20214, "zombie215.dff", "zombie215.txd");
    AddCharModel(0, 20215, "zombie216.dff", "zombie216.txd");
    AddCharModel(0, 20216, "zombie217.dff", "zombie217.txd");
    AddCharModel(0, 20217, "zombie218.dff", "zombie218.txd");
    AddCharModel(0, 20218, "zombie219.dff", "zombie219.txd");
    AddCharModel(0, 20219, "zombie220.dff", "zombie220.txd");
    AddCharModel(0, 20220, "zombie221.dff", "zombie221.txd");
    AddCharModel(0, 20221, "zombie222.dff", "zombie222.txd");
    AddCharModel(0, 20222, "zombie223.dff", "zombie223.txd");
    AddCharModel(0, 20223, "zombie224.dff", "zombie224.txd");
    AddCharModel(0, 20224, "zombie225.dff", "zombie225.txd");
    AddCharModel(0, 20225, "zombie226.dff", "zombie226.txd");
    AddCharModel(0, 20226, "zombie227.dff", "zombie227.txd");
    AddCharModel(0, 20227, "zombie228.dff", "zombie228.txd");
    AddCharModel(0, 20228, "zombie229.dff", "zombie229.txd");
    AddCharModel(0, 20229, "zombie230.dff", "zombie230.txd");
    AddCharModel(0, 20230, "zombie231.dff", "zombie231.txd");
    AddCharModel(0, 20231, "zombie232.dff", "zombie232.txd");
    AddCharModel(0, 20232, "zombie233.dff", "zombie233.txd");
    AddCharModel(0, 20233, "zombie234.dff", "zombie234.txd");
    AddCharModel(0, 20234, "zombie235.dff", "zombie235.txd");
    AddCharModel(0, 20235, "zombie236.dff", "zombie236.txd");
    AddCharModel(0, 20236, "zombie237.dff", "zombie237.txd");
    AddCharModel(0, 20237, "zombie238.dff", "zombie238.txd");
    AddCharModel(0, 20238, "zombie239.dff", "zombie239.txd");
    AddCharModel(0, 20239, "zombie240.dff", "zombie240.txd");
    AddCharModel(0, 20240, "zombie241.dff", "zombie241.txd");
    return 1;
}

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
