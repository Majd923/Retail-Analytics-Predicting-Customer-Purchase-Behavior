# Create a schema
create database if not exists retail_data;
USE retail_data;

# Set dt_customer as the datetime field (if mixed formats exist / & -)
UPDATE marketing_campaign_clean
SET Dt_Customer = 
    CASE
        WHEN Dt_Customer LIKE '%/%'
            THEN STR_TO_DATE(Dt_Customer, '%m/%d/%Y')
        WHEN Dt_Customer LIKE '%-%' 
             AND Dt_Customer NOT LIKE '%:%'
            THEN STR_TO_DATE(Dt_Customer, '%d-%m-%Y')
        ELSE Dt_Customer
    END;
ALTER TABLE marketing_campaign_clean
MODIFY Dt_Customer DATETIME;


# total number of customer encounters in the marketing campaign 
SELECT COUNT(*) AS Total_Responses
FROM marketing_campaign_clean;

# Identify the top 10 most purchased products in the dataset, such as Wines, Meat Products, etc.
SELECT 'Wines' AS Product, SUM(MntWines) AS Total_Spent FROM marketing_campaign_clean
UNION ALL
SELECT 'Fruits', SUM(MntFruits) FROM marketing_campaign_clean
UNION ALL
SELECT 'Meat Products', SUM(MntMeatProducts) FROM marketing_campaign_clean
UNION ALL
SELECT 'Fish Products', SUM(MntFishProducts) FROM marketing_campaign_clean
UNION ALL
SELECT 'Sweet Products', SUM(MntSweetProducts) FROM marketing_campaign_clean
UNION ALL
SELECT 'Gold Products', SUM(MntGoldProds) FROM marketing_campaign_clean
ORDER BY Total_Spent DESC;

# Find the count of response values
SELECT 
    CASE 
        WHEN Response = 1 THEN 'Responded (1)'
        ELSE 'Did Not Respond (0)'
    END AS Response_Status,
    COUNT(*) AS count
FROM marketing_campaign_clean
GROUP BY Response;

# Determine the distribution of customers based on their education level and marital status
SELECT 
    Education,
    SUM(CASE WHEN Marital_Status = 'Single' THEN 1 ELSE 0 END) AS Single,
    SUM(CASE WHEN Marital_Status = 'Married' THEN 1 ELSE 0 END) AS Married,
    SUM(CASE WHEN Marital_Status = 'Divorced' THEN 1 ELSE 0 END) AS Divorced,
    SUM(CASE WHEN Marital_Status = 'Together' THEN 1 ELSE 0 END) AS Together,
    SUM(CASE WHEN Marital_Status = 'Widow' THEN 1 ELSE 0 END) AS Widow
FROM marketing_campaign_clean
GROUP BY Education;

# Identify the average income of customers who participated in the marketing campaign
SELECT 
    Response,
    AVG(Income) AS Avg_Income
FROM marketing_campaign_clean
GROUP BY Response;

# Identify the distribution of customers' responses to the last campaign
SELECT 'Campaign 1' AS Campaign, SUM(AcceptedCmp1) AS Accepted, COUNT(*) - SUM(AcceptedCmp1) AS Not_Accepted FROM marketing_campaign_clean
UNION ALL
SELECT 'Campaign 2', SUM(AcceptedCmp2), COUNT(*) - SUM(AcceptedCmp2) FROM marketing_campaign_clean
UNION ALL
SELECT 'Campaign 3', SUM(AcceptedCmp3), COUNT(*) - SUM(AcceptedCmp3) FROM marketing_campaign_clean
UNION ALL
SELECT 'Campaign 4', SUM(AcceptedCmp4), COUNT(*) - SUM(AcceptedCmp4) FROM marketing_campaign_clean
UNION ALL
SELECT 'Campaign 5', SUM(AcceptedCmp5), COUNT(*) - SUM(AcceptedCmp5) FROM marketing_campaign_clean;

# Identify the distribution of customers' responses to the last campaign
SELECT 
    Response,
    COUNT(*) AS Total_Customers
FROM marketing_campaign_clean
GROUP BY Response
ORDER BY Total_Customers DESC;

# Calculate the average number of children and teenagers in customers' households
SELECT 
    AVG(Kidhome) AS Avg_Children,
    AVG(Teenhome) AS Avg_Teenagers
FROM marketing_campaign_clean;

# Create an Age column 
ALTER TABLE marketing_campaign_clean
ADD Age INT;

UPDATE marketing_campaign_clean
SET Age = YEAR(CURDATE()) - Year_Birth;

SELECT ID, Year_Birth, Age
FROM marketing_campaign_clean LIMIT 5;

# Create Age_group columns and determine the average number of visits per month for customers in each age group
SELECT 
    Age_Group,
    AVG(NumWebVisitsMonth) AS avg_monthly_visits
FROM (
    SELECT 
        NumWebVisitsMonth,
        CASE 
            WHEN Age BETWEEN 18 AND 25 THEN '18-25'
            WHEN Age BETWEEN 26 AND 35 THEN '26-35'
            WHEN Age BETWEEN 36 AND 45 THEN '36-45'
            WHEN Age BETWEEN 46 AND 55 THEN '46-55'
            ELSE '56+'
        END AS Age_Group
    FROM marketing_campaign_clean
) AS grouped_data
GROUP BY Age_Group
ORDER BY Age_Group;


# Customer Value Segmentation
SELECT 
    CASE 
        WHEN (Total_spending) > 1000 
        THEN 'High Value'
        ELSE 'Low Value'
    END AS Customer_Segment,
    COUNT(*) AS Total_customers
FROM marketing_campaign_clean
GROUP BY Customer_Segment;