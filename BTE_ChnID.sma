/* 本插件由 AMXX-Studio 中文版自动生成*/
/* UTF-8 func by www.DT-Club.net */

#include <amxmodx>
#include <fakemeta>
native bte_setname(id,name[])
#define PLUGIN_NAME	"CS CHN ID"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"New BTE TEAM"
#define NAME_MAX	32

new const URL[]="addons/amxmodx/configs/randname/last.txt"
new const URL2[]="addons/amxmodx/configs/randname/first.txt"

new szNamelist[33][32],szNamelist2[33][32]
new g_bNameUsed[33], g_bNameUsed2[33]
new g_iPlayerUseName[33], g_iPlayerUseName2[33]
new g_iUsedNum, g_iUsedNum2
new iAllNum,iAllNum2
public plugin_precache()
{
	loadnamelist()
}
public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
}
public client_connect(id) //client_putinserver
{
	if(!is_user_bot(id)) return
	//set_task(1.0,"ChangeName",id) //做个延迟比较好
	ChangeName(id);
}
public client_disconnect(id)
{
	if(!is_user_bot(id)) return
	g_iUsedNum--;
	g_iUsedNum2--;
	g_bNameUsed[g_iPlayerUseName[id]] = 0;
	g_bNameUsed2[g_iPlayerUseName2[id]] = 0;
}

public ChangeName(id)
{
	new szName[32];
	randname(id, szName, 31);
	
	//bte_setname(id,szNamelist[i]) // in fakemeta (modified)
	set_user_info(id, "name", szName);

}
public loadnamelist()
{
	new hFile = fopen(URL, "rt"),hFile2 = fopen(URL2, "rt");
	if(!hFile||!hFile2)
	{
		log_amx("文件读取错误")
		set_fail_state("文件读取错误")
		fclose(hFile)
		fclose(hFile2)
	}
	new szLine[128],iLine=1,szLine2[128],iLine2=1;
	while (!feof(hFile))
	{
		fgets(hFile, szLine,127)
		replace(szLine, 127, "^n", "")
		trim(szLine)
		if(szLine[0]==';') continue
		copy(szNamelist[iLine],31,szLine)
		iLine++
		if(iLine>NAME_MAX) break
	}
	iAllNum = iLine-1
	while (!feof(hFile2))
	{
		fgets(hFile2, szLine2,127)
		replace(szLine2, 127, "^n", "")
		trim(szLine2)
		if(szLine2[0]==';') continue
		copy(szNamelist2[iLine2],31,szLine2)
		iLine2++
		if(iLine2>NAME_MAX) break
	}
	iAllNum2 = iLine2-1
	fclose(hFile)
	fclose(hFile2)
}

public randname(id, szName[], len)
{
	if(g_iUsedNum >= iAllNum || g_iUsedNum2 >= iAllNum2)
		return;
	new i, j
	do
	{
		i = random_num(1,iAllNum);
		j = random_num(1,iAllNum2);
	} while(!g_bNameUsed[i] && !g_bNameUsed2[j])
	g_bNameUsed[i] = 1
	g_bNameUsed2[j] = 1
	g_iPlayerUseName[id] = i
	g_iPlayerUseName2[id] = j
	format(szName,len,"%s%s",szNamelist[i],szNamelist2[j])
	
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg936\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset134 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2052\\ f0\\ fs16 \n\\ par }
*/
