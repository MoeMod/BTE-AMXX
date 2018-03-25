new Float:g_flMaxSpeed[33]
new iBlockScoreInfoID = -1


new g_spawnCount,Float:g_spawns[MAX_SPAWNS][3][3],g_spawnCount_box,Float:g_spawns_box[MAX_SPAWNS][3]

new g_fwSpawn,g_fwUserInfected,g_fwDummyResult

new g_msgDeathMsg, g_msgScoreAttrib, g_msgStatusIcon,/*gmsgMoney,*/
g_msgScenario, /*g_msgDamage, g_HudMsg_ScoreMatch, */g_msgHostagePos, /*g_msgHostageK,*/ g_msgFlashBat, g_msgNVGToggle, g_msgHudTextArgs,
/*g_msgWeapPickup,*//*g_msgAmmoPickup, */g_msgTextMsg, g_msgSendAudio, g_msgTeamScore, g_msgScreenFade, g_msgClCorpse,g_msgScoreInfo,/*g_msgVGUIMenu,*/g_msgScreenShake,g_msgWeaponList,
/*g_msgCrosshair, g_msgHideWeapon,*//* g_msgMoney, */g_msgTeamInfo

new /*Cvar_Light,Cvar_BotQuota,*/Cvar_HolsterBomb

new g_light[2],g_sky_enable,g_skyname[32],g_ambience_rain,g_ambience_fog,g_fog_density[32],g_fog_color[32],g_ambience_snow,Array:g_objective_ents

// class zombie var
new class_count, Array:zombie_name, Array:zombie_gravity, Array:zombie_speed, Array:zombie_knockback, Array:zombie_modelindex,
Array:zombie_sound_death1, Array:zombie_sound_death2, Array:zombie_sound_hurt1, Array:zombie_sound_hurt2, Array:zombie_wpnmodel, Array:zombie_wpnmodel2,
Array:zombie_modelindex_host, Array:zombie_modelindex_origin, Array:zombie_viewmodel_host, Array:zombie_viewmodel_origin,
Array:zombie_sound_heal, Array:zombie_sound_evolution, Array:zombiebom_viewmodel, Array:zombiebom_viewmodel2, Array:zombie_sex, Array:zombie_xdamage, Array:zombie_xdamage2, Array:zombie_hosthand
new Array:zombie_model

new Array:sound_human_death, Array:sound_female_death, Array:sound_zombie_coming, Array:sound_zombie_comeback,Array:sound_zombie_attack,Array:sound_zombie_hitwall,Array:sound_zombie_swing

new RESPAWN_TIME_WAIT = 5
new /*MAX_HEALTH_ZOMBIE_RANDOM, */MIN_HEALTH_ZOMBIE_RANDOM
new HERO_MODEL_MALE[64],HERO_MODEL_FEMALE[64]/*,Float:HERO_GRAVITY*/, HERO_MODEL_MALE_INDEX, HERO_MODEL_FEMALE_INDEX
new Float:RESTORE_HEALTH_TIME, RESTORE_HEALTH_LV1, RESTORE_HEALTH_LV2
new Float:SUPPLYBOX_TIME, SUPPLYBOX_NUM, Float:SUPPLYBOX_TIME_FIRST, SUPPLYBOX_CLASSNAME[] = "bte_supplybox", SUPPLYBOX_SOUND_PICKUP[]="zombi/get_box.wav", SUPPLYBOX_SOUND_DROP[]="zombi/zombi_box.wav", SUPPLYBOX_MAX,Array:SUPPLYBOX_ITEMS
new /*ZOMBIEBOM_MODEL[64], */Float:ZOMBIEBOM_RADIUS=400.0, Float:ZOMBIEBOM_POWER=1500.0, ZOMBIEBOM_SOUND_EXP[]="zombi/zombi_bomb_exp.wav"
new const SUPPLYBOX_MODEL[]="models/supplybox.mdl"

new g_levelmax_check

new ZOMBIEBOMB_MODEL_W[]="models/w_zombibomb.mdl",ZOMBIEBOMB_MODEL_P[]="models/p_zombibomb.mdl"
//new const SND_ROUND_START[]="music/zb/zb_ready.wav",SND_WIN_HUMAN[]="bte/zb/zb_end_h.wav",SND_WIN_ZOMBIE[]="bte/zb/zb_end_z.wav",SND_BGM[]="music/zb/zb_start.mp3"
new const SND_NVG[][]={"items/nvg_off.wav", "items/nvg_on.wav"}
//new const SND_LEVELUP[]="zombi/levelup.wav"

//#define SND_COUNT_START		"vox/20secremain.wav"
#define SND_ROUND_START		"zombi/z5/start.mp3"
#define SND_ROUND_END		"zombi/z5/finish.mp3"
#define SND_WIN_HUMAN		"vox/win_human_2.wav"
#define SND_WIN_ZOMBIE		"vox/win_zombi_2.wav"
#define SND_BGM				"music/zb_start.mp3"

new const SND_COUNT[][] = {"vox/one.wav", "vox/two.wav", "vox/three.wav", "vox/four.wav", "vox/five.wav", "vox/six.wav",
"vox/seven.wav", "vox/eight.wav", "vox/nine.wav", "vox/ten.wav"}


new /*cache_spr_restore_health,*/cache_spr_zombie_respawn,cache_spr_zombiebomb_exp

new	/*g_freezetime,*/g_newround,g_endround,g_startcount,g_rount_count,g_supplybox_count,g_count_down,g_hamczbots
new g_score_human,g_score_zombie
new Float:g_c_zombie_swing_range = 28.0,Float:g_c_zombie_stab_range = 40.0

new	g_level[33],g_zombie[33],g_hero[33],g_evolution[33],g_restore_health[33],g_respawning[33],g_nvg[33],g_zombie_die[33],g_respawn_count[33],g_human[33]
new g_zombieclass[33],g_zombie_health_start[33],g_zombie_armor_start[33]/*,g_nextzombie[33]//,Float:g_maxspeed[33]*/
new Float:g_zombie_xdamage[33][3]
new g_havenvg[33]
new Float:g_next_picksupply[33]

new Float:g_fNextRestoreHealth[33];

//new g_block_check = 0
new g_mapname[32];

new g_iCanUseSkill[33];

new g_szLogName[128];

new g_attacking[33];

new g_player_weaponstrip;

new g_flDamageCount[33];

new Float:g_flHumanAttack, Float:g_flZombieDefence;
new Float:g_flNextCalc;

new OrpheuFunction:handleAddAccount;

new Float:g_flHMAdd;
new Float:g_flZBAdd;

new g_EnteredBuyMenu[33];