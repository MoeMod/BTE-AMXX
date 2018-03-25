public SetKnifeDelay(iEnt, Float:flDelay, const function[])
{
	set_pev(iEnt, pev_nextthink, get_gametime() + flDelay);
	BTE_SetThink(iEnt, function);
}

public ClearThink(iEnt)
{
	BTE_SetThink(iEnt, "");
}