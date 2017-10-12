create database gradesystem;

use gradesystem;

create table student
(
	sid INT(10) auto_increment,
	sname CHAR(20),
	gender ENUM('male','female'),
	CONSTRAINT sid PRIMARY KEY (sid)
);
create table course
(
	cid INT(10) auto_increment,
	cname CHAR(20),
	CONSTRAINT cid PRIMARY KEY (cid)
);
create table mark
(
	mid INT(10) auto_increment,
	sid INT(10),
	cid INT(10),
	score INT(10),
	CONSTRAINT mid PRIMARY KEY (mid),
	CONSTRAINT sid FOREIGN KEY (sid) REFERENCES student (sid),
	CONSTRAINT cid FOREIGN KEY (cid) REFERENCES course (cid)
);

INSERT INTO student 
(sname,gender)
VALUES
('Tom','male'),
('Jack','male'),
('Rose','female');

INSERT INTO course
(cname)
VALUES
('math'),
('physics'),
('chemistry');

INSERT INTO mark 
(sid,cid,score)
VALUES
(1,1,80),
(2,1,85),
(3,1,90),
(1,2,60),
(2,2,90),
(3,2,75),
(1,3,95),
(2,3,75),
(3,3,85);

