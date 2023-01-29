CREATE DATABASE learning;

CREATE TABLE student(
s_id VARCHAR(20),
s_name VARCHAR(20) NOT NULL DEFAULT '',
s_birth VARCHAR(20) NOT NULL DEFAULT '',
s_sex VARCHAR(10) NOT NULL DEFAULT '',
PRIMARY KEY (s_id)
);

CREATE TABLE teacher(
t_id VARCHAR(20),
t_name VARCHAR(20) NOT NULL DEFAULT '',
PRIMARY KEY (t_id)
);

CREATE TABLE course(
c_id VARCHAR(20),
c_name VARCHAR(20) NOT NULL DEFAULT '',
t_id VARCHAR(20),
PRIMARY KEY (c_id),
FOREIGN KEY (t_id) REFERENCES teacher(t_id)
);

CREATE TABLE score(
s_id VARCHAR(20),
c_id VARCHAR(20),
s_score INT,
FOREIGN KEY (s_id) REFERENCES student(s_id),
FOREIGN KEY (c_id) REFERENCES course(c_id)
);