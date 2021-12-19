/*
  Put all table create statements in this file as well as any UDFs or stored
  procedures.

  NOTE: This file must be able to run repetitively without any errors
*/
show tables;
CREATE DATABASE IF NOT EXISTS cs_hu_310_final_project; 
USE cs_hu_310_final_project; 
DROP TABLE IF EXISTS class_registrations; 
DROP TABLE IF EXISTS grades; 
DROP TABLE IF EXISTS class_sections; 
DROP TABLE IF EXISTS instructors; 
DROP TABLE IF EXISTS academic_titles; 
DROP TABLE IF EXISTS students; 
DROP TABLE IF EXISTS classes; 
DROP FUNCTION IF EXISTS convert_to_grade_point; 
DROP FUNCTION IF EXISTS convert_grade_point_to_letter_grade;
 
CREATE TABLE IF NOT EXISTS classes( 
    class_id INT AUTO_INCREMENT, 
    name VARCHAR(50) NOT NULL, 
    description VARCHAR(1000), 
    code VARCHAR(10) UNIQUE, 
    maximum_students INT DEFAULT 10, 
    PRIMARY KEY(class_id) 
); 
DESCRIBE classes;
 
CREATE TABLE IF NOT EXISTS students( 
    student_id INT AUTO_INCREMENT, 
    first_name VARCHAR(30) NOT NULL, 
    last_name VARCHAR(50) NOT NULL, 
    birthdate DATE, 
    PRIMARY KEY (student_id) 
); 
DESCRIBE students;
 
CREATE TABLE IF NOT EXISTS academic_titles(
    academic_title_id INT AUTO_INCREMENT NOT NULL, 
    title VARCHAR(255) NOT NULL, 
    PRIMARY KEY (academic_title_id)
);
describe academic_titles;

CREATE TABLE IF NOT EXISTS instructors(
	instructor_id INT AUTO_INCREMENT NOT NULL,
	first_name VARCHAR(80) NOT NULL, 
	last_name VARCHAR(80) NOT NULL, 
    academic_title_id INT,
    FOREIGN KEY (academic_title_id) REFERENCES academic_titles(academic_title_id),
    PRIMARY KEY (instructor_id)
);
describe instructors;

CREATE TABLE IF NOT EXISTS terms(
    term_id INT AUTO_INCREMENT NOT NULL, 
    name VARCHAR(80) NOT NULL, 
    PRIMARY KEY (term_id)
);
describe terms;

CREATE TABLE IF NOT EXISTS class_sections(
	class_section_id INT AUTO_INCREMENT NOT NULL, 
    class_id INT NOT NULL, 
    FOREIGN KEY (class_id) references classes(class_id),
    instructor_id INT NOT NULL, 
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id),
    term_id INT NOT NULL,
    FOREIGN KEY (term_id) REFERENCES terms(term_id),
    PRIMARY KEY (class_section_id)
);
describe class_sections;

CREATE TABLE IF NOT EXISTS grades(
    grade_id INT AUTO_INCREMENT NOT NULL, 
    letter_grade CHAR(2) NOT NULL, 
    PRIMARY KEY (grade_id)
);
describe grades;

CREATE TABLE IF NOT EXISTS class_registrations(
    class_registration_id INT AUTO_INCREMENT NOT NULL, 
    class_section_id INT NOT NULL,
    FOREIGN KEY (class_section_id) REFERENCES class_sections(class_section_id), 
    student_id INT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    grade_id INT,
    FOREIGN KEY (grade_id) REFERENCES grades(grade_id),
    signup_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (class_registration_id)
);
describe class_registrations;

ALTER TABLE class_registrations 
ADD CONSTRAINT UC_student UNIQUE (class_section_id, student_id);


DELIMITER $$
CREATE FUNCTION convert_to_grade_point(letter_grade char(2))
	RETURNS INT 
    DETERMINISTIC
BEGIN
	DECLARE grade_point int;
    
    IF letter_grade like 'A' THEN
		SET grade_point = 4;
	ELSEIF letter_grade like 'B' THEN
		SET grade_point = 3;
	ELSEIF letter_grade like 'C' THEN 
		set grade_point = 2;
	ELSEIF letter_grade like 'D' THEN 
		SET grade_point = 1;
	ELSEIF letter_grade like 'F' THEN 
		SET grade_point = 0;
	ELSE 
		SET grade_point = NULL;
	END IF;
    RETURN grade_point;
END $$

CREATE FUNCTION convert_grade_point_to_letter_grade(grade_point INT)
	RETURNS INT 
    DETERMINISTIC
BEGIN
    DECLARE letter_grade char(2);

    IF grade_point=4 THEN   
        SET letter_grade = 'A';
    ELSEIF grade_point=3 THEN  
        SET letter_grade = 'B';
    ELSEIF grade_point=2 THEN  
        SET letter_grade = 'C';
    ELSEIF grade_point=1 THEN  
        SET letter_grade = 'D';
    ELSEIF grade_point=0 THEN  
        SET letter_grade = 'F';
    ELSE 
        SET letter_grade = NULL;
    END IF;
    RETURN letter_grade;
END $$
