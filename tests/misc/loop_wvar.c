/* run.config
   GCC:
   OPT: -memory-footprint 1 -no-annot -val
   OPT: -memory-footprint 1 -val
   OPT: -memory-footprint 1 -val -main main_err1
   OPT: -memory-footprint 1 -val -main main_err2
*/

int i,j;

void main(void)
{ int n = 13;
// ceci �tait une annotation, mais on ne fait pas moins bien sans
// maintenant:
// loop pragma WIDEN_VARIABLES i;
  /*@ loop pragma WIDEN_HINTS i, 12, 13; */
  for (i=0; i<n; i++)
    {
      j = 4 * i + 7;
    }
}


void main_err1(void)
{ int n = 13;
  /*@ loop pragma WIDEN_HINTS 12 ; */
  for (i=0; i<n; i++)
    {
      j = 4 * i + 7;
    }
}




void main_err2(void)
{ int n = 13;
  /*@ loop pragma WIDEN_VARIABLES 12; */
  for (i=0; i<n; i++)
    {
      j = 4 * i + 7;
    }
}
