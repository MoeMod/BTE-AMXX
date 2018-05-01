#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "[Z4E] Object Remover"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

// OffSet
#define PDATA_SAFE 2
#define OFFSET_MAPZONE 235

// Block Round Event
new g_BlockedObj_Forward
new g_BlockedObj[][32] =
{
        "func_bomb_target",
        "info_bomb_target",
        "info_vip_start",
        "func_vip_safetyzone",
        "func_escapezone",
        "hostage_entity",
        "monster_scientist",
        "func_hostage_rescue",
        "info_hostage_rescue",
        "env_fog",
        "env_rain",
        "env_snow",
        "item_longjump",
        //"func_vehicle",
        "func_buyzone"
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    unregister_forward(FM_Spawn, g_BlockedObj_Forward)
    
    register_message(get_user_msgid("StatusIcon"), "Message_StatusIcon")
}

public plugin_precache()
{
    g_BlockedObj_Forward = register_forward(FM_Spawn, "fw_BlockedObj_Spawn")
}

public fw_BlockedObj_Spawn(ent)
{
    if (!pev_valid(ent))
        return FMRES_IGNORED
    
    static Ent_Classname[64]
    pev(ent, pev_classname, Ent_Classname, sizeof(Ent_Classname))
    
    for(new i = 0; i < sizeof g_BlockedObj; i++)
    {
        if (equal(Ent_Classname, g_BlockedObj[i]))
        {
            engfunc(EngFunc_RemoveEntity, ent)
            return FMRES_SUPERCEDE
        }
    }
    
    return FMRES_IGNORED
}

public Message_StatusIcon(msg_id, msg_dest, msg_entity)
{
    static szMsg[8];
    get_msg_arg_string(2, szMsg ,7)
    
    if(equal(szMsg, "buyzone") && get_msg_arg_int(1))
    {
        if(pev_valid(msg_entity) != PDATA_SAFE)
            return  PLUGIN_CONTINUE;
    
        set_pdata_int(msg_entity, OFFSET_MAPZONE, get_pdata_int(msg_entity, OFFSET_MAPZONE) & ~(1<<0))
        return PLUGIN_HANDLED;
    }
    
    return PLUGIN_CONTINUE;
}