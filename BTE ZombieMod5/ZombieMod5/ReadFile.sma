stock Load_Config()
{
	new path[64]
	get_configsdir(path, charsmax(path))
	formatex(g_szLogName, charsmax(g_szLogName),"%s/%s", path, LOG_FILE)
	format(path, charsmax(path), "%s/%s", path, SETTING_FILE)

	if(file_exists(g_szLogName))
	{
		delete_file(g_szLogName)
	}


	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
		Util_Log(error)
		set_fail_state(error)

		return;
	}
	new linedata[1024], key[64], value[960], section
	new file = fopen(path, "rt")
	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata))
		replace(linedata, charsmax(linedata), "^n", "")
		if (!linedata[0] || linedata[0] == ';') continue;
		if (linedata[0] == '[')
		{
			section++
			continue;
		}
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
		trim(key)
		trim(value)
		switch (section)
		{
			case SECTION_HERO:
			{
				if (equal(key, "MODEL_MALE"))
					format(HERO_MODEL_MALE, charsmax(HERO_MODEL_MALE), "%s", value)
				if (equal(key, "MODEL_FEMALE"))
					format(HERO_MODEL_FEMALE, charsmax(HERO_MODEL_FEMALE), "%s", value)
/*				else if (equal(key, "GRAVITY"))
					HERO_GRAVITY = str_to_float(value)*/

			}
			case SECTION_RESTORE_HEALTH:
			{
				if (equal(key, "RESTORE_HEALTH_TIME"))
					RESTORE_HEALTH_TIME = str_to_float(value)
				else if (equal(key, "RESTORE_HEALTH_LV1"))
					RESTORE_HEALTH_LV1 = str_to_num(value)
				else if (equal(key, "RESTORE_HEALTH_LV2"))
					RESTORE_HEALTH_LV2 = str_to_num(value)
			}
			case SECTION_SUPPLYBOX:
			{
				if (equal(key, "SUPPLYBOX_MAX"))
					SUPPLYBOX_MAX = min(MAX_SUPPLYBOX, str_to_num(value))
				else if (equal(key, "SUPPLYBOX_NUM"))
					SUPPLYBOX_NUM = str_to_num(value)
				else if (equal(key, "SUPPLYBOX_TIME_FIRST"))
					SUPPLYBOX_TIME_FIRST = str_to_float(value)
				else if (equal(key, "SUPPLYBOX_TIME"))
					SUPPLYBOX_TIME = str_to_float(value)
			}
			case SECTION_ZOMBIEBOM:
			{
				if (equal(key, "RADIUS"))
					ZOMBIEBOM_RADIUS = str_to_float(value)
				else if (equal(key, "POWER"))
					ZOMBIEBOM_POWER = str_to_float(value)
			}
			case SECTION_SOUNDS:
			{
				if (equal(key, "ZOMBIE_COMING"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)
						ArrayPushString(sound_zombie_coming, key)
					}
				}
				else if (equal(key, "ZOMBIE_COMEBACK"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)
						ArrayPushString(sound_zombie_comeback, key)
					}
				}
				else if (equal(key, "ZOMBIE_ATTACK"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)
						ArrayPushString(sound_zombie_attack, key)
					}
				}
				else if (equal(key, "ZOMBIE_HITWALL"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)
						ArrayPushString(sound_zombie_hitwall, key)
					}
				}
				else if (equal(key, "ZOMBIE_SWING"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)
						ArrayPushString(sound_zombie_swing, key)
					}
				}
				else if (equal(key, "HUMAN_DEATH"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)
						ArrayPushString(sound_human_death, key)
					}
				}
				else if (equal(key, "FEMALE_DEATH"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)
						ArrayPushString(sound_female_death, key)
					}
				}
			}
			case SECTION_LIGHT:
			{
				if (equal(key, "LIGHT"))
					copy(g_light, charsmax(g_light), value)
			}
			case SECTION_WEATHER_EFFECTS:
			{
				if (equal(key, "LIGHT"))
					copy(g_light, charsmax(g_light), value)
				else if (equal(key, "RAIN"))
					g_ambience_rain = str_to_num(value)
				else if (equal(key, "SNOW"))
					g_ambience_snow = str_to_num(value)
				else if (equal(key, "FOG"))
					g_ambience_fog = str_to_num(value)
				else if (equal(key, "FOG_DENSITY"))
					copy(g_fog_density, charsmax(g_fog_density), value)
				else if (equal(key, "FOG_COLOR"))
					copy(g_fog_color, charsmax(g_fog_color), value)
			}
			case SECTION_SKY:
			{
				if (equal(key, "SKY_ENABLE"))
					g_sky_enable = str_to_num(value)
				else if (equal(key, "SKY_CUSTOM"))
				{
					trim(value)
					copy(g_skyname, charsmax(g_skyname), value)
					formatex(linedata, charsmax(linedata), "gfx/env/%sbk.tga", g_skyname)
					engfunc(EngFunc_PrecacheGeneric, linedata)
					formatex(linedata, charsmax(linedata), "gfx/env/%sdn.tga", g_skyname)
					engfunc(EngFunc_PrecacheGeneric, linedata)
					formatex(linedata, charsmax(linedata), "gfx/env/%sft.tga", g_skyname)
					engfunc(EngFunc_PrecacheGeneric, linedata)
					formatex(linedata, charsmax(linedata), "gfx/env/%slf.tga", g_skyname)
					engfunc(EngFunc_PrecacheGeneric, linedata)
					formatex(linedata, charsmax(linedata), "gfx/env/%srt.tga", g_skyname)
					engfunc(EngFunc_PrecacheGeneric, linedata)
					formatex(linedata, charsmax(linedata), "gfx/env/%sup.tga", g_skyname)
					engfunc(EngFunc_PrecacheGeneric, linedata)
				}
			}
			case SECTION_OBJECTIVE_ENTS:
			{
				if (equal(key, "CLASSNAMES"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)
						ArrayPushString(g_objective_ents, key)
					}
				}
			}
		}
	}
	if (file) fclose(file)
}

stock Load_Config_Map()
{
	new cfgdir[32], mapname[32], path[100]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(path, charsmax(path), SETTING_FILE_MAP, cfgdir, mapname)

	if (!file_exists(path))
	{
		Util_Log("Map customization file not found!")

		return;
	}

	new linedata[1024], key[64], value[960], section
	new file = fopen(path, "rt")

	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata))
		replace(linedata, charsmax(linedata), "^n", "")
		if (!linedata[0] || linedata[0] == ';') continue;
		if (linedata[0] == '[')
		{
			section++
			continue;
		}
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
		trim(key)
		trim(value)
		switch (section)
		{
			case SECTION_MAP_LIGHT:
			{
				if (equal(key, "LIGHT"))
					copy(g_light, charsmax(g_light), value)
			}
			case SECTION_MAP_WEATHER_EFFECTS:
			{
				if (equal(key, "RAIN"))
					g_ambience_rain = str_to_num(value)
				else if (equal(key, "SNOW"))
					g_ambience_snow = str_to_num(value)
				else if (equal(key, "FOG"))
					g_ambience_fog = str_to_num(value)
				else if (equal(key, "FOG_DENSITY"))
					copy(g_fog_density, charsmax(g_fog_density), value)
				else if (equal(key, "FOG_COLOR"))
					copy(g_fog_color, charsmax(g_fog_color), value)
			}
			case SECTION_MAP_SKY:
			{
				if (equal(key, "SKY_ENABLE"))
					g_sky_enable = str_to_num(value)
				else if (equal(key, "SKY_CUSTOM") && g_sky_enable)
				{
					trim(value)
					copy(g_skyname, charsmax(g_skyname), value)
					formatex(linedata, charsmax(linedata), "gfx/env/%sbk.tga", g_skyname)
					engfunc(EngFunc_PrecacheGeneric, linedata)
					formatex(linedata, charsmax(linedata), "gfx/env/%sdn.tga", g_skyname)
					engfunc(EngFunc_PrecacheGeneric, linedata)
					formatex(linedata, charsmax(linedata), "gfx/env/%sft.tga", g_skyname)
					engfunc(EngFunc_PrecacheGeneric, linedata)
					formatex(linedata, charsmax(linedata), "gfx/env/%slf.tga", g_skyname)
					engfunc(EngFunc_PrecacheGeneric, linedata)
					formatex(linedata, charsmax(linedata), "gfx/env/%srt.tga", g_skyname)
					engfunc(EngFunc_PrecacheGeneric, linedata)
					formatex(linedata, charsmax(linedata), "gfx/env/%sup.tga", g_skyname)
					engfunc(EngFunc_PrecacheGeneric, linedata)
				}
			}

		}
	}

	if (file) fclose(file)
}



stock Load_PlayerSpawns()
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
			if(!linedata[0] || Str_Count(linedata,' ') < 2) continue;
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
		Collect_PlayerSpawns_Entity("info_player_start")
		Collect_PlayerSpawns_Entity("info_player_deathmatch")
	}
}
stock Collect_PlayerSpawns_Entity(const classname[])
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
stock Load_BoxSpawns()
{
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), SPAWNS_BOX_URL, cfgdir, mapname)

	if (file_exists(filepath))
	{
		new csdmdata[10][6], file = fopen(filepath,"rt")
		while (file && !feof(file))
		{
			fgets(file, linedata, charsmax(linedata))
			if(!linedata[0] || Str_Count(linedata,' ') < 2) continue;
			parse(linedata,csdmdata[0],5,csdmdata[1],5,csdmdata[2],5,csdmdata[3],5,csdmdata[4],5,csdmdata[5],5,csdmdata[6],5,csdmdata[7],5,csdmdata[8],5,csdmdata[9],5)
			g_spawns_box[g_spawnCount_box][0] = floatstr(csdmdata[0])
			g_spawns_box[g_spawnCount_box][1] = floatstr(csdmdata[1])
			g_spawns_box[g_spawnCount_box][2] = floatstr(csdmdata[2])
			g_spawnCount_box++
			if (g_spawnCount_box >= sizeof g_spawns) break;
		}
		if (file) fclose(file)
	}
	else
	{
		Collect_BoxSpawns_Entity("info_player_start")
		Collect_BoxSpawns_Entity("info_player_deathmatch")
	}
}
stock Collect_BoxSpawns_Entity(const classname[])
{
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0)
	{
		// get origin
		new Float:originF[3]
		pev(ent, pev_origin, originF)
		g_spawns_box[g_spawnCount_box][0] = originF[0]
		g_spawns_box[g_spawnCount_box][1] = originF[1]
		g_spawns_box[g_spawnCount_box][2] = originF[2]

		// increase spawn count
		g_spawnCount_box++
		if (g_spawnCount_box >= sizeof g_spawns) break;
	}
}
stock Load_SupplyBoxItems()
{
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, SETTING_FILE)

	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
		Util_Log(error)
		set_fail_state(error)

		return;
	}
	new linedata[1024], key[64], value[960], section
	new file = fopen(path, "rt")
	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata))
		replace(linedata, charsmax(linedata), "^n", "")
		if (!linedata[0] || linedata[0] == ';') continue;
		if (linedata[0] == '[')
		{
			section++
			continue;
		}
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
		trim(key)
		trim(value)
		switch (section)
		{
			case SECTION_SUPPLYBOX:
			{
				if (equal(key, "SUPPLYBOX_ITEMS"))
				{
					strtolower(value)
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)
						ArrayPushString(SUPPLYBOX_ITEMS, key)
					}
				}
			}
		}
	}
	if (file) fclose(file)
}