

#include<vector>
#include<iostream>
#include<stack>
#include<queue>
#include<algorithm>
#include<unordered_map>

using namespace std;

struct GraphNode {
    string name;
    vector<GraphNode*> children;
    unordered_map<string, double> values;

    void addChildren(GraphNode* node, double val) {
        children.push_back(node);
        values[node->name] = val;
    }
    GraphNode(string name0): name(name0) {}
};

class Solution {
public:
    unordered_map<string, int> index;
    vector<GraphNode*> g;
    int len;
    vector<double> calcEquation(vector<vector<string>>& equations, vector<double>& values, vector<vector<string>>& queries) {
        int equationNum = equations.size();
        int count = 0;
        for(int i = 0; i < equationNum; i++) {
            string node1Name = equations[i][0],node2Name = equations[i][1];
            double value1 = values[i], value2 = 1/values[i];
            GraphNode *node1, *node2;
            if(index.count(node1Name) == 0) {
                node1 = new GraphNode(node1Name);
                index[node1Name] = count++;
                g.push_back(node1);
            } else {
                node1 = g[index[node1Name]];
            }
            if(index.count(node2Name) == 0) {
                node2 = new GraphNode(node2Name);
                index[node2Name] = count++;
                g.push_back(node2);
            } else {
                node2 = g[index[node2Name]];
            }
            
            node1->addChildren(node2, value1);
            node2->addChildren(node1, value2);
        }
        printG();
        len = g.size();
        vector<double> res;
        for(auto query : queries) {
            res.push_back(search(query[0], query[1]));
        }
        return res;
    }

    void printG() {
        for(auto node : g) {
            cout << node->name << ": ";
            int size = node->children.size();
            for(int i = 0; i < size; i++) {
                cout << "(" << node->children[i]->name << " | " << node->values[node->children[i]->name] << "), ";
            }
            cout << endl;
        }
        
    }

    double search(const string& s, const string& e) {
        // printf("%s -> %s\n", s.c_str(), e.c_str());
        if(index.count(e) == 0 || index.count(s) == 0) return -1.0;
        int target = index[e];
        int start = index[s];
        if(start == target) return 1.0;
        vector<bool> visited(len, false);
        stack<pair<int, double>> q;
        q.push(pair<int, double>(start, 1.0));
        visited[start] = true;
        double res = 1.0;
        while(!q.empty()) {
            int nodeIndex = q.top().first;
            double val = q.top().second;
            res *= val;
            GraphNode* node = g[nodeIndex];
            bool add = false;
            // printf("node %s\n", node->name.c_str());
            q.pop();
            for(GraphNode* child : node->children) {
                int childIndex = index[child->name];
                if(childIndex == target) {
                    return res * node->values[child->name];
                } else if(!visited[childIndex]) {
                    q.push(pair<int, double>(childIndex, node->values[child->name]));
                    visited[childIndex] = true;
                    add = true;
                }
            }
            if(!add) {
                res /= val;
            }
        }
        return -1.0;
    }
};

template<class T>
void printVec(const vector<T> &v, const string& head = "")
{
    if(head != "") {
        cout << head << ": ";
    }
    for (T i : v)
    {
        cout << i << " ";
    }
    cout << "\n";
}
int main() {
    Solution s;
    vector<vector<string>> equations = {{"a","e"},{"b","e"}};
    vector<double> values = {4.0,3.0};
    vector<vector<string>> queries = {{"a","b"},{"e","e"},{"x","x"}};
    vector<double> res = s.calcEquation(equations, values, queries);
    printVec<double>(res, "result = ");
    return 0;
}