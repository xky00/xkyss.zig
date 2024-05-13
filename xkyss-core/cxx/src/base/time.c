#include <windows.h>
#include "base/time.h"

typedef __int64 LONGLONG;
typedef long LONG;
typedef unsigned long       DWORD;

typedef union LARGE_INTEGER {
    struct {
        DWORD LowPart;
        LONG HighPart;
    } DUMMYSTRUCTNAME;
    struct {
        DWORD LowPart;
        LONG HighPart;
    } u;
    LONGLONG QuadPart;
};

unsigned long long gethrtime() {
    static double s_freq = 0;
    if (s_freq == 0) {
        LARGE_INTEGER freq;
        QueryPerformanceFrequency(&freq);
        s_freq = (double)freq.QuadPart / 10000000;
    }
    if (s_freq != 0) {
        LARGE_INTEGER count;
        QueryPerformanceCounter(&count);
        return count.QuadPart / s_freq;
    }
    return 0;
}
