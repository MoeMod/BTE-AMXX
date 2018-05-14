#if defined _z4e_burn_included
  #endinput
#endif
#define _z4e_burn_included

native z4e_burn_get(id);
native z4e_burn_set(id, Float:flTime, bDrawEffect);
forward z4e_fw_burn_set_pre(id, Float:flTime, bDrawEffect);
forward z4e_fw_burn_set_post(id, Float:flTime, bDrawEffect);