/* Generated by Frama-C */
#include "stdio.h"
#include "stdlib.h"
int main(int argc, char const **argv)
{
  int __retres;
  __e_acsl_memory_init(& argc,(char ***)(& argv),(size_t)8);
  goto L;
  {
    int *p;
    __e_acsl_store_block((void *)(& p),(size_t)8);
    L: __e_acsl_store_block_duplicate((void *)(& p),(size_t)8);
    __e_acsl_full_init((void *)(& p));
    p = & argc;
    /*@ assert \valid(&p); */
    {
      int __gen_e_acsl_valid;
      __gen_e_acsl_valid = __e_acsl_valid((void *)(& p),sizeof(int *),
                                          (void *)(& p),(void *)0);
      __e_acsl_assert(__gen_e_acsl_valid,(char *)"Assertion",(char *)"main",
                      (char *)"\\valid(&p)",13);
      __e_acsl_delete_block((void *)(& p));
    }
  }
  __retres = 0;
  __e_acsl_delete_block((void *)(& argc));
  __e_acsl_memory_clean();
  return __retres;
}


