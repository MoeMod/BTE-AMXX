//[]
// Game Vars
new g_newround,g_endround,g_freezetime,g_start,g_end,g_end_confirm
new g_trigger_start[32]
new g_button_total
new g_button_target[20][32]
new g_button_time[20]
new g_button_msg[20][32]
new g_touch_train

new g_end_zb_ontrain,g_end_hm_escape,g_end_allinfected
new g_zombiecount
new g_msgDeathMsg,g_msgScoreAttrib,g_msgScoreInfo,g_msgTextMsg,g_msgScreenFade
new g_fwSpawn

new g_score_zb,g_score_hm
// Player Vars
new g_zombie[33]
new g_nvg[33]
new Float:g_tr_time[33]
new g_score_human,g_score_zombie,g_startcount

new g_plr_touchtrain[33]
// Couunt
new g_count_start
new g_counter,g_counter_button
new g_button[20]
new g_player_lastcount[33]

// Spawns
new g_spawn_zombie_total
new Float:g_spawn_zombie[3][3]
new g_counter_totol,Float:g_spawn_counter[20][3]

// Resource
new res_music_start[]="music/ze_start.mp3"
new res_music_ready[]="music/ze_ready.mp3"
new res_music_humanend[]="music/ze_humanend.mp3"
new res_music_end_s[]="music/ze_end_s.wav"
new res_music_end_f[]="music/ze_end_f.wav"
new res_music_bgm[]=""
new res_music_eswin[]=""
new res_music_esfail[]=""
new res_model_zb[]="models/player/tank_zombi_host/tank_zombi_host.mdl"
new res_model_zbhand[]="models/v_knife_tank_zombi.mdl"
new res_model_zb2[]="models/player/tank_zombi_origin/tank_zombi_origin.mdl"
new res_sound_zbhurt[][]= {"zombi/zombi_hurt_01.wav","zombi/zombi_hurt_01.wav"}
new res_sound_zbhitwall[][]={"zombi/zombi_wall_1.wav","zombi/zombi_wall_2.wav","zombi/zombi_wall_3.wav"}
new res_sound_zbswing[][]={"zombi/zombi_swing_1.wav","zombi/zombi_swing_2.wav","zombi/zombi_swing_3.wav"}
new res_sound_zbhit[][]={"zombi/zombi_attack_1.wav","zombi/zombi_attack_2.wav","zombi/zombi_attack_3.wav"}
new res_sound_infection[][]={"zombi/human_death_01.wav","zombi/human_death_02.wav"}
new res_sound_nvg[][]={"items/nvg_off.wav", "items/nvg_on.wav"}
new res_sound_coming[][]={"vox/zombi_coming_1.wav","vox/zombi_coming_1.wav"}
new g_block_entity[][]={"trigger_once"}

new g_zombie_index,g_zombie_index2
new g_hamczbots,cvar_botquota

// special
new g_special_button
new Float:g_special_button_origin[3]
new g_EnteredBuyMenu[33];
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1034\\ f0\\ fs16 \n\\ par }
*/
