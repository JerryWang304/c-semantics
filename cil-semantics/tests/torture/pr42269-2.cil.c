/* Generated by CIL v. 1.3.7 */
/* print_CIL_Input is true */

static long long ( __attribute__((__noinline__)) foo)(unsigned short s ) 
{ 

  {
  return ((long long )((short )s));
}
}
unsigned short s  =    (unsigned short)65535;
int main(void) 
{ long long tmp ;

  {
  tmp = foo(s);
  return (tmp + 1LL != 0LL);
}
}