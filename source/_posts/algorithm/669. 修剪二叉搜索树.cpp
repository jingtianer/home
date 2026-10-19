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
#include<unordered_map>

using namespace std;

class Solution {
public:
    int low, high;
    TreeNode* trimBST(TreeNode* root, int low, int high) {
        this->low = low;
        this->high = high;
        find(&root);
        return root;
    }

    bool valid(const int& i) {
        return i>= low && i <= high;
    }

    void find(TreeNode** root) {
        while((*root) != nullptr && !valid((*root)->val)){
            if((*root)->val > high) {
                *root = (*root)->left;
            } else if((*root)->val < low) {
                *root = (*root)->right;
            }
        }
        if((*root) == nullptr) return;
        if((*root)->left != nullptr) {
            find(&((*root)->left));
        }
        if((*root)->right != nullptr) {
            find(&((*root)->right));
        }
    }
};