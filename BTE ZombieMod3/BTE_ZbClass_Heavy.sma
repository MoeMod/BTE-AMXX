#define PLUGIN "BTE Heavy Zombie"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define CONFIG_NAME	  "[Heavy Zombie]"

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#include "metahook.inc"
#include "BTE_API.inc"
#include "BTE_zb3.inc"
#include "cdll_dll.h"

#define	m_pActiveItem	373
#define	m_iId			43

new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame

new g_msgScreenShake;

new iClass;
new Float:fCoolDownTime[3], Float:fTrapTime[3], Float:fTrapDeath[3], iAlpha[3], iMaxTrap[3];
new szName[32], szModel[32], szSkillName[32], szSoundDeath1[64],szSoundDeath2[64], szSoundHurt1[64],szSoundHurt2[64], szSoundHeal[64], szSoundEvolution[64];
new szSoundTrapMale[64], szSoundTrapFemale[64], szSoundTrap[64];
new szTrapModel[64];
new Float:fMins[3], Float:fMaxs[3];
new iModelIndex, iSex;
new Float:fGravity, Float:fSpeed, Float:fXDamage[3], Float:fKnockback;
new Float:fNextCanUse[33], iTrapTotal[33];
new isTraped[33]

new c_szArName[64], c_szArSound[64], Float:c_flArAmount, Float:c_flArWait
new Float:g_flArCD[33]

native MetahookMsg(id, type, i2 = -1, i3 = -1)

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_event("HLTV","Event_HLTV","a","1=0","2=0")
	register_forward(FM_ClientCommand, "fw_ClientCommand");
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink", 1)

	RegisterHam(Ham_Touch, "info_target", "HamF_Touch");
	RegisterHam(Ham_Think, "info_target", "HamF_Think");

	g_msgScreenShake = get_user_msgid("ScreenShake");
	register_clcmd("BTE_ZombieSkill2", "Activate_ArmorRecovery")

}

public plugin_natives()
{
	register_native("is_heavy_zombie", "aaa", 1);
}

public aaa(id)
{
	return bte_zb3_get_user_zombie_class(id) == iClass;
}
public plugin_precache()
{
	LoadConfigFile();
	iClass = bte_zb3_register_zombie_class(szName, szModel, fGravity, fSpeed, fKnockback, szSoundDeath1, szSoundDeath2, szSoundHurt1, szSoundHurt2, szSoundHeal, szSoundEvolution, iSex, iModelIndex , fXDamage[0], fXDamage[1])

	engfunc(EngFunc_PrecacheModel, szTrapModel);
	engfunc(EngFunc_PrecacheSound, szSoundTrapMale);
	engfunc(EngFunc_PrecacheSound, szSoundTrapFemale);
	engfunc(EngFunc_PrecacheSound, szSoundTrap);

}

public bte_zb_infected(id,inf)
{
	isTraped[id] = 0;
	if (iClass == bte_zb3_get_user_zombie_class(id))
	{
		MetahookMsg(id, 22);
		//MH_SendZB3Data(id,10,HEAVY_ZB)
		/*MH_SendZB3Data(id,8,1)
		MH_SendZB3Data(id,9,0)
		MH_ZB3UI(id,ZMOBIE_TYPE,0,2,3)
		MH_ZB3UI(id,SKILL_ICON,1,2,3)
		MH_DrawRetina(id,SKILL_RRTINA,0,0,0,1,0.0)*/
		fNextCanUse[id] = 0.0;
		g_flArCD[id] = 0.0;
	}

}

public bte_zb3_reset_skill(id)
{
	if (iClass == bte_zb3_get_user_zombie_class(id))
	{
		MetahookMsg(id, 22);
		fNextCanUse[id] = 0.0;
		g_flArCD[id] = 0.0;
	}
}

public fw_PlayerPostThink(id)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED;

	if(isTraped[id] && bte_get_user_zombie(id) != 1)
	{
		set_pev(id, pev_maxspeed, 1.0);
		set_pev(id, pev_velocity, {0.0, 0.0, -200.0});
		return FMRES_IGNORED;
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

	if(fNextCanUse[id] <= fCurTime)
		UseSkill(id);

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
	for(new i=1; i<33 ;i++)
	{
		iTrapTotal[i] = 0;
		isTraped[i] = 0;
		g_flArCD[i] = 0.0;
	}

	new ent = -1
	while((ent = engfunc( EngFunc_FindEntityByString, ent, "classname", "zombie_trap"))) engfunc( EngFunc_RemoveEntity, ent );
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

public UseSkill(id)
{
	new Float:fCurTime;
	global_get(glb_time, fCurTime);

	new iLevel = bte_zb3_get_user_level(id) - 1;

	if(iTrapTotal[id] > iMaxTrap[iLevel])
	{
		//client_print(id, print_center, "%L", LANG_PLAYER, "BTE_ZB3_ZOMBIE_SKILL_TRAP_MAX", iMaxTrap[iLevel]);
		return;
	}

	fNextCanUse[id] = fCoolDownTime[iLevel] * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95:1.0) + fCurTime;

	MetahookMsg(id, 23, floatround(fCoolDownTime[iLevel] * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95:1.0)))
	/*MH_ZB3UI(id,SKILL_ICON,1,3,floatround(fCoolDownTime[iLevel]));
	MH_DrawRetina(id,SKILL_RRTINA,1,0,1,1,1.0);*/

	new Float:vOrigin[3];
	pev(id, pev_origin, vOrigin);

	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if (!iEntity) return;

	set_pev(iEntity, pev_classname, "zombie_trap");
	set_pev(iEntity, pev_solid, SOLID_TRIGGER)
	set_pev(iEntity, pev_movetype, MOVETYPE_PUSHSTEP)
	set_pev(iEntity, pev_maxspeed, 30.0)
	set_pev(iEntity, pev_gravity, 800.0)
	set_pev(iEntity, pev_owner, id);
	set_pev(iEntity, pev_sequence, 0);
	set_pev(iEntity, pev_framerate, 1.0);

	set_pev(iEntity, pev_fuser1, fCurTime + fTrapDeath[iLevel]);
	set_pev(iEntity, pev_nextthink, fCurTime + 0.5);

	engfunc(EngFunc_SetSize, iEntity, fMins, fMaxs);
	engfunc(EngFunc_SetModel, iEntity, szTrapModel);
	set_pev(iEntity, pev_origin, vOrigin);

	SetRendering(iEntity, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, iAlpha[iLevel]);

	engfunc(EngFunc_EmitSound, id, CHAN_AUTO, szSoundTrap, 1.0, ATTN_NORM, 0, PITCH_NORM);

}

native MH_DrawFollowIcon(id, name[], pos_x, pos_y, pos_z, a, B, c, r, g, b)

public HamF_Touch(iEntity, pHit)
{
	if (!pev_valid(iEntity)) 
		return HAM_IGNORED;
	
	static szClassname[33]; pev(iEntity, pev_classname, szClassname, charsmax(szClassname))
	if(strcmp(szClassname, "zombie_trap"))
		return HAM_IGNORED;
		
	if(pev(iEntity, pev_iuser2))
	{
		return HAM_IGNORED
	}
	if(!is_user_alive(pHit) || bte_get_user_zombie(pHit) == 1)
	{
		return HAM_IGNORED
	}
	
	set_pev(iEntity, pev_iuser2, pHit)
	set_pev(iEntity, pev_rendermode, kRenderNormal)
	set_pev(iEntity, pev_renderamt, 255.0)
	
	if(pev(iEntity, pev_sequence) != 1)
	{
		set_pev(iEntity, pev_animtime, get_gametime());
		set_pev(iEntity, pev_sequence, 1);
	}
	
	set_pev(iEntity, pev_frame, 0.0)
	set_pev(iEntity, pev_framerate, 1.0)
	
	isTraped[pHit] = 1;
	ScreenShake(pHit);
	
	new Float:vecVelocity[3];
	pev(pHit, pev_velocity, vecVelocity);
	vecVelocity[0] = vecVelocity[1] = 0.0;
	set_pev(pHit, pev_velocity, vecVelocity);
	
	new iOwner = pev(iEntity, pev_owner);
	new iLevel = bte_zb3_get_user_level(iOwner) - 1;
	
	set_pev(iEntity, pev_nextthink, get_gametime() + fTrapTime[iLevel] * (bte_zb3_dna_get(iOwner, DNA_SKILL_STRENGTHEN) ? 1.325:1.0));
	set_pev(iEntity, pev_fuser1, get_gametime() + fTrapTime[iLevel] * (bte_zb3_dna_get(iOwner, DNA_SKILL_STRENGTHEN) ? 1.325:1.0));
	
	new Float:vecOrigin[3], Float:vecTarget[3]
	pev(iEntity, pev_origin, vecOrigin)
	pev(pHit, pev_origin, vecTarget)
	vecOrigin[0] = vecTarget[0]
	vecOrigin[1] = vecTarget[1]
	set_pev(iEntity, pev_origin, vecOrigin)
	
	SetRendering(iEntity, kRenderFxNone, 255, 255, 255, kRenderNormal);

	new iHumanSex = bte_get_user_sex(pHit);
	if(iHumanSex == SEX_MALE)
		engfunc(EngFunc_EmitSound, pHit, CHAN_AUTO, szSoundTrapMale, 1.0, ATTN_NORM, 0, PITCH_NORM);
	else
		engfunc(EngFunc_EmitSound, pHit, CHAN_AUTO, szSoundTrapFemale, 1.0, ATTN_NORM, 0, PITCH_NORM);

	
	for(new i=1;i<33;i++)
	{
		if(!is_user_connected(i))
			continue;
		if(bte_get_user_zombie(i) != 1)
			continue;
		client_print(i, print_center, "#CSBTE_ZB3_HeavyZB_HumanTraped");
	}
	
	set_pev(iEntity, pev_iuser1, 2)
	set_pev(iEntity, pev_iuser4, 1)
	
	return HAM_IGNORED
}

public HamF_Think(iEntity)
{
	if (!pev_valid(iEntity)) 
		return HAM_IGNORED;

	static szClassname[33]; pev(iEntity, pev_classname, szClassname, charsmax(szClassname))
	if(strcmp(szClassname, "zombie_trap"))
		return HAM_IGNORED;

	new iTrapped = pev(iEntity, pev_iuser2);
	if(is_user_alive(iTrapped) && isTraped[iTrapped])
	{
		
		isTraped[iTrapped] = 0;

		if (is_user_alive(iTrapped))
		{
			ExecuteHamB(Ham_Player_ResetMaxSpeed, iTrapped);
			
		}

		set_pev(iEntity, pev_flags, pev(iEntity, pev_flags) | FL_KILLME);
	
		return HAM_IGNORED
	}
	
	if(!pev(iEntity, pev_iuser2))
	{
		new iTarget = FindNearestHuman(iEntity, 4096.0)
		
		static Float:vecOrigin[3], Float:vecTarget[3], Float:vecVelocity[3]
		pev(iEntity, pev_origin, vecOrigin)
		pev(iTarget, pev_origin, vecTarget)
		xs_vec_sub(vecTarget, vecOrigin, vecVelocity)
		xs_vec_normalize(vecVelocity, vecVelocity)
		xs_vec_mul_scalar(vecVelocity, 30.0, vecVelocity)
		vecVelocity[2] = 0.0
		set_pev(iEntity, pev_velocity, vecVelocity)
	}
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.1)
	
	
	return HAM_IGNORED;
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

			else if (equal(key, "TRAP"))
				format(szSkillName, charsmax(szSkillName), "%s", value)
			else if (equal(key, "TRAP_MAX"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					iMaxTrap[i] = str_to_num(key);
					i += 1;
				}
			}
			else if (equal(key, "TRAP_WAIT"))
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
			else if (equal(key, "TRAP_TIME"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fTrapTime[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "TRAP_TIME_DEATH"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fTrapDeath[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "TRAP_MODEL_ALPHA"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					iAlpha[i] = str_to_num(key);
					i += 1;
				}
			}

			else if (equal(key, "TRAP_MODEL_MINS"))
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
			else if (equal(key, "TRAP_MODEL_MAXS"))
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


			else if (equal(key, "TRAP_MODEL"))
				format(szTrapModel, charsmax(szTrapModel), "%s", value)

			else if (equal(key, "SOUND_TRAP"))
				format(szSoundTrap, charsmax(szSoundTrap), "%s", value)
			else if (equal(key, "SOUND_TRAP_MALE"))
				format(szSoundTrapMale, charsmax(szSoundTrapMale), "%s", value)
			else if (equal(key, "SOUND_TRAP_FEMALE"))
				format(szSoundTrapFemale, charsmax(szSoundTrapFemale), "%s", value)

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
		else continue;
	}
	if (file) fclose(file)
}

SetRendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
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

ScreenShake(id, amplitude = 8, duration = 6, frequency = 18)
{
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
	write_short((1<<12)*amplitude)
	write_short((1<<12)*duration)
	write_short((1<<12)*frequency)
	message_end()
}

stock FindNearestHuman(iEntity, Float:fMaxDistance)
{
	new Float:vOrigin[3], Float:vTargetOrigin[3], Float:fDistance, iTarget
	pev(iEntity, pev_origin, vOrigin)
	
	new i = -1
	while((i = engfunc(EngFunc_FindEntityInSphere, i, vOrigin, fMaxDistance)) > 0)
	{
		if(!is_user_alive(i))
			continue

		if(bte_get_user_zombie(i) == 1)
			continue
		
		pev(i, pev_origin, vTargetOrigin)

		if(i != GetTraceLineHit(iEntity, i, vOrigin, vTargetOrigin))
			continue
	
		fDistance = get_distance_f(vOrigin, vTargetOrigin)
		if(fDistance >= fMaxDistance)
			continue

		fMaxDistance = fDistance
		iTarget = i
	}

	return iTarget
}

stock GetTraceLineHit(iEntity, iTarget, Float:vEyeOrigin[3], Float:vTargetOrigin[3])
{
	new Float:vSize[3]
	pev(iTarget, pev_size, vSize)
	vTargetOrigin[2] -= vSize[2] / 2.0
	for(new i = 0; i < 2; i ++)
	{
		engfunc(EngFunc_TraceLine, vEyeOrigin, vTargetOrigin, DONT_IGNORE_MONSTERS, iEntity, 0)
		
		if(get_tr2(0, TR_pHit) == iTarget)
			return get_tr2(0, TR_pHit)
		
		vTargetOrigin[2] += vSize[2] / 2.0
	}

	return 0
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