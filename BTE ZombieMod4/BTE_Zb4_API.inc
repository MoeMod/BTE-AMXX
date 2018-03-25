//native bte_get_user_zombie(id)
native bte_get_user_power(id)
native bte_set_user_power(id, power, Float:flashtime = 0.5)
native bte_set_using_skill(id, using_skill)
native bte_zb4_is_using_accshoot(id)
native bte_zb4_regiter_zombie(name[], model[], viewmodel[], stun[], Float:max_speed, Float:gravity, Float:heal_day, Float:heal_night, Float:xdamage, Float:knockback, Float:vm);

native bte_zb4_is_stuned(id)
native bte_zb4_is_using_skill(id)
native bte_zb4_get_zombie_class(id)
native bte_zb4_can_use_skill(id)

native bte_zb4_get_day_status()

native bte_zb4_set_dash(id, i, Float:time, value)
native bte_zb4_get_dash(id)
native bte_zb4_set_xdamage(id, Float:xdamage = 0.0)

native MH_ZB4SendData(id, type)
native MH_ZB4SetNightTime(start, end)


forward bte_zb4_kick(iVictim, iAttacker);

#define EMITSOUND_HURT	1
#define EMITSOUND_DEAD	2
forward bte_zb_EmitSound(id, iSoundType, iChannel, Float:volume, Float:attn, flags, pitch)

forward ZombieSkill(id, iEnt)
forward ZombieSkillEnd(id, iEnt)
