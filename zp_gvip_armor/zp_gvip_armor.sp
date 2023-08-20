





#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#include <autoexecconfig>
#include <sdktools_functions>

#pragma newdecls required

#pragma semicolon 1

#define DEBUG

char g_ChatPrefix[256];
ConVar gConVar_Chat_Prefix;

//START ROUND

ConVar gConVar_Health;
ConVar gConVar_Armor;
ConVar gConVar_Helmet;



public Plugin myinfo = 
{
	name = "Armor gVIP", 
	author = "AltF4", 
	description = "Armor for gVIP", 
	version = "1.0", 
	url = "https://steamcommunity.com/profiles/76561198882158727/"
};

//PLUGIN
//PLUGIN
//PLUGIN

public void OnPluginStart()
{
	//LoadTranslations
	LoadTranslations("benefitsvip.phrases");
	
	AutoExecConfig_SetFile("plugin.benefitsvip");
	
	//CHAT PREFIX
	gConVar_Chat_Prefix = AutoExecConfig_CreateConVar("sm_benefitsvip_chat_prefix", "[{green}TAG{default}]", "Chat Prefix");
	
	//HEALTH ARMOR HELMET
	gConVar_Health = AutoExecConfig_CreateConVar("sm_benefitsvip_health", "200", "Amount of Health when Start Round for VIPS ( Default CSGO = 100 )", 0, true, 1.0, true, 1000.0);
	gConVar_Armor = AutoExecConfig_CreateConVar("sm_benefitsvip_Armor", "100", "Amount of Armor when Start Round for VIPS ( Default CSGO = 100 | Without Armor = 0 )", 0, true, 0.0, true, 1000.0);
	gConVar_Helmet = AutoExecConfig_CreateConVar("sm_benefitsvip_helmet", "1", "VIPS have Helmet when Start Round? ( 1 = With Helmet | 0 = Without Helmet )", 0, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	gConVar_Chat_Prefix.AddChangeHook(OnPrefixChange);
	
	//MONEY HP

	
	
	//START ROUND
	HookEvent("player_spawn", OnPlayerSpawn);
}

//Prefix

public void SavePrefix()
{
	GetConVarString(gConVar_Chat_Prefix, g_ChatPrefix, sizeof(g_ChatPrefix));
}

public void OnConfigsExecuted()
{
	SavePrefix();
}

public void OnPrefixChange(ConVar cvar, char[] oldvalue, char[] newvalue)
{
	SavePrefix();
}

//START ROUND

public Action OnPlayerSpawn(Event event, const char[] sName, bool bDontBroadCast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (CheckCommandAccess(client, "sm_benefitsvip_override_vip", ADMFLAG_CUSTOM1))
	{
		//Free Health/Armor/Helmet
		


		
		//HEALTH
		SetEntProp(client, Prop_Send, "m_iHealth", gConVar_Health.IntValue);
		
		//Armor
		SetEntProp(client, Prop_Send, "m_ArmorValue", gConVar_Armor.IntValue);
		
		//Helmet
		SetEntProp(client, Prop_Send, "m_bHasHelmet", gConVar_Helmet.IntValue);
		
		
	}
}

