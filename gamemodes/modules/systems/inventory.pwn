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
    itemValue,
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

// New XML-based Loot Tables
#define MAX_LOOT_ITEMS_PER_TABLE 50
enum E_LOOT_ITEM
{
    lootItemId,
    lootItemWeight,
    lootItemMinQty,
    lootItemMaxQty
}
new lootTableCount = 0;
new lootTableName[MAX_LOOT_TABLES][32];
new lootTableItems[MAX_LOOT_TABLES][MAX_LOOT_ITEMS_PER_TABLE][E_LOOT_ITEM];
new lootTableItemCount[MAX_LOOT_TABLES];
new lootTableTotalWeight[MAX_LOOT_TABLES];

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

            ClearAnimations(playerid);
            OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 3.0, 0, 0, 0, 0, 0);
            
            // Calculate success rate based on Looter perk
            // Level 0: 15% success (85% failure) - Base is very difficult
            // Level 1: 30% success (70% failure) - First level doubles success
            // Level 2: 40% success (60% failure) - Significant improvement
            // Level 3: 50% success (50% failure) - Even odds
            // Level 4: 58% success (42% failure) - Decent chance
            // Level 5: 65% success (35% failure) - Master scavenger
            new successRate = 15; // Base rate
            if(player[playerid][looterSkillLevel] == 1) successRate = 30;
            else if(player[playerid][looterSkillLevel] == 2) successRate = 40;
            else if(player[playerid][looterSkillLevel] == 3) successRate = 50;
            else if(player[playerid][looterSkillLevel] == 4) successRate = 58;
            else if(player[playerid][looterSkillLevel] >= 5) successRate = 65;
            
            new searchSuccess = random(100);
            if(searchSuccess >= successRate) // Failed to find anything
            {
                SendClientMessage(playerid, COLOR_RP_PURPLE, "You search the area and cannot find anything of use.");
                amountFound = 0; // No EXP for failed searches
            }
            // Use new XML-based weighted loot system for all scav areas
            else if(scavArea[i][scavType] < lootTableCount)
            {
                if(GetRandomLootItem(scavArea[i][scavType], itemIdFound, amountFound))
                {
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
                }
                else
                {
                    SendClientMessage(playerid, COLOR_RP_PURPLE, "You search the area and cannot find anything of use.");
                    amountFound = 0; // No EXP for failed searches
                }
            }
            else
            {
                // Scav area type not found in loot tables
                printf("[LOOT TABLES] WARNING: Scav area type %d has no corresponding loot table", scavArea[i][scavType]);
                SendClientMessage(playerid, COLOR_RP_PURPLE, "You search the area and cannot find anything of use.");
                amountFound = 0;
            }
            
            /*
            * Give the player some EXP
            */
            if(amountFound > 0 && player[playerid][level] != MAX_LEVELS)
            {
                new expEarned = random(3) + 1; // 1 - 3
                GivePlayerExp(playerid, expEarned);
            }

            /*
            * Set location's active to false so it cannot be searched again for X amount of time.
            */
            UpdateDynamic3DTextLabelText(scavTextLabel[i], COLOR_RED, "Looted");
            scavArea[i][areaActive] = false;
            SetTimerEx("ResetSearchZone", SEARCH_NODE_RESET_TIME, false, "d", i);
            
            return 1;
        }
    }
    
    // If we get here, player wasn't near any scav area
    return SendClientMessage(playerid, COLOR_RED, "You are not in range of a scavenging location.");
}

// ============================================================================
// XML LOOT TABLE FUNCTIONS
// ============================================================================

/*
* LoadLootTablesFromXML
* Purpose: Load all loot tables from XML files listed in scriptfiles/loot_tables/index.txt
* Returns: Number of loot tables loaded
* 
* To add a new loot table:
* 1. Create the XML file in scriptfiles/loot_tables/
* 2. Add the filename to scriptfiles/loot_tables/index.txt
* 3. Reload with /reloadloottables or restart server
*/
LoadLootTablesFromXML()
{
    lootTableCount = 0;
    
    // Open index file that lists all loot table files
    new File:indexFile = fopen("loot_tables/index.txt", io_read);
    if(!indexFile)
    {
        print("[LOOT TABLES] ERROR: Could not open loot_tables/index.txt");
        print("[LOOT TABLES] Create this file with one XML filename per line (e.g., scrap.xml)");
        return 0;
    }
    
    new filename[64];
    new fullPath[128];
    new filesLoaded = 0;
    new line[128];
    
    // Read each line from index file
    while(fread(indexFile, line, sizeof(line)) && lootTableCount < MAX_LOOT_TABLES)
    {
        // Remove ALL whitespace, newlines, and carriage returns from the line
        new writePos = 0;
        for(new i = 0; i < strlen(line); i++)
        {
            // Stop at comment character
            if(line[i] == '#')
                break;
                
            // Skip whitespace, newlines, carriage returns, tabs
            if(line[i] == ' ' || line[i] == '\t' || line[i] == '\n' || line[i] == '\r')
                continue;
                
            // Copy valid character
            filename[writePos] = line[i];
            writePos++;
        }
        filename[writePos] = '\0';
        
        // Skip empty lines
        if(strlen(filename) == 0)
            continue;
        
        // Build full path
        format(fullPath, sizeof(fullPath), "loot_tables/%s", filename);
        
        // Load the XML file
        new XMLNode:doc = XML_LoadDocument(fullPath);
        
        if(!doc)
        {
            printf("[LOOT TABLES] ERROR: Failed to load %s", fullPath);
            continue;
        }
        
        // doc is the document node, we need to find the <loottable> element
        new XMLNode:currentNode = XML_GetFirstChild(doc);
        new XMLNode:rootNode = XMLNode:0;
        new nodeName[32];
        
        // Find the <loottable> element among document children (skip comments/text)
        while(currentNode)
        {
            XML_GetValue(currentNode, nodeName, sizeof(nodeName));
            if(strcmp(nodeName, "loottable", false) == 0)
            {
                rootNode = currentNode;
                break;
            }
            currentNode = XML_GetNextSibling(currentNode);
        }
        
        if(!rootNode)
        {
            printf("[LOOT TABLES] ERROR: No <loottable> element in %s", fullPath);
            XML_UnloadDocument(doc);
            continue;
        }
        
        // Now iterate through <loottable>'s children to find <name> and <items>
        currentNode = XML_GetFirstChild(rootNode);
        new XMLNode:itemsNode = XMLNode:0;
        
        while(currentNode)
        {
            XML_GetValue(currentNode, nodeName, sizeof(nodeName));
            
            if(strcmp(nodeName, "name", false) == 0)
            {
                // Get the text content of <name>
                new XMLNode:textNode = XML_GetFirstChild(currentNode);
                if(textNode)
                {
                    XML_GetValue(textNode, lootTableName[lootTableCount], 32);
                }
            }
            else if(strcmp(nodeName, "items", false) == 0)
            {
                itemsNode = currentNode;
            }
            
            currentNode = XML_GetNextSibling(currentNode);
        }
        
        // Use filename as fallback name if not found
        if(strlen(lootTableName[lootTableCount]) == 0)
        {
            format(lootTableName[lootTableCount], 32, "%s", filename);
        }
        
        // Make sure we found the items node
        if(!itemsNode)
        {
            printf("[LOOT TABLES] ERROR: No <items> node in %s", fullPath);
            XML_UnloadDocument(doc);
            continue;
        }
        
        // Parse each <item> node
        new XMLNode:itemNode = XML_GetFirstChild(itemsNode);
        new itemCount = 0;
        new totalWeight = 0;
        new itemNodeName[32];
        
        while(itemNode != XMLNode:0 && itemCount < MAX_LOOT_ITEMS_PER_TABLE)
        {
            // Check if this is an item element
            XML_GetValue(itemNode, itemNodeName, sizeof(itemNodeName));
            
            if(strcmp(itemNodeName, "item", false) == 0)
            {
                new tmpStr[16];
                
                // Get item id
                XML_GetAttribute(itemNode, "id", tmpStr, sizeof(tmpStr));
                lootTableItems[lootTableCount][itemCount][lootItemId] = strval(tmpStr);
                
                // Get weight
                XML_GetAttribute(itemNode, "weight", tmpStr, sizeof(tmpStr));
                lootTableItems[lootTableCount][itemCount][lootItemWeight] = strval(tmpStr);
                totalWeight += strval(tmpStr);
                
                // Get min_quantity
                XML_GetAttribute(itemNode, "min_quantity", tmpStr, sizeof(tmpStr));
                lootTableItems[lootTableCount][itemCount][lootItemMinQty] = strval(tmpStr);
                
                // Get max_quantity
                XML_GetAttribute(itemNode, "max_quantity", tmpStr, sizeof(tmpStr));
                lootTableItems[lootTableCount][itemCount][lootItemMaxQty] = strval(tmpStr);
                
                itemCount++;
            }
            
            itemNode = XML_GetNextSibling(itemNode);
        }
        
        lootTableItemCount[lootTableCount] = itemCount;
        lootTableTotalWeight[lootTableCount] = totalWeight;
        
        printf("[LOOT TABLES] Loaded '%s' with %d items (total weight: %d)", 
            lootTableName[lootTableCount], itemCount, totalWeight);
        
        XML_UnloadDocument(doc);
        lootTableCount++;
        filesLoaded++;
    }
    
    fclose(indexFile);
    
    printf("[LOOT TABLES] Successfully loaded %d loot tables from XML", filesLoaded);
    return lootTableCount;
}

/*
* GetRandomLootItem
* Purpose: Get a random item from a loot table using weighted probability
* Params:
*   - lootTableId: The ID of the loot table (SCAV_AREA_SCRAP, etc.)
*   - &foundItemId: Will be set to the selected item ID
*   - &quantity: Will be set to the random quantity (min to max)
* Returns: true if item found, false if no items in table
*/
GetRandomLootItem(lootTableId, &foundItemId, &quantity)
{
    if(lootTableId < 0 || lootTableId >= lootTableCount)
        return false;
    
    if(lootTableItemCount[lootTableId] == 0)
        return false;
    
    // Generate random number from 0 to totalWeight
    new randomWeight = random(lootTableTotalWeight[lootTableId]);
    new currentWeight = 0;
    
    // Find which item this weight corresponds to
    for(new i = 0; i < lootTableItemCount[lootTableId]; i++)
    {
        currentWeight += lootTableItems[lootTableId][i][lootItemWeight];
        
        if(randomWeight < currentWeight)
        {
            // Found the item!
            foundItemId = lootTableItems[lootTableId][i][lootItemId];
            
            // Calculate random quantity between min and max
            new minQty = lootTableItems[lootTableId][i][lootItemMinQty];
            new maxQty = lootTableItems[lootTableId][i][lootItemMaxQty];
            
            if(minQty == maxQty)
                quantity = minQty;
            else
                quantity = random(maxQty - minQty + 1) + minQty;
            
            return true;
        }
    }
    
    return false;
}

#endif // MODULE_INVENTORY_INCLUDED
