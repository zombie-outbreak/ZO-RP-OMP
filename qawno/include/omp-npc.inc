native NPC_Create(const name[]);
native NPC_Destroy(npcid);
native NPC_IsValid(npcid);
native NPC_Spawn(npcid);
native NPC_SetPos(npcid, Float:x, Float:y, Float:z);
native NPC_GetPos(npcid, &Float:x, &Float:y, &Float:z);
native NPC_SetRot(npcid, Float:x, Float:y, Float:z);
native NPC_GetRot(npcid, &Float:x, &Float:y, &Float:z);
native NPC_SetFacingAngle(npcid, Float:angle);
native NPC_GetFacingAngle(npcid, &Float:angle);
native NPC_SetVirtualWorld(npcid, vw);
native NPC_GetVirtualWorld(npcid, &vw);
native NPC_Move(npcid, Float:x, Float:y, Float:z, moveType, Float:moveSpeed = -1.0);
native NPC_StopMove(npcid);
native bool:NPC_IsMoving(npcid);
native NPC_SetSkin(npcid, model);
native NPC_IsStreamedIn(npcid, playerid);
native NPC_IsAnyStreamedIn(npcid);
native NPC_GetAll(npcs[], size = sizeof(npcs));
native NPC_SetInterior(npcid, interiorid);
native NPC_GetInterior(npcid);
native NPC_SetHealth(npcid, Float:health);
native Float:NPC_GetHealth(npcid);
native NPC_SetArmour(npcid, Float:armour);
native Float:NPC_GetArmour(npcid);
native NPC_ApplyAnimation(npcid, const animLib[], const animName[], Float:delta, bool:loop, bool:lockX, bool:lockY, bool:freeze, time, sync);
native NPC_SetWeapon(npcid, weapon);
native NPC_GetWeapon(npcid);
native NPC_SetAmmo(npcid, ammo);
native NPC_GetAmmo(npcid);
native NPC_SetKeys(npcid, upAndDown, leftAndRight, keys);
native NPC_GetKeys(npcid, &upAnddown, &leftandRight, &keys);
native NPC_MeleeAttack(npcid, time, bool:secondaryAttack = false);
native NPC_StopMeleeAttack(npcid);
native bool:NPC_IsMeleeAttacking(npcid);
native NPC_SetFightingStyle(npcid, style);
native NPC_GetFightingStyle(npcid);
native NPC_EnableReloading(npcid, bool:enable);
native bool:NPC_IsReloadEnabled(npcid);
native bool:NPC_IsReloading(npcid);
native NPC_EnableInfiniteAmmo(npcid, bool:enable);
native bool:NPC_IsInfiniteAmmoEnabled(npcid);
native NPC_GetWeaponState(npcid);
native NPC_SetAmmoInClip(npcid, ammo);
native NPC_GetAmmoInClip(npcid);
native NPC_Shoot(npcid, weapon, hitId, hitType, Float:endPointX, Float:endPointY, Float:endPointZ, Float:offsetX, Float:offsetY, Float:offsetZ, bool:isHit, checkInBetweenFlags);
native bool:NPC_IsShooting(npcid);
native NPC_AimAt(npcid, Float:pointX, Float:pointY, Float:pointZ, bool:shoot, shootDelay, bool:updateAngle, Float:offsetFromX, Float:offsetFromY, Float:offsetFromZ, checkInBetweenFlags);
native NPC_AimAtPlayer(npcid, playerid, bool:shoot, shootDelay, bool:updateAngle, Float:offsetX, Float:offsetY, Float:offsetZ, Float:offsetFromX, Float:offsetFromY, Float:offsetFromZ, checkInBetweenFlags);
native NPC_StopAim(npcid);
native bool:NPC_IsAiming(npcid);
native bool:NPC_IsAimingAtPlayer(npcid, playerid);
native NPC_SetWeaponAccuracy(npcid, weaponid, Float:accuracy);
native Float:NPC_GetWeaponAccuracy(npcid, weaponid);

forward OnNPCFinishMove(npcid);
forward OnNPCCreate(npcid);
forward OnNPCDestroy(npcid);
forward OnNPCTakeDamage(npcid, damagerid, Float:damage, WEAPON:weapon, bodypart);
forward OnNPCGiveDamage(npcid, damagedid, Float:damage, WEAPON:weapon, bodypart);
forward OnNPCDeath(npcid, killerid, reason);
forward onNPCSpawn(npcid);
forward OnNPCWeaponStateChange(npcid, newState, oldState);

// FCNPC Definitions
/*#define FCNPC_ENTITY_CHECK_NONE           (0)
#define FCNPC_ENTITY_CHECK_PLAYER         (1)
#define FCNPC_ENTITY_CHECK_NPC            (2)
#define FCNPC_ENTITY_CHECK_ACTOR          (4)
#define FCNPC_ENTITY_CHECK_VEHICLE        (8)
#define FCNPC_ENTITY_CHECK_OBJECT         (16)
#define FCNPC_ENTITY_CHECK_POBJECT_ORIG   (32)
#define FCNPC_ENTITY_CHECK_POBJECT_TARG   (64)
#define FCNPC_ENTITY_CHECK_MAP            (128)
#define FCNPC_ENTITY_CHECK_ALL            (255)

#define FCNPC_ENTITY_MODE_AUTO			(-1)
#define FCNPC_ENTITY_MODE_NONE			(0)
#define FCNPC_ENTITY_MODE_COLANDREAS	(1)

#define FCNPC_MOVE_TYPE_AUTO       (-1)
#define FCNPC_MOVE_TYPE_WALK       (0)
#define FCNPC_MOVE_TYPE_RUN        (1)
#define FCNPC_MOVE_TYPE_SPRINT     (2)
#define FCNPC_MOVE_TYPE_DRIVE      (3)

#define FCNPC_MOVE_MODE_AUTO       (-1)
#define FCNPC_MOVE_MODE_NONE       (0)
#define FCNPC_MOVE_MODE_MAPANDREAS (1)
#define FCNPC_MOVE_MODE_COLANDREAS (2)

#define FCNPC_MOVE_PATHFINDING_AUTO    (-1)
#define FCNPC_MOVE_PATHFINDING_NONE    (0)
#define FCNPC_MOVE_PATHFINDING_Z       (1)
#define FCNPC_MOVE_PATHFINDING_RAYCAST (2)

#define FCNPC_MOVE_SPEED_AUTO      (-1.0)
#define FCNPC_MOVE_SPEED_WALK      (0.1552086)
#define FCNPC_MOVE_SPEED_RUN       (0.56444)
#define FCNPC_MOVE_SPEED_SPRINT    (0.926784)

#define FCNPC_MAX_NODES            (64)

#define FCNPC_INVALID_MOVEPATH_ID  (-1)
#define FCNPC_INVALID_RECORD_ID    (-1)*/

// FCNPC Natives
/*native FCNPC_Create(const name[]);
native FCNPC_Spawn(npcid, skinid, Float:x, Float:y, Float:z);
native bool:FCNPC_IsDead(npcid);
native bool:FCNPC_IsStreamedInForAnyone(npcid);
native FCNPC_GetPosition(npcid, &Float:x, &Float:y, &Float:z);
native FCNPC_SetPosition(npcid, Float:x, Float:y, Float:z);
native Float:FCNPC_GetHealth(npcid);
native FCNPC_SetHealth(npcid, Float:health);
native FCNPC_SetVirtualWorld(npcid, worldid);
native FCNPC_SetWeapon(npcid, weaponid);
native FCNPC_SetAmmo(npcid, ammo);
native FCNPC_GiveAmmo(npcid, ammo);
native FCNPC_SetWeaponAccuracy(npcid, weaponid, Float:accuracy);
native FCNPC_UseReloading(npcid, bool:use = true);
native FCNPC_UseInfiniteAmmo(npcid, bool:use = true);
native FCNPC_AimAtPlayer(npcid, playerid, bool:shoot = false, shoot_delay = -1, bool:set_angle = true, Float:offset_x = 0.0, Float:offset_y = 0.0, Float:offset_z = 0.0, Float:offset_from_x = 0.0, Float:offset_from_y = 0.0, Float:offset_from_z = 0.0, between_check_mode = FCNPC_ENTITY_MODE_AUTO, between_check_flags = FCNPC_ENTITY_CHECK_ALL);
native FCNPC_Stop(npcid);
native FCNPC_StopAim(npcid);
native FCNPC_GoTo(npcid, Float:x, Float:y, Float:z, type = FCNPC_MOVE_TYPE_AUTO, Float:speed = FCNPC_MOVE_SPEED_AUTO, mode = FCNPC_MOVE_MODE_AUTO, pathfinding = FCNPC_MOVE_PATHFINDING_AUTO, Float:radius = 0.0, bool:set_angle = true, Float:min_distance = 0.0, stop_delay = 250);
native FCNPC_TriggerWeaponShot(npcid, weaponid, hittype, hitid, Float:x, Float:y, Float:z, bool:is_hit = true, Float:offset_from_x = 0.0, Float:offset_from_y = 0.0, Float:offset_from_z = 0.0, between_check_mode = FCNPC_ENTITY_MODE_AUTO, between_check_flags = FCNPC_ENTITY_CHECK_ALL);
native FCNPC_SetAngleToPlayer(npcid, playerid);
native FCNPC_MeleeAttack(npcid, delay = -1, bool:fighting_style = false);
native FCNPC_ApplyAnimation(npcid, const animlib[], const animname[], Float:fDelta = 4.1, loop = 0, lockx = 1, locky = 1, freeze = 0, time = 1);
native FCNPC_SetSkin(npcid, skinid);*/