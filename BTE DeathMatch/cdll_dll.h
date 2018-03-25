/***
*
*	Copyright (c) 1996-2002, Valve LLC. All rights reserved.
*
*	This product contains software technology licensed from Id
*	Software, Inc. ("Id Technology").  Id Technology (c) 1996 Id Software, Inc.
*	All Rights Reserved.
*
*   Use, distribution, and modification of this source code and/or resulting
*   object code is restricted to non-commercial enhancements to products from
*   Valve LLC.  All other use, distribution, or modification is prohibited
*   without written permission from Valve LLC.
*
****/

#define MAX_WEAPONS 32
#define MAX_WEAPON_SLOTS 5
#define MAX_ITEM_TYPES 6
#define MAX_ITEMS 4

#define HIDEHUD_WEAPONS (1<<0)
#define HIDEHUD_FLASHLIGHT (1<<1)
#define HIDEHUD_ALL (1<<2)
#define HIDEHUD_HEALTH (1<<3)
#define HIDEHUD_TIMER (1<<4)
#define HIDEHUD_MONEY (1<<5)
#define HIDEHUD_CROSSHAIR (1<<6)

#define MAX_AMMO_TYPES 32
#define MAX_AMMO_SLOTS 32

#define HUD_PRINTNOTIFY 1
#define HUD_PRINTCONSOLE 2
#define HUD_PRINTTALK 3
#define HUD_PRINTCENTER 4
#define HUD_PRINTRADIO 5

#define SCOREATTRIB_DEAD (1<<0)
#define SCOREATTRIB_BOMB (1<<1)
#define SCOREATTRIB_VIP (1<<2)

#define STATUSICON_HIDE 0
#define STATUSICON_SHOW 1
#define STATUSICON_FLASH 2

#define TEAM_UNASSIGNED 0
#define TEAM_TERRORIST 1
#define TEAM_CT 2
#define TEAM_SPECTATOR 3

#define CLASS_UNASSIGNED 0
#define CLASS_URBAN 1
#define CLASS_TERROR 2
#define CLASS_LEET 3
#define CLASS_ARCTIC 4
#define CLASS_GSG9 5
#define CLASS_GIGN 6
#define CLASS_SAS 7
#define CLASS_GUERILLA 8
#define CLASS_VIP 9
#define CLASS_MILITIA 10
#define CLASS_SPETSNAZ 11

#define MENU_KEY_1 (1<<0)
#define MENU_KEY_2 (1<<1)
#define MENU_KEY_3 (1<<2)
#define MENU_KEY_4 (1<<3)
#define MENU_KEY_5 (1<<4)
#define MENU_KEY_6 (1<<5)
#define MENU_KEY_7 (1<<6)
#define MENU_KEY_8 (1<<7)
#define MENU_KEY_9 (1<<8)
#define MENU_KEY_0 (1<<9)

#define MENUTYPE_CHOOSETEAM 2
#define MENUTYPE_CHOOSECLASS_T 26
#define MENUTYPE_CHOOSECLASS_CT 27
#define MENUTYPE_BUY 28
#define MENUTYPE_BUYPISTOL 29
#define MENUTYPE_BUYSHOTGUN 30
#define MENUTYPE_BUYRIFLE 31
#define MENUTYPE_BUYSUBMACHINEGUN 32
#define MENUTYPE_BUYMACHINEGUN 33
#define MENUTYPE_BUYITEM 34

#define IUSER3_LIMIT (1<<0)
#define IUSER3_FREEZE (1<<1)
#define IUSER3_PLANTING (1<<2)
#define IUSER3_HASSHIELD (1<<3)

#define ITEMSTATE_HASNIGHTVISION (1<<0)
#define ITEMSTATE_HASDEFUSER (1<<1)

#define WEAPON_SUIT 31
