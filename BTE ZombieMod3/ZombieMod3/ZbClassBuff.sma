public ZbClassBuff_Precache()
{
	ZbRevival_LoadConfig()
	ZbTeleport_LoadConfig()
	//g_iZbRevivalID = bte_zb3_register_zombie_class(c_ZbRevivalData[m_szZombieName], c_ZbRevivalData[m_szZombieModel], c_ZbRevivalData[m_flZombieGravity], c_ZbRevivalData[m_flZombieSpeed], c_ZbRevivalData[m_flZombieKnockback], 
	//	c_ZbRevivalData[m_szZombieSoundDeath1], c_ZbRevivalData[m_szZombieSoundDeath2], c_ZbRevivalData[m_szZombieSoundHurt1], c_ZbRevivalData[m_szZombieSoundHurt2], c_ZbRevivalData[m_szZombieSoundHeal], c_ZbRevivalData[m_szZombieSoundEvolution], c_ZbRevivalData[m_iZombieSex], c_ZbRevivalData[m_iZombieSetModelIndex], c_ZbRevivalData[m_flZombieXDamage][0], c_ZbRevivalData[m_flZombieXDamage][1], 1)
	//g_iZbTeleportID = bte_zb3_register_zombie_class(c_ZbTeleportData[m_szZombieName], c_ZbTeleportData[m_szZombieModel], c_ZbTeleportData[m_flZombieGravity], c_ZbTeleportData[m_flZombieSpeed], c_ZbTeleportData[m_flZombieKnockback], 
	//	c_ZbTeleportData[m_szZombieSoundDeath1], c_ZbTeleportData[m_szZombieSoundDeath2], c_ZbTeleportData[m_szZombieSoundHurt1], c_ZbTeleportData[m_szZombieSoundHurt2], c_ZbTeleportData[m_szZombieSoundHeal], c_ZbTeleportData[m_szZombieSoundEvolution], c_ZbTeleportData[m_iZombieSex], c_ZbTeleportData[m_iZombieSetModelIndex], c_ZbTeleportData[m_flZombieXDamage][0], c_ZbTeleportData[m_flZombieXDamage][1], 1)
}

stock ZbRevival_LoadConfig()
{
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, "bte_zombieclass.ini")
	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
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
		if (equali(linedata, "[Revival Zombie]"))
		{
			section = 1
			continue;
		}
		else if (linedata[0] == '[')
		{
			if (section)
			{
				section = 0
				return;
			}
			continue;
		}

		if (section == 1)
		{
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
			trim(key)
			trim(value)
			if (equal(key, "NAME"))
				format(c_ZbRevivalData[m_szZombieName], 63, "%s", value)
			else if (equal(key, "MODEL"))
				format(c_ZbRevivalData[m_szZombieModel], 63, "%s", value)
			else if (equal(key, "SET_MODEL_INDEX"))
				c_ZbRevivalData[m_iZombieSetModelIndex] = str_to_num(value)
			else if (equal(key, "SEX"))
				c_ZbRevivalData[m_iZombieSex] = str_to_num(value)
			else if (equal(key, "GRAVITY"))
				c_ZbRevivalData[m_flZombieGravity] = str_to_float(value)
			else if (equal(key, "SPEED"))
				c_ZbRevivalData[m_flZombieSpeed] = str_to_float(value)
			else if (equal(key, "XDAMAGE"))
				c_ZbRevivalData[m_flZombieXDamage][0] = str_to_float(value)
			else if (equal(key, "XDAMAGE2"))
				c_ZbRevivalData[m_flZombieXDamage][1] = c_ZbRevivalData[m_flZombieXDamage][2] = str_to_float(value)

			else if (equal(key, "KNOCK_BACK"))
				c_ZbRevivalData[m_flZombieKnockback] = str_to_float(value)

			else if (equal(key, "REVIVAL"))
				format(c_RevivalName, 63, "%s", value)
			else if (equal(key, "REVIVAL_TIME"))
				c_RevivalTime = str_to_float(value)
			else if (equal(key, "REVIVAL_WAIT"))
				c_RevivalWait = str_to_float(value)
			
			else if (equal(key, "SOUND_HURT1"))
				format(c_ZbRevivalData[m_szZombieSoundHurt1], 63, "%s", value)
			else if (equal(key, "SOUND_HURT2"))
				format(c_ZbRevivalData[m_szZombieSoundHurt2], 63, "%s", value)
			else if (equal(key, "SOUND_DEATH1"))
				format(c_ZbRevivalData[m_szZombieSoundDeath1], 63, "%s", value)
			else if (equal(key, "SOUND_DEATH2"))
				format(c_ZbRevivalData[m_szZombieSoundDeath2], 63, "%s", value)
			else if (equal(key, "SOUND_HEAL"))
				format(c_ZbRevivalData[m_szZombieSoundHeal], 63, "%s", value)
			else if (equal(key, "SOUND_EVOLUTION"))
				format(c_ZbRevivalData[m_szZombieSoundEvolution], 63, "%s", value)
			
			continue;
		}
		else continue;
	}
	if (file) fclose(file)
}

stock ZbTeleport_LoadConfig()
{
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, "bte_zombieclass.ini")
	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
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
		if (equali(linedata, "[Teleport Zombie]"))
		{
			section = 1
			continue;
		}
		else if (linedata[0] == '[')
		{
			if (section)
			{
				section = 0
				return;
			}
			continue;
		}

		if (section == 1)
		{
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
			trim(key)
			trim(value)
			if (equal(key, "NAME"))
				format(c_ZbTeleportData[m_szZombieName], 63, "%s", value)
			else if (equal(key, "MODEL"))
				format(c_ZbTeleportData[m_szZombieModel], 63, "%s", value)
			else if (equal(key, "SET_MODEL_INDEX"))
				c_ZbTeleportData[m_iZombieSetModelIndex] = str_to_num(value)
			else if (equal(key, "SEX"))
				c_ZbTeleportData[m_iZombieSex] = str_to_num(value)
			else if (equal(key, "GRAVITY"))
				c_ZbTeleportData[m_flZombieGravity] = str_to_float(value)
			else if (equal(key, "SPEED"))
				c_ZbTeleportData[m_flZombieSpeed] = str_to_float(value)
			else if (equal(key, "XDAMAGE"))
				c_ZbTeleportData[m_flZombieXDamage][0] = str_to_float(value)
			else if (equal(key, "XDAMAGE2"))
				c_ZbTeleportData[m_flZombieXDamage][1] = c_ZbTeleportData[m_flZombieXDamage][2] = str_to_float(value)
			else if (equal(key, "KNOCK_BACK"))
				c_ZbTeleportData[m_flZombieKnockback] = str_to_float(value)
			
			else if (equal(key, "TELEPORT"))
				format(c_TeleportName, 63, "%s", value)
			else if (equal(key, "TELEPORT_MODEL_MARK"))
				format(c_szTeleportModelMark, 63, "%s", value)
			else if (equal(key, "TELEPORT_SPR_IN"))
				format(c_szTeleportSprIn, 63, "%s", value)
			else if (equal(key, "TELEPORT_SPR_OUT"))
				format(c_szTeleportSprOut, 63, "%s", value)
			
			else if (equal(key, "SOUND_HURT1"))
				format(c_ZbTeleportData[m_szZombieSoundHurt1], 63, "%s", value)
			else if (equal(key, "SOUND_HURT2"))
				format(c_ZbTeleportData[m_szZombieSoundHurt2], 63, "%s", value)
			else if (equal(key, "SOUND_DEATH1"))
				format(c_ZbTeleportData[m_szZombieSoundDeath1], 63, "%s", value)
			else if (equal(key, "SOUND_DEATH2"))
				format(c_ZbTeleportData[m_szZombieSoundDeath2], 63, "%s", value)
			else if (equal(key, "SOUND_HEAL"))
				format(c_ZbTeleportData[m_szZombieSoundHeal], 63, "%s", value)
			else if (equal(key, "SOUND_EVOLUTION"))
				format(c_ZbTeleportData[m_szZombieSoundEvolution], 63, "%s", value)
			
			continue;
		}
		else continue;
	}
	if (file) fclose(file)
}

public Zb_Teleport_Skill(id)
{
	if(get_gametime() < g_flNextSkill[id])
	{
		new szNumber[4]
		format(szNumber, 3, "%d", floatround(g_flNextSkill[id] - get_gametime()))
		ClientPrint(0, HUD_PRINTCENTER, "#CSO_WaitSkillCoolTime", szNumber);
		return;
	}
	
	//while(pev_valid(iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", SKILLNAME)))
	//new iTarget = 
}

public Zb_Skill_HPBuff(id)
{
	
}

stock SendHealthExtra(id, iValue)
{
	message_begin(id ? MSG_ONE : MSG_ALL, gmsgHealthExtra, _, id ? id : 0);
	write_short(iValue);
	message_end();
}