#if defined _z4e_team_included
  #endinput
#endif
#define _z4e_team_included

enum
{
    Z4E_TEAM_INVALID = 0,
    Z4E_TEAM_ZOMBIE = 1,
    Z4E_TEAM_HUMAN = 2,
    Z4E_TEAM_SPECTATOR = 3
};

native z4e_team_get(id)

stock z4e_team_get_user_zombie(id)
    return z4e_team_get(id) && z4e_team_get(id) == Z4E_TEAM_ZOMBIE

native z4e_team_set(id, iTeam)

native z4e_team_count(iTeam, bAlive = 0)
native z4e_team_swap()
native z4e_team_balance()

native z4e_team_bits_get_member(iTeam)
native z4e_team_bits_get_connected()
native z4e_team_bits_get_alive()

forward z4e_fw_team_set_pre(id, iTeam)
forward z4e_fw_team_set_act(id, iTeam)
forward z4e_fw_team_set_post(id, iTeam)

forward z4e_fw_team_spawn_pre(id)
forward z4e_fw_team_spawn_act(id)
forward z4e_fw_team_spawn_post(id)