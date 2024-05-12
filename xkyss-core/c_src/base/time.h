#include <windows.h>
inline long long  gethrtime() {

        long long freq;
        QueryPerformanceFrequency(&freq);
        return freq;
}
