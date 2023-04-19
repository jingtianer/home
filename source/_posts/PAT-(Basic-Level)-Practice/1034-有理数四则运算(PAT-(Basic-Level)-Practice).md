---
title: PAT-Basic-1034
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目
>本题要求编写程序，计算 2 个有理数的和、差、积、商。
#### 输入格式：
>输入在一行中按照 a1/b1 a2/b2 的格式给出两个分数形式的有理数，其中分子和分母全是整型范围内的整数，负号只可能出现在分子前，分母不为 0。
#### 输出格式：
>分别在 4 行中按照 有理数1 运算符 有理数2 = 结果 的格式顺序输出 2 个有理数的和、差、积、商。注意输出的每个有理数必须是该有理数的最简形式 k a/b，其中 k 是整数部分，a/b 是最简分数部分；若为负数，则须加括号；若除法分母为 0，则输出 Inf。题目保证正确的输出中没有超过整型范围的整数。
#### 输入样例 1：
    2/3 -4/2
#### 输出样例 1：
    2/3 + (-2) = (-1 1/3)
    2/3 - (-2) = 2 2/3
    2/3 * (-2) = (-1 1/3)
    2/3 / (-2) = (-1/3)
#### 输入样例 2：
    5/3 0/6
#### 输出样例 2：
    1 2/3 + 0 = 1 2/3
    1 2/3 - 0 = 1 2/3
    1 2/3 * 0 = 0
    1 2/3 / 0 = Inf

## 通过代码
```c++
#include <iostream>
#include <string>
#include <algorithm>
using namespace std;
typedef long long ll;
string toString (ll a) {
    string ans;
    while (a) {
        ans.append(1,(char)(a%10 + '0'));
        a/=10;
    }
    reverse(ans.begin(), ans.end());
    return ans;
}
class Main {
private:
    ll ans1,ans2, pos;
public:
    Main(ll a, ll b) {
        pos = 1; ans1 = a; ans2 = b;
        if (a < 0) { ans1 *= -1; pos*=-1; }
        if (b < 0) { ans2 *= -1; pos*=-1; }
    }
    Main(Main& ob) { ans1 = ob.ans1; ans2 = ob.ans2; pos = ob.pos; }
    void set(ll a, ll b) {
        pos = 1; ans1 = a; ans2 = b;
        if (a < 0) { ans1 *= -1; pos*=-1; }
        if (b < 0) { ans2 *= -1; pos*=-1; }
        
    }
    string toString() {
        string ans;
        if (ans1 == 0 && ans2 != 0) { ans.append("0"); return ans; }
        if (ans2 == 0) { ans.append("Inf"); return ans;  }
        getSmall();
        if (pos == -1) { ans.append("(-"); }
        if (ans2 != 1) {
            if (ans1 < ans2) {
                ans.append(::toString(ans1)); ans.append("/"); ans.append(::toString(ans2));
            } else if (ans1 == ans2) {
                ans.append("1");
            } else {
                ll y = ans1 / ans2; ll ta1 = ans1;
                ta1 -= y * ans2;
                ans.append(::toString(y)); ans.append(" ");
                ans.append(::toString(ta1)); ans.append("/");
                ans.append(::toString(ans2));
            }
        } else {
            ans.append(::toString(ans1));
        }
        if (pos == -1) { ans.append(")"); }
        return ans;
    }
    void getSmall() {
        ll ta = ans1, tb = ans2;
        while (tb != 0) {
            ll temp = ta % tb;
            ta = tb;
            tb = temp;
        }
        ans1 /= ta;  ans2 /= ta;
    }
    static void add(Main* a, Main* b, Main* ans) {
        ll ans1 = a->ans1 * b->ans2 * a->pos + a->ans2 * b->ans1 * b->pos;
        ll ans2 = a->ans2 * b->ans2;
        ans->set(ans1, ans2);
    }
    static void sub(Main* a, Main* b, Main* ans) {
        ll ans1 = a->ans1 * b->ans2*a->pos - a->ans2 * b->ans1*b->pos;
        ll ans2 = a->ans2 * b->ans2;
        ans->set(ans1, ans2);
    }
    static void mul(Main* a, Main* b, Main* ans) {
        ll ans1 = a->pos * b->pos * a->ans1 * b->ans1;
        ll ans2 = a->ans2 * b->ans2;
        ans->set(ans1, ans2);
    }
    static void dev(Main* a, Main* b, Main* ans) {
        ll ans1 = a->pos * b->pos * a->ans1 * b->ans2;
        ll ans2 = a->ans2 * b->ans1;
        ans->set(ans1, ans2);
    }
};
int main() {
    ll a1,a2,b1,b2;
    scanf("%lld/%lld %lld/%lld", &a1, &a2, &b1, &b2);
    Main x(a1, a2);
    Main y(b1, b2);
    Main ans(0,0);
    Main::add(&x, &y, &ans);
    cout << x.toString() << " + " << y.toString() << " = " << ans.toString() << endl;
    Main::sub(&x, &y, &ans);
    cout << x.toString() << " - " << y.toString() << " = " << ans.toString() << endl;
    Main::mul(&x, &y, &ans);
    cout << x.toString() << " * " << y.toString() << " = " << ans.toString() << endl;
    Main::dev(&x, &y, &ans);
    cout << x.toString() << " / " << y.toString() << " = " << ans.toString() << endl;
    return 0;
}
```
## 思路与注意
>1. 写一个对分数的处理类，分别记录分子，分母和符号
>2. 计算什么的直接算，等最后要输出之前求一下最大公倍数约分一下就好了，（原谅我不会约分的英文，只好写成getSmall了，hhh） 
>2. 这道题题目上说输入和结构都在int范围，但是不保证中间过程也在int范围，所以要用long
>3. 注意第二个数为0时的要特判
## 反思与评价
>* 这次把Java移植成C++，把以下问题都解决了，个人认为这题大概就是给C++设计的吧？
>```
>* 处理加和减的函数有点臃肿，有待提高
>* 这个代码在超时的边缘疯狂试探，有时候能全部通过，有时候会运行超时。好神奇，而且越压行，越超时。
>```
>* 在移植的时候，构造函数写成只有参数为负才会赋值，一直算不出来，折腾很久，以后移植的时候要小心。
>* 移植过程中有很多内存泄漏的问题，后来也都改了。Java根本不用考虑内存的问题，以后移植的时候这一点也要注意。
