#define PLUGIN "BTE Default Zombie"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define CONFIG_NAME      "[Default Zombie]"

#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>

#include "metahook.inc"
#include "BTE_API.inc"
#include "BTE_zb3.inc"
#include "cdll_dll.h"

new zombie_sound_heal[64], zombie_name[64], zombie_model[64], zombie_sex, zombie_modelindex, Float:zombie_gravity, Float:zombie_speed, Float:zombie_knockback, Float:zombie_xdamage[3],
zombie_sound_death1[64], zombie_sound_death2[64], zombie_sound_hurt1[64], zombie_sound_hurt2[64], zombie_sound_evolution[64]
new idclass

new Float:zombie_xdamage_inskill[3]
new skill_name[33],skill_dmg,Float:skill_speed
new Float:skill_timewait[3],Float:skill_time[3]
new Float:skill_use_time_next[33]
new g_skill_wait[33],g_inskill[33]

new c_szSrName[64], c_szSrSound[64], Float:c_flSrAmount, Float:c_flSrWait
new Float:g_flSrCD[33]

new Float:fSkillKnockback[3], Float:fSkillGravity[3];


new sound_fastrun_start[33]
new Array:sound_fastrun_heartbeat

enum (+= 100)
{
	TASK_SKILL = 2000,
	TASK_WAIT_SKILL,
	TASK_BOT_USE_SKILL,
	TASK_SKILL_REMOVE,
	TASK_FASTRUN_HEARTBEAT
}

#define ID_SKILL (iTask - TASK_SKILL)
#define ID_WAIT_SKILL (iTask - TASK_WAIT_SKILL)
#define ID_BOT_USE_SKILL (iTask - TASK_BOT_USE_SKILL)
#define ID_SKILL_REMOVE (iTask - TASK_SKILL_REMOVE)
#define ID_FASTRUN_HEARTBEAT (iTask - TASK_FASTRUN_HEARTBEAT)

native MetahookMsg(id, type, i2 = -1, i3 = -1)

public bte_zb_infected(id,inf)
{
	if (idclass == bte_zb3_get_user_zombie_class(id))
	{
		MetahookMsg(id, 18);
		ResetPlayerValue(id)
		//MH_SendZB3Data(id, 10, TANK_ZB)
		/*MH_SendZB3Data(id,8,1)
		MH_SendZB3Data(id,9,0)
		MH_ZB3UI(id,ZMOBIE_TYPE,0,2,3)
		MH_ZB3UI(id,SKILL_ICON,1,2,3)
		MH_DrawRetina(id,SKILL_RRTINA,0,0,0,1,0.0)*/
		
		g_skill_wait[id] = 0
		g_inskill[id] = 0
		g_flSrCD[id] = 0.0
	}
}

public bte_zb3_reset_skill(id)
{
	if (idclass == bte_zb3_get_user_zombie_class(id))
	{
		MetahookMsg(id, 18);
		
		//MH_DrawRetina(id,SKILL_RRTINA,0,0,1,1,0.0)
		g_skill_wait[id] = 0
		g_flSrCD[id] = 0.0
	}
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0")
	register_event("DeathMsg", "Event_DeathMsg", "a")

	register_clcmd("BTE_ZombieSkill1", "UseSkill")
	register_clcmd("BTE_ZombieSkill2", "Activate_StrengthenRecovery")
}

public plugin_precache()
{
	sound_fastrun_heartbeat = ArrayCreate(64, 1)

	load_customization_from_files()

	new i, buffer[100]
	for (i = 0; i < ArraySize(sound_fastrun_heartbeat); i++)
	{
		ArrayGetString(sound_fastrun_heartbeat, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	engfunc(EngFunc_PrecacheSound, sound_fastrun_start)

	idclass = bte_zb3_register_zombie_class(zombie_name, zombie_model, zombie_gravity, zombie_speed, zombie_knockback, zombie_sound_death1, zombie_sound_death2, zombie_sound_hurt1, zombie_sound_hurt2, zombie_sound_heal, zombie_sound_evolution, zombie_sex, zombie_modelindex ,zombie_xdamage[0], zombie_xdamage[1])
}

public Event_HLTV()
{
	for (new id=1; id<33; id++)
	{
		if (!is_user_connected(id)) continue;
		ResetPlayerValue(id)
	}
	for (new id=1; id<33; id++)
	{
		if (!is_user_connected(id)) continue;
		if (is_user_bot(id))
		{
			if (task_exists(id+TASK_BOT_USE_SKILL)) remove_task(id+TASK_BOT_USE_SKILL)
			set_task(float(20), "Task_BOT_UseSkill", id+TASK_BOT_USE_SKILL)
		}
		if (task_exists(id+TASK_SKILL)) remove_task(id+TASK_SKILL)
		if (task_exists(id+TASK_WAIT_SKILL)) remove_task(id+TASK_WAIT_SKILL)
		if (task_exists(id+TASK_SKILL_REMOVE)) remove_task(id+TASK_SKILL_REMOVE)
		if (task_exists(id+TASK_FASTRUN_HEARTBEAT)) remove_task(id+TASK_FASTRUN_HEARTBEAT)

	}
}

public Task_BOT_UseSkill(iTask)
{
	new id = ID_BOT_USE_SKILL
	if (!is_user_bot(id)) return;
	UseSkill(id)
	if (task_exists(iTask)) remove_task(iTask)
	set_task(float(random_num(5,15)), "Task_BOT_UseSkill", id+TASK_BOT_USE_SKILL)

}
public Event_DeathMsg()
{
	new victim = read_data(2)
	ResetPlayerValue(victim)
	//MH_DrawRetina(victim,SKILL_RRTINA,0,0,1,1,0.0)
}
public client_connect(id)
{
	ResetPlayerValue(id)
}

ResetPlayerValue(id)
{
	if (task_exists(id+TASK_BOT_USE_SKILL)) remove_task(id+TASK_BOT_USE_SKILL)
	if (task_exists(id+TASK_FASTRUN_HEARTBEAT)) remove_task(id+TASK_FASTRUN_HEARTBEAT)

	//MH_DrawRetina(id,SKILL_RRTINA,0,0,1,1,0.0)
	g_skill_wait[id] = 0
	g_inskill[id] = 0
	g_flSrCD[id] = 0.0
}
public Task_Skill_RemoveWait(iTask)
{
	new id = ID_WAIT_SKILL
	g_skill_wait[id] = 0

}
public Task_Skill_Remove(iTask)
{
	new id = ID_SKILL_REMOVE
	if(bte_get_user_zombie(id)==1)
	{
		bte_zb3_reset_zombie_property(id)
		SetFov(id)
		fm_set_rendering(id)
		g_inskill[id] = 0
	}
}
public Task_FastRunHeartBeat(iTask)
{
	new id = ID_FASTRUN_HEARTBEAT

	if (g_inskill[id])
	{
		new sound[64]
		ArrayGetString(sound_fastrun_heartbeat, random(ArraySize(sound_fastrun_heartbeat)), sound, charsmax(sound))
		emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	else if (task_exists(iTask)) remove_task(iTask)
}
public UseSkill(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	new health = get_user_health(id) - skill_dmg

	if(idclass==bte_zb3_get_user_zombie_class(id) && bte_get_user_zombie(id)==1 && bte_zb3_can_use_skill(id))
	{
		if (health<=0) return PLUGIN_HANDLED
		new level = bte_zb3_get_user_level(id) - 1

		if (g_skill_wait[id])
		{
			new szNumber[4];
			format(szNumber, 3, "%i", floatround(skill_use_time_next[id] - get_gametime()))
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_WaitSkillCoolTime", szNumber);
			return PLUGIN_HANDLED
		}

		MetahookMsg(id, 19, floatround(skill_timewait[level] * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95 : 1.0)), floatround(skill_time[level] * (bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN) ? 1.35:1.0)));

		/*MH_DrawRetina(id,SKILL_RRTINA,1,1,1,1,skill_time[level])
		MH_ZB3UI(id,SKILL_ICON,1,3,floatround(skill_timewait[level]))*/
		set_task(skill_timewait[level] * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95 : 1.0), "Task_Skill_RemoveWait", id+TASK_WAIT_SKILL)
		set_task(skill_time[level] * (bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN) ? 1.35:1.0), "Task_Skill_Remove", id+TASK_SKILL_REMOVE)
		skill_use_time_next[id] = get_gametime() + skill_timewait[level]
		bte_zb3_set_next_restore_health(id, skill_time[level] * (bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN) ? 1.35:1.0))
		g_skill_wait[id] = 1

		g_inskill[id] = 1
		emit_sound(id, CHAN_VOICE, sound_fastrun_start, 1.0, ATTN_NORM, 0, PITCH_NORM)
		fm_set_rendering(id, kRenderFxGlowShell, 255, 3, 0, kRenderNormal, 0)
		set_pev(id,pev_health,float(health))
		SetFov(id,110)
		set_pev(id, pev_gravity, fSkillGravity[level]);
		bte_zb3_set_max_speed(id,skill_speed * (bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN) ? 1.35:1.0))
		bte_wpn_set_knockback(id, fSkillKnockback[level]);
		bte_zb3_set_xdamage(id,zombie_xdamage[level]*zombie_xdamage_inskill[level],level)
		bte_wpn_set_vm(id, 0.8);

		if (task_exists(id+TASK_FASTRUN_HEARTBEAT)) remove_task(id+TASK_FASTRUN_HEARTBEAT)
		set_task(2.0, "Task_FastRunHeartBeat", id+TASK_FASTRUN_HEARTBEAT, _, _, "b")

		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}
SetFov(id, fov = 90)
{
	message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, id)
	write_byte(fov)
	message_end()
}

public Activate_StrengthenRecovery(id)
{
	if(!is_user_alive(id)) 
		return PLUGIN_HANDLED

	if(idclass==bte_zb3_get_user_zombie_class(id) && bte_get_user_zombie(id)==1 && bte_zb3_can_use_skill(id))
	{
		new Float:flHealth
		pev(id, pev_health, flHealth)
		if (flHealth<=0.0) 
			return PLUGIN_HANDLED

		if(task_exists(id+TASK_SKILL_REMOVE))
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

load_customization_from_files()
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
				format(zombie_name, charsmax(zombie_name), "%s", value)
			else if (equal(key, "MODEL"))
				format(zombie_model, charsmax(zombie_model), "%s", value)
			else if (equal(key, "SET_MODEL_INDEX"))
				zombie_modelindex = str_to_num(value)
			else if (equal(key, "SEX"))
				zombie_sex = str_to_num(value)
			else if (equal(key, "GRAVITY"))
				zombie_gravity = str_to_float(value)
			else if (equal(key, "SPEED"))
				zombie_speed = str_to_float(value)
			else if (equal(key, "XDAMAGE"))
				zombie_xdamage[0] = str_to_float(value)
			else if (equal(key, "XDAMAGE2"))
				zombie_xdamage[2] = zombie_xdamage[1] = str_to_float(value)
			else if (equal(key, "XDAMAGE_SKILL"))
				zombie_xdamage_inskill[0] = str_to_float(value)
			else if (equal(key, "XDAMAGE2_SKILL"))
				zombie_xdamage_inskill[2] = zombie_xdamage_inskill[1] = str_to_float(value)
			else if (equal(key, "KNOCK_BACK"))
				zombie_knockback = str_to_float(value)

			else if (equal(key, "FASTRUN"))
				format(skill_name, charsmax(skill_name), "%s", value)

			else if (equal(key, "FASTRUN_DAMAGE"))
				skill_dmg = str_to_num(value)
			else if (equal(key, "FASTRUN_SPEED"))
				skill_speed = str_to_float(value)

			else if (equal(key, "FASTRUN_TIME_LV1"))
				skill_time[0] = str_to_float(value)
			else if (equal(key, "FASTRUN_TIME_LV2"))
				skill_time[1] = str_to_float(value)
			else if (equal(key, "FASTRUN_TIME_LV3"))
				skill_time[2] = str_to_float(value)

			else if (equal(key, "FASTRUN_TIME_WAIT_LV1"))
				skill_timewait[0] = str_to_float(value)
			else if (equal(key, "FASTRUN_TIME_WAIT_LV2"))
				skill_timewait[1] = str_to_float(value)
			else if (equal(key, "FASTRUN_TIME_WAIT_LV3"))
				skill_timewait[2] = str_to_float(value)
			else if (equal(key, "FASTRUN_KNOCK_BACK"))
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
			else if (equal(key, "FASTRUN_GRAVITY"))
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

			else if (equal(key, "STRENGTHENRECOVERY"))
				format(c_szSrName, charsmax(c_szSrName), "%s", value)
			else if (equal(key, "STRENGTHENRECOVERY_WAIT"))
				c_flSrWait = str_to_float(value)
			else if (equal(key, "STRENGTHENRECOVERY_AMOUNT"))
				c_flSrAmount = str_to_float(value)
			else if (equal(key, "STRENGTHENRECOVERY_SOUND"))
				format(c_szSrSound, charsmax(c_szSrSound), "%s", value)
			
			else if (equal(key, "SOUND_HURT1"))
				format(zombie_sound_hurt1, charsmax(zombie_sound_hurt1), "%s", value)
			else if (equal(key, "SOUND_HURT2"))
				format(zombie_sound_hurt2, charsmax(zombie_sound_hurt2), "%s", value)
			else if (equal(key, "SOUND_DEATH1"))
				format(zombie_sound_death1, charsmax(zombie_sound_death1), "%s", value)
			else if (equal(key, "SOUND_DEATH2"))
				format(zombie_sound_death2, charsmax(zombie_sound_death2), "%s", value)
			else if (equal(key, "SOUND_HEAL"))
				format(zombie_sound_heal, charsmax(zombie_sound_heal), "%s", value)
			else if (equal(key, "SOUND_EVOLUTION"))
				format(zombie_sound_evolution, charsmax(zombie_sound_evolution), "%s", value)

			else if (equal(key, "SOUND_FASTRUN_START"))
				format(sound_fastrun_start, charsmax(sound_fastrun_start), "%s", value)
			else if (equal(key, "SOUND_FASTRUN_HEARTBEAT"))
			{
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					ArrayPushString(sound_fastrun_heartbeat, key)
				}
			}

		}
		else continue;
	}
	if (file) fclose(file)
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