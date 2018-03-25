#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <round_terminator>
#include <xs>
#include "bte_api.inc"
#include "bte.inc"
#include "offset.inc"
#include "cdll_dll.h"
#include "inc.inc"

#define PLUGIN "BTE ZSE Escape"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define RESCUE_MAX 5

new szModel[RESCUE_MAX][64];
new Float:vecMins[RESCUE_MAX][3], Float:vecMaxs[RESCUE_MAX][3];
new Float:vecOrigin[RESCUE_MAX][4][3], Float:vecAngle[RESCUE_MAX][3];
new Float:vecCamOrigin[RESCUE_MAX][3], Float:vecCamAngle[RESCUE_MAX][3]/*, Float:vecCamVAngle[RESCUE_MAX][3]*/;
new Float:vecExpOrigin[RESCUE_MAX][3], iExpScale[RESCUE_MAX];
new Float:flRescue[RESCUE_MAX], Float:flDefence[RESCUE_MAX];
new Float:flSpeed[RESCUE_MAX][3];
new bNoMove[RESCUE_MAX];

new g_fw_ZombieEmitSound, g_fw_DummyResult;

new g_bRescued[33];
new g_iMaxRescure, g_iCurRescure;
new g_bBlock;

new gmsgDeathMsg, gmsgScoreInfo;

new Float:g_flMakeZombie = 99999.0;

#define CUR g_iCurRescure

native bte_set_block_emitsound(b)

//#define _TEST

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");
	register_logevent("LogEvent_RoundStart", 2, "1=Round_Start");

#if defined _TEST
	register_clcmd("escape_test", "test")
	register_clcmd("exp_test", "test2")
#endif

	RegisterHam(Ham_Touch, "info_target", "Touch");
	RegisterHam(Ham_Think, "info_target", "Think");

	gmsgDeathMsg = get_user_msgid("DeathMsg");
	gmsgScoreInfo = get_user_msgid("ScoreInfo");

	register_message(gmsgDeathMsg, "message_msgDeathMsg");

	register_forward(FM_EmitSound, "Forward_EmitSound");

	g_fw_ZombieEmitSound = CreateMultiForward("bte_zb_EmitSound", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_FLOAT, FP_CELL, FP_CELL);
}

#if defined _TEST
public test()
{
	g_iCurRescure = random_num(0, g_iMaxRescure - 1);
	client_print(0, print_chat, "你将使用%d个逃生点中的第%d个。", g_iMaxRescure, g_iCurRescure + 1);

	fm_remove_entity_name("human_escape")
	fm_remove_entity_name("human_camera")
	LoadCfg();
	Spawn();
}

public test2()
{
	g_iCurRescure = random_num(0, g_iMaxRescure - 1);
	client_print(0, print_chat, "你将使用%d个逃生点中的第%d个。", g_iMaxRescure, g_iCurRescure + 1);

	fm_remove_entity_name("human_escape");
	fm_remove_entity_name("human_camera");
	LoadCfg();
	Explosion();
}
#endif

new g_sModelIndexFireball, g_sModelIndexFireball2, g_sModelIndexFireball3;

public plugin_precache()
{
	LoadCfg();

	for (new i = 0; i < g_iMaxRescure; i++)
		precache_model(szModel[i]);

	g_sModelIndexFireball = precache_model("sprites/zerogxplode.spr");
	g_sModelIndexFireball2 = precache_model("sprites/eexplo.spr");
	g_sModelIndexFireball3 = precache_model("sprites/fexplo.spr");

	//precache_sound("zombi/td_nuc_exp.wav");
	//precache_sound("zombi/td_nuc_launch.wav");
}

public client_disconnect(id)
{
	new iPlayerCt = CountPlayer(TEAM_CT);
	new iPlayerT = CountPlayer(TEAM_TERRORIST);

	if (iPlayerCt == 0 && iPlayerT >= 1)
		ZombieWin();

	if (get_gametime() > g_flMakeZombie)
	{
		if (iPlayerT == 0 && iPlayerCt >= 1)
			HumanWin();
	}
}

public message_msgDeathMsg()
{
	if (g_bBlock)
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public Forward_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if (g_bBlock)
		return FMRES_SUPERCEDE;

	if (!is_user_connected(id))
		return FMRES_IGNORED;

	if (!bte_get_user_zombie(id))
		return FMRES_IGNORED;

	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't' || sample[7] == 'h' && sample[8] == 'e' && sample[9] == 'a' && sample[10] == 'd')
	{
		ExecuteForward(g_fw_ZombieEmitSound, g_fw_DummyResult, id, EMITSOUND_HURT, channel, volume, attn, flags, pitch);
		return FMRES_SUPERCEDE;
	}

	if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
		ExecuteForward(g_fw_ZombieEmitSound, g_fw_DummyResult, id, EMITSOUND_DEAD, channel, volume, attn, flags, pitch);
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public LogEvent_RoundStart()
{
	new Float:round_time;
	round_time = get_cvar_float("mp_roundtime") * 60.0;
	g_flMakeZombie = get_gametime() + 20.0;

	g_iCurRescure = random_num(0, g_iMaxRescure - 1);

	set_task(round_time - flRescue[CUR], "Spawn", TASK_ESCAPE);
	set_task(round_time, "Task_ZombieWin", TASK_HUMANWIN); // roundend zombie win
}

public Event_HLTV()
{
	new null[33]
	g_bRescued = null;
	g_bBlock = FALSE;
	bte_set_block_emitsound(FALSE);

	client_cmd(0, "mp3 stop");

	if (task_exists(TASK_ESCAPE)) remove_task(TASK_ESCAPE);
	if (task_exists(TASK_HUMANWIN)) remove_task(TASK_HUMANWIN);

	fm_remove_entity_name("human_escape")
	fm_remove_entity_name("human_camera")

	if (g_iMaxRescure == 0)
		client_print(0, print_chat, "NO config file for this map. CAN NOT spawn rescue point.");
}

public Think(pEntity)
{
	new classname[32];
	pev(pEntity, pev_classname, classname, charsmax(classname));
	if(!equal(classname, "human_escape")) return;

	switch (pev(pEntity, pev_iuser1))
	{
		case 0 : // now at TargetOrigin
		{
			set_pev(pEntity, pev_iuser1, 1);

			if (xs_vec_equal(vecOrigin[CUR][1], vecOrigin[CUR][2]))
			{
				set_pev(pEntity, pev_nextthink, get_gametime() + 0.01);
				return;
			}

			new Float:vecVelocity[3];
			new Float:time = GetSpeedVector(vecOrigin[CUR][1], vecOrigin[CUR][2], flSpeed[CUR][1], vecVelocity);
			set_pev(pEntity, pev_velocity, vecVelocity); // move to TargetOrigin2

			vector_to_angle(vecVelocity, vecAngle[CUR])
			if(vecAngle[CUR][0] > 90.0) vecAngle[CUR][0] = -(360.0 - vecAngle[CUR][0]);
			set_pev(pEntity, pev_angles, vecAngle[CUR]);

			set_pev(pEntity, pev_nextthink, get_gametime() + time); // wait for player
		}
		case 1 : // now at TargetOrigin2
		{
			set_pev(pEntity, pev_movetype, MOVETYPE_NONE);
			engfunc(EngFunc_SetSize, pEntity, vecMins[CUR], vecMaxs[CUR]);
			set_pev(pEntity, pev_velocity, {0.0, 0.0, 0.0});
			//set_pev(pEntity, pev_iuser1, 2);
			set_pev(pEntity, pev_nextthink, get_gametime() + 999.0); // wait for player

			//client_print(0, print_chat, "救援已到达，幸存者请迅速到达救援点。");
			UTIL_TutorText(0, "#CSBTE_Totur_ZSE_EscapeStarted", 1 << 0, 5.0);
		}
		case 2 : // now player arrived
		{
			set_pev(pEntity, pev_iuser1, 3);
			set_pev(pEntity, pev_nextthink, get_gametime() + flDefence[CUR]); // stay 10s

			//client_print(0, print_chat, "救援已开始，守在救援点附近%d秒可获救。", floatround(flDefence[CUR]));
			UTIL_TutorText(0, "#CSBTE_Totur_ZSE_EscapeStarted", 1 << 0, 5.0);

			UTIL_RoundTime(floatround(flDefence[CUR])); // round time
		}
		case 3 : // escape
		{
			if (CountPlayer(TEAM_CT, 1) == 0) // check is not ZB win
			{
				set_pev(pEntity, pev_nextthink, get_gametime() + 999.0);

				return;
			}

			CheckRescue();
			SetViewAll();

			if (!bNoMove[CUR])
			{
				set_pev(pEntity, pev_movetype, MOVETYPE_NOCLIP);
				if (xs_vec_equal(vecOrigin[CUR][2], vecOrigin[CUR][3]))
				{
					set_pev(pEntity, pev_nextthink, get_gametime() + 999.0);
					return;
				}

				new Float:vecVelocity[3];
				GetSpeedVector(vecOrigin[CUR][2], vecOrigin[CUR][3], flSpeed[CUR][2], vecVelocity);
				set_pev(pEntity, pev_velocity, vecVelocity); // move to LeaveOrigin

				vector_to_angle(vecVelocity, vecAngle[CUR])
				if(vecAngle[CUR][0] > 90.0) vecAngle[CUR][0] = -(360.0 - vecAngle[CUR][0]);
				set_pev(pEntity, pev_angles, vecAngle[CUR]);
			}

			set_pev(pEntity, pev_iuser1, 4);
			set_pev(pEntity, pev_nextthink, get_gametime() + 3.0);

			client_cmd(0, "mp3 stop; mp3 play sound/zombi/zse/hmwin.mp3");
		}
		case 4 :
		{
			set_pev(pEntity, pev_iuser1, 5);
			set_pev(pEntity, pev_nextthink, get_gametime() + 3.0);

			KillAll();
			Explosion();
		}
		case 5: // HM WIN !
		{
			HumanWin();
		}
	}
}

public CheckRescue()
{
	for (new id = 1; id <= 32; id++)
	{
		if (!is_user_connected(id))
			continue;

		if (bte_get_user_zombie(id))
			continue;

		if (!is_user_alive(id))
			continue;

		new Float:vecPlayerOrigin[3];
		pev(id, pev_origin, vecPlayerOrigin);

		if (get_distance_f(vecPlayerOrigin, vecOrigin[CUR][2]) < 500.0)
			g_bRescued[id] = TRUE;
	}
}

#define GIB_NORMAL 0
#define GIB_NEVER 1
#define GIB_ALWAYS 2

public KillAll()
{
	// block DeathMsg / EmitSound
	g_bBlock = TRUE;
	bte_set_block_emitsound(TRUE);

	for (new id = 1; id <= 32; id++)
	{
		if (!is_user_connected(id))
			continue;

		if (!is_user_alive(id))
			continue;

		if (g_bRescued[id])
		{
			UpdateFrags(id, 3, TRUE);
			continue;
		}

		UpdateFrags(id, 1);
		ExecuteHam(Ham_Killed, id, id, GIB_NEVER);
	}
}

stock UpdateFrags(id, num, sendmsg = FALSE)
{
	new Float:frags;
	pev(id, pev_frags, frags);
	frags += float(num);
	set_pev(id, pev_frags, frags);

	if (!sendmsg)
		return;

	message_begin(MSG_BROADCAST, gmsgScoreInfo);
	write_byte(id);
	write_short(floatround(frags));
	write_short(get_pdata_int(id, m_iDeaths));
	write_short(0);
	write_short(get_pdata_int(id, m_iTeam));
	message_end();

}

public Explosion()
{
	client_cmd(0, "spk zombi/td_nuc_exp.wav");
	//client_print(0, print_chat, "已肃清该区域。");
	UTIL_TutorText(0, "#CSBTE_Totur_ZSE_Explosion", 1 << 1, 4.0);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecExpOrigin[CUR], 0);
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, vecExpOrigin[CUR][0])
	engfunc(EngFunc_WriteCoord, vecExpOrigin[CUR][1])
	engfunc(EngFunc_WriteCoord, vecExpOrigin[CUR][2] - 10.0)
	write_short(g_sModelIndexFireball3)
	write_byte(iExpScale[CUR])
	write_byte(150)
	message_end()

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecExpOrigin[CUR], 0);
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, vecExpOrigin[CUR][0] + random_float(-512.0, 512.0))
	engfunc(EngFunc_WriteCoord, vecExpOrigin[CUR][1] + random_float(-512.0, 512.0))
	engfunc(EngFunc_WriteCoord, vecExpOrigin[CUR][2] + random_float(-10.0, 10.0))
	write_short(g_sModelIndexFireball2)
	write_byte(iExpScale[CUR])
	write_byte(150)
	message_end()

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecExpOrigin[CUR], 0);
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, vecExpOrigin[CUR][0] + random_float(-512.0, 512.0))
	engfunc(EngFunc_WriteCoord, vecExpOrigin[CUR][1] + random_float(-512.0, 512.0))
	engfunc(EngFunc_WriteCoord, vecExpOrigin[CUR][2] + random_float(-10.0, 10.0))
	write_short(g_sModelIndexFireball3)
	write_byte(iExpScale[CUR])
	write_byte(150)
	message_end()

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecExpOrigin[CUR], 0);
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, vecExpOrigin[CUR][0] + random_float(-512.0, 512.0))
	engfunc(EngFunc_WriteCoord, vecExpOrigin[CUR][1] + random_float(-512.0, 512.0))
	engfunc(EngFunc_WriteCoord, vecExpOrigin[CUR][2] + random_float(-10.0, 10.0))
	write_short(g_sModelIndexFireball)
	write_byte(iExpScale[CUR])
	write_byte(17)
	message_end()
}

public Touch(pEntity, id)
{
	new classname[32];
	pev(pEntity, pev_classname, classname, charsmax(classname));
	if (!equal(classname, "human_escape")) return;

	if (id < 1 || id > 32) return;
	if (!is_user_alive(id)) return;
	if (bte_get_user_zombie(id)) return;

	if (task_exists(TASK_HUMANWIN)) remove_task(TASK_HUMANWIN);

	if (pev(pEntity, pev_iuser1) == 1)
	{
		set_pev(pEntity, pev_iuser1, 2)
		set_pev(pEntity, pev_nextthink, get_gametime() + 0.1);
	}
}

public Spawn()
{
	if (g_iMaxRescure == 0)
	{
		client_print(0, print_chat, "NO config file for this map. CAN NOT spawn rescue point.");
		return;
	}

	new pEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if (!pev_valid(pEntity)) return;

	set_pev(pEntity, pev_classname, "human_escape");
	set_pev(pEntity, pev_solid, SOLID_BBOX);
	set_pev(pEntity, pev_movetype, MOVETYPE_NOCLIP);
	set_pev(pEntity, pev_sequence, 0);
	set_pev(pEntity, pev_framerate, 1.0);

	engfunc(EngFunc_SetSize, pEntity, vecMins[CUR], vecMaxs[CUR]);
	engfunc(EngFunc_SetModel, pEntity, szModel[CUR]);
	set_pev(pEntity, pev_angles, vecAngle[CUR]);
	set_pev(pEntity, pev_origin, vecOrigin[CUR][0]);

	if (!bNoMove[CUR])
	{
		new Float:vecVelocity[3];
		new Float:time = GetSpeedVector(vecOrigin[CUR][0], vecOrigin[CUR][1], flSpeed[CUR][0], vecVelocity);
		set_pev(pEntity, pev_velocity, vecVelocity);

		set_pev(pEntity, pev_nextthink, get_gametime() + time);

		UTIL_TutorText(0, "#CSBTE_Totur_ZSE_EscapeStart", 1 << 0, 3.0);
		//client_print(0, print_chat, "救援即将到达。");
	}
	else
	{
		set_pev(pEntity, pev_iuser1, 1);
		set_pev(pEntity, pev_nextthink, get_gametime() + 0.1);
	}

	client_cmd(0, "mp3 stop; mp3 play sound/zombi/zse/rescue.mp3");
}

stock Float:GetSpeedVector(const Float:origin1[3], const Float:origin2[3], Float:speed, Float:new_velocity[3])
{
	xs_vec_sub(origin2, origin1, new_velocity)
	new Float:time = xs_vec_len(new_velocity) / speed;
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	xs_vec_mul_scalar(new_velocity, num, new_velocity)

	return time
}

stock CountPlayer(iTeam, bAlive = 0)
{
	new iPlayer;

	for (new id = 1; id <= 32; id++)
	{
		if (!is_user_connected(id))
			continue;

		if (!is_user_alive(id) && bAlive)
			continue;

		if (!iTeam)
			iPlayer ++;
		else if (get_pdata_int(id, m_iTeam) == iTeam)
			iPlayer ++;
	}

	return iPlayer;
}

stock SetViewAll()
{
	new pEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if (!pev_valid(pEntity)) return;

	set_pev(pEntity, pev_classname, "human_camera");
	set_pev(pEntity, pev_solid, SOLID_BBOX);
	set_pev(pEntity, pev_movetype, MOVETYPE_NOCLIP);

	engfunc(EngFunc_SetModel, pEntity, "models/w_usp.mdl");
	set_pev(pEntity, pev_angles, vecCamAngle[CUR]);
	//set_pev(pEntity, pev_v_angle, vecCamVAngle[CUR]);
	set_pev(pEntity, pev_origin, vecCamOrigin[CUR]);
	//set_pev(pEntity, pev_effects, EF_NODRAW);

	//client_print(0, print_chat, "%f %f %f", vecCamOrigin[0], vecCamOrigin[1], vecCamOrigin[2])

	for (new id = 1; id <= 32; id++)
	{
		if (!is_user_connected(id))
			continue;

		if (!is_user_alive(id))
			continue;

		if (!g_bRescued[id])
			continue;

		if (get_pdata_int(id, m_iTeam) == TEAM_CT)
		{
			engfunc(EngFunc_SetView, id, pEntity);

			set_pev(id, pev_fov, 90.0);
			set_pdata_int(id, m_iFOV, 90);

			set_pev(id, pev_effects, EF_NODRAW);
			set_pev(id, pev_solid, SOLID_NOT);
			set_pev(id, pev_takedamage, DAMAGE_NO);
		}
	}
}

stock UTIL_RoundTime(seconds)
{
	message_begin(MSG_ALL, get_user_msgid("RoundTime"));
	write_short(seconds);
	message_end();
}

public Task_ZombieWin(taskid)
{
	if (CountPlayer(TEAM_CT, 1) != 0) // all HM die = ZB WIN
	{
		ZombieWin();
		KillAll();
		Explosion();
	}
}

native BTE_MVPBoard(iWinningTeam, iType, iPlayer = 0);

public ZombieWin()
{
	if (task_exists(TASK_ESCAPE)) remove_task(TASK_ESCAPE);
	if (task_exists(TASK_HUMANWIN)) remove_task(TASK_HUMANWIN);

	server_cmd("sv_noroundend 0");
	TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Terrorist);

	BTE_MVPBoard(1, 0);
}

public HumanWin()
{
	if (task_exists(TASK_ESCAPE)) remove_task(TASK_ESCAPE);
	if (task_exists(TASK_HUMANWIN)) remove_task(TASK_HUMANWIN);

	server_cmd("sv_noroundend 0");
	TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Ct);

	BTE_MVPBoard(2, 0);
}

#define SITTING_FILE "cstrike/addons/amxmodx/configs/map/%s.ini"
#define CONFIG_VALUE "Escape"

public LoadCfg()
{
	new mapname[32], filepath[100];
	get_mapname(mapname, charsmax(mapname));
	formatex(filepath, charsmax(filepath), SITTING_FILE, mapname);

	g_iMaxRescure = 0;

	for (new i = 0; i < RESCUE_MAX; i++)
	{
		new value[8];
		if (i != 0)
			format(value, charsmax(value), "Escape%d", i + 1);
		else
			format(value, charsmax(value), "Escape");

		GetPrivateProfile(value, "EscapeStart", "-1", filepath, BTE_FLOAT, flRescue[i]);
		if (flRescue[i] == -1)
			break;

		g_iMaxRescure ++;

		GetPrivateProfile(value, "EscapeStart", "-1", filepath, BTE_FLOAT, flRescue[i]);
		GetPrivateProfile(value, "Defence", "10", filepath, BTE_FLOAT, flDefence[i]);

		GetPrivateProfile(value, "Model", "models/helicopter_hind.mdl", filepath, BTE_STRING, szModel[i], 64/*charsmax(szModel[i])*/);

		new data[64];
		GetPrivateProfile(value, "Mins", "0", filepath, BTE_STRING, data, charsmax(data));
		BreakupStringFloat(data, vecMins[i]);
		GetPrivateProfile(value, "Maxs", "0", filepath, BTE_STRING, data, charsmax(data));
		BreakupStringFloat(data, vecMaxs[i]);
		GetPrivateProfile(value, "Angle", "0", filepath, BTE_STRING, data, charsmax(data));
		BreakupStringFloat(data, vecAngle[i]);

		GetPrivateProfile(value, "TargetOrigin", "@", filepath, BTE_STRING, data, charsmax(data));
		if (data[0] == '@')
		{
			bNoMove[i] = TRUE;
			GetPrivateProfile(value, "SpawnOrigin", "0", filepath, BTE_STRING, data, charsmax(data));
			BreakupStringFloat(data, vecOrigin[i][0]);
		}
		else
		{
			bNoMove[i] = FALSE;
			GetPrivateProfile(value, "SpawnOrigin", "0", filepath, BTE_STRING, data, charsmax(data));
			BreakupStringFloat(data, vecOrigin[i][0]);
			GetPrivateProfile(value, "TargetOrigin", "0", filepath, BTE_STRING, data, charsmax(data));
			BreakupStringFloat(data, vecOrigin[i][1]);
			GetPrivateProfile(value, "TargetOrigin2", "0", filepath, BTE_STRING, data, charsmax(data));
			BreakupStringFloat(data, vecOrigin[i][2]);
			GetPrivateProfile(value, "LeaveOrigin", "0", filepath, BTE_STRING, data, charsmax(data));
			BreakupStringFloat(data, vecOrigin[i][3]);
			GetPrivateProfile(value, "Speed", "100, 100, 100", filepath, BTE_STRING, data, charsmax(data));
			BreakupStringFloat(data, flSpeed[i]);
		}

		GetPrivateProfile(value, "CameraOrigin", "0", filepath, BTE_STRING, data, charsmax(data));
		BreakupStringFloat(data, vecCamOrigin[i]);
		GetPrivateProfile(value, "CameraAngle", "0", filepath, BTE_STRING, data, charsmax(data));
		BreakupStringFloat(data, vecCamAngle[i]);
		/*GetPrivateProfile(value, "CameraVAngle", "0", filepath, BTE_STRING, data, charsmax(data));
		BreakupStringFloat(data, vecCamVAngle[i]);*/

		GetPrivateProfile(value, "ExplosionOrigin", "0", filepath, BTE_STRING, data, charsmax(data));
		BreakupStringFloat(data, vecExpOrigin[i]);

		GetPrivateProfile(value, "ExplosionScale", "125", filepath, BTE_INT, iExpScale[i]);
	}
}

stock BreakupStringFloat(value[], any:data[])
{
	new key[128];
	new i = 0;
	while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
	{
		trim(key)
		trim(value)
		data[i] = str_to_float(key);
		i += 1;
	}
}
