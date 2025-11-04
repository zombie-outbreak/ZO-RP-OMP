// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - INTERIOR SYSTEM
// ============================================================================
/*
* MODULE: Interiors
* PURPOSE: Property and interior management system
* 
* DEPENDENCIES:
* - core/config.pwn
* - core/constants.pwn
* - core/player_data.pwn
* - core/database.pwn
* 
* PUBLIC FUNCTIONS:
* - LoadInteriors() - Load all interiors from database
* - GetPlayerInterior(playerid) - Get player's current interior
* - EnterInterior(playerid, interiorid) - Teleport player to interior
* - ExitInterior(playerid) - Teleport player out of interior
* - CreateInterior() - Create a new interior
* 
* DESCRIPTION:
* Manages all interior-related functionality including:
* - Player homes
* - Faction bases
* - Public buildings
* - Interior pickups and entrances
* - Ownership and locking
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_INTERIORS_INCLUDED
#define MODULE_INTERIORS_INCLUDED

// ============================================================================
// DATA STRUCTURES
// ============================================================================

/*
* Interior Data Enum
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

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

new serverInteriorCount = 0;
new srvInterior[MAX_SERVER_INTERIORS][E_INTERIORS];
new interiorEnterPickup[MAX_SERVER_INTERIORS];
new interiorExitPickup[MAX_SERVER_INTERIORS];

// ============================================================================
// FORWARD DECLARATIONS
// ============================================================================

// Add your interior system forward declarations here
// forward OnInteriorsLoad();
// forward OnPlayerEnterInterior(playerid, interiorid);
// forward OnPlayerExitInterior(playerid, interiorid);

#endif // MODULE_INTERIORS_INCLUDED
