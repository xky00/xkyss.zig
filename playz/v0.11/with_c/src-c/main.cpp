#include <cstdio>
#include "calc.h"

int main(int, char**){
  int x = 5;
  int y = 16;
  int z = add(x, y);
  printf("%d + %d = %d\n", x, y, z);
  return 0;
}
