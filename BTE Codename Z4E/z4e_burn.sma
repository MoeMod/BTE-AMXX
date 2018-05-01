#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include "z4e_bits.inc"
#include "z4e_team.inc"

#define PLUGIN "[Z4E] Burn"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define PDATA_SAFE 2
#define OFFSET_LINUX 5
stock m_flVelocityModifier = 108
stock m_bitsHUDDamage = 347 // int

enum _:TOTAL_FORWARDS
{
    FW_BURN_PRE,
    FW_BURN_POST,
}
new g_iForwards[TOTAL_FORWARDS]
new g_iForwardResult

#define TASK_BURN 3634364
#define TASK_BURN_END 543624542
#define BURN_LOOP_TIME 0.25

new g_bitsBurn

new const SPR_FIRE[] = "sprites/flame1.spr"
new g_iSprFire

new const SPR_SMOKE[] = "sprites/black_smoke3.spr"
new g_iSprSmoke

new g_MsgDamage

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    g_iForwards[FW_BURN_PRE] = CreateMultiForward("z4e_fw_burn_set_pre", ET_CONTINUE, FP_CELL, FP_FLOAT, FP_CELL)
    g_iForwards[FW_BURN_POST] = CreateMultiForward("z4e_fw_burn_set_post", ET_IGNORE, FP_CELL, FP_FLOAT, FP_CELL)
    
    g_MsgDamage = get_user_msgid("Damage")
}

public plugin_precache()
{
    g_iSprFire = precache_model(SPR_FIRE)
    g_iSprSmoke = precache_model(SPR_SMOKE)
}

public plugin_natives()
{
    register_native("z4e_burn_get", "Native_Get", 1)
    register_native("z4e_burn_set", "Native_Set", 1)
}

public Native_Get(id)
{
    return !!BitsGet(g_bitsBurn, id);
}

public Native_Set(id, Float:flTime, bDrawEffect)
{
    return Burn_Set(id, flTime, bDrawEffect)
}

public z4e_fw_team_set_act(id, iTeam)
{
    BitsUnSet(g_bitsBurn, id)
    remove_task(id + TASK_BURN)
    remove_task(id + TASK_BURN_END)
}

Burn_Set(id, Float:flTime, bDrawEffect = 1)
{
    ExecuteForward(g_iForwards[FW_BURN_PRE], g_iForwardResult, id, flTime, bDrawEffect)
    if(g_iForwardResult >= 1)
        return false
        
    if(bDrawEffect)
    {
        message_begin(MSG_ONE_UNRELIABLE, g_MsgDamage, _, id)
        write_byte(0) // damage save
        write_byte(0) // damage take
        write_long(DMG_BURN) // damage type - DMG_BURN
        write_coord(0) // x
        write_coord(0) // y
        write_coord(0) // z
        message_end()
    }
    
    BitsSet(g_bitsBurn, id)
    remove_task(id + TASK_BURN)
    remove_task(id + TASK_BURN_END)
    set_task(BURN_LOOP_TIME, "Task_BurnLoop", id + TASK_BURN, _, _, "b")
    set_task(flTime, "Task_BurnEnd", id + TASK_BURN_END)
    
    ExecuteForward(g_iForwards[FW_BURN_POST], g_iForwardResult, id, flTime, bDrawEffect)
    return true
}

public Task_BurnLoop(taskid)
{
    new id = taskid - TASK_BURN
    if(!Native_Get(id))
        return
    
    new Float:vecOrigin[3]
    pev(id, pev_origin, vecOrigin)
    
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
    write_byte(TE_SPRITE) // TE id
    engfunc(EngFunc_WriteCoord, vecOrigin[0]+random_float(-5.0, 5.0))
    engfunc(EngFunc_WriteCoord, vecOrigin[1]+random_float(-5.0, 5.0))
    engfunc(EngFunc_WriteCoord, vecOrigin[2]+random_float(-5.0, 5.0))
    write_short(g_iSprFire) // sprite
    write_byte(random_num(5, 10)) // scale
    write_byte(200) // brightness
    message_end()
    
    new Float:flHealth;
    pev(id, pev_health, flHealth)
    flHealth -= z4e_team_get_user_zombie(id) ? 30.0:3.0
    if(flHealth <= 1.0) flHealth = 1.0
    set_pev(id, pev_health, flHealth)
    
    set_pdata_float(id, m_flVelocityModifier, 0.6)
    
}

public Task_BurnEnd(taskid)
{
    new id = taskid - TASK_BURN_END
    BitsUnSet(g_bitsBurn, id)
    remove_task(id + TASK_BURN)

    new Float:vecOrigin[3]
    pev(id, pev_origin, vecOrigin)
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
    write_byte(TE_SMOKE) // TE id
    engfunc(EngFunc_WriteCoord, vecOrigin[0])
    engfunc(EngFunc_WriteCoord, vecOrigin[1])
    engfunc(EngFunc_WriteCoord, vecOrigin[2]-50.0)
    write_short(g_iSprSmoke) // sprite
    write_byte(random_num(15, 20)) // scale
    write_byte(random_num(10, 20)) // framerate
    message_end()
}