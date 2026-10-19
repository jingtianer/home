#include<vector>
#include<iostream>
#include<stack>
#include<queue>
#include<algorithm>
#include<unordered_map>
#include<climits>
#include<set>
using namespace std;

class Solution {
public:
    int n;
    vector<int> mem;
    int rob(vector<int>& nums) {
        this->n = nums.size();
        mem = vector<int>(n+2, -1);
        return maxRob(nums, -2);
    }
    int maxRob(const vector<int>& nums, int i) {
        if(i < n && mem[i+2] != -1) return mem[i+2];
        int a = (i+2 < n ? maxRob(nums, i+2) + nums[i+2] : 0);
        int b = (i+3 < n ? maxRob(nums, i+3) + nums[i+3] : 0);
        mem[i+2] = (a > b? a : b);
        return mem[i+2];
    }
};

int main() {
    Solution s;
    vector<int> v = {226,174,214,16,218,48,153,131,128,17,157,142,88,43,37,157,43,221,191,68,206,23,225,82,54,118,111,46,80,49,245,63,25,194,72,80,143,55,209,18,55,122,65,66,177,101,63,201,172,130,103,225,142,46,86,185,62,138,212,192,125,77,223,188,99,228,90,25,193,211,84,239,119,234,85,83,123,120,131,203,219,10,82,35,120,180,249,106,37,169,225,54,103,55,166,124};
    cout << v.size() << endl;
    cout << s.rob(v) << endl;
    return 0;
}