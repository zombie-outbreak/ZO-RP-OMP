// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - SHOP SYSTEM
// ============================================================================
/*
* MODULE: Shop System
* PURPOSE: Player shop management with NPC vendors
* 
* DEPENDENCIES:
* - core/config.pwn
* - core/constants.pwn
* - core/player_data.pwn
* - core/database.pwn
* - systems/inventory.pwn
* 
* PUBLIC FUNCTIONS:
* - CreateShop(Float:x, Float:y, Float:z, Float:a, interior, virtualworld, actorSkin) - Create a new shop at location with angle
* - DeleteShop(shopIndex) - Delete a shop by index
* - CreateShopActor(shopIndex) - Create visual elements for shop (actor, 3D label)
* - DestroyShopActor(shopIndex) - Remove visual elements for shop
* - GetNearestShop(playerid) - Get nearest shop index to player
* - GetShopIndexById(shopid) - Get shop array index from database ID
* - ShowShopMenu(playerid, shopIndex) - Show main shop dialog to player
* - ShowShopBuyMenu(playerid, shopIndex) - Show buy items dialog
* - ShowShopSellMenu(playerid, shopIndex) - Show sell items dialog
* - BuyShopItem(playerid, shopIndex, itemid, quantity) - Purchase item from shop
* - SellShopItem(playerid, shopIndex, itemid, quantity) - Sell item to shop
* 
* ADMIN COMMANDS:
* - /createshop [skin] - Create a shop at your location
* - /deleteshop - Delete nearest shop
* - /editshop - Edit nearest shop's inventory
* - /listshops - List all shops
* - /gotoshop [id] - Teleport to shop
* 
* DESCRIPTION:
* Manages NPC shop system where players can buy and sell items.
* Shops are represented by actors with 3D text labels using the streamer plugin.
* Currency is the Money item from the inventory system.
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_SHOPS_INCLUDED
#define MODULE_SHOPS_INCLUDED

// ============================================================================
// CONSTANTS
// ============================================================================

// Shop Interaction Types
#define SHOP_INTERACT_BUY 0
#define SHOP_INTERACT_SELL 1

// ============================================================================
// DATA STRUCTURES
// ============================================================================

/*
* Shop Data
*/
enum shopData
{
    shopId,
    shopActorSkin,
    Float:shopX,
    Float:shopY,
    Float:shopZ,
    Float:shopA,
    shopInterior,
    shopVirtualWorld,
    shopActorId, // Streamer actor ID
    Text3D:shopLabelId, // 3D text label ID
    shopMoney, // Shop's available money for buying items from players
    shopInventory[MAX_ITEMS] // Stock quantity for each item (0 = not sold)
}

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

new shopInfo[MAX_SHOPS][shopData];
new totalShops = 0;
new playerCurrentShop[MAX_PLAYERS] = {INVALID_SHOP_ID, ...};

// ============================================================================
// SHOP CREATION AND MANAGEMENT
// ============================================================================

/*
* Create shop actor and visual elements
*/
CreateShopActor(shopIndex)
{
    if(shopIndex < 0 || shopIndex >= MAX_SHOPS) return 0;
    
    // Create actor using streamer
    shopInfo[shopIndex][shopActorId] = CreateDynamicActor(
        shopInfo[shopIndex][shopActorSkin],
        shopInfo[shopIndex][shopX],
        shopInfo[shopIndex][shopY],
        shopInfo[shopIndex][shopZ],
        shopInfo[shopIndex][shopA], // rotation
        false, // invulnerable
        100.0, // health
        shopInfo[shopIndex][shopVirtualWorld],
        shopInfo[shopIndex][shopInterior]
    );
    
    // Create 3D text label
    new labelText[128];
    format(labelText, sizeof(labelText), "{00FF00}Shop\n{FFFFFF}Press {FFFF00}Y{FFFFFF} to interact");
    shopInfo[shopIndex][shopLabelId] = CreateDynamic3DTextLabel(
        labelText,
        0xFFFFFFFF,
        shopInfo[shopIndex][shopX],
        shopInfo[shopIndex][shopY],
        shopInfo[shopIndex][shopZ] + 1.0,
        10.0,
        INVALID_PLAYER_ID,
        INVALID_VEHICLE_ID,
        0,
        shopInfo[shopIndex][shopVirtualWorld],
        shopInfo[shopIndex][shopInterior]
    );
    
    return 1;
}

/*
* Destroy shop actor and visual elements
*/
DestroyShopActor(shopIndex)
{
    if(shopIndex < 0 || shopIndex >= MAX_SHOPS) return 0;
    
    if(IsValidDynamicActor(shopInfo[shopIndex][shopActorId]))
        DestroyDynamicActor(shopInfo[shopIndex][shopActorId]);
    
    if(IsValidDynamic3DTextLabel(shopInfo[shopIndex][shopLabelId]))
        DestroyDynamic3DTextLabel(shopInfo[shopIndex][shopLabelId]);
    
    return 1;
}

/*
* Create a new shop
*/
CreateShop(Float:x, Float:y, Float:z, Float:a, interior, virtualworld, actorSkin)
{
    if(totalShops >= MAX_SHOPS)
    {
        printf("[SHOPS] Error: Cannot create shop - limit reached (%d)", MAX_SHOPS);
        return INVALID_SHOP_ID;
    }
    
    new shopIndex = totalShops;
    
    // Get next available ID
    new query[128];
    format(query, sizeof(query), "SELECT MAX(id) AS maxid FROM `shops`");
    new Cache:result = mysql_query(database, query);
    new maxId = 0;
    if(cache_num_rows() > 0)
    {
        cache_get_value_int(0, "maxid", maxId);
    }
    cache_delete(result);
    
    shopInfo[shopIndex][shopId] = maxId + 1;
    shopInfo[shopIndex][shopActorSkin] = actorSkin;
    shopInfo[shopIndex][shopX] = x;
    shopInfo[shopIndex][shopY] = y;
    shopInfo[shopIndex][shopZ] = z;
    shopInfo[shopIndex][shopA] = a;
    shopInfo[shopIndex][shopInterior] = interior;
    shopInfo[shopIndex][shopVirtualWorld] = virtualworld;
    shopInfo[shopIndex][shopMoney] = 1000; // Starting shop money
    
    // Initialize empty inventory
    for(new i = 0; i < MAX_ITEMS; i++)
    {
        shopInfo[shopIndex][shopInventory][i] = 0;
    }
    
    // Create actor
    CreateShopActor(shopIndex);
    
    // Save to database
    SaveShopToDatabase(shopIndex);
    
    totalShops++;
    
    printf("[SHOPS] Created shop ID %d at position (%.2f, %.2f, %.2f)", 
        shopInfo[shopIndex][shopId], x, y, z);
    
    return shopIndex;
}

/*
* Delete a shop
*/
DeleteShop(shopIndex)
{
    if(shopIndex < 0 || shopIndex >= totalShops) return 0;
    
    // Delete from database
    DeleteShopFromDatabase(shopInfo[shopIndex][shopId]);
    
    // Destroy actor
    DestroyShopActor(shopIndex);
    
    // Shift array
    for(new i = shopIndex; i < totalShops - 1; i++)
    {
        shopInfo[i] = shopInfo[i + 1];
    }
    
    totalShops--;
    
    printf("[SHOPS] Deleted shop ID %d", shopInfo[shopIndex][shopId]);
    return 1;
}

// ============================================================================
// SHOP INTERACTION
// ============================================================================

/*
* Get nearest shop to player
*/
GetNearestShop(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new interior = GetPlayerInterior(playerid);
    new virtualworld = GetPlayerVirtualWorld(playerid);
    
    for(new i = 0; i < totalShops; i++)
    {
        if(shopInfo[i][shopInterior] == interior && shopInfo[i][shopVirtualWorld] == virtualworld)
        {
            if(IsPlayerInRangeOfPoint(playerid, SHOP_INTERACTION_RANGE, 
                shopInfo[i][shopX], shopInfo[i][shopY], shopInfo[i][shopZ]))
            {
                return i;
            }
        }
    }
    
    return INVALID_SHOP_ID;
}

/*
* Show shop main menu
*/
ShowShopMenu(playerid, shopIndex)
{
    if(shopIndex < 0 || shopIndex >= totalShops) return 0;
    
    playerCurrentShop[playerid] = shopIndex;
    
    new dialog[128];
    strcat(dialog, "{FFFF00}Buy Items\n");
    strcat(dialog, "{00FF00}Sell Items\n");
    strcat(dialog, "{FF6B6B}Exit Shop");
    
    new title[64];
    format(title, sizeof(title), "Shop - What would you like to do? (Shop Money: $%d)", shopInfo[shopIndex][shopMoney]);
    
    Dialog_Show(playerid, DIALOG_SHOP_MAIN, DIALOG_STYLE_LIST, title, dialog, "Select", "Close");
    return 1;
}

/*
* Show shop buy menu
*/
ShowShopBuyMenu(playerid, shopIndex)
{
    if(shopIndex < 0 || shopIndex >= totalShops) return 0;
    
    new itemCount = 0;
    
    // Add header row first for TABLIST_HEADERS
    AddDialogListitem(playerid, "{FFFFFF}Item\t{00FF00}Price\t{FFFF00}Stock");
    
    for(new i = 1; i < MAX_ITEMS; i++)
    {
        if(shopInfo[shopIndex][shopInventory][i] > 0) // Item is sold in this shop
        {
            new line[128];
            format(line, sizeof(line), "%s\t{00FF00}$%d\t{FFFF00}%d",
                inventoryItems[i][itemNameSingular],
                inventoryItems[i][itemValue],
                shopInfo[shopIndex][shopInventory][i]
            );
            AddDialogListitem(playerid, line);
            itemCount++;
        }
    }
    
    if(itemCount == 0)
    {
        SendClientMessage(playerid, COLOR_RED, "This shop has no items for sale.");
        ShowShopMenu(playerid, shopIndex);
        return 0;
    }
    
    new title[64];
    format(title, sizeof(title), "Shop - Buy Items (Shop Money: $%d)", shopInfo[shopIndex][shopMoney]);
    
    ShowPlayerDialogPages(playerid, "ShowShopBuyMenuPages", DIALOG_STYLE_TABLIST_HEADERS, title, "Buy", "Back", 15);
    return 1;
}

/*
* Show shop sell menu
*/
ShowShopSellMenu(playerid, shopIndex)
{
    if(shopIndex < 0 || shopIndex >= totalShops) return 0;
    
    new itemCount = 0;
    new moneyItemId = ReturnItemIdByName("Money");
    
    // Add header row first for TABLIST_HEADERS
    AddDialogListitem(playerid, "{FFFFFF}Item\t{00FF00}Sell Price\t{FFFF00}You Have");
    
    for(new i = 1; i < MAX_ITEMS; i++)
    {
        // Skip Money item
        if(i == moneyItemId) continue;
        
        if(playerInventory[playerid][i] > 0) // Player has item
        {
            // Calculate sell price (50% of item value, minimum $1)
            new sellPrice = inventoryItems[i][itemValue] > 0 ? floatround(inventoryItems[i][itemValue] * 0.5) : 1;
            
            new line[128];
            format(line, sizeof(line), "%s\t{00FF00}$%d\t{FFFF00}%d",
                inventoryItems[i][itemNameSingular],
                sellPrice,
                playerInventory[playerid][i]
            );
            AddDialogListitem(playerid, line);
            itemCount++;
        }
    }
    
    if(itemCount == 0)
    {
        SendClientMessage(playerid, COLOR_RED, "You have no items to sell.");
        ShowShopMenu(playerid, shopIndex);
        return 0;
    }
    
    new title[64];
    format(title, sizeof(title), "Shop - Sell Items (Shop Money: $%d)", shopInfo[shopIndex][shopMoney]);
    
    ShowPlayerDialogPages(playerid, "ShowShopSellMenuPages", DIALOG_STYLE_TABLIST_HEADERS, title, "Sell", "Back", 15);
    return 1;
}

/*
* Process shop item purchase
*/
BuyShopItem(playerid, shopIndex, itemid, quantity = 0)
{
    if(shopIndex < 0 || shopIndex >= totalShops) return 0;
    if(itemid < 1 || itemid >= MAX_ITEMS) return 0;
    
    // Check if shop has stock
    if(shopInfo[shopIndex][shopInventory][itemid] < quantity)
    {
        SendClientMessage(playerid, COLOR_RED, "The shop doesn't have enough stock of this item.");
        return 0;
    }
    
    // Calculate total cost
    new totalCost = inventoryItems[itemid][itemValue] * quantity;
    
    // Check if player has enough money
    new moneyItemId = ReturnItemIdByName("Money");
    if(playerInventory[playerid][moneyItemId] < totalCost)
    {
        SendClientMessage(playerid, COLOR_RED, "You don't have enough money for this purchase.");
        return 0;
    }
    
    // Process transaction
    playerInventory[playerid][moneyItemId] -= totalCost;
    playerInventory[playerid][itemid] += quantity;
    shopInfo[shopIndex][shopInventory][itemid] -= quantity;
    shopInfo[shopIndex][shopMoney] += totalCost; // Shop gains money
    
    // Update database
    UpdateCharacterInventoryEntry(playerid, moneyItemId);
    UpdateCharacterInventoryEntry(playerid, itemid);
    UpdateShopInventoryInDatabase(shopIndex, itemid);
    UpdateShopMoneyInDatabase(shopIndex);
    
    // Send message
    new message[128];
    if(quantity == 1)
    {
        format(message, sizeof(message), "You purchased 1 %s for $%d.",
            inventoryItems[itemid][itemNameSingular], totalCost);
    }
    else
    {
        format(message, sizeof(message), "You purchased %d %s for $%d.",
            quantity, inventoryItems[itemid][itemNamePlural], totalCost);
    }
    SendClientMessage(playerid, COLOR_GREEN, message);
    
    return 1;
}

/*
* Process shop item sale
*/
SellShopItem(playerid, shopIndex, itemid, quantity = 1)
{
    if(shopIndex < 0 || shopIndex >= totalShops) return 0;
    if(itemid < 1 || itemid >= MAX_ITEMS) return 0;
    
    // Check if player has item
    if(playerInventory[playerid][itemid] < quantity)
    {
        SendClientMessage(playerid, COLOR_RED, "You don't have enough of this item.");
        return 0;
    }
    
    // Calculate sell price (50% of item value, minimum $1 per item)
    new sellPrice = inventoryItems[itemid][itemValue] > 0 ? floatround(inventoryItems[itemid][itemValue] * 0.5) : 1;
    new totalEarnings = sellPrice * quantity;
    
    // Check if shop has enough money
    if(shopInfo[shopIndex][shopMoney] < totalEarnings)
    {
        SendClientMessage(playerid, COLOR_RED, "The shop doesn't have enough money to buy your items.");
        return 0;
    }
    
    // Process transaction
    new moneyItemId = ReturnItemIdByName("Money");
    playerInventory[playerid][moneyItemId] += totalEarnings;
    playerInventory[playerid][itemid] -= quantity;
    shopInfo[shopIndex][shopInventory][itemid] += quantity;
    shopInfo[shopIndex][shopMoney] -= totalEarnings; // Shop loses money
    
    // Update database
    UpdateCharacterInventoryEntry(playerid, moneyItemId);
    UpdateCharacterInventoryEntry(playerid, itemid);
    UpdateShopInventoryInDatabase(shopIndex, itemid);
    UpdateShopMoneyInDatabase(shopIndex);
    
    // Send message
    new message[128];
    if(quantity == 1)
    {
        format(message, sizeof(message), "You sold 1 %s for $%d.",
            inventoryItems[itemid][itemNameSingular], totalEarnings);
    }
    else
    {
        format(message, sizeof(message), "You sold %d %s for $%d.",
            quantity, inventoryItems[itemid][itemNamePlural], totalEarnings);
    }
    SendClientMessage(playerid, COLOR_GREEN, message);
    
    return 1;
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/*
* Get shop index by ID
*/
GetShopIndexById(shopid)
{
    for(new i = 0; i < totalShops; i++)
    {
        if(shopInfo[i][shopId] == shopid)
            return i;
    }
    return INVALID_SHOP_ID;
}

#endif // MODULE_SHOPS_INCLUDED
