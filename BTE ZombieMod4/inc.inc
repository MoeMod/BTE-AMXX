#define PRINT(%1) client_print(1,print_chat,%1)
#define SPRINT(%1) server_print(%1)

enum (+= 100)
{
	TASK_TEAM = 2144,
	TASK_HUMANWIN,
	TASK_SHOWINGMENU,
	TASK_HAM_BOT,
	TASK_TIMER,
	TASK_MAKEZOMBIE,
	TASK_RESPAWN,
	TASK_RESPAWN_EF,
	TASK_STUNNED
}

enum
{
	DAYSTATUS_DAY = 0,
	DAYSTATUS_NIGHT,
	DAYSTATUS_DAY2
}

enum
{
	ICON_POWER_UP = 0,
	ICON_CRITICALSHOT,
	ICON_NIGHT_UP,
	ICON_NIGHT_DOWN,
	ICON_SPEED_UP,
	ICON_SPEED_DOWN
}


native MH_ZB4Damage(id, damage)
native MH_ZB4Power(id, power, Float:flashtime)
native MH_ZB4AddIcon(id, slot, icon, status)
native MH_ZB4SendDamage(id, damage)
native MH_ZB4Nvg(id, nvg)

native GetLightStyle()

// Team
#define TEAM_UNASSIGNED 0
#define TEAM_TERRORIST 1
#define TEAM_CT 2
#define TEAM_SPECTATOR 3

// HideWeapon
#define HIDEHUD_WEAPONS (1<<0)
#define HIDEHUD_FLASHLIGHT (1<<1)
#define HIDEHUD_ALL (1<<2)
#define HIDEHUD_HEALTH (1<<3)
#define HIDEHUD_TIMER (1<<4)
#define HIDEHUD_MONEY (1<<5)
#define HIDEHUD_CROSSHAIR (1<<6)

// TextMsg
#define HUD_PRINTNOTIFY 1
#define HUD_PRINTCONSOLE 2
#define HUD_PRINTTALK 3
#define HUD_PRINTCENTER 4
#define HUD_PRINTRADIO 5

// BitDamageType
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

// WeaponState
#define WPNSTATE_USP_SILENCED (1<<0)
#define WPNSTATE_GLOCK18_BURST_MODE (1<<1)
#define WPNSTATE_M4A1_SILENCED (1<<2)
#define WPNSTATE_ELITE_LEFT (1<<3)
#define WPNSTATE_FAMAS_BURST_MODE (1<<4)
#define WPNSTATE_SHIELD_DRAWN (1<<5)
