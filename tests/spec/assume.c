
void f(int x) {
  int * p,*q;

//@ behavior default: assumes \valid(p); // je ne veux pas v�rifier cette assert

 q = p ;

//@ assert \valid(q); // je veux v�rifier cette assert

}
