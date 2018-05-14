#if defined _z4e_gameplay_included
  #endinput
#endif
#define _z4e_gameplay_included

enum _:MAX_GAMESTATUS
{
    Z4E_GAMESTATUS_NONE = 0,
    Z4E_GAMESTATUS_GAMESTARTED,
    Z4E_GAMESTATUS_INFECTIONSTART,
    Z4E_GAMESTATUS_ROUNDENDED,
}

native z4e_gameplay_bits_get_status()
native z4e_gameplay_bits_set_status(bitsNew)
native z4e_gameplay_get_timer()
native z4e_gameplay_set_timer(iTimer)
native z4e_gameplay_get_countdowntime()
native z4e_gameplay_set_countdowntime(x)

forward z4e_fw_gameplay_plague_pre()
forward z4e_fw_gameplay_plague_post()
forward z4e_fw_gameplay_round_new()
forward z4e_fw_gameplay_round_start()
forward z4e_fw_gameplay_roundend_pre(iWinTeam)
forward z4e_fw_gameplay_roundend_post(iWinTeam)
forward z4e_fw_gameplay_timer()
