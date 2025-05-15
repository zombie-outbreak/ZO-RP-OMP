/*
* Zombie Outbreak Roleplay
* (C) 2025 Zombie Outbreak Development Contributors
* GNU General Public License v3.0
*/

/*
* MTA Map Parser
* Original code: sneakyevil
* Forked and updated by burridgedan
*/
ParseMapString(const cBuffer[], const cName[])
{
    format(cTempBuffer, sizeof(cTempBuffer), "%s", cBuffer);
    new iResult = strfind(cTempBuffer, cName) + strlen(cName);
    strmid(cTempBuffer, cTempBuffer, iResult, strlen(cTempBuffer), strlen(cTempBuffer));
    iResult = strfind(cTempBuffer, "\"");
    strmid(cTempBuffer, cTempBuffer, 0, iResult, strlen(cTempBuffer));
    return cTempBuffer;
}

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
    //new iNpcs = 0;
    new cMapBuffer[1024];
    new cVehicleColor[48];
    /*new iNpcIDStart = 0;
    new iNpcIDEnd = MAX_NPCS - 1;
    new tempNpcIdNum = 999;*/

    // although this data is not loaded from the map, it looks tidier in the logs on startup to show all the stats here
    printf("|-> Vehicle Respawn Delay: %d", VEHICLE_RESPAWN_TIME);
    printf("|-> Interiors Loaded: %d/%d", serverInteriorCount, MAX_SERVER_INTERIORS);
    printf("|-> Scav Areas Loaded: %d/%d", scavAreaCount, MAX_SCAV_AREAS);

    format(mapDirectory, sizeof(mapDirectory), "%s", MAP_DIRECTORY);
    new dir:dDir = dir_open(mapDirectory);

    while(dir_list(dDir, dItem, dType))
    {
        if (dType != FM_FILE) continue;
        if (0 > strfind(dItem, ".map")) continue;

        format(cMapName, sizeof(cMapName), "/maps/%s", dItem);
        printf("|-> Parsing: %s", cMapName);

        new File:fMap = fopen(cMapName, io_read);
        if(fMap)
        {
            while(fread(fMap, cMapBuffer))
            {
                if (strfind(cMapBuffer, "<object") >= 0)
                {
                    new iObjectModel = strval(ParseMapString(cMapBuffer, "model=\""));
                    new Float:fObjectPosX = floatstr(ParseMapString(cMapBuffer, "posX=\""));
                    new Float:fObjectPosY = floatstr(ParseMapString(cMapBuffer, "posY=\""));
                    new Float:fObjectPosZ = floatstr(ParseMapString(cMapBuffer, "posZ=\""));
                    new Float:fObjectRotX = floatstr(ParseMapString(cMapBuffer, "rotX=\""));
                    new Float:fObjectRotY = floatstr(ParseMapString(cMapBuffer, "rotY=\""));
                    new Float:fObjectRotZ = floatstr(ParseMapString(cMapBuffer, "rotZ=\""));
                    CA_CreateDynamicObject_DC(iObjectModel, fObjectPosX, fObjectPosY, fObjectPosZ, fObjectRotX, fObjectRotY, fObjectRotZ);
                    iObjects++;
                }
                else if (strfind(cMapBuffer, "<vehicle") >= 0)
                {
                    new iVehicleModel = strval(ParseMapString(cMapBuffer, "model=\""));
                    new Float:fVehiclePosX = floatstr(ParseMapString(cMapBuffer, "posX=\""));
                    new Float:fVehiclePosY = floatstr(ParseMapString(cMapBuffer, "posY=\""));
                    new Float:fVehiclePosZ = floatstr(ParseMapString(cMapBuffer, "posZ=\""));
                    new Float:fVehicleRotation = floatstr(ParseMapString(cMapBuffer, "rotZ=\""));
                    format(cVehicleColor, sizeof(cVehicleColor), "%s", ParseMapString(cMapBuffer, "color=\""));
                    new cVehicleRGBColor[2][3];
                    for(new c1 = 0; 2 > c1; c1++)
                    {
                        for(new c2 = 0; 3 > c2; c2++)
                        {
                            new cVehicleColorTemp[4];
                            new iComma = strfind(cVehicleColor, ",");
                            strmid(cVehicleColorTemp, cVehicleColor, 0, iComma);
                            strdel(cVehicleColor, 0, iComma + 1);
                            cVehicleRGBColor[c1][c2] = strval(cVehicleColorTemp);
                        }
                    }
                    new iVehicleID = CreateVehicle(iVehicleModel, fVehiclePosX, fVehiclePosY, fVehiclePosZ, fVehicleRotation, FindClosetVehicleColor(cVehicleRGBColor[0][0], cVehicleRGBColor[0][1], cVehicleRGBColor[0][2]), FindClosetVehicleColor(cVehicleRGBColor[1][0], cVehicleRGBColor[1][1], cVehicleRGBColor[1][2]), VEHICLE_RESPAWN_TIME);
                
                    /*
                    * Set some vehicle stats etc. when spawned
                    */
                    SetupVehicleForSpawn(iVehicleID);
                    iVehicles++;
                }
                else if (strfind(cMapBuffer, "<removeWorldObject") >= 0)
                {
                    removedObjectRadius[removedObjects] = strval(ParseMapString(cMapBuffer, "radius=\""));
                    removedObjectModel[removedObjects] = strval(ParseMapString(cMapBuffer, "model=\""));
                    removedObjectLodModel[removedObjects] = strval(ParseMapString(cMapBuffer, "lodModel=\""));
                    removedObjectPos[removedObjects][0] = floatstr(ParseMapString(cMapBuffer, "posX=\""));
                    removedObjectPos[removedObjects][1] = floatstr(ParseMapString(cMapBuffer, "posY=\""));
                    removedObjectPos[removedObjects][2] = floatstr(ParseMapString(cMapBuffer, "posZ=\""));
                    CA_RemoveBuilding(removedObjectModel[removedObjects], removedObjectPos[removedObjects][0], removedObjectPos[removedObjects][1], removedObjectPos[removedObjects][2], removedObjectRadius[removedObjects]);
                    removedObjects ++;
                }
                /*else if (strfind(cMapBuffer, "<ped") >= 0)
                {
                    //Create the NPC
                    new tempName[MAX_PLAYER_NAME];
                    format(tempName, MAX_PLAYER_NAME, "NPC_%d", tempNpcIdNum);
                    tempNpcIdNum = tempNpcIdNum - 1;
                    new tempNpcId = FCNPC_Create(tempName);

                    if(tempNpcId == INVALID_PLAYER_ID) 
                    {
                        printf("Warning: Failed to create NPC ID %d (%s)", iNpcs, tempName);
                        continue;
                    }

                    // Set its variables from map file
                    npcVariable[tempNpcId][npcId] = tempNpcId;
                    format(npcVariable[tempNpcId][npcName], MAX_PLAYER_NAME, "%s", tempName);
                    npcVariable[tempNpcId][npcSkin] = strval(ParseMapString(cMapBuffer, "model=\""));
                    npcVariable[tempNpcId][npcX] = floatstr(ParseMapString(cMapBuffer, "posX=\""));
                    npcVariable[tempNpcId][npcY] = floatstr(ParseMapString(cMapBuffer, "posY=\""));
                    npcVariable[tempNpcId][npcZ] = floatstr(ParseMapString(cMapBuffer, "posZ=\""));
                    npcVariable[tempNpcId][npcA] = floatstr(ParseMapString(cMapBuffer, "rotZ=\""));
                    npcVariable[tempNpcId][npcInterior] = strval(ParseMapString(cMapBuffer, "interior=\""));

                    // Spawn the NPC
                    FCNPC_Spawn(npcVariable[tempNpcId][npcId], npcVariable[tempNpcId][npcSkin], npcVariable[tempNpcId][npcX], npcVariable[tempNpcId][npcY], npcVariable[tempNpcId][npcZ]);
                    FCNPC_SetAngle(npcVariable[tempNpcId][npcId], npcVariable[tempNpcId][npcA]);
                    FCNPC_SetInvulnerable(tempNpcId, true);

                    // Read/write from/to database
                    OnNpcDataLoaded(tempNpcId);

                    // Increment and go again!
                    iNpcs++;
                }*/
            }
            fclose(fMap);
            printf("    |-> Objects Parsed: %d/%d", iObjects, MAX_CA_OBJECTS);
            printf("    |-> Vehicles Parsed: %d/%d", iVehicles, MAX_VEHICLES);
            printf("    |-> Objects Removed: %d/%d", removedObjects, MAX_REMOVED_OBJECTS); //doesn't include LOD Models as the MTA map file contains both IDs for one line of removeWorldObject
            //printf("    |-> NPCs Parsed: %d", iNpcs);
        }
        else print("    |-> Parsing Failed!");
    }
    dir_close(dDir);

    print("-------------------------------------\n");

    // Initialize ColAndreas
    CA_Init();
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
