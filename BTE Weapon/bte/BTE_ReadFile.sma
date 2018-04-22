// [BTE Read File Function]
#include "BTE.inc"
public Read_Config_File()
{
	format(g_szConfigFile, charsmax(g_szConfigFile), "%s/%s", g_szConfigDir, BTE_CONFIG_FILE)
	if (!file_exists(g_szConfigFile))
	{
		Util_Log("Couldn't Open Config File:%s!",BTE_CONFIG_FILE)
		set_fail_state("ERROR!See bte_wpn_log.log for detail")
	}
	new linedata[1024], key[64], value[960]
	new file = fopen(g_szConfigFile, "rt")

	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata))
		replace(linedata, charsmax(linedata), "^n", "")
		if (!linedata[0] || linedata[0] == ';')
		{
			continue;
		}
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
		trim(key)
		trim(value)

		if (equal(key,"WeaponLastTime")) g_c_fWeaponLastTime = str_to_float(value)
		if (equal(key,"StripDroppedHe")) g_c_iStripDroppedHe = str_to_num(value)

		if (equal(key,"UnlimitedBpAmmo")) g_c_bUnlimitedBpAmmo = str_to_num(value);

		if (equal(key,"WeaponLimit"))
		{
			g_c_iWeaponLimitBit = 0;
			g_c_bWeaponLimitCustom = FALSE;

			if (equal(value, "Sniper"))
				g_c_iWeaponLimitBit = 1<<CSW_AWP | 1<<CSW_SCOUT | 1<<CSW_KNIFE;

			if (equal(value, "Grenade"))
				g_c_iWeaponLimitBit = 1<<CSW_HEGRENADE | 1<<CSW_KNIFE;

			if (equal(value, "Pistol"))
				g_c_iWeaponLimitBit = SECONDARY_WEAPONS_BIT_SUM | 1<<CSW_KNIFE;

			if (equal(value, "Knife"))
				g_c_iWeaponLimitBit = 1<<CSW_KNIFE;

			if (equal(value, "No"))
				g_c_iWeaponLimitBit = 0;

			if (equal(value, "Custom"))
				g_c_bWeaponLimitCustom = TRUE;
		}

		if (g_modruning == BTE_MOD_GD)
			g_c_iWeaponLimitBit = 0;

		if (g_modruning == BTE_MOD_DR)
			g_c_iWeaponLimitBit = 1<<CSW_KNIFE;

		if (equal(key, "WeaponLimitCustom"))
		{
			replace(value, charsmax(value), " ", "");
			strtolower(value);

			new i = 0;
			while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
			{
				trim(key)
				trim(value)
				copy(g_szLimitWeapon[i], 32, key);
				i += 1;
			}

		}

		/*if (g_modruning)
			g_c_iWeaponLimitBit =*/
	}

	fclose(file);
}

public Read_WeaponsINI(bPrecache)
{
	new sPath[64];
	format(sPath, charsmax(sPath), "%s/%s", g_szConfigDir, BTE_WPN_FILE);

	if (!file_exists(sPath))
	{
		Util_Log("Couldn't Open Weapons File:%s!",BTE_WPN_FILE);
		set_fail_state("ERROR!See bte_wpn_log.log for detail");
	}

	new i;

	for (i = 1; i <= 5; i++)
	{
		if (i == 1) copy(c_sModel[i], 31, "knife");
		if (i == 2) copy(c_sModel[i], 31, "glock18");
		if (i == 3) copy(c_sModel[i], 31, "usp");
		if (i == 4) copy(c_sModel[i], 31, "hegrenade");
		if (i == 5) copy(c_sModel[i], 31, "smokegrenade");

		ReadWeaponData(c_sModel[i], i);
		PrecacheWeapon(i, bPrecache);

		g_bDefaultWeaponLimited[i] = g_c_bWeaponLimitCustom ? WeaponLimitCheck(c_sModel[i]) : TRUE;
	}

	i = 5;

	new linedata[1024];
	new file = fopen(sPath, "rt");

	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata));
		replace(linedata, charsmax(linedata), "^n", "");

		if (!('a' <= linedata[0] <= 'z') && !('A' <= linedata[0] <= 'Z'))
			continue;

		if (WeaponLimitCheck(linedata) == FALSE)
			continue;

		if (CheckMyWpn(linedata))
		{
			Util_Log("ReadWeaponData: %s", linedata);

			copy(c_sModel[i], 31, linedata);
			ReadWeaponData(c_sModel[i], i);

			PrecacheWeapon(i, bPrecache);
			PrecacheSpecialWeapon(i, bPrecache);

			if (bPrecache == TRUE)
				BotWeaponListAdd(i);

			if (c_iType[i] == WEAPONS_DOUBLE)
			{
				ReadWeaponData(c_sModel[i], i + 1);
				ReadWeaponData(c_sDoubleMode[i], i + 1);
				i++;
			}

			i++;
		}

	}
}

public WeaponLimitCheck(szName[])
{
	if (g_c_bWeaponLimitCustom)
	{
		strtolower(szName);

		for(new i = 0; i < MAX_WPN; i++)
		{
			if (equal(g_szLimitWeapon[i], szName))
				return TRUE;
		}

		return FALSE;
	}
	else
	{
		new data[128], iId;
		GetPrivateProfile(szName, "WeaponID", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
		iId = GetWeaponID(data);

		if (!(g_c_iWeaponLimitBit & 1<<iId) && g_c_iWeaponLimitBit)
			return FALSE;

		return TRUE;
	}

	return TRUE;
}

public BotWeaponListAdd(iBteWpn)
{
	if (iBteWpn && c_iId[iBteWpn] && c_bCanBuy[iBteWpn] && (!c_iModeLimit[iBteWpn] || c_iModeLimit[iBteWpn] & (1<<g_modruning)) && (g_c_iWeaponLimitBit & 1<<c_iId[iBteWpn] || !g_c_iWeaponLimitBit))
	{
		// weapon in EQUIP
		if (c_iMenu[iBteWpn] == 5 && c_iId[iBteWpn] != CSW_HEGRENADE)
		{
			g_wpn_menu[7][g_wpn_menu_count[7]] = iBteWpn;
			g_wpn_menu_count[7] ++
		}
		else
		{
			g_wpn_menu[c_iMenu[iBteWpn]][g_wpn_menu_count[c_iMenu[iBteWpn]]] = iBteWpn;
			g_wpn_menu_count[c_iMenu[iBteWpn]] ++
		}

	}
}

public PrecacheWeapon(iBteWpn, bPrecache)
{
	format(c_sModel_P[iBteWpn], 63, "%s/p_%s.mdl", MODEL_URL, c_sModel[iBteWpn]);
	format(c_sModel_V[iBteWpn], 63, "%s/v_%s.mdl", MODEL_URL, c_sModel[iBteWpn]);

	if (c_iModel_W_Sub[iBteWpn] == -1)
		format(c_sModel_W[iBteWpn], 63, "%s/w_%s.mdl", MODEL_URL, c_sModel[iBteWpn]);
	else
		format(c_sModel_W[iBteWpn], 63, "%s/%s", MODEL_URL, c_sModel_W[iBteWpn]);

	if (bPrecache == TRUE)
	{
		if (c_iSpecial[iBteWpn] == SPECIAL_BLOCKAR)
		{
			precache_model("models/v_blockar1.mdl");
			precache_model("models/p_blockar1.mdl");
			precache_model("models/w_blockar1.mdl");
			precache_model("models/v_blockar2.mdl");
			precache_model("models/p_blockar2.mdl");
			precache_model("models/w_blockar2.mdl");
			precache_model("models/v_blockchange.mdl");
			g_sModelIndexBlockShell = precache_model("models/block_shell.mdl");
			precache_model("models/block_missile.mdl");
			precache_sound("weapons/blockar2-1.wav");
		}
		else if (c_iSpecial[iBteWpn] == SPECIAL_BLOCKSMG)
		{
			CBlockSMG_Precache();
		}
		else if(c_iSpecial[iBteWpn] == SPECIAL_THANATOS9)
		{
			precache_model("models/p_thanatos9a.mdl");
			precache_model("models/p_thanatos9b.mdl");
			precache_model(c_sModel_V[iBteWpn]);
		}
		else if(c_iSpecial[iBteWpn] == SPECIAL_CROW9)
		{
			precache_model("models/p_crow9a.mdl");
			precache_model("models/p_crow9b.mdl");
			precache_model(c_sModel_V[iBteWpn]);
		}
		else if(c_iSpecial[iBteWpn] == SPECIAL_JANUS9)
		{
			precache_model("models/p_janus9_a.mdl");
			precache_model(c_sModel_V[iBteWpn]);
		}
		else if(c_iSpecial[iBteWpn] == SPECIAL_DESPERADO)
		{
			precache_model("models/p_desperado_m.mdl");
			precache_model("models/p_desperado_w.mdl");
			precache_model(c_sModel_V[iBteWpn]);
		}
		else if(c_iSpecial[iBteWpn] == SPECIAL_DUALSWORD)
		{
			precache_model("models/p_dualsword_a.mdl");
			precache_model("models/p_dualsword_b.mdl");
			
			new model[64];
			format(model, 63, "%s/%s_skillfx1.mdl", MODEL_URL, c_sModel[iBteWpn]);
			precache_model(model);
			format(model, 63, "%s/%s_skillfx2.mdl", MODEL_URL, c_sModel[iBteWpn]);
			precache_model(model);
			
			new sound[63];
			new szInApp[32];
			for (new i = 1; i <= 5; i ++)
			{
				format(szInApp, 31, "CustomSound%d", i);
				GetPrivateProfile(c_sModel[iBteWpn], szInApp, "-", "cstrike/weapons_res.ini", BTE_STRING, sound, charsmax(sound));
				if (sound[0] != '-')
				{
					format(sound, 63, "%s/%s", SOUND_URL, sound);
					precache_sound(sound);
				}
			}
			precache_model(c_sModel_V[iBteWpn]);
		}
		else
		{
			precache_model(c_sModel_P[iBteWpn]);
			precache_model(c_sModel_V[iBteWpn]);
		}

		if (c_iId[iBteWpn] != CSW_KNIFE && c_iSpecial[iBteWpn] != SPECIAL_BLOCKAR && c_iSpecial[iBteWpn] != SPECIAL_BLOCKSMG)
			precache_model(c_sModel_W[iBteWpn]);
	}


	if (c_iType[iBteWpn] == WEAPONS_DOUBLE)
	{
		format(c_sModel_V[iBteWpn + 1], 63, "%s/v_%s_2.mdl", MODEL_URL, c_sModel[iBteWpn]);

		if (bPrecache == TRUE)
			precache_model(c_sModel_V[iBteWpn + 1]);
	}

	if (bPrecache == TRUE)
		precache_model(c_sEntityModel[iBteWpn]);

	if (c_iSpecial[iBteWpn] == SPECIAL_BUFFAK47)
		g_bHostOwnBuffAK47 = TRUE;
	else if (c_iSpecial[iBteWpn] == SPECIAL_BUFFSG552)
		g_bHostOwnBuffSG552 = TRUE;
	else if (c_iSpecial[iBteWpn] == SPECIAL_BUFFM4A1)
		g_bHostOwnBuffM4A1 = TRUE;
	else if (c_iSpecial[iBteWpn] == SPECIAL_BUFFAWP)
		g_bHostOwnBuffAWP = TRUE;
}

public PrecacheSpecialWeapon(iBteWpn, bPrecache)
{
	if (bPrecache == FALSE)
		return;

	if (c_iSpecial[iBteWpn] == SPECIAL_GAUSS)
	{
		precache_sound("weapons/gauss2.wav");
		precache_sound("weapons/electro4.wav");
		precache_sound("weapons/electro5.wav");
		precache_sound("weapons/electro6.wav");
		precache_sound("ambience/pulsemachine.wav");
		precache_model("sprites/hotglow.spr");
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BALROG11)
		precache_sound("weapons/balrog9_charge_finish1.wav");
	else if (c_iSpecial[iBteWpn] == SPECIAL_RAILCANNON)
		precache_model("sprites/hotglow_railcannon.spr")
	else if (c_iSpecial[iBteWpn] == SPECIAL_BUFFAK47)
	{
		g_sModelIndexBuffAKEXP = precache_model("sprites/ef_buffak_hit.spr");
		g_flFramesBuffAKEXP = float(engfunc(EngFunc_ModelFrames, precache_model("sprites/muzzleflash19.spr")));
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SFSWORD)
		precache_model("models/p_sfsword_off.mdl")
	else if (c_iSpecial[iBteWpn] == SPECIAL_DGUN)
		precache_model("models/drillgun_nail.mdl")
	else if (c_iSpecial[iBteWpn] == SPECIAL_SGDRILL)
	{
		precache_model("models/shell_sgdrill.mdl");
		precache_model("models/p_sgdrill_slash.mdl");
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_STORMGIANT)
	{
		m_usStormGiantEffect = engfunc(EngFunc_PrecacheEvent, 1, "events/stormgiant_effect.sc");
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_RUNEBLADE)
	{
		m_usRunebladeEffect = engfunc(EngFunc_PrecacheEvent, 1, "events/runeblade_effect.sc");
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SFSNIPER)
	{
		precache_sound("weapons/sfsniper_insight1.wav");
		precache_sound("weapons/sfsniper_zoom.wav");
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_DESTROYER)
	{
		precache_sound("weapons/destroyer_exp.wav");
		precache_model("models/shell_destroyer.mdl");
		g_cache_destroyerExplosion = precache_model("sprites/ef_destroyerexp.spr");
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SPEARGUN)
	{
		precache_model("models/spear.mdl")
		precache_model("models/spear2.mdl")
		precache_sound("weapons/speargun_metal1.wav")
		precache_sound("weapons/speargun_metal2.wav")
		precache_sound("weapons/speargun_wood1.wav")
		precache_sound("weapons/speargun_wood2.wav")
		precache_sound("weapons/speargun_stone1.wav")
		precache_sound("weapons/speargun_stone2.wav")
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUS1)
		precache_sound("weapons/janus1_exp.wav")
	else if (c_iSpecial[iBteWpn] == SPECIAL_M2)
		precache_model("models/p_m2_2.mdl")
	else if (c_iSpecial[iBteWpn] == SPECIAL_SPAS12EX)
	{
		precache_model("models/v_spas12ex_2.mdl")
	}
	/*else if (c_iSpecial[iBteWpn]==SPECIAL_CHAINSAW)
	{
		precache_sound("weapons/chainsaw_hit1.wav")
		precache_sound("weapons/chainsaw_hit2.wav")
		precache_sound("weapons/chainsaw_hit3.wav")
		precache_sound("weapons/chainsaw_hit4.wav")
		precache_sound("weapons/chainsaw_slash3.wav")
		precache_sound("weapons/chainsaw_slash4.wav")

	}*/
	else if (c_iSpecial[iBteWpn] == SPECIAL_BALROG11)
		precache_sound("weapons/balrog11-2.wav")
	else if (c_iSpecial[iBteWpn] == SPECIAL_PLASMA)
	{
		precache_sound("weapons/plasmagun_exp.wav")
		g_cache_plasmabomb = precache_model("sprites/plasmabomb.spr")
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SFPISTOL)
	{
		precache_model("sprites/plasmabomb.spr")
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_COILGUN)
		precache_model("models/missile_kraken.mdl")
	else if (c_iSpecial[iBteWpn] == SPECIAL_HAMMER)
		precache_model("models/v_hammer_2.mdl")
	else if (c_iSpecial[iBteWpn] == SPECIAL_SKULL3)
		precache_model("models/p_skull3dual.mdl")
	else if (c_iSpecial[iBteWpn] == SPECIAL_CROSSBOW)
		precache_model("models/cso_bolt.mdl")
	else if (c_iSpecial[iBteWpn]==SPECIAL_FIRECRAKER)
	{
		precache_model("models/s_grenade_spark.mdl")
		precache_sound("weapons/firecracker_bounce1.wav")
		precache_sound("weapons/firecracker_bounce2.wav")
		precache_sound("weapons/firecracker_bounce3.wav")
		precache_sound("weapons/firecracker_explode.wav")
		precache_model("sprites/spark2.spr")
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SKULL8)
	{
		precache_sound("weapons/skullaxe_hit.wav")
		precache_sound("weapons/skullaxe_wall.wav")
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUSMK5)
	{
		precache_sound("weapons/janusmk5-2.wav")
		precache_sound("weapons/janusmk5-12.wav")
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BOW)
	{
		precache_sound("weapons/bow_charge-1_empty.wav")
		precache_sound("weapons/bow_charge-2.wav")

		precache_sound("weapons/xbow_hit1.wav")
		precache_sound("weapons/xbow_hitbod1.wav")

		precache_model("models/arrow.mdl")
	}
	// !!
	/*if (c_iSlot[iBteWpn] == WPN_HE)
	{
		new szSprite[64];
		format(c_he_snd[iBteWpn], 63, "%s/%s_explosion.wav",SOUND_URL, c_sModel[iBteWpn])
		format(szSprite, 63, "%s/%s_exp.spr", SPR_URL,c_sModel[iBteWpn])

		if (c_sprite[iBteWpn]) c_he_spr[iBteWpn] = engfunc(EngFunc_PrecacheModel, szSprite);
		if (c_sound[iBteWpn]) precache_sound(c_he_snd[iBteWpn]);
	}*/
	else if (c_iSpecial[iBteWpn] == SPECIAL_TKNIFE)
	{
		new sound[64];
		format(sound, 63, "weapons/%s-2.wav", c_sModel[iBteWpn])
		precache_sound(sound);

		precache_sound("weapons/tknife_metal1.wav");
		precache_sound("weapons/tknife_metal2.wav");
		precache_sound("weapons/tknife_metal3.wav");
		precache_sound("weapons/tknife_stone1.wav");
		precache_sound("weapons/tknife_stone2.wav");
		precache_sound("weapons/tknife_wood1.wav");
		precache_sound("weapons/tknife_wood2.wav");
		precache_sound("weapons/axe_hit1.wav");

		engfunc(EngFunc_PrecacheModel, "models/tknife.mdl");
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_PETROLBOOMER)
	{
		precache_model("models/petrol.mdl")
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_RPG)
	{
		precache_model("models/rpg7_rocket.mdl")
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_CANNONEX)
	{
		CCannonex_Precache();
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_M249EP)
	{
		precache_sound("weapons/m249ep_hit2.wav")
		precache_sound("weapons/m249ep_hit1.wav")
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_M79)
		precache_sound("weapons/m79-1.wav");
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUS9)
	{
		Janus9_Precache();
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_GUILLOTINE)
	{
		CGuillotine_Precache();
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_THANATOS7)
	{
		CThanatos7_Precache();
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_THANATOS5)
	{
		CThanatos5_Precache();
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BLOODHUNTER)
	{
		CBloodhunter_Precache();
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUS7)
	{
		CJanus7_Precache();
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_AUGEX)
	{
		CAugEX_Precache();
	}
	else if(c_iSpecial[iBteWpn] == SPECIAL_GUNKATA)
	{
		CGunkata_Precache();
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_STARCHASERSR)
	{
		CStarchaserSR_Precache();
	}
	

	// !!!
	/*if (c_iType[iBteWpn] == WEAPONS_LAUNCHER)
	{
		format(c_model_v2[iBteWpn], 63, "%s/v_%s_2.mdl", MODEL_URL,c_sModel[iBteWpn])
		if (c_l_type[iBteWpn])
		{
			c_model_v2[iBteWpn] = c_model_v[iBteWpn]
			c_sound2[iBteWpn] = c_sound1[iBteWpn]
			c_sound1_silen[iBteWpn] = c_sound1[iBteWpn]
			c_sound2_silen[iBteWpn] = c_sound1[iBteWpn]
		}
		else
		{
			precache_model(c_model_v2[iBteWpn])
		}
	}*/
}

public Read_MyWeapon()
{
	new sPath[64]
	format(sPath, charsmax(sPath), "%s/%s", g_szConfigDir, BTE_MYWPN_FILE);

	if (!file_exists(sPath))
	{
		Util_Log("Couldn't Open My Weapon File:%s!", BTE_MYWPN_FILE);
		set_fail_state("ERROR! See bte_wpn_log.log for detail");
	}

	new linedata[1024], iLine;
	new file = fopen(sPath, "rt");

	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata));
		replace(linedata, charsmax(linedata), "^n", "");

		if (!('a' <= linedata[0] <= 'z') && !('A' <= linedata[0] <= 'Z'))
			continue;

		if (iLine == 0)
		{
			g_bEnableMyWpn = !equal(linedata, "false");

			copy(g_szMyWpn[0], 63, "knife");
			copy(g_szMyWpn[1], 63, "usp");
			copy(g_szMyWpn[2], 63, "glock18");
			copy(g_szMyWpn[3], 63, "hegrenade");
			copy(g_szMyWpn[4], 63, "smokegrenade");

			iLine = 5;
			continue;
		}

		copy(g_szMyWpn[iLine], 63, linedata);

		iLine++;
	}

	fclose(file);
}

public Read_Block_Res()
{
	new sPath[129]
	format(sPath, 127, "%s/bte_config/bte_blockresource.txt", g_szConfigDir)
	if (!file_exists(sPath))
	{
		Util_Log("Block Resource File Not Found!")
		set_fail_state("ERROR!See bte_wpn_log.log for detail")
	}
	new iFile = fopen(sPath, "r")
	new sBuffer[512]
	while (iFile && !feof(iFile))
	{
		fgets(iFile,sBuffer,511)
		replace_all(sBuffer,511,"^n","")
		copy(g_sBlockResource[g_iBlockNums++],511,sBuffer)
	}
	fclose(iFile)
	Util_Log("Block Resource File Read Successfully!")
}

public ReadWeaponData(szName[], iBteWpn)
{
	new data[128];
	GetPrivateProfile(szName, "WeaponID", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	c_iId[iBteWpn] = GetWeaponID(data);
	if (!c_iId[iBteWpn])
		Util_Log("Warning: WeaponID %d!", c_iId[iBteWpn]);

	if (c_iId[iBteWpn] == CSW_HEGRENADE)
	{
		GetPrivateProfile(szName, "ExplosionSound", "", "cstrike/weapons.ini", BTE_STRING, c_sSound[iBteWpn], 63);
		GetPrivateProfile(szName, "ExplosionSprite", "", "cstrike/weapons.ini", BTE_STRING, data, 63);

		if (data[0])
			c_iSprite[iBteWpn] = engfunc(EngFunc_PrecacheModel, data);

		if (c_sSound[iBteWpn][0])
			precache_sound(c_sSound[iBteWpn]);
	}
	/*
	if (PRIMARY_WEAPONS_BIT_SUM & (1<<c_iId[iBteWpn]))
		c_iSlot[iBteWpn] = WPN_RIFLE;
	else if (SECONDARY_WEAPONS_BIT_SUM & (1<<c_iId[iBteWpn]))
		c_iSlot[iBteWpn] = WPN_PISTOL;
	else if (c_iId[iBteWpn] == CSW_KNIFE)
		c_iSlot[iBteWpn] = WPN_KNIFE;
	else if (c_iId[iBteWpn] != CSW_C4)
		c_iSlot[iBteWpn] = WPN_HE;
	*/
	c_iSlot[iBteWpn] = Stock_Get_Wpn_Slot(c_iId[iBteWpn])
	
	GetPrivateProfile(szName, "Menu", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	c_iMenu[iBteWpn] = GetMenu(data);

	GetPrivateProfile(szName, "Type", "0", "cstrike/weapons.ini", BTE_INT, c_iType[iBteWpn]);
	GetPrivateProfile(szName, "Special", "0", "cstrike/weapons.ini", BTE_INT, c_iSpecial[iBteWpn]);

	GetPrivateProfile(szName, "WorldModel", "0", "cstrike/weapons.ini", BTE_STRING, data);

	c_iModel_W_Sub[iBteWpn] = -1;

	if (data[0] != '0')
	{
		new key[128];

		strtok(data, key, charsmax(key), data, charsmax(data), ',')
		trim(key);
		trim(data);

		copy(c_sModel_W[iBteWpn], 63, key);
		c_iModel_W_Sub[iBteWpn] = str_to_num(data);
	}


	GetPrivateProfile(szName, "AccuracyDefault", "", "cstrike/weapons.ini", BTE_FLOAT, c_flAccuracyDefault[iBteWpn]);
	GetPrivateProfile(szName, "AccuracyCalculate", "", "cstrike/weapons.ini", BTE_INT, c_iAccuracyCalculate[iBteWpn]);
	GetPrivateProfile(szName, "Accuracy", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flAccuracy[iBteWpn]);
	GetPrivateProfile(szName, "AccuracyRange", "0.0, 99.0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flAccuracyRange[iBteWpn]);
	GetPrivateProfile(szName, "AccuracyMul", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flAccuracyMul[iBteWpn]);
	GetPrivateProfile(szName, "Spread", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flSpread[iBteWpn]);
	GetPrivateProfile(szName, "SpreadRun", "", "cstrike/weapons.ini", BTE_FLOAT, c_flSpreadRun[iBteWpn]);
	GetPrivateProfile(szName, "SpreadUnZoom", "", "cstrike/weapons.ini", BTE_FLOAT, c_flSpreadUnZoom[iBteWpn]);

	GetPrivateProfile(szName, "KickBackWalking", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flKickBack[0][iBteWpn]);
	GetPrivateProfile(szName, "KickBackNotOnGround", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flKickBack[1][iBteWpn]);
	GetPrivateProfile(szName, "KickBackDucking", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flKickBack[2][iBteWpn]);
	GetPrivateProfile(szName, "KickBack", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flKickBack[3][iBteWpn]);


	GetPrivateProfile(szName, "Event", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	if (data[0])
	{
		format(data, 128, "events/%s", data);
		Util_Log("PrecacheEvent: %s", data)
		m_usFire[iBteWpn][0] = engfunc(EngFunc_PrecacheEvent, 1, data);
	}
	else
	{
		m_usFire[iBteWpn][0] = WEAPON_EVENT[c_iId[iBteWpn]];
	} 
	
	
	GetPrivateProfile(szName, "EventLeft", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	if (data[0])
	{
		format(data, 128, "events/%s", data);
		Util_Log("PrecacheEvent: %s", data)
		m_usFire[iBteWpn][0] = engfunc(EngFunc_PrecacheEvent, 1, data);
	}

	GetPrivateProfile(szName, "EventRight", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	if (data[0])
	{
		format(data, 128, "events/%s", data);
		Util_Log("PrecacheEvent: %s", data)
		m_usFire[iBteWpn][1] = engfunc(EngFunc_PrecacheEvent, 1, data);
	}
	
	

	GetPrivateProfile(szName, "AttackInterval", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flAttackInterval[iBteWpn], 4);

	GetPrivateProfile(szName, "Damage", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flDamage[iBteWpn], 4);
	c_flDamageZB[iBteWpn][0] = c_flDamage[iBteWpn][0];
	c_flDamageZB[iBteWpn][1] = c_flDamage[iBteWpn][1];
	c_flDamageZB[iBteWpn][2] = c_flDamage[iBteWpn][2];
	c_flDamageZB[iBteWpn][3] = c_flDamage[iBteWpn][3];
	GetPrivateProfile(szName, "DamageZombie", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	if (data[0])
		BreakupStringFloat(data, c_flDamageZB[iBteWpn], 4);

	GetPrivateProfile(szName, "Recoil", "0", "cstrike/weapons.ini", BTE_FLOAT, c_flRecoil[iBteWpn]);

	GetPrivateProfile(szName, "MaxClip", "0", "cstrike/weapons.ini", BTE_INT, c_iClip[iBteWpn]);
	GetPrivateProfile(szName, "Ammo", "0", "cstrike/weapons.ini", BTE_INT, c_iAmmo[iBteWpn]);
	GetPrivateProfile(szName, "MaxAmmo", "0", "cstrike/weapons.ini", BTE_INT, c_iMaxAmmo[iBteWpn]);
	GetPrivateProfile(szName, "AmmoCost", "0", "cstrike/weapons.ini", BTE_INT, c_iAmmoCost[iBteWpn]);

	if (g_c_bUnlimitedBpAmmo && c_iMaxAmmo[iBteWpn] > 0)
		c_iMaxAmmo[iBteWpn] *= 10;

	GetPrivateProfile(szName, "ExtraAmmo", "0", "cstrike/weapons.ini", BTE_INT, c_iExtraAmmo[iBteWpn]);
	GetPrivateProfile(szName, "ExtraAmmoCost", "0", "cstrike/weapons.ini", BTE_INT, c_iExtraAmmoCost[iBteWpn]);

	GetPrivateProfile(szName, "IdleAnim", "-1", "cstrike/weapons_anim.ini", BTE_STRING, data, charsmax(data));
	BreakupStringInt(data, c_iIdleAnim[iBteWpn]);
	GetPrivateProfile(szName, "ReloadAnim", "-1", "cstrike/weapons_anim.ini", BTE_STRING, data, charsmax(data));
	if (c_iId[iBteWpn] == CSW_M3 || c_iId[iBteWpn] == CSW_XM1014)
	{
		if (data[0] == '-')
		{
			c_iReloadAnim[iBteWpn][0] = 3;
			c_iReloadAnim[iBteWpn][1] = 4; // after_reload
			c_iReloadAnim[iBteWpn][2] = 5; // start_reload
		}
		else
			BreakupStringInt(data, c_iReloadAnim[iBteWpn]);
	}
	else
	{
		BreakupStringInt(data, c_iReloadAnim[iBteWpn], 4);
	}

	GetPrivateProfile(szName, "DeployAnim", "-1", "cstrike/weapons_anim.ini", BTE_STRING, data, charsmax(data));
	BreakupStringInt(data, c_iDeployAnim[iBteWpn], 4);

	GetPrivateProfile(szName, "ShotgunShots", "0", "cstrike/weapons.ini", BTE_INT, c_cShots[iBteWpn]);
	GetPrivateProfile(szName, "ShotgunSpread", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_vecSpread[iBteWpn]);

	if (c_iId[iBteWpn] == CSW_M3 || c_iId[iBteWpn] == CSW_XM1014)
	{
		GetPrivateProfile(szName, "ShotgunDamage", "1.0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
		BreakupStringFloat(data, c_flDamage[iBteWpn], 2);
		c_flDamageZB[iBteWpn][0] = c_flDamage[iBteWpn][0];
		c_flDamageZB[iBteWpn][1] = c_flDamage[iBteWpn][1];
		GetPrivateProfile(szName, "ShotgunDamageZombie", "1.0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
		if (data[0])
			BreakupStringFloat(data, c_flDamageZB[iBteWpn], 2);
	}

	GetPrivateProfile(szName, "FireSrcOfs", "0", "cstrike/weapons.ini", BTE_FLOAT, c_flElitesFireSrcOfs[iBteWpn]);
	if (c_iId[iBteWpn] == CSW_ELITE && !c_flElitesFireSrcOfs[iBteWpn])
		c_flElitesFireSrcOfs[iBteWpn] = 5.0;

	GetPrivateProfile(szName, "Penetration", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringInt(data, c_iPenetration[iBteWpn], 4);
	GetPrivateProfile(szName, "BulletType", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	c_iBulletType[iBteWpn] = GetBulletType(data);
	GetPrivateProfile(szName, "RangeModifier", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flRangeModifier[iBteWpn], 4);
	GetPrivateProfile(szName, "Distance", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flDistance[iBteWpn], 4);

	if (c_iId[iBteWpn] == CSW_M3 || c_iId[iBteWpn] == CSW_XM1014)
	{
		GetPrivateProfile(szName, "ReloadTime", "-", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
		if (data[0] == '-')
		{
			c_flReload[iBteWpn][0] = c_iId[iBteWpn] == CSW_M3 ? 0.45 : 0.3;
			c_flReload[iBteWpn][1] = 0.0;
			c_flReload[iBteWpn][2] = 0.55;
		}
		else
			BreakupStringFloat(data, c_flReload[iBteWpn]);
	}
	else
	{
		GetPrivateProfile(szName, "ReloadTime", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
		BreakupStringFloat(data, c_flReload[iBteWpn], 4);
	}

	c_flReloadAnimTime[iBteWpn] = c_flReload[iBteWpn];
	if (c_iId[iBteWpn] == CSW_M3 || c_iId[iBteWpn] == CSW_XM1014)
		c_flReloadAnimTime[iBteWpn][1] = 1.5;

	GetPrivateProfile(szName, "DeployTime", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flDeploy[iBteWpn], 4);

	GetPrivateProfile(szName, "ReloadAnimTime", "-", "cstrike/weapons_anim.ini", BTE_STRING, data, charsmax(data));
	if (data[0] != '-')
		BreakupStringFloat(data, c_flReloadAnimTime[iBteWpn], 4);

	GetPrivateProfile(szName, "DeployAnimTime", "1.25", "cstrike/weapons_anim.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flDeployAnimTime[iBteWpn], 4);
	GetPrivateProfile(szName, "IdleAnimTime", "60.0", "cstrike/weapons_anim.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flIdleAnimTime[iBteWpn], 4);

	GetPrivateProfile(szName, "ShootAnimTime", "0.0", "cstrike/weapons_anim.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flShootAnimTime[iBteWpn], 4);

	GetPrivateProfile(szName, "AnimExtention", "", "cstrike/weapons.ini", BTE_STRING, c_szAnimExtention[iBteWpn], 32);

	GetPrivateProfile(szName, "Zoom", "0, 0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringInt(data, c_iZoom[iBteWpn], 2);
	GetPrivateProfile(szName, "MaxSpeed", "250.0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flMaxSpeed[iBteWpn], 4);

	GetPrivateProfile(szName, "Cost", "0", "cstrike/weapons.ini", BTE_INT, c_iCost[iBteWpn]);

	GetPrivateProfile(szName, "EjectBrass", "0.0", "cstrike/weapons.ini", BTE_FLOAT, c_flEjectBrass[iBteWpn]);

	GetPrivateProfile(szName, "CanBuy", "TRUE", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	if (equal(data, "TRUE"))
		c_bCanBuy[iBteWpn] = TRUE;
	else
		c_bCanBuy[iBteWpn] = FALSE;

	GetPrivateProfile(szName, "Team", "ALL", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	if (equal(data, "TR"))
		c_iTeam[iBteWpn] = 1;
	else if (equal(data, "CT"))
		c_iTeam[iBteWpn] = 2;
	else
		c_iTeam[iBteWpn] = 0;

	GetPrivateProfile(szName, "KnockBack", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flKnockback[iBteWpn]);
	
	GetPrivateProfile(szName, "VelocityModifier", "0.0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flVelocityModifier[iBteWpn]);
	
	GetPrivateProfile(szName, "ArmorRatio", "0.0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flArmorRatio[iBteWpn], 4);
	

	/*if (!c_flKnockback[iBteWpn][1]) c_flKnockback[iBteWpn][1] = 1.0;
	if (!c_flKnockback[iBteWpn][3]) c_flKnockback[iBteWpn][3] = 1.0;*/

	GetPrivateProfile(szName, "Shake", "0", "cstrike/weapons.ini", BTE_INT, c_iShake[iBteWpn]);
	GetPrivateProfile(szName, "GameModeLimit", "0", "cstrike/weapons.ini", BTE_INT, c_iModeLimit[iBteWpn]);


	GetPrivateProfile(szName, "DoubleMode", "", "cstrike/weapons.ini", BTE_STRING, c_sDoubleMode[iBteWpn], 31);

	GetPrivateProfile(szName, "DoubleChangeTime", "-", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	if (data[0] != '-')
	{
		BreakupStringFloat(data, c_flDoubleChange[iBteWpn]);

		//Util_Log("DoubleChangeTime: %f %f", c_flDoubleChange[iBteWpn][0], c_flDoubleChange[iBteWpn][1]);
	}


	GetPrivateProfile(szName, "EntityModel", "s_grenade.mdl", "cstrike/weapons.ini", BTE_STRING, c_sEntityModel[iBteWpn], 64);
	format(c_sEntityModel[iBteWpn], 64, "models/%s", c_sEntityModel[iBteWpn]);

	GetPrivateProfile(szName, "EntitySpawnOrigin", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));

	BreakupStringFloat(data, c_vecViewAttachment[iBteWpn]);

	GetPrivateProfile(szName, "EntitySpeed", "", "cstrike/weapons.ini", BTE_FLOAT, c_flEntitySpeed[iBteWpn]);
	GetPrivateProfile(szName, "EntityAngle", "", "cstrike/weapons.ini", BTE_FLOAT, c_flEntityAngle[iBteWpn]);
	GetPrivateProfile(szName, "EntityGravity", "", "cstrike/weapons.ini", BTE_FLOAT, c_flEntityGravity[iBteWpn]);

	GetPrivateProfile(szName, "EntityMoveType", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	c_iEntityMove[iBteWpn] = GetEntityMoveType(data);
	GetPrivateProfile(szName, "EntityClass", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	c_iEntityClass[iBteWpn] = GetEntityClass(data);

	GetPrivateProfile(szName, "EntityBeam", "", "cstrike/weapons.ini", BTE_INT, c_iEntityBeam[iBteWpn]);
	GetPrivateProfile(szName, "EntityLightEffect", "0", "cstrike/weapons.ini", BTE_INT, c_iEntityLightEffect[iBteWpn]);
	GetPrivateProfile(szName, "EntityKnockBack", "0", "cstrike/weapons.ini", BTE_FLOAT, c_flEntityKnockBack[iBteWpn]);


	GetPrivateProfile(szName, "EntityRange", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flEntityRange[iBteWpn], 2);

	GetPrivateProfile(szName, "EntityDamage", "0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flEntityDamage[iBteWpn], 2);
	c_flEntityDamageZB[iBteWpn][0] = c_flEntityDamage[iBteWpn][0];
	c_flEntityDamageZB[iBteWpn][1] = c_flEntityDamage[iBteWpn][1];
	GetPrivateProfile(szName, "EntityDamageZombie", "", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	if (data[0])
		BreakupStringFloat(data, c_flEntityDamageZB[iBteWpn], 2);

	//Util_Log("EntityDamage: %f %f", c_flEntityDamage[iBteWpn][0], c_flEntityDamageZB[iBteWpn][0], data);


	if (c_iId[iBteWpn] == CSW_KNIFE)
	{
		if (!c_flDistance[iBteWpn][0]) c_flDistance[iBteWpn][0] = 48.0;
		if (!c_flDistance[iBteWpn][1]) c_flDistance[iBteWpn][1] = 32.0;
		if (!c_flDamage[iBteWpn][0]) c_flDamage[iBteWpn][0] = 15.0;
		if (!c_flDamage[iBteWpn][1]) c_flDamage[iBteWpn][1] = 65.0;
		if (!c_flDamageZB[iBteWpn][0]) c_flDamageZB[iBteWpn][0] = 75.0;
		if (!c_flDamageZB[iBteWpn][1]) c_flDamageZB[iBteWpn][1] = 325.0;
		if (!c_flAttackInterval[iBteWpn][0]) c_flAttackInterval[iBteWpn][0] = 0.4;
		if (!c_flAttackInterval[iBteWpn][1]) c_flAttackInterval[iBteWpn][1] = 1.1;
	}
	
	GetPrivateProfile(szName, "Delay", "0.0, 0.0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flDelay[iBteWpn], 4);

	GetPrivateProfile(szName, "Angle", "0.0, 0.0", "cstrike/weapons.ini", BTE_STRING, data, charsmax(data));
	BreakupStringFloat(data, c_flAngle[iBteWpn], 4);


	GetPrivateProfile(szName, "BurstTimes", "0", "cstrike/weapons.ini", BTE_INT, c_iBurstTimes[iBteWpn]);
	GetPrivateProfile(szName, "BurstSpeed", "0", "cstrike/weapons.ini", BTE_FLOAT, c_flBurstSpeed[iBteWpn]);
	GetPrivateProfile(szName, "BurstSpread", "0", "cstrike/weapons.ini", BTE_FLOAT, c_flBurstSpread[iBteWpn]);

	GetPrivateProfile(szName, "Punchangle", "0.0", "cstrike/weapons.ini", BTE_FLOAT, c_flPunchangle[iBteWpn]);

	/*new iEntitySpawnOrigin;
	GetPrivateProfile(szName, "EntitySpawnOrigin", "5", "cstrike/weapons.ini", BTE_INT, iEntitySpawnOrigin);
	if (iEntitySpawnOrigin < 5)
	{
		// 失败 QAQ 放弃
		GetModelAttachment(c_model_v[iBteWpn], 0, c_vecViewAttachment[iBteWpn]);
		Util_Log("GetModelAttachment: Origin[%d]: %f %f %f", iEntitySpawnOrigin, c_vecViewAttachment[iBteWpn][0], c_vecViewAttachment[iBteWpn][1], c_vecViewAttachment[iBteWpn][2]);
	}*/

	/*new Float:vecOrigin[3];
	GetModelAttachment(c_model_v[iBteWpn], 0, vecOrigin);
	Util_Log("GetWeaponData: ID: %d Damage: %f, %f DamageZB: %f, %f BulletType: %d", c_iId[iBteWpn], c_flDamage[iBteWpn][0], c_flDamage[iBteWpn][1], c_flDamageZB[iBteWpn][0], c_flDamageZB[iBteWpn][1], c_iBulletType[iBteWpn])
	Util_Log("GetModelAttachment: Origin[0]: %f %f %f", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
	*/
}

