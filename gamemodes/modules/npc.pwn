/*
* Zombie Outbreak Roleplay
* (C) 2025 Zombie Outbreak Development Contributors
* GNU General Public License v3.0
*/
CreateServerNpcs()
{
    new tmpNpcId;
    new randSkin = RandomRange(20001, 20240);

    tmpNpcId = NPC_Create("Zombie_Test");
    serverNpc[tmpNpcId][npcId] = tmpNpcId;
    
    // now setup and spawn the NPC
    NPC_Spawn(serverNpc[tmpNpcId][npcId]);
    NPC_SetSkin(serverNpc[tmpNpcId][npcId], randSkin);
    NPC_SetPos(serverNpc[tmpNpcId][npcId], 2452.8445, 1281.6398, 10.8210);
    return 1;
}