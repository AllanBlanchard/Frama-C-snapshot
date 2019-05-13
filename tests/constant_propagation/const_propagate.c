/* run.config
   OPT: -eva @EVA_OPTIONS@ -deps -out -input -scf -journal-disable
   OPT: -scf @EVA_OPTIONS@ -cast-from-constant -semantic-const-fold add3 -main init -journal-disable
*/
int x,y,z;
int TAB[10];
struct st { int a, b ; } s1, s2;
typedef struct st ST ;
void test_struct (void) {
  ST s = {0,1};
  s1 = s ;
  s1.a++;
  s2.a = s1.a;
  s.a++;
  s2 = s;
  s.b--;
}

void test_tab (int v) {
  TAB[s1.b] = TAB[++s2.b];
  int * r = &TAB[4];
  *r = v;
  r[1] = v;
  char * q = (char *)r;
  *q = v;
  q[1] = v;
  int decal = sizeof(int);
  q[decal] = v;
}

int * test_ptr(int v) {
  int * p = &x ;
  char *s= (char *)p;
  *s = v;
  int decal = 1;
  s[decal] = v;
  s = ((char *)p) + decal;
  *s = v;
  *p = v;
  return &x;
}

int * test_struct_ptr(void) {
  int * q = &s1.b;
  return &s1.a ;
}
int add3 (int v1, int v2, int v3) {
  return v1 + v2 + v3;
}

int init (int v) {
  int zero = 0;
  int sept = 7;
  x = v;
  y = sept;
  z = add3 (x, y, zero); // TODO: add3(x, 7, 0); z = 12;
  int z1 = z ;
  return zero ;
}

unsigned long long ull;
void test_ull () {
  ull = ull - 1L;
}

float  f0, f1, f2, f3;
double d0, d1, d2, d3;
void test_float_double (void) {
  d1 = d0;
  d2 = d1 + d0;
  d3 = d2 + 1.0;
  f1 = f0;
  f2 = f1 + f0;
  f3 = f2 + 1.0;
}

void main(int a) {
  test_ull ();
  test_struct () ;
  test_struct_ptr () ;
  test_tab (13) ;
  test_float_double ();

  int b = init(5);  // TODO: init(5); b = 0;
  z = add3 (a, 0, 0);

  int *p = test_ptr (y);
  //@ assert *p == 7 ;
  int *q = a?p:&y;
  int yy = *q;
  //@ assert a==0 ==> q==&y ;
  //@ assert *q == 7 ;

}
