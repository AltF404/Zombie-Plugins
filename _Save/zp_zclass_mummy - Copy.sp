

#include <sourcemod>
#include <sdktools>
#include <zombieplague>

#pragma newdecls required
#pragma semicolon 1

/**
 * @brief Record plugin info.
 **/
public Plugin myinfo =
{
	name            = "[ZP] Zombie Class: Mummy",
	author          = "AltF4",
	description     = "Addon of zombie classses",
	version         = "3.0",
	url             = "https://steamcommunity.com/profiles/76561198882158727/"
}

// Sound index
int gSound;// ConVar hSoundLevel;
#pragma unused gSound //hSoundLevel
 
// Zombie index
int gZombie; 
#pragma unused gZombie

/**
 * @brief Called after a library is added that the current plugin references optionally. 
 *        A library is either a plugin name or extension name, as exposed via its include file.
 **/
public void OnLibraryAdded(const char[] sLibrary)
{
	// Validate library
	if (!strcmp(sLibrary, "zombieplague", false))
	{
		// If map loaded, then run custom forward
		if (ZP_IsMapLoaded())
		{
			// Execute it
			ZP_OnEngineExecute();
		}
	}
}

/**
 * @brief Called after a zombie core is loaded.
 **/
public void ZP_OnEngineExecute(/*void*/)
{
	// Classes
	gZombie = ZP_GetClassNameID("mummy");
	//if (gZombie == -1) SetFailState("[ZP] Custom zombie class ID from name : \"mummy\" wasn't find");
	
	// Sounds
	gSound = ZP_GetSoundKeyID("TANK_SKILL_SOUNDS");
	if (gSound == -1) SetFailState("[ZP] Custom sound key ID from name : \"TANK_SKILL_SOUNDS\" wasn't find");
	
	// Cvars
	//hSoundLevel = FindConVar("zp_seffects_level");
	//if (hSoundLevel == null) SetFailState("[ZP] Custom cvar key ID from name : \"zp_seffects_level\" wasn't find");
}




/**
 * @brief Called before a client take a fake damage.
 * 
 * @param client            The client index.
 * @param attacker          The attacker index. (Not validated!)
 * @param inflicter         The inflicter index. (Not validated!)
 * @param flDamage          The amount of damage inflicted.
 * @param iBits             The ditfield of damage types.
 * @param weapon            The weapon index or -1 for unspecified.
 *
 * @note To block damage reset the damage to zero. 
 **/

public void ZP_OnClientValidateDamage(int client, int &attacker, int &inflictor, float &flDamage, int &iBits, int &weapon)
{
	// Validate attacker
	if (!IsPlayerExist(attacker))
	{
		return;
	}
	

	// Validate the zombie class index
	if (ZP_GetClientClass(client) == gZombie)
	{
		// Generate the chance
		flDamage *= 0.7;
	}
}
