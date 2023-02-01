-- 1、查询课程编号为“01”的课程比“02”的课程成绩高的所有学生的学号（难）
SELECT st.s_id, st.s_name, a.s_score AS score1, b.s_score AS score2
FROM student st
LEFT JOIN (SELECT * FROM score WHERE c_id = '01') AS a ON st.s_id = a.s_id
LEFT JOIN (SELECT * FROM score WHERE c_id = '02') AS b ON st.s_id = b.s_id
WHERE a.s_score > b.s_score;

-- 2、查询平均成绩大于60分的学生的学号和平均成绩
SELECT s_id, round(avg(s_score) , 2) AS avg_score
FROM score
GROUP BY s_id
HAVING avg(s_score) > 60;

-- 3、查询所有学生的学号、姓名、选课数、总成绩
SELECT st.s_id, st.s_name,
       count(s.c_id), sum(s.s_score)
FROM student st LEFT JOIN score s ON s.s_id = st.s_id
GROUP BY st.s_id, st.s_name;

-- 4、查询姓“猴”的老师的个数
SELECT count(t_name)
FROM teacher
WHERE t_name LIKE '猴%';

-- 5、查询没学过“张三”老师课的学生的学号、姓名
SELECT s_id, s_name
FROM student
WHERE s_id NOT IN(
                    SELECT s.s_id
                    FROM score s
                    LEFT JOIN course c ON s.c_id = c.c_id
                    LEFT JOIN teacher t ON c.t_id = t.t_id
                    WHERE t.t_name = '张三');

-- 6、查询学过“张三”老师所教的所有课的同学的学号、姓名
SELECT s_id, s_name
FROM student
WHERE s_id IN(
                SELECT s.s_id
                FROM score s
                LEFT JOIN course c ON s.c_id = c.c_id
                LEFT JOIN teacher t ON c.t_id = t.t_id
                WHERE t.t_name = '张三');

-- 7、查询学过编号为“01”的课程并且也学过编号为“02”的课程的学生的学号、姓名
SELECT s_id, s_name
FROM student
WHERE s_id IN(
    SELECT a.s_id
    FROM
        (SELECT s_id, c_id FROM score WHERE c_id = '01') AS a
        INNER JOIN (SELECT s_id, c_id FROM score WHERE c_id = '02') AS b
        ON a.s_id = b.s_id
);

-- 8、查询课程编号为“02”的总成绩
SELECT sum(s_score)
FROM score
WHERE c_id = '02';

-- 9、查询所有课程成绩小于60分的学生的学号、姓名
SELECT s_id, s_name
FROM student
WHERE s_id IN(
    SELECT s_id
    FROM score
    GROUP BY s_id
    HAVING max(s_score) < 60
);

-- 10、查询没有学全所有课的学生的学号、姓名
SELECT st.s_id, st.s_name
FROM student st LEFT JOIN score s ON st.s_id = s.s_id
GROUP BY st.s_id, st.s_name
HAVING count(s.c_id) < (SELECT count(DISTINCT c_id) FROM course);

-- 11、查询至少有一门课与学号为“01”的学生所学课程相同的学生的学号和姓名 （难）
SELECT s_id, s_name
FROM student
WHERE s_id IN (
    SELECT DISTINCT s_id FROM score
    WHERE c_id IN (SELECT c_id FROM score WHERE s_id = '01')
        AND s_id != '01'
    );

-- 12、查询和“01”号同学所学课程完全相同的其他同学的学号（难）
SELECT s_id, s_name
FROM student
WHERE s_id IN (
    SELECT DISTINCT s_id
    FROM score
    WHERE c_id IN (SELECT c_id FROM score WHERE s_id = '01')
      AND s_id != '01'
    GROUP BY s_id
    HAVING count(c_id) = (SELECT count(c_id) FROM score WHERE s_id = '01'));

-- 13、查询没学过"张三"老师讲授的任一门课程的学生姓名 和47题一样
SELECT s_name
FROM student
WHERE s_id NOT IN (
    SELECT s.s_id
    FROM score s INNER JOIN course c on c.c_id = s.c_id
        INNER JOIN teacher t on c.t_id = t.t_id
    WHERE t.t_name = '张三'
    );

-- 15、查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
SELECT st.s_id, st.s_name, round(avg(s.s_score), 2)
FROM student st INNER JOIN score s ON st.s_id = s.s_id
WHERE s.s_score < 60
GROUP BY st.s_id, st.s_name
HAVING count(st.s_id) >= 2;

-- 16、检索"01"课程分数小于60，按分数降序排列的学生信息
SELECT st.s_id, st.s_name, s.s_score
FROM student st INNER JOIN score s ON st.s_id = s.s_id
WHERE s.c_id = '01' AND s.s_score < 60
ORDER BY s.s_score DESC ;

-- 17、按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩(难)
select s.s_id, st.s_name,
max(CASE WHEN s.c_id='01' THEN s_score END) score01,
max(CASE WHEN s.c_id='02' THEN s_score END) score02,
max(CASE WHEN s.c_id='03' THEN s_score END) score03,
avg(s.s_score) avg_score
FROM score s INNER JOIN student st
ON s.s_id = st.s_id
GROUP BY s.s_id, st.s_name
ORDER BY avg_score DESC;

-- [***]18、查询各科成绩最高分、最低分和平均分：以如下形式显示：课程ID，课程name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
SELECT s.c_id, c.c_name,
       max(s.s_score), min(s.s_score), round(avg(s.s_score), 2) AS "平均分",
       round(avg(CASE WHEN s.s_score < 60 THEN 1 ELSE 0 END), 2) AS "及格率",
       round(avg(CASE WHEN s.s_score >= 70 AND s.s_score < 80 THEN 1 ELSE 0 END), 2) AS "中等率",
       round(avg(CASE WHEN s.s_score >= 80 AND s.s_score < 90 THEN 1 ELSE 0 END), 2) AS "优良率",
       round(avg(CASE WHEN s.s_score >= 90 THEN 1 ELSE 0 END), 2) AS "优秀率"
FROM score s INNER JOIN course c ON c.c_id = s.c_id
GROUP BY s.c_id, c_name;

-- 19、按各科成绩进行排序，并显示排名(难)
SELECT s_id, c_id, s_score,
       rank() OVER (PARTITION BY c_id ORDER BY s_score DESC ) AS "rank"
FROM score
ORDER BY c_id;

-- 20、查询学生的总成绩并进行排名
SELECT st.s_id, sum(CASE WHEN s.s_score IS NULL THEN 0 ELSE s.s_score END),
       rank() OVER (ORDER BY sum(CASE WHEN s.s_score IS NULL THEN 0 ELSE s.s_score END) DESC)
FROM student st LEFT JOIN score s ON st.s_id = s.s_id
GROUP BY st.s_id;

-- 21、查询不同老师所教不同课程平均分从高到低显示
SELECT t.t_id, t_name, round(avg(s.s_score), 2)
FROM teacher t INNER JOIN course c ON t.t_id = c.t_id
    INNER JOIN score s ON c.c_id = s.c_id
GROUP BY t.t_id, t_name;

-- 22、查询所有课程的成绩第2名到第3名的学生信息及该课程成绩（重要 25类似）
SELECT * FROM(
    SELECT s.c_id, st.s_id, st.s_name, s.s_score,
       rank() OVER (PARTITION BY c_id ORDER BY s_score) AS rk
    FROM student st INNER JOIN score s ON st.s_id = s.s_id
             ) a
WHERE rk IN (2, 3);

-- 23、使用分段[100-85],[85-70],[70-60],[<60]来统计各科成绩，分别统计各分数段人数：课程ID和课程名称
SELECT c.c_id, c.c_name,
       sum(CASE WHEN s.s_score < 60 THEN 1 ELSE 0 END) AS "[<60]",
       sum(CASE WHEN s.s_score >= 60 AND s.s_score < 70 THEN 1 ELSE 0 END) AS "[60-70]",
       sum(CASE WHEN s.s_score >= 70 AND s.s_score < 85 THEN 1 ELSE 0 END) AS "[70-85]",
       sum(CASE WHEN s.s_score >= 85 THEN 1 ELSE 0 END) AS "[85-100]"
FROM score s INNER JOIN course c ON c.c_id = s.c_id
GROUP BY c.c_id, c_name;

-- 24、查询学生平均成绩及其名次
SELECT s_id, round(avg(s_score), 2),
       rank() OVER (ORDER BY avg(s_score) DESC)
FROM score
GROUP BY s_id;

-- 25、查询各科成绩前三名的记录（不考虑成绩并列情况）
SELECT * FROM(
    SELECT s.c_id, st.s_id, st.s_name, s.s_score,
       row_number() OVER (PARTITION BY c_id ORDER BY s_score) AS rk
    FROM student st INNER JOIN score s ON st.s_id = s.s_id
             ) a
WHERE rk IN (1, 2, 3);

-- 26、查询每门课程被选修的学生数
SELECT c_id, COUNT(s_id)
FROM score
GROUP BY c_id;

-- 27、查询出只有两门课程的全部学生的学号和姓名
SELECT s_id, s_name
FROM student
WHERE s_id IN (
    SELECT s_id
    FROM score
    GROUP BY s_id
    HAVING COUNT(c_id) = 2
    );

-- 28、查询男生、女生人数
SELECT SUM(CASE WHEN s_sex = '男' THEN 1 ELSE 0 END) AS "男生人数",
       SUM(CASE WHEN s_sex = '女' THEN 1 ELSE 0 END) AS "女生人数"
FROM student;

SELECT s_sex, COUNT(s_id)
FROM student
GROUP BY s_sex;

-- 29、查询名字中含有"风"字的学生信息
SELECT * FROM student
WHERE s_name LIKE '%风%';

-- 31、查询1990年出生的学生名单
SELECT * FROM student
WHERE EXTRACT(YEAR from TO_DATE(s_birth, 'yyyy-mm-dd')) = 1990;

-- 32、查询平均成绩大于等于85的所有学生的学号、姓名和平均成绩
SELECT st.s_id, st.s_name, ROUND(AVG(s.s_score), 2)
FROM student st INNER JOIN score s ON st.s_id = s.s_id
GROUP BY st.s_id, st.s_name
HAVING AVG(s.s_score) >= 85;

-- 33、查询每门课程的平均成绩，结果按平均成绩升序排序，平均成绩相同时，按课程号降序排列
SELECT c_id, AVG(s_score) AS avg
FROM score
GROUP BY c_id
ORDER BY avg, c_id DESC;

-- 34、查询课程名称为"数学"，且分数低于60的学生姓名和分数
SELECT st.s_name, s.s_score
FROM student st INNER JOIN score s ON st.s_id = s.s_id
    INNER JOIN course c ON c.c_id = s.c_id
WHERE c.c_name = '数学' AND s.s_score < 60;

-- 35、查询所有学生的课程及分数情况【长表转宽表】
SELECT st.s_name,
       MAX(CASE WHEN c.c_name = '语文' THEN s.s_score END) AS "语文",
       MAX(CASE WHEN c.c_name = '数学' THEN s.s_score END) AS "数学",
       MAX(CASE WHEN c.c_name = '英语' THEN s.s_score END) AS "英语"
FROM student st INNER JOIN score s ON st.s_id = s.s_id
    INNER JOIN course c ON c.c_id = s.c_id
GROUP BY st.s_name;

-- 36、查询任何一门课程成绩在70分以上的姓名、课程名称和分数
SELECT st.s_name, c.c_name, s.s_score
FROM student st INNER JOIN score s ON st.s_id = s.s_id
    INNER JOIN course c ON c.c_id = s.c_id
WHERE s.s_score >= 70;

-- 37、查询不及格的课程并按课程号从大到小排列
SELECT c.c_id, c.c_name, s.s_score
FROM student st INNER JOIN score s ON st.s_id = s.s_id
    INNER JOIN course c ON c.c_id = s.c_id
WHERE s.s_score < 60
ORDER BY c.c_id DESC;

-- 38、查询课程编号为03且课程成绩在80分以上的学生的学号和姓名
SELECT st.s_id, st.s_name, s.s_score
FROM student st INNER JOIN score s ON st.s_id = s.s_id
WHERE s.s_score >= 80 AND s.c_id = '03';

-- 39、求每门课程的学生人数
SELECT c_id, COUNT(s_id)
FROM score
GROUP BY c_id;

-- 40、查询选修“张三”老师所授课程的学生中成绩最高的学生姓名及其成绩
SELECT st.s_name, s.s_score
FROM student st INNER JOIN score s ON st.s_id = s.s_id
    INNER JOIN course c ON c.c_id = s.c_id
    INNER JOIN teacher t ON t.t_id = c.t_id
WHERE t.t_name = '张三'
ORDER BY s.s_score DESC
LIMIT 1;

-- 41、查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩 （难）
SELECT DISTINCT s1.s_id, s1.c_id, s1.s_score
FROM score s1 INNER JOIN score s2
ON s1.c_id != s2.c_id AND s1.s_id = s2.s_id AND s1.s_score = s2.s_score;

-- 42、查询每门功成绩最好的前两名
SELECT *
FROM(
    SELECT s_id, c_id, s_score,
       ROW_NUMBER() OVER (PARTITION BY c_id ORDER BY s_score DESC) AS rk
    FROM score
    ) tmp
WHERE rk IN (1, 2);

-- 43、统计每门课程的学生选修人数（超过5人的课程才统计）。要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
SELECT c_id, COUNT(s_id) as cnt
FROM score
GROUP BY c_id
HAVING COUNT(s_id) > 5
ORDER BY cnt DESC, c_id;

-- 44、检索至少选修两门课程的学生学号
SELECT s_id, COUNT(c_id) as cnt
FROM score
GROUP BY s_id
HAVING COUNT(c_id) >= 2;

-- 45、查询选修了全部课程的学生信息
SELECT *
FROM student
WHERE s_id IN (
    SELECT s_id
    FROM score
    GROUP BY s_id
    HAVING COUNT(c_id) = (SELECT COUNT(c_id) FROM course)
    );

-- 46、查询各学生的年龄
SELECT s_id, s_name,
       EXTRACT(YEAR from CURRENT_DATE)- EXTRACT(YEAR from TO_DATE(s_birth, 'yyyy-mm-dd')) AS age
FROM student;

-- 47、查询没学过“张三”老师讲授的任一门课程的学生姓名
SELECT s_id, s_name
FROM student
WHERE s_id NOT IN (
    SELECT s.s_id
    FROM score s INNER JOIN course c ON s.c_id = c.c_id
        INNER JOIN teacher t ON t.t_id = c.t_id
    WHERE t.t_name = '张三'
    );

-- 48、查询两门以上不及格课程的同学的学号及其平均成绩
SELECT s_id, ROUND(AVG(s_score), 2)
FROM score
WHERE s_id IN (
    SELECT s_id
    FROM score
    WHERE s_score < 60
    GROUP BY s_id
    HAVING COUNT(c_id) >= 2
    )
GROUP BY s_id;

-- 49、查询本月过生日的学生
SELECT *
FROM student
WHERE EXTRACT(MONTH from TO_DATE(s_birth, 'yyyy-mm-dd')) = EXTRACT(MONTH from CURRENT_DATE);

-- 50、查询下一个月过生日的学生
SELECT *
FROM student
WHERE EXTRACT(MONTH from TO_DATE(s_birth, 'yyyy-mm-dd')) = EXTRACT(MONTH from CURRENT_DATE) + 1;