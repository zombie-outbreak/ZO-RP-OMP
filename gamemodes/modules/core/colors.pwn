// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - COLOR DEFINITIONS
// ============================================================================
/*
* MODULE: Colors
* PURPOSE: Centralized color definitions for the server
* 
* DEPENDENCIES: None (Core module)
* 
* DESCRIPTION:
* Contains all color definitions used throughout the server:
* - Standard colors (0xRRGGBBAA format)
* - Embeddable colors (for use in strings)
* - Special purpose colors (admin, system, PM, etc.)
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_CORE_COLORS_INCLUDED
#define MODULE_CORE_COLORS_INCLUDED

// ============================================================================
// STANDARD COLORS (0xRRGGBBAA format)
// ============================================================================

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

// ============================================================================
// SPECIAL PURPOSE COLORS
// ============================================================================

#define COLOR_ADMINISTRATOR 0xa0d3ffAA
#define COLOR_SYSTEM 0xECF2B1FF
#define COLOR_ADMINMSG 0xFF6347FF
#define COLOR_LIGHTRED 0xFF0000AA
#define COLOR_LIGHTBLUE 0x8D8DFF00
#define COLOR_LIGHTGREEN 0x9ACD32AA
#define PM_INCOMING_COLOR 0xFFFF22AA
#define PM_OUTGOING_COLOR 0xFFCC2299
#define COLOR_RP_PURPLE 0xC5A5DEFF
#define COLOR_FACTION 0x00FF00FF

// ============================================================================
// EMBEDDABLE COLORS (For use in strings)
// ============================================================================

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

#endif // MODULE_CORE_COLORS_INCLUDED
