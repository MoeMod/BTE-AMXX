#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <orpheu>
#include <orpheu_stocks>


#include "bte_api.inc"
#include "offset.inc"
#include "BTE_Zb4_API.inc"
#include "animation.inc"

#define PLUGIN "BTE Zb4 Zombie Knife"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define SWING "zombi/z4/all/z4zombi_swing_1.wav"
#define SWING2 "zombi/z4/all/z4zombi_swing_2.wav"
#define HIT "zombi/zombi_attack_1.wav"
#define HIT2 "zombi/zombi_attack_2.wav"
#define WALL "zombi/zombi_wall_1.wav"
#define WALL2 "zombi/zombi_wall_2.wav"

enum _:HIT_RESULT
{
	RESULT_HIT_NONE = 0,
	RESULT_HIT_PLAYER,
	RESULT_HIT_WORLD
}

new OrpheuFunction:handleSetAnimation;
new g_anim[33];
new g_fw_ZombieSkill, g_fw_ZombieSkillEnd, g_fw_DummyResult;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	RegisterHam(Ham_Item_PostFrame, "weapon_knife", "HamF_Item_PostFrame");
	
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "HamF_Item_Deploy")
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "HamF_Item_Deploy_Post", 1);
	
	handleSetAnimation = OrpheuGetFunction( "SetAnimation", "CBasePlayer" );
	
	g_fw_ZombieSkill = CreateMultiForward("ZombieSkill", ET_IGNORE, FP_CELL, FP_CELL);
	g_fw_ZombieSkillEnd = CreateMultiForward("ZombieSkillEnd", ET_IGNORE, FP_CELL, FP_CELL);
}

public plugin_precache()
{
	precache_sound(SWING);
	precache_sound(SWING2);
	precache_sound(HIT);
	precache_sound(HIT2);
	precache_sound(WALL);
	precache_sound(WALL2);
	
}


public HamF_Item_PostFrame(iEnt)
{
	static id;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4)
	
	if (bte_get_user_zombie(id) != 1)
		return HAM_IGNORED;
	
	static iButton, iHitResult, bool:bStab;
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 10.0 && get_pdata_float(iEnt, m_flNextSecondaryAttack) <= 10.0)
	{
		iButton = pev(id, pev_button);
		
		if (iButton & IN_ATTACK)
		{
			set_pdata_float(id, m_flNextAttack, 0.0);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.35 + 10.0);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.5 + 10.0);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.5);
			
			set_pev(iEnt, pev_iuser1, 1);
			set_pev(iEnt, pev_iuser2, 0);
			
			g_anim[id] += 1;
			new iAnim = g_anim[id] % 2;
			
			SendWeaponAnim(id, 1 + iAnim);
			OrpheuCallSuper(handleSetAnimation, id, PLAYER_ATTACK1 + iAnim);
			
			emit_sound(id, CHAN_ITEM, iAnim ? SWING2 : SWING, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
		
		if (iButton & IN_ATTACK2)
		{
			g_anim[id] = 0;
			
			set_pdata_float(id, m_flNextAttack, 10.0);
			/*set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.0 + 10.0);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.0 + 10.0);
			//set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.0);
			
			set_pev(iEnt, pev_iuser1, 1);*/
			set_pev(iEnt, pev_iuser2, 1);
			
			ExecuteForward(g_fw_ZombieSkill, g_fw_DummyResult, id, iEnt);
		}
		
		iButton &= ~IN_ATTACK;
		iButton &= ~IN_ATTACK2;
		set_pev(id, pev_button, iButton);
	}
	if (get_pdata_float(id, m_flNextAttack) <= 0.0 && pev(iEnt, pev_iuser1))
	{
		bStab = pev(iEnt, pev_iuser2)?true:false;
		if (!bStab)
		{
			iHitResult = bte_KnifeAttack(id, 0, 32.0, 100.0);
			
			switch (iHitResult)
			{
				case RESULT_HIT_PLAYER : emit_sound(id, CHAN_ITEM, pev(iEnt, pev_iuser4) ? HIT2 : HIT, 1.0, ATTN_NORM, 0, PITCH_NORM);
				case RESULT_HIT_WORLD : emit_sound(id, CHAN_ITEM, pev(iEnt, pev_iuser4) ? WALL2 : WALL, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		else
		{
			ExecuteForward(g_fw_ZombieSkillEnd, g_fw_DummyResult, id, iEnt);
		}
		
		set_pev(iEnt, pev_iuser1, 0);
	}
	
	return HAM_IGNORED;
}

public HamF_Item_Deploy(iEnt)
{
	static id 
	id = get_pdata_cbase(iEnt, m_pPlayer, 4)
	if (!is_user_alive(id)) return HAM_SUPERCEDE
	return HAM_IGNORED
}

public HamF_Item_Deploy_Post(iEnt)
{
	static id 
	id = get_pdata_cbase(iEnt, m_pPlayer, 4)
	
	if (bte_get_user_zombie(id) != 1)
		return HAM_IGNORED;
	
	SendWeaponAnim(id, 3);
	
	set_pdata_float(id, m_flNextAttack, 0.5, 5);
	set_pdata_float(iEnt,m_flTimeWeaponIdle, 1.5);
	
	set_pev(iEnt, pev_iuser1, 0);
	set_pev(iEnt, pev_iuser2, 0);
	set_pev(iEnt, pev_iuser3, 0);
	set_pev(iEnt, pev_iuser4, 0);
	
	g_anim[id] = 0;
	
	return HAM_SUPERCEDE;
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


