/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
#include <vector>
#include <iostream>
#include <stack>
#include <queue>
#include <algorithm>
#include <unordered_map>
struct ListNode
{
    int val;
    ListNode *next;
    ListNode() : val(0), next(nullptr) {}
    ListNode(int x) : val(x), next(nullptr) {}
    ListNode(int x, ListNode *next) : val(x), next(next) {}
};
using namespace std;
class Solution
{
public:
    ListNode *sortList(ListNode *head)
    {
        ListNode *left, *right;
        int len = split(head, &left, &right);
        if (len > 2)
        {
            left = sortList(left);
            right = sortList(right);
        }
        return merge(left, right);
    }

    ListNode *merge(ListNode *left, ListNode *right)
    {
        ListNode *head = new ListNode(0), *tmp;
        tmp = head;
        while (left != nullptr && right != nullptr)
        {
            if (left->val < right->val)
            {
                tmp->next = left;
                left = left->next;
            }
            else
            {
                tmp->next = right;
                right = right->next;
            }
            tmp = tmp->next;
        }
        if (left != nullptr)
        {
            tmp->next = left;
        }
        if (right != nullptr)
        {
            tmp->next = right;
        }
        tmp = head->next;
        return tmp;
    }

    int split(ListNode *head, ListNode **left, ListNode **right)
    {
        ListNode *v = new ListNode(0);
        v->next = head;
        ListNode *slow = v, *fast = v;
        int len = 0;
        while (fast->next != nullptr)
        {
            slow = slow->next;
            fast = fast->next;
            len++;
            if (fast->next != nullptr)
            {
                fast = fast->next;
                len++;
            }
        }
        *left = head;
        *right = slow->next;
        slow->next = nullptr;
        return len;
    }
};
