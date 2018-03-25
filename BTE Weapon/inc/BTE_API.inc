#if defined _bteapi_included
  #endinput
#endif
#define _bteapi_included

// ############### BTE WPN API ###################

enum _:BTE_WPN_DATA
{
	// Float:
	BTE_WPNDATA_DAMAGE,
	BTE_WPNDATA_SPEED,
	BTE_WPNDATA_KNOCKBACK,
	BTE_WPNDATA_RECOIL,
	BTE_WPNDATA_DMGZB,
	// Int return float(DATA)
	BTE_WPNDATA_CLIP,
	BTE_WPNDATA_AMMO,
	BTE_WPNDATA_RECOIL,
	BTE_WPNDATA_GRAVITY,
	BTE_WPNDATA_COST,
	BTE_WPNDATA_BUY
}
enum _:BTE_WPN_NAME
{
	BTE_WPNDATA_CN_NAME,
	BTE_WPNDATA_EN_NAME
}
enum _:BTE_MOD
{
	BTE_MOD_NONE=0,
	BTE_MOD_TD,
	BTE_MOD_ZE,
	BTE_MOD_NPC,
	BTE_MOD_ZB1,
	BTE_MOD_ZE,
	BTE_MOD_GD,
	BTE_MOD_DR,
	BTE_MOD_DM,
	BTE_MOD_GHOST,
	BTE_MOD_TD2,
	BTE_MOD_RPG_ONLY
}

enum _:BTE_WEAPON_LIMIT
{
	WEAPON_LIMIT_NO=0,
	WEAPON_LIMIT_SNIPER,
	WEAPON_LIMIT_PISTOL,
	WEAPON_LIMIT_GRENADE,
	WEAPON_LIMIT_KNIFE
}

enum _:BTE_ZB3UI_RETINA
{
	RETINA_FASTRUN=1,// Default Zombie
	RETINA_A,
	RETINA_INVISIBLE,// Speed Zombie
	RETINA_SPEEDUP,// Human Skill
	RETINA_A,
	RETINA_A,
	RETINA_ACCSHOOT,// Human Skill
}
// Weapon API
native bte_wpn_get_wpn_data(id,idwpn,iSlot,iSection,iSet,fValue) // 获取/设置 武器的数据
native bte_wpn_get_is_admin(id) // 检查玩家是否为管理员
native bte_wpn_give_named_wpn(id,sName[])  // 给玩家武器
native bte_wpn_set_playerwpn_model(id,iVis,sModel[],iBody,iSeq)  // 设置玩家武器的P模型 iVis 控制之后可视 sModel设置P模型 iBody 设置P模型body iSeq设置P模型动作序列
native bte_wpn_get_wpn_name(id,iCurrent,iType,sName[]) // 获取玩家的武器名字 如果iCurrent==0则获取当前玩家手中的武器 iType为BTE_WPNDATA_CN_NAME 或 BTE_WPNDATA_EN_NAME 这样在sName中就会保存中文/英文名字
native bte_wpn_en_to_cn_name(sEnName[],sCnName[]) // 把武器模型的名字转换为中文名
native bte_wpn_menu_add_item(hMenu,iSlot) // 内部API
native bte_wpn_get_playerwpn_model(id) // 获取玩家P模型的实体ID
native bte_wpn_get_mod_running() // 获得当前的模式 (注意 生化3和生化1都返回BTE_MOD_ZB1)
native bte_wpn_precache_named_weapon(sName[]) //  缓存一把枪支(必须在bte_fw_precache_weapon_pre中使用)
native bte_wpn_play_player_sequence(id,iSeq) // 功能已删除
native bte_wpn_play_player_sequence2(id,iSeq) // 功能已删除
native bte_wpn_get_zombie_anim_time(id) // 功能已删除
native bte_wpn_strip_weapon(id,iSlot) // 没收玩家武器 iSlot设置要没收的武器槽
native bte_wpn_set_maxspeed(id,Float:fSpeed) // 设置玩家最大移动速度 (pev_maxspeed)
forward bte_fw_precache_weapon_pre() // 当缓存仓库武器前发生 你可以在这里缓存仓库中不存在的枪(但是在bte_wpn.ini中要存在)
native bte_wpn_set_fullammo(id) // 是玩家武器子弹满
native bte_wpn_set_ammo(id,slot,ammo)
native bte_wpn_get_ammo(id,slot)
native bte_wpn_get_wpn_dmg(id)

forward bte_wpn_buy_wpn(id,iSlot)

native bte_wpn_set_ammo_clip(id,iSlot,clip)
native bte_wpn_set_gerenade_ammo(id,type,ammo)
native bte_wpn_play_seqence(id,seq)


native bte_get_wpndata(i,sData[])

// Player API
#define SEX_MALE	1
#define SEX_FEMALE	2
native bte_get_user_sex(id) // 获得玩家的性别
native bte_get_user_showdamage(id)
native bte_reset_user_model(id) // 重置玩家人物模型
native bte_set_user_model(id, sModel[]) // 设置玩家人物模型
native bte_set_user_model_index(id, iModelIndex) // 设置模型索引
native bte_reset_user_model_index(id) // 重置玩家人物模型索引
native api_cs_set_player_team(q,b,c) // 内部API



// Zombie API
native bte_zb3_register_zombie_class(name[], model[], Float:gravity, Float:speed, Float:knockback, sound_death1[], sound_death2[], sound_hurt1[], sound_hurt2[], sound_heal[], sound_evolution[], sex, modelindex, Float:xdamage, Float:xdamage2, hand) // 内部API
native bte_get_user_zombie(id) // 判断玩家是否为僵尸 (人类返回0 僵尸返回1 英雄返回2)
native bte_zb3_get_user_zombie_class(id) // 内部API
native MH_SendZB3Data(id,iDataType,iData) // 内部API
native MH_ZB3UI(id,sz[],slot,type,data) // 内部API
native bte_zb3_can_use_skill() // 内部API
forward bte_zb_infected(victim,attacker) // 当人类被感染时发生 victim为被感染者 attacker为感染者
native bte_zb3_get_user_level(id) // 内部API
native bte_hms_get_skillstat(id) // 内部API
native bte_zb3_set_max_health(id,health)
native bte_zb3_get_max_health(id)
native bte_zb3_set_max_armor(id,armor)
native bte_zb3_get_max_armor(id)
native bte_zb3_set_max_speed(id,Float:speed)
native bte_zb3_get_max_speed(id)
native bte_zb3_set_xdamage(id,Float:xdamage,level)
native bte_zb3_inflict_player(iAttacker,iVictim)

// Npc API
native bte_npc_is_npc(iEnt)

// Extra API
native bte_fun_get_point(id) // 内部API
native bte_fun_set_point(id,point) // 内部API
native bte_fun_process_data(id,data) // 内部API
native bte_fun_get_enhance_name(id,name[]) // 内部API
native bte_fun_get_enhance_id(id,name[])
native bte_fun_get_have_mode_item(id,iItem)
// Items API
native bte_item_register_item(sName[],sInfo[],iCost,iTeam) // 内部API





