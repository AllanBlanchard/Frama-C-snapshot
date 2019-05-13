/* Generated by Frama-C */
#include "stdio.h"
#include "stdlib.h"
struct spongeStateStruct {
   unsigned char __attribute__((__aligned__(32))) state[1600 / 8] ;
   unsigned char __attribute__((__aligned__(32))) dataQueue[1536 / 8] ;
   unsigned int bitsInQueue ;
} __attribute__((__aligned__(32)));
typedef struct spongeStateStruct spongeState;
int main(void)
{
  int __retres;
  __e_acsl_memory_init((int *)0,(char ***)0,(size_t)8);
  spongeState *state = malloc(sizeof(spongeState));
  __e_acsl_store_block((void *)(& state),(size_t)8);
  __e_acsl_full_init((void *)(& state));
  __e_acsl_initialize((void *)(& state->bitsInQueue),sizeof(unsigned int));
  state->bitsInQueue = (unsigned int)16;
  /*@ assert ¬\initialized(&state->dataQueue[state->bitsInQueue / 8]); */
  {
    int __gen_e_acsl_valid_read;
    int __gen_e_acsl_initialized;
    __gen_e_acsl_valid_read = __e_acsl_valid_read((void *)(& state->bitsInQueue),
                                                  sizeof(unsigned int),
                                                  (void *)(& state->bitsInQueue),
                                                  (void *)0);
    __e_acsl_assert(__gen_e_acsl_valid_read,(char *)"RTE",(char *)"main",
                    (char *)"mem_access: \\valid_read(&state->bitsInQueue)",
                    22);
    __gen_e_acsl_initialized = __e_acsl_initialized((void *)(& state->dataQueue[
                                                    state->bitsInQueue / 8U]),
                                                    sizeof(unsigned char __attribute__((
                                                    __aligned__(32)))));
    __e_acsl_assert(! __gen_e_acsl_initialized,(char *)"Assertion",
                    (char *)"main",
                    (char *)"!\\initialized(&state->dataQueue[state->bitsInQueue / 8])",
                    22);
  }
  free((void *)state);
  __retres = 0;
  __e_acsl_delete_block((void *)(& state));
  __e_acsl_memory_clean();
  return __retres;
}


