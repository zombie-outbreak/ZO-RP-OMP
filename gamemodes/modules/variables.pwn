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
    bool:infection,
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
    bool:hasDied,
    unlockedHpIncreaseSkill,
    bool:unlockedJumpSkill,
    unlockedUnarmedSkill,
    unlockedBiteSkill,
    bool:unlockedCombustSkill,
    bool:unlockedStunSkill,
    bool:unlockedGrabSkill,
    bool:unlockedBorrowedStrengthSkill,
    bool:unlockedBorrowedStrengthSkillActive,
    Float:unlockedBorrowedStrengthSkillDamage,
    bool:unlockedSuperJumpSkill,
    bool:unlockedCorneredSkill,
    bool:unlockedHuntSkill,
    bool:huntActive,
    huntTarget,
	
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
    biteAntiSpam,
    stunAntiSpam,
    grabAntiSpam,
    borrowedStrengthAntiSpam,
    borrowedSuperJumpAntiSpam,
    generalAntiSpam,
    stunnedRecently,
    grabbedRecently,
    characterCount,
    vendingAntiSpam,

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
    admChosenTableName[32],
    admChosenTableId,
    admChosenChanceNode,
    
};
new player[MAX_PLAYERS][E_PLAYERS];
new expForNextLevel[MAX_LEVELS] = // EXP to next level = n^3
{
    // exp needed to reach...
    0, // this is level 1 which is the base level of a character
    8, // level 2
    27, // level 3... and so on
    64,
    125,
    216,
    343,
    512,
    729,
    1000,
    1331,
    1728,
    2197,
    2744,
    3375,
    4096,
    4913,
    5832,
    6859,
    8000,
    9261,
    10648,
    12167,
    13824,
    15625,
    17576,
    19683,
    21952,
    24389,
    27000
    /*29791,
    32768,
    35937,
    39304,
    42875,
    46656,
    50653,
    54872,
    59319,
    64000,
    68921,
    74088,
    79507,
    85184,
    91125,
    97336,
    103823,
    110592,
    117649,
    125000,
    132651,
    140608,
    148877,
    157464,
    166375,
    175616,
    185193,
    195112,
    205379,
    216000,
    226981,
    238328,
    250047,
    262144,
    274625,
    287496,
    300763,
    314432,
    328509,
    343000,
    357911,
    373248,
    389017,
    405224,
    421875,
    438976,
    456533,
    474552,
    493039,
    512000,
    531441,
    551368,
    571787,
    592704,
    614125,
    636056,
    658503,
    681472,
    704969,
    729000,
    753571,
    778688,
    804357,
    830584,
    857375,
    884736,
    912673,
    941192,
    970299*/
};

/*
* Interior Data
*/
new serverInteriorCount = 0;
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
new interiorEnterPickup[MAX_SERVER_INTERIORS];
new interiorExitPickup[MAX_SERVER_INTERIORS];

/*
* Faction Data
*/
new serverFactionCount = 0;
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
* Inventory
*/
new serverItemCount = 0;
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
new inventoryItems[MAX_ITEMS][inventoryItemData];
new playerInventory[MAX_PLAYERS][MAX_ITEMS];
new playerInventoryResource[MAX_PLAYERS][MAX_ITEMS];

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
* Fuel Pump Locations
*/
new fuelPumpCount = 0;
new Float:fuelPump[MAX_FUEL_PUMPS][3];
new Text3D:fillTextLabel[MAX_FUEL_PUMPS];

/*
* Loot tables - corresponds to item IDs found in inventoryItems.
* 0 for no item
* 1+ for an item
*/
new lootTableCount = 0;
new lootTableName[MAX_LOOT_TABLES][32];
new lootTable[MAX_LOOT_TABLES][CHANCE];

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