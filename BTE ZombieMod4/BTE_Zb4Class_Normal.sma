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

#define PLUGIN "BTE Zb4 ZClass Normal"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define _BOT_USE_SKILL

#define NAME "z4normal"
#define PLAYER_MODEL "z4_normal"
#define VIEW_MODEL "v_knife_z4normal"

#define STUN_SOUND "zombi/z4/normal/normal_stun.wav"
#define HURT_SOUND "zombi/z4/normal/normal_hurt1.wav"
#define HURT_SOUND2 "zombi/z4/normal/normal_hurt2.wav"
#define DEATH_SOUND "zombi/z4/normal/normal_death.wav"
#define SKILL_SOUND "zombi/z4/normal/normal_skill.wav"
#define DASH_SOUND "zombi/z4/normal/normal_dash1.wav"
#define DASH_SOUND2 "zombi/z4/normal/normal_dash2.wav"


#define MAX_SPEED 275.0
#define GRAVITY 0.8
#define KNOCKBACK 1.0
#define XDAMAGE 1.0
#define VM 1.0

#define HEAL_DAY 12.0
#define HEAL_NIGHT 36.0

#define DASH_INTERVAL 0.3
#define DASH_USAGE 2
#define DASH_SPEED 360.0
#define DASH_KNOCKBACK 0.7
#define DASH_VM 0.9

#define SKILL_PRAPARE 0.8
#define SKILL_INTERVAL 0.55
#define SKILL_USAGE 11



new iClass;
new g_iSpeedUp[33], g_iCanUseSkill[33], Float:g_flNextDashSound[33], g_iDashSound[33];

#define IS_THIS_ZOMBIE(%1) (bte_zb4_get_zombie_class(id) == iClass && bte_get_user_zombie(id))

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("+dash", "DashStart");
	register_clcmd("-dash", "DashEnd");
	
	register_forward(FM_PlayerPostThink, "Forward_PlayerPostThink", 1);
	
#if defined _BOT_USE_SKILL
	register_event("StatusValue", "StatusValueA", "be", "1=1");
	register_event("StatusValue", "StatusValueB", "be", "1=2", "2!0");
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

public Forward_PlayerPostThink(id)
{
	if (pev(id, pev_deadflag) != DEAD_NO)
		return FMRES_IGNORED;
	
	if (!IS_THIS_ZOMBIE(id))
		return FMRES_IGNORED;
	
	new flags = pev(id, pev_flags);
	new Float:vecVelocity[3];
	pev(id, pev_velocity, vecVelocity);
	
	if (flags & FL_ONGROUND && pev(id, pev_sequence) == LookupSequence(id, "skill_start") && vecVelocity[2] <= 0.0)
		ResetSequence(id);
	
	g_iCanUseSkill[id] = !(flags & FL_DUCKING);
	
	if (flags & FL_DUCKING)
		DashEnd(id);
	
	if (g_iSpeedUp[id])
	{
		set_pev(id, pev_maxspeed, DASH_SPEED * get_pdata_float(id, m_flVelocityModifier));
		
		if (get_gametime() > g_flNextDashSound[id])
		{
			PlayEmitSound(id, CHAN_VOICE, g_iDashSound[id] ? DASH_SOUND2 : DASH_SOUND);
			g_flNextDashSound[id] = get_gametime() + 0.75;
			g_iDashSound[id] = 1 - g_iDashSound[id];
		}
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
		MH_ZB4SendData(id, 5);
	
	g_iSpeedUp[id] = 1;
	bte_zb4_set_dash(id, 1, DASH_INTERVAL, DASH_USAGE);
	bte_wpn_set_knockback(id, DASH_KNOCKBACK);
	bte_wpn_set_vm(id, DASH_VM);
	
	g_flNextDashSound[id] = get_gametime() + 0.2;
	g_iDashSound[id] = 0;
	
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
	
	MH_ZB4SendData(id, 6);
	
	g_iSpeedUp[id] = 0;
	bte_zb4_set_dash(id, 0, 0.0, 0);
	bte_wpn_set_knockback(id, KNOCKBACK);
	bte_wpn_set_vm(id, VM);
	
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
	
	new iReady = pev(iEnt, pev_iuser3);
	
	if (bte_get_user_power(id) < SKILL_USAGE || !g_iCanUseSkill[id] || !bte_zb4_can_use_skill(id))
	{
		if (iReady)
			SetSkillStop(id, iEnt);
		else
			SetSkillNextUse(id, iEnt, 1.0);
		
		return;
	}
	
	DashEnd(id);
	
	new Float:flFraction;
	flFraction = TraceLineCheck(id, 48.0);
	
	if (!iReady)
	{
		SetSkillNextUse(id, iEnt, SKILL_PRAPARE);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0);
		
		set_pev(iEnt, pev_iuser3, 1);
		
		SendWeaponAnim(id, 6);
		
		bte_set_using_skill(id, 1);
	}
	else
	{
		SetSkillNextUse(id, iEnt, SKILL_INTERVAL);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.7);
		
		SendWeaponAnim(id, 8);
		PlayAnimation(id, "skill_start");
		
		bte_set_user_power(id, -SKILL_USAGE, SKILL_INTERVAL);
		
		PlayEmitSound(id, CHAN_VOICE, SKILL_SOUND);
		
		if (flFraction > 0.95)
			SetSkillStop(id, iEnt);
		
		new Float:vecVelocity[3];
		vecVelocity[0] = vecVelocity[1] = 0.0;
		vecVelocity[2] = 280.0;
		set_pev(id, pev_velocity, vecVelocity);
	}
}

public ZombieSkillEnd(id, iEnt)
{
	if (!IS_THIS_ZOMBIE(id) || !bte_zb4_can_use_skill(id) || !g_iCanUseSkill[id])
		return;
	
	new iReady = pev(iEnt, pev_iuser3);
	if (iReady)
		SendWeaponAnim(id, 7);
	
	set_pdata_float(id, m_flNextAttack, 0.0);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.7 + 10.0);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.7 + 10.0);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.7);
	
	set_pev(iEnt, pev_iuser1, 0);
	set_pev(iEnt, pev_iuser2, 0);
	set_pev(iEnt, pev_iuser3, 0);
	
	bte_set_using_skill(id, 0);
}

public Float:TraceLineCheck(id, Float:flRange)
{
	new Float:vecScr[3], Float:vecEnd[3], Float:v_angle[3], Float:vecForward[3];
	GetGunPosition(id, vecScr);

	pev(id, pev_v_angle, v_angle);
	v_angle[2] = 0.0;
	
	engfunc(EngFunc_MakeVectors, v_angle);

	global_get(glb_v_forward, vecForward);
	xs_vec_mul_scalar(vecForward, flRange, vecForward);

	xs_vec_add(vecScr, vecForward, vecEnd);

	new tr = create_tr2();
	engfunc(EngFunc_TraceLine, vecScr, vecEnd, 0, id, tr);

	new Float:flFraction;
	get_tr2(tr, TR_flFraction, flFraction);
	
	return flFraction;
}

public plugin_precache()
{
	iClass = bte_zb4_regiter_zombie(NAME, PLAYER_MODEL, VIEW_MODEL, STUN_SOUND, MAX_SPEED, GRAVITY, HEAL_DAY, HEAL_NIGHT, XDAMAGE, KNOCKBACK, VM);
	
	precache_sound(HURT_SOUND);
	precache_sound(HURT_SOUND2);
	precache_sound(DEATH_SOUND);
	precache_sound(SKILL_SOUND);
	precache_sound(DASH_SOUND);
	precache_sound(DASH_SOUND2);
	
}

public bte_zb_infected(iVictim, iAttacker)
{
	g_iSpeedUp[iVictim] = 0;
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

stock GetGunPosition(id, Float:vecScr[3])
{
	new Float:vecViewOfs[3];
	pev(id, pev_origin, vecScr);
	pev(id, pev_view_ofs, vecViewOfs);
	xs_vec_add(vecScr, vecViewOfs, vecScr);
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
