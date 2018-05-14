#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include "z4e_zombie.inc"

#define PLUGIN "[Z4E] Effect Infect"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

new g_MsgDeathMsg, g_MsgScoreAttrib

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    g_MsgDeathMsg = get_user_msgid("DeathMsg")
    g_MsgScoreAttrib = get_user_msgid("ScoreAttrib")
}

public plugin_precache()
{
    
}

public z4e_fw_zombie_infect_act(id, iAttacker)
{
    message_begin(MSG_BROADCAST, g_MsgDeathMsg)
    write_byte(iAttacker) // killer
    write_byte(id) // victim
    write_byte(0) // headshot flag
    write_string("knife") // killer's weapon
    message_end()
    
    message_begin(MSG_BROADCAST, g_MsgScoreAttrib)
    write_byte(id) // id
    write_byte(0) // attrib
    message_end()
}