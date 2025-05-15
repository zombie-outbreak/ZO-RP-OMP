/*
* Zombie Outbreak Roleplay
* (C) 2025 Zombie Outbreak Development Contributors
* GNU General Public License v3.0
*/

/*
* Function Forwards
*/

forward RegisterDialog(playerid, dialogid, response, listitem, string:inputtext[]);
forward LoginDialog(playerid, dialogid, response, listitem, string:inputtext[]);
forward ChangePasswordDialog(playerid, dialogid, response, listitem, string:inputtext[]);
forward ChooseZombie(playerid, dialogid, response, listitem, string:inputtext[]);
forward CreateCharName(playerid, dialogid, response, listitem, string:inputtext[]);
forward CreateCharDescription(playerid, dialogid, response, listitem, string:inputtext[]);
forward CreateCharAge(playerid, dialogid, response, listitem, string:inputtext[]);
forward InventoryMain(playerid, dialogid, response, listitem, string:inputtext[]);
forward InventoryItemMain(playerid, dialogid, response, listitem, string:inputtext[]);
forward InventoryGeneralOpts(playerid, dialogid, response, listitem, string:inputtext[]);
forward FuelCanOptions(playerid, dialogid, response, listitem, string:inputtext[]);
forward ScrapOptions(playerid, dialogid, response, listitem, string:inputtext[]);
forward InventoryFoodDrinkOpts(playerid, dialogid, response, listitem, string:inputtext[]);
forward InventoryMedicalOpts(playerid, dialogid, response, listitem, string:inputtext[]);
forward InventoryWeaponsOpts(playerid, dialogid, response, listitem, string:inputtext[]);
forward InventoryAmmoOpts(playerid, dialogid, response, listitem, string:inputtext[]);
forward InventoryGiveId(playerid, dialogid, response, listitem, string:inputtext[]);
forward InventoryGiveAmount(playerid, dialogid, response, listitem, string:inputtext[]);
forward InventoryDropAmount(playerid, dialogid, response, listitem, string:inputtext[]);
forward InteriorOptions(playerid, dialogid, response, listitem, string:inputtext[]);
forward InteriorSetName(playerid, dialogid, response, listitem, string:inputtext[]);
forward InteriorSetVirWorld(playerid, dialogid, response, listitem, string:inputtext[]);
forward InteriorDeleteQuestion(playerid, dialogid, response, listitem, string:inputtext[]);
forward CreateFactionQuestion(playerid, dialogid, response, listitem, string:inputtext[]);
forward CreateFactionName(playerid, dialogid, response, listitem, string:inputtext[]);
forward FactionMain_Leader(playerid, dialogid, response, listitem, string:inputtext[]);
forward FactionMain_Member(playerid, dialogid, response, listitem, string:inputtext[]);
forward LeaveFactionQuestion(playerid, dialogid, response, listitem, string:inputtext[]);
forward UpdateFactionName(playerid, dialogid, response, listitem, string:inputtext[]);
forward EditFactionMember(playerid, dialogid, response, listitem, string:inputtext[]);
forward SelectFactionRank(playerid, dialogid, response, listitem, string:inputtext[]);
forward EditFactionRankSelect(playerid, dialogid, response, listitem, string:inputtext[]);
forward EditRankName(playerid, dialogid, response, listitem, string:inputtext[]);

/*
* Dialog Callbacks
*/
public RegisterDialog(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Kick(playerid);

	if (strlen(inputtext) <= 5) 
		return Dialog_ShowCallback(playerid, using public RegisterDialog<iiiis>, DIALOG_STYLE_PASSWORD, "Registration", "Your password must be longer than 5 characters!\nPlease enter your password in the field below:", "Register", "Abort");

    bcrypt_hash(playerid, "OnRegisterPasswordHash", inputtext, BCRYPT_COST);
	return 1;
}

public LoginDialog(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Kick(playerid);

	bcrypt_verify(playerid, "OnPasswordVerify", inputtext, player[playerid][Password]);
	return 1;
}

public ChangePasswordDialog(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response) 
		return 1;

	if (strlen(inputtext) <= 5) 
		return Dialog_ShowCallback(playerid, using public ChangePasswordDialog<iiiis>, DIALOG_STYLE_PASSWORD, "Change Password", "Your password must be longer than 5 characters!\nPlease enter a new password below:", "Confirm", "Close");

    bcrypt_hash(playerid, "OnUserPasswordChange", inputtext, BCRYPT_COST);
	return 1;
}

public ChooseZombie(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
	{
		PopulateCharacterMenu(playerid);
		return 1;
	}

	if(listitem == 0) // human character
	{
		player[playerid][chosenZombie] = false;

		Dialog_ShowCallback(playerid, using public CreateCharName<iiiis>, DIALOG_STYLE_INPUT, "Character Name", "Enter your character's name (Firstname_Lastname) format.", "Confirm", "Back");
	}
	else // zombie character
	{
		player[playerid][chosenZombie] = true;

		Dialog_ShowCallback(playerid, using public CreateCharName<iiiis>, DIALOG_STYLE_INPUT, "Character Name", "Enter your character's name (Firstname_Lastname) format.", "Confirm", "Back");
	}
	return 1;
}

public CreateCharName(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
	{
		PopulateCharacterMenu(playerid);
		return 1;
	}

	format(player[playerid][chosenChar], MAX_PLAYER_NAME, "%s", inputtext);
	Dialog_ShowCallback(playerid, using public CreateCharDescription<iiiis>, DIALOG_STYLE_INPUT, "Character Description", "A brief description of your character.", "Confirm", "Back");
	return 1;
}

public CreateCharDescription(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
	{
		Dialog_ShowCallback(playerid, using public CreateCharName<iiiis>, DIALOG_STYLE_INPUT, "Character Name", "Enter your character's name (Firstname_Lastname) format.", "Confirm", "Back");
		return 1;
	}

	format(player[playerid][description], MAX_PLAYER_NAME, "%s", inputtext);

	if(!player[playerid][chosenZombie])
	{
		Dialog_ShowCallback(playerid, using public CreateCharAge<iiiis>, DIALOG_STYLE_INPUT, "Character Age", "How old is your character?", "Confirm", "Back");
	}
	else
	{
		ShowSkinModelMenu(playerid);
	}
	return 1;
}

public CreateCharAge(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
	{
		Dialog_ShowCallback(playerid, using public CreateCharDescription<iiiis>, DIALOG_STYLE_INPUT, "Character Description", "A brief description of your character.", "Confirm", "Back");
		return 1;
	}

	player[playerid][age] = strval(inputtext);
	ShowSkinModelMenu(playerid);
	return 1;
}

public InventoryMain(playerid, dialogid, response, listitem, string:inputtext[])
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

public InventoryItemMain(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

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
		case CATEGORY_GENERAL: Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
		case CATEGORY_FOOD: Dialog_ShowCallback(playerid, using public InventoryFoodDrinkOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
		case CATEGORY_DRINK: Dialog_ShowCallback(playerid, using public InventoryFoodDrinkOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
		case CATEGORY_MEDICAL: Dialog_ShowCallback(playerid, using public InventoryMedicalOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
		case CATEGORY_WEAPONS: Dialog_ShowCallback(playerid, using public InventoryWeaponsOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nEquip\nUnequip", "Select", "Back");
		case CATEGORY_AMMO: Dialog_ShowCallback(playerid, using public InventoryAmmoOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop", "Select", "Back");
	}
	return 1;
}

public InventoryGeneralOpts(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	switch(listitem)
	{
		case 0:
		{
			SendClientMessage(playerid, COLOR_RP_PURPLE, "%s", inventoryItems[player[playerid][chosenItemId]][itemDescription]);
			Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
		}
		case 1: // give
		{
			Dialog_ShowCallback(playerid, using public InventoryGiveId<iiiis>, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		}
		case 2: // drop
		{
			Dialog_ShowCallback(playerid, using public InventoryDropAmount<iiiis>, DIALOG_STYLE_INPUT, "Input an amount to drop", "Input an amount of items you wish to drop.", "Confirm", "Go Back");
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

				SendClientMessage(playerid, COLOR_GREEN, "You have used a purification tablet on some dirty water and have gained 1 clean canteen of water.");
				SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER, "puts a purification tablet into a water canteen.");
			}
			else if(player[playerid][chosenItemId] == fuelCanId)
			{
				Dialog_ShowCallback(playerid, using public FuelCanOptions<iiiis>, DIALOG_STYLE_LIST, "Select An Option", "Fill Can\nFill Vehicle", "Select", "Close");
			}
			else if(player[playerid][chosenItemId] == scrapId)
			{
				Dialog_ShowCallback(playerid, using public ScrapOptions<iiiis>, DIALOG_STYLE_LIST, "Select An Option", "Fix Tyres\nFix Doors\nFix Lights\nFix Panels\nFix Health", "Select", "Close");
			}
		}
	}
	return 1;
}

public FuelCanOptions(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	new fuelCanId = ReturnItemIdByName("Fuel Can");

	switch(listitem)
	{
		case 0: // fill fuel can
		{
			if(playerInventoryResource[playerid][fuelCanId] >= inventoryItems[fuelCanId][itemMaxResource])
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Your fuel can is already full.");
				Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			if(!IsPlayerAtFuelPump(playerid))
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You are not near a fuel pump.");
				Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You can only do this on foot.");
				Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
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
				Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			// get pos of vehicle the player was last in
    		GetVehiclePos(player[playerid][lastInVehId], player[playerid][tmpVehPos][0], player[playerid][tmpVehPos][1], player[playerid][tmpVehPos][2]);

			if(!IsPlayerInRangeOfPoint(playerid, 5.0, player[playerid][tmpVehPos][0], player[playerid][tmpVehPos][1], player[playerid][tmpVehPos][2]))
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You are not close enough to your vehicle.");
				Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			if(serverVehicle[player[playerid][lastInVehId]][isBeingFilled])
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "That vehicle is already being filled.");
				Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You can only do this on foot.");
				Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			serverVehicle[player[playerid][lastInVehId]][isBeingFilled] = true;
			ShowHudForPlayer(playerid, HUD_VEHICLE);
			player[playerid][fillVehicleTimer] = SetTimerEx("FillVehicleTimer", 1000, true, "ddd", playerid, player[playerid][lastInVehId], FILL_TYPE_FUELCAN);
		}
	}
	return 1;
}

public ScrapOptions(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	new scrapId = ReturnItemIdByName("Scrap");

	// get pos of vehicle the player was last in
	GetVehiclePos(player[playerid][lastInVehId], player[playerid][tmpVehPos][0], player[playerid][tmpVehPos][1], player[playerid][tmpVehPos][2]);

	if(!IsPlayerInRangeOfPoint(playerid, 5.0, player[playerid][tmpVehPos][0], player[playerid][tmpVehPos][1], player[playerid][tmpVehPos][2]))
	{
		SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You are not close enough to your vehicle.");
		Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
		return 1;
	}

	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
	{
		SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You can only do this on foot.");
		Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
		return 1;
	}

	switch(listitem)
	{
		case 0: // fix tyres
		{
			if(playerInventory[playerid][scrapId] < 16)
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have enough scrap to perform this action.");
				Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			SendClientMessage(playerid, COLOR_GREEN, "You fixed your vehicle's tyres.");
			playerInventory[playerid][scrapId] = playerInventory[playerid][scrapId] - 16;
			GetVehicleDamageStatus(player[playerid][lastInVehId], serverVehicle[player[playerid][lastInVehId]][panels], serverVehicle[player[playerid][lastInVehId]][doors], serverVehicle[player[playerid][lastInVehId]][lights], serverVehicle[player[playerid][lastInVehId]][tires]);
			serverVehicle[player[playerid][lastInVehId]][tires] = encode_tires(0, 0, 0, 0);
			UpdateVehicleDamageStatus(player[playerid][lastInVehId], serverVehicle[player[playerid][lastInVehId]][panels], serverVehicle[player[playerid][lastInVehId]][doors], serverVehicle[player[playerid][lastInVehId]][lights], serverVehicle[player[playerid][lastInVehId]][tires]);
		}
		case 1: // fix doors
		{
			if(playerInventory[playerid][scrapId] < 16)
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have enough scrap to perform this action.");
				Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			SendClientMessage(playerid, COLOR_GREEN, "You fixed your vehicle's doors.");
			playerInventory[playerid][scrapId] = playerInventory[playerid][scrapId] - 16;
			GetVehicleDamageStatus(player[playerid][lastInVehId], serverVehicle[player[playerid][lastInVehId]][panels], serverVehicle[player[playerid][lastInVehId]][doors], serverVehicle[player[playerid][lastInVehId]][lights], serverVehicle[player[playerid][lastInVehId]][tires]);
			serverVehicle[player[playerid][lastInVehId]][doors] = encode_doors(0, 0, 0, 0, 0, 0);
			UpdateVehicleDamageStatus(player[playerid][lastInVehId], serverVehicle[player[playerid][lastInVehId]][panels], serverVehicle[player[playerid][lastInVehId]][doors], serverVehicle[player[playerid][lastInVehId]][lights], serverVehicle[player[playerid][lastInVehId]][tires]);
		}
		case 2: // fix lights
		{
			if(playerInventory[playerid][scrapId] < 16)
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have enough scrap to perform this action.");
				Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			SendClientMessage(playerid, COLOR_GREEN, "You fixed your vehicle's lights.");
			playerInventory[playerid][scrapId] = playerInventory[playerid][scrapId] - 16;
			GetVehicleDamageStatus(player[playerid][lastInVehId], serverVehicle[player[playerid][lastInVehId]][panels], serverVehicle[player[playerid][lastInVehId]][doors], serverVehicle[player[playerid][lastInVehId]][lights], serverVehicle[player[playerid][lastInVehId]][tires]);
			serverVehicle[player[playerid][lastInVehId]][doors] = encode_lights(0, 0, 0, 0);
			UpdateVehicleDamageStatus(player[playerid][lastInVehId], serverVehicle[player[playerid][lastInVehId]][panels], serverVehicle[player[playerid][lastInVehId]][doors], serverVehicle[player[playerid][lastInVehId]][lights], serverVehicle[player[playerid][lastInVehId]][tires]);
		}
		case 3: // fix panels
		{
			if(playerInventory[playerid][scrapId] < 16)
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have enough scrap to perform this action.");
				Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			SendClientMessage(playerid, COLOR_GREEN, "You fixed your vehicle's panels.");
			playerInventory[playerid][scrapId] = playerInventory[playerid][scrapId] - 16;
			GetVehicleDamageStatus(player[playerid][lastInVehId], serverVehicle[player[playerid][lastInVehId]][panels], serverVehicle[player[playerid][lastInVehId]][doors], serverVehicle[player[playerid][lastInVehId]][lights], serverVehicle[player[playerid][lastInVehId]][tires]);
			serverVehicle[player[playerid][lastInVehId]][doors] = encode_panels(0, 0, 0, 0, 0, 0, 0);
			UpdateVehicleDamageStatus(player[playerid][lastInVehId], serverVehicle[player[playerid][lastInVehId]][panels], serverVehicle[player[playerid][lastInVehId]][doors], serverVehicle[player[playerid][lastInVehId]][lights], serverVehicle[player[playerid][lastInVehId]][tires]);
		}
		case 4: // fix car HP
		{
			if(playerInventory[playerid][scrapId] < 10)
			{
				SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You do not have enough scrap to perform this action.");
				Dialog_ShowCallback(playerid, using public InventoryGeneralOpts<iiiis>, DIALOG_STYLE_LIST, "Select an option", "Description\nGive\nDrop\nUse", "Select", "Back");
				return 1;
			}

			SendClientMessage(playerid, COLOR_GREEN, "You restored some of your vehicles HP.");
			playerInventory[playerid][scrapId] = playerInventory[playerid][scrapId] - 10;

			serverVehicle[player[playerid][lastInVehId]][vehHealth] = serverVehicle[player[playerid][lastInVehId]][vehHealth] + 100;

			if(serverVehicle[player[playerid][lastInVehId]][vehHealth] >= 1000)
			{
				serverVehicle[player[playerid][lastInVehId]][vehHealth] = 1000;
				SetVehicleHealth(player[playerid][lastInVehId], 1000);
			}
			else
			{
				SetVehicleHealth(player[playerid][lastInVehId], serverVehicle[player[playerid][lastInVehId]][vehHealth]);
			}
		}
	}
	return 1;
}

public InventoryFoodDrinkOpts(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	switch(listitem)
	{
		case 0:
		{
			SendClientMessage(playerid, COLOR_RP_PURPLE, "%s", inventoryItems[player[playerid][chosenItemId]][itemDescription]);
			Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
		}
		case 1: // give
		{
			Dialog_ShowCallback(playerid, using public InventoryGiveId<iiiis>, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		}
		case 2: // drop
		{
			Dialog_ShowCallback(playerid, using public InventoryDropAmount<iiiis>, DIALOG_STYLE_INPUT, "Input an amount to drop", "Input an amount of items you wish to drop.", "Confirm", "Go Back");
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
				UpdatePlayerInventoryEntry(playerid, player[playerid][chosenItemId], player[playerid][chosenChar]);
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
					UpdatePlayerInventoryEntry(playerid, emptyCanteenItem, player[playerid][chosenChar]);
				}
				else if(player[playerid][chosenItemId] == waterCanteenItemId)
				{
					playerInventory[playerid][emptyCanteenItem] = playerInventory[playerid][emptyCanteenItem] + 1;
					UpdatePlayerInventoryEntry(playerid, emptyCanteenItem, player[playerid][chosenChar]);
				}
			}
		}
	}
	return 1;
}

public InventoryMedicalOpts(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	switch(listitem)
	{
		case 0:
		{
			SendClientMessage(playerid, COLOR_RP_PURPLE, "%s", inventoryItems[player[playerid][chosenItemId]][itemDescription]);
			Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
		}
		case 1: // give
		{
			Dialog_ShowCallback(playerid, using public InventoryGiveId<iiiis>, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		}
		case 2: // drop
		{
			Dialog_ShowCallback(playerid, using public InventoryDropAmount<iiiis>, DIALOG_STYLE_INPUT, "Input an amount to drop", "Input an amount of items you wish to drop.", "Confirm", "Go Back");
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
				UpdatePlayerInventoryEntry(playerid, player[playerid][chosenItemId], player[playerid][chosenChar]);
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
				UpdatePlayerInventoryEntry(playerid, player[playerid][chosenItemId], player[playerid][chosenChar]);
				SetPlayerHealth(playerid, player[playerid][health]);
				UpdateHudElementForPlayer(playerid, HUD_HEALTH);
				ShowInventoryItemListByCategory(playerid, CATEGORY_MEDICAL);
			}
		}
	}
	return 1;
}

public InventoryWeaponsOpts(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	switch(listitem)
	{
		case 0:
		{
			SendClientMessage(playerid, COLOR_RP_PURPLE, "%s", inventoryItems[player[playerid][chosenItemId]][itemDescription]);
			Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
		}
		case 1: // give
		{
			Dialog_ShowCallback(playerid, using public InventoryGiveId<iiiis>, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		}
		case 2: // drop
		{
			Dialog_ShowCallback(playerid, using public InventoryDropAmount<iiiis>, DIALOG_STYLE_INPUT, "Input an amount to drop", "Input an amount of items you wish to drop.", "Confirm", "Go Back");
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

public InventoryAmmoOpts(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	switch(listitem)
	{
		case 0:
		{
			SendClientMessage(playerid, COLOR_RP_PURPLE, "%s", inventoryItems[player[playerid][chosenItemId]][itemDescription]);
			Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
		}
		case 1: // give
		{
			Dialog_ShowCallback(playerid, using public InventoryGiveId<iiiis>, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		}
		case 2: // drop
		{
			Dialog_ShowCallback(playerid, using public InventoryDropAmount<iiiis>, DIALOG_STYLE_INPUT, "Input an amount to drop", "Input an amount of items you wish to drop.", "Confirm", "Go Back");
		}
	}
	return 1;
}

public InventoryGiveId(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	new id = strval(inputtext);
	if(!IsPlayerConnected(id) || IsPlayerNPC(id))
	{
		SendClientMessage(playerid, COLOR_RED, "You input an invalid player id.");
		Dialog_ShowCallback(playerid, using public InventoryGiveId<iiiis>, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		return 1;
	}

    player[playerid][invGivePlayerId] = id;
	Dialog_ShowCallback(playerid, using public InventoryGiveAmount<iiiis>, DIALOG_STYLE_INPUT, "Input an amount to give", "Input an amount of items you wish to give.", "Confirm", "Go Back");
	return 1;
}

public InventoryGiveAmount(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	if(!IsPlayerConnected(player[playerid][invGivePlayerId]) || IsPlayerNPC(player[playerid][invGivePlayerId]))
	{
		SendClientMessage(playerid, COLOR_RED, "You input an invalid player id.");
		Dialog_ShowCallback(playerid, using public InventoryGiveId<iiiis>, DIALOG_STYLE_INPUT, "Input a player ID", "Input a player ID to give an item to.", "Confirm", "Go Back");
		return 1;
	}

	new amount = strval(inputtext);

	if(amount > playerInventory[playerid][player[playerid][chosenItemId]])
	{
		SendClientMessage(playerid, COLOR_RED, "You don't have that many %s to give. You only have %d in your inventory.", 
			inventoryItems[player[playerid][chosenItemId]][itemNamePlural], playerInventory[playerid][player[playerid][chosenItemId]]);
		Dialog_ShowCallback(playerid, using public InventoryGiveAmount<iiiis>, DIALOG_STYLE_INPUT, "Input an amount to give", "Input an amount of items you wish to give.", "Confirm", "Go Back");
		return 1;
	}

	playerInventory[player[playerid][invGivePlayerId]][player[playerid][chosenItemId]] = playerInventory[player[playerid][invGivePlayerId]][player[playerid][chosenItemId]] + amount;
	SendClientMessage(player[playerid][invGivePlayerId], COLOR_RP_PURPLE, "You were given %d %s from %s.", amount, inventoryItems[player[playerid][chosenItemId]][itemNamePlural], player[playerid][chosenChar]);
	UpdatePlayerInventoryEntry(playerid, player[playerid][chosenItemId], player[playerid][chosenChar]);

	playerInventory[playerid][player[playerid][chosenItemId]] = playerInventory[playerid][player[playerid][chosenItemId]] - amount;
	SendClientMessage(playerid, COLOR_RP_PURPLE, "You gave %s %d %s.", player[player[playerid][invGivePlayerId]][chosenChar], amount, inventoryItems[player[playerid][chosenItemId]][itemNamePlural]);
	UpdatePlayerInventoryEntry(playerid, player[playerid][chosenItemId], player[player[playerid][invGivePlayerId]][chosenChar]);

	Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
	return 1;
}

public InventoryDropAmount(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");

	new amount = strval(inputtext);

	if(amount > playerInventory[playerid][player[playerid][chosenItemId]])
	{
		SendClientMessage(playerid, COLOR_RED, "You don't have that many %s to drop. You only have %d in your inventory.", 
			inventoryItems[player[playerid][chosenItemId]][itemNamePlural], playerInventory[playerid][player[playerid][chosenItemId]]);
		Dialog_ShowCallback(playerid, using public InventoryDropAmount<iiiis>, DIALOG_STYLE_INPUT, "Input an amount to drop", "Input an amount of items you wish to drop.", "Confirm", "Go Back");
		return 1;
	}

	playerInventory[playerid][player[playerid][chosenItemId]] = playerInventory[playerid][player[playerid][chosenItemId]] - amount;
	UpdatePlayerInventoryEntry(playerid, player[playerid][chosenItemId], player[playerid][chosenChar]);
	SendClientMessage(playerid, COLOR_RED, "You dropped %d %s.", amount, inventoryItems[player[playerid][chosenItemId]][itemNamePlural]);

	Dialog_ShowCallback(playerid, using public InventoryMain<iiiis>, DIALOG_STYLE_LIST, "Select A Category", "General\nFood\nDrink\nMedical\nWeapons\nAmmo", "Select", "Close");
	return 1;
}

public InteriorOptions(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return 1;

	switch(listitem)
	{
		case 0: // change interior name
		{
			Dialog_ShowCallback(playerid, using public InteriorSetName<iiiis>, DIALOG_STYLE_INPUT, "Interior Name", "Input an updated name of the interior.", "Confirm", "Close");
		}
		case 1: // set virtual world
		{
			Dialog_ShowCallback(playerid, using public InteriorSetVirWorld<iiiis>, DIALOG_STYLE_INPUT, "Interior Virtual World", "Input a new virtual world ID for this interior.", "Confirm", "Close");
		}
		case 2: // delete
		{
			Dialog_ShowCallback(playerid, using public InteriorDeleteQuestion<iiiis>, DIALOG_STYLE_MSGBOX, "Delete Interior", "Are you sure you wish to delete this interior? You cannot recover it without recreating it.", "Yes", "No");
		}
	}
	return 1;
}

public InteriorSetName(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response) // don't change
		return 1;

	new string[128];
	format(string, sizeof(string), "%s Options", player[playerid][tmpIntName]);

	if(strlen(inputtext) > 64)
	{
		SendClientMessage(playerid, COLOR_RED, "Name input was too long, please try a shorter name. 64 characters maximum.");
		Dialog_ShowCallback(playerid, using public InteriorOptions<iiiis>, DIALOG_STYLE_LIST, string, "Change Name\nSet Virtual World\nSet Map Icon\nDelete", "Select", "Close");
		return 1;
	}

	// update the interior name entry
    DB_ExecuteQuery(database, "UPDATE interiors SET name = '%q' WHERE name = '%q'", inputtext, player[playerid][tmpIntName]);
	SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You updated the interior name.");
	return 1;
}

public InteriorSetVirWorld(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response) // don't change
		return 1;

	new tmpIntId, string[128], DBResult:Result;
	format(string, sizeof(string), "%s Options", player[playerid][tmpIntName]);

	if(strval(inputtext) < 1000 || strval(inputtext) > 2147483647)
	{
		SendClientMessage(playerid, COLOR_RED, "Invalid Virtual world. Values between 1000 - 2147483647 only.");
		Dialog_ShowCallback(playerid, using public InteriorOptions<iiiis>, DIALOG_STYLE_LIST, string, "Change Name\nSet Virtual World\nSet Map Icon\nDelete", "Select", "Close");
		return 1;
	}

	// update the virtual world entry
    DB_ExecuteQuery(database, "UPDATE interiors SET virworld = '%d' WHERE name = '%q'", strval(inputtext), player[playerid][tmpIntName]);

	// now get the interior ID and new virtual world for the interior
	Result = DB_ExecuteQuery(database, "SELECT id, virworld FROM interiors WHERE name = '%q'", player[playerid][tmpIntName]);

	if(DB_GetFieldCount(Result) > 0)
	{
		tmpIntId = DB_GetFieldIntByName(Result, "id");
		srvInterior[tmpIntId][intVirWorld] = DB_GetFieldIntByName(Result, "virworld");
	}
	DB_FreeResultSet(Result);

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

public InteriorDeleteQuestion(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response) // don't delete
		return 1;

	new tmpIntId, DBResult:Result;

	// now get the interior ID and new virtual world for the interior
	Result = DB_ExecuteQuery(database, "SELECT id FROM interiors WHERE name = '%q'", player[playerid][tmpIntName]);

	if(DB_GetFieldCount(Result) > 0)
	{
		tmpIntId = DB_GetFieldIntByName(Result, "id");
	}
	DB_FreeResultSet(Result);

	// destroy the old pickups
	DestroyDynamicPickup(interiorEnterPickup[tmpIntId]);
	DestroyDynamicPickup(interiorExitPickup[tmpIntId]);

	/*
	* Now Delete interior from the table
	*/
    Result = DB_ExecuteQuery(database, "DELETE FROM interiors WHERE name = '%q'", player[playerid][tmpIntName]);
	DB_FreeResultSet(Result);

	SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You deleted the interior.");
	return 1;
}

/*
* Factions
*/
public CreateFactionQuestion(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return 1;

	Dialog_ShowCallback(playerid, using public CreateFactionName<iiiis>, DIALOG_STYLE_INPUT, "Create a Faction: Name", "Input your new faction's name (can be changed from the faction menu later).", "Confirm", "Close");
	return 1;
}

public CreateFactionName(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return 1;

	new DBResult:Result, tmpFactionId, bool:factionFound = false;
    Result = DB_ExecuteQuery(database, "SELECT * FROM factions WHERE name = '%q'", inputtext);

	if(DB_GetFieldCount(Result) > 0) // a faction exists with this name already
    {
        factionFound = true;
    }
    DB_FreeResultSet(Result);
    
    if(factionFound)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "A faction with that name already exists.");
        return 1;
    }
    else
    {
        DB_ExecuteQuery(database, "INSERT INTO factions (name, creator) VALUES ('%q', '%q')", inputtext, player[playerid][chosenChar]);
        Result = DB_ExecuteQuery(database, "SELECT last_insert_rowid()");
        tmpFactionId = DB_GetFieldInt(Result);
        DB_FreeResultSet(Result);
    }

	/*
	* Load the new faction's data and update the character's faction data
	*/
	LoadFactionData(tmpFactionId);
	player[playerid][plrFaction] = tmpFactionId;
	player[playerid][factionrank] = MAX_FACTION_RANKS; // MAX_FACTION_RANKS always equals the rank ID for the leader/creator
	DB_ExecuteQuery(database, "UPDATE characters SET faction = '%d', factionrank = '%d' WHERE name = '%q'", 
		player[playerid][plrFaction], player[playerid][factionrank], player[playerid][chosenChar]);

	/*
	* Success
	*/
	SendClientMessage(playerid, COLOR_GREEN, "You have successfully created: %s.", inputtext);
	SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You can now use /faction to manage your faction or invite some new members.");
	return 1;
}

public FactionMain_Leader(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return 1;

	switch(listitem)
	{
		case 0: // Edit faction name
		{
			Dialog_ShowCallback(playerid, using public UpdateFactionName<iiiis>, DIALOG_STYLE_INPUT, "Update Faction: Name", "Input the new name for your faction.", "Confirm", "Close");
		}
		case 1: // Manage faction rank names
		{
			new string[1024], factionid = player[playerid][plrFaction];
			format(string, sizeof(string), "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s", 
			factionRankName[factionid][0], factionRankName[factionid][1], factionRankName[factionid][2], factionRankName[factionid][3],
			factionRankName[factionid][4], factionRankName[factionid][5], factionRankName[factionid][6], factionRankName[factionid][7],
			factionRankName[factionid][8], factionRankName[factionid][9]);
			Dialog_ShowCallback(playerid, using public EditFactionRankSelect<iiiis>, DIALOG_STYLE_LIST, "Select A Rank", string, "Select", "Close");
		}
		case 2: // Manage faction members
		{
			PopulateFactionMembersList(playerid, player[playerid][plrFaction]);
		}
	}
	return 1;
}

public FactionMain_Member(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return 1;

	switch(listitem)
	{
		case 0: // Leave Faction
		{
			Dialog_ShowCallback(playerid, using public LeaveFactionQuestion<iiiis>, DIALOG_STYLE_MSGBOX, "Leave Faction?", "Do you wish to leave your faction?", "Yes", "No");
		}
	}
	return 1;
}

public LeaveFactionQuestion(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return 1;

	player[playerid][plrFaction] = 0;
	player[playerid][factionrank] = 0;

	DB_ExecuteQuery(database, "UPDATE characters SET faction = '0', factionrank = '0' WHERE name = '%q'", player[playerid][chosenChar]);
	SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You left your faction.");
	return 1;
}

public UpdateFactionName(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public FactionMain_Leader<iiiis>, DIALOG_STYLE_LIST, "Manage Faction", "Edit Faction Name\nManage Ranks\nManage Members", "Select", "Close");

	DB_ExecuteQuery(database, "UPDATE factions SET name = '%q' WHERE id = '%d'", inputtext, player[playerid][plrFaction]);
	SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You updated your faction name.");
	return 1;
}

public EditFactionMember(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public FactionMain_Leader<iiiis>, DIALOG_STYLE_LIST, "Manage Faction", "Edit Faction Name\nManage Ranks\nManage Members", "Select", "Close");

	switch(listitem)
	{
		case 0: // set rank
		{
			new string[1024], factionid = player[playerid][plrFaction];
			format(string, sizeof(string), "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s", 
			factionRankName[factionid][0], factionRankName[factionid][1], factionRankName[factionid][2], factionRankName[factionid][3],
			factionRankName[factionid][4], factionRankName[factionid][5], factionRankName[factionid][6], factionRankName[factionid][7],
			factionRankName[factionid][8], factionRankName[factionid][9]);
			Dialog_ShowCallback(playerid, using public SelectFactionRank<iiiis>, DIALOG_STYLE_LIST, "Select A Rank", string, "Select", "Close");
		}
		case 1: // kick
		{
            if(strcmp(player[playerid][facChosenChar], player[playerid][chosenChar]) == 0) // if the player is trying to kick themselves
            {
                SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot kick yourself from your faction.");
                return 1;
            }

			if(IsPlayerConnected(GetPlayerIdFromName(player[playerid][facChosenChar])))
			{
				player[GetPlayerIdFromName(player[playerid][facChosenChar])][plrFaction] = 0;
				player[GetPlayerIdFromName(player[playerid][facChosenChar])][factionrank] = 0;

				DB_ExecuteQuery(database, "UPDATE characters SET faction = '0', factionrank = '0' WHERE name = '%q'", player[GetPlayerIdFromName(player[playerid][facChosenChar])][chosenChar]);
			}
			else
			{
				DB_ExecuteQuery(database, "UPDATE characters SET faction = '0', factionrank = '0' WHERE name = '%q'", player[playerid][facChosenChar]);
			}
			SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You have kicked this character from your faction.");
		}
	}
	return 1;
}

public SelectFactionRank(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public FactionMain_Leader<iiiis>, DIALOG_STYLE_LIST, "Manage Faction", "Edit Faction Name\nManage Ranks\nManage Members", "Select", "Close");

	if(IsPlayerConnected(GetPlayerIdFromName(player[playerid][facChosenChar])))
	{
		player[GetPlayerIdFromName(player[playerid][facChosenChar])][factionrank] = listitem + 1; // ranks are 1 - 10

		DB_ExecuteQuery(database, "UPDATE characters SET factionrank = '%d' WHERE name = '%q'", listitem + 1, player[GetPlayerIdFromName(player[playerid][facChosenChar])][chosenChar]);
	}
	else
	{
		DB_ExecuteQuery(database, "UPDATE characters SET factionrank = '%d' WHERE name = '%q'", listitem + 1, player[playerid][facChosenChar]);
	}
	SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You have updated this character's rank within your faction.");
	return 1;
}

public EditFactionRankSelect(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public FactionMain_Leader<iiiis>, DIALOG_STYLE_LIST, "Manage Faction", "Edit Faction Name\nManage Ranks\nManage Members", "Select", "Close");

	player[playerid][facChosenRankId] = listitem;
	Dialog_ShowCallback(playerid, using public EditRankName<iiiis>, DIALOG_STYLE_INPUT, "Edit Faction: Rank", "Input a name for this rank.", "Confirm", "Close");
	return 1;
}

public EditRankName(playerid, dialogid, response, listitem, string:inputtext[])
{
	if(!response)
		return Dialog_ShowCallback(playerid, using public FactionMain_Leader<iiiis>, DIALOG_STYLE_LIST, "Manage Faction", "Edit Faction Name\nManage Ranks\nManage Members", "Select", "Close");

	format(factionRankName[player[playerid][plrFaction]][player[playerid][facChosenRankId]], 64, "%s", inputtext);
	DB_ExecuteQuery(database, "UPDATE factions SET rank%d = '%q' WHERE name = '%q'", player[playerid][facChosenRankId], factionRankName[player[playerid][plrFaction]][player[playerid][facChosenRankId]], player[playerid][facChosenChar]);
	SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You updated the faction rank.");
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
	Dialog_ShowCallback(playerid, using public InteriorOptions<iiiis>, DIALOG_STYLE_LIST, string, "Change Name\nSet Virtual World\nDelete", "Select", "Close");
	return 1;
}

DialogPages:ShowPlayerCharacterMenu(playerid, response, listitem, inputtext[])
{
	if(!response)
		return Kick(playerid);

	format(player[playerid][chosenChar], MAX_PLAYER_NAME, "%s", inputtext);

	if(strcmp("Create New", player[playerid][chosenChar]) == 0) // show the create character dialogs
	{
		Dialog_ShowCallback(playerid, using public ChooseZombie<iiiis>, DIALOG_STYLE_LIST, "Is Your Character A Zombie?", "Human\nZombie", "Confirm", "Back");
	}
	else // show character options
	{
		/*
		* Eventally this should show another dialog menu with character options. 
		* For now let's spawn the player as their chosen character.
		*/
		OnPlayerCharacterDataLoaded(playerid);
		OnPlayerInventoryDataLoaded(playerid);
		OnPlayerLockerDataLoaded(playerid);
	}
	return 1;
}

DialogPages:ShowFactionMemberList(playerid, response, listitem, inputtext[])
{
	if(!response)
		return 1;

	format(player[playerid][facChosenChar], MAX_PLAYER_NAME, "%s", inputtext);
	Dialog_ShowCallback(playerid, using public EditFactionMember<iiiis>, DIALOG_STYLE_LIST, "Faction Member Options", "Set Rank\nKick", "Confirm", "Back");
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

			Dialog_ShowCallback(playerid, using public InventoryItemMain<iiiis>, DIALOG_STYLE_TABLIST, string, invString, "Select", "Go Back");
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

			Dialog_ShowCallback(playerid, using public InventoryItemMain<iiiis>, DIALOG_STYLE_TABLIST, string, invString, "Select", "Go Back");
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

			Dialog_ShowCallback(playerid, using public InventoryItemMain<iiiis>, DIALOG_STYLE_TABLIST, string, invString, "Select", "Go Back");
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

			Dialog_ShowCallback(playerid, using public InventoryItemMain<iiiis>, DIALOG_STYLE_TABLIST, string, invString, "Select", "Go Back");
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

			Dialog_ShowCallback(playerid, using public InventoryItemMain<iiiis>, DIALOG_STYLE_TABLIST, string, invString, "Select", "Go Back");
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

			Dialog_ShowCallback(playerid, using public InventoryItemMain<iiiis>, DIALOG_STYLE_TABLIST, string, invString, "Select", "Go Back");
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
				DB_ExecuteQuery(database, "INSERT INTO characters (owner, name, age, description, skin, iszombie) VALUES \
					('%d', '%q', '%d', '%q', '%d', '%d')", 
					player[playerid][ID], player[playerid][chosenChar], player[playerid][age], player[playerid][description], player[playerid][skin], 
					player[playerid][iszombie]
				);
			}
			else
			{
				DB_ExecuteQuery(database, "INSERT INTO characters (owner, name, age, description, skin, iszombie, health, maxhealth) VALUES \
					('%d', '%q', '%d', '%q', '%d', '%d', '200.0', '200.0')", 
					player[playerid][ID], player[playerid][chosenChar], player[playerid][age], player[playerid][description], player[playerid][skin], 
					player[playerid][iszombie]
				);
			}

			if(player[playerid][iszombie] == 0)
			{
				/*
				* Create inventory entry
				*/
				DB_ExecuteQuery(database, "INSERT INTO inventories (name) VALUES ('%q')", player[playerid][chosenChar]);

				/*
				* Create lockers entry
				*/
				DB_ExecuteQuery(database, "INSERT INTO lockers (name) VALUES ('%q')", player[playerid][chosenChar]);
			}

			/*
			* To be removed when tutorial implemented.
			*/
			PopulateCharacterMenu(playerid);
            return 1;
        }
		else
		{
			if(!player[playerid][chosenZombie])
			{
				Dialog_ShowCallback(playerid, using public CreateCharAge<iiiis>, DIALOG_STYLE_INPUT, "Character Age", "How old is your character?", "Confirm", "Back");
			}
			else
			{
				Dialog_ShowCallback(playerid, using public CreateCharDescription<iiiis>, DIALOG_STYLE_INPUT, "Character Description", "A brief description of your character.", "Confirm", "Back");
			}
		}
    }
	return 1;
}