/*
* Zombie Outbreak Roleplay
* (C) 2025 Zombie Outbreak Development Contributors
* GNU General Public License v3.0
*/

/*
* Server Textdraws
*/
CreateServerTextdraws()
{
	Clock = TextDrawCreate(549.0, 14.0, "Clock");
	TextDrawSetShadow(Clock, 0);
	TextDrawSetOutline(Clock, 1);
	TextDrawLetterSize(Clock, 0.4, 0.9);
	TextDrawFont(Clock, 3);
    TextDrawSetProportional(Clock, 1);

	animhelper = TextDrawCreate(610.0, 400.0, "~r~~k~~PED_SPRINT~ ~w~to stop the animation");
	TextDrawUseBox(animhelper, 0);
	TextDrawFont(animhelper, 2);
	TextDrawSetShadow(animhelper,0); // no shadow
    TextDrawSetOutline(animhelper,1); // thickness 1
    TextDrawBackgroundColour(animhelper, 0x000000FF);
    TextDrawColour(animhelper,0xFFFFFFFF);
    TextDrawAlignment(animhelper,3); // align right
}

/*
* Dialogue Textdraws (also used for tutorial.)
*/
CreateDialogueTextdraw(playerid)
{
	dialogueText[playerid] = CreatePlayerTextDraw(playerid, 121.000000, 373.000000, "NPC: Some text.");
	PlayerTextDrawFont(playerid, dialogueText[playerid], 1);
	PlayerTextDrawLetterSize(playerid, dialogueText[playerid], 0.274999, 1.299999);
	PlayerTextDrawTextSize(playerid, dialogueText[playerid], 530.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, dialogueText[playerid], 1);
	PlayerTextDrawSetShadow(playerid, dialogueText[playerid], 0);
	PlayerTextDrawAlignment(playerid, dialogueText[playerid], 1);
	PlayerTextDrawColour(playerid, dialogueText[playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, dialogueText[playerid], 255);
	PlayerTextDrawBoxColor(playerid, dialogueText[playerid], 255);
	PlayerTextDrawUseBox(playerid, dialogueText[playerid], true);
	PlayerTextDrawSetProportional(playerid, dialogueText[playerid], true);
	PlayerTextDrawSetSelectable(playerid, dialogueText[playerid], false);
	return 1;
}

HideDialogueTextdraw(playerid)
{
    PlayerTextDrawHide(playerid, dialogueText[playerid]);
    return 1;
}

DestroyDialogueTextdraw(playerid)
{
	PlayerTextDrawDestroy(playerid, dialogueText[playerid]);
	return 1;
}

ShowDialogueTextDraw(playerid, const text[])
{
	PlayerTextDrawSetString(playerid, dialogueText[playerid], text);
	PlayerTextDrawShow(playerid, dialogueText[playerid]);
	return 1;
}

/*
* Player HUD
*/
CreatePlayerHud(playerid)
{
	infoBar[playerid] = CreatePlayerTextDraw(playerid, 319.000000, 434.000000, "ID:_0_I_LEVEL:_1_I_PERK_POINTS:_0");
	PlayerTextDrawFont(playerid, infoBar[playerid], 2);
	PlayerTextDrawLetterSize(playerid, infoBar[playerid], 0.279166, 1.350000);
	PlayerTextDrawTextSize(playerid, infoBar[playerid], 12.000000, 640.000000);
	PlayerTextDrawSetOutline(playerid, infoBar[playerid], 0);
	PlayerTextDrawSetShadow(playerid, infoBar[playerid], 0);
	PlayerTextDrawAlignment(playerid, infoBar[playerid], 2);
	PlayerTextDrawColour(playerid, infoBar[playerid], -1);
	PlayerTextDrawBackgroundColour(playerid, infoBar[playerid], 255);
	PlayerTextDrawBoxColor(playerid, infoBar[playerid], 101);
	PlayerTextDrawUseBox(playerid, infoBar[playerid], true);
	PlayerTextDrawSetProportional(playerid, infoBar[playerid], true);
	PlayerTextDrawSetSelectable(playerid, infoBar[playerid], false);

	hungerIcon[playerid] = CreatePlayerTextDraw(playerid, 260.000000, 415.000000, "HUD:radar_burgershot");
	PlayerTextDrawFont(playerid, hungerIcon[playerid], TEXT_DRAW_FONT_SPRITE_DRAW);
	PlayerTextDrawLetterSize(playerid, hungerIcon[playerid], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, hungerIcon[playerid], 17.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, hungerIcon[playerid], 1);
	PlayerTextDrawSetShadow(playerid, hungerIcon[playerid], 0);
	PlayerTextDrawAlignment(playerid, hungerIcon[playerid], 1);
	PlayerTextDrawColour(playerid, hungerIcon[playerid], -1);
	PlayerTextDrawBackgroundColour(playerid, hungerIcon[playerid], 255);
	PlayerTextDrawBoxColor(playerid, hungerIcon[playerid], 50);
	PlayerTextDrawUseBox(playerid, hungerIcon[playerid], true);
	PlayerTextDrawSetProportional(playerid, hungerIcon[playerid], true);
	PlayerTextDrawSetSelectable(playerid, hungerIcon[playerid], false);

	hungerText[playerid] = CreatePlayerTextDraw(playerid, 280.000000, 420.000000, "100/100");
	PlayerTextDrawFont(playerid, hungerText[playerid], 1);
	PlayerTextDrawLetterSize(playerid, hungerText[playerid], 0.150000, 0.850000);
	PlayerTextDrawTextSize(playerid, hungerText[playerid], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, hungerText[playerid], 1);
	PlayerTextDrawSetShadow(playerid, hungerText[playerid], 0);
	PlayerTextDrawAlignment(playerid, hungerText[playerid], 1);
	PlayerTextDrawColour(playerid, hungerText[playerid], -1);
	PlayerTextDrawBackgroundColour(playerid, hungerText[playerid], 255);
	PlayerTextDrawBoxColor(playerid, hungerText[playerid], 50);
	PlayerTextDrawUseBox(playerid, hungerText[playerid], false);
	PlayerTextDrawSetProportional(playerid, hungerText[playerid], true);
	PlayerTextDrawSetSelectable(playerid, hungerText[playerid], false);

	thirstIcon[playerid] = CreatePlayerTextDraw(playerid, 310.000000, 415.000000, "HUD:radar_diner");
	PlayerTextDrawFont(playerid, thirstIcon[playerid], TEXT_DRAW_FONT_SPRITE_DRAW);
	PlayerTextDrawLetterSize(playerid, thirstIcon[playerid], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, thirstIcon[playerid], 17.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, thirstIcon[playerid], 1);
	PlayerTextDrawSetShadow(playerid, thirstIcon[playerid], 0);
	PlayerTextDrawAlignment(playerid, thirstIcon[playerid], 1);
	PlayerTextDrawColour(playerid, thirstIcon[playerid], -1);
	PlayerTextDrawBackgroundColour(playerid, thirstIcon[playerid], 255);
	PlayerTextDrawBoxColor(playerid, thirstIcon[playerid], 50);
	PlayerTextDrawUseBox(playerid, thirstIcon[playerid], true);
	PlayerTextDrawSetProportional(playerid, thirstIcon[playerid], true);
	PlayerTextDrawSetSelectable(playerid, thirstIcon[playerid], false);

	thirstText[playerid] = CreatePlayerTextDraw(playerid, 330.000000, 420.000000, "100/100");
	PlayerTextDrawFont(playerid, thirstText[playerid], 1);
	PlayerTextDrawLetterSize(playerid, thirstText[playerid], 0.150000, 0.850000);
	PlayerTextDrawTextSize(playerid, thirstText[playerid], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, thirstText[playerid], 1);
	PlayerTextDrawSetShadow(playerid, thirstText[playerid], 0);
	PlayerTextDrawAlignment(playerid, thirstText[playerid], 1);
	PlayerTextDrawColour(playerid, thirstText[playerid], -1);
	PlayerTextDrawBackgroundColour(playerid, thirstText[playerid], 255);
	PlayerTextDrawBoxColor(playerid, thirstText[playerid], 50);
	PlayerTextDrawUseBox(playerid, thirstText[playerid], false);
	PlayerTextDrawSetProportional(playerid, thirstText[playerid], true);
	PlayerTextDrawSetSelectable(playerid, thirstText[playerid], false);

	diseaseIcon[playerid] = CreatePlayerTextDraw(playerid, 360.000000, 415.000000, "HUD:radar_hostpital");
	PlayerTextDrawFont(playerid, diseaseIcon[playerid], TEXT_DRAW_FONT_SPRITE_DRAW);
	PlayerTextDrawLetterSize(playerid, diseaseIcon[playerid], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, diseaseIcon[playerid], 17.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, diseaseIcon[playerid], 1);
	PlayerTextDrawSetShadow(playerid, diseaseIcon[playerid], 0);
	PlayerTextDrawAlignment(playerid, diseaseIcon[playerid], 1);
	PlayerTextDrawColour(playerid, diseaseIcon[playerid], -1);
	PlayerTextDrawBackgroundColour(playerid, diseaseIcon[playerid], 255);
	PlayerTextDrawBoxColor(playerid, diseaseIcon[playerid], 50);
	PlayerTextDrawUseBox(playerid, diseaseIcon[playerid], true);
	PlayerTextDrawSetProportional(playerid, diseaseIcon[playerid], true);
	PlayerTextDrawSetSelectable(playerid, diseaseIcon[playerid], false);

	diseaseText[playerid] = CreatePlayerTextDraw(playerid, 380.000000, 420.000000, "100/100");
	PlayerTextDrawFont(playerid, diseaseText[playerid], 1);
	PlayerTextDrawLetterSize(playerid, diseaseText[playerid], 0.150000, 0.850000);
	PlayerTextDrawTextSize(playerid, diseaseText[playerid], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, diseaseText[playerid], 1);
	PlayerTextDrawSetShadow(playerid, diseaseText[playerid], 0);
	PlayerTextDrawAlignment(playerid, diseaseText[playerid], 1);
	PlayerTextDrawColour(playerid, diseaseText[playerid], -1);
	PlayerTextDrawBackgroundColour(playerid, diseaseText[playerid], 255);
	PlayerTextDrawBoxColor(playerid, diseaseText[playerid], 50);
	PlayerTextDrawUseBox(playerid, diseaseText[playerid], false);
	PlayerTextDrawSetProportional(playerid, diseaseText[playerid], true);
	PlayerTextDrawSetSelectable(playerid, diseaseText[playerid], false);

	fuelIcon[playerid] = CreatePlayerTextDraw(playerid, 310.000000, 395.000000, "HUD:radar_impound");
	PlayerTextDrawFont(playerid, fuelIcon[playerid], TEXT_DRAW_FONT_SPRITE_DRAW);
	PlayerTextDrawLetterSize(playerid, fuelIcon[playerid], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, fuelIcon[playerid], 17.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, fuelIcon[playerid], 1);
	PlayerTextDrawSetShadow(playerid, fuelIcon[playerid], 0);
	PlayerTextDrawAlignment(playerid, fuelIcon[playerid], 1);
	PlayerTextDrawColour(playerid, fuelIcon[playerid], -1);
	PlayerTextDrawBackgroundColour(playerid, fuelIcon[playerid], 255);
	PlayerTextDrawBoxColor(playerid, fuelIcon[playerid], 50);
	PlayerTextDrawUseBox(playerid, fuelIcon[playerid], true);
	PlayerTextDrawSetProportional(playerid, fuelIcon[playerid], true);
	PlayerTextDrawSetSelectable(playerid, fuelIcon[playerid], false);

	fuelText[playerid] = CreatePlayerTextDraw(playerid, 330.000000, 400.000000, "100/100");
	PlayerTextDrawFont(playerid, fuelText[playerid], 1);
	PlayerTextDrawLetterSize(playerid, fuelText[playerid], 0.150000, 0.850000);
	PlayerTextDrawTextSize(playerid, fuelText[playerid], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, fuelText[playerid], 1);
	PlayerTextDrawSetShadow(playerid, fuelText[playerid], 0);
	PlayerTextDrawAlignment(playerid, fuelText[playerid], 1);
	PlayerTextDrawColour(playerid, fuelText[playerid], -1);
	PlayerTextDrawBackgroundColour(playerid, fuelText[playerid], 255);
	PlayerTextDrawBoxColor(playerid, fuelText[playerid], 50);
	PlayerTextDrawUseBox(playerid, fuelText[playerid], false);
	PlayerTextDrawSetProportional(playerid, fuelText[playerid], true);
	PlayerTextDrawSetSelectable(playerid, fuelText[playerid], false);

	healthText[playerid] = CreatePlayerTextDraw(playerid, 566.000000, 67.000000, "100/100");
	PlayerTextDrawFont(playerid, healthText[playerid], 1);
	PlayerTextDrawLetterSize(playerid, healthText[playerid], 0.150000, 0.850000);
	PlayerTextDrawTextSize(playerid, healthText[playerid], 400.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, healthText[playerid], 1);
	PlayerTextDrawSetShadow(playerid, healthText[playerid], 0);
	PlayerTextDrawAlignment(playerid, healthText[playerid], 1);
	PlayerTextDrawColour(playerid, healthText[playerid], -1);
	PlayerTextDrawBackgroundColour(playerid, healthText[playerid], 255);
	PlayerTextDrawBoxColor(playerid, healthText[playerid], 50);
	PlayerTextDrawUseBox(playerid, healthText[playerid], false);
	PlayerTextDrawSetProportional(playerid, healthText[playerid], true);
	PlayerTextDrawSetSelectable(playerid, healthText[playerid], false);
	return 1;
}

ShowHudForPlayer(playerid, element)
{
	PlayerTextDrawShow(playerid, infoBar[playerid]);

	switch(element)
	{
		case HUD_HUNGER:
		{
			PlayerTextDrawShow(playerid, hungerIcon[playerid]);
			PlayerTextDrawShow(playerid, hungerText[playerid]);
		}
		case HUD_THIRST:
		{
			PlayerTextDrawShow(playerid, thirstIcon[playerid]);
			PlayerTextDrawShow(playerid, thirstText[playerid]);
		}
		case HUD_DISEASE:
		{
			PlayerTextDrawShow(playerid, diseaseIcon[playerid]);
			PlayerTextDrawShow(playerid, diseaseText[playerid]);
		}
		case HUD_HEALTH:
		{
			PlayerTextDrawShow(playerid, healthText[playerid]);
		}
		case HUD_CLOCK:
		{
			TextDrawShowForPlayer(playerid, Clock);
		}
		case HUD_VEHICLE:
		{
			PlayerTextDrawShow(playerid, fuelIcon[playerid]);
			PlayerTextDrawShow(playerid, fuelText[playerid]);
		}
		case HUD_ALL:
		{
			PlayerTextDrawShow(playerid, hungerIcon[playerid]);
			PlayerTextDrawShow(playerid, hungerText[playerid]);
			PlayerTextDrawShow(playerid, thirstIcon[playerid]);
			PlayerTextDrawShow(playerid, thirstText[playerid]);
			PlayerTextDrawShow(playerid, diseaseIcon[playerid]);
			PlayerTextDrawShow(playerid, diseaseText[playerid]);
			PlayerTextDrawShow(playerid, healthText[playerid]);
			TextDrawShowForPlayer(playerid, Clock);
		}
	}
	return 1;
}

HideHudElementForPlayer(playerid, element)
{
	PlayerTextDrawShow(playerid, infoBar[playerid]);

	switch(element)
	{
		case HUD_HUNGER:
		{
			PlayerTextDrawHide(playerid, hungerIcon[playerid]);
			PlayerTextDrawHide(playerid, hungerText[playerid]);
		}
		case HUD_THIRST:
		{
			PlayerTextDrawHide(playerid, thirstIcon[playerid]);
			PlayerTextDrawHide(playerid, thirstText[playerid]);
		}
		case HUD_DISEASE:
		{
			PlayerTextDrawHide(playerid, diseaseIcon[playerid]);
			PlayerTextDrawHide(playerid, diseaseText[playerid]);
		}
		case HUD_HEALTH:
		{
			PlayerTextDrawHide(playerid, healthText[playerid]);
		}
		case HUD_CLOCK:
		{
			TextDrawHideForPlayer(playerid, Clock);
		}
		case HUD_VEHICLE:
		{
			PlayerTextDrawHide(playerid, fuelIcon[playerid]);
			PlayerTextDrawHide(playerid, fuelText[playerid]);
		}
		case HUD_ALL:
		{
			HideHudForPlayer(playerid);
		}
	}
	return 1;
}

HideHudForPlayer(playerid)
{
	PlayerTextDrawHide(playerid, infoBar[playerid]);
	PlayerTextDrawHide(playerid, hungerIcon[playerid]);
	PlayerTextDrawHide(playerid, hungerText[playerid]);
	PlayerTextDrawHide(playerid, thirstIcon[playerid]);
	PlayerTextDrawHide(playerid, thirstText[playerid]);
	PlayerTextDrawHide(playerid, diseaseIcon[playerid]);
	PlayerTextDrawHide(playerid, diseaseText[playerid]);
	PlayerTextDrawHide(playerid, fuelIcon[playerid]);
	PlayerTextDrawHide(playerid, fuelText[playerid]);
	PlayerTextDrawHide(playerid, healthText[playerid]);
	TextDrawHideForPlayer(playerid, Clock);
	return 1;
}

DestroyHudForPlayer(playerid)
{
	PlayerTextDrawDestroy(playerid, infoBar[playerid]);
	PlayerTextDrawDestroy(playerid, hungerIcon[playerid]);
	PlayerTextDrawDestroy(playerid, hungerText[playerid]);
	PlayerTextDrawDestroy(playerid, thirstIcon[playerid]);
	PlayerTextDrawDestroy(playerid, thirstText[playerid]);
	PlayerTextDrawDestroy(playerid, diseaseIcon[playerid]);
	PlayerTextDrawDestroy(playerid, diseaseText[playerid]);
	PlayerTextDrawDestroy(playerid, fuelIcon[playerid]);
	PlayerTextDrawDestroy(playerid, fuelText[playerid]);
	PlayerTextDrawDestroy(playerid, healthText[playerid]);
	return 1;
}

UpdateHudElementForPlayer(playerid, hudElement)
{
	new string[128];
	switch(hudElement)
	{
		case HUD_HUNGER:
		{
			/*
			* Hunger
			*/
			format(string, sizeof string, "%d/%d", player[playerid][hunger], player[playerid][maxHunger]);
			PlayerTextDrawSetString(playerid, hungerText[playerid], string);
		}
		case HUD_THIRST:
		{
			/*
			* Thirst
			*/
			format(string, sizeof string, "%d/%d", player[playerid][thirst], player[playerid][maxThirst]);
			PlayerTextDrawSetString(playerid, thirstText[playerid], string);
		}
		case HUD_DISEASE:
		{
			/*
			* Disease
			*/
			format(string, sizeof string, "%d/%d", player[playerid][disease], player[playerid][maxDisease]);
			PlayerTextDrawSetString(playerid, diseaseText[playerid], string);
		}
		case HUD_VEHICLE:
		{
			/*
			* Vehicle fuel
			*/
			format(string, sizeof string, "%d/%d", serverVehicle[player[playerid][lastInVehId]][vehFuel], serverVehicle[player[playerid][lastInVehId]][maxFuel]);
			PlayerTextDrawSetString(playerid, fuelText[playerid], string);
		}
		case HUD_HEALTH:
		{
			/*
			* Health
			*/
			GetPlayerHealth(playerid, player[playerid][health]);
			format(string, sizeof string, "%d/%d", floatround(player[playerid][health]), floatround(player[playerid][maxHealth]));
			PlayerTextDrawSetString(playerid, healthText[playerid], string);
		}
		case HUD_INFO:
		{
			/*
			* Info Bar for EXP, level etc.
			*/
			if(player[playerid][iszombie] == 1)
			{
				format(string, sizeof string, "ID:_%d_I_LEVEL:_%d_I_MUTATION_POINTS:_%d_I_EXP:_%d/%d", playerid, player[playerid][level], player[playerid][perkPoints], player[playerid][exp], expForNextLevel[player[playerid][level]]);
				PlayerTextDrawSetString(playerid, infoBar[playerid], string);
			}
			else
			{
				format(string, sizeof string, "ID:_%d_I_LEVEL:_%d_I_PERK_POINTS:_%d_I_EXP:_%d/%d", playerid, player[playerid][level], player[playerid][perkPoints], player[playerid][exp], expForNextLevel[player[playerid][level]]);
				PlayerTextDrawSetString(playerid, infoBar[playerid], string);
			}
		}
	}
	return 1;
}