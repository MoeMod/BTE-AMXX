#define PLUGIN "BTE UnderTaker Zombie"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define CONFIG_NAME      "[UnderTaker Zombie]"

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#include "metahook.inc"
#include "BTE_API.inc"
#include "BTE_zb3.inc"
#include "animation.inc"
#include "cdll_dll.h"

#define TASK_SKILL 998

stock m_flNextAttack = 83

//new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame

new g_msgScreenShake;

new iClass;
new Float:fCoolDownTime[3], Float:fPileTime[3];
new szName[32], szModel[32], szSkillName[32], szSoundDeath1[64],szSoundDeath2[64], szSoundHurt1[64],szSoundHurt2[64], szSoundHeal[64], szSoundEvolution[64];
new szSoundPile[64], szSoundPileExplode[64];
new szPileModel[64], szExplodeSpr[64];
new Float:fMins[3], Float:fMaxs[3];
new iModelIndex, iSex;
new Float:fGravity, Float:fSpeed, Float:fXDamage[3], Float:fKnockback;
new Float:fNextCanUse[33]
new g_bUsingSkill[33]

new c_szArName[64], c_szArSound[64], Float:c_flArAmount, Float:c_flArWait
new Float:g_flArCD[33]

new g_iPileIndex, g_iZombieBombExplo, g_iGibModel

native MetahookMsg(id, type, i2 = -1, i3 = -1)

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_event("HLTV","Event_HLTV","a","1=0","2=0")
	register_forward(FM_ClientCommand, "fw_ClientCommand");
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink", 1)

	RegisterHam(Ham_TraceAttack, "func_breakable", "HamF_TraceAttack")
	RegisterHam(Ham_TakeDamage, "func_breakable", "HamF_TakeDamage")
	RegisterHam(Ham_Think, "func_breakable", "HamF_Think");

	g_msgScreenShake = get_user_msgid("ScreenShake");
	
	register_clcmd("BTE_ZombieSkill2", "Activate_ArmorRecovery")

}

public plugin_precache()
{
	LoadConfigFile();
	iClass = bte_zb3_register_zombie_class(szName, szModel, fGravity, fSpeed, fKnockback, szSoundDeath1, szSoundDeath2, szSoundHurt1, szSoundHurt2, szSoundHeal, szSoundEvolution, iSex, iModelIndex , fXDamage[0], fXDamage[1])

	g_iPileIndex = engfunc(EngFunc_PrecacheModel, szPileModel);
	g_iZombieBombExplo = engfunc(EngFunc_PrecacheModel, szExplodeSpr)
	g_iGibModel = engfunc(EngFunc_PrecacheModel, "models/woodgibs.mdl")
	engfunc(EngFunc_PrecacheSound, szSoundPileExplode);
	engfunc(EngFunc_PrecacheSound, szSoundPile);

}

public bte_zb_infected(id,inf)
{
	g_bUsingSkill[id] = 0;
	if (iClass == bte_zb3_get_user_zombie_class(id))
	{
		bte_zb3_reset_skill(id)
	}
}

public bte_zb3_reset_skill(id)
{
	if (iClass == bte_zb3_get_user_zombie_class(id))
	{
		MetahookMsg(id, 44);
		fNextCanUse[id] = 0.0;
		g_flArCD[id] = 0.0;
	}
}

public fw_PlayerPostThink(id)
{
	if(pev(id, pev_deadflag) != DEAD_NO)
		return FMRES_IGNORED;

	if(g_bUsingSkill[id] && bte_get_user_zombie(id) == 1)
	{
		set_pev(id, pev_maxspeed, 1.0);
		set_pev(id, pev_velocity, {0.0, 0.0, -200.0});
	}

	// BOT USE SKILL
	if(bte_get_user_zombie(id) != 1)
		return FMRES_IGNORED;

	if(bte_zb3_get_user_zombie_class(id) != iClass)
		return FMRES_IGNORED;

	new Float:fCurTime;
	global_get(glb_time, fCurTime);

	if(!is_user_bot(id))
		return FMRES_IGNORED;

	// BUG Here?
	//if(fNextCanUse[id] <= fCurTime)
	//	UseSkill(id);

	return FMRES_IGNORED;
}


public fw_ClientCommand(id)
{
	static szCommand[24];
	read_argv(0, szCommand, charsmax(szCommand));

	if(pev(id, pev_deadflag) != DEAD_NO)
		return FMRES_IGNORED;

	if(iClass != bte_zb3_get_user_zombie_class(id) || bte_get_user_zombie(id) != 1)
		return FMRES_IGNORED;

	if(!bte_zb3_can_use_skill(id))
		return FMRES_IGNORED;

	if(!strcmp(szCommand, "BTE_ZombieSkill1"))
	{
		new Float:fCurTime;
		global_get(glb_time, fCurTime);

		if(fNextCanUse[id] > fCurTime)
		{
			//client_print(id, print_center, "%L", LANG_PLAYER, "BTE_ZB3_ZOMBIE_SKILL_WAIT", floatround(fNextCanUse[id] - fCurTime), szSkillName);
			new szNumber[4];
			format(szNumber, 3, "%i", floatround(fNextCanUse[id] - get_gametime()))
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_WaitSkillCoolTime", szNumber);
			return FMRES_SUPERCEDE;
		}

		UseSkill(id);
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public Event_HLTV()
{
	new pEntity = -1
	while((pEntity = engfunc( EngFunc_FindEntityByString, pEntity, "classname", "zombie_pile"))) 
		engfunc( EngFunc_RemoveEntity, pEntity );
	
	for (new id=1; id<33; id++)
	{
		if (!is_user_connected(id)) 
			continue;
		remove_task(id+TASK_SKILL)
		g_bUsingSkill[id] = 0;
	}
}

public UseSkill(id)
{
	if(g_bUsingSkill[id])
		return;
	if(pev(id, pev_flags) & FL_DUCKING)
		return;
	new Float:fCurTime;
	global_get(glb_time, fCurTime);

	new iLevel = bte_zb3_get_user_level(id) - 1;
	
	fNextCanUse[id] = fCoolDownTime[iLevel] * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95 : 1.0) + fCurTime;

	MetahookMsg(id, 45, floatround(fCoolDownTime[iLevel] * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95 : 1.0)))

	set_pdata_float(id, m_flNextAttack, 1.7)
	
	engclient_cmd(id, "weapon_knife");
	PlayAnimation(id, "skill1");
	SendWeaponAnim(id, 2)
		
	remove_task(id+TASK_SKILL)
	set_task(1.0, "Task_UsingSkill", id+TASK_SKILL)
	g_bUsingSkill[id] = 1
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

		/*if(task_exists(id+TASK_SKILL_REMOVE))
		{
			return PLUGIN_HANDLED
		}*/
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

public Task_UsingSkill(taskid)
{
	new id = taskid - TASK_SKILL
	if(!g_bUsingSkill[id])
		return
	CreatePile(id)
	g_bUsingSkill[id] = 0
}

public HamF_TraceAttack(pEntity, iAttacker, Float:flDamage, Float:vecDirection[3], pTr, bitsDamageType)
{
	if(!pev_valid(pEntity))
		return HAM_IGNORED;
	static szClassname[33]; pev(pEntity, pev_classname, szClassname, charsmax(szClassname))
	if(strcmp(szClassname, "zombie_pile"))
		return HAM_IGNORED;
    
	new Float:vecOrigin[3]
	get_tr2(pTr, TR_vecEndPos, vecOrigin)

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_SPARKS)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	message_end()
    
	return HAM_IGNORED;
}

public HamF_TakeDamage(pEntity, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if(!pev_valid(pEntity))
		return HAM_IGNORED;
	static szClassname[33]; pev(pEntity, pev_classname, szClassname, charsmax(szClassname))
	if(strcmp(szClassname, "zombie_pile"))
		return HAM_IGNORED;

	static Float:flHealth; pev(pEntity, pev_health, flHealth)
	if(flDamage >= flHealth)
	{
		PileExplode(pEntity)
		RemovePile(pEntity)
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED
}

public HamF_Think(pEntity)
{
	if(!pev_valid(pEntity))
		return HAM_IGNORED;
	static szClassname[33]; pev(pEntity, pev_classname, szClassname, charsmax(szClassname))
	if(strcmp(szClassname, "zombie_pile"))
	return HAM_IGNORED;

	RemovePile(pEntity)
	return HAM_IGNORED;
}

stock CreatePile(id)
{
	static Float:vecOrigin[3]; pev(id, pev_origin, vecOrigin)
	static Float:vecAngles[3]; pev(id, pev_angles, vecAngles)
	static Float:vecViewOfs[3]; pev(id, pev_view_ofs, vecViewOfs)
    
	vecAngles[0] = 0.0
	static Float:vecEnd[3]; pev(id, pev_angles, vecEnd)
	xs_vec_add(vecOrigin, vecViewOfs, vecOrigin)
	engfunc(EngFunc_MakeVectors, vecEnd)
	global_get(glb_v_forward, vecEnd)
	xs_vec_mul_scalar(vecEnd, 40.0, vecEnd)
	xs_vec_add(vecOrigin, vecEnd, vecEnd)

	new pEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_breakable"))
	if(!pev_valid(pEntity))
		return;
	set_pev(pEntity, pev_classname, "zombie_pile")
    
	engfunc(EngFunc_SetModel, pEntity, szPileModel)
	set_pev(pEntity, pev_modelindex, g_iPileIndex)
	
	engfunc(EngFunc_SetSize, pEntity, fMins, fMaxs)
	set_pev(pEntity, pev_body, (pev(id, pev_flags) & FL_DUCKING) ? 2:1)
	set_pev(pEntity, pev_skin, bte_zb3_get_user_level(id) ? 1:0)
	set_pev(pEntity, pev_movetype, MOVETYPE_TOSS)
	set_pev(pEntity, pev_solid, SOLID_BBOX)

	vecEnd[2] += 20.0
	set_pev(pEntity, pev_angles, vecAngles)
    
	engfunc(EngFunc_SetOrigin, pEntity, vecEnd)
	set_pev(pEntity, pev_gravity, 300.0)
	set_pev(pEntity, pev_gamestate, 0.0)
	set_pev(pEntity, pev_health, 1500.0)
	set_pev(pEntity, pev_takedamage, DAMAGE_YES)
    
	engfunc(EngFunc_EmitSound, pEntity, CHAN_AUTO, szSoundPile, 1.0, ATTN_NORM, 0, PITCH_NORM)
    
	set_pev(pEntity, pev_nextthink, get_gametime() + fPileTime[bte_zb3_get_user_level(id)])
    
	new ptr = create_tr2()
	engfunc(EngFunc_TraceToss, pEntity, pEntity, ptr)
	new pHit = get_tr2(ptr, TR_pHit)
	free_tr2(ptr)
    
	if(is_user_alive(pHit))
		RemovePile(pEntity)
	else
		FreezePile(pEntity)
        
}

stock FreezePile(pEntity)
{
    static Float:vecOrigin[3]; pev(pEntity, pev_origin, vecOrigin)
    new pEntity = -1
    while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, 200.0)) && pev_valid(pEntity))
    {
        if(!is_user_alive(pEntity) || bte_get_user_zombie(pEntity))
            continue;
        //z4h_set_zombie_slowdown(pEntity, 83.0, 5.0)
    }
}

stock PileExplode(pEntity)
{
	static Float:vecOrigin[3]; pev(pEntity, pev_origin, vecOrigin)
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	write_short(g_iZombieBombExplo)
	write_byte(35)
	write_byte(50)
	message_end()

	engfunc(EngFunc_EmitSound, pEntity, CHAN_AUTO, szSoundPileExplode, 1.0, ATTN_NORM, 0, PITCH_NORM)

	for (new id = 1; id < 33; id ++)
	{
		if (!is_user_connected(id))
			continue
		if (!is_user_alive(id))
		continue
		new Float:vecVictimOrigin[3]
		pev(id, pev_origin, vecVictimOrigin)
		new Float:flDistance = get_distance_f(vecOrigin, vecVictimOrigin)
		if (flDistance > 300.0)
			continue
		new Float:vecOldVelocity[3], Float:vecNewVelocity[3]
		pev(id, pev_velocity, vecOldVelocity)
        
		xs_vec_sub(vecVictimOrigin, vecOrigin, vecNewVelocity)
		xs_vec_mul_scalar(vecNewVelocity, bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN)?1.62:1.2, vecNewVelocity)
		xs_vec_add(vecOldVelocity, vecNewVelocity, vecNewVelocity)
		vecNewVelocity[2] += bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN)?405.0:300.0
		set_pev(id, pev_velocity, vecNewVelocity)
        
		message_begin(MSG_ONE, g_msgScreenShake, _, id)
		write_short((1<<12) * 4)
		write_short((1<<12) * 5)
		write_short((1<<12) * 10)
		message_end()
	}
}
stock RemovePile(pEntity)
{
	static Float:vecOrigin[3]; pev(pEntity, pev_origin, vecOrigin)
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BREAKMODEL)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	engfunc(EngFunc_WriteCoord, 0.5)
	engfunc(EngFunc_WriteCoord, 0.5)
	engfunc(EngFunc_WriteCoord, 0.5)
	engfunc(EngFunc_WriteCoord, random_float(-16.0,16.0))
	engfunc(EngFunc_WriteCoord, random_float(-16.0,16.0))
	engfunc(EngFunc_WriteCoord, random_float(-16.0,16.0))
	write_byte(10)
	write_short(g_iGibModel)
	write_byte(10)
	write_byte(25)
	write_byte(0x08)
	message_end()
	set_pev(pEntity, pev_flags, FL_KILLME)
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
		if (equali(linedata, CONFIG_NAME))
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
				format(szName, charsmax(szName), "%s", value)
			else if (equal(key, "MODEL"))
				format(szModel, charsmax(szModel), "%s", value)
			else if (equal(key, "SET_MODEL_INDEX"))
				iModelIndex = str_to_num(value)
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

			else if (equal(key, "PILE"))
				format(szSkillName, charsmax(szSkillName), "%s", value)
			else if (equal(key, "PILE_WAIT"))
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
			else if (equal(key, "PILE_TIME"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fPileTime[i] = str_to_float(key);
					i += 1;
				}
			}

			else if (equal(key, "PILE_MODEL_MINS"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fMins[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "PILE_MODEL_MAXS"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fMaxs[i] = str_to_float(key);
					i += 1;
				}
			}


			else if (equal(key, "PILE_MODEL"))
				format(szPileModel, charsmax(szPileModel), "%s", value)
			
			else if (equal(key, "EXPLODE_SPRITE"))
				format(szExplodeSpr, charsmax(szExplodeSpr), "%s", value)

			else if (equal(key, "SOUND_PILE"))
				format(szSoundPile, charsmax(szSoundPile), "%s", value)
			else if (equal(key, "SOUND_PILE_EXPLODE"))
				format(szSoundPileExplode, charsmax(szSoundPileExplode), "%s", value)

			else if (equal(key, "ARMORRECOVERY"))
				format(c_szArName, charsmax(c_szArName), "%s", value)
			else if (equal(key, "ARMORRECOVERY_WAIT"))
				c_flArWait = str_to_float(value)
			else if (equal(key, "ARMORRECOVERY_AMOUNT"))
				c_flArAmount = str_to_float(value)
			else if (equal(key, "ARMORRECOVERY_SOUND"))
				format(c_szArSound, charsmax(c_szArSound), "%s", value)
			
			else if (equal(key, "SOUND_HURT1"))
				format(szSoundHurt1, charsmax(szSoundHurt1), "%s", value)
			else if (equal(key, "SOUND_HURT2"))
				format(szSoundHurt2, charsmax(szSoundHurt2), "%s", value)
			else if (equal(key, "SOUND_DEATH1"))
				format(szSoundDeath1, charsmax(szSoundDeath1), "%s", value)
			else if (equal(key, "SOUND_DEATH2"))
				format(szSoundDeath2, charsmax(szSoundDeath2), "%s", value)
			else if (equal(key, "SOUND_HEAL"))
				format(szSoundHeal, charsmax(szSoundHeal), "%s", value)
			else if (equal(key, "SOUND_EVOLUTION"))
				format(szSoundEvolution, charsmax(szSoundEvolution), "%s", value)

		}
		else
			continue;
	}
	if (file)
		fclose(file)
}

stock SendWeaponAnim(id,iAnim)
{
	if(!is_user_alive(id)) return;

	set_pev(id, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(iAnim)
	write_byte(pev(id, pev_body))
	message_end()
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