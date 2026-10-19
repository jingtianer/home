#include <vector>
#include <iostream>
#include <stack>
#include <queue>
#include <algorithm>
#include <unordered_map>

using namespace std;

void printVec(const vector<int> &v, const string& head = "")
{
    if(head != "") {
        cout << head << ": ";
    }
    for (int i : v)
    {
        cout << i << " ";
    }
    cout << "\n";
}

vector<int> diffOf(const vector<int> &v)
{
    int len = v.size();
    vector<int> diff(len, 0);
    diff[0] = v[0];
    for (int i = 1; i < len; i++)
    {
        diff[i] = v[i] - v[i - 1];
    }
    return diff;
}

vector<int> dataOf(const vector<int> &v)
{
    int len = v.size();
    vector<int> data(len, 0);
    data[0] = v[0];
    for (int i = 1; i < len; i++)
    {
        data[i] = v[i] + data[i - 1];
    }
    return data;
}

int main()
{
    vector<int> data = {1, 2, 3, 4, 5, 6, 7, 8};
    vector<int> data_diff = diffOf(data);
    printVec(dataOf(data_diff), "data");
    printVec(data_diff, "diff");
    int l, r, diff; //区间 [l, r) 的所有数增加 diff
    while (cin >> l >> r >> diff)
    {
        data_diff[l] += diff;
        data_diff[r] -= diff;
        printVec(dataOf(data_diff), "data");
        printVec(data_diff, "diff");
    }
    return 0;
}