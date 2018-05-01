#if defined _z4e_bits_included
  #endinput
#endif
#define _z4e_bits_included

#define BitsGet(%1,%2) (%1 & (1 << (%2 & 31)))
#define BitsGetBool(%1,%2) !!(%1 & (1 << (%2 & 31)))
#define BitsSet(%1,%2) %1 |= (1 << (%2 & 31))
#define BitsUnSet(%1,%2) %1 &= ~(1 << (%2 & 31))
#define BitsSwitch(%1,%2) %1 ^= (1 << (%2 & 31))
#define BitsIsPlayer(%1) (1<= %1 <= 32)
stock BitsCount(x)
{
    x = (x & 0x55555555) + ((x >> 1) & 0x55555555);
    x = (x & 0x33333333) + ((x >> 2) & 0x33333333);
    x = (x & 0x0F0F0F0F) + ((x >> 4) & 0x0F0F0F0F);
    x = (x & 0x00FF00FF) + ((x >> 8) & 0x00FF00FF);
    x = (x & 0x0000FFFF) + ((x >> 16) & 0x0000FFFF);
    return x;
}
stock BitsGetFirst(x)
{  
    new iPos=0;  
    for(new i=4;i>=0;i--)
    if ((x & ((1<<(1<<i)) - 1)) == 0)  
    {     
        x >>= (1<<i);   
        iPos += (1<<i);  
    }
    return iPos;
}
stock BitsGetRandom(x)
{ 
    new iCount = BitsCount(x)
    while(x)
    {
        iCount--
        if(!random_num(0, iCount) || !iCount)
            return BitsGetFirst(x)
        else
            x  &= x - 1
    }
    return -1
}
stock BitsFlip(x)
{
    x = ((x & 0x55555555) << 1) | ((x & 0xAAAAAAAA) >> 1);
    x = ((x & 0x33333333) << 2) | ((x & 0xCCCCCCCC) >> 2);
    x = ((x & 0x0F0F0F0F) << 4) | ((x & 0xF0F0F0F0) >> 4);
    x = ((x & 0x00FF00FF) << 8) | ((x & 0xFF00FF00) >> 8);
    x = ((x & 0x0000FFFF) << 16) | ((x & 0xFFFF0000) >> 16);
    return x
}