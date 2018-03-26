#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <metahook>
#include <round_terminator>
#include <hamsandwich>
#include <BTE_API>
#define PLUGIN_NAME	"BTE Base"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"BTE TEAM"
#define PLAYER_URL	"bte_player.ini"
#define MAX_PLAYER	60
#define PRINT(%1) client_print(1,print_chat,%1)

// ##################### LINE DEFINE #########################
#define 	RES_C	"		^"ControlName^"		^"%s^"^n"
#define		RES_F	"		^"fieldName^"		^"%s^"^n"
#define		RES_X	"		^"xpos^"			^"%d^"^n"
#define		RES_Y	"		^"ypos^"			^"%d^"^n"

#define		RES_W	"		^"wide^"			^"%d^"^n"
#define		RES_T	"		^"tall^"			^"%d^"^n"
#define		RES_A	"		^"autoResize^"		^"%d^"^n"
#define		RES_P	"		^"pinCorner^"		^"%d^"^n"
#define		RES_V	"		^"visible^"		^"%d^"^n"
#define		RES_E	"		^"enabled^"		^"%d^"^n"
#define		RES_TAB	"		^"tabPosition^"		^"%d^"^n"
#define 	RES_LABEL "		^"labelText^"		^"%s^"^n"
#define 	RES_TA	"		^"textAlignment^"		^"%s^"^n"
#define 	RES_DT	"		^"dulltext^"		^"%d^"^n"
#define 	RES_BT	"		^"brighttext^"		^"%d^"^n"
#define 	RES_FONT	"		^"font^"			^"%s^"^n"
#define 	RES_WP	"		^"wrap^"			^"%d^"^n"
#define 	RES_SI	"		^"scaleImage^"		^"%d^"^n"
#define 	RES_I	"		^"image^"			^"%s^"^n"
#define		RES_CMD	"		^"command^"		^"%s^"^n"
#define 	RES_FR	"		^"fillColor^"		^"%s^"^n"
#define 	RES_Z	"		^"zpos^"		^"%d^"^n"

new g_player_name[MAX_PLAYER][32]
new g_player_model[MAX_PLAYER][32]
new g_player_model_index[MAX_PLAYER]
new g_player_sex[MAX_PLAYER]
new g_player_team[MAX_PLAYER]
new g_player_radio[MAX_PLAYER][32]
new g_player_showdamage[MAX_PLAYER]

new g_bHasCustomModel[33]
new g_szCustomModel[33][32]

new g_szLocation[33][32]
new g_set_model_index, g_modelindex_default, g_player_total, g_sex[33], g_idplayer[33], g_team[33], g_showdamage[33]
new g_dir_model[64] = "models/player/%s/%s.mdl"
new autoselect[] = "autoselect"
/*
new g_cache_player_ct_name[MAX_PLAYER][32]
new g_cache_player_t_name[MAX_PLAYER][32]
new g_cache_player_ct_name_chn[MAX_PLAYER][32]
new g_cache_player_t_name_chn[MAX_PLAYER][32]
new g_count_t,g_count_ct
*/
new g_init_player[33]
new g_bot_init

new g_bBlockEmitSound

enum
{
	SECTION_NAME = 0,
	SECTION_MODEL,
	SECTION_TEAM,
	SECTION_SEX,
	SECTION_HAND,
	SECTION_RADIO,
	SECTION_TATTOO,
	SECTION_EMOTION
}
// CS Teams
enum
{
	FM_CS_TEAM_UNASSIGNED = 0,
	FM_CS_TEAM_T,
	FM_CS_TEAM_CT,
	FM_CS_TEAM_SPECTATOR
}
enum TEAM
{
	TEAM_T = 1,
	TEAM_CT = 2
}

new g_msgSendAudio,g_msgTextMsg,g_msgSayText

new g_fw_PlayerModelChange, g_fw_DummyResult;

const OFFSET_LINUX = 5
const OFFSET_MODELINDEX = 491
// sound female
new const SOUND_F_BHIT[3][] = { "player/f_bhit_flesh-1.wav",
			"player/f_bhit_flesh-2.wav",
			"player/f_bhit_flesh-3.wav"}
new const SOUND_F_DIE[3][] = { "player/f_die1.wav",
			"player/f_die2.wav",
			"player/f_die3.wav"}
new const SOUND_F_HS[3][] = { "player/f_headshot1.wav",
			"player/f_headshot2.wav",
			"player/f_headshot3.wav"}

new cvar_bot_quota

public plugin_end()
{
	server_cmd("sv_noroundend 0")
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0")
	register_event("Location", "Event_Location", "be")
	register_forward(FM_EmitSound, "fw_EmitSound")
	register_clcmd("bte_choose_player", "cmd_choose_player")
	g_msgSendAudio = get_user_msgid("SendAudio")
	register_message(g_msgSendAudio, "message_SendAudio")
	g_msgTextMsg=get_user_msgid("TextMsg")
	g_msgSayText=get_user_msgid("SayText")
	register_message(g_msgSayText,"message_SayText")
	register_event("CurWeapon","Event_CurWeapon","be","1=1")

	//register_srvcmd("print_model_all", "print_model_all")

	cvar_bot_quota = get_cvar_pointer("bot_quota")
	//register_event("StatusValue", "SpectatorCheckBody", "bd", "1=2")
	//register_event("SpecHealth2", "SpectatorCheckBody", "bd")

	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	register_forward(FM_SetClientKeyValue, "Forward_SetClientKeyValue")

	register_forward(FM_CheckVisibility,"CheckLocation")
	register_forward(FM_SetModel, "CheckModel")

	g_fw_PlayerModelChange = CreateMultiForward("bte_player_model_change", ET_IGNORE, FP_CELL);
}

public CheckModel(iEnt, sModel[])
{
	if (strlen(sModel) < 8) return FMRES_IGNORED
	if (containi(sModel, "backpack"))
	{
		set_pev(iEnt,pev_euser2, 1)
		set_pev(iEnt,pev_iuser2, 998)
	}
	return FMRES_IGNORED
}
public CheckLocation(iEnt,pSet)
{
	if(!pev_valid(iEnt)) return FMRES_IGNORED
	static iFlag, iUser;
	iFlag = pev(iEnt, pev_flags)
	iUser = pev(iEnt, pev_iuser2)

	if (iFlag & FL_CLIENT || iUser == 998)
	{
		forward_return(FMV_CELL,1)
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public print_model_all()
{
	for (new id = 1; id <= 32; id++)
	{
		if (is_user_alive(id))
		{
			static currentmodel[32], model_url[64]
			fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
			pev(id, pev_model, model_url, 64)

			server_print("id: %d mid: %d hcm: %d model: %s url: %s cusmdl: %s radio: %s", id, g_idplayer[id], g_bHasCustomModel[id], currentmodel, model_url, g_szCustomModel[id], g_player_radio[g_idplayer[id]])
		}
	}
}

public Forward_SetClientKeyValue( id, const infobuffer[], const key[])
{
	if (get_pdata_bool(id, 837)) // m_bVIP
		return FMRES_IGNORED

	if (g_idplayer[id] && equal(key, "model"))
	{
		static currentmodel[32], newmodel[32]
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		copy(newmodel, 32, g_bHasCustomModel[id] ? g_szCustomModel[id] : g_player_model[g_idplayer[id]])

		if (!equal(currentmodel, newmodel) && strlen(newmodel) > 1)
		{
			fm_set_user_model(id, newmodel);
		}

		return FMRES_SUPERCEDE
	}

	return FMRES_IGNORED
}

stock fm_set_user_model(id,model[])
{
	if (strlen(model) <= 1)
		return;

	//engfunc( EngFunc_SetClientKeyValue, id, engfunc( EngFunc_GetInfoKeyBuffer, id ), "model", model )
	set_user_info(id, "model", model);

	new model_url[64];
	format(model_url, charsmax(model_url), "models/player/%s/%s.mdl", model, model);
	engfunc(EngFunc_SetModel, id, model_url);

	if (!g_bHasCustomModel[id])
		fm_cs_set_user_model_index(id, g_player_model_index[g_idplayer[id]])

	/*static currentmodel[32], newmodel[64]
	fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
	pev(id, pev_model, newmodel, 64);
	server_print("id: %d  infoset: %s  curinfo: %s  modelurl: %s", id, model, currentmodel, newmodel)*/
}

public fw_PlayerSpawn_Post(id)
{
	if(!g_init_player[id]) set_task(1.0,"ChangeModel",id)
		
}

public ChangeModel(id)
{
	g_init_player[id] = 1
	set_player_class(id, 0)
}

public Event_CurWeapon(id)
{
	new wpn = get_user_weapon(id)
	if(wpn == CSW_KNIFE)
	{
		new model[64]
		pev(id, pev_viewmodel2, model, 63)
		if(equal(model,"models/v_knife.mdl") && g_sex[id] == 2)
		{
			set_pev(id,pev_viewmodel2,"models/v_knife_w.mdl")
		}
	}
}

public message_SayText(fuck,you,id)
{
	static text[64]
	get_msg_arg_string(2, text, sizeof text - 1)
	if (equal(text, "#Cstrike_Name_Change")) return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public Event_Location()
{
	read_data(2, g_szLocation[read_data(1)], 31)
}
public plugin_precache()
{
	load_config()
	for (new i = 0; i <= 2; i++)
	{
		engfunc(EngFunc_PrecacheSound, SOUND_F_BHIT[i])
		engfunc(EngFunc_PrecacheSound, SOUND_F_DIE[i])
		engfunc(EngFunc_PrecacheSound, SOUND_F_HS[i])
	}
	g_modelindex_default = engfunc(EngFunc_PrecacheModel, "models/player/yuri/yuri.mdl")
	engfunc(EngFunc_PrecacheModel,"models/v_knife_w.mdl")
	//makeui()
}

native bte_get_zombie_sex(id)

public message_SendAudio(msg_id, msg_dest, msg_entity)
{
	new id, audio[64], audio_new[64];
	id = get_msg_arg_int(1);
	get_msg_arg_string(2, audio, charsmax(audio));

	if (g_player_radio[g_idplayer[id]][0])
		format(audio_new, charsmax(audio_new), "%s_%s", audio, g_player_radio[g_idplayer[id]]);
	else
		format(audio_new, charsmax(audio_new), "%s", audio);

	if (bte_wpn_get_mod_running() == BTE_MOD_ZB1)
	{
		if (bte_get_user_zombie(id) == 1)
		{
			if (bte_get_zombie_sex(id) == 2)
				format(audio_new, charsmax(audio_new), "%s_%s", audio, "ZW");
			else
				format(audio_new, charsmax(audio_new), "%s_%s", audio, "ZB");
		}
	}

	set_msg_arg_string(2, audio_new);
	return PLUGIN_CONTINUE;
}

#if 0

public message_SendAudio(msg_id, msg_dest, msg_entity)
{
	new audio[64], audio_f[8], id

	id = get_msg_arg_int(1)

	get_msg_arg_string(2, audio, charsmax(audio))
	format(audio_f, charsmax(audio_f), "%s", audio)

	// replace sound radio 1 - 3
	new check, radio_new[64]
	for (new i=0; i<23; i++)
	{
		if( equal(audio[7], RADIO_MESSEAGE[i]))
		{
			format(radio_new, charsmax(radio_new), "%s", get_urlsound_radio(RADIO_FILE[i], id))

			check = 1
		}
	}
	if((contain(audio, "draw")>-1 || contain(audio, "win")>-1) && bte_wpn_get_mod_running() ==BTE_MOD_ZB1)
	{
		return PLUGIN_HANDLED
	}
	// replace sound radio other
	if (equal(audio_f, "%!MRAD_") && !check)
	{
		// radio one
		replace(audio, charsmax(audio), "%!MRAD_", "")
		strtolower(audio)
		format(radio_new, charsmax(radio_new), "%s", get_urlsound_radio(audio, id))

		// radio all
		if (!id )
		{
			send_radio_all(audio)
			return PLUGIN_HANDLED
		}
	}

	// replace radio
	if (file_exists(get_fullurl_radio(radio_new))) set_msg_arg_string(2, radio_new)

	return PLUGIN_CONTINUE
}
#endif

/*
get_urlsound_radio(filename[], id)
{
	new audio[64]
	if(g_radio[id][0])
		format(audio, charsmax(audio), "radio/%s/%s.wav", g_radio[id], filename)
	else
		format(audio, charsmax(audio), "radio/%s.wav",filename)

	if(bte_wpn_get_mod_running() == BTE_MOD_ZB1)
	{
		if(bte_get_user_zombie(id) == 1)
		{
			if(bte_get_zombie_sex(id) == 2)
				format(audio, charsmax(audio), "radio/%s/%s.wav", "zombie_female", filename)
			else
				format(audio, charsmax(audio), "radio/%s/%s.wav", "zombie_male", filename)
		}
	}
	return audio
}
get_fullurl_radio(file[])
{
	new audio[64]
	format(audio, charsmax(audio), "sound/%s", file)

	return audio
}
send_radio_all(audio[])
{
	for (new id = 1; id < 33; id++)
	{
		if (!is_user_connected(id)) continue;

		message_begin(MSG_ONE, g_msgSendAudio, _, id)
		write_byte(0)
		write_string(get_urlsound_radio(audio, id))
		write_short(100)
		message_end()
	}
}*/

public register_ham_czbots(id)
{
	if (g_bot_init || !is_user_connected(id)) return
	RegisterHamFromEntity(Ham_Spawn, id, "fw_PlayerSpawn_Post", 1)
	
	g_bot_init = 1

}

public client_putinserver(id)
{
	if (is_user_bot(id) && !g_bot_init)
	{
		set_task(1.0, "register_ham_czbots", id)
	}
	g_init_player[id] = 0
	reset_value(id)
}

public fw_ClientDisconnect(id)
{
	reset_value(id)
}
reset_value(id)
{
	g_idplayer[id] = 0
	g_sex[id] = 1
	g_team[id] = 0
	g_showdamage[id] = 0
	// Random Player
	set_player_class(id, 0)
}

public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if (g_bBlockEmitSound)
		return FMRES_SUPERCEDE;

	if (!is_user_connected(id))
		return FMRES_IGNORED;

	// change sound Female
	if (g_sex[id] != 2) return FMRES_IGNORED;
	new sound[101]
	for (new i = 0; i <= 2; i++)
	{
		// Hit
		format(sound, charsmax(sound), "%s", SOUND_F_BHIT[i])
		replace(sound,charsmax(sound),"f_","")
		if (equal(sample, sound))
		{
			emit_sound(id, channel, SOUND_F_BHIT[i], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
		// Die
		format(sound, charsmax(sound), "%s", SOUND_F_DIE[i])
		replace(sound,charsmax(sound),"f_","")
		if (equal(sample, sound))
		{
			emit_sound(id, channel, SOUND_F_DIE[i], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
		if (equal(sample, "player/death6.wav"))
		{
			emit_sound(id, channel, "player/f_die3.wav", volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
		// Headshot
		format(sound, charsmax(sound), "%s", SOUND_F_HS[i])
		replace(sound,charsmax(sound),"f_","")
		if (equal(sample, sound))
		{
			emit_sound(id, channel, SOUND_F_HS[i], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

#include "offset.inc"
#define TASK_RESETMODEL 56255

public Event_HLTV()
{
	//MH_DrawCountDownReset(0)
	//MH_SetViewEntityRender(0,kRenderFxNone,kRenderNormal, 255, 255, 255,  16 )
	set_task(1.0,"set_model_new_round")
	for (new id = 1; id < 33; id++)
	{
		if (!is_user_connected(id))
		continue;
		MH_DrawFontText(id,"Author : New BTE Team",1,0.10,0.69,255,255,255,15,5.0,1.0,0,9999)
		
		g_bHasCustomModel[id] = 0;
		//reset_model(id + TASK_RESETMODEL);
	}
}

public set_model_new_round()
{
	for (new id = 1; id < 33; id++)
	{
		set_task(random_float(0.0, 2.0), "reset_model", id + TASK_RESETMODEL);
	}
}

public reset_model(taskid)
{
	new id = taskid - TASK_RESETMODEL;

	if (!is_user_connected(id))
		return;

	if (get_pdata_bool(id, 837))
		return

	if (bte_wpn_get_mod_running() == BTE_MOD_NONE || bte_wpn_get_mod_running() == BTE_MOD_TD || bte_wpn_get_mod_running() == BTE_MOD_GHOST)
	{
		if (is_user_alive(id))
		{
			new iTeam = get_pdata_int(id, m_iTeam);
			if (iTeam != g_player_team[g_idplayer[id]])
			{
				new idplayer = get_random_class(iTeam);
				if (idplayer)
					set_player_class(id, idplayer);

				return;
			}
		}
	}

	if (!g_idplayer[id])
	{
		new iTeam = get_pdata_int(id, m_iTeam);
		if (iTeam == 2 || iTeam == 1)
			g_idplayer[id] = get_random_class(iTeam);

		set_player_model(id, g_idplayer[id]);
	}
	// Update Model
	new name[32]
	fm_cs_get_user_model(id, name,31)
	if(!equal(name, g_player_model[g_idplayer[id]]))
	{
		set_player_model(id, g_idplayer[id]);
	}
}

public cmd_choose_player(id)
{
	if (!is_user_connected(id) || bte_get_user_zombie(id)) return PLUGIN_HANDLED

	new models[64]
	read_argv(1, models, 63)

	for(new i=1; i<=g_player_total; i++)
	{
		if (g_player_sex[i]>0)
		{
			if (equali(g_player_model[i], models))
			{
				set_player_class(id, i)

				ExecuteForward(g_fw_PlayerModelChange, g_fw_DummyResult, id);
				return PLUGIN_HANDLED
			}
		}
	}

	if (equali(models, autoselect))
	{
		new idplayer = get_random_class(get_user_team(id))
		if (idplayer) set_player_class(id, idplayer)
	}

	return PLUGIN_HANDLED
}
get_random_class(team)
{
	new n_player_idplayer[MAX_PLAYER], total, idrandom
	for (new i=1; i<=g_player_total; i++)
	{
		if (g_player_team[i] == team)
		{
			n_player_idplayer[total+1] = i
			total++
		}
	}
	if (total) idrandom = n_player_idplayer[random_num(1, total)]

	return idrandom
}

set_player_class(id, idplayer)
{
	new team = get_user_team(id)
	//if (team!=FM_CS_TEAM_T && team!=FM_CS_TEAM_CT) return;

	// check idplayer
	if (!idplayer)
	{
		idplayer = get_random_class(team)
	}

	// check team
	else if (team != g_player_team[idplayer])
	{
		fm_cs_set_user_team(id, g_player_team[idplayer])

		if (is_user_alive(id))
			user_kill(id);
	}

	// set class player
	set_player_model(id, idplayer)

	// show msg
}

set_player_model(id, idplayer)
{
	g_idplayer[id] = idplayer
	g_sex[id] = g_player_sex[idplayer]
	//set hand
	g_team[id] = g_player_team[idplayer]
	g_showdamage[id] = g_player_showdamage[idplayer]
	fm_set_user_model(id, g_player_model[idplayer])

	if (g_set_model_index)
	{
		fm_cs_set_user_model_index(id, g_player_model_index[idplayer])
	}
}

stock fm_cs_get_user_model( player, model[], len )
{
	engfunc( EngFunc_InfoKeyValue, engfunc( EngFunc_GetInfoKeyBuffer, player ), "model", model, len )
}

#include "bte.inc"
load_config()
{
	g_set_model_index = 1;

	// Build customization file path
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, "class.lst")

	new linedata[1024];

	new file = fopen(path, "rt")
	new idplayer = 1
	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata));
		replace(linedata, charsmax(linedata), "^n", "");

		if (!('a' <= linedata[0] <= 'z') && !('A' <= linedata[0] <= 'Z'))
			continue;

		copy(g_player_model[idplayer], 31, linedata);

		GetPrivateProfile(linedata, "Sex", "", "cstrike/class.ini", BTE_INT, g_player_sex[idplayer]);
		GetPrivateProfile(linedata, "Team", "", "cstrike/class.ini", BTE_INT, g_player_team[idplayer]);
		GetPrivateProfile(linedata, "Radio", "", "cstrike/class.ini", BTE_STRING, g_player_radio[idplayer], 32);
		GetPrivateProfile(linedata, "ShowDamage", "", "cstrike/class.ini", BTE_INT, g_player_showdamage[idplayer]);

		new modelurl[64];
		format(modelurl, charsmax(modelurl), g_dir_model, g_player_model[idplayer], g_player_model[idplayer])
		g_player_model_index[idplayer] = precache_model(modelurl)

		g_player_total = idplayer
		idplayer++
	}
}
#if 0
load_config()
{
	// Build customization file path
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, SETTING_FILE)

	// File not present
	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
		set_fail_state(error)
		return;
	}

	// Set up some vars to hold parsing info
	new linedata[1024], key[64], value[960], key2[64], value2[960]

	// Open customization file for reading
	new file = fopen(path, "rt")
	new idplayer = 1
	while (file && !feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, charsmax(linedata))

		// Replace newlines with a null character to prevent headaches
		replace(linedata, charsmax(linedata), "^n", "")

		// Blank line or comment
		if (!linedata[0] || linedata[0] == ';') continue;

		strtok(linedata, key2, charsmax(key2), value2, charsmax(value2), '=')
		trim(key2)
		trim(value2)

		// set model index
		if (equal(key2, "SET_MODEL_INDEX"))
		{
			g_set_model_index = str_to_num(value2)
			continue;
		}

		// Replace
		replace(linedata, charsmax(linedata), ",", "")
		replace(linedata, charsmax(linedata), "[name]", ",")
		replace(linedata, charsmax(linedata), "[model]", ",")
		replace(linedata, charsmax(linedata), "[team]", ",")
		replace(linedata, charsmax(linedata), "[sex]", ",")
		replace(linedata, charsmax(linedata), "[hand]", ",")
		replace(linedata, charsmax(linedata), "[radio]", ",")
		replace(linedata, charsmax(linedata), "[tattoo]", ",")
		replace(linedata, charsmax(linedata), "[emotion]", ",")

		// Get value
		strtok(linedata, key, charsmax(key), value, charsmax(value), ',')
		new i

		while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
		{
			switch (i)
			{
				case SECTION_NAME:
				{
					format(g_player_name[idplayer], 31, "%s", key)
				}
				case SECTION_MODEL:
				{
					format(g_player_model[idplayer], 31, "%s", key)
				}
				case SECTION_TEAM: g_player_team[idplayer]  = str_to_num(key)
				case SECTION_SEX: g_player_sex[idplayer] = str_to_num(key)
				case SECTION_HAND: g_player_hand[idplayer] = str_to_num(key)
				case SECTION_RADIO:
				{
					format(g_player_radio[idplayer],31,"%s",key)
				}
				case SECTION_TATTOO:
				{
					format(g_player_tattoo[idplayer],31,"%s",key)
				}
				case SECTION_EMOTION:
				{
					g_player_emotion[idplayer]  = str_to_num(key)
				}
			}
			i++
		}

		// Set Value
		new modelurl[64]
		format(modelurl, charsmax(modelurl), g_dir_model, g_player_model[idplayer], g_player_model[idplayer])
		g_player_model_index[idplayer] = precache_model(modelurl)

		g_player_total = idplayer
		idplayer++
	}
}
#endif

reset_user_model(id)
{
	if (!is_user_connected(id)) return;

	if (!g_idplayer[id])
	{
		g_idplayer[id] = get_random_class(get_user_team(id))
	}
	set_player_model(id, g_idplayer[id])
}
//////////////////////////STOCK//////////////////////
stock fm_cs_set_user_team(id, team)
{
	if (is_user_connected(id))
	{
		if(get_pdata_int(id, 114) != team)
			cs_set_user_team(id, team, 0)
	}
}
stock fm_cs_set_user_model_index(id, value)
{
	if (!value) return;

	set_pdata_int(id, OFFSET_MODELINDEX, value, OFFSET_LINUX)
	set_pev(id, pev_modelindex, value);
}
public plugin_natives()
{
	register_native("bte_get_user_sex","native_get_sex",1)
	register_native("bte_set_user_sex","native_set_sex",1)
	register_native("bte_get_user_showdamage","native_get_showdamage",1)
	register_native("bte_set_user_showdamage","native_set_showdamage",1)
	
	register_native("bte_set_user_model","native_set_user_model",1)
	register_native("bte_set_user_model_index","natives_set_user_model_index",1)

	register_native("bte_reset_user_model","natives_reset_user_model",1)
	register_native("bte_reset_user_model_index","natives_reset_user_model_index",1)

	register_native("bte_set_block_emitsound", "natives_set_block_emitsound", 1);
}
public natives_set_block_emitsound(block)
{
	g_bBlockEmitSound = block;
}

public natives_reset_user_model(id)
{
	reset_user_model(id)
	return 1;
}
public natives_set_user_model_index(id, modelindex)
{
	fm_cs_set_user_model_index(id, modelindex)
	return 1;
}
public natives_reset_user_model_index(id)
{
	fm_cs_set_user_model_index(id, g_modelindex_default)
	return 1;
}
public native_set_user_model(id,mdl[])
{
	param_convert(2)
	g_bHasCustomModel[id] = 1;
	copy(g_szCustomModel[id], 32, mdl)
	fm_set_user_model(id,mdl)
}
public native_get_sex(id)
{
	return g_sex[id]
}
public native_set_sex(id, sex)
{
	g_sex[id] = sex
}
public native_get_showdamage(id)
{
	return g_showdamage[id]
}
public native_set_showdamage(id, x)
{
	g_showdamage[id] = x
}

// NO MORE EGG USE
/*
public makeui()
{
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, PLAYER_URL)

	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
		set_fail_state(error)
		return;
	}
	new linedata[1024], key[64], value[960], key2[64], value2[960]

	// Open customization file for reading
	new file = fopen(path, "rt")
	new idplayer
	while (file && !feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, charsmax(linedata))

		// Replace newlines with a null character to prevent headaches
		replace(linedata, charsmax(linedata), "^n", "")

		// Blank line or comment
		if (!linedata[0] || linedata[0] == ';') continue;

		strtok(linedata, key2, charsmax(key2), value2, charsmax(value2), '=')
		trim(key2)
		trim(value2)

		// Replace
		replace(linedata, charsmax(linedata), ",", "")
		replace(linedata, charsmax(linedata), "[name]", ",")
		replace(linedata, charsmax(linedata), "[model]", ",")
		replace(linedata, charsmax(linedata), "[team]", ",")
		replace(linedata, charsmax(linedata), "[sex]", ",")
		replace(linedata, charsmax(linedata), "[hand]", ",")
		replace(linedata, charsmax(linedata), "[radio]", ",")
		replace(linedata, charsmax(linedata), "[tattoo]", ",")

		// Get value
		strtok(linedata, key, charsmax(key), value, charsmax(value), ',')
		new i
		new name[32],team,namechn[32]

		while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
		{
			switch (i)
			{
				case 0:
				{
					format(namechn, 31, "%s", key)
				}
				case 1:
				{
					format(name, 31, "%s", key)
				}
				case 2:
				{
					team = str_to_num(key)
				}
			}
			i++
		}
		//store
		if(team == _:TEAM_CT)
		{
			copy(g_cache_player_ct_name[g_count_ct],31,name)
			copy(g_cache_player_ct_name_chn[g_count_ct],31,namechn)
			g_count_ct ++
		}
		else if(team == _:TEAM_T)
		{
			copy(g_cache_player_t_name[g_count_t],31,name)
			copy(g_cache_player_t_name_chn[g_count_t],31,namechn)
			g_count_t ++
		}
	}
	fclose(file)
//####################### WRITE CT TEAM RES FILE ################################
	delete_file("Resource/UI/ClassMenu_CT.res")
	new g_file_ct = fopen("Resource/UI/ClassMenu_CT.res", "a")

	//HEAD
	fprintf(g_file_ct, "^"Resource/UI/ClassMenu_CT.res^"^n{^n	^"ClassMenu^"^n	{^n");
	//TITLE BASE
	fprintf(g_file_ct, RES_C,"Frame")
	fprintf(g_file_ct, RES_F,"ClassMenu")
	fprintf(g_file_ct, RES_X,0)
	fprintf(g_file_ct, RES_Y,0)
	fprintf(g_file_ct, RES_W,640)
	fprintf(g_file_ct, RES_T,448)
	fprintf(g_file_ct, RES_A,0)
	fprintf(g_file_ct, RES_P,0)
	fprintf(g_file_ct, RES_V,1)
	fprintf(g_file_ct, RES_E,1)
	fprintf(g_file_ct, RES_TAB,0)
	fprintf(g_file_ct, "	}^n")

	fprintf(g_file_ct, "	^"SysMenu^"^n	{^n")
	fprintf(g_file_ct, RES_C,"Menu")
	fprintf(g_file_ct, RES_F,"SysMenu")
	fprintf(g_file_ct, RES_X,0)
	fprintf(g_file_ct, RES_Y,0)
	fprintf(g_file_ct, RES_W,64)
	fprintf(g_file_ct, RES_T,24)
	fprintf(g_file_ct, RES_A,0)
	fprintf(g_file_ct, RES_P,0)
	fprintf(g_file_ct, RES_V,0)
	fprintf(g_file_ct, RES_E,0)
	fprintf(g_file_ct, RES_TAB,0)
	fprintf(g_file_ct, "	}^n")

	fprintf(g_file_ct, "	^"joinClass^"^n	{^n")
	fprintf(g_file_ct, RES_C,"Label")
	fprintf(g_file_ct, RES_F,"joinClass")
	fprintf(g_file_ct, RES_X,76)
	fprintf(g_file_ct, RES_Y,22)
	fprintf(g_file_ct, RES_W,500)
	fprintf(g_file_ct, RES_T,48)
	fprintf(g_file_ct, RES_A,0)
	fprintf(g_file_ct, RES_P,0)
	fprintf(g_file_ct, RES_V,1)
	fprintf(g_file_ct, RES_E,1)
	fprintf(g_file_ct, RES_LABEL,"#Cstrike_Join_Class")
	fprintf(g_file_ct, RES_TA,"west")
	fprintf(g_file_ct, RES_DT,0)
	fprintf(g_file_ct, RES_BT,0)
	fprintf(g_file_ct, RES_FONT,"Title")
	fprintf(g_file_ct, RES_WP,0)
	fprintf(g_file_ct, "	}^n")

	fprintf(g_file_ct, "	^"ClassInfo-bg^"^n	{^n")
	fprintf(g_file_ct, RES_C,"ImagePanel")
	fprintf(g_file_ct, RES_F,"ClassInfo-bg")
	fprintf(g_file_ct, RES_X,325)
	fprintf(g_file_ct, RES_Y,100)
	fprintf(g_file_ct, RES_W,276)
	fprintf(g_file_ct, RES_T,300)
	fprintf(g_file_ct, RES_A,0)
	fprintf(g_file_ct, RES_P,0)
	fprintf(g_file_ct, RES_V,1)
	fprintf(g_file_ct, RES_E,1)
	fprintf(g_file_ct, RES_TA,"center")
	fprintf(g_file_ct, RES_I,"resource/control/info_classmenu")
	fprintf(g_file_ct, RES_SI,1)
	fprintf(g_file_ct, "	}^n")

	fprintf(g_file_ct, "	^"classInfoLabel^"^n	{^n")
	fprintf(g_file_ct, RES_C,"Label")
	fprintf(g_file_ct, RES_F,"classInfoLabel")
	fprintf(g_file_ct, RES_X,168)
	fprintf(g_file_ct, RES_Y,72)
	fprintf(g_file_ct, RES_W,276)
	fprintf(g_file_ct, RES_T,24)
	fprintf(g_file_ct, RES_A,0)
	fprintf(g_file_ct, RES_P,0)
	fprintf(g_file_ct, RES_V,0)
	fprintf(g_file_ct, RES_E,1)
	fprintf(g_file_ct, RES_LABEL,"#csonst_Class_Info")
	fprintf(g_file_ct, RES_TA,"west")
	fprintf(g_file_ct, RES_DT,0)
	fprintf(g_file_ct, RES_BT,1)
	fprintf(g_file_ct, "	}^n")

	fprintf(g_file_ct, "	^"ClassInfo^"^n	{^n")
	fprintf(g_file_ct, RES_C,"Panel")
	fprintf(g_file_ct, RES_F,"ClassInfo")
	fprintf(g_file_ct, RES_X,335)
	fprintf(g_file_ct, RES_Y,110)
	fprintf(g_file_ct, RES_W,256)
	fprintf(g_file_ct, RES_T,380)
	fprintf(g_file_ct, RES_A,3)
	fprintf(g_file_ct, RES_P,0)
	fprintf(g_file_ct, RES_V,1)
	fprintf(g_file_ct, RES_E,1)
	fprintf(g_file_ct, RES_TAB,0)
	fprintf(g_file_ct, "	}^n")

	fprintf(g_file_ct, "//######################## BTE PLAYER INFO START ##########################^n")

	//WRITE PLAYER RES
	new xpos = 25 //+145
	new ypos = 100 //+28
	new buffer[256]

	for(new i=0 ; i<g_count_ct;i++)
	{
		new iMod = i%2

		format(buffer,255,"	^"bte-button-%d-bg^"^n	{^n",i+1)
		fprintf(g_file_ct, buffer)
		fprintf(g_file_ct, RES_C,"ImagePanel")
		format(buffer,255,"bte-button-%d-bg",i+1)
		fprintf(g_file_ct, RES_F,buffer)

		if(iMod)
		{
			xpos += 145
		}
		else if(i>0)
		{
			ypos += 28
			xpos -= 145
		}
		fprintf(g_file_ct, RES_X,xpos)
		fprintf(g_file_ct, RES_Y,ypos)
		fprintf(g_file_ct, RES_W,140)
		fprintf(g_file_ct, RES_T,26)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		fprintf(g_file_ct, RES_TA,"center")
		fprintf(g_file_ct, RES_I,"resource/control/blankslot_classmenu")
		fprintf(g_file_ct, RES_SI,1)
		fprintf(g_file_ct, "	}^n")

		format(buffer,255,"	^"bte-button-%d-key^"^n	{^n",i+1)
		fprintf(g_file_ct, buffer)
		fprintf(g_file_ct, RES_C,"ImagePanel")
		format(buffer,255,"bte-button-%d-key",i+1)
		fprintf(g_file_ct, RES_F,buffer)
		fprintf(g_file_ct, RES_X,xpos+3)
		fprintf(g_file_ct, RES_Y,ypos+3)
		fprintf(g_file_ct, RES_W,20)
		fprintf(g_file_ct, RES_T,20)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		fprintf(g_file_ct, RES_TA,"center")
		fprintf(g_file_ct, RES_I,"resource/control/keyboard")
		fprintf(g_file_ct, RES_SI,1)
		fprintf(g_file_ct, "	}^n")

		fprintf(g_file_ct, "	^"%s^"^n	{^n",g_cache_player_ct_name[i])
		fprintf(g_file_ct, RES_C,"MouseOverPanelButton")
		format(buffer,255,"%s",g_cache_player_ct_name[i])
		fprintf(g_file_ct, RES_F,buffer)
		fprintf(g_file_ct, RES_X,xpos)
		fprintf(g_file_ct, RES_Y,ypos)
		fprintf(g_file_ct, RES_W,140)
		fprintf(g_file_ct, RES_T,26)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,2)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		fprintf(g_file_ct, RES_TAB,0)
		format(buffer,255,"  &%d    %s",i+1,g_cache_player_ct_name_chn[i])
		fprintf(g_file_ct, RES_LABEL,buffer)
		fprintf(g_file_ct, RES_TA,"west")
		fprintf(g_file_ct, RES_DT,0)
		fprintf(g_file_ct, RES_BT,0)
		format(buffer,255,"joinclass 1;bte_choose_player %s",g_cache_player_ct_name[i])
		fprintf(g_file_ct, RES_CMD,buffer)
		fprintf(g_file_ct, "	}^n")
	}
	fprintf(g_file_ct, "}^n")
	fprintf(g_file_ct, "// ############### Generated By BTE UI Plugin ################### ^n")

	fclose(g_file_ct)

	// TEAM T
	delete_file("Resource/UI/ClassMenu_TER.res")
	g_file_ct = fopen("Resource/UI/ClassMenu_TER.res", "a")

	//HEAD
	fprintf(g_file_ct, "^"Resource/UI/ClassMenu_TER.res^"^n{^n	^"ClassMenu^"^n	{^n");
	//TITLE BASE
	fprintf(g_file_ct, RES_C,"Frame")
	fprintf(g_file_ct, RES_F,"ClassMenu")
	fprintf(g_file_ct, RES_X,0)
	fprintf(g_file_ct, RES_Y,0)
	fprintf(g_file_ct, RES_W,640)
	fprintf(g_file_ct, RES_T,448)
	fprintf(g_file_ct, RES_A,0)
	fprintf(g_file_ct, RES_P,0)
	fprintf(g_file_ct, RES_V,1)
	fprintf(g_file_ct, RES_E,1)
	fprintf(g_file_ct, RES_TAB,0)
	fprintf(g_file_ct, "	}^n")

	fprintf(g_file_ct, "	^"SysMenu^"^n	{^n")
	fprintf(g_file_ct, RES_C,"Menu")
	fprintf(g_file_ct, RES_F,"SysMenu")
	fprintf(g_file_ct, RES_X,0)
	fprintf(g_file_ct, RES_Y,0)
	fprintf(g_file_ct, RES_W,64)
	fprintf(g_file_ct, RES_T,24)
	fprintf(g_file_ct, RES_A,0)
	fprintf(g_file_ct, RES_P,0)
	fprintf(g_file_ct, RES_V,0)
	fprintf(g_file_ct, RES_E,0)
	fprintf(g_file_ct, RES_TAB,0)
	fprintf(g_file_ct, "	}^n")

	fprintf(g_file_ct, "	^"joinClass^"^n	{^n")
	fprintf(g_file_ct, RES_C,"Label")
	fprintf(g_file_ct, RES_F,"joinClass")
	fprintf(g_file_ct, RES_X,76)
	fprintf(g_file_ct, RES_Y,22)
	fprintf(g_file_ct, RES_W,500)
	fprintf(g_file_ct, RES_T,48)
	fprintf(g_file_ct, RES_A,0)
	fprintf(g_file_ct, RES_P,0)
	fprintf(g_file_ct, RES_V,1)
	fprintf(g_file_ct, RES_E,1)
	fprintf(g_file_ct, RES_LABEL,"#Cstrike_Join_Class")
	fprintf(g_file_ct, RES_TA,"west")
	fprintf(g_file_ct, RES_DT,0)
	fprintf(g_file_ct, RES_BT,0)
	fprintf(g_file_ct, RES_FONT,"Title")
	fprintf(g_file_ct, RES_WP,0)
	fprintf(g_file_ct, "	}^n")

	fprintf(g_file_ct, "	^"ClassInfo-bg^"^n	{^n")
	fprintf(g_file_ct, RES_C,"ImagePanel")
	fprintf(g_file_ct, RES_F,"ClassInfo-bg")
	fprintf(g_file_ct, RES_X,325)
	fprintf(g_file_ct, RES_Y,100)
	fprintf(g_file_ct, RES_W,276)
	fprintf(g_file_ct, RES_T,300)
	fprintf(g_file_ct, RES_A,0)
	fprintf(g_file_ct, RES_P,0)
	fprintf(g_file_ct, RES_V,1)
	fprintf(g_file_ct, RES_E,1)
	fprintf(g_file_ct, RES_TA,"center")
	fprintf(g_file_ct, RES_I,"resource/control/info_classmenu")
	fprintf(g_file_ct, RES_SI,1)
	fprintf(g_file_ct, "	}^n")

	fprintf(g_file_ct, "	^"classInfoLabel^"^n	{^n")
	fprintf(g_file_ct, RES_C,"Label")
	fprintf(g_file_ct, RES_F,"classInfoLabel")
	fprintf(g_file_ct, RES_X,168)
	fprintf(g_file_ct, RES_Y,72)
	fprintf(g_file_ct, RES_W,276)
	fprintf(g_file_ct, RES_T,24)
	fprintf(g_file_ct, RES_A,0)
	fprintf(g_file_ct, RES_P,0)
	fprintf(g_file_ct, RES_V,0)
	fprintf(g_file_ct, RES_E,1)
	fprintf(g_file_ct, RES_LABEL,"#csonst_Class_Info")
	fprintf(g_file_ct, RES_TA,"west")
	fprintf(g_file_ct, RES_DT,0)
	fprintf(g_file_ct, RES_BT,1)
	fprintf(g_file_ct, "	}^n")

	fprintf(g_file_ct, "	^"ClassInfo^"^n	{^n")
	fprintf(g_file_ct, RES_C,"Panel")
	fprintf(g_file_ct, RES_F,"ClassInfo")
	fprintf(g_file_ct, RES_X,335)
	fprintf(g_file_ct, RES_Y,110)
	fprintf(g_file_ct, RES_W,256)
	fprintf(g_file_ct, RES_T,380)
	fprintf(g_file_ct, RES_A,3)
	fprintf(g_file_ct, RES_P,0)
	fprintf(g_file_ct, RES_V,1)
	fprintf(g_file_ct, RES_E,1)
	fprintf(g_file_ct, RES_TAB,0)
	fprintf(g_file_ct, "	}^n")

	fprintf(g_file_ct, "//######################## BTE PLAYER INFO START ##########################^n")

	//WRITE PLAYER RES
	xpos = 25 //+145
	ypos = 100 //+28

	for(new i=0 ; i<g_count_t;i++)
	{
		new iMod = i%2

		format(buffer,255,"	^"bte-button-%d-bg^"^n	{^n",i+1)
		fprintf(g_file_ct, buffer)
		fprintf(g_file_ct, RES_C,"ImagePanel")
		format(buffer,255,"bte-button-%d-bg",i+1)
		fprintf(g_file_ct, RES_F,buffer)

		if(iMod)
		{
			xpos += 145
		}
		else if(i>0)
		{
			ypos += 28
			xpos -= 145
		}
		fprintf(g_file_ct, RES_X,xpos)
		fprintf(g_file_ct, RES_Y,ypos)
		fprintf(g_file_ct, RES_W,140)
		fprintf(g_file_ct, RES_T,26)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		fprintf(g_file_ct, RES_TA,"center")
		fprintf(g_file_ct, RES_I,"resource/control/blankslot_classmenu")
		fprintf(g_file_ct, RES_SI,1)
		fprintf(g_file_ct, "	}^n")

		format(buffer,255,"	^"bte-button-%d-key^"^n	{^n",i+1)
		fprintf(g_file_ct, buffer)
		fprintf(g_file_ct, RES_C,"ImagePanel")
		format(buffer,255,"bte-button-%d-key",i+1)
		fprintf(g_file_ct, RES_F,buffer)
		fprintf(g_file_ct, RES_X,xpos+3)
		fprintf(g_file_ct, RES_Y,ypos+3)
		fprintf(g_file_ct, RES_W,20)
		fprintf(g_file_ct, RES_T,20)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		fprintf(g_file_ct, RES_TA,"center")
		fprintf(g_file_ct, RES_I,"resource/control/keyboard")
		fprintf(g_file_ct, RES_SI,1)
		fprintf(g_file_ct, "	}^n")

		fprintf(g_file_ct, "	^"%s^"^n	{^n",g_cache_player_t_name[i])
		fprintf(g_file_ct, RES_C,"MouseOverPanelButton")

		new sTemp[64]
		if(equal(g_cache_player_t_name[i],"militia"))
		{
			format(sTemp,63,"%s","militiareplace")
		}
		else format(sTemp,63,"%s",g_cache_player_t_name[i])

		format(buffer,255,"%s",sTemp)
		fprintf(g_file_ct, RES_F,buffer)
		fprintf(g_file_ct, RES_X,xpos)
		fprintf(g_file_ct, RES_Y,ypos)
		fprintf(g_file_ct, RES_W,140)
		fprintf(g_file_ct, RES_T,26)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,2)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		fprintf(g_file_ct, RES_TAB,0)
		format(buffer,255,"  &%d    %s",i+1,g_cache_player_t_name_chn[i])
		fprintf(g_file_ct, RES_LABEL,buffer)
		fprintf(g_file_ct, RES_TA,"west")
		fprintf(g_file_ct, RES_DT,0)
		fprintf(g_file_ct, RES_BT,0)
		format(buffer,255,"joinclass 1;bte_choose_player %s",g_cache_player_t_name[i])
		fprintf(g_file_ct, RES_CMD,buffer)
		fprintf(g_file_ct, "	}^n")
	}
	fprintf(g_file_ct, "}^n")
	fprintf(g_file_ct, "// ############### Generated By BTE UI Plugin ################### ^n")

	fclose(g_file_ct)

	// Gernerate Class Menu Res
	// CT TEAM
	for(new i=0 ; i<g_count_ct;i++)
	{
		new szName[32]
		format(szName,31,"classes/%s.res",g_cache_player_ct_name[i])
		delete_file(szName)
		g_file_ct = fopen(szName, "a")

		format(buffer,255,"^"classes/%s.res^"^n{^n",g_cache_player_ct_name[i])
		fprintf(g_file_ct, buffer);
		fprintf(g_file_ct," 	^"imageBG^"^n	{^n");

		fprintf(g_file_ct, RES_C,"ImagePanel")
		fprintf(g_file_ct, RES_F,"imageBG")
		fprintf(g_file_ct, RES_X,0)
		fprintf(g_file_ct, RES_Y,0)
		fprintf(g_file_ct, RES_W,300)
		fprintf(g_file_ct, RES_T,196)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		fprintf(g_file_ct, RES_TA,"center")
		fprintf(g_file_ct, RES_FR,"WindowBG")
		fprintf(g_file_ct, RES_Z,0)
		fprintf(g_file_ct, "	}^n")

		fprintf(g_file_ct, "	^"classimage^"^n	{^n")
		fprintf(g_file_ct, RES_C,"ImagePanel")
		fprintf(g_file_ct, RES_F,"classimage")
		fprintf(g_file_ct, RES_X,0)
		fprintf(g_file_ct, RES_Y,0)
		fprintf(g_file_ct, RES_W,256)
		fprintf(g_file_ct, RES_T,196)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		fprintf(g_file_ct, RES_TA,"west")
		format(buffer,255,"gfx/vgui/%s",g_cache_player_ct_name[i])
		fprintf(g_file_ct, RES_I,buffer)
		fprintf(g_file_ct, RES_SI,1)
		fprintf(g_file_ct, RES_Z,1)
		fprintf(g_file_ct, "	}^n")

		fprintf(g_file_ct, "	^"imageBorder^"^n	{^n")
		fprintf(g_file_ct, RES_C,"Divider")
		fprintf(g_file_ct, RES_F,"imageBorder")
		fprintf(g_file_ct, RES_X,0)
		fprintf(g_file_ct, RES_Y,0)
		fprintf(g_file_ct, RES_W,300)
		fprintf(g_file_ct, RES_T,196)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		fprintf(g_file_ct, RES_TAB,0)
		fprintf(g_file_ct, RES_Z,2)
		fprintf(g_file_ct, "	}^n")

		fprintf(g_file_ct, "	^"className^"^n	{^n")
		fprintf(g_file_ct, RES_C,"Label")
		fprintf(g_file_ct, RES_F,"infolabel")
		fprintf(g_file_ct, RES_X,0)
		fprintf(g_file_ct, RES_Y,204)
		fprintf(g_file_ct, RES_W,300)
		fprintf(g_file_ct, RES_T,20)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		format(buffer,255, "#CstrikeBTE_%s_Name",g_cache_player_ct_name[i])
		fprintf(g_file_ct, RES_LABEL,buffer)
		fprintf(g_file_ct, RES_TA,"west")
		fprintf(g_file_ct, RES_DT,1)
		fprintf(g_file_ct, RES_BT,0)
		fprintf(g_file_ct, "	}^n")

		fprintf(g_file_ct, "	^"infolabel^"^n	{^n")
		fprintf(g_file_ct, RES_C,"Label")
		fprintf(g_file_ct, RES_F,"infolabel")
		fprintf(g_file_ct, RES_X,0)
		fprintf(g_file_ct, RES_Y,228)
		fprintf(g_file_ct, RES_W,300)
		fprintf(g_file_ct, RES_T,80)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		format(buffer,255, "#CstrikeBTE_%s_Label",g_cache_player_ct_name[i])
		fprintf(g_file_ct, RES_LABEL,buffer)
		fprintf(g_file_ct, RES_TA,"north-west")
		fprintf(g_file_ct, RES_DT,1)
		fprintf(g_file_ct, RES_BT,0)
		fprintf(g_file_ct, RES_FONT,"DefaultSmall")
		fprintf(g_file_ct, "	}^n")

		fprintf(g_file_ct, "}^n")
		fprintf(g_file_ct, "// ############### Generated By BTE UI Plugin ################### ^n")

		fclose(g_file_ct)
	}
	new sTemp[64]

	// T TEAM
	for(new i=0 ; i<g_count_t;i++)
	{
		if(equal(g_cache_player_t_name[i],"militia"))
		{
			format(sTemp,63,"%s","militiareplace")
		}
		else format(sTemp,63,"%s",g_cache_player_t_name[i])

		new szName[32]
		format(szName,31,"classes/%s.res",sTemp)
		delete_file(szName)
		g_file_ct = fopen(szName, "a")

		format(buffer,255,"^"classes/%s.res^"^n{^n",sTemp)
		fprintf(g_file_ct, buffer);
		fprintf(g_file_ct," 	^"imageBG^"^n	{^n");

		fprintf(g_file_ct, RES_C,"ImagePanel")
		fprintf(g_file_ct, RES_F,"imageBG")
		fprintf(g_file_ct, RES_X,0)
		fprintf(g_file_ct, RES_Y,0)
		fprintf(g_file_ct, RES_W,300)
		fprintf(g_file_ct, RES_T,196)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		fprintf(g_file_ct, RES_TA,"center")
		fprintf(g_file_ct, RES_FR,"WindowBG")
		fprintf(g_file_ct, RES_Z,0)
		fprintf(g_file_ct, "	}^n")

		fprintf(g_file_ct, "	^"classimage^"^n	{^n")
		fprintf(g_file_ct, RES_C,"ImagePanel")
		fprintf(g_file_ct, RES_F,"classimage")
		fprintf(g_file_ct, RES_X,0)
		fprintf(g_file_ct, RES_Y,0)
		fprintf(g_file_ct, RES_W,256)
		fprintf(g_file_ct, RES_T,196)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		fprintf(g_file_ct, RES_TA,"west")
		format(buffer,255,"gfx/vgui/%s",g_cache_player_t_name[i])
		fprintf(g_file_ct, RES_I,buffer)
		fprintf(g_file_ct, RES_SI,1)
		fprintf(g_file_ct, RES_Z,1)
		fprintf(g_file_ct, "	}^n")

		fprintf(g_file_ct, "	^"imageBorder^"^n	{^n")
		fprintf(g_file_ct, RES_C,"Divider")
		fprintf(g_file_ct, RES_F,"imageBorder")
		fprintf(g_file_ct, RES_X,0)
		fprintf(g_file_ct, RES_Y,0)
		fprintf(g_file_ct, RES_W,300)
		fprintf(g_file_ct, RES_T,196)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		fprintf(g_file_ct, RES_TAB,0)
		fprintf(g_file_ct, RES_Z,2)
		fprintf(g_file_ct, "	}^n")

		fprintf(g_file_ct, "	^"className^"^n	{^n")
		fprintf(g_file_ct, RES_C,"Label")
		fprintf(g_file_ct, RES_F,"infolabel")
		fprintf(g_file_ct, RES_X,0)
		fprintf(g_file_ct, RES_Y,204)
		fprintf(g_file_ct, RES_W,300)
		fprintf(g_file_ct, RES_T,20)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		format(buffer,255, "#CstrikeBTE_%s_Name",g_cache_player_t_name[i])
		fprintf(g_file_ct, RES_LABEL,buffer)
		fprintf(g_file_ct, RES_TA,"west")
		fprintf(g_file_ct, RES_DT,1)
		fprintf(g_file_ct, RES_BT,0)
		fprintf(g_file_ct, "	}^n")

		fprintf(g_file_ct, "	^"infolabel^"^n	{^n")
		fprintf(g_file_ct, RES_C,"Label")
		fprintf(g_file_ct, RES_F,"infolabel")
		fprintf(g_file_ct, RES_X,0)
		fprintf(g_file_ct, RES_Y,228)
		fprintf(g_file_ct, RES_W,300)
		fprintf(g_file_ct, RES_T,80)
		fprintf(g_file_ct, RES_A,0)
		fprintf(g_file_ct, RES_P,0)
		fprintf(g_file_ct, RES_V,1)
		fprintf(g_file_ct, RES_E,1)
		format(buffer,255, "#CstrikeBTE_%s_Label",g_cache_player_t_name[i])
		fprintf(g_file_ct, RES_LABEL,buffer)
		fprintf(g_file_ct, RES_TA,"north-west")
		fprintf(g_file_ct, RES_DT,1)
		fprintf(g_file_ct, RES_BT,0)
		fprintf(g_file_ct, RES_FONT,"DefaultSmall")
		fprintf(g_file_ct, "	}^n")

		fprintf(g_file_ct, "}^n")
		fprintf(g_file_ct, "// ############### Generated By BTE UI Plugin ################### ^n")

		fclose(g_file_ct)
	}
}*/