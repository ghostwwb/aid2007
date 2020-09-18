-- 把book表拆分成三个部分
--    图书信息
--    作者信息
--    出版社信息
--
--  作者 可以 编写图书   一对多
--  出版社 可以 出版图书  一对多
--  出版社 可以 签约作者  多对多
--
--可以先话 E-R 模型
create table 作家(
id int primary key auto_increment,
name varchar(30),
sex char,
remark text
);


create table 出版社(
id int primary key auto_increment,
pname varchar(30),
address varchar(128),
tel char(16)
);

create table 图书(
id int primary key auto_increment,
bname varchar(30),
price float,
publish_time date,
aid int,
pid int,
foreign key (aid) references 作家(id),
foreign key (pid) references 出版社(id)
);

create table author_publish(
id int primary key auto_increment,
author_id int,
publish_id int,
foreign key (author_id) references 作家(id),
foreign key (publish_id) references 出版社(id),
签约时间 date
);

多表链接查询 :

select b.bname,a.name,p.pname
from
图书 as b left join 作家 as a on b.aid = a.id
left join 出版社 as p on b.pid = p.id;

--查找练习
1. 查询每位老师教授的课程数量
select tname,count(teacher_id)
from teacher left join course
on teacher.tid = course.teacher_id
group by tname;

2. 查询学生的信息及学生所在班级信息
select stu.sid,stu.sname,stu.gender,cls.caption
from student as stu left join class as cls
on stu.class_id = cls.cid;

3. 查询各科成绩最高和最低的分数,
形式 : 课程ID 课程名称 最高分  最低分
select cid as 课程ID,cname as 课程名称,
max(number) as  最高分,min(number) as 最低分
from course left join score
on course.cid = score.course_id
group by cid,cname;

4. 查询平均成绩大于85分的所有学生学号,姓名和平均成绩
select student.sid,sname,avg(number)
from student left join score
on student.sid = score.student_id
group by student.sid,sname
having avg(number) > 85;

5. 查询课程编号为2且课程成绩在80以上的学生学号和姓名
select student.sid,sname,number
from student left join score
on student.sid = score.student_id
where course_id = 2 and number>80;

6. 查询各个课程及相应的选修人数
select cname,count(course_id)
from course left join score
on course.cid = score.course_id
group by cname;


--函数和存储过程
delimiter $$

create function st() returns int
begin
    return (select score from cls order by score desc limit 1);
end $$

delimiter ;

-- 函数不负责展示数据，所以不能直接写select ，写操作可以
create function st1() returns int
begin
    update cls set score=100 where name="Emma";
    return 1;
end $$

--局部变量定义 (局部变量不要与查询的字段名重名)
-- 两种变量赋值方法
create function st2() returns int
begin
    declare max_score int;
    declare min_score int;
    set max_score=(select score from cls
    order by score desc limit 1);
    select score from cls
    order by score limit 1 into min_score;
    return max_score - min_score;
end $$

--含有参数的函数
delimiter $$
create function queryNameById(uid int)
returns varchar(20)
begin
return  (select name from cls where id=uid);
end $$

delimiter ;


--存储过程
delimiter $$

create procedure st1()
begin
    select name,age from cls;
    select name,score from cls order by score desc;
end $$

delimiter ;


--存储过程形参
create procedure st2(inout a int):
begin
   set a=888
end

set @a=10;

create procedure p_inout ( inout num int )
begin
    select num;
    set num=100;
    select num;
end $$


















