#include<bits/stdc++.h>
#include<iostream>
using namespace std;

int reverse(int n, int d) {
    int res = 0;
    while(n != 0) {
        res *= d;
        res += n % d;
        n /= d;
    }
    return res;
}

const int MAX_PRIME = 10000;
int primes[MAX_PRIME] = {0};
int primeCount = 0;
void initPrimes() {
    primes[0] = 2;
    primes[1] = 3;
    primeCount = 2;
    for(int i = 5; primeCount < MAX_PRIME; i+=2) {
        primes[primeCount] = i;
        primeCount++;
        for(int j = 0; j < primeCount && primes[j]*primes[j] <= i; j++) {
            if(i%primes[j] == 0) {
                primeCount--;
                break;
            }
        }
    }
}

bool isPrime(int n) {
    int l = 0, r = primeCount;
    while(l <= r) {
        int mid = (r-l)/2 + l;
        if(primes[mid] == n) return true;
        else if(primes[mid] > n) r = mid-1;
        else l = mid+1;
    }
    return false;
}

int main() {
    int n, d;
    initPrimes();
    while(cin >> n >> d) {
        if(isPrime(n) && isPrime(reverse(n, d))) {
            cout << "Yes" << endl;
        } else {
            cout << "No" << endl;
        }
    }
    return 0;
}