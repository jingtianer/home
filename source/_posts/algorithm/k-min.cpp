#include<iostream>
#include<vector>
#include<algorithm>

using namespace std;

int partition(vector<int>& v, int l, int r) {
    int i = l;
    while(l<r) {
        while(r > l && v[r] >= v[i]) {
            r--;
        }
        swap(v[i], v[r]);
        i = r;
        while(r > l && v[l] <= v[i]) {
            l++;
        }
        swap(v[i], v[l]);
        i = l;
    }
    return i;
}

void searchK(vector<int>& v, int k, int l, int r) {
    //partition
    int n = partition(v,l,r);
    for(int i = 0; i < v.size(); i++) {
        cout << v[i] << " ";
    }
    cout << endl<< n;
    cout << endl;
    //search
    if(n > k) {
        searchK(v, k, l, n-1);
    } else if(n < k) {
        searchK(v, k, n+1, r);
    }
}
int main() {
    int n,k;
    cin >> n;
    vector<int> v;
    vector<bool> has(1001, false);
    for(int i = 0; i < n; i++) {
        int x;
        cin >> x;
        if(!has[x]) {
            has[x] = true;
            v.push_back(x);
        }
    }
    cin >> k;
    k--;
    searchK(v, k, 0, v.size()-1);
    cout << v[k];
    return 0;
}