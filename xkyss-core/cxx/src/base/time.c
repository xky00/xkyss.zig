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
    static LONGLONG s_freq = 0;
    if (s_freq == 0) {
        LARGE_INTEGER freq;
        QueryPerformanceFrequency(&freq);
        s_freq = freq.QuadPart;
    }
    if (s_freq != 0) {
        LARGE_INTEGER count;
        QueryPerformanceCounter(&count);
        return count.QuadPart / (double)s_freq * 10000000;
    }
    return 0;
}
