#define PLUGIN "BTE Speed Zombie"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define CONFIG_NAME "[Speed Zombie]"


#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>
#include "metahook.inc"
#include "BTE_API.inc"
#include "bte_zb3.inc"
#include "cdll_dll.h"

new zombie_sound_heal[64], zombie_name[64], zombie_model[64], zombie_sex, zombie_modelindex, Float:zombie_gravity, Float:zombie_speed, Float:zombie_knockback, Float:zombie_xdamage[3],
zombie_sound_death1[64], zombie_sound_death2[64], zombie_sound_hurt1[64], zombie_sound_hurt2[64], zombie_sound_evolution[64]
new idclass

new Float:zombie_xdamage_inskill[3]

new zombie_sound_invisible[64],Float:skill_time,Float:skill_timewait,
 Float:invisible_speed[3], Float:invisible_gravity[3], Float:invisible_alpha[3]
 
new c_szJumpupName[64],c_szJumpupSound[64],Float:c_flJumpupTime,Float:c_flJumpupWait,Float:c_flJumpupSpeed[3],Float:c_flJumpupGravity[3],Float:c_flJumpupXDamage[3]

new g_iSkillUsing[33], Float:g_flInvisiableCD[33], Float:g_flJumpupCD[33]

new skill_name[33]

new Float:g_flInvisiable[33], Float:g_flInvisiableRemove[33];

enum (+= 100)
{
	TASK_SKILL_REMOVE = 2000,
	TASK_BOT_USE_SKILL,
}

#define ID_INVISIBLE (taskid - TASK_SKILL_REMOVE)
#define ID_BOT_USE_SKILL (taskid - TASK_BOT_USE_SKILL)


#define INVISIBLE_FADE 0.5

native MetahookMsg(id, type, i2 = -1, i3 = -1)

public bte_zb_infected(id,inf)
{
	if (idclass == bte_zb3_get_user_zombie_class(id))
	{
		g_iSkillUsing[id] = 0
		g_flInvisiableCD[id] = 0.0
		g_flJumpupCD[id] = 0.0
		set_pev(id,pev_gravity,1.0)
		
		MetahookMsg(id, 20);
		//MH_SendZB3Data(id,10,SPEED_ZB)
	}
}

public bte_zb3_reset_skill(id)
{
	if (idclass == bte_zb3_get_user_zombie_class(id))
	{
		g_flInvisiableCD[id] = 0.0
		g_flJumpupCD[id] = 0.0
		
		MetahookMsg(id, 20);
		//MH_SendZB3Data(id,10,SPEED_ZB)
	}
}


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_logevent("LogEvent_RoundStart",2, "1=Round_Start")
	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0")
	register_event("DeathMsg", "Event_DeathMsg", "a")
	register_forward(FM_AddToFullPack, "AddToFullPack", 1);

	register_clcmd("BTE_ZombieSkill1", "UseSkill")
	register_clcmd("BTE_ZombieSkill2", "JumpupM_Activate")
}

public plugin_precache()
{
	load_customization_from_files()
	engfunc(EngFunc_PrecacheSound, zombie_sound_invisible)
	engfunc(EngFunc_PrecacheSound, c_szJumpupSound)
	idclass = bte_zb3_register_zombie_class(zombie_name, zombie_model, zombie_gravity, zombie_speed, zombie_knockback, zombie_sound_death1, zombie_sound_death2, zombie_sound_hurt1, zombie_sound_hurt2, zombie_sound_heal, zombie_sound_evolution, zombie_sex, zombie_modelindex ,zombie_xdamage[0], zombie_xdamage[1])
}

public Event_HLTV()
{
	for (new id=1; id<33; id++)
	{
		if (!is_user_connected(id)) 
			continue;
		ResetPlayerValue(id)
	}
}
public LogEvent_RoundStart()
{
	for (new id=1; id<33; id++)
	{
		if (!is_user_connected(id)) continue;
		if (is_user_bot(id))
		{
			if (task_exists(id+TASK_BOT_USE_SKILL)) remove_task(id+TASK_BOT_USE_SKILL)
			set_task(float(random_num(5,15)), "bot_use_skill", id+TASK_BOT_USE_SKILL)
		}
	}
}
public Event_DeathMsg()
{
	new victim = read_data(2)
	ResetPlayerValue(victim)
}
public client_connect(id)
{
	ResetPlayerValue(id)
}
public client_disconnect(id)
{
	ResetPlayerValue(id)
}
ResetPlayerValue(id)
{
	if (task_exists(id+TASK_SKILL_REMOVE)) remove_task(id+TASK_SKILL_REMOVE)
	if (task_exists(id+TASK_BOT_USE_SKILL)) remove_task(id+TASK_BOT_USE_SKILL)
	//MH_SetViewEntityRender(id,kRenderFxNone,kRenderNormal, 255, 255, 255,  16 )

	g_iSkillUsing[id] = 0
	g_flInvisiableCD[id] = 0.0
	g_flJumpupCD[id] = 0.0
	set_pev(id,pev_gravity,1.0)
	//MH_SendZB3Data(id,9,1)
	//MH_DrawRetina(id,SKILL_RRTINA,0,0,1,1,0.0)
}
public bot_use_skill(taskid)
{
	new id = ID_BOT_USE_SKILL
	if (!is_user_bot(id)) return;

	UseSkill(id)
	if (task_exists(taskid)) remove_task(taskid)
	set_task(float(random_num(5,15)), "bot_use_skill", id+TASK_BOT_USE_SKILL)
}

public UseSkill(id)
{
	//if (!is_user_alive(id) || !bte_zb3_can_use_skill()) return PLUGIN_CONTINUE
	if (!is_user_alive(id)) return PLUGIN_HANDLED
	if (idclass==bte_zb3_get_user_zombie_class(id) && bte_get_user_zombie(id)==1 && bte_zb3_can_use_skill(id))
	{
		if (get_gametime() < g_flInvisiableCD[id])
		{
			new szNumber[4];
			format(szNumber, 3, "%i", floatround(g_flInvisiableCD[id] - get_gametime()))
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_WaitSkillCoolTime", szNumber);
			return PLUGIN_HANDLED
		}
		else if(g_iSkillUsing[id])
		{
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_WaitSkillEnd");
			return PLUGIN_HANDLED
		}


		g_iSkillUsing[id] = 1
		g_flInvisiableCD[id] = get_gametime() + skill_timewait * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95:1.0)
		//MH_SetViewEntityRender(id,5,0,255,255,255,130)

		new Float:time_invi, level
		level = bte_zb3_get_user_level(id) - 1
		if (level==0) time_invi = skill_time*0.5
		else time_invi = skill_time
		if (task_exists(id+TASK_SKILL_REMOVE)) remove_task(id+TASK_SKILL_REMOVE)
		set_task(time_invi * (bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN) ? 1.35:1.0), "Task_SkillRemove", id+TASK_SKILL_REMOVE)
		emit_sound(id, CHAN_VOICE, zombie_sound_invisible, 1.0, ATTN_NORM, 0, PITCH_NORM)
		set_pev(id, pev_gravity, invisible_gravity[level])
		bte_zb3_set_max_speed(id, invisible_speed[level])
		bte_zb3_set_next_restore_health(id, skill_time)
		//MH_ZB3UI(id, SKILL_ICON, 1, 3, floatround(skill_timewait))
		bte_zb3_set_xdamage(id,zombie_xdamage[level]*zombie_xdamage_inskill[level],level)
		//MH_DrawRetina(id,SKILL_RRTINA,1,0,1,1,time_invi)
		//SetRendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,200)

		MetahookMsg(id, 21, floatround(skill_timewait * (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95:1.0)), floatround(time_invi * (bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN) ? 1.35:1.0)));

		g_flInvisiable[id] = get_gametime() + INVISIBLE_FADE;
		g_flInvisiableRemove[id] = get_gametime() + time_invi * (bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN) ? 1.35:1.0);

		set_pev(id, pev_skin, 1);

		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public JumpupM_Activate(id)
{
	//if (!is_user_alive(id) || !bte_zb3_can_use_skill()) return PLUGIN_CONTINUE
	if (!is_user_alive(id)) return PLUGIN_HANDLED
	if (idclass==bte_zb3_get_user_zombie_class(id) && bte_get_user_zombie(id)==1 && bte_zb3_can_use_skill(id))
	{
		if (get_gametime() < g_flJumpupCD[id])
		{
			//client_print(id, print_center, "%L", LANG_PLAYER, "BTE_ZB3_ZOMBIE_SKILL_WAIT", floatround(g_flJumpupCD[id] - get_gametime()), skill_name)
			new szNumber[4];
			format(szNumber, 3, "%i", floatround(g_flJumpupCD[id] - get_gametime()))
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_WaitSkillCoolTime", szNumber);
			return PLUGIN_HANDLED
		}
		else if(g_iSkillUsing[id])
		{
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_WaitSkillEnd");
			return PLUGIN_HANDLED
		}


		g_iSkillUsing[id] = 2
		g_flJumpupCD[id] = get_gametime() + c_flJumpupTime
		//MH_SetViewEntityRender(id,5,0,255,255,255,130)

		new level
		level = bte_zb3_get_user_level(id) - 1
		if (task_exists(id+TASK_SKILL_REMOVE)) remove_task(id+TASK_SKILL_REMOVE)
		set_task(c_flJumpupTime, "Task_SkillRemove", id+TASK_SKILL_REMOVE)
	
		emit_sound(id, CHAN_VOICE, c_szJumpupSound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		set_pev(id, pev_gravity, c_flJumpupGravity[level])
		bte_zb3_set_max_speed(id, c_flJumpupSpeed[level])
		bte_zb3_set_next_restore_health(id, c_flJumpupTime)
		
		g_flJumpupCD[id] = get_gametime() + c_flJumpupWait
		bte_zb3_set_xdamage(id,zombie_xdamage[level]*c_flJumpupXDamage[level],level)
		
		MetahookMsg(id, 35, floatround(c_flJumpupWait), floatround(c_flJumpupTime));

		fm_set_rendering(id, kRenderFxGlowShell, 255, 3, 0, kRenderNormal, 0)

		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public Task_SkillRemove(taskid)
{
	new id = ID_INVISIBLE

	set_pev(id, pev_skin, 0);

	g_iSkillUsing[id] = 0
	//if(MH_IsMetaHookPlayer(id)) MH_SetViewEntityRender(id,kRenderFxNone,kRenderNormal, 255, 255, 255,  16 )
	//SetRendering(id)
	if (task_exists(taskid)) remove_task(taskid)

	MH_SendZB3Data(id,7,1)
	if(bte_get_user_zombie(id)==1)
	{
		bte_zb3_reset_zombie_property(id)
		fm_set_rendering(id)
	}
}
/*public Forward_PlayerPreThink(id)
{
	if (!is_user_alive(id)) return;
	if (idclass==bte_zb3_get_user_zombie_class(id) && bte_get_user_zombie(id)==1)
	{
		if(g_iSkillUsing[id])
		{
			//set_pev(id, pev_maxspeed,invisible_speed)
			if(!g_invisible_wait[id])
			{
				new Float:velocity[3], velo, alpha
				pev(id, pev_velocity, velocity)
				velo = sqroot(floatround(velocity[0] * velocity[0] + velocity[1] * velocity[1] + velocity[2] * velocity[2]))/10
				alpha = floatround(float(velo)*invisible_alpha)
				SetRendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha, alpha)
				//MH_SetViewEntityRender(id,5,0,255*velo,255*velo,255*velo,130*velo)
			}
		}
	}
}*/

public AddToFullPack(es_handle, e, ent, host, hostflags, player, pSet)
{
	if (ent > 32 || !ent)
		return FMRES_IGNORED;

	if (idclass != bte_zb3_get_user_zombie_class(ent) || bte_get_user_zombie(ent) != 1)
		return FMRES_IGNORED;

	if (is_user_alive(ent) && g_iSkillUsing[ent]==1)
	{
		new level = bte_zb3_get_user_level(ent) - 1;
		new Float:flAlpha = invisible_alpha[level];

		if (g_flInvisiable[ent] - get_gametime() > 0.0)
			flAlpha += (255.0 - invisible_alpha[level]) * ((g_flInvisiable[ent] - get_gametime()) / INVISIBLE_FADE);

		if (0.0 < g_flInvisiableRemove[ent] - get_gametime() < INVISIBLE_FADE)
			flAlpha += (255.0 - invisible_alpha[level]) * ((INVISIBLE_FADE - (g_flInvisiableRemove[ent] - get_gametime())) / INVISIBLE_FADE);

		set_es(es_handle, ES_RenderMode, kRenderTransAlpha);
		set_es(es_handle, ES_RenderAmt, floatround(flAlpha));
		//set_es(es_handle, ES_RenderFx, kRenderFxGlowShell);
	}

	return FMRES_IGNORED;
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

			else if (equal(key, "INVISIBLE"))
				format(skill_name, charsmax(skill_name), "%s", value)
			else if (equal(key, "INVISIBLE_TIME"))
				skill_time = str_to_float(value)
			else if (equal(key, "INVISIBLE_TIME_WAIT"))
				skill_timewait = str_to_float(value)
			else if (equal(key, "INVISIBLE_SPEED"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					invisible_speed[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "INVISIBLE_GRAVITY"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					invisible_gravity[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "INVISIBLE_ALPHA"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					invisible_alpha[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "SOUND_INVISIBLE"))
				format(zombie_sound_invisible, charsmax(zombie_sound_invisible), "%s", value)
			
			else if (equal(key, "JUMPUPM"))
				format(c_szJumpupName, charsmax(c_szJumpupName), "%s", value)
			else if (equal(key, "JUMPUPM_TIME"))
				c_flJumpupTime = str_to_float(value)
			else if (equal(key, "JUMPUPM_TIME_WAIT"))
				c_flJumpupWait = str_to_float(value)
			else if (equal(key, "JUMPUPM_SOUND"))
				format(c_szJumpupSound, charsmax(c_szJumpupSound), "%s", value)
			else if (equal(key, "JUMPUPM_SPEED"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					c_flJumpupSpeed[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "JUMPUPM_GRAVITY"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					c_flJumpupGravity[i] = str_to_float(key);
					i += 1;
				}
			}
			else if (equal(key, "JUMPUPM_XDAMAGE"))
			{
				new i = 0;
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					trim(key)
					trim(value)
					c_flJumpupXDamage[i] = str_to_float(key);
					i += 1;
				}
			}
			
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