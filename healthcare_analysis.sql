-- Healthcare Data Analysis Using MySQL

-- Step 1 — Database Creation
CREATE DATABASE medical_db;
USE medical_db;
SHOW DATABASES;

-- Step 2 - Import each table using the Table Data Import Wizard
SHOW TABLES;

-- Step 3 - Checking table structures
DESCRIBE patients;
DESCRIBE admissions;
DESCRIBE doctors;
DESCRIBE province_names;

-- Step 4 - Checking row counts
SELECT COUNT(*) AS total_admissions FROM admissions;
SELECT COUNT(*) AS total_doctors FROM doctors;
SELECT COUNT(*) AS total_patients FROM patients;

-- Step 5 — Check duplicates and sample dates

	-- 1. Patient duplicate IDs
	SELECT patient_id, COUNT(*) AS count
	FROM patients
	GROUP BY patient_id
	HAVING COUNT(*) > 1;
    
    -- 2. Doctor duplicate IDs
    SELECT doctor_id, COUNT(*) AS count
	FROM doctors
	GROUP BY doctor_id
	HAVING COUNT(*) > 1;
    
    -- 3. Province duplicate IDs
	SELECT province_id, COUNT(*) AS count
	FROM province_names
	GROUP BY province_id
	HAVING COUNT(*) > 1;
    
    -- 4. Patient dates
    SELECT birth_date
	FROM patients
	LIMIT 10;
    
    -- 5. Admission dates
    SELECT admission_date, discharge_date
	FROM admissions
	LIMIT 10;
    
-- Step 6: Final ID Validation

SELECT COUNT(*) AS null_patient_ids
FROM patients
WHERE patient_id IS NULL;

SELECT COUNT(*) AS null_doctor_ids
FROM doctors
WHERE doctor_id IS NULL;

SELECT COUNT(*) AS null_province_ids
FROM province_names
WHERE province_id IS NULL;

-- Step 7: Row Count Validation
SELECT 'patients' AS table_name, COUNT(*) AS row_count
FROM patients
UNION ALL
SELECT 'admissions', COUNT(*)
FROM admissions
UNION ALL
SELECT 'doctors', COUNT(*)
FROM doctors
UNION ALL
SELECT 'province_names', COUNT(*)
FROM province_names;

-- Step 8: NULL Validation

SELECT
    COUNT(*) AS total_rows,
    SUM(patient_id IS NULL) AS null_patient_id,
    SUM(first_name IS NULL) AS null_first_name,
    SUM(last_name IS NULL) AS null_last_name,
    SUM(gender IS NULL) AS null_gender,
    SUM(birth_date IS NULL) AS null_birth_date,
    SUM(province_id IS NULL) AS null_province_id,
    SUM(height IS NULL) AS null_height,
    SUM(weight IS NULL) AS null_weight
FROM patients;

SELECT
    COUNT(*) AS total_rows,
    SUM(patient_id IS NULL) AS null_patient_id,
    SUM(admission_date IS NULL) AS null_admission_date,
    SUM(discharge_date IS NULL) AS null_discharge_date,
    SUM(diagnosis IS NULL) AS null_diagnosis,
    SUM(doctor_id IS NULL) AS null_doctor_id
FROM admissions;

SELECT
    COUNT(*) AS total_rows,
    SUM(doctor_id IS NULL) AS null_doctor_id,
    SUM(first_name IS NULL) AS null_first_name,
    SUM(last_name IS NULL) AS null_last_name,
    SUM(specialty IS NULL) AS null_specialty
FROM doctors;

SELECT
    COUNT(*) AS total_rows,
    SUM(province_id IS NULL) AS null_province_id,
    SUM(province_name IS NULL) AS null_province_name
FROM province_names;

-- Step 9 : Relationship Validation

	-- 1. Check admissions → patients
    SELECT COUNT(*) AS unmatched_patient_ids
	FROM admissions a
	LEFT JOIN patients p
    ON a.patient_id = p.patient_id
	WHERE p.patient_id IS NULL;
    
    -- 2. Check admissions → doctors
    SELECT COUNT(*) AS unmatched_doctor_ids
	FROM admissions a
	LEFT JOIN doctors d
    ON a.doctor_id = d.doctor_id
	WHERE d.doctor_id IS NULL;

	-- 3. Check patients → provinces
    SELECT COUNT(*) AS unmatched_province_ids
	FROM patients p
	LEFT JOIN province_names pn
    ON p.province_id = pn.province_id
	WHERE pn.province_id IS NULL;
    
    SELECT
    patient_id,
    admission_date,
    diagnosis,
    doctor_id,
    COUNT(*) AS record_count
FROM admissions
GROUP BY
    patient_id,
    admission_date,
    diagnosis,
    doctor_id
HAVING COUNT(*) > 1;

/*
patients
    patient_id → unique + NOT NULL
doctors
    doctor_id → unique + NOT NULL
province_names
    province_id → unique + NOT NULL
*/

-- Step 10: Validate Date Columns
	-- patients.birth_date
	SELECT COUNT(*) AS invalid_birth_dates
	FROM patients
	WHERE STR_TO_DATE(birth_date, '%Y-%m-%d') IS NULL;
    
    -- admissions.admission_date
	SELECT COUNT(*) AS invalid_admission_dates
	FROM admissions
	WHERE STR_TO_DATE(admission_date, '%Y-%m-%d') IS NULL;

	-- admissions.discharge_date
	SELECT COUNT(*) AS invalid_discharge_dates
	FROM admissions
	WHERE STR_TO_DATE(discharge_date, '%Y-%m-%d') IS NULL;
    
    
    
-- Step 11: Applying Required Schema Changes
ALTER TABLE admissions
RENAME COLUMN attending_doctor_id TO doctor_id;

-- 1. Patients
ALTER TABLE patients
MODIFY birth_date DATE;

-- 2. Admissions — admission date
ALTER TABLE admissions
MODIFY admission_date DATE;

-- 3. Admissions — discharge date
ALTER TABLE admissions
MODIFY discharge_date DATE;

-- 4. province_names.province_id
	ALTER TABLE province_names
	MODIFY province_id VARCHAR(10) NOT NULL;
    
-- 5. patients.province_id
	ALTER TABLE patients
	MODIFY province_id VARCHAR(10) NOT NULL;

DESCRIBE patients;
DESCRIBE admissions;
DESCRIBE doctors;
DESCRIBE province_names;

-- Data Quality Issue

SELECT COUNT(*) AS invalid_height
FROM patients
WHERE height <= 0;

SELECT COUNT(*) AS invalid_weight
FROM patients
WHERE weight <= 0;

SELECT COUNT(*) AS invalid_date_order
FROM admissions
WHERE admission_date > discharge_date;

SELECT
    patient_id,
    admission_date,
    discharge_date,
    diagnosis,
    doctor_id
FROM admissions
WHERE admission_date > discharge_date;

SELECT
    discharge_date,
    COUNT(*) AS record_count
FROM admissions
WHERE admission_date > discharge_date
GROUP BY discharge_date
ORDER BY record_count DESC;

/*
Row counts are correct.
No duplicate master IDs.
No important NULLs.
All foreign-key values have matching parent records.
Date formats are valid.
Date columns are now DATE.
62 records have admission_date > discharge_date.
We inspected those records and found the same suspicious discharge_date = 1971-01-05.
*/

-- Step 12: Apply Database Keys
	-- 1. patients
    ALTER TABLE patients
	ADD PRIMARY KEY (patient_id);
    
	-- 2. doctors
    ALTER TABLE doctors
	ADD PRIMARY KEY (doctor_id);
    
    -- 3. province_names
    ALTER TABLE province_names
	ADD PRIMARY KEY (province_id);
    
    -- 4. admissions
		-- admissions → patients
			ALTER TABLE admissions
			ADD CONSTRAINT fk_admissions_patient
			FOREIGN KEY (patient_id)
			REFERENCES patients(patient_id);
            
		-- admissions → doctors
			ALTER TABLE admissions
			ADD CONSTRAINT fk_admissions_doctor
			FOREIGN KEY (doctor_id)
			REFERENCES doctors(doctor_id);
            
		-- patients → province_names
			ALTER TABLE patients
			ADD CONSTRAINT fk_patients_province
			FOREIGN KEY (province_id)
			REFERENCES province_names(province_id);
            
-- Step 13: Final Database Validation

-- 1. Check Primary Keys
SHOW KEYS FROM patients WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM doctors WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM province_names WHERE Key_name = 'PRIMARY';

-- 2. Check Foreign Keys
SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'medical_db'
  AND REFERENCED_TABLE_NAME IS NOT NULL;
  
-- 3. Check Final Table Structures
DESCRIBE patients;
DESCRIBE admissions;
DESCRIBE doctors;
DESCRIBE province_names;

/*
1. Show first name, last name, and gender of patients who's gender is 'M' 
*/

SELECT 
	first_name,
    last_name,
    gender
FROM patients
WHERE gender = "M";

/*
2. Show first name and last name of patients who does not have allergies. 
*/

SELECT 
	first_name,
    last_name
FROM patients
WHERE allergies IS NULL;

/*
3. Show first name of patients that start with the letter 'C' 
*/

SELECT 
	first_name
FROM patients
WHERE first_name LIKE "C%";

/*
4. Show first name and last name of patients that weight within the range of 100 
to 120 (inclusive) 
*/

SELECT 
	first_name,
    last_name
FROM patients
WHERE weight BETWEEN 100 AND 120;

/*
5. Update the patients table for the allergies column. If the patient's allergies is 
null then replace it with 'NKA' 
*/

UPDATE patients
SET allergies = "NKA"
WHERE allergies IS NULL;

SELECT COUNT(*) AS null_alleregies_count
FROM patients
WHERE allergies IS NULL;

/*
6. Show first name and last name concatenated into one column to show their 
full name. 
*/

SELECT 
	concat(first_name," ",last_name) AS full_name
FROM patients;

/*
7. Show first name, last name, and the full province name of each patient. 
*/

SELECT 
	p.first_name,
    p.last_name,
    p1.province_name
FROM patients AS p
JOIN province_names AS p1
ON p.province_id = p1.province_id;

/*
8. Show how many patients have a birth_date with 2010 as the birth year. 
*/

SELECT COUNT(*) AS patients_born_2010
FROM patients
WHERE YEAR(birth_date) = 2010;

/*
9. Show the first_name, last_name, and height of the patient with the greatest 
height. 
*/

SELECT 
	first_name,
    last_name,
    height
FROM patients
WHERE height = (
	SELECT MAX(height)
	FROM patients
);

/*
10. Show all columns for patients who have one of the following patient_ids: 
1,45,534,879,1000 
*/

SELECT *
FROM patients
WHERE patient_id IN(1,45,534,879,1000);

/*
11. Show the total number of admissions 
*/

SELECT COUNT(*) total_admissions
FROM admissions;

/*
12. Show all the columns from admissions where the patient was admitted and 
discharged on the same day. 
*/

SELECT *
FROM admissions
WHERE admission_date = discharge_date;

/*
13. Show the total number of admissions for patient_id 579. 
*/

SELECT COUNT(*) AS total_admissions
FROM admissions
WHERE patient_id = 579;

/*
14. Based on the cities that our patients live in, show unique cities that are in 
province_id 'NS'? 
*/

SELECT DISTINCT(city)
FROM patients
WHERE province_id = "NS";

/*
15. Write a query to find the first_name, last name and birth date of patients 
who have height more than 160 and weight more than 70 
*/

SELECT 
	first_name,
    last_name,
    birth_date
FROM patients
WHERE height > 160 
AND weight > 70;

/*
16. Show unique birth years from patients and order them by ascending. 
*/

SELECT 
	DISTINCT YEAR(birth_date) AS birth_years
FROM patients
ORDER BY birth_years ASC;

/*
17. Show unique first names from the patients table which only occurs once in 
the list. 
For example, if two or more people are named 'John' in the first_name column 
then don't include their name in the output list. If only 1 person is named 'Leo' 
then include them in the output. Tip: HAVING clause was added to SQL 
because the WHERE keyword cannot be used with aggregate functions. 
*/

SELECT first_name
FROM patients
GROUP BY first_name
HAVING COUNT(*) = 1;

/*
18. Show patient_id and first_name from patients where their first_name start 
and ends with 's' and is at least 6 characters long. 
*/

SELECT 
	patient_id,
    first_name
FROM patients
WHERE first_name LIKE "S%s"
AND LENGTH(first_name) >= 6 ;

/*
19. Show patient_id, first_name, last_name from patients whos diagnosis is 
'Dementia'.   Primary diagnosis is stored in the admissions table. 
*/

SELECT DISTINCT
	p.patient_id,
	p.first_name,
    p.last_name
FROM patients AS p
JOIN admissions AS a
ON p.patient_id = a.patient_id
WHERE a.diagnosis = "Dementia";

/*
20. Display every patient's first_name. Order the list by the length of each name 
and then by alphbetically. 
*/

SELECT 
	first_name
FROM patients
ORDER BY LENGTH(first_name) ASC, first_name ASC;

/*
21. Show the total amount of male patients and the total amount of female 
patients in the patients table. Display the two results in the same row. 
*/

SELECT 
	SUM(CASE WHEN gender = "M" THEN 1 ELSE 0 END) AS male_patients,
	SUM(CASE WHEN gender = "F" THEN 1 ELSE 0 END) AS female_patients
FROM patients;

/*
22. Same as Q21, solved with COUNT(CASE ...) instead of SUM(CASE ...). 
*/

SELECT 
	COUNT(CASE WHEN gender = "M" THEN 1 END) AS male_patients,
	COUNT(CASE WHEN gender = "F" THEN 1 END) AS female_patients
FROM patients;

/*
23. Show patient_id, diagnosis from admissions. Find patients admitted 
multiple times for the same diagnosis. 
*/

SELECT 
	patient_id,
    diagnosis
FROM admissions
GROUP BY patient_id, diagnosis
HAVING COUNT(*) > 1;

/*
24. Show the city and the total number of patients in the city. Order from most 
to least patients and then by city name ascending. 
*/

SELECT 
	city,
    COUNT(*) AS total_patients
FROM patients
GROUP BY city
ORDER BY total_patients DESC,
	city ASC;

/*
25. Show first name, last name and role of every person that is either patient or 
doctor.    
The roles are either "Patient" or "Doctor" 
*/

SELECT 
	first_name,
    last_name,
    "Patient" AS role
FROM patients

UNION ALL

SELECT 
	first_name,
    last_name,
    "Doctor" AS role
FROM doctors;

/*
26. Show all allergies ordered by popularity. Remove NULL values from query.
(NULLs were replaced with 'NKA' in Q5, so 'NKA' is excluded here.) 
*/

SELECT 
	allergies,
	COUNT(*) AS total_patients
FROM patients
WHERE allergies != "NKA"
GROUP BY allergies
ORDER BY total_patients DESC;

/*
27. Show all patient's first_name, last_name, and birth_date who were born in 
the 1970s decade. Sort the list starting from the earliest birth_date. 
*/

SELECT 
	first_name,
    last_name,
    birth_date
FROM patients
WHERE YEAR(birth_date) BETWEEN 1970 AND 1979
ORDER BY birth_date ASC;

SELECT
    first_name,
    last_name,
    birth_date
FROM patients
WHERE birth_date >= '1970-01-01'
  AND birth_date < '1980-01-01'
ORDER BY birth_date ASC;

/*
28. We want to display each patient's full name in a single column. Their 
last_name in all upper letters must appear first, then first_name in all lower case 
letters. Separate the last_name and first_name with a comma. Order the list by 
the first_name in decending order    EX: SMITH,jane 
*/

SELECT 
	CONCAT(UPPER(last_name),",",LOWER(first_name)) AS full_name
FROM patients
ORDER BY first_name DESC;

/*
29. Show the province_id(s), sum of height; where the total sum of its patient's 
height is greater than or equal to 7,000. 
*/

SELECT 
	province_id,
    SUM(height) AS total_height
FROM patients
GROUP BY province_id
HAVING SUM(height) >= 7000;

/*
30. Show the difference between the largest weight and smallest weight for 
patients with the last name 'Maroni' 
*/

SELECT 
	last_name,
    MAX(weight) AS largest_weight,
    MIN(weight) AS smallest_weight,
    MAX(weight) - MIN(weight) AS weight_difference
FROM patients
WHERE last_name = "Maroni"
GROUP BY last_name;

/*
31. Show all of the days of the month (1-31) and how many admission_dates 
occurred on that day. Sort by the day with most admissions to least admissions. 
*/

SELECT 
	DAY(admission_date) AS day_of_month,
    COUNT(*) AS total_admissions
FROM admissions
GROUP BY day_of_month
ORDER BY total_admissions DESC;

/*
32. Show all of the patients grouped into weight groups. Show the total amount 
of patients in each weight group. Order the list by the weight group decending. 
e.g. if they weight 100 to 109 they are placed in the 100 weight group, 110-119 = 
110 weight group, etc. 
*/

SELECT
    FLOOR(weight / 10) * 10 AS weight_group,
    COUNT(*) AS total_patients
FROM patients
GROUP BY FLOOR(weight / 10) * 10
ORDER BY weight_group DESC;

/*
33. Show patient_id, weight, height, isObese from the patients table. Display 
isObese as a boolean 0 or 1. Obese is defined as BMI >= 30, where BMI = weight(kg) / height(m)^2. Weight 
is in units kg. Height is in units cm. 
*/

SELECT 
	patient_id,
    weight,
    height,
    CASE 
		WHEN weight / POWER(height / 100 , 2) >= 30 THEN 1 
        ELSE 0
	END AS isObese
FROM patients;

/*
34. Show patient_id, first_name, last_name, and attending doctor's specialty. 
Show only the patients who has a diagnosis as 'Epilepsy' and the doctor's first 
name is 'Lisa'. Check patients, admissions, and doctors tables for required 
information.
*/

SELECT 
	p.patient_id,
    p.first_name,
    p.last_name,
    d.specialty
FROM patients AS p
INNER JOIN admissions AS a
ON p.patient_id = a.patient_id
INNER JOIN doctors AS d
ON a.doctor_id = d.doctor_id
WHERE a.diagnosis = "Epilepsy"
AND d.first_name = "Lisa";
