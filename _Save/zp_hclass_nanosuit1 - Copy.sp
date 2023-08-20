

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
	name            = "[ZP] Human Class: Nanosuit1",
	author          = "AltF4",
	description     = "Addon of zombie classses",
	version         = "2.0",
	url             = "https://steamcommunity.com/profiles/76561198882158727/"
}


/**
 * @section Information about the class.
 **/
#define ZOMBIE_CLASS_SKILL_MODE         /// Uncomment to make invisible static.
#define ZOMBIE_CLASS_SKILL_RATIO        0.5 // alpha amount = speed * ratio

// Sound index
int gSound;

// Zombie index
int gZombie;

// Skill states
enum
{
	STATE_NORMAL,
	STATE_INVISIBLE
};

// Cvars
ConVar hCvarSkillAlpha;
ConVar hCvarSkillDynamic;
ConVar hCvarSkillRatio;

/**
 * @brief Called when the plugin is fully initialized and all known external references are resolved. 
 *        This is only called once in the lifetime of the plugin, and is paired with OnPluginEnd().
 **/
//public void OnPluginStart()
//{
//	hCvarSkillAlpha   = CreateConVar("zp_zclass_nanosuit1_alpha", "0", "Initial alpha value", 0, true, 0.0, true, 255.0);
//	hCvarSkillDynamic = CreateConVar("zp_zclass_nanosuit1_dynamic", "0", "Dynamic invisibility", 0, true, 0.0, true, 1.0);
//	hCvarSkillRatio   = CreateConVar("zp_zclass_nanosuit1_ratio", "0.1", "Alpha amount = speed * ratio", 0, true, 0.0, true, 1.0);
//	
//	AutoExecConfig(true, "zp_zclass_nanosuit1", "sourcemod/zombieplague");
//}

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
	
	gSound = ZP_GetSoundKeyID("GHOST_SKILL_SOUNDS");
	if (gSound == -1) SetFailState("[ZP] Custom sound key ID from name : \"GHOST_SKILL_SOUNDS\" wasn't find");
}

/**
 * @brief Called when a client became a zombie/human.
 * 
 * @param client            The client index.
 * @param attacker          The attacker index.
 **/
public void ZP_OnClientUpdated(int client, int attacker)
{
	UTIL_SetRenderColor(client, Color_Alpha, 255);
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
		UTIL_SetRenderColor(client, Color_Alpha, 200);
		AcceptEntityInput(client, "DisableShadow");

		ZP_EmitSoundToAll(gSound, 1, client, SNDCHAN_VOICE);
		


		int view = ZP_GetClientViewModel(client, true);
		
		if (view != -1)
		{
			SetEntProp(view, Prop_Send, "m_nBody", STATE_INVISIBLE);
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
		UTIL_SetRenderColor(client, Color_Alpha, 250);
		//AcceptEntityInput(client, "EnableDraw"); 
		AcceptEntityInput(client, "EnableShadow");

		ZP_EmitSoundToAll(gSound, 2, client, SNDCHAN_VOICE);
		
		int view = ZP_GetClientViewModel(client, true);
		
		if (view != -1)
		{
			SetEntProp(view, Prop_Send, "m_nBody", STATE_NORMAL);
		}
	}
}

/**
 * @brief Called on deploy of a weapon.
 *
 * @param client            The client index.
 * @param weapon            The weapon index.
 * @param weaponID          The weapon id.
 **/
public void ZP_OnWeaponDeploy(int client, int weapon, int weaponID) 
{
	if (ZP_GetClientClass(client) == gZombie && ZP_GetClientSkillUsage(client))
	{
		int view = ZP_GetClientViewModel(client, true);
		
		if (view != -1)
		{
			SetEntProp(view, Prop_Send, "m_nBody", STATE_INVISIBLE);
		}
	}
}

