Create Database Covid_Project;
Use Covid_Project;

SELECT * FROM district_wise_csv;

SELECT State_Code,SUM(Count) as Population
FROM district_wise_csv
WHERE status='population'
GROUP BY State_Code;



-- Q1-- Weekly evolution of number of confirmed cases, recovered cases, deaths, tests. For instance, 
-- your dashboard should be able to compare Week 3 of May with Week 2 of August 

SELECT Year,Month,CASE
WHEN Day<8 THEN 'Week 1'
WHEN Day < 15 THEN 'Week 2'
WHEN Day < 22 THEN 'Week 3'
ELSE 'Week 4'
END AS week_of_month,SUM(Tested) as Tested,Sum(Confirmed) as Confirmed,Sum(Recovered) as Recovered,Sum(Death) as Death
FROM
(
SELECT YEAR(DATE) AS Year,MONTHNAME(DATE) as Month,DAY(Date) as Day,
SUM(CASE WHEN Status='confirmed' THEN Count ELSE '0' END) as Confirmed,
SUM(CASE WHEN Status='deceased' THEN Count ELSE '0' END) as Death,
SUM(CASE WHEN Status='tested' THEN Count ELSE '0' END) as Tested,
SUM(CASE WHEN Status='recovered' THEN Count ELSE '0' END) as Recovered
FROM State_Wise
GROUP BY YEAR(DATE),MONTHNAME(DATE),DAY(Date)
)AS f
GROUP BY Year,Month,week_of_month;


SELECT State_Code,
SUM(CASE WHEN Status='population' THEN Count ELSE '0' END) as Population,
SUM(CASE WHEN Status='confirmed' THEN Count ELSE '0' END) as Confirmed,
SUM(CASE WHEN Status='deceased' THEN Count ELSE '0' END) as Deceased,
SUM(CASE WHEN Status='tested' THEN Count ELSE '0' END) as tested,
SUM(CASE WHEN Status='vaccinated1' THEN Count ELSE '0' END) as First_Dose,
SUM(CASE WHEN Status='vaccinated2' THEN Count ELSE '0' END) as Second_Dose
FROM  district_wise
GROUP BY State_Code;

-- 1.One Insight-Total Vaccination
SELECT (SUM(First_Dose)/SUM(Population))*100 as percentage_First_dose,
(SUM(Second_Dose)/SUM(Population))*100 AS percentage_second_dose
FROM per_state_analysis;


SELECT State_Code,District_Name,
SUM(CASE WHEN Status='population' THEN Count ELSE '0' END) as Population,
SUM(CASE WHEN Status='confirmed' THEN Count ELSE '0' END) as Confirmed,
SUM(CASE WHEN Status='deceased' THEN Count ELSE '0' END) as Deceased,
SUM(CASE WHEN Status='tested' THEN Count ELSE '0' END) as Tested,
SUM(CASE WHEN Status='recovered' THEN Count ELSE '0' END) as Recovered,
SUM(CASE WHEN Status='vaccinated1' THEN Count ELSE '0' END) as First_Dose,
SUM(CASE WHEN Status='vaccinated2' THEN Count ELSE '0' END) as Second_Dose
FROM  district_wise
GROUP BY State_Code,District_Name
ORDER BY State_Code,District_Name;


SELECT State_Code,
SUM(CASE WHEN Status='population' THEN Count ELSE '0' END) as Population,
SUM(CASE WHEN Status='confirmed' THEN Count ELSE '0' END) as Confirmed,
SUM(CASE WHEN Status='deceased' THEN Count ELSE '0' END) as Deceased,
SUM(CASE WHEN Status='tested' THEN Count ELSE '0' END) as Tested,
SUM(CASE WHEN Status='recovered' THEN Count ELSE '0' END) as Recovered,
SUM(CASE WHEN Status='vaccinated1' THEN Count ELSE '0' END) as First_Dose,
SUM(CASE WHEN Status='vaccinated2' THEN Count ELSE '0' END) as Second_Dose
FROM  district_wise
GROUP BY State_Code
ORDER BY State_Code;

-- 2.Insight-State with Most number of confirmed case
WITH CTE AS
(
SELECT * FROM per_state_analysis
)
SELECT State_Code,Population,Tested,Confirmed,Recovered,Deceased,(Confirmed-(Recovered+Deceased)) as Active_Cases FROM CTE
ORDER BY Confirmed DESC;



SELECT *,(Tested/Population) as Testing_ratio FROM
(
SELECT State_Code,District_Name,
SUM(CASE WHEN Status='population' THEN Count ELSE '0' END) as Population,
SUM(CASE WHEN Status='confirmed' THEN Count ELSE '0' END) as Confirmed,
SUM(CASE WHEN Status='deceased' THEN Count ELSE '0' END) as Death,
SUM(CASE WHEN Status='tested' THEN Count ELSE '0' END) as Tested,
SUM(CASE WHEN Status='recovered' THEN Count ELSE '0' END) as Recovered,
SUM(CASE WHEN Status='vaccinated1' THEN Count ELSE '0' END) as First_Dose,
SUM(CASE WHEN Status='vaccinated2' THEN Count ELSE '0' END) as Second_Dose
FROM  district_wise
GROUP BY State_Code,District_Name
) as f
-- saved it as districtwise_testing


-- --Testing ratio defined

SELECT (SUM(Death_in_Category_A)/SUM(total))*100 as 'Death_Rate_in_Category_A',(SUM(Death_in_Category_B)/SUM(Total))*100 as '% Death_in_Category_B' FROM
(
SELECT Category,SUM(Death) as Total,SUM(CASE WHEN Category='CATEGORY A' THEN Death ELSE '0' END) as Death_in_Category_A,
SUM(CASE WHEN Category='CATEGORY B' THEN Death ELSE '0' END) as Death_in_Category_B FROM
(
SELECT *,CASE
WHEN Testing_ratio BETWEEN 0.05 AND 0.1 THEN 'CATEGORY A'
WHEN Testing_ratio >0.1 OR Testing_ratio <=0.3 THEN 'CATEGORY B'
WHEN Testing_ratio >0.3 OR Testing_ratio <=0.5 THEN 'CATEGORY C'
WHEN Testing_ratio >0.5 OR Testing_ratio <=0.75 THEN 'CATEGORY D'
ELSE 'CATEGORY E' END as Category FROM
(
SELECT * FROM districtwise_testing
) as f
) as g
GROUP BY Category
)as h
ORDER BY Category;




SELECT STate_Code,(First_Dose/Population)*100 as First_Vaccine_Percentage,
(Second_Dose/Population)*100 as Second_Vaccine_Percentage
FROM per_state_analysis
ORDER BY First_Vaccine_Percentage DESC;

UPDATE Vaccination_percentage
SET First_Vaccine_Percentage=90.113
WHERE State_code='DN';

DELETE FROM covid_district_analysis
WHERE Population='0';

SELECT State_Code,District_Name,Population,First_Dose,Second_Dose,(First_Dose/Population)*100 as First_Dose_Percentage,
(Second_Dose/Population)*100 as Second_Dose_Percentage FROM covid_district_analysis
ORDER BY First_Dose_Percentage
LIMIT 5;

-- Compare delta7 confirmed cases with respect to vaccination

SELECT State_Code,District_Name,Type,
SUM(CASE WHEN Status='confirmed' THEN Count ELSE '0' END) AS Confirmed_Case,
SUM(CASE WHEN Status='vaccinated1' THEN Count ELSE '0' END) AS First_Dose,
SUM(CASE WHEN Status='vaccinated2' THEN Count ELSE '0' END) AS Second_Dose
FROM district_wise
WHERE Type='delta7'
GROUP BY  State_Code,District_Name,Type;


-- Categorise total number of confirmed cases in a state by Months and come up with that one month 
-- which was worst for India in terms of number of cases

SELECT State_Code,YEAR(Date) as Year,MONTHNAME(Date) as Month,SUM(Count) as Confirmed_Cases
FROM state_wise
WHERE Status='confirmed'
GROUP BY State_Code,YEAR(Date),MONTHNAME(Date)
ORDER BY Confirmed_Cases DESC
LIMIT 1;


SELECT Year,Month_Name,CASE
WHEN Day<8 THEN 'Week 1'
WHEN Day < 15 THEN 'Week 2'
WHEN Day < 22 THEN 'Week 3'
ELSE 'Week 4' END AS week_of_month,Sum(Tested) as Tested,SUM(Confirmed) as Confirmed,SUM(Recovered) as Recoverd,SUM(Death) as Death FROM
(
SELECT YEAR(Date) as Year,MONTH(Date) as Month,MONTHNAME(Date) as Month_Name,Day(Date) as Day,
SUM(CASE WHEN Status='confirmed' THEN Count ELSE '0' END) as Confirmed,
SUM(CASE WHEN Status='deceased' THEN Count ELSE '0' END) as Death,
SUM(CASE WHEN Status='tested' THEN Count ELSE '0' END) as Tested,
SUM(CASE WHEN Status='recovered' THEN Count ELSE '0' END) as Recovered
FROM state_wise
GROUP BY YEAR(Date),MONTH(Date),MONTHNAME(Date),DAY(Date)
) as f
GROUP BY Year,Month,Month_Name,week_of_month
ORDER BY YEAR,Month;


SELECT Year,Month,Confirmed,Death FROM
(
SELECT YEAR(DATE) AS Year,MONTHNAME(DATE) as Month,
SUM(CASE WHEN Status='confirmed' THEN Count ELSE '0' END) as Confirmed,
SUM(CASE WHEN Status='deceased' THEN Count ELSE '0' END) as Death,
SUM(CASE WHEN Status='tested' THEN Count ELSE '0' END) as Tested,
SUM(CASE WHEN Status='recovered' THEN Count ELSE '0' END) as Recovered
FROM State_Wise
WHERE YEAR(DATE)=2021
GROUP BY YEAR(DATE),MONTHNAME(DATE)
) as f
ORDER BY Confirmed DESC;


SELECT Confirmed,Death,(Confirmed-(Death+Recovered)) as Active_Cases FROM
(
SELECT 
SUM(CASE WHEN Status='confirmed' THEN Count ELSE '0' END) as Confirmed,
SUM(CASE WHEN Status='deceased' THEN Count ELSE '0' END) as Death,
SUM(CASE WHEN Status='tested' THEN Count ELSE '0' END) as Tested,
SUM(CASE WHEN Status='recovered' THEN Count ELSE '0' END) as Recovered
FROM State_Wise
)as f;

SELECT State_Code as State,Confirmed,Deceased,Recovered as Death 
FROM per_state_analysis
Where State_Code IN ('Bihar','Kerala');

UPDATE Per_state_analysis
SET State_Code='Kerala'
Where State_Code='KL';

SELECT * FROM Per_state_analysis
WHERE State_Code='Kerala';
