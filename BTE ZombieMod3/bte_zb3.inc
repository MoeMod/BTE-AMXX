#if defined _bte_zb3_included
  #endinput
#endif
#define _bte_zb3_included

// Zombie DNA
enum _:TOTAL_DNA
{
	DNA_GENE_STRENGTHEN,
	DNA_INFECTION,
	DNA_CRISIS_RECOVERY,
	DNA_SPEED_STRENGTHEN,
	DNA_STRENGTHEN_GROUP,
	DNA_MOVING_RECOVERY,
	DNA_RECOVERY_STRENGTHEN,
	DNA_CRISIS_DEFENCE,
	DNA_PAINSHOCK_STRENGTHEN,
	DNA_ACCSHOOT_STRENGTHEN,
	DNA_GRAVITY_STRENGTHEN,
	DNA_ARMOR_STRENGTHEN,
	DNA_DEFENCE_STRENGTHEN,
	DNA_GODMODE_STRENGTHEN,
	DNA_FREEZE_ON_HIT,
	DNA_FREEZE_STRENGTHEN,
	DNA_ZOMBIE_ENVY,
	DNA_SKILL_STRENGTHEN,
	DNA_RAGE_STRENGTHEN,
}

// Zombie API
native bte_zb3_register_zombie_class(name[], model[], Float:gravity, Float:speed, Float:knockback, sound_death1[], sound_death2[], sound_hurt1[], sound_hurt2[], sound_heal[], sound_evolution[], sex, modelindex, Float:xdamage, Float:xdamage2, hand = 0) // 内部API
native bte_get_user_zombie(id) // 判断玩家是否为僵尸 (人类返回0 僵尸返回1 英雄返回2)
native bte_zb3_get_user_zombie_class(id) // 内部API
native MH_SendZB3Data(id,iDataType,iData) // 内部API
native MH_ZB3UI(id,sz[],slot,type,data) // 内部API
//native bte_zb3_can_use_skill() // 内部API
forward bte_zb_infected(victim,attacker) // 当人类被感染时发生 victim为被感染者 attacker为感染者
native bte_zb3_get_user_level(id) // 内部API
native bte_hms_get_skillstat(id) // 内部API
native bte_zb3_set_max_health(id,health)
native bte_zb3_get_max_health(id)
native bte_zb3_set_max_armor(id,armor)
native bte_zb3_get_max_armor(id)
native bte_zb3_set_next_restore_health(id, Float:fTime)
native bte_zb3_set_max_speed(id, Float:speed)

native bte_zb3_set_xdamage(id,Float:xdamage,level)
native bte_zb3_inflict_player(iAttacker,iVictim) // 强制感染

native bte_zb3_can_use_skill(id)

native bte_zb3_dna_get(id, which)
native bte_zb3_reset_zombie_property(id)
forward bte_zb3_reset_skill(id)