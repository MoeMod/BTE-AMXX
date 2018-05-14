#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include <orpheu>

#define PLUGIN "[Z4E] Gameplay Fix"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_forward(FM_ClientKill, "fw_ClientKill")
    
    OrpheuRegisterHook(OrpheuGetFunction("DispatchBlocked"), "OnDispatchBlocked")
}

public fw_ClientKill()
{
    return FMRES_SUPERCEDE;
}

public OrpheuHookReturn:DispatchBlocked(pEntity, pOther)
{
    if(is_user_alive(pEntity) && is_user_alive(pOther))
        return OrpheuSupercede 
    return OrpheuIgnored
}