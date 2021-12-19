/* Put your final project reporting queries here */
USE cs_hu_310_final_project;

-- Calculate the GPA for student given a student_id (using student_id = 1)
SELECT students.first_name,
       students.last_name,
       COUNT(class_registrations.student_id) as number_of_classes,
       SUM(convert_to_grade_point(grades.letter_grade)) as total_grade_points_earned,
       AVG(convert_to_grade_point(grades.letter_grade)) as GPA
FROM class_registrations
JOIN students ON class_registrations.student_id = students.student_id
JOIN grades ON grades.grade_id = class_registrations.grade_id
WHERE class_registrations.student_id = '1'
GROUP BY class_registrations.student_id;

-- Calculate the GPA for each student (across all classes and all terms) 
SELECT students.first_name,
       students.last_name,
       COUNT(class_registrations.student_id) as number_of_classes,
       SUM(convert_to_grade_point(grades.letter_grade)) as total_grade_points_earned,
       AVG(convert_to_grade_point(grades.letter_grade)) as GPA
FROM class_registrations
JOIN students ON class_registrations.student_id = students.student_id
JOIN grades ON grades.grade_id = class_registrations.grade_id
GROUP BY class_registrations.student_id;

-- Calculate the avg GPA for each class 
SELECT code, name,
       COUNT(class_registrations.grade_id) AS number_of_grades, 
       SUM(convert_to_grade_point(grades.letter_grade)) AS total_grade_points,
       AVG(convert_to_grade_point(grades.letter_grade)) AS GPA
FROM classes
JOIN class_sections ON class_sections.class_id = classes.class_id
JOIN class_registrations ON class_sections.class_section_id = class_registrations.class_section_id
JOIN grades ON grades.grade_id = class_registrations.grade_id
GROUP BY classes.class_id;

-- Calculate the avg GPA for each class and term
SELECT classes.code, classes.name, terms.name as term,
       COUNT(class_registrations.grade_id) AS number_of_grades, 
       SUM(convert_to_grade_point(grades.letter_grade)) AS total_grade_points,
       AVG(convert_to_grade_point(grades.letter_grade)) AS GPA
FROM classes
JOIN class_sections ON class_sections.class_id = classes.class_id
LEFT JOIN class_registrations ON class_sections.class_section_id = class_registrations.class_section_id
LEFT JOIN grades ON grades.grade_id = class_registrations.grade_id
JOIN terms ON terms.term_id = class_sections.term_id
GROUP BY class_sections.term_id, class_sections.class_section_id;


-- List all the classes being taught by an instructor
SELECT instructors.first_name, instructors.last_name, academic_titles.title,
       classes.code, classes.name as class_name, terms.name as term
FROM class_sections
JOIN classes ON class_sections.class_id = classes.class_id
JOIN terms ON class_sections.term_id = terms.term_id
JOIN instructors ON instructors.instructor_id = class_sections.instructor_id
JOIN academic_titles ON instructors.academic_title_id = academic_titles.academic_title_id
WHERE class_sections.instructor_id = 1;

-- List all classes with terms & instructor 
SELECT classes.code, classes.name as class_name, terms.name as term, 
	instructors.first_name, instructors.last_name
FROM class_sections
JOIN classes ON class_sections.class_id = classes.class_id
JOIN terms ON class_sections.term_id = terms.term_id
JOIN instructors ON instructors.instructor_id = class_sections.instructor_id
JOIN academic_titles ON instructors.academic_title_id = academic_titles.academic_title_id
GROUP BY class_sections.term_id, class_sections.class_section_id;


-- Calculate the remaining space left in a class 
SELECT classes.code, classes.name, terms.name as term,
       (SELECT COUNT(student_id) 
        FROM class_registrations inner_class_registrations
        WHERE inner_class_registrations.class_section_id = outer_class_registrations.class_section_id
        GROUP BY class_section_id) as enrolled_students,
       classes.maximum_students - (SELECT COUNT(student_id)
                                   FROM class_registrations inner_class_registrations
                                   WHERE inner_class_registrations.class_section_id =
                                         outer_class_registrations.class_section_id
                                   GROUP BY class_section_id) as space_remaining
FROM class_registrations outer_class_registrations
JOIN class_sections ON class_sections.class_section_id = outer_class_registrations.class_section_id
JOIN classes ON class_sections.class_id = classes.class_id
JOIN terms ON terms.term_id = class_sections.term_id
GROUP BY outer_class_registrations.class_section_id;