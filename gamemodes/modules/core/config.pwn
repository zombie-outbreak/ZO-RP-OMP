// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - CORE CONFIGURATION
// ============================================================================
/*
* MODULE: Server Configuration
* PURPOSE: Central server configuration including MySQL, server settings
* 
* DEPENDENCIES: None (Core module)
* 
* DESCRIPTION:
* Contains all server-level configuration including:
* - Server name, version, website
* - MySQL database connection settings
* - Default spawn locations
* - Server directories
* - Security settings (RCON, password)
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_CORE_CONFIG_INCLUDED
#define MODULE_CORE_CONFIG_INCLUDED

// Pawn compiler settings
#define SAMP_CONST_CORRECT
#define NO_TAGS

// ============================================================================
// SERVER INFORMATION
// ============================================================================

#define SERVER_NAME	"Zombie Outbreak Roleplay [Account required on zo-rp.com]"
#define SERVER_RCON	"changethisifgoingpublic" // the live server has one I set when I compile for release
#define SERVER_PASSWORD	"0" // set to 0 for no server password, current live server is password protected
#define SERVER_VERSION "Zombie Outbreak v0.2.0"
#define SERVER_VERSION_SHORT "v0.2.0"
#define SERVER_MAP "The Fallen World"
#define SERVER_WEBSITE "https://beta.zo-rp.com"
#define DISCORD_URL "https://discord.com/invite/4J9KGyspU5"

// ============================================================================
// DATABASE CONFIGURATION
// ============================================================================

/*
* MySQL database credentials have been moved to mysql.ini
* This keeps sensitive information out of source code
* Configure your database connection in the mysql.ini file in the server root
*/

// ============================================================================
// DEFAULT SPAWN CONFIGURATION
// ============================================================================

#define DEFAULT_POS_X -2488.4236
#define DEFAULT_POS_Y 2215.8281
#define DEFAULT_POS_Z 4.9844
#define DEFAULT_POS_A 357.1140

// ============================================================================
// SERVER DIRECTORIES
// ============================================================================

#define MAP_DIRECTORY "scriptfiles/maps/" // MTA .map files are loaded from this directory

// ============================================================================
// SECURITY & LOGIN
// ============================================================================

#define SECONDS_TO_LOGIN 60 // Seconds until player is kicked if not logged in

#endif // MODULE_CORE_CONFIG_INCLUDED
