/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
  struct TreeNode {
      int val;
      TreeNode *left;
      TreeNode *right;
      TreeNode() : val(0), left(nullptr), right(nullptr) {}
      TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
      TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 };
#include<vector>
#include<iostream>
#include<stack>
#include<queue>
#include<algorithm>
using namespace std;
class Solution {
public:
    vector<vector<int>> levelOrderBottom(TreeNode* root) {
        queue<TreeNode*> s;
        if(root != nullptr) {
            s.push(root);
        }
        vector<vector<int>> res;
        vector<int> tmp;
        queue<TreeNode*> tmp_s;
        while(!s.empty()) {
            tmp.push_back(s.front()->val);
            TreeNode* tmp_node = s.front();
            if(tmp_node->left != nullptr) {
                tmp_s.push(tmp_node->left);
                // printf("add %d\n", tmp_node->left->val);
            }
            if(tmp_node->right != nullptr) {
                tmp_s.push(tmp_node->right);
                // printf("add %d\n", tmp_node->right->val);
            }
            s.pop();
            if(s.empty() && !tmp_s.empty()) {
                res.push_back(tmp);
                tmp.clear();
                while (!tmp_s.empty()){
                    s.push(tmp_s.front());
                    tmp_s.pop();
                }
            }
        }
        if(!tmp.empty()) {
            res.push_back(tmp);
        }
        reverse(res.begin(),res.end());
        return res;
    }
};