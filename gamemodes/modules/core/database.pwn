// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - DATABASE CONNECTION
// ============================================================================
/*
* MODULE: Database
* PURPOSE: MySQL database connection handle
* 
* DEPENDENCIES:
* - core/config.pwn
* - a_mysql library
* 
* DESCRIPTION:
* Contains the global MySQL database connection handle used throughout
* the server for all database operations.
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_CORE_DATABASE_INCLUDED
#define MODULE_CORE_DATABASE_INCLUDED

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

new MySQL:database; // Global MySQL connection handle

#endif // MODULE_CORE_DATABASE_INCLUDED
