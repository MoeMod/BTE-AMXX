#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include "z4e_bits.inc"
#include "z4e_team.inc"

#define PLUGIN "[Z4E] Nightvision"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

// NightVision
new const COLOR_NVG_ZOMBIE[3] = { 190, 90, 90 }
new const COLOR_NVG_HUMAN[3] = { 90, 190, 90 }
new const LIGHTSTYLE_NORMAL[] = "m"
new const LIGHTSTYLE_NVG[] = "z"
new const SOUND_NVG[2][] = { "items/nvg_off.wav", "items/nvg_on.wav"}

new g_MsgScreenFade

// Nightvision
new g_bitsHasNvg, g_bitsUsingNvg, g_bitsFadeEffect
new Float:g_flNextFadeTime[33]
new g_iViewTarget[33], g_iViewMode[33]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    register_clcmd("nightvision", "CMD_NightVision")
    
    RegisterHam(Ham_Player_PostThink, "player", "HamF_Player_PostThink")
    
    g_MsgScreenFade = get_user_msgid("ScreenFade")
}

public z4e_fw_api_bot_registerham(id)
{
    RegisterHamFromEntity(Ham_Player_PostThink, id, "HamF_Player_PostThink")
}

public z4e_fw_round_new()
{
    SetPlayerLight(0, LIGHTSTYLE_NORMAL)
}

public z4e_fw_team_set_post(id, iTeam)
{
    if(iTeam == Z4E_TEAM_ZOMBIE)
    {
        BitsSet(g_bitsHasNvg, id)
        BitsUnSet(g_bitsUsingNvg, id)
        NightVision_Switch(id)
    }
    else
    {
        if(BitsGet(g_bitsUsingNvg, id))
        {
            BitsUnSet(g_bitsHasNvg, id)
            BitsUnSet(g_bitsUsingNvg, id)
            NightVision_Update(id)
        }
        else
        {
            BitsUnSet(g_bitsHasNvg, id)
            BitsUnSet(g_bitsUsingNvg, id)
            SetPlayerLight(id, LIGHTSTYLE_NORMAL)
        }
        BitsUnSet(g_bitsHasNvg, id) //test
    }
}

public CMD_NightVision(id)
{
    NightVision_Switch(id)
    return PLUGIN_HANDLED;
}

public HamF_Player_PostThink(id)
{
    Check_Spectating(id)
    Check_ScreenFade(id)
}

NightVision_Switch(id)
{
    if(!BitsGet(g_bitsHasNvg, id) || !is_user_alive(id))
        return

    if(!BitsGet(g_bitsUsingNvg, id))
    {
        BitsSet(g_bitsUsingNvg, id)
        PlaySound(id, SOUND_NVG[1])
    }
    else 
    {
        BitsUnSet(g_bitsUsingNvg, id)
        PlaySound(id, SOUND_NVG[0])
    }
    NightVision_Update(id)
}

NightVision_Update(id)
{    
    if(!is_user_alive(id))
        return
    message_begin(MSG_ONE_UNRELIABLE, g_MsgScreenFade, _, id)
    write_short(0) // duration
    write_short(0) // hold time
    write_short(0x0004) // fade type
    if(!z4e_team_get_user_zombie(id))
    {
        write_byte(COLOR_NVG_HUMAN[0]) // r
        write_byte(COLOR_NVG_HUMAN[1]) // g
        write_byte(COLOR_NVG_HUMAN[2]) // b
    }
    else
    {
        write_byte(COLOR_NVG_ZOMBIE[0]) // r
        write_byte(COLOR_NVG_ZOMBIE[1]) // g
        write_byte(COLOR_NVG_ZOMBIE[2]) // b
    }
    write_byte(BitsGet(g_bitsUsingNvg, id) ? 100:0) // alpha
    message_end()

    if(BitsGet(g_bitsUsingNvg, id)) 
        SetPlayerLight(id, LIGHTSTYLE_NVG)
    else 
        SetPlayerLight(id, LIGHTSTYLE_NORMAL)
        
    Check_Spectating_Nvg(id)
}

Check_ScreenFade(id)
{
    if(!is_user_alive(id))
        return false
    if(!BitsGet(g_bitsFadeEffect, id))
        return false
    static Float:flCurTime;flCurTime = get_gametime()
    if(flCurTime < g_flNextFadeTime[id])
        return false
    
    static iAlpha; iAlpha = 75
    
    message_begin(MSG_ONE_UNRELIABLE, g_MsgScreenFade, _, id)
    write_short(1<<10) // duration
    write_short(1<<10) // hold time
    write_short(0x0000) // fade type
    if(!BitsGet(g_bitsUsingNvg, id))
    {
        write_byte(200) // r
        write_byte(200) // g
        write_byte(200) // b
    }
    else if(z4e_team_get_user_zombie(id))
    {
        write_byte(COLOR_NVG_ZOMBIE[0]) // r
        write_byte(COLOR_NVG_ZOMBIE[1]) // g
        write_byte(COLOR_NVG_ZOMBIE[2]) // b
    }
    else 
    {
        write_byte(COLOR_NVG_HUMAN[0]) // r
        write_byte(COLOR_NVG_HUMAN[1]) // g
        write_byte(COLOR_NVG_HUMAN[2]) // b
    }
    write_byte(iAlpha) // alpha
    message_end()
    
    g_flNextFadeTime[id] = flCurTime + 0.6
    return true
}


Check_Spectating(id)
{
    if(!is_user_connected(id) || is_user_alive(id))
        return
    static iViewTarget, iViewMode
    iViewTarget = pev(id, pev_iuser2)
    iViewMode = pev(id, pev_iuser1)
    if((g_iViewMode[id] != iViewMode) || (g_iViewTarget[id] != iViewTarget))
    {
        Update_Spectating(id)
    }
    g_iViewTarget[id] = iViewTarget
    g_iViewMode[id] = iViewMode
}

Check_Spectating_Nvg(iTarget)
{
    for(new id = 0;id < 33;id ++)
    {
        if(!is_user_connected(id) || is_user_alive(id))
            continue
        if((g_iViewMode[id] == 4) && (g_iViewTarget[id] == iTarget))
            Update_Spectating(id)
    }
}

Update_Spectating(id)
{
    static iViewTarget, iViewMode
    iViewTarget = pev(id, pev_iuser2)
    iViewMode = pev(id, pev_iuser1)
    message_begin(MSG_ONE_UNRELIABLE, g_MsgScreenFade, _, id)
    write_short(0) // duration
    write_short(0) // hold time
    write_short(0x0004) // fade type
    write_byte(z4e_team_get_user_zombie(iViewTarget) ? COLOR_NVG_ZOMBIE[0]:COLOR_NVG_HUMAN[0]) // r
    write_byte(z4e_team_get_user_zombie(iViewTarget) ? COLOR_NVG_ZOMBIE[1]:COLOR_NVG_HUMAN[1]) // g
    write_byte(z4e_team_get_user_zombie(iViewTarget) ? COLOR_NVG_ZOMBIE[2]:COLOR_NVG_HUMAN[2]) // b
    write_byte(BitsGet(g_bitsUsingNvg, iViewTarget) && (iViewMode == 4) ? 100:0) // alpha
    message_end()

    if(BitsGet(g_bitsUsingNvg, iViewTarget)) 
        SetPlayerLight(id, LIGHTSTYLE_NVG)
    else 
        SetPlayerLight(id, LIGHTSTYLE_NORMAL)
}

stock SetPlayerLight(id, const LightStyle[])
{
    if(id != 0)
    {
        message_begin(MSG_ONE_UNRELIABLE, SVC_LIGHTSTYLE, .player = id)
        write_byte(0)
        write_string(LightStyle)
        message_end()        
    } else {
        message_begin(MSG_ALL, SVC_LIGHTSTYLE)
        write_byte(0)
        write_string(LightStyle)
        message_end()    
    }
}

stock PlaySound(id, const sound[])
{
    if(equal(sound[strlen(sound)-4], ".mp3")) client_cmd(id, "mp3 play ^"sound/%s^"", sound)
    else client_cmd(id, "spk ^"%s^"", sound)
}