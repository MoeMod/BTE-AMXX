#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include "bte_api.inc"
#include "metahook.inc"
#include "cdll_dll.h"

#define PLUGIN "BTE Human Skill"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define ACCSHOOT_TIME 4.0
#define SPEEDUP_TIME 10.0
#define SPEEDUP_SLOWDOWN_TIME 5.0
#define SPEEDUP_1 360.0
#define SPEEDUP_2 100.0

#define SOUND_SKILL_START "zombi/speedup.wav"
#define HEART_BEAT "zombi/speedup_heartbeat.wav"
#define SPEEDUP_BREATH_MALE "zombi/human_breath_male.wav"
#define SPEEDUP_BREATH_FEMALE "zombi/human_breath_female.wav"

#define PRINT(%1) client_print(1,print_chat,%1)

native MetahookMsg(id, type, i2 = -1, i3 = -1)
native BTE_HostOwnBuffM4();
native BTE_HostOwnBuffSG552();
native BTE_HostOwnBuffAWP();

enum _:HUMAN_SKILL
{
	HS_SP=0,
	HS_HS,
}

#define	TASK_SOUND	100

new g_can_use[33][HUMAN_SKILL]
new g_using[33][HUMAN_SKILL]
new g_ham

new Cvar_BotUseSkill;
new g_iSpeedUpStatus[33];
new Float:g_fBotCanUseSkill[33];
new gmsgTextMsg;
new g_bCanUseSkill = 0;
new g_bBuffSG552Duanged[33];
new Float:g_flAdrShootWaitTime[33];

forward bte_zb3_round_start();

public bte_zb3_round_start()
{
	g_bCanUseSkill = 1;
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_concmd("BTE_HumanSkill1", "check_speed")
	register_concmd("BTE_HumanSkill2", "check_shoot")

	register_event("HLTV","Event_HLTV","a","1=0","2=0")
	register_forward(FM_PlayerPostThink, "Forward_PlayerPostThink", 1)

	RegisterHam(Ham_TraceAttack, "player", "HamF_TraceAttack");
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage")
	RegisterHam(Ham_Killed, "player", "HamF_Killed_Post", 1);

	Cvar_BotUseSkill = register_cvar("bte_zb3_bot_use_skill", "1")

	gmsgTextMsg = get_user_msgid("TextMsg");
}

public plugin_precache()
{
	precache_sound(SOUND_SKILL_START);
}

public Forward_PlayerPostThink(id)
{
	if (pev(id, pev_deadflag) != DEAD_NO)
		return FMRES_IGNORED;

	if (bte_get_user_zombie(id) == 1)
		return FMRES_IGNORED;

	switch(g_iSpeedUpStatus[id])
	{
		case 1: set_pev(id, pev_maxspeed, SPEEDUP_1);
		case 2: set_pev(id, pev_maxspeed, SPEEDUP_2);
	}

	return FMRES_IGNORED;
}

public plugin_natives()
{
	register_native("bte_hms_get_skillstat","Native_get_skillstat",1)
}

public Native_get_skillstat(id)
{
	new iReturn
	if (g_using[id][HS_HS]) iReturn|=(1<<HS_HS)
	if (g_using[id][HS_SP] || g_iSpeedUpStatus[id]) iReturn|=(1<<HS_SP)
	return iReturn
}

public bte_zb_infected(id,inf)
{
	ClearStat(id)
}

public HamF_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if (!is_user_alive(attacker) || !is_user_alive(victim)) return HAM_IGNORED
	if (bte_get_user_zombie(attacker) == 1) return HAM_IGNORED

	if (is_user_bot(attacker) && !(damage_type & (1<<24)) && get_pcvar_num(Cvar_BotUseSkill) && g_fBotCanUseSkill[attacker] <= get_gametime())
	{
		new Float:vVictim[3], Float:vAttacker[3];
		pev(victim, pev_origin, vVictim);
		pev(attacker, pev_origin, vAttacker);

		new Float:fDistance;
		fDistance = xs_vec_len(vVictim);

		if (fDistance < 200.0)
			check_speed(attacker);

		if (fDistance < 600.0 && get_user_weapon(attacker) != CSW_KNIFE)
			check_shoot(attacker);

		new Float:fHealth, Float:fMaxHealth;
		pev(victim, pev_health, fHealth);
		pev(victim, pev_max_health, fMaxHealth);

		if (get_user_weapon(attacker) != CSW_KNIFE)
		{
			if (fHealth < fMaxHealth * 0.5)
				check_shoot(attacker)
		}
	}

	return HAM_IGNORED
}

public ClearStat(id)
{
	for (new j=0;j<2;j++)
	{
		g_can_use[id][j] = 0
		g_using[id][j] = 0
	}
	g_iSpeedUpStatus[id] = 0;
	g_bBuffSG552Duanged[id] = 0;
	g_flAdrShootWaitTime[id] = 0.0;

	if (task_exists(id + 4841))
		remove_task(id + 4841);
	//if (task_exists(id))
		//remove_task(id);
	if (task_exists(id + TASK_SOUND))
		remove_task(id + TASK_SOUND);
}

public Event_HLTV()
{
	for (new i=1;i<33;i++)
	{
		g_fBotCanUseSkill[i] = get_gametime() + random_float(20.0, 60.0);
		ClearStat(i)
		if (task_exists(i))
			remove_task(i);
	}
	g_bCanUseSkill = 0;
}

public check_speed(id)
{
	if (bte_get_user_zombie(id)==1) return
	if (!g_bCanUseSkill)
	{
		ClientPrint(id, HUD_PRINTCENTER, "#HumanSkillRoundStart");
		return
	}
	if (g_can_use[id][HS_SP])
	{
		ClientPrint(id, HUD_PRINTCENTER, "#SpeedUpUsed");
		return
	}

	MetahookMsg(id, 13);

	emit_sound(id, CHAN_ITEM, SOUND_SKILL_START, 1.0, ATTN_NORM, 0, PITCH_NORM);

	g_can_use[id][HS_SP] = g_using[id][HS_SP] = 1
	new Param[2]
	Param[0] = id
	Param[1] = HS_SP
	g_iSpeedUpStatus[id] = 1;
	set_task(SPEEDUP_TIME + float(BTE_HostOwnBuffAWP()),"Task_RemoveSkill",id,Param,2)
	set_task (1.0,"Task_LoopSound", id+TASK_SOUND,"",0,"a",floatround(SPEEDUP_TIME+SPEEDUP_SLOWDOWN_TIME))
}

public Task_LoopSound(taskid)
{
	new id = taskid - TASK_SOUND
	new sound[32]
	if (bte_get_user_zombie(id) == 1) remove_task(taskid)
	if (g_using[id][HS_SP])
	{
		copy(sound,31,HEART_BEAT)
	}
	else if (g_iSpeedUpStatus[id])
	{
		new sex = bte_get_user_sex(id)
		if (sex == 1)
			copy(sound,31,SPEEDUP_BREATH_MALE)
		else
			copy(sound,31,SPEEDUP_BREATH_FEMALE)
	}
	PlaySound(id,sound)
}

public check_shoot(id)
{
	if (bte_get_user_zombie(id) == 1) return
	if (!g_bCanUseSkill)
	{
		ClientPrint(id, HUD_PRINTCENTER, "#CSO_CantHeadShotNotStart");
		return
	}

	if (!BTE_HostOwnBuffSG552())
	{
		if (g_can_use[id][HS_HS])
		{
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_CantHeadShotUsed");
			return
		}
	}
	else
	{
		if (g_bBuffSG552Duanged[id] >= 2 || g_using[id][HS_HS])
		{
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_CantHeadShotUsed");
			return;
		}
		else if (g_flAdrShootWaitTime[id] > get_gametime())
		{
			static time[3];
			format(time, 2, "%d", floatround(g_flAdrShootWaitTime[id] - get_gametime()));
			ClientPrint(id, HUD_PRINTCENTER, "#CSO_WaitSkillCoolTime", time);
			return;
		}
	}

	emit_sound(id, CHAN_ITEM, SOUND_SKILL_START, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	MetahookMsg(0, 12, id);

	g_can_use[id][HS_HS] = g_using[id][HS_HS] = 1

	new Param[2]
	Param[0] = id
	Param[1] = HS_HS
	set_task(ACCSHOOT_TIME + float(BTE_HostOwnBuffM4()),"Task_RemoveSkill",id,Param,2)
}

public Task_RemoveSkill(Param[])
{
	new id = Param[0];
	g_using[id][Param[1]] = 0

	if (Param[1] == HS_HS)
	{
		if (BTE_HostOwnBuffSG552())
		{
			g_bBuffSG552Duanged[id]++;
			if (g_bBuffSG552Duanged[id] < 2 && bte_get_user_zombie(id) != 1)
			{
				g_flAdrShootWaitTime[id] = get_gametime() + 30.0;
				MetahookMsg(id, 46, 30);
			}
			else
			{
				MetahookMsg(id, 14, 0);
			}
		}
		else
		{
			MetahookMsg(id, 14, 0);
		}
	}

	if (Param[1] == HS_SP)
	{
		set_task(SPEEDUP_SLOWDOWN_TIME, "Task_ResetMaxspeed", id + 4841)
		g_iSpeedUpStatus[id] = 2;
		MetahookMsg(id, 14, 1);
	}
}

new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame
public Task_ResetMaxspeed(taskid)
{
	new id = taskid - 4841
	remove_task(id)
	g_iSpeedUpStatus[id] = 0;

	if (is_user_alive(id))
		ExecuteHam(Ham_Player_ResetMaxSpeed, id);
}
//native bte_zb3_is_boomer_skilling(id)

public HamF_TraceAttack(iVictim, iAttacker, Float:flDamage, Float:vecDir[3], ptr, bitsDamageType)
{
	if (!(bitsDamageType & (DMG_BULLET)))
		return HAM_IGNORED;

	if (g_using[iAttacker][HS_HS])
		set_tr2(ptr, TR_iHitgroup, HIT_HEAD);

	//if (bte_zb3_is_boomer_skilling(iVictim))
	//	set_tr2(ptr, TR_iHitgroup, 0);

	return HAM_IGNORED;
}

public HamF_Killed_Post(iVictim, iAttacker, iShouldGib)
{
	if (0 < iAttacker < 33 && is_user_connected(iAttacker))
		if (g_using[iAttacker][HS_HS])
			g_bBuffSG552Duanged[iAttacker] = 1;
}

public client_putinserver(id)
{
	if (g_ham) return
	new classname[32]
	pev(id,pev_classname,classname,31)
	if (!equal(classname,"player") && is_user_zbot(id))
	{
		set_task(1.0,"RegHam",id)
	}
}
stock is_user_zbot(id)
{
	if (!is_user_bot(id))
		return 0;

	new tracker[2], friends[2], ah[2];
	get_user_info(id,"tracker",tracker,1);
	get_user_info(id,"friends",friends,1);
	get_user_info(id,"_ah",ah,1);

	if (tracker[0] == '0' && friends[0] == '0' && ah[0] == '0')
		return 0; // PodBot / YaPB / SyPB

	return 1; // Zbot
}
public RegHam(id)
{
	if (g_ham) return
	g_ham = 1

	RegisterHamFromEntity(Ham_TakeDamage,id, "HamF_TakeDamage")
	RegisterHamFromEntity(Ham_TraceAttack, id, "HamF_TraceAttack");
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed_Post", 1);
}

stock CreateSprEntity(id, iClass)
{
	for (new i=1;i<33;i++)
	{
		if (is_user_connected(i))
		{
			MH_SendZB3Data(i, 13 + iClass, id)
		}
	}
}

stock PlaySound(id, const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
	{
		client_cmd(id,"mp3 stop")
		client_cmd(id, "mp3 play sound/%s", sound)
	}
	else
		client_cmd(id, "spk %s", sound)
}

stock ClientPrint(id, type, message[], str1[] = "", str2[] = "", str3[] = "", str4[] = "")
{
	new dest
	if (id) dest = MSG_ONE_UNRELIABLE
	else dest = MSG_ALL

	message_begin(dest, gmsgTextMsg, {0, 0, 0}, id)
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