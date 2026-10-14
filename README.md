# Healthcare Data Analysis using MySQL

An end-to-end SQL project on a hospital database: importing raw CSV files into MySQL, validating and cleaning the data, enforcing keys, and answering 34 business questions with SQL.

**Tools:** MySQL 8, MySQL Workbench
**Skills shown:** data validation, schema design, joins, aggregations, subqueries, CASE logic, date and string functions

---

## Dataset

Four related tables (`data/` folder):

| Table | Rows | Description |
|---|---|---|
| `patients` | 4,530 | Demographics, city, province, allergies, height, weight |
| `admissions` | 5,067 | Admission and discharge dates, diagnosis, attending doctor |
| `doctors` | 27 | Doctor names and specialties |
| `province_names` | 13 | Province code to full name lookup |

**Relationships**

- `admissions.patient_id` → `patients.patient_id`
- `admissions.doctor_id` → `doctors.doctor_id`
- `patients.province_id` → `province_names.province_id`

Admissions cover June 2018 to June 2019.

---

## Project Workflow

### 1. Database setup and import
Created `medical_db` and imported the four CSV files with the MySQL Table Data Import Wizard.

### 2. Data validation
- Row counts checked against the source files
- Duplicate and NULL checks on all ID columns
- Orphan-record checks (admissions without a patient or doctor, patients without a province)
- Date format validation with `STR_TO_DATE`

### 3. Schema fixes
- Renamed `attending_doctor_id` to `doctor_id` so the column matches the `doctors` table
- Converted `birth_date`, `admission_date` and `discharge_date` to the `DATE` type
- Standardised `province_id` to `VARCHAR(10) NOT NULL`
- Added primary keys on all lookup and master tables and foreign keys on the relationships above

### 4. Data quality findings
- **62 admission records have an admission date after the discharge date.** All 62 share the same discharge date, `1971-01-05`, which looks like a default or placeholder value. These records were flagged rather than deleted.
- No duplicate IDs, no orphan records, and no missing values in key columns.
- 2,059 patients had no allergy recorded. These were replaced with `'NKA'` (No Known Allergies).

### 5. Analysis: 34 business questions
Queries are grouped below by the SQL concepts they practise.

| Concept | Examples |
|---|---|
| Filtering and pattern matching | Patients whose first name starts with `C`; names starting and ending with `s` |
| Aggregation and `HAVING` | Patients per city; provinces with total height of at least 7,000; weight groups |
| Joins | Patient with province name; patients with Epilepsy treated by a doctor named Lisa |
| Subqueries | Patient with the greatest height |
| `CASE` logic | Male vs female count in one row; obesity flag using BMI of 30 or more |
| Date functions | Admissions by day of month; patients born in the 1970s; same-day discharges |
| Set operations | Combined list of patients and doctors with a role column |

---

## Selected Results

- 4,530 patients: 2,468 male and 2,062 female
- Most common admission diagnosis: **Congestive Heart Failure** (277 admissions)
- 481 admissions were same-day discharges
- Most common allergy recorded: **Penicillin** (1,082 patients)
- 2,222 patients have a BMI of 30 or more

---

## How to Run

**Requirements**

- MySQL Server 8.0 or later (the script uses `RENAME COLUMN`)
- MySQL Workbench, or any MySQL client

**Steps**

1. Clone the repository:
   ```bash
   git clone https://github.com/jagdishsahukari/healthcare-sql-analysis.git
   ```
2. Open `healthcare_analysis.sql` in MySQL Workbench.
3. Run Step 1 to create and select the `medical_db` database.
4. Import the four CSV files from `data/` using **Table Data Import Wizard** (right-click the database, then *Table Data Import Wizard*). Keep the table names `patients`, `admissions`, `doctors` and `province_names`.
5. Run the rest of the script in order, step by step. The validation steps come before the schema changes and key creation, so the order matters.

> Note: the allergy `UPDATE` in question 5 may need Workbench safe update mode switched off (*Edit → Preferences → SQL Editor*).

---

## Repository Structure

```
healthcare-sql-analysis/
├── data/
│   ├── patients.csv
│   ├── admissions.csv
│   ├── doctors.csv
│   └── province_names.csv
├── healthcare_analysis.sql
└── README.md
```

---

## Author

**Jagdish Sahukari**: B.Sc. Data Science graduate, aspiring Data Analyst
[LinkedIn](https://www.linkedin.com/in/jagdish-sahukari-49064b312) · [GitHub](https://github.com/jagdishsahukari)
