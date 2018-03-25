#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include "BTE_API.inc"
#include "offset.inc"
#include "cdll_dll.h"
#include "bte.inc"
#include <round_terminator>
#include <metahook>
#include <BTE_API>

#define PLUGIN  "BTE DeathMatch"
#define VERSION "1.0"
#define AUTHOR  "NN"

#define TRUE 1
#define FALSE 0

#define PRINT(%1) client_print(1,print_chat,%1)

enum (+= 100)
{
	TASK_RESPAWN = 2144,
	TASK_CHOSEWPN,
	TASK_ROUND_TIME,
	TASK_PROTECTION,
	TASK_BOT
}

new g_hamczbots = FALSE;

new g_bEndRound, /*g_bEndStart, */g_bRamdomTeam;
new Float:g_flRespawnWait, Float:g_flWeaponChooseWait, Float:g_flProtectionTime, Float:g_flRoundTime;
new g_iRoundTime;

new Float:g_vecOrigin[33][3], Float:g_vecAngles[33][3], Float:g_vecVAngle[33][3];
new g_bSaveSpawn[33];

new gmsgArmorType, gmsgClCorpse, gmsgTextMsg;

new cvar_botquota;

new g_sModelIndexDie;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_logevent("LogEvent_RoundStart", 2, "1=Round_Start");
	register_logevent("LogEvent_RoundEnd", 2, "1=Round_End");
	register_event("HLTV", "Event_RoundStart", "a", "1=0", "2=0");

	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player");
	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player_Post", TRUE);
	RegisterHam(Ham_Killed, "player", "HamF_Killed_Player");
	RegisterHam(Ham_Killed, "player", "HamF_Killed_Player_Post", TRUE);

	gmsgArmorType = get_user_msgid("ArmorType");
	gmsgClCorpse = get_user_msgid("ClCorpse");
	gmsgTextMsg = get_user_msgid("TextMsg");
	
	set_msg_block(gmsgClCorpse, BLOCK_SET);

	server_cmd("bte_wpn_buyzone 0");
	server_cmd("bte_wpn_free 1");
	server_cmd("mp_autoteambalance 0");

	cvar_botquota = get_cvar_pointer("bot_quota");
}

public plugin_precache()
{
	LoadConfig();
	g_sModelIndexDie = precache_model("sprites/sc_spshoot.spr");
}

public client_putinserver(id)
{
	if (is_user_bot(id) && !g_hamczbots && get_pcvar_num(cvar_botquota) > 0)
	{
		set_task(0.1, "Task_Register_Bot", id + TASK_BOT)
	}

	if (g_flRoundTime * 60.0 - g_iRoundTime > 20.0)
	{
		if (is_user_bot(id))
			set_task(1.0, "Task_Respawn", id + TASK_RESPAWN);
	}
}

public LogEvent_RoundEnd()
{
	g_bEndRound = TRUE;
	//g_bEndStart = FALSE;
	
	for (new id = 1; id <= 32; id++)
		if (task_exists(id + TASK_RESPAWN)) remove_task(id + TASK_RESPAWN);
}

public LogEvent_RoundStart()
{
	//g_bEndStart = TRUE;
	
	server_cmd("sv_noroundend 1");
	
	g_iRoundTime = floatround(g_flRoundTime * 60.0);
	UTIL_RoundTime(g_iRoundTime);
	set_task(1.0, "Task_RoundTime", TASK_ROUND_TIME,  _, _, "b");
}

public Event_RoundStart()
{
	g_bEndRound = FALSE;
	
	server_cmd("sv_noroundend 0");
	server_cmd("mp_autoteambalance 0");
	
	if (task_exists(TASK_ROUND_TIME)) remove_task(TASK_ROUND_TIME)
}

public bte_fw_precache_weapon_pre()
{
	bte_wpn_precache_named_weapon("m4a1");
	bte_wpn_precache_named_weapon("ak47");
}

public HamF_Killed_Player(iVictim, iKiller, gib)
{
	g_bSaveSpawn[iVictim] = TRUE;
	
	pev(iVictim, pev_origin, g_vecOrigin[iVictim]);
	pev(iVictim, pev_angles, g_vecAngles[iVictim]);
	pev(iVictim, pev_v_angle, g_vecVAngle[iVictim]);
	
	if ((pev(iVictim, pev_flags) & FL_DUCKING))
		g_vecOrigin[iVictim][2] += 18.0;
}

public HamF_Killed_Player_Post(iVictim, iKiller, gib)
{
	if (is_user_connected(iKiller))
		set_pdata_int(iVictim, m_iTeam, get_pdata_int(iKiller, m_iTeam));
	
	if (iKiller != iVictim)
		CheckRoundEnd();
	
	if (g_bEndRound)
		return;
	
	KilledEffect(iVictim);
	
	if (task_exists(iVictim + TASK_RESPAWN)) remove_task(iVictim + TASK_RESPAWN);
	set_task(g_flRespawnWait, "Task_Respawn", iVictim + TASK_RESPAWN);
}

public KilledEffect(iVictim)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, g_vecOrigin[iVictim], 0);
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, g_vecOrigin[iVictim][0])
	engfunc(EngFunc_WriteCoord, g_vecOrigin[iVictim][1])
	engfunc(EngFunc_WriteCoord, g_vecOrigin[iVictim][2] + 20.0)
	write_short(g_sModelIndexDie)
	write_byte(8)
	write_byte(10)
	write_byte(TE_EXPLFLAG_NOSOUND | TE_EXPLFLAG_NOPARTICLES)
	message_end()
}

public HamF_Spawn_Player(id)
{
	RandomTeam();
}

public HamF_Spawn_Player_Post(id)
{
	SetProtection(id);
	SetKevlar(id, 2, 100.0);
	
	new iTeam = get_pdata_int(id, m_iTeam);
	GiveWeapons(id, iTeam);
	SetPlayerModel(id, iTeam);
	
	SetSpawnPoint(id);
}

public GiveWeapons(id, iTeam)
{
	if (iTeam == TEAM_CT)
		bte_wpn_give_named_wpn(id, "m4a1", 0);
	else
		bte_wpn_give_named_wpn(id, "ak47", 0);
}

native bte_set_user_sex(id, sex)

public SetPlayerModel(id, iTeam)
{
	new model[16];
	if (iTeam == TEAM_CT)
	{
		switch (random_num(0, 3))
		{
			case 0 : format(model, charsmax(model), "urban");
			case 1 : format(model, charsmax(model), "gsg9");
			case 2 : format(model, charsmax(model), "sas");
			case 3 : format(model, charsmax(model), "gign");
		}
	}
	else
	{
		switch (random_num(0, 3))
		{
			case 0 : format(model, charsmax(model), "terror");
			case 1 : format(model, charsmax(model), "leet");
			case 2 : format(model, charsmax(model), "arctic");
			case 3 : format(model, charsmax(model), "guerilla");
		}
	}
	
	bte_set_user_sex(id, 1);
	bte_set_user_model(id, model);
}

public SetSpawnPoint(id)
{
	if (!g_bSaveSpawn[id])
		return;
	
	new hull;
	hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN;
	
	if (!CheckHull(g_vecOrigin[id], hull))
	{
		client_print(id, print_chat, "你不能在当前位置复活，已更换出生点。");
		return;
	}
	
	set_pev(id, pev_origin, g_vecOrigin[id]);
	set_pev(id, pev_angles, g_vecAngles[id]);
	set_pev(id, pev_v_angle, g_vecVAngle[id]);
}

public bte_player_model_change(id)
{
	if (g_flRoundTime * 60.0 - g_iRoundTime > 20.0)
	{
		if (task_exists(id + TASK_RESPAWN)) remove_task(id + TASK_RESPAWN);
		set_task(g_flRespawnWait, "Task_Respawn", id + TASK_RESPAWN);
	}
}

public Task_RoundTime()
{
	if (!g_iRoundTime)
	{
		SetEndRound( RoundEndType_Draw, TeamWinning_None );
		remove_task(TASK_ROUND_TIME)
		return;
	}
	UTIL_RoundTime(g_iRoundTime);

	g_iRoundTime --;
}

public Task_Respawn(taskid)
{
	new id = taskid - TASK_RESPAWN;
	
	if (!is_user_connected(id))
		return;
	
	ExecuteHamB(Ham_CS_RoundRespawn, id);
}

public Task_RemoveProtection(taskid)
{
	new id = taskid - TASK_PROTECTION;

	if (!is_user_connected(id))
		return;

	RemoveProtection(id);
}

public Task_Register_Bot(taskid)
{
	new id = taskid - TASK_BOT;

	if (g_hamczbots || !is_user_connected(id) || !get_pcvar_num(cvar_botquota)) return

	//RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player");
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed_Player");
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed_Player_Post", TRUE);
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player_Post", TRUE);
	g_hamczbots = TRUE;
}

public CountPlayer(iTeam)
{
	new iPlayer;
	
	for (new id = 1; id <= 32; id++)
	{
		if (!is_user_connected(id))
			continue;
		
		if (get_pdata_int(id, m_iTeam) == iTeam)
			iPlayer ++;
	}
	
	return iPlayer;
}

public LastPlayer(iTeam)
{
	for (new id = 1; id <= 32; id++)
	{
		if (!is_user_connected(id))
			continue;
		
		if (get_pdata_int(id, m_iTeam) == iTeam)
			set_pev(id, pev_health, 300.0);
	}
}


public CheckRoundEnd()
{
	new iPlayerCT, iPlayerTR;
	
	iPlayerCT = CountPlayer(TEAM_CT);
	iPlayerTR = CountPlayer(TEAM_TERRORIST);
	
	if (iPlayerTR == 0 && iPlayerCT)
		SetEndRound( RoundEndType_TeamExtermination, TeamWinning_Ct );
	
	if (iPlayerCT == 0 && iPlayerTR)
		SetEndRound( RoundEndType_TeamExtermination, TeamWinning_Terrorist );
	
	if (iPlayerTR == 1 && iPlayerCT > 1)
		LastPlayer(TEAM_TERRORIST);
	
	if (iPlayerCT == 1 && iPlayerTR > 1)
		LastPlayer(TEAM_CT);
}

public SetEndRound(iType, iTeam)
{
	if (g_bEndRound)
		return;
	
	g_bEndRound = TRUE;
	g_bRamdomTeam = TRUE;
	server_cmd("sv_noroundend 0");
	
	TerminateRound(iType, iTeam);
}

public RandomTeam()
{
	if (!g_bRamdomTeam)
		return;
	
	new null[33];
	g_bSaveSpawn = null;
	
	g_bRamdomTeam = FALSE;
	
	new iTotal, bCanChange[33];
	for (new id = 1; id <= 32; id++)
	{
		if (!is_user_connected(id))
			continue;
		
		new iTeam = get_pdata_int(id, m_iTeam);
		if (iTeam != TEAM_TERRORIST && iTeam != TEAM_CT)
			continue;
		
		bCanChange[id] = TRUE;
		
		iTotal ++;
	}
	
	iTotal /= 2;
	
	while (iTotal > 0)
	{
		new id;
		while (!bCanChange[id])
		{
			id = random_num(1, 32);
		}
		
		bCanChange[id] = FALSE;
		set_pdata_int(id, m_iTeam, TEAM_TERRORIST);
		
		iTotal --;
	}
	
	for (new id = 1; id <= 32; id++)
	{
		if (bCanChange[id])
			set_pdata_int(id, m_iTeam, TEAM_CT);
	}
}

stock CheckHull(Float:origin[3], hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)
	
	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

stock SetKevlar(id, iKevlar, Float:armorvalue)
{
	new bSendMsg;
	bSendMsg = get_pdata_int(id, m_iKevlar) != iKevlar && iKevlar == 2;
	
	set_pdata_int(id, m_iKevlar, iKevlar);
	set_pev(id, pev_armorvalue, armorvalue);
	
	if (bSendMsg)
	{
		message_begin(MSG_ONE, gmsgArmorType, _, id);
		write_byte(iKevlar == 2);
		message_end();
	}
}

stock SetProtection(id)
{
	set_pev(id, pev_takedamage, DAMAGE_NO);

	SetRandering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 10);

	if (task_exists(id + TASK_PROTECTION)) remove_task(id + TASK_PROTECTION)
	set_task(g_flProtectionTime, "Task_RemoveProtection", id + TASK_PROTECTION);
}

stock RemoveProtection(id)
{
	set_pev(id, pev_takedamage, DAMAGE_AIM);

	SetRandering(id);
}

stock SetRandering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
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

stock UTIL_RoundTime(seconds)
{
	message_begin(MSG_ALL, get_user_msgid("RoundTime"));
	write_short(seconds);
	message_end();
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

#define SITTING_FILE "cstrike/addons/amxmodx/configs/bte_teamdeathmatch2.ini"
#define CONFIG_VALUE "Config Value"

public LoadConfig()
{
	GetPrivateProfile(CONFIG_VALUE, "ROUND_TIME", 		"10", 	SITTING_FILE, BTE_FLOAT, g_flRoundTime);
	GetPrivateProfile(CONFIG_VALUE, "RESPAWN_WAIT", 	"0.1", 	SITTING_FILE, BTE_FLOAT, g_flRespawnWait);
	GetPrivateProfile(CONFIG_VALUE, "CHOOSEWPN_WAIT", 	"2.0", 	SITTING_FILE, BTE_FLOAT, g_flWeaponChooseWait);
	GetPrivateProfile(CONFIG_VALUE, "PROTECTION_TIME", 	"0.5", 	SITTING_FILE, BTE_FLOAT, g_flProtectionTime);
}
