#include<vector>
#include<iostream>
#include<stack>

using namespace std;


class Solution {
public:
    vector<int> platesBetweenCandles(string s, const vector<vector<int>>& queries) {
        int len = s.length();
        vector<int> v(len, 0);
        vector<int> left(len, -1);
        vector<int> right(len, len);
        v[0] = s[0] == '*' ? 1 : 0; 
        int lastLeft = s[0] == '|' ? 0 : -1;
        left[0] = lastLeft;
        for(int i = 1; i < len; i++) {
            int x = s[i] == '*' ? 1 : 0;
            v[i] = v[i-1] + x;
            if(s[i] == '|') {
                lastLeft = i;
            }
            left[i] = lastLeft;
        }
        int lastRight = s[len-1] == '|' ? len-1 : len;
        for(int i = len-2; i >= 0; i--) {
            if(s[i] == '|') {
                lastRight = i;
            }
            right[i] = lastRight;
        }
        vector<int> ans;
        len = queries.size();
        for(int i = 0; i < len; i++) {
            int diff = 0;
            printf("%d, %d\n", right[queries[i][0]], left[queries[i][1]]);
            printf("%d, %d\n", v[right[queries[i][0]]], v[left[queries[i][1]]]);
            if(right[queries[i][0]] < left[queries[i][1]]) {
                diff = v[left[queries[i][1]]] - v[right[queries[i][0]]];
            }
            ans.push_back(diff);
        }
        return ans;
    }
};

int main() {
    Solution s;
    string str = "***|**|*****|**||**|*";
    vector<int> res = s.platesBetweenCandles(str, {{1,17},{4,5},{14,17},{5,11},{15,16}});
    int len = res.size();
    for(int i = 0; i < len; i++) {
        cout << res[i] << " ";
    }
    cout << endl;
    return 0;
}