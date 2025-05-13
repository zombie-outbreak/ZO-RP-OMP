/*
* Zombie Outbreak Roleplay
* (C) 2025 Zombie Outbreak Development Contributors
* GNU General Public License v3.0
*/

// All the below code is for testing purposes
// It will be tidied before being merged into the main branch
// Currently using server builds generated from https://github.com/openmultiplayer/open.mp/pull/916
// The above builds add the NPC component to the open.mp server

#define MOVE_TYPE_AUTO       (-1)
#define MOVE_TYPE_WALK       (0)
#define MOVE_TYPE_RUN        (1)
#define MOVE_TYPE_SPRINT     (2)
#define MOVE_TYPE_DRIVE      (3)

new Float:tmpNpcSpawn[MAX_NPCS][4] =
{
    {778.5193,1859.9006,4.8145,270.0591},
    {779.4307,1864.6426,4.8436,265.6929},
    {779.4075,1869.4309,4.8909,271.6670},
    {779.5596,1873.6708,4.9210,276.7220},
    {780.0729,1878.2432,4.9500,273.2753},
    {779.7413,1882.6240,4.9778,270.0582},
    {779.1008,1886.8875,5.0049,270.7473}
};

CreateServerNpcs()
{
    new tmpNpcId;
    new tmpNpcName[MAX_PLAYER_NAME];
    new randSkin;

    for(new i = 0; i < MAX_NPCS; i++)
	{
        format(tmpNpcName, sizeof(tmpNpcName), "Zombie_%d", i);
        tmpNpcId = NPC_Create(tmpNpcName);
        serverNpc[tmpNpcId][npcId] = tmpNpcId;
        randSkin = RandomRange(20001, 20240);
        
        // now setup and spawn the NPC
        NPC_Spawn(serverNpc[tmpNpcId][npcId]);
        NPC_SetSkin(serverNpc[tmpNpcId][npcId], randSkin);
        NPC_SetPos(serverNpc[tmpNpcId][npcId], tmpNpcSpawn[i][0], tmpNpcSpawn[i][1], tmpNpcSpawn[i][2]);
        NPC_SetFacingAngle(serverNpc[tmpNpcId][npcId], tmpNpcSpawn[i][3]);
        SetTimerEx("MoveZombie", 100, true, "i", serverNpc[tmpNpcId][npcId]);
    }
    return 1;
}

forward MoveZombie(zombieid);
public MoveZombie(zombieid)
{
    if(!NPC_IsValid(zombieid))
        return 1;

    new Float:plrX, Float:plrY, Float:plrZ;
    new Float:npcX, Float:npcY, Float:npcZ;
    new Float:rx, Float:ry, Float:rz;
    new Float:rxx, Float:ryy, Float:rzz;

    foreach(new playerid : Player)
	{
        GetPlayerPos(playerid, plrX, plrY, plrZ);
        NPC_GetPos(zombieid, npcX, npcY, npcZ);
        
        if(player[playerid][isSpawned])
        {
            if(IsPlayerInRangeOfPoint(zombieid, 2.0, plrX, plrY, plrZ) && CA_RayCastReflectionVector(npcX, npcY, npcZ, plrX, plrY, plrZ, rx, ry, rz, rxx, ryy, rzz) == 0) // melee attack range
            {
                
            }
            else if(IsPlayerInRangeOfPoint(zombieid, 10.0, plrX, plrY, plrZ) && CA_RayCastReflectionVector(npcX, npcY, npcZ, plrX, plrY, plrZ, rx, ry, rz, rxx, ryy, rzz) == 0) // within range to start chase
            {
                NPC_Move(zombieid, plrX, plrY, plrZ, MOVE_TYPE_SPRINT);
            }
            else // lost sight of the player or too far away
            {
                // set some sort of variable to make the zombie immune while it makes its way back to its original spawn point
                // like how MMOs such as FF14 do it
                // or make them more randomized
                // basically it needs to avoid a player being able to group all the zombies together
                NPC_Move(zombieid, tmpNpcSpawn[zombieid][0], tmpNpcSpawn[zombieid][1], tmpNpcSpawn[zombieid][2], MOVE_TYPE_SPRINT);
            }
        }
    }
    return 1;
}