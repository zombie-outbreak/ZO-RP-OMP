// ============================================================================
// ZOMBIE OUTBREAK ROLEPLAY - MESSAGING SYSTEM
// ============================================================================
/*
* MODULE: Messaging
* PURPOSE: Chat and messaging system with PawnPlus integration
* 
* DEPENDENCIES:
* - core/config.pwn
* - core/constants.pwn
* - core/player_data.pwn
* - PawnPlus library
* 
* PUBLIC FUNCTIONS:
* - SendPlayerServerMessage() - Send formatted server message to player
* - SendAdminMessage() - Broadcast message to all online admins
* - SendProxMessage() - Send proximity message to nearby players
* - KickWithMessage() - Kick player with delayed message
* - BanWithMessage() - Ban player with delayed message
* 
* DESCRIPTION:
* Manages all chat and messaging functionality including:
* - Server messages with type formatting (INFO, ERROR, DENIED, SUCCESS)
* - Admin broadcast messages
* - Proximity chat with multiple types (ME, DO, CHAT, SHOUT, etc.)
* - PawnPlus String handling for efficient memory management
* - Delayed kick/ban messages
*/

// ============================================================================
// CONFIGURATION
// ============================================================================
#if !defined MODULE_MESSAGING_INCLUDED
#define MODULE_MESSAGING_INCLUDED

// ============================================================================
// PAWNPLUS NATIVE BINDINGS
// ============================================================================

native PlayerServerMessage(playerid, color, AmxString:message) = SendClientMessage;
native AdminMessage(playerid, color, AmxString:message) = SendClientMessage;
native ProxMessage(playerid, color, AmxString:message) = SendClientMessage;

// ============================================================================
// SERVER MESSAGES
// ============================================================================

SendPlayerServerMessage(playerid, color, msgType, const text[])
{
	new String:chatMsg;
	new String:inputText = str_new(text);

	switch(msgType)
	{
		case PLR_SERVER_MSG_TYPE_INFO:
		{
			chatMsg = str_new_static(COL_YELLOW"[INFO]: "COL_SYSTEM) + inputText;
			PlayerServerMessage(playerid, color, chatMsg);
		}
		case PLR_SERVER_MSG_TYPE_ERROR:
		{
			chatMsg = str_new_static(COL_RED"[ERROR]: "COL_SYSTEM) + inputText;
			PlayerServerMessage(playerid, color, chatMsg);
		}
		case PLR_SERVER_MSG_TYPE_DENIED:
		{
			chatMsg = str_new_static(COL_RED"[DENIED]: "COL_SYSTEM) + inputText;
			PlayerServerMessage(playerid, color, chatMsg);
		}
        case PLR_SERVER_MSG_TYPE_SUCCESS:
		{
			chatMsg = str_new_static(COL_GREEN"[SUCCESS]: "COL_SYSTEM) + inputText;
			PlayerServerMessage(playerid, color, chatMsg);
		}
	}
    str_delete(chatMsg);
    str_delete(inputText);
	return 1;
}

// ============================================================================
// ADMIN MESSAGES
// ============================================================================

SendAdminMessage(playerid, color, const text[])
{
	new String:chatMsg;
	new String:plrName = str_new(player[playerid][chosenChar]);
	new String:inputText = str_new(text);

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i))
			return 1;
			
		if(player[i][admin] > 0)
		{
			chatMsg = str_new_static("ADMIN: ") + plrName + str_new_static(" ") + inputText;
			AdminMessage(i, color, chatMsg);
		}
	}
    str_delete(inputText);
    str_delete(plrName);
    str_delete(chatMsg);
	return 1;
}

// ============================================================================
// PROXIMITY MESSAGES
// ============================================================================

SendProxMessage(playerid, color, Float:radi, msgType, const text[])
{
    new Float:x, Float:y, Float:z;
	new String:chatMsg;
	new String:plrName = str_new(player[playerid][chosenChar]);
	new String:inputText = str_new(text);
    GetPlayerPos(playerid, x, y, z);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerInRangeOfPoint(i, radi, x, y, z))
        {
			switch(msgType)
			{
				case PROXY_MSG_TYPE_ME: 
				{
					chatMsg = str_new_static("* ") + plrName + str_new_static(" ") + inputText;
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_INVENTORY_EQUIP: 
				{
					chatMsg = str_new_static("* ") + plrName + str_new_static(" equips their ") + inputText;
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_INVENTORY_UNEQUIP: 
				{
					chatMsg = str_new_static("* ") + plrName + str_new_static(" unequips their ") + inputText;
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_DO: 
				{
					chatMsg = str_new_static("* ") + plrName + str_new_static(" (( ") + inputText + str_new_static(" ))");
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_OOCCHAT: 
				{
					chatMsg = str_new_static("((") + plrName + str_new_static(" says: ") + inputText + str_new_static("))");
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_SHOUT: 
				{
					chatMsg = str_new_static("((") + plrName + str_new_static(" shouts: ") + inputText + str_new_static("))");
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_CHAT: 
				{
					chatMsg = plrName + str_new_static(" says: ") + inputText;
					ProxMessage(i, color, chatMsg);
				}
				case PROXY_MSG_TYPE_OTHER: 
				{
					chatMsg = str_new_static("* ") + plrName + str_new_static(" ") + inputText;
					ProxMessage(i, color, chatMsg);
				}
			}
        }
    }
    str_delete(inputText);
    str_delete(plrName);
    str_delete(chatMsg);
	return 1;
}

// ============================================================================
// PUNISHMENT MESSAGES
// ============================================================================

KickWithMessage(playerid, color, const message[], {Float, _}:...)
{
    SendClientMessage(playerid, color, message);
    SetTimerEx("TimedKick", 500, false, "d", playerid); // Delay of 500 miliseconds before kicking the player so he recieves the message
    return 1;
}

BanWithMessage(playerid, color, const message[], {Float, _}:...)
{
    SendClientMessage(playerid, color, message);
    SetTimerEx("TimedBan", 500, false, "d", playerid); 	// Delay of 500 miliseconds before banning the player so he recieves the message
    return 1;
}

#endif // MODULE_MESSAGING_INCLUDED
