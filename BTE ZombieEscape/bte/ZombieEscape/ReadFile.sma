public Pub_Load_Spawns()
{
	// Check for CSDM spawns of the current map
	new mapname[32], filepath[100], linedata[64],key[64],value[64]
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), "addons/amxmodx/configs/bte/ze/%s_spawns.bte",mapname)
	new iSection
	// Load CSDM spawns if present
	if (file_exists(filepath))
	{
		new csdmdata[10][6], file = fopen(filepath,"rt")
		
		while (file && !feof(file))
		{
			
			fgets(file, linedata, charsmax(linedata))
			replace(linedata, charsmax(linedata), "^n", "")
			
			// invalid spawn
			if(!linedata[0] || linedata[0] == ';') continue;
			if (linedata[0] == '[')
			{
				iSection++
				continue;
			}
			if(iSection == 1)
			{
				// get spawn point data
				parse(linedata,csdmdata[0],5,csdmdata[1],5,csdmdata[2],5)
			
				// origin
				g_spawn_zombie[g_spawn_zombie_total][0] = floatstr(csdmdata[0])
				g_spawn_zombie[g_spawn_zombie_total][1] = floatstr(csdmdata[1])
				g_spawn_zombie[g_spawn_zombie_total][2] = floatstr(csdmdata[2])
			
				// increase spawn count
				g_spawn_zombie_total++
			}
			if(iSection == 2)
			{
				strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
				trim(key)
				trim(value)	
				if(equal(key,"TriggerStart")) format(g_trigger_start,31,"%s",value)
				else if(contain(key,"Button_")>-1)
				{
					new iBtn,data[3][20]
					replace(key, charsmax(key), "Button_", "")

					iBtn = str_to_num(key)
					replace_all(value, charsmax(value), ",", " ")						
					parse(value,data[0],20,data[1],20,data[2],20)
					format(g_button_target[iBtn],31,"%s",data[0])
					format(g_button_msg[iBtn],31,"%s",data[2])
					g_button_time[iBtn] = str_to_num(data[1])
					g_button_total++
				}
			}
		}
		if (file) fclose(file)
	}
	//else set_fail_state
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1034\\ f0\\ fs16 \n\\ par }
*/
