#include<iostream>
#include<vector>
#include<algorithm>
#include<cmath>
#include<unordered_map>

using namespace std;

void mul(vector<vector<int>>& a, const vector<vector<int>> b, int n) {
    for(int i = 0; i < n; i++) {
        vector<int> ta;
        for(int j  = 0; j < n; j++) {
            int m = 0;
            for(int k = 0; k < n; k++) {
                m += a[i][k] * b[k][j];
            }
            ta.push_back(m);
        }
        a[i] = ta;
    }
}

void matPow(int n, vector<vector<int>>& res, const vector<vector<int>>& arr, int pow) {
    switch(pow) {
        case 1:
            break;
        case 2:
            mul(res, arr, n);
            break;
        case 3:
            mul(res, arr, n);
            mul(res, arr, n);
            break;
        case 4:
            mul(res, arr, n);
            mul(res, res, n);
            break;
        case 5:
            mul(res, arr, n);
            mul(res, res, n);
            mul(res, arr, n);
            break;
    }
}
int main() {
    int n, k;
    while(scanf("%d%d", &n, &k) != EOF){
        vector<vector<int>> arr(n, vector<int>(n, 0));
        vector<vector<int>> res(n, vector<int>(n, 0));
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                int t;
                scanf("%d", &t);
                res[i][j] = t;
                arr[i][j] = t;
            }
        }
        matPow(n, res, arr, k);
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n-1; j++) {
                printf("%d ", res[i][j]);
            }
            printf("%d\n", res[i][n-1]);
        }
        
    }
    return 0;
}

