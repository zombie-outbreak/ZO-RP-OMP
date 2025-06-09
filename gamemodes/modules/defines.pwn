/*
* Zombie Outbreak Roleplay
* (C) 2025 Zombie Outbreak Development Contributors
* GNU General Public License v3.0
*/
#define SAMP_CONST_CORRECT
#define NO_TAGS
#define CGEN_MEMORY 20000
#define WC_CUSTOM_VENDING_MACHINES false // should disable vending machines

/*
* Max ColAndreas Objects
* This is the maximum number of objects that the plugin can add collisions for
*/
#define MAX_CA_OBJECTS 50000

/*
* Set below to false if the server is a test server
*/
#define SERVER_LIVE false

/*
* Server configuration
*/
#define SERVER_NAME	"Zombie Outbreak Roleplay"
#define SERVER_RCON	"rconpass123" // the live server has one I set when I compile for release
#define SERVER_PASSWORD	"Nuts7bolts" // set to 0 for no server password, current live server is password protected
#define SERVER_VERSION "Zombie Outbreak PT" // PT = public test
#define SERVER_VERSION_SHORT "PT"
#define SERVER_MAP "The Fallen World"
#define SERVER_WEBSITE "https://zo-rp.com"
#define DISCORD_URL "https://discord.com/invite/4J9KGyspU5"

/*
* Seconds until player is kicked if not logged in.
*/
#define	SECONDS_TO_LOGIN 60

/*
* Default spawn location
*/
#define DEFAULT_POS_X -2488.4236
#define DEFAULT_POS_Y 2215.8281
#define DEFAULT_POS_Z 4.9844
#define DEFAULT_POS_A 357.1140

/*
* Server Directories
*/
#define MAP_DIRECTORY "scriptfiles/maps/" // MTA .map files are loaded from this directory

/*
* Colours (0xRRGGBBAA)
*/
#define COLOR_BLACK 0x000000FF
#define COLOR_RED 0xFF0000FF
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_BLUE 0x2641FEAA
#define COLOR_GREEN 0x008000FF
#define COLOR_YELLOW 0xFFFF00FF
#define COLOR_ORANGE 0xFFA500FF
#define COLOR_CYAN 0x00FFFFFF
#define COLOR_PURPLE 0x580C7AFF
#define COLOR_LIGHTPURPLE 0xc013a0FF
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_LIGHTCYAN 0xE0FFFFFF
#define COLOR_TEAL 0x008080FF
#define COLOR_ADMINISTRATOR 0xa0d3ffAA
#define COLOR_SYSTEM 0xECF2B1FF
#define COLOR_ADMINMSG 0xFF6347FF
#define COLOR_LIGHTRED 0xFF0000AA
#define COLOR_LIGHTBLUE 0x8D8DFF00
#define COLOR_LIGHTGREEN 0x9ACD32AA
#define PM_INCOMING_COLOR 0xFFFF22AA
#define PM_OUTGOING_COLOR 0xFFCC2299
#define COLOR_RP_PURPLE 0xC5A5DEFF

/*
* Embedable colours
*/
#define COL_WHITE "{FFFFFF}"
#define COL_RED "{FF0000}"
#define COL_GREEN "{33AA33}"
#define COL_BLUE "{2641FE}"
#define COL_LBLUE "{D3DCE3}"
#define COL_YELLOW "{FFFF00}"
#define COL_ORANGE "{FF8300}"
#define COL_LIGHTBLUE "{00FFEE}"
#define COL_BLACK "{0E0101}"
#define COL_GRAY "{808080}"
#define COL_DGREEN "{336633}"
#define COL_LIGHTCYAN "{E0FFFF}"
#define COL_TEAL "{008080}"
#define COL_LIGHTGREEN "{9ACD32}"
#define COL_SYSTEM "{ECF2B1}"

/*
* Maximum number of remove object lines
*/
#define MAX_REMOVED_OBJECTS 1000

/*
* Server Settings
*/
#define VEHICLE_RESPAWN_TIME -1

/*
* Maximum Interiors, lockers etc
*/
#define MAX_SERVER_INTERIORS 500 // increase if required
#define INTERIOR_ENTER_EXIT_RANGE 2.0
#define MAX_LOCKERS 1

/*
* HUD Element IDs
*/
#define HUD_HUNGER 0
#define HUD_THIRST 1
#define HUD_DISEASE 2
#define HUD_HEALTH 3
#define HUD_INFO 4
#define HUD_CLOCK 5
#define HUD_VEHICLE 6
#define HUD_ALL 7

/*
* Levels and EXP
*/
#define MAX_LEVELS 30

/*
* Inventory, Looting, Vendors
*/
#define MAX_ITEMS 150 // increase as needed
#define INVALID_ITEM 0
#define MAX_SCAV_AREAS 5000 // increase if required.
#define INV_CATEGORY_UNKNOWN -1
#define CATEGORY_GENERAL 0
#define CATEGORY_FOOD 1
#define CATEGORY_DRINK 2
#define CATEGORY_MEDICAL 3
#define CATEGORY_WEAPONS 4
#define CATEGORY_AMMO 5
#define CHANCE 100
#define MAX_VENDORS 20
#define DEFAULT_HEALAMOUNT -1
#define DEFAULT_AMMO -1
#define SEARCH_NODE_RESET_TIME 300000 // 5 minutes (in ms)
#define MAX_LOOT_TABLES 50

/*
* Scavenging area types
* Loot Table ID also use the same IDs
*/
#define SCAV_AREA_SCRAP 0
#define SCAV_AREA_WEAPONS 1 // includes ammo
#define SCAV_AREA_BODY 2
#define SCAV_AREA_FOODDRINK 3
#define SCAV_AREA_MEDICAL 4
#define SCAV_AREA_MONEY 5
#define SCAV_AREA_GASSTATION 6

/*
* Hunger and Thirst timers
* Time in ms
*/
#define HUNGER_TIMER_DURATION 30000 * 5 // 2.5 minutes
#define THIRST_TIMER_DURATION 10000 * 5 // 50 seconds
#define DISEASE_TIMER_DURATION 60000 * 3 // 3 minutes

/*
* Max Character
*/
#define MAX_CHARACTERS 17

/*
* skin model selection dialog
*/
#define MODEL_SELECTION_SKIN_MENU 0
#define CHARACTER_SELECTION_SKIN_MENU 1

/*
* Interior Types
*/
#define INTERIOR_TYPE_PLAYERHOME 1
#define INTERIOR_TYPE_FACTIONBASE 2
#define INTERIOR_TYPE_PUBLIC 3

/*
* Interior pickup IDs
*/
#define UNOWNED_PLAYERHOME_PICKUP 1273
#define UNOWNED_FACTIONBASE_PICKUP 1272
#define OWNED_PROPERTY_PICKUP 19522
#define ENTER_EXIT_INTERIOR_PICKUP 1318

/*
* Factions
*/
#define FACTION_CREATION_PRICE 1000
#define MAX_FACTION_RANKS 10
#define MAX_FACTIONS 1000
#define MAX_FACTION_MEMBERS 500
#define TEAM_ZOMBIE 0

/*
* String Types (Proximity Messages)
*/
#define PROXY_MSG_TYPE_ME 0
#define PROXY_MSG_TYPE_INVENTORY_EQUIP 1
#define PROXY_MSG_TYPE_INVENTORY_UNEQUIP 2
#define PROXY_MSG_TYPE_DO 3
#define PROXY_MSG_TYPE_OOCCHAT 4
#define PROXY_MSG_TYPE_SHOUT 5
#define PROXY_MSG_TYPE_CHAT 6
#define PROXY_MSG_TYPE_OTHER 7

/*
* String Types (Player Server Messages)
*/
#define PLR_SERVER_MSG_TYPE_INFO 0
#define PLR_SERVER_MSG_TYPE_ERROR 1
#define PLR_SERVER_MSG_TYPE_DENIED 2

/*
* Fuel
*/
#define MAX_FUEL_PUMPS 100 // increase as needed
#define FUEL_PUMP_RANGE 2.5
#define FILL_TYPE_FUELPUMP 0
#define FILL_TYPE_FUELCAN 1

//perktests
#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))
#define INITIAL_MAX_HEALTH_ZED 200.0
#define INITIAL_MAX_HEALTH_HUM 100.0
#define VK_KEYB1 0x31
#define JUMP_SKILL_GRAVITY 0.005 // Adjust value to fit game balance
#define DEFAULT_SERVER_GRAVITY 0.008
//perktests