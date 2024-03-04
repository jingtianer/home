---
title: LeetCode-数据库-1
date: 2024-3-3 11:14:34
tags: 
    - LeetCode
    - 数据库
categories: 
    - LeetCode
    - 数据库
toc: true
language: zh-CN
---

## [181. 超过经理收入的员工](https://leetcode.cn/problems/employees-earning-more-than-their-managers/description/)
### 思路
- `Employee`表中给出员工id，员工的manager的id
- 按照managerid和员工id自连接一下，使用内连接去掉null
- 筛选员工工资大于管理员工资的
### 知识点
- 判断相等用单引号
### 代码
```sql
SELECT E1.name AS Employee
FROM Employee E1 
INNER JOIN Employee E2 
ON E1.managerId = E2.id 
AND E1.salary > E2.salary
```

## [182. 查找重复的电子邮箱](https://leetcode.cn/problems/duplicate-emails/description/)

### 知识点
- group by 根据元组进行分组
- having 根据条件将聚合后的分组进行筛选（可否理解为对分组整体的where语句？）


### 代码
```c++
SELECT Email
FROM Person
GROUP BY email
HAVING count(email) > 1;
```

## [183. 从不订购的客户](https://leetcode.cn/problems/customers-who-never-order/description/)

### 思路
- 一个顾客表，一个订单表
- 顾客表和订单表左连接，按照顾客id连接
- 没有订单的顾客通过左连接会产生null，用where找出含有null的行

### 知识点
- 左连接，右边存在null依然保留左边，左边有null就不保留
- 右连接，右边存在null不保留左边，右边有null就不保留
- 内连接，不论左右，有null就不保留

### 代码
```sql
SELECT name AS Customers
FROM Customers LEFT JOIN Orders O ON O.customerId = Customers.id 
WHERE O.customerId IS NULL;
```

## [196. 删除重复的电子邮箱](https://leetcode.cn/problems/delete-duplicate-emails/description/)

### 思路
- 对于有重复的email，保留id最小的一项，删除剩余的重复项
- 依照email进行group by
- 使用min找到每个email的最小值
- 将上面的结果作为子查询，若id不在其中，则删除
- 不允许删除表时对表作查询，需要再嵌套一层子查询

### 知识点
- 子查询必须指定别名`紧跟在子查询的括号后面`
- 一般来说，`DELETE FROM XXX WHERE <-condition->`
### 代码
```sql
DELETE FROM Person
WHERE 
id NOT IN (SELECT T.id FROM (SELECT MIN(id) as id FROM Person GROUP BY email) T);

-- 不允许删除与查询在同一个表上
DELETE FROM Person
WHERE 
id NOT IN (SELECT MIN(id) as id FROM Person GROUP BY email);
```

## [197. 上升的温度](https://leetcode.cn/problems/rising-temperature/description/)

### 思路
- 如果第二天温度比第一天高，就输出
- 同一张表自连接，筛选出日期相差一天且温度升高的
### 知识点
```sql
FROM A, B, C, ... WHERE <-condition->
```
相当于对所有表全连接，然后根据WHERE筛选

```sql
FROM A XXX JOIN B ON <-condition1-> XXX JOIN C ON <-condition2-> ...
```
相当依次连接各个表，且可以控制连接的方式（左、右、全），并根据条件筛选

- timestampdiff(expr, date1, date2)
  - 根据expr计算两个date的差值
  - 如果expr是day，就是算差距多少天

### 代码
```sql
SELECT W2.id
FROM Weather W1 JOIN  Weather W2
ON timestampdiff(day, W2.recordDate, W1.recordDate) = -1
AND W2.temperature > W1.temperature;
```

```sql
SELECT W2.id
FROM Weather W1, Weather W2
WHERE timestampdiff(day, W2.recordDate, W1.recordDate) = -1
AND W2.temperature > W1.temperature;
```

## [511. 游戏玩法分析 I](https://leetcode.cn/problems/game-play-analysis-i/description/)

### 思路
- 找到每个用户第一次登录的时间
- group by用户id，然后通过min计算最小日期

### 代码

```sql
SELECT player_id, min(event_date) AS first_login
FROM Activity
GROUP BY player_id
```

## [550. 游戏玩法分析 IV](https://leetcode.cn/problems/game-play-analysis-iv/description/)

### 思路
- 判断有多少用户在第一次登录后的第二天也登录游戏了
- 创建子查询查找每个用户的第一次登录时间
- 子查询与用户登录时间表左连接，按照用户id
- 找到登录日期与第一次登录时间相差1天的行，如果第二天登陆了，则登录时间非空，否则登录时间为空
- 统计登录时间为空的个数，除以总用户个数

### 知识点

- ADDDATE(date, expr)
  - 根据expr在date的基础上相加
  - expr = `INTERVAL 1 DAY`表示在date的基础上加一天
- ROUND(number, n)
  - number精确到小数点后n位

### 代码

```sql
SELECT ROUND(count(event_date)/count(First_Login.player_id), 2) AS fraction
FROM (
    SELECT player_id, min(event_date) AS first_login
    FROM Activity
    GROUP BY player_id) First_Login 
LEFT JOIN Activity
ON First_Login.player_id = Activity.player_id
AND ADDDATE(First_Login.first_login, INTERVAL 1 DAY) = Activity.event_date
```

## [180. 连续出现的数字](https://leetcode.cn/problems/consecutive-numbers/description/)

### 思路
- 表格自连接三次，筛选出id递增且num一样的
### 代码

```sql
SELECT DISTINCT L3.num AS ConsecutiveNums 
FROM
    Logs L1,
    Logs L2,
    Logs L3
WHERE 
    L1.id = L2.id-1 AND
    L1.num = L2.num AND
    L2.id = L3.id-1 AND
    L2.num = L3.num
```

## [178. 分数排名](https://leetcode.cn/problems/rank-scores/description/)
- 对分数进行排序，并给出排名，同分同排

### 思路1+知识点

- `row_number()` + `over(ORDER BY column_name [desc])`函数可以按照列排序，并给出行号
- 但行号不能实现同分同排
- 按照分数GROUP BY，然后`row_number` + `over`计算出每个分数对应的排序
- 将上面的内容作为子查询，与成绩表相连接，就可以得到同分同排名了

### 代码

```sql
SELECT T.score, T.rank FROM (
    SELECT score, (row_number() over(ORDER BY score DESC)) AS 'rank'
    FROM Scores 
    GROUP BY score 
    ORDER BY score DESC
) T INNER JOIN Scores on T.score = Scores.score
ORDER BY score DESC
```

### 思路2+知识点

- `dense_rank()` + `over()` 可以给出同分同排名

```sql
SELECT score, dense_rank() over(ORDER BY score DESC) AS 'rank'
FROM Scores
ORDER BY score DESC
```

## [184. 部门工资最高的员工](https://leetcode.cn/problems/department-highest-salary/description/)

### 思路1
- 子查询，通过group by找出每个部门最大salary
- 与员工表连接，筛选出部门id相同，薪资与部门最高薪资相同的行

```sql
SELECT T.Department, E.name AS Employee, T.Salary
FROM Employee E INNER JOIN (
    SELECT D.id as DID, D.name AS Department, E.name AS Employee, MAX(E.salary) AS Salary
    FROM Employee E JOIN Department D ON E.departmentId = D.id
    GROUP BY E.departmentId
) T 
ON T.Salary = E.salary 
AND T.DID = E.departmentId;
```

### 思路2

- 子查询，通过group by找出每个部门最大salary
- 员工表啊与部门表合并，若(员工薪水, 部门id)存在于子查询中，则筛选出来

```sql
SELECT
    Department.name AS 'Department',
    Employee.name AS 'Employee',
    Salary
FROM
    Employee
        JOIN
    Department ON Employee.DepartmentId = Department.Id
WHERE
    (Employee.DepartmentId , Salary) IN
    (   SELECT
            DepartmentId, MAX(Salary)
        FROM
            Employee
        GROUP BY DepartmentId
	)
```


## [176. 第二高的薪水](https://leetcode.cn/problems/second-highest-salary/description/)
### 思路1 + 知识点
- IFNULL(a, b) 如果a是NULL则值替换为b
- LIMIT N，只选出前N个（最多N个）
- LIMIT M OFFSET M，从第M个开始选出N个（最多N个）
- LIMIT 1 OFFSET 1则表示第二个，如果没有第二个，返回空列表

- 子查询根据salary排序，使用`LIMIT 1 OFFSET 1`找出第二个
- 如果没有第二个需要返回NULL，则根据
- 题目需要返回列表为指定名称，通过`AS 别名`可以为列取别名
```sql
SELECT IFNULL(
    (SELECT DISTINCT salary FROM Employee ORDER BY salary DESC
LIMIT 1 OFFSET 1)
, NULL) AS SecondHighestSalary 
```

### 思路2 + 知识点
- 子查询通过max找到最大的
- 同where筛选所有小于max的
- 对所有小于max的行，再次使用max，获得第二大的
```sql
SELECT MAX(salary) AS SecondHighestSalary FROM Employee
WHERE salary < (SELECT MAX(salary) FROM Employee)
```

## [177. 第N高的薪水](https://leetcode.cn/problems/nth-highest-salary/description/)
- 这道题需要我们实现一个函数，参数是N
- 与上一题一样，通过`LIMIT 1 OFFSET M`
- OFFSET后面不能跟表达式
  - 需要声明一个新变量M`DECLARE M INT; `
  - 并置值为N-1`SET M = N-1;`
  - 通过return语句返回
```sql
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
DECLARE M INT; 
    SET M = N-1; 
  RETURN (
      SELECT IFNULL((SELECT DISTINCT salary FROM Employee ORDER BY salary DESC LIMIT 1 OFFSET M), NULL)
  );
END
```

## [185. 部门工资前三高的所有员工](https://leetcode.cn/problems/department-top-three-salaries/description/)

### 知识点
- count(column_name): 计算列中非null的个数
- count(distinct column_name): 计算列中非null的互不相同的个数
- count(*): 统计总行数，包括NULL和重复的
- count(1), count(2), ...
  - 根据第1列、第二列、、、
  - 记录总数，包括重复和NULL
- having count(xxx) > 0
  - 相当于将值为NULL的筛选出去，如果整个分组空了，就移除整个分组
- having count(xxx) <= N
  - 相当于将组内多与N个的行删除

> ?: having相当于，若组满足条件，则整组留下，若不满足，则去掉不满足的行，直到组满足为止

### 思路
- 找出各部门前三高的不同工资
- 通过having筛选

### 代码
```sql
SELECT D.name AS Department, E.name AS Employee, E.salary AS Salary
FROM Employee E, Department AS D, Employee E2
WHERE D.id = E.departmentId AND E2.departmentId = E.departmentId AND E.salary <= E2.salary
group by D.ID,E.Name having count(distinct E2.Salary) <= 3
order by D.Name, E.Salary desc
```

## [262. 行程和用户](https://leetcode.cn/problems/trips-and-users/description/)
### 知识点
```sql
count(CASE WHEN condition THEN A ELSE B END)
```
- 根据条件，若某一行满足条件，则该行统计是，按照值A，否则按照值B
- 统计非NULL的个数，所以一般A和B中一个为NULL一个为非NULL
### 思路
- 先将路程表，用户表根据司机id，乘客id和用户id进行连接，排除被禁用户的订单，排除掉时间在`2023-10-01`到`2013-10-03`之外的订单
- 使用`count(status)`筛选出分母
- 使用`count(case when then else end)`筛选出分子

### 代码

```sql
SELECT 
    T.request_at AS Day, 
    ROUND(sum(CASE WHEN T.status = 'completed' THEN 0 ELSE 1 END) / count(T.status), 2) AS 'Cancellation Rate'
FROM Trips T LEFT JOIN Users U1
ON T.client_id = U1.users_id
LEFT JOIN Users U2
ON T.driver_id = U2.users_id
WHERE U1.banned = 'No' AND U2.banned = 'No'
AND T.request_at 
BETWEEN DATE("2013-10-01") AND DATE("2013-10-03")
GROUP BY T.request_at
```

## SQL性能优化

- [神奇的 SQL 之性能优化 → 让 SQL 飞起来](https://www.cnblogs.com/youzhibing/p/11909821.html)

### 用`EXISTS`代替`IN`
- 使用`IN`会产生一张临时表（内联视图），且在匹配时会扫描全表
- 使用`IN`不会产生临时表，在匹配时不会扫描全表，满足条件则停止

### 用连接替代IN
- 在有索引时，连接与`EXISTS`性能相近
- 没有索引，`EXISTS`更好

### 避免排序
- 很多关键字都存在排序的过程
  - ORDER BY
  - GROUP BY
  - DISTINCT
  - 聚合函数(MIN,MAX,SUM,AVG,COUNT)
  - 集合函数(UNION,INTERSECT,EXCEPT)
    - 为了去重而排序
    - 使用(UNION ALL,INTERSECT ALL,EXCEPT ALL)不去重
  - 窗口函数(row_number, rank等)

#### 使用 `EXISTS` 代替 `DISTINCT`

#### 能写在`where`中的条件不要写在`having`里

#### 在极值函数中使用索引
- min，max会全表扫描+排序
- 对需要求min,max的列创建索引，加快查找速度
#### 在 `GROUP BY` 子句和 `ORDER BY` 子句中使用索引

### 使用索引

- [神奇的 SQL 之擦肩而过 → 真的用到索引了吗](https://www.cnblogs.com/youzhibing/p/14175374.html)

### 减少临时表
- 临时表会消耗内存资源
- 临时表有时无法继承索引，导致效率低下

#### 尽量使用`having`而不是临时表

#### 需要对多个字段使用`IN`谓词时，将它们汇总到一处

```sql
select A
from tableA A1
where col1 in (
  select col1 
  from tableA A2
  where A1.xxx = A2.xxx
) and col2 in (
  select col2 
  from tableA A2
  where A1.xxx = A2.xxx
) and col3 in (
  select col2 
  from tableA A2
  where A1.xxx = A2.xxx
)
-- 可以优化为
select A
from tableA A1
where col1 || col2 || col3
in (
  select col1 || col2 || col3
  from tableA A2
)
-- or
select A
from tableA A1
where (col1, col2, col3)
in (
  select col1, col2, col3
  from tableA A2
)
```

#### 先进行连接再进行聚合

#### 定义视图时避免集合函数和聚合函数