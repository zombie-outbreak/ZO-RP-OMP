// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - CORE CONSTANTS
// ============================================================================
/*
* MODULE: Game Constants
* PURPOSE: Global game constants and limits
* 
* DEPENDENCIES:
* - core/config.pwn
* 
* DESCRIPTION:
* Contains all game-wide constants including:
* - Maximum limits (players, items, vehicles, etc.)
* - HUD element IDs
* - Category definitions
* - Timer durations
* - Key bindings
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_CORE_CONSTANTS_INCLUDED
#define MODULE_CORE_CONSTANTS_INCLUDED

// ============================================================================
// PLAYER & SERVER LIMITS
// ============================================================================

#define MAX_PLAYERS 50 // adjust as needed (needs to include total for maximum zombie NPCs too)
#define MAX_CA_OBJECTS 50000 // Maximum ColAndreas Objects for collision detection

// ============================================================================
// VEHICLE CONFIGURATION
// ============================================================================

#define VEHICLE_RESPAWN_TIME -1 // -1 = never respawn

// ============================================================================
// INTERIOR SYSTEM
// ============================================================================

#define MAX_SERVER_INTERIORS 500 // increase if required
#define INTERIOR_ENTER_EXIT_RANGE 2.0
#define MAX_LOCKERS 1

// Interior Types
#define INTERIOR_TYPE_PLAYERHOME 1
#define INTERIOR_TYPE_FACTIONBASE 2 // unused until faction system in place
#define INTERIOR_TYPE_PUBLIC 3

// Interior Pickup IDs
#define UNOWNED_PLAYERHOME_PICKUP 1273
#define UNOWNED_FACTIONBASE_PICKUP 1272 // unused until faction system in place
#define OWNED_PROPERTY_PICKUP 19522
#define ENTER_EXIT_INTERIOR_PICKUP 1318

// ============================================================================
// HUD ELEMENT IDS
// ============================================================================

#define HUD_HUNGER 0
#define HUD_THIRST 1
#define HUD_DISEASE 2
#define HUD_HEALTH 3
#define HUD_INFO 4
#define HUD_CLOCK 5
#define HUD_VEHICLE 6
#define HUD_ALL 7

// ============================================================================
// LEVELS AND EXPERIENCE
// ============================================================================

#define MAX_LEVELS 30

// ============================================================================
// INVENTORY, LOOTING, VENDORS
// ============================================================================

#define MAX_ITEMS 150 // increase as needed
#define INVALID_ITEM 0
#define MAX_SCAV_AREAS 5000 // increase if required
#define MAX_VENDORS 20
#define MAX_LOOT_TABLES 50

// Shop System
#define MAX_SHOPS 100
#define INVALID_SHOP_ID -1
#define SHOP_INTERACTION_RANGE 2.0

// Inventory Categories
#define INV_CATEGORY_UNKNOWN -1
#define CATEGORY_GENERAL 0
#define CATEGORY_FOOD 1
#define CATEGORY_DRINK 2
#define CATEGORY_MEDICAL 3
#define CATEGORY_WEAPONS 4
#define CATEGORY_AMMO 5

// Loot & Crafting
#define CHANCE 100
#define DEFAULT_HEALAMOUNT -1
#define DEFAULT_AMMO -1
#define MAX_RECIPES 100 // Maximum number of crafting recipes

// Scavenging Area Types (also used for Loot Table IDs)
#define SCAV_AREA_SCRAP 0
#define SCAV_AREA_WEAPONS 1 // includes ammo
#define SCAV_AREA_BODY 2
#define SCAV_AREA_FOODDRINK 3
#define SCAV_AREA_MEDICAL 4
#define SCAV_AREA_MONEY 5
#define SCAV_AREA_GASSTATION 6

// Search Timers
#define SEARCH_NODE_RESET_TIME 300000 // 5 minutes (in ms)

// ============================================================================
// TIMERS AND COOLDOWNS (Time in milliseconds)
// ============================================================================

// Time System Configuration
#define SERVER_TIME_MULTIPLIER 10 // How much faster than real time (10x = 2.4 hour real day = 24 hour game day)

#define HUNGER_TIMER_DURATION 30000 * 5 // 2.5 minutes
#define THIRST_TIMER_DURATION 10000 * 5 // 50 seconds
#define DISEASE_TIMER_DURATION 60000 * 3 // 3 minutes
#define LOCATION_TIMER_DURATION 60000 * 15 // 15 minutes
#define BITE_COOLDOWN 15000 // 15 seconds
#define STUN_COOLDOWN 30000 // 30 seconds
#define GRAB_COOLDOWN 30000 // 30 seconds
#define VENDING_MACHINE_COOLDOWN 30000 // 30 seconds
#define FUEL_TIMER 25000 // 25 seconds

// ============================================================================
// CHARACTER SYSTEM
// ============================================================================

#define MAX_CHARACTERS 17

// Model Selection Dialog Types
#define MODEL_SELECTION_SKIN_MENU 0
#define CHARACTER_SELECTION_SKIN_MENU 1

// ============================================================================
// FACTION SYSTEM
// ============================================================================

#define TEAM_ZOMBIE 0

// ============================================================================
// MESSAGE TYPES
// ============================================================================

// Proximity Message Types
#define PROXY_MSG_TYPE_ME 0
#define PROXY_MSG_TYPE_INVENTORY_EQUIP 1
#define PROXY_MSG_TYPE_INVENTORY_UNEQUIP 2
#define PROXY_MSG_TYPE_DO 3
#define PROXY_MSG_TYPE_OOCCHAT 4
#define PROXY_MSG_TYPE_SHOUT 5
#define PROXY_MSG_TYPE_CHAT 6
#define PROXY_MSG_TYPE_OTHER 7

// Player Server Message Types
#define PLR_SERVER_MSG_TYPE_INFO 0
#define PLR_SERVER_MSG_TYPE_ERROR 1
#define PLR_SERVER_MSG_TYPE_DENIED 2
#define PLR_SERVER_MSG_TYPE_SUCCESS 3

// ============================================================================
// FUEL SYSTEM
// ============================================================================

#define MAX_FUEL_PUMPS 100 // increase as needed
#define FUEL_PUMP_RANGE 2.5
#define FILL_TYPE_FUELPUMP 0
#define FILL_TYPE_FUELCAN 1

// ============================================================================
// MAP CONVERSION
// ============================================================================

#define MAX_REMOVED_OBJECTS 1000 // Maximum number of remove object lines

// ============================================================================
// KEY BINDINGS HELPER MACROS
// ============================================================================

#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

// ============================================================================
// PERKS SYSTEM
// ============================================================================

// Human Perks
#define MAX_PERKS_HUM 5
#define H_PERK_TINKERER 0
#define H_PERK_MECHANIC 1
#define H_PERK_MEDIC 2
#define H_PERK_GOURMET 3
#define H_PERK_LOOTER 4

// Zombie Perks
#define MAX_PERKS_ZOM 11
#define Z_PERK_HP 0
#define Z_PERK_JUMP 1
#define Z_PERK_MELEEDAM 2
#define Z_PERK_BITE 3
#define Z_PERK_COMBUST 4
#define Z_PERK_STUN 5
#define Z_PERK_GRAB 6
#define Z_PERK_BSTR 7
#define Z_PERK_SJUMP 8
#define Z_PERK_CORNERED 9
#define Z_PERK_HUNT 10

// Perk Constants
#define INITIAL_MAX_HEALTH_ZED 200.0
#define INITIAL_MAX_HEALTH_HUM 100.0
#define VK_KEYB1 0x31
#define JUMP_SKILL_GRAVITY 0.005 // Adjust value to fit game balance
#define DEFAULT_SERVER_GRAVITY 0.008
#define BITE_DAMAGE 10
#define GRAB_RANGE 10.0
#define STUN_RANGE 3.0

#endif // MODULE_CORE_CONSTANTS_INCLUDED
