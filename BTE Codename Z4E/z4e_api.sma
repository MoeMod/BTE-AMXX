#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>

#include <orpheu>
#include <orpheu_memory>

#include "z4e_bits.inc"
#include "offset.inc"
#include "../BTE_API.inc"

#define PLUGIN "[Z4E] API Function"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define PDATA_SAFE 2
#define OFFSET_LINUX_WEAPONS 4
#define OFFSET_LINUX 5

// Team API
#define TASK_TEAMMSG 1500
enum CsTeams 
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T = 1,
	CS_TEAM_CT = 2,
	CS_TEAM_SPECTATOR = 3
};
new const CS_TEAM_NAMES[][] = { "UNASSIGNED", "TERRORIST", "CT", "SPECTATOR" }
#define TEAMCHANGE_DELAY 0.1
new Float:g_TeamMsgTargetTime

// Player Model API
#define MODELCHANGE_DELAY random_float(0.02, 0.2)
new Float:g_fModelDelay[33], g_szModel[33][64]
new g_bitsCustomModel

// Terminate Round API
enum
{
	WINSTATUS_CT = 1,
	WINSTATUS_TERRORIST,
	WINSTATUS_DRAW
}

/******************************
	Forwards
******************************/
enum _:MAX_FORWARDS
{
	FW_BOT_REGISTERHAM,
}
new g_iForwards[MAX_FORWARDS]
new g_iForwardResult

new g_MsgTeamInfo, g_MsgScoreInfo
new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame
new g_bitsCustomMaxspeed

new g_pGameRules
new g_bInfinityRound

// Safety Cache
new g_bitsConnected, g_bitsIsAlive, g_fwHamBotRegister
#define IsConnected(%1) (BitsIsPlayer(%1) && BitsGet(g_bitsConnected, %1))
#define IsAlive(%1) (BitsIsPlayer(%1) && BitsGet(g_bitsIsAlive, %1))

public plugin_precache()
{
	OrpheuRegisterHook(OrpheuGetFunction("InstallGameRules"), "OnInstallGameRules", OrpheuHookPost)
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Spawn, "player", "HamF_Player_Spawn_Post", 1)
	RegisterHam(Ham_Killed, "player", "HamF_Player_Killed_Post", 1)
	
	register_forward(FM_SetClientKeyValue,"fw_SetClientKeyValue")
	register_forward(FM_ClientUserInfoChanged,"fw_ClientUserInfoChanged")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "HamF_Player_ResetMaxSpeed")
	
	OrpheuRegisterHook(OrpheuGetFunction("SetPlayerModel", "CBasePlayer"), "OnSetPlayerModel")
	
	g_fwHamBotRegister = register_forward(FM_PlayerPostThink, "fw_BotRegisterHam", 1)
	
	g_iForwards[FW_BOT_REGISTERHAM] = CreateMultiForward("z4e_fw_api_bot_registerham", ET_IGNORE, FP_CELL)
	
	g_MsgTeamInfo = get_user_msgid("TeamInfo")
	g_MsgScoreInfo = get_user_msgid("ScoreInfo")
}

public plugin_natives()
{
	register_native("z4e_api_set_player_maxspeed", "Native_SetPlayerMaxspeed", 1)
	register_native("z4e_api_reset_player_maxspeed", "Native_ResetPlayerMaxspeed", 1)
	register_native("z4e_api_set_player_model", "Native_SetPlayerModel", 1)
	register_native("z4e_api_reset_player_model", "Native_ResetPlayerModel", 1)
	register_native("z4e_api_set_player_team", "Native_SetPlayerTeam", 1)
	register_native("z4e_api_infinity_round", "Native_InfinityRound", 1)
	register_native("z4e_api_terminate_round", "Native_TerminateRound", 1)
}

public Native_SetPlayerMaxspeed(id, Float:flMaxspeed, bKeep)
{
	if(!IsAlive(id))
		return false;
	API_Set_Maxspeed(id, flMaxspeed, bKeep)
	return true;
}

public Native_ResetPlayerMaxspeed(id)
{
	if(!IsAlive(id))
		return false;
	API_Reset_Maxspeed(id)
	return true;
}

public Native_SetPlayerModel(id, szModel[])
{
	param_convert(2)
	if(!IsAlive(id))
		return false;
	//API_Set_PlayerModel(id, szModel, false)
	bte_set_user_model(id, szModel);
	return true;
}

public Native_ResetPlayerModel(id)
{
	if(!IsAlive(id))
		return false;
	//API_Reset_PlayerModel(id)
	bte_reset_user_model(id);
	return true;
}

public Native_SetPlayerTeam(id, CsTeams:iTeam, bUpdate)
{
	if(!IsConnected(id))
		return false;
	API_Set_PlayerTeam(id, iTeam, bUpdate)
	return true;
}

public Native_InfinityRound(bSet)
{
	return (g_bInfinityRound = bSet)
}

public Native_TerminateRound(Float:flDelay, iWinstatus)
{
	return API_RoundTerminating(iWinstatus, flDelay)
}

public client_putinserver(id)
{
	BitsSet(g_bitsConnected, id)
	BitsUnSet(g_bitsIsAlive, id)
	
	BitsUnSet(g_bitsCustomModel, id)
	BitsUnSet(g_bitsCustomMaxspeed, id)
}

public fw_BotRegisterHam(id)
{
	if(is_bot_type(id) != 2)
		return
	
	unregister_forward(FM_PlayerPostThink, g_fwHamBotRegister, 1)
	
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Player_Spawn_Post", 1)
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Player_Killed_Post", 1)
	
	RegisterHamFromEntity(Ham_Player_ResetMaxSpeed, id, "HamF_Player_ResetMaxSpeed")
	ExecuteForward(g_iForwards[FW_BOT_REGISTERHAM], g_iForwardResult, id)
}

public client_disconnect(id)
{
	BitsUnSet(g_bitsConnected, id)
	BitsUnSet(g_bitsIsAlive, id)
	
	BitsUnSet(g_bitsCustomModel, id)
	BitsUnSet(g_bitsCustomMaxspeed, id)
}

public fw_PlayerPreThink(id)
{
	if(!IsAlive(id))
		return

	if(g_fModelDelay[id] <= 0)
		return

	if(g_fModelDelay[id] <= get_gametime())
	{
		API_Set_PlayerModel(id, g_szModel[id], true)
		g_fModelDelay[id] = -1.0
	}
}

public fw_SetClientKeyValue(id, infobuffer[], key[], value[])
{
	if(!strcmp(key,"model"))
	{
		if(BitsGet(g_bitsCustomModel, id))
			return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public fw_ClientUserInfoChanged(id) 
{
	// 玩家没有使用自定义模型
	if (!g_szModel[id][0])
		 return FMRES_IGNORED;
		 
	 // 获取当前模型
	static szCurrentModel[32]
	engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, id), "model", szCurrentModel, charsmax(szCurrentModel))
	
	// 看它是否和自定义模型一致－如果不是, 重新设回自定义的模型
	if (!equal(szCurrentModel, g_szModel[id]))
		API_Set_PlayerModel(id, g_szModel[id], true)
	return FMRES_IGNORED;
}

public HamF_Player_Spawn_Post(id)
{
	if(!is_user_alive(id))
		return
		
	BitsSet(g_bitsIsAlive, id)
}

public HamF_Player_Killed_Post(id)
{
	BitsUnSet(g_bitsIsAlive, id)
}

public HamF_Player_ResetMaxSpeed(id)
{
	if(BitsGet(g_bitsCustomMaxspeed, id))
		return HAM_SUPERCEDE
	
	return HAM_IGNORED
}

public OrpheuHookReturn:OnInstallGameRules()
{
	g_pGameRules = OrpheuGetReturn();
	
	OrpheuRegisterHook(OrpheuGetFunctionFromObject(g_pGameRules, "CheckWinConditions", "CGameRules"), "OnCheckWinConditions")
}

public OrpheuHookReturn:OnCheckWinConditions(this)
{
	if(g_bInfinityRound)
	{
		return OrpheuSupercede
	}
	return OrpheuIgnored
}

public OrpheuHookReturn:OnSetPlayerModel(id, bHasC4)
{
	if(BitsGet(g_bitsCustomModel, id))
		return OrpheuSupercede
	return OrpheuIgnored
}

// Team API
stock API_Set_PlayerTeam(id, CsTeams:team, send_message = 1)
{
	if (pev_valid(id) != PDATA_SAFE)
		return;
	if (fm_get_user_team(id) == team)
		return;

	remove_task(id+TASK_TEAMMSG)
	set_pdata_int(id, m_iTeam, _:team)
	if (send_message) fm_user_team_update(id)
}

public Task_SetPlayerTeam(taskid)
{
	new id = taskid - TASK_TEAMMSG
	emessage_begin(MSG_BROADCAST, g_MsgTeamInfo)
	ewrite_byte(id) // player
	ewrite_string(CS_TEAM_NAMES[_:fm_get_user_team(id)]) // team
	emessage_end()
	
	emessage_begin(MSG_BROADCAST, g_MsgScoreInfo)
	ewrite_byte(id) // id
	ewrite_short(pev(id, pev_frags)) // frags
	ewrite_short(fm_get_user_deaths(id)) // deaths
	ewrite_short(0) // class?
	ewrite_short(_:fm_get_user_team(id)) // team
	emessage_end()
}

stock fm_user_team_update(id)
{	
	new Float:current_time
	current_time = get_gametime()
	
	if (current_time - g_TeamMsgTargetTime >= TEAMCHANGE_DELAY)
	{
		set_task(0.1, "Task_SetPlayerTeam", id+TASK_TEAMMSG)
		g_TeamMsgTargetTime = current_time + TEAMCHANGE_DELAY
	}
	else
	{
		set_task((g_TeamMsgTargetTime + TEAMCHANGE_DELAY) - current_time, "Task_SetPlayerTeam", id+TASK_TEAMMSG)
		g_TeamMsgTargetTime = g_TeamMsgTargetTime + TEAMCHANGE_DELAY
	}
}

// PlayerModel API
// PlayerModel API
stock API_Set_PlayerModel(id, const szModel[], bool:bPre = false)
{
	copy(g_szModel[id], charsmax(g_szModel[]), szModel)
	if(!bPre)
	{
		g_fModelDelay[id] = get_gametime() + MODELCHANGE_DELAY
		return
	}
	
	BitsSet(g_bitsCustomModel, id)
	set_user_info(id, "model", szModel)
	engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "model", szModel)
	static szModelPath[64]
	formatex(szModelPath, charsmax(szModelPath), "models/player/%s/%s.mdl", szModel, szModel)
	fm_cs_set_user_model_index(id, engfunc(EngFunc_ModelIndex, szModelPath))
	dllfunc(DLLFunc_ClientUserInfoChanged, id, engfunc(EngFunc_GetInfoKeyBuffer, id))
}

stock API_Reset_PlayerModel(id)
{
	BitsUnSet(g_bitsCustomModel, id)
	g_szModel[id][0] = 0
	dllfunc(DLLFunc_ClientUserInfoChanged, id, engfunc(EngFunc_GetInfoKeyBuffer, id))
}

// PlayerSpeed API
stock API_Set_Maxspeed(id, Float:flMaxSpeed, bKeep)
{
	if(bKeep)
		BitsSet(g_bitsCustomMaxspeed, id)
	else
		BitsUnSet(g_bitsCustomMaxspeed, id)
	set_pev(id, pev_maxspeed, flMaxSpeed)
	engfunc(EngFunc_SetClientMaxspeed, id, flMaxSpeed)
}

stock API_Reset_Maxspeed(id)
{
	BitsUnSet(g_bitsCustomMaxspeed, id)
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
}

// TerminateRound API
stock API_RoundTerminating(iWinStatus, Float:flDelay )
{
	OrpheuMemorySetAtAddress(g_pGameRules, "m_iRoundWinStatus", 1, iWinStatus);
	OrpheuMemorySetAtAddress(g_pGameRules, "m_fTeamCount", 1, get_gametime() + flDelay);
	OrpheuMemorySetAtAddress(g_pGameRules, "m_bRoundTerminating", 1, 1);
	return true
}

stock CsTeams:fm_get_user_team(id)
{
	if (pev_valid(id) != PDATA_SAFE)
		return CsTeams:-1;
	return CsTeams:get_pdata_int(id, m_iTeam);
}

stock fm_cs_set_user_model_index(id, model_index)
{
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, 491, model_index)
}

stock fm_get_user_deaths(index)
{
	if (pev_valid(index) != PDATA_SAFE)
		return -1;
	return get_pdata_int(index, m_iDeaths);
}

stock is_bot_type(id) // Thanks to Hsk
{
	if (!is_user_bot (id))
		return 0; // not bot

	new tracker[2], friends[2], ah[2];
	get_user_info(id,"tracker",tracker,1);
	get_user_info(id,"friends",friends,1);
	get_user_info(id,"_ah",ah,1);

	if (tracker[0] == '0' && friends[0] == '0' && ah[0] == '0')
		return 1; // PodBot / YaPB / SyPB

	return 2; // Zbot
}