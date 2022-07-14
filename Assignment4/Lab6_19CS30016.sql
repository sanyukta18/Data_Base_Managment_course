-- Sanyukta Deogade
-- 19CS30016

CREATE TABLE Student
(
   roll_no int not null,
   name varchar(30) not null,
   cgpa decimal(7,2) not null ,
   credits_cleared int not null 
);
CREATE TABLE Student_course
(
   roll_no int not null,
   course_cd char(2) not null,
   grade_point int not null
);
CREATE TABLE Course
(
   course_cd char(2) not null,
   course_name varchar(30) not null,
   credits int not null
);
CREATE TABLE Preqrequisite
(
   course_cd char(2) not null,
   prereq_course_cd char(2) not null
);


-- 1a)

DELIMITER $$

CREATE TRIGGER update_on_insert AFTER INSERT ON Student_course
FOR EACH ROW
BEGIN
	UPDATE Student,
	(SELECT sum(credits) as creditupdate
	FROM Course,Student_course 
	WHERE Student_course.course_cd = Course.course_cd
	AND Student_course.roll_no = NEW.roll_no
    AND Student_course.grade_point >= 5) AS total
	set credits_cleared = creditupdate
	where Student.roll_no=NEW.roll_no;
END

$$
DELIMITER ;

-- 1b) trial is database used in my laptop

DELIMITER $$
USE `trial`$$
CREATE DEFINER=`root`@`localhost` TRIGGER `course_AFTER_UPDATE` AFTER UPDATE ON `course` FOR EACH ROW BEGIN
	UPDATE trial.student,
	(SELECT sum(c.credits) as credit
	FROM trial.course as c, trial.`student_course` as sc
	WHERE c.course_cd=NEW.course_cd
	AND sc.course_cd = c.course_cd)AS tot_credit
	set trial.student.credits_cleared = tot_credit.credit
	where trial.student.roll_no=sc.roll_no;
END

$$
DELIMITER ;

-- Q2

DELIMITER $$

create procedure update_cgpa (in roll_no int, out new_cgpa decimal(7,2))
    BEGIN
            SELECT
            new_cgpa_1 INTO new_cgpa
            FROM
        		(
            	SELECT total_points/(1.0*(total_credits)) as new_cgpa_1
            	FROM
       	 		(
            		SELECT sum(C.credits*SC.grade_point) as total_points, sum(C.credits) as total_credits
            		FROM Course C, Student_course SC
            		WHERE update_cgpa.roll_no=SC.roll_no and SC.course_cd=C.course_cd
            	) as t
            ) as t1 ;
        UPDATE Student
        SET Student.cgpa=new_cgpa
        WHERE Student.roll_no=update_cgpa.roll_no ;
    END

$$
DELIMITER ;

-- Q3
DELIMITER $$

WITH RECURSIVE credits_complete(course_cd) AS
(
SELECT course_cd
FROM Course
UNION
SELECT prereq_course_cd
FROM Preqrequisite
WHERE Preqrequisite.prereq_course_cd = Course.course_cd
)
SELECT credits AS total_credits
FROM Course
WHERE Course.course_cd='AB'
AND Course.course_cd = Preqrequisite.prereq_course_cd
;

$$
DELIMITER ;

