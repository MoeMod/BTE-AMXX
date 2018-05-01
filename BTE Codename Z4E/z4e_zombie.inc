#if defined _z4e_zombie_included
  #endinput
#endif
#define _z4e_zombie_included

native z4e_zombie_originate(id, iZombieCount, bIgnoreCheck = 0)
native z4e_zombie_infect(id, iAttacker = 0, bIgnoreCheck = 0)
native z4e_zombie_respawn(id, bIgnoreCheck = 0)

forward z4e_fw_zombie_originate_pre(id, iZombieCount)
forward z4e_fw_zombie_originate_act(id, iZombieCount)
forward z4e_fw_zombie_originate_post(id, iZombieCount)
forward z4e_fw_zombie_infect_pre(id, iAttacker)
forward z4e_fw_zombie_infect_act(id, iAttacker)
forward z4e_fw_zombie_infect_post(id, iAttacker)
forward z4e_fw_zombie_respawn_pre(id)
forward z4e_fw_zombie_respawn_act(id)
forward z4e_fw_zombie_respawn_post(id)