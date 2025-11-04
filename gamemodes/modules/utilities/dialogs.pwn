// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - DIALOGS MODULE
// ============================================================================
/*
* MODULE: Dialogs
* PURPOSE: All dialog callbacks and handlers using Emmet's dialog system
* 
* DEPENDENCIES:
* - easyDialog include (dialog callback system)
* - core/player_data.pwn (player arrays)
* - utilities/sql.pwn (database operations)
* - bcrypt (password hashing)
* 
* PUBLIC FUNCTIONS:
* - ShowPlayerMessageBox(playerid, title[], message[]) - General info dialog
* 
* DIALOG HANDLERS:
* ACCOUNT SYSTEM:
* - RegisterDialog - Account registration with password
* - EmailInputDialog - Email input for registration
* - LoginDialog - Account login with password verification
* - ChangePasswordDialog - Change password dialog
* - ConfirmPasswordDialog - Confirm new password
* 
* CHARACTER SYSTEM:
* - CharacterCreationDialog - Create new character
* 
* INVENTORY/ITEM SYSTEM:
* - UseFoodDialog - Food consumption
* - UseDrinkDialog - Drink consumption
* - UseMedicalDialog - Medical item usage
* - UseToolDialog - Tool item usage
* - UseAmmoDialog - Ammo selection
* 
* ADMIN SYSTEM:
* - AdminPanel - Main admin menu
* - AdminDeleteItemDialog - Delete items from player
* 
* CRAFTING SYSTEM:
* - CraftingDialog - Main crafting menu
* - CraftWeaponDialog - Weapon crafting
* - CraftRangedAmmoDialog - Ranged weapon ammo crafting
* - CraftMeleeDialog - Melee weapon crafting
* - CraftClothingDialog - Clothing crafting
* - CraftConsumableDialog - Consumable item crafting
* - CraftToolDialog - Tool crafting
* - CraftBarricadeDialog - Barricade crafting
* 
* VEHICLE SYSTEM:
* - VehicleMenuDialog - Vehicle interaction menu
* 
* BUILDING/MANAGEMENT:
* - ShowInteriorsDialog - Interior selection
* - ManageLootTableDialog - Loot table management
* - AddLootTableListDialog - Add loot table
* - ManageLootTableChanceDialog - Loot spawn chance management
* - ModifyLootChanceDialog - Modify loot spawn chances
* 
* MISCELLANEOUS:
* - GeneralMessageBox - Simple message display
* 
* DESCRIPTION:
* Centralized dialog management system using Emmet's easyDialog include.
* Handles all player interactions including registration, login, character
* creation, inventory management, crafting, admin tools, and more.
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_DIALOGS_INCLUDED
#define MODULE_DIALOGS_INCLUDED

// ============================================================================
// GENERAL MESSAGEBOX DIALOG
// ============================================================================

/*
* ShowPlayerMessageBox
* 
* Shows a general information dialog to a player
* 
* Parameters:
*   playerid - The player to show the dialog to
*   title[] - The dialog title
*   message[] - The dialog message/content
* 
* Usage:
*   ShowPlayerMessageBox(playerid, "Information", "This is an information message.");
*/
ShowPlayerMessageBox(playerid, const title[], const message[])
{
    Dialog_Show(playerid, GeneralMessageBox, DIALOG_STYLE_MSGBOX, title, message, "Close", "");
    return 1;
}

/*
* General MessageBox Dialog Handler
* Simple dialog that just closes when button is clicked
*/
Dialog:GeneralMessageBox(playerid, response, listitem, string:inputtext[])
{
    // Dialog closes automatically, no action needed
    return 1;
}

// ============================================================================
// ACCOUNT SYSTEM DIALOGS
// ============================================================================

Dialog:RegisterDialog(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return Kick(playerid);

	if (strlen(inputtext) <= 5) 
		return Dialog_Show(playerid, RegisterDialog, DIALOG_STYLE_PASSWORD, "Registration", "Your password must be longer than 5 characters!\nPlease enter your password in the field below:", "Register", "Abort");

    bcrypt_hash(playerid, "OnRegisterPasswordHash", inputtext, BCRYPT_COST);
	return 1;
}

Dialog:LoginDialog(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return Kick(playerid);

	bcrypt_verify(playerid, "OnPasswordVerify", inputtext, player[playerid][Password]);
	return 1;
}

Dialog:ChangePasswordDialog(playerid, response, listitem, string:inputtext[])
{
	if(!response) 
		return 1;

	if (strlen(inputtext) <= 5) 
		return Dialog_Show(playerid, ChangePasswordDialog, DIALOG_STYLE_PASSWORD, "Change Password", "Your password must be longer than 5 characters!\nPlease enter a new password below:", "Confirm", "Close");

    bcrypt_hash(playerid, "OnUserPasswordChange", inputtext, BCRYPT_COST);
	return 1;
}

// ============================================================================
// CHARACTER SYSTEM DIALOGS
// ============================================================================

Dialog:ChooseZombie(playerid, response, listitem, string:inputtext[])
{
	if(!response)
	{
		PopulateCharacterMenu(playerid);
		return 1;
	}

	if(listitem == 0) // human character
	{
		player[playerid][chosenZombie] = false;

		Dialog_Show(playerid, CreateCharName, DIALOG_STYLE_INPUT, "Character Name", "Enter your character's name (Firstname_Lastname) format.", "Confirm", "Back");
	}
	else // zombie character
	{
		player[playerid][chosenZombie] = true;

		Dialog_Show(playerid, CreateCharName, DIALOG_STYLE_INPUT, "Character Name", "Enter your character's name (Firstname_Lastname) format.", "Confirm", "Back");
	}
	return 1;
}

Dialog:CreateCharName(playerid, response, listitem, string:inputtext[])
{
	if(!response)
	{
		PopulateCharacterMenu(playerid);
		return 1;
	}

	format(player[playerid][chosenChar], MAX_PLAYER_NAME, "%s", inputtext);
	Dialog_Show(playerid, CreateCharDescription, DIALOG_STYLE_INPUT, "Character Description", "A brief description of your character.", "Confirm", "Back");
	return 1;
}

Dialog:CreateCharDescription(playerid, response, listitem, string:inputtext[])
{
	if(!response)
	{
		Dialog_Show(playerid, CreateCharName, DIALOG_STYLE_INPUT, "Character Name", "Enter your character's name (Firstname_Lastname) format.", "Confirm", "Back");
		return 1;
	}

	format(player[playerid][description], MAX_PLAYER_NAME, "%s", inputtext);

	if(!player[playerid][chosenZombie])
	{
		Dialog_Show(playerid, CreateCharAge, DIALOG_STYLE_INPUT, "Character Age", "How old is your character?", "Confirm", "Back");
	}
	else
	{
		ShowSkinModelMenu(playerid);
	}
	return 1;
}

Dialog:CreateCharAge(playerid, response, listitem, string:inputtext[])
{
	if(!response)
	{
		Dialog_Show(playerid, CreateCharDescription, DIALOG_STYLE_INPUT, "Character Description", "A brief description of your character.", "Confirm", "Back");
		return 1;
	}

	player[playerid][age] = strval(inputtext);
	ShowSkinModelMenu(playerid);
	return 1;
}

// ============================================================================
// INVENTORY SYSTEM DIALOGS
// ============================================================================

Dialog:InventoryMain(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return 1;

	switch(listitem)
	{
		case CATEGORY_GENERAL: ShowInventoryItemListByCategory(playerid, CATEGORY_GENERAL);
		case CATEGORY_FOOD: ShowInventoryItemListByCategory(playerid, CATEGORY_FOOD);
		case CATEGORY_DRINK: ShowInventoryItemListByCategory(playerid, CATEGORY_DRINK);
		case CATEGORY_MEDICAL: ShowInventoryItemListByCategory(playerid, CATEGORY_MEDICAL);
		case CATEGORY_WEAPONS: ShowInventoryItemListByCategory(playerid, CATEGORY_WEAPONS);
		case CATEGORY_AMMO: ShowInventoryItemListByCategory(playerid, CATEGORY_AMMO);
	}
	return 1;
}

Dialog:InventoryItemMain(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	format(player[playerid][chosenItem], 128, "%s", inputtext);

	/*
	* Set the chosen Item ID for future dialogs
	*/
	for(new i = 0, j = MAX_ITEMS; i < j; i++)
	{
		if(strcmp(player[playerid][chosenItem], inventoryItems[i][itemNameSingular]) == 0)
		{
			player[playerid][chosenItemId] = i;
		}
	}

	/*
	* Now show relevant dialog depending on item category
	*/
	switch(inventoryItems[player[playerid][chosenItemId]][itemCategory])
	{
		case CATEGORY_GENERAL: Dialog_Show(playerid, InventoryGeneralOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
		case CATEGORY_FOOD: Dialog_Show(playerid, InventoryFoodDrinkOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
		case CATEGORY_DRINK: Dialog_Show(playerid, InventoryFoodDrinkOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
		case CATEGORY_MEDICAL: Dialog_Show(playerid, InventoryMedicalOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
		case CATEGORY_WEAPONS: Dialog_Show(playerid, InventoryWeaponsOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nEquip\nUnequip", "Select", "Back");
		case CATEGORY_AMMO: Dialog_Show(playerid, InventoryAmmoOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop", "Select", "Back");
	}
	return 1;
}

Dialog:InventoryGeneralOpts(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	switch(listitem)
	{
		case 0:
		{
			SendClientMessage(playerid, COLOR_RP_PURPLE, "%s", inventoryItems[player[playerid][chosenItemId]][itemDescription]);
			Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
		}
		case 1: // give
		{
			Dialog_Show(playerid, InventoryGiveId, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		}
		case 2: // drop
		{
			Dialog_Show(playerid, InventoryDropAmount, DIALOG_STYLE_INPUT, "Input an amount to drop", "Input an amount of items you wish to drop.", "Confirm", "Go Back");
		}
		case 3: // use
		{
			new emptyCanteenId = ReturnItemIdByName("Empty Canteen");
			new dirtyWaterCanteenId = ReturnItemIdByName("Canteen of Dirty Water");
			new pureTabletId = ReturnItemIdByName("Purification Tablet");
			new waterCanteenId = ReturnItemIdByName("Canteen of Water");
			new fuelCanId = ReturnItemIdByName("Fuel Can");
			new scrapId = ReturnItemIdByName("Scrap");

			if(!inventoryItems[player[playerid][chosenItemId]][isUsable])
			{
				SendClientMessage(playerid, COLOR_RED, "This item is not usable from the inventory.");
				return 1;
			}

			if(player[playerid][chosenItemId] == emptyCanteenId)
			{
				if(!CA_IsPlayerNearWater(playerid))
				{
					SendClientMessage(playerid, COLOR_RED, "You are not near any water.");
					ShowInventoryItemListByCategory(playerid, CATEGORY_GENERAL);
					return 1;
				}

				RefillWaterCanteen(playerid, dirtyWaterCanteenId);
			}
			else if(player[playerid][chosenItemId] == pureTabletId)
			{
				if(playerInventory[playerid][dirtyWaterCanteenId] <= 0)
				{
					SendClientMessage(playerid, COLOR_RED, "YYou do not have any canteens of dirty water.");
					ShowInventoryItemListByCategory(playerid, CATEGORY_GENERAL);
					return 1;
				}
				
				playerInventory[playerid][player[playerid][chosenItemId]] = playerInventory[playerid][player[playerid][chosenItemId]] - 1;
				playerInventory[playerid][dirtyWaterCanteenId] = playerInventory[playerid][dirtyWaterCanteenId] - 1;
				playerInventory[playerid][waterCanteenId] = playerInventory[playerid][waterCanteenId] + 1;
                UpdateCharacterInventoryEntry(playerid, playerInventory[playerid][player[playerid][chosenItemId]]);
                UpdateCharacterInventoryEntry(playerid, playerInventory[playerid][dirtyWaterCanteenId]);
                UpdateCharacterInventoryEntry(playerid, playerInventory[playerid][waterCanteenId]);

				SendClientMessage(playerid, COLOR_GREEN, "You have used a purification tablet on some dirty water and have gained 1 clean canteen of water.");
				SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER, "puts a purification tablet into a water canteen.");
			}
			else if(player[playerid][chosenItemId] == fuelCanId)
			{
				Dialog_Show(playerid, FuelCanOptions, DIALOG_STYLE_LIST, "Select An Option", "Fill Can\nFill Vehicle", "Select", "Close");
			}
			else if(player[playerid][chosenItemId] == scrapId)
			{
                new string[128];
                new scrapRequired = ScrapRequiredToRepairVeh(playerid);
                
                GetVehiclePos(player[playerid][lastInVehId], player[playerid][tmpVehPos][0], player[playerid][tmpVehPos][1], player[playerid][tmpVehPos][2]);
                if(!IsPlayerInRangeOfPoint(playerid, 5.0, player[playerid][tmpVehPos][0], player[playerid][tmpVehPos][1], player[playerid][tmpVehPos][2]))
                {
                    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You are not close enough to your vehicle.");
                    Dialog_Show(playerid, InventoryGeneralOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
                    return 1;
                }
                
                if(scrapRequired == 0) // doesn't need repairing
                {
                    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You are not close enough to your vehicle.");
                    Dialog_Show(playerid, InventoryGeneralOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
                    return 1;
                }
                
                if(playerInventory[playerid][scrapId] < scrapRequired)
                {
                    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have enough scrap to perform this action.");
                    format(string, sizeof(string), "You require %d scrap to repair this vehicle.", scrapRequired);
                    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, string);
                    Dialog_Show(playerid, InventoryGeneralOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
                    return 1;
                }
                
                // has passed all the checks so ask the player whether they wish to fix their vehicle
                format(string, sizeof(string), "Would you like to try and fix your vehicle?\nIt will cost %d scrap.", scrapRequired);
				Dialog_Show(playerid, ScrapOptions, DIALOG_STYLE_MSGBOX, "Fix vehicle?", string, "Yes", "No");
			}
		}
	}
	return 1;
}

Dialog:FuelCanOptions(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	new fuelCanId = ReturnItemIdByName("Fuel Can");

	switch(listitem)
	{
		case 0: // fill fuel can
		{
			if(playerInventoryResource[playerid][fuelCanId] >= inventoryItems[fuelCanId][itemMaxResource])
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Your fuel can is already full.");
				Dialog_Show(playerid, InventoryGeneralOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			if(!IsPlayerAtFuelPump(playerid))
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You are not near a fuel pump.");
				Dialog_Show(playerid, InventoryGeneralOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You can only do this on foot.");
				Dialog_Show(playerid, InventoryGeneralOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			playerInventoryResource[playerid][fuelCanId] = inventoryItems[fuelCanId][itemMaxResource];
			SendClientMessage(playerid, COLOR_YELLOW, "You have filled your fuel can.");
		}
		case 1: // fill vehicle
		{
			if(playerInventoryResource[playerid][fuelCanId] <= 0)
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Your fuel can is empty.");
				Dialog_Show(playerid, InventoryGeneralOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			// get pos of vehicle the player was last in
    		GetVehiclePos(player[playerid][lastInVehId], player[playerid][tmpVehPos][0], player[playerid][tmpVehPos][1], player[playerid][tmpVehPos][2]);

			if(!IsPlayerInRangeOfPoint(playerid, 5.0, player[playerid][tmpVehPos][0], player[playerid][tmpVehPos][1], player[playerid][tmpVehPos][2]))
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You are not close enough to your vehicle.");
				Dialog_Show(playerid, InventoryGeneralOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			if(serverVehicle[player[playerid][lastInVehId]][isBeingFilled])
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "That vehicle is already being filled.");
				Dialog_Show(playerid, InventoryGeneralOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You can only do this on foot.");
				Dialog_Show(playerid, InventoryGeneralOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			serverVehicle[player[playerid][lastInVehId]][isBeingFilled] = true;
			ShowHudForPlayer(playerid, HUD_VEHICLE);
			player[playerid][fillVehicleTimer] = SetTimerEx("FillVehicleTimer", 1000, true, "ddd", playerid, player[playerid][lastInVehId], FILL_TYPE_FUELCAN);
		}
	}
	return 1;
}

Dialog:ScrapOptions(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	new scrapId = ReturnItemIdByName("Scrap");

	// get pos of vehicle the player was last in
	GetVehiclePos(player[playerid][lastInVehId], player[playerid][tmpVehPos][0], player[playerid][tmpVehPos][1], player[playerid][tmpVehPos][2]);

	if(!IsPlayerInRangeOfPoint(playerid, 5.0, player[playerid][tmpVehPos][0], player[playerid][tmpVehPos][1], player[playerid][tmpVehPos][2]))
	{
		SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You are not close enough to your vehicle.");
		Dialog_Show(playerid, InventoryGeneralOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
		return 1;
	}

	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
	{
		SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You can only do this on foot.");
		Dialog_Show(playerid, InventoryGeneralOpts, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
		return 1;
	}
    
    new scrapRequired = ScrapRequiredToRepairVeh(playerid);
    playerInventory[playerid][scrapId] = playerInventory[playerid][scrapId] - scrapRequired;
    RepairVehicle(player[playerid][lastInVehId]);
    
    // Award EXP for repairing vehicle
    GivePlayerExp(playerid, 5);
    
	return 1;
}

Dialog:InventoryFoodDrinkOpts(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	switch(listitem)
	{
		case 0:
		{
			SendClientMessage(playerid, COLOR_RP_PURPLE, "%s", inventoryItems[player[playerid][chosenItemId]][itemDescription]);
			Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
		}
		case 1: // give
		{
			Dialog_Show(playerid, InventoryGiveId, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		}
		case 2: // drop
		{
			Dialog_Show(playerid, InventoryDropAmount, DIALOG_STYLE_INPUT, "Input an amount to drop", "Input an amount of items you wish to drop.", "Confirm", "Go Back");
		}
		case 3: // use
		{
			if(inventoryItems[player[playerid][chosenItemId]][itemCategory] == CATEGORY_FOOD)
			{
				if(player[playerid][hunger] >= player[playerid][maxHunger])
				{
					SendClientMessage(playerid, COLOR_RED, "Your hunger is full so you do not need to use this item.");
					ShowInventoryItemListByCategory(playerid, CATEGORY_FOOD);
					return 1;
				}

				SendClientMessage(playerid, COLOR_RP_PURPLE, "You eat a %s.", inventoryItems[player[playerid][chosenItemId]][itemNameSingular]);
				player[playerid][hunger] = player[playerid][hunger] + inventoryItems[player[playerid][chosenItemId]][itemHealAmount];

				if(player[playerid][hunger] > player[playerid][maxHunger])
				{
					player[playerid][hunger] = player[playerid][maxHunger];
				}

				playerInventory[playerid][player[playerid][chosenItemId]] = playerInventory[playerid][player[playerid][chosenItemId]] - 1;
				UpdateHudElementForPlayer(playerid, HUD_HUNGER);
				ShowInventoryItemListByCategory(playerid, CATEGORY_FOOD);
			}
			else if(inventoryItems[player[playerid][chosenItemId]][itemCategory] == CATEGORY_DRINK)
			{
				if(player[playerid][thirst] >= player[playerid][maxThirst])
				{
					SendClientMessage(playerid, COLOR_RED, "Your thirst is full so you do not need to use this item.");
					ShowInventoryItemListByCategory(playerid, CATEGORY_DRINK);
					return 1;
				}

				SendClientMessage(playerid, COLOR_RP_PURPLE, "You drink a %s.", inventoryItems[player[playerid][chosenItemId]][itemNameSingular]);
				player[playerid][thirst] = player[playerid][thirst] + inventoryItems[player[playerid][chosenItemId]][itemHealAmount];

				if(player[playerid][thirst] > player[playerid][maxThirst])
				{
					player[playerid][thirst] = player[playerid][maxThirst];
				}

				playerInventory[playerid][player[playerid][chosenItemId]] = playerInventory[playerid][player[playerid][chosenItemId]] - 1;
				UpdateHudElementForPlayer(playerid, HUD_THIRST);
				ShowInventoryItemListByCategory(playerid, CATEGORY_DRINK);

				/*
				* Handle Water canteens
				*/
				new emptyCanteenItem = ReturnItemIdByName("Empty Canteen");
				new dirtyWaterItemId = ReturnItemIdByName("Canteen of Dirty Water");
				new waterCanteenItemId = ReturnItemIdByName("Canteen of Water");

				if(player[playerid][chosenItemId] == dirtyWaterItemId)
				{
					player[playerid][disease] = player[playerid][disease] - random(15) + 1;
					if(player[playerid][disease] <= 0)
					{
						player[playerid][disease] = 0;
					}
    				UpdateHudElementForPlayer(playerid, HUD_DISEASE);
					playerInventory[playerid][emptyCanteenItem] = playerInventory[playerid][emptyCanteenItem] + 1;
				}
				else if(player[playerid][chosenItemId] == waterCanteenItemId)
				{
					playerInventory[playerid][emptyCanteenItem] = playerInventory[playerid][emptyCanteenItem] + 1;
				}
			}
		}
	}
	return 1;
}

Dialog:InventoryMedicalOpts(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	switch(listitem)
	{
		case 0:
		{
			SendClientMessage(playerid, COLOR_RP_PURPLE, "%s", inventoryItems[player[playerid][chosenItemId]][itemDescription]);
			Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
		}
		case 1: // give
		{
			Dialog_Show(playerid, InventoryGiveId, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		}
		case 2: // drop
		{
			Dialog_Show(playerid, InventoryDropAmount, DIALOG_STYLE_INPUT, "Input an amount to drop", "Input an amount of items you wish to drop.", "Confirm", "Go Back");
		}
		case 3: // use
		{
			new antibioticItemId = ReturnItemIdByName("Antibiotic");

			if(player[playerid][chosenItemId] == antibioticItemId)
			{
				if(player[playerid][disease] >= player[playerid][maxDisease])
				{
					SendClientMessage(playerid, COLOR_RED, "You have no sickness or disease and do not need to use this item.");
					ShowInventoryItemListByCategory(playerid, CATEGORY_MEDICAL);
					return 1;
				}

				SendClientMessage(playerid, COLOR_RP_PURPLE, "You use a %s to heal some of your injuries.", inventoryItems[player[playerid][chosenItemId]][itemNameSingular]);
				player[playerid][disease] = player[playerid][disease] + inventoryItems[player[playerid][chosenItemId]][itemHealAmount];

				if(player[playerid][disease] >= player[playerid][maxDisease])
				{
					player[playerid][disease] = player[playerid][maxDisease];
				}

				playerInventory[playerid][player[playerid][chosenItemId]] = playerInventory[playerid][player[playerid][chosenItemId]] - 1;
				UpdateHudElementForPlayer(playerid, HUD_DISEASE);
				ShowInventoryItemListByCategory(playerid, CATEGORY_MEDICAL);
			}
			else
			{
				if(player[playerid][health] >= player[playerid][maxHealth])
				{
					SendClientMessage(playerid, COLOR_RED, "Your health is full so you do not need to use this item.");
					ShowInventoryItemListByCategory(playerid, CATEGORY_MEDICAL);
					return 1;
				}

				SendClientMessage(playerid, COLOR_RP_PURPLE, "You use a %s to heal some of your injuries.", inventoryItems[player[playerid][chosenItemId]][itemNameSingular]);
				player[playerid][health] = player[playerid][health] + inventoryItems[player[playerid][chosenItemId]][itemHealAmount];

				if(player[playerid][health] >= player[playerid][maxHealth])
				{
					player[playerid][health] = player[playerid][maxHealth];
				}

				playerInventory[playerid][player[playerid][chosenItemId]] = playerInventory[playerid][player[playerid][chosenItemId]] - 1;
				SetPlayerHealth(playerid, player[playerid][health]);
				UpdateHudElementForPlayer(playerid, HUD_HEALTH);
				ShowInventoryItemListByCategory(playerid, CATEGORY_MEDICAL);
			}
		}
	}
	return 1;
}

Dialog:InventoryWeaponsOpts(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	switch(listitem)
	{
		case 0:
		{
			SendClientMessage(playerid, COLOR_RP_PURPLE, "%s", inventoryItems[player[playerid][chosenItemId]][itemDescription]);
			Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
		}
		case 1: // give
		{
			Dialog_Show(playerid, InventoryGiveId, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		}
		case 2: // drop
		{
			Dialog_Show(playerid, InventoryDropAmount, DIALOG_STYLE_INPUT, "Input an amount to drop", "Input an amount of items you wish to drop.", "Confirm", "Go Back");
		}
		case 3: // equip
		{
			new tmpWepSlot = player[playerid][wepSlot][inventoryItems[player[playerid][chosenItemId]][itemWepSlot]];
			new tmpWepId = inventoryItems[player[playerid][chosenItemId]][itemWepId];
			if(tmpWepSlot == tmpWepId) // weapon is equipped
			{
				SendClientMessage(playerid, COLOR_RED, "You already have this weapon equipped.");
				ShowInventoryItemListByCategory(playerid, CATEGORY_WEAPONS);
				return 1;
			}

			SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_INVENTORY_EQUIP, inventoryItems[player[playerid][chosenItemId]][itemNameSingular]);

			if(inventoryItems[player[playerid][chosenItemId]][itemAmmoId] == DEFAULT_AMMO)
			{
				GivePlayerWeapon(playerid, inventoryItems[player[playerid][chosenItemId]][itemWepId], 1);
				UpdatePlayerWepslotEntry(inventoryItems[player[playerid][chosenItemId]][itemWepSlot], inventoryItems[player[playerid][chosenItemId]][itemWepId], player[playerid][chosenChar]);
			}
			else
			{
				if(playerInventory[playerid][inventoryItems[player[playerid][chosenItemId]][itemAmmoId]] < 1)
				{
					SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You do not have enough ammo for this weapon.");
				}
				else
				{
					RemoveWeaponFromSlot(playerid, inventoryItems[player[playerid][chosenItemId]][itemWepSlot]); // just in case they are changing from an Uzi to a Tec-9 with the same ammo
					player[playerid][wepSlot][inventoryItems[player[playerid][chosenItemId]][itemWepSlot]] = inventoryItems[player[playerid][chosenItemId]][itemWepId];
					GivePlayerWeapon(playerid, inventoryItems[player[playerid][chosenItemId]][itemWepId], playerInventory[playerid][inventoryItems[player[playerid][chosenItemId]][itemAmmoId]]);
					UpdatePlayerWepslotEntry(inventoryItems[player[playerid][chosenItemId]][itemWepSlot], inventoryItems[player[playerid][chosenItemId]][itemWepId], player[playerid][chosenChar]);
				}
			}
		}
		case 4: // unequip
		{
			new tmpWepSlot = player[playerid][wepSlot][inventoryItems[player[playerid][chosenItemId]][itemWepSlot]];
			new tmpWepId = inventoryItems[player[playerid][chosenItemId]][itemWepId];
			if(tmpWepSlot <= 0 || tmpWepSlot != tmpWepId) // weapon not equipped
			{
				SendClientMessage(playerid, COLOR_RED, "You do not currently have this weapon equipped.");
				ShowInventoryItemListByCategory(playerid, CATEGORY_WEAPONS);
				return 1;
			}

    		SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_INVENTORY_UNEQUIP, inventoryItems[player[playerid][chosenItemId]][itemNameSingular]);

			RemoveWeaponFromSlot(playerid, inventoryItems[player[playerid][chosenItemId]][itemWepSlot]);
			player[playerid][wepSlot][inventoryItems[player[playerid][chosenItemId]][itemWepSlot]] = WEAPON_FIST;
			UpdatePlayerWepslotEntry(inventoryItems[player[playerid][chosenItemId]][itemWepSlot], WEAPON_FIST, player[playerid][chosenChar]);
			ShowInventoryItemListByCategory(playerid, CATEGORY_WEAPONS);
		}
	}
	return 1;
}

Dialog:InventoryAmmoOpts(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	switch(listitem)
	{
		case 0:
		{
			SendClientMessage(playerid, COLOR_RP_PURPLE, "%s", inventoryItems[player[playerid][chosenItemId]][itemDescription]);
			Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
		}
		case 1: // give
		{
			Dialog_Show(playerid, InventoryGiveId, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		}
		case 2: // drop
		{
			Dialog_Show(playerid, InventoryDropAmount, DIALOG_STYLE_INPUT, "Input an amount to drop", "Input an amount of items you wish to drop.", "Confirm", "Go Back");
		}
	}
	return 1;
}

Dialog:InventoryGiveId(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	new id = strval(inputtext);
	if(!IsPlayerConnected(id) || IsPlayerNPC(id))
	{
		SendClientMessage(playerid, COLOR_RED, "You input an invalid player id.");
		Dialog_Show(playerid, InventoryGiveId, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		return 1;
	}

    player[playerid][invGivePlayerId] = id;
	Dialog_Show(playerid, InventoryGiveAmount, DIALOG_STYLE_INPUT, "Input an amount to give", "Input an amount of items you wish to give.", "Confirm", "Go Back");
	return 1;
}

Dialog:InventoryGiveAmount(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	if(!IsPlayerConnected(player[playerid][invGivePlayerId]) || IsPlayerNPC(player[playerid][invGivePlayerId]))
	{
		SendClientMessage(playerid, COLOR_RED, "You input an invalid player id.");
		Dialog_Show(playerid, InventoryGiveId, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		return 1;
	}

	new amount = strval(inputtext);
    
    if(amount < 1) // stops users entering values less than 1
    {
        SendClientMessage(playerid, COLOR_RED, "You cannot enter a value less than 1.");
		Dialog_Show(playerid, InventoryGiveAmount, DIALOG_STYLE_INPUT, "Input an amount to give", "Input an amount of items you wish to give.", "Confirm", "Go Back");
		return 1;
    }

	if(amount > playerInventory[playerid][player[playerid][chosenItemId]])
	{
		SendClientMessage(playerid, COLOR_RED, "You don't have that many %s to give. You only have %d in your inventory.", 
			inventoryItems[player[playerid][chosenItemId]][itemNamePlural], playerInventory[playerid][player[playerid][chosenItemId]]);
		Dialog_Show(playerid, InventoryGiveAmount, DIALOG_STYLE_INPUT, "Input an amount to give", "Input an amount of items you wish to give.", "Confirm", "Go Back");
		return 1;
	}

	playerInventory[player[playerid][invGivePlayerId]][player[playerid][chosenItemId]] = playerInventory[player[playerid][invGivePlayerId]][player[playerid][chosenItemId]] + amount;
	SendClientMessage(player[playerid][invGivePlayerId], COLOR_RP_PURPLE, "You were given %d %s from %s.", amount, inventoryItems[player[playerid][chosenItemId]][itemNamePlural], player[playerid][chosenChar]);

	playerInventory[playerid][player[playerid][chosenItemId]] = playerInventory[playerid][player[playerid][chosenItemId]] - amount;
	SendClientMessage(playerid, COLOR_RP_PURPLE, "You gave %s %d %s.", player[player[playerid][invGivePlayerId]][chosenChar], amount, inventoryItems[player[playerid][chosenItemId]][itemNamePlural]);

	Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
	return 1;
}

Dialog:InventoryDropAmount(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	new amount = strval(inputtext);
    
    if(amount < 1) // stops users entering values less than 1
    {
        SendClientMessage(playerid, COLOR_RED, "You cannot enter a value less than 1.");
		Dialog_Show(playerid, InventoryGiveAmount, DIALOG_STYLE_INPUT, "Input an amount to give", "Input an amount of items you wish to give.", "Confirm", "Go Back");
		return 1;
    }

	if(amount > playerInventory[playerid][player[playerid][chosenItemId]])
	{
		SendClientMessage(playerid, COLOR_RED, "You don't have that many %s to drop. You only have %d in your inventory.", 
			inventoryItems[player[playerid][chosenItemId]][itemNamePlural], playerInventory[playerid][player[playerid][chosenItemId]]);
		Dialog_Show(playerid, InventoryDropAmount, DIALOG_STYLE_INPUT, "Input an amount to drop", "Input an amount of items you wish to drop.", "Confirm", "Go Back");
		return 1;
	}

	playerInventory[playerid][player[playerid][chosenItemId]] = playerInventory[playerid][player[playerid][chosenItemId]] - amount;
	SendClientMessage(playerid, COLOR_RED, "You dropped %d %s.", amount, inventoryItems[player[playerid][chosenItemId]][itemNamePlural]);

	Dialog_Show(playerid, InventoryMain, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
	return 1;
}

// ============================================================================
// INTERIOR MANAGEMENT DIALOGS
// ============================================================================

Dialog:InteriorOptions(playerid, response, listitem, string:inputtext[])
{
	if(!response)
		return 1;

	switch(listitem)
	{
		case 0: // change interior name
		{
			Dialog_Show(playerid, InteriorSetName, DIALOG_STYLE_INPUT, "Interior Name", "Input an updated name of the interior.", "Confirm", "Close");
		}
		case 1: // set virtual world
		{
			Dialog_Show(playerid, InteriorSetVirWorld, DIALOG_STYLE_INPUT, "Interior Virtual World", "Input a new virtual world ID for this interior.", "Confirm", "Close");
		}
		case 2: // delete
		{
			Dialog_Show(playerid, InteriorDeleteQuestion, DIALOG_STYLE_MSGBOX, "Delete Interior", "Are you sure you wish to delete this interior? You cannot recover it without recreating it.", "Yes", "No");
		}
	}
	return 1;
}

Dialog:InteriorSetName(playerid, response, listitem, string:inputtext[])
{
	if(!response) // don't change
		return 1;

	new string[128];
	format(string, sizeof(string), "%s Options", player[playerid][tmpIntName]);

	if(strlen(inputtext) > 64)
	{
		SendClientMessage(playerid, COLOR_RED, "Name input was too long, please try a shorter name. 64 characters maximum.");
		Dialog_Show(playerid, InteriorOptions, DIALOG_STYLE_LIST, string, "Change Name\nSet Virtual World\nSet Map Icon\nDelete", "Select", "Close");
		return 1;
	}

	// update the interior name entry
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "UPDATE `interiors` SET `name` = '%e' WHERE `name` = '%e'", inputtext, player[playerid][tmpIntName]);
    mysql_tquery(database, query);
    
	SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You updated the interior name.");
	return 1;
}

Dialog:InteriorSetVirWorld(playerid, response, listitem, string:inputtext[])
{
	if(!response) // don't change
		return 1;

	new string[128];
	format(string, sizeof(string), "%s Options", player[playerid][tmpIntName]);

	if(strval(inputtext) < 1000 || strval(inputtext) > 2147483647)
	{
		SendClientMessage(playerid, COLOR_RED, "Invalid Virtual world. Values between 1000 - 2147483647 only.");
		Dialog_Show(playerid, InteriorOptions, DIALOG_STYLE_LIST, string, "Change Name\nSet Virtual World\nSet Map Icon\nDelete", "Select", "Close");
		return 1;
	}

	// update the virtual world entry
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "UPDATE `interiors` SET `virworld` = %d WHERE `name` = '%e'", strval(inputtext), player[playerid][tmpIntName]);
    mysql_tquery(database, query, "OnInteriorVirWorldUpdated", "ds", playerid, player[playerid][tmpIntName]);
    
	return 1;
}

forward OnInteriorVirWorldUpdated(playerid, const intname[]);
public OnInteriorVirWorldUpdated(playerid, const intname[])
{
    new queryCheck[256];
    mysql_format(database, queryCheck, sizeof(queryCheck), 
        "SELECT `id`, `virworld` FROM `interiors` WHERE `name` = '%e'", intname);
    mysql_tquery(database, queryCheck, "OnInteriorVirWorldData", "ds", playerid, intname);
    return 1;
}

forward OnInteriorVirWorldData(playerid, const intname[]);
public OnInteriorVirWorldData(playerid, const intname[])
{
    new tmpIntId;
    if(cache_num_rows() > 0)
    {
        cache_get_value_name_int(0, "id", tmpIntId);
        cache_get_value_name_int(0, "virworld", srvInterior[tmpIntId][intVirWorld]);
    }

	// destroy the old pickups
	DestroyDynamicPickup(interiorEnterPickup[tmpIntId]);
	DestroyDynamicPickup(interiorExitPickup[tmpIntId]);

	// create new pickups
	interiorEnterPickup[tmpIntId] = CreateDynamicPickup(1318, 1, srvInterior[tmpIntId][intEnter][0], srvInterior[tmpIntId][intEnter][1], srvInterior[tmpIntId][intEnter][2], 
		srvInterior[tmpIntId][intExitVirWorld], srvInterior[tmpIntId][intExitWorld]);
	interiorExitPickup[tmpIntId] = CreateDynamicPickup(1318, 1, srvInterior[tmpIntId][intExit][0], srvInterior[tmpIntId][intExit][1], srvInterior[tmpIntId][intExit][2], 
		srvInterior[tmpIntId][intVirWorld], srvInterior[tmpIntId][intWorld]);

	// let the user know
	SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You updated the interior virtual world.");
	return 1;
}

Dialog:InteriorDeleteQuestion(playerid, response, listitem, string:inputtext[])
{
	if(!response) // don't delete
		return 1;

	// Get the interior ID and delete it
    new query[256];
    mysql_format(database, query, sizeof(query), 
        "SELECT `id` FROM `interiors` WHERE `name` = '%e'", player[playerid][tmpIntName]);
    mysql_tquery(database, query, "OnInteriorDeleteData", "ds", playerid, player[playerid][tmpIntName]);
	return 1;
}

forward OnInteriorDeleteData(playerid, const intname[]);
public OnInteriorDeleteData(playerid, const intname[])
{
    new tmpIntId;
    if(cache_num_rows() > 0)
    {
        cache_get_value_name_int(0, "id", tmpIntId);
    }

	// destroy the old pickups
	DestroyDynamicPickup(interiorEnterPickup[tmpIntId]);
	DestroyDynamicPickup(interiorExitPickup[tmpIntId]);

	/*
	* Now Delete interior from the table
	*/
    new query[256];
    mysql_format(database, query, sizeof(query), "DELETE FROM `interiors` WHERE `name` = '%e'", intname);
    mysql_tquery(database, query);

	SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You deleted the interior.");
	return 1;
}

/*
* Loot tables
*/
Dialog:EditLootTableChanceNode(playerid, response, listitem, string:inputtext[])
{   
    if(!response)
        return 1;
        
    if(strval(inputtext) < 0 || strval(inputtext) > MAX_ITEMS - 1)
    {
        SendClientMessage(playerid, COLOR_RED, "Invalid item ID. Values between 0 & %d only.", MAX_ITEMS - 1);
        Dialog_Show(playerid, EditLootTableChanceNode, DIALOG_STYLE_INPUT, "Loot Table Chance Node", "Input a valid item ID for this node. It will then be added to the loot table.", "Confirm", "Back");
        return 1;
    }
    
    UpdateLootTableEntry(player[playerid][admChosenTableName], player[playerid][admChosenTableId], player[playerid][admChosenChanceNode], strval(inputtext));
    PopulateLootTableList(playerid);
    return 1;
}

/*
* Paged Dialogs
*/
DialogPages:ShowInteriorsDialog(playerid, response, listitem, inputtext[])
{
	if(!response)
		return 1;

	new string[128];
    format(player[playerid][tmpIntName], 64, "%s", inputtext);
	format(string, sizeof(string), "%s Options", inputtext);
	Dialog_Show(playerid, InteriorOptions, DIALOG_STYLE_LIST, string, "Change Name\nSet Virtual World\nDelete", "Select", "Close");
	return 1;
}

DialogPages:ShowLootTableAdminList(playerid, response, listitem, inputtext[])
{
	if(!response)
		return 1;

    player[playerid][admChosenTableId] = listitem;
	format(player[playerid][admChosenTableName], 32, "%s", inputtext);
    PopulateLootTableChanceList(playerid, player[playerid][admChosenTableName]);
	return 1;
}

DialogPages:ShowLootTableChanceList(playerid, response, listitem, inputtext[])
{
	if(!response)
		return 1;

	player[playerid][admChosenChanceNode] = listitem;
    Dialog_Show(playerid, EditLootTableChanceNode, DIALOG_STYLE_INPUT, "Loot Table Chance Node", "Input a valid item ID for this node. It will then be added to the loot table.", "Confirm", "Back");
	return 1;
}

/*
* Dynamic Dialog Functions
*/
ShowInventoryItemListByCategory(playerid, category)
{
	new invString[1024], string[128], itemQuantity[10];

	switch(category)
	{
		case CATEGORY_GENERAL:
		{
			format(string, sizeof string, "%s's General Items", player[playerid][chosenChar]);
    		format(invString, sizeof invString, "Item Name\tQuantity\n");

			for(new i = 1; i < MAX_ITEMS; i++) // valid item ids start from 1 not 0
			{
				if(playerInventory[playerid][i] >= 1 && inventoryItems[i][itemCategory] == CATEGORY_GENERAL)
				{
					strcat(invString, inventoryItems[i][itemNameSingular]);
					strcat(invString, "\t");
					format(itemQuantity, sizeof itemQuantity, "%d", playerInventory[playerid][i]);
					strcat(invString, itemQuantity);
					strcat(invString, "\n");
				}
			}

			Dialog_Show(playerid, InventoryItemMain, DIALOG_STYLE_TABLIST, string, invString, "Select", "Go Back");
		}
		case CATEGORY_FOOD:
		{
			format(string, sizeof string, "%s's Food Items", player[playerid][chosenChar]);
			format(invString, sizeof invString, "Item Name\tQuantity\n");

			for(new i = 1; i < MAX_ITEMS; i++) // valid item ids start from 1 not 0
			{
				if(playerInventory[playerid][i] >= 1 && inventoryItems[i][itemCategory] == CATEGORY_FOOD)
				{
					strcat(invString, inventoryItems[i][itemNameSingular]);
					strcat(invString, "\t");
					format(itemQuantity, sizeof itemQuantity, "%d", playerInventory[playerid][i]);
					strcat(invString, itemQuantity);
					strcat(invString, "\n");
				}
			}

			Dialog_Show(playerid, InventoryItemMain, DIALOG_STYLE_TABLIST, string, invString, "Select", "Go Back");
		}
		case CATEGORY_DRINK:
		{
			format(string, sizeof string, "%s's Drink Items", player[playerid][chosenChar]);
			format(invString, sizeof invString, "Item Name\tQuantity\n");

			for(new i = 1; i < MAX_ITEMS; i++) // valid item ids start from 1 not 0
			{
				if(playerInventory[playerid][i] >= 1 && inventoryItems[i][itemCategory] == CATEGORY_DRINK)
				{
					strcat(invString, inventoryItems[i][itemNameSingular]);
					strcat(invString, "\t");
					format(itemQuantity, sizeof itemQuantity, "%d", playerInventory[playerid][i]);
					strcat(invString, itemQuantity);
					strcat(invString, "\n");
				}
			}

			Dialog_Show(playerid, InventoryItemMain, DIALOG_STYLE_TABLIST, string, invString, "Select", "Go Back");
		}
		case CATEGORY_MEDICAL:
		{
			format(string, sizeof string, "%s's Medical Items", player[playerid][chosenChar]);
			format(invString, sizeof invString, "Item Name\tQuantity\n");

			for(new i = 1; i < MAX_ITEMS; i++) // valid item ids start from 1 not 0
			{
				if(playerInventory[playerid][i] >= 1 && inventoryItems[i][itemCategory] == CATEGORY_MEDICAL)
				{
					strcat(invString, inventoryItems[i][itemNameSingular]);
					strcat(invString, "\t");
					format(itemQuantity, sizeof itemQuantity, "%d", playerInventory[playerid][i]);
					strcat(invString, itemQuantity);
					strcat(invString, "\n");
				}
			}

			Dialog_Show(playerid, InventoryItemMain, DIALOG_STYLE_TABLIST, string, invString, "Select", "Go Back");
		}
		case CATEGORY_WEAPONS:
		{
			format(string, sizeof string, "%s's Weapons", player[playerid][chosenChar]);
			format(invString, sizeof invString, "Item Name\tQuantity\n");

			for(new i = 1; i < MAX_ITEMS; i++) // valid item ids start from 1 not 0
			{
				if(playerInventory[playerid][i] >= 1 && inventoryItems[i][itemCategory] == CATEGORY_WEAPONS)
				{
					strcat(invString, inventoryItems[i][itemNameSingular]);
					strcat(invString, "\t");
					format(itemQuantity, sizeof itemQuantity, "%d", playerInventory[playerid][i]);
					strcat(invString, itemQuantity);
					strcat(invString, "\n");
				}
			}

			Dialog_Show(playerid, InventoryItemMain, DIALOG_STYLE_TABLIST, string, invString, "Select", "Go Back");
		}
		case CATEGORY_AMMO:
		{
			format(string, sizeof string, "%s's Ammo", player[playerid][chosenChar]);
			format(invString, sizeof invString, "Item Name\tQuantity\n");

			for(new i = 1; i < MAX_ITEMS; i++) // valid item ids start from 1 not 0
			{
				if(playerInventory[playerid][i] >= 1 && inventoryItems[i][itemCategory] == CATEGORY_AMMO)
				{
					strcat(invString, inventoryItems[i][itemNameSingular]);
					strcat(invString, "\t");
					format(itemQuantity, sizeof itemQuantity, "%d", playerInventory[playerid][i]);
					strcat(invString, itemQuantity);
					strcat(invString, "\n");
				}
			}

			Dialog_Show(playerid, InventoryItemMain, DIALOG_STYLE_TABLIST, string, invString, "Select", "Go Back");
		}
	}
	return 1;
}

/*
* eSelection Dialog Functions
*/
ShowSkinModelMenu(playerid)
{
    // create a dynamic PawnPlus list to populate with models.
    // you don't need to worry about deleting this list, it's handled by the include once it's passed to it
    new List:skins = list_new();

	if(!player[playerid][chosenZombie])
	{
		// add all the default SA-MP skins
		for(new i = 0; i < 311; i++)
		{
			if(i != 74)
			{
				AddModelMenuItem(skins, i);
			}
		}
	}
	else
	{
		// Zombie skins
		// taken from Zombie Andreas mod
		// https://libertycity.net/files/gta-san-andreas/185232-modeli-personazhejj-zombi.html
		for(new i = 20001; i < 20240; i++)
		{
			AddModelMenuItem(skins, i);
		}
	}

    // show the menu to the player
    ShowModelSelectionMenu(playerid, "Select Your Skin", MODEL_SELECTION_SKIN_MENU, skins);
	return 1;
}

public OnModelSelectionResponse(playerid, extraid, index, modelid, response)
{
    // make sure the extraid matches the skin menu ID
    if(extraid == MODEL_SELECTION_SKIN_MENU)
    {
        // make sure the player actually clicked on a model and not the close button
        if(response == MODEL_RESPONSE_SELECT)
        {
			player[playerid][skin] = modelid;

			if(!player[playerid][chosenZombie])
			{
				player[playerid][iszombie] = 0;
			}
			else
			{
				player[playerid][iszombie] = 1;
			}

			/*
			* Insert character into the database
			*/
			if(player[playerid][iszombie] == 0)
			{
                new query[512];
                mysql_format(database, query, sizeof(query),
                    "INSERT INTO `characters` (`owner`, `name`, `age`, `description`, `skin`, `iszombie`) VALUES (%d, '%e', %d, '%e', %d, %d)",
                    player[playerid][ID], player[playerid][chosenChar], player[playerid][age], player[playerid][description], 
                    player[playerid][skin], player[playerid][iszombie]
                );
                mysql_tquery(database, query, "OnCharacterCreatedInDialog", "d", playerid);
			}
			else
			{
                new query[512];
                mysql_format(database, query, sizeof(query),
                    "INSERT INTO `characters` (`owner`, `name`, `age`, `description`, `skin`, `iszombie`, `health`, `maxhealth`) VALUES (%d, '%e', %d, '%e', %d, %d, 200.0, 200.0)",
                    player[playerid][ID], player[playerid][chosenChar], player[playerid][age], player[playerid][description], 
                    player[playerid][skin], player[playerid][iszombie]
                );
                mysql_tquery(database, query);
			}

			SetTimerEx("DelayedShowCharacterMenu", 500, false, "d", playerid);
            return 1;
        }
		else
		{
			if(!player[playerid][chosenZombie])
			{
				Dialog_Show(playerid, CreateCharAge, DIALOG_STYLE_INPUT, "Character Age", "How old is your character?", "Confirm", "Back");
			}
			else
			{
				Dialog_Show(playerid, CreateCharDescription, DIALOG_STYLE_INPUT, "Character Description", "A brief description of your character.", "Confirm", "Back");
			}
		}
    }
    else if(extraid == CHARACTER_SELECTION_SKIN_MENU)
    {
        if(response == MODEL_RESPONSE_SELECT)
        {
            if(index == 0) // create character index
            {
                if(player[playerid][characterCount] >= MAX_CHARACTERS + 1) // +1 for the empty create character slot
                {
                    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You have reached the maximum character count, please delete one to be able to create another.");
                    PopulateCharacterMenu(playerid);
                    return 1;
                }
                else
                {
                    Dialog_Show(playerid, ChooseZombie, DIALOG_STYLE_LIST, "Human or Zombie?", "Human\nZombie", "Confirm", "Back");
                }
            }
            else // a character has been selected
            {
                new query[256];
                mysql_format(database, query, sizeof(query), 
                    "SELECT `name` FROM `characters` WHERE `owner` = %d AND `skin` = %d", 
                    player[playerid][ID], modelid);
                mysql_tquery(database, query, "OnCharacterSelectedBySkin", "d", playerid);
            }
        }
        else
        {
            return Kick(playerid);
        }
    }
	return 1;
}

forward OnCharacterCreatedInDialog(playerid);
public OnCharacterCreatedInDialog(playerid)
{
    /*
    * Create character's inventory entry
    */
    CreateCharacterInventory(playerid);
    return 1;
}

forward OnCharacterSelectedBySkin(playerid);
public OnCharacterSelectedBySkin(playerid)
{
    if(cache_num_rows() > 0)
    {
        cache_get_value_name(0, "name", player[playerid][chosenChar], MAX_PLAYER_NAME);
    }
    
    /*
    * Now load the player's character data and spawn them
    * This will be replaced with a new menu which allows for character editing and deletion eventually
    */
    OnPlayerCharacterDataLoaded(playerid);
    return 1;
}

/*
* Creation of an item
*/
Dialog:CreateItemSName(playerid, response, listitem, string:inputtext[])
{
    if(!response)
        return 1;
        
    if(strlen(inputtext) > 128)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Name cannot be more than 128 characters.");
        Dialog_Show(playerid, CreateItemSName, DIALOG_STYLE_INPUT, "Create Item: Name (Singular)", "Enter the item's singular name.", "Confirm", "Back");
        return 1;
    }
    
    new tmpItemId = serverItemCount + 1;
    inventoryItems[tmpItemId][itemId] = tmpItemId;
    format(inventoryItems[tmpItemId][itemNameSingular], 128, "%s", inputtext);
    Dialog_Show(playerid, CreateItemPName, DIALOG_STYLE_INPUT, "Create Item: Name (Plural)", "Enter the item's plural name.", "Confirm", "Back");
    return 1;
}

Dialog:CreateItemPName(playerid, response, listitem, string:inputtext[])
{
    if(!response)
        return 1;
    
    if(strlen(inputtext) > 128)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Name cannot be more than 128 characters.");
        Dialog_Show(playerid, CreateItemPName, DIALOG_STYLE_INPUT, "Create Item: Name (Plural)", "Enter the item's plural name.", "Confirm", "Back");
        return 1;
    }
    
    new tmpItemId = serverItemCount + 1;
    format(inventoryItems[tmpItemId][itemNamePlural], 128, "%s", inputtext);
    Dialog_Show(playerid, CreateItemDescription, DIALOG_STYLE_INPUT, "Create Item: Description", "Enter the item's description.", "Confirm", "Back");
    return 1;
}

Dialog:CreateItemDescription(playerid, response, listitem, string:inputtext[])
{
    if(!response)
        return 1;
        
    if(strlen(inputtext) > 128)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Description cannot be more than 128 characters.");
        Dialog_Show(playerid, CreateItemPName, DIALOG_STYLE_INPUT, "Create Item: Description", "Enter the item's description.", "Confirm", "Back");
        return 1;
    }
    
    new tmpItemId = serverItemCount + 1;
    format(inventoryItems[tmpItemId][itemDescription], 128, "%s", inputtext);
    Dialog_Show(playerid, CreateItemCategory, DIALOG_STYLE_INPUT, "Create Item: Category", "Enter the item's category ID.", "Confirm", "Back");
    return 1;
}

Dialog:CreateItemCategory(playerid, response, listitem, string:inputtext[])
{
    if(!response)
        return 1;
    
    if(strval(inputtext) < 0)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Value cannot be below 0.");
        Dialog_Show(playerid, CreateItemCategory, DIALOG_STYLE_INPUT, "Create Item: Category", "Enter the item's category ID.", "Confirm", "Back");
        return 1;
    }
    
    new tmpItemId = serverItemCount + 1;
    inventoryItems[tmpItemId][itemCategory] = strval(inputtext);
    Dialog_Show(playerid, CreateItemHealAmount, DIALOG_STYLE_INPUT, "Create Item: Heal Amount", "Enter the amount this item heals (-1 for non use).", "Confirm", "Back");
    return 1;
}

Dialog:CreateItemHealAmount(playerid, response, listitem, string:inputtext[])
{
    if(!response)
        return 1;
    
    if(strval(inputtext) < -1)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Value cannot be below -1.");
        Dialog_Show(playerid, CreateItemHealAmount, DIALOG_STYLE_INPUT, "Create Item: Heal Amount", "Enter the amount this item heals (-1 for non use).", "Confirm", "Back");
        return 1;
    }
    
    new tmpItemId = serverItemCount + 1;
    inventoryItems[tmpItemId][itemHealAmount] = strval(inputtext);
    Dialog_Show(playerid, CreateItemWepId, DIALOG_STYLE_INPUT, "Create Item: Weapon ID", "Enter this item's weapon ID (-1 if not a weapon).", "Confirm", "Back");
    return 1;
}

Dialog:CreateItemWepId(playerid, response, listitem, string:inputtext[])
{
    if(!response)
        return 1;
    
    if(strval(inputtext) < -1)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Value cannot be below -1.");
        Dialog_Show(playerid, CreateItemWepId, DIALOG_STYLE_INPUT, "Create Item: Weapon ID", "Enter this item's weapon ID (-1 if not a weapon).", "Confirm", "Back");
        return 1;
    }
    
    new tmpItemId = serverItemCount + 1;
    inventoryItems[tmpItemId][itemWepId] = strval(inputtext);
    Dialog_Show(playerid, CreateItemAmmoId, DIALOG_STYLE_INPUT, "Create Item: Ammo ID", "Enter this item's ammo ID (-1 if not a weapon).", "Confirm", "Back");
    return 1;
}

Dialog:CreateItemAmmoId(playerid, response, listitem, string:inputtext[])
{
    if(!response)
        return 1;
    
    if(strval(inputtext) < -1)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Value cannot be below -1.");
        Dialog_Show(playerid, CreateItemAmmoId, DIALOG_STYLE_INPUT, "Create Item: Ammo ID", "Enter this item's ammo ID (-1 if not a weapon).", "Confirm", "Back");
        return 1;
    }
    
    new tmpItemId = serverItemCount + 1;
    inventoryItems[tmpItemId][itemAmmoId] = strval(inputtext);
    Dialog_Show(playerid, CreateItemWepSlot, DIALOG_STYLE_INPUT, "Create Item: Weaponslot", "Enter this item's weaponslot ID (-1 if not a weapon).", "Confirm", "Back");
    return 1;
}

Dialog:CreateItemWepSlot(playerid, response, listitem, string:inputtext[])
{
    if(!response)
        return 1;
    
    if(strval(inputtext) < -1)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Value cannot be below -1.");
        Dialog_Show(playerid, CreateItemWepSlot, DIALOG_STYLE_INPUT, "Create Item: Weaponslot", "Enter this item's weaponslot ID (-1 if not a weapon).", "Confirm", "Back");
        return 1;
    }
    
    new tmpItemId = serverItemCount + 1;
    inventoryItems[tmpItemId][itemWepSlot] = strval(inputtext);
    Dialog_Show(playerid, CreateItemIsUsable, DIALOG_STYLE_INPUT, "Create Item: Is Usable", "Enter whether this item can use the 'use' command (1 for true, 0 for false).", "Confirm", "Back");
    return 1;
}

Dialog:CreateItemIsUsable(playerid, response, listitem, string:inputtext[])
{
    if(!response)
        return 1;
    
    if(strval(inputtext) < 0 || strval(inputtext) > 1)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Value can only be 0 or 1.");
        Dialog_Show(playerid, CreateItemIsUsable, DIALOG_STYLE_INPUT, "Create Item: Is Usable", "Enter whether this item can use the 'use' command (1 for true, 0 for false).", "Confirm", "Back");
        return 1;
    }
    
    new tmpItemId = serverItemCount + 1;
    if(strval(inputtext) == 0)
    {
        inventoryItems[tmpItemId][isUsable] = false;
    }
    else if(strval(inputtext) == 1)
    {
        inventoryItems[tmpItemId][isUsable] = true;
    }
    Dialog_Show(playerid, CreateItemMaxResource, DIALOG_STYLE_INPUT, "Create Item: Max Resource", "Enter a value for this item's max resource (fuel can for example)(-1 for no resource).", "Confirm", "Back");
    return 1;
}

Dialog:CreateItemMaxResource(playerid, response, listitem, string:inputtext[])
{
    if(!response)
        return 1;
    
    if(strval(inputtext) < -1)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Value cannot be below -1.");
        Dialog_Show(playerid, CreateItemMaxResource, DIALOG_STYLE_INPUT, "Create Item: Max Resource", "Enter a value for this item's max resource (fuel can for example)(-1 for no resource).", "Confirm", "Back");
        return 1;
    }
    
    inventoryItems[inventoryItems[serverItemCount + 1][itemId]][itemMaxResource] = strval(inputtext);
    new tmpItemId = inventoryItems[serverItemCount + 1][itemId];
    
    // now add the new item to the database
    CreateServerItem(inventoryItems[tmpItemId][itemNameSingular], inventoryItems[tmpItemId][itemNamePlural], inventoryItems[tmpItemId][itemDescription], 
        inventoryItems[tmpItemId][itemCategory], inventoryItems[tmpItemId][itemHealAmount], inventoryItems[tmpItemId][itemWepId], inventoryItems[tmpItemId][itemAmmoId], 
        inventoryItems[tmpItemId][itemWepSlot], inventoryItems[tmpItemId][isUsable], inventoryItems[tmpItemId][itemMaxResource]);
    return 1;
}

// ============================================================================
// PERK SYSTEM DIALOGS
// ============================================================================

/*
* Perks
*/
Dialog:PerkMenu(playerid, response, listitem, string:inputtext[])
{
    if(!response)
        return 1;

	new skillName[32];

	if(player[playerid][iszombie] == 1) // zombie
	{
		format(skillName, sizeof(skillName), "%s", zombieSkills[listitem]);

		switch(listitem)
		{
			case Z_PERK_HP:
			{
				TryUpgradeHpSkill(playerid);
			}
			case Z_PERK_JUMP:
			{
				TryUpgradeJumpSkill(playerid);
			}
			case Z_PERK_MELEEDAM:
			{
				TryUpgradeUnarmedSkill(playerid);
			}
			case Z_PERK_BITE:
			{
				TryUpgradeBiteSkill(playerid);
			}
			case Z_PERK_COMBUST:
			{
				TryUnlockCombustSkill(playerid);
			}
			case Z_PERK_STUN:
			{
				TryUnlockStunSkill(playerid);
			}
			case Z_PERK_GRAB:
			{
				TryUnlockGrabSkill(playerid);
			}
			case Z_PERK_BSTR:
			{
				TryUnlockBorrowedStrengthSkill(playerid);
			}
			case Z_PERK_SJUMP:
			{
				TryUnlockSuperJumpSkill(playerid);
			}
			case Z_PERK_CORNERED:
			{
				TryUnlockCorneredSkill(playerid);
			}
			case Z_PERK_HUNT:
			{
				TryUnlockHuntSkill(playerid);
			}
			default: // should probably never be reached... but just in case
			{
				SendClientMessage(playerid, COLOR_YELLOW, "Invalid selection.");
			}
		}
	}
	else // human
	{
		switch(listitem)
		{
			case H_PERK_TINKERER:
			{
				TryUnlockTinkererPerk(playerid);
			}
			case H_PERK_MECHANIC:
			{
				TryUnlockMechanicPerk(playerid);
			}
		}
	}
    return 1;
}

// used for message boxes where we just want to kick the player on close
Dialog:MessageBoxKick(playerid, response, listitem, string:inputtext[])
{
    Kick(playerid);
    return 1;
}

#endif // MODULE_DIALOGS_INCLUDED