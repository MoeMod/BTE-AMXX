#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <orpheu>

#include <beams>

#include "z4e_bits.inc"
#include "z4e_api.inc"
#include "z4e_team.inc"
#include "z4e_gameplay.inc"
#include "z4e_zombie.inc"
#include "z4e_alarm.inc"
#include "z4e_burn.inc"
#include "z4e_freeze.inc"

#include <x_api>

#define PLUGIN "[Z4E] Map : ze_FFVII_Mako_Reactor_v1_1"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define MODELINDEX_WALL_SPAWN 11

#define MODELINDEX_BREAKABLE1 3
#define MODELINDEX_DOOR1A 20
#define MODELINDEX_WALL1B 34
#define MODELINDEX_DOOR1A_BUTTON 19

#define MODELINDEX_DOOR2 31
#define MODELINDEX_DOOR2_BUTTON 32

#define MODELINDEX_DOOR3_TOPWALL 38
#define MODELINDEX_DOOR3_BOXWALL 42
#define MODELINDEX_DOOR3 44
#define MODELINDEX_DOOR3_BUTTON 37

#define MODELINDEX_BARRIER4A 46
#define MODELINDEX_BARRIER4B 47
#define MODELINDEX_BARRIER4C 48

#define MODELINDEX_DOOR4 51
#define MODELINDEX_DOOR4_BUTTON 52

#define MODELINDEX_WALL5 103
#define MODELINDEX_DOOR5 54
#define MODELINDEX_WALL5_BUTTON 55

#define MODELINDEX_GLASS5 53

#define MODELINDEX_DOOR6A 121
#define MODELINDEX_DOOR6B 122
#define MODELINDEX_DOOR6_BUTTON 56
#define MODELINDEX_DOOR6_ELEVATOR_DOWN 58

#define MODELINDEX_DOOR7A 123
#define MODELINDEX_DOOR7B 124
#define MODELINDEX_DOOR7_BUTTON 98
#define MODELINDEX_DOOR7_ELEVATOR_UP 57
#define MODELINDEX_WALL7_SIDE 110

#define MODELINDEX_WALL8A 101
#define MODELINDEX_WALL8B 105

#define MODELINDEX_WALL9 91

#define MODELINDEX_WALL10 97
#define MODELINDEX_DOOR10 96

#define MODELINDEX_FANCE1 45
#define MODELINDEX_FANCE2 47

#define MODELINDEX_DOOR_BRIDGE 73 // func_door

#define MODELINDEX_WALL_BUTTONROOM 100 // func_wall
#define MODELINDEX_BUTTON_BUTTONROOM 102

#define MODELINDEX_WALL_BFUCKEX2 48

enum 
{
	BUTTON_DOOR1,
	BUTTON_DOOR2,
	BUTTON_DOOR3,
	BUTTON_DOOR4,
	BUTTON_WALL5,
	BUTTON_DOOR6,
	BUTTON_DOOR7,
	BUTTON_BUTTONROOM,
	BUTTON_BRIDGE
}

new const Float:ZOMBIESPAWN_ORIGIN[] = {3223.0, -3600.0, 3730.0}
new const Float:ZOMBIESPAWN_ELECTRIC[] = {762.0, 360.0, -276.0}

new const Float:UNDERGROUND_ORIGIN_CHECK[3] = {450.0, 3200.0, -2955.0 }
new const Float:UNDERGROUND_ORIGIN_CAGE[3] = {432.0, 733.0, -2950.0}
#define UNDERGROUND_BELOW -1433.0
#define UNDERGROUND_MAXDISTANCE_XY 1000.0
#define UNDERGROUND_MAXDISTANCE_Z 500.0

#define BOSS_BAHAMUT_CLASSNAME "z4e_boss"
#define BOSS_BAHAMUT_HEALTH 6666.0
#define BOSS_BAHAMUT_HEALTH2 2333.0
#define BOSS_BAHAMUT_MODEL "models/ffvii/bahamut.mdl"
#define BOSS_BAHAMUT_SOUND "z4e/ffvii/bahamut.wav"
new const Float:BOSS_BAHAMUT_MINS[3] = {-50.0 , -50.0 , -150.0}
new const Float:BOSS_BAHAMUT_MAXS[3] = {50.0 , 50.0 , 150.0}
new const Float:BOSS_BAHAMUT_ORIGIN[3] = {450.0, 2000.0, -2700.0}
new const Float:BOSS_BAHAMUT_ANGLES[3] = {0.0, 90.0, 0.0}
new const Float:BOSS_BAHAMUT_ORIGIN_ROUTE_LOW[3] = {211.0, 1400.0, -2660.0}
new const Float:BOSS_BAHAMUT_AVELOCITY_ROUTE[3] = {0.0, -45.0, 0.0}

new const Float:BOSS_BAHAMUT_ORIGIN2[3] = {-3490.0, 80.0, 900.0}
new const Float:BOSS_BAHAMUT_ANGLES2[3] = {0.0, 0.0, 0.0}

#define BAHAMUT_GRAVITY_CLASSNAME "z4e_bahamut_gravity"

#define BOSS_SEPH_CLASSNAME "z4e_boss"
#define BOSS_SEPH_HEALTH 200.0
#define BOSS_SEPH_MODEL "models/ffvii/seph.mdl"
new const Float:BOSS_SEPH_MINS[3] = {-16.0 , -16.0 , -48.0}
new const Float:BOSS_SEPH_MAXS[3] = {16.0 , 16.0 , 48.0}
new const Float:BOSS_SEPH_TRIGGER_MINS[3] = {-64.0 , -64.0 , -48.0}
new const Float:BOSS_SEPH_TRIGGER_MAXS[3] = {64.0 , 64.0 , 48.0}
new const Float:BOSS_SEPH_ORIGIN[3] = {-3500.0, 2332.0, 800.0}
new const Float:BOSS_SEPH_ORIGIN2[3] = {50.0, 899.0, -1434.0}
new const Float:BOSS_SEPH_ANGLES[3] = {0.0, -90.0, 0.0}
new const Float:BOSS_SEPH_ANGLES2[3] = {0.0, -90.0, 0.0}
new const Float:BOSS_SEPH_ANGLES_EXI[3] = {0.0, 90.0, 0.0}

#define BEAM_BLADE_MODEL "sprites/laserbeam.spr"
#define BEAM_BLADE_CLASSNAME "z4e_beam_blade"
new const Float:BEAM_BLADE_ORIGIN[3] = {-3358.0, 2388.0, 760.0} // 760.0
new const Float:BEAM_BLADE_ORIGIN2[3] = {-24.0, 941.0, -1480.0} // 760.0


#define BEAM_BLADE_ORIGIN_FIXZ1 random_float(0.0, 80.0)
#define BEAM_BLADE_ORIGIN_FIXZ2 random_float(40.0, 120.0)
#define BEAM_BLADE_BARRIER_Z 40.0
new const Float:BEAM_BLADE_VELOCITY[3] = {0.0, -10.0, 0.0}
new const Float:BEAM_BLADE_VELOCITY2[3] = {0.0, 10.0, 0.0}

new const Float:BEAM_BLADE_DIRECTION[3] = {-282.0, 0.0, 0.0}
new const Float:BEAM_BLADE_DIRECTION2[3] = {282.0, 0.0, 0.0}
new const SOUND_BLADE[] = "z4e/ffvii/bridge_down.wav"
new const SOUND_EXPLODE[] = "z4e/ffvii/ultima_explode.wav"
new const SOUND_SEPHISEEYOU[] = "z4e/ffvii/seph_iseeyou.wav"
new const SOUND_SEPHCHOSEN[] = "z4e/ffvii/seph_onlythechosen.wav"
new const SOUND_SEPHGOODBYE[] = "z4e/ffvii/seph_saygoodbye.wav"
new const SOUND_SEPHTOOLATE[] = "z4e/ffvii/seph_toolate.wav"
new const SOUND_SEPHSLOW[] = "z4e/ffvii/seph_slow.wav"
new const SOUND_SEPHKOW[] = "z4e/ffvii/vulcan.wav"

new const Float:ESCAPE_ORIGIN_MINS[3] = {-3617.0, 2422.0, 600.0 }
new const Float:ESCAPE_ORIGIN_MAXS[3] = {-3380.0, 2642.0, 900.0 }

new const Float:SEPH_EXI_ORIGIN_A[3] = {-3405.0, -101.0, 800.0}
new const Float:SEPH_EXI_ORIGIN_B[3] = {-3602.0, 166.0, 800.0}
new const Float:SEPH_EXI_ORIGIN_C[3] = {-3405.0, 562.0, 800.0}
new const Float:SEPH_EXI_ORIGIN_D[3] = {-3602.0, 1014.0, 800.0}
new const Float:SEPH_EXI_ORIGIN_E[3] = {-3405.0, 1290.0, 800.0}
new const Float:SEPH_EXI_ORIGIN_F[3] = {-3602.0, 1530.0, 800.0}
new const Float:SEPH_EXI_ORIGIN_G[3] = {-3405.0, 1827.0, 800.0}
new const Float:SEPH_EXI_ORIGIN_H[3] = {-3602.0, 2101.0, 800.0}
new const Float:SEPH_EXI_ORIGIN_I[3] = {-3503.0, 2333.0, 800.0}

enum _:MAX_DIFF
{
	DIFF_NORMAL = 0,
	DIFF_HARD,
	DIFF_EXTREMEI, 
	DIFF_EXTREMEII
} new g_iDifficulty = DIFF_EXTREMEII;

enum _:MAX_BGMTYPE
{
	BGMTYPE_START,
	BGMTYPE_DOOR4_ENTRANCE,
	BGMTYPE_BOSS1_TRIGGER,
	BGMTYPE_TEMPEST,
	BGMTYPE_BOSS2_DOOR5,
	BGMTYPE_VICTORY
}

new const SOUND_BGM[MAX_DIFF][MAX_BGMTYPE][] = {
	{ // NORMAL
		"z4e/ffvii/waste.mp3", // start
		"z4e/ffvii/battleinthe.mp3", // door4
		"z4e/ffvii/jenova.mp3",  // boss1
		"",
		"",  // boss2
		"z4e/ffvii/victory.mp3"
	},
	{ // HARD
		"z4e/ffvii/blackwater.mp3", // start
		"z4e/ffvii/divinity.mp3", // door4
		"",
		"",  // boss1
		"z4e/ffvii/winged3.mp3",  // boss2
		"z4e/ffvii/victory.mp3"
	},
	{// EX1
		"z4e/ffvii/voodoo.mp3", // start
		"z4e/ffvii/pendulum_1.mp3", // door4
		"z4e/ffvii/pendulum_ot1.mp3",  // boss1
		"",  // tempest
		"z4e/ffvii/pendulum_ot2.mp3",  // boss2
		"z4e/ffvii/pendulum_ot3.mp3"
	},
	{ // EX2
		"z4e/ffvii/bloodsugar.mp3", // start
		"z4e/ffvii/thefountain.mp3", // door4
		"z4e/ffvii/selfvsself.mp3",  // boss1
		"z4e/ffvii/tempest.mp3",  // tempest
		"",  // boss2
		"z4e/ffvii/victory.mp3"
	}
}



new const EARTH_BARRIER_MODEL[] = "models/ffvii/earth.mdl"
new const EARTH_BARRIER_CLASSNAME[] = "z4e_earth_barrier"

new const FIRE_MODEL[] = "sprites/flame1.spr"

#define TASK_TIMER 523423
#define TASK_GAMEPLAY 1342534
#define TASK_TEMPESTBGM 789489
#define TASK_BUGPUNISH 589759
#define TASK_EXISEPH 159753

enum
{
	MAPSTATUS_NONE,
	MAPSTATUS_CHECKING,
	MAPSTATUS_WAITING,
	MAPSTATUS_BAHAMUT_ATTACKING,
	MAPSTATUS_BAHAMUT_RUN,
	MAPSTATUS_SETTINGOFF,
	MAPSTATUS_SEPH_ATTACKING,
	MAPSTATUS_SEPH_KILLED,
	MAPSTATUS_ESCAPEZONE
}

// OFFSET
// CBsePlayer
stock m_flVelocityModifier = 108
// CBaseToggle
stock m_toggle_state = 41 // TOGGLE_STATE(int?)
// CBreakable
#define OFFSET_LINUX_BREAKABLE 4
stock m_Material = 36 // int (+4)

// FROM util.h
#define VEC_DUCK_HULL_MIN Float:{-16.0, -16.0, -18.0}
#define VEC_DUCK_HULL_MAX Float:{16.0, 16.0, 32.0}
#define VEC_DUCK_VIEW Float:{0.0, 0.0, 12.0}

// FROM util.h
enum
{
	TS_AT_TOP, // 激发态
	TS_AT_BOTTOM, // 初始状态
	TS_GOING_UP, // 从初始状态到激发态
	TS_GOING_DOWN // 从激发态到初始状态
}

enum 
{ 
	matGlass = 0, 
	matWood, 
	matMetal, 
	matFlesh, 
	matCinderBlock, 
	matCeilingTile, 
	matComputer, 
	matUnbreakableGlass, 
	matRocks, 
	matNone, 
	matLastMaterial 
}

enum _:TOTAL_BAHAMUT_SKILL
{
	BAHAMUT_SKILL_NONE,
	BAHAMUT_SKILL_FIRE,
	BAHAMUT_SKILL_ICE,
	BAHAMUT_SKILL_EARTH,
	BAHAMUT_SKILL_WIND,
	BAHAMUT_SKILL_HEAL,
	BAHAMUT_SKILL_ULTIMA,
	BAHAMUT_SKILL_GRAVITY,
	BAHAMUT_SKILL_ELECTRIC,
}

enum _:TOTAL_ELEMENT
{
	ELEMENT_FIRE,
	ELEMENT_ICE,
	ELEMENT_EARTH,
	ELEMENT_WIND,
	ELEMENT_ULTIMA,
	ELEMENT_HEAL,
	ELEMENT_GRAVITY,
	ELEMENT_ELECTRIC
}

new const ELEMENT_NAME[TOTAL_ELEMENT][] = { "火","冰","土","风","终极","治疗","黑洞", "电" }
new const ELEMENT_DESC[TOTAL_ELEMENT][] = { 
	"烧死附近的僵尸",
	"冰冻附近的僵尸",
	"在面前放堆土墙",
	"吹飞面前的僵尸",
	"20秒后干掉附近所有僵尸",
	"给附近人类补血",
	"吸引附近的僵尸",
	"电击附近的僵尸"
}
new const Float:ELEMENT_COLOR[TOTAL_ELEMENT][] = {
	{250.0,50.0,50.0},
	{42.0,112.0,255.0},
	{250.0,250.0,50.0},
	{250.0,250.0,250.0},
	{75.0,75.0,75.0},
	{50.0,250.0,50.0},
	{250.0,50.0,250.0},
	{50.0,250.0,250.0}
}
new const ELEMENT_SOUND[TOTAL_ELEMENT][] = { 
	"zombie_plague/grenade_explode.wav",
	"warcraft3/impalehit.wav",
	"z4e/ffvii/earth.wav",
	"z4e/ffvii/wind.wav",
	"z4e/ffvii/ultima_explode.wav",
	"z4e/ffvii/heal.wav",
	"z4e/ffvii/gravity.wav",
	"weapons/coilmg_exp1.wav"
}
new const ELEMENT_MODEL[] = "sprites/z4e/z4e_element.spr"
new const ELEMENT_CLASSNAME[] = "z4e_element"

new const ELEMENT_EARTH_MODEL[] = "models/ffvii/earth.mdl"
new const ELEMENT_EARTH_CLASSNAME[] = "z4e_element_earth"

new const ELEMENT_WIND_MODEL[] = "sprites/ef_aircyclone.spr"
new const ELEMENT_WIND_TORNADO_MODEL[] = "models/ef_hurricane2.mdl"
new const ELEMENT_WIND_SOUND[] = "weapons/airburster_shoot.wav"
new const ELEMENT_WIND_CLASSNAME[] = "z4e_element_wind"

new const ELEMENT_GRAVITY_MODEL[] = "sprites/ef_teleportzombie.spr"
new const ELEMENT_GRAVITY_CLASSNAME[] = "z4e_element_gravity"


new g_bitsButtonUsed, g_iMapStatus, g_bSephKilled
//new g_pBossEntity
new g_pBahamut, g_pSeph
new m_iBlood[2], g_iSprFire, g_iSprBeam, g_iModelTornado, g_iModelElevatorGibs
new g_iSprExplo, g_iSprExplo2
new gmsgScreenFade, gmsgScreenShake


#define TASK_ELEMENT_USE 2333
new g_pElementAttached[33]
new g_pElementEarth
new gmsgBarTime

new const Float:ELEMENT_SPAWNPOINT[][3] = {
	// 普通元素 0~15
	{199.0,-2301.0, 3449.0}, // 1号卡车
	{773.0,773.0, 3210.0}, // 桥底
	{-748.8,581.6, 3465.0}, // 屋顶（误
	{120.6,1644.7, 3551.0}, // 桥头
	{1225.8,865.6, 3290.0}, // bunker
	{2256.0,-893.4, 3721.0}, // 出生地屋顶
	{1871.0,764.3, 3649.0}, // 室内房间
	{1997.0,1304.3, 3481.0}, // 室内客厅
	{740.0,2244.0, 3576.0}, // 仓库箱子
	{-3360.0,2364.0, 787.0}, // 终点门口
	{-1661.0,79.0, 625.0}, // 大桥桥底
	{500.0,-45.4, 787.0}, // 电梯门口
	{800.3,-278.0, -316.9}, // 电梯下层左侧
	{373.0,80.4, -870.0}, // 魔光炉楼梯二层
	{66.0,48.0, -1434.0}, // 楼梯底下
	{-13.0,1350.0, -1698.0}, // 横杆
	
	// 土元素 16~17
	{-250.0,2484.7, 3715.0}, // 仓库第二个入口二层
	{2555.0,3082.7, 3715.0}, // 仓库出口前面的二层
	
	// 终极元素 18~20
	{-698.0,1825.6, 3756.0}, // 电梯出口圆柱平台
	{-20.0,1742.7, -2030.0}, // 桥头那边进去很麻烦的那个房间
	{446.0,3571.6, -2771.0} // 魔光炉后面（ex2专用）
}

public plugin_precache()
{
	new szMap[32];
	get_mapname(szMap, 31)
	if(!equali(szMap, "ze_FFVII_Mako_Reactor_v1_1"))
	{
		pause("a")
		return;
	}
	precache_model(BOSS_BAHAMUT_MODEL)
	precache_model(BOSS_SEPH_MODEL)
	precache_sound(BOSS_BAHAMUT_SOUND)
	precache_model(BEAM_BLADE_MODEL)
	precache_model(EARTH_BARRIER_MODEL)
	precache_sound(SOUND_BLADE)
	precache_sound(SOUND_EXPLODE)
	precache_sound(SOUND_SEPHCHOSEN)
	precache_sound(SOUND_SEPHISEEYOU)
	precache_sound(SOUND_SEPHTOOLATE)
	precache_sound(SOUND_SEPHGOODBYE)
	precache_sound(SOUND_SEPHSLOW)
	precache_model(ELEMENT_MODEL)
	precache_model(ELEMENT_EARTH_MODEL)
	precache_model(ELEMENT_GRAVITY_MODEL)
	precache_model(ELEMENT_WIND_MODEL)
	precache_sound(ELEMENT_WIND_SOUND)
	
	for(new i = 0; i < sizeof(SOUND_BGM); i++)
	{
		for(new j = 0; j < sizeof(SOUND_BGM[]); j++)
		{
			if(!SOUND_BGM[i][j][0])
				continue;
			new szBuffer[64]
			format(szBuffer, charsmax(szBuffer), "sound/%s", SOUND_BGM[i][j])
			engfunc(EngFunc_PrecacheGeneric, szBuffer)
		}
		
	}
	
	for(new i = 0; i < sizeof(ELEMENT_SOUND); i++)
	{
		engfunc(EngFunc_PrecacheSound, ELEMENT_SOUND[i])
	}
	
	m_iBlood[0] = precache_model("sprites/blood.spr")
	m_iBlood[1] = precache_model("sprites/bloodspray.spr")
	
	g_iSprFire = precache_model(FIRE_MODEL)
	g_iSprBeam =  engfunc(EngFunc_PrecacheModel, "sprites/lgtning.spr")  //"sprites/laserbeam.spr"
	g_iModelTornado = precache_model(ELEMENT_WIND_TORNADO_MODEL)
	g_iModelElevatorGibs = precache_model("models/ceilinggibs.mdl")
	g_iSprExplo = engfunc(EngFunc_PrecacheModel, "sprites/fexplo.spr")
	g_iSprExplo2 = engfunc(EngFunc_PrecacheModel, "sprites/eexplo.spr")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_PlayerPreThink, "fw_Player_PreThink")
	register_forward(FM_PlayerPostThink, "fw_Player_PostThink")
	
	RegisterHam(Ham_Spawn, "func_wall", "HamF_FuncWall_Spawn")
	RegisterHam(Ham_Spawn, "func_door", "HamF_FuncDoor_Spawn")
	RegisterHam(Ham_Use, "func_door", "HamF_FuncDoor_Use")
	RegisterHam(Ham_Use, "func_button", "HamF_FuncButton_Use")
	RegisterHam(Ham_Touch, "trigger_teleport", "HamF_TriggerTeleport_Touch")
	RegisterHam(Ham_Touch, "func_breakable", "HamF_FuncBreakable_Touch")
	RegisterHam(Ham_Touch, "func_door", "HamF_FuncDoor_Touch")
	
	RegisterHam(Ham_Think, "beam", "HamF_BeamBlade_Think")
	
	RegisterHam(Ham_Think, "info_target", "HamF_Boss_Think")
	RegisterHam(Ham_Touch, "info_target", "HamF_Boss_Touch")
	RegisterHam(Ham_TraceAttack, "info_target", "HamF_Boss_TraceAttack")
	RegisterHam(Ham_Killed, "info_target", "HamF_Boss_Killed")
	
	RegisterHam(Ham_TakeDamage, "info_target", "HamF_Boss_TakeDamage")
	RegisterHam(Ham_TakeDamage, "player", "HamF_Player_TakeDamage")
	
	RegisterHam(Ham_Think, "info_target", "HamF_Element_Think")
	RegisterHam(Ham_Touch, "info_target", "HamF_Element_Touch")
	RegisterHam(Ham_Think, "info_target", "HamF_ElementWind_Think")
	RegisterHam(Ham_Touch, "info_target", "HamF_ElementWind_Touch")
	RegisterHam(Ham_Think, "func_breakable", "HamF_ElementEarth_Think")
	RegisterHam(Ham_Think, "env_sprite", "HamF_ElementGravity_Think")
	RegisterHam(Ham_Think, "env_sprite", "HamF_BahamutGravity_Think")
	
	set_task(1.0, "Task_Timer", TASK_TIMER, _, _, "b");
	
	gmsgScreenFade = get_user_msgid("ScreenFade")
	gmsgScreenShake = get_user_msgid("ScreenShake")
	gmsgBarTime = get_user_msgid("BarTime")
	
	register_clcmd("goto" , "CMD_GOTO");
	register_clcmd("goto2" , "CMD_GOTO2");
	register_clcmd("goto3" , "CMD_GOTO3");
	register_clcmd("beam" , "CMD_Beam");
	
}

public CMD_GOTO(id)
{
	set_pev(id, pev_origin, SEPH_EXI_ORIGIN_A);
}

public CMD_GOTO2(id)
{
	set_pev(id, pev_origin, ELEMENT_SPAWNPOINT[20]);
	
}

public CMD_GOTO3(id)
{
	set_pev(id, pev_origin, ELEMENT_SPAWNPOINT[11]);
	
}

public CMD_Beam()
{
	BeamBladeCreate()
}

public plugin_cfg()
{
	z4e_fw_gameplay_round_new();
}

public z4e_fw_api_bot_registerham(id)
{
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_Player_TakeDamage")
}
/*
public x_fw_api_semiclip(id, iEntity)
{
	if(!g_pElementEarth)
		return PLUGIN_CONTINUE;
	
	if(!BitsIsPlayer(id) && !BitsIsPlayer(iEntity))
		return PLUGIN_CONTINUE;
	
	if(id == g_pElementEarth)
	{
		if(!z4e_team_get_user_zombie(iEntity))
			return PLUGIN_HANDLED;
	}
	if(iEntity == g_pElementEarth)
	{
		if(!z4e_team_get_user_zombie(id))
			return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}
*/

public fw_Player_PreThink(id)
{
	// set semiclip to human
	if(pev_valid(g_pElementEarth) && !z4e_team_get_user_zombie(id))
	{
		new groupinfo = pev(g_pElementEarth, pev_groupinfo);
		BitsSet(groupinfo, id);
		set_pev(g_pElementEarth, pev_groupinfo, groupinfo);
	}
}

public fw_Player_PostThink(id)
{
	// reset semiclip
	set_pev(g_pElementEarth, pev_groupinfo, 0);
}

public z4e_fw_zombie_originate_post(id, iZombieCount)
{
	set_pev(id, pev_origin, ZOMBIESPAWN_ORIGIN)
	z4e_freeze_set(id, 0.1, 0)
}

public z4e_fw_zombie_respawn_post(id)
{
	if(g_iMapStatus >= MAPSTATUS_BAHAMUT_RUN) 
		set_pev(id, pev_origin, ZOMBIESPAWN_ELECTRIC)
}

public z4e_fw_gameplay_round_new()
{
	g_bitsButtonUsed = 0
	g_iMapStatus = MAPSTATUS_NONE
	remove_task(TASK_GAMEPLAY)
	remove_task(TASK_TEMPESTBGM)
	remove_task(TASK_EXISEPH)
	new pEntity
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
	{
		ExecuteHamB(Ham_Spawn, pEntity)
	}
	
	fm_remove_entity_name(BOSS_BAHAMUT_CLASSNAME)
	fm_remove_entity_name(BOSS_SEPH_CLASSNAME)
	fm_remove_entity_name(ELEMENT_EARTH_CLASSNAME)
	fm_remove_entity_name("z4e_earth_barrier")
	g_pElementEarth = 0;
	g_pBahamut = 0;
	g_pSeph = 0;
	
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_tracktrain"))))
	{
		ExecuteHamB(Ham_Spawn, pEntity)
		//client_print(0, print_chat, "火车%d 已刷新", pEntity)
	}
	
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
	{
		if(pev(pEntity, pev_modelindex) != MODELINDEX_DOOR3_BOXWALL && pev(pEntity, pev_modelindex) != MODELINDEX_DOOR3_TOPWALL)
			continue;
		
		if(g_iDifficulty >= DIFF_HARD)
		{
			set_pev(pEntity, pev_solid, SOLID_NOT);
			set_pev(pEntity, pev_effects, EF_NODRAW);
		}
		else
		{
			set_pev(pEntity, pev_solid, SOLID_BSP);
			set_pev(pEntity, pev_effects, 0);
		}
	}
	
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
	{
		if(pev(pEntity, pev_modelindex) == MODELINDEX_DOOR6_ELEVATOR_DOWN)
		{
			set_pev(pEntity, pev_effects, 0)
			set_pev(pEntity, pev_solid, SOLID_BSP)
		}
	}
	
	for(new i;i<33;i++)
		g_pElementAttached[i] = 0
	
	if(!BitsGet(z4e_gameplay_bits_get_status(), Z4E_GAMESTATUS_GAMESTARTED))
	{
		z4e_fw_gameplay_plague_post()
	}
		
	fm_remove_entity_name(ELEMENT_CLASSNAME)
	
	new bitsAvailable = (1<<sizeof(ELEMENT_SPAWNPOINT)) - 1
	for(new iElementType;iElementType<TOTAL_ELEMENT;iElementType++)
	{
		new iSpawnPoint
		new bitsAvailable2 = bitsAvailable
		do
		{
			iSpawnPoint = BitsGetRandom(bitsAvailable)
			if(iSpawnPoint < 0)
			{
				break;
			}
			
			BitsUnSet(bitsAvailable2, iSpawnPoint);
		} while(!CanElementSpawn(iElementType, iSpawnPoint, ELEMENT_SPAWNPOINT[iSpawnPoint]));
		
		ElementSpawn(iElementType, iSpawnPoint);
		BitsUnSet(bitsAvailable, iSpawnPoint);
	}
		
}

public z4e_fw_gameplay_round_start()
{
	PlaySound(0, SOUND_BGM[g_iDifficulty][BGMTYPE_START], 1)
	
	z4e_alarm_push(_, "** 地图: 最终幻想7-魔光炉 ** 文本&插件: 小白白&鬼鬼 **", "难度：*****", "", { 50,250,50 }, 2.0);
	
	if(g_iDifficulty == DIFF_EXTREMEII) 
		z4e_alarm_push(_, "** 当前关卡: EXTREME II (老司机) **", "", "", { 50,250,50 }, 2.0);
	else if(g_iDifficulty == DIFF_EXTREMEI) 
		z4e_alarm_push(_, "** 当前关卡: EXTREME I (大佬) **", "", "", { 50,250,50 }, 2.0);
	else if(g_iDifficulty == DIFF_HARD) 
		z4e_alarm_push(_, "** 当前关卡: HARD (困难) **", "", "", { 50,250,50 }, 2.0);
	else if(g_iDifficulty == DIFF_NORMAL) 
		z4e_alarm_push(_, "** 当前关卡: NORMAL (萌新) **", "", "", { 50,250,50 }, 2.0);
}

public z4e_fw_gameplay_plague_post()
{
	new pEntity
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
	{
		if(pev(pEntity, pev_modelindex) != MODELINDEX_WALL_SPAWN)
			continue;
		set_pev(pEntity, pev_solid, SOLID_NOT)
		set_pev(pEntity, pev_effects, EF_NODRAW)
	}
}

public z4e_fw_team_spawn_post(id)
{
	if(g_iMapStatus >= MAPSTATUS_BAHAMUT_ATTACKING && g_iMapStatus <= MAPSTATUS_SETTINGOFF)
		set_pev(id, pev_origin, UNDERGROUND_ORIGIN_CAGE)
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!pev_valid(g_pElementAttached[id]))
		return;
	if(pev(g_pElementAttached[id], pev_iuser2))
		return;
	static bitsCurButton; bitsCurButton = get_uc(uc_handle, UC_Buttons)
	static bitsOldButton; bitsOldButton = pev(id, pev_oldbuttons)
	if((bitsCurButton & ~bitsOldButton & IN_USE))
	{ // Press E
		set_task(1.0, "Task_Element_Use", TASK_ELEMENT_USE + id)
		
		message_begin(MSG_ONE, gmsgBarTime, _, id)
		write_short(1)
		message_end()
	}
	else if((~bitsCurButton & bitsOldButton & IN_USE))
	{ // Release E
		remove_task(TASK_ELEMENT_USE + id)
		message_begin(MSG_ONE, gmsgBarTime, _, id)
		write_short(0)
		message_end()
	}
}


public CanElementSpawn(iType, iSpawnPoint, Float:vecOrigin[3])
{
	//if(iType == ELEMENT_ULTIMA && vecOrigin[2] > UNDERGROUND_BELOW)
	//	return 0
	if(iType == ELEMENT_ULTIMA || iSpawnPoint >= 18)
	{
		if(iType == ELEMENT_ULTIMA && iSpawnPoint >= 18)
		{
			if(g_iDifficulty == DIFF_EXTREMEII)
			{
				if(iSpawnPoint == 20)
				{
					return 1;
				}
				else
				{
					return 0;
				}
			}
			else
			{
				return 1;
			}
			
		}
		else
			return 0
	}
	
	if(iType == ELEMENT_EARTH || iSpawnPoint == 16 || iSpawnPoint == 17)
	{
		if(iType == ELEMENT_EARTH && (iSpawnPoint == 16 || iSpawnPoint == 17))
			return 1
		else
			return 0
	}
	
	return 1
}

public Task_Element_Use(taskid)
{
	new id = taskid - TASK_ELEMENT_USE
	if(!pev_valid(g_pElementAttached[id]))
		return;
	new iType = pev(g_pElementAttached[id], pev_iuser1)
	switch(iType)
	{
		case ELEMENT_FIRE:
		{
			if(g_iDifficulty == DIFF_NORMAL)
			{
				ElementFire_Shoot(id)
				set_pev(g_pElementAttached[id], pev_fuser2, get_gametime() + 0.1)
			}
			else
			{
				set_pev(g_pElementAttached[id], pev_fuser2, get_gametime() + 5.0)
			}
			
			set_pev(g_pElementAttached[id], pev_fuser4, get_gametime() + 60.0)
			emit_sound(g_pElementAttached[id], CHAN_WEAPON, ELEMENT_SOUND[iType], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case ELEMENT_ICE:
		{
			ElementIce_Spawn(id)
			set_pev(g_pElementAttached[id], pev_fuser2, get_gametime() + 0.1)
			set_pev(g_pElementAttached[id], pev_fuser4, get_gametime() + 60.0)
			emit_sound(g_pElementAttached[id], CHAN_WEAPON, ELEMENT_SOUND[iType], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case ELEMENT_EARTH:
		{
			ElementEarthSpawn(id)
			set_pev(g_pElementAttached[id], pev_fuser2, get_gametime() + 0.1)
			set_pev(g_pElementAttached[id], pev_fuser4, get_gametime() + 60.0)
			emit_sound(g_pElementAttached[id], CHAN_WEAPON, ELEMENT_SOUND[iType], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case ELEMENT_WIND:
		{
			if(g_iDifficulty == DIFF_EXTREMEII)
			{
				ElementWind_TornadoEffect(id, 7.0)
				set_pev(g_pElementAttached[id], pev_fuser2, get_gametime() + 7.0)
			}
			else
				set_pev(g_pElementAttached[id], pev_fuser2, get_gametime() + 5.0)
			
			set_pev(g_pElementAttached[id], pev_fuser4, get_gametime() + 55.0)
			emit_sound(g_pElementAttached[id], CHAN_WEAPON, ELEMENT_SOUND[iType], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case ELEMENT_ULTIMA:
		{
			set_pev(g_pElementAttached[id], pev_fuser2, get_gametime() + 20.0)
			//set_pev(g_pElementAttached[id], pev_fuser3, get_gametime())
			set_pev(g_pElementAttached[id], pev_fuser4, get_gametime() + 60.0)
		}
		case ELEMENT_HEAL:
		{
			set_pev(g_pElementAttached[id], pev_fuser2, get_gametime() + 5.0)
			set_pev(g_pElementAttached[id], pev_fuser4, get_gametime() + 60.0)
			emit_sound(g_pElementAttached[id], CHAN_WEAPON, ELEMENT_SOUND[iType], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case ELEMENT_GRAVITY:
		{
			ElementGravitySpawn(id)
			set_pev(g_pElementAttached[id], pev_fuser2, get_gametime() + 0.1)
			set_pev(g_pElementAttached[id], pev_fuser4, get_gametime() + 60.0)
			emit_sound(g_pElementAttached[id], CHAN_WEAPON, ELEMENT_SOUND[iType], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case ELEMENT_ELECTRIC:
		{
			set_pev(g_pElementAttached[id], pev_fuser2, get_gametime() + 5.0)
			set_pev(g_pElementAttached[id], pev_fuser4, get_gametime() + 60.0)
		}
	}
	
	set_pev(g_pElementAttached[id], pev_renderfx, kRenderFxStrobeFaster)
	
	new Float:vecOrigin[3]
	pev(g_pElementAttached[id], pev_origin, vecOrigin)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_KILLBEAM)
	write_short(g_pElementAttached[id])
	message_end()
	
	//fm_remove_entity(g_pElementAttached[id])
	//g_pElementAttached[id] = 0
	set_pev(g_pElementAttached[id], pev_iuser2, 1)
	
	LightEffect(vecOrigin, floatround(ELEMENT_COLOR[iType][0]), floatround(ELEMENT_COLOR[iType][1]), floatround(ELEMENT_COLOR[iType][2]))
	
}

public HamF_Element_Touch(iEntity, id)
{
	if(!pev_valid(iEntity) || !pev_valid(id))
		return HAM_IGNORED;
	
	static szClassname[33]; pev(iEntity, pev_classname, szClassname, charsmax(szClassname))
	if(strcmp(szClassname, ELEMENT_CLASSNAME))
		return HAM_IGNORED;
	if(!is_user_alive(id) || z4e_team_get_user_zombie(id))
		return HAM_IGNORED;
		
	ElementAttach(iEntity, id)
	
	return HAM_IGNORED;
}

ElementAttach(iEntity, id)
{
	if(pev_valid(g_pElementAttached[id]))
	{
		ElementDetach(g_pElementAttached[id])
	}
	g_pElementAttached[id] = iEntity
	
	set_pev(iEntity, pev_owner, id)
	set_pev(iEntity, pev_solid, SOLID_NOT)
	set_pev(iEntity, pev_movetype, MOVETYPE_NOCLIP)
	set_pev(iEntity, pev_renderfx, kRenderFxPulseSlow)
	
	new iType = pev(iEntity, pev_iuser1)
	
	if(!pev(iEntity, pev_iuser2))
		ElementBeamUpdate(iEntity)
	
	set_pev(iEntity, pev_nextthink, get_gametime())
	
	new szMessage[128]
	format(szMessage, charsmax(szMessage), "有玩家装备了%s元素", ELEMENT_NAME[iType])
	new iColor[3]
	iColor[0] = floatround(ELEMENT_COLOR[iType][0])
	iColor[1] = floatround(ELEMENT_COLOR[iType][1])
	iColor[2] = floatround(ELEMENT_COLOR[iType][2])
	
	z4e_alarm_push(_, szMessage, ELEMENT_DESC[iType], "", iColor, 2.0)
	
}

ElementBeamUpdate(iEntity)
{
	new iType = pev(iEntity, pev_iuser1)
	new id = pev(iEntity, pev_owner)
	new Float:vecOrigin[3]
	pev(id, pev_origin, vecOrigin)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BEAMENTS)
	write_short(id | 0x2000) // start entity
	write_short(iEntity) // end entity
	write_short(g_iSprBeam) // sprite index
	write_byte(0) // starting frame
	write_byte(15) // frame rate in 0.1's
	write_byte(127) // life in 0.1's
	write_byte(10) // line width in 0.1's
	write_byte(10) // noise amplitude in 0.01's
	write_byte(floatround(ELEMENT_COLOR[iType][0])) // red
	write_byte(floatround(ELEMENT_COLOR[iType][1])) // green
	write_byte(floatround(ELEMENT_COLOR[iType][2])) // blue
	write_byte(150) // brightness
	write_byte(15) // scroll speed in 0.1's
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BEAMENTS)
	write_short(id | 0x1000) // start entity
	write_short(iEntity) // end entity
	write_short(g_iSprBeam) // sprite index
	write_byte(0) // starting frame
	write_byte(15) // frame rate in 0.1's
	write_byte(127) // life in 0.1's
	write_byte(10) // line width in 0.1's
	write_byte(10) // noise amplitude in 0.01's
	write_byte(floatround(ELEMENT_COLOR[iType][0])) // red
	write_byte(floatround(ELEMENT_COLOR[iType][1])) // green
	write_byte(floatround(ELEMENT_COLOR[iType][2])) // blue
	write_byte(150) // brightness
	write_byte(15) // scroll speed in 0.1's
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BEAMENTS)
	write_short(id) // start entity
	write_short(iEntity) // end entity
	write_short(g_iSprBeam) // sprite index
	write_byte(0) // starting frame
	write_byte(10) // frame rate in 0.1's
	write_byte(127) // life in 0.1's
	write_byte(80) // line width in 0.1's
	write_byte(10) // noise amplitude in 0.01's
	write_byte(floatround(ELEMENT_COLOR[iType][0])) // red
	write_byte(floatround(ELEMENT_COLOR[iType][1])) // green
	write_byte(floatround(ELEMENT_COLOR[iType][2])) // blue
	write_byte(180) // brightness
	write_byte(10) // scroll speed in 0.1's
	message_end()
	
	set_pev(iEntity, pev_fuser1, get_gametime() + 6.0)
}

ElementReset(iEntity)
{
	//new id = pev(iEntity, pev_owner)
	
	set_pev(iEntity, pev_renderfx, kRenderFxPulseSlow)
	
	//new iType = pev(iEntity, pev_iuser1)
	
	ElementBeamUpdate(iEntity)
	
	set_pev(iEntity, pev_nextthink, get_gametime())
	set_pev(iEntity, pev_iuser2, 0)
	set_pev(iEntity, pev_fuser2, 0.0)
	set_pev(iEntity, pev_fuser3, 0.0)
	set_pev(iEntity, pev_fuser4, 0.0)
	/*
	new szName[32];
	get_user_name(id, szName, 31)
	
	new szMessage[128]
	format(szMessage, charsmax(szMessage), "%s 的 %s 元素已重新激活", szName, ELEMENT_NAME[iType])
	new iColor[3]
	iColor[0] = floatround(ELEMENT_COLOR[iType][0])
	iColor[1] = floatround(ELEMENT_COLOR[iType][1])
	iColor[2] = floatround(ELEMENT_COLOR[iType][2])
	
	z4e_alarm_push(_, szMessage, ELEMENT_DESC[iType], "", iColor, 2.0)
	*/
}

ElementDetach(iEntity)
{
	new id = pev(iEntity, pev_owner)
	g_pElementAttached[id] = 0
	
	if(!pev_valid(id))
	{
		fm_remove_entity(iEntity)
		return;
	}
	
	set_pev(iEntity, pev_owner, 0)
	set_pev(iEntity, pev_renderfx, kRenderFxPulseSlowWide)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_KILLBEAM)
	write_short(iEntity)
	message_end()
	
	new Float:vecOrigin[3]
	pev(id, pev_origin, vecOrigin)
	vecOrigin[2] += 16.0
	set_pev(iEntity, pev_origin, vecOrigin)
	set_pev(iEntity, pev_velocity, Float:{0.0,0.0,0.0})
	set_pev(iEntity, pev_nextthink, get_gametime() + 1.0)
}

ElementSpawn(iType, iSpawnPoint)
{
	
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(iEntity))
		return 0;

	set_pev(iEntity, pev_classname, ELEMENT_CLASSNAME);
	
	set_pev(iEntity, pev_solid, SOLID_TRIGGER)
	set_pev(iEntity, pev_movetype, MOVETYPE_PUSHSTEP)
	set_pev(iEntity, pev_iuser1, iType)
	
	engfunc(EngFunc_SetModel, iEntity, ELEMENT_MODEL)
	
	set_pev(iEntity, pev_mins, Float:{-16.0, -16.0, -16.0})
	set_pev(iEntity, pev_maxs, Float:{16.0, 16.0, 16.0})
	engfunc(EngFunc_SetOrigin, iEntity, ELEMENT_SPAWNPOINT[iSpawnPoint])
	set_pev(iEntity, pev_gravity, 800.0)
	
	set_pev(iEntity, pev_animtime, get_gametime())
	set_pev(iEntity, pev_framerate, 30.0)
	set_pev(iEntity, pev_spawnflags, SF_SPRITE_STARTON)
	set_pev(iEntity, pev_rendermode, kRenderTransAdd)
	set_pev(iEntity, pev_renderamt, 250.0)
	set_pev(iEntity, pev_renderfx, kRenderFxPulseSlowWide)
	set_pev(iEntity, pev_rendercolor, ELEMENT_COLOR[iType])
	set_pev(iEntity, pev_scale, 0.3)
	
	return iEntity;
}

ElementGravitySpawn(id)
{
	new Float:vecOrigin[3]; pev(id, pev_origin, vecOrigin)
	new Float:vecAngles[3]; pev(id, pev_angles, vecAngles)
	new Float:vecViewOfs[3]; pev(id, pev_view_ofs, vecViewOfs)
	
	vecAngles[0] = 0.0
	new Float:vecEnd[3]; pev(id, pev_angles, vecEnd)
	xs_vec_add(vecOrigin, vecViewOfs, vecOrigin)
	engfunc(EngFunc_MakeVectors, vecEnd)
	global_get(glb_v_forward, vecEnd)
	xs_vec_mul_scalar(vecEnd, 150.0, vecEnd)
	xs_vec_add(vecOrigin, vecEnd, vecEnd)
	
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
	set_pev(iEntity, pev_classname, ELEMENT_GRAVITY_CLASSNAME)
	
	set_pev(iEntity, pev_owner, id)
	
	set_pev(iEntity, pev_solid, SOLID_TRIGGER)
	set_pev(iEntity, pev_movetype, MOVETYPE_NONE)
	
	engfunc(EngFunc_SetModel, iEntity, ELEMENT_GRAVITY_MODEL)
	
	engfunc(EngFunc_SetOrigin, iEntity, vecEnd)
	
	set_pev(iEntity, pev_animtime, get_gametime())
	set_pev(iEntity, pev_framerate, 30.0)
	set_pev(iEntity, pev_spawnflags, SF_SPRITE_STARTON)
	set_pev(iEntity, pev_rendermode, kRenderTransAdd)
	set_pev(iEntity, pev_renderamt, 250.0)
	set_pev(iEntity, pev_scale, 0.3)
	
	set_pev(iEntity, pev_fuser1, get_gametime() + 5.0)	// time remove
	
	dllfunc(DLLFunc_Spawn, iEntity)
	
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.1);
	
	return iEntity;
}

ElementEarthSpawn(id)
{
	new Float:vecOrigin[3]; pev(id, pev_origin, vecOrigin)
	new Float:vecAngles[3]; pev(id, pev_angles, vecAngles)
	new Float:vecViewOfs[3]; pev(id, pev_view_ofs, vecViewOfs)
	
	vecAngles[0] = 0.0
	new Float:vecEnd[3]; pev(id, pev_angles, vecEnd)
	xs_vec_add(vecOrigin, vecViewOfs, vecOrigin)
	engfunc(EngFunc_MakeVectors, vecEnd)
	global_get(glb_v_forward, vecEnd)
	xs_vec_mul_scalar(vecEnd, 150.0, vecEnd)
	xs_vec_add(vecOrigin, vecEnd, vecEnd)
	
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_breakable"))
	set_pev(iEntity, pev_classname, ELEMENT_EARTH_CLASSNAME)
	
	engfunc(EngFunc_SetModel, iEntity, ELEMENT_EARTH_MODEL)
	set_pev(iEntity, pev_modelindex, engfunc(EngFunc_ModelIndex, ELEMENT_EARTH_MODEL))
	
	if(floatabs(vecAngles[1]) > 45.0 && floatabs(vecAngles[1]) < 135.0)
	{
		new Float:vecMins[3] = {-200.0, -50.0, -85.0}
		new Float:vecMaxs[3] = {200.0, 50.0, 85.0}
		engfunc(EngFunc_SetSize, iEntity, vecMins, vecMaxs)
		set_pev(iEntity, pev_angles, { 0.0, 90.0, 0.0})
	}
	else
	{
		new Float:vecMins[3] = {-50.0, -200.0, -85.0}
		new Float:vecMaxs[3] = {50.0, 200.0, 85.0}
		engfunc(EngFunc_SetSize, iEntity, vecMins, vecMaxs)
		set_pev(iEntity, pev_angles, { 0.0, 0.0, 0.0})
	}
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS)
	set_pev(iEntity, pev_solid, SOLID_SLIDEBOX)

	//vecEnd[2] += 100.0
	
	engfunc(EngFunc_SetOrigin, iEntity, vecEnd)
	
	set_pev(iEntity, pev_gravity, 0.0001)
	set_pev(iEntity, pev_gamestate, 0.0)
		
	set_pev(iEntity, pev_health, 5000.0)
	set_pev(iEntity, pev_takedamage, DAMAGE_YES)
	
	set_pev(iEntity, pev_nextthink, get_gametime() + 5.0)
	
	set_pdata_int(iEntity, m_Material, matWood, OFFSET_LINUX_BREAKABLE)
	
	g_pElementEarth = iEntity
}

public HamF_ElementEarth_Think(iEntity)
{
	if(!pev_valid(iEntity))
		return HAM_SUPERCEDE;
	static szClassname[33]; pev(iEntity, pev_classname, szClassname, charsmax(szClassname))
	if(strcmp(szClassname, ELEMENT_EARTH_CLASSNAME))
		return HAM_IGNORED;
		
	//ExecuteHamB(Ham_Killed, iEntity, iEntity, 0);
	fm_remove_entity(iEntity);
	if(g_pElementEarth == iEntity)
		g_pElementEarth = 0;
	return HAM_SUPERCEDE;
}

public HamF_Element_Think(iEntity)
{
	if(!pev_valid(iEntity))
		return HAM_SUPERCEDE;
	static szClassname[33]; pev(iEntity, pev_classname, szClassname, charsmax(szClassname))
	if(strcmp(szClassname, ELEMENT_CLASSNAME))
		return HAM_IGNORED;
		
	new id = pev(iEntity, pev_owner)
	if(!id)
	{
		set_pev(iEntity, pev_solid, SOLID_TRIGGER)
		set_pev(iEntity, pev_movetype, MOVETYPE_PUSHSTEP)
		return HAM_IGNORED;
	}
	
	if(!is_user_alive(id) || z4e_team_get_user_zombie(id))
	{
		ElementDetach(iEntity)
		return HAM_IGNORED;
	}
	
	if(pev(g_pElementAttached[id], pev_iuser2))
	{
		new Float:flTimeReset
		pev(iEntity, pev_fuser4, flTimeReset)
		if(get_gametime() > flTimeReset)
		{
			ElementReset(iEntity)
		}
		else if(pev(g_pElementAttached[id], pev_iuser2) == 1)
		{
			new Float:flTimeEnd
			pev(iEntity, pev_fuser2, flTimeEnd)
			if(get_gametime() > flTimeEnd)
			{
				new iType = pev(iEntity, pev_iuser1)
				if(iType == ELEMENT_ULTIMA)
				{
					ElementUltimaExplode(iEntity)
					//set_pev(iEntity, pev_fuser2, 0.0)
					fm_remove_entity(iEntity);
					return HAM_SUPERCEDE;
				}
				set_pev(g_pElementAttached[id], pev_iuser2, 2);
			}
			else
			{
				new Float:flNextSkillCheck
				pev(iEntity, pev_fuser3, flNextSkillCheck)
				
				if(get_gametime() > flNextSkillCheck)
				{
					new iType = pev(iEntity, pev_iuser1)
					switch(iType)
					{
						case ELEMENT_FIRE:
						{
							ElementFire_RadiusAttack(id)
							flNextSkillCheck = get_gametime() + 0.5
							set_pev(iEntity, pev_fuser3, flNextSkillCheck)
						}
						case ELEMENT_ICE:
						{
						}
						case ELEMENT_EARTH:
						{
						}
						case ELEMENT_WIND:
						{
							if(g_iDifficulty < DIFF_EXTREMEI)
								ElementWind_ShootDamage(id)
							else
								ElementWind_RadiusAttack(id)
							emit_sound(iEntity, CHAN_WEAPON, ELEMENT_WIND_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM)
							flNextSkillCheck = get_gametime() + 0.1
							set_pev(iEntity, pev_fuser3, flNextSkillCheck)
						}
						case ELEMENT_ULTIMA:
						{
							ElementUltima_Effect(iEntity)
							flNextSkillCheck = get_gametime() + 1.0
							set_pev(iEntity, pev_fuser3, flNextSkillCheck)
						}
						case ELEMENT_HEAL:
						{
							ElementHeal_RadiusHeal(id)
							flNextSkillCheck = get_gametime() + 0.5
							set_pev(iEntity, pev_fuser3, flNextSkillCheck)
						}
						case ELEMENT_ELECTRIC:
						{
							ElementElectric_RadiusAttack(id)
							emit_sound(g_pElementAttached[id], CHAN_WEAPON, ELEMENT_SOUND[iType], 1.0, ATTN_NORM, 0, PITCH_NORM)
							flNextSkillCheck = get_gametime() + 0.5
							set_pev(iEntity, pev_fuser3, flNextSkillCheck)
						}
					}
				}
			}
			
		}
		
	}
	else
	{
		new Float:flNextBeam
		pev(iEntity, pev_fuser1, flNextBeam)
		if(get_gametime() > flNextBeam)
		{
			ElementBeamUpdate(iEntity)
		}
	}
	
	static Float:vecOrigin[3], Float:vecForward[3]
	pev(iEntity, pev_origin, vecOrigin)
	
	static Float:vecSrc[3], Float: vecEnd[3]
	GetGunPosition(id, vecSrc)
	
	static origin[3];
	get_user_origin(id, origin, 3);
	IVecFVec(origin, vecEnd);
	
	static Float:vecVelocity2[3];
	pev(id, pev_velocity, vecVelocity2);
	
	xs_vec_sub(vecEnd, vecSrc, vecForward);
	xs_vec_mul_scalar(vecForward, 70.0 / xs_vec_len(vecForward), vecForward)
	vecForward[2] -= 20.0
	xs_vec_add(vecSrc, vecForward, vecEnd)
	
	static Float:vecDirection[3]
	xs_vec_sub(vecEnd, vecOrigin, vecDirection)
	if(xs_vec_len(vecDirection) > 25.0)
	{
		xs_vec_mul_scalar(vecDirection, 1000.0 / xs_vec_len(vecDirection), vecDirection)
		xs_vec_add(vecVelocity2, vecDirection, vecDirection);
		set_pev(iEntity, pev_velocity, vecDirection)
	}
	else
	{
		set_pev(iEntity, pev_velocity, vecVelocity2)
	}
	
	set_pev(iEntity, pev_frame, random_num(0, 1))
	
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.05)
	return HAM_IGNORED;
}

ElementIce_Spawn(id)
{
	new Float:vecOrigin[3]; 
	pev(id, pev_origin, vecOrigin)
	new pEntity = -1
	new Float:flRadius = g_iDifficulty >= DIFF_HARD ? 1000.0:675.0
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, flRadius)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || !z4e_team_get_user_zombie(pEntity))
			continue;
		if(g_iDifficulty >= DIFF_EXTREMEI)
			z4e_freeze_set(pEntity, 10.0, 1)
		else
			z4e_freeze_set(pEntity, 5.0, 1)
	}
	
	ExplodeEffect(vecOrigin, 0, 100, 200)
}

ElementHeal_RadiusHeal(id)
{
	new Float:vecOrigin[3]; 
	pev(id, pev_origin, vecOrigin)
	new Float:flRadius = g_iDifficulty >= DIFF_EXTREMEI ? 1000.0:675.0
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, flRadius)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || z4e_team_get_user_zombie(pEntity))
			continue;
		if(g_iDifficulty == DIFF_NORMAL)
			set_pev(pEntity, pev_health, 100.0)
		else if(g_iDifficulty == DIFF_HARD)
			set_pev(pEntity, pev_health, 150.0)
		else 
			set_pev(pEntity, pev_health, 255.0)
	}
	
	ExplodeEffect(vecOrigin, 50, 200, 50)
	LightEffect(vecOrigin, 50, 200, 50)
}

ElementElectric_RadiusAttack(id)
{
	if(!pev_valid(g_pElementAttached[id]))
		return;
	new Float:vecOrigin[3]; 
	pev(id, pev_origin, vecOrigin)
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, 675.0)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || !z4e_team_get_user_zombie(pEntity))
			continue;
		
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
		write_byte(TE_BEAMENTS)
		write_short(g_pElementAttached[id]) // start entity
		write_short(pEntity) // end entity
		write_short(g_iSprBeam) // sprite index
		write_byte(0) // starting frame
		write_byte(15) // frame rate in 0.1's
		write_byte(6) // life in 0.1's
		write_byte(30) // line width in 0.1's
		write_byte(10) // noise amplitude in 0.01's
		write_byte(floatround(ELEMENT_COLOR[ELEMENT_ELECTRIC][0])) // red
		write_byte(floatround(ELEMENT_COLOR[ELEMENT_ELECTRIC][1])) // green
		write_byte(floatround(ELEMENT_COLOR[ELEMENT_ELECTRIC][2])) // blue
		write_byte(150) // brightness
		write_byte(15) // scroll speed in 0.1's
		message_end()
		
		ExecuteHamB(Ham_TakeDamage, pEntity, g_pElementAttached[id], g_pElementAttached[id], 100.0, DMG_BULLET);
		set_pdata_float(pEntity, m_flVelocityModifier, 0.1)
	}
	
	ExplodeEffect(vecOrigin, 50, 200, 200)
	LightEffect(vecOrigin, 50, 200, 200)
}

ElementFire_Shoot(id)
{
	new Float:vecOrigin[3]; 
	pev(id, pev_origin, vecOrigin)
	new pEntity = -1
	new Float:flDistance = 675.0
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, flDistance)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || !z4e_team_get_user_zombie(pEntity))
			continue;
		
		new Float:vecEnd[3]; 
		pev(pEntity, pev_origin, vecEnd)
		
		if(fm_get_view_angle_diff(id, vecEnd) >= 45.0)
			continue;
		
		z4e_burn_set(pEntity, 5.0, 1)
	}
}

ElementFire_RadiusAttack(id)
{
	new Float:vecOrigin[3]; 
	pev(id, pev_origin, vecOrigin)
	new pEntity = -1
	new Float:flDistance = g_iDifficulty >= DIFF_EXTREMEI ? 1000.0:675.0
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, flDistance)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || !z4e_team_get_user_zombie(pEntity))
			continue;
		z4e_burn_set(pEntity, 5.0, 1)
	}
	
	ExplodeEffect(vecOrigin, 200, 50, 50)
	LightEffect(vecOrigin, 200, 50, 50)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_FIREFIELD) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0]+random_float(-5.0, 5.0))
	engfunc(EngFunc_WriteCoord, vecOrigin[1]+random_float(-5.0, 5.0))
	engfunc(EngFunc_WriteCoord, vecOrigin[2]-10.0)
	engfunc(EngFunc_WriteCoord, flDistance) //radius
	write_short(g_iSprFire) // sprite
	write_byte(random_num(20, 50)) // count
	write_byte(TEFIRE_FLAG_SOMEFLOAT|TEFIRE_FLAG_LOOP|TEFIRE_FLAG_PLANAR|32) // flags
	write_byte(15) // duration (in seconds) * 10
	message_end()
}

ElementWind_RadiusAttack(id)
{
	new Float:vecOrigin[3]; 
	pev(id, pev_origin, vecOrigin)
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, 675.0)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || !z4e_team_get_user_zombie(pEntity))
			continue;
		KnockBack_Set(pEntity, id, 800.0, 1000.0, 650.0, 500.0, 0.7);
	}
	
	//ExplodeEffect(vecOrigin, 200, 200, 200)
	//LightEffect(vecOrigin, 200, 200, 200)
}

ElementWind_TornadoEffect(id, Float:flTime)
{
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_PLAYERATTACHMENT)
	write_byte(id)
	write_coord(-15)// vertical offset
	write_short(g_iModelTornado) // model index
	write_short(floatround(flTime * 10.0 + 0.5)) // life * 10
	message_end()
}

ElementUltimaExplode(iEntity)
{
	new Float:vecOrigin[3]; 
	pev(iEntity, pev_origin, vecOrigin)
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, 675.0)) && pev_valid(pEntity))
	{
		//if(!is_user_alive(pEntity))
		//	continue;
		if(!is_user_connected(pEntity))
			continue;
		
		message_begin(MSG_ONE_UNRELIABLE, gmsgScreenFade, _, pEntity)
		write_short((1<<12)) // duration
		write_short((1<<12)) // hold time
		write_short((0x0000)) // fade type
		write_byte(50)
		write_byte(50)
		write_byte(50)
		write_byte(255) // alpha
		message_end()
		
		
		message_begin(MSG_ONE, gmsgScreenShake, _, pEntity)
		write_short((1<<12) * 10) // amplitude
		write_short((1<<12) * 10) // duration
		write_short((1<<12) * 10) // frequency
		message_end()
		
		if(z4e_team_get_user_zombie(pEntity))
		{
			user_kill(pEntity, 1);
		}
	}
	
	ExplodeEffect(vecOrigin, 50, 50, 50)
	LightEffect(vecOrigin, 50, 50, 50)
	
	emit_sound(iEntity, CHAN_WEAPON, ELEMENT_SOUND[ELEMENT_ULTIMA], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	if(g_iMapStatus == MAPSTATUS_SEPH_ATTACKING)
	{
		if(pev_valid(g_pBahamut))
			BahamutKilled2(g_pBahamut)
	}
}

ElementWind_ShootDamage(id)
{
	new ptr = create_tr2()
	new Float:vecSrc[3], Float: vecEnd[3]
	GetGunPosition(id, vecSrc)
	
	new Float:flRange = 500.0
	
	static Float:vecForward[3]
	global_get(glb_v_forward, vecForward)
	xs_vec_mul_scalar(vecForward, flRange, vecForward)
	xs_vec_add(vecSrc, vecForward, vecEnd)

	engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, id, ptr)

	new Float:flFraction
	get_tr2(ptr, TR_flFraction, flFraction)
	
	if (flFraction >= 1.0)
	{
		engfunc(EngFunc_TraceHull, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, HULL_HEAD, id, ptr)
		
		if (flFraction < 1.0)
		{
			new pHit = get_tr2(ptr, TR_pHit)
			if(!pHit || ExecuteHamB(Ham_IsBSPModel, pHit))
			{
				FindHullIntersection(vecSrc, ptr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, id)
				get_tr2(ptr, TR_vecEndPos, vecEnd)
			}
		}
	}
	
	get_tr2(ptr, TR_flFraction, flFraction)
	if (flFraction < 1.0)
	{
		new pEntity = get_tr2(ptr, TR_pHit)
		if(pEntity < 0) pEntity = 0
		
		if(pEntity && ExecuteHamB(Ham_IsBSPModel, pEntity))
		{
			OrpheuCall(OrpheuGetFunction("ClearMultiDamage"))
			ExecuteHamB(Ham_TraceAttack, pEntity, id, 32.0, vecForward, ptr, DMG_NEVERGIB | DMG_BULLET)
			OrpheuCall(OrpheuGetFunction("ApplyMultiDamage"), id, id)
		}

	}
	free_tr2(ptr)
	
	// 对玩家执行范围伤害
	new Float:vecEndZ = vecEnd[2]
	new pEntity
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecSrc, flRange)) != 0)
	{
		if(ExecuteHamB(Ham_IsBSPModel, pEntity))
			continue;
			
		pev(pEntity, pev_origin, vecEnd)
		
		vecEnd[2] = vecSrc[2] + (vecEndZ - vecSrc[2]) * (get_distance_f(vecSrc, vecEnd) / flRange)
		
		if(fm_get_view_angle_diff(id, vecEnd) >= 45.0)
			continue;
		
		engfunc(EngFunc_TraceLine, vecSrc, vecEnd, 0, id, ptr)
		get_tr2(ptr, TR_flFraction, flFraction)
		if (flFraction >= 1.0) 
		{
			engfunc(EngFunc_TraceHull, vecSrc, vecEnd, 0, HULL_HEAD, id, ptr)
			get_tr2(ptr, TR_flFraction, flFraction)
		}
		
		new pHit = get_tr2(ptr, TR_pHit)
		if(!pev_valid(pHit) || pHit != pEntity)
			continue;
		
		OrpheuCall(OrpheuGetFunction("ClearMultiDamage"))
		ExecuteHamB(Ham_TraceAttack, pEntity, id, 32.0, vecForward, ptr, DMG_NEVERGIB | DMG_BULLET)
		OrpheuCall(OrpheuGetFunction("ApplyMultiDamage"), id, id)
		
		if(is_user_alive(pEntity) && z4e_team_get_user_zombie(pEntity))
		{
			if(g_iDifficulty == DIFF_HARD)
				KnockBack_Set(pHit, id, 800.0, 1000.0, 650.0, 500.0, 0.9)
			else
				KnockBack_Set(pHit, id, 800.0, 1000.0, 650.0, 500.0, 0.7)
		}
		free_tr2(ptr)
	}
	
	new Float:vecVelocity[3]
	xs_vec_normalize(vecForward, vecVelocity)
	xs_vec_mul_scalar(vecVelocity, random_float(400.0, 405.0), vecVelocity)
	
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(iEntity)) return
	
	set_pev(iEntity, pev_classname, ELEMENT_WIND_CLASSNAME)
	set_pev(iEntity, pev_owner, id)
	
	engfunc(EngFunc_SetModel, iEntity, ELEMENT_WIND_MODEL)
	
	set_pev(iEntity, pev_rendermode, kRenderTransAdd)
	set_pev(iEntity, pev_renderamt, 150.0)
	set_pev(iEntity, pev_scale, 0.15)
	
	set_pev(iEntity, pev_movetype, MOVETYPE_FLY)
	set_pev(iEntity, pev_solid, SOLID_TRIGGER)
	
	set_pev(iEntity, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(iEntity, pev_maxs, Float:{1.0, 1.0, 1.0})
	
	static Float:vecAngles[3]
	vecAngles[0] = random_float(-60.0,60.0)
	vecAngles[1] = random_float(-60.0,60.0)
	vecAngles[2] = random_float(-60.0,60.0)
	set_pev(iEntity, pev_angles, vecAngles)
	
	set_pev(iEntity, pev_origin, vecSrc)
	set_pev(iEntity, pev_velocity, vecVelocity)
	set_pev(iEntity, pev_fuser1, get_gametime() + 0.75)	// time remove
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.06)
}

public HamF_ElementWind_Touch(iEntity, pHit)
{
	if(!pev_valid(iEntity))
		return
	static szClassname[32]; pev(iEntity, pev_classname, szClassname, sizeof(szClassname))
	if(!equal(szClassname, ELEMENT_WIND_CLASSNAME))
		return
	if(is_user_alive(pHit))
		return
		
	if(pev_valid(pHit))
	{
		pev(pHit, pev_classname, szClassname, sizeof(szClassname))
		
		if(equal(szClassname, ELEMENT_WIND_CLASSNAME)) 
			return
	}
		
	set_pev(iEntity, pev_movetype, MOVETYPE_NONE)
	set_pev(iEntity, pev_solid, SOLID_NOT)
	set_pev(iEntity, pev_velocity, { 0.0, 0.0, 0.0})
}

public HamF_ElementWind_Think(iEntity)
{
	if(!pev_valid(iEntity)) 
		return
	static szClassname[32]; pev(iEntity, pev_classname, szClassname, sizeof(szClassname))
	if(!equal(szClassname, ELEMENT_WIND_CLASSNAME))
		return
		
	static Float:flFrame, Float:flNextThink, Float:flScale
	pev(iEntity, pev_frame, flFrame)
	pev(iEntity, pev_scale, flScale)
	
	// effect exp
	static iMoveType; iMoveType = pev(iEntity, pev_movetype)
	if (iMoveType == MOVETYPE_NONE)
	{
		flNextThink = 0.0015
		flFrame += random_float(0.25, 0.75)
		flScale += 0.01
		
		flScale = floatmin(1.5, flFrame)
		if(flFrame > 21.0)
		{
			engfunc(EngFunc_RemoveEntity, iEntity)
			return
		}
	} 
	else if(iMoveType == MOVETYPE_FLY)
	{
		flNextThink = 0.045
		
		flFrame += random_float(0.5, 1.0)
		flScale += 0.001
		
		flFrame = floatmin(21.0, flFrame)
		flScale = floatmin(1.5, flFrame)
	}
	else if(iMoveType == MOVETYPE_FOLLOW)
	{
		flNextThink = 0.045
		
		flFrame += random_float(0.5, 1.0)
		
		if(flFrame > 12.0)
			flFrame = 0.0
	}
	
	set_pev(iEntity, pev_frame, flFrame)
	set_pev(iEntity, pev_scale, flScale)
	set_pev(iEntity, pev_nextthink, get_gametime() + flNextThink)
	
	// time remove
	static Float:flTimeRemove
	pev(iEntity, pev_fuser1, flTimeRemove)
	if(get_gametime() >= flTimeRemove)
	{
		static Float:flRenderAmt; pev(iEntity, pev_renderamt, flRenderAmt)
		if(flRenderAmt <= 5.0)
		{
			engfunc(EngFunc_RemoveEntity, iEntity)
			return
		} 
		else 
		{
			flRenderAmt -= 5.0
			set_pev(iEntity, pev_renderamt, flRenderAmt)
		}
	}
}

public HamF_BahamutGravity_Think(this)
{
	if(!pev_valid(this)) 
		return
	static szClassname[32]; pev(this, pev_classname, szClassname, sizeof(szClassname))
	if(!equal(szClassname, BAHAMUT_GRAVITY_CLASSNAME))
		return
	
	engfunc(EngFunc_RemoveEntity, this);
}

public HamF_ElementGravity_Think(this)
{
	if(!pev_valid(this)) 
		return
	static szClassname[32]; pev(this, pev_classname, szClassname, sizeof(szClassname))
	if(!equal(szClassname, ELEMENT_GRAVITY_CLASSNAME))
		return
		
	new Float:vecOrigin[3]; 
	pev(this, pev_origin, vecOrigin)
	
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, 675.0)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || !z4e_team_get_user_zombie(pEntity))
			continue;
		
		new Float:flPower = floatsqroot(1.0 / (fm_entity_range(this, pEntity) + 0.1)) * 200000.0
		flPower = floatmin(flPower, 2000.0);
		
		new Float:vecOrigin2[3];
		
		pev(pEntity, pev_origin, vecOrigin2);
		xs_vec_sub(vecOrigin, vecOrigin2, vecOrigin2);
		xs_vec_normalize(vecOrigin2, vecOrigin2);
		xs_vec_mul_scalar(vecOrigin2, flPower, vecOrigin2)
		
		set_pev(pEntity, pev_velocity, vecOrigin2);
	}
	
	ImplosionEffect(vecOrigin)
	LightEffect(vecOrigin, 250, 250, 50)
	/*
	static Float:flNextFrame
	pev(iEntity, pev_fuser1, flNextFrame)
	if(get_gametime() > flNextFrame)
	{
		static Float:flFrame
		pev(iEntity, pev_frame, flFrame)
		flFrame += 1.0
		if(flFrame > 15.0)
			flFrame = 0.0
		set_pev(iEntity, pev_frame, flFrame)
	}
	*/
	// time remove
	static Float:flTimeRemove
	pev(this, pev_fuser1, flTimeRemove)
	if(get_gametime() >= flTimeRemove)
	{
		engfunc(EngFunc_RemoveEntity, this)
		return;
	}
	
	set_pev(this, pev_nextthink, get_gametime() + 0.1);
}

public HamF_Player_TakeDamage(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if(!pev_valid(iAttacker))
		return HAM_IGNORED
	static szClassname[32]
	pev(iAttacker, pev_classname, szClassname, 31)
	if(!equal(szClassname, "func_door"))
		return HAM_IGNORED
	/*
	if(pev(iAttacker, pev_modelindex) == MODELINDEX_DOOR6_ELEVATOR_DOWN)
		return HAM_SUPERCEDE*/
	return HAM_IGNORED
}

public Task_Timer()
{
	if(g_iMapStatus == MAPSTATUS_CHECKING)
	{
		for(new id=1;id<33;id++)
		{
			if(IsInBoss(id))
			{
					BossTrigger()
					break;
			}
		}
	}
	
	if(g_iMapStatus == MAPSTATUS_BAHAMUT_ATTACKING)
	{
		for(new id=1;id<33;id++)
		{
			if(is_user_alive(id) && pev(id, pev_movetype) == MOVETYPE_FLY && z4e_team_get(id) == Z4E_TEAM_HUMAN)
			{
				user_kill(id)
				z4e_alarm_push(_, "** 漏洞使用者已被处死 **", "", "", { 50,250,50 }, 2.0);
			}
		}
	}

	
	else if(g_iDifficulty == DIFF_NORMAL && g_iMapStatus == MAPSTATUS_SEPH_KILLED)
	{
		for(new id=1;id<33;id++)
		{
			if(!IsInEscapeZone(id))
				continue;
				
			EscapeZoneTrigger()
			break;
		}
	}
}

IsInBoss(id)
{
	if(!is_user_alive(id))
		return 0;
	new Float:vecOrigin[3], Float:vecDelta[3]
	pev(id, pev_origin, vecOrigin)
	xs_vec_sub(vecOrigin, UNDERGROUND_ORIGIN_CHECK, vecDelta)
	if(floatabs(vecDelta[2]) > UNDERGROUND_MAXDISTANCE_Z)
		return 0;
	vecDelta[0] = 0.0
	if(xs_vec_len(vecDelta) > UNDERGROUND_MAXDISTANCE_XY)
		return 0;
	return 1;
}

IsInEscapeZone(id)
{
	if(!is_user_alive(id))
		return 0;
	new Float:vecOrigin[3]
	pev(id, pev_origin, vecOrigin)
	
	return CheckPointIn(vecOrigin, ESCAPE_ORIGIN_MINS, ESCAPE_ORIGIN_MAXS);
}

BossTrigger()
{
	g_iMapStatus = MAPSTATUS_WAITING
	z4e_alarm_timertip(20, "克劳德正在安放炸彈...")
	set_task(20.0, "Task_BossAppear", TASK_GAMEPLAY)
	PlaySound(0, SOUND_BGM[g_iDifficulty][BGMTYPE_BOSS1_TRIGGER], 1)
}

public Task_BossAppear()
{
	g_iMapStatus = MAPSTATUS_BAHAMUT_ATTACKING
	
	
	z4e_alarm_insert(_, "持续开火，阻止巴哈姆特的攻击！", "TIPS:火箭炮可以对它造成巨大伤害", "", { 250,50,50 }, 3.0)
	z4e_alarm_insert(_, "不好!是巴哈姆特!", "", "", { 250,50,50 }, 2.0)
	z4e_alarm_insert(_, "炸彈已经裝置好了，快跑！", "", "", { 250,50,50 }, 2.0)
	
	for(new id=1;id<33;id++)
	{
		if(!is_user_alive(id))
			continue;
		if(IsInBoss(id))
			continue;
			
		set_pev(id, pev_origin, UNDERGROUND_ORIGIN_CAGE)
	}
	
	message_begin(MSG_ALL, gmsgScreenFade)
	write_short((1<<13))
	write_short((1<<13))
	write_short((0x0000))
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(255)
	message_end()
	
	EarthBarrierSpawn()
	
	BahamutCreate()
}

BahamutCreate()
{
	if(pev_valid(g_pBahamut))
		fm_remove_entity(g_pBahamut)
	
	g_pBahamut = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(g_pBahamut))
		return;
	   
	//server_print("Console: BahamutCreate()");
	   
	set_pev(g_pBahamut, pev_solid, SOLID_BBOX)
	set_pev(g_pBahamut, pev_movetype, MOVETYPE_PUSHSTEP)
	set_pev(g_pBahamut, pev_takedamage, DAMAGE_YES)
	set_pev(g_pBahamut, pev_classname, BOSS_BAHAMUT_CLASSNAME)
	set_pev(g_pBahamut, pev_deadflag, DEAD_NO)
	
	set_pev(g_pBahamut, pev_maxspeed, 100.0)
	
	// 引用 http://tieba.baidu.com/p/4251793388
	set_pev(g_pBahamut, pev_model, BOSS_BAHAMUT_MODEL);
	set_pev(g_pBahamut, pev_modelindex, engfunc(EngFunc_ModelIndex, BOSS_BAHAMUT_MODEL));
	
	engfunc(EngFunc_SetSize, g_pBahamut, BOSS_BAHAMUT_MINS, BOSS_BAHAMUT_MAXS)
	
	set_pev(g_pBahamut, pev_frame, 0.0)
	set_pev(g_pBahamut, pev_framerate, 1.0)
	
	if(g_iMapStatus == MAPSTATUS_SEPH_ATTACKING)
	{
		engfunc(EngFunc_SetOrigin, g_pBahamut, BOSS_BAHAMUT_ORIGIN2)
		set_pev(g_pBahamut, pev_angles, BOSS_BAHAMUT_ANGLES2)
		set_pev(g_pBahamut, pev_v_angle, BOSS_BAHAMUT_ANGLES2)
		set_pev(g_pBahamut, pev_max_health, BOSS_BAHAMUT_HEALTH2 * float(max(4, z4e_team_count(Z4E_TEAM_HUMAN, 1))))
		set_pev(g_pBahamut, pev_health, BOSS_BAHAMUT_HEALTH2 * float(max(4, z4e_team_count(Z4E_TEAM_HUMAN, 1))))
	}
	else
	{
		engfunc(EngFunc_SetOrigin, g_pBahamut, BOSS_BAHAMUT_ORIGIN)
		set_pev(g_pBahamut, pev_angles, BOSS_BAHAMUT_ANGLES)
		set_pev(g_pBahamut, pev_v_angle, BOSS_BAHAMUT_ANGLES)
		set_pev(g_pBahamut, pev_max_health, BOSS_BAHAMUT_HEALTH * float(max(4, z4e_team_count(Z4E_TEAM_HUMAN, 1))))
		set_pev(g_pBahamut, pev_health, BOSS_BAHAMUT_HEALTH * float(max(4, z4e_team_count(Z4E_TEAM_HUMAN, 1))))
	}
	
	set_pev(g_pBahamut, pev_nextthink, get_gametime() + random_float(5.0, 20.0))
	
}

BahamutRun(this)
{
	//server_print("Console: BahamutRun()");
	g_iMapStatus = MAPSTATUS_BAHAMUT_RUN
	
	set_pev(this, pev_takedamage, DAMAGE_NO);
	set_pev(this, pev_health, 0.0);
	set_pev(this, pev_iuser1, 0);
	
	set_pev(this, pev_solid, SOLID_NOT);
	set_pev(this, pev_movetype, MOVETYPE_NOCLIP);
	set_pev(this, pev_gravity, 0.0);
	
	set_pev(this, pev_iuser1, 1);
	set_pev(this, pev_sequence, 1);
	
	set_pev(this, pev_nextthink, get_gametime() + 2.0);
	fm_set_rendering(this);
	
	// 强行让电梯下降并且电梯下层大门打开
	new pEntity = 0
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
	{
		if(pev(pEntity, pev_modelindex) == MODELINDEX_DOOR6_ELEVATOR_DOWN)
		{
			if(get_pdata_int(pEntity, m_toggle_state) != TS_AT_TOP)
			{
				ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0)
			}
		}
		if(pev(pEntity, pev_modelindex) == MODELINDEX_DOOR7A || pev(pEntity, pev_modelindex) == MODELINDEX_DOOR7B)
		{
			if(get_pdata_int(pEntity, m_toggle_state) == TS_AT_BOTTOM)
				ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0)
		}
	}
	BitsUnSet(g_bitsButtonUsed, BUTTON_DOOR7)
	
	z4e_alarm_insert(_, "炸弹快引爆了,迅速撤退!", "", "", { 250,50,50 }, 2.0)
	
	if(g_iDifficulty <= DIFF_HARD)
	{
		set_task(15.0, "Task_ReleaseAgain", TASK_GAMEPLAY)
		z4e_alarm_timertip(15, "铁门马上就要开启了！")
	}
	else
	{
		set_task(7.0, "Task_ReleaseAgain", TASK_GAMEPLAY)
		z4e_alarm_timertip(7, "铁门开启中...")
	}
	
	/*
	message_begin(MSG_ALL, gmsgScreenFade)
	write_short((1<<12))
	write_short((1<<12))
	write_short((0x0000))
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	message_end()
	*/
	fm_remove_entity_name("z4e_earth_barrier")
	
	
}

public BahamutKilled2(this)
{
	fm_remove_entity(this);
	g_pBahamut = 0;
	
	if(!pev_valid(g_pSeph))
		EscapeZoneOpen()
}

public Task_ReleaseAgain()
{
	g_iMapStatus = MAPSTATUS_SETTINGOFF
	
	z4e_alarm_timertip(86, "炸弹引爆中...")
	set_task(86.0, "Task_Explode", TASK_GAMEPLAY)
	set_task(32.0, "Task_TempestBGM", TASK_TEMPESTBGM)
	
	if(g_iDifficulty == DIFF_EXTREMEII)
	{
		SephTriggerCreate();
	}
	
	new pEntity
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
	{
		if(pev(pEntity, pev_modelindex) == MODELINDEX_WALL9)
		{
			set_pev(pEntity, pev_solid, SOLID_NOT)
			set_pev(pEntity, pev_effects, EF_NODRAW)
		}
		else if(pev(pEntity, pev_modelindex) == MODELINDEX_WALL_BUTTONROOM)
		{
			if(g_iDifficulty <= DIFF_HARD)
			{
				set_pev(pEntity, pev_solid, SOLID_NOT)
				set_pev(pEntity, pev_effects, EF_NODRAW)
			}
		}
		else if(pev(pEntity, pev_modelindex) == MODELINDEX_WALL_BFUCKEX2)
		{
			if(g_iDifficulty == DIFF_EXTREMEII)
			{
				set_pev(pEntity, pev_solid, SOLID_NOT)
				set_pev(pEntity, pev_effects, EF_NODRAW)
			}
		}
		
	}
	
	pEntity = 0
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
	{
		if(pev(pEntity, pev_modelindex) != MODELINDEX_DOOR5)
			continue;
		if(get_pdata_int(pEntity, m_toggle_state) == TS_AT_TOP)
		{
			new bitsSpawnFlags = pev(pEntity, pev_spawnflags)
			set_pev(pEntity, pev_spawnflags, bitsSpawnFlags | SF_DOOR_NO_AUTO_RETURN)
			
			ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0)
			set_pev(pEntity, pev_spawnflags, bitsSpawnFlags)
		}
	}
}

public Task_TempestBGM()
{
	PlaySound(0, SOUND_BGM[g_iDifficulty][BGMTYPE_TEMPEST], 1)
}

public Task_ElevatorExplode()
{
	//server_print("Console: Task_ElevatorExplode()")
	// 强行让电梯消失并且电梯下层大门打开
	new pEntity = 0
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
	{
		if(pev(pEntity, pev_modelindex) == MODELINDEX_DOOR6_ELEVATOR_DOWN)
		{
			set_pev(pEntity, pev_effects, EF_NODRAW)
			set_pev(pEntity, pev_solid, SOLID_NOT)
		}
		
		if(pev(pEntity, pev_modelindex) == MODELINDEX_DOOR7A || pev(pEntity, pev_modelindex) == MODELINDEX_DOOR7B)
		{
			if(get_pdata_int(pEntity, m_toggle_state) == TS_AT_BOTTOM)
				ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0)
		}
	}
	pEntity = 0
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
	{
		if(pev(pEntity, pev_modelindex) == MODELINDEX_WALL7_SIDE)
		{
			set_pev(pEntity, pev_effects, EF_NODRAW)
			set_pev(pEntity, pev_solid, SOLID_NOT)
		}
	}
	
	BitsSet(g_bitsButtonUsed, BUTTON_DOOR7)
	
	new const Float:vecElevatorOrigin[3] = {1234.0, 350.0, 793.0}
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BREAKMODEL)
	engfunc(EngFunc_WriteCoord, vecElevatorOrigin[0])
	engfunc(EngFunc_WriteCoord, vecElevatorOrigin[1])
	engfunc(EngFunc_WriteCoord, vecElevatorOrigin[2])
	write_coord(200); // size x
	write_coord(80); // size y
	write_coord(64); // size z
	write_coord(random_num(-128,128)); // velocity x
	write_coord(random_num(-128,128)); // velocity y
	write_coord(25); // velocity z
	write_byte(10); // random velocity
	write_short(g_iModelElevatorGibs); // model index that you want to break
	write_byte(127); // count
	write_byte(25); // life
	write_byte(0); // flags: BREAK_GLASS
	message_end();
	
	for(new i=0;i<8;i++)
	{
		new Float:vecOrigin[3]
		
		vecOrigin[0] = vecElevatorOrigin[0] + random_float(-128.0,128.0)
		vecOrigin[1] = vecElevatorOrigin[1] + random_float(-128.0,128.0)
		vecOrigin[2] = vecElevatorOrigin[2] + random_float(-16.0,64.0)
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_EXPLOSION)
		engfunc(EngFunc_WriteCoord, vecOrigin[0])
		engfunc(EngFunc_WriteCoord, vecOrigin[1])
		engfunc(EngFunc_WriteCoord, vecOrigin[2])
		write_short(random_num(0,1)?g_iSprExplo:g_iSprExplo2)
		write_byte(random_num(20,25))
		write_byte(random_num(23,30))
		write_byte(0)
		message_end()
	}
	
	pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecElevatorOrigin, 600.0)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity))
			continue;
		
		message_begin(MSG_ONE, gmsgScreenShake, _, pEntity)
		write_short((1<<12) * 5) // amplitude
		//write_short((1<<12) * 15) // duration
		write_short((1<<12) * 2) // duration
		write_short((1<<12) * 10) // frequency
		message_end()
	}
}

public Task_Explode()
{
	g_iMapStatus = MAPSTATUS_SEPH_ATTACKING
	
	if(pev_valid(g_pBahamut))
		fm_remove_entity(g_pBahamut);
	g_pBahamut = 0;
	
	if(pev_valid(g_pSeph))
		fm_remove_entity(g_pSeph);
	g_pSeph = 0;
	
	for(new id=1;id<33;id++)
	{
		if(!is_user_alive(id))
			continue;
		new Float:vecOrigin[3]
		pev(id, pev_origin, vecOrigin)
		if(vecOrigin[2] < UNDERGROUND_BELOW)
		{
			message_begin(MSG_ONE_UNRELIABLE, gmsgScreenFade, _, id)
			write_short((1<<12) * 2) // duration
			write_short((1<<12) * 2) // hold time
			write_short((0x0000)) // fade type
			write_byte(255)
			write_byte(255)
			write_byte(255)
			write_byte(255) // alpha
			message_end()
		
			user_kill(id, 1);
		}
		
		message_begin(MSG_ONE, gmsgScreenShake, _, id)
		write_short((1<<12) * 10) // amplitude
		//write_short((1<<12) * 15) // duration
		write_short((1<<15) - 1) // duration
		write_short((1<<12) * 10) // frequency
		message_end()
	}
	
	new pEntity = 0
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
	{
		if(pev(pEntity, pev_modelindex) != MODELINDEX_DOOR5)
			continue;
		if(get_pdata_int(pEntity, m_toggle_state) == TS_AT_BOTTOM)
		{
			ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0)
		}
	}
	
	if(g_iDifficulty == DIFF_EXTREMEII)
	{
		z4e_alarm_insert(_, "提示：刀光会把你一击毙命...", "", "", { 250,50,50 }, 5.0)
		z4e_alarm_insert(_, "只有天选之子才能走向光明...", "", "", { 250,50,50 }, 10.0)
		PlaySound(0, SOUND_BGM[g_iDifficulty][BGMTYPE_BOSS2_DOOR5], 1)
		
		new pEntity
		while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
		{
			if(pev(pEntity, pev_modelindex) != MODELINDEX_FANCE1 || pev(pEntity, pev_modelindex) != MODELINDEX_FANCE2)
				continue;
			set_pev(pEntity, pev_solid, SOLID_NOT)
			set_pev(pEntity, pev_effects, EF_NODRAW)
		}
		
		SephCreate()
		BahamutCreate()
		set_pev(g_pSeph, pev_nextthink, get_gametime() + 7.0)
		set_pev(g_pSeph, pev_fuser1, get_gametime() + 300.0)
		PlaySound(0, SOUND_SEPHCHOSEN)
	}
	else if(g_iDifficulty == DIFF_EXTREMEI || g_iDifficulty == DIFF_HARD)
	{
		z4e_alarm_insert(_, "这里马上就要爆炸了, 快跑!", "", "", { 250,50,50 }, 5.0)
		PlaySound(0, SOUND_BGM[g_iDifficulty][BGMTYPE_BOSS2_DOOR5], 1)
		set_task(26.9, "EscapeZoneTrigger", TASK_GAMEPLAY)
		
		new pEntity
		while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
		{
			if(pev(pEntity, pev_modelindex) != MODELINDEX_WALL10)
				continue;
			set_pev(pEntity, pev_solid, SOLID_NOT)
			set_pev(pEntity, pev_effects, EF_NODRAW)
		}
		
		set_task(24.0, "SephCreate", TASK_EXISEPH)
	}
	else if(g_iDifficulty == DIFF_NORMAL)
	{
		z4e_alarm_insert(_, "这里马上就要爆炸了, 快跑!", "", "", { 250,50,50 }, 5.0)
		PlaySound(0, SOUND_BGM[g_iDifficulty][BGMTYPE_BOSS2_DOOR5], 1)
		set_task(26.9, "EscapeZoneTrigger", TASK_GAMEPLAY)
		
		new pEntity
		while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
		{
			if(pev(pEntity, pev_modelindex) != MODELINDEX_WALL10)
				continue;
			set_pev(pEntity, pev_solid, SOLID_NOT)
			set_pev(pEntity, pev_effects, EF_NODRAW)
		}
	}
	
	PlaySound(0, SOUND_EXPLODE)
}

public SephCreate()
{
	if(pev_valid(g_pSeph))
		fm_remove_entity(g_pSeph)
	
	g_pSeph = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(g_pSeph))
		return;
	   
	set_pev(g_pSeph, pev_solid, SOLID_BBOX)
	set_pev(g_pSeph, pev_movetype, MOVETYPE_PUSHSTEP)
	set_pev(g_pSeph, pev_classname, BOSS_SEPH_CLASSNAME)
	set_pev(g_pSeph, pev_deadflag, DEAD_NO)
	set_pev(g_pSeph, pev_maxspeed, 100.0)
	set_pev(g_pSeph, pev_takedamage, DAMAGE_YES)
	
	if(g_iDifficulty == DIFF_EXTREMEII)
	{
		set_pev(g_pSeph, pev_max_health, BOSS_SEPH_HEALTH * max(2, z4e_team_count(Z4E_TEAM_HUMAN, 1)/2))
		set_pev(g_pSeph, pev_health, BOSS_SEPH_HEALTH * max(2, z4e_team_count(Z4E_TEAM_HUMAN, 1)/2))
	}
	else if(g_iDifficulty == DIFF_EXTREMEI || g_iDifficulty == DIFF_HARD)
	{
		set_pev(g_pSeph, pev_max_health, 1.0);
		set_pev(g_pSeph, pev_health, 1.0);
	}
	
	// 引用 http://tieba.baidu.com/p/4251793388
	set_pev(g_pSeph, pev_model, BOSS_SEPH_MODEL);
	set_pev(g_pSeph, pev_modelindex, engfunc(EngFunc_ModelIndex, BOSS_SEPH_MODEL));
	
	engfunc(EngFunc_SetSize, g_pSeph, BOSS_SEPH_MINS, BOSS_SEPH_MAXS)
	engfunc(EngFunc_SetOrigin, g_pSeph, BOSS_SEPH_ORIGIN)
	if(g_iDifficulty == DIFF_EXTREMEII)
	{
	set_pev(g_pSeph, pev_angles, BOSS_SEPH_ANGLES)
	}
	else if(g_iDifficulty == DIFF_EXTREMEI)
	{
	set_pev(g_pSeph, pev_angles, BOSS_SEPH_ANGLES_EXI)
	}
	
	set_pev(g_pSeph, pev_frame, 0.0)
	set_pev(g_pSeph, pev_framerate, 1.0)
	set_pev(g_pSeph, pev_nextthink, get_gametime() + 2.0)
	
	if(g_iDifficulty == DIFF_EXTREMEI) Seph_Move_A()
}

public Seph_Move_A()
{
	set_pev(g_pSeph, pev_takedamage, DAMAGE_YES)
	engfunc(EngFunc_SetOrigin, g_pSeph, SEPH_EXI_ORIGIN_A)
	set_task(0.3, "Seph_Move_B", TASK_EXISEPH)
	PlaySound(0, SOUND_SEPHTOOLATE)
}

public Seph_Move_B()
{
	engfunc(EngFunc_SetOrigin, g_pSeph, SEPH_EXI_ORIGIN_B)
	set_task(0.3, "Seph_Move_C", TASK_EXISEPH)
}

public Seph_Move_C()
{
	engfunc(EngFunc_SetOrigin, g_pSeph, SEPH_EXI_ORIGIN_C)
	set_task(0.3, "Seph_Move_D", TASK_EXISEPH)
}

public Seph_Move_D()
{
	engfunc(EngFunc_SetOrigin, g_pSeph, SEPH_EXI_ORIGIN_D)
	set_task(0.3, "Seph_Move_E", TASK_EXISEPH)
}

public Seph_Move_E()
{
	engfunc(EngFunc_SetOrigin, g_pSeph, SEPH_EXI_ORIGIN_E)
	set_task(0.3, "Seph_Move_F", TASK_EXISEPH)
}

public Seph_Move_F()
{
	engfunc(EngFunc_SetOrigin, g_pSeph, SEPH_EXI_ORIGIN_F)
	set_task(0.3, "Seph_Move_G", TASK_EXISEPH)
}

public Seph_Move_G()
{
	engfunc(EngFunc_SetOrigin, g_pSeph, SEPH_EXI_ORIGIN_G)
	set_task(0.3, "Seph_Move_H", TASK_EXISEPH)
}

public Seph_Move_H()
{
	engfunc(EngFunc_SetOrigin, g_pSeph, SEPH_EXI_ORIGIN_H)
	set_task(0.3, "Seph_Move_I", TASK_EXISEPH)
}

public Seph_Move_I()
{
	engfunc(EngFunc_SetOrigin, g_pSeph, SEPH_EXI_ORIGIN_I)
}

SephKilled()
{
	remove_task(TASK_EXISEPH);
	
	if(pev_valid(g_pSeph))
		fm_remove_entity(g_pSeph)
	g_pSeph = 0
	
	
	if(!pev_valid(g_pBahamut))
	{
		EscapeZoneOpen()
	}
	
	z4e_alarm_insert(_, "成功击毙萨菲罗斯！", "", "", { 250,50,50 }, 2.0)
}

EscapeZoneOpen()
{
	g_iMapStatus = MAPSTATUS_SEPH_KILLED;
	
	// 开门
	new pEntity
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
	{
		if(pev(pEntity, pev_modelindex) != MODELINDEX_WALL10)
			continue;
		set_pev(pEntity, pev_solid, SOLID_NOT);
		set_pev(pEntity, pev_effects, EF_NODRAW);
		
		z4e_alarm_insert(_, "迅速进入逃生区域！", "", "", { 250,50,50 }, 2.0)
		
		EscapeZoneTrigger();
	}
}

public SephTriggerCreate()
{
	if(pev_valid(g_pSeph))
		fm_remove_entity(g_pSeph)
	
	g_pSeph = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(g_pSeph))
		return;
	   
	set_pev(g_pSeph, pev_solid, SOLID_TRIGGER)
	set_pev(g_pSeph, pev_movetype, MOVETYPE_NONE)
	set_pev(g_pSeph, pev_classname, BOSS_SEPH_CLASSNAME)
	set_pev(g_pSeph, pev_deadflag, DEAD_NO)
	set_pev(g_pSeph, pev_maxspeed, 100.0)
	set_pev(g_pSeph, pev_takedamage, DAMAGE_YES)
	
	set_pev(g_pSeph, pev_max_health, 1.0)
	set_pev(g_pSeph, pev_health, 1.0)
	
	// 引用 http://tieba.baidu.com/p/4251793388
	set_pev(g_pSeph, pev_model, BOSS_SEPH_MODEL);
	set_pev(g_pSeph, pev_modelindex, engfunc(EngFunc_ModelIndex, BOSS_SEPH_MODEL));
	
	engfunc(EngFunc_SetSize, g_pSeph, BOSS_SEPH_TRIGGER_MINS, BOSS_SEPH_TRIGGER_MAXS)
	engfunc(EngFunc_SetOrigin, g_pSeph, BOSS_SEPH_ORIGIN2)
	set_pev(g_pSeph, pev_angles, BOSS_SEPH_ANGLES2)
	
	set_pev(g_pSeph, pev_frame, 0.0)
	set_pev(g_pSeph, pev_framerate, 1.0)

	//set_pev(g_pSeph, pev_nextthink, get_gametime() + 2.0);
}

BeamBladeCreate()
{
	new iEntity = Beam_Create(BEAM_BLADE_MODEL, 25.0)
	set_pev(iEntity, pev_classname, BEAM_BLADE_CLASSNAME)
	new Float:vecStart[3], Float:vecEnd[3], Float:vecDirection[3]
	if(g_iMapStatus == MAPSTATUS_SETTINGOFF)
	{
		xs_vec_copy(BEAM_BLADE_ORIGIN2, vecStart)
		xs_vec_add(vecStart, BEAM_BLADE_DIRECTION2, vecEnd)
		xs_vec_normalize(BEAM_BLADE_DIRECTION2, vecDirection)
		xs_vec_mul_scalar(vecDirection, 16.0, vecDirection)
	}
	else
	{
		xs_vec_copy(BEAM_BLADE_ORIGIN, vecStart)
		xs_vec_add(vecStart, BEAM_BLADE_DIRECTION, vecEnd)
		xs_vec_normalize(BEAM_BLADE_DIRECTION, vecDirection)
		xs_vec_mul_scalar(vecDirection, 16.0, vecDirection)
		
		if(vecStart[2] > BEAM_BLADE_ORIGIN[2] + BEAM_BLADE_BARRIER_Z)
		{
			xs_vec_sub(vecStart, vecDirection, vecStart)
		}
		if(vecEnd[2] > BEAM_BLADE_ORIGIN[2] + BEAM_BLADE_BARRIER_Z)
		{
			xs_vec_add(vecEnd, vecDirection, vecEnd)
		}
	}
	
	
	
	if(!iEntity)
	{
		vecStart[2] += BEAM_BLADE_ORIGIN_FIXZ2
		vecEnd[2] += BEAM_BLADE_ORIGIN_FIXZ2
	}
	else
	{
		vecStart[2] += BEAM_BLADE_ORIGIN_FIXZ1
		vecEnd[2] += BEAM_BLADE_ORIGIN_FIXZ1
	}
	
	Beam_PointsInit(iEntity, vecStart, vecEnd)
	Beam_SetColor(iEntity, {42.0,172.0,255.0})
	Beam_SetNoise(iEntity, 0)
	Beam_SetBrightness(iEntity, 255.0 );
	
	set_pev(iEntity, pev_spawnflags, SF_BEAM_STARTON)
	//set_pev(iEntity, pev_rendermode, kRenderTransAdd)
	set_pev(iEntity, pev_renderfx, kRenderFxPulseSlowWide)
	
	set_pev(iEntity, pev_nextthink, get_gametime())
	
	emit_sound(iEntity, CHAN_WEAPON, SOUND_BLADE, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public EscapeZoneTrigger()
{
	g_iMapStatus = MAPSTATUS_ESCAPEZONE
	
	new pEntity = 0
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
	{
		if(pev(pEntity, pev_modelindex) != MODELINDEX_DOOR10)
			continue;
		new bitsSpawnFlags = pev(pEntity, pev_spawnflags)
		set_pev(pEntity, pev_spawnflags, bitsSpawnFlags | SF_DOOR_NO_AUTO_RETURN)
		ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0)
	}
	
	z4e_alarm_timertip(14, "最终逃跑...")
	if(g_iDifficulty == DIFF_EXTREMEI)
	{
		if(g_bSephKilled != 1)
		{
			z4e_alarm_insert(_, "击毙萨菲罗斯失败! 他会杀死我们所有人!", "", "", { 250,50,50 }, 2.0)
			PlaySound(0, SOUND_SEPHSLOW)
		
			for(new id=1;id<33;id++)
			{
				if(is_user_alive(id) && !z4e_team_get_user_zombie(id)) 
					user_kill(id)
			}
		
		}
		else 
			set_task(8.0, "EXI_Blade")
	}
	set_task(14.0, "Task_EscapeEnd", TASK_GAMEPLAY)
}

public EXI_Blade()
{
	new blade = random_num(1, 2)
	new g_iKnifeA = find_ent_by_model( -1,"func_button" ,"*115" ); 
	new g_iKnifeB = find_ent_by_model( -1,"func_button" ,"*114" ); 
	
	if(blade == 1) ExecuteHamB(Ham_Use, g_iKnifeB, 0, 0, 0, 0.0)
	else ExecuteHamB(Ham_Use, g_iKnifeA, 0, 0, 0, 0.0)
	
	PlaySound(0, SOUND_SEPHGOODBYE)
	PlaySound(0, SOUND_BLADE)
}

public Task_EscapeEnd()
{
	PlaySound(0, SOUND_BGM[g_iDifficulty][BGMTYPE_VICTORY], 1)
	for(new id=1;id<33;id++)
	{
		if(!is_user_alive(id))
			continue;
		if(IsInEscapeZone(id))
			continue;
			
		user_kill(id, 1);
	}
	
	if(g_iDifficulty < DIFF_EXTREMEII)
		g_iDifficulty++;
	
}

public HamF_Boss_TraceAttack(this, iAttacker, Float:fDamage, Float:vecDirection[3], ptr, bitsDamageType)
{
	new szClassName[33]
	pev(this, pev_classname, szClassName, charsmax(szClassName))
	if(!equal(szClassName, BOSS_BAHAMUT_CLASSNAME) && !equal(szClassName, BOSS_SEPH_CLASSNAME))
		return HAM_IGNORED
	
	if(pev(this, pev_iuser1) == BAHAMUT_SKILL_EARTH)
		return HAM_IGNORED
		
	new Float:vecEnd[3]
	get_tr2(ptr, TR_vecEndPos, vecEnd)
	SpawnBlood(vecEnd, 247, floatround(fDamage))
	return HAM_IGNORED
}

public HamF_Boss_TakeDamage(this, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	new szClassName[33]
	pev(this, pev_classname, szClassName, charsmax(szClassName))
	if(!equal(szClassName, BOSS_BAHAMUT_CLASSNAME) && !equal(szClassName, BOSS_SEPH_CLASSNAME))
		return HAM_IGNORED
	
	if(pev(this, pev_iuser1) == BAHAMUT_SKILL_EARTH)
	{
		ExecuteHamB(Ham_TakeDamage, iAttacker, this, this, flDamage / 3.0, bitsDamageType);
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED
}

public HamF_Boss_Killed(this)
{
	new szClassName[33]
	pev(this, pev_classname, szClassName, charsmax(szClassName))
	if(!equal(szClassName, BOSS_BAHAMUT_CLASSNAME))
		return HAM_IGNORED
	if(this == g_pBahamut)
	{
		if(g_iMapStatus == MAPSTATUS_BAHAMUT_ATTACKING)
		{
			BahamutRun(this)
			return HAM_SUPERCEDE
		}
		else if(g_iMapStatus == MAPSTATUS_SEPH_ATTACKING)
		{
			BahamutKilled2(this)
			return HAM_SUPERCEDE;
		}
	}
	else if(this == g_pSeph)
	{
		if(g_iMapStatus == MAPSTATUS_SEPH_ATTACKING)
		{
			if(g_iDifficulty == DIFF_EXTREMEII)
			{
				SephKilled()
				return HAM_SUPERCEDE
			}
			else if(g_iDifficulty == DIFF_EXTREMEI)
			{
				g_iMapStatus = MAPSTATUS_SEPH_KILLED
	
				if(pev_valid(g_pSeph))
				{
					fm_remove_entity(g_pSeph)
					g_pSeph = 0
				}
			
				g_bSephKilled = 1
				return HAM_SUPERCEDE
			}
		}
	}
	return HAM_IGNORED
}

public HamF_FuncWall_Spawn(this)
{
	if(!pev_valid(this))
		return;
	if(pev(this, pev_modelindex) == MODELINDEX_WALL_SPAWN)
	{
		set_pev(this, pev_effects, 0)
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_WALL1B)
	{
		set_pev(this, pev_effects, 0)
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_BARRIER4A || pev(this, pev_modelindex) == MODELINDEX_BARRIER4B || pev(this, pev_modelindex) == MODELINDEX_BARRIER4C)
	{
		set_pev(this, pev_effects, 0)
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_WALL5)
	{
		set_pev(this, pev_effects, 0)
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_WALL8A || pev(this, pev_modelindex) == MODELINDEX_WALL8B)
	{
		set_pev(this, pev_effects, 0)
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_WALL9)
	{
		set_pev(this, pev_effects, 0)
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_WALL10)
	{
		set_pev(this, pev_effects, 0)
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_GLASS5 && g_iDifficulty >= DIFF_EXTREMEI)
	{
		set_pev(this, pev_effects, 0)
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_FANCE1 || pev(this, pev_modelindex) == MODELINDEX_FANCE2)
	{
		set_pev(this, pev_effects, 0)
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_WALL_BUTTONROOM)
	{
		set_pev(this, pev_effects, 0)
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_WALL_BFUCKEX2)
	{
		set_pev(this, pev_effects, 0)
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_WALL7_SIDE)
	{
		set_pev(this, pev_effects, 0)
	}
}

public HamF_FuncDoor_Spawn(this)
{
	if(!pev_valid(this))
		return HAM_IGNORED
	if(pev(this, pev_modelindex) == MODELINDEX_DOOR6A)
	{
		set_pev(this, pev_effects, 0)
		set_pev(this, pev_solid, SOLID_BSP)
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_DOOR6B)
	{
		set_pev(this, pev_effects, 0)
		set_pev(this, pev_solid, SOLID_BSP)
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_DOOR7_ELEVATOR_UP)
	{
		set_pev(this, pev_solid, SOLID_NOT)
		set_pev(this, pev_effects, EF_NODRAW)
		return HAM_SUPERCEDE
	}
	else if(pev(this, pev_modelindex) == MODELINDEX_DOOR6_ELEVATOR_DOWN)
	{
		set_pev(this, pev_effects, 0)
		set_pev(this, pev_solid, SOLID_BSP)
	}
	
	return HAM_IGNORED
}

public HamF_FuncDoor_Use(this, caller, activator, use_type)
{
	if(!pev_valid(this))
		return HAM_IGNORED
	switch(pev(this, pev_modelindex))
	{
		case MODELINDEX_DOOR1A:
		{
			new pEntity
			while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
			{
				if(pev(pEntity, pev_modelindex) != MODELINDEX_WALL1B)
					continue;
				set_pev(pEntity, pev_solid, SOLID_NOT)
				set_pev(pEntity, pev_effects, EF_NODRAW)
			}
		}
		case MODELINDEX_DOOR6_ELEVATOR_DOWN:
		{
			// 上层电梯启动
			new iToggleState = get_pdata_int(this, m_toggle_state)
			if(g_iMapStatus < MAPSTATUS_SETTINGOFF)
			{
				if(iToggleState == TS_AT_BOTTOM)
					z4e_alarm_timertip(7, "电梯下降中...")
				else if(iToggleState == TS_AT_TOP)
					z4e_alarm_timertip(7, "电梯上升中...")
			}
			
			new pEntity
			while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
			{
				if(iToggleState == TS_AT_BOTTOM)
				{
					if(pev(pEntity, pev_modelindex) == MODELINDEX_DOOR6A || pev(pEntity, pev_modelindex) == MODELINDEX_DOOR6B)
					{
						// 如果电梯在上面就关闭上面的门
						ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0)
						BitsUnSet(g_bitsButtonUsed, BUTTON_DOOR7)
					}
				}
				if(iToggleState == TS_AT_TOP)
				{
					if(pev(pEntity, pev_modelindex) == MODELINDEX_DOOR7A || pev(pEntity, pev_modelindex) == MODELINDEX_DOOR7B)
					{
						// 如果电梯在下面就关闭下面的门
						ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0)
						// 并且准备打开上面的门
						set_task(7.0, "Task_OpenDoor6", TASK_GAMEPLAY)
					}
				}
			}
		}
		case MODELINDEX_DOOR7_ELEVATOR_UP:
		{
			// 下层按钮本来引导下面的电梯的，现在去掉了，因此直接调用上层电梯并且阻止下层电梯被使用
			new pEntity
			while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
			{
				if(pev(pEntity, pev_modelindex) != MODELINDEX_DOOR6_ELEVATOR_DOWN)
					continue;
				//FBitSet(pev->spawnflags, SF_DOOR_NO_AUTO_RETURN)
				// 因为cs引擎判断上面这个条件才允许func_door返回所以就这么办吧QAQ
				new bitsSpawnFlags = pev(pEntity, pev_spawnflags)
				set_pev(pEntity, pev_spawnflags, bitsSpawnFlags | SF_DOOR_NO_AUTO_RETURN)
				
				ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0)
				set_pev(pEntity, pev_spawnflags, bitsSpawnFlags)
				
				return HAM_SUPERCEDE
			}
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}

public Task_OpenDoor6()
{
	// 当电梯回到上层的时候
	new pEntity
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
	{
		// 打开上层电梯大门
		if(pev(pEntity, pev_modelindex) == MODELINDEX_DOOR6A || pev(pEntity, pev_modelindex) == MODELINDEX_DOOR6B)
		{
			ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0)
		}
	}
	
	pEntity = 0
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
	{
		// 打开小道
		if(pev(pEntity, pev_modelindex) == MODELINDEX_WALL8A || pev(pEntity, pev_modelindex) == MODELINDEX_WALL8B)
		{
			set_pev(pEntity, pev_solid, SOLID_NOT)
			set_pev(pEntity, pev_effects, EF_NODRAW)
		}
	}
	
	if(g_iDifficulty >= DIFF_EXTREMEI && g_iMapStatus == MAPSTATUS_SETTINGOFF)
	{
		set_task(5.0, "Task_ElevatorExplode", TASK_GAMEPLAY);
		BitsSet(g_bitsButtonUsed, BUTTON_DOOR6)
	}
	else
	{
		BitsUnSet(g_bitsButtonUsed, BUTTON_DOOR6)
	}
	
}

public HamF_FuncButton_Use(this, caller, activator, use_type)
{
	if(!pev_valid(this))
		return HAM_IGNORED
	switch(pev(this, pev_modelindex))
	{
		case MODELINDEX_DOOR1A_BUTTON:
			if(!BitsGet(g_bitsButtonUsed, BUTTON_DOOR1))
			{
				z4e_alarm_timertip(30, "仓库入口防御...")
				BitsSet(g_bitsButtonUsed, BUTTON_DOOR1)
			}
		case MODELINDEX_DOOR2_BUTTON:
			if(!BitsGet(g_bitsButtonUsed, BUTTON_DOOR2))
			{
				z4e_alarm_timertip(12, "仓库大门开启中...")
				BitsSet(g_bitsButtonUsed, BUTTON_DOOR2)
			}
			
		case MODELINDEX_DOOR3_BUTTON:
			if(!BitsGet(g_bitsButtonUsed, BUTTON_DOOR3))
			{
				new pEntity
				while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
				{
					if(pev(this, pev_modelindex) != MODELINDEX_BARRIER4A && pev(this, pev_modelindex) != MODELINDEX_BARRIER4B && pev(this, pev_modelindex) != MODELINDEX_BARRIER4C)
						continue;
					set_pev(pEntity, pev_solid, SOLID_NOT)
					set_pev(pEntity, pev_effects, EF_NODRAW)
				}
				z4e_alarm_timertip(10, "仓库出口防御...")
				BitsSet(g_bitsButtonUsed, BUTTON_DOOR3)
				
			}
			
		case MODELINDEX_DOOR4_BUTTON:
			if(!BitsGet(g_bitsButtonUsed, BUTTON_DOOR4))
			{
				new pEntity
				while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
				{
					if(pev(pEntity, pev_modelindex) != MODELINDEX_GLASS5)
						continue;
					set_pev(pEntity, pev_solid, SOLID_NOT)
					set_pev(pEntity, pev_effects, EF_NODRAW)
				}
				z4e_alarm_timertip(10, "魔光炉大门开启中...")
				
				PlaySound(0, SOUND_BGM[g_iDifficulty][BGMTYPE_DOOR4_ENTRANCE], 1)
				
				BitsSet(g_bitsButtonUsed, BUTTON_DOOR4)
			}
			
		case MODELINDEX_WALL5_BUTTON:
		{
			if(!BitsGet(g_bitsButtonUsed, BUTTON_WALL5))
			{
				new pEntity
				while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_wall"))))
				{
					if(pev(pEntity, pev_modelindex) != MODELINDEX_WALL5)
						continue;
					set_pev(pEntity, pev_solid, SOLID_NOT)
					set_pev(pEntity, pev_effects, EF_NODRAW)
				}
				if(g_iMapStatus == MAPSTATUS_NONE)
					z4e_alarm_timertip(5, "进入魔光炉...")
				BitsSet(g_bitsButtonUsed, BUTTON_WALL5)
			}
			else
			{
				return HAM_SUPERCEDE;
			}
		}
		case MODELINDEX_DOOR6_BUTTON:
		{
			// 按了上层电梯按钮
			if(g_iMapStatus == MAPSTATUS_NONE)
				g_iMapStatus = MAPSTATUS_CHECKING
				
			if(BitsGet(g_bitsButtonUsed, BUTTON_DOOR6) || g_iMapStatus >= MAPSTATUS_SETTINGOFF)
			{
				return HAM_SUPERCEDE;
			}
			
			new pEntity
			
			while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
			{
				// 如果电梯在上面打开上层电梯大门
				if(pev(pEntity, pev_modelindex) == MODELINDEX_DOOR6A || pev(pEntity, pev_modelindex) == MODELINDEX_DOOR6B)
				{
					// 如果是第一次按就开门
					if(get_pdata_int(pEntity, m_toggle_state) == TS_AT_BOTTOM)
						ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0)
				}
				
				// 去掉下层电梯
				if(pev(pEntity, pev_modelindex) == MODELINDEX_DOOR7_ELEVATOR_UP)
				{
					set_pev(pEntity, pev_solid, SOLID_NOT)
					set_pev(pEntity, pev_effects, EF_NODRAW)
				}
			}
			BitsSet(g_bitsButtonUsed, BUTTON_DOOR6)
			
			if(g_iMapStatus < MAPSTATUS_SETTINGOFF)
				z4e_alarm_timertip(10, "等待电梯下降...")
		}
		case MODELINDEX_DOOR7_BUTTON:
		{
			// 按了下层电梯按钮
			if(BitsGet(g_bitsButtonUsed, BUTTON_DOOR7))
			{
				return HAM_SUPERCEDE;
			}
			
			new pEntity
			while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
			{
				if(pev(pEntity, pev_modelindex) == MODELINDEX_DOOR7A || pev(pEntity, pev_modelindex) == MODELINDEX_DOOR7B)
				{
					// 如果是第一次按就开门
					if(get_pdata_int(pEntity, m_toggle_state) == TS_AT_BOTTOM)
						ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0)
				}
				if((g_iMapStatus >= MAPSTATUS_SETTINGOFF) && pev(pEntity, pev_modelindex) == MODELINDEX_DOOR7_ELEVATOR_UP)
				{
					ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0)
					BitsSet(g_bitsButtonUsed, BUTTON_DOOR7)
					return HAM_SUPERCEDE;
				}
			}

			// 这个按钮本来是要激活下层电梯的（实际上我又改成激活上层的了）
			z4e_alarm_timertip(10, "等待电梯上升...")
			BitsSet(g_bitsButtonUsed, BUTTON_DOOR7)
		}
		case MODELINDEX_BUTTON_BUTTONROOM:
		{
			if(!BitsGet(g_bitsButtonUsed, BUTTON_BUTTONROOM))
			{
				if(g_iMapStatus == MAPSTATUS_SETTINGOFF)
				{
					z4e_alarm_insert(_, "做得好！大门即将开启", "", "", { 250,50,50 }, 2.0)
					z4e_alarm_timertip(5, "炸弹引爆中...")
					
					remove_task(TASK_GAMEPLAY);
					set_task(5.0, "Task_Explode", TASK_GAMEPLAY)
				}
				BitsSet(g_bitsButtonUsed, BUTTON_BUTTONROOM)
			}
			return HAM_SUPERCEDE;
		}
	}
	return HAM_IGNORED;
}

public HamF_TriggerTeleport_Touch(this, id)
{
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(g_iMapStatus >= MAPSTATUS_BAHAMUT_ATTACKING)
	{
		static Float:vecOrigin[3]
		pev(id, pev_origin, vecOrigin)
		if(vecOrigin[2] < UNDERGROUND_BELOW && vecOrigin[2] > UNDERGROUND_ORIGIN_CHECK[2])
			return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}

public HamF_FuncBreakable_Touch(this, id)
{
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(pev(this, pev_modelindex) != MODELINDEX_BREAKABLE1)
		return HAM_IGNORED
	if(!z4e_team_get_user_zombie(id))
		return HAM_IGNORED
	set_pev(this, pev_takedamage, DAMAGE_YES)
	ExecuteHamB(Ham_TakeDamage, this, id, id, 5.0, DMG_BULLET)
	return HAM_SUPERCEDE
}

public HamF_FuncDoor_Touch(this, id)
{
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(pev(this, pev_modelindex) != MODELINDEX_DOOR_BRIDGE)
		return HAM_IGNORED
	
	if(g_iDifficulty == DIFF_HARD && g_iMapStatus == MAPSTATUS_SEPH_ATTACKING)
	{
		if(!BitsGet(g_bitsButtonUsed, BUTTON_BRIDGE))
		{
			set_task(5.0, "Task_BridgeDown", TASK_GAMEPLAY)
			BitsSet(g_bitsButtonUsed, BUTTON_BRIDGE)
		}
	}
	return HAM_IGNORED
}


public Task_BridgeDown(taskid)
{
	new pEntity
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
	{
		if(pev(pEntity, pev_modelindex) == MODELINDEX_DOOR_BRIDGE)
		{
			ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0);
			PlaySound(0, SOUND_BLADE);
			break;
		}
	}
	
}

public HamF_Boss_Think(this)
{
	if(!pev_valid(this))
		return HAM_IGNORED;
	static szClassname[33]; pev(this, pev_classname, szClassname, charsmax(szClassname))
	if(strcmp(szClassname, "z4e_boss"))
		return HAM_IGNORED;
	
	if(this == g_pBahamut)
	{
		if(g_iMapStatus == MAPSTATUS_BAHAMUT_ATTACKING || g_iMapStatus == MAPSTATUS_SEPH_ATTACKING)
		{
			if(g_iDifficulty == DIFF_EXTREMEII)
			{
				new iLastSkill = pev(this, pev_iuser1)
				new Float:flNextThink = get_gametime()+0.1;
				if(iLastSkill == BAHAMUT_SKILL_ULTIMA)
				{
					Bahamut_Skill_Ultima_Effect(this)
					flNextThink = get_gametime() + 1.0;
				}
				else if(iLastSkill == BAHAMUT_SKILL_WIND)
				{
					Bahamut_Skill_Wind_Action(this)
					flNextThink = get_gametime() + 0.1;
				}
				else if(iLastSkill == BAHAMUT_SKILL_GRAVITY)
				{
					Bahamut_Skill_Gravity_Action(this)
					flNextThink = get_gametime() + 0.01;
				}
				else if(iLastSkill == BAHAMUT_SKILL_ELECTRIC)
				{
					Bahamut_Skill_Electric_Action(this)
					flNextThink = get_gametime() + 0.1;
				}
				
				new Float:flNextSkill;
				pev(this, pev_fuser1, flNextSkill)
				if(get_gametime()>flNextSkill)
				{
					
					if(iLastSkill == BAHAMUT_SKILL_ULTIMA)
					{
						Bahamut_Skill_Ultima_Action(this)
						iLastSkill = BAHAMUT_SKILL_NONE
						flNextSkill = get_gametime() + random_float(3.0, 7.0);
						flNextThink = flNextSkill
					}
					else
					{
						set_pev(this, pev_sequence, 0);
						switch(random_num(BAHAMUT_SKILL_NONE + 1, TOTAL_BAHAMUT_SKILL))
						{
							case BAHAMUT_SKILL_FIRE: 
							{
								Bahamut_Skill_Fire(this)
								flNextSkill = get_gametime() + random_float(7.0, 15.0)
							}
							case BAHAMUT_SKILL_ICE: 
							{
								Bahamut_Skill_Ice(this)
								flNextSkill = get_gametime() + random_float(7.0, 15.0)
							}
							case BAHAMUT_SKILL_WIND: 
							{
								Bahamut_Skill_Wind(this)
								flNextSkill = get_gametime() + random_float(7.0, 15.0)
								flNextThink = get_gametime() + 0.1;
							}
							case BAHAMUT_SKILL_HEAL: 
							{
								Bahamut_Skill_Heal(this)
								flNextSkill = get_gametime() + random_float(7.0, 15.0)
							}
							case BAHAMUT_SKILL_EARTH: 
							{
								Bahamut_Skill_Earth(this)
								flNextSkill = get_gametime() + random_float(10.0, 20.0)
							}
							case BAHAMUT_SKILL_ULTIMA: 
							{
								Bahamut_Skill_Ultima(this)
								flNextSkill = get_gametime() + 20.0;
								flNextThink = get_gametime() + 1.0;
							}
							case BAHAMUT_SKILL_GRAVITY:
							{
								Bahamut_Skill_Gravity(this)
								flNextSkill = get_gametime() + 10.0
								flNextThink = get_gametime() + 0.01;
							}
							case BAHAMUT_SKILL_ELECTRIC:
							{
								Bahamut_Skill_Electric(this)
								flNextSkill = get_gametime() + 10.0
								flNextThink = get_gametime() + 0.01;
							}
						}
						set_pev(this, pev_fuser1, flNextSkill)
					}
						
					
				}
				set_pev(this, pev_nextthink, flNextThink)
			}
		}
		else if(g_iMapStatus == MAPSTATUS_BAHAMUT_RUN || g_iMapStatus == MAPSTATUS_SETTINGOFF)
		{
			if(pev(this, pev_iuser1) == 1)
			{
				set_pev(this, pev_avelocity, BOSS_BAHAMUT_AVELOCITY_ROUTE);
				
				new Float:vecVelocity[3];
				xs_vec_sub(BOSS_BAHAMUT_ORIGIN_ROUTE_LOW, BOSS_BAHAMUT_ORIGIN, vecVelocity);
				xs_vec_mul_scalar(vecVelocity, 1.0/2.0, vecVelocity);
				set_pev(this, pev_velocity, vecVelocity);
				
				set_pev(this, pev_sequence, 2);
				set_pev(this, pev_iuser1, 2);
				set_pev(this, pev_nextthink, get_gametime() + 2.0);
				
			}
			else if(pev(this, pev_iuser1) == 2)
			{
				set_pev(this, pev_velocity, Float:{0.0,0.0,0.0});
				set_pev(this, pev_avelocity, Float:{0.0,0.0,0.0});
				set_pev(this, pev_iuser1, 3)
				set_pev(this, pev_nextthink, get_gametime() + 0.5);
			}
			else if(pev(this, pev_iuser1) == 3)
			{
				set_pev(this, pev_velocity, Float:{0.0,0.0,60.0});
				set_pev(this, pev_nextthink, get_gametime() + random_float(15.0, 30.0));
				emit_sound(this, CHAN_WEAPON, BOSS_BAHAMUT_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
	}
	else if(this == g_pSeph)
	{
		if(g_iMapStatus == MAPSTATUS_SETTINGOFF)
		{
			if(g_iDifficulty == DIFF_EXTREMEII)
			{
				new iCount = pev(this, pev_iuser4);
				if(iCount)
				{
					BeamBladeCreate()
					set_pev(this, pev_nextthink, get_gametime() + random_float(1.5, 2.0))
					iCount --;
					set_pev(this, pev_iuser4, iCount);
				}
				else
				{
					fm_remove_entity(this);
				}
				
				return HAM_SUPERCEDE
			}
		}
		else if(g_iMapStatus == MAPSTATUS_SEPH_ATTACKING)
		{
			if(g_iDifficulty == DIFF_EXTREMEII)
			{
				BeamBladeCreate()
				set_pev(this, pev_nextthink, get_gametime() + random_float(1.5, 2.0))
				return HAM_SUPERCEDE
			}
		}
	}
	
	return HAM_IGNORED
}

public HamF_Boss_Touch(this, pTouched)
{
	if(!pev_valid(this))
		return HAM_IGNORED;
	static szClassname[33]; pev(this, pev_classname, szClassname, charsmax(szClassname))
	if(strcmp(szClassname, "z4e_boss"))
		return HAM_IGNORED;
	
	if(this == g_pSeph)
	{
		if(g_iMapStatus == MAPSTATUS_SETTINGOFF)
		{
			if(g_iDifficulty == DIFF_EXTREMEII)
			{
				set_pev(this, pev_solid, SOLID_NOT);
				set_pev(this, pev_iuser4, 1);
				set_pev(this, pev_nextthink, get_gametime() + random_float(0.5, 1.0));
				z4e_alarm_insert(_, "萨菲罗斯将会稍后出现", "", "", { 250,250,250 }, 2.0);
				//PlaySound(0, SOUND_SEPHISEEYOU)
				emit_sound(this, CHAN_WEAPON, SOUND_SEPHISEEYOU, 1.0, ATTN_NORM, 0, PITCH_NORM)
				return HAM_SUPERCEDE;
			}
		}
		else if(g_iMapStatus == MAPSTATUS_SEPH_ATTACKING)
		{
			if(is_user_alive(pTouched))
				user_kill(pTouched);
		}
	}
	else if(this == g_pBahamut)
	{
		new iLastSkill = pev(this, pev_iuser1)
		if(iLastSkill == BAHAMUT_SKILL_GRAVITY)
		{
			if(is_user_alive(pTouched))
				user_kill(pTouched);
		}
	}
	
	return HAM_IGNORED
}

public HamF_BeamBlade_Think(this)
{
	static szClassname[33]; pev(this, pev_classname, szClassname, charsmax(szClassname))
	if(strcmp(szClassname, BEAM_BLADE_CLASSNAME))
		return HAM_IGNORED;
	
	static Float:flRenderAmt
	pev(this, pev_renderamt, flRenderAmt)
	flRenderAmt-=1.0
	set_pev(this, pev_renderamt, flRenderAmt)
	if(flRenderAmt <= 5.0)
	{
		fm_remove_entity(this)
		return HAM_SUPERCEDE
	}
		
	static Float:vecStart[3], Float:vecEnd[3]
	Beam_GetStartPos(this, vecStart)
	Beam_GetEndPos(this, vecEnd)
	if(g_iMapStatus == MAPSTATUS_SETTINGOFF)
	{
		xs_vec_add(vecStart, BEAM_BLADE_VELOCITY2, vecStart)
		xs_vec_add(vecEnd, BEAM_BLADE_VELOCITY2, vecEnd)
	}
	else
	{
		xs_vec_add(vecStart, BEAM_BLADE_VELOCITY, vecStart)
		xs_vec_add(vecEnd, BEAM_BLADE_VELOCITY, vecEnd)
	}
	
	Beam_SetStartPos(this, vecStart)
	Beam_SetEndPos(this, vecEnd)
	
	new ptr = create_tr2()
	engfunc(EngFunc_TraceLine, vecStart, vecEnd, DONT_IGNORE_MONSTERS, 0, ptr)
	new pHit = get_tr2(ptr, TR_pHit)
	if(is_user_alive(pHit) && !z4e_team_get_user_zombie(pHit))
	{
		new Float:vecDirection[3]
		xs_vec_sub(vecEnd, vecStart, vecDirection)
		xs_vec_normalize(vecDirection, vecDirection)
		OrpheuCall(OrpheuGetFunction("ClearMultiDamage"))
		ExecuteHamB(Ham_TraceAttack, pHit, this, flRenderAmt * 200.0, vecDirection, ptr, DMG_NEVERGIB | DMG_BULLET)
		OrpheuCall(OrpheuGetFunction("ApplyMultiDamage"), this, this)
	}
	
	free_tr2(ptr)
	
	set_pev(this, pev_nextthink, get_gametime() + 0.01)
	
	return HAM_IGNORED
}

Bahamut_Skill_Fire(this)
{
	new Float:vecOrigin[3]; 
	pev(this, pev_origin, vecOrigin)
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, 2000.0)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || z4e_team_get_user_zombie(pEntity))
			continue;
		z4e_burn_set(pEntity, 5.0, 1)
	}
	
	ExplodeEffect(vecOrigin, 200, 50, 50)
	LightEffect(vecOrigin, 200, 50, 50)
	fm_set_rendering(this, kRenderFxGlowShell, 200, 50, 50, kRenderNormal, 1)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_FIREFIELD) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0]+random_float(-5.0, 5.0))
	engfunc(EngFunc_WriteCoord, vecOrigin[1]+random_float(-5.0, 5.0))
	engfunc(EngFunc_WriteCoord, vecOrigin[2]-10.0)
	write_short(1200) //radius
	write_short(g_iSprFire) // sprite
	write_byte(random_num(20, 50)) // count
	write_byte(TEFIRE_FLAG_SOMEFLOAT|TEFIRE_FLAG_LOOP|TEFIRE_FLAG_PLANAR|32) // flags
	write_byte(15) // duration (in seconds) * 10
	message_end()
	
	set_pev(this, pev_iuser1, BAHAMUT_SKILL_FIRE)
	z4e_alarm_insert(_, "巴哈姆特释放了烈焰元素 | 你会受到灼烧数秒", "", "", { 250,250,250 }, 2.0)
}

Bahamut_Skill_Ice(this)
{
	new Float:vecOrigin[3]; 
	pev(this, pev_origin, vecOrigin)
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, 2000.0)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || z4e_team_get_user_zombie(pEntity))
			continue;
		z4e_freeze_set(pEntity, 7.0, 1);
	}
	
	ExplodeEffect(vecOrigin, 0, 100, 200)
	LightEffect(vecOrigin, 0, 100, 200)
	fm_set_rendering(this, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 1)
	
	set_pev(this, pev_iuser1, BAHAMUT_SKILL_ICE)
	z4e_alarm_insert(_, "巴哈姆特释放了寒冰元素 | 你会被冰冻数秒", "", "", { 250,250,250 }, 2.0)
}

Bahamut_Skill_Gravity(this)
{
	fm_set_rendering(this, kRenderFxGlowShell, 200, 50, 200, kRenderNormal, 1)
	
	set_pev(this, pev_iuser1, BAHAMUT_SKILL_GRAVITY)
	set_pev(this, pev_sequence, 1);
	z4e_alarm_insert(_, "巴哈姆特释放了黑洞元素 | 你会被吸引", "", "", { 250,250,250 }, 2.0)
	
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
	set_pev(iEntity, pev_classname, BAHAMUT_GRAVITY_CLASSNAME)
	
	set_pev(iEntity, pev_owner, this)
	
	set_pev(iEntity, pev_solid, SOLID_TRIGGER)
	set_pev(iEntity, pev_movetype, MOVETYPE_NONE)
	
	engfunc(EngFunc_SetModel, iEntity, ELEMENT_GRAVITY_MODEL)
	
	engfunc(EngFunc_SetOrigin, iEntity, Float:{450.0, 2200.0, -2800.0})
	
	set_pev(iEntity, pev_animtime, get_gametime())
	set_pev(iEntity, pev_framerate, 30.0)
	set_pev(iEntity, pev_spawnflags, SF_SPRITE_STARTON)
	set_pev(iEntity, pev_rendermode, kRenderTransAdd)
	set_pev(iEntity, pev_renderamt, 250.0)
	set_pev(iEntity, pev_scale, 0.6)
	set_pev(iEntity, pev_rendercolor, Float:{250.0, 50.0, 50.0})
	
	dllfunc(DLLFunc_Spawn, iEntity)
	
	set_pev(iEntity, pev_nextthink, get_gametime() + 10.0);	// time remove
}

Bahamut_Skill_Gravity_Action(this)
{
	new Float:vecOrigin[3]; 
	pev(this, pev_origin, vecOrigin)
	
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, 2000.0)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || z4e_team_get_user_zombie(pEntity))
			continue;
		
		new Float:vecOrigin2[3];
		
		pev(pEntity, pev_origin, vecOrigin2);
		vecOrigin2[2] = 0.0
		xs_vec_sub(vecOrigin, vecOrigin2, vecOrigin2);
		xs_vec_normalize(vecOrigin2, vecOrigin2);
		xs_vec_mul_scalar(vecOrigin2, 360.0, vecOrigin2)
		
		set_pev(pEntity, pev_velocity, vecOrigin2);
	}
}

Bahamut_Skill_Electric(this)
{
	fm_set_rendering(this, kRenderFxGlowShell, 50, 200, 200, kRenderNormal, 1)
	
	set_pev(this, pev_iuser1, BAHAMUT_SKILL_ELECTRIC)
	set_pev(this, pev_sequence, 1);
	z4e_alarm_insert(_, "巴哈姆特释放了电元素 | 地面会导电", "", "", { 250,250,250 }, 2.0)
}

Bahamut_Skill_Electric_Action(this)
{
	
	new Float:flHeighMin
	new Float:flHeighMax
	
	new Float:vecEffectMins[3]
	new Float:vecEffectMaxs[3]
	
	if(g_iMapStatus == MAPSTATUS_BAHAMUT_ATTACKING)
	{
		flHeighMin = -2973.0;
		flHeighMax = -2954.0;
		xs_vec_copy(Float:{-40.0, 1083.0, -2958.0 }, vecEffectMins);
		xs_vec_copy(Float:{697.0, 3571.0, -2962.0 }, vecEffectMaxs);
	}
	else
	{
		flHeighMin = 769.0;
		flHeighMax = 788.0;
		xs_vec_copy(Float:{-3674.0, -2475.0, 766.0 }, vecEffectMins);
		xs_vec_copy(Float:{-1634.0, 2388.0, 766.0 }, vecEffectMaxs);
	}
	
	for(new i=0;i<8;i++)
	{
		new i=random_num(0,1)
		new Float:vecStart[3];
		xs_vec_copy(vecEffectMins, vecStart)
		new Float:vecEnd[3];
		xs_vec_copy(vecEffectMaxs, vecEnd)
		vecStart[i] = random_float(vecEffectMins[i], vecEffectMaxs[i])
		vecEnd[i] = random_float(vecEffectMins[i], vecEffectMaxs[i])
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMPOINTS)
		engfunc(EngFunc_WriteCoord, vecStart[0])
		engfunc(EngFunc_WriteCoord, vecStart[1])
		engfunc(EngFunc_WriteCoord, vecStart[2] - 12.0)
		engfunc(EngFunc_WriteCoord, vecEnd[0])
		engfunc(EngFunc_WriteCoord, vecEnd[1])
		engfunc(EngFunc_WriteCoord, vecEnd[2] - 12.0)
		write_short(g_iSprBeam)
		write_byte(0) // starting frame
		write_byte(10) // frame rate in 0.1's
		write_byte(3) // life in 0.1's
		write_byte(30) // line width in 0.1's
		write_byte(10) // noise amplitude in 0.01's
		write_byte(random_num(50, 250)) // red
		write_byte(250) // green
		write_byte(250) // blue
		write_byte(130) // brightness
		write_byte(30) // scroll speed in 0.1's
		message_end()
	}
	
	for(new i=1;i<33;i++)
	{
		if(!is_user_alive(i) || z4e_team_get_user_zombie(i))
			continue;
		new Float:vecOrigin2[3]
		pev(i, pev_origin, vecOrigin2);
		if(vecOrigin2[2]>=flHeighMin && vecOrigin2[2]<=flHeighMax)
		{
			ExecuteHamB(Ham_TakeDamage, i, this, this, 3.0, DMG_BULLET);
			set_pdata_float(i, m_flVelocityModifier, 0.3);
		}
	}
	
}

Bahamut_Skill_Wind(this)
{
	fm_set_rendering(this, kRenderFxGlowShell, 200, 200, 200, kRenderNormal, 1)
	
	set_pev(this, pev_iuser1, BAHAMUT_SKILL_WIND)
	set_pev(this, pev_sequence, 1);
	z4e_alarm_insert(_, "巴哈姆特释放了疾风元素 | 你会被击退", "", "", { 250,250,250 }, 2.0)
}

Bahamut_Skill_Wind_Action(this)
{
	new Float:vecOrigin[3]; 
	pev(this, pev_origin, vecOrigin)
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, 2000.0)) && pev_valid(pEntity))
	{
		if(!is_user_alive(pEntity) || z4e_team_get_user_zombie(pEntity))
			continue;
		
		if(g_iMapStatus == MAPSTATUS_BAHAMUT_ATTACKING)
		{
			new Float:vecEnd[3]
			pev(pEntity, pev_origin, vecEnd)
			if(fm_get_view_angle_diff(this, vecEnd) >= 45.0)
				continue;
		}
		
		new Float:vecOrigin2[3]
		pev(pEntity, pev_origin, vecOrigin2)
			
		new Float:vecVelocity[3]
		xs_vec_sub(vecOrigin2, vecOrigin, vecVelocity)
		vecVelocity[2] = 0.0
		xs_vec_normalize(vecVelocity, vecVelocity)
		xs_vec_mul_scalar(vecVelocity, 512.0, vecVelocity)
		vecVelocity[2] = 10.0
		set_pev(pEntity, pev_velocity, vecVelocity)
	}
	
	if(g_iMapStatus == MAPSTATUS_BAHAMUT_ATTACKING)
	{
		new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if(!pev_valid(iEntity)) return
		
		set_pev(iEntity, pev_classname, ELEMENT_WIND_CLASSNAME)
		set_pev(iEntity, pev_owner, this)
		
		engfunc(EngFunc_SetModel, iEntity, ELEMENT_WIND_MODEL)
		
		set_pev(iEntity, pev_rendermode, kRenderTransAdd)
		set_pev(iEntity, pev_renderamt, 150.0)
		set_pev(iEntity, pev_scale, 0.15)
		
		set_pev(iEntity, pev_movetype, MOVETYPE_FLY)
		set_pev(iEntity, pev_solid, SOLID_TRIGGER)
		
		set_pev(iEntity, pev_mins, Float:{-1.0, -1.0, -1.0})
		set_pev(iEntity, pev_maxs, Float:{1.0, 1.0, 1.0})
		
		static Float:vecAngles[3]
		vecAngles[0] = random_float(-60.0,60.0)
		vecAngles[1] = random_float(-60.0,60.0)
		vecAngles[2] = random_float(-60.0,60.0)
		set_pev(iEntity, pev_angles, vecAngles)
		
		set_pev(iEntity, pev_origin, vecOrigin)
		set_pev(iEntity, pev_velocity, Float:{0.0, 400.0, -10.0})
		set_pev(iEntity, pev_fuser1, get_gametime() + 0.75)	// time remove
		set_pev(iEntity, pev_nextthink, get_gametime() + 0.06)
	}
	else
	{
		ExplodeEffect(vecOrigin, 200, 200, 200);
	}
	
}

Bahamut_Skill_Heal(this)
{
	new Float:vecOrigin[3]; 
	pev(this, pev_origin, vecOrigin)
	vecOrigin[2] -= 16.0
	
	new Float:flHealth, Float:flMaxHealth
	pev(this, pev_health, flHealth)
	pev(this, pev_max_health, flMaxHealth)
	
	flHealth += flMaxHealth * 0.35
	if(flHealth > flMaxHealth)
		flHealth = flMaxHealth
	set_pev(this, pev_health, flHealth);
	
	ExplodeEffect(vecOrigin, 50, 200, 50)
	LightEffect(vecOrigin, 50, 200, 50)
	fm_set_rendering(this, kRenderFxGlowShell, 50, 200, 50, kRenderNormal, 1)
	
	set_pev(this, pev_iuser1, BAHAMUT_SKILL_HEAL)
	z4e_alarm_insert(_, "巴哈姆特释放了治疗元素 | 恢复部分血量", "", "", { 250,250,250 }, 2.0)
}

Bahamut_Skill_Earth(this)
{
	new Float:vecOrigin[3]; 
	pev(this, pev_origin, vecOrigin)
	
	ExplodeEffect(vecOrigin, 250, 150, 50)
	LightEffect(vecOrigin, 250, 150, 50)
	fm_set_rendering(this, kRenderFxGlowShell, 250, 150, 50, kRenderNormal, 1)
	
	set_pev(this, pev_iuser1, BAHAMUT_SKILL_EARTH)
	z4e_alarm_insert(_, "巴哈姆特释放了土木元素 | 小心! 会反弹伤害!", "", "", { 250,250,250 }, 2.0)
}

Bahamut_Skill_Ultima(this)
{
	new Float:vecOrigin[3]; 
	pev(this, pev_origin, vecOrigin)
	
	ExplodeEffect(vecOrigin, 250, 250, 250)
	LightEffect(vecOrigin, 250, 250, 250)
	fm_set_rendering(this, kRenderFxGlowShell, 250, 250, 250, kRenderNormal, 1)
	
	set_pev(this, pev_iuser1, BAHAMUT_SKILL_ULTIMA)
	z4e_alarm_insert(_, "巴哈姆特释放了终极元素 | 20秒后将是末日", "", "", { 250,50,50 }, 2.0)
	z4e_alarm_timertip(20, "巴哈姆特的终极元素...")
}

Bahamut_Skill_Ultima_Effect(this)
{
	new Float:vecOrigin[3];
	pev(this, pev_origin, vecOrigin)
	vecOrigin[2]+=250.0
	
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_ALL, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BEAMDISK) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, vecOrigin[2]) // z
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, vecOrigin[2]+555.0) // z axis
	write_short(g_iSprBeam) // sprite
	write_byte(0) // startframe
	write_byte(15) // framerate
	write_byte(100) // life
	write_byte(60) // width
	write_byte(1) // noise
	write_byte(255) // red
	write_byte(50) // green
	write_byte(50) // blue
	write_byte(200) // brightness
	write_byte(5) // speed
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_ALL, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BEAMENTPOINT)
	write_short(this) //start entity
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 2048.0) // z
	write_short(g_iSprBeam) //modelindex
	write_byte(0) //starting frame
	write_byte(10) //frame rate in 0.1's
	write_byte(11) //life in 0.1's
	write_byte(127) //line width in 0.1's
	write_byte(10) // noise amplitude in 0.01's
	write_byte(255) // red
	write_byte(50) // green 
	write_byte(50) // blue
	write_byte(200) // brightness
	write_byte(15) // scroll speed in 0.1's
	message_end()
}

Bahamut_Skill_Ultima_Action(this)
{
	new Float:vecOrigin[3];
	pev(this, pev_origin, vecOrigin)
	
	new bShouldKill = 1;
	new pEntity
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", ELEMENT_CLASSNAME))))
	{
		new iType = pev(pEntity, pev_iuser1)
		if(iType != ELEMENT_HEAL)
			continue;
		new Float:flEndTime;
		pev(pEntity, pev_fuser2, flEndTime)
		if(get_gametime() > flEndTime)
			continue;
		
		z4e_alarm_insert(_, "巴哈姆特的终极元素释放失败", "", "", { 250,50,50 }, 2.0)
		bShouldKill = 0;
		break;
	}
	
	
	pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, 2000.0)) && pev_valid(pEntity))
	{
		//if(!is_user_alive(pEntity))
		//	continue;
		if(!is_user_alive(pEntity))
			continue;
		
		message_begin(MSG_ONE_UNRELIABLE, gmsgScreenFade, _, pEntity)
		write_short((1<<12)) // duration
		write_short((1<<12)) // hold time
		write_short((0x0000)) // fade type
		write_byte(250)
		write_byte(50)
		write_byte(50)
		write_byte(255) // alpha
		message_end()
		
		
		message_begin(MSG_ONE, gmsgScreenShake, _, pEntity)
		write_short((1<<12) * 10) // amplitude
		write_short((1<<12) * 10) // duration
		write_short((1<<12) * 10) // frequency
		message_end()
		
		if(!z4e_team_get_user_zombie(pEntity) && bShouldKill)
		{
			user_kill(pEntity, 1);
		}
	}
	
	ExplodeEffect(vecOrigin, 250, 50, 50);
	LightEffect(vecOrigin, 250, 50, 50);
	
	emit_sound(this, CHAN_AUTO, ELEMENT_SOUND[ELEMENT_ULTIMA], 1.0, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(this, CHAN_AUTO, BOSS_BAHAMUT_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	if(bShouldKill)
		z4e_alarm_insert(_, "巴哈姆特的终极元素带来了末日", "", "", { 250,50,50 }, 2.0)
	
	set_pev(this, pev_iuser1, BAHAMUT_SKILL_NONE);
}

ImplosionEffect(Float:vecOrigin[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_IMPLOSION) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	write_byte(500) // radius
	write_byte(20) // count
	write_byte(2) // duration
	message_end()
}

ExplodeEffect(Float:vecOrigin[3], r, g, b)
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, vecOrigin[2]) // z
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, vecOrigin[2]+385.0) // z axis
	write_short(g_iSprBeam) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(15) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(r) // red
	write_byte(g) // green
	write_byte(b) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, vecOrigin[2]) // z
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, vecOrigin[2]+470.0) // z axis
	write_short(g_iSprBeam) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(15) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(r) // red
	write_byte(g) // green
	write_byte(b) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, vecOrigin[2]) // z
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, vecOrigin[2]+555.0) // z axis
	write_short(g_iSprBeam) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(15) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(r) // red
	write_byte(g) // green
	write_byte(b) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

ElementUltima_Effect(iEntity)
{
	new Float:vecOrigin[3];
	pev(iEntity, pev_origin, vecOrigin)
	
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_ALL, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BEAMDISK) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, vecOrigin[2]) // z
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, vecOrigin[2]+555.0) // z axis
	write_short(g_iSprBeam) // sprite
	write_byte(0) // startframe
	write_byte(15) // framerate
	write_byte(15) // life
	write_byte(60) // width
	write_byte(1) // noise
	write_byte(75) // red
	write_byte(75) // green
	write_byte(75) // blue
	write_byte(200) // brightness
	write_byte(5) // speed
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_ALL, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_BEAMENTPOINT)
	write_short(iEntity) //start entity
	engfunc(EngFunc_WriteCoord, vecOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, vecOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 2048.0) // z
	write_short(g_iSprBeam) //modelindex
	write_byte(0) //starting frame
	write_byte(10) //frame rate in 0.1's
	write_byte(11) //life in 0.1's
	write_byte(127) //line width in 0.1's
	write_byte(10) // noise amplitude in 0.01's
	write_byte(75) // red
	write_byte(75) // green 
	write_byte(75) // blue
	write_byte(200) // brightness
	write_byte(15) // scroll speed in 0.1's
	message_end()
}

LightEffect(Float:vecOrigin[3], r, g, b)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_DLIGHT) // TE id
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	write_byte(250) // radius
	write_byte(r) // red
	write_byte(g) // green
	write_byte(b) // blue
	write_byte(10) // life
	write_byte(2000) // decay rate
	message_end()
}

EarthBarrierSpawn()
{
	
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_breakable"))
	if(!iEntity)
		return;
	set_pev(iEntity, pev_classname, EARTH_BARRIER_CLASSNAME)
	
	engfunc(EngFunc_SetModel, iEntity, EARTH_BARRIER_MODEL)
	set_pev(iEntity, pev_modelindex, engfunc(EngFunc_ModelIndex, EARTH_BARRIER_MODEL))
	
	new Float:vecMins[3] = {-200.0, -50.0, -85.0}
	new Float:vecMaxs[3] = {200.0, 50.0, 100.0}
	engfunc(EngFunc_SetSize, iEntity, vecMins, vecMaxs)
	set_pev(iEntity, pev_angles, { 0.0, 90.0, 0.0})
		
	set_pev(iEntity, pev_movetype, MOVETYPE_NONE)
	set_pev(iEntity, pev_solid, SOLID_SLIDEBOX)

	//vecEnd[2] += 100.0
	
	engfunc(EngFunc_SetOrigin, iEntity, { 443.0, 1698.0, -2955.0})
	
	set_pev(iEntity, pev_gravity, 0.0)
	set_pev(iEntity, pev_gamestate, 0.0)
		
	set_pev(iEntity, pev_health, 2333333333.0)
	set_pev(iEntity, pev_takedamage, DAMAGE_NO)
	
	set_pev(iEntity, pev_nextthink, get_gametime() + 5.0)
	
	set_pdata_int(iEntity, m_Material, matWood, OFFSET_LINUX_BREAKABLE)
}

stock SpawnBlood(const Float:vecOrigin[3], iColor, iAmount)
{
	if(iAmount == 0)
		return

	iAmount *= 2
	
	if(iAmount > 255)
		iAmount = 255
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin)
	write_byte(TE_BLOODSPRITE)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	write_short(m_iBlood[1])
	write_short(m_iBlood[0])
	write_byte(iColor)
	write_byte(min(max(3, iAmount / 10), 16))
	message_end()
}

stock CheckPointIn(const Float:vecOrigin[3], const Float:vecMins[3], const Float:vecMaxs[3])
{
	if(vecOrigin[0] < vecMins[0] || vecOrigin[0] > vecMaxs[0])
		return 0;
	if(vecOrigin[1] < vecMins[1] || vecOrigin[1] > vecMaxs[1])
		return 0;
	if(vecOrigin[2] < vecMins[2] || vecOrigin[2] > vecMaxs[2])
		return 0;
	return 1;
}

stock PlaySound(index, const szSound[], stop_sounds_first = 0)
{
	if(!szSound[0])
		return
	if (stop_sounds_first)
	{
		if (equal(szSound[strlen(szSound)-4], ".mp3"))
			client_cmd(index, "stopsound; mp3 play ^"sound/%s^"", szSound)
		else
			client_cmd(index, "mp3 stop; stopsound; spk ^"%s^"", szSound)
	}
	else
	{
		if (equal(szSound[strlen(szSound)-4], ".mp3"))
			client_cmd(index, "mp3 play ^"sound/%s^"", szSound)
		else
			client_cmd(index, "spk ^"%s^"", szSound)
	}
}

stock GetGunPosition(id, Float:vecOut[3])
{
	new Float:vecOrigin[3]; pev(id, pev_origin, vecOrigin)
	new Float:vecViewOfs[3]; pev(id, pev_view_ofs, vecViewOfs)
	xs_vec_add(vecOrigin, vecViewOfs, vecOut)
}

stock FindHullIntersection(Float:vecSrc[3], &ptr, Float:flMins[3], Float:fkMaxs[3], pEntity)
{
	new ptrTemp = create_tr2();
	new Float:flDistance = 1000000.0;

	new Float:flMinMaxs[2][3]
	for(new i;i<3;i++)
	{
		flMinMaxs[0][i] = flMins[i];
		flMinMaxs[1][i] = fkMaxs[i];
	}
	new Float:vecHullEnd[3]
	get_tr2(ptr, TR_vecEndPos, vecHullEnd)
	
	new Float:vecTemp[3]
	xs_vec_sub(vecHullEnd, vecSrc, vecTemp);
	xs_vec_mul_scalar(vecTemp, 2.0, vecTemp);
	xs_vec_add(vecSrc, vecTemp, vecHullEnd)
	
	engfunc(EngFunc_TraceLine, vecSrc, vecHullEnd, DONT_IGNORE_MONSTERS, pEntity, ptrTemp);
	
	new Float:flFraction
	get_tr2(ptrTemp, TR_flFraction, flFraction)
	
	if (flFraction < 1.0)
	{
		free_tr2(ptr)
		ptr = ptrTemp
		return ptr;
	}
	
	for(new i; i < 2; i++)
	{
		for(new j; j < 2; j++)
		{
			for(new k; k < 2; k++)
			{
				new Float:vecEnd[3];
				for(new l;l < 3;l++)
				{
					vecEnd[l] = vecHullEnd[l] + flMinMaxs[i][l];
					vecEnd[l] = vecHullEnd[l] + flMinMaxs[j][l];
					vecEnd[l] = vecHullEnd[l] + flMinMaxs[k][l];
				}
				
				engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, pEntity, ptrTemp)
				
				get_tr2(ptrTemp, TR_flFraction, flFraction)
				if (flFraction < 1.0)
				{
					new Float:vecEndPos[3]
					get_tr2(ptrTemp, TR_vecEndPos, vecEndPos)
					xs_vec_sub(vecEndPos, vecSrc, vecTemp);
					new Float:flThisDistance = xs_vec_len(vecTemp)
					if (flThisDistance < flDistance)
					{
						free_tr2(ptr)
						ptr = ptrTemp
						flDistance = flThisDistance;
						return ptr;
					}
				}
			}
		}
	}
	return ptr;
}

stock KnockBack_Set(id, iAttacker, Float:flGround = -1.0, Float:flAir = -1.0, Float:flFly = -1.0, Float:flDuck = -1.0, Float:flVelocityModifier = -1.0)
{
	new Float:flKnockBack
	if(pev(id, pev_flags) & FL_ONGROUND)
	{
		if(pev(id, pev_flags) & FL_DUCKING)
			flKnockBack = flDuck
		else
			flKnockBack = flGround
	}
	else
	{
		new Float:vecVelocity[3]
		pev(id, pev_velocity, vecVelocity)
		vecVelocity[2] = 0.0
		if(xs_vec_len(vecVelocity) > 140.0)
			flKnockBack = flFly
		else
			flKnockBack = flAir
	}
	
	if(flKnockBack > 0.0)
	{
		new Float:vecOriginVictim[3]; pev(id, pev_origin, vecOriginVictim)
		new Float:vecOriginAttacker[3]; pev(iAttacker, pev_origin, vecOriginAttacker)
		new Float:vecVelocity[3]; pev(id, pev_velocity, vecVelocity)
		
		new Float:vecDelta[3]
		xs_vec_sub(vecOriginVictim, vecOriginAttacker, vecDelta)
		vecDelta[2] = 0.0 
		xs_vec_normalize(vecDelta, vecDelta)
		xs_vec_mul_scalar(vecDelta, flKnockBack, vecDelta)
		xs_vec_add(vecVelocity, vecDelta, vecVelocity)
		
		set_pev(id, pev_velocity, vecVelocity)
	}
	if(flVelocityModifier > 0.0)
		set_pdata_float(id, m_flVelocityModifier, flVelocityModifier)
	return true
}