// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - INVENTORY SYSTEM
// ============================================================================
/*
* MODULE: Inventory
* PURPOSE: Player inventory and item management system
* 
* DEPENDENCIES:
* - core/config.pwn
* - core/constants.pwn
* - core/player_data.pwn
* - core/database.pwn
* 
* PUBLIC FUNCTIONS:
* - LoadInventoryItems() - Load all items from database
* - GetPlayerInventoryItem(playerid, itemid) - Get player's item quantity
* - GivePlayerInventoryItem(playerid, itemid, amount) - Give item to player
* - RemovePlayerInventoryItem(playerid, itemid, amount) - Remove item
* - GetPlayerInventoryCount(playerid) - Count player's inventory items
* 
* DESCRIPTION:
* Manages all inventory-related functionality including:
* - Item definitions and properties
* - Player inventory storage
* - Loot tables and scavenging locations
* - Item usage and equipping
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_INVENTORY_INCLUDED
#define MODULE_INVENTORY_INCLUDED

// ============================================================================
// DATA STRUCTURES
// ============================================================================

/*
* Inventory Item Data
*/
enum inventoryItemData
{
    itemId,
    itemNameSingular[128],
    itemNamePlural[128],
    itemDescription[128],
    itemCategory,
    itemHealAmount,
    itemWepId,
    itemAmmoId,
    itemWepSlot,
    bool:isUsable, // mostly only used for general category items which may not all have a usecase
    itemMaxResource,
}

/*
* Scavenging Area Data
*/
enum E_SCAV_AREAS
{
    scavId,
    Float:scavPos[3],
    scavInterior,
    scavWorld,
    scavType,
    bool:areaActive,
}

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

// Item System
new serverItemCount = 0;
new inventoryItems[MAX_ITEMS][inventoryItemData];
new playerInventory[MAX_PLAYERS][MAX_ITEMS];
new playerInventoryResource[MAX_PLAYERS][MAX_ITEMS];

// Scavenging System
new scavAreaCount = 0;
new scavArea[MAX_SCAV_AREAS][E_SCAV_AREAS];
new Text3D:scavTextLabel[MAX_SCAV_AREAS];

// Loot Tables (corresponds to item IDs found in inventoryItems)
// 0 for no item, 1+ for an item
new lootTableCount = 0;
new lootTableName[MAX_LOOT_TABLES][32];
new lootTable[MAX_LOOT_TABLES][CHANCE];

// Fuel Pump System
new fuelPumpCount = 0;
new Float:fuelPump[MAX_FUEL_PUMPS][3];
new Text3D:fillTextLabel[MAX_FUEL_PUMPS];

// ============================================================================
// FORWARD DECLARATIONS
// ============================================================================

// Add your inventory system forward declarations here
// forward OnInventoryLoad();
// forward OnPlayerUseItem(playerid, itemid);

// ============================================================================
// INVENTORY MANAGEMENT FUNCTIONS
// ============================================================================

RefillWaterCanteen(playerid, dirtyWaterCanteenId)
{
	ClearAnimations(playerid);
	OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 3.0, 0, 0, 0, 0, 0);
	SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER, "fills their canteen with dirty water.");

	playerInventory[playerid][player[playerid][chosenItemId]] = playerInventory[playerid][player[playerid][chosenItemId]] - 1;
	playerInventory[playerid][dirtyWaterCanteenId] = playerInventory[playerid][dirtyWaterCanteenId] + 1;
	return 1;
}

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

                        UpdateCharacterInventoryEntry(playerid, itemIdFound);
                        
                        // Award EXP for successful search
                        GivePlayerExp(playerid, 2);
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

                        UpdateCharacterInventoryEntry(playerid, itemIdFound);
                        
                        // Award EXP for successful search
                        GivePlayerExp(playerid, 2);
                    }
                    else
                    {
                        SendClientMessage(playerid, COLOR_RP_PURPLE, "You search the area and cannot find anything of use.");
                    }
                }
            }
            return 1;
        }
    }
    
    SendClientMessage(playerid, COLOR_RED, "You are not near a search location.");
    return 0;
}

#endif // MODULE_INVENTORY_INCLUDED
