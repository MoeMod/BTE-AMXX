#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <round_terminator>
#include "bte_api.inc"
#include "offset.inc"
#include "inc.inc"
#include "BTE_Zombie_Mod2_2.sma"

#define PLUGIN "BTE Zombie Mod4"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

new g_hamczbots, bot_quota;
new g_bRoundStart;

new g_iZombie[33], g_iClass[33];

new g_fw_ZombieEmitSound, g_fw_UserInfected, g_fw_DummyResult;


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");
	register_logevent("LogEvent_RoundStart", 2, "1=Round_Start");
	register_logevent("LogEvent_RoundEnd", 2, "1=Round_End");
	
	/*RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage");
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage_Post", 1);
	RegisterHam(Ham_Killed, "player", "HamF_Killed", 1);*/
	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player");
	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player_Post", 1);
	
	/*RegisterHam(Ham_Touch, "weaponbox", "HamF_TouchWeaponBox");
	
	register_forward(FM_PlayerPostThink, "Forward_PlayerPostThink", 1);*/
	register_forward(FM_EmitSound, "Forward_EmitSound");
	register_forward(FM_ClientKill, "Forward_ClientKill");
	
	bot_quota = get_cvar_pointer("bot_quota");
	
	g_fw_ZombieEmitSound = CreateMultiForward("bte_zb_EmitSound", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_FLOAT, FP_CELL, FP_CELL);
	g_fw_UserInfected = CreateMultiForward("bte_zb_infected", ET_IGNORE, FP_CELL, FP_CELL);
}

public plugin_cfg()
{
	new cfgdir[32]
	get_configsdir(cfgdir, charsmax(cfgdir))
	
	server_cmd("exec %s/%s", cfgdir, "bte_zombiemod2.cfg")
}

public plugin_natives()
{
	register_native("bte_get_user_zombie", "native_get_user_zombie", 1);
	register_native("bte_get_zombie_sex", "native_get_sex", 1);
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
	if (!g_hamczbots && is_user_bot(id) && get_pcvar_num(bot_quota) > 0)
		set_task(0.4, "RegisterBotHam", id + TASK_HAM_BOT);
	
	if (CountPlayer(0) == 1)
	{
		server_cmd("sv_noroundend 0");
		TerminateRound(RoundEndType_Draw, TeamWinning_None);
	}
}

public Event_HLTV()
{
	g_bRoundStart = FALSE;
	
	server_cmd("mp_autoteambalance 0");
	
	for (new id=1; id<=32; id++)
	{
		ResetValue(id);
	}
}

public LogEvent_RoundStart()
{
	new Float:round_time;
	round_time = get_cvar_float("mp_roundtime") * 60.0;
	
	if (task_exists(TASK_HUMANWIN))
		remove_task(TASK_HUMANWIN);
		
	if (task_exists(TASK_MAKEZOMBIE))
		remove_task(TASK_MAKEZOMBIE);
	
	set_task(round_time, "HumanWin", TASK_HUMANWIN);
	set_task(20.0, "MakeFirstZombie", TASK_MAKEZOMBIE);
	
	server_cmd("sv_noroundend 1");
}

public LogEvent_RoundEnd()
{
	g_bRoundStart = FALSE;
	
	server_cmd("sv_noroundend 0");
	if (task_exists(TASK_HUMANWIN)) remove_task(TASK_HUMANWIN);
}

public MakeFirstZombie()
{
	new iInGame = CountPlayer(0, TRUE);
	
	if (iInGame <= 1)
		return;
	
	new iZombieNum = iInGame / 10 + 1;
	
	new Float:fMaxHealth;
	fMaxHealth = 1000.0 * iInGame / iZombieNum + 1000.0;
	fMaxHealth = fMaxHealth < 4000.0 ? 4000.0 : fMaxHealth;

	while (iZombieNum)
	{
		new id = random_num(1, iInGame);
		if (is_user_alive(id) && is_user_connected(id) && !g_iZombie[id])
		{
			/*if (is_user_bot(id))
				g_iClass[id] = random_num(0, g_iZombieClassCount - 1);
			
			MakeZombie(id);*/
			
			set_pev(id, pev_health, fMaxHealth);
			set_pev(id, pev_max_health, fMaxHealth);
			set_pev(id, pev_armorvalue, fMaxHealth / 5.0);
			
			/*iZombieNum--;
			
			g_bCanUseSkill[id] = FALSE;
			
			if (task_exists(id + TASK_SHOWINGMENU))
				remove_task(id + TASK_SHOWINGMENU);
			
			set_task(5.0, "SetCanUseSkill", id + TASK_SHOWINGMENU);*/
			
			ExecuteForward(g_fw_UserInfected, g_fw_DummyResult, id, 0);
		}
	}
	
	g_bRoundStart = TRUE;
}


public HumanWin()
{
	server_cmd("sv_noroundend 0");
	TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Ct);
}

public Forward_ClientKill(id)
{
	return FMRES_SUPERCEDE;
}

public HamF_Spawn_Player(id)
{
	if (!g_iZombie[id])
		set_pdata_int(id, m_iTeam, 2);
	
	return HAM_IGNORED;
}

public HamF_Spawn_Player_Post(id)
{
	SetRendering(id);
	StripWeapons(id);
	bte_wpn_give_named_wpn(id, "knife", 1);
	
	if (!g_iZombie[id])
		HumamSpawn(id);
	
	return HAM_IGNORED;
}

public HumamSpawn(id)
{
	bte_wpn_give_named_wpn(id, "usp", 1);
	set_pdata_int(id, m_iKevlar, 2);
	set_pev(id, pev_armorvalue, 100.0);
	set_pev(id, pev_health, 1000.0);
	set_pev(id, pev_max_health, 1000.0);
	set_pev(id, pev_skin, 0);
	set_pev(id, pev_gravity, 1.0);
}

public ResetValue(id)
{
	g_iZombie[id] = FALSE;
}

public RegisterBotHam(taskid)
{
	new id = taskid - TASK_HAM_BOT;

	if (g_hamczbots || !is_user_connected(id))
		return;

	/*RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage");
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage_Post", 1);
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed", 1);*/
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player");
	//RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player_Post",1)

	g_hamczbots = TRUE;
}
