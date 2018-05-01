#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include "z4e_bits.inc"
#include "z4e_api.inc"
#include "z4e_team.inc"
#include "z4e_gameplay.inc"

#define PLUGIN "[Z4E] DeathMatch"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define PDATA_SAFE 2
#define OFFSET_LINUX 5

enum _:TOTAL_FORWARDS
{
	FW_RESPAWN_PRE,
	FW_RESPAWN_POST,
}
new g_iForwards[TOTAL_FORWARDS]
new g_iForwardResult

#define TASK_RESPAWN 14232

new g_bitsRespawning, g_iRespawnCount[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Killed, "player", "HamF_Player_Killed_Post", 1)
	
	g_iForwards[FW_RESPAWN_PRE] = CreateMultiForward("z4e_fw_deathmatch_respawn_pre", ET_CONTINUE, FP_CELL)
	g_iForwards[FW_RESPAWN_POST] = CreateMultiForward("z4e_fw_deathmatch_respawn_post", ET_IGNORE, FP_CELL)

}

public z4e_fw_api_bot_registerham(id)
{
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Player_Killed_Post", 1)
}

public z4e_fw_team_spawn_act(id)
{
	BitsUnSet(g_bitsRespawning, id)
	g_iRespawnCount[id] = 0
	remove_task(id + TASK_RESPAWN)
}

public HamF_Player_Killed_Post(id)
{
	ExecuteForward(g_iForwards[FW_RESPAWN_PRE], g_iForwardResult, id)
	if(g_iForwardResult >= 1)
		return;
	BitsSet(g_bitsRespawning, id)
	g_iRespawnCount[id] = 5
	set_task(random_float(0.5, 1.0), "Task_Respawn", id+TASK_RESPAWN)
	
	ExecuteForward(g_iForwards[FW_RESPAWN_POST], g_iForwardResult, id)
}

public Task_Respawn(taskid)
{
	new id = taskid - TASK_RESPAWN
	
	if(!is_user_connected(id))
		return
	if(!BitsGet(z4e_gameplay_bits_get_status(), Z4E_GAMESTATUS_INFECTIONSTART) || BitsGet(z4e_gameplay_bits_get_status(), Z4E_GAMESTATUS_ROUNDENDED))
		return
	if(!is_user_alive(id))
	{
		if(g_iRespawnCount[id])
		{
			/*
			if(g_iRespawnCount[id] == 5 || g_iRespawnCount[id] == 2)
			{
				static Float:vecOrigin[3]; pev(id, pev_origin, vecOrigin)
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
				write_byte(TE_SPRITE)
				engfunc(EngFunc_WriteCoord, vecOrigin[0])
				engfunc(EngFunc_WriteCoord, vecOrigin[1])
				engfunc(EngFunc_WriteCoord, vecOrigin[2] + 16.0)
				write_short(g_iSprRespawn)
				write_byte(7)
				write_byte(200)
				message_end()
			}
			*/
			client_print(id, print_center, "复活时间剩余 %d 秒", g_iRespawnCount[id])
			g_iRespawnCount[id] --
			set_task(1.0, "Task_Respawn", taskid)
		}
		else
		{
			set_pev(id, pev_deadflag, DEAD_RESPAWNABLE)
			ExecuteHamB(Ham_CS_RoundRespawn, id)
		}
	}
}
