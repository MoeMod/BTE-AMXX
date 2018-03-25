// [BTE Util Function]

public Util_Log(const szString[],any:...)
{
	static szWrite[256]
	g_hLog = fopen(g_szLogName,"a")
	vformat(szWrite,charsmax(szWrite),szString,2)
	fprintf(g_hLog,szWrite)
	fprintf(g_hLog,"^n")
	fclose(g_hLog)
}
