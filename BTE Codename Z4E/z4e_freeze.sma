#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <orpheu>

#include "z4e_bits.inc"

#define PLUGIN "[Z4E] Freeze"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define PDATA_SAFE 2
#define OFFSET_LINUX 5
stock m_flVelocityModifier = 108
stock m_bitsHUDDamage = 347 // int

stock m_flNextAttack = 83 // float

enum _:TOTAL_FORWARDS
{
	FW_FREEZE_PRE,
	FW_FREEZE_POST,
}
new g_iForwards[TOTAL_FORWARDS]
new g_iForwardResult

#define TASK_FREEZE 3634364

new g_bitsFreeze

new const MODEL_BLOCK[] = "models/z4e/talrasha_ice_block.mdl"
new g_iModelBlock

new const MODEL_GLASS[] = "models/glassgibs.mdl"
new g_iModelGlass

new g_MsgDamage

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1)
	
	OrpheuRegisterHook(OrpheuGetFunction("PM_Move"), "OnPM_Move");
	
	OrpheuRegisterHook(OrpheuGetFunction("SelectItem", "CBasePlayer"), "OnSelectItem_Pre", OrpheuHookPre);
	OrpheuRegisterHook(OrpheuGetFunction("SelectLastItem", "CBasePlayer"), "OnSelectLastItem_Pre", OrpheuHookPre);
	
	g_iForwards[FW_FREEZE_PRE] = CreateMultiForward("z4e_fw_freeze_set_pre", ET_CONTINUE, FP_CELL, FP_FLOAT, FP_CELL)
	g_iForwards[FW_FREEZE_POST] = CreateMultiForward("z4e_fw_freeze_set_post", ET_IGNORE, FP_CELL, FP_FLOAT, FP_CELL)
	
	g_MsgDamage = get_user_msgid("Damage")
}

public plugin_precache()
{
	g_iModelGlass = precache_model(MODEL_GLASS)
	//g_iModelBlock = precache_model(MODEL_BLOCK)
}

public plugin_natives()
{
	register_native("z4e_freeze_get", "Native_Get", 1)
	register_native("z4e_freeze_set", "Native_Set", 1)
}

public Native_Get(id)
{
	return !!BitsGet(g_bitsFreeze, id)
}

public Native_Set(id, Float:flTime, bDrawEffect)
{
	return Freeze_Set(id, flTime, bDrawEffect)
}

public z4e_fw_team_set_act(id, iTeam)
{
	BitsUnSet(g_bitsFreeze, id)
	remove_task(id + TASK_FREEZE)
}

public OrpheuHookReturn:OnPM_Move(OrpheuStruct:ppmove, server)
{
	static id; id = OrpheuGetStructMember(ppmove, "player_index") + 1
	if(BitsIsPlayer(id) && BitsGet(g_bitsFreeze, id))
	{
		return OrpheuSupercede;
	}
	return OrpheuIgnored;
}

public OrpheuHookReturn:OnSelectItem_Pre(id, pstr[])
{
	if(BitsIsPlayer(id) && BitsGet(g_bitsFreeze, id))
	{
		return OrpheuSupercede;
	}
	return OrpheuIgnored;
}

public OrpheuHookReturn:OnSelectLastItem_Pre(id)
{
	if(BitsIsPlayer(id) && BitsGet(g_bitsFreeze, id))
	{
		return OrpheuSupercede;
	}
	return OrpheuIgnored;
}

Freeze_Set(id, Float:flTime, bDrawEffect = 1)
{
	ExecuteForward(g_iForwards[FW_FREEZE_PRE], g_iForwardResult, id, flTime, bDrawEffect)
	if(g_iForwardResult >= 1)
		return false
		
		
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_KILLPLAYERATTACHMENTS)
	write_byte(id)
	message_end()
		
	if(bDrawEffect)
	{
		
		message_begin(MSG_ONE_UNRELIABLE, g_MsgDamage, _, id)
		write_byte(0) // damage save
		write_byte(0) // damage take
		write_long(DMG_DROWN) // damage type - DMG_FREEZE
		write_coord(0) // x
		write_coord(0) // y
		write_coord(0) // z
		message_end()
		
		/*message_begin(MSG_ALL, SVC_TEMPENTITY)
		write_byte(TE_PLAYERATTACHMENT) // damage save
		write_byte(id) // damage take
		write_coord(-45)// vertical offset
		write_short(g_iModelBlock) // model index
		write_short(floatround(flTime * 10.0 + 0.5)) // life * 10
		message_end()*/
		
	}
	
	
	BitsSet(g_bitsFreeze, id)
	remove_task(id + TASK_FREEZE)
	set_task(flTime, "Task_FreezeReturn", id + TASK_FREEZE)
	set_pdata_float(id, m_flNextAttack, flTime);
	
	ExecuteForward(g_iForwards[FW_FREEZE_POST], g_iForwardResult, id, flTime, bDrawEffect)
	return true
}

public Task_FreezeReturn(taskid)
{
	new id = taskid - TASK_FREEZE
	BitsUnSet(g_bitsFreeze, id)
	
	
	new Float:vecOrigin[3]
	pev(id, pev_origin, vecOrigin)
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BREAKMODEL) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 24.0)
	write_coord(16) // size x
	write_coord(16) // size y
	write_coord(16) // size z
	write_coord(random_num(-50, 50)) // velocity x
	write_coord(random_num(-50, 50)) // velocity y
	write_coord(25) // velocity z
	write_byte(10) // random velocity
	write_short(g_iModelGlass) // model
	write_byte(10) // count
	write_byte(25) // life
	write_byte(0x01) // flags
	message_end()
	
	set_pdata_float(id, m_flVelocityModifier, 0.0)
	
}

public fw_AddToFullPack_Post(es_handle, e, iEntity, host, hostflags, player, pset)
{
	if(player)
	{
		if(BitsIsPlayer(iEntity) && BitsGet(g_bitsFreeze, iEntity))
		{
			set_es(es_handle, ES_RenderMode, kRenderNormal)
			set_es(es_handle, ES_RenderColor, {0, 100, 200})
			set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
			set_es(es_handle, ES_RenderAmt, 25)
			
			set_es(es_handle, ES_Velocity, {0.0, 0.0, 0.0})
		}
	}
}