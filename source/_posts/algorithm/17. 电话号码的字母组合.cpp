
#include<vector>
#include<iostream>
#include<stack>
#include<queue>
#include<algorithm>
using namespace std;

class Solution {
public:
    string digits;
    int len;
    vector<string> res;
    vector<string> table;
    vector<string> letterCombinations(string digits) {
        this->digits = digits;
        this->len = digits.length();
        table = {"abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz"};
        if(digits == "") return res;
        search(0, "");
        return res;
    }

    void search(int depth, string s) {
        if(depth == len) {
            res.push_back(s);
            return;
        }
        char c = digits[depth] - '2';
        int len = (c == '7'-'2' || c == '9'-'2') ? 4 :  3;
        for(int i = 0; i < len; i++) {
            search(depth+1, s+table[c][i]);
        }
    }

};