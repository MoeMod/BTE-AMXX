#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "BTE Random Spawn"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

new const SPAWNS_URL[] = "%s/csdm/%s.spawns.cfg"


new bool:g_hamczbots = false;
new g_spawnCount, Float:g_spawns[128][3][3];
new g_bBlock[33];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player_Post", 1);
}

public plugin_natives()
{
	register_native("bte_set_block_random_spawn", "Native_set_block_random_spawn",1)
}

public Native_set_block_random_spawn(id, bBlock)
{
	g_bBlock[id] = bBlock;
}

public plugin_cfg()
{
	LoadPlayerSpawns();
}

public client_putinserver(id)
{
	g_bBlock[id] = 0;
	
	if (is_user_zbot(id) && !g_hamczbots)
	{
		set_task(1.0, "register_ham_czbots", id)

		g_hamczbots = true;
	}
}

public HamF_Spawn_Player_Post(id)
{
	if (!g_bBlock[id])
		PlayerRandomSpawn(id);
}

stock PlayerRandomSpawn(id)
{
	static hull, sp_index, i
	hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN
	
	if (!g_spawnCount) return
	sp_index = random_num(0, g_spawnCount - 1)
	for (i = sp_index + 1;; i++)
	{
		if (i >= g_spawnCount) i = 0
		
		if (CheckHull(g_spawns[i][0], hull))
		{
			engfunc(EngFunc_SetOrigin, id, g_spawns[i][0])
			set_pev(id, pev_angles, g_spawns[i][1])
			set_pev(id, pev_v_angle, g_spawns[i][2])
			break
		}
		if (i == sp_index) break
	}
}

stock CheckHull(Float:origin[3], hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)
	
	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

public register_ham_czbots(id)
{
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player_Post", 1)
}

stock is_user_zbot(id) // not work ?
{
	if (!is_user_bot(id))
		return 0;

	new tracker[2], friends[2], ah[2];
	get_user_info(id,"tracker",tracker,1);
	get_user_info(id,"friends",friends,1);
	get_user_info(id,"_ah",ah,1);

	if (tracker[0] == '0' && friends[0] == '0' && ah[0] == '0')
		return 0; // PodBot / YaPB / SyPB

	return 1; // Zbot
}


stock LoadPlayerSpawns()
{
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), SPAWNS_URL, cfgdir, mapname)
	
	if (file_exists(filepath))
	{
		new csdmdata[10][6], file = fopen(filepath,"rt")
		while (file && !feof(file))
		{
			fgets(file, linedata, charsmax(linedata))
			if(!linedata[0]) continue;
			parse(linedata,csdmdata[0],5,csdmdata[1],5,csdmdata[2],5,csdmdata[3],5,csdmdata[4],5,csdmdata[5],5,csdmdata[6],5,csdmdata[7],5,csdmdata[8],5,csdmdata[9],5)
			g_spawns[g_spawnCount][0][0] = floatstr(csdmdata[0])
			g_spawns[g_spawnCount][0][1] = floatstr(csdmdata[1])
			g_spawns[g_spawnCount][0][2] = floatstr(csdmdata[2])
			g_spawns[g_spawnCount][1][0] = floatstr(csdmdata[3])
			g_spawns[g_spawnCount][1][1] = floatstr(csdmdata[4])
			g_spawns[g_spawnCount][1][2] = floatstr(csdmdata[5])
			g_spawns[g_spawnCount][2][0] = floatstr(csdmdata[6])
			g_spawns[g_spawnCount][2][1] = floatstr(csdmdata[7])
			g_spawns[g_spawnCount][2][2] = floatstr(csdmdata[8])
			g_spawnCount++
			if (g_spawnCount >= sizeof g_spawns) break;
		}
		if (file) fclose(file)
	}
	else
	{
		CollectPlayerSpawnsEntity("info_player_start")
		CollectPlayerSpawnsEntity("info_player_deathmatch")
	}
}

stock CollectPlayerSpawnsEntity(const classname[])
{
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0)
	{
		// get origin
		new Float:vec[3]
		pev(ent, pev_origin, vec)
		g_spawns[g_spawnCount][0][0] = vec[0]
		g_spawns[g_spawnCount][0][1] = vec[1]
		g_spawns[g_spawnCount][0][2] = vec[2]
		
		pev(ent, pev_angles, vec)
		g_spawns[g_spawnCount][1][0] = vec[0]
		g_spawns[g_spawnCount][1][1] = vec[1]
		g_spawns[g_spawnCount][1][2] = vec[2]
		
		pev(ent, pev_v_angle, vec)
		g_spawns[g_spawnCount][2][0] = vec[0]
		g_spawns[g_spawnCount][2][1] = vec[1]
		g_spawns[g_spawnCount][2][2] = vec[2]
		
		// increase spawn count
		g_spawnCount++
		if (g_spawnCount >= sizeof g_spawns) break;
	}
}
