/* Generated by Frama-C */
#include "stdio.h"
#include "stdlib.h"
extern int __e_acsl_sound_verdict;

/*@ ensures \valid(\result); */
int *__gen_e_acsl_f(int *x, int *y);

int *f(int *x, int *y)
{
  __e_acsl_store_block((void *)(& y),(size_t)8);
  __e_acsl_store_block((void *)(& x),(size_t)8);
  __e_acsl_initialize((void *)y,sizeof(int));
  *y = 1;
  __e_acsl_delete_block((void *)(& y));
  __e_acsl_delete_block((void *)(& x));
  return x;
}

int main(void)
{
  int __retres;
  int *p;
  __e_acsl_memory_init((int *)0,(char ***)0,(size_t)8);
  __e_acsl_store_block((void *)(& p),(size_t)8);
  int x = 0;
  __e_acsl_store_block((void *)(& x),(size_t)4);
  __e_acsl_full_init((void *)(& x));
  int *q = malloc(sizeof(int));
  __e_acsl_store_block((void *)(& q),(size_t)8);
  __e_acsl_full_init((void *)(& q));
  int *r = malloc(sizeof(int));
  __e_acsl_full_init((void *)(& p));
  p = __gen_e_acsl_f(& x,q);
  __e_acsl_full_init((void *)(& q));
  q = __gen_e_acsl_f(& x,r);
  __retres = 0;
  __e_acsl_delete_block((void *)(& q));
  __e_acsl_delete_block((void *)(& p));
  __e_acsl_delete_block((void *)(& x));
  __e_acsl_memory_clean();
  return __retres;
}

/*@ ensures \valid(\result); */
int *__gen_e_acsl_f(int *x, int *y)
{
  int *__retres;
  __e_acsl_store_block((void *)(& __retres),(size_t)8);
  __e_acsl_store_block((void *)(& y),(size_t)8);
  __e_acsl_store_block((void *)(& x),(size_t)8);
  __retres = f(x,y);
  {
    int __gen_e_acsl_valid;
    __gen_e_acsl_valid = __e_acsl_valid((void *)__retres,sizeof(int),
                                        (void *)__retres,
                                        (void *)(& __retres));
    __e_acsl_assert(__gen_e_acsl_valid,(char *)"Postcondition",(char *)"f",
                    (char *)"\\valid(\\result)",10);
    __e_acsl_delete_block((void *)(& y));
    __e_acsl_delete_block((void *)(& x));
    __e_acsl_delete_block((void *)(& __retres));
    return __retres;
  }
}


