#include<vector>
#include<iostream>
#include<stack>
#include<queue>
#include<algorithm>
#include<unordered_map>

using namespace std;

class Solution {
public:
    string largestNumber(vector<int>& nums) {
        vector<string> snums;
        for(int n : nums) {
            snums.push_back(toString(n));
        }
        sort(snums.begin(), snums.end(), greater);
        string res = "";
        int len = snums.size();
        int i = 0;
        while(i < len && snums[i] == "0") {
            i++;
        }
        if(i > 0) i--;
        for(; i < len; i++) {
            res += snums[i];
        }
        return res;
    }

    string toString(int a) {
        if(a == 0) return "0";
        stack<int> sa;
        while(a != 0) {
            sa.push(a%10);
            a/=10;
        }
        string res = "";
        while(!sa.empty()) {
            res.push_back(sa.top() + '0');
            sa.pop();
        }
        return res;
    }
    
    static bool greater(string a, string b) {
        int na = a.length(), nb = b.length();
        int nc = na > nb ? nb : na;
        int i = 0,j = 0;
        int last_i = 0, last_j = 0;
        while(i < na && j < nb) {
            while(i < na && j < nb && a[i] == b[j]) {
                i++;
                j++;
            }
            if(i == na && j == nb) {
                return a > b;
            }
            if(i != na && j != nb) {
                i = last_i; j = last_j;
                break;
            } else {
                if(i == na) {
                    i = last_i;
                } else {
                    j = last_j;
                }
                last_i = i;
                last_j = j;
            }
        }
        // cout << "d " << i << " " << j << endl;
        // cout << "a " << a << " " << b << endl;
        while(i < na && j < nb) {
            // cout << "b " << a[i] << " " << b[j] << endl;
            // cout << "c " << i << " " << j << endl;
            if(a[i] > b[j]) {
                return true;
            } else if(a[i] < b[j]) {
                return false;
            }
            i++;
            j++;
        }
        return (na-i) > (nb-j);
        // return false;
    }

    void swap(int &a, int &b) {
        a = a+b;
        b = a-b;
        a = a-b;
    }
};