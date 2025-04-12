
--number of orders	
SELECT  COUNT(DISTINCT order_id) FROM Order360   -- 98,402

--number of records		
SELECT COUNT(order_id) FROM Order360   -- 1,02,464

--number of customers
SELECT COUNT(DISTINCT Customer_id) FROM Order360    -- 98,311

--number of stores
SELECT COUNT(DISTINCT Delivered_StoreID) FROM Order360  -- 37

--total revenue	
SELECT SUM(Total_Amount) FROM Order360   -- 1,58,12,860 INR

---total profit		   
SELECT SUM(Profit) FROM Order360    -- 22,45,715 INR

--total cost		  
SELECT SUM(Cost_Per_Unit*Quantity) FROM Order360   -- 1,35,67,145 INR

--total discount		   
SELECT SUM(Discount) FROM Order360  -- 5,10,781 INR

--total categories		
SELECT DISTINCT Product_Category FROM Order360

SELECT COUNT(DISTINCT Product_Category) TOTAL_CAT FROM Order360
WHERE Product_Category <> 'Unknown'

--total quantity	
SELECT SUM(Quantity) FROM Order360   -- 1,12,339 No.of products

--total products	
SELECT COUNT(DISTINCT product_id) FROM Order360   -- 32,887 No.of DISTINCT products

--total locations	
SELECT COUNT(DISTINCT seller_city) FROM Store360  -- 37 (IT MEANS EACH STORE IS IN DIFFERENT CITY)

--total regions
SELECT COUNT(DISTINCT Region) No_Of_Regions FROM Store360    -- 4

SELECT DISTINCT Region FROM Store360

--total channels	
SELECT COUNT(DISTINCT Channel) No_Of_Channel FROM Order360    -- 3

SELECT DISTINCT Channel FROM Order360

--total payment methods 
SELECT COUNT(DISTINCT payment_type ) No_Of_PayMethod FROM OrderPay_ment    -- 4

SELECT DISTINCT payment_type FROM OrderPay_ment

--avg disc per cust	
SELECT SUM(Discount) / COUNT(DISTINCT Customer_id) FROM Order360  -- 5.196 INR

--avg disc per order
SELECT SUM(Discount) / COUNT(DISTINCT order_id) FROM Order360   -- 5.190 INR

--avg order value
SELECT SUM(Total_Amount) / COUNT(DISTINCT order_id) FROM Order360   -- 160.697 INR

--avg sale per customer
SELECT SUM(Total_Amount) / COUNT(DISTINCT Customer_id) FROM Order360   -- 160.845 INR

--avg profit per customer
SELECT SUM(Profit) / COUNT(DISTINCT Customer_id) FROM Order360   -- 22.843 INR

--avg categories per order
SELECT COUNT(Product_Category)*1.0 / (COUNT(DISTINCT order_id)) AVG_CAT_PER_ORD FROM Order360   -- 1.0412 CATEGORIES

--avg number of items per order
SELECT SUM(Quantity)*1.0 / COUNT(DISTINCT order_id) FROM Order360   -- 1.142 ITEMS

--avg no of transactions per customer
SELECT COUNT(Customer_id)*1.0 / (COUNT(DISTINCT Customer_id)) AVG_no_of_tran_PER_CusT FROM Order360   -- 1.042 TRANSACTIONS

--average no. of days between 2 transactions
SELECT AVG(AvgDaysBetween) [Avg_days b/w 2 Customer Transaction]
FROM
    (SELECT Customer_id, AVG(DaysBetween) AS AvgDaysBetween
     FROM
        (SELECT Customer_id, DATEDIFF(DAY, Bill_date_timestamp, NextTransactionDate) AS DaysBetween
         FROM
            (SELECT Customer_id, Bill_date_timestamp, 
                    LEAD(Bill_date_timestamp) OVER (PARTITION BY Customer_id ORDER BY Bill_Date_TIMESTAMP) AS NextTransactionDate
             FROM ORDER360) Y
         WHERE NextTransactionDate IS NOT NULL) Z
     GROUP BY Customer_id) X

--percentage of profit
SELECT (SUM(Profit)*100)/SUM(Total_Amount) FROM Order360    -- 14.20 PERCENT PROFIT OVERALL

--percentage of discount
SELECT (SUM(Discount)*100)/SUM(MRP*Quantity) FROM Order360   -- 3.12 PERCENT DISCOUNT OVERALL


--repeate customer rate
SELECT 
    COUNT(CASE WHEN Purchase_Count > 1 THEN Customer_ID END) * 100.0 / COUNT(DISTINCT Customer_ID) AS Repeat_Customer_Percentage
FROM (
    SELECT Customer_ID, COUNT(DISTINCT order_id) AS Purchase_Count FROM Order360                       -- 0.0366 PERCENT (VERY LOW)
    GROUP BY Customer_ID
) AS Y

--one time buyer percentage
SELECT 
    (SUM(CASE WHEN Purchase_Count = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(DISTINCT Customer_id) AS One_Time_Buyer_Percentage
FROM (
    SELECT Customer_id, COUNT(DISTINCT order_id) AS Purchase_Count FROM Order360             -- 99.9633 PERCENT ONE TIME BUYER
    GROUP BY Customer_id
) AS Z

--================================================= THE END ==================================================================

		
--how many new customers acquired per month
--===========================================
WITH FirstPurchase AS (
    SELECT Customer_id, MIN(Bill_date_timestamp) AS First_Purchase_Date FROM Order360
    GROUP BY Customer_id
)
SELECT YEAR(First_Purchase_Date) AS Year, MONTH(First_Purchase_Date) AS Month,
		COUNT( Customer_id) AS New_Customers_Acquired
FROM FirstPurchase
GROUP BY YEAR(First_Purchase_Date), MONTH(First_Purchase_Date)
ORDER BY Year, Month

--retention of customers on an MOM basis
--========================================
WITH FirstPurchase AS (
    SELECT Customer_id, MIN(Bill_date_timestamp) AS First_Purchase_Date FROM order360
    GROUP BY Customer_id
),
 counts as ( select Customer_id,count(distinct order_id) as cnt from Order360
            group by Customer_id
			having count(distinct order_id)>1)

select YEAR(First_Purchase_Date) as Years,MONTH(First_Purchase_Date) as months,
COUNT( X.Customer_id) AS New_Customers_Acquired,count(Y.Customer_id) as [Total customer retention] from FirstPurchase as X
left join counts as Y
on X.Customer_id=Y.Customer_id 
group by YEAR(First_Purchase_Date),MONTH(First_Purchase_Date)
order by Years,months
	

--==================	
--trends of sale :-
--==================
	--by category
	--==============
	SELECT Product_Category,
    YEAR(O.Bill_date_timestamp) AS Year, MONTH(O.Bill_date_timestamp) AS Month, SUM(O.Quantity * (O.MRP - O.Discount)) AS Total_Sales
	FROM Order360 O
	GROUP BY Product_Category, YEAR(O.Bill_date_timestamp), MONTH(O.Bill_date_timestamp)
	ORDER BY Product_Category, YEAR(O.Bill_date_timestamp), MONTH(O.Bill_date_timestamp)

	--by region	
	--===========
	SELECT S.Region,
    YEAR(O.Bill_date_timestamp) AS Year, MONTH(O.Bill_date_timestamp) AS Month, SUM(O.Quantity * (O.MRP - O.Discount)) AS Total_Sales
	FROM Order360 O
	JOIN Store360 S ON O.Delivered_StoreID = S.StoreID
	GROUP BY S.Region, YEAR(O.Bill_date_timestamp), MONTH(O.Bill_date_timestamp)
	ORDER BY S.Region, YEAR(O.Bill_date_timestamp), MONTH(O.Bill_date_timestamp)

	--by store	
	--==========
	SELECT Delivered_StoreID,
    YEAR(O.Bill_date_timestamp) AS Year, MONTH(O.Bill_date_timestamp) AS Month, SUM(O.Quantity * (O.MRP - O.Discount)) AS Total_Sales
	FROM Order360 O
	GROUP BY Delivered_StoreID, YEAR(O.Bill_date_timestamp), MONTH(O.Bill_date_timestamp)
	ORDER BY Delivered_StoreID, YEAR(O.Bill_date_timestamp), MONTH(O.Bill_date_timestamp)

	--by channel	
	--============
	SELECT Channel,
    YEAR(O.Bill_date_timestamp) AS Year, MONTH(O.Bill_date_timestamp) AS Month, SUM(O.Quantity * (O.MRP - O.Discount)) AS Total_Sales
	FROM Order360 O
	GROUP BY Channel, YEAR(O.Bill_date_timestamp), MONTH(O.Bill_date_timestamp)
	ORDER BY Channel, YEAR(O.Bill_date_timestamp), MONTH(O.Bill_date_timestamp)



--================================	
--Popular category and product-:
--================================
	--==========
	--by store	
	--==========
WITH StoreCategorySales AS (
    SELECT Delivered_StoreID, Product_Category, SUM(Total_Amount) AS TotalSales
    FROM Order360
    GROUP BY Delivered_StoreID, Product_Category
),
PopularCategory AS (
    SELECT Delivered_StoreID, Product_Category, TotalSales, RANK() OVER (PARTITION BY Delivered_StoreID ORDER BY TotalSales DESC) AS Rank
    FROM StoreCategorySales
)
SELECT Delivered_StoreID, Product_Category AS PopularCategory, TotalSales
FROM PopularCategory
WHERE Rank = 1

	--===========
	--by region	
	--===========
WITH StoreCategorySales AS (
    SELECT S.Region AS Region, Product_Category, SUM(Total_Amount) AS TotalSales
    FROM Order360 AS O
	JOIN Store360 AS S ON O.Delivered_StoreID = S.StoreID
    GROUP BY S.Region, Product_Category
),
PopularCategory AS (
    SELECT Region, Product_Category, TotalSales, RANK() OVER (PARTITION BY Region ORDER BY TotalSales DESC) AS Rank
    FROM StoreCategorySales
)
SELECT Region, Product_Category AS PopularCategory, TotalSales
FROM PopularCategory
WHERE Rank = 1

	--==========
	--by state	
	--==========
WITH StoreCategorySales AS (
    SELECT S.seller_state AS States, Product_Category, SUM(Total_Amount) AS TotalSales
    FROM Order360 AS O
	JOIN Store360 AS S ON O.Delivered_StoreID = S.StoreID
    GROUP BY S.seller_state, Product_Category
),
PopularCategory AS (
    SELECT States, Product_Category, TotalSales, RANK() OVER (PARTITION BY States ORDER BY TotalSales DESC) AS Rank
    FROM StoreCategorySales
)
SELECT States, Product_Category AS PopularCategory, TotalSales
FROM PopularCategory
WHERE Rank = 1



--top 10 most expensive products by price and their contribution to sale
--=======================================================================

WITH [Top 10 Exp Products] AS (
    SELECT TOP 10 product_id, MRP-Discount AS Price
    FROM Order360
	ORDER BY Price DESC
),
SaleContribution AS (
    SELECT X.product_id, X.Price, SUM(O.Total_Amount) AS Total_Revenue
    FROM [Top 10 Exp Products] AS X
	JOIN Order360 AS O ON O.product_id = X.product_id 
	GROUP BY X.product_id, X.Price
)
SELECT *, Total_Revenue*100/(Select SUM(Total_Amount) FROM Order360) AS Sale_Contribution
FROM SaleContribution 

--top 10 best and worst performing stores in terms of revenue		
--================================================================

--Best
SELECT TOP 10 Delivered_StoreID, ROUND(SUM(Total_Amount),2) AS Store_total_Revenue
FROM order360
GROUP BY Delivered_StoreID
ORDER BY Store_total_Revenue DESC

-- Worst
SELECT TOP 10 Delivered_StoreID, ROUND(SUM(Total_Amount),2) AS Store_total_Revenue
FROM order360
GROUP BY Delivered_StoreID
ORDER BY Store_total_Revenue ASC

--==================================================================================================
-- CROSS SELLING COMBINATION OF PRODUCTS
--=========================================
-- Combination of 3 categorie
--============================

WITH CombinationCounts AS (
    SELECT A.order_id, A.Product_Category AS Category1, B.Product_Category AS Category2, C.Product_Category AS Category3
    FROM ORDER360 A
    JOIN ORDER360 B
    ON A.order_id = B.order_id 
        AND A.Product_Category < B.Product_Category  -- Avoid duplicate/reverse combinations
    JOIN ORDER360 C
    ON B.order_id = C.order_id 
        AND B.Product_Category < C.Product_Category  -- Avoid duplicate/reverse combinations
)
SELECT top 10 Category1, Category2, Category3, COUNT(*) AS Frequency
FROM CombinationCounts
GROUP BY Category1, Category2, Category3
ORDER BY Frequency DESC;

-- Combination of 2 categorie
--============================

WITH CombinationCounts AS (
    SELECT A.order_id, A.Product_Category AS Category1, B.Product_Category AS Category2
    FROM ORDER360 A
    JOIN ORDER360 B
    ON A.order_id = B.order_id 
        AND A.Product_Category < B.Product_Category  -- Avoid duplicate/reverse combinations
)
SELECT Category1, Category2, COUNT(*) AS Frequency
FROM CombinationCounts
GROUP BY Category1, Category2
ORDER BY Frequency DESC;

--========================================= COHORT ANALYSIS @ Fixed Months ======================================

WITH FirstPurchase AS (
    SELECT Customer_id, MIN(Bill_date_timestamp) AS First_Purchase_Date FROM Order360
    GROUP BY Customer_id
),
counts AS ( SELECT Customer_id, MIN(Bill_date_timestamp) AS mins, MAX(Bill_date_timestamp) AS maxs,
                   COUNT(DISTINCT order_id) AS cnt,
				   DATEDIFF(MONTH, MIN(Bill_date_timestamp), MAX(Bill_date_timestamp)) / (COUNT(DISTINCT order_id) - 1) AS avg_order_gap
			FROM Order360
            GROUP BY Customer_id
			HAVING COUNT(DISTINCT order_id)>1),

Retention_rates AS (SELECT YEAR(First_Purchase_Date) AS Years, MONTH(First_Purchase_Date) AS Months,
						   COUNT( X.Customer_id) AS New_Customers_Acquired, COUNT(Y.Customer_id) AS [Total customer retention],
                           CASE 
                                WHEN COUNT(Y.Customer_id) is null THEN 0
                                ELSE  CAST((COUNT(Y.Customer_id) * 1.0 / COUNT(X.Customer_id) * 100) AS DECIMAL(10, 3))
                           END AS Retention_Rate
					FROM FirstPurchase AS X
					LEFT JOIN counts AS Y ON X.Customer_id=Y.Customer_id 
					GROUP BY YEAR(First_Purchase_Date), MONTH(First_Purchase_Date)),

avgs AS (SELECT Z.*, CASE 
						WHEN AVG(Y.avg_order_gap) IS NULL THEN 0
						ELSE AVG(Y.avg_order_gap) 
					 END AS Avg_Months_Repeated_Customers
		FROM Order360 AS X
		LEFT JOIN counts AS Y ON YEAR(x.Bill_date_timestamp) = YEAR(Y.mins) AND MONTH(X.Bill_date_timestamp) = MONTH(Y.mins)
		RIGHT JOIN Retention_rates AS Z ON YEAR(x.Bill_date_timestamp) = Z.Years AND MONTH(X.Bill_date_timestamp) = Z.months
		GROUP BY Z.Years, Z.months, Z.New_Customers_Acquired, Z.[Total customer retention], Z.Retention_Rate),

Total_amt_qty  AS (SELECT X.*, ROUND(SUM([Total_Amount]),2) AS [Tot.amount by new customer], SUM(Quantity) AS [Tot.quantity by new customer]
				   FROM avgs AS X
				   LEFT JOIN Order360 AS O ON X.Years = YEAR(o.Bill_date_timestamp)
										  AND X.months = MONTH(Bill_date_timestamp)
				   GROUP BY X.Years, X.months, X.New_Customers_Acquired, X.[Total customer retention], X.Retention_Rate, X.Avg_Months_Repeated_Customers )

SELECT Z.*, CASE 
				WHEN SUM(Total_Amount) IS NULL THEN 0 
				ELSE ROUND(SUM(Total_Amount),2) 
			END AS [Tot.amount by retention customer],
			CASE 
				WHEN SUM(Quantity) IS NULL THEN 0
				ELSE SUM(Quantity) 
			END AS [Tot.quantity by retention customer]
FROM Order360 AS X
RIGHT JOIN counts AS Y ON X.Customer_id=Y.Customer_id AND YEAR(X.Bill_date_timestamp) = YEAR(Y.mins) 
													  AND MONTH(X.Bill_date_timestamp) = MONTH(Y.mins)
RIGHT JOIN Total_amt_qty AS Z ON YEAR(x.Bill_date_timestamp) = Z.Years
							AND MONTH(X.Bill_date_timestamp) = Z.months
GROUP BY Z.Years, Z.months, Z.New_Customers_Acquired, Z.[Total customer retention], Z.Retention_Rate,
			Z.Avg_Months_Repeated_Customers, [Tot.amount by new customer], [Tot.quantity by new customer]
ORDER BY Z.Years, Z.months

--=========================================== COHORT ANALYSIS @ Customer Retention =================================================

-- First we will segregate all the customers into different cohorts based on the months of their first purchase.
-- And store these segments as "MONTHLY_Cohort_SEG".
-- Step:1
--=======
SELECT Customer_id, MIN(Bill_date_timestamp) AS First_Purchase_Date,
	   DATEFROMPARTS(year(MIN(Bill_date_timestamp)),MONTH(MIN(Bill_date_timestamp)),1) AS cohort_date  --INTO Fixed_Cohort1
FROM order360_copy
GROUP BY Customer_id;

--HERE IS WHAT WE GET--
--=====================	
 select * from Fixed_Cohort1
 
 -- Step:2
 --========

 WITH CTE1 AS ( SELECT Z.*, (order_month-cohort_month) AS month_delay                    
				FROM ( SELECT X.*,Y.cohort_date,MONTH(Bill_date_timestamp) AS order_month, MONTH(cohort_date) AS cohort_month
					   FROM Order360_copy AS X
                LEFT JOIN Fixed_Cohort1 AS Y ON X.Customer_id=Y.Customer_id
                                             AND year(X.Bill_date_timestamp)=year(Y.cohort_date)) AS Z)
 SELECT *, (month_delay) AS cohort_index  --INTO cohort_retention  
 FROM CTE1 

 --HERE IS WHAT WE GET--
 --=====================
SELECT * FROM cohort_retention
 
 -- Step:3
 --========
 
 SELECT * FROM ( SELECT DISTINCT Customer_id, cohort_date, cohort_index 
				FROM cohort_retention
				WHERE cohort_date IS NOT NULL
			   ) AS TBL
 PIVOT(COUNT(Customer_id) FOR cohort_index IN
           ([0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS pivot_table
 ORDER BY cohort_date


 --                                ================================== THE END ============================
