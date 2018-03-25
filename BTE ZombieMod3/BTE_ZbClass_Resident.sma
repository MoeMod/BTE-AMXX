#define PLUGIN "BTE Resident Zombie"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define CONFIG_NAME			"[Resident Zombie]"

#define ZMOBIE_TYPE			"resource\\hud\\zombie\\zombietype_resident_zombi"
#define SKILL_ICON			"mode\\zb3\\zombieskill_zombijumpup"
#define SKILL_ICON2			"mode\\zb3\\zombieskill_zombipenetration"
#define SKILL_RRTINA		"mode\\zb3\\retina_zombijumpup"
#define SKILL_RRTINA2		"mode\\zb3\\retina_zombitentacle"

#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>
#include <orpheu>

#include "metahook.inc"
#include "BTE_API.inc"
#include "BTE_zb3.inc"
#include "animation.inc"
#include "cdll_dll.h"

#include "offset.inc"

new zombie_sound_heal[64], zombie_name[64], zombie_model[64], zombie_sex, zombie_modelindex, Float:zombie_gravity, Float:zombie_speed, Float:zombie_knockback, Float:zombie_xdamage[3],
zombie_sound_death1[64], zombie_sound_death2[64], zombie_sound_hurt1[64], zombie_sound_hurt2[64], zombie_sound_evolution[64]
new idclass

new Float:skill_speed, Float:skill_gravity, Float:skill2_distance
new Float:skill_time, Float:skill_time_prepare, Float:skill_timewait,Float:skill2_time_prepare, Float:skill2_timewait
new Float:skill_use_time_next[33],Float:skill2_use_time_next[33]
new g_skill_wait[33], g_skill2_wait[33]
new skill_name[33], skill2_name[33]

new c_szJumpupName[64],c_szJumpupSound[64],Float:c_flJumpupTime,Float:c_flJumpupWait,Float:c_flJumpupSpeed[3],Float:c_flJumpupGravity[3],Float:c_flJumpupXDamage[3]

new g_iSkillUsing[33], Float:g_flJumpupCD[33]

enum (+= 100)
{
	TASK_SKILL = 2000,
	TASK_SKILL_REMOVE,
	TASK_WAIT_SKILL,
	TASK_SKILL2,
	TASK_WAIT_SKILL2
}

#define ID_SKILL (iTask - TASK_SKILL)
#define ID_SKILL_REMOVE (iTask - TASK_SKILL_REMOVE)
#define ID_WAIT_SKILL (iTask - TASK_WAIT_SKILL)
#define ID_SKILL2 (iTask - TASK_SKILL2)
#define ID_WAIT_SKILL2 (iTask - TASK_WAIT_SKILL2)


native MetahookMsg(id, type, i2 = -1, i3 = -1)

public bte_zb_infected(id,inf)
{
	if(idclass==bte_zb3_get_user_zombie_class(id))
	{
		/*MH_SendZB3Data(id,8,1)
		MH_SendZB3Data(id,9,1)
		MH_ZB3UI(id,ZMOBIE_TYPE,0,2,3)
		MH_ZB3UI(id,SKILL_ICON,1,2,3)
		MH_ZB3UI(id,SKILL_ICON2,2,2,3)
		MH_DrawRetina(id,SKILL_RRTINA,0,0,1,1,0.0)*/
		if(inf)
		{
			g_skill_wait[id] = 0;
			g_flJumpupCD[id] = 0.0;
			//MH_SendZB3Data(id,10,RESIDENT_ZB)
			MetahookMsg(id, 34);
		}
		else
		{
			g_skill_wait[id] = 0;
			g_flJumpupCD[id] = 0.0;
			//MH_SendZB3Data(id,11,RESIDENT_ZB)
			MetahookMsg(id, 37, g_skill2_wait[id]);
		}


	}
}

public bte_zb3_reset_skill(id)
{
	if (idclass == bte_zb3_get_user_zombie_class(id))
	{
		g_skill_wait[id] = 0
		g_flJumpupCD[id] = 0.0
		
		MetahookMsg(id, 37, g_skill2_wait[id]);
		//MH_SendZB3Data(id,10,SPEED_ZB)
	}
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0")
	register_event("DeathMsg", "Event_DeathMsg", "a")

	//register_forward(FM_CmdStart, "Forward_CmdStart")

	register_clcmd("BTE_ZombieSkill1", "UseSkill2")
	//register_clcmd("zbskill", "UseSkill2")
	register_clcmd("BTE_ZombieSkill2", "JumpupM_Activate")
	
}

public plugin_precache()
{
	load_customization_from_files()
	idclass = bte_zb3_register_zombie_class(zombie_name, zombie_model, zombie_gravity, zombie_speed, zombie_knockback, zombie_sound_death1, zombie_sound_death2, zombie_sound_hurt1, zombie_sound_hurt2, zombie_sound_heal, zombie_sound_evolution, zombie_sex, zombie_modelindex , zombie_xdamage[0], zombie_xdamage[1])
}


public Event_HLTV()
{
	for (new id=1; id<33; id++)
	{
		if (!is_user_connected(id)) continue;
		ResetPlayerValue(id)
		if (task_exists(id+TASK_SKILL)) remove_task(id+TASK_SKILL)
		if (task_exists(id+TASK_SKILL_REMOVE)) remove_task(id+TASK_SKILL_REMOVE)
		if (task_exists(id+TASK_WAIT_SKILL)) remove_task(id+TASK_WAIT_SKILL)
		if (task_exists(id+TASK_SKILL2)) remove_task(id+TASK_SKILL2)
		if (task_exists(id+TASK_WAIT_SKILL2)) remove_task(id+TASK_WAIT_SKILL2)
	}
}

public Event_DeathMsg()
{
	new victim = read_data(2)
	//ResetPlayerValue(victim)
	MH_DrawRetina(victim,SKILL_RRTINA,0,0,1,1,0.0)
}
public client_connect(id)
{
	ResetPlayerValue(id)
}

ResetPlayerValue(id)
{
	MH_DrawRetina(id,SKILL_RRTINA,0,0,1,1,0.0)
	g_skill_wait[id] = 0
	g_skill2_wait[id] = 0
}
public UseSkill2(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE
	if(idclass==bte_zb3_get_user_zombie_class(id) && bte_get_user_zombie(id) && bte_zb3_can_use_skill(id))
	{
		if(g_skill2_wait[id])
		{
			//if (skill2_use_time_next[id] - skill2_timewait - get_gametime() <=-1.0)
			//	client_print(id, print_center, "%L", LANG_PLAYER, "BTE_ZB3_ZOMBIE_SKILL_WAIT", floatround(skill2_use_time_next[id] - get_gametime()), skill2_name)
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_ZOMBIE_DNA_STING_FINGER_SKILL_IS_ONLY_ONE_TIME_IN_A_ROUND");
			return PLUGIN_HANDLED
		}
		/*MH_ZB3UI(id,SKILL_ICON2,2,3,floatround(skill2_timewait))
		MH_DrawRetina(id,SKILL_RRTINA2,1,0,1,1,2.0)*/

		engclient_cmd(id, "weapon_knife");
		
		MetahookMsg(id, 36, floatround(skill2_timewait));


		set_task(skill2_time_prepare, "Task_Skill2", id+TASK_SKILL2)
		//set_task(skill2_timewait, "Task_Skill2_RemoveWait", id+TASK_WAIT_SKILL2)
		//skill2_use_time_next[id] = get_gametime() + skill2_timewait
		g_skill2_wait[id] = 1
		//bte_wpn_play_seqence(id, 92, 14)
		SendWeaponAnim(id,8)

		PlayAnimation(id, "skill1");
		
		set_pdata_float(id, m_flNextAttack, 1.7)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

native BTE_FireBullets3_Lite(Float:vecSrc[3], Float:vecDir[3], Float:flDistance, iPenetration, Float:flDamage, pevAttacker)

public Task_Skill2(iTask)
{
	new id = ID_SKILL2;

	new Float:vecSrc[3];
	GetGunPosition(id, vecSrc);

	new Float:v_angle[3], Float:punchangle[3];
	pev(id, pev_v_angle, v_angle);
	pev(id, pev_punchangle, punchangle);
	xs_vec_add(v_angle, punchangle, v_angle);

	new Float:vecDir[3];
	engfunc(EngFunc_MakeVectors, v_angle);
	global_get(glb_v_forward, vecDir);

	//BTE_FireBullets3_Lite(vecSrc, vecDir, skill2_distance, 10, 200.0, id)
	new Float:vecVelocity[3]
	pev(id, pev_velocity, vecVelocity)
	if(!(pev(id, pev_flags) & FL_ONGROUND)) // 空
		FireBullets_Lite(7, vecSrc, vecDir, Float:{0.5, 0.5, 0.0}, skill2_distance, bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN)?360:260, id)
	else if(vector_length(vecVelocity) > 140.0) // 跑
		FireBullets_Lite(7, vecSrc, vecDir, Float:{0.25, 0.25, 0.0}, skill2_distance, bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN)?360:260, id)
	else // 地
		FireBullets_Lite(7, vecSrc, vecDir, Float:{0.075, 0.075, 0.0}, skill2_distance, bte_zb3_dna_get(id, DNA_SKILL_STRENGTHEN)?360:260, id)
}

public FireBullets_Lite(cShots, Float:vecSrc[3], Float:vecDirShooting[3], Float:vecSpread[3], Float:flDistance, iDamage, pAttacker)
{
	new tr = create_tr2(), iVictim
	static Float:vecRight[3]; global_get(glb_v_right, vecRight)
	static Float:vecUp[3]; global_get(glb_v_up, vecUp)

	for(new iShot = 1; iShot <= cShots; iShot++)
	{
		static Float:x, Float:y, Float:z;

		do
		{
			x = random_float(-0.5, 0.5) + random_float(-0.5, 0.5);
			y = random_float(-0.5, 0.5) + random_float(-0.5, 0.5);
			z = x * x + y * y;
		}
		while (z > 1.0);
		
		static Float:vecDir[3]
		vecDir[0] = vecDirShooting[0] + x * vecSpread[0] * vecRight[0] + y * vecSpread[1] * vecUp[0];
		vecDir[1] = vecDirShooting[1] + x * vecSpread[0] * vecRight[1] + y * vecSpread[1] * vecUp[1];
		vecDir[2] = vecDirShooting[2] + x * vecSpread[0] * vecRight[2] + y * vecSpread[1] * vecUp[2];
		
		static Float:vecEnd[3]
		xs_vec_mul_scalar(vecDir, flDistance, vecEnd)
		xs_vec_add(vecSrc, vecEnd, vecEnd)
		
		iVictim = pAttacker
		while(is_user_alive(iVictim) && bte_get_user_zombie(iVictim)==1/* && get_distance(vecSrc, vecEnd) > 15.0*/)
		{
			xs_vec_add(vecSrc, vecDir, vecSrc)
			engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, pAttacker, tr)
			iVictim = get_tr2(tr, TR_pHit)
		}
		
		static Float:flFraction; get_tr2(tr, TR_flFraction, flFraction)
		if(flFraction != 1.0)
		{
			if(iVictim < 0) iVictim = 0

			if(pev_valid(iVictim) && pev(iVictim, pev_takedamage) != DAMAGE_NO)
			{
				OrpheuCall(OrpheuGetFunction("ClearMultiDamage"))
				ExecuteHamB(Ham_TraceAttack, iVictim, pAttacker, float(iDamage), vecDir, tr, DMG_NEVERGIB | DMG_BULLET)
				OrpheuCall(OrpheuGetFunction("ApplyMultiDamage"), pAttacker, pAttacker)
			}
				//ExecuteHamB(Ham_TakeDamage, iVictim, pAttacker, pAttacker, float(iDamage), (DMG_NEVERGIB | DMG_BULLET))
		}
	}

	if(is_user_alive(iVictim))
		set_pdata_int(iVictim, 75, get_tr2(tr, TR_iHitgroup))
	
	free_tr2(tr)
}

stock GetGunPosition(id, Float:vecSrc[3])
{
	new Float:vecViewOfs[3];
	pev(id, pev_origin, vecSrc);
	pev(id, pev_view_ofs, vecViewOfs);
	xs_vec_add(vecSrc, vecViewOfs, vecSrc);
}

/*public Task_Skill2(iTask)
{
	new id = ID_SKILL2
	static iVictim, body
	static Float:vecOri1[3]
	get_user_aiming(id,iVictim,body,floatround(skill2_distance))
	if (!(iVictim>33 || iVictim<1 || bte_get_user_zombie(iVictim)==1)) bte_zb3_inflict_player(id,iVictim)

	pev(id,pev_origin,vecOri1)
	iVictim = -1
	while ((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, vecOri1, skill2_distance)) != 0)
	{
		if (id==iVictim || !pev_valid(iVictim)) continue
		if (!(CheckAngle(id,iVictim)>floatcos(float(15),degrees))) continue
		if (iVictim>33 || iVictim<1 || bte_get_user_zombie(iVictim)==1) continue
		bte_zb3_inflict_player(id,iVictim)
	}

	set_pdata_float(id,46,1.7) // from model
	set_pdata_float(id,47,1.7)
	set_pdata_float(id,83,1.7)
	//set_pev(id, pev_animtime, get_gametime())
	//set_pev(id, pev_sequence, 91)

	//bte_wpn_set_anim_offset(id,12,6.0,0);
}*/
public Task_Skill2_RemoveWait(iTask)
{
	new id = ID_WAIT_SKILL2
	g_skill2_wait[id] = 0
}
public Task_Skill(iTask)
{
	new id = ID_SKILL

	bte_zb3_set_max_speed(id,skill_speed)
	set_pev(id,pev_gravity,skill_gravity)
	set_task(skill_time, "Task_Skill_Remove", id+TASK_SKILL_REMOVE)
	MH_DrawRetina(id,SKILL_RRTINA,1,1,1,1,skill_time)

}
public Task_Skill_Remove(iTask)
{
	new id = ID_SKILL_REMOVE

	bte_zb3_set_max_speed(id,zombie_speed)
	set_pev(id,pev_gravity,zombie_gravity)
}
public Task_Skill_RemoveWait(iTask)
{
	new id = ID_WAIT_SKILL
	g_skill_wait[id] = 0

}
public UseSkill(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED

	if(idclass==bte_zb3_get_user_zombie_class(id) && bte_get_user_zombie(id) && bte_zb3_can_use_skill(id))
	{

		if(g_skill_wait[id])
		{
			//if (skill_use_time_next[id] - skill_timewait - get_gametime() <=-1.0)
			//	client_print(id, print_center, "%L", LANG_PLAYER, "BTE_ZB3_ZOMBIE_SKILL_WAIT", floatround(skill_use_time_next[id] - get_gametime()), skill_name)
			return PLUGIN_HANDLED
		}

		//MH_ZB3UI(id,SKILL_ICON,1,3,floatround(skill_timewait))
		engclient_cmd(id, "weapon_knife");
		MetahookMsg(id, 35, floatround(skill_timewait));

		SendWeaponAnim(id,9)
		//bte_wpn_set_anim_offset(id,98,3.0,1);
		//bte_wpn_play_seqence(id, 98, 43)
		set_pdata_float(id,46,1.57)
		set_pdata_float(id,47,1.57)
		set_pdata_float(id,83,1.57)
		bte_zb3_set_next_restore_health(id, skill_time_prepare + skill_time)

		set_task(skill_time_prepare, "Task_Skill", id+TASK_SKILL)
		set_task(skill_timewait, "Task_Skill_RemoveWait", id+TASK_WAIT_SKILL)
		skill_use_time_next[id] = get_gametime() + skill_timewait
		g_skill_wait[id] = 1

		PlayAnimation(id, "skill2");

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
	new id = taskid-TASK_SKILL_REMOVE

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

			else if (equal(key, "HIGHJUMP"))
				format(skill_name, charsmax(skill_name), "%s", value)
			else if (equal(key, "HIGHJUMP_TIME_PREPARE"))
				skill_time_prepare = str_to_float(value)
			else if (equal(key, "HIGHJUMP_TIME"))
				skill_time = str_to_float(value)
			else if (equal(key, "HIGHJUMP_TIME_WAIT"))
				skill_timewait = str_to_float(value)
			else if (equal(key, "HIGHJUMP_SPEED"))
				skill_speed = str_to_float(value)
			else if (equal(key, "HIGHJUMP_GRAVITY"))
				skill_gravity = str_to_float(value)


			else if (equal(key, "LONGATTACK"))
				format(skill2_name, charsmax(skill2_name), "%s", value)
			else if (equal(key, "LONGATTACK_TIME_PREPARE"))
				skill2_time_prepare = str_to_float(value)
			else if (equal(key, "LONGATTACK_TIME_WAIT"))
				skill2_timewait = str_to_float(value)
			else if (equal(key, "LONGATTACK_DISTANCE"))
				skill2_distance = str_to_float(value)
			
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