---
title: LeetCode-数据库-2
date: 2024-3-4 21:14:34
tags: 
    - LeetCode
    - 数据库
categories: 
    - LeetCode
    - 数据库
toc: true
language: zh-CN
---

## [584. 寻找用户推荐人](https://leetcode.cn/problems/find-customer-referee/description/)
```sql
SELECT
    name
FROM
    Customer
WHERE
    referee_id <> 2
    OR
    referee_id IS NULL
```

## [577. 员工奖金](https://leetcode.cn/problems/employee-bonus/description/)
```sql
SELECT
    E.name,
    B.bonus
FROM
    Employee E
    LEFT JOIN Bonus B
    ON E.empId = B.empId
WHERE
    B.bonus < 1000
    OR
    B.bonus IS NULL
```

## [570. 至少有5名直接下属的经理](https://leetcode.cn/problems/managers-with-at-least-5-direct-reports/description/)

```sql
SELECT 
    E1.name
FROM 
    Employee E1 
    LEFT JOIN Employee E2
    ON E1.id = E2.managerId
GROUP BY
    E1.id
HAVING
    COUNT(E1.id) >= 5
```

## [596. 超过5名学生的课](https://leetcode.cn/problems/classes-more-than-5-students/description/)

```sql
SELECT
    class
FROM
    Courses
GROUP BY
    class
HAVING
    COUNT(class) >= 5
```

## [595. 大的国家](https://leetcode.cn/problems/big-countries/description/)

```sql
SELECT
    name,
    population,
    area
FROM
    World
WHERE
    population >= 25000000
    OR
    area >= 3000000
```

## [586. 订单最多的客户](https://leetcode.cn/problems/customer-placing-the-largest-number-of-orders/description/)

```sql
SELECT
    customer_number
FROM
    Orders
GROUP BY
    customer_number
ORDER BY
    COUNT(customer_number) DESC
LIMIT 1
```

## [585. 2016年的投资](https://leetcode.cn/problems/investments-in-2016/description/)

### 思路1
- join两个Insurance表，连接方式为pid不同
- 通过where筛选出2015投资相等的行
- 再来一个子查询找出所有location只出现一次的id
- 通过where筛选出满足条件的id
### sql

```sql
SELECT
    ROUND(SUM(T.tiv_2016), 2) as tiv_2016
FROM
(
    SELECT
        MAX(I1.tiv_2016) as tiv_2016
    FROM
        Insurance I1
        LEFT JOIN
        Insurance I2
        ON I1.pid != I2.pid
    WHERE 
        I1.pid IN
        (
            SELECT
                pid
            FROM
                Insurance
            GROUP BY
                lat, lon
            HAVING
                COUNT(*) = 1
        )
        AND
            I1.tiv_2015 = I2.tiv_2015
    GROUP BY
        I1.pid
) T
```
### 错误分析
- ON和 WHERE的条件可以互换吗？
```sql
SELECT
    ROUND(SUM(T.tiv_2016), 2) as tiv_2016
FROM
(
    SELECT
        I1.pid,
        MAX(I1.tiv_2016) as tiv_2016
    FROM
        Insurance I1
        LEFT JOIN
        Insurance I2
        ON I1.pid != I2.pid AND
        I1.tiv_2015 = I2.tiv_2015 AND 
        I1.pid IN
        (
            SELECT
                pid
            FROM
                Insurance
            GROUP BY
                lat, lon
            HAVING
                COUNT(*) = 1
        )
    GROUP BY
        I1.pid
) T
```
发现上面的结果不对，原因是使用了LEFT JOIN, 导致On后的条件没有满足，但是左侧都被保留了下来，需要改成内连接

```sql
SELECT
    ROUND(SUM(T.tiv_2016), 2) as tiv_2016
FROM
(
    SELECT
        I1.pid,
        MAX(I1.tiv_2016) as tiv_2016
    FROM
        Insurance I1
        JOIN
        Insurance I2
        ON I1.pid != I2.pid AND
        I1.tiv_2015 = I2.tiv_2015 AND 
        I1.pid IN
        (
            SELECT
                pid
            FROM
                Insurance
            GROUP BY
                lat, lon
            HAVING
                COUNT(*) = 1
        )
    GROUP BY
        I1.pid
) T
```
### 思路2
- count() + over(parition by)
  - count计算个数
  - partition by指定计算时的聚合方法
### sql
```sql
SELECT
    ROUND(SUM(T.tiv_2016), 2) as tiv_2016
FROM
(
    SELECT
        tiv_2016,
        COUNT(1) OVER(PARTITION BY tiv_2015) AS tiv_2015_cnt,
        COUNT(1) OVER(PARTITION BY lat, lon) AS pos_cnt
    FROM
        Insurance
) T
WHERE 
    T.tiv_2015_cnt > 1
    AND
    T.pos_cnt = 1
```

## [602. 好友申请 II ：谁有最多的好友](https://leetcode.cn/problems/friend-requests-ii-who-has-the-most-friends/description/)

### 思路1
- a向b申请好友，通过后，a-b都互为好友
- 所以需要把requester和accepter互换后，使用UNION ALL连接
- 然后group by + count()

```sql
SELECT
    id,
    COUNT(friend_id) AS num
FROM
(
    SELECT
        accepter_id AS id,
        requester_id AS friend_id
    FROM
        RequestAccepted
UNION ALL
    SELECT
        requester_id AS id,
        accepter_id AS friend_id
    FROM
        RequestAccepted
) T
GROUP BY
    id
ORDER BY
    COUNT(friend_id) DESC
LIMIT 1
```

### 思路2
- 题目的意思是不存在重复添加好友的情况，比如a加b，a删b，b加回a等情况
- 所以可以直接在子查询中计数，然后在外面求和，可以快一点

```sql
SELECT
    id,
    SUM(num) AS num
FROM
(
    SELECT
        accepter_id AS id,
        COUNT(requester_id) AS num
    FROM
        RequestAccepted
    GROUP BY
        accepter_id
UNION ALL
    SELECT
        requester_id AS id,
        COUNT(accepter_id) AS num
    FROM
        RequestAccepted
    GROUP BY
        requester_id
) T
GROUP BY
    id
ORDER BY
    SUM(num) DESC
LIMIT 1
```

## [1661. 每台机器的进程平均运行时间](https://leetcode.cn/problems/average-time-of-process-per-machine/description/)

```sql
SELECT
    A1.machine_id,
    ROUND(AVG(A2.timestamp - A1.timestamp), 3) AS processing_time
FROM
    Activity A1
    JOIN
    Activity A2
    ON 
        A1.machine_id = A2.machine_id AND
        A1.process_id = A2.process_id AND
        A1.activity_type = 'start' AND
        A2.activity_type = 'end'
GROUP BY
    A1.machine_id
```