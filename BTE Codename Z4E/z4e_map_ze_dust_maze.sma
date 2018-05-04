#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include "z4e_alarm.inc"
#include "z4e_gameplay.inc"

#define PLUGIN "[Z4E] Map: ze_dust_maze"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define TASK_MAP 10086

#define BOX_MODEL "models/z4e/Woodenbox.mdl"

// offset

// CBreakable
#define OFFSET_LINUX_BREAKABLE 4
stock m_Material = 36 // int (+4)
// FROM util.h
#define VEC_DUCK_HULL_MIN Float:{-16.0, -16.0, -18.0}
#define VEC_DUCK_HULL_MAX Float:{16.0, 16.0, 32.0}
#define VEC_DUCK_VIEW Float:{0.0, 0.0, 12.0}

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

#define WIDTH 25
#define HEIGHT 25
enum MazePointType
{
	WALL = 0,
	ROAD,
}
new MazePointType:map[WIDTH][HEIGHT]

enum Directon
{
	dir_x,
	dir_y,
} 
new dir[][Directon] = 
{
	{ 0, -1 }, /** UP */
	{ 0, 1 },  /** DOWN */
	{ -1, 0 }, /** LEFT */
	{ 1, 0 }   /** RIGHT */
};

new g_pBoxEntity[1024];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Use, "func_button", "HamF_FuncButton_Use")
	
	register_clcmd("maze_print", "Maze_Print")
}

public plugin_precache()
{
	new szMap[32];
	get_mapname(szMap, 31)
	if(!equali(szMap, "ze_dust_maze")) // equali比较字符串不区分大小写
	{
		pause("a")
		return;
	}
	
	precache_model(BOX_MODEL);
}

public plugin_cfg()
{
	z4e_fw_gameplay_round_new();
}

public z4e_fw_gameplay_round_new()
{
	remove_task(TASK_MAP);
	
	Maze_Init();
	Maze_Entity();
	
	z4e_alarm_push(_, "** 地图: 沙漠迷宫 ** 插件：小白白 **", "难度：*****", "", { 250,250,50 }, 2.0);
	
	
}

public HamF_FuncButton_Use(this, caller, activator, use_type)
{
	if(!pev_valid(this))
		return HAM_IGNORED
	
	
	if(!task_exists(TASK_MAP))
	{
		z4e_alarm_timertip(30, "#CSBTE_Z4E_Waiting_Helicopter")
		set_task(30.0, "Task_Go", TASK_MAP)
	}
	else
	{
		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

public Task_Go()
{
	z4e_alarm_timertip(30, "#CSBTE_Z4E_Waiting_Helicopter_Running")
	set_task(30.0, "Task_Kill", TASK_MAP)
}

public Task_Kill()
{
	//z4e_alarm_insert(_, "成功逃跑！", "", "", { 250,50,50 }, 2.0);
	
	new Float:vecOrigin[3];
	for(new id=1;id<33;id++)
	{
		if(!is_user_alive(id))
			continue;
		pev(id, pev_origin, vecOrigin);
		if(vecOrigin[2] < 240.0)
			user_kill(id);
	}
}

public CreateBox(Float:vecOrigin[3])
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_wall"));
	set_pev(iEntity, pev_classname, "maze_box");
	
	engfunc(EngFunc_SetModel, iEntity, BOX_MODEL)
	set_pev(iEntity, pev_modelindex, engfunc(EngFunc_ModelIndex, BOX_MODEL))
	
	new Float:vecMins[3] = {-96.0, -96.0, 0.0}
	new Float:vecMaxs[3] = {96.0, 96.0, 192.0}
	engfunc(EngFunc_SetSize, iEntity, vecMins, vecMaxs)
	set_pev(iEntity, pev_angles, { 0.0, 0.0, 0.0})
	
	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS)
	set_pev(iEntity, pev_solid, SOLID_SLIDEBOX)
	
	engfunc(EngFunc_SetOrigin, iEntity, vecOrigin)
	set_pev(iEntity, pev_gravity, 0.0)
	set_pev(iEntity, pev_gamestate, 0.0)
	//set_pdata_int(iEntity, m_Material, matWood, OFFSET_LINUX_BREAKABLE)
	return iEntity;
}

public Maze_Init()
{
	for (new x = 0; x < WIDTH; x++)
		for (new y = 0; y < HEIGHT; y++)
			map[x][y] = WALL;
		
	Maze_Process(WIDTH - 2, WIDTH - 2);
}

public Maze_Process(x, y)
{
	new d = random_num(0,3);
	new dd = d;
	for(;;)
	{
		new px = x + dir[d][dir_x] * 2;
		new py = y + dir[d][dir_y] * 2;
		if (px < 0 || px >= WIDTH || py < 0 || py >= HEIGHT || map[px][py] != WALL) 
		{
			d++;
			if (d == 4)
				d = 0;
			if (d == dd)
			{
				break;
			}
			
			continue;
		}
		map[x + dir[d][dir_x]][y + dir[d][dir_y]] = ROAD;
		map[px][py] = ROAD;
		Maze_Process(px, py);
		d = dd = random_num(0,3);
	}
}

public Maze_Print(id)
{
	new szPrint[(HEIGHT + 1) * (WIDTH + 1)]
	for (new y = 0; y < HEIGHT; y++)
	{
		for (new x = 0; x < WIDTH; x++)
		{
			if (map[x][y] == WALL)
				format(szPrint, charsmax(szPrint), "%s墙", szPrint);
			else
				format(szPrint, charsmax(szPrint), "%s　", szPrint);
		}
		client_print(id, print_console, szPrint);
		szPrint[0] = 0;
	}
}

public Maze_Entity()
{
	//fm_remove_entity_name("maze_box");
	new i=0;
	for (new y = 1; y <= HEIGHT - 2; y++)
	{
		for (new x = 1; x <= WIDTH - 2; x++)
		{
			if(map[x][y] != WALL)
				continue;
			new Float:vecOrigin[3];
			vecOrigin[0] = 0.0 + float(x - WIDTH / 2) * 192.0
			vecOrigin[1] = 0.0 + float(y - HEIGHT / 2) * 192.0
			vecOrigin[2] = 0.0 
			
			
				if(pev_valid(g_pBoxEntity[i]))
				{
					engfunc(EngFunc_SetOrigin, g_pBoxEntity[i], vecOrigin)
				}
				else
				{
					g_pBoxEntity[i] = CreateBox(vecOrigin)
				}
			
			
			
			i++;
		}
	}
	
	for(;i<1024;i++)
	{
		if(pev_valid(g_pBoxEntity[i]))
		{
			engfunc(EngFunc_SetOrigin, g_pBoxEntity[i], {0.0, 0.0, -4096.0})
		}
	}
}