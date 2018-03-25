public plugin_natives()
{
	register_native("bte_get_user_zombie", "native_get_user_zombie", 1)
	register_native("bte_get_zombie_sex", "native_get_zombie_sex", 1)
	//register_native("bte_zb_get_user_sex", "native_get_user_sex", 1)
	//register_native("bte_zb_get_user_team", "native_get_user_team", 1)
	register_native("bte_zb3_get_user_zombie_class", "native_get_user_zombie_class", 1)
	register_native("bte_zb3_get_user_level", "native_get_user_level", 1)
	register_native("bte_zb3_can_use_skill2", "native_can_use_skill", 1)
	register_native("bte_zb3_register_zombie_class", "native_register_zombie_class", 1)
	register_native("bte_zb3_set_max_health", "native_set_max_health", 1)
	register_native("bte_zb3_get_max_health", "native_get_max_health", 1)
	register_native("bte_zb3_set_max_armor", "native_set_max_armor", 1)
	register_native("bte_zb3_get_max_armor", "native_get_max_armor", 1)
	register_native("bte_zb3_get_max_speed", "native_get_max_speed", 1)
	register_native("bte_zb3_set_max_speed", "native_set_max_speed", 1)
	register_native("bte_zb3_get_xdamage", "native_get_xdamage", 1)
	register_native("bte_zb3_set_xdamage", "native_set_xdamage", 1)

	register_native("bte_zb3_inflict_player", "native_inflict_player", 1)
	register_native("bte_zb3_can_use_skill", "native_can_use_skill2", 1)
	register_native("bte_zb3_set_next_restore_health", "native_set_next_restore_health", 1)


	// Read Supplybox

}
public native_set_next_restore_health(id, Float:fTime)
{
	g_fNextRestoreHealth[id] = get_gametime() + fTime;
}

public native_can_use_skill2(id)
{
	return g_iCanUseSkill[id];
}

public native_get_zombie_sex(id)
{
	return ArrayGetCell(zombie_sex, g_zombieclass[id]);
}

public Float:native_get_xdamage(id,level)
{
	return g_zombie_xdamage[id][level]
}
public native_set_xdamage(id,Float:xdamage,level)
{
	g_zombie_xdamage[id][level] = xdamage
}
public native_get_max_armor(id)
{
	return g_zombie_armor_start[id]
}
public native_set_max_armor(id,armor)
{
	g_zombie_armor_start[id] = armor
}

public native_inflict_player(iAttacker,iVictim)
{
	ExecuteHamB(Ham_TakeDamage,iVictim,0,iAttacker,0.0,DMG_CLUB)
}
public Float:native_get_max_speed(id)
{
	return g_flMaxSpeed[id]
}
public native_set_max_speed(id,Float:speed)
{
	g_flMaxSpeed[id] = speed
	set_pev(id, pev_maxspeed, g_flMaxSpeed[id])
}
public native_get_max_health(id)
{
	return g_zombie_health_start[id]
}
public native_set_max_health(id,health)
{
	g_zombie_health_start[id] = health
}
public native_get_user_level(id)
{
	return g_level[id]
}
public native_can_use_skill()
{
	return (!g_endround && g_newround)
}
public native_get_user_zombie_class(id)
{
	return g_zombieclass[id]
}
public native_get_user_zombie(id)
{
	if(id>32) return 0
	if(g_zombie[id]) return 1
	else if(g_hero[id]) return 2
	return 0
}
public native_register_zombie_class(const name[], const model[], Float:gravity, Float:speed, Float:knockback, const sound_death1[], const sound_death2[], const sound_hurt1[], const sound_hurt2[], const sound_heal[], const sound_evolution[], sex, modelindex, Float:xdamage, Float:xdamage2, host_hand)
{
	param_convert(1)
	param_convert(2)
	param_convert(6)
	param_convert(7)
	param_convert(8)
	param_convert(9)
	param_convert(10)
	param_convert(11)

	ArrayPushString(zombie_name, name)
	ArrayPushString(zombie_model,model)
	ArrayPushCell(zombie_gravity, gravity)
	ArrayPushCell(zombie_speed, speed)
	ArrayPushCell(zombie_knockback, knockback)
	ArrayPushCell(zombie_sex, sex)
	ArrayPushCell(zombie_modelindex, modelindex)
	ArrayPushString(zombie_sound_death1, sound_death1)
	ArrayPushString(zombie_sound_death2, sound_death2)
	ArrayPushString(zombie_sound_hurt1, sound_hurt1)
	ArrayPushString(zombie_sound_hurt2, sound_hurt2)
	ArrayPushString(zombie_sound_heal, sound_heal)
	ArrayPushString(zombie_sound_evolution, sound_evolution)
	ArrayPushCell(zombie_xdamage,xdamage)
	ArrayPushCell(zombie_xdamage2,xdamage2)
	ArrayPushCell(zombie_hosthand, host_hand)

	new viewmodel_host[64], viewmodel_origin[128], viewmodel_host_url[128], viewmodel_origin_url[64], wpnmodel[64], v_zombiebom[64], wpnmodel2[64], v_zombiebom2[64]
	formatex(viewmodel_host, charsmax(viewmodel_host), "%s_host", model)
	formatex(viewmodel_origin, charsmax(viewmodel_origin), "%s_origin", model)
	formatex(viewmodel_host_url, charsmax(viewmodel_host_url), "models/player/%s/%s.mdl", viewmodel_host, viewmodel_host)
	formatex(viewmodel_origin_url, charsmax(viewmodel_origin_url), "models/player/%s/%s.mdl", viewmodel_origin, viewmodel_origin)
	formatex(wpnmodel, charsmax(wpnmodel), "models/v_knife_%s.mdl", model)
	formatex(wpnmodel2, charsmax(wpnmodel2), "models/v_knife_%s_host.mdl", model)
	formatex(v_zombiebom, charsmax(v_zombiebom), "models/v_zombibomb_%s.mdl", model)
	formatex(v_zombiebom2, charsmax(v_zombiebom2), "models/v_zombibomb_%s_host.mdl", model)

	ArrayPushString(zombie_viewmodel_host, viewmodel_host)
	ArrayPushString(zombie_viewmodel_origin, viewmodel_origin)
	ArrayPushString(zombie_wpnmodel, wpnmodel)
	ArrayPushString(zombiebom_viewmodel, v_zombiebom)
	ArrayPushString(zombie_wpnmodel2, wpnmodel2)
	ArrayPushString(zombiebom_viewmodel2, v_zombiebom2)

	ArrayPushCell(zombie_modelindex_host, engfunc(EngFunc_PrecacheModel, viewmodel_host_url))
	ArrayPushCell(zombie_modelindex_origin, engfunc(EngFunc_PrecacheModel, viewmodel_origin_url))
	engfunc(EngFunc_PrecacheModel, wpnmodel)
	engfunc(EngFunc_PrecacheModel, v_zombiebom)
	engfunc(EngFunc_PrecacheSound, sound_death1)
	engfunc(EngFunc_PrecacheSound, sound_death2)
	engfunc(EngFunc_PrecacheSound, sound_hurt1)
	engfunc(EngFunc_PrecacheSound, sound_hurt2)
	engfunc(EngFunc_PrecacheSound, sound_heal)
	engfunc(EngFunc_PrecacheSound, sound_evolution)

	class_count++
	return class_count-1;
}
