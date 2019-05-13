/* Generated by Frama-C */
#include "stdio.h"
#include "stdlib.h"
extern int __e_acsl_sound_verdict;

/*@ behavior yes:
      assumes ∀ int i; 0 < i < n ⇒ *(t + (i - 1)) ≤ *(t + i);
      ensures \result ≡ 1;
 */
int __gen_e_acsl_sorted(int *t, int n);

int sorted(int *t, int n)
{
  int __retres;
  int b = 1;
  if (n <= 1) {
    __retres = 1;
    goto return_label;
  }
  b = 1;
  while (b < n) {
    if (*(t + (b - 1)) > *(t + b)) {
      __retres = 0;
      goto return_label;
    }
    b ++;
  }
  __retres = 1;
  return_label: return __retres;
}

int main(void)
{
  int __retres;
  __e_acsl_memory_init((int *)0,(char ***)0,(size_t)8);
  int t[7] = {1, 4, 4, 5, 5, 5, 7};
  __e_acsl_store_block((void *)(t),(size_t)28);
  __e_acsl_full_init((void *)(& t));
  int n = __gen_e_acsl_sorted(t,7);
  /*@ assert n ≡ 1; */
  __e_acsl_assert(n == 1,(char *)"Assertion",(char *)"main",(char *)"n == 1",
                  23);
  __retres = 0;
  __e_acsl_delete_block((void *)(t));
  __e_acsl_memory_clean();
  return __retres;
}

/*@ behavior yes:
      assumes ∀ int i; 0 < i < n ⇒ *(t + (i - 1)) ≤ *(t + i);
      ensures \result ≡ 1;
 */
int __gen_e_acsl_sorted(int *t, int n)
{
  int __gen_e_acsl_at;
  int __retres;
  {
    int __gen_e_acsl_forall;
    int __gen_e_acsl_i;
    __gen_e_acsl_forall = 1;
    __gen_e_acsl_i = 0 + 1;
    while (1) {
      if (__gen_e_acsl_i < n) ; else break;
      {
        int __gen_e_acsl_valid_read;
        int __gen_e_acsl_valid_read_2;
        __gen_e_acsl_valid_read = __e_acsl_valid_read((void *)(t + __gen_e_acsl_i),
                                                      sizeof(int),(void *)t,
                                                      (void *)(& t));
        __e_acsl_assert(__gen_e_acsl_valid_read,(char *)"RTE",
                        (char *)"sorted",
                        (char *)"mem_access: \\valid_read(t + __gen_e_acsl_i)",
                        6);
        __gen_e_acsl_valid_read_2 = __e_acsl_valid_read((void *)(t + (
                                                                 __gen_e_acsl_i - 1L)),
                                                        sizeof(int),
                                                        (void *)t,
                                                        (void *)(& t));
        __e_acsl_assert(__gen_e_acsl_valid_read_2,(char *)"RTE",
                        (char *)"sorted",
                        (char *)"mem_access: \\valid_read(t + (long)(__gen_e_acsl_i - 1))",
                        6);
        if (*(t + (__gen_e_acsl_i - 1L)) <= *(t + __gen_e_acsl_i)) ;
        else {
          __gen_e_acsl_forall = 0;
          goto e_acsl_end_loop1;
        }
      }
      __gen_e_acsl_i ++;
    }
    e_acsl_end_loop1: ;
    __gen_e_acsl_at = __gen_e_acsl_forall;
  }
  __e_acsl_store_block((void *)(& t),(size_t)8);
  __retres = sorted(t,n);
  {
    int __gen_e_acsl_implies;
    if (! __gen_e_acsl_at) __gen_e_acsl_implies = 1;
    else __gen_e_acsl_implies = __retres == 1;
    __e_acsl_assert(__gen_e_acsl_implies,(char *)"Postcondition",
                    (char *)"sorted",
                    (char *)"\\old(\\forall int i; 0 < i < n ==> *(t + (i - 1)) <= *(t + i)) ==>\n\\result == 1",
                    7);
    __e_acsl_delete_block((void *)(& t));
    return __retres;
  }
}


