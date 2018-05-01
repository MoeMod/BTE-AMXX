#if defined _z4e_freeze_included
  #endinput
#endif
#define _z4e_freeze_included

native z4e_freeze_get(id);
native z4e_freeze_set(id, Float:flTime, bDrawEffect);
forward z4e_fw_freeze_set_pre(id, Float:flTime, bDrawEffect);
forward z4e_fw_freeze_set_post(id, Float:flTime, bDrawEffect);