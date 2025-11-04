// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - MAP LOADING SYSTEM
// ============================================================================
/*
* MODULE: Map
* PURPOSE: MTA .map file parser and object spawning
* 
* DEPENDENCIES:
* - core/config.pwn
* - core/constants.pwn
* - XML Plugin (Zeex's XML plugin)
* - Streamer Plugin
* - ColAndreas Plugin
* - systems/vehicles.pwn (for SetupVehicleForSpawn)
* 
* PUBLIC FUNCTIONS:
* - ParseMapFiles() - Parse and load all .map files from scriptfiles/maps/
* - RemoveBuildings() - Apply building removals to a player
* 
* DESCRIPTION:
* Handles all map loading functionality including:
* - XML parsing of MTA .map files
* - Dynamic object creation with streaming
* - ColAndreas collision object creation
* - Vehicle spawning from map files
* - Building removal management
* - Vehicle color management
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_MAP_INCLUDED
#define MODULE_MAP_INCLUDED

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

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

// ============================================================================
// MAP PARSING FUNCTIONS
// ============================================================================

DecimalABS(Value)
{
	if (0 > Value) Value = -Value;
	return Value;
}

FindClosetVehicleColor(R, G, B)
{
	new iClosetDifference = 1000;
	new iCloset = 0;
	for (new i = 0; 256 > i; i++)
	{
		new VR = ((VehicleColoursTableRGBA[i] >> 24) & 0xFF);
		new VG = ((VehicleColoursTableRGBA[i] >> 16) & 0xFF);
		new VB = ((VehicleColoursTableRGBA[i] >> 8) & 0xFF);
	    new iDifference = DecimalABS(VR - R) + DecimalABS(VG - G) + DecimalABS(VB - B);
	    if (iDifference > iClosetDifference) continue;
	    
	    iClosetDifference = iDifference;
	    iCloset = i;
	}
	return iCloset;
}

ParseMapFiles()
{
    new mapDirectory[128];
    new cMapName[128];
    new dItem[64];
    new dType;
    new iObjects = 0;
    new iVehicles = 0;
    new timeMs = GetTickCount();
    
    // XML parsing variables
    new XMLNode:xmlDoc, XMLNode:xmlNode;
    new xmlNodeValue[64], xmlValue[256];
    new Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ;
    new model;
    new cVehicleColor[64], tmpVehiclePlate[32];

    // although this data is not loaded from the map, it looks tidier in the logs on startup to show all the stats here
    printf("|-> Vehicle Respawn Delay: %d", VEHICLE_RESPAWN_TIME);

    format(mapDirectory, sizeof(mapDirectory), "%s", MAP_DIRECTORY);
    new dir:dDir = dir_open(mapDirectory);
    new fileStartTime = GetTickCount();

    while(dir_list(dDir, dItem, dType))
    {
        if (dType != FM_FILE) continue;
        if (0 > strfind(dItem, ".map")) continue;

        format(cMapName, sizeof(cMapName), "/maps/%s", dItem);
        printf("|-> Parsing: %s (using XML plugin)", cMapName);
        
        // Load XML document
        xmlDoc = XML_LoadDocument(cMapName);
        if(!xmlDoc)
        {
            print("|-> ERROR: Failed to load XML file!");
            continue;
        }
        
        // Get first child of the document (should be the root element like <map>)
        xmlNode = XML_GetFirstChild(xmlDoc);
        if(!xmlNode)
        {
            print("|-> ERROR: No root element found!");
            XML_UnloadDocument(xmlDoc);
            continue;
        }
        
        // Iterate through all child elements
        xmlNode = XML_GetFirstChild(xmlNode);
        
        while(xmlNode)
        {
            // Get node value (element name)
            XML_GetValue(xmlNode, xmlNodeValue, sizeof(xmlNodeValue));
            
            if(strcmp(xmlNodeValue, "object", false) == 0)
            {
                // Parse object attributes
                XML_GetAttribute(xmlNode, "model", xmlValue, sizeof(xmlValue));
                model = strval(xmlValue);
                
                XML_GetAttribute(xmlNode, "posX", xmlValue, sizeof(xmlValue));
                fX = floatstr(xmlValue);
                
                XML_GetAttribute(xmlNode, "posY", xmlValue, sizeof(xmlValue));
                fY = floatstr(xmlValue);
                
                XML_GetAttribute(xmlNode, "posZ", xmlValue, sizeof(xmlValue));
                fZ = floatstr(xmlValue);
                
                XML_GetAttribute(xmlNode, "rotX", xmlValue, sizeof(xmlValue));
                fRotX = floatstr(xmlValue);
                
                XML_GetAttribute(xmlNode, "rotY", xmlValue, sizeof(xmlValue));
                fRotY = floatstr(xmlValue);
                
                XML_GetAttribute(xmlNode, "rotZ", xmlValue, sizeof(xmlValue));
                fRotZ = floatstr(xmlValue);
                
                // Create object with ColAndreas collision for cover mechanics
                CA_CreateDynamicObject_DC(model, fX, fY, fZ, fRotX, fRotY, fRotZ);
                iObjects++;
            }
            else if(strcmp(xmlNodeValue, "vehicle", false) == 0)
            {
                // Parse vehicle attributes
                XML_GetAttribute(xmlNode, "model", xmlValue, sizeof(xmlValue));
                model = strval(xmlValue);
                
                XML_GetAttribute(xmlNode, "posX", xmlValue, sizeof(xmlValue));
                fX = floatstr(xmlValue);
                
                XML_GetAttribute(xmlNode, "posY", xmlValue, sizeof(xmlValue));
                fY = floatstr(xmlValue);
                
                XML_GetAttribute(xmlNode, "posZ", xmlValue, sizeof(xmlValue));
                fZ = floatstr(xmlValue);
                
                XML_GetAttribute(xmlNode, "rotZ", xmlValue, sizeof(xmlValue));
                fRotZ = floatstr(xmlValue);
                
                XML_GetAttribute(xmlNode, "plate", tmpVehiclePlate, sizeof(tmpVehiclePlate));
                XML_GetAttribute(xmlNode, "color", cVehicleColor, sizeof(cVehicleColor));
                
                // Parse RGB colors (format: "R,G,B,R,G,B")
                new cVehicleRGBColor[2][3];
                for(new c1 = 0; c1 < 2; c1++)
                {
                    for(new c2 = 0; c2 < 3; c2++)
                    {
                        new cVehicleColorTemp[4];
                        new iComma = strfind(cVehicleColor, ",");
                        if(iComma < 0) iComma = strlen(cVehicleColor); // Last value
                        strmid(cVehicleColorTemp, cVehicleColor, 0, iComma);
                        strdel(cVehicleColor, 0, iComma + 1);
                        cVehicleRGBColor[c1][c2] = strval(cVehicleColorTemp);
                    }
                }
                
                new iVehicleID = CreateVehicle(
                    model, fX, fY, fZ, fRotZ,
                    FindClosetVehicleColor(cVehicleRGBColor[0][0], cVehicleRGBColor[0][1], cVehicleRGBColor[0][2]),
                    FindClosetVehicleColor(cVehicleRGBColor[1][0], cVehicleRGBColor[1][1], cVehicleRGBColor[1][2]),
                    VEHICLE_RESPAWN_TIME
                );
                SetVehicleNumberPlate(iVehicleID, tmpVehiclePlate);
                SetupVehicleForSpawn(iVehicleID);
                iVehicles++;
            }
            else if(strcmp(xmlNodeValue, "removeWorldObject", false) == 0)
            {
                // Parse removeWorldObject attributes
                XML_GetAttribute(xmlNode, "model", xmlValue, sizeof(xmlValue));
                removedObjectModel[removedObjects] = strval(xmlValue);
                
                XML_GetAttribute(xmlNode, "lodModel", xmlValue, sizeof(xmlValue));
                removedObjectLodModel[removedObjects] = strval(xmlValue);
                
                XML_GetAttribute(xmlNode, "posX", xmlValue, sizeof(xmlValue));
                removedObjectPos[removedObjects][0] = floatstr(xmlValue);
                
                XML_GetAttribute(xmlNode, "posY", xmlValue, sizeof(xmlValue));
                removedObjectPos[removedObjects][1] = floatstr(xmlValue);
                
                XML_GetAttribute(xmlNode, "posZ", xmlValue, sizeof(xmlValue));
                removedObjectPos[removedObjects][2] = floatstr(xmlValue);
                
                XML_GetAttribute(xmlNode, "radius", xmlValue, sizeof(xmlValue));
                removedObjectRadius[removedObjects] = strval(xmlValue);
                
                CA_RemoveBuilding(
                    removedObjectModel[removedObjects],
                    removedObjectPos[removedObjects][0],
                    removedObjectPos[removedObjects][1],
                    removedObjectPos[removedObjects][2],
                    removedObjectRadius[removedObjects]
                );
                removedObjects++;
            }
            
            // Get next sibling node
            xmlNode = XML_GetNextSibling(xmlNode);
        }
        
        XML_UnloadDocument(xmlDoc);
        printf("    |-> Objects Parsed: %d/%d", iObjects, MAX_CA_OBJECTS);
        printf("    |-> Vehicles Parsed: %d/%d", iVehicles, MAX_VEHICLES);
        printf("    |-> Objects Removed: %d/%d", removedObjects, MAX_REMOVED_OBJECTS);
        printf("|-> Map files Parsed in %d ms", GetTickCount() - fileStartTime);
    }
    dir_close(dDir);

    print("-------------------------------------\n");

    // Initialize ColAndreas
    print("-------------Col Andreas-------------\n");
    timeMs = GetTickCount();
    CA_Init();
    printf("|-> Col Andreas Initialized in %d ms", GetTickCount() - timeMs);
    print("-------------------------------------\n");
    return 1;
}

/*
* Use loaded map data for removing buildings.
*/
RemoveBuildings(playerid)
{
    for(new o = 0; o < removedObjects; o++)
	{
        /*
        * Remove the LOD model if the removed object has one
        */
        if(removedObjectLodModel[o] > 0)
        {
            RemoveBuildingForPlayer(playerid, removedObjectLodModel[o], removedObjectPos[o][0], removedObjectPos[o][1], removedObjectPos[o][2], removedObjectRadius[o]);
        }

        /*
        * Remove the models
        */
        RemoveBuildingForPlayer(playerid, removedObjectModel[o], removedObjectPos[o][0], removedObjectPos[o][1], removedObjectPos[o][2], removedObjectRadius[o]);
    }
    return 1;
}

#endif // MODULE_MAP_INCLUDED
