// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - PLAYER DATA
// ============================================================================
/*
* MODULE: Player Data
* PURPOSE: Core player data structures and variables
* 
* DEPENDENCIES:
* - core/config.pwn
* - core/constants.pwn
* 
* DESCRIPTION:
* Contains the main player data enum and array that stores all player
* information including:
* - Account data (ID, name, password, admin, VIP)
* - Character data (name, age, skin, health, stats)
* - Zombie/Human perks and skills
* - Temporary session variables
* - Inventory and property data
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_CORE_PLAYER_DATA_INCLUDED
#define MODULE_CORE_PLAYER_DATA_INCLUDED

// ============================================================================
// DATA STRUCTURES
// ============================================================================

/*
* Main Player Data Enum
* Contains all player-related data for accounts and characters
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
    wepSlot[13],
    bool:hasDied,

    // Human perks
    tinkererSkillLevel,
    mechanicSkillLevel,
    medicSkillLevel,
    gourmetSkillLevel,
    
    // Zombie Perks
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
	* Not Saved (Session Variables)
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
    locationTimer,
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
    bool:isEmailVerified,
    zombieSurvivalTicks, // Tracks survival time for periodic EXP as zombie

    /*
    * Admin fly
    */
    bool:isflying,
    flyTimer,
    Float:flyPos[4],
    flySpeed,
    
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

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

new player[MAX_PLAYERS][E_PLAYERS]; // Main player data array
new mysqlRaceCheck[MAX_PLAYERS]; // MySQL race condition prevention

/*
* Experience Points Required for Each Level
* Formula: EXP to next level = n^3
*/
new expForNextLevel[MAX_LEVELS] = 
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
};

/*
* Human Skills/Perks
*/
new humanSkills[MAX_PERKS_HUM][] = {
    {"Tinkerer"},
    {"Mechanic"},
    {"Medic"},
    {"Gourmet"}
};

/*
* Zombie Skills/Perks
*/
new zombieSkills[MAX_PERKS_ZOM][] = {
    {"HP Increase"},
    {"Jump"},
    {"Unarmed Damage"},
    {"Bite"},
    {"Combust"},
    {"Stun"},
    {"Grab"},
    {"Borrowed Strength"},
    {"Super Jump"},
    {"Cornered"},
    {"Hunt"}
};

// ============================================================================
// SPAWN LOCATIONS
// ============================================================================

/*
* Random Human Spawn Locations
*/
new Float:humanSpawns[5][4] =
{
    {2087.2439,2079.7832,11.0579,269.9525},
    {2076.2598,2209.6716,10.8203,2.1941},
    {2096.7009,1286.7515,10.8203,180.1222},
    {2388.6819,991.8413,10.8203,84.0609},
    {1958.1028,1343.0325,15.3746,271.0728}
};

/*
* Random Zombie Spawn Locations
*/
new Float:zombieSpawns[5][4] =
{
    {2452.8445,1281.6398,10.8210,178.8857},
    {2124.8530,888.2714,11.1797,358.2520},
    {2004.2582,1544.9500,13.5859,268.0276},
    {1607.3772,1819.2645,10.8280,359.6999},
    {1724.1140,1445.8679,10.8203,349.5623}
};

// ============================================================================
// HUD TEXTDRAWS
// ============================================================================

/*
* Player HUD textdraws
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

// ============================================================================
// GAME TIME VARIABLES
// ============================================================================

new GameTimeHour; // Current game hour (0-23)
new GameTimeMinute = 0; // Current game minute (0-59)
new GameTimeStartTick = 0; // Server tick when time system started
new GameTimeStartHour = 0; // Initial hour when server started (for calculations)
new GameTimeStartMinute = 0; // Initial minute when server started (for calculations)

/*
* Quest Specific Textdraws
*/
new PlayerText:dialogueText[MAX_PLAYERS];

#endif // MODULE_CORE_PLAYER_DATA_INCLUDED
