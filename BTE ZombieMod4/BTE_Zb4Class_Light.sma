#include <amxmodx>
#include <amxmisc> 
#include <hamsandwich>
#include <fakemeta>
#include <xs>

#include "inc.inc"
#include "offset.inc"
#include "animation.inc"
#include "BTE_Zb4_API.inc"
#include "BTE_API.inc"

#define PLUGIN "BTE Zb4 ZClass Light"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define _BOT_USE_SKILL

#define NAME "z4light"
#define PLAYER_MODEL "z4_light"
#define VIEW_MODEL "v_knife_z4light"

#define STUN_SOUND "zombi/z4/light/light_stun.wav"
#define HURT_SOUND "zombi/z4/light/light_gut_flinch1.wav"
#define HURT_SOUND2 "zombi/z4/light/light_gut_flinch2.wav"
#define DEATH_SOUND "zombi/z4/light/light_death.wav"
#define SKILL_SOUND "zombi/z4/light/light_skill_start.wav"
#define DASH_SOUND "zombi/z4/light/light_dash.wav"


#define MAX_SPEED 285.0
#define GRAVITY 0.6
#define KNOCKBACK 1.1
#define XDAMAGE 1.15
#define VM 1.1

#define HEAL_DAY 10.0
#define HEAL_NIGHT 30.0

#define DASH_INTERVAL 0.25
#define DASH_USAGE 2
#define DASH_SPEED 310.0
#define DASH_KNOCKBACK 1.5
#define DASH_XDAMAGE 1.32
#define DASH_VM 0.95
#define DASH_ALPHA 70.0

#define SKILL_INTERVAL 1.0
#define SKILL_USAGE 60
#define SKILL_SPEED 600.0
#define SKILL_SPEED_Z 400.0


#define IS_THIS_ZOMBIE(%1) (bte_zb4_get_zombie_class(%1) == iClass && bte_get_user_zombie(%1))

new iClass;
new g_iSpeedUp[33], g_iCanUseSkill[33];
new Float:g_flNextResetAnimCheck[33];
new Float:g_flAlpha[33];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("+dash", "DashStart");
	register_clcmd("-dash", "DashEnd");
	
	register_forward(FM_PlayerPostThink, "PlayerPostThink", 1);
	register_forward(FM_AddToFullPack, "AddToFullPack", 1);
	
#if defined _BOT_USE_SKILL
	//register_event("StatusValue", "StatusValueA", "be", "1=1");
	register_event("StatusValue", "StatusValueB", "be", "1=2");
#endif
}

#if defined _BOT_USE_SKILL
public StatusValueA(id)
{
	if (!IS_THIS_ZOMBIE(id))
		return;
	
	if (!is_user_bot(id) || !is_user_alive(id))
		return;
	
	if (g_iSpeedUp[id])
		DashEnd(id);
}

public StatusValueB(id)
{
	if (!IS_THIS_ZOMBIE(id))
		return;
	
	if (!is_user_bot(id) || !is_user_alive(id))
		return;
	
	if (!g_iSpeedUp[id])
		DashStart(id);
}
#endif

new Float:flLastCheck[33];

public AddToFullPack(es_handle, e, ent, host, hostflags, player, pSet)
{
	if (ent > 32 || !ent)
		return FMRES_IGNORED;
	
	if (!IS_THIS_ZOMBIE(ent))
		return FMRES_IGNORED;
	
	if (is_user_alive(ent)/* && g_iSpeedUp[ent]*/)
	{
		if (g_iSpeedUp[ent])
			g_flAlpha[ent] -= (get_gametime() - flLastCheck[ent]) * ((255.0 - DASH_ALPHA) / 0.5);
		else
			g_flAlpha[ent] += (get_gametime() - flLastCheck[ent]) * ((255.0 - DASH_ALPHA) / 0.5);
		
		if (g_flAlpha[ent] > 255.0)
		{
			g_flAlpha[ent] = 255.0;
			set_pev(ent, pev_skin, 0);
			
			return FMRES_IGNORED;
		}
		
		if (g_flAlpha[ent] < DASH_ALPHA)
			g_flAlpha[ent] = DASH_ALPHA;
		
		flLastCheck[ent] = get_gametime();
		
		set_es(es_handle, ES_RenderMode, kRenderTransAlpha);
		set_es(es_handle, ES_RenderAmt, floatround(g_flAlpha[ent]));
	}
	
	return FMRES_IGNORED;
}

public PlayerPostThink(id)
{
	if (pev(id, pev_deadflag) != DEAD_NO)
		return FMRES_IGNORED;
	
	if (!IS_THIS_ZOMBIE(id))
		return FMRES_IGNORED;
	
	new flags = pev(id, pev_flags);
	new Float:vecVelocity[3];
	pev(id, pev_velocity, vecVelocity);
	
	if (flags & FL_ONGROUND && get_gametime() > g_flNextResetAnimCheck[id] && g_flNextResetAnimCheck[id])
	{
		g_flNextResetAnimCheck[id] = 0.0;
		
		if (pev(id, pev_weaponanim) == 6)
		{
			set_pdata_float(get_pdata_cbase(id, m_pActiveItem), m_flTimeWeaponIdle, 1.0);
			SendWeaponAnim(id, 7);
		}
		if (pev(id, pev_sequence) == LookupSequence(id, "skill_start"))
			ResetSequence(id);
	}
	
	g_iCanUseSkill[id] = !(flags & FL_DUCKING);
	
	if (flags & FL_DUCKING)
		DashEnd(id);
	
	if (g_iSpeedUp[id])
	{
		set_pev(id, pev_maxspeed, DASH_SPEED * get_pdata_float(id, m_flVelocityModifier));
	}
	
	return FMRES_IGNORED;
}

public DashStart(id)
{
	if (!IS_THIS_ZOMBIE(id))
		return PLUGIN_CONTINUE;
	
	if (bte_get_user_power(id) < DASH_USAGE || !bte_zb4_can_use_skill(id) || !g_iCanUseSkill[id] || bte_zb4_is_stuned(id))
		return PLUGIN_HANDLED;
	
	if (!g_iSpeedUp[id])
		MH_ZB4SendData(id, 7);
	
	g_iSpeedUp[id] = 1;
	bte_zb4_set_dash(id, 1, DASH_INTERVAL, DASH_USAGE);
	bte_zb4_set_xdamage(id, DASH_XDAMAGE);
	bte_wpn_set_knockback(id, DASH_KNOCKBACK);
	bte_wpn_set_vm(id, DASH_VM);

	set_pev(id, pev_skin, 1);
	
	PlayEmitSound(id, CHAN_VOICE, DASH_SOUND);
	
	//SetRendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 130);
	
	return PLUGIN_HANDLED;
}

public DashEnd(id)
{
	if (!IS_THIS_ZOMBIE(id))
		return PLUGIN_CONTINUE;
	
	if (!bte_zb4_can_use_skill(id))
		return PLUGIN_HANDLED;
	
	if (!g_iSpeedUp[id])
		return PLUGIN_HANDLED;
		
	MH_ZB4SendData(id, 8);
	
	g_iSpeedUp[id] = 0;
	bte_zb4_set_dash(id, 0, 0.0, 0);
	bte_zb4_set_xdamage(id);
	//set_pev(id, pev_skin, 0);
	bte_wpn_set_knockback(id, KNOCKBACK);
	bte_wpn_set_vm(id, VM);
	
	//SetRendering(id);
	
	return PLUGIN_HANDLED;
}

public SetSkillStop(id, iEnt)
{
	set_pdata_float(iEnt, m_flNextPrimaryAttack, SKILL_INTERVAL + 20.0);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, SKILL_INTERVAL + 20.0);
	set_pdata_float(id, m_flNextAttack, SKILL_INTERVAL - 0.05);
	set_pev(iEnt, pev_iuser1, 1);
}

public SetSkillNextUse(id, iEnt, Float:flNext)
{
	set_pdata_float(iEnt, m_flNextPrimaryAttack, flNext + 10.0);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, flNext + 10.0);
	set_pdata_float(id, m_flNextAttack, flNext + 0.05);
	set_pev(iEnt, pev_iuser1, 1);
}

public ZombieSkill(id, iEnt)
{
	if (!IS_THIS_ZOMBIE(id))
		return;
	
	if (bte_get_user_power(id) < SKILL_USAGE || !g_iCanUseSkill[id] || !bte_zb4_can_use_skill(id))
	{
		SetSkillNextUse(id, iEnt, 1.0);
		return;
	}
	
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 10.0);
	SetSkillNextUse(id, iEnt, SKILL_INTERVAL);
	
	SendWeaponAnim(id, 6);
	PlayAnimation(id, "skill_start");
	
	g_flNextResetAnimCheck[id] = get_gametime() + 0.01;
	
	bte_set_user_power(id, -SKILL_USAGE, SKILL_INTERVAL);
	
	PlayEmitSound(id, CHAN_VOICE, SKILL_SOUND);
	
	
	new Float:v_angle[3], Float:vecForward[3];
	
	pev(id, pev_v_angle, v_angle);
	//v_angle[0] = -35.0;
	engfunc(EngFunc_MakeVectors, v_angle);

	global_get(glb_v_forward, vecForward);
	xs_vec_mul_scalar(vecForward, SKILL_SPEED, vecForward);
	vecForward[2] = SKILL_SPEED_Z;
	
	new Float:vecVelocity[3];
	pev(id, pev_velocity, vecVelocity);
	
	xs_vec_add(vecVelocity, vecForward, vecVelocity);
	
	set_pev(id, pev_velocity, vecVelocity);
}

public plugin_precache()
{
	iClass = bte_zb4_regiter_zombie(NAME, PLAYER_MODEL, VIEW_MODEL, STUN_SOUND, MAX_SPEED, GRAVITY, HEAL_DAY, HEAL_NIGHT, XDAMAGE, KNOCKBACK, VM);
	
	precache_sound(HURT_SOUND);
	precache_sound(HURT_SOUND2);
	precache_sound(DEATH_SOUND);
	precache_sound(SKILL_SOUND);
	precache_sound(DASH_SOUND);
	
}

public bte_zb_infected(iVictim, iAttacker)
{
	g_iSpeedUp[iVictim] = 0;
	g_flAlpha[iVictim] = 255.0;
	flLastCheck[iVictim] = get_gametime();
}

public bte_zb_EmitSound(id, iSoundType, iChannel, Float:volume, Float:attn, flags, pitch)
{
	if (!IS_THIS_ZOMBIE(id))
		return;
	
	if (iSoundType == EMITSOUND_HURT)
		emit_sound(id, iChannel, random_num(0,1) ? HURT_SOUND : HURT_SOUND2, volume, attn, flags, pitch);
	else
		emit_sound(id, iChannel, DEATH_SOUND, volume, attn, flags, pitch);

}

stock SendWeaponAnim(id, iAnim)
{
	if (!is_user_alive(id)) return;
	
	set_pev(id, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(iAnim)
	write_byte(pev(id, pev_body))
	message_end()
}

stock PlayEmitSound(id, type, const sound[])
{
	emit_sound(id, type, sound, 1.0, ATTN_NORM, 0, PITCH_NORM);
}

stock SetRendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) 
{
	new Float:RenderColor[3];
	RenderColor[0] = float(r);
	RenderColor[1] = float(g);
	RenderColor[2] = float(b);

	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, RenderColor);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));
}

