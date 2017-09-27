create database grandesystem;

use grandesystem;

create table student
(
	sid INT(10) PRIMARY KEY identity(1,1),
	sname CHAR(20),
	gender ENUM('male','female')
);
create table course
(
	cid INT(10) PRIMARY KEY identity(1,1),
	cname CHAR(20)
);
create table mark
(
	mid INT(10) PRIMARY KEY identity(1,1),
	sid INT(10),
	cid INT(10),
	score INT(10),
	CONSTRAINT sid FOREIGN KEY (sid) REFERENCES student (sid),
	CONSTRAINT cid FOREIGN KEY (cid) REFERENCES course (cid)
);

INSERT INTO student 
(sid,sname,gender)
VALUES
(1,'Tom','male'),
(2,'Jack','male'),
(3,'Rose','female');

INSERT INTO course
(cid,cname)
VALUES
(1,'math'),
(2,'physics'),
(3,'chemistry');

INSERT INTO mark 
(mid,sid,cid,score)
VALUES
(1,1,1,80),
(2,2,1,85),
(3,3,1,90),
(4,1,2,60),
(5,2,2,90),
(6,3,2,75),
(7,1,3,95),
(8,2,3,75),
(9,3,3,85);

