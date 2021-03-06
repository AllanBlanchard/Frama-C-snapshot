[kernel] Parsing tests/saveload/multi_project.i (no preprocessing)
[scf] beginning constant propagation
[eva] Analyzing a complete application starting at main
[eva] Computing initial state
[eva] Initial state computed
[eva:initial-state] Values of globals at initialization
  
[eva] computing for function f <- main.
  Called from tests/saveload/multi_project.i:14.
[eva] Recording results for f
[eva] Done for function f
[eva] tests/saveload/multi_project.i:15: assertion got status valid.
[eva] Recording results for main
[eva] done for function main
[eva:summary] ====== ANALYSIS SUMMARY ======
  ----------------------------------------------------------------------------
  2 functions analyzed (out of 2): 100% coverage.
  In these functions, 7 statements reached (out of 7): 100% coverage.
  ----------------------------------------------------------------------------
  No errors or warnings raised during the analysis.
  ----------------------------------------------------------------------------
  0 alarms generated by the analysis.
  ----------------------------------------------------------------------------
  Evaluation of the logical properties reached by the analysis:
    Assertions        1 valid     0 unknown     0 invalid      1 total
    Preconditions     0 valid     0 unknown     0 invalid      0 total
  100% of the logical properties reached have been proven.
  ----------------------------------------------------------------------------
/* Generated by Frama-C */
int f(int x)
{
  int __retres;
  __retres = 4;
  return __retres;
}

int main(void)
{
  int __retres;
  int x = 2;
  int y = f(2);
  /*@ assert y ≡ 4; */ ;
  __retres = 8;
  return __retres;
}


[scf] constant propagation done
