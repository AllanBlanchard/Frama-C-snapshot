/* Generated by Frama-C */
#include "stdio.h"
#include "stdlib.h"
int G = 0;
int *P;
void __e_acsl_globals_init(void)
{
  static char __e_acsl_already_run = 0;
  if (! __e_acsl_already_run) {
    __e_acsl_already_run = 1;
    __e_acsl_store_block((void *)(& P),(size_t)8);
    __e_acsl_full_init((void *)(& P));
    __e_acsl_store_block((void *)(& G),(size_t)4);
    __e_acsl_full_init((void *)(& G));
  }
  return;
}

int main(void)
{
  int __retres;
  __e_acsl_memory_init((int *)0,(char ***)0,(size_t)8);
  __e_acsl_globals_init();
  P = & G;
  int *q = P;
  __e_acsl_store_block((void *)(& q),(size_t)8);
  __e_acsl_full_init((void *)(& q));
  {
    int __gen_e_acsl_valid_read;
    int __gen_e_acsl_valid;
    __e_acsl_initialize((void *)P,sizeof(int));
    __gen_e_acsl_valid_read = __e_acsl_valid_read((void *)P,sizeof(int),
                                                  (void *)P,(void *)(& P));
    __e_acsl_assert(__gen_e_acsl_valid_read,(char *)"RTE",(char *)"main",
                    (char *)"mem_access: \\valid_read(P)",14);
    __gen_e_acsl_valid = __e_acsl_valid((void *)P,sizeof(int),(void *)P,
                                        (void *)(& P));
    __e_acsl_assert(__gen_e_acsl_valid,(char *)"RTE",(char *)"main",
                    (char *)"mem_access: \\valid(P)",14);
  }
  (*P) ++;
  /*@ assert *q ≡ G; */
  {
    int __gen_e_acsl_initialized;
    int __gen_e_acsl_and;
    __gen_e_acsl_initialized = __e_acsl_initialized((void *)(& q),
                                                    sizeof(int *));
    if (__gen_e_acsl_initialized) {
      int __gen_e_acsl_valid_read_2;
      __gen_e_acsl_valid_read_2 = __e_acsl_valid_read((void *)q,sizeof(int),
                                                      (void *)q,
                                                      (void *)(& q));
      __gen_e_acsl_and = __gen_e_acsl_valid_read_2;
    }
    else __gen_e_acsl_and = 0;
    __e_acsl_assert(__gen_e_acsl_and,(char *)"RTE",(char *)"main",
                    (char *)"mem_access: \\valid_read(q)",15);
    __e_acsl_assert(*q == G,(char *)"Assertion",(char *)"main",
                    (char *)"*q == G",15);
  }
  __retres = 0;
  __e_acsl_delete_block((void *)(& P));
  __e_acsl_delete_block((void *)(& G));
  __e_acsl_delete_block((void *)(& q));
  __e_acsl_memory_clean();
  return __retres;
}


