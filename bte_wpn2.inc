#define PLUGIN_NAME	"BTE Weapon Base"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"BTE TEAM"

#define BTE_WPN_FILE "weapons.lst"
#define BTE_MYWPN_FILE "weapons_precache.lst"
#define PRECACHE_MAX	50
#define BTE_LOG_FILE	"bte_wpn_log.log"
#define BTE_CONFIG_FILE	"bte_wpn_config.ini"

#define MODEL_URL	"models"
#define SPR_URL		"sprites"
#define SOUND_URL	"weapons"

#define IS_ZBMODE	(g_modruning == BTE_MOD_ZB1)

new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame

native bte_zb3_is_boomer_skilling(id)


native BTE_SetThink(iEnt, const function[]);
native BTE_SetTouch(iEnt, const function[]);
native Float:GetKickBack(szName[], a, b)
native Float:GetWeaponData(szName[], iType)


/* idwpn default */
// CSW_KNIFE	1
// CSW_GLOCK18	2
// CSW_USP	3

#define PRINT(%1) client_print(1,print_chat,%1)
#define SPRINT(%1) server_print(%1)
#define write_coord_f(%0) ( engfunc( EngFunc_WriteCoord, %0 ) )
#define MAX_WPN		512
#define MAX_WPN_RIFLES	256
#define MAX_WPN_PISTOLS	128
#define MAX_WPN_KNIFES	64
#define MAX_WPN_HES	64
#define CSW_END		CSW_P90+1

#define MAX_MYWPN_RIFLES	100
#define MAX_MYWPN_PISTOLS	50
#define MAX_MYWPN_KNIFES	20
#define MAX_MYWPN_HES	20
#define WPN_SLOT	4

#define CHANNEL_SVDEX	1
#define MAX_BLOCK	256

// Save Weapon Data
#define DEF_ISWEAPONBOX	11
#define DEF_SPAWN	12
#define DEF_ID		13
#define DEF_CLIP	14
#define DEF_AMMO	15
#define DEF_OWNER	16
#define DEF_ISDOUBLE	17
#define DEF_ISDROPPED	18
// Save Entity Data
#define DEF_ENTCLASS	19
#define DEF_ENTID		20
#define DEF_ENTSTAT		21

#define Set_Ent_Data(%1,%2,%3) set_pdata_int(%1,%2,%3,4)
#define Get_Ent_Data(%1,%2) get_pdata_int(%1,%2,4)
#define Set_Wpn_Data(%1,%2,%3) set_pdata_int(%1,%2,%3,4)
#define Get_Wpn_Data(%1,%2) get_pdata_int(%1,%2,4)

#define MAXMENUPOS 26
new g_Aliases[MAXMENUPOS][] = {"usp","glock","deagle","p228","elites","fn57","m3","xm1014","mp5","tmp","p90","mac10","ump45","ak47","galil","famas","sg552","m4a1","aug","scout","awp","g3sg1","sg550","m249","hegren","shield"}
new g_Aliases2[MAXMENUPOS][] = {"km45","9x19mm","nighthawk","228compact","elites","fiveseven","12gauge","autoshotgun","smg","mp","c90","mac10","ump45","cv47","defender","clarion","krieg552","m4a1","bullpup","scout","magnum","d3au1","krieg550","m249","hegren","hegren"}

new Float:g_vecZero[3]={0.0,0.0,0.0}

new const RELOAD_ANIM[CSW_P90+1] = {
	-1,  5, -1, 3, -1,  6,   -1, 1, 1, -1, 14,
		4,  1, 3,  1,  1,   13, 7, 4,  1,  3,
		6, 11, 1,  3, -1,    4, 1, 1, -1,  1
}
new const Float:WEAPON_DELAY[CSW_P90+1] = {
	0.00, 2.70, 0.00, 2.00, 0.00, 0.55,   0.00, 3.15, 3.30, 0.00, 4.50,
		 2.70, 3.50, 3.35, 2.45, 3.30,   2.70, 2.20, 2.50, 2.63, 4.70,
		 0.55, 3.05, 2.12, 3.50, 0.00,   2.20, 3.00, 2.45, 0.00, 3.40
}

new const CSWPN_POSITION[] = { 0,3,0,9,1,12,3,13,14,3,5,6,15,16,17,18,4,2,2,7,4,5,6,11,3,2,1,10,1,1,8,0}
new const WEAPON_NAME[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90"
}
new const WEAPON_TOTALANIM[]={0,7,0,5,0,7,0,6,6,0,16,6,6,5,6,6,16,13,6,6,5,7,14,6,5,0,6,6,6,0,6,0}
//new const WEAPON_EVENT[]={0,18,0,4,0,11,0,13,8,0,24,15,14,9,27,28,12,20,1,21,5,10,6,22,2,0,17,0,3,19,16}
new const WEAPON_AMMOID[] = { -1, 9, -1, 2, 12, 5, 14, 6, 4, 13, 10, 7, 6, 4, 4, 4, 6, 10,
			1, 10, 3, 5, 4, 10, 2, 11, 8, 4, 2, -1, 7
}
new const WEAPON_AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp",
			"556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot",
			"556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm"
}
enum _:(+=2) {
	ammo_buckshot = 11,
	ammo_9mm,
	ammo_556nato,
	ammo_556natobox,
	ammo_762nato,
	ammo_45acp,
	ammo_50ae,
	ammo_338Magnum,
	ammo_57mm,
	ammo_357sig
}

enum _: {
	BULLET_NONE = 0,
	BULLET_PLAYER_9MM,
	BULLET_PLAYER_MP5,
	BULLET_PLAYER_357,
	BULLET_PLAYER_BUCKSHOT,
	BULLET_PLAYER_CROWBAR,

	BULLET_MONSTER_9MM,
	BULLET_MONSTER_MP5,
	BULLET_MONSTER_12MM,

	BULLET_PLAYER_45ACP,
	BULLET_PLAYER_338MAG,
	BULLET_PLAYER_762MM,
	BULLET_PLAYER_556MM,
	BULLET_PLAYER_50AE,
	BULLET_PLAYER_57MM,
	BULLET_PLAYER_357SIG
}

// cs wepaon type bit sum
const CSWPN_NOCLIP	= ((1<<2)|(1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4))
const CSWPN_NOTREMOVE = (1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_C4)
const CSWPN_SHOTGUNS	= ((1<<CSW_M3)|(1<<CSW_XM1014))
const CSWPN_SILENT	= ((1<<CSW_USP)|(1<<CSW_M4A1))
const CSWPN_SNIPER	= ((1<<CSW_SCOUT)|(1<<CSW_SG550)|(1<<CSW_AWP)|(1<<CSW_G3SG1))
const CSWPN_FIRSTZOOM	= ((1<<CSW_AUG)|(1<<CSW_SG552))
const CSWPN_BURST	= ((1<<CSW_FAMAS)|(1<<CSW_GLOCK18))
const NOSHOOT2_BS = ((1<<CSW_KNIFE)|(1<<CSW_GLOCK18)|(1<<CSW_ELITE))
const CSWPN_SEC = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)

//Weapon/Player Offset
const m_rgpWeaponBoxPlayerItems	 = 34
const m_fKnown			= 44
const m_iPrimaryAmmoType	= 49
const m_rgpPlayerItems = 367
const m_iTeam			= 114
const m_flEjectBrass = 111

const m_iDefaultAmmo = 56
const m_flFamasShoot = 71
const m_iFamasShotsFired = 72
const m_fHasBeenKilledLastRound = 113
stock m_fFireOnEmpty = 45 // int
stock m_iDirection = 60
stock m_IdealActivity = 74
stock m_LastHitGroup = 75

// CBaseEntity
stock m_iSwing = 32 // int
// CBaseMonster
stock m_flNextAttack = 83 // float
// CBasePlayer
stock random_seed = 96 // int
stock m_flVelocityModifier = 108 // float
stock m_iLastZoom = 109 // int
stock m_bResumeZoom = 440 // bool
stock m_iWeaponVolume = 239 // int
stock m_iWeaponFlash = 241 // int
stock m_iFOV = 363 // int
stock m_pActiveItem = 373 // CBasePlayerItem *
stock m_szAnimExtention = 492 // char [32]
stock m_bShieldDrawn = 2002 // bool
// CBasePlayerItem
stock m_pPlayer = 41 // CBasePlayer *
stock m_pNext = 42 // CBasePlayerItem *
stock m_iId = 43 // int
// CBasePlayerWeapon
stock m_flNextPrimaryAttack = 46 // float
stock m_flNextSecondaryAttack = 47 // float
stock m_flTimeWeaponIdle = 48 // float
stock m_iClip = 51 // int
stock m_fInReload = 54 // int
stock m_fInSpecialReload = 55 // int
stock m_fMaxSpeed = 58 // float
stock m_bDelayFire = 236 // bool
stock m_flAccuracy = 62 // float
stock m_flLastFire = 63 // float
stock m_iShotsFired = 64 // int
stock m_iWeaponState = 74 // int
stock m_flNextReload = 75 // float
stock m_flDecreaseShotsFired = 76 // float

#define LOUD_GUN_VOLUME 1000
#define NORMAL_GUN_VOLUME 600
#define QUIET_GUN_VOLUME 200

#define BRIGHT_GUN_FLASH 512
#define NORMAL_GUN_FLASH 256
#define DIM_GUN_FLASH 128

#define BIG_EXPLOSION_VOLUME 2048
#define NORMAL_EXPLOSION_VOLUME 1024
#define SMALL_EXPLOSION_VOLUME 512

#define WEAPON_ACTIVITY_VOLUME 64

#define WPNSTATE_USP_SILENCED (1<<0)
#define WPNSTATE_GLOCK18_BURST_MODE (1<<1)
#define WPNSTATE_M4A1_SILENCED (1<<2)
#define WPNSTATE_ELITE_LEFT (1<<3)
#define WPNSTATE_FAMAS_BURST_MODE (1<<4)
#define WPNSTATE_SHIELD_DRAWN (1<<5)

#define WPNSTATE_M134_IDLE 0
#define WPNSTATE_M134_SPIN_UP (1<<6)
#define WPNSTATE_M134_SPINNING (1<<7)
#define WPNSTATE_M134_SPIN_DOWN (1<<8)

#define WPNSTATE_M16A1_SEMIAUTO (1<<0)
#define WPNSTATE_SKULL1_AUTO (1<<0)
#define WPNSTATE_SFMG_MODEB (1<<0)
#define WPNSTATE_SKULL11_SLUG (1<<0)
#define WPNSTATE_SVDEX_GRENADE (1<<0)
#define WPNSTATE_M1GARAND_AIMING (1<<0)
#define WPNSTATE_RPG_AIMING (1<<0)
#define WPNSTATE_RAILCANNON_CHARGE (1<<0)
#define WPNSTATE_HAMMER_STAB	(1<<0)


const m_rgAmmo_player_Slot0	= 376
const m_Activity		= 73
//const m_rgAmmo = 376
stock m_rgAmmo[] = { 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407 } // int
const EXTRAOFFSET = 4
const OFFSET_LINUX = 5
const OFFSET_LINUX_WEAPONS = 4
const OFFSET_WEAPONCLIP = 52
const OFFSET_AWM_AMMO  = 377
const OFFSET_SCOUT_AMMO = 378
const OFFSET_PARA_AMMO = 379
const OFFSET_FAMAS_AMMO = 380
const OFFSET_M3_AMMO = 381
const OFFSET_USP_AMMO = 382
const OFFSET_FIVESEVEN_AMMO = 383
const OFFSET_DEAGLE_AMMO = 384
const OFFSET_P228_AMMO = 385
const OFFSET_GLOCK_AMMO = 386
const OFFSET_FLASH_AMMO = 387
const OFFSET_HE_AMMO = 388
const OFFSET_SMOKE_AMMO = 389
const OFFSET_C4_AMMO = 390
const OFFSET_CLIPAMMO = 51
const OFFSET_ZOOMTYPE	= 363

enum
{
	STATUS_MODE1 = 0,
	STATUS_CHANGE1,
	STATUS_CHANGE2,
	STATUS_MODE2
}

enum _:BUFF_STAT(+=1)
{
	BUFF_START = 0,
	BUFF_FLAME,
	BUFF_HOLY,
	BUFF_FIRE,
	BUFF_END
}
enum _:WEAPON_SPECIAL
{
	SPECIAL_M134EX=1, /////
	SPECIAL_HAMMER,   /////
	SPECIAL_INFINITY, /////
	SPECIAL_MUSKET,   /////
	SPECIAL_CROSSBOW, ///// -- 5
	SPECIAL_SKULL1,   /////
	SPECIAL_HOLYBOMB, /////
	SPECIAL_AT4CS,    /////
	SPECIAL_SKULLAXE, /////
	SPECIAL_DRAGONTAIL, ///// --- 10
	SPECIAL_CATAPULT, /////
	SPECIAL_CANNON,   /////
	SPECIAL_KATANA,   /////
	SPECIAL_STRONGKNIFE,/////
	SPECIAL_TRACER,   ///// --- 15
	SPECIAL_M79,	  /////
	SPECIAL_FIRECRAKER, /////
	SPECIAL_VIOLIN,    /////
	SPECIAL_FIREBOMB,  /////
	SPECIAL_POISON,    ///// --- 20
	SPECIAL_BALROG7,   /////
	SPECIAL_SKULL3,    /////
	SPECIAL_SFMG,     //////
	SPECIAL_BAZOOKA, //////
	SPECIAL_ZG ,        ///// --- 25
	SPECIAL_HERO,
	SPECIAL_SFSNIPER,
	SPECIAL_OICW,
	SPECIAL_M249EP,
	SPECIAL_BALROG9, ///// --- 30
	SPECIAL_BALROG5,
	SPECIAL_BALROG1,
	SPECIAL_CHAINSAW,
	SPECIAL_QBARREL,
	SPECIAL_BALROG3, ////--- 35
	SPECIAL_M16A1,
	SPECIAL_COILGUN,
	SPECIAL_FIXSHOOT,
	SPECIAL_SPAS12EX,
	SPECIAL_SPAS12EX2, ///// --- 40
	SPECIAL_BALROG11,
	SPECIAL_M200,
	SPECIAL_PLASMA,
	SPECIAL_WATERCANNON,
	SPECIAL_SFSWORD,//// ----- 45
	SPECIAL_SKULL8,
	SPECIAL_TKNIFE,
	SPECIAL_JANUSMK5,
	SPECIAL_BOW,
	SPECIAL_JANUS7, ///// ---- 50
	SPECIAL_DGUN,
	SPECIAL_DRAGONSWORD,
	SPECIAL_JKNIFE,
	SPECIAL_M2,
	SPECIAL_JANUS1, ///// ----- 55
	SPECIAL_KATANAD,
	SPECIAL_SPEARGUN,
	SPECIAL_PETROLBOOMER,
	SPECIAL_SFPISTOL,
	SPECIAL_SKULL11,  ///// ----- 60
	SPECIAL_MAUSERC96,
	SPECIAL_RAILCANNON,
	SPECIAL_GILBOAEX,
	SPECIAL_M1GARAND,
	SPECIAL_RPG, ///// ----- 65
	SPECIAL_FFF,
	SPECIAL_DESTROYER,
	SPECIAL_SPSMG,
	SPECIAL_AIRBURSTER,
	SPECIAL_SGDRILL,	///// ----- 70
	SPECIAL_BLOCKAR,
	SPECIAL_STORMGIANT,
	SPECIAL_BUFFM4A1,
	SPECIAL_BUFFAK47,
	SPECIAL_GAUSS,	///// ----- 75
	SPECIAL_BUFFSG552,
	SPECIAL_CANNONEX,
	SPECIAL_BUFFAWP,
	SPECIAL_BLOODHUNTER,
	SPECIAL_GUILLOTINE, //// ----- 80
	SPECIAL_RUNEBLADE,
	SPECIAL_THANATOS5,
	SPECIAL_THANATOS7,
	SPECIAL_THANATOS1,
	SPECIAL_THANATOS9, //// ---- 85
	SPECIAL_JANUS9,
	SPECIAL_BLOCKSMG,
	SPECIAL_CROW9,
	SPECIAL_CROW7,
	SPECIAL_CROW1, //// ---- 90
	SPECIAL_STERLINGBAYONET,
	SPECIAL_AUGEX,
	SPECIAL_DESPERADO,
	SPECIAL_DUALSWORD,
	SPECIAL_JANUS11, //// ---- 95
	SPECIAL_GUNKATA
}
enum _:ENTITY_CLASS (+=100)
{
	ENTCLASS_NADE=2000,
	ENTCLASS_NADE_BOUNCE,
	ENTCLASS_BOLT,
	ENTCLASS_PLASMA,
	ENTCLASS_SMOKE,
	ENTCLASS_TKNIFE,
	ENTCLASS_KILLME,
	ENTCLASS_BOW,
	ENTCLASS_DGUN,
	ENTCLASS_SPEARGUN,
	ENTCLASS_PETROL,
	ENTCLASS_DESTROYER,
	ENTCLASS_BLOCKMISSILE,
	ENTCLASS_BOW,
	ENTCLASS_FADEIN
}

enum _:WPN_SLOT_TYPE
{
	WPN_RIFLE = 1,
	WPN_PISTOL,
	WPN_KNIFE,
	WPN_HE
}

enum _:WPN_TYPE
{
	WEAPONS_NORMAL = 1,  //
	WEAPONS_DOUBLE,      //
	WEAPONS_LAUNCHER,	//
	WEAPONS_SHOTGUN,     //
	WEAPONS_M134,        //
	WEAPONS_SPSHOOT,     //
	WEAPONS_FLAMETHROWER, //
	WEAPONS_BAZOOKA, //
	WEAPONS_M32, // 9
	WEAPONS_SVDEX,
	WEAPONS_CHAINSAW,
	WEAPONS_FG, //12
	WEAPONS_CUSTOM,
	WEAPONS_SPAS12,
	WEAPONS_PLASMA, //15
	WEAPONS_SINGLE,
	WEAPONS_SHOTGUN_RELOAD,
	WEAPONS_BLOCK_RIGHT,
	WEAPONS_PISTOL
}


// fake damage
enum _:FAKEDAMAGETYPE
{
	FAKE_TYPE_HULL = (1<<1),
	FAKE_TYPE_GENER = (1<<2),
	FAKE_TYPE_GENER_HEAD = (1<<3), //for flamethrower
	FAKE_TYPE_TRACEBLEED = (1<<4),
	FAKE_TYPE_CHECKDIRECT = (1<<5),
	FAKE_TYPE_CHECKPHIT = (1<<6),
	FAKE_TYPE_HITHEAD = (1<<7)
}
enum _:FAKEDAMAGERESULT
{
	FAKE_RESULT_HIT_PLAYER,
	FAKE_RESULT_HIT_WALL,
	FAKE_RESULT_HIT_NONE
}
enum _:FAKEBUTTON
{
	FAKE_SLASH = 1,
	FAKE_STAB
}
// Weapon anim
enum _:SHOTGUN_ANIM
{
	SHOTGUN_idle,
	SHOTGUN_shoot1,
	SHOTGUN_shoot2,
	SHOTGUN_insert,
	SHOTGUN_after_reload,
	SHOTGUN_start_reload,
	SHOTGUN_draw
}
enum _:INFINITY_ANIM
{
	INFINITY_idle,
	INFINITY_idle_leftempty,
	shoot_left_1,
	shoot_left_2,
	shoot_left_3,
	shoot_left_4,
	shoot_left_5,
	shoot_leftlast,
	shoot_right_1,
	shoot_right_2,
	shoot_right_3,
	shoot_right_4,
	shoot_right_5,
	shoot_rightlast,
	INFINITY_reload,
	INFINITY_draw,
	SP_shoot_left_1, //16
	SP_shoot_left_2,
	SP_shoot_right_1,
	SP_shoot_right_2
}
// Launcher
enum _:Launcher_Anim
{
	LAUNCHER_Anim_Draw,
	LAUNCER_Anim_Shoot,
	LAUNCER_Anim_ShootLast
}
// M134 Stat


enum _:MUSKET_STAT
{
	MUSKET_IDLE,
	MUSKET_PREFIRE
}
enum _:KNIFE_DELAY_ANIM
{
	KNIFE_IDLE = 0,
	KNIFE_PRE,
	KNIFE_CD
}
enum _:Sfsword_Anim
{
	Sfsword_idel = 0,
	Sfsword_on,
	Sfsword_off,
	Sfsword_draw,
	Sfsword_stab,
	Sfsword_stab_miss,
	Sfsword_midslash1,
	Sfsword_midslash2,
	Sfsword_midslash3,
	Sfsword_off_idle,
	Sfsword_off_slash1
}

enum _:M2_Anim
{
	M2_idleA = 0,
	M2_idleB,
	M2_draw,
	M2_draw_empty,
	M2_changeA,
	M2_changeA_empty,
	M2_changeB,
	M2_changeB_empty,
	M2_reloadA,
	M2_reloadB,
	M2_shootA,
	M2_shootB,
	M2_idleA_empty,
	M2_idleB_empty
}

enum _:M134_Anim
{
	M134_idle = 0,
	M134_draw,
	M134_reload,
	M134_fire_ready,
	M134_shoot,
	M134_fire_after,
	M134_fire_change,
	M134_idle_change
}

#define DMG_GENERIC 0
#define DMG_CRUSH (1<<0)
#define DMG_BULLET (1<<1)
#define DMG_SLASH (1<<2)
#define DMG_BURN (1<<3)
#define DMG_FREEZE (1<<4)
#define DMG_FALL (1<<5)
#define DMG_BLAST (1<<6)
#define DMG_CLUB (1<<7)
#define DMG_SHOCK (1<<8)
#define DMG_SONIC (1<<9)
#define DMG_ENERGYBEAM (1<<10)
#define DMG_NEVERGIB (1<<12)
#define DMG_ALWAYSGIB (1<<13)
#define DMG_DROWN (1<<14)
//#define DMG_TIMEBASED (~(0x3FFF))

#define DMG_PARALYZE (1<<15)
#define DMG_NERVEGAS (1<<16)
#define DMG_POISON (1<<17)
#define DMG_RADIATION (1<<18)
#define DMG_DROWNRECOVER (1<<19)
#define DMG_ACID (1<<20)
#define DMG_SLOWBURN (1<<21)
#define DMG_SLOWFREEZE (1<<22)
#define DMG_MORTAR (1<<23)
#define DMG_EXPLOSION (1<<24)
#define DMG_GIB_CORPSE (DMG_CRUSH | DMG_FALL | DMG_BLAST | DMG_SONIC | DMG_CLUB)
#define DMG_SHOWNHUD (DMG_POISON | DMG_ACID | DMG_FREEZE | DMG_SLOWFREEZE | DMG_DROWN | DMG_BURN | DMG_SLOWBURN | DMG_NERVEGAS | DMG_RADIATION | DMG_SHOCK)

enum _:HITGROUP
{
	HITGROUP_GENERIC = 0,
	HITGROUP_HEAD,
	HITGROUP_CHEST,
	HITGROUP_STOMACH,
	HITGROUP_LEFTARM,
	HITGROUP_RIGHTARM,
	HITGROUP_LEFTLEG,
	HITGROUP_RIGHTLEG,
	HITGROUP_SHIELD
}

#define JANUSMK5_CANUSE		1
#define JANUSMK5_USING		2


#define VEC_DUCK_HULL_MIN  Float:{-16.0, -16.0, -18.0}
#define VEC_DUCK_HULL_MAX Float:{16.0, 16.0, 32.0}
#define VEC_DUCK_VIEW Float:{0.0, 0.0, 12.0}

#define dont_ignore_monsters 0
#define head_hull 3

enum _:HIT_RESULT
{
	RESULT_HIT_NONE = 0,
	RESULT_HIT_PLAYER,
	RESULT_HIT_WORLD
}

enum _:PLAYER_ANIM
{
	PLAYER_IDLE = 0,
	PLAYER_WALK,
	PLAYER_JUMP,
	PLAYER_SUPERJUMP,
	PLAYER_DIE,
	PLAYER_ATTACK1,
	PLAYER_ATTACK2,
	PLAYER_FLINCH,
	PLAYER_LARGE_FLINCH,
	PLAYER_RELOAD,
	PLAYER_HOLDBOMB
}

enum _:SEND_KNIFE_SOUND_TYPE
{
	TYPE_SWING = 1,
	TYPE_SWING_PLAYER,
	TYPE_WORLD,
	TYPE_STAB,
	TYPE_STAB_PLAYER,
	TYPE_DRAW
}

#define KNIFE_BODYHIT_VOLUME 128
#define KNIFE_WALLHIT_VOLUME 512

#define PLAYERBONE_PELVIS 1
#define PLAYERBONE_SPINE 2
#define PLAYERBONE_SPINE1 3
#define PLAYERBONE_SPINE2 4
#define PLAYERBONE_SPINE3 5
#define PLAYERBONE_NECK 6
#define PLAYERBONE_HEAD 7
#define PLAYERBONE_L_CLAVICLE 9
#define PLAYERBONE_L_UPPERARM 10
#define PLAYERBONE_L_FOREARM 11
#define PLAYERBONE_L_HAND 12
#define PLAYERBONE_L_FINGER0 13
#define PLAYERBONE_L_FINGER01 14
#define PLAYERBONE_L_FINGER1 15
#define PLAYERBONE_L_FINGER11 16
#define PLAYERBONE_L_THIGH 40
#define PLAYERBONE_L_CALF 41
#define PLAYERBONE_L_FOOT 42
#define PLAYERBONE_R_CLAVICLE 23
#define PLAYERBONE_R_UPPERARM 24
#define PLAYERBONE_R_FOREARM 25
#define PLAYERBONE_R_HAND 26
#define PLAYERBONE_R_FINGER0 27
#define PLAYERBONE_R_FINGER01 28
#define PLAYERBONE_R_FINGER1 29
#define PLAYERBONE_R_FINGER11 30
#define PLAYERBONE_R_THIGH 46
#define PLAYERBONE_R_CALF 47
#define PLAYERBONE_R_FOOT 48

native LookupSequence(id, szAnim[]);
//native GetModelAttachment(szName[], iAttachment, Float:vecOrigin[3]);

#define TRUE 1
#define FALSE 0

// TextMsg
#define HUD_PRINTNOTIFY 1
#define HUD_PRINTCONSOLE 2
#define HUD_PRINTTALK 3
#define HUD_PRINTCENTER 4
#define HUD_PRINTRADIO 5

stock m_iAccount = 115

stock m_iKevlar = 112
#define TEAM_CT 2

// CArmoury
stock m_iItem = 34 // int
stock m_iCount = 35 // int
stock m_iSaveCount = 36 // int
stock m_bRestoreCount = 148 // bool

#define ARMOURY_MP5NAVY 0
#define ARMOURY_TMP 1
#define ARMOURY_P90 2
#define ARMOURY_MAC10 3
#define ARMOURY_AK47 4
#define ARMOURY_SG552 5
#define ARMOURY_M4A1 6
#define ARMOURY_AUG 7
#define ARMOURY_SCOUT 8
#define ARMOURY_G3SG1 9
#define ARMOURY_AWP 10
#define ARMOURY_M3 11
#define ARMOURY_XM1014 12
#define ARMOURY_M249 13
#define ARMOURY_FLASHBANG 14
#define ARMOURY_HEGRENADE 15
#define ARMOURY_KEVLAR 16
#define ARMOURY_ASSAULT 17
#define ARMOURY_SMOKEGRENADE 18

stock m_bIsVIP = 837 // bool

// cbase.h
#define CLASS_NONE 0
#define CLASS_MACHINE 1
#define CLASS_PLAYER 2
#define CLASS_HUMAN_PASSIVE 3
#define CLASS_HUMAN_MILITARY 4
#define CLASS_ALIEN_MILITARY 5
#define CLASS_ALIEN_PASSIVE 6
#define CLASS_ALIEN_MONSTER 7
#define CLASS_ALIEN_PREY 8
#define CLASS_ALIEN_PREDATOR 9
#define CLASS_INSECT 10
#define CLASS_PLAYER_ALLY 11
#define CLASS_PLAYER_BIOWEAPON 12
#define CLASS_ALIEN_BIOWEAPON 13
#define CLASS_VEHICLE 14
#define CLASS_BARNACLE 99

#define SIGNAL_BUY (1<<0)
#define SIGNAL_BOMB (1<<1)
#define SIGNAL_RESCUE (1<<2)
#define SIGNAL_ESCAPE (1<<3)
#define SIGNAL_VIPSAFETY (1<<4)