/* Generated by CIL v. 1.3.7 */
/* print_CIL_Input is true */

extern  __attribute__((__nothrow__, __noreturn__)) void abort(void)  __attribute__((__leaf__)) ;
extern  __attribute__((__nothrow__, __noreturn__)) void exit(int __status )  __attribute__((__leaf__)) ;
void f(int i ) 
{ 

  {
  if (((1 << i) & 1) == 0) {
    abort();
  }
  return;
}
}
int main(void) 
{ 

  {
  f(0);
  exit(0);
}
}