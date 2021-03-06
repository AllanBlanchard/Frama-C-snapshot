/* Generated by Frama-C */
#include "stdio.h"
#include "stdlib.h"
extern int __e_acsl_sound_verdict;

struct list {
   int element ;
   struct list *next ;
};
/*@ behavior B1:
      assumes l ≡ \null;
      ensures \result ≡ \old(l);
    
    behavior B2:
      assumes ¬\valid(l) ∨ ¬\valid(l->next);
      ensures \result ≡ \old(l);
 */
struct list *__gen_e_acsl_f(struct list *l);

struct list *f(struct list *l)
{
  struct list *__retres;
  __e_acsl_store_block((void *)(& __retres),(size_t)8);
  __e_acsl_store_block((void *)(& l),(size_t)8);
  if (l == (struct list *)0) {
    __e_acsl_full_init((void *)(& __retres));
    __retres = l;
    goto return_label;
  }
  if (l->next == (struct list *)0) {
    __e_acsl_full_init((void *)(& __retres));
    __retres = l;
    goto return_label;
  }
  __e_acsl_full_init((void *)(& __retres));
  __retres = (struct list *)0;
  return_label:
  {
    __e_acsl_delete_block((void *)(& l));
    __e_acsl_delete_block((void *)(& __retres));
    return __retres;
  }
}

int main(void)
{
  int __retres;
  __e_acsl_memory_init((int *)0,(char ***)0,(size_t)8);
  __gen_e_acsl_f((struct list *)0);
  __retres = 0;
  __e_acsl_memory_clean();
  return __retres;
}

/*@ behavior B1:
      assumes l ≡ \null;
      ensures \result ≡ \old(l);
    
    behavior B2:
      assumes ¬\valid(l) ∨ ¬\valid(l->next);
      ensures \result ≡ \old(l);
 */
struct list *__gen_e_acsl_f(struct list *l)
{
  struct list *__gen_e_acsl_at_4;
  int __gen_e_acsl_at_3;
  struct list *__gen_e_acsl_at_2;
  int __gen_e_acsl_at;
  struct list *__retres;
  __e_acsl_store_block((void *)(& __retres),(size_t)8);
  __gen_e_acsl_at_4 = l;
  {
    int __gen_e_acsl_valid;
    int __gen_e_acsl_or;
    __gen_e_acsl_valid = __e_acsl_valid((void *)l,sizeof(struct list),
                                        (void *)l,(void *)(& l));
    if (! __gen_e_acsl_valid) __gen_e_acsl_or = 1;
    else {
      int __gen_e_acsl_initialized;
      int __gen_e_acsl_and;
      __gen_e_acsl_initialized = __e_acsl_initialized((void *)(& l->next),
                                                      sizeof(struct list *));
      if (__gen_e_acsl_initialized) {
        int __gen_e_acsl_valid_read;
        int __gen_e_acsl_valid_2;
        __gen_e_acsl_valid_read = __e_acsl_valid_read((void *)(& l->next),
                                                      sizeof(struct list *),
                                                      (void *)(& l->next),
                                                      (void *)0);
        __e_acsl_assert(__gen_e_acsl_valid_read,(char *)"RTE",(char *)"f",
                        (char *)"mem_access: \\valid_read(&l->next)",18);
        __gen_e_acsl_valid_2 = __e_acsl_valid((void *)l->next,
                                              sizeof(struct list),
                                              (void *)l->next,
                                              (void *)(& l->next));
        __gen_e_acsl_and = __gen_e_acsl_valid_2;
      }
      else __gen_e_acsl_and = 0;
      __gen_e_acsl_or = ! __gen_e_acsl_and;
    }
    __gen_e_acsl_at_3 = __gen_e_acsl_or;
  }
  __gen_e_acsl_at_2 = l;
  __gen_e_acsl_at = l == (struct list *)0;
  __e_acsl_store_block((void *)(& l),(size_t)8);
  __retres = f(l);
  {
    int __gen_e_acsl_implies;
    int __gen_e_acsl_implies_2;
    if (! __gen_e_acsl_at) __gen_e_acsl_implies = 1;
    else __gen_e_acsl_implies = __retres == __gen_e_acsl_at_2;
    __e_acsl_assert(__gen_e_acsl_implies,(char *)"Postcondition",(char *)"f",
                    (char *)"\\old(l == \\null) ==> \\result == \\old(l)",16);
    if (! __gen_e_acsl_at_3) __gen_e_acsl_implies_2 = 1;
    else __gen_e_acsl_implies_2 = __retres == __gen_e_acsl_at_4;
    __e_acsl_assert(__gen_e_acsl_implies_2,(char *)"Postcondition",
                    (char *)"f",
                    (char *)"\\old(!\\valid{Here}(l) || !\\valid{Here}(l->next)) ==> \\result == \\old(l)",
                    19);
    __e_acsl_delete_block((void *)(& l));
    __e_acsl_delete_block((void *)(& __retres));
    return __retres;
  }
}


