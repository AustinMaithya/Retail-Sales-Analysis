select * from customers ;
-- Converting the SignupDate column to date from text
-- Added a new column new_SignupDate and dropped the SignupDate that had the date in text format 
select str_to_date(SignUpDate , '%m/%d/%Y') as new_SignUpDate
from customers;

alter table customers
add column new_SignUpDate Date;

update customers 
set new_SignUpDate = str_to_date(SignUpDate , '%m/%d/%Y');

alter table customers
drop column SignupDate;

select * from orderdetails ;

select * from orders ;

select * from product ;

-- customer insights
-- 1. Which customers have the highest total purchase amounts over time?
select c.Name,sum(o.TotalAmount) as purchase_amount
from customers c
join orders o
on c.CustomerID = o.CustomerID
group by c.Name
order by sum(o.TotalAmount) desc
limit 5;

-- 2. What is the average customer lifetime value by location?
SELECT c.Location, AVG(total.TotalSpent) AS AvgLifetimeValue
FROM (
  SELECT CustomerID, SUM(TotalAmount) AS TotalSpent
  FROM Orders
  GROUP BY CustomerID
) total
JOIN Customers c ON total.CustomerID = c.CustomerID
GROUP BY c.Location;

-- 3.	How many customers signed up each month?
select count(*) as signed_up_customers ,monthname(new_SignupDate) as month_name
from customers 
group by monthname(new_SignupDate);


-- 4.	What percentage of customers placed more than one order?
select CustomerID, count(*) as Orders_Count 
from Orders
group by CustomerID
having count(*) > 1 ;

-- 5.	Are there patterns in customer signup dates and their first purchase dates?
select * from orders;
select str_to_date(OrderDate , '%m/%d/%Y') as new_OrderDate
from orders ;

alter table orders
add column new_OrderDate date;

update orders
set new_OrderDate = str_to_date(OrderDate , '%m/%d/%Y');

alter table orders
drop column OrderDate;

select * from orders;

select c.CustomerID,
		c.new_SignUpDate,
		min(o.new_OrderDate) as First_Order_Date ,
		datediff(c.new_SignUpDate,min(o.new_OrderDate))as date_difference 
from customers c
join orders o
on c.CustomerID = o.CustomerID 
group by c.CustomerID,
		c.new_SignUpDate
order by c.CustomerID asc
;



-- 📦 Product & Inventory Insights
-- 6.	Which products are ordered the most frequently?
select * from product;
select * from orderdetails;

select p.ProductName, sum(d.Quantity) as Quantity
from product p
join orderdetails d
on p.ProductID = d.ProductID
group by p.ProductName
order by sum(d.Quantity) desc;

-- 7.	What are the top-selling product categories by revenue?
select * from product;
select * from orderdetails;

select p.Category, sum(d.Quantity * d.UnitPrice) as Revenue 
from product p
join orderdetails d
on p.ProductID = d.ProductID
group by p.Category
order by sum(d.Quantity * d.UnitPrice) desc ;

-- 8.	How does product demand vary by season or quarter?

select * from product;
select * from orderdetails;
select * from orders;

select p.ProductName, 
		sum(d.Quantity) as quantity, 
		quarter(o.new_OrderDate) as quarter 
from orders o
join orderdetails d
on o.OrderID = d.OrderID
join product p
on d.ProductID= p.ProductID
group by p.ProductName,quarter(o.new_OrderDate)
order by sum(d.Quantity),quarter(o.new_OrderDate) desc;

-- 9.	Are there any products that consistently sell together?
select d1.ProductID as Product1, d2.ProductID as Product2, count(*) as PairCount
from OrderDetails d1
join OrderDetails d2 on d1.OrderID = d2.OrderID and d1.ProductID < d2.ProductID
group by Product1, Product2
order by  PairCount desc;


-- 10.	What is the average order size per product category?
select * from product;
select * from orderdetails;
select * from orders;

select p.Category, avg(d.Quantity) as avg_order
from product p
join orderdetails d
on p.ProductID = d.ProductID
group by p.Category
order by avg(d.Quantity);

-- ________________________________________
-- 🛒 Sales & Order Behavior
-- 11.	What is the trend in monthly sales revenue over the past year?
select * from orders;

select monthname(new_OrderDate) as month_name ,
		sum(TotalAmount) as revenue 
from orders
group by monthname(new_OrderDate)
order by sum(TotalAmount) desc;

-- 12.	How many orders are placed each week?

select * from orderdetails;
select * from orders;

select count(*) as total_orders,
	week(new_OrderDate, 1) as weeknumber 
from orders 
group by week(new_OrderDate, 1)
order by week(new_OrderDate, 1) asc ;


-- 13.	What is the average order value per payment method?
select * from orders ;

select PaymentMethod, avg(TotalAmount) as avg_order_value
from orders 
group by PaymentMethod
order by avg(TotalAmount) desc;

-- 14.	Are there certain days of the week with higher sales activity?
select * from orders ;

select count(*) as orders,
	dayofweek(new_OrderDate) as day_of_week,
    dayname(new_OrderDate) as day_name
from orders
group by dayofweek(new_OrderDate) ,dayname(new_OrderDate)
order by dayofweek(new_OrderDate) asc;
-- 15.	What is the distribution of order quantities (e.g., single item vs. multiple items)?
select * from orderdetails;

select OrderID,
		 sum(Quantity) as order_quantities,
         case when sum(Quantity) >1 then'multiple items'
			else 'Single item '
            end as quantity_type
from orderdetails
group by OrderID;
	
-- ________________________________________
-- 💳 Payment & Transaction Insights
-- 16.	What are the most commonly used payment methods?
select * from orders;
select PaymentMethod,
		count(*) as method_usage
from orders 
group by PaymentMethod
order by count(*) desc;
-- 17.	Is there any correlation between payment method and order value?
select PaymentMethod,
		avg(TotalAmount) as avg_order_value
from orders
group by PaymentMethod
order by avg(TotalAmount) desc ;
-- 18.	Which payment method has the highest total revenue contribution?
select PaymentMethod,
		sum(TotalAmount) as revenue
from orders
group by PaymentMethod
order by sum(TotalAmount) desc ;
-- ________________________________________
-- 🌎 Regional & Demographic Trends
-- 19.	Which locations generate the most revenue?
select * from customers;
select * from orders;

select c.Location , sum(o.TotalAmount) as revenue 
from  customers c
join orders o 
on c.CustomerID = o.CustomerID
group by c.Location
order by sum(o.TotalAmount) desc  ;


-- 20.	Are there differences in product preferences across regions?

select * from customers ;
select * from product;
select * from orders ;
select * from orderdetails;

select p.ProductName,c.Location,sum(d.Quantity)as units_sold
from customers c
join orders o 
on c.CustomerID = o.CustomerID
join orderdetails d 
on o.OrderID = d.OrderId
join product p
on d.ProductID = d.ProductID
group by p.ProductName,c.Location
order by c.Location,sum(d.Quantity) ;



