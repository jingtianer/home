#include<vector>
#include<iostream>
#include<stack>
#include<queue>
#include<algorithm>
#include<unordered_map>

using namespace std;

class Solution {
public:
    bool canFinish(int numCourses, vector<vector<int>>& prerequisites) {
        vector<int> m(numCourses, 0);
        vector<bool> visited(numCourses, false);
        unordered_map<int, vector<int>> g;
        for(vector<int>& p:prerequisites) {
            m[p[0]]++;
            g[p[1]].push_back(p[0]);
        }
        bool find = true;
        stack<int> s;
        for(int i = 0; i < numCourses; i++) {
            if(m[i] == 0) {
                s.push(i);
                visited[i] = true;
            }
        }
        while(!s.empty()) {
            int pos = s.top();
            s.pop();
            vector<int> arcs = g[pos];
            for(int arc : arcs) {
                m[arc]--;
                if(m[arc] == 0) {
                    s.push(arc);
                    visited[arc] = true;
                }
            }
        }
        for(bool visit:visited) {
            if(!visit) {
                return false;
            }
        }
        return true;
    }
};