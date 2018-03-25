//#define SND_COUNT_START		"vox/20secremain.wav"
#define SND_ROUND_START		"vox/zombi_start.wav"
#define SND_BGM			"music/zb_start.mp3"

#define COUNT_DOWN_START	20

#define ZOMBIE_MIN_HEALTH	1000.0
#define ZOMBIE_START_HEALTH	4000.0
#define ZOMBIE_XDAMAGE		0.9

#define ZOMBIE_SWING_RANGE	35.0
#define ZOMBIE_STAB_RANGE	48.0

#define ZOMBIE_MAXSPEED		270.0

#define MAX_SPAWN	100

#define NVG_HUMAN_R		0
#define NVG_HUMAN_G		110
#define NVG_HUMAN_B		0
#define NVG_HUMAN_A		80

#define NVG_ZOMBIE_R	110
#define NVG_ZOMBIE_G	0
#define NVG_ZOMBIE_B	0
#define NVG_ZOMBIE_A	80


new const SND_COUNT[][] = {"vox/one.wav", "vox/two.wav", "vox/three.wav", "vox/four.wav", "vox/five.wav", "vox/six.wav", 
"vox/seven.wav", "vox/eight.wav", "vox/nine.wav", "vox/ten.wav"}
new const SND_WIN[][] = {"vox/win_human_2.wav", "vox/win_zombi_2.wav"}
new const SND_NVG[][]={"items/nvg_off.wav", "items/nvg_on.wav"}

new MDL_ZOMBIE_HAND[]="models/v_knife_tank_zombi.mdl"

new MDL_HOST[]="tank_zombi_host"
new MDL_ORIGIN[]="tank_zombi_origin"

new MDL_ZOMBIE_HOST[]="models/player/tank_zombi_host/tank_zombi_host.mdl"
new MDL_ZOMBIE_ORIGIN[]="models/player/tank_zombi_origin/tank_zombi_origin.mdl"
new const SND_ZOMBIE_HURT[][]= {"zombi/zombi_hurt_01.wav","zombi/zombi_hurt_01.wav"}
new const SND_ZOMBIE_INFECTION_MALE[][]={"zombi/human_death_01.wav","zombi/human_death_02.wav"}
new const SND_ZOMBIE_INFECTION_FEMALE[][]={"zombi/human_death_female_01.wav","zombi/human_death_female_02.wav"}
new const SND_ZOMBIE_DEATH[][]={"zombi/zombi_death_1.wav","zombi/zombi_death_2.wav"}
new const SND_ZOMBIE_COMING[][]={"vox/zombi_coming_1.wav","vox/zombi_coming_1.wav"}

enum (+= 100)
{
	TASK_ROUNDSTART = 2000,
	//TASK_WAITTEXT,
	TASK_TEAM,
	TASK_INFECTEDSOUND,
	TASK_FORCEWIN
}

enum _:USER_INFO
{
	TEAM = 0
}

enum _:USER_INFO_TEAM
{
	HUMAN = 0,
	ZOMBIE,
	ALL
};
enum _:ROUND_STATUS
{
	FREEZE = 0,
	START,
	COUNT,
	END
};


