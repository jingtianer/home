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

## 1279. 红绿灯路口
- 睾贵的会员题，不过本科的时候学过

```java
package leetcode;

import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Semaphore;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

class TrafficLight {
    private int road = 0;
    private final Semaphore lockNS;
    private final Semaphore lockSW;
    private static final int NS = 1;
    private static final int SW = 2;
    private int carNumber = 0;
    public TrafficLight() {
        lockNS = new Semaphore(1);
        lockSW = new Semaphore(1);
    }

    public void carArrived(int carId, // ID of the car
                                        int roadId, // ID of the road the car travels on. Can be 1 (road A) or 2 (road B)
                                        int direction, // Direction of the car
                                        Runnable turnGreen, // Use turnGreen.run() to turn light to green on current road
                                        Runnable crossCar // Use crossCar.run() to make car cross the intersection
    ) {
        Semaphore lockOur, lockOther;
        if(roadId == NS) {
            lockOur = lockNS;
            lockOther = lockSW;
        } else {
            lockOur = lockSW;
            lockOther = lockNS;
        }
        try {
            lockOur.acquire();
            if(roadId != road) {
                lockOther.acquire();
                road = roadId;
                turnGreen.run();
            }
            carNumber++;
            lockOur.release();

            crossCar.run();

            lockOur.acquire();
            carNumber--;
            if(carNumber == 0) {
                lockOther.release();
            }
            lockOur.release();
        } catch (InterruptedException e) {

        }
    }
}

public class TestTrafficLight {
    public static void main(String[] args) {
        final TrafficLight trafficLight = new TrafficLight();
        Random random = new Random(System.currentTimeMillis());
        int carNumber = random.nextInt(100, 200);
        try(ExecutorService executor = Executors.newCachedThreadPool()) {
            for(int i = 0; i < carNumber; i++) {
                final int carId = i;
                final int roadId = random.nextInt(1,3);
                final int direction = random.nextInt(1,3);
                executor.submit(()->trafficLight.carArrived(
                        carId,
                        roadId,
                        direction,
                        ()-> System.out.printf("car:%d, onRoad:%d, direction:%d, turn traffic light green\n", carId, roadId, direction),
                        ()-> System.out.printf("car:%d, onRoad:%d, direction:%d, running\n", carId, roadId, direction)
                ));
            }
        }
    }
}
```

## 1188. 设计有限阻塞队列
- 又是睾贵的会员题目
- 生产者消费者模型

```java
package leetcode;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Semaphore;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import static leetcode.Tools.printf;
import static leetcode.Tools.runCatching;

class BoundedBlockingQueue {
    Semaphore consumer, producer;
    Lock mutex;
    final private int capacity;
    private LinkedList<Integer> q = new LinkedList<>();

    public BoundedBlockingQueue(int capacity) {
        this.capacity = capacity;
        consumer = new Semaphore(0);
        producer = new Semaphore(capacity);
        mutex = new ReentrantLock();
    }

    public void enqueue(int element) {
        try {
            producer.acquire();
            mutex.lock();
            q.add(element);
        } catch (Exception e) {
            producer.release();
            throw new RuntimeException(e);
        } finally {
            mutex.unlock();
            consumer.release();
        }
    }

    public int dequeue() {
        int ret;
        try {
            consumer.acquire();
            mutex.lock();
            ret = q.remove(0);
        } catch (Exception e) {
            consumer.release();
            throw new RuntimeException(e);
        } finally {
            mutex.unlock();
            producer.release();
        }
        return ret;
    }

    public int size() {
        return q.size();
    }
}
public class TestBoundedBlockingQueue {
    static final int MIN_THREAD_NUM = 2;
    static final int MAX_THREAD_NUM = 50;
    static final int MIN_CAPACITY = 1;
    static final int MAX_CAPACITY = 50;
    static final int MIN_OP_NUM = 20;
    static final int MAX_OP_NUM = 100;

    static
    Random random = new Random(System.currentTimeMillis());
    static int produceTotal; // 生产者生产总数
    static int consumerTotal; // 消费者总数
    static void getOps(int[] producerNum, int[] consumerNum, int maxRemainNum) {
        produceTotal = consumerTotal = 0;
        for(int i = 0; i < producerNum.length; i++){
            int opNum = random.nextInt(MIN_OP_NUM, MAX_OP_NUM + 1);
            producerNum[i] = opNum;
            produceTotal += opNum;
        }
        for(int i = consumerNum.length-1; produceTotal - maxRemainNum - consumerTotal > 0; i--) {
            int opNum = random.nextInt((produceTotal - maxRemainNum - consumerTotal) / (i*i + 1), (produceTotal - maxRemainNum - consumerTotal) / (i + 1) + 1);
            consumerNum[i] = opNum;
            consumerTotal += opNum;
        }
    }
    public static void main(String[] args) {
        int threadNum = random.nextInt(MIN_THREAD_NUM, MAX_THREAD_NUM + 1);
        int capacity = random.nextInt(MIN_CAPACITY, MAX_CAPACITY + 1);
        int maxRemainNum = random.nextInt(0, capacity + 1);
        int[] producerNum = new int[random.nextInt(1, threadNum)];
        int[] consumerNum = new int[threadNum - producerNum.length];
        getOps(producerNum, consumerNum, maxRemainNum);
        System.out.printf("producerNum=%s\nconsumerNum=%s\nthreadNum=%d\ncapacity=%d\nproducerTotal=%d\nconsumerTotal=%d\nsize=%d\nmaxRemainNum=%d\n",
                Arrays.toString(producerNum), Arrays.toString(consumerNum), threadNum, capacity, produceTotal, consumerTotal, produceTotal - consumerTotal, maxRemainNum);
        BoundedBlockingQueue boundedBlockingQueue = new BoundedBlockingQueue(capacity);
        try(ExecutorService executorService = Executors.newFixedThreadPool(threadNum)) {
            for(int i = 0; i < producerNum.length; i++) {
                final int id = i;
                executorService.submit(runCatching(() -> {
                    for(int j = 0; j < producerNum[id]; j++) {
                        System.out.printf("%s, enqueue\n", Thread.currentThread().getName());
                        boundedBlockingQueue.enqueue(id);
                    }
                }));
            }
            for(int i = 0; i < consumerNum.length; i++) {
                final int id = i;
                executorService.submit(runCatching(() -> {
                    for(int j = 0; j < consumerNum[id]; j++) {
                        int front = boundedBlockingQueue.dequeue();
                        System.out.printf("%s, dequeue, front = %d\n", Thread.currentThread().getName(), front);
                    }
                }));
            }
        }
        if(produceTotal - consumerTotal == boundedBlockingQueue.size()) {
            System.out.printf("ok!, size = %d\n", produceTotal - consumerTotal);
        } else {
            throw new RuntimeException(printf("fail, you are foolish, correct size = %d, q.size = %d\n", produceTotal - consumerTotal, boundedBlockingQueue.size()));
        }
    }
}
```

```java
package leetcode;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

public class Tools {
    interface ExceptionRunnable {
        void run() throws Exception;
    }
    static Runnable runCatching(ExceptionRunnable r) {
        return () -> {try {r.run();} catch (Exception e) { e.printStackTrace(); }};
    }
    static public String printf(String format, Object ... args) {
        ByteArrayOutputStream byteArrayOutputStream;
        PrintStream printStream = new PrintStream((byteArrayOutputStream = new ByteArrayOutputStream()));
        printStream.printf(format, args);
        return byteArrayOutputStream.toString();
    }
}
```