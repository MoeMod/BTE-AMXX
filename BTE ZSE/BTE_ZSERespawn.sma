#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include "BTE_API.inc"
#include "BTE_ZSE_API.inc"
#include "offset.inc"
#include "cdll_dll.h"
#include "bte.inc"
#include <round_terminator>
#include <metahook>
#include <BTE_API>

#define PLUGIN  "BTE HumanKilledRespawn"
#define VERSION "1.0"
#define AUTHOR  "NN"

#define TRUE 1
#define FALSE 0

#define PRINT(%1) client_print(1,print_chat,%1)

enum (+= 100)
{
	TASK_RESPAWN = 5144,
	TASK_BOT
}

new g_hamczbots = FALSE;

new Float:g_vecOrigin[33][3], Float:g_vecAngles[33][3], Float:g_vecVAngle[33][3];
new g_bSaveSpawn[33];

new gmsgClCorpse, gmsgTextMsg;

new cvar_botquota;

native bte_set_block_random_spawn(id, bBlock)

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_event("HLTV", "Event_RoundStart", "a", "1=0", "2=0");
	register_logevent("LogEvent_RoundEnd", 2, "1=Round_End");

	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player");
	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player_Post", TRUE);
	RegisterHam(Ham_Killed, "player", "HamF_Killed_Player");
	RegisterHam(Ham_Killed, "player", "HamF_Killed_Player_Post", TRUE);

	gmsgClCorpse = get_user_msgid("ClCorpse");
	gmsgTextMsg = get_user_msgid("TextMsg");

	set_msg_block(gmsgClCorpse, BLOCK_SET);

	cvar_botquota = get_cvar_pointer("bot_quota");
}

public Event_RoundStart()
{
	for (new id=1; id<=32; id++)
	{
		g_bSaveSpawn[id] = FALSE;
		bte_set_block_random_spawn(id, FALSE);
	}
}

public LogEvent_RoundEnd()
{
	for (new id = 1; id <= 32; id++)
		if (task_exists(id + TASK_RESPAWN)) remove_task(id + TASK_RESPAWN);
}

public client_putinserver(id)
{
	g_bSaveSpawn[id] = FALSE;
	bte_set_block_random_spawn(id, FALSE);

	if (is_user_bot(id) && !g_hamczbots && get_pcvar_num(cvar_botquota) > 0)
	{
		if (!task_exists(id + TASK_BOT))
			set_task(0.1, "Task_Register_Bot", id + TASK_BOT)
	}
}

public HamF_Killed_Player(iVictim, iKiller, gib)
{
	if (bte_get_user_zombie(iVictim))
	{
		g_bSaveSpawn[iVictim] = FALSE;
		bte_set_block_random_spawn(iVictim, FALSE);
		return;
	}

	if (!bte_get_user_zombie(iVictim) && !bte_get_user_zombie(iKiller)) // HM kill HM
		return;

	g_bSaveSpawn[iVictim] = TRUE;

	pev(iVictim, pev_origin, g_vecOrigin[iVictim]);
	pev(iVictim, pev_angles, g_vecAngles[iVictim]);
	pev(iVictim, pev_v_angle, g_vecVAngle[iVictim]);

	if ((pev(iVictim, pev_flags) & FL_DUCKING))
		g_vecOrigin[iVictim][2] += 18.0;

	bte_set_block_random_spawn(iVictim, TRUE);
}

public HamF_Killed_Player_Post(iVictim, iKiller, gib)
{
	if (task_exists(iVictim + TASK_RESPAWN)) remove_task(iVictim + TASK_RESPAWN);

	if (!bte_get_user_zombie(iVictim) && !bte_get_user_zombie(iKiller)) // HM kill HM
		return;

	if (bte_get_user_zombie(iKiller))
	{
		if (CountPlayer(TEAM_CT) > 1) // last HM no respawn
		{
			//client_print(iVictim, print_chat, "3 秒后你将复活成为僵尸。");
			UTIL_TutorText(iVictim, "#CSBTE_Totur_ZSE_RespawnAsZombie", 1 << 1, 3.0);
			set_task(3.0, "Task_Respawn", iVictim + TASK_RESPAWN);
		}
	}
	else
	{
		if (bte_zse_get_level(iVictim) <= 1)
		{
			//client_print(iVictim, print_chat, "3 秒后复活。");
			UTIL_TutorText(iVictim, "#CSBTE_Totur_ZSE_Respawn3", 1 << 0, 3.0);
			set_task(3.0, "Task_Respawn", iVictim + TASK_RESPAWN);
		}
		else
		{
			//client_print(iVictim, print_chat, "15 秒后复活。");
			UTIL_TutorText(iVictim, "#CSBTE_Totur_ZSE_Respawn15", 1 << 0, 3.0);
			set_task(15.0, "Task_Respawn", iVictim + TASK_RESPAWN);
		}
	}
}

new const SND_ZOMBIE_INFECTION_MALE[][]={"zombi/human_death_01.wav","zombi/human_death_02.wav"}
new const SND_ZOMBIE_INFECTION_FEMALE[][]={"zombi/human_death_female_01.wav","zombi/human_death_female_02.wav"}

public HamF_Spawn_Player(id)
{
	if (!bte_get_user_zombie(id))
		return;

	if (g_bSaveSpawn[id]) // human killed respawn
	{
		new sex = bte_get_user_sex(id);
		if(sex == SEX_MALE)
			emit_sound(id, CHAN_ITEM, SND_ZOMBIE_INFECTION_MALE[random_num(0,1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		else
			emit_sound(id, CHAN_ITEM, SND_ZOMBIE_INFECTION_FEMALE[random_num(0,1)], 1.0, ATTN_NORM, 0, PITCH_NORM)

		client_cmd(0, random_num(0, 1) ? "spk vox/zombi_coming_1.wav" : "spk vox/zombi_coming_2.wav")
		set_pdata_int(id, m_iTeam, TEAM_TERRORIST);
	}
	else
	{
		client_cmd(0, "spk vox/zombi_comeback.wav")
	}
}

public HamF_Spawn_Player_Post(id)
{
	SetSpawnPoint(id);
}

public SetSpawnPoint(id)
{
	if (!g_bSaveSpawn[id])
		return;

	new hull;
	hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN;

	if (!CheckHull(g_vecOrigin[id], hull))
	{
		//client_print(id, print_chat, "你不能在当前位置复活，已更换出生点。");
		return;
	}

	set_pev(id, pev_origin, g_vecOrigin[id]);
	set_pev(id, pev_angles, g_vecAngles[id]);
	set_pev(id, pev_v_angle, g_vecVAngle[id]);
}

public Task_Respawn(taskid)
{
	new id = taskid - TASK_RESPAWN;

	if (!is_user_connected(id))
		return;

	ExecuteHamB(Ham_CS_RoundRespawn, id);
}

public Task_Register_Bot(taskid)
{
	new id = taskid - TASK_BOT;

	if (g_hamczbots || !is_user_connected(id) || !get_pcvar_num(cvar_botquota)) return

	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed_Player");
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed_Player_Post", TRUE);
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player");
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player_Post", TRUE);

	g_hamczbots = TRUE;
}

stock CountPlayer(iTeam, bAlive = FALSE)
{
	new iPlayer;

	for (new id = 1; id <= 32; id++)
	{
		if (!is_user_connected(id))
			continue;

		if (!is_user_alive(id) && bAlive)
			continue;

		new iPlayerTeam = get_pdata_int(id, m_iTeam);

		if (iPlayerTeam == TEAM_UNASSIGNED || iPlayerTeam == TEAM_SPECTATOR)
			continue;

		if (!iTeam)
			iPlayer ++;
		else if (iPlayerTeam == iTeam)
			iPlayer ++;
	}

	return iPlayer;
}

stock CheckHull(Float:origin[3], hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)

	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;

	return false;
}

stock UTIL_ClientPrint(id, type, message[], str1[] = "", str2[] = "", str3[] = "", str4[] = "")
{
	new dest
	if (id) dest = MSG_ONE
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