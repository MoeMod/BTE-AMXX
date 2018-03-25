#define PLUGIN "BTE Heal Zombie"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define CONFIG_NAME      "[Heal Zombie]"

#define SKILL_RRTINA     "resource\\zombi\\zombiheal"

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#include "metahook.inc"
#include "BTE_API.inc"
#include "BTE_zb3.inc"
#include "cdll_dll.h"

new zombie_sound_heal[64], zombie_name[64], zombie_model[64], zombie_sex, zombie_modelindex, Float:zombie_gravity, Float:zombie_speed, Float:zombie_knockback, Float:zombie_xdamage[3],
zombie_sound_death1[64], zombie_sound_death2[64], zombie_sound_hurt1[64], zombie_sound_hurt2[64], zombie_sound_evolution[64]
new idclass

new Float:skill_heal_health[3], Float:skill_heal_armor[3], Float:skill_raduis
new Float:skill_timewait[3]
new Float:skill_use_time_next[33]
new g_skill_wait[33]
new skill_name[33], skill_sound[64] ,spr[64] ,spr_head[64]
new g_cache_spr, g_cache_spr_head

new c_szSrName[64], c_szSrSound[64], Float:c_flSrAmount, Float:c_flSrWait
new Float:g_flSrCD[33]

enum (+= 100)
{
	TASK_SKILL = 2000,
	TASK_WAIT_SKILL,
	TASK_BOT_USE_SKILL
}

#define ID_SKILL (iTask - TASK_SKILL)
#define ID_WAIT_SKILL (iTask - TASK_WAIT_SKILL)
#define ID_BOT_USE_SKILL (iTask - TASK_BOT_USE_SKILL)

native MetahookMsg(id, type, i2 = -1, i3 = -1)

#define PRINT(%1) client_print(1,print_chat,%1)

public bte_zb_infected(id,inf)
{
	if (idclass == bte_zb3_get_user_zombie_class(id))
	{
		MetahookMsg(id, 24);
		
		g_flSrCD[id] = 0.0;
		g_skill_wait[id] = 0;
		skill_use_time_next[id] = 0.0;
		//MH_SendZB3Data(id,10,HEAL_ZB)
		/*MH_SendZB3Data(id,8,1)
		MH_SendZB3Data(id,9,0)
		MH_ZB3UI(id,ZMOBIE_TYPE,0,2,3)
		MH_ZB3UI(id,SKILL_ICON,1,2,3)
		MH_DrawRetina(id,SKILL_RRTINA,0,0,0,1,0.0)*/
	}
}

public bte_zb3_reset_skill(id)
{
	if (idclass == bte_zb3_get_user_zombie_class(id))
	{
		MetahookMsg(id, 24);
		
		g_flSrCD[id] = 0.0;
		g_skill_wait[id] = 0;
		skill_use_time_next[id] = 0.0;
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
	load_customization_from_files()
	precache_sound(skill_sound)
	g_cache_spr = precache_model(spr)
	g_cache_spr_head = precache_model(spr_head)

	idclass = bte_zb3_register_zombie_class(zombie_name, zombie_model, zombie_gravity, zombie_speed, zombie_knockback, zombie_sound_death1, zombie_sound_death2, zombie_sound_hurt1, zombie_sound_hurt2, zombie_sound_heal, zombie_sound_evolution, zombie_sex, zombie_modelindex , zombie_xdamage[0], zombie_xdamage[1])
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
			set_task(float(25), "Task_BOT_UseSkill", id+TASK_BOT_USE_SKILL)
		}
		if (task_exists(id+TASK_SKILL)) remove_task(id+TASK_SKILL)
		if (task_exists(id+TASK_WAIT_SKILL)) remove_task(id+TASK_WAIT_SKILL)

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
	//MH_DrawRetina(id,SKILL_RRTINA,0,0,1,1,0.0)
	g_skill_wait[id] = 0
}
public Task_Skill_RemoveWait(iTask)
{
	new id = ID_WAIT_SKILL
	g_skill_wait[id] = 0

}

public UseSkill(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE

	if(idclass==bte_zb3_get_user_zombie_class(id) && bte_get_user_zombie(id)==1 && bte_zb3_can_use_skill(id))
	{
		new Float:health, Float:maxhealth, Float:newhealth
		new Float:armor, Float:maxarmor, Float:newarmor
		new Float:Ori[3], Float:vOri[3], Float:fDistance

		new level = bte_zb3_get_user_level(id) - 1

		if(g_skill_wait[id])
		{
			//client_print(id, print_center, "%L", LANG_PLAYER, "BTE_ZB3_ZOMBIE_SKILL_WAIT", floatround(skill_use_time_next[id] - get_gametime()), skill_name)
			return PLUGIN_HANDLED
		}

		MetahookMsg(id, 25, floatround(skill_timewait[level] * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95:1.0)));
		//MH_ZB3UI(id,SKILL_ICON,1,3,floatround(skill_timewait[level]))
		set_task(skill_timewait[level] * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95:1.0), "Task_Skill_RemoveWait", id+TASK_WAIT_SKILL)
		skill_use_time_next[id] = get_gametime() + skill_timewait[level] * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95:1.0)
		g_skill_wait[id] = 1

		new i = -1
		pev(id,pev_origin,Ori)
		while ((i = engfunc(EngFunc_FindEntityInSphere, i, Ori, skill_raduis * (bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN) ? 1.35:1.0))) != 0)
		{
			if (!pev_valid(i) || bte_get_user_zombie(i)!=1 || !is_user_alive(i)) continue;

			MH_DrawRetina(i,SKILL_RRTINA,1,1,0,2,1.5)
/*
			pev(i, pev_origin, vOri)
			fDistance = get_distance_f(Ori, vOri)
			if(fDistance>skill_raduis) continue;
*/
			maxhealth = float(bte_zb3_get_max_health(i))
			maxarmor= float(bte_zb3_get_max_armor(i))

			pev(i,pev_health,health)
			newhealth = health + maxhealth * skill_heal_health[level] * (bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN) ? 1.35:1.0)
			set_pev(i,pev_health,newhealth<maxhealth?newhealth:maxhealth)

			pev(i,pev_armorvalue,armor)
			newarmor = armor + skill_heal_armor[level]
			set_pev(i,pev_armorvalue,newarmor<maxarmor?newarmor:maxarmor)

			if(i==id) continue;

			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_SPRITE)
			write_coord(floatround(vOri[0]))
			write_coord(floatround(vOri[1]))
			write_coord(floatround(vOri[2]+30.0))
			write_short(g_cache_spr_head)
			write_byte(10)
			write_byte(255)
			message_end()

		}

		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_SPRITE)
		write_coord(floatround(Ori[0]))
		write_coord(floatround(Ori[1]))
		write_coord(floatround(Ori[2]))
		write_short(g_cache_spr)
		write_byte(12)
		write_byte(255)
		message_end()

		emit_sound(id, CHAN_VOICE, skill_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)


		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
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
			else if (equal(key, "KNOCK_BACK"))
				zombie_knockback = str_to_float(value)

			else if (equal(key, "HEAL"))
				format(skill_name, charsmax(skill_name), "%s", value)
			else if (equal(key, "HEAL_SOUND"))
				format(skill_sound, charsmax(skill_sound), "%s", value)
			else if (equal(key, "HEAL_SPR"))
				format(spr, charsmax(spr), "%s", value)
			else if (equal(key, "HEAL_SPR_HEAD"))
				format(spr_head, charsmax(spr_head), "%s", value)

			else if (equal(key, "HEAL_RADUIS"))
				skill_raduis = str_to_float(value)

			else if (equal(key, "HEAL_TIME_WAIT_LV1"))
				skill_timewait[0] = str_to_float(value)
			else if (equal(key, "HEAL_TIME_WAIT_LV2"))
				skill_timewait[1] = str_to_float(value)
			else if (equal(key, "HEAL_TIME_WAIT_LV3"))
				skill_timewait[2] = str_to_float(value)

			else if (equal(key, "HEAL_HEALTH_LV1"))
				skill_heal_health[0] = str_to_float(value)
			else if (equal(key, "HEAL_HEALTH_LV2"))
				skill_heal_health[1] = str_to_float(value)
			else if (equal(key, "HEAL_HEALTH_LV3"))
				skill_heal_health[2] = str_to_float(value)

			else if (equal(key, "HEAL_ARMOR_LV1"))
				skill_heal_armor[0] = str_to_float(value)
			else if (equal(key, "HEAL_ARMOR_LV2"))
				skill_heal_armor[1] = str_to_float(value)
			else if (equal(key, "HEAL_ARMOR_LV3"))
				skill_heal_armor[2] = str_to_float(value)

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
