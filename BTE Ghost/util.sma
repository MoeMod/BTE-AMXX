#include "util.h"

stock gmsgTextMsg;
stock gmsgArmorType;
stock gmsgBlinkAcct;
stock gmsgMoney;

stock ClientPrint(id, type, message[], str1[] = "", str2[] = "", str3[] = "", str4[] = "")
{
	new dest
	if (id) dest = MSG_ONE
	else dest = MSG_ALL
	
	message_begin(dest, gmsgTextMsg, {0, 0, 0}, id)
	write_byte(type)
	write_string(message)
	
	if (str1[0])
		write_string(str1)
	if (str2[0])
		write_string(str2)
	if (str3[0])
		write_string(str3)
	if (str4[0])
		write_string(str4)
		
	message_end()
}

stock SendArmorType(id, type)
{
	message_begin(MSG_ONE, gmsgArmorType, _, id);
	write_byte(type);
	message_end();
}

stock BlinkAccount(id, numBlinks)
{
	message_begin(MSG_ONE, gmsgBlinkAcct, _, id);
	write_byte(numBlinks);
	message_end();
}

stock AddAccount(id, amount, bTrackChange)
{
	new iAccount = get_pdata_int(id, m_iAccount);
	
	iAccount += amount;
	
	if (iAccount < 0)
		iAccount = 0;
	else if (iAccount > 16000)
		iAccount = 16000;
	
	set_pdata_int(id, m_iAccount, iAccount);
	
	message_begin(MSG_ONE, gmsgMoney, _, id);
	write_long(iAccount);
	write_byte(bTrackChange);
	message_end();
}

