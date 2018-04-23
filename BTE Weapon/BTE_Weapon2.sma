#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <rage>

#include "../BTE_API.inc"
#include "../bte_wpn2.inc"
#include "inc/metahook.inc"

#include <cstrike>
#include <csx>
#include <xs>
#include <orpheu>
#include <orpheu_memory>
#include <orpheu_stocks>

native CanPlayerAttack(id);

#include "bte/BTE_Vars.sma"
#include "bte/BTE_ValueDef.sma"
#include "bte/BTE_Task.sma"
#include "bte/BTE_Util.sma"
#include "bte/BTE_Public.sma"
#include "bte/BTE_ReadFile.sma"
#include "bte/BTE_Stocks.sma"
#include "bte/BTE_Ham.sma"
#include "bte/BTE_EventCmd.sma"
#include "bte/BTE_Natives.sma"
//#include "bte/BTE_Menu.sma"
//#include "bte/BTE_UIMaker.sma"
#include "bte/BTE_WpnEffect.sma"
#include "bte/BTE_Forward.sma"

public plugin_init()
{
	//g_iBlockSetModel = 0

	//Event
	//register_event("StatusIcon", "Event_StatusIcon", "be", "2=buyzone")
	register_event("HLTV","Event_HLTV","a","1=0","2=0")
	//LogEvent
	register_logevent("LogEvent_Round_Start",2, "1=Round_Start")

	//Message ID
	g_msgScreenShake = get_user_msgid("ScreenShake")
	g_msgCurWeapon = get_user_msgid("CurWeapon")
	g_msgHideWeapon = get_user_msgid("HideWeapon")
	g_msgAmmoPickup = get_user_msgid("AmmoPickup")
	g_msgWeaponList = get_user_msgid("WeaponList")
	g_msgAmmoPickup = get_user_msgid("AmmoPickup")

	gmsgBlinkAcct = get_user_msgid("BlinkAcct");
	gmsgTextMsg = get_user_msgid("TextMsg");
	gmsgMoney = get_user_msgid("Money");
	gmsgFade = get_user_msgid("ScreenFade");
	g_msgScoreInfo = get_user_msgid("ScoreInfo")

	// Register clcmd
	register_clcmd("buyammo1","cmd_buyammo1")
	register_clcmd("primammo","cmd_buyfullammo1")
	register_clcmd("buyammo2","cmd_buyammo2")
	register_clcmd("secammo","cmd_buyfullammo2")

	//register_clcmd("bte_select_wpn","cmd_select_wpn")
	//register_clcmd("bte_wpn_menu","cmd_wpn_menu")
	register_clcmd("bte_wpn_rebuy","cmd_wpn_rebuy")
	register_clcmd("sv_create_psb", "cmd_buy_mywpn")
	register_concmd("bte_wpn_reload_data","cmd_wpn_reload_data")
	//register_concmd("test","cmd_test")
	// Block Buy Command
	register_clcmd("cl_setautobuy","cmd_block")
	register_clcmd("cl_autobuy","cmd_block")
	//register_clcmd("bte_buy", "Cmd_Buy");
	//register_clcmd("cl_setrebuy","cmd_block")
	//register_clcmd("cl_rebuy","cmd_block")

	//Fakemeta Forwards

	register_forward(FM_ClientCommand , "Forward_ClientCommand")
	register_forward(FM_PlaybackEvent, "Forward_PlaybackEvent")
	unregister_forward(FM_PrecacheEvent, g_fwPrecacheEvent, 1)
	register_forward(FM_UpdateClientData, "Forward_UpdateClientData_Post", 1)
	register_forward(FM_EmitSound,"Forward_EmitSound")
	register_forward(FM_FindEntityInSphere, "Forward_FindEntityInSphere")
	register_forward(FM_PlayerPostThink, "Forward_PlayerPostThink", 1)
	g_fwHamBotRegister = register_forward(FM_PlayerPostThink, "fw_BotRegisterHam", 1)

	// Hamsandwich Forwards
	RegisterHam(Ham_Touch, "grenade", "HamF_Touch_Grenade",1)
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage")
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage_Post", 1);
	RegisterHam(Ham_TakeDamage, "func_breakable", "HamF_TakeDamage_Breakable")
	RegisterHam(Ham_TakeDamage, "hostage_entity", "HamF_TakeDamage")
	RegisterHam(Ham_TakeDamage, "monster_scientist", "HamF_TakeDamage")

	RegisterHam(Ham_Killed, "player", "HamF_Killed", 1)
	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player_Post",1)
	//RegisterHam(Ham_Item_PreFrame, "player", "HamF_Set_Player_Maxspeed_Post", 1)
	RegisterHam(Ham_Think, "info_target", "HamF_InfoTarget_Think")
	RegisterHam(Ham_Think, "grenade", "HamF_Think_Grenade",1)

	RegisterHam(Ham_Touch, "info_target", "HamF_InfoTarget_Touch")
	RegisterHam(Ham_AddPlayerItem, "player", "HamF_AddPlayerItem")

	RegisterHam(Ham_Touch, "armoury_entity", "HamF_ArmouryEntity_Touch");

	for (new i=1; i<=CSW_P90; i++)
	{
		if (WEAPON_NAME[i][0])
		{
			RegisterHam(Ham_Item_Deploy, WEAPON_NAME[i], "HamF_Item_Deploy")
			RegisterHam(Ham_Item_Deploy, WEAPON_NAME[i], "HamF_Item_Deploy_Post",1)

			if (!(CSWPN_NOTREMOVE & (1<<i)))
			{
				if (!(CSWPN_SHOTGUNS & (1<<i)) && !((1<<CSW_HEGRENADE) & (1<<i)))
				{
					RegisterHam(Ham_Weapon_WeaponIdle, WEAPON_NAME[i], "HamF_Weapon_WeaponIdle")
					RegisterHam(Ham_Weapon_Reload, WEAPON_NAME[i], "HamF_Weapon_Reload")
					RegisterHam(Ham_Weapon_Reload, WEAPON_NAME[i], "HamF_Weapon_Reload_Post")
				}

				RegisterHam(Ham_Spawn,WEAPON_NAME[i], "HamF_Spawn_Weapon");
				RegisterHam(Ham_Item_Holster,WEAPON_NAME[i], "HamF_Item_Holster_Post",1);
				RegisterHam(Ham_Item_PostFrame, WEAPON_NAME[i], "HamF_Item_PostFrame");
				RegisterHam(Ham_CS_Item_GetMaxSpeed, WEAPON_NAME[i], "HamF_Item_GetMaxSpeed");
				RegisterHam(Ham_CS_Item_CanDrop, WEAPON_NAME[i], "HamF_Item_CanDrop");

				if (i != CSW_KNIFE)
				{
					RegisterHam(Ham_Weapon_PrimaryAttack, WEAPON_NAME[i], "HamF_Weapon_PrimaryAttack_Post",1)
					RegisterHam(Ham_Weapon_PrimaryAttack, WEAPON_NAME[i], "HamF_Weapon_PrimaryAttack")

					RegisterHam(Ham_Weapon_SecondaryAttack, WEAPON_NAME[i], "HamF_Weapon_SecondaryAttack");
				}
			}
		}
	}

	RegisterHam(Ham_Item_PostFrame, "weapon_knife", "CKnife_PostFrame");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "CKnife_PrimaryAttack");
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "CKnife_SecondaryAttack");
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_knife", "CKnife_WeaponIdle");

	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_m3", "HamF_Weapon_WeaponIdle_Shotgun");
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_xm1014", "HamF_Weapon_WeaponIdle_Shotgun");
	RegisterHam(Ham_Weapon_Reload, "weapon_m3", "HamF_Weapon_Reload_Shotgun");
	RegisterHam(Ham_Weapon_Reload, "weapon_xm1014", "HamF_Weapon_Reload_Shotgun");
	
	//Cvar
	cvar_botquota = get_cvar_pointer("bot_quota")
	cvar_friendlyfire = get_cvar_pointer("mp_friendlyfire")
	cvar_freebuy = register_cvar("bte_wpn_free","1")
	cvar_freebuyzone = register_cvar("bte_wpn_buyzone","0")

	register_message(get_user_msgid("StatusIcon"), "message_StatusIcon");
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg");
	register_message(SVC_TEMPENTITY, "message_HeGrenadeExplosion");
	register_message(get_user_msgid("StatusValue"), "message_StatusValue");
	register_message(gmsgTextMsg, "message_TextMsg");
	register_message(SVC_DIRECTOR, "message_Director");

	//register_message(get_user_msgid("Damage"), "message_Damage");

	handleApplyMultiDamage = OrpheuGetFunction( "ApplyMultiDamage" );
	handleClearMultiDamage = OrpheuGetFunction( "ClearMultiDamage" );
	handleHandleBuyAliasCommands = OrpheuGetFunction( "HandleBuyAliasCommands" );
	//handleBuyItem = OrpheuGetFunction( "BuyItem" );
	handleSetAnimation = OrpheuGetFunction ( "SetAnimation", "CBasePlayer" );
	//handleCanPlayerBuy = OrpheuGetFunction ( "CanPlayerBuy", "CBasePlayer" );
	handleResetSequenceInfo = OrpheuGetFunction( "ResetSequenceInfo", "CBaseAnimating" );
	handleKickBack = OrpheuGetFunction ( "KickBack", "CBasePlayerWeapon" );
	handleAddAccount = OrpheuGetFunction ( "AddAccount", "CBasePlayer" );
	handleTEXTURETYPE_PlaySound = OrpheuGetFunction("TEXTURETYPE_PlaySound")
	handleSelectItem = OrpheuGetFunction ( "SelectItem", "CBasePlayer" );
	handleSelectLastItem = OrpheuGetFunction ( "SelectLastItem", "CBasePlayer" );
	handleDefaultReload = OrpheuGetFunction ( "DefaultReload", "CBasePlayerWeapon" );

	//OrpheuRegisterHook( handleSetAnimation, "Orpheu_SetAnimation", OrpheuHookPre );
	OrpheuRegisterHook( handleHandleBuyAliasCommands, "OnHandleBuyAliasCommands_Pre", OrpheuHookPre );

	OrpheuRegisterHook( handleKickBack, "OnKickBack_Pre", OrpheuHookPre );
	OrpheuRegisterHook( handleAddAccount, "OnAddAccount_Pre", OrpheuHookPre );
	OrpheuRegisterHook( handleSelectItem, "OnSelectItem_Pre", OrpheuHookPre );
	OrpheuRegisterHook( handleSelectLastItem, "OnSelectLastItem_Pre", OrpheuHookPre );

	g_fBuyTime = get_gametime() + get_cvar_float("mp_buytime") * 60.0

	handleFireBullets3 = RageGetFunction( "CBaseEntity::FireBullets3" );
	handleFireBullets = RageGetFunction( "CBaseEntity::FireBullets" );

	RageCreateHook( handleFireBullets3, "OnFireBullets3_Pre", RageHookPre );
	RageCreateHook( handleFireBullets, "OnFireBullets_Pre", RageHookPre );

	gmsgRoundStart = engfunc(EngFunc_RegUserMsg, "RoundStart", 0);
	gmsgAlarm = engfunc(EngFunc_RegUserMsg, "StatusAlarm", 2);
	gmsgAssist = engfunc(EngFunc_RegUserMsg, "Assist", 4);
	gmsgMVP = engfunc(EngFunc_RegUserMsg, "MVP", -1);
	gmsgMVPBoard = engfunc(EngFunc_RegUserMsg, "MVPBoard", -1);
}

public fw_BotRegisterHam(id)
{
	if (!is_user_zbot(id) || get_pcvar_num(cvar_botquota) <= 0) 
		return
	unregister_forward(FM_PlayerPostThink, g_fwHamBotRegister, 1)
	
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage");
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage_Post", 1);
	/////RegisterHamFromEntity(Ham_TraceAttack, id, "HamF_TraceAttack");
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player_Post", 1);
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed", 1);
	RegisterHamFromEntity(Ham_AddPlayerItem, id, "HamF_AddPlayerItem");
	RegisterHamFromEntity(Ham_BloodColor, id, "HamF_BloodColor");
}

public message_HeGrenadeExplosion(iMsg,iType,iId)
{
	if (get_msg_arg_int(1) == TE_BLOODSPRITE)
		if (bte_get_user_zombie(g_pLastVictim) == 1)
			set_msg_arg_int(7, get_msg_argtype(7), 180);

	if (iType==MSG_PAS && get_msg_arg_int(1) == TE_EXPLOSION && get_msg_arg_int(7) == 30 && (get_msg_arg_int(6) == 25 || get_msg_arg_int(6) == 30))
	{
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public message_Director()
{
	if (get_msg_arg_int(1) != 9) return;
	if (get_msg_arg_int(2) != 2) return;
	if (get_msg_arg_int(4)) return;
	if (get_msg_arg_int(5) == (15 | (1<<9) | (1<<7) | (1<<5)))
	{
		g_iDefuser = get_msg_arg_int(3);
	}
	else if (get_msg_arg_int(5) == (11 | (1<<7)))
	{
		g_iPlanter = get_msg_arg_int(3);
		Native_Alarm(g_iPlanter, 24);
	}
}

public plugin_end()
{
	Pub_ShutDown()
}

public plugin_precache()
{
	// Init Plugin
	Pub_Init()

	g_fBuyTime = get_gametime() + get_cvar_float("mp_buytime") * 60.0;
	// Register Forward
	g_fw_RegisterNamedWeapon = CreateMultiForward("bte_fw_precache_weapon_pre",ET_IGNORE)
	ExecuteForward(g_fw_RegisterNamedWeapon, g_fwDummyResult)
	//g_iBlockSetModel = 1 // Fix Map Weapon Entity Precache
	register_forward(FM_SetModel, "Forward_SetModel")
	//OrpheuRegisterHook(OrpheuGetEngineFunction("pfnSetModel", "SetModel"), "OnSetModel_Pre")

	RegisterHam(Ham_Spawn, "armoury_entity", "HamF_ArmouryEntity_Spawn_Post",1);

	Read_Config_File()
	Read_Block_Res()
	register_forward(FM_PrecacheModel, "Forward_PrecaceResource")
	register_forward(FM_PrecacheSound, "Forward_PrecaceResource")
	g_fwPrecacheEvent = register_forward(FM_PrecacheEvent, "Forward_PrecacheEvent", 1)


	Read_MyWeapon()
	Read_WeaponsINI(1)

	m_usExplosion = engfunc(EngFunc_PrecacheEvent, 1, "events/explosion.sc");
	m_usTempEntity = engfunc(EngFunc_PrecacheEvent, 1, "events/te.sc");
	m_usGaussFire = engfunc(EngFunc_PrecacheEvent, 1, "events/gauss.sc");
	m_usGaussSpin = engfunc(EngFunc_PrecacheEvent, 1, "events/gaussspin.sc");

	//m_usBalrog11Cannon = engfunc(EngFunc_PrecacheEvent, 1, "events/balrog11follow.sc");

	precache_model("models/s_grenade.mdl")
	precache_model("models/s_grenade_spark.mdl")
	precache_model("sprites/sparkeffect2.spr");

	g_sModelIndexSmokeBeam = precache_model("sprites/smoke.spr");
	g_sModelIndexSmokeSmallPuff = precache_model("sprites/smokepuff.spr");
	g_cache_trail = precache_model("sprites/smoke.spr")
	g_sModelIndexLaserBeam = precache_model("sprites/laserbeam.spr")
	
	precache_model("sprites/smoke_ia.spr")
	precache_model("sprites/fexplo.spr")
	precache_model("sprites/spark1.spr")
	precache_model("sprites/steam1.spr")
	precache_model("sprites/bte_cp_smoke.spr")
	precache_model("sprites/flame_puff01.spr")
	precache_model("sprites/plasmaball.spr")
	g_cache_blood = precache_model("sprites/blood.spr")
	g_cache_bloodspray = precache_model("sprites/bloodspray.spr")

	precache_model("models/w_usp.mdl")

	g_cache_flameburn = precache_model("sprites/flame_burn01.spr")
	g_cache_holyburn = precache_model("sprites/holybomb_burn.spr")

	precache_model("sprites/holybomb_exp.spr")

	g_sModelIndexBubbles = precache_model("sprites/bubble.spr");
	g_sModelIndexSmoke = precache_model("sprites/steam1.spr");
	g_sModelIndexFireball2 = precache_model("sprites/eexplo.spr");
	g_sModelIndexFireball3 = precache_model("sprites/fexplo.spr");
}

public client_putinserver(id)
{
	
	g_knockback[id] = 1.0;
	g_flNextSetAnim[id] = 0.0;
	g_iAnimOffset[id] = 0;
	g_iRank[0][id] = g_iRank[1][id] = g_iRank[2][id] = 0;

	if (!DECAL_SCORCH[0])
	{
	DECAL_SCORCH[0] = engfunc(EngFunc_DecalIndex, "{scorch1");
	DECAL_SCORCH[1] = engfunc(EngFunc_DecalIndex, "{scorch2");
	DECAL_SCORCH[2] = engfunc(EngFunc_DecalIndex, "{scorch3");

	DECAL_SHOT[0] = engfunc(EngFunc_DecalIndex, "{shot1");
	DECAL_SHOT[1] = engfunc(EngFunc_DecalIndex, "{shot2");
	DECAL_SHOT[2] = engfunc(EngFunc_DecalIndex, "{shot3");
	DECAL_SHOT[3] = engfunc(EngFunc_DecalIndex, "{shot4");
	DECAL_SHOT[4] = engfunc(EngFunc_DecalIndex, "{shot5");
	}
}

public client_disconnect(id)
{
	Pub_DisConnectReset(id)
}

public bte_zb_infected(iVictim, iAttacker)
{
	for (new j=1; j<33; j++)
		g_fTotalDamage[iVictim][j] = 0.0;
	if (0 < iAttacker < 33)
		g_iRank[2][iAttacker] ++;

	if ((iAttacker < 33 && iAttacker > 0))
	{
		new iInGame=0, iPlayer = 0;
		for (new id=1; id<33; id++)
		{
			if (!is_user_connected(id) || !is_user_alive(id) || bte_get_user_zombie(id) == 1) continue;
			iInGame++;
			iPlayer = id;
		}
		if (iInGame == 1 && IsPlayer(iPlayer))
		{
			Native_Alarm(iPlayer, 28);
		}
		if (!CountHumans())
		{
			Native_Alarm(iAttacker, 19);
		}
	}
}
public bomb_planting(planter)
{
	g_iPlanting = planter;
}
public bomb_defusing(defuser)
{
	g_iDefusing = defuser;
}
public bomb_planted(planter)
{
	g_iPlanting = g_iDefusing = 0;
}
public bomb_defused(defuser)
{
	g_iPlanting = g_iDefusing = 0;
}