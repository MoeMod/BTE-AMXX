#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>

#include "z4e_bits.inc"
#include "z4e_api.inc"
#include "z4e_team.inc"

#include "../BTE_API.inc"

#define PLUGIN "[Z4E] Zombie"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

// OffSet
#define PDATA_SAFE 2
#define OFFSET_LINUX_WEAPONS 4
#define OFFSET_LINUX 5
#define OFFSET_WEAPONOWNER 41
#define OFFSET_WEAPONTYPE 43
#define OFFSET_VELOCITYMODIFIER 108
#define OFFSET_ARMORTYPE 112

new const ZOMBIE_MODEL[][] = { "tank_zombi_host", "tank_zombi_origin" }

// Forwards
enum _:TOTAL_FORWARDS
{
    FW_ORIGINATE_PRE,
    FW_ORIGINATE_ACT,
    FW_ORIGINATE_POST,
    FW_INFECT_PRE,
    FW_INFECT_ACT,
    FW_INFECT_POST,
    FW_RESPAWN_PRE,
    FW_RESPAWN_ACT,
    FW_RESPAWN_POST,
}
new g_iForwards[TOTAL_FORWARDS]
new g_iForwardResult

new g_bitsOrigin
new g_iMaxHealth[33], g_iMaxArmor[33]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage_Post", 1)
    RegisterHam(Ham_Use, "func_tank", "HamF_UseStationary")
    RegisterHam(Ham_Use, "func_tankmortar", "HamF_UseStationary")
    RegisterHam(Ham_Use, "func_tankrocket", "HamF_UseStationary")
    RegisterHam(Ham_Use, "func_tanklaser", "HamF_UseStationary")
    RegisterHam(Ham_Use, "func_tank", "HamF_UseStationary_Post", 1)
    RegisterHam(Ham_Use, "func_tankmortar", "HamF_UseStationary_Post", 1)
    RegisterHam(Ham_Use, "func_tankrocket", "HamF_UseStationary_Post", 1)
    RegisterHam(Ham_Use, "func_tanklaser", "HamF_UseStationary_Post", 1)
    RegisterHam(Ham_Touch, "weaponbox", "HamF_TouchWeapon")
    RegisterHam(Ham_Touch, "armoury_entity", "HamF_TouchWeapon")
    RegisterHam(Ham_Touch, "weapon_shield", "HamF_TouchWeapon")
    
    g_iForwards[FW_ORIGINATE_PRE] = CreateMultiForward("z4e_fw_zombie_originate_pre", ET_CONTINUE, FP_CELL, FP_CELL)
    g_iForwards[FW_ORIGINATE_ACT] = CreateMultiForward("z4e_fw_zombie_originate_act", ET_IGNORE, FP_CELL, FP_CELL)
    g_iForwards[FW_ORIGINATE_POST] = CreateMultiForward("z4e_fw_zombie_originate_post", ET_IGNORE, FP_CELL, FP_CELL)
    g_iForwards[FW_INFECT_PRE] = CreateMultiForward("z4e_fw_zombie_infect_pre", ET_CONTINUE, FP_CELL, FP_CELL)
    g_iForwards[FW_INFECT_ACT] = CreateMultiForward("z4e_fw_zombie_infect_act", ET_IGNORE, FP_CELL, FP_CELL)
    g_iForwards[FW_INFECT_POST] = CreateMultiForward("z4e_fw_zombie_infect_post", ET_IGNORE, FP_CELL, FP_CELL)
    g_iForwards[FW_RESPAWN_PRE] = CreateMultiForward("z4e_fw_zombie_respawn_pre", ET_CONTINUE, FP_CELL)
    g_iForwards[FW_RESPAWN_ACT] = CreateMultiForward("z4e_fw_zombie_respawn_act", ET_IGNORE, FP_CELL)
    g_iForwards[FW_RESPAWN_POST] = CreateMultiForward("z4e_fw_zombie_respawn_post", ET_IGNORE, FP_CELL)
}

public plugin_precache()
{
    new i, szBuffer[64]
    
    for(i = 0; i < sizeof(ZOMBIE_MODEL); i++) 
    {
        format(szBuffer, charsmax(szBuffer), "models/player/%s/%s.mdl", ZOMBIE_MODEL[i], ZOMBIE_MODEL[i])
        engfunc(EngFunc_PrecacheModel, szBuffer); 
    }
}

public plugin_natives()
{
    register_native("z4e_zombie_originate", "Native_Originate", 1)
    register_native("z4e_zombie_infect", "Native_Infect", 1)
    register_native("z4e_zombie_respawn", "Native_Respawn", 1)
}

public Native_Originate(id, iZombieCount, bIgnoreCheck)
{
    if(!bIgnoreCheck)
    {
        ExecuteForward(g_iForwards[FW_ORIGINATE_PRE], g_iForwardResult, id, iZombieCount)
        if(g_iForwardResult >= 1)
            return 0
    }
    ExecuteForward(g_iForwards[FW_ORIGINATE_ACT], g_iForwardResult, id, iZombieCount)
    g_iMaxHealth[id] = ((z4e_team_count(Z4E_TEAM_HUMAN, 1) + z4e_team_count(Z4E_TEAM_ZOMBIE, 1) / iZombieCount) + 1) * 1000
    g_iMaxArmor[id] = 1100
    BitsSet(g_bitsOrigin, id)
    z4e_team_set(id, Z4E_TEAM_ZOMBIE)
    ZombieME(id)
    ExecuteForward(g_iForwards[FW_ORIGINATE_POST], g_iForwardResult, id, iZombieCount)
    return 1
}

public Native_Infect(id, iAttacker, bIgnoreCheck)
{
    if(!bIgnoreCheck)
    {
        ExecuteForward(g_iForwards[FW_INFECT_PRE], g_iForwardResult, id, iAttacker)
        if(g_iForwardResult >= 1)
            return 0
    }
    ExecuteForward(g_iForwards[FW_INFECT_ACT], g_iForwardResult, id, iAttacker)
    if(is_user_alive(iAttacker))
    {
        g_iMaxHealth[id] = max(floatround(float(get_user_health(iAttacker)) * 0.75), 4000)
        g_iMaxArmor[id] = max(get_user_armor(iAttacker) / 2, 200)
    }
    else
    {
        g_iMaxHealth[id] = 4000
        g_iMaxArmor[id] = 200
    }
    BitsUnSet(g_bitsOrigin, id)
    z4e_team_set(id, Z4E_TEAM_ZOMBIE)
    ZombieME(id)
    ExecuteForward(g_iForwards[FW_INFECT_POST], g_iForwardResult, id, iAttacker)
    return 1
}

public Native_Respawn(id, bIgnoreCheck)
{
    if(!bIgnoreCheck)
    {
        ExecuteForward(g_iForwards[FW_RESPAWN_PRE], g_iForwardResult, id)
        if(g_iForwardResult >= 1)
            return 0
    }
    ExecuteForward(g_iForwards[FW_RESPAWN_ACT], g_iForwardResult, id)
    z4e_team_set(id, Z4E_TEAM_ZOMBIE)
    if(!is_user_alive(id))
    {
        set_pev(id, pev_deadflag, DEAD_RESPAWNABLE)
        ExecuteHamB(Ham_CS_RoundRespawn, id)
    }
    ZombieME(id)
    ExecuteForward(g_iForwards[FW_RESPAWN_POST], g_iForwardResult, id)
    return 1
}

public z4e_fw_api_bot_registerham(id)
{
    RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage_Post", 1)
}

public z4e_fw_gameplay_round_new()
{
    g_bitsOrigin = 0
}

public client_connect(id)
{
    g_iMaxArmor[id] = 0
}

public z4e_fw_team_spawn_post(id)
{
    if(z4e_team_get(id) == Z4E_TEAM_ZOMBIE)
    {
        Native_Respawn(id, 1)
    }
    return PLUGIN_CONTINUE
}

public z4e_fw_team_set_post(id, iTeam)
{
    if(iTeam != Z4E_TEAM_ZOMBIE || !is_user_alive(id))
        return;
    ZombieME(id)
}

ZombieME(id)
{
    if(g_iMaxHealth[id] < 1000)
    {
        g_iMaxHealth[id] = 1000
    }
    set_pev(id, pev_max_health, float(g_iMaxHealth[id]))
    fm_set_user_health(id, g_iMaxHealth[id])
        
    if(pev_valid(id) == PDATA_SAFE)
        set_pdata_int(id, OFFSET_ARMORTYPE, 1);
    fm_set_user_armor(id, g_iMaxArmor[id])
    
    if(BitsGet(g_bitsOrigin, id))
    {
        set_pev(id, pev_body, 1)
        set_pev(id, pev_skin, 0)
        z4e_api_set_player_model(id, ZOMBIE_MODEL[1])
    }
    else
    {
        set_pev(id, pev_body, random_num(0,6))
        set_pev(id, pev_skin, random_num(0,1))
        z4e_api_set_player_model(id, ZOMBIE_MODEL[0])
    }
    z4e_api_set_player_maxspeed(id, 290.0)
    set_pev(id, pev_gravity, 0.8)
    
    // Start Weapon
    fm_strip_user_weapons(id)
    /*new pKnife = fm_give_item(id, "weapon_knife")*/
	bte_wpn_give_named_wpn(id, "knife");
	new pKnife = fm_get_user_weapon_entity(id, CSW_KNIFE);
    if(pev_valid(pKnife))
        ExecuteHamB(Ham_Item_Deploy, pKnife);
	
    
    // Turn Off the FlashLight
    if (pev(id, pev_effects) & EF_DIMLIGHT) set_pev(id, pev_impulse, 100)
    else set_pev(id, pev_impulse, 0)
    
    // Bug Fix
    fm_set_user_rendering(id)
    client_cmd(id, "-duck")
}

public HamF_TakeDamage_Post(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
    if(!is_user_connected(iVictim))
        return HAM_IGNORED
    
    if(z4e_team_get(iVictim) != Z4E_TEAM_ZOMBIE)
        return HAM_IGNORED
    
    if(get_user_weapon(iVictim) == CSW_KNIFE)
        set_pev(iVictim, pev_punchangle, Float:{ 0.0, 0.0, 0.0 })
    
    return HAM_IGNORED
}

public HamF_UseStationary(entity, caller, activator, use_type)
{
    if (use_type == 2 && is_user_connected(caller) && z4e_team_get(caller) == Z4E_TEAM_ZOMBIE)
        return HAM_SUPERCEDE
    return HAM_IGNORED
}

public HamF_UseStationary_Post(entity, caller, activator, use_type)
{
    if(use_type == 0 && is_user_connected(caller) && z4e_team_get(caller) == Z4E_TEAM_ZOMBIE)
    {
        if(get_user_weapon(caller) == CSW_KNIFE)
        {
            new pKnife = fm_get_user_weapon_entity(caller, CSW_KNIFE)
            if(pev_valid(pKnife))
                ExecuteHamB(Ham_Item_Deploy, pKnife)
        }
    }
}

public HamF_TouchWeapon(weapon, id)
{
    if(!is_user_connected(id))
        return HAM_IGNORED
    if(z4e_team_get(id) == Z4E_TEAM_ZOMBIE)
        return HAM_SUPERCEDE
    
    return HAM_IGNORED
}