// 把size改小+改view_ofs 看起来可以和蹲下效果差不多..不过没这么做....
// 似乎没什么办法让BOT蹲下 所以这个就不加BOT使用技能了.....

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

#define PLUGIN "BTE Zb4 ZClass Humpback"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define NAME "z4humpback"
#define PLAYER_MODEL "z4_humpback"
#define VIEW_MODEL "v_knife_z4humpback"

#define STUN_SOUND "zombi/z4/hump_back/stun.wav"
#define HURT_SOUND "zombi/z4/hump_back/hurt1.wav"
#define HURT_SOUND2 "zombi/z4/hump_back/hurt2.wav"
#define DEATH_SOUND "zombi/z4/hump_back/death.wav"
#define SKILL_SOUND "zombi/z4/hump_back/skill_start.wav"
#define DASH_SOUND "zombi/z4/hump_back/dash_loop.wav"


#define MAX_SPEED 260.0
#define GRAVITY 0.8
#define KNOCKBACK 0.85
#define XDAMAGE 1.1
#define VM 1.0

#define HEAL_DAY 14.0
#define HEAL_NIGHT 42.0

#define DASH_INTERVAL 0.3
#define DASH_USAGE 4
#define DASH_SPEED 320.0
#define DASH_KNOCKBACK 0.9
#define DASH_XDAMAGE 1.0

#define SKILL_INTERVAL 1.0
#define SKILL_USAGE 40


#define IS_THIS_ZOMBIE(%1) (bte_zb4_get_zombie_class(id) == iClass && bte_get_user_zombie(id))

new iClass;
new g_iSpeedUp[33], Float:g_flNextDashSound[33], Float:g_flNextDashModel[33];

new g_sModelIndexDust;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("+dash", "DashStart");
	register_clcmd("-dash", "DashEnd");
	
	register_forward(FM_PlayerPostThink, "Forward_PlayerPostThink", 1);
	
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_knife", "HamF_Weapon_WeaponIdle");
}

public plugin_precache()
{
	iClass = bte_zb4_regiter_zombie(NAME, PLAYER_MODEL, VIEW_MODEL, STUN_SOUND, MAX_SPEED, GRAVITY, HEAL_DAY, HEAL_NIGHT, XDAMAGE, KNOCKBACK, VM);
	
	precache_sound(HURT_SOUND);
	precache_sound(HURT_SOUND2);
	precache_sound(DEATH_SOUND);
	precache_sound(SKILL_SOUND);
	precache_sound(DASH_SOUND);
	
	g_sModelIndexDust = precache_model("sprites/dust2.spr");
}

public bte_zb_infected(iVictim, iAttacker)
{
	g_iSpeedUp[iVictim] = 0;
	// 直接写入cfg
	//client_cmd(iVictim, "cl_forwardspeed 1200");
}

public Forward_PlayerPostThink(id)
{
	if (pev(id, pev_deadflag) != DEAD_NO)
		return FMRES_IGNORED;
	
	if (!IS_THIS_ZOMBIE(id))
		return FMRES_IGNORED;
	
	new Float:vecVelocity[3];
	pev(id, pev_velocity, vecVelocity);
	
	if (g_iSpeedUp[id])
	{
		set_pev(id, pev_maxspeed, DASH_SPEED * get_pdata_float(id, m_flVelocityModifier) * 3.0);
		
		if (get_gametime() > g_flNextDashSound[id])
		{
			PlayEmitSound(id, CHAN_VOICE, DASH_SOUND);
			g_flNextDashSound[id] = get_gametime() + 0.6;
		}
		if (get_gametime() > g_flNextDashModel[id])
		{
			g_flNextDashModel[id] = get_gametime() + 0.2;
			
			new Float:vecOrigin[3];
			pev(id, pev_origin, vecOrigin);
			
			UTIL_Sprite(vecOrigin, g_sModelIndexDust);
		}
	}
	
	return FMRES_IGNORED;
}

public HamF_Weapon_WeaponIdle(iEnt)
{
	new Float:flTimeWeaponIdle = get_pdata_float(iEnt, m_flTimeWeaponIdle);
	if (flTimeWeaponIdle > 0.0)
		return HAM_IGNORED;
	
	static id
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	if (!IS_THIS_ZOMBIE(id))
		return HAM_IGNORED;
	
	if (g_iSpeedUp[id])
	{
		if (pev(id, pev_weaponanim) != 9)
		{
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.36);
			SendWeaponAnim(id, 9);
			
			return HAM_IGNORED;
		}
		
		SendWeaponAnim(id, 10);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 10.0);
		
		return HAM_IGNORED;
	}
	
	return HAM_IGNORED;
}

public DashStart(id)
{
	if (!IS_THIS_ZOMBIE(id))
		return PLUGIN_CONTINUE;
	
	if (bte_get_user_power(id) < DASH_USAGE || !bte_zb4_can_use_skill(id) || bte_zb4_is_stuned(id))
		return PLUGIN_HANDLED;
	
	if (!g_iSpeedUp[id])
		MH_ZB4SendData(id, 11);
	
	g_iSpeedUp[id] = 1;
	bte_zb4_set_dash(id, 1, DASH_INTERVAL, DASH_USAGE);
	bte_wpn_set_knockback(id, DASH_KNOCKBACK);
	
	g_flNextDashSound[id] = get_gametime() + 0.2;
	g_flNextDashModel[id] = get_gametime() + 0.1;
	
	set_pdata_float(get_pdata_cbase(id, m_pActiveItem), m_flTimeWeaponIdle, 0.33);
	SendWeaponAnim(id, 9);
	
	client_cmd(id, "+duck");
	
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
	
	MH_ZB4SendData(id, 12);
	
	g_iSpeedUp[id] = 0;
	bte_zb4_set_dash(id, 0, 0.0, 0);
	bte_wpn_set_knockback(id, KNOCKBACK);
	
	set_pdata_float(get_pdata_cbase(id, m_pActiveItem), m_flTimeWeaponIdle, 0.7);
	SendWeaponAnim(id, 11);
	
	client_cmd(id, "-duck");
	
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
	
	if (bte_get_user_power(id) < SKILL_USAGE || !g_iSpeedUp[id] || !bte_zb4_can_use_skill(id))
	{
		SetSkillNextUse(id, iEnt, 1.0);
		return;
	}
		
	bte_set_user_power(id, -SKILL_USAGE, SKILL_INTERVAL);
	
	SetSkillNextUse(id, iEnt, 0.2);
	
	new Float:v_angle[3], Float:vecForward[3];
	
	pev(id, pev_v_angle, v_angle);
	v_angle[0] = -60.0;
	
	engfunc(EngFunc_MakeVectors, v_angle);
	
	global_get(glb_v_forward, vecForward);
	xs_vec_mul_scalar(vecForward, 600.0, vecForward);
	
	new Float:vecVelocity[3];
	pev(id, pev_velocity, vecVelocity);
	
	xs_vec_add(vecVelocity, vecForward, vecVelocity);
	
	set_pev(id, pev_velocity, vecVelocity);
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

stock UTIL_Sprite(const Float:vecOrigin[3], model, scale = 10, brightness = 255)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(model);
	write_byte(scale);
	write_byte(brightness);
	message_end();
}