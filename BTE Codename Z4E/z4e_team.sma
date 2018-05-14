#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include "z4e_bits"
#include "z4e_api"

#define PLUGIN "[Z4E] Team Manager"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

// Safety Cache
new g_bitsConnected, g_bitsIsAlive
#define IsConnected(%1) (BitsIsPlayer(%1) && BitsGet(g_bitsConnected, %1))
#define IsAlive(%1) (BitsIsPlayer(%1) && BitsGet(g_bitsIsAlive, %1))

#define OFFSET_TEAM 114

enum _:TOTAL_FORWARDS
{
    FW_SET_TEAM_PRE = 0,
    FW_SET_TEAM_ACT,
    FW_SET_TEAM_POST,
    FW_SPAWN_PRE,
    FW_SPAWN_ACT,
    FW_SPAWN_POST,
}
new g_iForwards[TOTAL_FORWARDS]
new g_iForwardResult

enum _:TOTAL_Z4E_TEAM
{
    Z4E_TEAM_INVALID = 0,
    Z4E_TEAM_ZOMBIE = 1,
    Z4E_TEAM_HUMAN = 2,
    Z4E_TEAM_SPECTATOR = 3
};

new g_iTeam[33], g_bitsTeamMember[TOTAL_Z4E_TEAM]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Post", 1)
    RegisterHam(Ham_Killed, "player", "HamF_Killed_Post", 1)
    
    register_message(get_user_msgid("TeamInfo"), "Message_TeamInfo");
    
    g_iForwards[FW_SET_TEAM_PRE] = CreateMultiForward("z4e_fw_team_set_pre", ET_CONTINUE, FP_CELL, FP_CELL)
    g_iForwards[FW_SET_TEAM_ACT] = CreateMultiForward("z4e_fw_team_set_act", ET_IGNORE, FP_CELL, FP_CELL)
    g_iForwards[FW_SET_TEAM_POST] = CreateMultiForward("z4e_fw_team_set_post", ET_IGNORE, FP_CELL, FP_CELL)
    
    g_iForwards[FW_SPAWN_PRE] = CreateMultiForward("z4e_fw_team_spawn_pre", ET_CONTINUE, FP_CELL)
    g_iForwards[FW_SPAWN_ACT] = CreateMultiForward("z4e_fw_team_spawn_act", ET_IGNORE, FP_CELL)
    g_iForwards[FW_SPAWN_POST] = CreateMultiForward("z4e_fw_team_spawn_post", ET_IGNORE, FP_CELL)
}

public plugin_natives()
{
    register_native("z4e_team_get", "Native_GetUserTeam", 1)
    register_native("z4e_team_set", "Native_SetUserTeam", 1)
    register_native("z4e_team_count", "Native_TeamCount", 1)
    register_native("z4e_team_swap", "Native_TeamSwap", 1)
    register_native("z4e_team_balance", "Native_TeamBalance", 1)
    register_native("z4e_team_bits_get_member", "Native_BitsGetMember", 1)
    register_native("z4e_team_bits_get_connected", "Native_BitsGetConnected", 1)
    register_native("z4e_team_bits_get_alive", "Native_BitsGetAlive", 1)
}

public client_putinserver(id)
{
    BitsSet(g_bitsConnected, id)
    BitsUnSet(g_bitsIsAlive, id)
    
    g_iTeam[id] = Z4E_TEAM_INVALID
    BitsSet(g_bitsTeamMember[Z4E_TEAM_INVALID], id)
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_ZOMBIE], id)
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_HUMAN], id)
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_SPECTATOR], id)
}

public z4e_fw_api_bot_registerham(id)
{
    RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Post", 1)
    RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed_Post", 1)
}

public client_disconnect(id)
{
    BitsUnSet(g_bitsConnected, id)
    BitsUnSet(g_bitsIsAlive, id)
    
    g_iTeam[id] = Z4E_TEAM_INVALID
    BitsSet(g_bitsTeamMember[Z4E_TEAM_INVALID], id)
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_ZOMBIE], id)
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_HUMAN], id)
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_SPECTATOR], id)
}

public HamF_Spawn_Post(id)
{
    if(!is_user_alive(id))
        return
        
    BitsSet(g_bitsIsAlive, id)
    
    ExecuteForward(g_iForwards[FW_SPAWN_PRE], g_iForwardResult, id)
    if(g_iForwardResult >= PLUGIN_HANDLED)
        return
    ExecuteForward(g_iForwards[FW_SPAWN_ACT], g_iForwardResult, id)
    
    Set_Player_Team(id, g_iTeam[id])
    
    ExecuteForward(g_iForwards[FW_SPAWN_POST], g_iForwardResult, id)
}

public HamF_Killed_Post(id)
{
    BitsUnSet(g_bitsIsAlive, id)
}

public Message_TeamInfo(iMessage, iDest, iEntity)
{
    static id, szTeam[2]
    id = get_msg_arg_int(1)
    get_msg_arg_string(2, szTeam, charsmax(szTeam))
    
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_INVALID], id)
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_ZOMBIE], id)
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_HUMAN], id)
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_SPECTATOR], id)
    
    switch (szTeam[0])
    {
        case 'T' : // TERRORIST
        {
            BitsSet(g_bitsTeamMember[Z4E_TEAM_ZOMBIE], id)
            g_iTeam[id] = Z4E_TEAM_ZOMBIE
        }
        case 'C' : // CT
        {
            BitsSet(g_bitsTeamMember[Z4E_TEAM_HUMAN], id)
            g_iTeam[id] = Z4E_TEAM_HUMAN
        }
        case 'S' : // SPECTATOR
        {
            BitsSet(g_bitsTeamMember[Z4E_TEAM_SPECTATOR], id)
            g_iTeam[id] = Z4E_TEAM_SPECTATOR
        }
        default : 
        {
            BitsSet(g_bitsTeamMember[Z4E_TEAM_INVALID], id)
            g_iTeam[id] = Z4E_TEAM_INVALID
        }
    }
}

Set_Player_Team(id, iTeam)
{
    ExecuteForward(g_iForwards[FW_SET_TEAM_PRE], g_iForwardResult, id, iTeam)
    if(g_iForwardResult >= PLUGIN_HANDLED)
        return g_iForwardResult
    ExecuteForward(g_iForwards[FW_SET_TEAM_ACT], g_iForwardResult, id, iTeam)
    if(g_iTeam[id] != iTeam)
        z4e_api_set_player_team(id, CsTeams:iTeam, 1)
    
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_INVALID], id)
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_ZOMBIE], id)
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_HUMAN], id)
    BitsUnSet(g_bitsTeamMember[Z4E_TEAM_SPECTATOR], id)
    BitsSet(g_bitsTeamMember[iTeam], id)
    g_iTeam[id] = iTeam
    
    ExecuteForward(g_iForwards[FW_SET_TEAM_POST], g_iForwardResult, id, iTeam)
    return 1
}

Team_Swap()
{
    new bitsRemaining = g_bitsConnected
    while(bitsRemaining)
    {
        static id; id = BitsGetRandom(bitsRemaining)
        id = !id ? 32:id
        if(g_iTeam[id] == Z4E_TEAM_ZOMBIE)
            Set_Player_Team(id, Z4E_TEAM_HUMAN)
        else if(g_iTeam[id] == Z4E_TEAM_HUMAN)
            Set_Player_Team(id, Z4E_TEAM_ZOMBIE)
        BitsUnSet(bitsRemaining, id)
    }
}

Team_Balance()
{
    new bitsRemaining = g_bitsConnected
    while(bitsRemaining)
    {
        static id; id = BitsGetRandom(bitsRemaining)
        id = !id ? 32:id
        if(BitsCount(g_bitsTeamMember[Z4E_TEAM_ZOMBIE]) > BitsCount(g_bitsTeamMember[Z4E_TEAM_HUMAN]))
            Set_Player_Team(id, Z4E_TEAM_HUMAN)
        else if(g_iTeam[id] == Z4E_TEAM_HUMAN)
            Set_Player_Team(id, Z4E_TEAM_ZOMBIE)
        BitsUnSet(bitsRemaining, id)
    }
}

public Native_GetUserTeam(id)
{
    if(!BitsIsPlayer(id))
        return z4bTeam:-1
    return z4bTeam:g_iTeam[id]
}

public Native_SetUserTeam(id, iTeam)
{
    if(!BitsIsPlayer(id))
        return 0
    return Set_Player_Team(id, iTeam)
}

public Native_TeamCount(z4bTeam:iTeam, bAlive)
{
    if(bAlive)
        return BitsCount(g_bitsTeamMember[iTeam] & g_bitsIsAlive)
    return BitsCount(g_bitsTeamMember[iTeam])
}

public Native_BitsGetMember(z4bTeam:iTeam)
{
    return g_bitsTeamMember[iTeam]
}

public Native_BitsGetConnected()
{
    return g_bitsConnected
}

public Native_BitsGetAlive()
{
    return g_bitsIsAlive
}

public Native_TeamSwap()
{
    Team_Swap()
}

public Native_TeamBalance()
{
    Team_Balance()
}