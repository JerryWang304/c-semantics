// Copyright (c) 2015 Runtime Verification, Inc. (RV-Match team). All Rights Reserved.

int main() {
  volatile int x;
  volatile char *y = (char*)&x;
  *y = 5;
  return 0;
}
