#define BTE_STRING 1
#define BTE_FLOAT 2
#define BTE_INT 3

native GetPrivateProfile(lpAppName[], lpKeyName[], lpDefault[], lpFileName[], iType, any:...);
native UTIL_TutorText(id, str[], color, Float:time);