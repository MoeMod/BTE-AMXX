#include <amxmodx>
#include <amxmisc> 
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <xs>
#include "offset.inc"
#include "cdll_dll.h"
#include "util.h"
#include "BTE_GhostMode.inc"

// for BTE ver

#define PLUGIN "BTE Ghost Mode"
#define VERSION "1.0"
#define AUTHOR "NN"

#define ZBOT_SUPPORT

#if defined ZBOT_SUPPORT
new g_hamczbots;
new cvar_botquota;
#endif

//#define SOUND_BREATHE "player/breathe2.wav"
#define SOUND_BREATHE "zombi/human_breath_male.wav"
#define GHOST_SPEED 270.0

new gmsgStatusText;
new g_iAlpha[33], Float:g_flHideStart[33], Float:g_flAlphaModifier[33];
new Float:g_flNextBreathe[33];
new g_iTeam[33];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	RegisterHam(Ham_AddPlayerItem, "player", "AddPlayerItem");
	RegisterHam(Ham_Spawn, "player", "Player_Spawn");
	RegisterHam(Ham_Spawn, "player", "Player_Spawn_Post", 1);
	RegisterHam(Ham_Killed, "player", "Player_Killed_Post", 1);
	RegisterHam(Ham_Touch, "weaponbox", "WeaponBox_Touch");
	
	register_forward(FM_PlayerPostThink, "PlayerPostThink", 1);
	register_forward(FM_AddToFullPack, "AddToFullPack", 1);
	
	gmsgStatusText = get_user_msgid("StatusText");
	
	register_message(gmsgStatusText, "message_StatusText");
	
#if defined ZBOT_SUPPORT
	cvar_botquota = get_cvar_pointer("bot_quota");
#endif
}

public plugin_precache()
{
	precache_sound(SOUND_BREATHE);
}

public plugin_natives()
{
	register_native("ghost_get_alpha", "native_get_alpha", 1);
}

public native_get_alpha(id)
{
	return floatround(g_iAlpha[id] * g_flAlphaModifier[id]);
}

#if defined ZBOT_SUPPORT
public client_putinserver(id)
{
	if (!g_hamczbots && get_pcvar_num(cvar_botquota) > 0 && is_user_bot(id))
	{
		set_task(0.1, "RegisterHamBot", id);
	}
}

public RegisterHamBot(id)
{
	if (g_hamczbots || !is_user_connected(id))
		return;
	
	RegisterHamFromEntity(Ham_Spawn, id, "Player_Spawn");
	RegisterHamFromEntity(Ham_Spawn, id, "Player_Spawn_Post", 1);
	RegisterHamFromEntity(Ham_AddPlayerItem, id, "AddPlayerItem");
	RegisterHamFromEntity(Ham_Killed, id, "Player_Killed_Post", 1);
	g_hamczbots = 1
}
#endif

public AddToFullPack(es_handle, e, ent, host, hostflags, player, pSet)
{
	if (ent > 32 || !ent)
		return FMRES_IGNORED;
	
	if (g_iTeam[ent] == TEAM_TERRORIST && is_user_alive(ent))
	{
		set_es(es_handle, ES_RenderMode, kRenderTransAlpha);
		set_es(es_handle, ES_RenderAmt, floatround(g_iAlpha[ent] * g_flAlphaModifier[ent]));
		set_es(es_handle, ES_RenderFx, kRenderFxGlowShell);
	}
	
	return FMRES_IGNORED;
}

public Player_Killed_Post(id, iAttacker, shouldgib)
{
	if (g_iTeam[id] == TEAM_TERRORIST)
		emit_sound(id, CHAN_ITEM, SOUND_BREATHE, 1.0, ATTN_NORM, SND_STOP, PITCH_NORM);
}

public PlayerPostThink(id)
{
	if (pev(id, pev_deadflag) != DEAD_NO)
		return FMRES_IGNORED;
	
	if (g_iTeam[id] == TEAM_TERRORIST)
	{
		set_pev(id, pev_maxspeed, GHOST_SPEED);
		
		new iButton = pev(id, pev_button);
		if(iButton & (IN_BACK | IN_FORWARD | IN_RUN | IN_MOVELEFT | IN_MOVERIGHT | IN_LEFT | IN_RIGHT))
		{
			new Float:flVelocity2D = GetVelocity2D(id);
			flVelocity2D = flVelocity2D > 250.0 ? 250.0 : flVelocity2D;
		
			new Float:amount;
			if (flVelocity2D > 140.0)
				amount = (flVelocity2D - 140.0) / 250.0 * 70.0 + 15.2;
			else
				amount = flVelocity2D / 250.0 * 20.0 + 5.0;
			
			g_iAlpha[id] = floatround(amount);
			g_flAlphaModifier[id] = 1.0;
			g_flHideStart[id] = get_gametime();
		}
		else
		{
			g_flAlphaModifier[id] = 1.0 - (get_gametime() - g_flHideStart[id]) / 0.35;
			g_flAlphaModifier[id] = g_flAlphaModifier[id] < 0.0 ? 0.0 : g_flAlphaModifier[id];
			
			if (g_flNextBreathe[id] <= get_gametime())
			{
				emit_sound(id, CHAN_ITEM, SOUND_BREATHE, 1.0, ATTN_NORM, 0, PITCH_NORM);
				g_flNextBreathe[id] = get_gametime() + random_float(3.0, 5.0);
			}
		}
	}
	
	return FMRES_IGNORED;
}

public Player_Spawn(id)
{
	new iTeam = get_pdata_int(id, m_iTeam);
	g_iTeam[id] = iTeam;
}

public Player_Spawn_Post(id)
{
	if (g_iTeam[id] == TEAM_TERRORIST)
	{
		StripSlot(id, 1);
		StripSlot(id, 2);
		StripSlot(id, 4);
		
		g_flNextBreathe[id] = get_gametime() + random_float(0.0, 2.0);
		/*set_pev(id, pev_health, 120.0);
		set_pev(id, pev_max_health, 120.0);*/
		set_pev(id, pev_gravity, 0.8);
	}
	else
	{
		set_pev(id, pev_gravity, 0.9);
	}
	
	if (!get_pdata_bool(id, m_bIsVIP))
	{
		set_pdata_int(id, m_iKevlar, 2);
		set_pev(id, pev_armorvalue, 100.0);
	}
	
	message_begin(MSG_ONE, get_user_msgid("ArmorType"), _, id);
	write_byte(1);
	message_end();
	
	return HAM_IGNORED;
}

public WeaponBox_Touch(pWeaponBox, id)
{
	if (id > 33 || id <= 0)
		return HAM_IGNORED;
	
	if (g_iTeam[id] == TEAM_TERRORIST)
	{
		new pWeapon = get_pdata_cbase(pWeaponBox, m_rgpPlayerItems2[5]);
		if (pWeapon <= 0)
			return HAM_SUPERCEDE;
		
		new iId = get_pdata_int(pWeapon, m_iId);
		if (iId != CSW_C4)
			return HAM_SUPERCEDE;
		
		return HAM_IGNORED;
	}
	
	return HAM_IGNORED;
}

public AddPlayerItem(id, iEnt)
{
	if (g_iTeam[id] == TEAM_TERRORIST)
	{
		new iId = get_pdata_int(iEnt, m_iId);
		
		if (iId != CSW_KNIFE && iId != CSW_C4)
			return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

public message_StatusText(msg_id, msg_dest, msg_entity)
{
	if (g_iTeam[msg_entity] == TEAM_CT)
	{
		new sBarString[32];
		get_msg_arg_string(2, sBarString, 32);
		
		if (equal(sBarString, "1 %c1: %p2"))
			set_msg_arg_string(2, "");
	}
}

stock Float:GetVelocity2D(id)
{
	new Float:vecVelocity[3];
	pev(id, pev_velocity, vecVelocity);
	vecVelocity[2] = 0.0;
	
	return xs_vec_len(vecVelocity);
}

stock StripSlot(id, slot)
{
	new item = get_pdata_cbase(id, m_rgpPlayerItems[slot]);
	
	while (item > 0)
	{
		set_pev(id, pev_weapons, pev(id, pev_weapons) &~ (1<<get_pdata_int(item, m_iId)))
		
		ExecuteHamB(Ham_Weapon_RetireWeapon, item);
		new new_item = get_pdata_cbase(item, m_pNext);
		
		if (ExecuteHamB(Ham_RemovePlayerItem, id, item))
			ExecuteHamB(Ham_Item_Kill, item);
		
		item = new_item;
	}
	
	set_pdata_cbase(id, m_rgpPlayerItems[slot], -1);
}