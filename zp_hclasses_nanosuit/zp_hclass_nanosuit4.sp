
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
	name            = "[ZP] Human Class: Nanosuit2",
	author          = "AltF4",
	description     = "Addon of zombie classses",
	version         = "1.0",
	url             = "https://steamcommunity.com/profiles/76561198882158727/"
}

// Decal index
int gTrail;

// Sound index
int gSound;
 
// Zombie index
int gZombie; 

// Cvars
ConVar hCvarSkillReduction;
ConVar hCvarSkillEffect;

/**
 * @brief Called when the plugin is fully initialized and all known external references are resolved. 
 *        This is only called once in the lifetime of the plugin, and is paired with OnPluginEnd().
 **/
public void OnPluginStart()
{
	hCvarSkillReduction = CreateConVar("zp_zclass_nanosuit_reduction", "0.6", "Damage reduction multiplier", 0, true, 0.0, true, 1.0);
//	hCvarSkillEffect    = CreateConVar("zp_zclass_nanosuit_effect", "cloud", "Particle effect for the skill (''-default)");

	AutoExecConfig(true, "zp_zclass_nanosuit", "sourcemod/zombieplague");
}

/**
 * @brief Called after a library is added that the current plugin references optionally. 
 *        A library is either a plugin name or extension name, as exposed via its include file.
 **/
public void OnLibraryAdded(const char[] sLibrary)
{
	if (!strcmp(sLibrary, "zombieplague", false))
	{
		if (ZP_IsMapLoaded())
		{
			ZP_OnEngineExecute();
		}
	}
}

/**
 * @brief Called after a zombie core is loaded.
 **/
public void ZP_OnEngineExecute()
{
	gZombie = ZP_GetClassNameID("nanosuit");
	
	gSound = ZP_GetSoundKeyID("TANK_SKILL_SOUNDS");
	if (gSound == -1) SetFailState("[ZP] Custom sound key ID from name : \"TANK_SKILL_SOUNDS\" wasn't find");
}

/**
 * @brief The map is starting.
 **/
public void OnMapStart()
{
	gTrail = PrecacheModel("materials/sprites/laserbeam.vmt", true);
}

/**
 * @brief Called when a client use a skill.
 * 
 * @param client             The client index.
 *
 * @return                   Plugin_Handled to block using skill. Anything else
 *                              (like Plugin_Continue) to allow use.
 **/
public Action ZP_OnClientSkillUsed(int client)
{
	if (ZP_GetClientClass(client) == gZombie)
	{
		ZP_EmitSoundToAll(gSound, 1, client, SNDCHAN_VOICE, SNDLEVEL_NORMAL);
		
		static char sEffect[SMALL_LINE_LENGTH];
		//hCvarSkillEffect.GetString(sEffect, sizeof(sEffect));
		
		if (hasLength(sEffect))
		{
			static float vPosition[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vPosition);
			UTIL_CreateParticle(client, vPosition, _, _, sEffect, ZP_GetClassSkillDuration(gZombie));
		}
		else
		{
			TE_SetupBeamFollow(client, gTrail, 0, ZP_GetClassSkillDuration(gZombie), 6.0, 6.0, 3, {255, 255, 0, 200});
			TE_SendToAll();	
		}
	}
	
	return Plugin_Continue;
}

/**
 * @brief Called when a skill duration is over.
 * 
 * @param client            The client index.
 **/
public void ZP_OnClientSkillOver(int client)
{
	if (ZP_GetClientClass(client) == gZombie)
	{
		ZP_EmitSoundToAll(gSound, 2, client, SNDCHAN_VOICE, SNDLEVEL_NORMAL);
	}
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
	if (ZP_GetClientClass(client) == gZombie && ZP_GetClientSkillUsage(client))
	{
		flDamage *= hCvarSkillReduction.FloatValue;
	}
}
