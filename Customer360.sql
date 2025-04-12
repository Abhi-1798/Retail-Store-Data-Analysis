
SELECT 
    C.*, 
    MIN(O.Bill_date_timestamp) AS [FIRST_TRANS_DATE], 
    MAX(O.Bill_date_timestamp) AS [LAST_TRANS_DATE],
    DATEDIFF(DAY, MIN(O.Bill_date_timestamp), MAX(O.Bill_date_timestamp)) AS TENURE,
    DATEDIFF(DAY, MAX(O.Bill_date_timestamp), (SELECT MAX(Bill_date_timestamp) FROM Order_Final)) AS Inactive_Days,
    COUNT(DISTINCT O.order_id) AS Frequency,
    SUM(O.Quantity * (O.MRP - O.Discount)) AS Monetory,
    SUM(O.Quantity * (O.MRP - O.Discount)) - SUM(O.Quantity * O.Cost_Per_Unit) AS Profit,
    SUM(O.Discount) AS Tot_Discount,
    SUM(O.Quantity) AS TOT_PROD_QTY,
    COUNT(DISTINCT O.product_id) AS Distinct_PROD_QTY,
    COUNT(DISTINCT O.Delivered_StoreID) AS Distinct_StoreID,
    COUNT(DISTINCT P.Category) AS Distinct_Category,
    -- Count no of Purchase with discounts
    COUNT(CASE WHEN O.Discount > 0 THEN (O.order_id) ELSE NULL END) AS No_Of_Trans_with_Disc,
	-- Amount paid using Credit Card
	SUM(CASE WHEN PY.payment_type = 'Credit_Card' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS CC_pay,
	-- Amount paid using Debit Card
	SUM(CASE WHEN PY.payment_type = 'Debit_Card' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS DC_pay,
	-- Amount paid using UPI/Cash
	SUM(CASE WHEN PY.payment_type = 'UPI/Cash' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS UPI_Cash_pay,
	-- Amount paid using Voucher
	SUM(CASE WHEN PY.payment_type = 'Voucher' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Vouch_pay,
    
	-- Instore order Frequency
    COUNT(DISTINCT CASE WHEN O.channel = 'Instore' THEN (O.order_id) ELSE NULL END) AS Freq_Instore,
    -- Instore monetory value
    SUM(CASE WHEN O.channel = 'Instore' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Instore,
    -- Profit from instore transactions
    SUM(CASE WHEN O.channel = 'Instore' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Instore,
	-- Total Product Quantity in Instore Purchase
	SUM(CASE WHEN O.Channel = 'Instore' THEN (O.Quantity) ELSE 0 END) AS TOT_INSTORE_PROD_QTY,
	-- Total DISTINCT Product Quantity in Instore Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Instore' THEN (O.product_id) ELSE NULL END) AS TOT_Dstinct_PROD_QTY_Instore,
	-- Total DISTINCT Category Quantity in Instore Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Instore' THEN (P.Category) ELSE NULL END) AS TOT_Dstinct_Cate_QTY_Instore,
	-- Total no. of orders with discount in Instore Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Instore' AND O.Discount > 0 THEN (O.order_id) ELSE NULL END) AS No_of_orders_with_Disc_Instore,
	-- No. of Distinct Stores in Instore Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Instore' THEN (O.Delivered_StoreID) ELSE NULL END) AS No_of_Distinct_Stores_Instore,
	-- Total no. of products with discount in Instore Purchase
	COUNT(CASE WHEN O.Channel = 'Instore' AND O.Discount > 0 THEN (O.order_id) ELSE NULL END) AS No_of_prod_with_Disc_Instore,
	-- Amount paid using Credit Card in Instore
	SUM(CASE WHEN PY.payment_type = 'Credit_Card' AND O.channel = 'Instore' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Instore_CC_pay,
	-- Amount paid using Debit Card in Instore
	SUM(CASE WHEN PY.payment_type = 'Debit_Card' AND O.channel = 'Instore' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Instore_DC_pay,
	-- Amount paid using UPI/Cash in Instore
	SUM(CASE WHEN PY.payment_type = 'UPI/Cash' AND O.channel = 'Instore' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Instore_UPI_Cash_pay,
	-- Amount paid using Voucher in Instore
	SUM(CASE WHEN PY.payment_type = 'Voucher' AND O.channel = 'Instore' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Instore_Vouch_pay,

	-- Phone Delivery order frequency
    COUNT(DISTINCT CASE WHEN O.channel = 'Phone Delivery' THEN (O.order_id) ELSE NULL END) AS Freq_Phone_Del,
    -- Phone Delivery monetory value
    SUM(CASE WHEN O.channel = 'Phone Delivery' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Phone_Del,
    -- Profit from Phone Delivery transaction
    SUM(CASE WHEN O.channel = 'Phone Delivery' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Phone_Del,
	-- Total Product Quantity in PhoneDelivery Purchase
	SUM(CASE WHEN O.Channel = 'Phone Delivery' THEN (O.Quantity) ELSE 0 END) AS TOT_Phone_Del_PROD_QTY,
	-- Total DISTINCT Product Quantity in PhoneDelivery Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Phone Delivery' THEN (O.product_id) ELSE NULL END) AS TOT_Dstinct_PROD_QTY_Phone_Del,
	-- Total DISTINCT Category Quantity in PhoneDelivery Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Phone Delivery' THEN (P.Category) ELSE NULL END) AS TOT_Dstinct_Cate_QTY_Phone_Del,
	-- Total no. of orders with discount in PhoneDelivery Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'PhoneDelivery' AND O.Discount > 0 THEN (O.order_id) ELSE NULL END) AS No_of_orders_with_Disc_Phone_Del,
	-- No. of Distinct Stores in PhoneDelivery Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'PhoneDelivery' THEN (O.Delivered_StoreID) ELSE NULL END) AS No_of_Distinct_Stores_Phone_Del,
	-- Total no. of products with discount in PhoneDelivery Purchase
	COUNT(CASE WHEN O.Channel = 'PhoneDelivery' AND O.Discount > 0 THEN (O.order_id) ELSE NULL END) AS No_of_prod_with_Disc_Phone_Del,
	-- Amount paid using Credit Card in PhoneDelivery
	SUM(CASE WHEN PY.payment_type = 'Credit_Card' AND O.channel = 'Phone Delivery' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Phone_Del_CC_pay,
	-- Amount paid using Debit Card in PhoneDelivery
	SUM(CASE WHEN PY.payment_type = 'Debit_Card' AND O.channel = 'Phone Delivery' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Phone_Del_DC_pay,
	-- Amount paid using UPI/Cash in PhoneDelivery
	SUM(CASE WHEN PY.payment_type = 'UPI/Cash' AND O.channel = 'Phone Delivery' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Phone_Del_UPI_Cash_pay,
	-- Amount paid using Voucher in PhoneDelivery
	SUM(CASE WHEN PY.payment_type = 'Voucher' AND O.channel = 'Phone Delivery' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Phone_Del_Vouch_pay,
 
	-- Online order frequency
    COUNT(DISTINCT CASE WHEN O.channel = 'Online' THEN (O.order_id) ELSE NULL END) AS Freq_Online,
    -- Online monetory value
    SUM(CASE WHEN O.channel = 'Online' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Online,
    -- Profit from Online transaction
    SUM(CASE WHEN O.channel = 'Online' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Online,
	-- Total Product Quantity in Online Purchase
	SUM(CASE WHEN O.Channel = 'Online' THEN (O.Quantity) ELSE 0 END) AS TOT_Online_PROD_QTY,
	-- Total DISTINCT Product Quantity in Online Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Online' THEN (O.product_id) ELSE NULL END) AS TOT_Dstinct_PROD_QTY_Online,
	-- Total DISTINCT Category Quantity in Online Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Online' THEN (P.Category) ELSE NULL END) AS TOT_Dstinct_Cate_QTY_Online,
	-- Total no. of orders with discount in Online Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Online' AND O.Discount > 0 THEN (O.order_id) ELSE NULL END) AS No_of_orders_with_Disc_Online,
	-- No. of Distinct Stores in Online Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Online' THEN (O.Delivered_StoreID) ELSE NULL END) AS No_of_Distinct_Stores_Online,
	-- Total no. of products with discount in Online Purchase
	COUNT(CASE WHEN O.Channel = 'Online' AND O.Discount > 0 THEN (O.order_id) ELSE NULL END) AS No_of_prod_with_Disc_Online,
	-- Amount paid using Credit Card in Online
	SUM(CASE WHEN PY.payment_type = 'Credit_Card' AND O.channel = 'Online' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Online_CC_pay,
	-- Amount paid using Debit Card in Online
	SUM(CASE WHEN PY.payment_type = 'Debit_Card' AND O.channel = 'Online' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Online_DC_pay,
	-- Amount paid using UPI/Cash in Online
	SUM(CASE WHEN PY.payment_type = 'UPI/Cash' AND O.channel = 'Online' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Online_UPI_Cash_pay,
	-- Amount paid using Voucher in Online
	SUM(CASE WHEN PY.payment_type = 'Voucher' AND O.channel = 'Online' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Online_Vouch_pay,

	-- AUTO Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Auto' THEN (O.order_id) ELSE NULL END) AS No_of_trans_Auto,
	COUNT(CASE WHEN P.Category = 'Auto' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Auto,
	SUM(CASE WHEN P.Category = 'Auto' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Auto,
	SUM(CASE WHEN P.Category = 'Auto' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Auto,
	SUM(CASE WHEN P.Category = 'Auto' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Auto,

	-- BABY Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Baby' THEN (O.order_id) ELSE NULL END) AS No_of_trans_Baby,
	COUNT(CASE WHEN P.Category = 'Baby' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Baby,
	SUM(CASE WHEN P.Category = 'Baby' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Baby,
	SUM(CASE WHEN P.Category = 'Baby' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Baby,
	SUM(CASE WHEN P.Category = 'Baby' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Baby,

	-- Computers & Accessories Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Computers & Accessories' THEN (O.order_id) ELSE NULL END) AS No_of_trans_ComAcs,
	COUNT(CASE WHEN P.Category = 'Computers & Accessories' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_ComAcs,
	SUM(CASE WHEN P.Category = 'Computers & Accessories' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_ComAcs,
	SUM(CASE WHEN P.Category = 'Computers & Accessories' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_ComAcs,
	SUM(CASE WHEN P.Category = 'Computers & Accessories' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_ComAcs,

	-- Construction_Tools Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Construction_Tools' THEN (O.order_id) ELSE NULL END) AS No_of_trans_Contool,
	COUNT(CASE WHEN P.Category = 'Construction_Tools' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Contool,
	SUM(CASE WHEN P.Category = 'Construction_Tools' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Contool,
	SUM(CASE WHEN P.Category = 'Construction_Tools' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Contool,
	SUM(CASE WHEN P.Category = 'Construction_Tools' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Contool,

	-- Electronics Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Electronics' THEN (O.order_id) ELSE NULL END) AS No_of_trans_Elect,
	COUNT(CASE WHEN P.Category = 'Electronics' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Elect,
	SUM(CASE WHEN P.Category = 'Electronics' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Elect,
	SUM(CASE WHEN P.Category = 'Electronics' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Elect,
	SUM(CASE WHEN P.Category = 'Electronics' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Elect,

	-- Fashion Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Fashion' THEN (O.order_id) ELSE NULL END) AS No_of_trans_Fashion,
	COUNT(CASE WHEN P.Category = 'Fashion' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Fashion,
	SUM(CASE WHEN P.Category = 'Fashion' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Fashion,
	SUM(CASE WHEN P.Category = 'Fashion' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Fashion,
	SUM(CASE WHEN P.Category = 'Fashion' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Fashion,

	-- Food & Beverages Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Food & Beverages' THEN (O.order_id) ELSE NULL END) AS No_of_trans_Food_Bev,
	COUNT(CASE WHEN P.Category = 'Food & Beverages' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Food_Bev,
	SUM(CASE WHEN P.Category = 'Food & Beverages' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Food_Bev,
	SUM(CASE WHEN P.Category = 'Food & Beverages' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Food_Bev,
	SUM(CASE WHEN P.Category = 'Food & Beverages' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Food_Bev,
	
	-- Furniture Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Furniture' THEN (O.order_id) ELSE NULL END) AS No_of_trans_Furniture,
	COUNT(CASE WHEN P.Category = 'Furniture' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Furniture,
	SUM(CASE WHEN P.Category = 'Furniture' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Furniture,
	SUM(CASE WHEN P.Category = 'Furniture' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Furniture,
	SUM(CASE WHEN P.Category = 'Furniture' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Furniture,
	
	-- Home Appliances Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Home_Appliances' THEN (O.order_id) ELSE NULL END) AS No_of_trans_Home_Appliances,
	COUNT(CASE WHEN P.Category = 'Home_Appliances' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Home_Appliances,
	SUM(CASE WHEN P.Category = 'Home_Appliances' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Home_Appliances,
	SUM(CASE WHEN P.Category = 'Home_Appliances' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Home_Appliances,
	SUM(CASE WHEN P.Category = 'Home_Appliances' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Home_Appliances,
	
	-- Luggage Accessories Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Luggage_Accessories' THEN (O.order_id) ELSE NULL END) AS No_of_trans_Luggage,
	COUNT(CASE WHEN P.Category = 'Luggage_Accessories' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Luggage,
	SUM(CASE WHEN P.Category = 'Luggage_Accessories' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Luggage,
	SUM(CASE WHEN P.Category = 'Luggage_Accessories' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Luggage,
	SUM(CASE WHEN P.Category = 'Luggage_Accessories' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Luggage,
	
	-- Pet Shop Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Pet_Shop' THEN (O.order_id) ELSE NULL END) AS No_of_trans_Pet_Shop,
	COUNT(CASE WHEN P.Category = 'Pet_Shop' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Pet_Shop,
	SUM(CASE WHEN P.Category = 'Pet_Shop' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Pet_Shop,
	SUM(CASE WHEN P.Category = 'Pet_Shop' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Pet_Shop,
	SUM(CASE WHEN P.Category = 'Pet_Shop' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Pet_Shop,
	
	-- Stationery Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Stationery' THEN (O.order_id) ELSE NULL END) AS No_of_trans_Stationery,
	COUNT(CASE WHEN P.Category = 'Stationery' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Stationery,
	SUM(CASE WHEN P.Category = 'Stationery' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Stationery,
	SUM(CASE WHEN P.Category = 'Stationery' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Stationery,
	SUM(CASE WHEN P.Category = 'Stationery' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Stationery,
	
	-- Toys & Gifts Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Toys & Gifts' THEN (O.order_id) ELSE NULL END) AS No_of_trans_Toys_Gifts,
	COUNT(CASE WHEN P.Category = 'Toys & Gifts' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Toys_Gifts,
	SUM(CASE WHEN P.Category = 'Toys & Gifts' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Toys_Gifts,
	SUM(CASE WHEN P.Category = 'Toys & Gifts' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Toys_Gifts,
	SUM(CASE WHEN P.Category = 'Toys & Gifts' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Toys_Gifts,

	-- Classification of customer based on their spending
	CASE 
        WHEN SUM(O.Quantity * (O.MRP - O.Discount)) > 9018 THEN 'High spender'
        WHEN SUM(O.Quantity * (O.MRP - O.Discount)) <= 9018 AND SUM(O.Quantity * (O.MRP - O.Discount)) >= 4509 THEN 'Medium spender'
        ELSE 'Low spender'
    END AS Customer_Segment1,
	
	-- Classification of customer based on their frequncy of orders
	CASE 
        WHEN COUNT(DISTINCT O.order_id) > 9 THEN 'Frequent Buyer'
        WHEN COUNT(DISTINCT O.order_id) <= 9 AND COUNT(DISTINCT O.order_id) >= 3 THEN 'Reguler Buyer'
        ELSE 'Ocassionly Buyer'
    END AS Customer_Segment2,

	-- Classification of customer based on their Tenure
	CASE 
		WHEN DATEDIFF(DAY, MIN(O.Bill_date_timestamp), MAX(O.Bill_date_timestamp)) > 112 THEN 'High Engagement'
		WHEN DATEDIFF(DAY, MIN(O.Bill_date_timestamp), MAX(O.Bill_date_timestamp)) < 112 AND
			 DATEDIFF(DAY, MIN(O.Bill_date_timestamp), MAX(O.Bill_date_timestamp)) > 28 THEN 'Medium Engagement'
		WHEN DATEDIFF(DAY, MIN(O.Bill_date_timestamp), MAX(O.Bill_date_timestamp)) < 28 AND
			 DATEDIFF(DAY, MIN(O.Bill_date_timestamp), MAX(O.Bill_date_timestamp)) > 0 THEN 'Low Engagement' ELSE 'No Engagement' 
	END AS Customer_Segment3

FROM 
    Cust_info C
INNER JOIN 
    Order_Final O ON C.Custid = O.Customer_id
INNER JOIN 
    Product_Info P ON O.product_id = P.product_id
INNER JOIN 
   OrderPay_ment PY ON O.order_id = PY.order_id
GROUP BY C.Custid, C.customer_city, C.customer_state, C.Gender




/*
--======================================================================================================================================================
--====:ROUGH WORK:====
--====================
AND COUNT(DISTINCT O.order_id) > 8 
AND COUNT(DISTINCT O.order_id) <= 8 AND COUNT(DISTINCT O.order_id) > 4 
WHEN SUM(O.Quantity * (O.MRP - O.Discount)) < 4509 AND COUNT(DISTINCT O.order_id) < 4 THEN 'Low Value Customer'
WHEN DATEDIFF(DAY, MAX(O.Bill_date_timestamp), (SELECT MAX(Bill_date_timestamp) FROM BASE)) > 90 THEN 'Low Engagement'

SELECT MAX(O.Bill_date_timestamp) FROM BASE

SELECT COUNT(DISTINCT order_id) P FROM BASE
GROUP BY Customer_id
ORDER BY P DESC               -- 12 ORDERS MAX  SO,  9 IS P75 AND 3 IS P25

SELECT SUM(Quantity * (MRP - Discount)) Q FROM BASE
GROUP BY Customer_id
ORDER BY Q DESC               -- 13664 INR MAX SPENT  SO, 9018 IS P66 AND 4509 IS P33

SELECT customer_id, DATEDIFF(DAY, min(Bill_date_timestamp), MAX(Bill_date_timestamp)) R FROM Order360
GROUP BY Customer_id
ORDER BY R DESC               -- 692 days  P75 IS 112days  P50 will be 28 days       (only 370 customers are buying more than 1 time on diff dates.)

*/


