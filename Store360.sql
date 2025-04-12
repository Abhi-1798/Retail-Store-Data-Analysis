
SELECT 
    S.*,
	COUNT(DISTINCT O.customer_id) AS No_of_Customers,
	-- Count of cities the store is catering
	COUNT(DISTINCT CASE WHEN C.Custid = O.Customer_id THEN (C.customer_city) ELSE NULL END) AS No_of_Covered_cities,
	-- Count of total Purchases
	COUNT(DISTINCT O.order_id) AS Frequency,
	-- Number of Purchases with discounts
    COUNT(CASE WHEN O.Discount > 0 THEN (O.order_id) ELSE NULL END) AS No_Of_Trans_with_Disc,
	COUNT(DISTINCT O.product_id) AS Distinct_PROD_QTY,
	SUM(O.Quantity) AS TOT_PROD_QTY,
	COUNT(DISTINCT P.Category) AS Distinct_Category,
    MIN(O.Bill_date_timestamp) AS First_Sale_Date, 
    MAX(O.Bill_date_timestamp) AS Last_Sale_Date,
	((SUM(O.Quantity * (O.MRP - O.Discount)))/(DATEDIFF(DAY, MIN(O.Bill_date_timestamp), MAX(O.Bill_date_timestamp)))) AS Avg_daily_Sale,	
    SUM(O.Quantity * (O.MRP - O.Discount)) AS Total_Revenue,
    SUM(O.Quantity * (O.MRP - O.Discount)) - SUM(O.Quantity * O.Cost_Per_Unit) AS Profit,
    SUM(O.Discount) AS Tot_Discount_given,
    -- Amount paid using Credit Card
	SUM(CASE WHEN PY.payment_type = 'Credit_Card' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS CC_pay,
	-- Amount paid using Debit Card
	SUM(CASE WHEN PY.payment_type = 'Debit_Card' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS DC_pay,
	-- Amount paid using UPI/Cash
	SUM(CASE WHEN PY.payment_type = 'UPI/Cash' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS UPI_Cash_pay,
	-- Amount paid using Voucher
	SUM(CASE WHEN PY.payment_type = 'Voucher' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Vouch_pay,

	-- Total no of distinct Customers with store via Online
	COUNT(CASE WHEN O.channel = 'Online' THEN O.Customer_id ELSE NULL END) AS Tot_Online_Customers,
	-- Total no. of sale via Online
    COUNT(CASE WHEN O.channel = 'Online' THEN (O.order_id) ELSE NULL END) AS Freq_Online,
	-- Total no. of purchase with discount in Online Purchase
	COUNT(CASE WHEN O.Channel = 'Online' AND O.Discount > 0 THEN (O.order_id) ELSE NULL END) AS No_of_Tran_with_Disc_Online,
    -- Online monetory value
    SUM(CASE WHEN O.channel = 'Online' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Online,
    -- Profit from Online transaction
    SUM(CASE WHEN O.channel = 'Online' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Online,
	-- Total discount given on Online channel
	SUM(CASE WHEN O.channel = 'Online' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Online,
	-- Total Product Quantity in Online Purchase
	SUM(CASE WHEN O.Channel = 'Online' THEN (O.Quantity) ELSE 0 END) AS TOT_Online_PROD_QTY,
	-- Total DISTINCT Product Quantity in Online Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Online' THEN (O.product_id) ELSE NULL END) AS TOT_Dstinct_PROD_QTY_Online,
	-- Total DISTINCT Category Quantity in Online Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Online' THEN (P.Category) ELSE NULL END) AS TOT_Dstinct_Cate_QTY_Online,	
	-- Amount paid using Credit Card in Online
	SUM(CASE WHEN PY.payment_type = 'Credit_Card' AND O.channel = 'Online' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Online_CC_pay,
	-- Amount paid using Debit Card in Online
	SUM(CASE WHEN PY.payment_type = 'Debit_Card' AND O.channel = 'Online' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Online_DC_pay,
	-- Amount paid using UPI/Cash in Online
	SUM(CASE WHEN PY.payment_type = 'UPI/Cash' AND O.channel = 'Online' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Online_UPI_Cash_pay,
	-- Amount paid using Voucher in Online
	SUM(CASE WHEN PY.payment_type = 'Voucher' AND O.channel = 'Online' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Online_Vouch_pay,
    
    -- Total no of distinct Customers with store via Instore
	COUNT(CASE WHEN O.channel = 'Instore' THEN O.Customer_id ELSE NULL END) AS Tot_Instore_Customers,
	-- Total no. of sale via Instore
	COUNT(CASE WHEN O.channel = 'Instore' THEN (O.order_id) ELSE NULL END) AS Freq_Instore,
	-- Total no. of purchase with discount in Instore Purchase
	COUNT(CASE WHEN O.Channel = 'Instore' AND O.Discount > 0 THEN (O.order_id) ELSE NULL END) AS No_of_Tran_with_Disc_Instore,
	-- Instore monetary value
	SUM(CASE WHEN O.channel = 'Instore' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetary_Instore,
	-- Profit from Instore transaction
	SUM(CASE WHEN O.channel = 'Instore' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Instore,
	-- Total discount given on Instore channel
	SUM(CASE WHEN O.channel = 'Instore' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Instore,
	-- Total Product Quantity in Instore Purchase
	SUM(CASE WHEN O.Channel = 'Instore' THEN (O.Quantity) ELSE 0 END) AS TOT_Instore_PROD_QTY,
	-- Total DISTINCT Product Quantity in Instore Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Instore' THEN (O.product_id) ELSE NULL END) AS TOT_Dstinct_PROD_QTY_Instore,
	-- Total DISTINCT Category Quantity in Instore Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Instore' THEN (P.Category) ELSE NULL END) AS TOT_Dstinct_Cate_QTY_Instore,	
	-- Amount paid using Credit Card in Instore
	SUM(CASE WHEN PY.payment_type = 'Credit_Card' AND O.channel = 'Instore' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Instore_CC_pay,
	-- Amount paid using Debit Card in Instore
	SUM(CASE WHEN PY.payment_type = 'Debit_Card' AND O.channel = 'Instore' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Instore_DC_pay,
	-- Amount paid using UPI/Cash in Instore
	SUM(CASE WHEN PY.payment_type = 'UPI/Cash' AND O.channel = 'Instore' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Instore_UPI_Cash_pay,
	-- Amount paid using Voucher in Instore
	SUM(CASE WHEN PY.payment_type = 'Voucher' AND O.channel = 'Instore' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS Instore_Vouch_pay,

    -- Total no of distinct Customers with store via Phone Delivery
	COUNT(CASE WHEN O.channel = 'Phone Delivery' THEN O.Customer_id ELSE NULL END) AS Tot_PhoneDelivery_Customers,
	-- Total no. of sale via Phone Delivery
	COUNT(CASE WHEN O.channel = 'Phone Delivery' THEN (O.order_id) ELSE NULL END) AS Freq_PhoneDelivery,
	-- Total no. of purchase with discount in Phone Delivery Purchase
	COUNT(CASE WHEN O.Channel = 'Phone Delivery' AND O.Discount > 0 THEN (O.order_id) ELSE NULL END) AS No_of_Tran_with_Disc_PhoneDelivery,
	-- Phone Delivery monetary value
	SUM(CASE WHEN O.channel = 'Phone Delivery' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetary_PhoneDelivery,
	-- Profit from Phone Delivery transaction
	SUM(CASE WHEN O.channel = 'Phone Delivery' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_PhoneDelivery,
	-- Total discount given on Phone Delivery channel
	SUM(CASE WHEN O.channel = 'Phone Delivery' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_PhoneDelivery,
	-- Total Product Quantity in Phone Delivery Purchase
	SUM(CASE WHEN O.Channel = 'Phone Delivery' THEN (O.Quantity) ELSE 0 END) AS TOT_PhoneDelivery_PROD_QTY,
	-- Total DISTINCT Product Quantity in Phone Delivery Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Phone Delivery' THEN (O.product_id) ELSE NULL END) AS TOT_Dstinct_PROD_QTY_PhoneDelivery,
	-- Total DISTINCT Category Quantity in Phone Delivery Purchase
	COUNT(DISTINCT CASE WHEN O.Channel = 'Phone Delivery' THEN (P.Category) ELSE NULL END) AS TOT_Dstinct_Cate_QTY_PhoneDelivery,	
	-- Amount paid using Credit Card in Phone Delivery
	SUM(CASE WHEN PY.payment_type = 'Credit_Card' AND O.channel = 'Phone Delivery' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS PhoneDelivery_CC_pay,
	-- Amount paid using Debit Card in Phone Delivery
	SUM(CASE WHEN PY.payment_type = 'Debit_Card' AND O.channel = 'Phone Delivery' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS PhoneDelivery_DC_pay,
	-- Amount paid using UPI/Cash in Phone Delivery
	SUM(CASE WHEN PY.payment_type = 'UPI/Cash' AND O.channel = 'Phone Delivery' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS PhoneDelivery_UPI_Cash_pay,
	-- Amount paid using Voucher in Phone Delivery
	SUM(CASE WHEN PY.payment_type = 'Voucher' AND O.channel = 'Phone Delivery' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END ) AS PhoneDelivery_Vouch_pay,

    -- BABY Category related Information per Customer :
	COUNT(DISTINCT CASE WHEN P.Category = 'Baby' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Baby,
	COUNT(CASE WHEN P.Category = 'Baby' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Baby,
	SUM(CASE WHEN P.Category = 'Baby' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Baby,
	SUM(CASE WHEN P.Category = 'Baby' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Baby,
	SUM(CASE WHEN P.Category = 'Baby' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Baby,

	-- AUTO Category-related Information per Store:
	COUNT(DISTINCT CASE WHEN P.Category = 'Auto' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Auto,
	COUNT(CASE WHEN P.Category = 'Auto' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Auto,
	SUM(CASE WHEN P.Category = 'Auto' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Auto,
	SUM(CASE WHEN P.Category = 'Auto' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Auto,
	SUM(CASE WHEN P.Category = 'Auto' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Auto,
	
	-- FASHION Category-related Information per Store:
	COUNT(DISTINCT CASE WHEN P.Category = 'Fashion' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Fashion,
	COUNT(CASE WHEN P.Category = 'Fashion' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Fashion,
	SUM(CASE WHEN P.Category = 'Fashion' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Fashion,
	SUM(CASE WHEN P.Category = 'Fashion' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Fashion,
	SUM(CASE WHEN P.Category = 'Fashion' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Fashion,
	
	-- FOOD & BEVERAGES Category-related Information per Store:
	COUNT(DISTINCT CASE WHEN P.Category = 'Food & Beverages' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Food_Beverages,
	COUNT(CASE WHEN P.Category = 'Food & Beverages' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Food_Beverages,
	SUM(CASE WHEN P.Category = 'Food & Beverages' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Food_Beverages,
	SUM(CASE WHEN P.Category = 'Food & Beverages' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Food_Beverages,
	SUM(CASE WHEN P.Category = 'Food & Beverages' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Food_Beverages,
	
	-- FURNITURE Category-related Information per Store:
	COUNT(DISTINCT CASE WHEN P.Category = 'Furniture' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Furniture,
	COUNT(CASE WHEN P.Category = 'Furniture' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Furniture,
	SUM(CASE WHEN P.Category = 'Furniture' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Furniture,
	SUM(CASE WHEN P.Category = 'Furniture' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Furniture,
	SUM(CASE WHEN P.Category = 'Furniture' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Furniture,
	
	-- HOME APPLIANCES Category-related Information per Store:
	COUNT(DISTINCT CASE WHEN P.Category = 'Home_Appliances' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Home_Appliances,
	COUNT(CASE WHEN P.Category = 'Home_Appliances' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Home_Appliances,
	SUM(CASE WHEN P.Category = 'Home_Appliances' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Home_Appliances,
	SUM(CASE WHEN P.Category = 'Home_Appliances' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Home_Appliances,
	SUM(CASE WHEN P.Category = 'Home_Appliances' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Home_Appliances,
	
	-- LUGGAGE ACCESSORIES Category-related Information per Store:
	COUNT(DISTINCT CASE WHEN P.Category = 'Luggage_Accessories' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Luggage_Accessories,
	COUNT(CASE WHEN P.Category = 'Luggage_Accessories' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Luggage_Accessories,
	SUM(CASE WHEN P.Category = 'Luggage_Accessories' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Luggage_Accessories,
	SUM(CASE WHEN P.Category = 'Luggage_Accessories' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Luggage_Accessories,
	SUM(CASE WHEN P.Category = 'Luggage_Accessories' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Luggage_Accessories,
	
	-- PET SHOP Category-related Information per Store:
	COUNT(DISTINCT CASE WHEN P.Category = 'Pet_Shop' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Pet_Shop,
	COUNT(CASE WHEN P.Category = 'Pet_Shop' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Pet_Shop,
	SUM(CASE WHEN P.Category = 'Pet_Shop' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Pet_Shop,
	SUM(CASE WHEN P.Category = 'Pet_Shop' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Pet_Shop,
	SUM(CASE WHEN P.Category = 'Pet_Shop' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Pet_Shop,
	
	-- STATIONERY Category-related Information per Store:
	COUNT(DISTINCT CASE WHEN P.Category = 'Stationery' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Stationery,
	COUNT(CASE WHEN P.Category = 'Stationery' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Stationery,
	SUM(CASE WHEN P.Category = 'Stationery' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Stationery,
	SUM(CASE WHEN P.Category = 'Stationery' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Stationery,
	SUM(CASE WHEN P.Category = 'Stationery' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Stationery,
	
	-- TOYS & GIFTS Category-related Information per Store:
	COUNT(DISTINCT CASE WHEN P.Category = 'Toys & Gifts' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Toys_Gifts,
	COUNT(CASE WHEN P.Category = 'Toys & Gifts' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Toys_Gifts,
	SUM(CASE WHEN P.Category = 'Toys & Gifts' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Toys_Gifts,
	SUM(CASE WHEN P.Category = 'Toys & Gifts' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Toys_Gifts,
	SUM(CASE WHEN P.Category = 'Toys & Gifts' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Toys_Gifts,
	
	-- COMPUTERS & ACCESSORIES Category-related Information per Store:
	COUNT(DISTINCT CASE WHEN P.Category = 'Computers & Accessories' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Computers_Accessories,
	COUNT(CASE WHEN P.Category = 'Computers & Accessories' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Computers_Accessories,
	SUM(CASE WHEN P.Category = 'Computers & Accessories' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Computers_Accessories,
	SUM(CASE WHEN P.Category = 'Computers & Accessories' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Computers_Accessories,
	SUM(CASE WHEN P.Category = 'Computers & Accessories' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Computers_Accessories,
	
	-- CONSTRUCTION TOOLS Category-related Information per Store:
	COUNT(DISTINCT CASE WHEN P.Category = 'Construction_Tools' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Construction_Tools,
	COUNT(CASE WHEN P.Category = 'Construction_Tools' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Construction_Tools,
	SUM(CASE WHEN P.Category = 'Construction_Tools' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Construction_Tools,
	SUM(CASE WHEN P.Category = 'Construction_Tools' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Construction_Tools,
	SUM(CASE WHEN P.Category = 'Construction_Tools' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Construction_Tools,
	
	-- ELECTRONICS Category-related Information per Store:
	COUNT(DISTINCT CASE WHEN P.Category = 'Electronics' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Electronics,
	COUNT(CASE WHEN P.Category = 'Electronics' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Electronics,
	SUM(CASE WHEN P.Category = 'Electronics' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Electronics,
	SUM(CASE WHEN P.Category = 'Electronics' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Electronics,
	SUM(CASE WHEN P.Category = 'Electronics' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Electronics,
	
	-- UNKNOWN Category-related Information per Store:
	COUNT(DISTINCT CASE WHEN P.Category = 'Unknown' THEN (O.order_id) ELSE NULL END) AS No_of_trans_for_Unknown,
	COUNT(CASE WHEN P.Category = 'Unknown' THEN (O.product_id) ELSE NULL END) AS No_of_prod_from_Unknown,
	SUM(CASE WHEN P.Category = 'Unknown' THEN (O.Quantity * (O.MRP - O.Discount)) ELSE 0 END) AS Monetory_Unknown,
	SUM(CASE WHEN P.Category = 'Unknown' THEN (O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) ELSE 0 END) AS Profit_Unknown,
	SUM(CASE WHEN P.Category = 'Unknown' THEN (O.Discount) ELSE 0 END) AS Tot_Disc_Unknown
	
FROM 
    Store_Info S
INNER JOIN 
    Order_Final O ON S.StoreID = O.Delivered_StoreID
INNER JOIN 
    Product_Info P ON O.product_id = P.product_id
INNER JOIN
	Cust_info C ON C.Custid = O.Customer_id
INNER JOIN 
   OrderPay_ment PY ON O.order_id = PY.order_id
GROUP BY StoreID, seller_city, seller_state, Region
ORDER BY Frequency DESC






