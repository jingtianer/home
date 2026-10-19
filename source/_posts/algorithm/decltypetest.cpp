#include<iostream>
#include<iomanip>
using namespace std;


int i = 0;
void f(decltype(++i) a, decltype(i++) b, decltype(&i) c) {
    a++;
    b++;
    (*c)++;
}
int arr[5] = {0};
void f1(decltype(arr) a) {
    cout << ios::hex << a << " " << a+1 <<  endl;
}

int &j = i;
int &n = j;
int &&k = move(i);
int &&m  = move(k);
void f2(decltype(j) a, decltype(k) b, decltype(m) c, decltype(n) d) {
    a++;
    b++;
    c++;
    d++;
    cout << a << " " << b << " " << c << " " << d << endl;

}

int main() {
    int a = 0, b = 0,c = 0, d = 0;
    f(a, b, &c);
    cout << a << " " << b << " " << c <<  endl;
    int brr[6] = {0};
    f1(brr);
    f2(a,move(b),move(c),d);
    cout << a << " " << b << " " << c << " " << d << endl;
    return 0;
}