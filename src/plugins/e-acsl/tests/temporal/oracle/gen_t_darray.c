/* Generated by Frama-C */
#include "stdio.h"
#include "stdlib.h"
void area_triangle(double (*vertices)[4])
{
  /*@ assert rte: mem_access: \valid_read((double *)*(vertices + 0)); */
  {
    int __gen_e_acsl_valid_read;
    __e_acsl_store_block((void *)(& vertices),(size_t)8);
    __e_acsl_temporal_pull_parameter((void *)(& vertices),0U,8UL);
    __gen_e_acsl_valid_read = __e_acsl_valid_read((void *)(*(vertices + 0)),
                                                  sizeof(double),
                                                  (void *)(*(vertices + 0)),
                                                  (void *)(*(vertices + 0)));
    __e_acsl_assert(__gen_e_acsl_valid_read,(char *)"Assertion",
                    (char *)"area_triangle",
                    (char *)"rte: mem_access: \\valid_read((double *)*(vertices + 0))",
                    6);
  }
  /*@ assert rte: mem_access: \valid_read((double *)*(vertices + 1)); */
  {
    int __gen_e_acsl_valid_read_2;
    __gen_e_acsl_valid_read_2 = __e_acsl_valid_read((void *)(*(vertices + 1)),
                                                    sizeof(double),
                                                    (void *)(*(vertices + 1)),
                                                    (void *)(*(vertices + 1)));
    __e_acsl_assert(__gen_e_acsl_valid_read_2,(char *)"Assertion",
                    (char *)"area_triangle",
                    (char *)"rte: mem_access: \\valid_read((double *)*(vertices + 1))",
                    7);
  }
  __e_acsl_delete_block((void *)(& vertices));
  return;
}

void abe_matrix(double (*vertices)[4])
{
  __e_acsl_store_block((void *)(& vertices),(size_t)8);
  __e_acsl_temporal_pull_parameter((void *)(& vertices),0U,8UL);
  __e_acsl_temporal_reset_parameters();
  __e_acsl_temporal_reset_return();
  __e_acsl_temporal_save_nreferent_parameter((void *)(& vertices),0U);
  area_triangle(vertices);
  __e_acsl_delete_block((void *)(& vertices));
  return;
}

double Vertices[3][4];
double Vertices2[3][4] = {};
void __e_acsl_globals_init(void)
{
  static char __e_acsl_already_run = 0;
  if (! __e_acsl_already_run) {
    __e_acsl_already_run = 1;
    __e_acsl_store_block((void *)(Vertices2),(size_t)96);
    __e_acsl_full_init((void *)(& Vertices2));
    __e_acsl_store_block((void *)(Vertices),(size_t)96);
    __e_acsl_full_init((void *)(& Vertices));
  }
  return;
}

int main(int argc, char const **argv)
{
  int __retres;
  double vertices2[3][4];
  double vertices3[3][4];
  double triple_vertices[2][3][4];
  __e_acsl_memory_init(& argc,(char ***)(& argv),(size_t)8);
  __e_acsl_globals_init();
  __e_acsl_store_block((void *)(triple_vertices),(size_t)192);
  __e_acsl_store_block((void *)(vertices3),(size_t)96);
  __e_acsl_store_block((void *)(vertices2),(size_t)96);
  double vertices[3][4] =
    {{1.0, 2.0, 3.0, 4.0}, {5.0, 6.0, 7.0, 8.0}, {9.0, 10.0, 11.0, 12.0}};
  __e_acsl_store_block((void *)(vertices),(size_t)96);
  __e_acsl_full_init((void *)(& vertices));
  double triple_vertices2[2][3][4] = {};
  __e_acsl_store_block((void *)(triple_vertices2),(size_t)192);
  __e_acsl_full_init((void *)(& triple_vertices2));
  __e_acsl_temporal_reset_parameters();
  __e_acsl_temporal_reset_return();
  __e_acsl_temporal_save_nblock_parameter((void *)(vertices),0U);
  abe_matrix(vertices);
  __e_acsl_temporal_reset_parameters();
  __e_acsl_temporal_reset_return();
  __e_acsl_temporal_save_nblock_parameter((void *)(vertices2),0U);
  abe_matrix(vertices2);
  __e_acsl_temporal_reset_parameters();
  __e_acsl_temporal_reset_return();
  __e_acsl_temporal_save_nblock_parameter((void *)(vertices3),0U);
  abe_matrix(vertices3);
  __e_acsl_temporal_reset_parameters();
  __e_acsl_temporal_reset_return();
  __e_acsl_temporal_save_nblock_parameter((void *)(Vertices),0U);
  abe_matrix(Vertices);
  __e_acsl_temporal_reset_parameters();
  __e_acsl_temporal_reset_return();
  __e_acsl_temporal_save_nblock_parameter((void *)(Vertices2),0U);
  abe_matrix(Vertices2);
  __e_acsl_temporal_reset_parameters();
  __e_acsl_temporal_reset_return();
  __e_acsl_temporal_save_nblock_parameter((void *)(triple_vertices[0]),0U);
  abe_matrix(triple_vertices[0]);
  __e_acsl_temporal_reset_parameters();
  __e_acsl_temporal_reset_return();
  __e_acsl_temporal_save_nblock_parameter((void *)(triple_vertices2[0]),0U);
  abe_matrix(triple_vertices2[0]);
  __retres = 0;
  __e_acsl_delete_block((void *)(Vertices2));
  __e_acsl_delete_block((void *)(Vertices));
  __e_acsl_delete_block((void *)(triple_vertices2));
  __e_acsl_delete_block((void *)(triple_vertices));
  __e_acsl_delete_block((void *)(vertices3));
  __e_acsl_delete_block((void *)(vertices2));
  __e_acsl_delete_block((void *)(vertices));
  __e_acsl_memory_clean();
  return __retres;
}


