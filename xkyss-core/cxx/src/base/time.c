#include <windows.h>
long long  gethrtime() {
    long long freq;
    QueryPerformanceFrequency(&freq);
    return freq;
}
