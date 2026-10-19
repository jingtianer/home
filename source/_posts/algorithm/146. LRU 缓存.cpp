#include<vector>
#include<iostream>
#include<stack>
#include<queue>
#include<algorithm>
#include<unordered_map>
using namespace std;

struct Node {
    int val;
    int key;
    Node* next;
    Node* last;
    Node(int val0, int key0, Node* next0=nullptr, Node* last0 = nullptr):key(key0), next(next0), val(val0), last(last0) {}
};
class LRUCache {
public:
    unordered_map<int, Node*> hash;
    Node* root;
    int size = 0;
    int capacity = 0;
    LRUCache(int capacity) {
        root = new Node(-1,-1);
        this->capacity = capacity;
        size = 0;
        root->last = root;
        root->next = root;
    }
    
    int get(int key) {
        Node* cur = hash[key];
        
        // printf("get %d\n", (cur==nullptr? -1 : (cur->val)));
        printAll();
        if(cur == nullptr) return -1;
        remove(cur);
        insertTop(cur);
        printAll();
        return cur->val;
    }
    
    void remove(Node*cur) {
        Node* last = cur->last;
        Node* next = cur->next;
        last->next = next;
        next->last = last;
    }

    void put(int key, int value) {
        // printf("put %d\n", value);
        printAll();
        if(hash[key] != nullptr) {
            Node* cur = hash[key];
            cur->val = value;
            remove(cur);
            insertTop(cur);
            // printf("replace :%d\n", cur->val);
        } else {
            if(size < capacity) {
                Node * cur = new Node(value, key);
                hash[key] = cur;
                insertTop(cur);
                size++;
                // printf("insert :%d\n", cur->val);
            } else {
                Node* cur = root->last;
                if(cur->key != -1){
                    hash[cur->key] = nullptr;
                    hash[key] = cur;
                    
                    cur->val = value;
                    cur->key = key;
                    remove(cur);
                    insertTop(cur);
                }
                // printf("lru :%d\n", cur->val);
            }
            
        }
        printAll();
    }
    void printAll() {
        // Node * cur = root->next;
        // while(cur != root) {
        //     printf("%d ", cur->val);
        //     cur = cur->next;
        // }
        // printf("\n");
    }
    void insertTop(Node* cur) {
        cur->last = root;
        cur->next = root->next;
        root->next->last = cur;
        root->next = cur;
    }
};

/**
 * Your LRUCache object will be instantiated and called as such:
 * LRUCache* obj = new LRUCache(capacity);
 * int param_1 = obj->get(key);
 * obj->put(key,value);
 */