#include<iostream>
using namespace std;
class A {
    public:
    int a;
    int b;
    A(int a0, int b0) : a(a0), b(b0) {}
    ~A() {
        cout << "delete this" << endl;
        delete this;
    }
};

struct B
{
    int a;
    int b;
    B(int a0, int b0) : a(a0), b(b0) {}
};

void f1(A a, B b) {
    a.a = 5, a.b = 6;
    b.a = 5, b.b = 6;
}

int main() {
    A *a = new A(1,2);
    B b(1,2);
    // f1(a, b);
    cout << a->a << " " << a->b << endl;
    // cout << b.a << " " << b.b << endl;
    delete a;
    return 0;
}
