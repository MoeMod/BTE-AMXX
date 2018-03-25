#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include "BTE_API.inc"
#include "BTE_zb3.inc"
#include "metahook.inc"
#include "animation.inc"
#include "cdll_dll.h"


#include <xs>
native bte_wpn_set_anim_offset(id,a,Float:b,c);

#define PLUGIN "BTE Deimos Zombie"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

const m_iTeam = 114
const m_rgpPlayerItems = 367
const m_pNext = 42

new const CONFIG_NAME[] = "[Deimos Zombie]"
new const light_classname[] = "bte_skill"

new idclass
new zombie_name[64], zombie_model[64], zombie_sex, zombie_modelindex, Float:zombie_gravity, Float:zombie_speed, Float:zombie_knockback, zombie_sound_evolution[64], Float:zombie_xdamage[3] ,
zombie_sound_death1[64], zombie_sound_death2[64], zombie_sound_hurt1[64], zombie_sound_hurt2[64], zombie_sound_heal[64],
Float:skill_time_wait, sound_skill_start[64], sound_skill_hit[64], sprites_exp[64], sprites_exp_index, sprites_trail[64], sprites_trail_index

new g_wait[33], g_useskill[33]

new Float:skill_use_time_next[33],skill_name[33]

new c_szSrName[64], c_szSrSound[64], Float:c_flSrAmount, Float:c_flSrWait
new Float:g_flSrCD[33]

new g_msgScreenShake

native MetahookMsg(id, type, i2 = -1, i3 = -1)

const WPN_NOT_DROP = ((1<<2)|(1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4))
enum (+= 100)
{
	TASK_WAIT = 2000,
	TASK_ATTACK,
	TASK_BOT_USE_SKILL,
	TASK_USE_SKILL
}
// IDs inside tasks
#define ID_WAIT (taskid - TASK_WAIT)
#define ID_ATTACK (taskid - TASK_ATTACK)
#define ID_BOT_USE_SKILL (taskid - TASK_BOT_USE_SKILL)
#define ID_USE_SKILL (taskid - TASK_USE_SKILL)

const m_flTimeWeaponIdle = 48
const m_flNextAttack = 83
public bte_zb_infected(id,inf)
{
	if(idclass==bte_zb3_get_user_zombie_class(id))
	{
		//MH_SendZB3Data(id,10,DEIMOS_ZB)

		MetahookMsg(id, 26);
		g_flSrCD[id] = 0.0;
		g_wait[id] = 0;
		skill_use_time_next[id] = 0.0;

		set_pev(id, pev_mins, Float:{-16.0, -16.0, -36.0});
		set_pev(id, pev_maxs, Float:{16.0, 16.0, 56.0});
		/*MH_SendZB3Data(id,9,0)
		MH_SendZB3Data(id,8,1)
		MH_ZB3UI(id,ZMOBIE_TYPE,0,2,3)
		MH_ZB3UI(id,spr_skill,1,2,3)*/
	}
}

public bte_zb3_reset_skill(id)
{
	if (idclass == bte_zb3_get_user_zombie_class(id))
	{
		MetahookMsg(id, 26);
		g_flSrCD[id] = 0.0;
		g_wait[id] = 0;
		skill_use_time_next[id] = 0.0;
	}
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_dictionary("bte_zombie.bte")

	register_logevent("logevent_round_start",2, "1=Round_Start")
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("DeathMsg", "Death", "a")
	register_clcmd("BTE_ZombieSkill1", "use_skill")
	register_clcmd("BTE_ZombieSkill2", "Activate_StrengthenRecovery")
	RegisterHam(Ham_Touch, "info_target", "HamF_InfoTarget_Touch")

	register_forward(FM_SetSize, "fw_SetSize")

	g_msgScreenShake = get_user_msgid("ScreenShake");
}

public fw_SetSize(id, Float:vecMins[3], Float:vecMaxs[3])
{
	if (!is_user_connected(id))
		return 0;

	if (idclass != bte_zb3_get_user_zombie_class(id))
		return 0;

	vecMaxs[2] += 20.0;

	set_pev(id, pev_mins, vecMins);
	set_pev(id, pev_maxs, vecMaxs);

	engfunc(EngFunc_SetSize, id, vecMins, vecMaxs);

	return 1;
}



public HamF_InfoTarget_Touch(ptr,ptd)
{
	if(!pev_valid(ptr)) return
	static iflag
	iflag = pev(ptr,pev_iuser1)
	if(iflag != 123) return
	light_exp(ptr, ptd)
	set_pev(ptr, pev_flags, pev(ptr, pev_flags) | FL_KILLME);

}
public plugin_precache()
{
	load_customization_from_files()
	sprites_exp_index = precache_model(sprites_exp)
	sprites_trail_index = precache_model(sprites_trail)
	precache_sound(sound_skill_start)
	precache_sound(sound_skill_hit)

	new wpnmodel2[64], v_zombiebom2[64]
	formatex(wpnmodel2, charsmax(wpnmodel2), "models/v_knife_%s_host.mdl", zombie_model)
	formatex(v_zombiebom2, charsmax(v_zombiebom2), "models/v_zombibomb_%s_host.mdl", zombie_model)
	engfunc(EngFunc_PrecacheModel, wpnmodel2)
	engfunc(EngFunc_PrecacheModel, v_zombiebom2)

	idclass = bte_zb3_register_zombie_class(zombie_name, zombie_model, zombie_gravity, zombie_speed, zombie_knockback, zombie_sound_death1, zombie_sound_death2, zombie_sound_hurt1, zombie_sound_hurt2, zombie_sound_heal, zombie_sound_evolution, zombie_sex, zombie_modelindex, zombie_xdamage[0] ,zombie_xdamage[1], 1)

}
public event_round_start()
{
	for (new id=1; id<33; id++)
	{
		if (!is_user_connected(id)) continue;

		reset_value_player(id)
	}
}
public logevent_round_start()
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
public Death()
{
	new victim = read_data(2)
	reset_value_player(victim)
}
public client_connect(id)
{
	reset_value_player(id)
}
public client_disconnect(id)
{
	reset_value_player(id)
}
reset_value_player(id)
{
	if (task_exists(id+TASK_WAIT)) remove_task(id+TASK_WAIT)
	if (task_exists(id+TASK_BOT_USE_SKILL)) remove_task(id+TASK_BOT_USE_SKILL)
	if (task_exists(id+TASK_WAIT)) remove_task(id+TASK_WAIT)
	if (task_exists(id+TASK_ATTACK)) remove_task(id+TASK_ATTACK)
	if (task_exists(id+TASK_USE_SKILL)) remove_task(id+TASK_USE_SKILL)

	g_wait[id] = 0
	g_useskill[id] = 0
	g_flSrCD[id] = 0.0
}

// bot use skill
public bot_use_skill(taskid)
{
	new id = ID_BOT_USE_SKILL
	if (!is_user_bot(id)) return;

	use_skill(id)
	if (task_exists(taskid)) remove_task(taskid)
	set_task(float(random_num(5,15)), "bot_use_skill", id+TASK_BOT_USE_SKILL)
}

// #################### USE SKILL PUBLIC ####################
public use_skill(id)
{
	if (!is_user_alive(id)) return PLUGIN_CONTINUE

	//new health = get_user_health(id) - skill_dmg
	if (idclass==bte_zb3_get_user_zombie_class(id) && bte_get_user_zombie(id)==1 && bte_zb3_can_use_skill(id))
	{

		if(g_wait[id])
		{

			//client_print(id, print_center, "%L", LANG_PLAYER, "BTE_ZB3_ZOMBIE_SKILL_WAIT", floatround(skill_use_time_next[id] - get_gametime()), skill_name)
			return PLUGIN_HANDLED
		}
		g_useskill[id] = 1

		engclient_cmd(id, "weapon_knife");
		
		PlayAnimation(id, "skill");

		//fm_set_user_health(id, health)

		// set time wait
		new Float:timewait = skill_time_wait
		if (bte_zb3_get_user_level(id)==1) timewait = skill_time_wait*2
		timewait *= (bte_zb3_dna_get(id, DNA_FREEZE_STRENGTHEN) ? 0.95:1.0);
		skill_use_time_next[id] = get_gametime() + timewait
		g_wait[id] = 1
		if (task_exists(id+TASK_WAIT)) remove_task(id+TASK_WAIT)
		set_task(timewait, "RemoveWait", id+TASK_WAIT)
		Use_Skill(id)
		//MH_ZB3UI(id,spr_skill,1,3,floatround(timewait))
		//MH_SendZB3Data(id,6,4)
		//MH_DrawRetina(id,SKILL_RRTINA,1,0,0,1,1.5)

		MetahookMsg(id, 27, floatround(timewait));

		set_task(0.5,"RemoveHud",id)

		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}
public RemoveHud(id)
{
	//MH_SendZB3Data(id,6,0)

}

public Use_Skill(id)
{
	play_weapon_anim(id, 2)
	set_weapons_timeidle(id, skill_time_wait)
	set_player_nextattack(id, 1.5)
	PlayEmitSound(id, sound_skill_start)
	if (task_exists(id+TASK_ATTACK)) remove_task(id+TASK_ATTACK)
	set_task(0.5, "launch_light", id+TASK_ATTACK)
	//bte_wpn_set_anim_offset(id,8,6.0,0);
}
public launch_light(taskid)
{
	new id = ID_ATTACK
	if (task_exists(id+TASK_ATTACK)) remove_task(id+TASK_ATTACK)

	if (!is_user_alive(id)) return;


	// check
	new Float: fOrigin[3], Float:fAngle[3],Float: fVelocity[3]
	Stock_Get_Postion(id,5.0,0.0,0.0,fOrigin)
	//pev(id, pev_origin, fOrigin)
	pev(id, pev_view_ofs, fAngle)
	fm_velocity_by_aim(id, 1.5, fVelocity, fAngle)
	fAngle[0] *= -1.0

	// create ent
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(ent, pev_classname, light_classname)
	engfunc(EngFunc_SetModel, ent, "models/w_hegrenade.mdl")
	set_pev(ent, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(ent, pev_maxs, Float:{1.0, 1.0, 1.0})
	set_pev(ent, pev_origin, fOrigin)
	fOrigin[0] += fVelocity[0]
	fOrigin[1] += fVelocity[1]
	fOrigin[2] += fVelocity[2]
	set_pev(ent, pev_movetype, MOVETYPE_BOUNCE)
	set_pev(ent, pev_gravity, 0.01)
	fVelocity[0] *= 1000
	fVelocity[1] *= 1000
	fVelocity[2] *= 1000
	set_pev(ent, pev_velocity, fVelocity)
	set_pev(ent, pev_owner, id)
	set_pev(ent, pev_angles, fAngle)
	set_pev(ent, pev_solid, SOLID_BBOX)
	set_pev(ent, pev_iuser1, 123)

	// invisible ent
	fm_set_rendering(ent, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)

	// show trail
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte(TE_BEAMFOLLOW)
	write_short(ent)				//entity
	write_short(sprites_trail_index)		//model
	write_byte(5)		//10)//life
	write_byte(3)		//5)//width
	write_byte(209)					//r, hegrenade
	write_byte(120)					//g, gas-grenade
	write_byte(9)					//b
	write_byte(200)		//brightness
	message_end()					//move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)

	//client_print(0, print_chat, "phong")
	return;
}
light_exp(ent, victim)
{
	new attacker = pev(ent, pev_owner)
	if(victim <= 32)
	{
		if (is_user_alive(victim) && bte_get_user_zombie(victim)!=2 && get_pdata_int(attacker, m_iTeam) != get_pdata_int(victim, m_iTeam))
		{
			if(!Drop(victim, 1)) Drop(victim, 2)
			ScreenShake(victim)
			ExecuteHam(Ham_TakeDamage, victim, attacker, attacker, 0.0, (1<<7));
		}
	}

	// create effect
	static Float:origin[3];
	pev(ent, pev_origin, origin);
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_EXPLOSION); // TE_EXPLOSION
	write_coord(floatround(origin[0])); // origin x
	write_coord(floatround(origin[1])); // origin y
	write_coord(floatround(origin[2])); // origin z
	write_short(sprites_exp_index); // sprites
	write_byte(40); // scale in 0.1's
	write_byte(30); // framerate
	write_byte(14); // flags
	message_end(); // message end

	// play sound exp
	PlayEmitSound(ent, sound_skill_hit)
}
public RemoveWait(taskid)
{
	new id = ID_WAIT
	g_wait[id] = 0
	if (task_exists(taskid)) remove_task(taskid)
}
PlayEmitSound(id, const sound[])
{
	emit_sound(id, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}
play_weapon_anim(player, anim)
{
	set_pev(player, pev_weaponanim, anim)
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, player)
	write_byte(anim)
	write_byte(pev(player, pev_body))
	message_end()
}
fm_velocity_by_aim(iIndex, Float:fDistance, Float:fVelocity[3], Float:fViewAngle[3])
{
	//new Float:fViewAngle[3]
	pev(iIndex, pev_v_angle, fViewAngle)
	fVelocity[0] = floatcos(fViewAngle[1], degrees) * fDistance
	fVelocity[1] = floatsin(fViewAngle[1], degrees) * fDistance
	fVelocity[2] = floatcos(fViewAngle[0]+90.0, degrees) * fDistance
	return 1
}
get_weapon_ent(id, weaponid)
{
	static wname[32], weapon_ent
	get_weaponname(weaponid, wname, charsmax(wname))
	weapon_ent = fm_find_ent_by_owner(-1, wname, id)
	return weapon_ent
}
set_weapons_timeidle(id, Float:timeidle)
{
	new entwpn = get_weapon_ent(id, get_user_weapon(id))
	if (pev_valid(entwpn)) set_pdata_float(entwpn, m_flTimeWeaponIdle, timeidle+3.0, 4)
}
set_player_nextattack(id, Float:nexttime)
{
	set_pdata_float(id, m_flNextAttack, nexttime, 4)
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

		if(task_exists(id+TASK_ATTACK))
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

// ################### LOAD CONFIG ###################
load_customization_from_files()
{
	// Build customization file path
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, "bte_zombieclass.ini")

	// File not present
	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
		set_fail_state(error)
		return;
	}

	// Set up some vars to hold parsing info
	new linedata[1024], key[64], value[960], section

	// Open customization file for reading
	new file = fopen(path, "rt")

	while (file && !feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, charsmax(linedata))

		// Replace newlines with a null character to prevent headaches
		replace(linedata, charsmax(linedata), "^n", "")

		// Blank line or comment
		if (!linedata[0] || linedata[0] == ';') continue;

		// New section starting
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
			// Get key and value(s)
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=')

			// Trim spaces
			trim(key)
			trim(value)

			// set value
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
			else if (equal(key, "SKILL"))
				format(skill_name, charsmax(skill_name), "%s", value)

			else if (equal(key, "SKILL_TIME_WAIT"))
				skill_time_wait = str_to_float(value)
			else if (equal(key, "SKILL_SOUND_START"))
				format(sound_skill_start, charsmax(sound_skill_start), "%s", value)
			else if (equal(key, "SKILL_SOUND_HIT"))
				format(sound_skill_hit, charsmax(sound_skill_hit), "%s", value)
			else if (equal(key, "SKILL_SPRITES_EXP"))
				format(sprites_exp, charsmax(sprites_exp), "%s", value)
			else if (equal(key, "SKILL_SPRITES_TRAIL"))
				format(sprites_trail, charsmax(sprites_trail), "%s", value)
			else if (equal(key, "STRENGTHENRECOVERY"))
				format(c_szSrName, charsmax(c_szSrName), "%s", value)
			else if (equal(key, "STRENGTHENRECOVERY_WAIT"))
				c_flSrWait = str_to_float(value)
			else if (equal(key, "STRENGTHENRECOVERY_AMOUNT"))
				c_flSrAmount = str_to_float(value)
			else if (equal(key, "STRENGTHENRECOVERY_SOUND"))
				format(c_szSrSound, charsmax(c_szSrSound), "%s", value)
		}
		else continue;

	}
	if (file) fclose(file)
}


// ################### STOCK ###################
// Set player's health (from fakemeta_util)
stock fm_set_user_health(id, health)
{
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}
// Set entity's rendering type (from fakemeta_util)
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)

	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
}
// Find entity by its owner (from fakemeta_util)
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) { /* keep looping */ }
	return entity;
}
stock Stock_Get_Postion(id,Float:forw,Float:right,Float:up,Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]

	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs,vUp)
	xs_vec_add(vOrigin,vUp,vOrigin)
	pev(id, pev_v_angle, vAngle)

	angle_vector(vAngle,ANGLEVECTOR_FORWARD,vForward)
	angle_vector(vAngle,ANGLEVECTOR_RIGHT,vRight)
	angle_vector(vAngle,ANGLEVECTOR_UP,vUp)

	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}
stock Drop(id, slot)
{
	new item = get_pdata_cbase(id, m_rgpPlayerItems + slot)
	new droped = 0

	while (item > 0)
	{
		static classname[24]
		pev(item, pev_classname, classname, charsmax(classname))
		engclient_cmd(id, "drop", classname)
		droped = 1

		item = get_pdata_cbase(item, m_pNext)
	}

	set_pdata_cbase(id, m_rgpPlayerItems, -1)

	return droped
}
stock ScreenShake(id, amplitude = 8, duration = 6, frequency = 18)
{
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
	write_short((1<<12)*amplitude)
	write_short((1<<12)*duration)
	write_short((1<<12)*frequency)
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