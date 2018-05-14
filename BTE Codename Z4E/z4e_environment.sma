#include <amxmodx>
#include <fakemeta_util>

#define PLUGIN "[Z4E] Environment"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

new const SKYNAMES[][] = { "hk" }

new g_pFogEntity

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
}

public plugin_precache()
{
    new szBuffer[64]
    // Weather & Sky
    fm_remove_entity_name("env_fog")
    g_pFogEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
    //engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"))
    //engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_snow"))
    Set_EnvironmentFog( "0.003", "25 25 25")
    
    for(new i = 0; i < sizeof(SKYNAMES); i++)
    {
        // Preache custom sky files
        formatex(szBuffer, charsmax(szBuffer), "gfx/env/%sbk.tga", SKYNAMES[i]); engfunc(EngFunc_PrecacheGeneric, szBuffer)
        formatex(szBuffer, charsmax(szBuffer), "gfx/env/%sdn.tga", SKYNAMES[i]); engfunc(EngFunc_PrecacheGeneric, szBuffer)
        formatex(szBuffer, charsmax(szBuffer), "gfx/env/%sft.tga", SKYNAMES[i]); engfunc(EngFunc_PrecacheGeneric, szBuffer)
        formatex(szBuffer, charsmax(szBuffer), "gfx/env/%slf.tga", SKYNAMES[i]); engfunc(EngFunc_PrecacheGeneric, szBuffer)
        formatex(szBuffer, charsmax(szBuffer), "gfx/env/%srt.tga", SKYNAMES[i]); engfunc(EngFunc_PrecacheGeneric, szBuffer)
        formatex(szBuffer, charsmax(szBuffer), "gfx/env/%sup.tga", SKYNAMES[i]); engfunc(EngFunc_PrecacheGeneric, szBuffer)        
    }     
}

public plugin_cfg()
{
    set_cvar_num("sv_skycolor_r", 150)
    set_cvar_num("sv_skycolor_g", 150)
    set_cvar_num("sv_skycolor_b", 150)    
    
    
    // Sky
    set_cvar_string("sv_skyname", SKYNAMES[random_num(0, sizeof(SKYNAMES) - 1)])

}

Set_EnvironmentFog(szDensity[] = "0.0016", szColor[] = "0 0 0")
{
    if (pev_valid(g_pFogEntity))
    {
        fm_set_kvd(g_pFogEntity, "density", szDensity, "env_fog")
        fm_set_kvd(g_pFogEntity, "rendercolor", szColor, "env_fog")
    }
}