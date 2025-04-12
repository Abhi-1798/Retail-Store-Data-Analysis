
SELECT
	O.*,
	-- Calculating the profit earned in each order
	(O.Quantity * (O.MRP - O.Discount)) - (O.Quantity * O.Cost_Per_Unit) AS Profit,
	-- Adjesting the Payment_Rating Table in Order table
	AVG(CASE WHEN O.order_id = RT.order_id THEN RT.Customer_Satisfaction_Score ELSE NULL END) AS Avg_CustSat_Scr,
	-- Category of the product
	(CASE WHEN O.product_id = P.product_id THEN P.Category ELSE NULL END) AS Product_Category,
	-- To know all kind of modes of Payment
	SUM(CASE WHEN OP.payment_type = 'Credit_Card' THEN O.Total_Amount ELSE 0 END ) AS CC_Pay,
	SUM(CASE WHEN OP.payment_type = 'Debit_Card' THEN O.Total_Amount ELSE 0 END ) AS DC_Pay,
	SUM(CASE WHEN OP.payment_type = 'UPI/Cash' THEN O.Total_Amount ELSE 0 END ) AS UPI_Cash_Pay,
	SUM(CASE WHEN OP.payment_type = 'Voucher' THEN O.Total_Amount ELSE 0 END ) AS Vouch_Pay
	

FROM Order_Final AS O
JOIN OrderRat_ing AS RT on O.order_id = RT.order_id
JOIN Product_Info AS P ON O.product_id = P.product_id
JOIN OrderPay_ment AS OP ON O.order_id = OP.order_id
GROUP BY O.Bill_date_timestamp, O.Channel, O.Cost_Per_Unit, O.Customer_id, O.Delivered_StoreID, O.Discount, O.MRP, O.order_id, O.product_id, O.Quantity, O.Total_Amount,
         P.product_id, P.Category

--select * from Order_Final