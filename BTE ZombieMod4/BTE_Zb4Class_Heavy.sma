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

#define PLUGIN "BTE Zb4 ZClass Heavy"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define _BOT_USE_SKILL

#define NAME "z4heavy"
#define PLAYER_MODEL "z4_heavy"
#define VIEW_MODEL "v_knife_z4heavy"

#define STUN_SOUND "zombi/z4/heavy/z4heavy_stun.wav"
#define HURT_SOUND "zombi/z4/heavy/heavy_hurt1.wav"
#define HURT_SOUND2 "zombi/z4/heavy/heavy_hurt2.wav"
#define DEATH_SOUND "zombi/z4/heavy/z4heavy_death.wav"
#define SKILL_SOUND "zombi/z4/heavy/z4heavy_skill_start.wav"
#define SKILL_SOUND2 "zombi/z4/heavy/z4heavy_skill_end.wav"
#define DASH_SOUND "zombi/z4/heavy/z4heavy_dash1.wav"
#define DASH_SOUND2 "zombi/z4/heavy/z4heavy_dash2.wav"


#define MAX_SPEED 265.0
#define GRAVITY 0.84
#define KNOCKBACK 0.7
#define XDAMAGE 0.7
#define VM 0.9

#define HEAL_DAY 15.0
#define HEAL_NIGHT 45.0

#define DASH_INTERVAL 0.3
#define DASH_USAGE 2
#define DASH_SPEED 210.0
#define DASH_KNOCKBACK 0.3
#define DASH_XDAMAGE 0.4
#define DASH_VM 0.8

#define SKILL_INTERVAL 1.0
#define SKILL_USAGE 25
#define SKILL_RANGE 150.0

#define IS_THIS_ZOMBIE(%1) (bte_zb4_get_zombie_class(id) == iClass && bte_get_user_zombie(id))

new iClass;
new g_iSpeedUp[33], g_iCanUseSkill[33], Float:g_flNextDashSound[33], g_iDashSound[33];
new Float:g_flNextResetAnimCheck[33];
new g_iSkillSucceed[33];

new Float:g_flRemoveSkill[33], g_iSkill[33];

new g_msgScreenShake;

new Cache_Event;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("+dash", "DashStart");
	register_clcmd("-dash", "DashEnd");
	
	register_forward(FM_PlayerPostThink, "Forward_PlayerPostThink", 1);
	
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_knife", "HamF_Weapon_WeaponIdle");
	
	Cache_Event = engfunc(EngFunc_PrecacheEvent, 1, "events/knife.sc");
	
	g_msgScreenShake = get_user_msgid("ScreenShake");
	
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

public plugin_precache()
{
	iClass = bte_zb4_regiter_zombie(NAME, PLAYER_MODEL, VIEW_MODEL, STUN_SOUND, MAX_SPEED, GRAVITY, HEAL_DAY, HEAL_NIGHT, XDAMAGE, KNOCKBACK, VM);
	
	precache_sound(HURT_SOUND);
	precache_sound(HURT_SOUND2);
	precache_sound(DEATH_SOUND);
	precache_sound(SKILL_SOUND);
	precache_sound(SKILL_SOUND2);
	precache_sound(DASH_SOUND);
	precache_sound(DASH_SOUND2);
	
}

public bte_zb_infected(iVictim, iAttacker)
{
	g_iSpeedUp[iVictim] = 0;
}

public Forward_PlayerPostThink(id)
{
	if (pev(id, pev_deadflag) != DEAD_NO)
		return FMRES_IGNORED;
	
	if (!bte_get_user_zombie(id) && g_iSkill[id])
	{
		if(g_flRemoveSkill[id] > get_gametime())
		{
			set_pdata_float(id, m_flVelocityModifier, 0.3);
		}
		else
		{
			g_iSkill[id] = 0;
			MH_ZB4AddIcon(id, 8, 5, 3);
		}
	}
	
	if (bte_zb4_get_zombie_class(id) != iClass || !bte_get_user_zombie(id))
		return FMRES_IGNORED;
	
	new flags = pev(id, pev_flags);
	new Float:vecVelocity[3];
	pev(id, pev_velocity, vecVelocity);
	
	if (flags & FL_ONGROUND && get_gametime() > g_flNextResetAnimCheck[id] && g_flNextResetAnimCheck[id])
	{
		g_flNextResetAnimCheck[id] = 0.0;
		
		Skill(id);
	}
	
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

public bte_zb4_kick(iVictim, iAttacker)
{
	if (g_iSkillSucceed[iVictim])
		SetSkillNextUse(iVictim, get_pdata_cbase(iVictim, m_pActiveItem), 0.0);
	
	g_iSkillSucceed[iVictim] = 0;
}

public HamF_Weapon_WeaponIdle(iEnt)
{
	new Float:flTimeWeaponIdle = get_pdata_float(iEnt, m_flTimeWeaponIdle);
	if (flTimeWeaponIdle > 0.0)
		return HAM_IGNORED;
	
	static id
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	if (bte_zb4_get_zombie_class(id) != iClass || !bte_get_user_zombie(id))
		return HAM_IGNORED;
	
	if (g_iSpeedUp[id])
	{
		if (pev(id, pev_weaponanim) != 9)
		{
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.33);
			SendWeaponAnim(id, 9);
			
			return HAM_IGNORED;
		}
		SendWeaponAnim(id, 10);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 10.0);
		
		return HAM_IGNORED;
	}
	
	if (g_iSkillSucceed[id])
	{
		SendWeaponAnim(id, 8);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 10.0);
		
		return HAM_IGNORED;
	}
	
	return HAM_IGNORED;
}

public DashStart(id)
{
	if (!IS_THIS_ZOMBIE(id))
		return PLUGIN_CONTINUE;
	
	if (bte_get_user_power(id) < DASH_USAGE || !bte_zb4_can_use_skill(id) || !g_iCanUseSkill[id] || bte_zb4_is_stuned(id))
		return PLUGIN_HANDLED;
	
	if (!g_iSpeedUp[id])
		MH_ZB4SendData(id, 9);
	
	g_iSpeedUp[id] = 1;
	bte_zb4_set_dash(id, 1, DASH_INTERVAL, DASH_USAGE);
	bte_wpn_set_knockback(id, DASH_KNOCKBACK);
	bte_zb4_set_xdamage(id, DASH_XDAMAGE);
	bte_wpn_set_vm(id, DASH_VM);
	
	g_flNextDashSound[id] = get_gametime() + 0.2;
	g_iDashSound[id] = 0;
	
	set_pdata_float(get_pdata_cbase(id, m_pActiveItem), m_flTimeWeaponIdle, 0.33);
	SendWeaponAnim(id, 9);
	
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
	
	MH_ZB4SendData(id, 10);
	
	g_iSpeedUp[id] = 0;
	bte_zb4_set_dash(id, 0, 0.0, 0);
	bte_wpn_set_knockback(id, KNOCKBACK);
	bte_zb4_set_xdamage(id);
	bte_wpn_set_vm(id, VM);
	
	set_pdata_float(get_pdata_cbase(id, m_pActiveItem), m_flTimeWeaponIdle, 0.43);
	SendWeaponAnim(id, 11);
	
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
	
	if (bte_get_user_power(id) < SKILL_USAGE || !g_iCanUseSkill[id] || !bte_zb4_can_use_skill(id) || !(pev(id, pev_flags) & FL_ONGROUND))
	{
		SetSkillNextUse(id, iEnt, SKILL_INTERVAL);
		return;
	}
	
	DashEnd(id);
	
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.53);
	SendWeaponAnim(id, 6);
	
	PlayAnimation(id, "skill_start");
	
	SetSkillNextUse(id, iEnt, 999.0);
	bte_set_user_power(id, -SKILL_USAGE, SKILL_INTERVAL);
	bte_set_using_skill(id, 1);
	bte_wpn_set_vm(id, 0.1);
	bte_wpn_set_knockback(id, 0.1);
	
	PlayEmitSound(id, CHAN_VOICE, SKILL_SOUND);
	
	g_iSkillSucceed[id] = 1;
	g_flNextResetAnimCheck[id] = get_gametime() + 0.01;
	
	new Float:v_angle[3], Float:vecForward[3], Float:vecVelocity[3];
	
	pev(id, pev_v_angle, v_angle);
	engfunc(EngFunc_MakeVectors, v_angle);
	v_angle[0] = 0.0;
	
	global_get(glb_v_forward, vecForward);
	xs_vec_mul_scalar(vecForward, 175.0, vecForward);
	vecForward[2] = 250.0;
	xs_vec_copy(vecForward, vecVelocity);
	
	set_pev(id, pev_velocity, vecVelocity);

}

public Skill(id)
{
	if (!g_iSkillSucceed[id])
		return;
	
	PlayEmitSound(id, CHAN_VOICE, SKILL_SOUND2);
	
	SendWeaponAnim(id, 7);
	PlayAnimation(id, "skill_end");
	
	new iEnt = get_pdata_cbase(id, m_pActiveItem);
	
	SetSkillNextUse(id, iEnt, 1.0);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.56);
	g_iSkillSucceed[id] = 0;
	bte_set_using_skill(id, 0);
	bte_wpn_set_vm(id, VM);
	bte_wpn_set_knockback(id, KNOCKBACK);
	
	set_pdata_float(id, m_flVelocityModifier, 0.5);
	
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, Cache_Event, 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0 , 0.0, (1<<6), 0, false, false);
	
	new Float:vecOrigin[3];
	pev(id, pev_origin, vecOrigin);
	
	new pEntity = -1;
	while ((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, SKILL_RANGE)) != 0)
	{
		if (pEntity > 32)
			break;
		
		if (!is_user_alive(pEntity))
			continue;
		
		if (bte_get_user_zombie(pEntity))
			ScreenShake(pEntity, 8, 4, 18);
		else
		{
			g_iSkill[pEntity] = 1;
			g_flRemoveSkill[pEntity] = get_gametime() + 1.0;
			ScreenShake(pEntity, 16, 4, 18);
			
			new Float:vecOrigin2[2][3], Float:vecVelocity[3];
			pev(pEntity, pev_origin, vecOrigin2[1]);
			pev(pEntity, pev_velocity, vecVelocity);
			
			xs_vec_copy(vecOrigin, vecOrigin2[0]);
			vecOrigin2[0][2] -= 28.0;
			xs_vec_sub(vecOrigin2[1], vecOrigin2[0], vecOrigin2[1]);
			xs_vec_normalize(vecOrigin2[1], vecOrigin2[1]);
			
			xs_vec_mul_scalar(vecOrigin2[1], 600.0, vecOrigin2[1]);
			
			xs_vec_add(vecVelocity, vecOrigin2[1], vecVelocity);
			
			set_pev(pEntity, pev_velocity, vecVelocity);
			
			MH_ZB4AddIcon(pEntity, 8, 5, 1);
		}
		
	}
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

stock ScreenShake(id, amplitude = 8, duration = 6, frequency = 18)
{
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
	write_short((1<<12)*amplitude) 
	write_short((1<<12)*duration) 
	write_short((1<<12)*frequency) 
	message_end()
}
