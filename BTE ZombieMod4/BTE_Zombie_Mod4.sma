#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <round_terminator>
#include <orpheu>
#include "bte_api.inc"
#include "offset.inc"
#include "inc.inc"
#include "resources.inc"

#include "BTE_Zb4_API.inc"

#define PLUGIN "BTE Zombie Mod4"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

native BTE_MVPBoard(iWinningTeam, iType, iPlayer = 0);

//#define _TEST
//#define _PRINT

// TODO
// 支持非3分钟每回合
// 闪光弹和烟雾弹？

new g_hamczbots, bot_quota;

new g_iZombie[33], g_iRespawning[33], g_iStun[33], g_iRespawnCount[33], g_iCanUseSkill[33], g_iKillWhenNight[33];
new g_iNormalZombie[33]
new g_iDash[33], g_iDashUsage[33], Float:g_flNextCheckDash[33], Float:g_flDashCheckInterval[33], g_iDashRemove[33];
new Float:g_fOldHealth[33], Float:g_fHealth[33], Float:g_fDamageRound[33], Float:g_fDamage[33], Float:g_fArmorValue[33], Float:g_fMaxHealth[33], Float:g_fXDamage[33];
new g_iPower[33];
new g_iLastSendPower[33], Float:g_flNextPowerRefreshTime[33];
new Float:fLastSendDamage[33], Float:g_flNextSendDamage[33];
new Float:g_flNextRestoreHealth[33];
new g_iUsingSkill[33];
new g_iChangedTeam[33];
new g_msgTeamInfo, g_msgSendAudio/*, g_msgHideWeapon*/, g_msgDeathMsg, g_msgScoreAttrib, g_msgScoreInfo, g_msgTextMsg, /*g_msgScreenFade, */g_msgClCorpse;
new g_iLight, g_iTimer;
new g_iDayStatus;
new g_iRoundStart;
new g_iSkyColor[3], g_iCurLight;
new g_szLight[9][4] = {"i", "h", "g", "f", "e", "f","g", "h", "i"};
new g_iZombieClassCount = 0;
new g_iClass[33];
new g_iNightStart, g_iNightEnd;
new Float:g_flStopVelocityModify[33];
new Float:g_flMaxSpeed[33];
//new g_iZbNvg;
new g_EnteredBuyMenu[33];
new g_sWeapon[33][4][32];

new Cache_Spr_ZombieRespawn, Cache_Event;

new g_fw_ZombieEmitSound, g_fw_UserInfected, g_fw_DummyResult;

#define MAX_ZOMBIES	5

new g_szZombieName[MAX_ZOMBIES][32]
new g_szZombieModel[MAX_ZOMBIES][16], g_iZombieModel[MAX_ZOMBIES], g_szZombieViewModel[MAX_ZOMBIES][64], g_iZombieViewModel[MAX_ZOMBIES];
new g_szZombieStun[MAX_ZOMBIES][64];
new Float:g_fZombieGravity[MAX_ZOMBIES], Float:g_fZombieMaxSpeed[MAX_ZOMBIES], Float:g_fZombieHeal[MAX_ZOMBIES][2], Float:g_fZombieXDamage[MAX_ZOMBIES], Float:g_fZombieKnockback[MAX_ZOMBIES], Float:g_fZombieVM[MAX_ZOMBIES];

new g_pGameRules
new gmsgZombieMenu

#include "BTE_Zombie_Mod4_2.sma"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_dictionary("bte_zombie.bte");

	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");
	//register_event("TeamInfo", "Event_TeamInfo", "a");
	register_logevent("LogEvent_RoundStart", 2, "1=Round_Start");
	register_logevent("LogEvent_RoundEnd", 2, "1=Round_End");

	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage");
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage_Post", 1);
	RegisterHam(Ham_Killed, "player", "HamF_Killed", 1);
	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player");
	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player_Post", 1);

	RegisterHam(Ham_Touch, "weaponbox", "HamF_TouchWeaponBox");

	register_forward(FM_PlayerPostThink, "Forward_PlayerPostThink", 1);
	register_forward(FM_EmitSound, "Forward_EmitSound");
	register_forward(FM_ClientKill, "Forward_ClientKill");

	register_clcmd("bte_zb4_select_zombie","SelectZombie");
	register_clcmd("bte_normal_zombie","NormalZombie")
	register_clcmd("chooseteam","Cmd_ChooseTeam")
	register_clcmd("bte_dm_set_weapon","Cmd_SetWeapons");
	register_clcmd("bte_dm_buy","Cmd_GiveWeapons");

	g_msgTeamInfo = get_user_msgid("TeamInfo");
	g_msgSendAudio = get_user_msgid("SendAudio");
	g_msgDeathMsg = get_user_msgid("DeathMsg");
	g_msgScoreAttrib = get_user_msgid("ScoreAttrib");
	g_msgScoreInfo = get_user_msgid("ScoreInfo");
	g_msgTextMsg = get_user_msgid("TextMsg");
	//g_msgScreenFade = get_user_msgid("ScreenFade");
	g_msgClCorpse = get_user_msgid("ClCorpse");

	register_message(g_msgClCorpse, "message_ClCorpse");
	register_message(g_msgSendAudio, "message_SendAudio");
	register_message(g_msgDeathMsg, "message_DeathMsg");
	register_message(g_msgTextMsg, "message_TextMsg");

	bot_quota = get_cvar_pointer("bot_quota");

	server_cmd("mp_roundtime 3");
	server_cmd("mp_freezetime 0");
	server_cmd("mp_flashlight 1");
	server_cmd("bte_wpn_buyzone 0");
	server_cmd("bte_wpn_free 1");

	g_iLight = GetLightStyle();

	if (g_iLight > g_szLight[0][0])
		for(new i=0;i<9;i++)
			g_szLight[i][0] += (g_iLight - g_szLight[0][0]);

	g_iSkyColor[0] = get_cvar_num("sv_skycolor_r");
	g_iSkyColor[1] = get_cvar_num("sv_skycolor_g");
	g_iSkyColor[2] = get_cvar_num("sv_skycolor_b");

	g_fw_ZombieEmitSound = CreateMultiForward("bte_zb_EmitSound", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_FLOAT, FP_CELL, FP_CELL);
	g_fw_UserInfected = CreateMultiForward("bte_zb_infected", ET_IGNORE, FP_CELL, FP_CELL);
	
	gmsgZombieMenu = engfunc(EngFunc_RegUserMsg, "ZombieMenu", -1);

}

public plugin_cfg()
{
	new cfgdir[32]
	get_configsdir(cfgdir, charsmax(cfgdir))

	server_cmd("exec %s/%s", cfgdir, "bte_zombiemod4.cfg")
}

public plugin_precache()
{
	for(new i=0;i<sizeof(HUMAN_INFECTED_SND);i++)
	{
		precache_sound(HUMAN_INFECTED_SND[i])
	}

	Cache_Spr_ZombieRespawn = precache_model("sprites/zb_respawn.spr");
	Cache_Event = engfunc(EngFunc_PrecacheEvent, 1, "events/knife.sc");
	OrpheuRegisterHook(OrpheuGetFunction("InstallGameRules"), "OnInstallGameRules", OrpheuHookPost)
}

public OrpheuHookReturn:OnInstallGameRules()
{
	g_pGameRules = OrpheuGetReturn();
	
	OrpheuRegisterHook(OrpheuGetFunctionFromObject(g_pGameRules, "CheckWinConditions", "CGameRules"), "OnCheckWinConditions")
	OrpheuRegisterHook(OrpheuGetFunctionFromObject(g_pGameRules, "FPlayerCanRespawn", "CGameRules"), "OnFPlayerCanRespawn")
}

public OrpheuHookReturn:OnCheckWinConditions(this)
{
	if (!g_iRoundStart || !CountPlayer(1))
		return OrpheuIgnored
	return OrpheuSupercede
}

public OrpheuHookReturn:OnFPlayerCanRespawn(this, id)
{
	if (!g_iRoundStart || !CountPlayer(1))
		OrpheuSetReturn(true)
	else
		OrpheuSetReturn(false)
	return OrpheuSupercede
}

public Cmd_ChooseTeam(id)
{
	ShowZombieMenu(id, 0);
	return PLUGIN_HANDLED
}

public Forward_ClientKill(id)
{
	return FMRES_SUPERCEDE;
}

public Forward_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if (!is_user_connected(id) || !g_iZombie[id])
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

public Forward_PlayerPostThink(id)
{
	/*set_pev(id, pev_button, pev(id,pev_button) | IN_DUCK);
	set_pev(id, pev_oldbuttons, pev(id,pev_oldbuttons) | IN_DUCK);*/

	if (pev(id, pev_deadflag) != DEAD_NO)
	{
		/*if (g_iDash[id])
			client_cmd(id, "-dash");*/

		return FMRES_IGNORED;
	}

	if (g_iZombie[id] && g_flStopVelocityModify[id] > get_gametime())
		set_pdata_float(id, m_flVelocityModifier, 0.7);

	if (g_iZombie[id] && g_flMaxSpeed[id])
		set_pev(id, pev_maxspeed, g_flMaxSpeed[id]);

	if (g_iStun[id])
	{
		set_pev(id, pev_maxspeed, 0.1);
		set_pev(id, pev_view_ofs, {0.0, 0.0, 7.0});

		new Float:vecVelocity[3];
		pev(id, pev_velocity, vecVelocity);
		vecVelocity[0] = vecVelocity[1] = 0.0;
		set_pev(id, pev_velocity, vecVelocity);
	}

	CheckPower(id);
	CheckDamage(id);
	CheckDash(id);
	Restore(id);

	return FMRES_IGNORED;
}

public Restore(id)
{
	if (!g_iZombie[id] || g_iStun[id] || g_iDayStatus == DAYSTATUS_DAY2)
		return;

	if (get_gametime() >= g_flNextSendDamage[id])
	{
		g_flNextSendDamage[id] = get_gametime() + 0.5;

		new Float:fHealth , Float:fMaxHealth;
		pev(id, pev_health, fHealth);
		pev(id, pev_max_health, fMaxHealth);

		fHealth += g_iDayStatus == DAYSTATUS_NIGHT ? g_fZombieHeal[g_iClass[id]][1] : g_fZombieHeal[g_iClass[id]][0];
		fHealth = fHealth > fMaxHealth ? fMaxHealth : fHealth;

		set_pev(id, pev_health, fHealth);
	}
}

public CheckDash(id)
{
	if (get_gametime() >= g_flNextCheckDash[id] && g_iDash[id])
	{
		SetPower(id, -g_iDashUsage[id], g_flDashCheckInterval[id], is_user_bot(id) == 0);

		if (g_iDashRemove[id])
			client_cmd(id, "-dash");

		if (!g_iPower[id])
			g_iDashRemove[id] = 1;
		else
			g_iDashRemove[id] = 0;

		g_flNextCheckDash[id] = get_gametime() + g_flDashCheckInterval[id];
	}
}

public CheckDamage(id)
{
	if (get_gametime() >= g_flNextRestoreHealth[id])
	{
		g_flNextRestoreHealth[id] = get_gametime() + 1.0;

		if (fLastSendDamage[id] == g_fDamageRound[id])
			return;

		fLastSendDamage[id] = g_fDamageRound[id];
		MH_ZB4Damage(id, floatround(g_fDamageRound[id]));
		//MH_ZB4SendDamage(id, floatround(g_fDamage[id] / 1000.0)); // new TAB cant show dmg
	}
}

public CheckPower(id)
{
	if (g_iUsingSkill[id] || g_iStun[id])
		return;

	if (get_gametime() >= g_flNextPowerRefreshTime[id])
	{
		if (g_iDayStatus == DAYSTATUS_NIGHT && g_iZombie[id])
		{
			g_flNextPowerRefreshTime[id] = get_gametime() + 0.7;
			SetPower(id, 4, 1.0);
		}
		else
		{
			g_flNextPowerRefreshTime[id] = get_gametime() + 1.0;
			SetPower(id, 1, 0.5);
		}
	}
}

public HamF_Spawn_Player_Post(id)
{
	SetRendering(id);
	StripWeapons(id);
	bte_wpn_give_named_wpn(id, "knife", 1);

	if (!g_iZombie[id])
	{
		HumamSpawn(id);
	}

	if (!is_user_bot(id) && is_user_connected(id))
	{
		MH_ZB4Power(id, g_iPower[id], 0.0);
		MH_ZB4Damage(id, floatround(g_fDamageRound[id]));
		//MH_ZB4AddIcon(id, 0, 1);
	}

	return HAM_IGNORED;
}

public GiveWeapons(id)
{
	for (new i=0; i<4; i++)
		if (g_sWeapon[id][i][0])
			bte_wpn_give_named_wpn(id, g_sWeapon[id][i], 1);
}

public Cmd_GiveWeapons(id)
{
	GiveWeapons(id);
	
	return PLUGIN_HANDLED;
}

public Cmd_SetWeapons(id)
{
	new sWeapon[32];
	read_argv(1, sWeapon, 31);
	format(g_sWeapon[id][0], 31, "%s", sWeapon);

	read_argv(2, sWeapon, 31);
	format(g_sWeapon[id][1], 31, "%s", sWeapon);

	read_argv(3, sWeapon, 31);
	format(g_sWeapon[id][2], 31, "%s", sWeapon);

	read_argv(4, sWeapon, 31);
	format(g_sWeapon[id][3], 31, "%s", sWeapon);

	return PLUGIN_HANDLED;
}

native PlayerSpawn(id);

public HumamSpawn(id)
{
	bte_wpn_give_named_wpn(id, "usp", 1);
	set_pdata_int(id, m_iKevlar, 2);
	set_pev(id, pev_armorvalue, 100.0);
	set_pev(id, pev_health, 1000.0);
	set_pev(id, pev_max_health, 1000.0);
	set_pev(id, pev_skin, 0);
	set_pev(id, pev_gravity, 0.8);
	
	if (!g_EnteredBuyMenu[id])
		PlayerSpawn(id);
}


public HamF_Spawn_Player(id)
{
	if (!g_iZombie[id])
		set_pdata_int(id, m_iTeam, 2);

	return HAM_IGNORED;
}

public HamF_TouchWeaponBox(weapon, id)
{
	if (!is_user_connected(id)) return HAM_IGNORED
	if (g_iZombie[id]) return HAM_SUPERCEDE
	return HAM_IGNORED
}

public HamF_TakeDamage(iVictim, inflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if (!g_iRoundStart || g_iTimer <= 20)
		return HAM_SUPERCEDE;

	if (!is_user_connected(iVictim) || !is_user_connected(iAttacker))
		return HAM_IGNORED;

	pev(iVictim, pev_health, g_fOldHealth[iVictim]);

	if (!g_iZombie[iAttacker] && get_user_weapon(iAttacker) != CSW_KNIFE)
		flDamage = flDamage + flDamage * float(g_iPower[iAttacker]) / 100.0;

	if (g_iZombie[iVictim])
		flDamage *= g_fXDamage[iVictim];

	/*if (g_iStun[iVictim])
		return HAM_SUPERCEDE;*/

#if defined _PRINT
	PRINT("id: %d health: %f damage:%f", iVictim, g_fOldHealth[iVictim], flDamage)
#endif

	if (g_iDayStatus == DAYSTATUS_NIGHT && g_iZombie[iVictim] && (g_fOldHealth[iVictim] - flDamage) < 1.0 && !(pev(iVictim, pev_flags) & FL_DUCKING) && !g_iStun[iVictim])
	{
		Stun(iVictim);
		return HAM_SUPERCEDE;
	}

	if (g_iZombie[iAttacker] && !g_iZombie[iVictim] && inflictor <= 32)
	{
		ZombieInfectedHuman(iAttacker, iVictim);
		return HAM_SUPERCEDE;
	}

	SetHamParamFloat(4, flDamage);

	return HAM_IGNORED;
}

public HamF_TakeDamage_Post(iVictim, inflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if (!g_iRoundStart || g_iTimer <= 20)
		return HAM_SUPERCEDE;

	if (!is_user_connected(iVictim) || !is_user_connected(iAttacker))
		return HAM_IGNORED;

	pev(iVictim, pev_health, g_fHealth[iVictim]);

	if (!g_iZombie[iAttacker])
	{
		g_fDamageRound[iAttacker] += g_fOldHealth[iVictim] - g_fHealth[iVictim];
		g_fDamage[iAttacker] += g_fOldHealth[iVictim] - g_fHealth[iVictim];
	}

	return HAM_IGNORED;
}

public HamF_Killed(iVictim, iKiller, gib)
{
	if (g_iZombie[iVictim])
		HumanKilledZombie(iKiller, iVictim);

	if (g_iZombie[iVictim])
	{
		SetLight(iVictim, g_szLight[g_iCurLight], 0);
		MH_SendZB3Data(iVictim, 12, 0);
		set_pev(iVictim, pev_skin, 0);
	}

#if defined _PRINT
	if (g_iDayStatus == DAYSTATUS_NIGHT && g_iZombie[iVictim])
		PRINT("Warning: Zombie killed when night Victim: %d", iVictim)

	// 这问题应该不存在了...
#endif
}

public Stun(id)
{
	g_iStun[id] = 1;

	set_pev(id, pev_health, 1.0);

	new item = get_pdata_cbase(id, m_pActiveItem);

	set_pdata_float(id, m_flNextAttack, 5.0);
	set_pdata_float(item, m_flTimeWeaponIdle, 4.0);
	set_pdata_float(item, m_flNextPrimaryAttack, 5.0);
	set_pdata_float(item, m_flNextSecondaryAttack, 5.0);

	SendWeaponAnim(id, 4);

	ResetZombieKnife(item);

	pev(id, pev_armorvalue, g_fArmorValue[id]);
	pev(id, pev_max_health, g_fMaxHealth[id]);

	set_pev(id, pev_takedamage, DAMAGE_NO);
	set_pev(id, pev_skin, 0);

	Nvg(id);
	MH_ZB4AddIcon(id, 8, 6, 1);

	client_cmd(id, "-dash;-duck");

	PlayEmitSound(id, CHAN_VOICE, g_szZombieStun[g_iClass[id]]);

	g_iRespawnCount[id] = 5;
	if (task_exists(id + TASK_STUNNED)) remove_task(id + TASK_STUNNED);
	set_task(1.0, "Task_Stuned", id + TASK_STUNNED, "", 0, "a", 5);

	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, Cache_Event, 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0 , 0.0, (1<<5), id, false, false);

	new sz[2];
	sz[0] = '0' + g_iRespawnCount[id];
	sz[1] = 0;

	TextMsg(id, HUD_PRINTCENTER, "#CSBTE_RespawnWait", sz);
}

public Task_Stuned(taskid)
{
	new id = taskid - TASK_STUNNED;
	if (!is_user_connected(id) || !is_user_alive(id))
		return;

	g_iRespawnCount[id]--;
	if (g_iRespawnCount[id])
	{
		if (g_iRespawnCount[id] <= 5)
		{
			new sz[2];
			sz[0] = '0' + g_iRespawnCount[id];
			sz[1] = 0;

			TextMsg(id, HUD_PRINTCENTER, "#CSBTE_RespawnWait", sz);
		}

		if (g_iRespawnCount[id] == 1)
		{
			/*message_begin(MSG_ONE, g_msgScreenFade, _, id)
			write_short((1<<12)) // duration
			write_short((1<<12)) // hold time
			write_short(0x0000) // fade type
			write_byte(80) // red
			write_byte(0) // green
			write_byte(0) // blue
			write_byte(180) // alpha
			message_end()*/

			MH_ZB4AddIcon(id, 8, 6, 3);
		}

		return;
	}

	TextMsg(id, HUD_PRINTCENTER, "#CSBTE_Respawn");

	g_iStun[id] = 0;

	/*g_fMaxHealth[id] /= 2.0;
	g_fArmorValue[id] /= 2.0;*/
	g_fMaxHealth[id] = g_fMaxHealth[id] < 1000.0 ? 1000.0 : g_fMaxHealth[id];
	g_fArmorValue[id] = g_fArmorValue[id] < 0.0 ? 0.0 : g_fArmorValue[id];

	set_pev(id, pev_health, g_fMaxHealth[id]);
	set_pev(id, pev_max_health, g_fMaxHealth[id]);
	set_pev(id, pev_armorvalue, g_fArmorValue[id]);


	new item = get_pdata_cbase(id, m_pActiveItem);
	if(item)
	{
		set_pdata_float(item, m_flTimeWeaponIdle, 1.0);
		set_pdata_float(item, m_flNextPrimaryAttack, 0.5);
		set_pdata_float(item, m_flNextSecondaryAttack, 0.5);
	}
	set_pdata_float(id, m_flNextAttack, 0.5);

	SendWeaponAnim(id, 5);

	set_pev(id, pev_velocity, {0.0, 0.0, 0.0});
	set_pev(id, pev_view_ofs, {0.0, 0.0, 17.0});

	set_pev(id, pev_takedamage, DAMAGE_AIM);

	Nvg(id);

	if (task_exists(taskid)) remove_task(taskid);
}

public ResetZombieKnife(item)
{
	set_pev(item, pev_iuser1, 0);
	set_pev(item, pev_iuser2, 0);
	set_pev(item, pev_iuser3, 0);
	set_pev(item, pev_iuser4, 0);
}

public SetCanUseSkill(taskid)
{
	g_iCanUseSkill[taskid - TASK_SHOWINGMENU] = 1;
}

public ZombieInfectedHuman(iAttacker, iVictim)
{
	SendDeathMsg(iAttacker, iVictim);
	FixDeadAttrib(iVictim);

	UpdateFrags(iAttacker, 1, 1);

	g_iCanUseSkill[iVictim] = 0;
	if (task_exists(iVictim + TASK_SHOWINGMENU)) remove_task(iVictim + TASK_SHOWINGMENU);
	set_task(5.0, "SetCanUseSkill", iVictim + TASK_SHOWINGMENU);

	if (is_user_bot(iVictim))
		g_iClass[iVictim] = random_num(0, g_iZombieClassCount - 1);
	else if(g_iNormalZombie[iVictim] < 0)
	{
		g_iClass[iVictim] = 0;
		ShowZombieMenu(iVictim, 1);
	}
	else
	{
		g_iClass[iVictim] = g_iNormalZombie[iVictim];
		g_iCanUseSkill[iVictim] = 1;
	}

	MakeZombie(iVictim);
	SetPower(iVictim, 100, 0.5);

	new Float:fMaxHealth, Float:fArmor;
	pev(iAttacker, pev_max_health, fMaxHealth);
	fMaxHealth /= 1.4;
	fMaxHealth = floatmax(1000.0, fMaxHealth);
	fArmor = fMaxHealth / 10.0;
	set_pev(iVictim, pev_health, fMaxHealth);
	set_pev(iVictim, pev_max_health, fMaxHealth);
	set_pev(iVictim, pev_armorvalue, fArmor);
	set_pdata_int(iVictim, m_iKevlar, 2);

	//MH_ZB4SendData(iVictim, 2);

	PlaySound(0, ZOMBIE_COMING[random_num(0, 1)]);
	PlayEmitSound(iVictim, CHAN_VOICE, HUMAN_INFECTED_SND[bte_get_user_sex(iVictim) == 2 ? 1 : 0]);

	ExecuteForward(g_fw_UserInfected, g_fw_DummyResult, iVictim, iAttacker);

	CheckWinCondition();
}

//native MH_ZombieMenu(id,a[]);

public ShowZombieMenu(id, bSelect)
{
	if(bSelect)
	{
		if(!g_iZombie[id]) return

		g_iCanUseSkill[id] = 0;
		
		if (task_exists(id + TASK_SHOWINGMENU)) remove_task(id + TASK_SHOWINGMENU);
		set_task(5.0, "SetCanUseSkill", id + TASK_SHOWINGMENU);
	}
	
	engfunc(EngFunc_MessageBegin, MSG_ONE, gmsgZombieMenu, {0.0, 0.0, 0.0}, id);
	write_byte(bSelect);
	write_byte(g_iZombieClassCount);
	for (new i = 0; i < g_iZombieClassCount; i++)
	{
		write_string(g_szZombieName[i]);
		
	}
	message_end();
	
	//MH_ZombieMenu(id,message);
	//menu_display(id, mHandleID, 0)
}

public HumanKilledZombie(iKiller, iVictim)
{
	if (bte_zb4_is_using_accshoot(iKiller) && g_iZombie[iVictim] && g_iDayStatus != DAYSTATUS_NIGHT)
	{
		TextMsg(iVictim, HUD_PRINTCENTER, "#CSBTE_CannotRespawnByAdrShot");

		UpdateFrags(iKiller, 2, 1);
	}
	else if (g_iZombie[iVictim])
	{
		/*new text[2] = "5";
		TextMsg(iVictim, HUD_PRINTCENTER, "#CSBTE_RespawnWait", text);*/
		/*if (g_iDayStatus == DAYSTATUS_NIGHT)
			set_msg_block(g_msgDeathMsg, BLOCK_ONCE);*/

		g_iKillWhenNight[iVictim] = (g_iDayStatus == DAYSTATUS_NIGHT);
		g_iRespawnCount[iVictim] = 5 + 2;
		if (task_exists(iVictim + TASK_RESPAWN)) remove_task(iVictim + TASK_RESPAWN);
		set_task(1.0, "Task_ZombieRespawn", iVictim + TASK_RESPAWN, "", 0, "a", 7);


		if (task_exists(iVictim + TASK_RESPAWN_EF)) remove_task(iVictim + TASK_RESPAWN_EF);
		set_task(1.0, "Task_ZombieRespawnEffect", iVictim + TASK_RESPAWN_EF);

		g_iRespawning[iVictim] = 1;

		pev(iVictim, pev_armorvalue, g_fArmorValue[iVictim]);
		pev(iVictim, pev_max_health, g_fMaxHealth[iVictim]);

		Nvg(iVictim);
	}

	if (iKiller == iVictim)
		return;

	if (!CheckRespawning() || !CountPlayer(0))
		CheckWinCondition();
}

public CheckWinCondition()
{
	if (!CountPlayer(0))
	{
		TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Terrorist);
		BTE_MVPBoard(1, 0);
	}
	else if (!CountPlayer(1))
	{
		TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Ct);
		BTE_MVPBoard(2, 0);
	}
}

public plugin_natives()
{
	register_native("bte_get_user_zombie", "native_get_user_zombie", 1);
	register_native("bte_zb4_get_day_status", "native_get_day_status", 1);
	register_native("bte_get_user_power", "native_get_user_power", 1);
	register_native("bte_set_user_power", "native_set_user_power", 1);
	register_native("bte_set_using_skill", "native_set_using_skill", 1);

	register_native("bte_zb4_regiter_zombie", "native_register_zombie", 1);
	register_native("bte_zb4_is_stuned", "native_is_stuned", 1);
	register_native("bte_zb4_is_using_skill", "native_is_using_skill", 1);
	register_native("bte_zb4_set_dash", "native_set_dash", 1);
	register_native("bte_zb4_get_dash", "native_get_dash", 1);

	register_native("bte_zb4_get_zombie_class", "native_get_zombie_class", 1);
	register_native("bte_zb4_can_use_skill", "native_can_use_skill", 1);

	register_native("bte_zb4_set_xdamage", "native_set_xdamage", 1);

	register_native("bte_get_zombie_sex", "native_get_sex", 1);
}

public native_get_sex(id)
{
	return ((g_iClass[id] == 1) ? 1 : 0) + 1;
}

public native_set_xdamage(id, Float:xdamage)
{
	if (xdamage)
		g_fXDamage[id] = xdamage;
	else
		g_fXDamage[id] = g_fZombieXDamage[g_iClass[id]];
}

public native_can_use_skill(id)
{
	return g_iCanUseSkill[id];
}

public native_set_dash(id, i, Float:time, value)
{
	g_iDash[id] = i;
	g_iUsingSkill[id] = i;

	g_iDashUsage[id] = value;
	g_flDashCheckInterval[id] = time;

	g_flNextCheckDash[id] = get_gametime();

/*#if defined _TEST
	PRINT("SetDashUsage:%f %f", g_iDashUsage[id], g_flDashCheckInterval[id])
#endif*/
}

public native_get_dash(id)
{
	return g_iDash[id];
}

public native_get_zombie_class(id)
{
	return g_iClass[id];
}

public native_is_using_skill(id)
{
	return g_iUsingSkill[id];
}

public native_is_stuned(id)
{
	return g_iStun[id];
}
public native_register_zombie(const Name[], const PlayerModel[], const ViewModel[], const StunSound[], Float:Maxspeed, Float:Gravity, Float:HealDay, Float:HealNight, Float:XDamage, Float:Knockback, Float:VM)
{
	param_convert(1);
	param_convert(2);
	param_convert(3);
	param_convert(4);

	copy(g_szZombieName[g_iZombieClassCount], 31, Name)
	
	new szZombieModel[64], szZombieViewModel[64];
	format(szZombieModel, 64, "models/player/%s/%s.mdl", PlayerModel, PlayerModel);
	copy(g_szZombieModel[g_iZombieClassCount], 32, PlayerModel);
	format(szZombieViewModel, 64, "models/%s.mdl", ViewModel);
	copy(g_szZombieViewModel[g_iZombieClassCount], 64, szZombieViewModel);

	g_iZombieModel[g_iZombieClassCount] = engfunc(EngFunc_PrecacheModel, szZombieModel);
	g_iZombieViewModel[g_iZombieClassCount] = engfunc(EngFunc_PrecacheModel, szZombieViewModel);

	copy(g_szZombieStun[g_iZombieClassCount], 64, StunSound);
	precache_sound(StunSound);

	g_fZombieHeal[g_iZombieClassCount][0] = HealDay;
	g_fZombieHeal[g_iZombieClassCount][1] = HealNight;
	g_fZombieMaxSpeed[g_iZombieClassCount] = Maxspeed;
	g_fZombieGravity[g_iZombieClassCount] = Gravity;
	g_fZombieXDamage[g_iZombieClassCount] = XDamage;
	g_fZombieKnockback[g_iZombieClassCount] = Knockback;
	g_fZombieVM[g_iZombieClassCount] = VM;

	g_iZombieClassCount += 1;

	return g_iZombieClassCount - 1;
}

public native_set_using_skill(id, using_skill)
{
	g_iUsingSkill[id] = using_skill;
}

public native_set_user_power(id, power, Float:flashtime)
{
	SetPower(id, power, flashtime);
}

public native_get_user_power(id)
{
	return g_iPower[id];
}

public native_get_user_zombie(id)
{
	if (!id || id >32)
		return 0;

	return g_iZombie[id];
}

public native_get_day_status(id)
{
	return g_iDayStatus;
}

public client_putinserver(id)
{
	if (!g_hamczbots && is_user_bot(id) && get_pcvar_num(bot_quota) > 0)
	{
		set_task(0.4, "RegisterBotHam", id + TASK_HAM_BOT);
	}

	ResetValue(id);

	set_task(1.0, "SendLight", id);

#if defined _PRINT
	if (!CheckRespawning() && (CountPlayer(0) + CountPlayer(1) == 1))
	{
		TerminateRound(RoundEndType_Draw, TeamWinning_None);
		PRINT("TerminateRound: TeamWinning_None")
	}
#else
	if (!CheckRespawning() && (CountPlayer(0) + CountPlayer(1) == 1))
		TerminateRound(RoundEndType_Draw, TeamWinning_None);
#endif
}

public client_disconnect(id)
{
	if (!CheckRespawning() && (CountPlayer(0) + CountPlayer(1) == 1))
		TerminateRound(RoundEndType_Draw, TeamWinning_None);
}

public SendLight(id)
{
	SetLight(id, g_szLight[0]);
}

/*public Event_TeamInfo()
{
	new id = read_data(1);
	if (!g_iChangedTeam[id])
	{
		set_task(0.1, "SendLight", id + TASK_SEND_LIGHT);
		g_iChangedTeam[id] = 1;
	}
}*/

public ResetValue(id)
{
	g_iUsingSkill[id] = 0;
	g_iChangedTeam[id] = 0;
	g_iPower[id] = 0;
	g_iZombie[id] = 0;
	g_fDamageRound[id] = 0.0;
	g_fDamage[id] = 0.0;
	g_flNextPowerRefreshTime[id] = 0.0;
	g_flNextSendDamage[id] = 0.0;
	g_iLastSendPower[id] = 0;
	g_flNextRestoreHealth[id] = 0.0;
	g_iRespawning[id] = 0;
	g_iClass[id] = 0;
	g_iDash[id] = 0;
	g_iStun[id] = 0;
	g_EnteredBuyMenu[id] = 0;
	g_iNormalZombie[id] = -1;
}


/*public SendLight(taskid)
{
	new id = taskid - TASK_SEND_LIGHT;

	SetLight(id, "g");
}*/

public RegisterBotHam(taskid)
{
	new id = taskid - TASK_HAM_BOT;

	if (g_hamczbots || !is_user_connected(id))
		return;

	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage");
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage_Post", 1);
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed", 1);
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player");
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player_Post",1)

	g_hamczbots = 1;
}

public LogEvent_RoundStart()
{
	g_iRoundStart = 1;
	g_iDayStatus = DAYSTATUS_DAY;

	new Float:round_time;
	round_time = get_cvar_float("mp_roundtime") * 60.0;

	if (task_exists(TASK_HUMANWIN))
		remove_task(TASK_HUMANWIN);

	set_task(round_time, "HumanWin", TASK_HUMANWIN);

	if (task_exists(TASK_MAKEZOMBIE))
		remove_task(TASK_MAKEZOMBIE);

#if defined _TEST
	set_task(2.0, "MakeFirstZombie", TASK_MAKEZOMBIE);
#else
	set_task(20.0, "MakeFirstZombie", TASK_MAKEZOMBIE);
#endif

	for(new id=1;id<=32;id++)
	{
		g_flNextPowerRefreshTime[id] = get_gametime() + 1.0;
		g_flNextSendDamage[id] = get_gametime() + 1.0;
		g_flNextRestoreHealth[id] = get_gametime() + 1.0;
	}

	if (task_exists(TASK_TIMER))
		remove_task(TASK_TIMER);

	g_iTimer = 0;
	set_task(1.0, "Task_Timer", TASK_TIMER, _, _, "b");
}

public Task_Timer(taskid)
{
	g_iTimer += 1;

	/*if (g_iTimer == 50)
	{
		SetLight(0, g_szLight[0]);
		SetSkyColor();
	}*/
	if (g_iTimer == g_iNightStart)
		g_iDayStatus = DAYSTATUS_NIGHT;

	if (g_iTimer == g_iNightEnd)
	{
		g_iDayStatus = DAYSTATUS_DAY2;

		for (new id=1;id<=32;id++)
		{
			if (!is_user_connected(id))
				continue;

			if (!g_iZombie[id])
			{
				bte_wpn_set_fullammo(id);
				bte_wpn_give_grenade(id);
			}
			else
			{
				g_flStopVelocityModify[id] = get_gametime() + 4.0;
			}
		}
	}

	// 好像很傻
	/*if (g_iTimer > g_iNightStart - 5 && g_iTimer <= g_iNightStart)
		SetZombieNvg(1.0 - (g_iNightStart - g_iTimer) * 0.2);*/

	/*if (g_iTimer == g_iNightStart - 10)
	{
		g_iZbNvg = 3;
	}

	if (g_iTimer == g_iNightEnd - 10)
	{
		g_iZbNvg = 4;
	}*/

	if (g_iTimer == g_iNightStart - 6)
	{
		g_iCurLight = 1;
		SetLight(0, g_szLight[1], 1);
		SetSkyColor(0.8);
	}

	if (g_iTimer == g_iNightStart - 3)
	{
		g_iCurLight = 2;
		SetLight(0, g_szLight[2], 1);
		SetSkyColor(0.7);
	}

	if (g_iTimer == g_iNightStart)
	{
		g_iCurLight = 3;
		SetLight(0, g_szLight[3], 1);
		SetSkyColor(0.5);

		//g_iZbNvg = 2;

#if defined _PRINT
	PRINT("NightStart!");
#endif

	}

	if (g_iTimer == g_iNightStart + 10)
	{
		g_iCurLight = 4;
		SetLight(0, g_szLight[4], 1);
		SetSkyColor(0.4);
	}

	if (g_iTimer == g_iNightEnd - 30)
	{
		g_iCurLight = 5;
		SetLight(0, g_szLight[5], 1);
		SetSkyColor(0.5);
	}

	if (g_iTimer == g_iNightEnd - 7)
	{
		g_iCurLight = 6;
		SetLight(0, g_szLight[6], 1);
		SetSkyColor(0.7);
	}

	if (g_iTimer == g_iNightEnd - 4)
	{
		g_iCurLight = 7;
		SetLight(0, g_szLight[7], 1);
		SetSkyColor(0.8);
	}

	if (g_iTimer == g_iNightEnd)
	{
		g_iCurLight = 8;
		SetLight(0, g_szLight[8], 1);
		SetSkyColor();

		//g_iZbNvg = 1;

#if defined _PRINT
	PRINT("NightEnd!");
#endif

	}

	/*if (g_iTimer > g_iNightEnd - 5 && g_iTimer <= g_iNightEnd)
		SetZombieNvg((g_iNightEnd - g_iTimer) * 0.2);*/
}

/*public SetZombieNvg(Float:scale)
{
#if defined _PRINT
	PRINT("ZombieNvg: %f", scale)
#endif
	if (scale != 1.0 && scale != 0.0)
		g_iZombieNvgFlag = 0x0000;
	else
		g_iZombieNvgFlag = 0x0004;

	g_iZombieNvg[0] = ZOMBIE_NVG_R + floatround((ZOMBIE_NVG_NIGHT_R - ZOMBIE_NVG_R) * scale);
	g_iZombieNvg[1] = ZOMBIE_NVG_G + floatround((ZOMBIE_NVG_NIGHT_G - ZOMBIE_NVG_G) * scale);
	g_iZombieNvg[2] = ZOMBIE_NVG_B + floatround((ZOMBIE_NVG_NIGHT_B - ZOMBIE_NVG_B) * scale);
	g_iZombieNvg[3] = ZOMBIE_NVG_A + floatround((ZOMBIE_NVG_NIGHT_A - ZOMBIE_NVG_A) * scale);

	for (new id=0; id<32; id++)
		if (g_iZombie[id] && !g_iRespawning[id] && !g_iStun[id])
			Nvg(id);
}*/

public Task_ZombieRespawnEffect(taskid)
{
	if (task_exists(taskid)) remove_task(taskid);

	new id = taskid - TASK_RESPAWN_EF;
	if (!is_user_connected(id))
		return;

	new Float:vecOrigin[3];
	pev(id, pev_origin, vecOrigin);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(Cache_Spr_ZombieRespawn);
	write_byte(10);
	write_byte(20);
	write_byte(14);
	message_end();


	return;
}

public Task_ZombieRespawn(taskid)
{
	new id = taskid - TASK_RESPAWN;
	if (!is_user_connected(id))
		return;

	g_iRespawnCount[id]--;
	if (g_iRespawnCount[id])
	{
		if (g_iRespawnCount[id] <= 5)
		{
			new sz[2];
			sz[0] = '0' + g_iRespawnCount[id];
			sz[1] = 0;

			TextMsg(id, HUD_PRINTCENTER, g_iKillWhenNight[id] ? "#CSBTE_RespawnWaitForNight" : "#CSBTE_RespawnWait", sz);
		}
		return;
	}

	TextMsg(id, HUD_PRINTCENTER, "#CSBTE_Respawn");
	ZombieRespawn(id);

	if (task_exists(taskid)) remove_task(taskid);

	return;
}

public LogEvent_RoundEnd()
{
	g_iRoundStart = 0;

	server_cmd("sv_noroundend 0");

	if (task_exists(TASK_HUMANWIN)) remove_task(TASK_HUMANWIN);
}

public MakeFirstZombie()
{
	new iInGame;
	for(new i =1;i<33;i++)
	{
		if (is_user_connected(i) && is_user_alive(i))
			iInGame++;
	}

#if defined _TEST
	if (!iInGame)
#else
	if (iInGame <= 1)
#endif
	{
#if defined _PRINT
		PRINT("Warning : No enough players!")
#endif
		return;
	}

	//g_iZbNvg = 1;

	new iZombieNum = iInGame / 10 + 1;

	new Float:fMaxHealth;
	fMaxHealth = 1000.0 * iInGame / iZombieNum + 1000.0;
	if (fMaxHealth < 4000.0) fMaxHealth = 4000.0;

	while (iZombieNum)
	{
		new id = random_num(1, iInGame);
		if (is_user_alive(id) && is_user_connected(id) && !g_iZombie[id])
		{
			if (is_user_bot(id))
				g_iClass[id] = random_num(0, g_iZombieClassCount - 1);
			else if(g_iNormalZombie[id] < 0)
			{
				g_iClass[id] = 0;
				ShowZombieMenu(id, 1);
			}
			else
			{
				g_iClass[id] = g_iNormalZombie[id];
				g_iCanUseSkill[id] = 1;
			}
			
			MakeZombie(id);
			SetPower(id, 100, 0.2);
			

			MH_ZB4SendData(id, 2);

			set_pev(id, pev_health, fMaxHealth);
			set_pev(id, pev_max_health, fMaxHealth);
			set_pev(id, pev_armorvalue, fMaxHealth / 5.0);

			iZombieNum--;

			g_iCanUseSkill[id] = 0;
			if (task_exists(id + TASK_SHOWINGMENU)) remove_task(id + TASK_SHOWINGMENU);
			set_task(5.0, "SetCanUseSkill", id + TASK_SHOWINGMENU);

			ExecuteForward(g_fw_UserInfected, g_fw_DummyResult, id, 0);
		}
	}

	if (task_exists(TASK_MAKEZOMBIE)) remove_task(TASK_MAKEZOMBIE)

	PlaySound(0, ZOMBIE_COMING[random_num(0, 1)]);
}

public SelectZombie(id)
{
	if (g_iCanUseSkill[id])
		return PLUGIN_HANDLED;
	
	new sCmd[32];
	read_argv(1, sCmd, 31);

	new i = str_to_num(sCmd);
	if (i < g_iZombieClassCount)
	{
		if (g_iClass[id] != i)
		{
			g_iClass[id] = i;
			MakeZombie(id);
		}

		if (task_exists(id + TASK_SHOWINGMENU)) 
			remove_task(id + TASK_SHOWINGMENU);
		g_iCanUseSkill[id] = 1;
	}
#if defined _PRINT
	else
		PRINT("Warning : Selected Zombie Class not exist");
#endif
	
	return PLUGIN_HANDLED;
}

public NormalZombie(id)
{
	new sCmd[32];
	read_argv(1,sCmd,31);
	
	new iZombieClass = -1;
	
	if(!strcmp(sCmd, "random"))
	{
		iZombieClass = -2;
	}
	else
	{
		for(new i=0;i<g_iZombieClassCount;i++)
		{
			if(!strcmp(g_szZombieName[i], sCmd))
			{
				iZombieClass = i;
				break;
			}
		}
	}
	g_iNormalZombie[id] = iZombieClass;
}

public MakeZombie(id)
{
	if (!is_user_alive(id)) return;

	g_iZombie[id] = 1;
	g_iUsingSkill[id] = 0;
	g_iRespawning[id] = 0;
	g_fXDamage[id] = g_fZombieXDamage[g_iClass[id]];
	SetTeam(id, TEAM_TERRORIST);

	set_pdata_int(id, m_iKevlar, 2);
	set_pev(id, pev_gravity, g_fZombieGravity[g_iClass[id]]);
	bte_wpn_set_knockback(id, g_fZombieKnockback[g_iClass[id]]);
	bte_wpn_set_vm(id, g_fZombieVM[g_iClass[id]]);

	g_flMaxSpeed[id] = g_fZombieMaxSpeed[g_iClass[id]];

	StripWeapons(id);
	Nvg(id);

	bte_wpn_give_named_wpn(id, "knife", 1);
	set_pev(id, pev_weaponmodel, 0);

	//client_cmd(id, "-dash");

	if (!g_iZombieClassCount)
	{
#if defined _PRINT
		PRINT("Error: No Zombie Class!");
#endif
		return;
	}

	bte_set_user_model(id, g_szZombieModel[g_iClass[id]]);
	bte_set_user_model_index(id, g_iZombieModel[g_iClass[id]]);
	set_pev(id, pev_viewmodel2, g_szZombieViewModel[g_iClass[id]]);
}

public ZombieRespawn(id)
{
	ExecuteHamB(Ham_CS_RoundRespawn, id);

	MakeZombie(id);
	g_iPower[id] = 0;
	SetPower(id, 50, 0.0);

	g_fMaxHealth[id] /= 2.0;
	g_fArmorValue[id] /= 2.0;
	g_fMaxHealth[id] = g_fMaxHealth[id] < 1000.0 ? 1000.0 : g_fMaxHealth[id];
	g_fArmorValue[id] = g_fArmorValue[id] < 0.0 ? 0.0 : g_fArmorValue[id];

	set_pev(id, pev_health, g_fMaxHealth[id]);
	set_pev(id, pev_max_health, g_fMaxHealth[id]);
	set_pev(id, pev_armorvalue, g_fArmorValue[id]);

	PlaySound(0, ZOMBIE_COMEBACK);

	ExecuteForward(g_fw_UserInfected, g_fw_DummyResult, id, 0);
}

public Nvg(id)
{
	if (!g_iZombie[id])
		return;

	if (g_iRespawning[id])
	{
		MH_SendZB3Data(id, 12, 0);
		MH_ZB4Nvg(id, 0);
		SetLight(id, g_szLight[g_iCurLight]);
		/*message_begin(MSG_ONE, g_msgScreenFade, _, id)
		write_short(0) // duration
		write_short(0) // hold time
		write_short(0x0000) // fade type
		write_byte(100) // red
		write_byte(100) // green
		write_byte(100) // blue
		write_byte(255) // alpha
		message_end()*/

		return;
	}

	if (g_iStun[id])
	{
		SetLight(id, g_szLight[g_iCurLight]);
		MH_ZB4Nvg(id, 5);
		/*message_begin(MSG_ONE, g_msgScreenFade, _, id)
		write_short((1<<12)*2) // duration
		write_short((1<<10)*10) // hold time
		write_short(0x0004) // fade type
		write_byte(255) // red
		write_byte(0) // green
		write_byte(0) // blue
		write_byte(180) // alpha
		message_end()*/

		return;
	}

	MH_SendZB3Data(id, 12, 1);
	SetLight(id, "0");
	//MH_ZB4Nvg(id, g_iZbNvg);
	/*message_begin(MSG_ONE, g_msgScreenFade, _, id);
	write_short((1<<12)*2); // duration
	write_short((1<<10)*3); // hold time
	write_short(g_iZombieNvgFlag); // fade type
	write_byte(g_iZombieNvg[0]); // red
	write_byte(g_iZombieNvg[1]); // green
	write_byte(g_iZombieNvg[2]); // blue
	write_byte(g_iZombieNvg[3]); // alpha
	message_end();*/

	return;
}



public HumanWin()
{
	TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Ct);
	BTE_MVPBoard(2, 0);
}

public Event_HLTV()
{
	g_iRoundStart = 0;

	server_cmd("mp_autoteambalance 0");

	SendLight(0);
	SetSkyColor();

	g_iNightStart = random_num(95, 130);
	g_iNightEnd = random_num(40, 65);

#if defined _PRINT
	PRINT("NightStart: %d:%d NightEnd: %d:%d", g_iNightStart / 60, g_iNightStart % 60, g_iNightEnd / 60, g_iNightEnd % 60);
#endif

	MH_ZB4SetNightTime(g_iNightStart, g_iNightEnd);

	g_iNightStart = 180 - g_iNightStart;
	g_iNightEnd = 180 - g_iNightEnd;

	for(new id=1;id<=32;id++)
	{
		if(!is_user_connected(id))
			continue;
		g_iZombie[id] = 0;
		g_fDamageRound[id] = 0.0;
		g_iUsingSkill[id] = 0;
		g_iRespawning[id] = 0;
		g_iStun[id] = 0;
		g_iDash[id] = 0;
		g_iDashUsage[id] = 0;
		g_flDashCheckInterval[id] = 0.0;
		g_EnteredBuyMenu[id] = 1;
		SetPower(id, -100, _, 1);
		client_cmd(id, "-dash;-duck");

		if (task_exists(id + TASK_RESPAWN)) remove_task(id + TASK_RESPAWN);
		if (task_exists(id + TASK_STUNNED)) remove_task(id + TASK_STUNNED);
		if (task_exists(id + TASK_RESPAWN_EF)) remove_task(id + TASK_RESPAWN_EF);
	}
	PlayerSpawn(0);
}

stock SetPower(id, power, Float:flashtime = 0.5, sendmsg = 1)
{
	g_iPower[id] += power;

	g_iPower[id] = g_iPower[id] > 100 ? 100 : g_iPower[id];
	g_iPower[id] = g_iPower[id] < 0 ? 0 : g_iPower[id];

	if (g_iLastSendPower[id] == g_iPower[id])
		return;

	g_iLastSendPower[id] = g_iPower[id];

	if (!is_user_bot(id) && is_user_connected(id) && sendmsg)
		MH_ZB4Power(id, g_iPower[id], flashtime);
}

/*public message_TeamInfo()
{
	new id = get_msg_arg_int(1);
	new sTeam[2]; get_msg_arg_string(2, sTeam, 1);

	if (g_iChangedTeam[id])
		return PLUGIN_CONTINUE;

	SetLight(id, "g");

	switch (sTeam[0])
	{
		case 'T':
		{
			g_iChangedTeam[id] = 1;
			set_msg_arg_string(2, "CT");
			set_pdata_int(id, m_iTeam, 2);
		}
		case 'C':
		{
			g_iChangedTeam[id] = 1;
		}
	}

	return PLUGIN_CONTINUE;
}*/

public message_TextMsg()
{
	static textmsg[22];
	get_msg_arg_string(2, textmsg, charsmax(textmsg));

	if (equal(textmsg, "#Game_will_restart_in") || equal(textmsg, "#Game_Commencing"))
	{
		for (new id=0; id<32; id++)
			g_fDamage[id] = 0.0;
	}
}

public message_ClCorpse()
{
	new iVictim = get_msg_arg_int(12);

	if (g_iRespawning[iVictim])
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}


public message_SendAudio()
{
	static audio[17]
	get_msg_arg_string(2, audio, charsmax(audio))

	if (equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw"))
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public message_DeathMsg()
{
	new KillerID = get_msg_arg_int(1);
	new IsHeadshot = bte_zb4_is_using_accshoot(KillerID);

	set_msg_arg_int(3, get_msg_argtype(3), IsHeadshot);
}

/*public message_HideWeapon()
{
	new Flags = get_msg_arg_int(1);
	Flags |= HIDEHUD_TIMER;

	set_msg_arg_int(1, get_msg_argtype(1), Flags);

	return PLUGIN_CONTINUE;
}*/

