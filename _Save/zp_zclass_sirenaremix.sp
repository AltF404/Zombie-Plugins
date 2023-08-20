

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <zombieplague>

#pragma newdecls required
#pragma semicolon 1

/**
 * @brief Record plugin info.
 **/
public Plugin myinfo =
{
	name            = "[ZP] Zombie Class: Sirenaremix",
	author          = "AltF4",
	description     = "Addon of zombie classses",
	version         = "1.0",
	url             = "https://steamcommunity.com/profiles/76561198882158727/"
}

// Decal index
int gTrail;

// Timer index
Handle hZombieScream[MAXPLAYERS+1] = { null, ... }; 

// Sound index
int gSound;
 
// Zombie index
int gZombie;

// Cvars
ConVar hCvarSkillRadius;
ConVar hCvarSkillDamage;
ConVar hCvarSkillEffect;

/**
 * @brief Called when the plugin is fully initialized and all known external references are resolved. 
 *        This is only called once in the lifetime of the plugin, and is paired with OnPluginEnd().
 **/
public void OnPluginStart()
{ 
	hCvarSkillRadius = CreateConVar("zp_zclass_sirenaremix_radius", "140.0", "Wave radius", 0, true, 0.0);
	hCvarSkillDamage = CreateConVar("zp_zclass_sirenaremix_damage", "170.0", "Damage amount", 0, true, 0.0);
	hCvarSkillEffect = CreateConVar("zp_zclass_sirenaremix_effect", "hell_end", "Particle effect for the skill (''-off)");
	
	AutoExecConfig(true, "zp_zclass_sirenaremix", "sourcemod/zombieplague");
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
	gZombie = ZP_GetClassNameID("sirenaremix");
	
	gSound = ZP_GetSoundKeyID("PSYH_SKILL_SOUNDS");
	if (gSound == -1) SetFailState("[ZP] Custom sound key ID from name : \"PSYH_SKILL_SOUNDS\" wasn't find");
}

/**
 * @brief The map is starting.
 **/
public void OnMapStart()
{
	gTrail = PrecacheModel("materials/sprites/laserbeam.vmt", true);
}

/**
 * @brief The map is ending.
 **/
public void OnMapEnd()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		hZombieScream[i] = null; /// with flag TIMER_FLAG_NO_MAPCHANGE
	}
}

/**
 * @brief Called when a client is disconnecting from the server.
 *
 * @param client            The client index.
 **/
public void OnClientDisconnect(int client)
{
	delete hZombieScream[client];
}

/**
 * @brief Called when a client has been killed.
 * 
 * @param client            The client index.
 * @param attacker          The attacker index.
 **/
public void ZP_OnClientDeath(int client, int attacker)
{
	delete hZombieScream[client];
}

/**
 * @brief Called when a client became a zombie/human.
 * 
 * @param client            The client index.
 * @param attacker          The attacker index.
 **/
public void ZP_OnClientUpdated(int client, int attacker)
{
	delete hZombieScream[client];
}

/**
 * @brief Called when a client use a skill.
 * 
 * @param client            The client index.
 *
 * @return                  Plugin_Handled to block using skill. Anything else
 *                              (like Plugin_Continue) to allow use.
 **/
public Action ZP_OnClientSkillUsed(int client)
{
	if (ZP_GetClientClass(client) == gZombie)
	{
		delete hZombieScream[client];
		hZombieScream[client] = CreateTimer(0.1, ClientOnScreaming, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

		ZP_EmitSoundToAll(gSound, 1, client, SNDCHAN_VOICE, SNDLEVEL_NORMAL);
		
		static char sEffect[SMALL_LINE_LENGTH];
		hCvarSkillEffect.GetString(sEffect, sizeof(sEffect));
		
		if (hasLength(sEffect))
		{
			static float vPosition[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vPosition);
			UTIL_CreateParticle(client, vPosition, _, _, sEffect, ZP_GetClassSkillDuration(gZombie));
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
		delete hZombieScream[client];
	}
}

/**
 * @brief Timer for the screamming process.
 *
 * @param hTimer            The timer handle.
 * @param userID            The user id.
 **/
public Action ClientOnScreaming(Handle hTimer, int userID)
{
	int client = GetClientOfUserId(userID);
	
	if (client)
	{
		static float vPosition[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vPosition); vPosition[2] += 25.0;  

		float flRadius = hCvarSkillRadius.FloatValue;
		float flDamage = hCvarSkillDamage.FloatValue;

		int i; int it = 1; /// iterator
		while ((i = ZP_FindPlayerInSphere(it, vPosition, flRadius)) != -1)
		{
			if (ZP_IsPlayerZombie(i))
			{
				continue;
			}
			
			UTIL_CreateFadeScreen(i, 0.1, 0.2, FFADE_IN, {114, 22, 17, 75});  
			
			ZP_TakeDamage(i, client, client, flDamage, DMG_SONIC);
		}
	   
		TE_SetupBeamRingPoint(vPosition, 50.0, flRadius * 2.0, gTrail, 0, 1, 10, 1.0, 15.0, 0.0, {255, 0, 0, 200}, 50, 0);
		TE_SendToAll();
		
		return Plugin_Continue;
	}

	hZombieScream[client] = null;

	return Plugin_Stop;
}
