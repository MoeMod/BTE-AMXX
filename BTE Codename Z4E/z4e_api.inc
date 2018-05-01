#if defined _z4e_api_included
  #endinput
#endif
#define _z4e_api_included

enum
{
    WINSTATUS_CT = 1,
    WINSTATUS_TERRORIST,
    WINSTATUS_DRAW
}

native z4e_api_set_player_maxspeed(id, Float:flMaxspeed, bKeep = true)
native z4e_api_reset_player_maxspeed(id)
native z4e_api_set_player_model(id, const szModel[])
native z4e_api_reset_player_model(id)
native z4e_api_set_player_team(id, CsTeams:iTeam, bUpdate = true)
native z4e_api_infinity_round(bSet)
native z4e_api_terminate_round(Float:flDelay, iWinstatus)

forward z4e_fw_api_bot_registerham(id)