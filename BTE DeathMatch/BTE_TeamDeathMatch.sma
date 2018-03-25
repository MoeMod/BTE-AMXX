#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <orpheu>
#include "BTE_API.inc"
#include "offset.inc"
#include "cdll_dll.h"
#include "bte.inc"
#include <round_terminator>
#include <metahook>

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

new g_bEndRound;
new g_iTickets_CT, g_iTickets_T, g_iTickets;
new Float:g_flRespawnWait, Float:g_flWeaponChooseWait, Float:g_flProtectionTime, Float:g_flRoundTime;
new g_sWeapon[33][4][32];
new g_iRoundTime;

new gmsgArmorType, gmsgClCorpse, gmsgTextMsg;

new g_fwHamBotRegister;
new cvar_botquota;

new g_pGameRules

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_logevent("LogEvent_RoundStart", 2, "1=Round_Start");
	register_logevent("LogEvent_RoundEnd", 2, "1=Round_End");
	register_event("HLTV", "Event_RoundStart", "a", "1=0", "2=0");
	register_event("DeathMsg", "Event_Death", "a");
	register_clcmd("bte_dm_set_weapon","Cmd_SetWeapons");
	register_clcmd("bte_dm_buy","Cmd_GiveWeapons");

	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player_Post", TRUE);

	g_fwHamBotRegister = register_forward(FM_PlayerPostThink, "fw_BotRegisterHam", 1)
	
	gmsgArmorType = get_user_msgid("ArmorType");
	gmsgClCorpse = get_user_msgid("ClCorpse");
	gmsgTextMsg = get_user_msgid("TextMsg");

	set_msg_block(gmsgClCorpse, BLOCK_SET);

	server_cmd("bte_wpn_buyzone 0");
	server_cmd("bte_wpn_free 1");

	cvar_botquota = get_cvar_pointer("bot_quota");
}

public fw_BotRegisterHam(id)
{
	if (!is_user_zbot(id) || get_pcvar_num(cvar_botquota) <= 0) 
		return
	unregister_forward(FM_PlayerPostThink, g_fwHamBotRegister, 1)
	
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player_Post", TRUE);
}

public plugin_precache()
{
	LoadConfig();
	OrpheuRegisterHook(OrpheuGetFunction("InstallGameRules"), "OnInstallGameRules", OrpheuHookPost)
}

public OrpheuHookReturn:OnInstallGameRules()
{
	g_pGameRules = OrpheuGetReturn();
	
	OrpheuRegisterHook(OrpheuGetFunctionFromObject(g_pGameRules, "CheckWinConditions", "CGameRules"), "OnCheckWinConditions")
}

public OrpheuHookReturn:OnCheckWinConditions(this)
{
	return OrpheuSupercede
}

public client_putinserver(id)
{
	if (g_flRoundTime * 60.0 - g_iRoundTime > 20.0)
	{
		if (is_user_bot(id))
			set_task(1.0, "Task_Respawn", id + TASK_RESPAWN);
	}
}

public LogEvent_RoundEnd()
{
	g_bEndRound = TRUE;
}

public LogEvent_RoundStart()
{

	g_iRoundTime = floatround(g_flRoundTime * 60.0);
	UTIL_RoundTime(g_iRoundTime);
	set_task(1.0, "Task_RoundTime", TASK_ROUND_TIME,  _, _, "b");
}

public Event_RoundStart()
{
	g_bEndRound = FALSE;
	g_iTickets_CT = 0;
	g_iTickets_T = 0;


	if (task_exists(TASK_ROUND_TIME)) remove_task(TASK_ROUND_TIME)

	for (new id = 1; id <= get_maxplayers(); id++)
	{
		if (!is_user_bot(id))
			GiveWeapons(id);
		//client_cmd(id, "teamsuit");
	}
}

public HamF_Spawn_Player_Post(id)
{
	UpdateScore();

	SetProtection(id);
	SetKevlar(id, 2, 100.0);

	if (!is_user_bot(id))
	{
		GiveWeapons(id);
		/*{
		Strip_Weapon(id);
		bte_wpn_give_named_wpn(id, "knife", 1);
		//GiveWeapons(id);
		client_cmd(id, "teamsuit");
		}*/
	}
}

public GiveWeapons(id)
{
	for (new i=0; i<4; i++)
		if (g_sWeapon[id][i][0])
			bte_wpn_give_named_wpn(id, g_sWeapon[id][i], 1);
}
public Cmd_GiveWeapons(id)
{
	GiveWeapons(id);

	/*if (!is_user_alive(id))
		ExecuteHamB(Ham_CS_RoundRespawn, id);*/

	return PLUGIN_HANDLED;
}
public Cmd_SetWeapons(id)
{
	new sWeapon[32];
	read_argv(1, sWeapon, 31);
	format(g_sWeapon[id][0], 31, "%s", sWeapon);

	read_argv(2, sWeapon, 31);
	format(g_sWeapon[id][1], 31, "%s", sWeapon);

	read_argv(3, sWeapon, 31);
	format(g_sWeapon[id][2], 31, "%s", sWeapon);

	read_argv(4, sWeapon, 31);
	format(g_sWeapon[id][3], 31, "%s", sWeapon);

	return PLUGIN_HANDLED;
}

public bte_player_model_change(id)
{
	if (g_flRoundTime * 60.0 - g_iRoundTime > 20.0)
	{
		if (task_exists(id + TASK_RESPAWN)) remove_task(id + TASK_RESPAWN);
		set_task(g_flRespawnWait, "Task_Respawn", id + TASK_RESPAWN);
	}

	if (task_exists(id + TASK_CHOSEWPN)) remove_task(id + TASK_CHOSEWPN);
	set_task(0.5, "Task_ChooseWpn", id + TASK_CHOSEWPN);
}

public Event_Death()
{
	new iKiller = read_data(1);
	new iVictim = read_data(2);

	MH_RespawnBar(iVictim, 1, g_flRespawnWait);

	new team_k = get_pdata_int(iKiller, m_iTeam);
	new team_v = get_pdata_int(iVictim, m_iTeam);

	if (team_k == TEAM_CT && team_v == TEAM_TERRORIST)
		g_iTickets_CT += 1;
	else if (team_k == TEAM_TERRORIST && team_v == TEAM_CT)
		g_iTickets_T += 1;

	CheckRoundEnd();
	UpdateScore();

	if (task_exists(iVictim + TASK_RESPAWN)) remove_task(iVictim + TASK_RESPAWN);
	set_task(g_flRespawnWait, "Task_Respawn", iVictim + TASK_RESPAWN);

	if (task_exists(iVictim + TASK_CHOSEWPN)) remove_task(iVictim + TASK_CHOSEWPN);
	set_task(g_flWeaponChooseWait, "Task_ChooseWpn", iVictim + TASK_CHOSEWPN);

	return PLUGIN_CONTINUE;
}

public Task_RoundTime()
{
	if (!g_iRoundTime)
	{
		SetEndRound();
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

public Task_ChooseWpn(taskid)
{
	new id = taskid - TASK_CHOSEWPN;

	if (!is_user_connected(id))
		return;

	client_cmd(id, "teamsuit");
}

public Task_RemoveProtection(taskid)
{
	new id = taskid - TASK_PROTECTION;

	if (!is_user_connected(id))
		return;

	RemoveProtection(id);
}

public CheckRoundEnd()
{
	if (g_iTickets_CT >= g_iTickets || g_iTickets_T >= g_iTickets)
		SetEndRound();
}

public SetEndRound()
{
	if (g_bEndRound)
		return;

	g_bEndRound = TRUE;
	if (g_iTickets_CT > g_iTickets_T)
	{
		TerminateRound( RoundEndType_TeamExtermination, TeamWinning_Ct );
	}
	else if (g_iTickets_CT < g_iTickets_T)
	{
		TerminateRound( RoundEndType_TeamExtermination, TeamWinning_Terrorist );
	}
	else
	{
		TerminateRound( RoundEndType_Draw, TeamWinning_None );
	}
}

public UpdateScore()
{
	for(new i=1;i<33;i++)
	{
		if(is_user_connected(i))
			MH_DrawScoreBoard(i, g_iTickets_T, g_iTickets, g_iTickets_CT, 0, 0, 2);
	}
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

#define SITTING_FILE "cstrike/addons/amxmodx/configs/bte_teamdeathmatch.ini"
#define CONFIG_VALUE "Config Value"

public LoadConfig()
{
	GetPrivateProfile(CONFIG_VALUE, "TICKETS", 			"150", 	SITTING_FILE, BTE_INT,	 g_iTickets);
	GetPrivateProfile(CONFIG_VALUE, "ROUND_TIME", 		"20", 	SITTING_FILE, BTE_FLOAT, g_flRoundTime);
	GetPrivateProfile(CONFIG_VALUE, "RESPAWN_WAIT", 	"5.0", 	SITTING_FILE, BTE_FLOAT, g_flRespawnWait);
	GetPrivateProfile(CONFIG_VALUE, "CHOOSEWPN_WAIT", 	"2.0", 	SITTING_FILE, BTE_FLOAT, g_flWeaponChooseWait);
	GetPrivateProfile(CONFIG_VALUE, "PROTECTION_TIME", 	"3.0", 	SITTING_FILE, BTE_FLOAT, g_flProtectionTime);
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
