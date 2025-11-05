// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - FACTION SYSTEM
// ============================================================================
/*
* MODULE: Factions
* PURPOSE: Faction management and territory control system
* 
* DEPENDENCIES:
* - core/config.pwn
* - core/constants.pwn
* - core/player_data.pwn
* - core/database.pwn
* 
* PUBLIC FUNCTIONS:
* - InitializeFactionSystem() - Initialize and load all factions
* - LoadPlayerFaction(playerid, charactername) - Load player's faction data
* - CreateFaction(name, tag, leader, color) - Create a new faction
* - AddFactionMember(factionid, charactername, rankid) - Add member to faction
* - RemoveFactionMember(charactername) - Remove member from faction
* - SendFactionMessage(factionid, color, message) - Send message to all faction members
* - GetPlayerTerritory(playerid) - Get territory player is currently in
* - StartTerritoryCapture(territoryid, attackingfactionid) - Begin territory capture
* 
* DESCRIPTION:
* Manages all faction-related functionality including:
* - Faction creation and management
* - Member hierarchy and permissions
* - Territory ownership and capture
* - Faction bank system
* - Inter-faction warfare
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_FACTIONS_INCLUDED
#define MODULE_FACTIONS_INCLUDED

#define MAX_FACTIONS            50      // Maximum number of factions
#define MAX_FACTION_RANKS       10      // Maximum ranks per faction
#define MAX_TERRITORIES         100     // Maximum number of territories
#define FACTION_NAME_MIN        3       // Minimum faction name length
#define FACTION_NAME_MAX        64      // Maximum faction name length
#define FACTION_TAG_MIN         2       // Minimum faction tag length
#define FACTION_TAG_MAX         6       // Maximum faction tag length
#define FACTION_CREATE_COST     0       // Cost to create a faction (0 = free)
#define FACTION_INVITE_EXPIRE   300     // Invite expires after 5 minutes (in seconds)
#define TERRITORY_CAPTURE_TIME  180     // Seconds to capture a territory (3 minutes)
#define TERRITORY_CONTEST_TIME  120     // Seconds before territory can be contested
#define TERRITORY_CAPTURE_RANGE 100.0   // Distance player must be in to capture
#define TERRITORY_CLAIM_COST    50000   // Cost to claim an unclaimed territory

// ============================================================================
// DATA STRUCTURES
// ============================================================================

/*
* Faction Data
*/
enum E_FACTION_DATA
{
    factionId,
    factionName[64],
    factionTag[7],
    factionLeader[MAX_PLAYER_NAME],
    factionColor,
    factionCreatedDate,
    factionMotd[128],
    factionBankBalance,
    factionLevel,
    factionBaseInteriorId,
    bool:factionLoaded
}

/*
* Faction Rank Data
*/
enum E_FACTION_RANK_DATA
{
    rankFactionId,
    rankId,
    rankName[32],
    bool:rankCanInvite,
    bool:rankCanKick,
    bool:rankCanPromote,
    bool:rankCanDemote,
    bool:rankCanWithdraw,
    bool:rankCanEditRanks
}

/*
* Player Faction Data
*/
enum E_PLAYER_FACTION_DATA
{
    playerFactionId,
    playerFactionRank,
    playerFactionContribution,
    playerFactionJoinedDate,
    playerFactionInvitedBy[MAX_PLAYER_NAME],
    playerFactionInviteId,
    playerFactionInviteTime
}

/*
* Territory Data
*/
enum E_TERRITORY_DATA
{
    territoryId,
    territoryFactionId,
    territoryName[64],
    Float:territoryMinX,
    Float:territoryMinY,
    Float:territoryMaxX,
    Float:territoryMaxY,
    territoryCapturedDate,
    territoryCapturePoints,
    territoryGangZoneId,
    bool:territoryLoaded,
    bool:territoryBeingCaptured,
    territoryCaptureProgress,
    territoryCaptureTimer,
    territoryAttackingFactionId
}

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

new Factions[MAX_FACTIONS][E_FACTION_DATA];
new FactionRanks[MAX_FACTIONS][MAX_FACTION_RANKS][E_FACTION_RANK_DATA];
new PlayerFaction[MAX_PLAYERS][E_PLAYER_FACTION_DATA];
new Territories[MAX_TERRITORIES][E_TERRITORY_DATA];
new ServerFactionCount = 0;
new ServerTerritoryCount = 0;

// ============================================================================
// FORWARD DECLARATIONS
// ============================================================================

// Faction callbacks

forward OnFactionCreated(const leader[]);
forward OnFactionLoaded(factionid);
forward OnFactionRanksLoaded(factionid);
forward OnPlayerFactionLoaded(playerid, const charactername[]);
forward OnFactionMemberAdded(factionid, const charactername[]);
forward OnTerritoriesLoaded();
forward OnTerritoryCreated(territoryid);
forward TerritoryCaptureTimer(territoryid);

// ============================================================================
// FACTION MANAGEMENT FUNCTIONS
// ============================================================================

/*
* Initialize the faction system
*/
InitializeFactionSystem()
{
    print("=====================================");
    print("Initializing Faction System...");
    
    // Reset all factions
    for(new i = 0; i < MAX_FACTIONS; i++)
    {
        ResetFaction(i);
        
        for(new r = 0; r < MAX_FACTION_RANKS; r++)
        {
            ResetFactionRank(i, r);
        }
    }
    
    // Reset all territories
    for(new i = 0; i < MAX_TERRITORIES; i++)
    {
        ResetTerritory(i);
    }
    
    // Load factions from database
    LoadAllFactions();
    
    // Load territories from database
    LoadAllTerritories();
    
    printf("Faction System Initialized");
    print("=====================================");
    return 1;
}

/*
* Reset a faction slot
*/
ResetFaction(factionid)
{
    if(factionid < 0 || factionid >= MAX_FACTIONS)
        return 0;
        
    Factions[factionid][factionId] = -1;
    Factions[factionid][factionName][0] = EOS;
    Factions[factionid][factionTag][0] = EOS;
    Factions[factionid][factionLeader][0] = EOS;
    Factions[factionid][factionColor] = 0xFFFFFFFF;
    Factions[factionid][factionCreatedDate] = 0;
    Factions[factionid][factionMotd][0] = EOS;
    Factions[factionid][factionBankBalance] = 0;
    Factions[factionid][factionLevel] = 1;
    Factions[factionid][factionBaseInteriorId] = -1;
    Factions[factionid][factionLoaded] = false;
    
    return 1;
}

/*
* Reset a territory slot
*/
ResetTerritory(territoryid)
{
    if(territoryid < 0 || territoryid >= MAX_TERRITORIES)
        return 0;
        
    Territories[territoryid][territoryId] = -1;
    Territories[territoryid][territoryFactionId] = -1;
    Territories[territoryid][territoryName][0] = EOS;
    Territories[territoryid][territoryMinX] = 0.0;
    Territories[territoryid][territoryMinY] = 0.0;
    Territories[territoryid][territoryMaxX] = 0.0;
    Territories[territoryid][territoryMaxY] = 0.0;
    Territories[territoryid][territoryCapturedDate] = 0;
    Territories[territoryid][territoryCapturePoints] = 0;
    Territories[territoryid][territoryGangZoneId] = -1;
    Territories[territoryid][territoryLoaded] = false;
    Territories[territoryid][territoryBeingCaptured] = false;
    Territories[territoryid][territoryCaptureProgress] = 0;
    Territories[territoryid][territoryCaptureTimer] = -1;
    Territories[territoryid][territoryAttackingFactionId] = -1;
    
    return 1;
}

/*
* Reset a faction rank slot
*/
ResetFactionRank(factionid, rankid)
{
    if(factionid < 0 || factionid >= MAX_FACTIONS)
        return 0;
    if(rankid < 0 || rankid >= MAX_FACTION_RANKS)
        return 0;
        
    FactionRanks[factionid][rankid][rankFactionId] = -1;
    FactionRanks[factionid][rankid][rankId] = -1;
    FactionRanks[factionid][rankid][rankName][0] = EOS;
    FactionRanks[factionid][rankid][rankCanInvite] = false;
    FactionRanks[factionid][rankid][rankCanKick] = false;
    FactionRanks[factionid][rankid][rankCanPromote] = false;
    FactionRanks[factionid][rankid][rankCanDemote] = false;
    FactionRanks[factionid][rankid][rankCanWithdraw] = false;
    FactionRanks[factionid][rankid][rankCanEditRanks] = false;
    
    return 1;
}

/*
* Reset player faction data
*/
ResetPlayerFaction(playerid)
{
    PlayerFaction[playerid][playerFactionId] = -1;
    PlayerFaction[playerid][playerFactionRank] = -1;
    PlayerFaction[playerid][playerFactionContribution] = 0;
    PlayerFaction[playerid][playerFactionJoinedDate] = 0;
    PlayerFaction[playerid][playerFactionInvitedBy][0] = EOS;
    PlayerFaction[playerid][playerFactionInviteId] = -1;
    PlayerFaction[playerid][playerFactionInviteTime] = 0;
    return 1;
}

// ============================================================================
// DATABASE FUNCTIONS
// ============================================================================

/*
* Load all factions from database
*/
LoadAllFactions()
{
    new query[128];
    mysql_format(database, query, sizeof(query),
        "SELECT COUNT(*) as count FROM `factions`");
    
    new Cache:result = mysql_query(database, query);
    new count = 0;
    cache_get_value_name_int(0, "count", count);
    cache_delete(result);
    
    ServerFactionCount = count;
    
    if(count == 0)
    {
        print("|-> No factions found in database");
        return 1;
    }
    
    mysql_format(database, query, sizeof(query),
        "SELECT * FROM `factions` ORDER BY `id` ASC");
    mysql_tquery(database, query, "OnFactionsLoadedAll");
    
    return 1;
}

forward OnFactionsLoadedAll();
public OnFactionsLoadedAll()
{
    new rows = cache_num_rows();
    new loaded = 0;
    
    for(new i = 0; i < rows && loaded < MAX_FACTIONS; i++)
    {
        new factionid = loaded;
        
        cache_get_value_name_int(i, "id", Factions[factionid][factionId]);
        cache_get_value_name(i, "name", Factions[factionid][factionName], 64);
        cache_get_value_name(i, "tag", Factions[factionid][factionTag], 7);
        cache_get_value_name(i, "leader", Factions[factionid][factionLeader], MAX_PLAYER_NAME);
        cache_get_value_name_int(i, "color", Factions[factionid][factionColor]);
        cache_get_value_name_int(i, "created_date", Factions[factionid][factionCreatedDate]);
        cache_get_value_name(i, "motd", Factions[factionid][factionMotd], 128);
        cache_get_value_name_int(i, "bank_balance", Factions[factionid][factionBankBalance]);
        cache_get_value_name_int(i, "level", Factions[factionid][factionLevel]);
        cache_get_value_name_int(i, "base_interior_id", Factions[factionid][factionBaseInteriorId]);
        
        Factions[factionid][factionLoaded] = true;
        
        // Load ranks for this faction
        LoadFactionRanks(factionid);
        
        loaded++;
    }
    
    printf("|-> Loaded %d factions", loaded);
    return 1;
}

/*
* Load faction ranks from database
*/
LoadFactionRanks(factionid)
{
    if(factionid < 0 || factionid >= MAX_FACTIONS)
        return 0;
    if(!Factions[factionid][factionLoaded])
        return 0;
        
    new query[256];
    mysql_format(database, query, sizeof(query),
        "SELECT * FROM `faction_ranks` WHERE `faction_id` = %d ORDER BY `rank_id` ASC",
        Factions[factionid][factionId]);
    mysql_tquery(database, query, "OnFactionRanksLoaded", "d", factionid);
    
    return 1;
}

public OnFactionRanksLoaded(factionid)
{
    new rows = cache_num_rows();
    
    if(rows == 0)
    {
        // Create default ranks if none exist
        CreateDefaultFactionRanks(factionid);
        return 1;
    }
    
    for(new i = 0; i < rows && i < MAX_FACTION_RANKS; i++)
    {
        new rankid;
        cache_get_value_name_int(i, "rank_id", rankid);
        
        if(rankid >= 0 && rankid < MAX_FACTION_RANKS)
        {
            cache_get_value_name_int(i, "faction_id", FactionRanks[factionid][rankid][rankFactionId]);
            FactionRanks[factionid][rankid][rankId] = rankid;
            cache_get_value_name(i, "rank_name", FactionRanks[factionid][rankid][rankName], 32);
            
            new tempInt;
            cache_get_value_name_int(i, "can_invite", tempInt);
            FactionRanks[factionid][rankid][rankCanInvite] = bool:tempInt;
            cache_get_value_name_int(i, "can_kick", tempInt);
            FactionRanks[factionid][rankid][rankCanKick] = bool:tempInt;
            cache_get_value_name_int(i, "can_promote", tempInt);
            FactionRanks[factionid][rankid][rankCanPromote] = bool:tempInt;
            cache_get_value_name_int(i, "can_demote", tempInt);
            FactionRanks[factionid][rankid][rankCanDemote] = bool:tempInt;
            cache_get_value_name_int(i, "can_withdraw", tempInt);
            FactionRanks[factionid][rankid][rankCanWithdraw] = bool:tempInt;
            cache_get_value_name_int(i, "can_edit_ranks", tempInt);
            FactionRanks[factionid][rankid][rankCanEditRanks] = bool:tempInt;
        }
    }
    
    return 1;
}

/*
* Create default faction ranks
*/
CreateDefaultFactionRanks(factionid)
{
    if(factionid < 0 || factionid >= MAX_FACTIONS)
        return 0;
    if(!Factions[factionid][factionLoaded])
        return 0;
    
    new dbFactionId = Factions[factionid][factionId];
    
    // Rank 0: Recruit (lowest rank)
    AddFactionRank(dbFactionId, 0, "Recruit", false, false, false, false, false, false);
    
    // Rank 1: Member
    AddFactionRank(dbFactionId, 1, "Member", false, false, false, false, false, false);
    
    // Rank 2: Trusted
    AddFactionRank(dbFactionId, 2, "Trusted", true, false, false, false, false, false);
    
    // Rank 3: Officer
    AddFactionRank(dbFactionId, 3, "Officer", true, true, true, true, false, false);
    
    // Rank 4: Co-Leader (highest rank below leader)
    AddFactionRank(dbFactionId, 4, "Co-Leader", true, true, true, true, true, true);
    
    // Reload ranks
    LoadFactionRanks(factionid);
    
    return 1;
}

/*
* Add a faction rank to database
*/
AddFactionRank(dbfactionid, rankid, const rankname[], bool:caninvite, bool:cankick, bool:canpromote, bool:candemote, bool:canwithdraw, bool:caneditranks)
{
    new query[512];
    mysql_format(database, query, sizeof(query),
        "INSERT INTO `faction_ranks` (`faction_id`, `rank_id`, `rank_name`, `can_invite`, `can_kick`, \
        `can_promote`, `can_demote`, `can_withdraw`, `can_edit_ranks`) \
        VALUES (%d, %d, '%e', %d, %d, %d, %d, %d, %d)",
        dbfactionid, rankid, rankname, caninvite, cankick, canpromote, candemote, canwithdraw, caneditranks);
    mysql_tquery(database, query);
    
    return 1;
}

/*
* Load player's faction data
*/
LoadPlayerFaction(playerid, const charactername[])
{
    if(!IsPlayerConnected(playerid))
        return 0;
        
    ResetPlayerFaction(playerid);
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "SELECT * FROM `faction_members` WHERE `character_name` = '%e' LIMIT 1",
        charactername);
    mysql_tquery(database, query, "OnPlayerFactionLoaded", "ds", playerid, charactername);
    
    return 1;
}

public OnPlayerFactionLoaded(playerid, const charactername[])
{
    if(!IsPlayerConnected(playerid))
        return 0;
        
    new rows = cache_num_rows();
    
    if(rows == 0)
    {
        // Player is not in a faction
        ResetPlayerFaction(playerid);
        return 1;
    }
    
    new dbfactionid, factionid;
    cache_get_value_name_int(0, "faction_id", dbfactionid);
    
    // Find the faction array index
    factionid = GetFactionByDatabaseId(dbfactionid);
    
    if(factionid == -1)
    {
        // Faction doesn't exist
        ResetPlayerFaction(playerid);
        return 1;
    }
    
    PlayerFaction[playerid][playerFactionId] = factionid;
    cache_get_value_name_int(0, "rank", PlayerFaction[playerid][playerFactionRank]);
    cache_get_value_name_int(0, "joined_date", PlayerFaction[playerid][playerFactionJoinedDate]);
    cache_get_value_name_int(0, "contribution", PlayerFaction[playerid][playerFactionContribution]);
    
    return 1;
}

/*
* Create a new faction
*/
CreateFaction(const name[], const tag[], const leader[], color)
{
    new query[512];
    mysql_format(database, query, sizeof(query),
        "INSERT INTO `factions` (`name`, `tag`, `leader`, `color`, `created_date`) \
        VALUES ('%e', '%e', '%e', %d, %d)",
        name, tag, leader, color, gettime());
    mysql_tquery(database, query, "OnFactionCreated", "s", leader);
    
    ServerFactionCount++;
    
    return 1;
}

public OnFactionCreated(const leader[])
{
    new factionid = cache_insert_id();
    
    // Add the leader as a member with rank 4 (Co-Leader rank, leader status is by name comparison)
    new query[256];
    mysql_format(database, query, sizeof(query),
        "INSERT INTO `faction_members` (`faction_id`, `character_name`, `rank`, `joined_date`) \
        VALUES (%d, '%e', 4, %d)",
        factionid, leader, gettime());
    mysql_tquery(database, query);
    
    // Reload all factions
    LoadAllFactions();
    
    // Reload the leader's faction data if they're online
    new playerid = GetPlayerIdFromName(leader);
    if(playerid != INVALID_PLAYER_ID)
    {
        LoadPlayerFaction(playerid, leader);
    }
    
    return 1;
}

/*
* Add a member to a faction
*/
AddFactionMember(factionid, const charactername[], rankid)
{
    if(factionid < 0 || factionid >= MAX_FACTIONS)
        return 0;
    if(!Factions[factionid][factionLoaded])
        return 0;
        
    new dbfactionid = Factions[factionid][factionId];
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "INSERT INTO `faction_members` (`faction_id`, `character_name`, `rank`, `joined_date`) \
        VALUES (%d, '%e', %d, %d)",
        dbfactionid, charactername, rankid, gettime());
    mysql_tquery(database, query, "OnFactionMemberAdded", "ds", factionid, charactername);
    
    return 1;
}

public OnFactionMemberAdded(factionid, const charactername[])
{
    // Reload the player's faction data
    new playerid = GetPlayerIdFromName(charactername);
    if(playerid != INVALID_PLAYER_ID)
    {
        LoadPlayerFaction(playerid, charactername);
    }
    
    return 1;
}

/*
* Remove a member from a faction
*/
RemoveFactionMember(const charactername[])
{
    new query[256];
    mysql_format(database, query, sizeof(query),
        "DELETE FROM `faction_members` WHERE `character_name` = '%e'",
        charactername);
    mysql_tquery(database, query);
    
    // Reset player faction data if they're online
    new playerid = GetPlayerIdFromName(charactername);
    if(playerid != INVALID_PLAYER_ID)
    {
        ResetPlayerFaction(playerid);
    }
    
    return 1;
}

/*
* Update faction member rank
*/
UpdateFactionMemberRank(const charactername[], newrank)
{
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `faction_members` SET `rank` = %d WHERE `character_name` = '%e'",
        newrank, charactername);
    mysql_tquery(database, query);
    
    // Update player faction data if they're online
    new playerid = GetPlayerIdFromName(charactername);
    if(playerid != INVALID_PLAYER_ID)
    {
        PlayerFaction[playerid][playerFactionRank] = newrank;
    }
    
    return 1;
}

/*
* Update faction MOTD
*/
UpdateFactionMotd(factionid, const motd[])
{
    if(factionid < 0 || factionid >= MAX_FACTIONS)
        return 0;
    if(!Factions[factionid][factionLoaded])
        return 0;
        
    new dbfactionid = Factions[factionid][factionId];
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `factions` SET `motd` = '%e' WHERE `id` = %d",
        motd, dbfactionid);
    mysql_tquery(database, query);
    
    format(Factions[factionid][factionMotd], 128, "%s", motd);
    
    return 1;
}

/*
* Update faction bank balance
*/
UpdateFactionBank(factionid, amount)
{
    if(factionid < 0 || factionid >= MAX_FACTIONS)
        return 0;
    if(!Factions[factionid][factionLoaded])
        return 0;
        
    Factions[factionid][factionBankBalance] = amount;
    
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `factions` SET `bank_balance` = %d WHERE `id` = %d",
        amount, Factions[factionid][factionId]);
    mysql_tquery(database, query);
    
    return 1;
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/*
* Get faction array index by database ID
*/
GetFactionByDatabaseId(dbid)
{
    for(new i = 0; i < MAX_FACTIONS; i++)
    {
        if(Factions[i][factionLoaded] && Factions[i][factionId] == dbid)
            return i;
    }
    return -1;
}

/*
* Get faction slot by database ID (alias for GetFactionByDatabaseId)
*/
/*
* Convert hex string to integer
*/
HexToInt(const string[])
{
    new result = 0;
    new len = strlen(string);
    
    // Skip "0x" or "0X" prefix if present
    new start = 0;
    if(len > 2 && string[0] == '0' && (string[1] == 'x' || string[1] == 'X'))
    {
        start = 2;
    }
    
    for(new i = start; i < len; i++)
    {
        result *= 16;
        
        if(string[i] >= '0' && string[i] <= '9')
            result += string[i] - '0';
        else if(string[i] >= 'A' && string[i] <= 'F')
            result += string[i] - 'A' + 10;
        else if(string[i] >= 'a' && string[i] <= 'f')
            result += string[i] - 'a' + 10;
        else
            return 0; // Invalid character
    }
    
    return result;
}

GetFactionSlotById(dbid)
{
    return GetFactionByDatabaseId(dbid);
}

/*
* Get faction array index by name
*/
GetFactionByName(const name[])
{
    for(new i = 0; i < MAX_FACTIONS; i++)
    {
        if(Factions[i][factionLoaded] && !strcmp(Factions[i][factionName], name, true))
            return i;
    }
    return -1;
}

/*
* Get player ID from character name
*/
GetPlayerIdFromName(const name[])
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && player[i][isSpawned])
        {
            if(strcmp(player[i][chosenChar], name, false) == 0)
                return i;
        }
    }
    return INVALID_PLAYER_ID;
}

/*
* Check if player has faction permission
*/
bool:PlayerHasFactionPermission(playerid, E_FACTION_RANK_DATA:permission)
{
    if(!IsPlayerConnected(playerid))
        return false;
        
    new factionid = PlayerFaction[playerid][playerFactionId];
    
    if(factionid == -1)
        return false;
        
    new rankid = PlayerFaction[playerid][playerFactionRank];
    
    // Leader has all permissions
    if(strcmp(player[playerid][chosenChar], Factions[factionid][factionLeader], false) == 0)
        return true;
    
    if(rankid < 0 || rankid >= MAX_FACTION_RANKS)
        return false;
    
    switch(permission)
    {
        case rankCanInvite: return FactionRanks[factionid][rankid][rankCanInvite];
        case rankCanKick: return FactionRanks[factionid][rankid][rankCanKick];
        case rankCanPromote: return FactionRanks[factionid][rankid][rankCanPromote];
        case rankCanDemote: return FactionRanks[factionid][rankid][rankCanDemote];
        case rankCanWithdraw: return FactionRanks[factionid][rankid][rankCanWithdraw];
        case rankCanEditRanks: return FactionRanks[factionid][rankid][rankCanEditRanks];
    }
    
    return false;
}

/*
* Check if player is faction leader
*/
bool:IsPlayerFactionLeader(playerid)
{
    if(!IsPlayerConnected(playerid))
        return false;
        
    new factionid = PlayerFaction[playerid][playerFactionId];
    
    if(factionid == -1)
        return false;
        
    return (strcmp(player[playerid][chosenChar], Factions[factionid][factionLeader], false) == 0);
}

/*
* Send message to all faction members
*/
SendFactionMessage(factionid, color, const message[])
{
    if(factionid < 0 || factionid >= MAX_FACTIONS)
        return 0;
    if(!Factions[factionid][factionLoaded])
        return 0;
    
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && player[i][isSpawned])
        {
            if(PlayerFaction[i][playerFactionId] == factionid)
            {
                SendClientMessage(i, color, message);
            }
        }
    }
    
    return 1;
}

// ============================================================================
// COMMANDS
// ============================================================================

CMD:createfaction(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");
    
    // Check if player is already in a faction
    if(PlayerFaction[playerid][playerFactionId] != -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are already in a faction.");
    
    // Check if max factions reached
    if(ServerFactionCount >= MAX_FACTIONS)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Maximum number of factions reached.");
    
    new inputName[64], inputTag[6], inputColor[12];

    if(sscanf(params, "p<,>s[64]s[6]s[12]", inputName, inputTag, inputColor))
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /createfaction [name], [tag], [color]");
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Color format: 0xRRGGBBAA (e.g., 0xFF0000AA for red)");
        return 1;
    }
    
    // Validate name length
    if(strlen(inputName) < FACTION_NAME_MIN || strlen(inputName) > FACTION_NAME_MAX)
    {
        new string[128];
        format(string, sizeof(string), "Faction name must be between %d and %d characters.", FACTION_NAME_MIN, FACTION_NAME_MAX);
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, string);
        return 1;
    }
    
    // Validate tag length
    if(strlen(inputTag) < FACTION_TAG_MIN || strlen(inputTag) > FACTION_TAG_MAX)
    {
        new string[128];
        format(string, sizeof(string), "Faction tag must be between %d and %d characters.", FACTION_TAG_MIN, FACTION_TAG_MAX);
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, string);
        return 1;
    }
    
    // Convert color string to hex
    new color = HexToInt(inputColor);
    if(color == 0)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid color format. Use: 0xRRGGBBAA (e.g., 0xFF0000AA)");
        return 1;
    }
    
    // Create the faction
    CreateFaction(inputName, inputTag, player[playerid][chosenChar], color);
    
    new string[128];
    format(string, sizeof(string), "You have created the faction '%s' [%s]", inputName, inputTag);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    // Add the creator as leader (rank 5 - above Co-Leader)
    // Note: Player will be added when faction loads, handled in OnFactionCreated callback
    return 1;
}

CMD:setfactioncolor(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    // Check if player is in a faction
    new factionslot = PlayerFaction[playerid][playerFactionId];
    if(factionslot == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    // Check if player is the faction leader
    if(!Factions[factionslot][factionLoaded])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Faction data error.");
    
    if(strcmp(Factions[factionslot][factionLeader], player[playerid][chosenChar], false) != 0)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Only the faction leader can change the faction color.");
    
    new inputColor[12];
    if(sscanf(params, "s[12]", inputColor))
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /setfactioncolor [color]");
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Color format: 0xRRGGBBAA (e.g., 0xFF0000AA for red)");
        return 1;
    }
    
    // Convert color string to hex
    new color = HexToInt(inputColor);
    if(color == 0)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid color format. Use: 0xRRGGBBAA (e.g., 0xFF0000AA)");
        return 1;
    }
    
    // Update faction color in memory
    Factions[factionslot][factionColor] = color;
    
    // Update in database
    new query[256];
    mysql_format(database, query, sizeof(query), "UPDATE factions SET color = %d WHERE id = %d", color, Factions[factionslot][factionId]);
    mysql_tquery(database, query);
    
    // Update all territories owned by this faction
    for(new i = 0; i < MAX_TERRITORIES; i++)
    {
        if(Territories[i][territoryLoaded] && Territories[i][territoryFactionId] == factionslot)
        {
            if(Territories[i][territoryGangZoneId] != -1)
            {
                // Hide old gangzone
                GangZoneHideForAll(Territories[i][territoryGangZoneId]);
                
                // Show with new color
                new territoryColor = (color & 0xFFFFFF00) | 0xDD; // More opaque for better visibility
                GangZoneShowForAll(Territories[i][territoryGangZoneId], territoryColor);
            }
        }
    }
    
    new string[128];
    format(string, sizeof(string), "Faction color has been updated to %s", inputColor);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    // Notify faction
    format(string, sizeof(string), "[FACTION] The faction leader has changed the faction color.");
    SendFactionMessage(factionslot, COLOR_FACTION, string);
    
    return 1;
}

CMD:factioninvite(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");
    
    // Check if player is in a faction
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    // Check permission
    if(!PlayerHasFactionPermission(playerid, rankCanInvite))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to invite players.");
    
    new targetid;
    if(sscanf(params, "u", targetid))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /factioninvite [playerid/name]");
    
    if(!IsPlayerConnected(targetid) || !player[targetid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid player.");
    
    if(targetid == playerid)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You cannot invite yourself.");
    
    // Check if target is already in a faction
    if(PlayerFaction[targetid][playerFactionId] != -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "That player is already in a faction.");
    
    // Check if target already has a pending invite
    if(PlayerFaction[targetid][playerFactionInviteId] != -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "That player already has a pending faction invite.");
    
    // Send invite
    PlayerFaction[targetid][playerFactionInviteId] = factionid;
    PlayerFaction[targetid][playerFactionInviteTime] = gettime();
    format(PlayerFaction[targetid][playerFactionInvitedBy], MAX_PLAYER_NAME, "%s", player[playerid][chosenChar]);
    
    new string[128];
    format(string, sizeof(string), "You have invited %s to join your faction.", player[targetid][chosenChar]);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    format(string, sizeof(string), "%s has invited you to join the faction '%s' [%s]",
        player[playerid][chosenChar], Factions[factionid][factionName], Factions[factionid][factionTag]);
    SendPlayerServerMessage(targetid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, string);
    SendPlayerServerMessage(targetid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Use /factionaccept to accept or /factiondeny to decline.");
    
    return 1;
}

CMD:factionaccept(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");
    
    // Check if player has a pending invite
    if(PlayerFaction[playerid][playerFactionInviteId] == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You don't have any pending faction invites.");
    
    // Check if invite has expired
    if((gettime() - PlayerFaction[playerid][playerFactionInviteTime]) > FACTION_INVITE_EXPIRE)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Your faction invite has expired.");
        PlayerFaction[playerid][playerFactionInviteId] = -1;
        return 1;
    }
    
    new factionid = PlayerFaction[playerid][playerFactionInviteId];
    
    // Add player to faction (rank 0 - Recruit)
    AddFactionMember(factionid, player[playerid][chosenChar], 0);
    
    // Clear invite
    PlayerFaction[playerid][playerFactionInviteId] = -1;
    PlayerFaction[playerid][playerFactionInviteTime] = 0;
    
    new string[128];
    format(string, sizeof(string), "You have joined the faction '%s' [%s]",
        Factions[factionid][factionName], Factions[factionid][factionTag]);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    // Notify faction
    format(string, sizeof(string), "[FACTION] %s has joined the faction.", player[playerid][chosenChar]);
    SendFactionMessage(factionid, COLOR_FACTION, string);
    
    return 1;
}

CMD:factiondeny(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");
    
    // Check if player has a pending invite
    if(PlayerFaction[playerid][playerFactionInviteId] == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You don't have any pending faction invites.");
    
    new factionid = PlayerFaction[playerid][playerFactionInviteId];
    
    // Clear invite
    PlayerFaction[playerid][playerFactionInviteId] = -1;
    PlayerFaction[playerid][playerFactionInviteTime] = 0;
    
    new string[128];
    format(string, sizeof(string), "You have declined the invitation to join '%s'",
        Factions[factionid][factionName]);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, string);
    
    return 1;
}

CMD:factionkick(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");
    
    // Check if player is in a faction
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    // Check permission
    if(!PlayerHasFactionPermission(playerid, rankCanKick))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to kick members.");
    
    new targetName[MAX_PLAYER_NAME];
    if(sscanf(params, "s[24]", targetName))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /factionkick [character name]");
    
    // Cannot kick the leader
    if(strcmp(targetName, Factions[factionid][factionLeader], false) == 0)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You cannot kick the faction leader.");
    
    // Remove member
    RemoveFactionMember(targetName);
    
    new string[128];
    format(string, sizeof(string), "You have kicked %s from the faction.", targetName);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    // Notify faction
    format(string, sizeof(string), "[FACTION] %s has been kicked from the faction by %s",
        targetName, player[playerid][chosenChar]);
    SendFactionMessage(factionid, COLOR_FACTION, string);
    
    // Notify kicked player if online
    new targetid = GetPlayerIdFromName(targetName);
    if(targetid != INVALID_PLAYER_ID)
    {
        SendPlayerServerMessage(targetid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You have been kicked from your faction.");
    }
    
    return 1;
}

CMD:factionleave(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");
    
    // Check if player is in a faction
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    // Leaders cannot leave (they must transfer leadership or disband)
    if(IsPlayerFactionLeader(playerid))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Leaders cannot leave. Transfer leadership or disband the faction.");
    
    // Remove player from faction
    RemoveFactionMember(player[playerid][chosenChar]);
    
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, "You have left your faction.");
    
    // Notify faction
    new string[128];
    format(string, sizeof(string), "[FACTION] %s has left the faction.", player[playerid][chosenChar]);
    SendFactionMessage(factionid, COLOR_FACTION, string);
    
    return 1;
}

CMD:factionchat(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");
    
    // Check if player is in a faction
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    new message[128];
    if(sscanf(params, "s[128]", message))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /factionchat [message]");
    
    new string[256];
    format(string, sizeof(string), "[%s] %s: %s",
        Factions[factionid][factionTag], player[playerid][chosenChar], message);
    SendFactionMessage(factionid, COLOR_FACTION, string);
    
    return 1;
}
alias:factionchat("f")

CMD:factioninfo(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");
    
    // Check if player is in a faction
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    new string[256];
    format(string, sizeof(string), "=== %s [%s] ===",
        Factions[factionid][factionName], Factions[factionid][factionTag]);
    SendClientMessage(playerid, COLOR_FACTION, string);
    
    format(string, sizeof(string), "Leader: %s | Level: %d | Bank: $%d",
        Factions[factionid][factionLeader], Factions[factionid][factionLevel],
        Factions[factionid][factionBankBalance]);
    SendClientMessage(playerid, COLOR_WHITE, string);
    
    // Display rank - show "Leader" for the faction leader
    if(IsPlayerFactionLeader(playerid))
    {
        format(string, sizeof(string), "Your Rank: Leader");
        SendClientMessage(playerid, COLOR_WHITE, string);
    }
    else
    {
        new rankid = PlayerFaction[playerid][playerFactionRank];
        format(string, sizeof(string), "Your Rank: %s (Rank %d)",
            FactionRanks[factionid][rankid][rankName], rankid);
        SendClientMessage(playerid, COLOR_WHITE, string);
    }
    
    if(strlen(Factions[factionid][factionMotd]) > 0)
    {
        format(string, sizeof(string), "MOTD: %s", Factions[factionid][factionMotd]);
        SendClientMessage(playerid, COLOR_YELLOW, string);
    }
    
    return 1;
}

CMD:factionmotd(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");
    
    // Check if player is in a faction
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    // Only leader can set MOTD
    if(!IsPlayerFactionLeader(playerid))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Only the faction leader can set the MOTD.");
    
    new motd[128];
    if(sscanf(params, "s[128]", motd))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /factionmotd [message]");
    
    UpdateFactionMotd(factionid, motd);
    
    new string[128];
    format(string, sizeof(string), "Faction MOTD updated to: %s", motd);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    return 1;
}

CMD:fhelp(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    // Check if player is in a faction
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    new bool:isLeader = IsPlayerFactionLeader(playerid);
    new message[2048];
    
    // Build the help message
    strcat(message, "{00FF00}=== FACTION COMMANDS ===\n\n");
    
    // Basic commands (available to all)
    strcat(message, "{FFFFFF}BASIC COMMANDS:\n");
    strcat(message, "{CCCCCC}- /factioninfo - View your faction's information\n");
    strcat(message, "{CCCCCC}- /factionchat (/f) [message] - Send message to faction\n");
    strcat(message, "{CCCCCC}- /factionranks - View all faction ranks\n");
    strcat(message, "{CCCCCC}- /factionleave - Leave your faction\n");
    strcat(message, "{CCCCCC}- /territories - View your faction's territories\n");
    strcat(message, "{CCCCCC}- /territoryinfo - Info about current territory\n");
    strcat(message, "{CCCCCC}- /captureterritory - Start capturing a territory\n");
    strcat(message, "{CCCCCC}- /claimterritory - Claim an unclaimed territory (Leader only, costs $50,000)\n\n");
    
    // Permission-based commands
    new bool:hasPerms = false;
    new permCommands[1024] = "{FFFFFF}YOUR PERMISSIONS:\n";
    
    // Invite permission
    if(isLeader || PlayerHasFactionPermission(playerid, rankCanInvite))
    {
        strcat(permCommands, "{33FF33}- /factioninvite [playerid] - Invite a player to faction\n");
        hasPerms = true;
    }
    
    // Kick permission
    if(isLeader || PlayerHasFactionPermission(playerid, rankCanKick))
    {
        strcat(permCommands, "{33FF33}- /factionkick [character name] - Kick member from faction\n");
        hasPerms = true;
    }
    
    // Promote permission
    if(isLeader || PlayerHasFactionPermission(playerid, rankCanPromote))
    {
        strcat(permCommands, "{33FF33}- /promote [character name] - Promote a member\n");
        hasPerms = true;
    }
    
    // Demote permission
    if(isLeader || PlayerHasFactionPermission(playerid, rankCanDemote))
    {
        strcat(permCommands, "{33FF33}- /demote [character name] - Demote a member\n");
        hasPerms = true;
    }
    
    // Edit ranks permission
    if(isLeader || PlayerHasFactionPermission(playerid, rankCanEditRanks))
    {
        strcat(permCommands, "{33FF33}- /editrankname [rank id] [new name] - Change rank name\n");
        strcat(permCommands, "{33FF33}- /editrankperm [rank id] [permission] [0/1] - Edit rank permission\n");
        hasPerms = true;
    }
    
    if(hasPerms)
    {
        strcat(message, permCommands);
        strcat(message, "\n");
    }
    
    // Leader only commands
    if(isLeader)
    {
        strcat(message, "{FFFFFF}LEADER COMMANDS:\n");
        strcat(message, "{FFFF00}- /factionmotd [message] - Set faction message of the day\n");
        strcat(message, "{FFFF00}- /setfactioncolor [color] - Change faction color (0xRRGGBBAA)\n\n");
    }
    
    // Invite response commands (if player has NO pending invite, show greyed out)
    if(PlayerFaction[playerid][playerFactionInviteId] == -1)
    {
        strcat(message, "{FFFFFF}INVITE RESPONSE:\n");
        strcat(message, "{999999}- /factionaccept - Accept a faction invite\n");
        strcat(message, "{999999}- /factiondeny - Deny a faction invite\n");
        strcat(message, "{AAAAAA}(You have no pending invites)");
    }
    
    // Show the dialog
    ShowPlayerMessageBox(playerid, "Faction Commands", message);
    
    return 1;
}

CMD:factionranks(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    if(player[playerid][iszombie] == 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You cannot use this as a Zombie.");
    
    // Check if player is in a faction
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    new string[256];
    SendClientMessage(playerid, COLOR_FACTION, "=== Faction Ranks ===");
    
    for(new i = 0; i < MAX_FACTION_RANKS; i++)
    {
        if(FactionRanks[factionid][i][rankId] != -1)
        {
            format(string, sizeof(string), "Rank %d: %s", i, FactionRanks[factionid][i][rankName]);
            SendClientMessage(playerid, COLOR_WHITE, string);
            
            new permissions[128] = "Permissions: ";
            if(FactionRanks[factionid][i][rankCanInvite]) strcat(permissions, "Invite ");
            if(FactionRanks[factionid][i][rankCanKick]) strcat(permissions, "Kick ");
            if(FactionRanks[factionid][i][rankCanPromote]) strcat(permissions, "Promote ");
            if(FactionRanks[factionid][i][rankCanDemote]) strcat(permissions, "Demote ");
            if(FactionRanks[factionid][i][rankCanWithdraw]) strcat(permissions, "Withdraw ");
            if(FactionRanks[factionid][i][rankCanEditRanks]) strcat(permissions, "EditRanks");
            
            if(strlen(permissions) == 13) // Just "Permissions: "
                strcat(permissions, "None");
                
            SendClientMessage(playerid, COLOR_GREY, permissions);
        }
    }
    
    return 1;
}

CMD:editrankname(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    // Check if player is in a faction
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    // Check permission
    if(!PlayerHasFactionPermission(playerid, rankCanEditRanks))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to edit ranks.");
    
    new rankid, newName[32];
    if(sscanf(params, "ds[32]", rankid, newName))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /editrankname [rank id] [new name]");
    
    if(rankid < 0 || rankid >= MAX_FACTION_RANKS)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid rank ID.");
    
    if(FactionRanks[factionid][rankid][rankId] == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "That rank doesn't exist.");
    
    // Update in database
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `faction_ranks` SET `rank_name` = '%e' WHERE `faction_id` = %d AND `rank_id` = %d",
        newName, Factions[factionid][factionId], rankid);
    mysql_tquery(database, query);
    
    // Update in memory
    format(FactionRanks[factionid][rankid][rankName], 32, "%s", newName);
    
    new string[128];
    format(string, sizeof(string), "Rank %d name changed to: %s", rankid, newName);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    return 1;
}

CMD:editrankperm(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    // Check if player is in a faction
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    // Check permission
    if(!PlayerHasFactionPermission(playerid, rankCanEditRanks))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to edit ranks.");
    
    new rankid, permission[32], value;
    if(sscanf(params, "ds[32]d", rankid, permission, value))
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /editrankperm [rank id] [permission] [0/1]");
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Permissions: invite, kick, promote, demote, withdraw, editranks");
        return 1;
    }
    
    if(rankid < 0 || rankid >= MAX_FACTION_RANKS)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid rank ID.");
    
    if(FactionRanks[factionid][rankid][rankId] == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "That rank doesn't exist.");
    
    if(value != 0 && value != 1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Value must be 0 (disable) or 1 (enable).");
    
    new bool:bValue = bool:value;
    new column[32];
    new permName[32];
    
    // Determine which permission to update
    if(!strcmp(permission, "invite", true))
    {
        FactionRanks[factionid][rankid][rankCanInvite] = bValue;
        column = "can_invite";
        permName = "Invite";
    }
    else if(!strcmp(permission, "kick", true))
    {
        FactionRanks[factionid][rankid][rankCanKick] = bValue;
        column = "can_kick";
        permName = "Kick";
    }
    else if(!strcmp(permission, "promote", true))
    {
        FactionRanks[factionid][rankid][rankCanPromote] = bValue;
        column = "can_promote";
        permName = "Promote";
    }
    else if(!strcmp(permission, "demote", true))
    {
        FactionRanks[factionid][rankid][rankCanDemote] = bValue;
        column = "can_demote";
        permName = "Demote";
    }
    else if(!strcmp(permission, "withdraw", true))
    {
        FactionRanks[factionid][rankid][rankCanWithdraw] = bValue;
        column = "can_withdraw";
        permName = "Withdraw";
    }
    else if(!strcmp(permission, "editranks", true))
    {
        FactionRanks[factionid][rankid][rankCanEditRanks] = bValue;
        column = "can_edit_ranks";
        permName = "Edit Ranks";
    }
    else
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid permission. Use: invite, kick, promote, demote, withdraw, editranks");
        return 1;
    }
    
    // Update in database
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `faction_ranks` SET `%s` = %d WHERE `faction_id` = %d AND `rank_id` = %d",
        column, value, Factions[factionid][factionId], rankid);
    mysql_tquery(database, query);
    
    new string[128];
    format(string, sizeof(string), "Rank %d (%s) permission '%s' set to: %s",
        rankid, FactionRanks[factionid][rankid][rankName], permName, bValue ? "Enabled" : "Disabled");
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    return 1;
}

CMD:promote(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    // Check if player is in a faction
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    // Check permission
    if(!PlayerHasFactionPermission(playerid, rankCanPromote))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to promote members.");
    
    new targetName[MAX_PLAYER_NAME];
    if(sscanf(params, "s[24]", targetName))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /promote [character name]");
    
    // Get target's current rank (need to query database)
    new query[256];
    mysql_format(database, query, sizeof(query),
        "SELECT `rank` FROM `faction_members` WHERE `character_name` = '%e' AND `faction_id` = %d LIMIT 1",
        targetName, Factions[factionid][factionId]);
    
    new Cache:result = mysql_query(database, query);
    
    if(cache_num_rows() == 0)
    {
        cache_delete(result);
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "That player is not in your faction.");
    }
    
    new currentRank;
    cache_get_value_name_int(0, "rank", currentRank);
    cache_delete(result);
    
    // Can't promote to rank 5 or higher (reserved for leader status)
    if(currentRank >= 4)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "That member is already at the highest promotable rank.");
    
    new newRank = currentRank + 1;
    
    // Update rank
    UpdateFactionMemberRank(targetName, newRank);
    
    new string[128];
    format(string, sizeof(string), "You have promoted %s to rank %d (%s)",
        targetName, newRank, FactionRanks[factionid][newRank][rankName]);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    // Notify target if online
    new targetid = GetPlayerIdFromName(targetName);
    if(targetid != INVALID_PLAYER_ID)
    {
        format(string, sizeof(string), "You have been promoted to rank %d (%s) by %s",
            newRank, FactionRanks[factionid][newRank][rankName], player[playerid][chosenChar]);
        SendPlayerServerMessage(targetid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    }
    
    // Notify faction
    format(string, sizeof(string), "[FACTION] %s has been promoted to %s by %s",
        targetName, FactionRanks[factionid][newRank][rankName], player[playerid][chosenChar]);
    SendFactionMessage(factionid, COLOR_FACTION, string);
    
    return 1;
}

CMD:demote(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    // Check if player is in a faction
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    // Check permission
    if(!PlayerHasFactionPermission(playerid, rankCanDemote))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to demote members.");
    
    new targetName[MAX_PLAYER_NAME];
    if(sscanf(params, "s[24]", targetName))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /demote [character name]");
    
    // Cannot demote the leader
    if(strcmp(targetName, Factions[factionid][factionLeader], false) == 0)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You cannot demote the faction leader.");
    
    // Get target's current rank
    new query[256];
    mysql_format(database, query, sizeof(query),
        "SELECT `rank` FROM `faction_members` WHERE `character_name` = '%e' AND `faction_id` = %d LIMIT 1",
        targetName, Factions[factionid][factionId]);
    
    new Cache:result = mysql_query(database, query);
    
    if(cache_num_rows() == 0)
    {
        cache_delete(result);
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "That player is not in your faction.");
    }
    
    new currentRank;
    cache_get_value_name_int(0, "rank", currentRank);
    cache_delete(result);
    
    // Can't demote below rank 0
    if(currentRank <= 0)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "That member is already at the lowest rank.");
    
    new newRank = currentRank - 1;
    
    // Update rank
    UpdateFactionMemberRank(targetName, newRank);
    
    new string[128];
    format(string, sizeof(string), "You have demoted %s to rank %d (%s)",
        targetName, newRank, FactionRanks[factionid][newRank][rankName]);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    // Notify target if online
    new targetid = GetPlayerIdFromName(targetName);
    if(targetid != INVALID_PLAYER_ID)
    {
        format(string, sizeof(string), "You have been demoted to rank %d (%s) by %s",
            newRank, FactionRanks[factionid][newRank][rankName], player[playerid][chosenChar]);
        SendPlayerServerMessage(targetid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, string);
    }
    
    // Notify faction
    format(string, sizeof(string), "[FACTION] %s has been demoted to %s by %s",
        targetName, FactionRanks[factionid][newRank][rankName], player[playerid][chosenChar]);
    SendFactionMessage(factionid, COLOR_FACTION, string);
    
    return 1;
}

// ============================================================================
// TERRITORY SYSTEM
// ============================================================================

/*
* Helper function to convert timestamp to readable date
*/
ConvertTimeToDate(timestamp)
{
    new date[32];
    new timeElapsed = gettime() - timestamp;
    
    // Simple relative time display
    if(timeElapsed < 60)
        format(date, sizeof(date), "%d seconds ago", timeElapsed);
    else if(timeElapsed < 3600)
        format(date, sizeof(date), "%d minutes ago", timeElapsed / 60);
    else if(timeElapsed < 86400)
        format(date, sizeof(date), "%d hours ago", timeElapsed / 3600);
    else
        format(date, sizeof(date), "%d days ago", timeElapsed / 86400);
    
    return date;
}

/*
* Load all territories from database
*/
LoadAllTerritories()
{
    new query[256];
    mysql_format(database, query, sizeof(query), "SELECT * FROM `faction_territories`");
    mysql_tquery(database, query, "OnTerritoriesLoaded", "");
}

/*
* Callback when territories are loaded
*/
public OnTerritoriesLoaded()
{
    new rows = cache_num_rows();
    
    if(rows == 0)
    {
        print("No territories found in database.");
        return 1;
    }
    
    ServerTerritoryCount = 0;
    
    for(new i = 0; i < rows && ServerTerritoryCount < MAX_TERRITORIES; i++)
    {
        new territoryid = ServerTerritoryCount;
        
        cache_get_value_name_int(i, "id", Territories[territoryid][territoryId]);
        
        // Get faction_id from database and convert to slot index
        new dbFactionId;
        cache_get_value_name_int(i, "faction_id", dbFactionId);
        Territories[territoryid][territoryFactionId] = (dbFactionId == -1) ? -1 : GetFactionSlotById(dbFactionId);
        
        cache_get_value_name(i, "zone_name", Territories[territoryid][territoryName], 64);
        cache_get_value_name_float(i, "min_x", Territories[territoryid][territoryMinX]);
        cache_get_value_name_float(i, "min_y", Territories[territoryid][territoryMinY]);
        cache_get_value_name_float(i, "max_x", Territories[territoryid][territoryMaxX]);
        cache_get_value_name_float(i, "max_y", Territories[territoryid][territoryMaxY]);
        cache_get_value_name_int(i, "captured_date", Territories[territoryid][territoryCapturedDate]);
        cache_get_value_name_int(i, "capture_points", Territories[territoryid][territoryCapturePoints]);
        
        // Create gangzone for this territory
        new color = 0x808080DD; // Default neutral color (gray with high visibility)
        if(Territories[territoryid][territoryFactionId] != -1)
        {
            // Get faction color and make it more visible
            color = (Factions[Territories[territoryid][territoryFactionId]][factionColor] & 0xFFFFFF00) | 0xDD; // More opaque for better visibility
        }
        
        Territories[territoryid][territoryGangZoneId] = GangZoneCreate(
            Territories[territoryid][territoryMinX],
            Territories[territoryid][territoryMinY],
            Territories[territoryid][territoryMaxX],
            Territories[territoryid][territoryMaxY]
        );
        
        Territories[territoryid][territoryLoaded] = true;
        Territories[territoryid][territoryBeingCaptured] = false;
        Territories[territoryid][territoryCaptureProgress] = 0;
        Territories[territoryid][territoryCaptureTimer] = -1;
        Territories[territoryid][territoryAttackingFactionId] = -1;
        
        // Show gangzone to all players
        for(new p = 0; p < MAX_PLAYERS; p++)
        {
            if(IsPlayerConnected(p))
            {
                GangZoneShowForPlayer(p, Territories[territoryid][territoryGangZoneId], color);
            }
        }
        
        ServerTerritoryCount++;
    }
    
    printf("Loaded %d territories from database.", ServerTerritoryCount);
    return 1;
}

/*
* Get territory by name
*/
GetTerritoryByName(const name[])
{
    for(new i = 0; i < ServerTerritoryCount; i++)
    {
        if(Territories[i][territoryLoaded] && !strcmp(Territories[i][territoryName], name, true))
            return i;
    }
    return -1;
}

/*
* Show all territories to a player
*/
ShowTerritoriesToPlayer(playerid)
{
    for(new i = 0; i < ServerTerritoryCount; i++)
    {
        if(!Territories[i][territoryLoaded])
            continue;
            
        new color = 0x808080DD; // Default neutral color
        
        if(Territories[i][territoryFactionId] != -1)
        {
            // territoryFactionId is already a slot index
            color = (Factions[Territories[i][territoryFactionId]][factionColor] & 0xFFFFFF00) | 0xDD;
        }
        
        GangZoneShowForPlayer(playerid, Territories[i][territoryGangZoneId], color);
    }
    return 1;
}

/*
* Check if player is in a territory
*/
GetPlayerTerritory(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    for(new i = 0; i < ServerTerritoryCount; i++)
    {
        if(!Territories[i][territoryLoaded])
            continue;
        
        if(x >= Territories[i][territoryMinX] && x <= Territories[i][territoryMaxX] &&
           y >= Territories[i][territoryMinY] && y <= Territories[i][territoryMaxY])
        {
            return i;
        }
    }
    
    return -1;
}

/*
* Create a new territory
*/
CreateTerritory(const name[], Float:minx, Float:miny, Float:maxx, Float:maxy, factionid = -1)
{
    if(ServerTerritoryCount >= MAX_TERRITORIES)
        return -1;
    
    new query[512];
    mysql_format(database, query, sizeof(query),
        "INSERT INTO `faction_territories` (`faction_id`, `zone_name`, `min_x`, `min_y`, `max_x`, `max_y`, `captured_date`, `capture_points`) VALUES (%d, '%e', %f, %f, %f, %f, %d, 0)",
        factionid, name, minx, miny, maxx, maxy, gettime()
    );
    mysql_tquery(database, query, "OnTerritoryCreated", "d", ServerTerritoryCount);
    
    // Setup territory data
    new territoryid = ServerTerritoryCount;
    Territories[territoryid][territoryFactionId] = factionid;
    format(Territories[territoryid][territoryName], 64, "%s", name);
    Territories[territoryid][territoryMinX] = minx;
    Territories[territoryid][territoryMinY] = miny;
    Territories[territoryid][territoryMaxX] = maxx;
    Territories[territoryid][territoryMaxY] = maxy;
    Territories[territoryid][territoryCapturedDate] = gettime();
    Territories[territoryid][territoryCapturePoints] = 0;
    Territories[territoryid][territoryLoaded] = true;
    Territories[territoryid][territoryBeingCaptured] = false;
    Territories[territoryid][territoryCaptureProgress] = 0;
    Territories[territoryid][territoryCaptureTimer] = -1;
    Territories[territoryid][territoryAttackingFactionId] = -1;
    
    // Create gangzone
    new color = 0x00000050; // Neutral color
    if(factionid != -1)
    {
        new fslot = GetFactionSlotById(factionid);
        if(fslot != -1)
        {
            color = (Factions[fslot][factionColor] & 0xFFFFFF00) | 0x80;
        }
    }
    
    Territories[territoryid][territoryGangZoneId] = GangZoneCreate(minx, miny, maxx, maxy);
    
    // Show to all players
    for(new p = 0; p < MAX_PLAYERS; p++)
    {
        if(IsPlayerConnected(p))
        {
            GangZoneShowForPlayer(p, Territories[territoryid][territoryGangZoneId], color);
        }
    }
    
    ServerTerritoryCount++;
    return territoryid;
}

/*
* Check if any members of a faction are online
*/
bool:IsFactionMemberOnline(factionid)
{
    if(factionid == -1)
        return false;
    
    for(new p = 0; p < MAX_PLAYERS; p++)
    {
        if(IsPlayerConnected(p) && player[p][isSpawned])
        {
            if(PlayerFaction[p][playerFactionId] == factionid)
                return true;
        }
    }
    return false;
}

/*
* Callback when territory is created
*/
public OnTerritoryCreated(territoryid)
{
    Territories[territoryid][territoryId] = cache_insert_id();
    printf("Territory created with ID: %d (Slot: %d)", Territories[territoryid][territoryId], territoryid);
}

/*
* Update territory gangzone color
*/
UpdateTerritoryColor(territoryid)
{
    if(territoryid < 0 || territoryid >= ServerTerritoryCount || !Territories[territoryid][territoryLoaded])
        return 0;
    
    new color = 0x808080DD; // Neutral gray with high visibility
    
    if(Territories[territoryid][territoryFactionId] != -1)
    {
        // territoryFactionId is already a slot index
        color = (Factions[Territories[territoryid][territoryFactionId]][factionColor] & 0xFFFFFF00) | 0xDD; // More opaque for better visibility
    }
    
    // Update for all players
    for(new p = 0; p < MAX_PLAYERS; p++)
    {
        if(IsPlayerConnected(p))
        {
            GangZoneHideForPlayer(p, Territories[territoryid][territoryGangZoneId]);
            GangZoneShowForPlayer(p, Territories[territoryid][territoryGangZoneId], color);
        }
    }
    
    return 1;
}

/*
* Start capturing a territory
*/
StartTerritoryCapture(territoryid, attackingfactionid)
{
    if(territoryid < 0 || territoryid >= ServerTerritoryCount || !Territories[territoryid][territoryLoaded])
        return 0;
    
    if(Territories[territoryid][territoryBeingCaptured])
        return 0; // Already being captured
    
    // Check if defending faction has any members online
    new defendingFactionId = Territories[territoryid][territoryFactionId];
    if(defendingFactionId != -1 && !IsFactionMemberOnline(defendingFactionId))
        return -1; // Return -1 to indicate no defenders online
    
    Territories[territoryid][territoryBeingCaptured] = true;
    Territories[territoryid][territoryCaptureProgress] = 0;
    Territories[territoryid][territoryAttackingFactionId] = attackingfactionid;
    
    // Start capture timer (called every second)
    Territories[territoryid][territoryCaptureTimer] = SetTimerEx("TerritoryCaptureTimer", 1000, true, "d", territoryid);
    
    // Flash gangzone for attacking faction (attackingfactionid is already a slot)
    if(attackingfactionid != -1 && Factions[attackingfactionid][factionLoaded])
    {
        new flashColor = Factions[attackingfactionid][factionColor];
        
        for(new p = 0; p < MAX_PLAYERS; p++)
        {
            if(IsPlayerConnected(p))
            {
                GangZoneFlashForPlayer(p, Territories[territoryid][territoryGangZoneId], flashColor);
            }
        }
    }
    
    // Notify both factions
    new string[128];
    format(string, sizeof(string), "Your faction is capturing %s!", Territories[territoryid][territoryName]);
    SendFactionMessage(attackingfactionid, COLOR_FACTION, string);
    
    if(Territories[territoryid][territoryFactionId] != -1)
    {
        format(string, sizeof(string), "WARNING: %s is under attack!", Territories[territoryid][territoryName]);
        SendFactionMessage(Territories[territoryid][territoryFactionId], COLOR_RED, string);
    }
    
    return 1;
}

/*
* Territory capture timer - called every second
*/
public TerritoryCaptureTimer(territoryid)
{
    if(territoryid < 0 || territoryid >= ServerTerritoryCount || !Territories[territoryid][territoryLoaded])
    {
        return 0;
    }
    
    if(!Territories[territoryid][territoryBeingCaptured])
    {
        KillTimer(Territories[territoryid][territoryCaptureTimer]);
        Territories[territoryid][territoryCaptureTimer] = -1;
        return 0;
    }
    
    // Count players from attacking faction in the territory
    new attackerCount = 0;
    new defenderCount = 0;
    
    for(new p = 0; p < MAX_PLAYERS; p++)
    {
        if(!IsPlayerConnected(p) || !player[p][isSpawned])
            continue;
        
        if(GetPlayerTerritory(p) == territoryid)
        {
            new pFactionId = PlayerFaction[p][playerFactionId];
            
            if(pFactionId == Territories[territoryid][territoryAttackingFactionId])
                attackerCount++;
            else if(pFactionId == Territories[territoryid][territoryFactionId])
                defenderCount++;
        }
    }
    
    // If no attackers, cancel capture
    if(attackerCount == 0)
    {
        CancelTerritoryCapture(territoryid);
        return 0;
    }
    
    // Calculate progress (attackers vs defenders)
    if(attackerCount > defenderCount)
    {
        Territories[territoryid][territoryCaptureProgress] += attackerCount - defenderCount;
    }
    else if(defenderCount > attackerCount)
    {
        Territories[territoryid][territoryCaptureProgress] -= (defenderCount - attackerCount);
        
        // If progress goes negative, cancel capture
        if(Territories[territoryid][territoryCaptureProgress] <= 0)
        {
            CancelTerritoryCapture(territoryid);
            return 0;
        }
    }
    
    // Display capture progress to all players in the territory
    new progressPercent = (Territories[territoryid][territoryCaptureProgress] * 100) / TERRITORY_CAPTURE_TIME;
    new progressBar[64];
    
    // Create visual progress bar
    new barLength = progressPercent / 5; // 20 characters max (100/5)
    if(barLength > 20) barLength = 20;
    
    new barString[32] = "";
    for(new i = 0; i < 20; i++)
    {
        if(i < barLength)
            strcat(barString, "|");
        else
            strcat(barString, ".");
    }
    
    format(progressBar, sizeof(progressBar), "~r~CAPTURING~w~ %s ~y~%d%%", barString, progressPercent);
    
    // Show to all players in the territory (style 1 = bottom right, less intrusive)
    for(new p = 0; p < MAX_PLAYERS; p++)
    {
        if(IsPlayerConnected(p) && player[p][isSpawned] && GetPlayerTerritory(p) == territoryid)
        {
            GameTextForPlayer(p, progressBar, 1200, 1);
        }
    }
    
    // Check if territory is captured
    if(Territories[territoryid][territoryCaptureProgress] >= TERRITORY_CAPTURE_TIME)
    {
        CompleteTerritoryCapture(territoryid);
    }
    
    return 1;
}

/*
* Complete territory capture
*/
CompleteTerritoryCapture(territoryid)
{
    if(territoryid < 0 || territoryid >= ServerTerritoryCount || !Territories[territoryid][territoryLoaded])
        return 0;
    
    new attackingFactionId = Territories[territoryid][territoryAttackingFactionId];
    new oldFactionId = Territories[territoryid][territoryFactionId];
    
    // Update territory
    Territories[territoryid][territoryFactionId] = attackingFactionId;
    Territories[territoryid][territoryCapturedDate] = gettime();
    Territories[territoryid][territoryBeingCaptured] = false;
    Territories[territoryid][territoryCaptureProgress] = 0;
    Territories[territoryid][territoryAttackingFactionId] = -1;
    
    // Kill timer
    KillTimer(Territories[territoryid][territoryCaptureTimer]);
    Territories[territoryid][territoryCaptureTimer] = -1;
    
    // Stop gangzone flashing, update color, and notify players
    for(new p = 0; p < MAX_PLAYERS; p++)
    {
        if(IsPlayerConnected(p))
        {
            GangZoneStopFlashForPlayer(p, Territories[territoryid][territoryGangZoneId]);
            
            // Show visual feedback to players in the territory
            if(player[p][isSpawned] && GetPlayerTerritory(p) == territoryid)
            {
                new pFactionId = PlayerFaction[p][playerFactionId];
                
                if(pFactionId == attackingFactionId)
                    GameTextForPlayer(p, "~g~TERRITORY CAPTURED!", 5000, 1);
                else if(pFactionId == oldFactionId)
                    GameTextForPlayer(p, "~r~TERRITORY LOST!", 5000, 1);
                else
                    GameTextForPlayer(p, "~y~TERRITORY OWNERSHIP CHANGED", 4000, 1);
            }
        }
    }
    
    UpdateTerritoryColor(territoryid);
    
    // Update database (convert slot to database ID)
    new query[256];
    new dbFactionId = (attackingFactionId != -1) ? Factions[attackingFactionId][factionId] : -1;
    mysql_format(database, query, sizeof(query),
        "UPDATE `faction_territories` SET `faction_id` = %d, `captured_date` = %d WHERE `id` = %d",
        dbFactionId, gettime(), Territories[territoryid][territoryId]
    );
    mysql_tquery(database, query);
    
    // Notify factions (both IDs are already slot indices)
    new string[128];
    
    if(attackingFactionId != -1 && Factions[attackingFactionId][factionLoaded])
    {
        format(string, sizeof(string), "Your faction has captured %s!", Territories[territoryid][territoryName]);
        SendFactionMessage(attackingFactionId, COLOR_FACTION, string);
    }
    
    if(oldFactionId != -1 && Factions[oldFactionId][factionLoaded])
    {
        format(string, sizeof(string), "Your faction has lost control of %s!", Territories[territoryid][territoryName]);
        SendFactionMessage(oldFactionId, COLOR_RED, string);
    }
    
    return 1;
}

/*
* Cancel territory capture
*/
CancelTerritoryCapture(territoryid)
{
    if(territoryid < 0 || territoryid >= ServerTerritoryCount || !Territories[territoryid][territoryLoaded])
        return 0;
    
    if(!Territories[territoryid][territoryBeingCaptured])
        return 0;
    
    new attackingFactionId = Territories[territoryid][territoryAttackingFactionId];
    
    Territories[territoryid][territoryBeingCaptured] = false;
    Territories[territoryid][territoryCaptureProgress] = 0;
    Territories[territoryid][territoryAttackingFactionId] = -1;
    
    // Kill timer
    if(Territories[territoryid][territoryCaptureTimer] != -1)
    {
        KillTimer(Territories[territoryid][territoryCaptureTimer]);
        Territories[territoryid][territoryCaptureTimer] = -1;
    }
    
    // Stop gangzone flashing and notify players
    for(new p = 0; p < MAX_PLAYERS; p++)
    {
        if(IsPlayerConnected(p))
        {
            GangZoneStopFlashForPlayer(p, Territories[territoryid][territoryGangZoneId]);
            
            // Show visual feedback to players in the territory
            if(player[p][isSpawned] && GetPlayerTerritory(p) == territoryid)
            {
                GameTextForPlayer(p, "~r~CAPTURE CANCELLED", 3000, 1);
            }
        }
    }
    
    // Notify attacking faction
    new string[128];
    format(string, sizeof(string), "Capture of %s has been cancelled.", Territories[territoryid][territoryName]);
    SendFactionMessage(attackingFactionId, COLOR_YELLOW, string);
    
    if(Territories[territoryid][territoryFactionId] != -1)
    {
        format(string, sizeof(string), "%s has been defended successfully!", Territories[territoryid][territoryName]);
        SendFactionMessage(Territories[territoryid][territoryFactionId], COLOR_FACTION, string);
    }
    
    return 1;
}

// ============================================================================
// TERRITORY COMMANDS
// ============================================================================

CMD:createterritory(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to use this command.");
    
    new name[64], Float:minx, Float:miny, Float:maxx, Float:maxy;
    if(sscanf(params, "p<,>s[64]ffff", name, minx, miny, maxx, maxy))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /createterritory [name], [minx], [miny], [maxx], [maxy]");
    
    new territoryid = CreateTerritory(name, minx, miny, maxx, maxy, -1);
    
    if(territoryid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Failed to create territory. Max territories reached.");
    
    new string[128];
    format(string, sizeof(string), "Territory '%s' created (ID: %d)", name, territoryid);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    return 1;
}

CMD:deleteterritory(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to use this command.");
    
    new name[64];
    if(isnull(params))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /deleteterritory [territory name]");
    
    format(name, sizeof(name), "%s", params);
    new territoryslot = GetTerritoryByName(name);
    if(territoryslot == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Territory not found.");
    
    // Get territory ID before deleting
    new dbid = Territories[territoryslot][territoryId];
    new territoryname[64];
    format(territoryname, sizeof(territoryname), "%s", Territories[territoryslot][territoryName]);
    
    // Delete from database
    new query[128];
    mysql_format(database, query, sizeof(query), "DELETE FROM `faction_territories` WHERE `id` = %d", dbid);
    mysql_tquery(database, query);
    
    // Destroy gangzone
    if(Territories[territoryslot][territoryGangZoneId] != -1)
    {
        GangZoneDestroy(Territories[territoryslot][territoryGangZoneId]);
    }
    
    // Reset territory slot
    Territories[territoryslot][territoryLoaded] = false;
    Territories[territoryslot][territoryId] = 0;
    Territories[territoryslot][territoryName][0] = EOS;
    Territories[territoryslot][territoryMinX] = 0.0;
    Territories[territoryslot][territoryMinY] = 0.0;
    Territories[territoryslot][territoryMaxX] = 0.0;
    Territories[territoryslot][territoryMaxY] = 0.0;
    Territories[territoryslot][territoryFactionId] = -1;
    Territories[territoryslot][territoryCapturedDate] = 0;
    Territories[territoryslot][territoryGangZoneId] = -1;
    Territories[territoryslot][territoryBeingCaptured] = false;
    Territories[territoryslot][territoryAttackingFactionId] = -1;
    Territories[territoryslot][territoryCaptureProgress] = 0;
    
    new string[128];
    format(string, sizeof(string), "Territory '%s' has been deleted.", territoryname);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    return 1;
}

CMD:editterritory(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to use this command.");
    
    new name[64], option[32], value[64];
    if(sscanf(params, "p<,>s[64]s[32]s[64]", name, option, value))
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /editterritory [territory name], [option], [value]");
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Options: name, minx, miny, maxx, maxy");
        return 1;
    }
    
    new territoryslot = GetTerritoryByName(name);
    if(territoryslot == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Territory not found.");
    
    new dbid = Territories[territoryslot][territoryId];
    new query[256], string[128];
    
    if(!strcmp(option, "name", true))
    {
        format(Territories[territoryslot][territoryName], 64, "%s", value);
        mysql_format(database, query, sizeof(query), "UPDATE `faction_territories` SET `zone_name` = '%e' WHERE `id` = %d", value, dbid);
        mysql_tquery(database, query);
        
        format(string, sizeof(string), "Territory name changed to '%s'", value);
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    }
    else if(!strcmp(option, "minx", true))
    {
        new Float:newval = floatstr(value);
        Territories[territoryslot][territoryMinX] = newval;
        mysql_format(database, query, sizeof(query), "UPDATE `faction_territories` SET `min_x` = %f WHERE `id` = %d", newval, dbid);
        mysql_tquery(database, query);
        
        // Recreate gangzone with new coordinates
        if(Territories[territoryslot][territoryGangZoneId] != -1)
        {
            GangZoneDestroy(Territories[territoryslot][territoryGangZoneId]);
        }
        Territories[territoryslot][territoryGangZoneId] = GangZoneCreate(
            Territories[territoryslot][territoryMinX],
            Territories[territoryslot][territoryMinY],
            Territories[territoryslot][territoryMaxX],
            Territories[territoryslot][territoryMaxY]
        );
        
        if(Territories[territoryslot][territoryFactionId] != -1)
        {
            new factionslot = GetFactionSlotById(Territories[territoryslot][territoryFactionId]);
            if(factionslot != -1)
            {
                GangZoneShowForAll(Territories[territoryslot][territoryGangZoneId], Factions[factionslot][factionColor]);
            }
        }
        
        format(string, sizeof(string), "Territory MinX changed to %f", newval);
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    }
    else if(!strcmp(option, "miny", true))
    {
        new Float:newval = floatstr(value);
        Territories[territoryslot][territoryMinY] = newval;
        mysql_format(database, query, sizeof(query), "UPDATE `faction_territories` SET `min_y` = %f WHERE `id` = %d", newval, dbid);
        mysql_tquery(database, query);
        
        // Recreate gangzone
        if(Territories[territoryslot][territoryGangZoneId] != -1)
        {
            GangZoneDestroy(Territories[territoryslot][territoryGangZoneId]);
        }
        Territories[territoryslot][territoryGangZoneId] = GangZoneCreate(
            Territories[territoryslot][territoryMinX],
            Territories[territoryslot][territoryMinY],
            Territories[territoryslot][territoryMaxX],
            Territories[territoryslot][territoryMaxY]
        );
        
        if(Territories[territoryslot][territoryFactionId] != -1)
        {
            new factionslot = GetFactionSlotById(Territories[territoryslot][territoryFactionId]);
            if(factionslot != -1)
            {
                GangZoneShowForAll(Territories[territoryslot][territoryGangZoneId], Factions[factionslot][factionColor]);
            }
        }
        
        format(string, sizeof(string), "Territory MinY changed to %f", newval);
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    }
    else if(!strcmp(option, "maxx", true))
    {
        new Float:newval = floatstr(value);
        Territories[territoryslot][territoryMaxX] = newval;
        mysql_format(database, query, sizeof(query), "UPDATE `faction_territories` SET `max_x` = %f WHERE `id` = %d", newval, dbid);
        mysql_tquery(database, query);
        
        // Recreate gangzone
        if(Territories[territoryslot][territoryGangZoneId] != -1)
        {
            GangZoneDestroy(Territories[territoryslot][territoryGangZoneId]);
        }
        Territories[territoryslot][territoryGangZoneId] = GangZoneCreate(
            Territories[territoryslot][territoryMinX],
            Territories[territoryslot][territoryMinY],
            Territories[territoryslot][territoryMaxX],
            Territories[territoryslot][territoryMaxY]
        );
        
        if(Territories[territoryslot][territoryFactionId] != -1)
        {
            new factionslot = GetFactionSlotById(Territories[territoryslot][territoryFactionId]);
            if(factionslot != -1)
            {
                GangZoneShowForAll(Territories[territoryslot][territoryGangZoneId], Factions[factionslot][factionColor]);
            }
        }
        
        format(string, sizeof(string), "Territory MaxX changed to %f", newval);
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    }
    else if(!strcmp(option, "maxy", true))
    {
        new Float:newval = floatstr(value);
        Territories[territoryslot][territoryMaxY] = newval;
        mysql_format(database, query, sizeof(query), "UPDATE `faction_territories` SET `max_y` = %f WHERE `id` = %d", newval, dbid);
        mysql_tquery(database, query);
        
        // Recreate gangzone
        if(Territories[territoryslot][territoryGangZoneId] != -1)
        {
            GangZoneDestroy(Territories[territoryslot][territoryGangZoneId]);
        }
        Territories[territoryslot][territoryGangZoneId] = GangZoneCreate(
            Territories[territoryslot][territoryMinX],
            Territories[territoryslot][territoryMinY],
            Territories[territoryslot][territoryMaxX],
            Territories[territoryslot][territoryMaxY]
        );
        
        if(Territories[territoryslot][territoryFactionId] != -1)
        {
            new factionslot = GetFactionSlotById(Territories[territoryslot][territoryFactionId]);
            if(factionslot != -1)
            {
                GangZoneShowForAll(Territories[territoryslot][territoryGangZoneId], Factions[factionslot][factionColor]);
            }
        }
        
        format(string, sizeof(string), "Territory MaxY changed to %f", newval);
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    }
    else
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Invalid option. Use: name, minx, miny, maxx, maxy");
    }
    
    return 1;
}

CMD:setterritoryowner(playerid, params[])
{
    if(player[playerid][admin] < 5)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "You don't have permission to use this command.");
    
    new territoryname[64], factionname[64];
    if(sscanf(params, "p<,>s[64]s[64]", territoryname, factionname))
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Usage: /setterritoryowner [territory name], [faction name]");
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_INFO, "Use 'none' as faction name to make it neutral.");
        return 1;
    }
    
    new territoryslot = GetTerritoryByName(territoryname);
    if(territoryslot == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Territory not found.");
    
    new string[256], query[256];
    new dbid = Territories[territoryslot][territoryId];
    
    // Check if making neutral
    if(!strcmp(factionname, "none", true))
    {
        // Reset to neutral
        Territories[territoryslot][territoryFactionId] = -1;
        Territories[territoryslot][territoryCapturedDate] = 0;
        
        mysql_format(database, query, sizeof(query), "UPDATE `faction_territories` SET `faction_id` = -1, `captured_date` = 0 WHERE `id` = %d", dbid);
        mysql_tquery(database, query);
        
        // Update gangzone to neutral color
        if(Territories[territoryslot][territoryGangZoneId] != -1)
        {
            GangZoneHideForAll(Territories[territoryslot][territoryGangZoneId]);
            GangZoneShowForAll(Territories[territoryslot][territoryGangZoneId], 0xFFFFFF96);
        }
        
        format(string, sizeof(string), "Territory '%s' is now neutral.", territoryname);
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
        return 1;
    }
    
    // Find faction
    new factionslot = GetFactionByName(factionname);
    if(factionslot == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Faction not found.");
    
    new factiondbid = Factions[factionslot][factionId];
    
    // Set new owner
    Territories[territoryslot][territoryFactionId] = factiondbid;
    Territories[territoryslot][territoryCapturedDate] = gettime();
    
    mysql_format(database, query, sizeof(query), "UPDATE `faction_territories` SET `faction_id` = %d, `captured_date` = %d WHERE `id` = %d", 
        factiondbid, gettime(), dbid);
    mysql_tquery(database, query);
    
    // Update gangzone color
    if(Territories[territoryslot][territoryGangZoneId] != -1)
    {
        GangZoneHideForAll(Territories[territoryslot][territoryGangZoneId]);
        GangZoneShowForAll(Territories[territoryslot][territoryGangZoneId], Factions[factionslot][factionColor]);
    }
    
    format(string, sizeof(string), "Territory '%s' is now owned by [%s] %s", 
        territoryname, Factions[factionslot][factionTag], Factions[factionslot][factionName]);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    return 1;
}

CMD:captureterritory(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    // Check if player is in a faction
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be in a faction to capture territories.");
    
    // Check if player is in a territory
    new territoryid = GetPlayerTerritory(playerid);
    if(territoryid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a territory.");
    
    // Check if territory is unclaimed - must use /claimterritory instead
    if(Territories[territoryid][territoryFactionId] == -1)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "This territory is unclaimed. Use /claimterritory to purchase it.");
        return 1;
    }
    
    // Check if already owned by their faction
    if(Territories[territoryid][territoryFactionId] == factionid)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Your faction already owns this territory.");
    
    // Check if already being captured
    if(Territories[territoryid][territoryBeingCaptured])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "This territory is already being captured.");
    
    // Start capture
    new result = StartTerritoryCapture(territoryid, factionid);
    if(result == 1)
    {
        new string[128];
        format(string, sizeof(string), "Started capturing %s! Stay in the area to capture it.", Territories[territoryid][territoryName]);
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
        
        // Show visual feedback (style 1 = bottom right corner)
        GameTextForPlayer(playerid, "~g~CAPTURE STARTED~n~~w~Stay in the zone!", 3000, 1);
    }
    else if(result == -1)
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Cannot capture this territory - no members of the defending faction are online.");
    }
    else
    {
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "Failed to start territory capture.");
    }
    
    return 1;
}

CMD:claimterritory(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    // Check if player is in a faction
    new factionslot = PlayerFaction[playerid][playerFactionId];
    if(factionslot == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be in a faction to claim territories.");
    
    // Check if player has permission (only leader can claim)
    if(!IsPlayerFactionLeader(playerid))
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_DENIED, "Only the faction leader can claim territories.");
    
    // Check if player is in a territory
    new territoryid = GetPlayerTerritory(playerid);
    if(territoryid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a territory.");
    
    // Check if territory is unclaimed
    if(Territories[territoryid][territoryFactionId] != -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "This territory is already claimed. Use /captureterritory to take it from another faction.");
    
    // Check if faction has enough money
    if(Factions[factionslot][factionBankBalance] < TERRITORY_CLAIM_COST)
    {
        new string[128];
        format(string, sizeof(string), "Your faction needs $%d in the bank to claim a territory. Current balance: $%d", 
            TERRITORY_CLAIM_COST, Factions[factionslot][factionBankBalance]);
        SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, string);
        return 1;
    }
    
    // Deduct cost from faction bank
    new newBalance = Factions[factionslot][factionBankBalance] - TERRITORY_CLAIM_COST;
    UpdateFactionBank(factionslot, newBalance);
    
    // Claim the territory
    Territories[territoryid][territoryFactionId] = factionslot;
    Territories[territoryid][territoryCapturedDate] = gettime();
    
    // Update territory in database
    new query[256];
    mysql_format(database, query, sizeof(query),
        "UPDATE `faction_territories` SET `faction_id` = %d, `captured_date` = %d WHERE `id` = %d",
        Factions[factionslot][factionId], gettime(), Territories[territoryid][territoryId]);
    mysql_tquery(database, query);
    
    // Update gangzone color
    UpdateTerritoryColor(territoryid);
    
    // Notify player and faction
    new string[128];
    format(string, sizeof(string), "Successfully claimed %s for $%d!", Territories[territoryid][territoryName], TERRITORY_CLAIM_COST);
    SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_SUCCESS, string);
    
    format(string, sizeof(string), "[FACTION] %s has claimed the territory '%s' for $%d", 
        player[playerid][chosenChar], Territories[territoryid][territoryName], TERRITORY_CLAIM_COST);
    SendFactionMessage(factionslot, COLOR_FACTION, string);
    
    // Show visual feedback (style 1 = bottom right corner)
    GameTextForPlayer(playerid, "~g~TERRITORY CLAIMED!", 3000, 1);
    
    return 1;
}

CMD:territories(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    new factionid = PlayerFaction[playerid][playerFactionId];
    if(factionid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a faction.");
    
    new count = 0;
    new string[128];
    
    SendClientMessage(playerid, COLOR_FACTION, "=== Faction Territories ===");
    
    for(new i = 0; i < ServerTerritoryCount; i++)
    {
        if(!Territories[i][territoryLoaded])
            continue;
        
        if(Territories[i][territoryFactionId] == factionid)
        {
            format(string, sizeof(string), "- %s (Captured: %s)", 
                Territories[i][territoryName],
                ConvertTimeToDate(Territories[i][territoryCapturedDate])
            );
            SendClientMessage(playerid, COLOR_WHITE, string);
            count++;
        }
    }
    
    if(count == 0)
    {
        SendClientMessage(playerid, COLOR_GREY, "Your faction doesn't own any territories.");
    }
    else
    {
        format(string, sizeof(string), "Total: %d territories", count);
        SendClientMessage(playerid, COLOR_FACTION, string);
    }
    
    return 1;
}

CMD:territoryinfo(playerid, params[])
{
    if(!player[playerid][isSpawned])
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You must be spawned to use this command.");
    
    new territoryid = GetPlayerTerritory(playerid);
    if(territoryid == -1)
        return SendPlayerServerMessage(playerid, COLOR_SYSTEM, PLR_SERVER_MSG_TYPE_ERROR, "You are not in a territory.");
    
    new string[256];
    
    SendClientMessage(playerid, COLOR_FACTION, "=== Territory Information ===");
    
    format(string, sizeof(string), "Name: %s", Territories[territoryid][territoryName]);
    SendClientMessage(playerid, COLOR_WHITE, string);
    
    if(Territories[territoryid][territoryFactionId] != -1)
    {
        // territoryFactionId is already a slot index
        new factionSlot = Territories[territoryid][territoryFactionId];
        if(Factions[factionSlot][factionLoaded])
        {
            format(string, sizeof(string), "Owner: [%s] %s", 
                Factions[factionSlot][factionTag],
                Factions[factionSlot][factionName]
            );
            SendClientMessage(playerid, COLOR_WHITE, string);
            
            format(string, sizeof(string), "Captured: %s", 
                ConvertTimeToDate(Territories[territoryid][territoryCapturedDate])
            );
            SendClientMessage(playerid, COLOR_WHITE, string);
        }
    }
    else
    {
        SendClientMessage(playerid, COLOR_GREY, "Owner: None (Neutral)");
        
        // Show claim information for unclaimed territories
        new playerFactionSlot = PlayerFaction[playerid][playerFactionId];
        if(playerFactionSlot != -1)
        {
            SendClientMessage(playerid, COLOR_YELLOW, " ");
            format(string, sizeof(string), "This territory can be claimed by your faction leader for $%d", TERRITORY_CLAIM_COST);
            SendClientMessage(playerid, COLOR_GREEN, string);
            SendClientMessage(playerid, COLOR_WHITE, "Use: /claimterritory (leader only)");
        }
    }
    
    if(Territories[territoryid][territoryBeingCaptured])
    {
        // territoryAttackingFactionId is already a slot index
        new attackingSlot = Territories[territoryid][territoryAttackingFactionId];
        if(attackingSlot != -1 && Factions[attackingSlot][factionLoaded])
        {
            format(string, sizeof(string), "~r~UNDER ATTACK by [%s] %s", 
                Factions[attackingSlot][factionTag],
                Factions[attackingSlot][factionName]
            );
            SendClientMessage(playerid, COLOR_RED, string);
            
            new progress = (Territories[territoryid][territoryCaptureProgress] * 100) / TERRITORY_CAPTURE_TIME;
            new timeRemaining = TERRITORY_CAPTURE_TIME - Territories[territoryid][territoryCaptureProgress];
            
            // Create visual progress bar
            new barLength = progress / 5; // 20 characters max
            if(barLength > 20) barLength = 20;
            
            new progressBar[64] = "Progress: [";
            for(new i = 0; i < 20; i++)
            {
                if(i < barLength)
                    strcat(progressBar, "|");
                else
                    strcat(progressBar, ".");
            }
            strcat(progressBar, "]");
            
            SendClientMessage(playerid, COLOR_YELLOW, progressBar);
            
            format(string, sizeof(string), "Capture: %d%% complete (~%d seconds remaining)", progress, timeRemaining);
            SendClientMessage(playerid, COLOR_YELLOW, string);
        }
    }
    
    return 1;
}

#endif // MODULE_FACTIONS_INCLUDED
