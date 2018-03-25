#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <round_terminator>
#include "bte_api.inc"
#include "offset.inc"
#include "inc.inc"
#include "bte.inc"
#include "cdll_dll.h"

#define PLUGIN "BTE Zombie Mod"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

new g_hamczbots, bot_quota;
new g_bRoundStart, g_bLastPlayer;

new g_iZombie[33], g_iClass[33], g_iLevel[33], g_iLastHuman[33];
new Float:g_flMaxHealth[33], Float:g_flSpeed[33], Float:g_flXDamage[33], Float:g_flAttack[33];

new gmsgTeamInfo, gmsgTextMsg, gmsgNVGToggle, gmsgStatusIcon;

new g_fw_UserInfected, g_fw_DummyResult;

new Float:HUMAN_HEALTH, Float:HUMAN_ARMOR, Float:HUMAN_GRAVITY;
new Float:LASTHUMAN_HEALTH, Float:LASTHUMAN_ARMOR, Float:LASTHUMAN_GRAVITY, Float:LASTHUMAN_SPEED;
new Float:ZOMBIE_SPEED, Float:ZOMBIE_HEALTH_MIN, Float:ZOMBIE_HEALTH_MIN_START, ZOMBIE_NUM_PRE, Float:ZOMBIE_HEALTH_PRE_START, Float:ZOMBIE_KILL_AWARD, Float:ZOMBIE_VICTIM_HP, Float:ZOMBIE_GRAVITY, Float:ZOMBIE_KILLED_HP, Float:ZOMBIE_ATTACK_VM, Float:ZOMBIE_ATTACK_AWARD;

new g_EnteredBuyMenu[33];

#define PRINT(%1) client_print(1,print_chat,%1)

#include "BTE_Zombie_Breakout_2.sma"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");
	register_logevent("LogEvent_RoundStart", 2, "1=Round_Start");
	register_logevent("LogEvent_RoundEnd", 2, "1=Round_End");

	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage");
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage_Post", TRUE);
	RegisterHam(Ham_Killed, "player", "HamF_Killed");
	RegisterHam(Ham_Killed, "player", "HamF_Killed_Post", TRUE);
	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player");
	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player_Post", TRUE);

	RegisterHam(Ham_Touch, "weaponbox", "HamF_TouchWeaponBox");

	register_forward(FM_PlayerPostThink, "Forward_PlayerPostThink", TRUE);
	register_forward(FM_ClientKill, "Forward_ClientKill");

	bot_quota = get_cvar_pointer("bot_quota");

	gmsgTeamInfo = get_user_msgid("TeamInfo");
	gmsgTextMsg = get_user_msgid("TextMsg");
	gmsgNVGToggle = get_user_msgid("NVGToggle");
	gmsgStatusIcon = get_user_msgid("StatusIcon");

	set_msg_block(gmsgNVGToggle, BLOCK_SET);
	set_msg_block(gmsgStatusIcon, BLOCK_SET);

	register_message(gmsgTextMsg, "Message_TextMsg");

	g_fw_UserInfected = CreateMultiForward("bte_zb_infected", ET_IGNORE, FP_CELL, FP_CELL);

	server_cmd("mp_autoteambalance 0");
}

public plugin_cfg()
{
	new cfgdir[32]
	get_configsdir(cfgdir, charsmax(cfgdir))

	server_cmd("exec %s/%s", cfgdir, "bte_zombiemod_breakout.cfg")
}

new g_zombie_index_origin, g_zombie_index_host

public plugin_precache()
{
	LoadCfg();

	precache_sound("zombi/human_death_01.wav");
	precache_sound("zombi/human_death_02.wav");
	precache_sound("zombi/human_death_female_01.wav");
	precache_sound("zombi/human_death_female_02.wav");

	engfunc(EngFunc_PrecacheModel, "models/v_knife_tank_zombi.mdl");
	g_zombie_index_host = engfunc(EngFunc_PrecacheModel, "models/player/tank_zombi_host/tank_zombi_host.mdl");
	g_zombie_index_origin = engfunc(EngFunc_PrecacheModel, "models/player/tank_zombi_origin/tank_zombi_origin.mdl");
}

public plugin_natives()
{
	register_native("bte_get_user_zombie", "native_get_user_zombie", 1);
	register_native("bte_get_zombie_sex", "native_get_sex", 1);
	register_native("bte_zse_get_level", "native_get_level", 1);
	register_native("bte_zse_set_maxspeed", "native_set_maxspeed", 1);
	register_native("bte_zse_set_xdamage", "native_set_xdamage", 1);
	register_native("bte_zse_set_attack", "native_set_attack", 1);
}

public native_set_attack(id, Float:attack)
{
	g_flAttack[id] = attack;
}

public native_set_xdamage(id, Float:xdamage)
{
	g_flXDamage[id] = xdamage;
}

public native_set_maxspeed(id, Float:speed)
{
	g_flSpeed[id] = speed;
}

public native_get_level(id)
{
	return g_iLevel[id];
}

public native_get_user_zombie(id)
{
	if (id < 1 || id > 32)
		return 0;

	return g_iZombie[id];
}

public native_get_sex(id)
{
	return ((g_iClass[id] == 1) ? 1 : 0) + 1;
}

public client_putinserver(id)
{
	g_EnteredBuyMenu[id] = 0;

	if (!g_hamczbots && is_user_bot(id) && get_pcvar_num(bot_quota) > 0)
	{
		if (!task_exists(id + TASK_HAM_BOT))
			set_task(0.4, "RegisterBotHam", id + TASK_HAM_BOT);
	}

	if (CountPlayer(0) <= 2)
	{
		server_cmd("sv_noroundend 0");
		TerminateRound(RoundEndType_Draw, TeamWinning_None);
	}
}

native PlayerSpawn(id);

public Event_HLTV()
{
	g_bRoundStart = FALSE;
	g_bLastPlayer = FALSE;

	server_cmd("mp_autoteambalance 0");
	client_cmd(0, "nvgoff");

	for (new id=1; id<=32; id++)
	{
		ResetValue(id);
	}

	PlayerSpawn(0);
}

public LogEvent_RoundStart()
{
	if (task_exists(TASK_MAKEZOMBIE)) remove_task(TASK_MAKEZOMBIE);

	if (CountPlayer(0) >= 2)
	{
		set_task(20.0, "MakeFirstZombie", TASK_MAKEZOMBIE);

		server_cmd("sv_noroundend 1");
		client_cmd(0, "zb_roundstart");
	}
}

public LogEvent_RoundEnd()
{
	g_bRoundStart = FALSE;

	server_cmd("sv_noroundend 0");
}

public MakeFirstZombie()
{
	new iInGame = CountPlayer(0, TRUE);

	if (iInGame <= 1)
		return;

	new iZombieNum = iInGame / ZOMBIE_NUM_PRE + 1;

	new Float:fMaxHealth;
	new iX = iInGame / iZombieNum;
	fMaxHealth = ZOMBIE_HEALTH_PRE_START * iX + ZOMBIE_HEALTH_MIN_START;

	while (iZombieNum)
	{
		new id = random_num(1, iInGame);
		if (is_user_alive(id) && is_user_connected(id) && !g_iZombie[id])
		{
			/*if (is_user_bot(id))
				g_iClass[id] = random_num(0, g_iZombieClassCount - 1);*/

			g_iLevel[id] = 2;
			MakeZombie(id);

			set_pev(id, pev_health, fMaxHealth);
			set_pev(id, pev_max_health, fMaxHealth);
			set_pev(id, pev_armorvalue, fMaxHealth / 10.0);
			set_pdata_int(id, m_iKevlar, 2);

			g_flMaxHealth[id] = fMaxHealth;

			iZombieNum--;

			bte_wpn_set_knockback(id, 0.7);
			bte_wpn_set_vm(id, 0.7);
			g_flXDamage[id] = 0.9;

			/*g_bCanUseSkill[id] = FALSE;

			if (task_exists(id + TASK_SHOWINGMENU))
				remove_task(id + TASK_SHOWINGMENU);

			set_task(5.0, "SetCanUseSkill", id + TASK_SHOWINGMENU);*/

			UTIL_TutorText(id, "#CSBTE_Totur_ZSE_FirstZombie", 1 << 1, 5.0);
			//client_print(id, print_chat, "你已被选为母体僵尸，杀死所有人类！");
		}
	}

	g_bRoundStart = TRUE;

	for (new id = 1; id<33; id ++)
	{
		if (is_user_alive(id) && !g_iZombie[id])
			UTIL_TutorText(id, "#CSBTE_Totur_ZSE_RoundStart", 1 << 0, 3.5);
	}
	//client_print(0, print_chat, "侦测到区域内有感染体反应，幸存者请坚持到救援到达，最后将对区域进行肃清处理！");
}

public MakeZombie(id)
{
	client_cmd(id, "nvgon");

	g_iZombie[id] = TRUE;
	g_flSpeed[id] = ZOMBIE_SPEED;
	g_flXDamage[id] = 1.0;

	StripWeapon(id);
	bte_wpn_give_named_wpn(id, "knife", FALSE);

	SetTeam(id, TEAM_TERRORIST);

	if (g_flMaxHealth[id] < ZOMBIE_HEALTH_MIN)
		g_flMaxHealth[id] = ZOMBIE_HEALTH_MIN;

	set_pev(id, pev_health, g_flMaxHealth[id]);
	set_pev(id, pev_max_health, g_flMaxHealth[id]);
	set_pev(id, pev_skin, 0);
	set_pev(id, pev_gravity, ZOMBIE_GRAVITY);
	set_pev(id, pev_weaponmodel, 0);

	/*set_pdata_int(id, m_iKevlar, 2);
	set_pev(id, pev_armorvalue, g_flMaxHealth[id] / 10.0);*/

	set_pev(id, pev_viewmodel2, "models/v_knife_tank_zombi.mdl");
	SetPlayerModel(id);

	ExecuteForward(g_fw_UserInfected, g_fw_DummyResult, id, 0);
}

stock SetPlayerModel(id)
{
	if (g_iLevel[id] == 2)
	{
		bte_set_user_model(id, "tank_zombi_origin");
		bte_set_user_model_index(id, g_zombie_index_origin);
	}
	else
	{
		bte_set_user_model(id, "tank_zombi_host");
		bte_set_user_model_index(id, g_zombie_index_host);
	}
}

native BTE_MVPBoard(iWinningTeam, iType, iPlayer = 0);

public ZombieWin()
{
	server_cmd("sv_noroundend 0");
	TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Terrorist);
	BTE_MVPBoard(1, 0);
}

public Forward_PlayerPostThink(id)
{
	if (!is_user_alive(id))
		return;

	if (g_iZombie[id])
		set_pev(id, pev_maxspeed, g_flSpeed[id]);

	if (g_iLastHuman[id])
		set_pev(id, pev_maxspeed, LASTHUMAN_SPEED);
}

public Forward_ClientKill(id)
{
	return FMRES_SUPERCEDE;
}

public HamF_TakeDamage(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if (!g_bRoundStart)
		return HAM_SUPERCEDE;

	if (g_iZombie[iVictim])
	{
		flDamage *= g_flXDamage[iVictim];
		SetHamParamFloat(4, flDamage);
	}

	if (iAttacker <= 32 && iAttacker >= 1)
	{
		flDamage *= g_flAttack[iAttacker];
		SetHamParamFloat(4, flDamage);
	}

	return HAM_IGNORED;
}

public HamF_TakeDamage_Post(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if (!is_user_connected(iAttacker))
		return HAM_IGNORED;

	if (g_iZombie[iAttacker] && !g_iZombie[iVictim]) // ZB attack HM
	{
		set_pdata_float(iVictim, m_flVelocityModifier, ZOMBIE_ATTACK_VM);

		new Float:flHealth;
		pev(iAttacker, pev_health, flHealth);
		set_pev(iAttacker, pev_health, flHealth + flDamage * ZOMBIE_ATTACK_AWARD); // attack award
	}

	return HAM_IGNORED;
}

public HamF_Killed(iVictim, iKiller, gib)
{
	if (!g_iZombie[iKiller] && g_iZombie[iVictim]) // HM kill ZB
	{
		if (g_iLevel[iVictim] >= 2)
			UpdateFrags(iKiller, 2);
		else
			UpdateFrags(iKiller, 1);
	}

	if (g_iZombie[iKiller] && !g_iZombie[iVictim]) // ZB kill HM
	{
		set_pdata_int(iVictim, m_iDeaths, get_pdata_int(iVictim, m_iDeaths) + 2);
		UpdateFrags(iKiller, 1);
	}
}

stock UpdateFrags(id, num)
{
	new Float:frags;
	pev(id, pev_frags, frags);
	frags += float(num);
	set_pev(id, pev_frags, frags);
}

public HamF_Killed_Post(iVictim, iKiller, gib)
{
	if (g_iZombie[iKiller] && !g_iZombie[iVictim]) // ZB kill HM
	{
		g_iZombie[iVictim] = TRUE;

		new Float:flHealth;
		pev(iKiller, pev_health, flHealth);

		g_flMaxHealth[iVictim] = flHealth * ZOMBIE_VICTIM_HP;
		g_flMaxHealth[iKiller] += ZOMBIE_KILL_AWARD;

		if (is_user_alive(iKiller))
		{
			set_pev(iKiller, pev_health, flHealth + ZOMBIE_KILL_AWARD);
			set_pev(iKiller, pev_max_health, g_flMaxHealth[iKiller]);
		}

		if (CountPlayer(TEAM_CT, TRUE) == 1)
			LastHumanCheck();
	}

	if (g_iZombie[iVictim] && g_iLevel[iVictim] == 1) // ZB dead
		g_flMaxHealth[iVictim] *= ZOMBIE_KILLED_HP;

	if (CountPlayer(TEAM_CT, TRUE) == 0)
		ZombieWin();
}

public HamF_TouchWeaponBox(weapon, id)
{
	if (!is_user_connected(id)) return HAM_IGNORED
	if (g_iZombie[id]) return HAM_SUPERCEDE
	return HAM_IGNORED
}

public HamF_Spawn_Player(id)
{
	if (!g_iZombie[id])
		set_pdata_int(id, m_iTeam, TEAM_CT);

	return HAM_IGNORED;
}

public HamF_Spawn_Player_Post(id)
{
	SetRendering(id);
	StripWeapons(id);
	bte_wpn_give_named_wpn(id, "knife", 1);

	if (!g_iZombie[id])
		MakeHuman(id);
	else
		MakeZombie(id);

	return HAM_IGNORED;
}

public LastHumanCheck()
{
	if (g_bLastPlayer)
		return;

	g_bLastPlayer = TRUE;

	for (new id = 1; id <= 32; id++)
	{
		if (!is_user_connected(id))
			continue;

		if (!is_user_alive(id))
			continue;

		if (get_pdata_int(id, m_iTeam) == TEAM_CT)
		{
			g_iLastHuman[id] = TRUE;

			set_pev(id, pev_armorvalue, LASTHUMAN_ARMOR);
			set_pev(id, pev_health, LASTHUMAN_HEALTH);
			set_pev(id, pev_max_health, LASTHUMAN_HEALTH);
			set_pev(id, pev_skin, 0);
			set_pev(id, pev_gravity, LASTHUMAN_GRAVITY);
		}
	}
}

public MakeHuman(id)
{
	bte_wpn_give_named_wpn(id, "usp", 1);
	set_pdata_int(id, m_iKevlar, 2);
	set_pev(id, pev_armorvalue, HUMAN_ARMOR);
	set_pev(id, pev_health, HUMAN_HEALTH);
	set_pev(id, pev_max_health, HUMAN_HEALTH);
	set_pev(id, pev_skin, 0);
	set_pev(id, pev_gravity, HUMAN_GRAVITY);
	
	if (!g_EnteredBuyMenu[id])
		PlayerSpawn(id);
}

public ResetValue(id)
{
	g_iLastHuman[id] = FALSE;
	g_iZombie[id] = FALSE;
	g_iLevel[id] = 1;
	g_flXDamage[id] = 1.0;
	g_flAttack[id] = 1.0;
	g_EnteredBuyMenu[id] = 1;
}

public RegisterBotHam(taskid)
{
	new id = taskid - TASK_HAM_BOT;

	if (g_hamczbots || !is_user_connected(id))
		return;

	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage");
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage_Post", TRUE);
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed");
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed_Post", TRUE);
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player");
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player_Post", TRUE);

	g_hamczbots = TRUE;
}

public Message_TextMsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))

	if (equal(textmsg, "#Game_will_restart_in") || equal(textmsg, "#Game_Commencing") || equal(textmsg, "#CTs_Win") || equal(textmsg, "#Terrorists_Win"))
	{
		if (task_exists(TASK_MAKEZOMBIE))
			remove_task(TASK_MAKEZOMBIE);

		g_bRoundStart = FALSE;
	}
	else if (equal(textmsg, "#Round_Draw"))
	{
		g_bRoundStart = FALSE;

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

#define SITTING_FILE "cstrike/addons/amxmodx/configs/bte_zse.ini"

public LoadCfg()
{
	GetPrivateProfile("Human", "HEALTH", "1000", SITTING_FILE, BTE_FLOAT, HUMAN_HEALTH);
	GetPrivateProfile("Human", "ARMOR", "100", SITTING_FILE, BTE_FLOAT, HUMAN_ARMOR);
	GetPrivateProfile("Human", "GRAVITY", "0.9", SITTING_FILE, BTE_FLOAT, HUMAN_GRAVITY);

	GetPrivateProfile("Last Human", "HEALTH", "4000", SITTING_FILE, BTE_FLOAT, LASTHUMAN_HEALTH);
	GetPrivateProfile("Last Human", "ARMOR", "1000", SITTING_FILE, BTE_FLOAT, LASTHUMAN_ARMOR);
	GetPrivateProfile("Last Human", "GRAVITY", "0.7", SITTING_FILE, BTE_FLOAT, LASTHUMAN_GRAVITY);
	GetPrivateProfile("Last Human", "MAXSPEED", "310", SITTING_FILE, BTE_FLOAT, LASTHUMAN_SPEED);

	GetPrivateProfile("Zombie", "GRAVITY", "0.7", SITTING_FILE, BTE_FLOAT, ZOMBIE_GRAVITY);
	GetPrivateProfile("Zombie", "MAXSPEED", "320", SITTING_FILE, BTE_FLOAT, ZOMBIE_SPEED);
	GetPrivateProfile("Zombie", "HEALTH_MIN", "2000", SITTING_FILE, BTE_FLOAT, ZOMBIE_HEALTH_MIN);

	GetPrivateProfile("Zombie", "NUM_PRE", "8", SITTING_FILE, BTE_INT, ZOMBIE_NUM_PRE);
	GetPrivateProfile("Zombie", "HEALTH_PRE_START", "1000", SITTING_FILE, BTE_FLOAT, ZOMBIE_HEALTH_PRE_START);
	GetPrivateProfile("Zombie", "HEALTH_MIN_START", "8000", SITTING_FILE, BTE_FLOAT, ZOMBIE_HEALTH_MIN_START);

	GetPrivateProfile("Zombie", "ATTACK_AWARD_HP", "1.0", SITTING_FILE, BTE_FLOAT, ZOMBIE_ATTACK_AWARD);
	GetPrivateProfile("Zombie", "KILL_AWARD_HP", "2000", SITTING_FILE, BTE_FLOAT, ZOMBIE_KILL_AWARD);
	GetPrivateProfile("Zombie", "KILL_VICTIM_HP", "0.5", SITTING_FILE, BTE_FLOAT, ZOMBIE_VICTIM_HP);
	GetPrivateProfile("Zombie", "KILLED_HP", "0.7", SITTING_FILE, BTE_FLOAT, ZOMBIE_KILLED_HP);

	GetPrivateProfile("Zombie", "ATTACK_VELOCITY_MODIFIER", "0.7", SITTING_FILE, BTE_FLOAT, ZOMBIE_ATTACK_VM);
}
