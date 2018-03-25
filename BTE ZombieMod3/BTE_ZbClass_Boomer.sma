#define PLUGIN "BTE Boomer Zombie"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define CONFIG_sName		"[Boomer Zombie]"

#define ZMOBIE_TYPE		"resource\\hud\\zombie\\zombietype_boomer_zombi"
#define SKILL_ICON		"mode\\zb3\\zombieskill_zombiheal"
#define SKILL_ICON2		"mode\\zb3\\zombieskill_zombiguard"
#define SKILL_RRTINA	"mode\\zb3\\retina_zombiheal"
#define SKILL_RRTINA2	"mode\\zb3\\zombitrap"


#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#include "metahook.inc"
#include "bte_api.inc"
#include "bte_zb3.inc"
#include "cdll_dll.h"

#define	m_pActiveItem	373
#define	m_iId			43

#define	m_iTeam			114

#define m_flNextPrimaryAttack	 46
#define m_flNextSecondaryAttack	 47
#define m_flTimeWeaponIdle		 48

#define DMG_EXPLOSION (1<<24)

#define CanUseSkill(%1)		bte_zb3_can_use_skill(%1) && iCanUseSkill[%1]
#define CanUseSkill2(%1)	bte_zb3_can_use_skill(%1)


new iClass;
new sName[32], sModel[32], sSkillsName[32], SoundDeath1[64],SoundDeath2[64], SoundHurt1[64],SoundHurt2[64], SoundHeal[64], SoundEvolution[64];
new Float:fGravity, Float:fSpeed, Float:fXDamage[3], Float:fKnockback;
new isModelIndex, iSex;

new Float:fCoolDownTime[3], Float:fCoolDownTime2[3];
new Float:fSkillTime[3];
new Float:fSkillKnockback[3], Float:fSkillXDamage[3];

new sSkillsName2[32];

new iCanUseSkill[33];
new Float:fNextCanUse[33], Float:fNextCanUse2[33];
new Float:fNextSkillRemove[33];

new Float:fDeathKnockback, Float:fDeathKnockbackRadius, Float:fDeathDamage;

new isSkilling[33];

new SoundSkillHeal[64];
new Float:fSkillHealHealth[3];
new sSprHeal[64], sSprDeathA[64], sSprDeathB[64], SprHeal, SprDeathA, SprDeathB;
new sModelExpA[64], sModelExpB[64];

new g_msgScreenShake;

new g_hamczbots;

new c_szArName[64], c_szArSound[64], Float:c_flArAmount, Float:c_flArWait
new Float:g_flArCD[33]

native MetahookMsg(id, type, i2 = -1, i3 = -1)


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1");

	register_forward(FM_ClientCommand, "fw_ClientCommand");
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink", 1);
	//register_forward(FM_TraceLine, "fw_TraceLine",1);

	RegisterHam(Ham_Think, "info_target", "HamF_Think");
	RegisterHam(Ham_Killed, "player", "HamF_Killed", 1);

	register_message(get_user_msgid("ClCorpse"), "message_ClCorpse");

	g_msgScreenShake = get_user_msgid("ScreenShake");
	register_clcmd("zbskill", "Activate_ArmorRecovery")

}

public client_putinserver(id)
{
	if (is_user_bot(id) && !g_hamczbots)
		set_task(0.1, "RegisterHamBot", id)

}

public RegisterHamBot(id)
{
	if (g_hamczbots || !is_user_connected(id)) return;

	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed", 1);
	g_hamczbots = 1;
}

public plugin_precache()
{
	LoadConfigFile();
	iClass = bte_zb3_register_zombie_class(sName, sModel, fGravity, fSpeed, fKnockback, SoundDeath1, SoundDeath2, SoundHurt1, SoundHurt2, SoundHeal, SoundEvolution, iSex, isModelIndex , fXDamage[0], fXDamage[1])

	SprHeal = engfunc(EngFunc_PrecacheModel, sSprHeal);
	SprDeathA = engfunc(EngFunc_PrecacheModel, sSprDeathA);
	SprDeathB = engfunc(EngFunc_PrecacheModel, sSprDeathB);
	engfunc(EngFunc_PrecacheModel, sModelExpA);
	engfunc(EngFunc_PrecacheModel, sModelExpB);
	engfunc(EngFunc_PrecacheSound, SoundSkillHeal);
}

public message_ClCorpse(msgid, msgdest, id)
{
	static szModel[32];
	get_msg_arg_string(1, szModel, 31);

	return (equal(szModel, sModel, strlen(sModel))) ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}

public HamF_Think(iEnt)
{
	if (!pev_valid(iEnt)) return HAM_IGNORED;

	new classname[32];
	pev(iEnt, pev_classname, classname, charsmax(classname));
	if(!equal(classname, "boomer_exp")) return HAM_IGNORED;

	set_pev(iEnt, pev_effects, EF_NODRAW);
	set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);
	return HAM_IGNORED;
}


public fw_PlayerPostThink(id)
{
	if(pev(id, pev_deadflag) != DEAD_NO)
		return FMRES_IGNORED;

	if(bte_get_user_zombie(id) != 1)
		return FMRES_IGNORED;

	if(bte_zb3_get_user_zombie_class(id) != iClass)
		return FMRES_IGNORED;

	new Float:fCurTime;
	global_get(glb_time, fCurTime);

	if(fNextSkillRemove[id] <= fCurTime && fNextSkillRemove[id])
	{
		new iLevel = bte_zb3_get_user_level(id) - 1;

		SetRendering(id);
		isSkilling[id] = 0;
		fNextSkillRemove[id] = 0.0;
		bte_wpn_set_knockback(id, fKnockback);
		bte_zb3_set_xdamage(id, fXDamage[iLevel], iLevel);
	}

	if(!is_user_bot(id))
		return FMRES_IGNORED;

	new Float:fMaxHealth, Float:fHealth;
	pev(id, pev_max_health, fMaxHealth);
	pev(id, pev_health, fHealth);

	if(fHealth / fMaxHealth < 0.3 && fNextCanUse[id] <= fCurTime && CanUseSkill2(id))
		UseSkill(id);

	if(fHealth / fMaxHealth < 0.2 && fNextCanUse2[id] <= fCurTime && CanUseSkill(id))
		UseSkill2(id);

	return FMRES_IGNORED;
}


public fw_ClientCommand(id)
{
	static szCommand[24];
	read_argv(0, szCommand, charsmax(szCommand));

	if(iClass != bte_zb3_get_user_zombie_class(id) || bte_get_user_zombie(id) != 1) return FMRES_IGNORED;
	if(pev(id, pev_deadflag) != DEAD_NO) return FMRES_IGNORED;

	if(!strcmp(szCommand, "BTE_ZombieSkill1") && CanUseSkill2(id))
	{
		new Float:fCurTime;
		global_get(glb_time, fCurTime);

		if(fNextCanUse[id] > fCurTime)
		{
			//client_print(id, print_center, "%L", LANG_PLAYER, "BTE_ZB3_ZOMBIE_SKILL_WAIT", floatround(fNextCanUse[id] - fCurTime), sSkillsName);
			new szNumber[4];
			format(szNumber, 3, "%i", floatround(fNextCanUse[id] - get_gametime()))
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_WaitSkillCoolTime", szNumber);
			return FMRES_SUPERCEDE;
		}

		UseSkill(id);
		return FMRES_SUPERCEDE;
	}

	if(!strcmp(szCommand, "BTE_ZombieSkill2") && CanUseSkill(id))
	{
		new Float:fCurTime;
		global_get(glb_time, fCurTime);

		if(fNextCanUse2[id] > fCurTime)
		{
			//client_print(id, print_center, "%L", LANG_PLAYER, "BTE_ZB3_ZOMBIE_SKILL_WAIT", floatround(fNextCanUse2[id] - fCurTime), sSkillsName2);
			new szNumber[4];
			format(szNumber, 3, "%i", floatround(fNextCanUse2[id] - get_gametime()))
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_WaitSkillCoolTime", szNumber);
			return FMRES_SUPERCEDE;
		}

		//UseSkill2(id);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

#if 0
public fw_TraceLine(Float:start[3], Float:end[3], conditions, id, trace)
{
	if(is_user_alive(id))
		return FMRES_IGNORED;

	static hit;
	hit = get_tr2(trace, TR_pHit);

	if(!pev_valid(hit))
		return FMRES_IGNORED;

	if(is_user_alive(hit))
	{
		if(iClass != bte_zb3_get_user_zombie_class(hit) || bte_get_user_zombie(hit) != 1)
			return FMRES_IGNORED;

		if(isSkilling[hit])
			set_tr2(trace, TR_iHitgroup, 0/*random_num(HIT_LEFTLEG, HIT_RIGHTLEG)*/);
	}
	return FMRES_IGNORED;
}
#endif

public Event_CurWeapon(id)
{
	if(get_user_weapon(id) == CSW_KNIFE) iCanUseSkill[id] = 1;
	else iCanUseSkill[id] = 0;
}

public HamF_Killed(id)
{
	if(iClass != bte_zb3_get_user_zombie_class(id) || bte_get_user_zombie(id) != 1)
		return HAM_IGNORED;

	set_pev(id, pev_effects, EF_NODRAW);

	new Float:vOrigin[3];
	pev(id, pev_origin, vOrigin);

	new iVictim = -1;
	while ((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, vOrigin, fDeathKnockbackRadius)) != 0)
	{
		if(!is_user_alive(iVictim)) continue;
		if(iVictim == id) continue;
		if(get_pdata_int(iVictim, m_iTeam) == get_pdata_int(id, m_iTeam)) continue;
		if(!IsDirect(id, iVictim)) continue;

		CreateKnockBack(id, iVictim, fDeathKnockback, fDeathKnockbackRadius, fDeathDamage);
		ScreenShake(iVictim);
	}

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord,vOrigin[0]);
	engfunc(EngFunc_WriteCoord,vOrigin[1]);
	engfunc(EngFunc_WriteCoord,vOrigin[2]);
	write_short(SprDeathA);
	write_byte(10);
	write_byte(255);
	message_end();

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord,vOrigin[0]);
	engfunc(EngFunc_WriteCoord,vOrigin[1]);
	engfunc(EngFunc_WriteCoord,vOrigin[2]);
	write_short(SprDeathB);
	write_byte(10);
	write_byte(255);
	message_end();

	new iEnt;
	new Float:fCurTime;
	new iLevel = bte_zb3_get_user_level(id);
	global_get(glb_time, fCurTime);

	iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));

	set_pev(iEnt, pev_classname, "boomer_exp");
	set_pev(iEnt, pev_solid, SOLID_NOT);
	set_pev(iEnt, pev_movetype, MOVETYPE_TOSS);
	set_pev(iEnt, pev_sequence, 0);
	set_pev(iEnt, pev_framerate, 1.0);
	engfunc(EngFunc_SetModel, iEnt, sModelExpA);
	set_pev(iEnt, pev_origin, vOrigin);
	engfunc(EngFunc_DropToFloor, iEnt);
	set_pev(iEnt, pev_nextthink, fCurTime + 3.0);

	iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));

	set_pev(iEnt, pev_classname, "boomer_exp");
	set_pev(iEnt, pev_solid, SOLID_NOT);
	set_pev(iEnt, pev_movetype, MOVETYPE_TOSS);
	set_pev(iEnt, pev_sequence, 0);
	set_pev(iEnt, pev_framerate, 1.0);
	set_pev(iEnt, pev_body, iLevel>=2?0:1);
	engfunc(EngFunc_SetModel, iEnt, sModelExpB);
	set_pev(iEnt, pev_origin, vOrigin);
	engfunc(EngFunc_DropToFloor, iEnt);
	set_pev(iEnt, pev_nextthink, fCurTime + 2.0);

	return HAM_IGNORED;
}


public UseSkill(id)
{
	new Float:fMaxHealth, Float:fHealth;
	pev(id, pev_max_health, fMaxHealth);
	pev(id, pev_health, fHealth);
	
	if(fHealth > fMaxHealth * 0.5)
	{
		
		ClientPrint(id, HUD_PRINTCENTER, "#CSO_BoomerCannotHealNotLowerHealth");
		return;
	}
	
	new Float:fCurTime;
	global_get(glb_time, fCurTime);

	new iLevel = bte_zb3_get_user_level(id) - 1;

	fNextCanUse[id] = (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? fCoolDownTime[iLevel]*0.95 : fCoolDownTime[iLevel]) + fCurTime;


	//fHealth += fMaxHealth * fSkillHealHealth[iLevel] + fHealth;
	//fHealth += fSkillHealHealth[iLevel];
	fHealth += fMaxHealth * (bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN)?0.85:0.5);
	fHealth = fHealth>fMaxHealth?fMaxHealth:fHealth;

	set_pev(id, pev_health, fHealth);

	new Float:vOrigin[3];
	pev(id,pev_origin,vOrigin);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord,vOrigin[0]);
	engfunc(EngFunc_WriteCoord,vOrigin[1]);
	engfunc(EngFunc_WriteCoord,vOrigin[2] + 30.0);
	write_short(SprHeal);
	write_byte(10);
	write_byte(255);
	message_end();

	/*MH_ZB3UI(id,SKILL_ICON,1,3,floatround(fCoolDownTime[iLevel]));
	MH_DrawRetina(id,SKILL_RRTINA,1,1,0,2,1.5);*/

	MetahookMsg(id, 31, floatround(fCoolDownTime[iLevel] * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95 : 1.0)));

	engfunc(EngFunc_EmitSound, id, CHAN_AUTO, SoundSkillHeal, 1.0, ATTN_NORM, 0, PITCH_NORM);
}

public UseSkill2(id)
{
	new Float:fCurTime;
	global_get(glb_time, fCurTime);

	new iLevel = bte_zb3_get_user_level(id) - 1;

	isSkilling[id] = 1;

	SetRendering(id, kRenderFxGlowShell, 255, 3, 0, kRenderNormal, 0);

	fNextCanUse2[id] = fCoolDownTime2[iLevel] + fCurTime;
	bte_wpn_set_knockback(id, fSkillKnockback[iLevel]);
	bte_zb3_set_xdamage(id, fSkillXDamage[iLevel], iLevel);
	bte_zb3_set_next_restore_health(id, fSkillTime[iLevel]);
	fNextSkillRemove[id] = fCurTime + fSkillTime[iLevel];

	static pAct;
	pAct = get_pdata_cbase(id, m_pActiveItem);

	// 2.36 from model
	set_pdata_float(pAct, m_flNextPrimaryAttack, 2.36);
	set_pdata_float(pAct, m_flNextSecondaryAttack, 2.36);
	set_pdata_float(pAct, m_flTimeWeaponIdle, 2.36);



	/*MH_ZB3UI(id,SKILL_ICON2,2,3,floatround(fCoolDownTime2[iLevel]));
	MH_DrawRetina(id,SKILL_RRTINA2,1,0,1,1,fSkillTime[iLevel]);*/

	MetahookMsg(id, 32, floatround(fCoolDownTime2[iLevel]), floatround(fSkillTime[iLevel]));

	SendAnim(id, 2);
}

public Activate_ArmorRecovery(id)
{
	if(!is_user_alive(id)) 
		return PLUGIN_HANDLED

	if(iClass==bte_zb3_get_user_zombie_class(id) && bte_get_user_zombie(id)==1 && bte_zb3_can_use_skill(id))
	{
		new Float:flArmor
		pev(id, pev_armorvalue, flArmor)
		if (flArmor<=0.0) 
			return PLUGIN_HANDLED

		if(isSkilling[id])
		{
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_WaitSkillEnd");
			return PLUGIN_HANDLED
		}
		if (get_gametime() < g_flArCD[id])
		{
			//client_print(id, print_center, "%L", LANG_PLAYER, "BTE_ZB3_ZOMBIE_SKILL_WAIT", floatround(skill_use_time_next[id] - get_gametime()), skill_name)
			new szNumber[4];
			format(szNumber, 3, "%i", floatround(g_flArCD[id] - get_gametime()))
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_WaitSkillCoolTime", szNumber);
			return PLUGIN_HANDLED
		}
		if(floatround(flArmor) + 1 > bte_zb3_get_max_armor(id))
		{
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_CommonArmorUp_AlreadyMaxArmor");
			return PLUGIN_HANDLED
		}

		MetahookMsg(id, 49, floatround(c_flArWait));

		g_flArCD[id] = get_gametime() + c_flArWait
		
		emit_sound(id, CHAN_VOICE, c_szArSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		flArmor = floatmin(float(bte_zb3_get_max_health(id)), flArmor + c_flArAmount)
		
		set_pev(id,pev_armorvalue, flArmor)
		
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

LoadConfigFile()
{
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, "bte_zombieclass.ini")
	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
		set_fail_state(error)
		return;
	}
	new linedata[1024], key[64], value[960], section
	new file = fopen(path, "rt")
	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata))
		replace(linedata, charsmax(linedata), "^n", "")
		if (!linedata[0] || linedata[0] == ';') continue;
		if (equali(linedata, CONFIG_sName))
		{
			section = 1
			continue;
		}
		else if (linedata[0] == '[')
		{
			if (section)
			{
				section = 0
				return;
			}
			continue;
		}

		if (section)
		{
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
			trim(key)
			trim(value)
			if (equal(key, "NAME"))
				format(sName, charsmax(sName), "%s", value)
			else if (equal(key, "MODEL"))
				format(sModel, charsmax(sModel), "%s", value)
			else if (equal(key, "SET_MODELl_INDEX"))
				isModelIndex = str_to_num(value)
			else if (equal(key, "SEX"))
				iSex = str_to_num(value)
			else if (equal(key, "GRAVITY"))
				fGravity = str_to_float(value)
			else if (equal(key, "SPEED"))
				fSpeed = str_to_float(value)
			else if (equal(key, "XDAMAGE"))
				fXDamage[0] = str_to_float(value)
			else if (equal(key, "XDAMAGE2"))
				fXDamage[2] = fXDamage[1] = str_to_float(value)
			else if (equal(key, "KNOCK_BACK"))
				fKnockback = str_to_float(value)


			else if (equal(key, "SOUND_HURT1"))
				format(SoundHurt1, charsmax(SoundHurt1), "%s", value)
			else if (equal(key, "SOUND_HURT2"))
				format(SoundHurt2, charsmax(SoundHurt2), "%s", value)
			else if (equal(key, "SOUND_DEATH1"))
				format(SoundDeath1, charsmax(SoundDeath1), "%s", value)
			else if (equal(key, "SOUND_DEATH2"))
				format(SoundDeath2, charsmax(SoundDeath2), "%s", value)
			else if (equal(key, "SOUND_HEAL"))
				format(SoundHeal, charsmax(SoundHeal), "%s", value)
			else if (equal(key, "SOUND_EVOLUTION"))
				format(SoundEvolution, charsmax(SoundEvolution), "%s", value)

			else if (equal(key, "HEAL"))
				format(sSkillsName, charsmax(sSkillsName), "%s", value)
			else if (equal(key, "HEAL_SOUND"))
				format(SoundSkillHeal, charsmax(SoundSkillHeal), "%s", value)
			else if (equal(key, "HEAL_HEALTH"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fSkillHealHealth[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "HEAL_WAIT"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fCoolDownTime[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "HEAL_SPR_HEAD"))
				format(sSprHeal, charsmax(sSprHeal), "%s", value)


			else if (equal(key, "GUARD"))
				format(sSkillsName2, charsmax(sSkillsName2), "%s", value)
			else if (equal(key, "GUARD_WAIT"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fCoolDownTime2[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "GUARD_TIME"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fSkillTime[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "GUARD_KNOCK_BACK"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fSkillKnockback[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "GUARD_XDAMAGE"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fSkillXDamage[i] = str_to_float(key);
					i += 1;
				}
			}

			else if (equal(key, "DEATH_KNOCKBACK"))
				fDeathKnockback = str_to_float(value);

			else if (equal(key, "DEATH_KNOCKBACK_RADIUS"))
				fDeathKnockbackRadius = str_to_float(value);
			else if (equal(key, "DEATH_SPR_A"))
				format(sSprDeathA, charsmax(sSprDeathA), "%s", value)
			else if (equal(key, "DEATH_SPR_B"))
				format(sSprDeathB, charsmax(sSprDeathB), "%s", value)
			else if (equal(key, "DEATH_MODEL_GROUND"))
				format(sModelExpA, charsmax(sModelExpA), "%s", value)
			else if (equal(key, "DEATH_MODEL"))
				format(sModelExpB, charsmax(sModelExpB), "%s", value)
			else if (equal(key, "DEATH_DAMAGE"))
				fDeathDamage = str_to_float(value);
			else if (equal(key, "ARMORRECOVERY"))
				format(c_szArName, charsmax(c_szArName), "%s", value)
			else if (equal(key, "ARMORRECOVERY_WAIT"))
				c_flArWait = str_to_float(value)
			else if (equal(key, "ARMORRECOVERY_AMOUNT"))
				c_flArAmount = str_to_float(value)
			else if (equal(key, "ARMORRECOVERY_SOUND"))
				format(c_szArSound, charsmax(c_szArSound), "%s", value)

		}
		else continue;
	}
	if (file) fclose(file)
}

public bte_zb_infected(id, inf)
{
	isSkilling[id] = 0;
	if (iClass == bte_zb3_get_user_zombie_class(id))
	{
		if (inf)
		{
			fNextCanUse[id] = 0.0;
			fNextCanUse2[id] = 0.0;
			MetahookMsg(id, 30);
			//MH_SendZB3Data(id, 10, BOMMER_ZB)
		}
		else
		{
			fNextCanUse2[id] = 0.0;
			MetahookMsg(id, 33);
			//MH_SendZB3Data(id, 11, BOMMER_ZB)
		}
		/*MH_SendZB3Data(id,8,1)
		MH_SendZB3Data(id,9,1)
		MH_ZB3UI(id,ZMOBIE_TYPE,0,2,3)
		MH_ZB3UI(id,SKILL_ICON,1,2,3)
		MH_ZB3UI(id,SKILL_ICON2,2,2,3)
		MH_DrawRetina(id,SKILL_RRTINA,0,0,0,1,0.0)*/

	}

}

public bte_zb3_reset_skill(id)
{
	if (iClass == bte_zb3_get_user_zombie_class(id))
	{
		fNextCanUse[id] = 0.0;
		fNextCanUse2[id] = 0.0;
		MetahookMsg(id, 30);
	}
}

public plugin_natives()
{
	// for BTE_HumanSkill + BTE_Weapon2
	register_native("bte_zb3_is_boomer_skilling", "is_skilling", 1);
}

public is_skilling(id)
{
	return isSkilling[id];
}



stock IsDirect(id,id2)
{
	new Float:v1[3], Float:v2[3];
	pev(id, pev_origin, v1);
	pev(id2, pev_origin, v2);

	new Float:hit_origin[3];
	new tr;

	engfunc(EngFunc_TraceLine, v1, v2, 1, -1, tr);
	get_tr2(tr, TR_vecEndPos, hit_origin);

	if (!vector_distance(hit_origin, v2)) return 1;
	return 0;
}

stock CreateKnockBack(iAttacker, iVictim, Float:fMulti, Float:fRadius, Float:fMaxDamage)
{
	new Float:vVictim[3], Float:vAttacker[3];
	pev(iVictim, pev_origin, vVictim);
	pev(iAttacker, pev_origin, vAttacker);

	new Float:vVelocity[3];
	pev(iVictim, pev_velocity, vVelocity);
	vVictim[2] -= 1.0;

	xs_vec_sub(vVictim, vAttacker, vVictim);
	xs_vec_normalize(vVictim, vVictim);

	new Float:fDistance;
	fDistance = xs_vec_len(vVictim);

	new Float:fDamage;
	fDamage = (fRadius - fDistance) / fRadius * fMaxDamage;
	fDamage = fDamage < 1.0 ? 1.0 : fDamage;
	ExecuteHam(Ham_TakeDamage, iVictim, 0, iAttacker, fDamage, DMG_EXPLOSION);

	xs_vec_mul_scalar(vVictim, fMulti, vVictim);

	xs_vec_add(vVelocity, vVictim, vVelocity);

	set_pev(iVictim, pev_velocity, vVictim/*vVelocity*/);
}

stock SendAnim(id,iAnim)
{
	if(!is_user_alive(id)) return;

	set_pev(id, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(iAnim)
	write_byte(pev(id, pev_body))
	message_end()
}

stock ScreenShake(id, amplitude = 8, duration = 6, frequency = 18)
{
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
	write_short((1<<12)*amplitude)
	write_short((1<<12)*duration)
	write_short((1<<12)*frequency)
	message_end()
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


stock ClientPrint(id, type, message[], str1[] = "", str2[] = "", str3[] = "", str4[] = "")
{
	static msgTextMsg;
	if(!msgTextMsg) 
		msgTextMsg = get_user_msgid("TextMsg");
	
	new dest
	if (id) dest = MSG_ONE_UNRELIABLE
	else dest = MSG_ALL

	message_begin(dest, msgTextMsg, {0, 0, 0}, id)
	write_byte(type)
	write_string(message)

	if (str1[0])
		write_string(str1)
	if (str2[0])
		write_string(str2)
	if (str3[0])
		write_string(str3)
	if (str4[0])
		write_string(str4)

	message_end()
}