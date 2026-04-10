-- Create Database 

CREATE DATABASE churn;

-- USE DATABASE CHURN

USE churn;

-- Importing CSV from wizard


-- 

SELECT top 5 *
FROM ChurnTable;


-- Data Validation and Cleaning 


-- customer ID column is not required, let's drop customerID

ALTER TABLE ChurnTable
DROP COLUMN customerID;

SELECT top 5 *
FROM ChurnTable;

-- let's check null values in each column now:
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ChurnTable';

SELECT 
	SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS gender_null,
	SUM(CASE WHEN SeniorCitizen IS NULL THEN 1 ELSE 0 END ) AS SeniorCitizen_NULL,
	SUM(CASE WHEN [Partner] IS NULL THEN 1 ELSE 0 END ) AS Partner_NULL,
	SUM(CASE WHEN Dependents IS NULL THEN 1 ELSE 0 END) as Dependents_Nulls,
	SUM(CASE WHEN tenure IS NULL THEN 1 ELSE 0 END ) as tenure_nulls,
	SUM(CASE WHEN PhoneService IS NULL THEN 1 ELSE 0 END) as PhoneService_Null,
	SUM(CASE WHEN MultipleLines IS NULL THEN 1 ELSE 0 END) as MultipleLines_null,
	SUM(CASE WHEN InternetService IS NULL THEN 1 ELSE 0 END) as InternetService,
	SUM(CASE WHEN OnlineSecurity IS NULL THEN 1 ELSE 0 END) as OnlineSecurity,
	SUM(CASE WHEN OnlineBackup IS NULL THEN 1 ELSE 0 END) as OnlineBackup,
	SUM(CASE WHEN DeviceProtection IS NULL THEN 1 ELSE 0 END) as DeviceProtection,
	SUM(CASE WHEN TechSupport IS NULL THEN 1 ELSE 0 END) as TechSupport,
	SUM(CASE WHEN StreamingTV IS NULL THEN 1 ELSE 0 END) as StreamingTV,
	SUM(CASE WHEN StreamingMovies IS NULL THEN 1 ELSE 0 END) as StreamingMovies,
	SUM(CASE WHEN [Contract] IS NULL THEN 1 ELSE 0 END) as [Contract],
	SUM(CASE WHEN PaperlessBilling IS NULL THEN 1 ELSE 0 END) as PaperlessBilling,
	SUM(CASE WHEN PaymentMethod IS NULL THEN 1 ELSE 0 END) as PaymentMethod,
	SUM(CASE WHEN MonthlyCharges IS NULL THEN 1 ELSE 0 END) as MonthlyCharges,
	SUM(CASE WHEN TotalCharges IS NULL THEN 1 ELSE 0 END) as TotalCharges,
	SUM(CASE WHEN Churn IS NULL THEN 1 ELSE 0 END) as Churn

FROM ChurnTable;

-- there are 11 null vaslues in TotalCharges column, let's check its distribution and then fill it up

SELECT DISTINCT
    AVG(TotalCharges) OVER () AS mean,
    PERCENTILE_CONT(0.5) 
    WITHIN GROUP (ORDER BY TotalCharges) 
    OVER () AS median
FROM ChurnTable;

-- as mean is greater than median lets replace missing values with median value


WITH CTE AS (
SELECT DISTINCT
    PERCENTILE_CONT(0.5) 
    WITHIN GROUP (ORDER BY TotalCharges) 
    OVER () AS median
FROM ChurnTable
WHERE TotalCharges IS NOT NULL

)

UPDATE ChurnTable
SET TotalCharges = (SELECT median from CTE)
WHERE TotalCharges IS NULL;


-- let's check the count of null values now
SELECT COUNT(*) - COUNT(TotalCharges)
FROM ChurnTable

-- now 

SELECT TOP 5 * 
FROM ChurnTable;

-- EDA

-- let' check Churn by Gender

SELECT Gender,SUM(CAST([Churn] AS int))  as Total_Churn,ROUND(SUM(CAST([Churn] AS float)) * 100 / COUNT(*),2) as [%]
FROM ChurnTable
GROUP BY Gender
ORDER by [%] DESC;

-- looks like Female 26.92% have high churn rate compare to male 26.16 but the difference is not that huge , so this feature does not give us the idea
-- of churn by gender

-- Chrun by Senior Citizen

SELECT
	CASE WHEN SeniorCitizen = 0 Then 'No' ELSE 'Yes' END as SeniorCitizen,
	COUNT(*) as Number_of_Citizens,
	SUM(CAST(Churn AS INT))  as total_churned,
	ROUND(SUM(CAST(Churn AS float)) * 100 / COUNT(*),2) as [%_of_Churned]

FROM ChurnTable
GROUP BY SeniorCitizen

-- senior citizens have high churn % i.e 41.68% than non senior citizens 23.61%

-- chrun by partner

SELECT 
	CASE WHEN [Partner] = 0 THEN 'No' ELSE 'Yes'END as [partner],
	count(*) as total_customers,
	SUM(CAST(churn as INT)) as total_churned,
	ROUND(SUM(CAST(churn as float))*100/count(*),2) as [%_churned]

FROM ChurnTable
GROUP BY [partner]

--  32.96 % of cu without partners have chruned, that is higher than with partners 19.66%

-- Chrun by Dependents

SELECT 
	CASE WHEN [Dependents] = 0 THEN 'No' ELSE 'Yes'END as [Dependents],
	count(*) as total_customers,
	SUM(CAST(churn as INT)) as total_churned,
	ROUND(SUM(CAST(churn as float))*100/count(*),2) as [%_churned]

FROM ChurnTable
GROUP BY [Dependents]

--  31.28 % of cu without dependents have chruned, that is higher than with dependents 15.45%

-- Churned by tenure

SELECT MAX([tenure]),MIN([Tenure])
FROM ChurnTable


--GROUP BY [tenure]

WITH CTE2 AS(
SELECT *,
	CASE WHEN [tenure] BETWEEN 0 and 12 THEN '0-1 year'
		 WHEN [tenure] BETWEEN 13 and 24 THEN '1-2 years'
		 WHEN [tenure] BETWEEN 25 and 36 THEN '2-3 years'
		 WHEN [tenure] BETWEEN 37 and 48 THEN '3-4 years'
		 WHEN [tenure] BETWEEN 49 and 60 THEN '4-5 years'
		ElSE '6 years' END as [Tenures]
FROM ChurnTable
)

SELECT [Tenures],
	   COUNT(*) as total_customers,
	   SUM(CAST([Churn] as INT)) as Total_churned,
	   ROUND(SUM(CAST([Churn] as float)) * 100 / Count(*),2) as [%_Chunred]
FROM CTE2
GROUP by [Tenures]
ORDER by [%_Chunred] DESC;

-- churned % is more for the Tenures of 0-1 year 47.44% followed by 1-2 ,2-3 and so on 
-- we can say that people with tenure less or equal to 1 year are more likely to churn compare to higher tenure period customers

-- Churn by phone service

SELECT PhoneService, 
	   COUNT(*) as Total_Customers,
	   SUM(CAST(Churn AS INT)) as Churned_Customers,
	   ROUND(SUM(CAST(Churn AS FLOAT)) * 100 / COUNT(*),2) as [Churned_%]
from ChurnTable
GROUP BY PhoneService

-- similar churn % for both customers with and without phone serivce

--chrun by Multiplelines

SELECT Multiplelines, 
	   COUNT(*) as Total_Customers,
	   SUM(CAST(Churn AS INT)) as Churned_Customers,
	   ROUND(SUM(CAST(Churn AS FLOAT)) * 100 / COUNT(*),2) as [Churned_%]
from ChurnTable
GROUP BY MultipleLines
ORDER BY [Churned_%] DESC

-- customers with multiple lines have high churn %  of 28.61% compare to customers without multiplelines and no phone service compartively

-- Churn by internet service

SELECT InternetService, 
	   COUNT(*) as Total_Customers,
	   SUM(CAST(Churn AS INT)) as Churned_Customers,
	   ROUND(SUM(CAST(Churn AS FLOAT)) * 100 / COUNT(*),2) as [Churned_%]
from ChurnTable
GROUP BY InternetService
ORDER BY [Churned_%] DESC

-- customers with fiber optic as internet service have higher churn % of 41.89 followed by DSL with 18.96% and customers withoit internet service with 7.4%
-- this tells us that  the fiber optic cusotmers are leaving

-- Churn by Online security


SELECT OnlineSecurity, 
	   COUNT(*) as Total_Customers,
	   SUM(CAST(Churn AS INT)) as Churned_Customers,
	   ROUND(SUM(CAST(Churn AS FLOAT)) * 100 / COUNT(*),2) as [Churned_%]
from ChurnTable
GROUP BY OnlineSecurity
ORDER BY [Churned_%] DESC

-- Customers without onlinesecurity have high churn% of 41.77% then with security of 14.61% followed by customers without internet service 7.4%

-- Churn by Online backup


SELECT OnlineBackup, 
	   COUNT(*) as Total_Customers,
	   SUM(CAST(Churn AS INT)) as Churned_Customers,
	   ROUND(SUM(CAST(Churn AS FLOAT)) * 100 / COUNT(*),2) as [Churned_%]
from ChurnTable
GROUP BY OnlineBackup
ORDER BY [Churned_%] DESC

-- Customers without online backup have high churn% of 39.93% then with security of 21.53% followed by customers without internet service 7.4%

-- Churn by Device Protection


SELECT DeviceProtection, 
	   COUNT(*) as Total_Customers,
	   SUM(CAST(Churn AS INT)) as Churned_Customers,
	   ROUND(SUM(CAST(Churn AS FLOAT)) * 100 / COUNT(*),2) as [Churned_%]
from ChurnTable
GROUP BY DeviceProtection
ORDER BY [Churned_%] DESC

-- Customers without device protection have high churn% of 39.13% then with protection of 22.5% followed by customers without internet service 7.4%

-- Churn by Device Protection


SELECT TechSupport, 
	   COUNT(*) as Total_Customers,
	   SUM(CAST(Churn AS INT)) as Churned_Customers,
	   ROUND(SUM(CAST(Churn AS FLOAT)) * 100 / COUNT(*),2) as [Churned_%]
from ChurnTable
GROUP BY TechSupport
ORDER BY [Churned_%] DESC

-- Customers without tech support have high churn% of 41.64% then with tech support of 15.17% followed by customers without internet service 7.4%

-- Churn by StreamingTV


SELECT StreamingTV, 
	   COUNT(*) as Total_Customers,
	   SUM(CAST(Churn AS INT)) as Churned_Customers,
	   ROUND(SUM(CAST(Churn AS FLOAT)) * 100 / COUNT(*),2) as [Churned_%]
from ChurnTable
GROUP BY StreamingTV
ORDER BY [Churned_%] DESC

-- is almost similar....nothing major to make out of this column

-- Churn by StreamingMovie


SELECT StreamingMovies, 
	   COUNT(*) as Total_Customers,
	   SUM(CAST(Churn AS INT)) as Churned_Customers,
	   ROUND(SUM(CAST(Churn AS FLOAT)) * 100 / COUNT(*),2) as [Churned_%]
from ChurnTable
GROUP BY StreamingMovies
ORDER BY [Churned_%] DESC

-- is almost similar....nothing major to make out of this column
-- these two columns do not provide much of information 

-- churn by contract

SELECT Contract, 
	   COUNT(*) as Total_Customers,
	   SUM(CAST(Churn AS INT)) as Churned_Customers,
	   ROUND(SUM(CAST(Churn AS FLOAT)) * 100 / COUNT(*),2) as [Churned_%]
from ChurnTable
GROUP BY Contract
ORDER BY [Churned_%] DESC

-- Month to month contract customers have high churn % of 42.71 then followed by one year 11.27% and Two year 2.83%
--  cusomters with longer contracts tend to not churn compare to smaller time frame contracts

--Churn by paperlessBilling
SELECT paperlessBilling, 
	   COUNT(*) as Total_Customers,
	   SUM(CAST(Churn AS INT)) as Churned_Customers,
	   ROUND(SUM(CAST(Churn AS FLOAT)) * 100 / COUNT(*),2) as [Churned_%]
from ChurnTable
GROUP BY paperlessBilling
ORDER BY [Churned_%] DESC

-- cusotmer with paperless billing have higher churn % than without 16.33%
-- mostly this says that the customers who visit stores for rechagers are more loyal

-- Churn by Payement Method

SELECT PaymentMethod, 
	   COUNT(*) as Total_Customers,
	   SUM(CAST(Churn AS INT)) as Churned_Customers,
	   ROUND(SUM(CAST(Churn AS FLOAT)) * 100 / COUNT(*),2) as [Churned_%]
from ChurnTable
GROUP BY PaymentMethod
ORDER BY [Churned_%] DESC

-- churn % higher for electronic checks 45.29% then followed by mailed check and bank transfer and credit card but its way less and its between 20- 15%

-- churn by total charges

WITH CTE4 AS (
SELECT *,
	  CASE WHEN TotalCharges BETWEEN 0 AND 1000 THEN '0 - 1000'
		   WHEN TotalCharges BETWEEN 1001 AND 2000 THEN '1000 - 2000'
		   WHEN TotalCharges BETWEEN 2001 AND 3000 THEN '2000 - 3000'
		   WHEN TotalCharges BETWEEN 3001 AND 4000 THEN '3000 - 4000'
		   WHEN TotalCharges BETWEEN 4001 AND 5000 THEN '4000 - 5000'
		   WHEN TotalCharges BETWEEN 5001 AND 6000 THEN '5000 - 6000'
		   WHEN TotalCharges BETWEEN 6001 AND 7000 THEN '6000 - 7000'
		   WHEN TotalCharges BETWEEN 7001 AND 8000 THEN '7000 - 8000'
		   ELSE '8000 - 9000' END as Totalcharge
FROM ChurnTable
)

SELECT Totalcharge, COUNT(*) as total_customers, SUM(CAST(Churn AS INT)) AS churned_customers,ROUND(SUM(CAST(Churn AS FLOAT)) * 100 /COUNT(*),2) AS  [Churned_%]
FROM CTE4
GROUP BY Totalcharge
ORDER BY [Churned_%] DESC;

-- there is a higher churn % for less total charges between 0 -1000 36.99 % compare to higher total charges
-- it basically tells us that cusotmers with high totalcharges tend to stay where as customers with less charges tend to leave 


-- Let's check overall churn rate

SELECT count(*) as total_customers , SUM(CAST(Churn AS INT)) as Churned_cusotmers, ROUND(SUM(CAST(Churn AS FLOAT)) * 100/ COUNT(*),2) as [Churned_%]
FROM ChurnTable

-- our company has churn% of 26.54%



'''
Key Findings:

The overall churn rate is 26.54%, indicating a significant customer retention challenge.
Customers with shorter tenure (0–1 year) have the highest churn rate (~47%), highlighting issues in early customer onboarding and engagement.
Month-to-month contract customers show extremely high churn (~42.7%), whereas long-term contracts (1–2 years) have significantly lower churn (<12%).
Fiber optic users exhibit the highest churn (~41.9%), suggesting potential concerns around pricing, service quality, or customer expectations.
Customers without value-added services such as Tech Support, Online Security, Backup, and Device Protection have significantly higher churn (~39–41%).
Senior citizens show higher churn (~41.7%), indicating possible usability or support challenges.
Payment method plays a key role, with electronic check users having the highest churn (~45%), indicating friction in payment experience.
Customers with lower total charges tend to churn more, suggesting that long-term/high-value customers are more retained.


Business Recommendations:

Introduce incentives for long-term contracts (discounts, bundled offers) to reduce dependency on month-to-month subscriptions.
Improve onboarding experience for new customers (first 6 months) through proactive engagement, tutorials, and support.
Re-evaluate fiber optic service pricing and performance to address high churn in this segment.
Bundle value-added services (Tech Support, Online Security, Backup) with plans to increase perceived value and retention.
Enhance support for senior citizens through simplified interfaces and dedicated customer assistance.
Optimize payment experience, especially for electronic check users, by reducing failures and improving usability.
Implement targeted retention campaigns (emails/SMS) for high-risk customers based on churn indicators.


“I analyzed customer churn across demographics, services, and billing behavior.
I found that churn is highest among new customers, month-to-month contract users, and customers without value-added services like tech support.
Based on this, I suggested targeted retention strategies such as contract incentives, service bundling, and improving onboarding experience.”

'''





SELECT TOP 5 *
FROM ChurnTable