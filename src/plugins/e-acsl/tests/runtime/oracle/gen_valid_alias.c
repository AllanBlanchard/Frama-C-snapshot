/* Generated by Frama-C */
#include "stdio.h"
#include "stdlib.h"
int main(void)
{
  int __retres;
  int *a;
  int *b;
  __e_acsl_memory_init((int *)0,(char ***)0,(size_t)8);
  __e_acsl_store_block((void *)(& b),(size_t)8);
  __e_acsl_store_block((void *)(& a),(size_t)8);
  int n = 0;
  /*@ assert ¬\valid(a) ∧ ¬\valid(b); */
  {
    int __gen_e_acsl_initialized;
    int __gen_e_acsl_and;
    int __gen_e_acsl_and_3;
    __gen_e_acsl_initialized = __e_acsl_initialized((void *)(& a),
                                                    sizeof(int *));
    if (__gen_e_acsl_initialized) {
      int __gen_e_acsl_valid;
      __gen_e_acsl_valid = __e_acsl_valid((void *)a,sizeof(int),(void *)a,
                                          (void *)(& a));
      __gen_e_acsl_and = __gen_e_acsl_valid;
    }
    else __gen_e_acsl_and = 0;
    if (! __gen_e_acsl_and) {
      int __gen_e_acsl_initialized_2;
      int __gen_e_acsl_and_2;
      __gen_e_acsl_initialized_2 = __e_acsl_initialized((void *)(& b),
                                                        sizeof(int *));
      if (__gen_e_acsl_initialized_2) {
        int __gen_e_acsl_valid_2;
        __gen_e_acsl_valid_2 = __e_acsl_valid((void *)b,sizeof(int),
                                              (void *)b,(void *)(& b));
        __gen_e_acsl_and_2 = __gen_e_acsl_valid_2;
      }
      else __gen_e_acsl_and_2 = 0;
      __gen_e_acsl_and_3 = ! __gen_e_acsl_and_2;
    }
    else __gen_e_acsl_and_3 = 0;
    __e_acsl_assert(__gen_e_acsl_and_3,(char *)"Assertion",(char *)"main",
                    (char *)"!\\valid(a) && !\\valid(b)",10);
  }
  __e_acsl_full_init((void *)(& a));
  a = (int *)malloc(sizeof(int));
  __e_acsl_initialize((void *)a,sizeof(int));
  *a = n;
  __e_acsl_full_init((void *)(& b));
  b = a;
  /*@ assert \valid(a) ∧ \valid(b); */
  {
    int __gen_e_acsl_initialized_3;
    int __gen_e_acsl_and_4;
    int __gen_e_acsl_and_6;
    __gen_e_acsl_initialized_3 = __e_acsl_initialized((void *)(& a),
                                                      sizeof(int *));
    if (__gen_e_acsl_initialized_3) {
      int __gen_e_acsl_valid_3;
      __gen_e_acsl_valid_3 = __e_acsl_valid((void *)a,sizeof(int),(void *)a,
                                            (void *)(& a));
      __gen_e_acsl_and_4 = __gen_e_acsl_valid_3;
    }
    else __gen_e_acsl_and_4 = 0;
    if (__gen_e_acsl_and_4) {
      int __gen_e_acsl_initialized_4;
      int __gen_e_acsl_and_5;
      __gen_e_acsl_initialized_4 = __e_acsl_initialized((void *)(& b),
                                                        sizeof(int *));
      if (__gen_e_acsl_initialized_4) {
        int __gen_e_acsl_valid_4;
        __gen_e_acsl_valid_4 = __e_acsl_valid((void *)b,sizeof(int),
                                              (void *)b,(void *)(& b));
        __gen_e_acsl_and_5 = __gen_e_acsl_valid_4;
      }
      else __gen_e_acsl_and_5 = 0;
      __gen_e_acsl_and_6 = __gen_e_acsl_and_5;
    }
    else __gen_e_acsl_and_6 = 0;
    __e_acsl_assert(__gen_e_acsl_and_6,(char *)"Assertion",(char *)"main",
                    (char *)"\\valid(a) && \\valid(b)",14);
  }
  /*@ assert *b ≡ n; */
  {
    int __gen_e_acsl_initialized_5;
    int __gen_e_acsl_and_7;
    __gen_e_acsl_initialized_5 = __e_acsl_initialized((void *)(& b),
                                                      sizeof(int *));
    if (__gen_e_acsl_initialized_5) {
      int __gen_e_acsl_valid_read;
      __gen_e_acsl_valid_read = __e_acsl_valid_read((void *)b,sizeof(int),
                                                    (void *)b,(void *)(& b));
      __gen_e_acsl_and_7 = __gen_e_acsl_valid_read;
    }
    else __gen_e_acsl_and_7 = 0;
    __e_acsl_assert(__gen_e_acsl_and_7,(char *)"RTE",(char *)"main",
                    (char *)"mem_access: \\valid_read(b)",15);
    __e_acsl_assert(*b == n,(char *)"Assertion",(char *)"main",
                    (char *)"*b == n",15);
  }
  free((void *)b);
  /*@ assert ¬\valid(a) ∧ ¬\valid(b); */
  {
    int __gen_e_acsl_initialized_6;
    int __gen_e_acsl_and_8;
    int __gen_e_acsl_and_10;
    __gen_e_acsl_initialized_6 = __e_acsl_initialized((void *)(& a),
                                                      sizeof(int *));
    if (__gen_e_acsl_initialized_6) {
      int __gen_e_acsl_valid_5;
      /*@ assert Eva: dangling_pointer: ¬\dangling(&a); */
      __gen_e_acsl_valid_5 = __e_acsl_valid((void *)a,sizeof(int),(void *)a,
                                            (void *)(& a));
      __gen_e_acsl_and_8 = __gen_e_acsl_valid_5;
    }
    else __gen_e_acsl_and_8 = 0;
    if (! __gen_e_acsl_and_8) {
      int __gen_e_acsl_initialized_7;
      int __gen_e_acsl_and_9;
      __gen_e_acsl_initialized_7 = __e_acsl_initialized((void *)(& b),
                                                        sizeof(int *));
      if (__gen_e_acsl_initialized_7) {
        int __gen_e_acsl_valid_6;
        __gen_e_acsl_valid_6 = __e_acsl_valid((void *)b,sizeof(int),
                                              (void *)b,(void *)(& b));
        __gen_e_acsl_and_9 = __gen_e_acsl_valid_6;
      }
      else __gen_e_acsl_and_9 = 0;
      __gen_e_acsl_and_10 = ! __gen_e_acsl_and_9;
    }
    else __gen_e_acsl_and_10 = 0;
    __e_acsl_assert(__gen_e_acsl_and_10,(char *)"Assertion",(char *)"main",
                    (char *)"!\\valid(a) && !\\valid(b)",17);
  }
  __retres = 0;
  __e_acsl_delete_block((void *)(& b));
  __e_acsl_delete_block((void *)(& a));
  __e_acsl_memory_clean();
  return __retres;
}


