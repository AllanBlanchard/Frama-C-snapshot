
int s ;
//@ assigns s;
void g(int x);
//@ assigns s ; //<- doit �tre prouvable
void f(void) {
  g(1);
}
int main (void) {return 0;}
