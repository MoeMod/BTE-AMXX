#define PLUGIN "BTE China Zombie"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define CONFIG_NAME		"[China Zombie]"

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>

#include "metahook.inc"
#include "BTE_API.inc"
#include "BTE_zb3.inc"
#include "cdll_dll.h"

#define	m_pActiveItem	373
#define	m_iId			43

#define CANNOT			0
#define CANUSE			1

new iClass;
new szName[32], szModel[32], szSkillName[32], SoundDeath1[64],SoundDeath2[64], SoundHurt1[64],SoundHurt2[64], SoundHeal[64], SoundEvolution[64];
new SoundJump[64], SoundSkillStart[64];
new Array:SoundSkillHeartBeat;

new Float:fGravity, Float:fSpeed, Float:fXDamage[3], Float:fKnockback;
new iModelIndex, iSex;
new Float:fCoolDownTime[3], Float:fSkillTime[3];

new Float:fSkillSpeed[3], Float:fSkillKnockback[3], Float:fSkillDamage[3], Float:fSkillXDamage[3], Float:fSkillGravity[3];

new Float:fNextCanUse[33];
new Float:fNextSkillRemove[33];

new c_szSrName[64], c_szSrSound[64], Float:c_flSrAmount, Float:c_flSrWait
new Float:g_flSrCD[33]

new Float:fNextSkillSoundCanPlay[33];
new Float:fNextJumpSoundCanPlay[33];

native MetahookMsg(id, type, i2 = -1, i3 = -1)

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_forward(FM_ClientCommand, "fw_ClientCommand");
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink", 1);

	RegisterHam(Ham_Player_Jump, "player", "HamF_Player_Jump", 0);
	register_clcmd("BTE_ZombieSkill2", "Activate_StrengthenRecovery")
}

public HamF_Player_Jump(id)
{
	if(iClass != bte_zb3_get_user_zombie_class(id) || bte_get_user_zombie(id) != 1) return HAM_IGNORED;

	new Float:fCurTime;
	global_get(glb_time, fCurTime);

	if(fNextJumpSoundCanPlay[id] > fCurTime) return HAM_IGNORED;

	new iFlag = pev(id,pev_flags);

	if(!(iFlag & FL_ONGROUND))
	{
		fNextJumpSoundCanPlay[id] = fCurTime + 0.7;
		engfunc(EngFunc_EmitSound, id, CHAN_AUTO, SoundJump, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}

	return HAM_IGNORED;
}

public plugin_precache()
{
	SoundSkillHeartBeat = ArrayCreate(64, 1);

	LoadConfigFile();
	iClass = bte_zb3_register_zombie_class(szName, szModel, fGravity, fSpeed, fKnockback, SoundDeath1, SoundDeath2, SoundHurt1, SoundHurt2, SoundHeal, SoundEvolution, iSex, iModelIndex , fXDamage[0], fXDamage[1])

	engfunc(EngFunc_PrecacheSound, SoundJump);
	engfunc(EngFunc_PrecacheSound, SoundSkillStart);

	new buffer[64];
	for (new i = 0; i < ArraySize(SoundSkillHeartBeat); i++)
	{
		ArrayGetString(SoundSkillHeartBeat, i, buffer, charsmax(buffer));
		engfunc(EngFunc_PrecacheSound, buffer);
	}

}

public bte_zb_infected(id,inf)
{
	if(iClass==bte_zb3_get_user_zombie_class(id))
	{
		MetahookMsg(id, 28);
		//MH_SendZB3Data(id,10,CHINA_ZB)
		/*MH_SendZB3Data(id,8,1)
		MH_SendZB3Data(id,9,0)
		MH_ZB3UI(id,ZMOBIE_TYPE,0,2,3)
		MH_ZB3UI(id,SKILL_ICON,1,2,3)
		MH_DrawRetina(id,SKILL_RRTINA,0,0,0,1,0.0)*/
		fNextCanUse[id] = 0.0;
		g_flSrCD[id] = 0.0;
		fNextJumpSoundCanPlay[id] = 0.0;
		fNextSkillSoundCanPlay[id] = 0.0;
	}

}

public bte_zb3_reset_skill(id)
{
	if(iClass==bte_zb3_get_user_zombie_class(id))
	{
		MetahookMsg(id, 28);
		//MH_SendZB3Data(id,10,CHINA_ZB)
		/*MH_SendZB3Data(id,8,1)
		MH_SendZB3Data(id,9,0)
		MH_ZB3UI(id,ZMOBIE_TYPE,0,2,3)
		MH_ZB3UI(id,SKILL_ICON,1,2,3)
		MH_DrawRetina(id,SKILL_RRTINA,0,0,0,1,0.0)*/
		g_flSrCD[id] = 0.0;
		fNextCanUse[id] = 0.0;
	}
}

public fw_PlayerPostThink(id)
{
	if (!pev_valid(id))
		return FMRES_IGNORED;

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
		bte_zb3_reset_zombie_property(id);


		SetFov(id);
		SetRendering(id);
		fNextSkillRemove[id] = 0.0;
		fNextSkillSoundCanPlay[id] = 0.0;
	}

	if(fNextSkillSoundCanPlay[id] <= fCurTime && fNextSkillSoundCanPlay[id])
	{
		fNextSkillSoundCanPlay[id] = fCurTime + 2.0;

		new szSound[64];
		ArrayGetString(SoundSkillHeartBeat, random(ArraySize(SoundSkillHeartBeat)), szSound, charsmax(szSound));
		engfunc(EngFunc_EmitSound, id, CHAN_AUTO, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}

	if(!is_user_bot(id))
		return FMRES_IGNORED;

	if(fNextCanUse[id] <= fCurTime && bte_zb3_can_use_skill(id))
		UseSkill(id);

	return FMRES_IGNORED;
}


public fw_ClientCommand(id)
{
	if (!pev_valid(id))
		return FMRES_IGNORED;

	static szCommand[24];
	read_argv(0, szCommand, charsmax(szCommand));

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

public UseSkill(id)
{
	new Float:fCurTime;
	global_get(glb_time, fCurTime);

	new iLevel = bte_zb3_get_user_level(id) - 1;

	new Float:fHealth;
	pev(id, pev_health, fHealth);
	fHealth -= fSkillDamage[iLevel];
	if(fHealth < 1) return;

	set_pev(id, pev_health, fHealth);
	SetFov(id, 110);
	//bte_wpn_set_maxspeed2(id, fSkillSpeed[iLevel], fSkillTime[iLevel]);
	bte_zb3_set_max_speed(id, fSkillSpeed[iLevel]);
	bte_wpn_set_knockback(id, fSkillKnockback[iLevel])
	SetRendering(id, kRenderFxGlowShell, 255, 3, 0, kRenderNormal, 0);
	bte_zb3_set_xdamage(id, fSkillXDamage[iLevel], iLevel);
	bte_zb3_set_next_restore_health(id, fSkillTime[iLevel]);
	bte_wpn_set_vm(id, 0.75);
	set_pev(id, pev_gravity, fSkillGravity[iLevel]);

	fNextSkillRemove[id] = fSkillTime[iLevel] * (bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN) ? 1.35:1.0) + fCurTime;
	fNextCanUse[id] = fCoolDownTime[iLevel] * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95 : 1.0) + fCurTime;
	/*MH_ZB3UI(id,SKILL_ICON,1,3,floatround(fCoolDownTime[iLevel]));
	MH_DrawRetina(id,SKILL_RRTINA,1,1,1,1,fSkillTime[iLevel]);*/

	MetahookMsg(id, 29, floatround(fCoolDownTime[iLevel] * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95 : 1.0)), floatround(fSkillTime[iLevel] * (bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN) ? 1.35:1.0)));

	engfunc(EngFunc_EmitSound, id, CHAN_AUTO, SoundSkillStart, 1.0, ATTN_NORM, 0, PITCH_NORM);

	fNextSkillSoundCanPlay[id] = fCurTime + 2.0;
}

public Activate_StrengthenRecovery(id)
{
	if(!is_user_alive(id)) 
		return PLUGIN_HANDLED

	if(iClass==bte_zb3_get_user_zombie_class(id) && bte_get_user_zombie(id)==1 && bte_zb3_can_use_skill(id))
	{
		new Float:flHealth
		pev(id, pev_health, flHealth)
		if (flHealth<=0.0) 
			return PLUGIN_HANDLED

		if(get_gametime()<fNextSkillRemove[id])
		{
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_WaitSkillEnd");
			return PLUGIN_HANDLED
		}
		if (get_gametime() < g_flSrCD[id])
		{
			//client_print(id, print_center, "%L", LANG_PLAYER, "BTE_ZB3_ZOMBIE_SKILL_WAIT", floatround(skill_use_time_next[id] - get_gametime()), skill_name)
			new szNumber[4];
			format(szNumber, 3, "%i", floatround(g_flSrCD[id] - get_gametime()))
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_WaitSkillCoolTime", szNumber);
			return PLUGIN_HANDLED
		}
		if(floatround(flHealth) + 1 > bte_zb3_get_max_health(id))
		{
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_CommonArmorUp_AlreadyMaxHealth");
			return PLUGIN_HANDLED
		}

		MetahookMsg(id, 48, floatround(c_flSrWait));

		g_flSrCD[id] = get_gametime() + c_flSrWait
		
		emit_sound(id, CHAN_VOICE, c_szSrSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		flHealth = floatmin(float(bte_zb3_get_max_health(id)), flHealth + c_flSrAmount)
		
		set_pev(id,pev_health, flHealth)
		
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

			else if (equal(key, "STIFFEN"))
				format(szSkillName, charsmax(szSkillName), "%s", value)
			else if (equal(key, "STIFFEN_WAIT"))
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
			else if (equal(key, "STIFFEN_SPEED"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fSkillSpeed[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "STIFFEN_KNOCK_BACK"))
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
			else if (equal(key, "STIFFEN_XDAMAGE"))
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
			else if (equal(key, "STIFFEN_GRAVITY"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fSkillGravity[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "STIFFEN_TIME"))
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
			else if (equal(key, "STIFFEN_HEALTH"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					fSkillDamage[i] = str_to_float(key);
					i += 1;
				}
			}

			else if (equal(key, "STIFFEN_SOUND_START"))
				format(SoundSkillStart, charsmax(SoundSkillStart), "%s", value)

			else if (equal(key, "STIFFEN_SOUND_HEARTBEAT"))
			{
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					ArrayPushString(SoundSkillHeartBeat, key)
				}
			}
			else if (equal(key, "STRENGTHENRECOVERY"))
				format(c_szSrName, charsmax(c_szSrName), "%s", value)
			else if (equal(key, "STRENGTHENRECOVERY_WAIT"))
				c_flSrWait = str_to_float(value)
			else if (equal(key, "STRENGTHENRECOVERY_AMOUNT"))
				c_flSrAmount = str_to_float(value)
			else if (equal(key, "STRENGTHENRECOVERY_SOUND"))
				format(c_szSrSound, charsmax(c_szSrSound), "%s", value)

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

			else if (equal(key, "SOUND_JUMP"))
				format(SoundJump, charsmax(SoundJump), "%s", value)
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

SetFov(id, fov = 90)
{
	message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, id)
	write_byte(fov)
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