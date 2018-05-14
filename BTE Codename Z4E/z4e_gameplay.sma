#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <orpheu>
#include <orpheu_memory>

#include <round_terminator>

#include "z4e_bits.inc"
#include "z4e_team.inc"
#include "z4e_api.inc"
#include "z4e_zombie.inc"
#include "z4e_deathmatch.inc"

#include "../cdll_dll.h"

#define PLUGIN "[Z4E] GamePlay"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

// Game Status
enum _:MAX_GAMESTATUS
{
	Z4E_GAMESTATUS_NONE = 0,
	Z4E_GAMESTATUS_GAMESTARTED,
	Z4E_GAMESTATUS_INFECTIONSTART,
	Z4E_GAMESTATUS_ROUNDENDED,
}

new const SOUND_AMBIENCE[] = "zombie_plague/ambience.wav"
new const SOUND_START[] = "ambience/3dmstart.wav"
new const SOUND_COUNTDOWN[10][] = {
	"vox/one.wav",
	"vox/two.wav",
	"vox/three.wav",
	"vox/four.wav",
	"vox/five.wav",
	"vox/six.wav",
	"vox/seven.wav",
	"vox/eight.wav",
	"vox/nine.wav",
	"vox/ten.wav"
}
new const SOUND_WIN[3][] = {
	"zombie_plague/win_humans2.wav",
	"zombie_plague/win_humans1.wav",
	"zombie_plague/the_horror1.wav"
}

#define TASK_TIMER 8888

// Forwards
enum _:TOTAL_FORWARDS
{
	FW_PLAGUE_PRE,
	FW_PLAGUE_POST,
	FW_ROUND_NEW,
	FW_ROUND_START,
	FW_ROUNDEND_PRE,
	FW_ROUNDEND_POST,
	FW_TIMER,
}
new g_iForwards[TOTAL_FORWARDS]
new g_iForwardResult

new g_pGameRules

new g_iCountDownTime = 14

new g_bitsGameStatus, g_iTimer

// OffSet
#define PDATA_SAFE 2

new gmsgTextMsg;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	//if(x_thanatos_verify("z4e_gameplay") != 215314)
	//	pause("a");
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_event("TextMsg", "Event_GameRestart", "a", "2=#Game_will_restart_in")	
	register_logevent("Event_RoundStart", 2, "1=Round_Start")
	register_logevent("Event_RoundEnd", 2, "1=Round_End")	

	RegisterHam(Ham_TraceAttack, "player", "HamF_TraceAttack")
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage")
	
	g_iForwards[FW_ROUND_NEW] = CreateMultiForward("z4e_fw_gameplay_round_new", ET_IGNORE)
	g_iForwards[FW_ROUND_START] = CreateMultiForward("z4e_fw_gameplay_round_start", ET_IGNORE)
	g_iForwards[FW_PLAGUE_PRE] = CreateMultiForward("z4e_fw_gameplay_plague_pre", ET_CONTINUE)
	g_iForwards[FW_PLAGUE_POST] = CreateMultiForward("z4e_fw_gameplay_plague_post", ET_IGNORE)
	g_iForwards[FW_ROUNDEND_PRE] = CreateMultiForward("z4e_fw_gameplay_roundend_pre", ET_CONTINUE, FP_CELL)
	g_iForwards[FW_ROUNDEND_POST] = CreateMultiForward("z4e_fw_gameplay_roundend_post", ET_IGNORE, FP_CELL)
	g_iForwards[FW_TIMER] = CreateMultiForward("z4e_fw_gameplay_timer", ET_IGNORE)
	
	gmsgTextMsg = get_user_msgid("TextMsg");
}

public z4e_fw_api_bot_registerham(id)
{
	RegisterHamFromEntity(Ham_TraceAttack, id, "HamF_TraceAttack")
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage")
}

public plugin_precache()
{
	OrpheuRegisterHook(OrpheuGetFunction("InstallGameRules"), "OnInstallGameRules", OrpheuHookPost)
	
	//new szBuffer[64]
	//format(szBuffer, charsmax(szBuffer), "sound/%s", SOUND_AMBIENCE)
	//engfunc(EngFunc_PrecacheGeneric, szBuffer)
	engfunc(EngFunc_PrecacheSound, SOUND_AMBIENCE)
	
	//format(szBuffer, charsmax(szBuffer), "sound/%s", SOUND_START)
	//engfunc(EngFunc_PrecacheGeneric, szBuffer)
	engfunc(EngFunc_PrecacheSound, SOUND_START)
	
	for(new i = 0; i < sizeof(SOUND_COUNTDOWN); i++)
		engfunc(EngFunc_PrecacheSound, SOUND_COUNTDOWN[i])
	for(new i = 0; i < sizeof(SOUND_WIN); i++)
		engfunc(EngFunc_PrecacheSound, SOUND_WIN[i])
}

public plugin_cfg()
{
	set_cvar_num("mp_limitteams", 0)
	
	set_cvar_num("sv_maxspeed", 999)
	
	set_cvar_num("sv_skycolor_r", 0)
	set_cvar_num("sv_skycolor_g", 0)
	set_cvar_num("sv_skycolor_b", 0)
	
	remove_task(TASK_TIMER)
	set_task(1.0, "Task_Timer", TASK_TIMER, _, _, "b");
}

public plugin_natives()
{
	register_native("z4e_gameplay_bits_get_status", "Native_GetStatus", 1)
	register_native("z4e_gameplay_bits_set_status", "Native_SetStatus", 1)
	register_native("z4e_gameplay_get_timer", "Native_GetTimer", 1)
	register_native("z4e_gameplay_set_timer", "Native_SetTimer", 1)
	register_native("z4e_gameplay_get_countdowntime", "Native_GetCountdownTime", 1)
	register_native("z4e_gameplay_set_countdowntime", "Native_SetCountdownTime", 1)
}

public Native_GetStatus()
{
	return g_bitsGameStatus
}

public Native_SetStatus(bitsNew)
{
	g_bitsGameStatus = bitsNew;
}

public Native_GetTimer()
{
	return g_iTimer
}

public Native_SetTimer(x)
{
	g_iTimer = x;
}

public Native_GetCountdownTime()
{
	return g_iCountDownTime
}

public Native_SetCountdownTime(x)
{
	g_iCountDownTime = x;
}

public OrpheuHookReturn:OnInstallGameRules()
{
	g_pGameRules = OrpheuGetReturn();
	
	OrpheuRegisterHook(OrpheuGetFunctionFromObject(g_pGameRules, "FPlayerCanRespawn", "CGameRules"), "OnFPlayerCanRespawn")
	OrpheuRegisterHook(OrpheuGetFunctionFromObject(g_pGameRules, "CheckWinConditions", "CGameRules"), "OnCheckWinConditions")
}

public OrpheuHookReturn:OnCheckWinConditions(this)
{
	if(!BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_GAMESTARTED) && (z4e_team_count(Z4E_TEAM_HUMAN, 1) + z4e_team_count(Z4E_TEAM_ZOMBIE, 1) >= 2))
	{
		BitsSet(g_bitsGameStatus, Z4E_GAMESTATUS_GAMESTARTED)
		BitsUnSet(g_bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART)
		server_cmd("sv_restart 1")
	}
	
	if(BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART) && !BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED))
	{
		if(!z4e_team_count(Z4E_TEAM_ZOMBIE, 1))
		{
			ExecuteForward(g_iForwards[FW_ROUNDEND_PRE], g_iForwardResult, Z4E_TEAM_HUMAN)
			if(!g_iForwardResult)
			{
				//z4e_alarm_push(Z4E_ALARMTYPE_HUMANWIN, "人类战胜了僵尸...", "", SOUND_WIN[0], { 50,50,250 }, 6.0)
				TerminateRound( RoundEndType_TeamExtermination,TeamWinning_Ct )
				//z4e_api_terminate_round(5.0, WINSTATUS_CT)
				BitsSet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED)
				ExecuteForward(g_iForwards[FW_ROUNDEND_POST], g_iForwardResult, Z4E_TEAM_HUMAN)
			}
		}
		else if(!z4e_team_count(Z4E_TEAM_HUMAN, 1))
		{
			ExecuteForward(g_iForwards[FW_ROUNDEND_PRE], g_iForwardResult, Z4E_TEAM_ZOMBIE)
			if(!g_iForwardResult)
			{
				//z4e_alarm_push(Z4E_ALARMTYPE_ZOMBIEWIN, "僵尸统治了世界...", "", SOUND_WIN[1], { 250,50,50 }, 6.0)
				TerminateRound( RoundEndType_TeamExtermination,TeamWinning_Terrorist )
				//z4e_api_terminate_round(5.0, WINSTATUS_TERRORIST)
				BitsSet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED)
				ExecuteForward(g_iForwards[FW_ROUNDEND_POST], g_iForwardResult, Z4E_TEAM_ZOMBIE)
			}
		}
		else if(g_iTimer > OrpheuMemoryGetAtAddress(g_pGameRules, "m_iRoundTimeSecs"))
		{
			ExecuteForward(g_iForwards[FW_ROUNDEND_PRE], g_iForwardResult, Z4E_TEAM_INVALID)
			if(!g_iForwardResult)
			{
				//z4e_alarm_push(Z4E_ALARMTYPE_ROUNDDRAW, "午时已到...", "", SOUND_WIN[2], { 50,50,50 }, 6.0)
				TerminateRound( RoundEndType_TeamExtermination,TeamWinning_Ct )
				//z4e_api_terminate_round(5.0, WINSTATUS_DRAW)
				BitsSet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED)
				ExecuteForward(g_iForwards[FW_ROUNDEND_POST], g_iForwardResult, Z4E_TEAM_INVALID)
			}
		}
	}
	return OrpheuSupercede
}

public OrpheuHookReturn:OnFPlayerCanRespawn(this, id)
{
	if(BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART) || BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED))
	{
		OrpheuSetReturn(false)
	}
	else
	{
		OrpheuSetReturn(true)
	}
	return OrpheuSupercede
}
/*
public z4e_fw_team_set_pre(id, iTeam)
{
	if(BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART) && !BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED))
		return PLUGIN_CONTINUE
	if(iTeam == Z4E_TEAM_ZOMBIE)
	{
		z4e_team_set(id, Z4E_TEAM_HUMAN)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
*/
public Event_NewRound()
{
	ExecuteForward(g_iForwards[FW_ROUND_NEW], g_iForwardResult)
	
	set_cvar_num("mp_autoteambalance", 0)
	
	BitsUnSet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED)
	BitsUnSet(g_bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART)
	
	if(BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_GAMESTARTED) && BitsCount(z4e_team_bits_get_connected()) < 2)
	{
		BitsUnSet(g_bitsGameStatus, Z4E_GAMESTATUS_GAMESTARTED)
		BitsUnSet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED)
		BitsUnSet(g_bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART)
		return ;
	}
	
	g_iTimer = 0
	remove_task(TASK_TIMER)
	
	PlaySound(0, SOUND_AMBIENCE, 1)
}

public Event_RoundStart()
{
	if(!BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_GAMESTARTED) || BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED))
		return
	
	g_iTimer = 0
	
	remove_task(TASK_TIMER)
	set_task(1.0, "Task_Timer", TASK_TIMER, _, _, "b");
	
	Check_RoundStart()
	
	ExecuteForward(g_iForwards[FW_ROUND_START], g_iForwardResult)
}

public Event_RoundEnd()
{
	ExecuteForward(g_iForwards[FW_ROUNDEND_PRE], g_iForwardResult, Z4E_TEAM_INVALID)
	if(!g_iForwardResult)
	{
		BitsSet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED)
		ExecuteForward(g_iForwards[FW_ROUNDEND_POST], g_iForwardResult, Z4E_TEAM_INVALID)
	}
}

public Event_GameRestart()
{
	ExecuteForward(g_iForwards[FW_ROUNDEND_PRE], g_iForwardResult, Z4E_TEAM_INVALID)
	if(!g_iForwardResult)
	{
		BitsSet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED)
		g_iTimer = -233
		ExecuteForward(g_iForwards[FW_ROUNDEND_POST], g_iForwardResult, Z4E_TEAM_INVALID)
	}
}

public HamF_TraceAttack(iVictim, iAttacker, Float:flDamage, Float:vecDirection[3], pTr, bitsDamageType)
{
	if(!BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART) || BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED))
		return HAM_SUPERCEDE
	if(!is_user_alive(iVictim) || !is_user_alive(iAttacker))
		return HAM_IGNORED
	new Float:flHealth; pev(iVictim, pev_health, flHealth)
	if(z4e_team_get_user_zombie(iAttacker) && !z4e_team_get_user_zombie(iVictim))
	{
		set_tr2(pTr, TR_iHitgroup, HIT_CHEST)
		if(flHealth < flDamage - 1.0)
		{
			z4e_zombie_infect(iVictim, iAttacker)
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}

public HamF_TakeDamage(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if(!BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART) || BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED))
		return HAM_SUPERCEDE
	return HAM_IGNORED
}

public z4e_fw_team_spawn_act(id)
{
	if(BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART))
	{
		z4e_team_set(id, Z4E_TEAM_ZOMBIE)
	}
	else
	{
		z4e_team_set(id, Z4E_TEAM_HUMAN)
	}
	return PLUGIN_CONTINUE
}

public z4e_fw_team_set_post(id)
{
	OnCheckWinConditions(g_pGameRules)
}

public z4e_fw_deathmatch_respawn_pre(id)
{
	if(!BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART))
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public z4e_fw_deathmatch_respawn_post(id)
{
	z4e_team_set(id, Z4E_TEAM_ZOMBIE)
}

public Task_Timer()
{
	// Check Timer
	Ckeck_Timer()
	
	OnCheckWinConditions(g_pGameRules)
	
	ExecuteForward(g_iForwards[FW_TIMER], g_iForwardResult)
}

Check_RoundStart()
{
	// Play Ambience Sound
	PlaySound(0, SOUND_START)
}

Ckeck_Timer()
{
	if(!BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_GAMESTARTED) || BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED))
		return
		
	if(!BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_GAMESTARTED))
	{
		ClientPrint(0, HUD_PRINTCENTER, "#CSO_WaitEnemy");
	}
	else if(!BitsGet(g_bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART))
	{
		if(0 <= g_iTimer <= g_iCountDownTime - 1)
		{
			new iCountDown = g_iCountDownTime - g_iTimer
			new number[10];
			format(number, 9, "%d", iCountDown);
			ClientPrint(0, HUD_PRINTCENTER, "#CSO_ZombiSelectCount", number);
			if(iCountDown <= 10)
				PlaySound(0, SOUND_COUNTDOWN[iCountDown - 1])
		}
	}
		
	if(g_iTimer == g_iCountDownTime)
	{
		Check_InfectionStart()
	}
	
	g_iTimer ++
}

Check_InfectionStart()
{
	// Exec Forward
	ExecuteForward(g_iForwards[FW_PLAGUE_PRE], g_iForwardResult)
	if(g_iForwardResult > 0)
		return;
	
	BitsUnSet(g_bitsGameStatus, Z4E_GAMESTATUS_ROUNDENDED)
	BitsSet(g_bitsGameStatus, Z4E_GAMESTATUS_INFECTIONSTART)
	
	new iZombieNum
	new bitsRemaining = z4e_team_bits_get_alive()
	switch(BitsCount(bitsRemaining))
	{
		case 1..7: iZombieNum = 1
		case 8..10: iZombieNum = random_num(1, 2)
		case 11..17: iZombieNum = 2
		case 18..20: iZombieNum = random_num(2, 3)
		case 21..32: iZombieNum = 3
		default: 
		{
			BitsUnSet(g_bitsGameStatus, Z4E_GAMESTATUS_GAMESTARTED)
			return;
		}
	}
	
	for(new i = 0; i < iZombieNum; i++)
	{
		new iRandom = BitsGetRandom(bitsRemaining)
		iRandom = !iRandom ? 32:iRandom
		
		z4e_zombie_originate(iRandom, iZombieNum)
		BitsUnSet(bitsRemaining, iRandom)
	}
	
	ExecuteForward(g_iForwards[FW_PLAGUE_POST], g_iForwardResult)
	
}


stock PlaySound(index, const szSound[], stop_sounds_first = 0)
{
	if(equal(szSound, ""))
		return
	if (stop_sounds_first)
	{
		if (equal(szSound[strlen(szSound)-4], ".mp3"))
			client_cmd(index, "stopsound; mp3 play ^"sound/%s^"", szSound)
		else
			client_cmd(index, "mp3 stop; stopsound; spk ^"%s^"", szSound)
	}
	else
	{
		if (equal(szSound[strlen(szSound)-4], ".mp3"))
			client_cmd(index, "mp3 play ^"sound/%s^"", szSound)
		else
			client_cmd(index, "spk ^"%s^"", szSound)
	}
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