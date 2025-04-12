--===============--
-- DATA CLEANING --
--===============--

SELECT * FROM Cust_info


--==================================================================================================================
--======== Store Table ======
--==================================

SELECT DISTINCT * FROM Store_Info

WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY storeID ORDER BY (SELECT NULL)) AS RowNum
    FROM Store_Info
)
DELETE FROM CTE
WHERE RowNum > 1

--==================================================================================================================
--======== Product Table ======
--==================================

SELECT DISTINCT * FROM Product_Info

UPDATE product_info
SET Category = 'Unknown'
WHERE Category = '#N/A'


EXEC sp_rename 'product_info.product_name_lenght', 'product_name_length', 'COLUMN'
EXEC sp_rename 'product_info.product_description_lenght', 'product_description_length', 'COLUMN'


--==================================================================================================================
--======== Order Rating Table ======
--==================================

SELECT * FROM OrderRat_ing

SELECT order_id, AVG(Customer_Satisfaction_Score) as avg_satisfaction_score
FROM OrderRat_ing
GROUP BY order_id


--===================================================================================================================
--======= Order Payment Table ========
--====================================
select * from OrderPay_ment
where payment_value = 0

select order_id, payment_type , payment_value, sum(payment_value) over (partition by order_id) as Total_Amt from OrderPay_ment
order by Total_Amt desc

select distinct order_id,payment_type,payment_value,sum(payment_value) over (partition by order_id) as Total_Amt from OrderPay_ment
where order_id='1c11d0f4353b31ac3417fbfa5f0f2a8a'

select order_id,payment_type,payment_value,sum(payment_value) over (partition by order_id) as Total_Amt from OrderPay_ment
where order_id='1c11d0f4353b31ac3417fbfa5f0f2a8a'


--========================================================================================================================
--============= ORDER TABLE CLEANING ============
--===============================================

-- The very first thing we'll do is to compare the Total_Amount of Order_info Table with the Payment_Value of Order_Payment Table,
-- On the basis of each order_IDs.
-- It will give us 88,631 matching records (Using INTERSECT) & 24,019 mis-matched records (Using EXCEPT)
-- We'll separate both the records in different table say "order1" and "order2" respectively.

WITH orderid AS
(SELECT DISTINCT order_id
FROM Order_info

--INTERSECT
EXCEPT

SELECT Y.order_id
FROM 
    (SELECT order_id, SUM(ROUND(payment_value,2)) AS TPV 
     FROM OrderPay_ment 
     GROUP BY order_id) AS X
INNER JOIN 
    (SELECT order_id, SUM(ROUND(Total_Amount,2)) AS TA 
     FROM Order_info
     GROUP BY order_id) AS Y
ON X.order_id = Y.order_id
WHERE ABS(ROUND(TPV, 0) - ROUND(TA, 0)) < 1)

SELECT X.* FROM Order_info AS X
INNER JOIN orderid AS Y
ON X.order_id=Y.order_id

--HERE ARE THOSE TABLES :
SELECT * FROM order1
SELECT * FROM order2

--==========================================================
-- Now we have to treat the 24,019 records which are there in order2 table. For that we are going to use the DENSE_RANK function
-- Purpose : To select the product_id with Maximum Quantity, wherever there are cumlative quantity exist. It will give 13,794 records with RANK 1.
-- We're going to put all these records as "order3" as we are suppose to match these records with Payment_Value column of Order_Payment table.

WITH CTE1 AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY order_id, product_id ORDER BY Quantity  DESC) AS Ranks
    FROM order2 )
SELECT Customer_id, order_id, product_id, Channel, Delivered_StoreID, Bill_date_timestamp, Quantity, Cost_Per_Unit, MRP, Discount, Total_Amount
FROM CTE1
WHERE Ranks = 1

-- HERE IS THE TABLE :
SELECT * FROM order3

--==========================================================
-- When we matched the records of Total_Amount of Order3 Table with the Payment_Value of Order_Payment Table,
-- On the basis of order_IDs, and it will give us 6,553 matching records.
-- Lets put these in a separate table say order4, so that we can append it with order1 Table having matched 88,631 records.

WITH orderid AS
(SELECT DISTINCT order_id
FROM order3

INTERSECT

SELECT Y.order_id
FROM 
    (SELECT order_id, SUM(ROUND(payment_value, 2)) AS TPV 
     FROM OrderPay_ment 
     GROUP BY order_id) AS X
INNER JOIN 
    (SELECT order_id, SUM(ROUND(Total_Amount, 2)) AS TA 
     FROM order3
     GROUP BY order_id) AS Y
ON X.order_id = Y.order_id
WHERE ABS(ROUND(TPV, 0) - ROUND(TA, 0)) < 1)

SELECT X.* FROM order3 AS X
INNER JOIN orderid AS Y
ON X.order_id = Y.order_id

-- HERE IS THE TABLE :
SELECT * FROM order4

--=============================================================
/*
-- Since these above 6,553 records are distinct orderIDs, with rank 1, we have to remove all the other records of these orderIDs,
   associated with other rankings, from the order2 Table (having untreated 24,019 records).
-- We will add these distinct orderID's record with order1 Table (having matched 88,631 records). Since we added them with matching records,
   we can delete them from unmatched table.
*/

-- After leaving those orderIDs that are there in the order4 Table, we are left with only 8,032 records that needs to be treated.
-- Let's put them in a new table name, order5

WITH CTE2 AS 
 (SELECT DISTINCT order_id FROM order2
 EXCEPT
  SELECT DISTINCT order_id FROM order4)

 SELECT X.* INTO order5 FROM order2 AS X
 INNER JOIN CTE2 AS Y
 ON X.order_id = Y.order_id

 -- HERE IS THE TABLE:
 SELECT * FROM order5

--=============================================================
/*
-- Out of those 8032 records, if we neglect the Quantity, and then calculate the Total_Amount, we get the 3221 matching records with
   Order_Payment Table's Payment_Value column.
-- Purpose of doing so is, there are many orderIDs having different products but their Quantity count is cumulative. For those products,
   Quantity column is not about the purchasing the same item many times but, maximum of it, refers to the no. of products that has been purchased in that single order.
*/

-- Lets put these 7725 records in a separate table say order6, so that we can append it with order1 and order4 Table having matched records.
-- These 7,725 records are having 

WITH CTE3 AS (

SELECT X.order_id FROM 
	(SELECT order_id,(SUM(ROUND(MRP, 2)) - SUM(Discount)) AS TA FROM order5
	GROUP BY order_id) AS X
INNER JOIN
	(SELECT order_id,SUM(ROUND(payment_value,2)) AS TPV FROM OrderPay_ment
    GROUP BY order_id) AS Y
ON X.order_id=Y.order_id
WHERE ABS(ROUND(TA, 0) - ROUND(TPV, 0))<1)                                      -- 3221 distinct orderIDs are matching

SELECT X.* FROM order5 AS X                                                     -- These much Dist. OrderIDs having 7725 recods in the order5 Table.
INNER JOIN CTE3 AS Y
ON X.order_id = Y.order_id

-- HERE IS THE TABLE :
SELECT * FROM order6

--================================================================

-- Now since these 7725 records also have been added to the matched records, we can delete them from unmatched records.
-- Hence we are left with (8032 - 7725) = 307 number of records, having 261 distinct orderIDs as order7 Table.

WITH CTE4 AS
  	(SELECT X.order_id FROM 
  	(SELECT order_id,(SUM(ROUND(MRP, 2))-SUM(Discount)) AS TA FROM order5
  	GROUP BY order_id) AS X
  INNER JOIN
  	(SELECT order_id,SUM(payment_value) AS TPV FROM OrderPay_ment
      GROUP BY order_id) AS Y
  ON X.order_id=Y.order_id
  WHERE ABS(ROUND(TA, 0) - ROUND(TPV, 0))<1),

CTE5 AS 
	(SELECT DISTINCT order_id FROM order5
	EXCEPT
	SELECT DISTINCT order_id FROM CTE4)

SELECT X.* FROM order5 AS X
INNER JOIN CTE5 AS Y
ON X.order_id = Y.order_id

-- HERE IS THE TABLE:
SELECT * FROM order7

-- There are no pattern left, that we can observe, that's why assuming that we can't treat these 307 records, we are left with
-- matching records that are in order1, order4 and order6 Tables.

-- Before appending these three tables, let's replace the values of Quantity column with 1 in the order6 Table.

UPDATE order6
SET Quantity = 1
WHERE Quantity > 1

-- Also we have to fix the Total_Amount column in order6 Table as we've changed the quantity.

UPDATE order6
SET Total_Amount = MRP - Discount

-- Now let's check the records of order6 again with Order_Payment table for same Amount and Payment_value

SELECT Y.order_id
FROM 
    (SELECT order_id, SUM(ROUND(payment_value,2)) AS TPV 
     FROM OrderPay_ment 
     GROUP BY order_id) AS X
INNER JOIN 
    (SELECT order_id, SUM(ROUND(Total_Amount,2)) AS TA 
     FROM order6
     GROUP BY order_id) AS Y
ON X.order_id = Y.order_id
WHERE ABS(ROUND(TPV, 0) - ROUND(TA, 0)) < 1                           

-- All the 3221 distinct OrderIDs are matching, hence all the 7725 records of order6 table are matched with Order_Payment table.

-- Now we'll since we want to show the Delivered_storeID, having the maximum amount in each record of the table. So we update the Delivered_store_ID column.
-- Also we'll do the same only for the channels, Instore and Phone Delivery, as Online mode can have different stores.

WITH StoreRank AS (
    SELECT 
        order_id,
        Delivered_StoreID,
        SUM([Total_Amount]) AS TotalAmount,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY SUM(Total_Amount) DESC) AS Row_Num
    FROM order6
    GROUP BY order_id, Delivered_StoreID
)
UPDATE O
SET O.Delivered_StoreID = M.Delivered_StoreID
FROM order6 as O
INNER JOIN StoreRank as M
    ON O.order_id = M.order_id
WHERE M.Row_Num = 1 and Channel in ('Instore','Phone Delivery')

-- Now here is the refined roder6 table :
SELECT * FROM order6

-- But there are records, which are having record level duplicacy because of same quantity and same amount. So we have to club those records.

SELECT Customer_id, order_id, product_id, Channel, Delivered_StoreID, Bill_date_timestamp, SUM(Quantity) Quantity, Cost_Per_Unit, MRP, Discount, SUM(Total_Amount) Total_Amount
FROM order6
GROUP BY Customer_id, order_id, product_id, Channel, Delivered_StoreID, Bill_date_timestamp, Cost_Per_Unit, MRP, Discount	

-- Thus we'll get 7,283 records as order6 out of all 7,725 records. We'll save them as "order6N"
-- HERE IS THE TABLE :
SELECT * FROM order6N
--===================================================
-- Now the Final Order Table that we have is this : Order_Final
--===================================================
SELECT * FROM
(SELECT * FROM order1          -- 88,631 records
UNION
SELECT * FROM order4           -- 6553 records
UNION
SELECT * FROM order6N) AS X    -- 7283 records

-- HERE IS THE TABLE :
SELECT * FROM Order_Final      -- Having 98,314 unique Customer's data and 98,405 unique orderIDs

--======================================================================================================================================================================================




