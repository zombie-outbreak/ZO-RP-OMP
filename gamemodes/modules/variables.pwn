/*
* Zombie Outbreak Roleplay
* (C) 2025 Zombie Outbreak Development Contributors
* GNU General Public License v3.0
*/
new DB:database;

/*
* Player Data
*/
enum E_PLAYERS
{
	ID,
	Name[MAX_PLAYER_NAME],
	Password[BCRYPT_HASH_LENGTH],
    ip[16],
    serial[128],
	admin,
	vip,
	isNew,
	isBanned,
    regdate,
    lastlogin,

    /*
    * Character Variables
    */
    charid,
    charname[MAX_PLAYER_NAME],
    age,
    description[128],
    skin,
    iszombie,
    Float:health,
    Float:maxHealth,
    hunger,
    maxHunger,
    thirst,
    maxThirst,
    disease,
    maxDisease,
    spawned,
    Float:pPos[4],
    plrinterior,
    world,
    level,
    exp,
    perkPoints,
    plrFaction,
    factionrank,
    wepSlot[13],

	/*
	* Not Saved
	*/
	bool:IsLoggedIn,
	LoginAttempts,
	LoginTimer,
    tmpIp[16],
	tmpSerial[128],
    chosenItemId,
    chosenVendorItemId,
    chosenItem[128],
    chosenChar[MAX_PLAYER_NAME],
    currentSkin,
    skinActor,
    bool:isSpawned,
    bool:usingloopinganim,
    hungerTimer,
    thirstTimer,
    diseaseTimer,
    fuelTimer,
    fillVehicleTimer,
    invItemsCount, // dynamic as the player picks/drops/gives away items
    bool:backpackEquipped, // dynamic and changes based on if a player has a backpack equipped
    chosenProperty[64],
    bool:chosenZombie,
    facChosenChar[MAX_PLAYER_NAME],
    facChosenRankId,
    facInviteId,
    facInvitedBy[MAX_PLAYER_NAME],
    Float:adminPos[4],
    lastInVehId,
    Float:tmpVehPos[3],
    antiMessageSpam,
    invGivePlayerId,
    engineAntiSpam,

    /*
    * Admin fly
    */
    bool:isflying,
    flyTimer,
    Float:flyPos[4],
    
    /*
    * Property Variables (used to be slower pVars)
    */
    createIntStep,
    currentInterior,
    atProperty,
    tmpIntName[64],
    
};
new player[MAX_PLAYERS][E_PLAYERS];

/*
* NpcData
*/
enum E_NPCS
{
    npcId,
};
new serverNpc[MAX_NPCS][E_NPCS];

/*
* Interior Data
*/
enum E_INTERIORS
{
    intId,
    intName[64],
    intWorld,
    intExitWorld,
    intVirWorld,
    intExitVirWorld,
    intPrice,
    intType,
    intOwner[MAX_PLAYER_NAME],
    intLocked,
    Float:intEnter[7],
    Float:intExit[7],
    mapIcon,
};
new srvInterior[MAX_SERVER_INTERIORS][E_INTERIORS];
new serverInteriorCount = 0;
new interiorEnterPickup[MAX_SERVER_INTERIORS];
new interiorExitPickup[MAX_SERVER_INTERIORS];

/*
* NPC Data
*/
/*enum npcData
{
    npcId,
    npcName[MAX_PLAYER_NAME],
    npcSkin,
    Float:npcX,
    Float:npcY,
    Float:npcZ,
    Float:npcA,
    npcInterior,
    npcWorld,
}
new npcVariable[MAX_PLAYERS][npcData];
new Text3D:npcNameTag[MAX_PLAYERS];*/

/*
* Faction Data
*/
enum E_FACTIONS
{
    facId,
    facName[64],
    facCreator[MAX_PLAYER_NAME],
    facRankId[MAX_FACTION_RANKS],
    facMoney,
}
new faction[MAX_FACTIONS][E_FACTIONS];
new factionRankName[MAX_FACTIONS][MAX_FACTION_RANKS][64];

/*
* Vehicle Data
*/
enum E_VEHICLES
{
    vehId,
    vehOwner[64], // it is either a player or a faction so maximum is the same as the maximum faction name
    vehPos[4],
    Float:vehHealth,
    vehFuel,
    maxFuel,
    panels,
    doors,
    lights,
    tires,
    bool:engine, // true for on, false for off
    bool:isBeingFilled,
}
new serverVehicle[MAX_VEHICLES][E_VEHICLES];

/*
* Map Conversion Variables
*/
new cTempBuffer[1024];
new VehicleColoursTableRGBA[256] = 
{
    // The existing colours from San Andreas
    0x000000FF, 0xF5F5F5FF, 0x2A77A1FF, 0x840410FF, 0x263739FF, 0x86446EFF, 0xD78E10FF, 0x4C75B7FF, 0xBDBEC6FF, 0x5E7072FF,
    0x46597AFF, 0x656A79FF, 0x5D7E8DFF, 0x58595AFF, 0xD6DAD6FF, 0x9CA1A3FF, 0x335F3FFF, 0x730E1AFF, 0x7B0A2AFF, 0x9F9D94FF,
    0x3B4E78FF, 0x732E3EFF, 0x691E3BFF, 0x96918CFF, 0x515459FF, 0x3F3E45FF, 0xA5A9A7FF, 0x635C5AFF, 0x3D4A68FF, 0x979592FF,
    0x421F21FF, 0x5F272BFF, 0x8494ABFF, 0x767B7CFF, 0x646464FF, 0x5A5752FF, 0x252527FF, 0x2D3A35FF, 0x93A396FF, 0x6D7A88FF,
    0x221918FF, 0x6F675FFF, 0x7C1C2AFF, 0x5F0A15FF, 0x193826FF, 0x5D1B20FF, 0x9D9872FF, 0x7A7560FF, 0x989586FF, 0xADB0B0FF,
    0x848988FF, 0x304F45FF, 0x4D6268FF, 0x162248FF, 0x272F4BFF, 0x7D6256FF, 0x9EA4ABFF, 0x9C8D71FF, 0x6D1822FF, 0x4E6881FF,
    0x9C9C98FF, 0x917347FF, 0x661C26FF, 0x949D9FFF, 0xA4A7A5FF, 0x8E8C46FF, 0x341A1EFF, 0x6A7A8CFF, 0xAAAD8EFF, 0xAB988FFF,
    0x851F2EFF, 0x6F8297FF, 0x585853FF, 0x9AA790FF, 0x601A23FF, 0x20202CFF, 0xA4A096FF, 0xAA9D84FF, 0x78222BFF, 0x0E316DFF,
    0x722A3FFF, 0x7B715EFF, 0x741D28FF, 0x1E2E32FF, 0x4D322FFF, 0x7C1B44FF, 0x2E5B20FF, 0x395A83FF, 0x6D2837FF, 0xA7A28FFF,
    0xAFB1B1FF, 0x364155FF, 0x6D6C6EFF, 0x0F6A89FF, 0x204B6BFF, 0x2B3E57FF, 0x9B9F9DFF, 0x6C8495FF, 0x4D8495FF, 0xAE9B7FFF,
    0x406C8FFF, 0x1F253BFF, 0xAB9276FF, 0x134573FF, 0x96816CFF, 0x64686AFF, 0x105082FF, 0xA19983FF, 0x385694FF, 0x525661FF,
    0x7F6956FF, 0x8C929AFF, 0x596E87FF, 0x473532FF, 0x44624FFF, 0x730A27FF, 0x223457FF, 0x640D1BFF, 0xA3ADC6FF, 0x695853FF,
    0x9B8B80FF, 0x620B1CFF, 0x5B5D5EFF, 0x624428FF, 0x731827FF, 0x1B376DFF, 0xEC6AAEFF, 0x000000FF,
    // SA-MP extended colours (0.3x)
    0x177517FF, 0x210606FF, 0x125478FF, 0x452A0DFF, 0x571E1EFF, 0x010701FF, 0x25225AFF, 0x2C89AAFF, 0x8A4DBDFF, 0x35963AFF,
    0xB7B7B7FF, 0x464C8DFF, 0x84888CFF, 0x817867FF, 0x817A26FF, 0x6A506FFF, 0x583E6FFF, 0x8CB972FF, 0x824F78FF, 0x6D276AFF,
    0x1E1D13FF, 0x1E1306FF, 0x1F2518FF, 0x2C4531FF, 0x1E4C99FF, 0x2E5F43FF, 0x1E9948FF, 0x1E9999FF, 0x999976FF, 0x7C8499FF,
    0x992E1EFF, 0x2C1E08FF, 0x142407FF, 0x993E4DFF, 0x1E4C99FF, 0x198181FF, 0x1A292AFF, 0x16616FFF, 0x1B6687FF, 0x6C3F99FF,
    0x481A0EFF, 0x7A7399FF, 0x746D99FF, 0x53387EFF, 0x222407FF, 0x3E190CFF, 0x46210EFF, 0x991E1EFF, 0x8D4C8DFF, 0x805B80FF,
    0x7B3E7EFF, 0x3C1737FF, 0x733517FF, 0x781818FF, 0x83341AFF, 0x8E2F1CFF, 0x7E3E53FF, 0x7C6D7CFF, 0x020C02FF, 0x072407FF,
    0x163012FF, 0x16301BFF, 0x642B4FFF, 0x368452FF, 0x999590FF, 0x818D96FF, 0x99991EFF, 0x7F994CFF, 0x839292FF, 0x788222FF,
    0x2B3C99FF, 0x3A3A0BFF, 0x8A794EFF, 0x0E1F49FF, 0x15371CFF, 0x15273AFF, 0x375775FF, 0x060820FF, 0x071326FF, 0x20394BFF,
    0x2C5089FF, 0x15426CFF, 0x103250FF, 0x241663FF, 0x692015FF, 0x8C8D94FF, 0x516013FF, 0x090F02FF, 0x8C573AFF, 0x52888EFF,
    0x995C52FF, 0x99581EFF, 0x993A63FF, 0x998F4EFF, 0x99311EFF, 0x0D1842FF, 0x521E1EFF, 0x42420DFF, 0x4C991EFF, 0x082A1DFF,
    0x96821DFF, 0x197F19FF, 0x3B141FFF, 0x745217FF, 0x893F8DFF, 0x7E1A6CFF, 0x0B370BFF, 0x27450DFF, 0x071F24FF, 0x784573FF,
    0x8A653AFF, 0x732617FF, 0x319490FF, 0x56941DFF, 0x59163DFF, 0x1B8A2FFF, 0x38160BFF, 0x041804FF, 0x355D8EFF, 0x2E3F5BFF,
    0x561A28FF, 0x4E0E27FF, 0x706C67FF, 0x3B3E42FF, 0x2E2D33FF, 0x7B7E7DFF, 0x4A4442FF, 0x28344EFF
};
new removedObjects = 0;
new removedObjectModel[MAX_REMOVED_OBJECTS];
new removedObjectLodModel[MAX_REMOVED_OBJECTS];
new Float:removedObjectPos[MAX_REMOVED_OBJECTS][3];
new removedObjectRadius[MAX_REMOVED_OBJECTS];

/*
* Quest Specific Textdraws
*/
new PlayerText:dialogueText[MAX_PLAYERS];

/*
* Player HUD
*/
new PlayerText:infoBar[MAX_PLAYERS];
new PlayerText:hungerIcon[MAX_PLAYERS];
new PlayerText:hungerText[MAX_PLAYERS];
new PlayerText:thirstIcon[MAX_PLAYERS];
new PlayerText:thirstText[MAX_PLAYERS];
new PlayerText:diseaseIcon[MAX_PLAYERS];
new PlayerText:diseaseText[MAX_PLAYERS];
new PlayerText:fuelIcon[MAX_PLAYERS];
new PlayerText:fuelText[MAX_PLAYERS];
new PlayerText:healthText[MAX_PLAYERS];
new Text:animhelper;
new	Text:Clock;

/*
* Locker locations
*/
new Float:lockerLocation[MAX_LOCKERS][3] =
{
    {-2583.5339,2359.8047,3.6328}
};

new lockerInterior[MAX_LOCKERS] =
{
    0
};

new lockerVirWorld[MAX_LOCKERS] =
{
    1002
};

/*
* Sleep Locations
*/
/*
new Float:sleepLocations[MAX_SLEEP_LOCATIONS][3] =
{
    {-2585.1775,2368.4158,3.6328}
};

new sleepInterior[MAX_SLEEP_LOCATIONS] =
{
    0
};

new sleepVirWorld[MAX_SLEEP_LOCATIONS] =
{
    1002
};
*/

/*
* Fuel Pump Locations
*/
new Float:fuelPump[MAX_FUEL_PUMPS][3] =
{
    // Redlands West fuel station
    {1602.9343,2193.6711,11.0610}, {1597.0671,2193.6724,11.0610}, {1591.2882,2193.7856,11.0610},
    {1591.2859,2204.5198,11.0610}, {1597.0685,2204.6177,11.0610}, {1602.9369,2204.5825,11.0610},
    
    // Bone County fuel station
    {602.9949,1708.2792,6.9922}, {625.0079,1677.0963,6.9922},
    
    // Emerald Isle fuel station
    {2208.6399,2469.7236,10.8203}, {2208.7542,2474.8875,10.8203}, {2208.9165,2480.4324,10.8203},
    {2195.8984,2470.0959,10.8203}, {2195.8499,2474.6213,10.8203}, {2195.7922,2480.0513,10.8203},
    
    // Strip (bottom) fuel station
    {2121.1812,914.1354,10.9609}, {2115.1523,914.0585,10.9577}, {2109.4880,914.0550,10.9565},
    {2108.7522,926.0942,10.9609}, {2114.7932,926.0942,10.9609}, {2120.6821,926.0942,10.9609}
};

/*
* Inventory
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

new inventoryItems[MAX_ITEMS][inventoryItemData] =
{
    //{id, name(singular), name(plural), description, category, healamount, wepid, ammoid, wepslot, isusable, maxresource}
    //{id, "", "", "", INV_CATEGORY_UNKNOWN, DEFAULT_HEALAMOUNT, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, false, -1}
    {0, "Invalid Item", "Invalid Items", "This is used for no items found when looting. If you're seeing this item... you shouldn't.", INV_CATEGORY_UNKNOWN, DEFAULT_HEALAMOUNT, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, false, -1},
    {1, "Scrap", "Scrap", "Some scrap metal. Might be useful for something.", CATEGORY_GENERAL, DEFAULT_HEALAMOUNT, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {2, "Candy Bar", "Candy Bars", "It might be a bit out of date by now... but it'll have to do.", CATEGORY_FOOD, 5, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {3, "Carton of Juice", "Cartons of Juice", "Freshly squeezed orange juice in a carton... or maybe it once was.", CATEGORY_DRINK, 5, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {4, "Money", "Monies", "You pay for things with it.", CATEGORY_GENERAL, DEFAULT_HEALAMOUNT, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, false, -1},
    {5, "Baseball Bat", "Baseball Bats", "Normally used for baseball games... good at smashing heads in too.", CATEGORY_WEAPONS, DEFAULT_HEALAMOUNT, WEAPON_BAT, DEFAULT_AMMO, WEAPON_SLOT_MELEE, true, -1},
    {6, "9mm Pistol", "9mm Pistols", "A pistol which fires 9mm rounds.", CATEGORY_WEAPONS, DEFAULT_HEALAMOUNT, WEAPON_COLT45, 7, WEAPON_SLOT_PISTOL, true, -1},
    {7, "9mm Round", "9mm Rounds", "Rounds of ammo used in the 9mm pistols, Uzi and Tec-9 weapons.", CATEGORY_AMMO, DEFAULT_HEALAMOUNT, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, false, -1},
    {8, "Shotgun", "Shotguns", "Good at close range. Fires 12 gauge shells.", CATEGORY_WEAPONS, DEFAULT_HEALAMOUNT, WEAPON_SHOTGUN, 9, WEAPON_SLOT_SHOTGUN, true, -1},
    {9, "12 Gauge Shell", "12 Gauge Shells", "Shells used as shotgun ammo.", CATEGORY_AMMO, DEFAULT_HEALAMOUNT, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, false, -1},
    {10, "Bandage", "Bandages", "Used to stop bleeding from minor wounds.", CATEGORY_MEDICAL, 5, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {11, "Large Medical Kit", "Large Medical Kits", "A large kit full of medical supplies which can deal with major wounds.", CATEGORY_MEDICAL, 100, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {12, "Small Medical Kit", "Small Medical Kits", "A small medical kit which can deal with small injuries.", CATEGORY_MEDICAL, 50, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {13, "Medical Syringe", "Medical Syringes", "A syringe with some form of  liquid.", CATEGORY_MEDICAL, 25, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {14, "Paracetamol", "Paracetamol", "A small tablet that helps ease pain.", CATEGORY_MEDICAL, 10, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {15, "Uzi", "Uzis", "A submachine gun with a faster fire rate than a standard pistol while still using 9mm ammo.", CATEGORY_WEAPONS, DEFAULT_HEALAMOUNT, WEAPON_UZI, 7, WEAPON_SLOT_MACHINE_GUN, true, -1},
    {16, "Shovel", "Shovels", "Good at digging things up or burying things.", CATEGORY_WEAPONS, DEFAULT_HEALAMOUNT, WEAPON_SHOVEL, DEFAULT_AMMO, WEAPON_SLOT_MELEE, true, -1},
    {17, "Desert Eagle", "Desert Eagles", "Uses .44 ammo, a heavier and more powerful handgun.", CATEGORY_WEAPONS, DEFAULT_HEALAMOUNT, WEAPON_DEAGLE, 18, WEAPON_SLOT_PISTOL, true, -1},
    {18, ".44 Round", ".44 Rounds", "Ammo used in the Desert Eagle.", CATEGORY_AMMO, DEFAULT_HEALAMOUNT, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, false, -1},
    {19, "Ration", "Rations", "A ration pack which greatly restores hunger.", CATEGORY_FOOD, DEFAULT_HEALAMOUNT, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {20, "Bottle of Water", "Bottles of Water", "Probably the most important liquid for human life.", CATEGORY_DRINK, 25, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {21, "Chocolate Bar", "Chocolate Bars", "It might not be the healthiest, but it is still tasty.", CATEGORY_FOOD, 15, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {22, "Biscuit", "Biscuits", "Very dry but it staves off hunger a little bit.", CATEGORY_FOOD, 10, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {23, "Canteen of Water", "Canteens of Water", "Bigger and heavier than a basic bottle of water, but reusable!", CATEGORY_DRINK, 45, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {24, "Empty Canteen", "Empty Canteens", "Refillable canteen for water.", CATEGORY_GENERAL, DEFAULT_HEALAMOUNT, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {25, "Canteen of Dirty Water", "Canteens of Dirty Water", "A water canteen that has been filled with dirty water.", CATEGORY_DRINK, 15, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {26, "Purification Tablet", "Purification Tablets", "A purification tablet used to purify dirty water.", CATEGORY_GENERAL, DEFAULT_HEALAMOUNT, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {27, "Antibiotic", "Antibiotics", "An Antibiotic tablet used to cure disease.", CATEGORY_MEDICAL, 10, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, -1},
    {28, "Fuel Can", "Fuel Cans", "Holds fuel for vehicles or generators.", CATEGORY_GENERAL, DEFAULT_HEALAMOUNT, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, true, 30},
    {29, "", "", "", INV_CATEGORY_UNKNOWN, DEFAULT_HEALAMOUNT, WEAPON_UNKNOWN, DEFAULT_AMMO, WEAPON_SLOT_UNKNOWN, false, -1}
};
new playerInventory[MAX_PLAYERS][MAX_ITEMS];
new playerInventoryResource[MAX_PLAYERS][MAX_ITEMS];
new lockerInventory[MAX_PLAYERS][MAX_ITEMS];

/*
* Scavenging Locations
*/
new scavAreaCount = 0;
enum E_SCAV_AREAS
{
    scavId,
    Float:scavPos[3],
    scavInterior,
    scavWorld,
    scavType,
    bool:areaActive,
}
new scavArea[MAX_SCAV_AREAS][E_SCAV_AREAS];
new Text3D:scavTextLabel[MAX_SCAV_AREAS];

/*
* Loot tables - corresponds to item IDs found in inventoryItems.
* 0 for no item
* 1+ for an item
*/
new lootTableScrap[CHANCE] =
{
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 0, 0, 0, 0, 0, 0
};

new lootTableBody[CHANCE] =
{
    1, 1, 1, 4, 24, 0, 0, 0, 0, 0,
    1, 2, 3, 4, 24, 0, 0, 0, 0, 0,
    1, 2, 3, 4, 24, 0, 0, 0, 0, 0,
    1, 2, 3, 4, 24, 0, 0, 0, 0, 0,
    1, 2, 3, 4, 24, 0, 0, 0, 0, 0,
    1, 2, 3, 4, 24, 0, 0, 0, 0, 0,
    1, 2, 3, 4, 24, 0, 0, 0, 0, 0,
    1, 2, 3, 4, 24, 0, 0, 0, 0, 0,
    1, 2, 3, 4, 24, 0, 0, 0, 0, 0,
    1, 2, 3, 4, 24, 0, 0, 0, 0, 0
};

new lootTableFoodDrink[CHANCE] =
{
    2, 2, 2, 3, 3, 3, 23, 23, 0, 0,
    2, 2, 2, 3, 3, 3, 23, 23, 0, 0,
    2, 2, 2, 3, 3, 3, 23, 23, 0, 0,
    2, 2, 2, 3, 3, 3, 23, 23, 0, 0,
    2, 2, 2, 3, 3, 3, 23, 23, 0, 0,
    2, 2, 2, 3, 3, 3, 25, 25, 0, 0,
    2, 2, 2, 3, 3, 3, 25, 25, 0, 0,
    2, 2, 2, 3, 3, 3, 25, 25, 0, 0,
    2, 2, 2, 3, 3, 3, 25, 25, 0, 0,
    2, 2, 2, 3, 3, 3, 25, 25, 0, 0
};

new lootTableWeapons[CHANCE] =
{
    0, 0, 6, 7, 7, 8, 0, 0, 9, 7,
    15, 17, 18, 0, 5, 16, 0, 0, 0,
    0, 0, 6, 7, 7, 8, 0, 0, 9, 7,
    15, 17, 18, 0, 5, 16, 0, 0, 0,
    15, 17, 18, 0, 5, 16, 0, 0, 0,
    0, 0, 6, 7, 7, 8, 0, 0, 9, 7,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

new lootTableMedical[CHANCE] =
{
    11, 10, 12, 13, 14, 0, 0, 0, 0,
    0, 10, 12, 13, 14, 0, 0, 0, 0,
    10, 10, 12, 13, 14, 0, 0, 0, 0,
    12, 10, 12, 13, 14, 0, 0, 0, 0,
    13, 10, 12, 13, 14, 0, 0, 0, 0,
    14, 10, 12, 13, 14, 0, 0, 0, 0,
    27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

new lootTableMoney[CHANCE] =
{
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
    0, 0, 0, 0, 0, 4, 4, 4, 4, 4
};

new lootTableGasStation[CHANCE] =
{
    1, 4, 28, 21, 20, 0, 0, 0, 0, 0,
    1, 4, 28, 21, 20, 0, 0, 0, 0, 0,
    1, 4, 28, 21, 20, 0, 0, 0, 0, 0,
    1, 4, 28, 21, 20, 0, 0, 0, 0, 0,
    1, 4, 28, 21, 20, 0, 0, 0, 0, 0,
    1, 4, 28, 21, 20, 0, 0, 0, 0, 0,
    1, 4, 28, 21, 20, 0, 0, 0, 0, 0,
    1, 4, 28, 21, 20, 0, 0, 0, 0, 0,
    1, 4, 28, 21, 20, 0, 0, 0, 0, 0,
    1, 4, 28, 21, 20, 0, 0, 0, 0, 0
};

/*
* Random Spawns
*/
new Float:humanSpawns[5][4] =
{
    {2087.2439,2079.7832,11.0579,269.9525},
    {2076.2598,2209.6716,10.8203,2.1941},
    {2096.7009,1286.7515,10.8203,180.1222},
    {2388.6819,991.8413,10.8203,84.0609},
    {1958.1028,1343.0325,15.3746,271.0728}
};

new Float:zombieSpawns[5][4] =
{
    {2452.8445,1281.6398,10.8210,178.8857},
    {2124.8530,888.2714,11.1797,358.2520},
    {2004.2582,1544.9500,13.5859,268.0276},
    {1607.3772,1819.2645,10.8280,359.6999},
    {1724.1140,1445.8679,10.8203,349.5623}
};