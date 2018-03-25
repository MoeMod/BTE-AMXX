// [BTE Weapon Value Define ]

// Seconds

#define ROF_CROSSBOW	0.12
#define IDLE_RAINBOWGUN	5
#define ANIM_RAINBOWGUN	2.6
#define ROF_MUSKET	3.0
#define ROF_CATAPULT	2.0
#define ROF_SKULL1	0.15
#define ROF_INFINITY	0.1
#define ROF_CANNON	3.5
#define ROF_FLAMETHROWER	0.12
#define RELOAD_FLAMETHROWER	5.2
#define SOUND_FLAMETHROWER	0.6
#define BAZOOKA_SPEED	1000
#define BAZOOKA_GRAVITY	1.0


new JANUS7_CHARGE_SHOOTTIME = 100
#define JANUS7_CHARGE_TIME_CANUSE	9.0
#define JANUS7_CHARGE_TIME			15.0
#define JANUS7_CHARGE_SHOOT_SOUND	"weapons/janus7_shoot2.wav"
#define JANUS7_CHARGE_RANGE			700.0
#define JANUS7_CHARGE_KNOCKBACK		150.0

#define DGUN_GRAVITY	0.18
#define DGUN_VELOCITY	4200.0
// TaskID

/*enum (+=100)
{
	TASK_RAINBOW_IDLE = 1000,
	TASK_MUSKET_DELAY,
	TASK_FLAMETHROWER_RELOAD,
	TASK_LAUNCHER_RELOAD,
	TASK_HAMMER_CHANGE,
	TASK_KNIFE_DELAY,
	TASK_CHANGE_WPN,
	TASK_BOT_WEAPON
}*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1034\\ f0\\ fs16 \n\\ par }
*/

new Float:ARMOR_RATIO[] = { 0.0, 1.25, 0.0, 1.7, 1.0, 1.0, 1.0, 0.95,1.4, 1.0, 1.05, 1.5, 1.0,
		1.45, 1.55, 1.4, 1.0, 1.05, 1.95, 1.0, 1.5, 1.0, 1.4, 1.0, 1.65, 1.0, 1.5, 1.4, 1.55, 1.7, 1.5 }