// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - PERK SYSTEM
// ============================================================================
/*
* MODULE: Perks
* PURPOSE: Human and zombie perk unlock/upgrade system
* 
* DEPENDENCIES:
* - core/config.pwn
* - core/constants.pwn
* - core/player_data.pwn
* - core/database.pwn
* - utilities/messaging.pwn
* 
* PUBLIC FUNCTIONS:
* Human Perks:
* - TryUnlockTinkererPerk() - Unlock/upgrade tinkerer perk (5 levels)
* - TryUnlockMechanicPerk() - Unlock/upgrade mechanic perk (5 levels, 5% repair discount)
* - TryUnlockMedicPerk() - Unlock/upgrade medic perk (5 levels, 2% healing boost per level)
* - TryUnlockGourmetPerk() - Unlock/upgrade gourmet perk (5 levels, 2% food/drink boost per level)
* 
* Zombie Perks:
* - TryUpgradeHpSkill() - Increase max HP by 10% (5 levels)
* - TryUpgradeJumpSkill() - Unlock higher jump ability
* - TryUpgradeUnarmedSkill() - Increase melee damage (5 levels)
* - TryUpgradeBiteSkill() - Increase bite disease damage (5 levels)
* - TryUnlockCombustSkill() - Explode on death dealing damage
* - TryUnlockStunSkill() - Stun nearby player (30s cooldown)
* - TryUnlockGrabSkill() - Pull distant player closer (30s cooldown)
* - TryUnlockBorrowedStrengthSkill() - Trade HP for damage
* - TryUnlockSuperJumpSkill() - Super jump at cost of 50HP
* - TryUnlockCorneredSkill() - Damage boost below 30% HP
* - TryUnlockHuntSkill() - Focus target for damage boost/resistance
* 
* Zombie Perk Actions:
* - Grab() - Pull furthest player within 10 units
* - Stun() - Stun closest player and deal 10 damage
* - Combust() - Explode on death dealing 20 damage in 6 unit radius
* - Bite() - Bite closest player for damage and disease
* - SuperJump() - Jump high at cost of 50 HP
* 
* DESCRIPTION:
* Manages the entire perk progression system including:
* - Perk point checking and consumption
* - Database persistence
* - HUD updates
* - Skill level tracking
* - Active ability cooldowns
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_PERKS_INCLUDED
#define MODULE_PERKS_INCLUDED

// ============================================================================
// HUMAN PERKS
// ============================================================================

TryUnlockTinkererPerk(playerid)
{
    if (player[playerid][tinkererSkillLevel] >= 5)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the maximum level of this skill.");
        return 0;
    }

    // Calculate required points for next level (level 1 = 1 point, level 2 = 2 points, etc.)
    new nextLevel = player[playerid][tinkererSkillLevel] + 1;
    new requiredPoints = nextLevel;

    // Check if player has enough perk points
    if (player[playerid][perkPoints] < requiredPoints)
    {
        new string[128];
        format(string, sizeof(string), "You need %d perk point%s to unlock level %d of this skill.", 
            requiredPoints, (requiredPoints == 1) ? "" : "s", nextLevel);
        SendClientMessage(playerid, COLOR_YELLOW, string);
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints] -= requiredPoints;

    // Increase the tinkerer skill level by 1
    player[playerid][tinkererSkillLevel]++;

    // Update database
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `tinkererskilllevel` = `tinkererskilllevel` + 1, `perkpoints` = `perkpoints` - %d WHERE `owner` = %d AND `name` = '%e'",
        requiredPoints, player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);

    switch (player[playerid][tinkererSkillLevel])
    {
        case 1: SendClientMessage(playerid, COLOR_RP_PURPLE, "You feel a spark of ingenuity ignite within you."),
                SendClientMessage(playerid, COLOR_GREEN, "Tinkerer skill 1/5");
        case 2: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your mind sharpens, seeing new ways to mend and modify."),
                SendClientMessage(playerid, COLOR_GREEN, "Tinkerer skill 2/5");
        case 3: SendClientMessage(playerid, COLOR_RP_PURPLE, "A surge of creativity flows through you, enhancing your craft."),
                SendClientMessage(playerid, COLOR_GREEN, "Tinkerer skill 3/5");
        case 4: SendClientMessage(playerid, COLOR_RP_PURPLE, "You become a master of improvisation, turning scraps into wonders."),
                SendClientMessage(playerid, COLOR_GREEN, "Tinkerer skill 4/5");
        case 5: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your inventive spirit knows no bounds - you are a true Tinkerer."),
                SendClientMessage(playerid, COLOR_GREEN, "Tinkerer skill 5/5");
    }
    return 1;
}

TryUnlockMechanicPerk(playerid)
{
    if (player[playerid][mechanicSkillLevel] >= 5)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the maximum level of this skill.");
        return 0;
    }

    // Calculate required points for next level (level 1 = 1 point, level 2 = 2 points, etc.)
    new nextLevel = player[playerid][mechanicSkillLevel] + 1;
    new requiredPoints = nextLevel;

    // Check if player has enough perk points
    if (player[playerid][perkPoints] < requiredPoints)
    {
        new string[128];
        format(string, sizeof(string), "You need %d perk point%s to unlock level %d of this skill.", 
            requiredPoints, (requiredPoints == 1) ? "" : "s", nextLevel);
        SendClientMessage(playerid, COLOR_YELLOW, string);
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints] -= requiredPoints;

    // Increase the mechanic skill level by 1
    player[playerid][mechanicSkillLevel]++;

    // Update database
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `mechanicskilllevel` = `mechanicskilllevel` + 1, `perkpoints` = `perkpoints` - %d WHERE `owner` = %d AND `name` = '%e'",
        requiredPoints, player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);

    switch (player[playerid][mechanicSkillLevel])
    {
        case 1: SendClientMessage(playerid, COLOR_RP_PURPLE, "You gain a basic understanding of vehicle mechanics."),
                SendClientMessage(playerid, COLOR_GREEN, "Mechanic skill 1/5 - 5% scrap discount on vehicle repairs");
        case 2: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your mechanical skills improve, allowing for quicker repairs."),
                SendClientMessage(playerid, COLOR_GREEN, "Mechanic skill 2/5 - 10% scrap discount on vehicle repairs");
        case 3: SendClientMessage(playerid, COLOR_RP_PURPLE, "You become adept at diagnosing and fixing vehicle issues."),
                SendClientMessage(playerid, COLOR_GREEN, "Mechanic skill 3/5 - 15% scrap discount on vehicle repairs");
        case 4: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your expertise in mechanics allows for efficient restorations."),
                SendClientMessage(playerid, COLOR_GREEN, "Mechanic skill 4/5 - 20% scrap discount on vehicle repairs");
        case 5: SendClientMessage(playerid, COLOR_RP_PURPLE, "You are a master mechanic, capable of reviving even the most broken vehicles."),
                SendClientMessage(playerid, COLOR_GREEN, "Mechanic skill 5/5 - 25% scrap discount on vehicle repairs");
    }
    return 1;
}

TryUnlockMedicPerk(playerid)
{
    if (player[playerid][medicSkillLevel] >= 5)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the maximum level of this skill.");
        return 0;
    }

    // Calculate required points for next level (level 1 = 1 point, level 2 = 2 points, etc.)
    new nextLevel = player[playerid][medicSkillLevel] + 1;
    new requiredPoints = nextLevel;

    // Check if player has enough perk points
    if (player[playerid][perkPoints] < requiredPoints)
    {
        new string[128];
        format(string, sizeof(string), "You need %d perk point%s to unlock level %d of this skill.", 
            requiredPoints, (requiredPoints == 1) ? "" : "s", nextLevel);
        SendClientMessage(playerid, COLOR_YELLOW, string);
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints] -= requiredPoints;

    // Increase the medic skill level by 1
    player[playerid][medicSkillLevel]++;

    // Update database
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `medicskilllevel` = `medicskilllevel` + 1, `perkpoints` = `perkpoints` - %d WHERE `owner` = %d AND `name` = '%e'",
        requiredPoints, player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);

    switch (player[playerid][medicSkillLevel])
    {
        case 1: SendClientMessage(playerid, COLOR_RP_PURPLE, "You learn the basics of first aid and medicine."),
                SendClientMessage(playerid, COLOR_GREEN, "Medic skill 1/5 - 2% increased healing from medical items");
        case 2: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your knowledge of treating wounds deepens."),
                SendClientMessage(playerid, COLOR_GREEN, "Medic skill 2/5 - 4% increased healing from medical items");
        case 3: SendClientMessage(playerid, COLOR_RP_PURPLE, "You become skilled at diagnosing and treating illness."),
                SendClientMessage(playerid, COLOR_GREEN, "Medic skill 3/5 - 6% increased healing from medical items");
        case 4: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your medical expertise allows you to maximize treatment effectiveness."),
                SendClientMessage(playerid, COLOR_GREEN, "Medic skill 4/5 - 8% increased healing from medical items");
        case 5: SendClientMessage(playerid, COLOR_RP_PURPLE, "You are a master healer, able to restore health with remarkable efficiency."),
                SendClientMessage(playerid, COLOR_GREEN, "Medic skill 5/5 - 10% increased healing from medical items");
    }
    return 1;
}

TryUnlockGourmetPerk(playerid)
{
    if (player[playerid][gourmetSkillLevel] >= 5)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the maximum level of this skill.");
        return 0;
    }

    // Calculate required points for next level (level 1 = 1 point, level 2 = 2 points, etc.)
    new nextLevel = player[playerid][gourmetSkillLevel] + 1;
    new requiredPoints = nextLevel;

    // Check if player has enough perk points
    if (player[playerid][perkPoints] < requiredPoints)
    {
        new string[128];
        format(string, sizeof(string), "You need %d perk point%s to unlock level %d of this skill.", 
            requiredPoints, (requiredPoints == 1) ? "" : "s", nextLevel);
        SendClientMessage(playerid, COLOR_YELLOW, string);
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints] -= requiredPoints;

    // Increase the gourmet skill level by 1
    player[playerid][gourmetSkillLevel]++;

    // Update database
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `gourmetskilllevel` = `gourmetskilllevel` + 1, `perkpoints` = `perkpoints` - %d WHERE `owner` = %d AND `name` = '%e'",
        requiredPoints, player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);

    switch (player[playerid][gourmetSkillLevel])
    {
        case 1: SendClientMessage(playerid, COLOR_RP_PURPLE, "You learn to savor every morsel, extracting more nourishment."),
                SendClientMessage(playerid, COLOR_GREEN, "Gourmet skill 1/5 - 2% increased benefits from food and drink");
        case 2: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your refined palate allows you to gain more from each meal."),
                SendClientMessage(playerid, COLOR_GREEN, "Gourmet skill 2/5 - 4% increased benefits from food and drink");
        case 3: SendClientMessage(playerid, COLOR_RP_PURPLE, "You've become adept at maximizing nutritional value."),
                SendClientMessage(playerid, COLOR_GREEN, "Gourmet skill 3/5 - 6% increased benefits from food and drink");
        case 4: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your body efficiently processes every nutrient."),
                SendClientMessage(playerid, COLOR_GREEN, "Gourmet skill 4/5 - 8% increased benefits from food and drink");
        case 5: SendClientMessage(playerid, COLOR_RP_PURPLE, "You are a survival gourmet, able to thrive on minimal rations."),
                SendClientMessage(playerid, COLOR_GREEN, "Gourmet skill 5/5 - 10% increased benefits from food and drink");
    }
    return 1;
}

// ============================================================================
// ZOMBIE PERKS
// ============================================================================

TryUpgradeHpSkill(playerid)
{
    if (player[playerid][unlockedHpIncreaseSkill] >= 5)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the maximum level of this skill.");
        return 0;
    }

    // Calculate required points for next level (level 1 = 1 point, level 2 = 2 points, etc.)
    new nextLevel = player[playerid][unlockedHpIncreaseSkill] + 1;
    new requiredPoints = nextLevel;

    // Check if player has enough perk points
    if (player[playerid][perkPoints] < requiredPoints)
    {
        new string[128];
        format(string, sizeof(string), "You need %d mutation point%s to unlock level %d of this skill.", 
            requiredPoints, (requiredPoints == 1) ? "" : "s", nextLevel);
        SendClientMessage(playerid, COLOR_YELLOW, string);
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints] -= requiredPoints;

    // Increase max health by 10% of initial max health
    player[playerid][maxHealth] += INITIAL_MAX_HEALTH_ZED * 0.10;

    // Set current health to new max health
    player[playerid][health] = player[playerid][maxHealth];

    // Update the max health, health, skillcount, and perk points in the database
    new query[512];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `maxhealth` = %f, `health` = %f, `unlockedhpinc` = `unlockedhpinc` + 1, `perkpoints` = `perkpoints` - %d WHERE `owner` = %d AND `name` = '%e'",
        player[playerid][maxHealth], player[playerid][health], requiredPoints, player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Apply the changes in-game
    SetPlayerMaxHealth(playerid, player[playerid][maxHealth]);
    SetPlayerHealth(playerid, player[playerid][health]);

    // Update HUD
    UpdateHudElementForPlayer(playerid, HUD_HEALTH);
    UpdateHudElementForPlayer(playerid, HUD_INFO);

    switch (player[playerid][unlockedHpIncreaseSkill])
    {
        case 0: SendClientMessage(playerid, COLOR_RP_PURPLE, "A faint pulse of strength returns to your limbs."),
                SendClientMessage(playerid, COLOR_GREEN, "HP increase 1/5");
        case 1: SendClientMessage(playerid, COLOR_RP_PURPLE, "You steady yourself, feeling less fragile."),
                SendClientMessage(playerid, COLOR_GREEN, "HP increase 2/5");
        case 2: SendClientMessage(playerid, COLOR_RP_PURPLE, "A dark vigor spreads through your decaying form."),
                SendClientMessage(playerid, COLOR_GREEN, "HP increase 3/5");
        case 3: SendClientMessage(playerid, COLOR_RP_PURPLE, "You stand taller, the rot no longer slowing you."),
                SendClientMessage(playerid, COLOR_GREEN, "HP increase 4/5");
        case 4: SendClientMessage(playerid, COLOR_RP_PURPLE, "You are reborn in death - relentless, unbreakable."),
                SendClientMessage(playerid, COLOR_GREEN, "HP increase 5/5");
    }

    player[playerid][unlockedHpIncreaseSkill]++;

    return 1;
}

TryUpgradeJumpSkill(playerid)
{
    if(player[playerid][unlockedJumpSkill])
	{
	    SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the Jump skill.");
        return 0;
	}

    // Check if player has perk points
    if (player[playerid][perkPoints] < 1)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You do not have enough mutation points to unlock this skill.");
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints]--;
	
    player[playerid][unlockedJumpSkill] = true;

	// Lower gravity for higher jumps
	SetPlayerGravity(playerid, JUMP_SKILL_GRAVITY);

	// Save skill unlock to DB
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `unlockedjump` = 1, `perkpoints` = `perkpoints` - 1 WHERE `owner` = %d AND `name` = '%e'",
        player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);

	SendClientMessage(playerid, COLOR_RP_PURPLE, "Rotting muscles shift and tighten - your body learns to spring forward..");
    SendClientMessage(playerid, COLOR_GREEN, "You have unlocked the jump skill! You can now now jump higher.");
    return 1;
}

TryUpgradeUnarmedSkill(playerid)
{
    if (player[playerid][unlockedUnarmedSkill] >= 5)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the maximum level of this skill.");
        return 0;
    }

    // Calculate required points for next level (level 1 = 1 point, level 2 = 2 points, etc.)
    new nextLevel = player[playerid][unlockedUnarmedSkill] + 1;
    new requiredPoints = nextLevel;

    // Check if player has enough perk points
    if (player[playerid][perkPoints] < requiredPoints)
    {
        new string[128];
        format(string, sizeof(string), "You need %d mutation point%s to unlock level %d of this skill.", 
            requiredPoints, (requiredPoints == 1) ? "" : "s", nextLevel);
        SendClientMessage(playerid, COLOR_YELLOW, string);
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints] -= requiredPoints;
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `unlockedunarmed` = `unlockedunarmed` + 1, `perkpoints` = `perkpoints` - %d WHERE `owner` = %d AND `name` = '%e'",
        requiredPoints, player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);

    switch (player[playerid][unlockedUnarmedSkill])
    {
        case 0: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your claws scrape with more bite, tearing flesh just a little deeper."),
                SendClientMessage(playerid, COLOR_GREEN, "Unarmed upgrade 1/5");
        case 1: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your strikes rend sinew and bone with growing hunger."),
                SendClientMessage(playerid, COLOR_GREEN, "Unarmed upgrade 2/5");
        case 2: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your blows now crush and shatter, like the dead rising relentless."),
                SendClientMessage(playerid, COLOR_GREEN, "Unarmed upgrade 3/5");
        case 3: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your claws rend through armor and flesh, driven by unholy fury."),
                SendClientMessage(playerid, COLOR_GREEN, "Unarmed upgrade 4/5");
        case 4: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your hands become weapons of decay, pulverizing all in your ravenous path."),
                SendClientMessage(playerid, COLOR_GREEN, "Unarmed upgrade 5/5");
    }
    player[playerid][unlockedUnarmedSkill]++;
    return 1;
}

TryUpgradeBiteSkill(playerid)
{
    if(player[playerid][unlockedBiteSkill] >= 5)
	{
		SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the maximum level of this skill.");
        return 0;
	}

    // Calculate required points for next level (level 1 = 1 point, level 2 = 2 points, etc.)
    new nextLevel = player[playerid][unlockedBiteSkill] + 1;
    new requiredPoints = nextLevel;

    // Check if player has enough perk points
    if (player[playerid][perkPoints] < requiredPoints)
    {
        new string[128];
        format(string, sizeof(string), "You need %d mutation point%s to unlock level %d of this skill.", 
            requiredPoints, (requiredPoints == 1) ? "" : "s", nextLevel);
        SendClientMessage(playerid, COLOR_YELLOW, string);
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints] -= requiredPoints;
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `unlockedbite` = `unlockedbite` + 1, `perkpoints` = `perkpoints` - %d WHERE `owner` = %d AND `name` = '%e'",
        requiredPoints, player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);
    
    switch (player[playerid][unlockedBiteSkill])
    {
        case 0: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your bite carries a faint trace of sickness, leaving victims weak and weary."),
                SendClientMessage(playerid, COLOR_GREEN, "Bite upgrade 1/5. Hold Alt+Aim near a human to bite them.");
        case 1: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your jaws infect flesh, sowing festering sores that drain the life slowly."),
                SendClientMessage(playerid, COLOR_GREEN, "Bite upgrade 2/5. Hold Alt+Aim near a human to bite them.");
        case 2: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your bite spreads vile disease, twisting flesh and mind alike with creeping rot."),
                SendClientMessage(playerid, COLOR_GREEN, "Bite upgrade 3/5. Hold Alt+Aim near a human to bite them.");
        case 3: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your teeth inject a venomous plague, corrupting flesh and bone with agonizing speed."),
                SendClientMessage(playerid, COLOR_GREEN, "Bite upgrade 4/5. Hold Alt+Aim near a human to bite them.");
        case 4: SendClientMessage(playerid, COLOR_RP_PURPLE, "Your savage bite spreads unstoppable contagion, dooming victims to a gruesome, agonizing death."),
                SendClientMessage(playerid, COLOR_GREEN, "Bite upgrade 5/5. Hold Alt+Aim near a human to bite them.");
    }
    player[playerid][unlockedBiteSkill]++;
    return 1;
}

TryUnlockCombustSkill(playerid)
{
    if(player[playerid][unlockedCombustSkill])
	{
		SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the combust skill.");
        return 0;
	}

    // Check if player has perk points
    if (player[playerid][perkPoints] < 1)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You do not have enough mutation points to unlock this skill.");
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints]--;

	player[playerid][unlockedCombustSkill] = true;
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `unlockedcombust` = 1, `perkpoints` = `perkpoints` - 1 WHERE `owner` = %d AND `name` = '%e'",
        player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);

	SendClientMessage(playerid, COLOR_RP_PURPLE, "A volatile change brews within you... your final moments will not go unnoticed.");
    SendClientMessage(playerid, COLOR_GREEN, "On Death: Deal damage to players around you.");
    return 1;
}

TryUnlockStunSkill(playerid)
{
    if(player[playerid][unlockedStunSkill])
    {
	SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the stun skill.");
    return 0;
    }

    // Check if player has perk points
    if (player[playerid][perkPoints] < 1)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You do not have enough mutation points to unlock this skill.");
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints]--;

    player[playerid][unlockedStunSkill] = true;
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `unlockedstun` = 1, `perkpoints` = `perkpoints` - 1 WHERE `owner` = %d AND `name` = '%e'",
        player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);
    
    SendClientMessage(playerid, COLOR_RP_PURPLE, "The infection mutates. Newfound strength in your arms. Snap Impact - halting prey with a brutal, staggering blow.");
    SendClientMessage(playerid, COLOR_GREEN, "alt+fire, 30s cooldown");
    return 1;
}

TryUnlockGrabSkill(playerid)
{
    if(player[playerid][unlockedGrabSkill])
	{
		SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the grab skill.");
        return 0;
	}

    // Check if player has perk points
    if (player[playerid][perkPoints] < 1)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You do not have enough mutation points to unlock this skill.");
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints]--;

	player[playerid][unlockedGrabSkill] = true;
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `unlockedgrab` = 1, `perkpoints` = `perkpoints` - 1 WHERE `owner` = %d AND `name` = '%e'",
        player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);
    
	SendClientMessage(playerid, COLOR_RP_PURPLE, "Twisted tendrils writhe from your flesh, hunting prey beyond your reach. (alt+crouch)");
    SendClientMessage(playerid, COLOR_GREEN, "alt+crouch to pull the furthest player to you from a max range of 10. 30s cooldown");
    return 1;
}

TryUnlockBorrowedStrengthSkill(playerid)
{
    if(player[playerid][unlockedBorrowedStrengthSkill])
    {
    SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the Borrowed Strength skill.");
    return 0;
    }

    // Check if player has perk points
    if (player[playerid][perkPoints] < 1)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You do not have enough mutation points to unlock this skill.");
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints]--;

    player[playerid][unlockedBorrowedStrengthSkill] = true;
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `unlockedbstr` = 1, `perkpoints` = `perkpoints` - 1 WHERE `owner` = %d AND `name` = '%e'",
        player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);
    
    SendClientMessage(playerid, COLOR_RP_PURPLE, "Rip life from your veins to fuel savage blows, but dont push past your limits. ");
    SendClientMessage(playerid, COLOR_GREEN, "/bstr (amount of hp) to gain gain damage equal to 25 percent of health lost.");
    return 1;
}

TryUnlockSuperJumpSkill(playerid)
{
    if(player[playerid][unlockedSuperJumpSkill])
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the Super Jump skill.");
        return 0;
    }

    // Check if player has perk points
    if (player[playerid][perkPoints] < 1)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You do not have enough mutation points to unlock this skill.");
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints]--;

    player[playerid][unlockedSuperJumpSkill] = true;
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `unlockedsjump` = 1, `perkpoints` = `perkpoints` - 1 WHERE `owner` = %d AND `name` = '%e'",
        player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);
    
    SendClientMessage(playerid, COLOR_RP_PURPLE, "A new instinct awakens within you: the ability to defy gravity itself. ");
    SendClientMessage(playerid, COLOR_GREEN, "alt+shift to sacrifice 50hp for a very strong jump");
    return 1;
}

TryUnlockCorneredSkill(playerid)
{
    if(player[playerid][unlockedCorneredSkill])
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked cornered skill.");
        return 0;
    }

    // Check if player has perk points
    if (player[playerid][perkPoints] < 1)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You do not have enough mutation points to unlock this skill.");
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints]--;

    player[playerid][unlockedCorneredSkill] = true;
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `unlockedcorn` = 1, `perkpoints` = `perkpoints` - 1 WHERE `owner` = %d AND `name` = '%e'",
        player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);
    
    SendClientMessage(playerid, COLOR_RP_PURPLE, "Near deaths grasp, your desperation fuels a deadly, relentless assault.");
    SendClientMessage(playerid, COLOR_GREEN, "Damage boost when below 30 percent HP");
    return 1;
}

TryUnlockHuntSkill(playerid)
{
    if(player[playerid][unlockedHuntSkill])
	{
		SendClientMessage(playerid, COLOR_YELLOW, "You have already unlocked the hunt skill.");
        return 0;
	}

    // Check if player has perk points
    if (player[playerid][perkPoints] < 1)
    {
        SendClientMessage(playerid, COLOR_YELLOW, "You do not have enough mutation points to unlock this skill.");
        return 0;
    }

    // Reduce perk points
    player[playerid][perkPoints]--;

    player[playerid][unlockedHuntSkill] = true;
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `characters` SET `unlockedhunt` = 1, `perkpoints` = `perkpoints` - 1 WHERE `owner` = %d AND `name` = '%e'",
        player[playerid][ID], player[playerid][chosenChar]);
    mysql_tquery(database, query);

    // Update HUD to show new perk points
    UpdateHudElementForPlayer(playerid, HUD_INFO);

	SendClientMessage(playerid, COLOR_RP_PURPLE, "A primal predatory instinct awakens within.");
    SendClientMessage(playerid, COLOR_GREEN, "/hunt (id). Deal more and take less damage to specified player. Take more and deal less damage to everyone else.");
    return 1;
}

// ============================================================================
// ZOMBIE PERK ACTIONS
// ============================================================================

Grab(playerid)
{
    if ((GetTickCount() - player[playerid][grabAntiSpam]) < GRAB_COOLDOWN)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 30 seconds between uses of this command.");
    }
    if ((GetTickCount() - player[playerid][generalAntiSpam]) < 2000){
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 2 seconds between active ability uses");
    }
    if ((GetTickCount() - player[playerid][grabbedRecently]) < 8000){
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "This player has already been grabbed in the past 8 seconds.");
    }

    new players[MAX_PLAYERS], length;
    new Float:grabberX, Float:grabberY, Float:grabberZ;
    GetPlayerPos(playerid, grabberX, grabberY, grabberZ);

    length = GetPlayers(players, sizeof(players));

    new furthestCandidates[MAX_PLAYERS];
    new candidateCount = 0;
    new Float:maxDistance = 0.0;

    for (new i = 0; i < length; i++)
    {
        new target = players[i];
        if (target == playerid || !IsPlayerConnected(target) || player[target][iszombie] == 1) continue;

        new Float:targetX, Float:targetY, Float:targetZ;
        GetPlayerPos(target, targetX, targetY, targetZ);

        new Float:distance = floatsqroot(
            floatpower(grabberX - targetX, 2.0) +
            floatpower(grabberY - targetY, 2.0) +
            floatpower(grabberZ - targetZ, 2.0)
        );

        if (distance <= GRAB_RANGE)
        {
            if (floatcmp(distance, maxDistance) > 0)
            {
                // Found new furthest
                maxDistance = distance;
                candidateCount = 1;
                furthestCandidates[0] = target;
            }
            else if (floatcmp(distance, maxDistance) == 0)
            {
                // Same distance as furthest, add to pool
                furthestCandidates[candidateCount++] = target;
            }
        }
    }

    if (candidateCount == 0)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "No valid targets to grab within 10 units.");
    }

    new target = furthestCandidates[random(candidateCount)];

    // Pull the target to the grabber's position
    SetPlayerPos(target, grabberX, grabberY+1, grabberZ);
    SendPlayerServerMessage(target, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You have been grabbed!");
    SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER, "Tendrils burst out of the infected, pulling in their prey.");
    
    // Award EXP for successful grab
    GivePlayerExp(playerid, 3);
    
    // Anti-spam timer
    SetTimerEx("grabCooldownTimer", GRAB_COOLDOWN, false, "d", playerid);
    player[playerid][grabAntiSpam] = GetTickCount();
    player[playerid][generalAntiSpam] = GetTickCount();
    player[playerid][grabbedRecently] = GetTickCount();
    return 1;
}    

Stun(playerid)
{
    if((GetTickCount() - player[playerid][stunnedRecently]) < 8000)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "This player has already been stunned in the past 8 seconds.");
    }
    if ((GetTickCount() - player[playerid][stunAntiSpam]) < STUN_COOLDOWN)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 30 seconds between uses of this command.");
    }
    if ((GetTickCount() - player[playerid][generalAntiSpam]) < 2000){
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 2 seconds between active ability uses");
    }

    new players[MAX_PLAYERS], length;
    new Float:zombieX, Float:zombieY, Float:zombieZ;
    GetPlayerPos(playerid, zombieX, zombieY, zombieZ);

    length = GetPlayers(players, sizeof(players));

    new closestCandidates[MAX_PLAYERS];
    new candidateCount = 0;
    new Float:closestDistance = 99999.0;

    for (new i = 0; i < length; i++)
    {
        new target = players[i];
        if (target == playerid || !IsPlayerConnected(target) || player[target][iszombie] == 1) continue;

        new Float:targetX, Float:targetY, Float:targetZ;
        GetPlayerPos(target, targetX, targetY, targetZ);

        //blackmagic
        new Float:distance = floatsqroot( floatpower(zombieX - targetX, 2.0) + floatpower(zombieY - targetY, 2.0) + floatpower(zombieZ - targetZ, 2.0) );

        if (distance <= STUN_RANGE)
        {
            if (floatcmp(distance, closestDistance) < 0)
            {
                // Found closer target
                closestDistance = distance;
                candidateCount = 1;
                closestCandidates[0] = target;
            }
            else if (floatcmp(distance, closestDistance) == 0)
            {
                // Same distance as closest, add to pool
                closestCandidates[candidateCount++] = target;
            }
        }
    }

    if (candidateCount == 0)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "No valid targets nearby to stun.");
    }
    new target = closestCandidates[random(candidateCount)];

    // Stun logic
    player[target][health] -= 10;
    SetPlayerHealth(target, player[target][health]);
    UpdateHudElementForPlayer(target, HUD_HEALTH);
    SetTimerEx("SpawnTimer", 1000, false, "d", target);
    TogglePlayerControllable(target, false);
    SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER, "The infected crashes into their victim with overwhelming force, leaving them dazed.");
    SendPlayerServerMessage(target, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "You have been stunned!");
    
    // Award EXP for successful stun
    GivePlayerExp(playerid, 4);
    
    SetTimerEx("stunCooldownTimer", STUN_COOLDOWN, false, "d", playerid);
    // Update anti-spam timer
    player[playerid][stunAntiSpam] = GetTickCount();
    player[playerid][generalAntiSpam] = GetTickCount();
    player[playerid][stunnedRecently] = GetTickCount();
    return 1;
}

Combust(playerid)
{
    new players[MAX_PLAYERS];
    new length;
    new Float:zombieX, Float:zombieY, Float:zombieZ;

    GetPlayerPos(playerid, zombieX, zombieY, zombieZ);

    length = GetPlayers(players, sizeof(players));
    
    for (new i = 0; i < length; i++)
    {
        new target = players[i];

        // Skip self
        if (target == playerid || !IsPlayerConnected(target)) continue;

        new Float:targetX, Float:targetY, Float:targetZ;
        GetPlayerPos(target, targetX, targetY, targetZ);

        if (IsPlayerInRangeOfPoint(playerid, 6.0, targetX, targetY, targetZ))
        {
            //player[target][disease] = 0;
            player[target][health] -= 20;

            SetPlayerHealth(target, player[target][health]);

            UpdateHudElementForPlayer(target, HUD_HEALTH);
            //UpdateHudElementForPlayer(target, HUD_DISEASE);

            SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER, "The infected erupts in a grotesque explosion of acidic bile and razor-sharp bone fragments.");
        }
    }
}

Bite(playerid)
{
    if ((GetTickCount() - player[playerid][biteAntiSpam]) < BITE_COOLDOWN)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 15 seconds between uses of this command.");
    }
    if ((GetTickCount() - player[playerid][generalAntiSpam]) < 2000){
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Please wait 2 seconds between active ability uses");
    }
    new players[MAX_PLAYERS], length;
    new Float:zombieX, Float:zombieY, Float:zombieZ;
    GetPlayerPos(playerid, zombieX, zombieY, zombieZ);

    length = GetPlayers(players, sizeof(players));

    new closestCandidates[MAX_PLAYERS];
    new candidateCount = 0;
    new Float:closestDistance = 99999.0;

    for (new i = 0; i < length; i++)
    {
        new target = players[i];
        if (target == playerid || !IsPlayerConnected(target) || player[target][iszombie] == 1) continue;

        new Float:targetX, Float:targetY, Float:targetZ;
        GetPlayerPos(target, targetX, targetY, targetZ);

        //blackmagic
        new Float:distance = floatsqroot( floatpower(zombieX - targetX, 2.0) + floatpower(zombieY - targetY, 2.0) + floatpower(zombieZ - targetZ, 2.0) );

        if (distance <= 3.0)
        {
            if (floatcmp(distance, closestDistance) < 0)
            {
                // Found closer target
                closestDistance = distance;
                candidateCount = 1;
                closestCandidates[0] = target;
            }
            else if (floatcmp(distance, closestDistance) == 0)
            {
                // Same distance as closest, add to pool
                closestCandidates[candidateCount++] = target;
            }
        }
    }

    if (candidateCount == 0)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "No valid targets nearby to bite.");
    }

    new target = closestCandidates[random(candidateCount)];

    // Bite logic
    player[target][disease] -= (10 * player[playerid][unlockedBiteSkill]);
    if(player[target][disease]<0){
        player[target][disease]=0;
    }
    player[target][health] -= BITE_DAMAGE;

    SetPlayerHealth(target, player[target][health]);

    UpdateHudElementForPlayer(target, HUD_HEALTH);
    UpdateHudElementForPlayer(target, HUD_DISEASE);
    SendProxMessage(playerid, COLOR_RP_PURPLE, 30.0, PROXY_MSG_TYPE_OTHER,
        "Fractured teeth pierce flesh and inoculate disease.");

    SendPlayerServerMessage(target, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Something rips a chunk out of you!");
    
    // Award EXP for successful bite
    GivePlayerExp(playerid, 5);
    
    // Update anti-spam timer
    SetTimerEx("biteCooldownTimer", BITE_COOLDOWN, false, "d", playerid);
    player[playerid][biteAntiSpam] = GetTickCount();
    player[playerid][generalAntiSpam] = GetTickCount();
    
    return 1;
}

SuperJump(playerid)
{
    if ((GetTickCount() - player[playerid][borrowedSuperJumpAntiSpam]) < 5000)
    {
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED,
        "Please wait 5 seconds between uses of this command.");
    }
    
    new Float:damage = 50;
    player[playerid][health] -= damage;
    SetPlayerHealth(playerid, player[playerid][health]);
    UpdateHudElementForPlayer(playerid, HUD_HEALTH);

    player[playerid][borrowedSuperJumpAntiSpam] = GetTickCount();
    SetPlayerVelocity(playerid, 0.0, 0.0, 5); 
    SetTimerEx("superJumpCooldownTimer", 5000, false, "d", playerid);
    SendProxMessage(playerid, COLOR_RED, 30.0, PROXY_MSG_TYPE_OTHER,
        "Bones crack, tendons shred, the earth breaks beneath their leap");

    return 1;
}

#endif // MODULE_PERKS_INCLUDED
