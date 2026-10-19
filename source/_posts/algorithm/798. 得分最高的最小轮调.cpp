#include<vector>
#include<iostream>
#include<stack>
#include<queue>
#include<algorithm>
#include<unordered_map>

using namespace std;

class Solution {
public:
    int bestRotation(vector<int>& nums) {
        int len = nums.size();
        vector<int> diff(len, 0);
        for(int i = 0; i < len; i++) {
            int low = (i+1)%len, high = (len + i - nums[i] + 1) % len;
            diff[low]++;
            diff[high]--;
            if(low >= high) {
                diff[0]++;
            }
        }
        int max = 0;
        int cur = 0;
        int pos = 0;
        for(int i = 0; i < len; i++) {
            cur += diff[i];
            if(max < cur) {
                pos = i;
                max = cur;
            }
        }
        return pos;
    }
};