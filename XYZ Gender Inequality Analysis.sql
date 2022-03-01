SELECT * FROM emp_data
SELECT * FROM bonus_rules

--PREPARING THE DATASET AS PER THE HR MANAGER'S REQUEST

-- Assigning a generic gender to employees that have refused to disclose their gender
UPDATE emp_data
SET Gender = 'undisclosed'
WHERE Gender IS NULL

-- From information gotten from HR, employees without a stated salary have left the company.
DELETE FROM emp_data
WHERE Salary IS NULL

-- Per request by the HR  manager, NULL departments can be taken out.
DELETE FROM emp_data
WHERE Department = 'NULL'

/*----------------------------------------------*/

----1. Looking at the Gender distribution in the company ----
SELECT DISTINCT Gender, COUNT(Gender) AS Total
FROM emp_data
GROUP BY Gender

----------------------------------------------

----2. Gender distribution by location and departments----
SELECT Gender, Location, Department, COUNT(Gender) AS Total_Count
FROM emp_data
GROUP BY Gender, Location, Department
ORDER BY 4 DESC

----------------------------------------------

----3. Insights on ratings based on Gender----
SELECT Rating, Gender, COUNT(Gender) AS Total_Count
FROM emp_data
GROUP BY Rating, Gender
ORDER BY 3 DESC
----------------------------------------------

----4. Looking for gender pay gaps in the departments and regions.----

WITH 
--creating a CTE that holds the average female salary by department and location 
cteFemales (Department, Location, Average_Salary)
AS 
(
SELECT Department, 
		Location,	
		AVG(Salary) as Average_Salary
FROM emp_data
WHERE Gender = 'Female' 
GROUP BY Department, Location
),
--creating a CTE that holds the average male salary by department and location
cteMales (Department, Location, Average_Salary)
AS
(SELECT Department, Location, AVG(Salary) as Average_Salary
FROM emp_data
WHERE Gender = 'Male'
GROUP BY Department, Location
)
/* Joining both CTEs and calculating for the difference between male and female average 
salaries to determine the average pay gap by department and location */
SELECT f.Department, f.Location, (m.Average_Salary-f.Average_Salary) as GenderPayGap
FROM cteFemales f
INNER JOIN cteMales m
ON f.Department = m.Department AND f.Location = m.Location
ORDER BY GenderPayGap DESC

----------------------------------------------
----5. From the HR Managers mail, the new minimum salary across the country is $90,000. 
-- I am to check if the company mets this requirement at the moment.

SELECT 
Gender,
count(CASE WHEN Salary>= 20000 AND Salary < 30000 THEN 1 END) AS [20K<=s<30K],
count(CASE WHEN Salary>= 30000 AND Salary < 40000 THEN 1 END) AS [30K<=s<40K],
count(CASE WHEN Salary>= 40000 AND Salary < 50000 THEN 1 END) AS [40K<=s<50K],
count(CASE WHEN Salary>= 50000 AND Salary < 60000 THEN 1 END) AS [50K<=s<60K],
count(CASE WHEN Salary>= 60000 AND Salary < 70000 THEN 1 END) AS [60K<=s<70K],
count(CASE WHEN Salary>= 70000 AND Salary < 80000 THEN 1 END) AS [70K<=s<80K],
count(CASE WHEN Salary>= 80000 AND Salary < 90000 THEN 1 END) AS [80K<=s<90K],
count(CASE WHEN Salary>= 90000 AND Salary < 100000 THEN 1 END) AS [90K<=s<100K],
count(CASE WHEN Salary>= 100000 AND Salary < 110000 THEN 1 END) AS [100K<=s<110K],
count(CASE WHEN Salary>= 110000 AND Salary < 120000 THEN 1 END) AS [110K<=s<120K]
FROM emp_data AS SalaryBands
GROUP BY Gender

----------------------------------------------
----6. Using the bonus rules data to determine and analyze all employee bonuses.
-- I first transposed the bonus rules data in excel using INDEX and MATCH function before importing into SQL as CSV


SELECT Name, 
		Gender, 
		e.Department, 
		Location, 
		e.Rating, 
		e.Salary as 'Salary ($)', 
		b.Bonus_Percentages, 
		CONVERT(DECIMAL(10,2),(e.Salary*b.Bonus_Percentages)) as 'Bonus ($)'
FROM emp_data e
INNER JOIN bonus_rules b
ON e.Department = b.Department AND e.Rating = b.Rating
--WHERE e.Department = 'Sales'
