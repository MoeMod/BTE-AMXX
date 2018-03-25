#include <amxmodx>
#include <fakemeta>
#include <amxmisc> 

#define PLUGIN "BTE Map Config"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

native	bte_wpn_get_mod_running()

enum _:BTE_MOD
{
	BTE_MOD_NONE=0,
	BTE_MOD_TD,
	BTE_MOD_ZE,
	BTE_MOD_NPC,
	BTE_MOD_ZB1,
	BTE_MOD_ZE,
	BTE_MOD_GD,
	BTE_MOD_DR,
	BTE_MOD_DM
}

enum
{
	SECTION_MAP_NONE = 0,
	SECTION_MAP_LIGHT,
	SECTION_MAP_WEATHER_EFFECTS,
	SECTION_MAP_SKY
}

new g_iModRuning//, g_isZb3, g_isZb4;

new g_light[2],g_sky_enable,g_skyname[32],g_ambience_rain,g_ambience_fog,g_fog_density[32],g_fog_color[32],g_ambience_snow

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("nvgon", "cmd_nvgon");
	register_clcmd("nvgoff", "cmd_nvgoff");
}

public cmd_nvgon(id)
{
	SetLight(id, "0");
	
	return PLUGIN_HANDLED;
}

public cmd_nvgoff(id)
{
	SetLight(id, g_light);
	
	return PLUGIN_HANDLED;
}

public plugin_natives()
{
	/*new config_dir[64], url_zb3[64], url_zb4[64]
	get_configsdir(config_dir, charsmax(config_dir))
	format(url_zb3, charsmax(url_zb3), "%s/plugins-zb3.ini", config_dir)
	format(url_zb4, charsmax(url_zb4), "%s/plugins-zb4.ini", config_dir)
	
	if (file_exists(url_zb3)) g_isZb3 = 1
	else if (file_exists(url_zb4)) g_isZb4 = 1*/
	
	
	
	register_native("GetLightStyle","natve_GetLightStyle",1)
}

public natve_GetLightStyle()
{
	return g_light[0];
}

public client_putinserver(id)
{
	set_task(1.0, "SendLight", id);
}

public SendLight(id)
{
	if (g_iModRuning == BTE_MOD_ZB1)
	{
		SetLight(id, g_light);
	}
}

stock SetLight(id, light[])
{
	if (id && !is_user_connected(id)) return
	
	message_begin(id?MSG_ONE:MSG_ALL, SVC_LIGHTSTYLE, _, id)
	write_byte(0)
	write_string(light)
	message_end()
}

public plugin_precache()
{
	g_iModRuning = bte_wpn_get_mod_running();
	
	LoadMapConfig();
	
	if (g_iModRuning == BTE_MOD_ZB1)
	{
		if (g_sky_enable)
			set_cvar_string("sv_skyname", g_skyname)
		
		if (g_ambience_fog)
		{
			new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
			if (pev_valid(ent))
			{
				Set_Kvd(ent, "density", g_fog_density, "env_fog")
				Set_Kvd(ent, "rendercolor", g_fog_color, "env_fog")
			}
		}
		if (g_ambience_rain) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"))
		if (g_ambience_snow) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_snow"))
	}
}

stock LoadMapConfig()
{
	new cfgdir[32], mapname[32], path[100]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(path, charsmax(path), "%s/map/%s.ini", cfgdir, mapname)
	
	if (!file_exists(path))
	{
		copy(g_light, charsmax(g_light), "g");
		
		g_sky_enable = 1;
		copy(g_skyname, charsmax(g_skyname), "hk");
		
		new linedata[64];
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
		
		g_ambience_fog = 1;
		copy(g_fog_density, charsmax(g_fog_density), "0.0008");
		copy(g_fog_color, charsmax(g_fog_color), "0 0 0");
		
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

stock Set_Kvd(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	dllfunc(DLLFunc_KeyValue, entity, 0)
}

