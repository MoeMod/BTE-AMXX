#include <amxmodx>
#include <amxmisc> 
#include <hamsandwich>
#include <fakemeta>
#include <xs>

#include "BTE_ZSE_API.inc"
#include "bte.inc"
#include "inc.inc"
#include "offset.inc"
#include "BTE_API.inc"
#include "cdll_dll.h"
#include "util.sma"

#define PLUGIN "BTE ZClass Tank"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define HURT_SOUND "zombi/zombi_hurt_01.wav"
#define HURT_SOUND2 "zombi/zombi_hurt_02.wav"
#define DEATH_SOUND "zombi/zombi_death_1.wav"
#define DEATH_SOUND2 "zombi/zombi_death_2.wav"
#define SKILL_START "zombi/zombi_pressure.wav"

new Float:g_flNextSkillCanUse[33][2], Float:g_flSkillEnd[33][2];
new Float:g_flNextSkillSoundCanPlay[33];
new g_bUsing[33][2];

new Array:SoundSkillHeartBeat;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");
	
	register_forward(FM_PlayerPostThink, "Forward_PlayerPostThink", TRUE);
	
	register_clcmd("drop", "Skill");
	register_clcmd("zbskill", "Skill2");
	
	gmsgTextMsg = get_user_msgid("TextMsg");
}

public plugin_precache()
{
	precache_sound(HURT_SOUND);
	precache_sound(HURT_SOUND2);
	precache_sound(DEATH_SOUND);
	precache_sound(DEATH_SOUND2);
	precache_sound(SKILL_START);
	
	SoundSkillHeartBeat = ArrayCreate(64, 1);
	
	ArrayPushString(SoundSkillHeartBeat, "zombi/zombi_pre_idle_1.wav")
	ArrayPushString(SoundSkillHeartBeat, "zombi/zombi_pre_idle_2.wav")
	
	new buffer[64];
	for (new i = 0; i < ArraySize(SoundSkillHeartBeat); i++)
	{
		ArrayGetString(SoundSkillHeartBeat, i, buffer, charsmax(buffer));
		engfunc(EngFunc_PrecacheSound, buffer);
	}
}

public Forward_PlayerPostThink(id)
{
	if (!is_user_alive(id))
		return;
	
	if (get_gametime() > g_flSkillEnd[id][0] && g_bUsing[id][0])
	{
		bte_zse_set_maxspeed(id, 320.0);
		bte_zse_set_attack(id, 1.0);
		
		set_pdata_int(id, m_iFOV, 90);
		set_pev(id, pev_fov, 90.0);
		set_pev(id, pev_gravity, 0.7);
		
		g_bUsing[id][0] = FALSE;
	}
	
	if (get_gametime() > g_flSkillEnd[id][1] && g_bUsing[id][1])
	{
		bte_wpn_set_knockback(id, 0.7);
		bte_wpn_set_vm(id, 0.7);
		bte_zse_set_xdamage(id, 0.9);
		
		g_bUsing[id][1] = FALSE;
	}
	
	if(g_flNextSkillSoundCanPlay[id] <= get_gametime() && g_bUsing[id][0])
	{
		g_flNextSkillSoundCanPlay[id] = get_gametime() + 2.0;

		new szSound[64];
		ArrayGetString(SoundSkillHeartBeat, random(ArraySize(SoundSkillHeartBeat)), szSound, charsmax(szSound));
		engfunc(EngFunc_EmitSound, id, CHAN_AUTO, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
}

public Event_HLTV()
{
	new Float:null[33][2];
	g_flNextSkillCanUse = null;
	g_flSkillEnd = null;
}

public Skill(id)
{
	if (!CanUseSkill(id))
		return PLUGIN_CONTINUE;
	
	if (get_gametime() < g_flNextSkillCanUse[id][0])
	{
		new str[4];
		format(str, 4, "%d", floatround(g_flNextSkillCanUse[id][0] - get_gametime()));
		ClientPrint(id, HUD_PRINTCENTER, "#ZombieSkillCoolTime", str);
		
		return PLUGIN_HANDLED;
	}
	
	g_bUsing[id][0] = TRUE;
	
	// speed / atk up
	bte_zse_set_maxspeed(id, 360.0);
	bte_zse_set_attack(id, 2.0);
	
	set_pdata_int(id, m_iFOV, 110);
	set_pev(id, pev_fov, 110.0);
	set_pev(id, pev_gravity, 0.6);
	
	new Float:time = (bte_zse_get_level(id) <= 1) ? 3.0 : 6.0;
	new Float:cooltime = (bte_zse_get_level(id) <= 1) ? 20.0 : 30.0;
	
	g_flNextSkillCanUse[id][0] = get_gametime() + cooltime;
	g_flSkillEnd[id][0] = get_gametime() + time;
	g_flNextSkillSoundCanPlay[id] = get_gametime() + 2.0;
	
	MH_ZSESendData(id, 0, floatround(time));
	
	engfunc(EngFunc_EmitSound, id, CHAN_AUTO, SKILL_START, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	return PLUGIN_HANDLED;
}

public Skill2(id)
{
	if (!CanUseSkill(id))
		return PLUGIN_CONTINUE;
	
	if (bte_zse_get_level(id) <= 1)
		return PLUGIN_HANDLED;
	
	if (get_gametime() < g_flNextSkillCanUse[id][1])
	{
		new str[4];
		format(str, 4, "%d", floatround(g_flNextSkillCanUse[id][1] - get_gametime()));
		ClientPrint(id, HUD_PRINTCENTER, "#ZombieSkillCoolTime", str);
		
		return PLUGIN_HANDLED;
	}
	
	g_bUsing[id][1] = TRUE;
	
	// 减击退和定身减伤
	bte_wpn_set_knockback(id, 0.1);
	bte_wpn_set_vm(id, 0.6);
	bte_zse_set_xdamage(id, 0.5);
	
	g_flNextSkillCanUse[id][1] = get_gametime() + 30.0;
	g_flSkillEnd[id][1] = get_gametime() + 5.0;
	
	MH_ZSESendData(id, 1, 5); // 5s
	
	return PLUGIN_HANDLED;
}

public CanUseSkill(id)
{
	if (!bte_get_user_zombie(id))
		return 0;

	if (!is_user_alive(id))
		return 0;
	
	return 1;
}

public bte_zb_infected(id, attacker)
{
	g_flNextSkillCanUse[id][0] = g_flNextSkillCanUse[id][1] = 0.0;
	g_flSkillEnd[id][0] = g_flSkillEnd[id][1] = 0.0;
	g_flNextSkillSoundCanPlay[id] = 0.0;
/*	
	if (bte_zse_get_level(id) == 1)
		client_print(id, print_chat, "按下G键来使用技能。", floatround(g_flNextSkillCanUse[id][0] - get_gametime()));
	else
		client_print(id, print_chat, "按下G或5键来使用技能。", floatround(g_flNextSkillCanUse[id][0] - get_gametime()));*/
}

public bte_zb_EmitSound(id, iSoundType, iChannel, Float:volume, Float:attn, flags, pitch)
{
	if (iSoundType == EMITSOUND_HURT)
		emit_sound(id, iChannel, random_num(0,1) ? HURT_SOUND : HURT_SOUND2, volume, attn, flags, pitch);
	else
		emit_sound(id, iChannel, random_num(0,1) ? DEATH_SOUND : DEATH_SOUND2, volume, attn, flags, pitch);

}