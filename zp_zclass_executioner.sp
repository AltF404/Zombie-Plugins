#include <zombieplague>
/**
 * @brief Record plugin info.
 **/
public Plugin myinfo =
{
	name            = "Executioner knife",
	author          = "AltF4",
	description     = "Addon of custom weapon",
	version         = "1.0",
	url             = "https:/steamcommunity.com/profiles/76561198882158727"
}



#define SPEED 1.1

public Action OnPlayerRunCmd(int client, int &buttons)
{
    if (IsPlayerAlive(client) && ZP_GetClientLevel(client) <=44 && (buttons & IN_ATTACK || buttons & IN_ATTACK2))
    {
        char[] sWeapon = new char[32];
        GetClientWeapon(client, sWeapon, 32);
        
        if (StrEqual(sWeapon, "weapon_knife"))
        {
			// Initialize round type
			int mode = ZP_GetCurrentGameMode();			
		
			if ( mode == ZP_GetGameModeNameID("survivor mode"))
			{
				return;
			}
			if ( mode == ZP_GetGameModeNameID("sniper mode"))
			{
				return;
			}
			if ( mode == ZP_GetGameModeNameID("berserker mode"))
			{
				return;
			}
			if ( mode == ZP_GetGameModeNameID("wesker mode"))
			{
				return;
			}
			if ( mode == ZP_GetGameModeNameID("spy mode"))
			{
				return;
			}
			if ( mode == ZP_GetGameModeNameID("plasma mode"))
			{
				return;
			}
			if ( mode == ZP_GetGameModeNameID("santa mode"))
			{
				return;
			}

            int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
            SetEntPropFloat(iWeapon, Prop_Send, "m_flNextPrimaryAttack", GetEntPropFloat(iWeapon, Prop_Send, "m_flNextPrimaryAttack") - ((SPEED - 1) / 5));
            SetEntPropFloat(iWeapon, Prop_Send, "m_flNextSecondaryAttack", GetEntPropFloat(iWeapon, Prop_Send, "m_flNextSecondaryAttack") - ((SPEED - 1) / 5));
        }
    }
} 