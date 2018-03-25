// Zombie DNA
enum _:TOTAL_DNA
{
	DNA_GENE_STRENGTHEN,
	DNA_INFECTION,
	DNA_CRISIS_RECOVERY,
	DNA_SPEED_STRENGTHEN,
	DNA_STRENGTHEN_GROUP,
	DNA_MOVING_RECOVERY,
	DNA_RECOVERY_STRENGTHEN,
	DNA_CRISIS_DEFENCE, // x	【抵抗强化】每损失相当于HP上限的7%时，自身获得2.5%的移动速度、击退抵抗、僵直抵抗
	DNA_PAINSHOCK_STRENGTHEN,
	DNA_ACCSHOOT_STRENGTHEN,
	DNA_GRAVITY_STRENGTHEN,
	DNA_ARMOR_STRENGTHEN,
	DNA_DEFENCE_STRENGTHEN,
	DNA_GODMODE_STRENGTHEN,
	DNA_FREEZE_ON_HIT, //   x	【被击冷却】受到攻击时，有1.5%概率重置所有技能的CD，两次重置的最短间隔时间为10秒。
	DNA_FREEZE_STRENGTHEN, // x	【快速冷却】主技能（默认G键）冷却时间减少5%。
	DNA_ZOMBIE_ENVY,
	DNA_SKILL_STRENGTHEN, // x	【技能强化】将所有僵尸（不包括两名英雄僵尸）的主要技能（默认G键）提升至相当于原“僵尸进化系统”三阶段5级水准。
	DNA_RAGE_STRENGTHEN,
}
#define DNA_BITSUM (1<<TOTAL_DNA) - 1
#define MAX_DNA 12

new g_bitsDNA[33]
new Float:g_flNextEnvyCheck[33]
new Float:g_flNextSkillReset[33]

public DNA_LoadSettings(id)
{
	if(is_user_bot(id))
	{
		while((~g_bitsDNA[id] & DNA_BITSUM) && BitsCount(g_bitsDNA[id]) < MAX_DNA)
		{
			BitsSet(g_bitsDNA[id], BitsGetRandom(~g_bitsDNA[id] & DNA_BITSUM));
		}
	}
	else
	{
		static szStored[32];
		get_user_info(id, "bte_dna", szStored, 31);
		new bitsStored = str_to_num(szStored);
		if(BitsCount(bitsStored) <= MAX_DNA)
		{
			g_bitsDNA[id] = bitsStored & DNA_BITSUM;
		}
	}
	
	/*
	else
	{
		new bitsRemaining = DNA_BITSUM
		bitsStored = 0
		for(new i;i < MAX_DNA; i++)
		{
			new iDNA = BitsGetRandom(bitsRemaining)
			BitsSet(bitsStored, iDNA)
			BitsUnSet(bitsRemaining, iDNA)
		}
		g_bitsDNA[id] = bitsStored & DNA_BITSUM
	}*/
}

public DNA_OnZombieInfectedHuman(iAttacker, iVictim)
{
	if(BitsGet(g_bitsDNA[iAttacker], DNA_INFECTION))
	{
		new iHealth = min(g_iZombieMaxHealth[iAttacker], g_iZombieMaxHealth[iAttacker] / 10 + get_user_health(iAttacker))
		set_pev(iAttacker, pev_health, float(iHealth))
	}
	
	for(new i = 1; i < 33;i++)
	{
		if(!is_user_alive(i) || !g_zombie[i])
			continue;
		if(BitsGet(g_bitsDNA[i], DNA_STRENGTHEN_GROUP))
		{
			g_iZombieMaxHealth[i] += 100
			new iHealth = get_user_health(i) + 100
			set_pev(i, pev_health, float(iHealth))
		}
	}
	
	if(BitsGet(g_bitsDNA[iVictim], DNA_GENE_STRENGTHEN))
		g_iZombieMaxHealth[iVictim] += 3000
	if(BitsGet(g_bitsDNA[iVictim], DNA_ARMOR_STRENGTHEN))
		g_iZombieMaxArmor[iVictim] += 3000;
	
}

public DNA_OnBeingZombieOrigin(id)
{
	if(BitsGet(g_bitsDNA[id], DNA_GENE_STRENGTHEN))
		g_iZombieMaxHealth[id] += 3000
	if(BitsGet(g_bitsDNA[id], DNA_ARMOR_STRENGTHEN))
		g_iZombieMaxArmor[id] += 3000;
	
	//if(BitsGet(g_bitsDNA[id], DNA_STRENGTHEN_LV2))
	//	g_iZombieMaxHealth[id] += 500;
}

public DNA_OnZombieEvolution(id)
{
	if(BitsGet(g_bitsDNA[id], DNA_ARMOR_STRENGTHEN))
		g_iZombieMaxArmor[id] += 3000;
	
	//if(BitsGet(g_bitsDNA[id], DNA_STRENGTHEN_LV2))
	//	g_iZombieMaxHealth[id] += 500;
}

DNA_RageEnvyThink(id)
{
	
	if(get_gametime() < g_flNextEnvyCheck[id])
		return
	if(g_zombie[id] && BitsGet(g_bitsDNA[id], DNA_ZOMBIE_ENVY))
	{
		if(g_level[id] == 3)
			return
		for(new i = 0; i < 33; i++)
		{
			if(!is_user_alive(i))
				continue;
			if(!g_zombie[i])
				continue;
			if(i == id)
				continue;
			if(g_level[id] >= g_level[i])
				continue;
			if(fm_entity_range(id, i) > 200.0)
				continue;
				
			UpdateEvolutionDamage(id, 200.0)
			g_flNextEnvyCheck[id] = get_gametime() + 1.0
			return
		}
	}
	g_flNextEnvyCheck[id] = get_gametime() + 1.0
	
}

// 1.5%概率+间隔10秒?
DNA_CheckSkillReset(id)
{
	if(get_gametime() < g_flNextSkillReset[id])
		return;
	if(random_num(1,200) <= 3)
	{
		ExecuteForward(g_fwResetSkill, g_fwDummyResult, id);
		g_flNextSkillReset[id] = get_gametime() + 10.0;
	}
	
}