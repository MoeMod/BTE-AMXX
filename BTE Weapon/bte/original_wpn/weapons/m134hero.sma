native CM134Hero_KickBack(pWeapon, Float:up_base, Float:lateral_base, Float:up_modifier, Float:lateral_modifier, Float:up_max, Float:lateral_max, direction_change);

#define M134HERO_NONE		0
#define M134HERO_SECATTACKING	1
#define M134HERO_OVERHEAT	2

public CM134Hero_Deploy(id, iEnt, iBteWpn)
{
	if (!get_pdata_int(iEnt, m_iWeaponState))
		return 1;

}

public CM134Hero_Radiating(id, iEnt, iBteWpn)
{
	
}