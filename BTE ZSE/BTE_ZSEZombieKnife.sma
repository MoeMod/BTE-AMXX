#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <orpheu>
#include <orpheu_stocks>

#include "BTE_ZSE_API.inc"
#include "bte_api.inc"
#include "offset.inc"
#include "bte.inc"

#define PLUGIN "BTE Zombie Knife"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define SWING "zombi/zombi_swing_1.wav"
#define SWING2 "zombi/zombi_swing_2.wav"
#define SWING3 "zombi/zombi_swing_3.wav"
#define HIT "zombi/zombi_attack_1.wav"
#define HIT2 "zombi/zombi_attack_2.wav"
#define HIT3 "zombi/zombi_attack_3.wav"
#define WALL "zombi/zombi_wall_1.wav"
#define WALL2 "zombi/zombi_wall_2.wav"

new Float:DAMAGE[2], Float:DISTANCE[2];

enum _:HIT_RESULT
{
	RESULT_HIT_NONE = 0,
	RESULT_HIT_PLAYER,
	RESULT_HIT_WORLD
}

new OrpheuFunction:handleSetAnimation;
new g_anim[33];

enum _:knife_e
{
	KNIFE_IDLE = 0,
	KNIFE_ATTACK1HIT,
	KNIFE_ATTACK2HIT,
	KNIFE_DRAW,
	KNIFE_STABHIT,
	KNIFE_STABMISS,
	KNIFE_MIDATTACK1HIT,
	KNIFE_MIDATTACK2HIT
}

enum _:PLAYER_ANIM
{
	PLAYER_IDLE = 0,
	PLAYER_WALK,
	PLAYER_JUMP,
	PLAYER_SUPERJUMP,
	PLAYER_DIE,
	PLAYER_ATTACK1,
	PLAYER_ATTACK2,
	PLAYER_FLINCH,
	PLAYER_LARGE_FLINCH,
	PLAYER_RELOAD,
	PLAYER_HOLDBOMB
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "PrimaryAttack");
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "SecondaryAttack");
	
	handleSetAnimation = OrpheuGetFunction( "SetAnimation", "CBasePlayer" );
}

public PrimaryAttack(iEnt)
{
	static id;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4)
	
	if (bte_get_user_zombie(id) != 1)
		return HAM_IGNORED;
	
	g_anim[id] += 1;
	new iAnim = g_anim[id] % 2;
	
	SendWeaponAnim(id, iAnim ? KNIFE_MIDATTACK1HIT : KNIFE_MIDATTACK2HIT);
	OrpheuCallSuper(handleSetAnimation, id, PLAYER_ATTACK1);

	new iHitResult = bte_KnifeAttack(id, 0, DISTANCE[0], bte_zse_get_level(id) >= 2 ? DAMAGE[0] * 1.5 : DAMAGE[0]);
	
	if (iHitResult == RESULT_HIT_NONE)
	{
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.35);
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.5);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.0);
		
		emit_sound(id, CHAN_ITEM, iAnim ? SWING2 : SWING, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
	else
	{
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.4);
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.5);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.0);
		
		if (iHitResult == RESULT_HIT_PLAYER)
			emit_sound(id, CHAN_ITEM, iAnim ? HIT2 : HIT, 1.0, ATTN_NORM, 0, PITCH_NORM);
		else
			emit_sound(id, CHAN_ITEM, iAnim ? WALL2 : WALL, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}

	return HAM_SUPERCEDE;
}

public SecondaryAttack(iEnt)
{
	static id;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4)
	
	if (bte_get_user_zombie(id) != 1)
		return HAM_IGNORED;
	
	OrpheuCallSuper(handleSetAnimation, id, PLAYER_ATTACK1);
	
	new iHitResult = bte_KnifeAttack(id, 0, DISTANCE[1], bte_zse_get_level(id) >= 2 ? DAMAGE[1] * 1.5 : DAMAGE[1]);
	
	if (iHitResult == RESULT_HIT_NONE)
	{
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.0);
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.0);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.0);
		
		SendWeaponAnim(id, KNIFE_STABMISS);
		
		emit_sound(id, CHAN_ITEM, SWING3, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
	else
	{
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.1);
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.1);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.0);
		
		SendWeaponAnim(id, KNIFE_STABHIT);
		
		if (iHitResult == RESULT_HIT_PLAYER)
			emit_sound(id, CHAN_ITEM, HIT3, 1.0, ATTN_NORM, 0, PITCH_NORM);
		else
			emit_sound(id, CHAN_ITEM, random_num(0, 1) ? WALL2 : WALL, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
	
	return HAM_SUPERCEDE;
}

public plugin_precache()
{
	LoadCfg();
	
	precache_sound(SWING);
	precache_sound(SWING2);
	precache_sound(SWING3);
	precache_sound(HIT);
	precache_sound(HIT2);
	precache_sound(HIT3);
	precache_sound(WALL);
	precache_sound(WALL2);
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

stock BreakupStringFloat(value[], any:data[])
{
	new key[128];
	new i = 0;
	while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
	{
		trim(key)
		trim(value)
		data[i] = str_to_float(key);
		i += 1;
	}
}

#define SITTING_FILE "cstrike/addons/amxmodx/configs/bte_zse.ini"
#define CONFIG_VALUE "Zombie"

public LoadCfg()
{
	new data[64];
	GetPrivateProfile(CONFIG_VALUE, "DAMAGE", "80, 240", SITTING_FILE, BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, DAMAGE);
	
	GetPrivateProfile(CONFIG_VALUE, "DISTANCE", "32, 48", SITTING_FILE, BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, DISTANCE);
}