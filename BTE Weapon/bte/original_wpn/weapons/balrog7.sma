public CBalrog7_ItemPostFrame(id, iEnt, iClip, iBteWpn)
{
	if (!(pev(id, pev_button) & IN_ATTACK))
		set_pev(iEnt, pev_iuser1, 0);
}

public CBalrog7_PrimaryAttack_Post(id, iEnt, iId, iClip, iBteWpn)
{
	static iShootTime;
	iShootTime = pev(iEnt, pev_iuser1)

	if (iShootTime>10)
	{
		
		g_anim[id] = 1 - g_anim[id]
		//SendWeaponAnim(id, WEAPON_TOTALANIM[c_iId[iBteWpn]] + g_anim[id])

		iShootTime = 0

		// Explosion
		static vOri[3],Float:fVec[3],Float:vOrigin[3]
		static Float:fRadius,Float:fDistance,Float:fDamage

		fRadius=100.0
		static Float:fRadiusDmg
		fRadiusDmg= 120.0
		get_user_origin(id,vOri,3)
		IVecFVec(vOri,fVec)
		// Damage
		new iVictim = -1
		while ((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, fVec, fRadius)) != 0)
		{
			if (!pev_valid(iVictim) || !is_user_alive(iVictim)) continue;
			if (iVictim == id) continue
			if (!can_damage(iVictim, id)) continue;

			Stock_Get_Origin(iVictim, vOrigin)
			fDistance = get_distance_f(fVec, vOrigin)
			if (fDistance>fRadius) continue
			fDamage = fRadiusDmg - floatmul(fRadiusDmg, floatdiv(fDistance, fRadius)) //get the damage value
			fDamage *= Stock_Adjust_Damage(fVec, iVictim, 0) //adjust
			
			if (fDamage<1.0) 
				fDamage = 1.0
			
			set_pdata_int(iVictim, 75, HIT_CHEST);
			ExecuteHamB(Ham_TakeDamage, iVictim, iEnt, id, fDamage, DMG_EXPLOSION);
			
		}
		// Effect
		/*message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_EXPLOSION)
		write_coord(vOri[0])
		write_coord(vOri[1])
		write_coord(vOri[2])
		write_short(g_cache_explo)
		write_byte(10)
		write_byte(16)
		write_byte(TE_EXPLFLAG_NOPARTICLES)
		message_end()

		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_EXPLOSION)
		write_coord(vOri[0])
		write_coord(vOri[1])
		write_coord(vOri[2]+20)
		write_short(g_cache_barlog7exp)
		write_byte(5)
		write_byte(1)
		write_byte(TE_EXPLFLAG_NONE)
		message_end()*/
		fVec[2] += 20;
		engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, WEAPON_EVENT[CSW_KNIFE], 0.0, fVec, {0.0, 0.0, 0.0}, 0.0 , 0.0, (1<<3), 1, false, false);

		// TODO Muz
	
	}

	
	iShootTime ++
	set_pev(iEnt, pev_iuser1, iShootTime)
	
}