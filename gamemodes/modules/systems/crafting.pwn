// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - CRAFTING SYSTEM
// ============================================================================
/*
* MODULE: Crafting
* PURPOSE: Item crafting and recipe management system
* 
* DEPENDENCIES:
* - core/config.pwn
* - core/constants.pwn
* - core/player_data.pwn
* - core/database.pwn
* - systems/inventory.pwn
* 
* PUBLIC FUNCTIONS:
* - InitializeCraftingSystem() - Initialize and load all crafting recipes
* - LoadCraftingRecipes() - Load recipes from database
* - StartCrafting(playerid, recipeid) - Begin crafting process
* - CancelCrafting(playerid) - Cancel player's current crafting
* - PlayerHasRecipeItems(playerid, recipeid) - Check if player has required items
* - ShowCraftingMenu(playerid, category) - Display crafting menu to player
* 
* DESCRIPTION:
* Manages all crafting-related functionality including:
* - Recipe definitions and storage
* - Item combination and creation
* - Skill requirement checks
* - Crafting time management
* - Recipe discovery and filtering
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_CRAFTING_INCLUDED
#define MODULE_CRAFTING_INCLUDED

#define MAX_RECIPES             100     // Maximum number of crafting recipes
#define MAX_RECIPE_INPUTS       5       // Maximum input items per recipe
#define CRAFT_MENU_CATEGORY     0       // Show by category
#define CRAFT_MENU_ALL          1       // Show all recipes

// ============================================================================
// DATA STRUCTURES
// ============================================================================

/*
* Crafting Recipe Data
*/
enum E_RECIPE_DATA
{
    recipeId,
    recipeName[64],
    recipeDescription[128],
    recipeInputItem[MAX_RECIPE_INPUTS],        // Item IDs required
    recipeInputQty[MAX_RECIPE_INPUTS],         // Quantities required
    recipeOutputItem,                           // Item ID produced
    recipeOutputQty,                            // Quantity produced
    recipeSkillRequired,                        // Level requirement
    recipeCraftTime,                            // Time in milliseconds
    recipeCategory,                             // Category for filtering
    bool:recipeActive                           // Is this recipe enabled?
}

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

new CraftingRecipes[MAX_RECIPES][E_RECIPE_DATA];
new RecipeCount = 0;
new PlayerCraftingTimer[MAX_PLAYERS];
new PlayerCraftingRecipe[MAX_PLAYERS];

// ============================================================================
// FORWARD DECLARATIONS
// ============================================================================

// Crafting callbacks
forward OnPlayerFinishCraft(playerid, recipeid);
forward OnRecipesLoaded();

// ============================================================================
// CRAFTING MANAGEMENT FUNCTIONS
// ============================================================================

/*
* Initialize the crafting system and load recipes
*/
InitializeCraftingSystem()
{
    print("=====================================");
    print("Initializing Crafting System...");
    
    // Reset all recipes
    for(new i = 0; i < MAX_RECIPES; i++)
    {
        ResetRecipe(i);
    }
    
    // Load recipes from database or create defaults
    LoadCraftingRecipes();
    
    printf("Loaded %d crafting recipes", RecipeCount);
    print("=====================================");
    return 1;
}

/*
* Reset a recipe slot
*/
ResetRecipe(recipeid)
{
    if(recipeid < 0 || recipeid >= MAX_RECIPES)
        return 0;
        
    CraftingRecipes[recipeid][recipeId] = -1;
    CraftingRecipes[recipeid][recipeName][0] = EOS;
    CraftingRecipes[recipeid][recipeDescription][0] = EOS;
    
    for(new i = 0; i < MAX_RECIPE_INPUTS; i++)
    {
        CraftingRecipes[recipeid][recipeInputItem][i] = -1;
        CraftingRecipes[recipeid][recipeInputQty][i] = 0;
    }
    
    CraftingRecipes[recipeid][recipeOutputItem] = -1;
    CraftingRecipes[recipeid][recipeOutputQty] = 0;
    CraftingRecipes[recipeid][recipeSkillRequired] = 0;
    CraftingRecipes[recipeid][recipeCraftTime] = 0;
    CraftingRecipes[recipeid][recipeCategory] = 0;
    CraftingRecipes[recipeid][recipeActive] = false;
    
    return 1;
}

// ============================================================================
// DATABASE FUNCTIONS
// ============================================================================

/*
* Load crafting recipes from database
*/
LoadCraftingRecipes()
{
    // Load existing recipes from the database
    new query[256];
    mysql_format(database, query, sizeof(query),
        "SELECT * FROM `crafting_recipes` WHERE `active` = 1 ORDER BY `category`, `name`"
    );
    mysql_tquery(database, query, "OnRecipesLoaded");
    
    return 1;
}

/*
* Callback when recipes are loaded from database
*/
public OnRecipesLoaded()
{
    new rows = cache_num_rows();
    
    RecipeCount = 0;
    
    for(new i = 0; i < rows && RecipeCount < MAX_RECIPES; i++)
    {
        cache_get_value_name_int(i, "id", CraftingRecipes[RecipeCount][recipeId]);
        cache_get_value_name(i, "name", CraftingRecipes[RecipeCount][recipeName], 64);
        cache_get_value_name(i, "description", CraftingRecipes[RecipeCount][recipeDescription], 128);
        
        cache_get_value_name_int(i, "input_item1", CraftingRecipes[RecipeCount][recipeInputItem][0]);
        cache_get_value_name_int(i, "input_qty1", CraftingRecipes[RecipeCount][recipeInputQty][0]);
        cache_get_value_name_int(i, "input_item2", CraftingRecipes[RecipeCount][recipeInputItem][1]);
        cache_get_value_name_int(i, "input_qty2", CraftingRecipes[RecipeCount][recipeInputQty][1]);
        cache_get_value_name_int(i, "input_item3", CraftingRecipes[RecipeCount][recipeInputItem][2]);
        cache_get_value_name_int(i, "input_qty3", CraftingRecipes[RecipeCount][recipeInputQty][2]);
        cache_get_value_name_int(i, "input_item4", CraftingRecipes[RecipeCount][recipeInputItem][3]);
        cache_get_value_name_int(i, "input_qty4", CraftingRecipes[RecipeCount][recipeInputQty][3]);
        cache_get_value_name_int(i, "input_item5", CraftingRecipes[RecipeCount][recipeInputItem][4]);
        cache_get_value_name_int(i, "input_qty5", CraftingRecipes[RecipeCount][recipeInputQty][4]);
        
        cache_get_value_name_int(i, "output_item", CraftingRecipes[RecipeCount][recipeOutputItem]);
        cache_get_value_name_int(i, "output_qty", CraftingRecipes[RecipeCount][recipeOutputQty]);
        cache_get_value_name_int(i, "skill_required", CraftingRecipes[RecipeCount][recipeSkillRequired]);
        cache_get_value_name_int(i, "craft_time", CraftingRecipes[RecipeCount][recipeCraftTime]);
        cache_get_value_name_int(i, "category", CraftingRecipes[RecipeCount][recipeCategory]);
        
        CraftingRecipes[RecipeCount][recipeActive] = true;
        
        RecipeCount++;
    }
    
    return 1;
}

/*
* Add a recipe to the system (Admin use only - adds to database)
*/
AddRecipe(const name[], const desc[], 
    input1, qty1, input2, qty2, input3, qty3, input4, qty4, input5, qty5,
    output, outputQty, skillReq, craftTime, category)
{
    if(RecipeCount >= MAX_RECIPES)
        return -1;
    
    new recipeid = RecipeCount;
    
    CraftingRecipes[recipeid][recipeId] = recipeid;
    format(CraftingRecipes[recipeid][recipeName], 64, "%s", name);
    format(CraftingRecipes[recipeid][recipeDescription], 128, "%s", desc);
    
    CraftingRecipes[recipeid][recipeInputItem][0] = input1;
    CraftingRecipes[recipeid][recipeInputQty][0] = qty1;
    CraftingRecipes[recipeid][recipeInputItem][1] = input2;
    CraftingRecipes[recipeid][recipeInputQty][1] = qty2;
    CraftingRecipes[recipeid][recipeInputItem][2] = input3;
    CraftingRecipes[recipeid][recipeInputQty][2] = qty3;
    CraftingRecipes[recipeid][recipeInputItem][3] = input4;
    CraftingRecipes[recipeid][recipeInputQty][3] = qty4;
    CraftingRecipes[recipeid][recipeInputItem][4] = input5;
    CraftingRecipes[recipeid][recipeInputQty][4] = qty5;
    
    CraftingRecipes[recipeid][recipeOutputItem] = output;
    CraftingRecipes[recipeid][recipeOutputQty] = outputQty;
    CraftingRecipes[recipeid][recipeSkillRequired] = skillReq;
    CraftingRecipes[recipeid][recipeCraftTime] = craftTime;
    CraftingRecipes[recipeid][recipeCategory] = category;
    CraftingRecipes[recipeid][recipeActive] = true;
    
    RecipeCount++;
    
    // Insert into database
    new query[1024];
    mysql_format(database, query, sizeof(query),
        "INSERT INTO `crafting_recipes` (`name`, `description`, \
        `input_item1`, `input_qty1`, `input_item2`, `input_qty2`, \
        `input_item3`, `input_qty3`, `input_item4`, `input_qty4`, \
        `input_item5`, `input_qty5`, `output_item`, `output_qty`, \
        `skill_required`, `craft_time`, `category`, `active`) \
        VALUES ('%e', '%e', %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, 1)",
        name, desc, input1, qty1, input2, qty2, input3, qty3, input4, qty4,
        input5, qty5, output, outputQty, skillReq, craftTime, category
    );
    mysql_tquery(database, query);
    
    return recipeid;
}

// ============================================================================
// CRAFTING FUNCTIONS
// ============================================================================

/*
* Check if player has required items for recipe
*/
bool:PlayerHasRecipeItems(playerid, recipeid)
{
    if(recipeid < 0 || recipeid >= RecipeCount)
        return false;
    
    if(!CraftingRecipes[recipeid][recipeActive])
        return false;
    
    for(new i = 0; i < MAX_RECIPE_INPUTS; i++)
    {
        new itemid = CraftingRecipes[recipeid][recipeInputItem][i];
        new qty = CraftingRecipes[recipeid][recipeInputQty][i];
        
        if(itemid == -1 || qty == 0)
            continue;
        
        if(playerInventory[playerid][itemid] < qty)
            return false;
    }
    
    return true;
}

/*
* Remove recipe items from player inventory
*/
RemoveRecipeItems(playerid, recipeid)
{
    if(recipeid < 0 || recipeid >= RecipeCount)
        return 0;
    
    for(new i = 0; i < MAX_RECIPE_INPUTS; i++)
    {
        new itemid = CraftingRecipes[recipeid][recipeInputItem][i];
        new qty = CraftingRecipes[recipeid][recipeInputQty][i];
        
        if(itemid == -1 || qty == 0)
            continue;
        
        playerInventory[playerid][itemid] -= qty;
        
        if(playerInventory[playerid][itemid] < 0)
            playerInventory[playerid][itemid] = 0;
    }
    
    return 1;
}

/*
* Give crafted item to player
*/
GiveCraftedItem(playerid, recipeid)
{
    if(recipeid < 0 || recipeid >= RecipeCount)
        return 0;
    
    new itemid = CraftingRecipes[recipeid][recipeOutputItem];
    new qty = CraftingRecipes[recipeid][recipeOutputQty];
    
    if(itemid == -1)
        return 0;
    
    playerInventory[playerid][itemid] += qty;
    
    return 1;
}

/*
* Start crafting process
*/
StartCrafting(playerid, recipeid)
{
    if(recipeid < 0 || recipeid >= RecipeCount)
        return 0;
    
    if(!CraftingRecipes[recipeid][recipeActive])
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "This recipe is not available.");
        return 0;
    }
    
    // Check tinkerer skill level requirement
    if(player[playerid][tinkererSkillLevel] < CraftingRecipes[recipeid][recipeSkillRequired])
    {
        new string[128];
        format(string, sizeof(string), "You need tinkerer skill level %d to craft this item.", 
            CraftingRecipes[recipeid][recipeSkillRequired]);
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, string);
        return 0;
    }
    
    // Check if player has items
    if(!PlayerHasRecipeItems(playerid, recipeid))
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You don't have the required items.");
        return 0;
    }
    
    // Remove items from inventory
    RemoveRecipeItems(playerid, recipeid);
    
    // Start crafting timer
    PlayerCraftingRecipe[playerid] = recipeid;
    PlayerCraftingTimer[playerid] = SetTimerEx("OnPlayerFinishCraft", 
        CraftingRecipes[recipeid][recipeCraftTime], false, "dd", playerid, recipeid);
    
    // Send message
    new string[128];
    format(string, sizeof(string), "Crafting %s... Please wait %d seconds.", 
        CraftingRecipes[recipeid][recipeName], 
        CraftingRecipes[recipeid][recipeCraftTime] / 1000);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, string);
    
    // Apply animation
    ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 1, 0, 0, 0, CraftingRecipes[recipeid][recipeCraftTime]);
    
    return 1;
}

/*
* Finish crafting process
*/
public OnPlayerFinishCraft(playerid, recipeid)
{
    if(!IsPlayerConnected(playerid))
        return 0;
    
    PlayerCraftingTimer[playerid] = 0;
    
    // Give crafted item
    GiveCraftedItem(playerid, recipeid);
    
    // Clear animation
    ClearAnimations(playerid);
    
    // Send success message
    new string[128];
    format(string, sizeof(string), "You successfully crafted %dx %s!", 
        CraftingRecipes[recipeid][recipeOutputQty],
        inventoryItems[CraftingRecipes[recipeid][recipeOutputItem]][itemNameSingular]);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    // Award EXP for crafting (scales with skill requirement)
    new expReward = 3 + (CraftingRecipes[recipeid][recipeSkillRequired] * 2); // 3-13 EXP based on difficulty
    GivePlayerExp(playerid, expReward);
    
    return 1;
}

/*
* Cancel crafting if player disconnects or dies
*/
CancelCrafting(playerid)
{
    if(PlayerCraftingTimer[playerid] != 0)
    {
        KillTimer(PlayerCraftingTimer[playerid]);
        PlayerCraftingTimer[playerid] = 0;
        PlayerCraftingRecipe[playerid] = -1;
    }
    return 1;
}

// ============================================================================
// DIALOG FUNCTIONS
// ============================================================================

/*
* Show crafting menu to player
*/
ShowCraftingMenu(playerid, category = -1)
{
    new tmpRecipeName[128];
    
    // Clear any previous dialog list items
    ClearDialogListitems(playerid);
    
    new recipeAdded = 0;
    for(new i = 0; i < RecipeCount; i++)
    {
        if(!CraftingRecipes[i][recipeActive])
            continue;
        
        if(category != -1 && CraftingRecipes[i][recipeCategory] != category)
            continue;
        
        // Check if player can craft (has items and tinkerer skill level)
        new bool:canCraft = PlayerHasRecipeItems(playerid, i);
        new bool:hasSkillLevel = (player[playerid][tinkererSkillLevel] >= CraftingRecipes[i][recipeSkillRequired]);
        
        // Build recipe name with status
        if(canCraft && hasSkillLevel)
            format(tmpRecipeName, sizeof(tmpRecipeName), "{00FF00}%s", CraftingRecipes[i][recipeName]);
        else if(!hasSkillLevel)
            format(tmpRecipeName, sizeof(tmpRecipeName), "{FF0000}%s (Tinkerer Lvl %d)", 
                CraftingRecipes[i][recipeName], CraftingRecipes[i][recipeSkillRequired]);
        else
            format(tmpRecipeName, sizeof(tmpRecipeName), "{FFFF00}%s", CraftingRecipes[i][recipeName]);
        
        AddDialogListitem(playerid, tmpRecipeName);
        recipeAdded++;
    }
    
    if(recipeAdded == 0)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "No recipes available.");
        return 0;
    }
    
    ShowPlayerDialogPages(playerid, "ShowCraftingMenuPages", DIALOG_STYLE_LIST, "Crafting Menu", "View", "Close", 15);
    
    return 1;
}

/*
* Dialog handler for crafting menu (DialogPages callback)
*/
DialogPages:ShowCraftingMenuPages(playerid, response, listitem, string:inputtext[])
{
    if(!response)
        return 1;
    
    // Find the recipe at the selected listitem position
    new count = 0;
    for(new i = 0; i < RecipeCount; i++)
    {
        if(!CraftingRecipes[i][recipeActive])
            continue;
        
        if(count == listitem)
        {
            // Check if player has required tinkerer skill level
            if(player[playerid][tinkererSkillLevel] < CraftingRecipes[i][recipeSkillRequired])
            {
                new string[128];
                format(string, sizeof(string), "You need tinkerer skill level %d to craft this item.", 
                    CraftingRecipes[i][recipeSkillRequired]);
                SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, string);
                ShowCraftingMenu(playerid);
                return 1;
            }
            
            ShowRecipeDetails(playerid, i);
            return 1;
        }
        count++;
    }
    
    return 1;
}

/*
* Show recipe details to player
*/
ShowRecipeDetails(playerid, recipeid)
{
    if(recipeid < 0 || recipeid >= RecipeCount)
        return 0;
    
    new string[1024], line[128];
    format(string, sizeof(string), "{FFFFFF}%s\n\n{AAAAAA}%s\n\n{FFFF00}Required Items:\n", 
        CraftingRecipes[recipeid][recipeName],
        CraftingRecipes[recipeid][recipeDescription]);
    
    // List required items
    for(new i = 0; i < MAX_RECIPE_INPUTS; i++)
    {
        new itemid = CraftingRecipes[recipeid][recipeInputItem][i];
        new qty = CraftingRecipes[recipeid][recipeInputQty][i];
        
        if(itemid == -1 || qty == 0)
            continue;
        
        new playerHas = playerInventory[playerid][itemid];
        
        if(playerHas >= qty)
        {
            format(line, sizeof(line), "{00FF00}- %dx %s (You have: %d)\n", 
                qty, inventoryItems[itemid][itemNameSingular], playerHas);
        }
        else
        {
            format(line, sizeof(line), "{FF0000}- %dx %s (You have: %d)\n", 
                qty, inventoryItems[itemid][itemNameSingular], playerHas);
        }
        strcat(string, line);
    }
    
    // Output info
    format(line, sizeof(line), "\n{00FF00}Produces:\n- %dx %s\n\n", 
        CraftingRecipes[recipeid][recipeOutputQty],
        inventoryItems[CraftingRecipes[recipeid][recipeOutputItem]][itemNameSingular]);
    strcat(string, line);
    
    // Requirements
    format(line, sizeof(line), "{FFFFFF}Tinkerer Skill Required: %d\nCrafting Time: %d seconds", 
        CraftingRecipes[recipeid][recipeSkillRequired],
        CraftingRecipes[recipeid][recipeCraftTime] / 1000);
    strcat(string, line);
    
    // Store recipe ID in temp variable for confirmation
    player[playerid][chosenItemId] = recipeid;
    
    Dialog_Show(playerid, CraftingConfirm, DIALOG_STYLE_MSGBOX, "Recipe Details", string, "Craft", "Back");
    
    return 1;
}

/*
* Dialog handler for recipe confirmation
*/
Dialog:CraftingConfirm(playerid, response, listitem, string:inputtext[])
{
    if(!response)
    {
        ShowCraftingMenu(playerid);
        return 1;
    }
    
    new recipeid = player[playerid][chosenItemId];
    StartCrafting(playerid, recipeid);
    
    return 1;
}

// ============================================================================
// COMMANDS
// ============================================================================

CMD:craft(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");
    
    ShowCraftingMenu(playerid);
    return 1;
}

CMD:recipes(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");
    
    ShowCraftingMenu(playerid);
    return 1;
}

// Admin command to add recipes
CMD:addrecipe(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have permission to use this command.");
    
    new name[64], desc[128], input1, qty1, input2, qty2, input3, qty3, input4, qty4, input5, qty5;
    new output, outputQty, skillReq, craftTime, category;
    
    // Parse command parameters
    // Format: /addrecipe [name] [description] [input1] [qty1] [input2] [qty2] [input3] [qty3] [input4] [qty4] [input5] [qty5] [output] [outputQty] [skillReq] [craftTime] [category]
    if(sscanf(params, "p<|>s[64]s[128]ddddddddddddddd", 
        name, desc, input1, qty1, input2, qty2, input3, qty3, input4, qty4, input5, qty5, 
        output, outputQty, skillReq, craftTime, category))
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Usage: /addrecipe [name]|[description]|[input1]|[qty1]|[input2]|[qty2]|[input3]|[qty3]|[input4]|[qty4]|[input5]|[qty5]|[output]|[outputQty]|[skillReq]|[craftTime]|[category]");
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Use -1 for unused input slots. Use | as separator.");
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Example: /addrecipe Bandage|Craft a basic bandage|1|2|5|1|-1|0|-1|0|-1|0|10|1|0|5000|3");
        return 1;
    }
    
    // Validate output item
    if(output < 0 || output >= MAX_ITEMS)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid output item ID.");
        return 1;
    }
    
    // Validate at least one input item
    if(input1 == -1 && input2 == -1 && input3 == -1 && input4 == -1 && input5 == -1)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Recipe must have at least one input item.");
        return 1;
    }
    
    // Add the recipe
    new recipeid = AddRecipe(name, desc, 
        input1, qty1, input2, qty2, input3, qty3, input4, qty4, input5, qty5,
        output, outputQty, skillReq, craftTime, category);
    
    if(recipeid == -1)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Failed to add recipe. Maximum recipes reached.");
        return 1;
    }
    
    new string[128];
    format(string, sizeof(string), "Recipe '%s' added successfully! Recipe ID: %d", name, recipeid);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Recipe has been saved to the database and is now available.");
    
    return 1;
}

#endif // MODULE_CRAFTING_INCLUDED
