---
title: LeetCode-多线程-1
date: 2024-3-4 23:14:34
tags: 
    - LeetCode
    - 多线程
categories: 
    - LeetCode
    - 多线程
toc: true
language: zh-CN
---

## [1115. 交替打印 FooBar](https://leetcode.cn/problems/print-foobar-alternately/description/)


### 信号量
```java
class FooBar {
    private int n;
    private Semaphore fooSem, barSem;
    public FooBar(int n) {
        this.n = n;
        fooSem = new Semaphore(1);
        barSem = new Semaphore(0);
    }

    public void foo(Runnable printFoo) throws InterruptedException {

        for (int i = 0; i < n; i++) {

            // printFoo.run() outputs "foo". Do not change or remove this line.
            fooSem.acquire();
            printFoo.run();
            barSem.release();
        }
    }

    public void bar(Runnable printBar) throws InterruptedException {

        for (int i = 0; i < n; i++) {

            // printBar.run() outputs "bar". Do not change or remove this line.
            barSem.acquire();
            printBar.run();
            fooSem.release();
        }
    }
}
```

### 条件变量

```java
class FooBar {
    private int n;
    Lock lock;
    Condition condition;
    boolean fooOrBar = true;
    public FooBar(int n) {
        this.n = n;
        lock = new ReentrantLock();
        condition = lock.newCondition();
    }

    public void foo(Runnable printFoo) throws InterruptedException {

        for (int i = 0; i < n; i++) {

            // printFoo.run() outputs "foo". Do not change or remove this line.
            lock.lock();
            while(!fooOrBar) {
                condition.await();
            }
            printFoo.run();
            fooOrBar = !fooOrBar;
            condition.signalAll();
            lock.unlock();
        }
    }

    public void bar(Runnable printBar) throws InterruptedException {

        for (int i = 0; i < n; i++) {

            // printBar.run() outputs "bar". Do not change or remove this line.
            lock.lock();
            while(fooOrBar) {
                condition.await();
            }
            printBar.run();
            fooOrBar = !fooOrBar;
            condition.signalAll();
            lock.unlock();
        }
    }
}
```

## [1116. 打印零与奇偶数](https://leetcode.cn/problems/print-zero-even-odd/description/)

### 条件变量

```java
class ZeroEvenOdd {
    private int n;

    private int state;
    private int curValue;
    final private Lock lock;
    final private Condition condition;
    public ZeroEvenOdd(int n) {
        this.n = n;
        lock = new ReentrantLock();
        condition = lock.newCondition();
        state = 0;
        curValue = 0;
    }

    // printNumber.accept(x) outputs "x", where x is an integer.
    public void zero(IntConsumer printNumber) throws InterruptedException {
        for(int i = 0; i < n; i++) {
            lock.lock();
            while(state != 0 && state != 2) {
                condition.await();
            }
            printNumber.accept(0);
            condition.signalAll();
            state = (state + 1) % 4;
            lock.unlock();
        }
    }

    public void even(IntConsumer printNumber) throws InterruptedException {
        for(int i = 2; i <= n; i+=2) {
            lock.lock();
            while(state != 3) {
                condition.await();
            }
            printNumber.accept(++curValue);
            condition.signalAll();
            state = (state + 1) % 4;
            lock.unlock();
        }
    }

    public void odd(IntConsumer printNumber) throws InterruptedException {
        for(int i = 1; i <= n; i+=2) {
            lock.lock();
            while(state != 1) {
                condition.await();
            }
            printNumber.accept(++curValue);
            condition.signalAll();
            state = (state + 1) % 4;
            lock.unlock();
        }
    }
}
```

### synchronized
```java
class ZeroEvenOdd {
    private int n;

    private int state;
    final private Lock lock;
    final private Condition condition;
    public ZeroEvenOdd(int n) {
        this.n = n;
        lock = new ReentrantLock();
        condition = lock.newCondition();
        state = 0;
    }

    // printNumber.accept(x) outputs "x", where x is an integer.
    public void zero(IntConsumer printNumber) throws InterruptedException {
        for(int i = 0; i < n; i++) {
            synchronized (this) {
                while(state != 0 && state != 2) {
                    this.wait();
                }
                printNumber.accept(0);
                state = (state + 1) % 4;
                this.notifyAll();
            }
        }
    }

    public void even(IntConsumer printNumber) throws InterruptedException {
        for(int i = 2; i <= n; i+=2) {
            synchronized (this) {
                while(state != 3) {
                    this.wait();
                }
                printNumber.accept(i);
                state = (state + 1) % 4;
                this.notifyAll();
            }
        }
    }

    public void odd(IntConsumer printNumber) throws InterruptedException {
        for(int i = 1; i <= n; i+=2) {
            synchronized (this) {
                while(state != 1) {
                    this.wait();
                }
                printNumber.accept(i);
                state = (state + 1) % 4;
                this.notifyAll();
            }
        }
    }
}
```

## [1195. 交替打印字符串](https://leetcode.cn/problems/fizz-buzz-multithreaded/description/)

### synchronized
```java
class FizzBuzz {
    private int n;
    private int curNum;
    public FizzBuzz(int n) {
        this.n = n;
        curNum = 1;
    }
    private void runner(Predicate<Integer> test, IntConsumer consumer) throws InterruptedException {
        while(curNum <= n) {
            synchronized (this) {
                while (!test.test(curNum) && curNum <= n) {
                    this.wait();
                }
                if(curNum <= n) {
                    consumer.accept(curNum);
                    curNum++;
                    this.notifyAll();
                }
            }
        }
    }
    // printFizz.run() outputs "fizz".
    public void fizz(Runnable printFizz) throws InterruptedException {
        runner((n)->n % 3 == 0 && n % 5 != 0, (n)->printFizz.run());
    }

    // printBuzz.run() outputs "buzz".
    public void buzz(Runnable printBuzz) throws InterruptedException {
        runner((n)->n % 3 != 0 && n % 5 == 0, (n)->printBuzz.run());
    }

    // printFizzBuzz.run() outputs "fizzbuzz".
    public void fizzbuzz(Runnable printFizzBuzz) throws InterruptedException {
        runner((n)->n % 3 == 0 && n % 5 == 0, (n)->printFizzBuzz.run());
    }

    // printNumber.accept(x) outputs "x", where x is an integer.
    public void number(IntConsumer printNumber) throws InterruptedException {
        runner((n)->n % 3 != 0 && n % 5 != 0, printNumber);
    }
}
```

### condition
```java
class FizzBuzz {
    private int n;
    final private Lock lock;
    final private Condition condition;
    private int curNum;
    public FizzBuzz(int n) {
        this.n = n;
        curNum = 1;
        lock = new ReentrantLock();
        condition = lock.newCondition();
    }
   private void runner(Predicate<Integer> test, IntConsumer consumer) throws InterruptedException {
       while(curNum <= n) {
           lock.lock();
           while (!test.test(curNum) && curNum <= n) {
               condition.await();
           }
           if(curNum <= n) {
               consumer.accept(curNum);
               curNum++;
               condition.signalAll();
           }
           lock.unlock();
       }
   }
    // printFizz.run() outputs "fizz".
    public void fizz(Runnable printFizz) throws InterruptedException {
        runner((n)->n % 3 == 0 && n % 5 != 0, (n)->printFizz.run());
    }

    // printBuzz.run() outputs "buzz".
    public void buzz(Runnable printBuzz) throws InterruptedException {
        runner((n)->n % 3 != 0 && n % 5 == 0, (n)->printBuzz.run());
    }

    // printFizzBuzz.run() outputs "fizzbuzz".
    public void fizzbuzz(Runnable printFizzBuzz) throws InterruptedException {
        runner((n)->n % 3 == 0 && n % 5 == 0, (n)->printFizzBuzz.run());
    }

    // printNumber.accept(x) outputs "x", where x is an integer.
    public void number(IntConsumer printNumber) throws InterruptedException {
        runner((n)->n % 3 != 0 && n % 5 != 0, printNumber);
    }
}
```

## [1117. H2O 生成](https://leetcode.cn/problems/building-h2o/description/)

```java
class H2O {
    Semaphore semH, semO;
    public H2O() {
        semH = new Semaphore(2);
        semO = new Semaphore(0);
    }

    public void hydrogen(Runnable releaseHydrogen) throws InterruptedException {

        // releaseHydrogen.run() outputs "H". Do not change or remove this line.
        semH.acquire();
        releaseHydrogen.run();
        semO.release();
    }

    public void oxygen(Runnable releaseOxygen) throws InterruptedException {

        // releaseOxygen.run() outputs "O". Do not change or remove this line.
        semO.acquire(2);
        releaseOxygen.run();
        semH.release(2);
    }
}
```

## [1114. 按序打印](https://leetcode.cn/problems/print-in-order/description/)
### 信号量
```java
class Foo {
    Semaphore a, b;
    public Foo() {
        a = new Semaphore(0);
        b = new Semaphore(0);
    }

    public void first(Runnable printFirst) throws InterruptedException {

        // printFirst.run() outputs "first". Do not change or remove this line.
        printFirst.run();
        a.release();
    }

    public void second(Runnable printSecond) throws InterruptedException {

        // printSecond.run() outputs "second". Do not change or remove this line.
        a.acquire();
        printSecond.run();
        b.release();
    }

    public void third(Runnable printThird) throws InterruptedException {

        // printThird.run() outputs "third". Do not change or remove this line.
        b.acquire();
        printThird.run();
    }
}
```
### 条件
```java
class Foo {
    private int seq;
    public Foo() {
        seq = 0;
    }

    public void first(Runnable printFirst) throws InterruptedException {

        // printFirst.run() outputs "first". Do not change or remove this line.
        synchronized (this) {
            printFirst.run();
            seq++;
            notifyAll();
        }
    }

    public void second(Runnable printSecond) throws InterruptedException {

        // printSecond.run() outputs "second". Do not change or remove this line.
        synchronized (this) {
            while (seq != 1) {
                wait();
            }
            printSecond.run();
            seq++;
            notifyAll();
        }
    }

    public void third(Runnable printThird) throws InterruptedException {

        // printThird.run() outputs "third". Do not change or remove this line.
        synchronized (this) {
            while (seq != 2) {
                wait();
            }
            printThird.run();
        }
    }
}
```

### CountDownLatch
[CountDownLatch的理解和使用](https://www.cnblogs.com/Lee_xy_z/p/10470181.html)

> 当每一个线程完成自己任务后，计数器的值就会减一。当计数器的值为0时，表示所有的线程都已经完成一些任务，然后在CountDownLatch上等待的线程就可以恢复执行接下来的任务。


```java
class Foo {
    private CountDownLatch count1;
    private CountDownLatch count2;
    public Foo() {
        count1 = new CountDownLatch(1);
        count2 = new CountDownLatch(1);
    }

    public void first(Runnable printFirst) throws InterruptedException {
        
        // printFirst.run() outputs "first". Do not change or remove this line.
        printFirst.run();
        count1.countDown();
    }

    public void second(Runnable printSecond) throws InterruptedException {
        count1.await();
        // printSecond.run() outputs "second". Do not change or remove this line.
        printSecond.run();
        count2.countDown();
    }

    public void third(Runnable printThird) throws InterruptedException {
        count2.await();
        // printThird.run() outputs "third". Do not change or remove this line.
        printThird.run();
    }
}
```

## [1226. 哲学家进餐](https://leetcode.cn/problems/the-dining-philosophers/description/)


### 条件
- 一个数组保存每个筷子是否使用
- 检查需要的两个筷子，如果筷子可用，改为false，释放锁，开始吃
- 吃完后，释放两个筷子，通知其他线程

```java
class DiningPhilosophers {
    Lock lock;
    boolean[] ready;
    Condition condition;
    public DiningPhilosophers() {
        lock = new ReentrantLock();
        ready = new boolean[5];
        Arrays.fill(ready, true);
        condition = lock.newCondition();
    }

    // call the run() method of any runnable to execute its code
    public void wantsToEat(int philosopher,
                           Runnable pickLeftFork,
                           Runnable pickRightFork,
                           Runnable eat,
                           Runnable putLeftFork,
                           Runnable putRightFork) throws InterruptedException {
        boolean leftChopstick = false;
        boolean rightChopstick = false;
        lock.lock();
        while(!ready[philosopher] || !ready[(philosopher+1) % 5]) {
            condition.await();
        }
        ready[philosopher] = false;
        ready[(philosopher+1) % 5] = false;
        pickLeftFork.run();
        pickRightFork.run();
        lock.unlock();

        eat.run();

        lock.lock();
        putLeftFork.run();
        putRightFork.run();
        ready[philosopher] = true;
        ready[(philosopher+1) % 5] = true;
        condition.signalAll();
        lock.unlock();
    }
}
```
### 5个条件
- 这样可以减少唤醒的线程个数
```java
class DiningPhilosophers {
    Lock lock;
    boolean[] ready;
    Condition[] conditions;
    public DiningPhilosophers() {
        lock = new ReentrantLock();
        ready = new boolean[5];
        Arrays.fill(ready, true);
        conditions = new Condition[5];
        for (int i = 0; i < conditions.length; i++) {
            conditions[i] = lock.newCondition();
        }
    }

    // call the run() method of any runnable to execute its code
    public void wantsToEat(int philosopher,
                           Runnable pickLeftFork,
                           Runnable pickRightFork,
                           Runnable eat,
                           Runnable putLeftFork,
                           Runnable putRightFork) throws InterruptedException {
        lock.lock();
        while(!ready[philosopher] || !ready[(philosopher+1) % 5]) {
            conditions[philosopher].await();
        }
        ready[philosopher] = false;
        ready[(philosopher+1) % 5] = false;
        pickLeftFork.run();
        pickRightFork.run();
        lock.unlock();

        eat.run();

        lock.lock();
        putLeftFork.run();
        putRightFork.run();
        ready[philosopher] = true;
        ready[(philosopher+1) % 5] = true;
        conditions[(philosopher+1) % 5].signalAll();
        conditions[(philosopher-1 + 5) % 5].signalAll();
        lock.unlock();
    }
}
```