#include<vector>
#include<iostream>
#include<stack>
#include<queue>
#include<algorithm>
#include<unordered_map>
#include<climits>
using namespace std;
struct Node {
    int n, cur;
    Node* next;
    Node(int n0, int cur0) : n(n0), cur(cur0) {
        next = nullptr;
    }
};

class Solution {
public:
    int removeBoxes(vector<int>& boxes) {
        Node* head = new Node(0,0);
        Node* move = head;
        int i = 0;
        int len = boxes.size();
        int total[101] = {0};
        while(i < len) {
            int cur = boxes[i];
            int n = 0;
            while(i < len && cur == boxes[i]) {
                n++;
                i++;
                total[cur]++;
            }
            move->next = new Node(n, cur);
            move = move->next;
        }

        
        int min = INT_MAX;
        int minn = INT_MAX;
        int maxt = INT_MIN;
        int minBox = 0;
        move = head;
        while(move->next != nullptr) {
            int diff = total[move->next->cur] - move->next->n;
            if(min > diff) {
                maxt = total[move->next->cur];
                min = diff;
                minBox = move->next->cur;
                minn = move->next->n;
            } else if(min == diff) {
                if(maxt < total[move->cur]) {
                    maxt = total[move->next->cur];
                    min = diff;
                    minBox = move->next->cur;
                    minn = move->next->n;
                } else if(maxt == total[move->cur]) {
                    if(minn > move->n) {
                        min = diff;
                        maxt = total[move->cur];
                        minBox = move->cur;
                        minn = move->n;
                    }
                }
            }
            move = move->next;
        }
        cout << "minbox = " << minBox << endl;
        int res = 0;
        while(head->next != nullptr) {
            move = head;
            int newMin = INT_MAX;
            int newMinn = INT_MAX;
            int newMinNode = 0;
            int maxt = INT_MIN;
            while(move != nullptr && move->next != nullptr) {
                if(move->next->cur == minBox) {
                    Node* node = move->next;
                    move->next = node->next;
                    if(move->next != nullptr && move->cur == move->next->cur) {
                        move->n += move->next->n;
                        move->next = move->next->next;
                    }
                    res += node->n * node->n;
                } else {
                    move=move->next;
                }
                if(move == nullptr) break;
                int diff = total[move->cur] - move->n;
                cout << "diff : " << move->cur << " = " << diff << endl;
                if(newMin > diff) {
                    newMin = diff;
                    maxt = total[move->cur];
                    newMinNode = move->cur;
                    newMinn = move->n;
                } else if(newMin == diff) {
                    if(maxt < total[move->cur]) {
                        newMin = diff;
                        maxt = total[move->cur];
                        newMinNode = move->cur;
                        newMinn = move->n;
                    } else if(maxt == total[move->cur]) {
                        if(newMinn > move->n) {
                            newMin = diff;
                            maxt = total[move->cur];
                            newMinNode = move->cur;
                            newMinn = move->n;
                        }
                    }
                }
                
            }
            minBox = newMinNode;
            cout << "minbox = " << minBox << endl;
        }
        return res;
    }
};

int main() {
    Solution s;
    vector<int> v = {5,8,3,8,4,8,5,7,4,2};
    int res = 18;
    int ret = s.removeBoxes(v);
    cout << "ret = " << ret << " res = " << res << " " << (res == ret) << endl;
    return 0;
}

