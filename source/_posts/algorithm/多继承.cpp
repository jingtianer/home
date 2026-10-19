class A {
    public:
    virtual int afun() = 0;
};

class B {
    public:
    virtual int bfun() = 0;
};

class C : public A, public B {
    public:
    virtual int afun() {
        return 0;
    }
    virtual int bfun() {
        return 1;
    }

};

#include<iostream>
using namespace std;

int main() {
    C c;
    int a = c.afun();
    int b = c.bfun();

    cout << a << b << endl;
    return 0;
}