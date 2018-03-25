// [BTE Util Function]

public Util_Log(const szString[],any:...)
{
	new szWrite[256]
	new hLog = fopen(g_szLogName,"a")
	vformat(szWrite,charsmax(szWrite),szString,2)
	fprintf(hLog,szWrite)
	fprintf(hLog,"^n")
	fclose(hLog)
}
