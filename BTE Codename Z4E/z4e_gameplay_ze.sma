#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <orpheu>
#include <orpheu_memory>

#include "z4e_bits.inc"
#include "z4e_team.inc"
#include "z4e_gameplay.inc"
#include "z4e_alarm.inc"
#include "z4e_freeze.inc"
#include "z4e_random_spawn.inc"

#define PLUGIN "[Z4E] Gameplay: Zombie Escape"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define GROUP_OP_AND    0
#define GROUP_OP_NAND    1

new Float:g_flNextRegenTime[33]

public plugin_precache()
{
	new szMap[4];
	get_mapname(szMap, 3)
	if(!equali(szMap, "ze_")) // equali比较字符串不区分大小写
	{
		pause("a")
		return;
	}
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_PlayerPreThink, "fw_Player_PreThink")
	register_forward(FM_PlayerPostThink, "fw_Player_PostThink")
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1)
	
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage_Post", 1)
	
	OrpheuRegisterHook(OrpheuGetFunction("SyncRoundTimer", "CBasePlayer"), "OnSyncRoundTimer")
	register_message(get_user_msgid("RoundTime"), "Message_RoundTime")
}

public z4e_fw_api_bot_registerham(id)
{
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage_Post", 1)
}

public OrpheuHookReturn:OnSyncRoundTimer(id)
{
	new msg=get_user_msgid("RoundTime")
	if(msg && z4e_gameplay_get_timer() > 0)
	{
		message_begin(MSG_ONE, msg, _, id);
		write_short(z4e_gameplay_get_timer());
		message_end();
	}
	return OrpheuSupercede;
}

public z4e_fw_gameplay_timer()
{
	for(new i;i < 33;i++)
	{
		if(is_user_connected(i))
			OnSyncRoundTimer(i);
	}
}

public Message_RoundTime()
{
	set_msg_arg_int(1, get_msg_argtype(1), z4e_gameplay_get_timer())
}

public x_fw_api_semiclip(id, iEntity)
{
	if(!BitsIsPlayer(id) || !BitsIsPlayer(iEntity))
		return PLUGIN_CONTINUE;
	
	return PLUGIN_HANDLED;
}

public fw_Player_PreThink(id)
{
	Check_HealthRegen(id);
	
	// semiclip
	if(is_user_alive(id))
	{
		new groupinfo = pev(id, pev_groupinfo);
		BitsSet(groupinfo, id);
		set_pev(id, pev_groupinfo, groupinfo);
		for(new i=1;i<33;i++)
		{
			if(!is_user_alive(i))
				continue;
			
			new groupinfo2 = pev(i, pev_groupinfo);
			BitsSet(groupinfo2, id);
			set_pev(i, pev_groupinfo, groupinfo2);
		}
	}
	engfunc(EngFunc_SetGroupMask, 0, GROUP_OP_NAND);
	
	return FMRES_IGNORED;
}

public fw_Player_PostThink(id)
{
	new groupinfo = pev(id, pev_groupinfo);
	BitsUnSet(groupinfo, id);
	set_pev(id, pev_groupinfo, groupinfo);
	for(new i=1;i<33;i++)
	{
		if(!is_user_alive(i))
			continue;
		
		new groupinfo2 = pev(i, pev_groupinfo);
		BitsUnSet(groupinfo2, id);
		set_pev(i, pev_groupinfo, groupinfo2);
	}
	
	engfunc(EngFunc_SetGroupMask, 0, 0);
}

public fw_AddToFullPack_Post(es_handle, e, iEntity, host, hostflags, player, pset)
{
    if(BitsIsPlayer(iEntity) && BitsIsPlayer(host))
    {
        set_es(es_handle, ES_Solid, SOLID_NOT)
    }
}

public z4e_fw_gameplay_roundend_pre(iWinTeam)
{
	if(iWinTeam == Z4E_TEAM_INVALID)
		return PLUGIN_HANDLED;
	return PLUGIN_CONTINUE;
}

public z4e_fw_gameplay_round_new()
{
	new pEntity
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_button"))))
	{
		ExecuteHamB(Ham_Spawn, pEntity)
	}
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_tracktrain"))))
	{
		ExecuteHamB(Ham_Spawn, pEntity)
	}
}

public z4e_fw_gameplay_plague_post()
{
	z4e_alarm_timertip(7, "追击开始")
}

public z4e_fw_zombie_originate_pre(id, iZombieCount)
{
	z4e_random_spawn_set(id)
}

public z4e_fw_zombie_originate_post(id, iZombieCount)
{
	z4e_freeze_set(id, 7.0, 1)
}

public HamF_TakeDamage_Post(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if(!is_user_alive(iVictim))
		return;
	g_flNextRegenTime[iVictim] = get_gametime() + 1.1
}

Check_HealthRegen(id)
{
	if(!is_user_alive(id))
		return
	if(!z4e_team_get_user_zombie(id))
		return
	if(get_gametime() > g_flNextRegenTime[id])
	{
		new Float:flHealth; pev(id, pev_health, flHealth)
		new Float:flMaxHealth; pev(id, pev_max_health, flMaxHealth)
		flHealth = floatmin(flMaxHealth, flHealth + 1000.0)
		set_pev(id, pev_health, flHealth)
		
		g_flNextRegenTime[id] = get_gametime() + 0.5
	}
}