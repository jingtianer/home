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
    template<class T>
    void printVec(const vector<T> &v, const string& head = "") {
        if(head != "") {
            cout << head << ": ";
        }
        for (T i : v) {
            cout << i << " ";
        }
        cout << "\n";
    }
    vector<int> size;
    vector<int> parents;
    unordered_map<int, vector<int>> children;
    int n;
    long long max = LONG_LONG_MIN;
    int maxn = 0;
    int countHighestScoreNodes(vector<int>& parents) {
        int n = parents.size();
        this->parents = parents;
        this->size = vector<int>(n, 1);
        this->n = n;
        for(int i = 0; i < n; i++) {
            getG(i);
        }
        getSize(0);
        for(int i = 0; i < n; i++) {
            calScore(i);
        }
        return maxn;

    }


    int getSize(int root) {
        int childNum = children[root].size();
        if(childNum == 0) {
            size[root] = 1;
        } else if(childNum == 1) {
            size[root] += getSize(children[root][0]);
        } else {
            size[root] += getSize(children[root][0]) + getSize(children[root][1]);
        }
        return size[root];
    }

    void calScore(int i) {
        int parent = parents[i];
        long long res = (parent == -1) ? 1 : (size[0] - size[i]);
        vector<int>& childi = children[i];
        for(int child : childi) {
            res *= size[child];
        }
        if(res > max) {
            max = res;
            maxn = 1;
        } else if(res == max) {
            maxn++;
        }
    }

    void getG(int i) {
        int parent = parents[i];
        if(parent == -1) {
            return;
        } else {
            children[parent].push_back(i);
        }
    }
};

int main() {
    Solution s;
    vector<int> v = {-1,2,0,2,0};
    cout << s.countHighestScoreNodes(v) << endl;
    return 0;
}

class SolutionBetter {
    //不使用map和set
public:
    vector<int> parents;
    vector<pair<int, int>> children;
    vector<int> size;
    int n;
    long long max = LONG_LONG_MIN;
    int maxn = 0;
    int countHighestScoreNodes(vector<int>& parents) {
        int n = parents.size();
        this->parents = parents;
        this->children = vector<pair<int, int>>(n, {-1,-1});
        this->size = vector<int>(n, 1);
        this->n = n;
        for(int i = 0; i < n; i++) {
            int parent = parents[i];
            if(parent == -1) {
                continue;
            } else {
                if(children[parent].first == -1) {
                    children[parent].first = i;
                } else {
                    children[parent].second = i;
                }
            }
        }
        getSize(0);
        for(int i = 0; i < n; i++) {
            int parent = parents[i];
            long long res = (parent == -1) ? 1 : (size[0] - size[i]);
            pair<int, int>& childi = children[i];
            res *= childi.first != -1 ? size[childi.first] : 1;
            res *= childi.second != -1 ? size[childi.second] : 1;
            if(res > max) {
                max = res;
                maxn = 1;
            } else if(res == max) {
                maxn++;
            }
        }
        return maxn;

    }


    int getSize(int root) {
        pair<int, int> child = children[root];
        int a = 0, b = 0;
        if(child.first != -1) {
            a = getSize(child.first);
        }
        if(child.second != -1) {
            b = getSize(child.second);
        }
        size[root] = 1 + a + b;
        return size[root];
    }
};
