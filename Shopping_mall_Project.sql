-- create database shopping;

# To import customer_shopping_data table into the database
# Select the desired schema say 'shopping' < Right on Tables < Click 'Table data import wizard' < Copy paste the path of the desired file

# To check that the table is imported
select * from customer_shopping_data;

# Create a duplicate table to prevent any mishapps
create table customer
like customer_shopping_data;

insert into customer
select * from customer_shopping_data;

select * from customer;

# Alter Data type
alter table customer
modify column invoice_date DATE;

# checking for duplicate values in the column invoice_no
with duplicate1 as(
	select invoice_no,
	row_number() over (partition by invoice_no) as row_rn
	from customer) 
select *
from duplicate1
where row_rn>1 ;

# checking for duplicate values in the column customer_id
with duplicate2 as(
	select customer_id,
	row_number() over (partition by customer_id) as row_rn
	from customer) 
select *
from duplicate2 
where row_rn>1 ;

# Listing different shopping malls
select distinct shopping_mall
from customer;

# Listing different categories
select distinct category
from customer; 

# Checking age groups
select max(age) 'Max Age', min(age) 'Min Age'
from customer;

# Checking for any null values
select distinct shopping_mall
from customer
where payment_method = '' or payment_method is null;

# How many years of data is provided
select distinct year(invoice_date)
from customer; 

-- Top 10 customer ids based on total spendings

select customer_id,category,Shopping_mall,
sum(quantity*price) as Total_spending
from customer
group by customer_id,category,Shopping_mall
order by Total_spending desc
limit 10;


-- Total and Average sales of each shopping mall

select shopping_mall,
round(sum(quantity*price),2) as Total_Sales, 
round(avg(quantity*price),2) as Average_Sales
from customer
group by shopping_mall
order by Total_sales desc;



-- Total and Average year wise sales of each shopping mall 

select shopping_mall,year(invoice_date),
round(sum(quantity*price),2) as Total_Sales, 
round(avg(quantity*price),2) as Average_Sales
from customer
group by  year(invoice_date),shopping_mall
order by shopping_mall,year(invoice_date);



-- Average sales w.r.t all shopping malls
select round(avg(total_sales),2) as average_sales_mall
from (select sum(quantity*price) as Total_Sales
	  from customer
      group by shopping_mall
     ) as totals;


-- Shopping Malls whose total sales is more than the average sales of all Malls

with mall_sales as(
	select shopping_mall,
	round(sum(quantity*price),2) as Total_Sales
	from customer
	group by shopping_mall),
average_sales as (
	select round(avg(total_sales),2) as average_sales
	from mall_sales)
select m.shopping_mall, m.total_sales
from mall_sales m, average_sales a
where m.Total_sales> a.average_sales;


-- TOP 3 MOST SELLING CATEGORY OF EACH MALL

with top3 as(
select shopping_mall,category,round(sum(quantity*price),2) as sales,
rank() over(partition by shopping_mall order by round(sum(quantity*price),2) desc ) as ranking
from customer 
group by category,shopping_mall
order by shopping_mall)
select * 
from top3
where ranking<4;


-- Highest selling category per Year

with category_sales as(
	select shopping_mall,category,
    year(invoice_date) as year,
    round(sum(quantity*price),2) as sales,
    rank() over(partition by shopping_mall, year(invoice_date)  order by round(sum(quantity*price),2) desc) as rk
	from customer 
	group by shopping_mall,category, year(invoice_date)
)
select shopping_mall,year,category,sales as 'Maximum Sales'
from  category_sales
where rk = 1;   
 

-- Least selling category in each Year

with category_sales as(
	select shopping_mall,category,
    year(invoice_date) as year,
    round(sum(quantity*price),2) as sales,
    rank() over(partition by shopping_mall, year(invoice_date)  order by round(sum(quantity*price),2) ) as rk
	from customer 
	group by shopping_mall,category, year(invoice_date)
)
select shopping_mall,year,category,sales as 'Minimum Sales'
from  category_sales
where rk = 1;


-- Comparision of Total Sales and Highest selling Category Sales for each Shopping Mall in each year 

with Max_sales as
	(select shopping_mall,
    category,
    year(invoice_date) as `Year`,
    round(sum(quantity*price),2) as sales,
	max(sum(quantity*price)) over(partition by shopping_mall,year(invoice_date)) as max_sales
	from customer 
	group by category,shopping_mall,year(invoice_date)
    ) 
select x.shopping_mall,x.`Year`,x.category as 'Category with Max Sales',
x.max_sales as 'Maximum Sales',ts.Total_sales, round((x.sales/ts.Total_Sales)*100,2) as '% of Total Sales'
from Max_sales x
Join (select shopping_mall,
      year(invoice_date) as `Year`,
      round(sum(quantity*price),2) as Total_Sales
	  from customer
	  group by year(invoice_date),shopping_mall
	  order by shopping_mall,year(invoice_date)) ts
on x.shopping_mall=ts.shopping_mall 
      and x.`Year`=ts.`Year`
      where x.sales= x.max_sales;


-- Comparision of Total Sales and Least selling Category Sales for each Shopping Mall in each year
 
with Min_sales as
	(select shopping_mall,
    category,year(invoice_date) as `Year`,
    round(sum(quantity*price),2) as sales,
	min(sum(quantity*price)) over(partition by shopping_mall,year(invoice_date)) as min_sales
	from customer 
	group by category,shopping_mall,year(invoice_date)
    ) 
select x.shopping_mall,
x.`Year`,
x.category as 'Category with Min Sales',
x.min_sales as 'Lowest Sales',ts.Total_sales,
round((x.sales/ts.Total_Sales)*100,2) as '% of Total Sales'
from Min_sales x
Join (select shopping_mall,
      year(invoice_date) as `Year`,
      round(sum(quantity*price),2) as Total_Sales
	  from customer
	  group by year(invoice_date),shopping_mall
	  order by shopping_mall,year(invoice_date)) ts
on x.shopping_mall=ts.shopping_mall 
   and x.`Year`=ts.`Year`
   where x.sales= x.min_sales;


-- Which gender prefers which payment method?
-- What is the percentage distribution of payment methods used by each gender?

with prefer as(
select gender, payment_method,
count(*) as `Usage`,
sum(count(*)) over (partition by gender) as Total
from customer
group by gender,payment_method
order by gender,`Usage` desc
)
select gender,
payment_method,
concat(round((`Usage`/Total)*100,2),' %') as "Gender-wise Usage %"
from prefer;

-- What is the percentage contribution of each payment method to total sales by gender?

-- overall
with gender as(
select gender,
round(sum(quantity*price),2) as sales
from customer
group by gender),
total as(
select sum(quantity*price) as total_sales
from customer)
select g.gender, concat(round((g.sales/t.total_sales)*100,2),' %') as percentage
from gender g, total t ;

-- payment method wise
with sales as
(
select gender, 
sum(quantity*price) as Total_Sales,payment_method
from customer
group by gender,payment_method
),
gen_sales as
(
select gender, sum(quantity*price) as Total_Sales
from customer
group by gender
)
select s.gender, 
s.payment_method,
round(s.Total_sales,3) as 'Sales' ,
round((s.Total_sales/nullif(g.Total_sales,0))*100,2) as "Gender_wise_Sales_%"
from sales s 
join gen_sales g
on s.gender = g.gender
order by gender,round((s.Total_sales/nullif(g.Total_sales,0))*100,2)  Desc;


-- Top payment method by mall and its contribution to total sales

with paySales as(
	select x.* from(
	select shopping_mall,
	payment_method,
	round(sum(quantity*price),2) as Sales ,
	rank() over(partition by shopping_mall order by sum(quantity*price) desc) as rnk
	from customer
	group by shopping_mall,payment_method
	order by shopping_mall)x
	where x.rnk=1),
Total as(
	select shopping_mall,
	sum(quantity*price) as tt
	from customer 
	group by shopping_mall)
select p.shopping_mall,p.payment_method,p.Sales,
concat(round((p.sales/t.tt)*100,2),' %') as Contribution_percent
from paySales p
join Total t
on p.shopping_mall = t.shopping_mall
where p.rnk=1;


-- Identifying the highest selling product category for each customer age group
-- All Agr group spends the most on clothing

select m.category, m.Age_Group, m.sales from (
select row_number() over(partition by Age_Group) as 'S.no.' ,x.*
from(
select category,
case
	when age between 18 and 25 then '18-25' 
    when age between 26 and 35 then '26-35'
    when age between 36 and 45 then '36-45'
    when age between 46 and 60 then '46-60'
    else '60+'
end as Age_Group,
round(sum(quantity*price),2) as Sales
from customer
group by category,age_group
order by age_group,sales desc) x
)m
where `S.no.` = 1;


-- Monthly Trends
-- Monthly trends are based on available months only. Some months have no recorded sales due to data sparsity

-- Monthly Sales Vs. Yearly Total-Contribution Percentage Analysis
with MonthlySales as
   (
	select shopping_mall,
	year(invoice_date) as year,
	monthname(invoice_date) as Month,
	round(sum(quantity*price),2) as Monthly_Sales
	from customer
	group by shopping_mall,month(invoice_date), year(invoice_date),monthname(invoice_date)
	order by shopping_mall,year(invoice_date), month(invoice_date) 
    ),
YearlySales as
    (
	select shopping_mall,
    year(invoice_date) as year,
	round(sum(quantity*price),2) as Total_Sales 
	from customer
	group by year(invoice_date),shopping_mall
    )
select m.*, y.Total_Sales, round(m.Monthly_Sales/y.Total_Sales*100,2) as 'Yearly_Contribution_%'
from MonthlySales m
join YearlySales y
	on m.year=y.year
    and m.shopping_mall = y.shopping_mall;



-- Month-over-Month Sales Difference Analysis

select shopping_mall,
year(invoice_date) as year,
monthname(invoice_date) as Month,
round(sum(quantity*price),2) as Monthly_Sales,
round(
		(sum(quantity*price) - 
		lag(sum(quantity*price),1,0) over(partition by shopping_mall, year(invoice_date)order by month(invoice_date))
		)
	,2
	) as Sales_Difference
from customer
group by shopping_mall,
		 month(invoice_date),
         year(invoice_date),
         monthname(invoice_date)
order by shopping_mall,
		 year(invoice_date), 
         month(invoice_date);


-- Month-over-Month Sales Difference Percentage Analysis
select shopping_mall,
year(invoice_date) as year,
monthname(invoice_date) as Month,
round(sum(quantity*price),2) as Monthly_Sales,
concat(round(
	case
		when lag(sum(quantity*price),1,0) over(partition by shopping_mall, year(invoice_date)order by month(invoice_date))=0 then 0
        else
			(sum(quantity*price) - 
			lag(sum(quantity*price),1,0) over(partition by shopping_mall, year(invoice_date)order by month(invoice_date))
            )/lag(sum(quantity*price),1,0) over(partition by shopping_mall, year(invoice_date)order by month(invoice_date))
            *100
	end,
	2
	),' %') as Sales_Difference_percent 
from customer
group by shopping_mall,
		 month(invoice_date),
         year(invoice_date),
         monthname(invoice_date)
order by shopping_mall,
		 year(invoice_date), 
         month(invoice_date) ;


-- Seasonal Analysis
-- Identify the top 3 months with highest total sales across all malls

select *
from (
	select shopping_mall,
	monthname(invoice_date) as Month,
	year(invoice_date) as year,
	sum(quantity*price),
	rank() over(partition by shopping_mall,year(invoice_date) order by sum(quantity*price) desc) as sales_rank
	from customer
	group by shopping_mall,Month,year,month(invoice_date)
	order by shopping_mall,year(invoice_date),sum(quantity*price)) x
where x.sales_rank<=3
order by x.shopping_mall,x.year,x.sales_rank;


-- Average Trasaction Value(ATV) per Shopping Mall
-- What is the average spend per transaction in each shopping mall
select shopping_mall,
sum(quantity*price) as Total_Sales,
sum(quantity*price)/count(invoice_no) as Average_Trancation_Value
from customer
group by shopping_mall;


select shopping_mall,
sum(quantity) as Total_Quantity,
sum(quantity)/count(invoice_no) as Avg_Item_per_Transaction,
sum(price)*sum(quantity)/count(invoice_no) as Avg_sales_per_Transaction
from customer
group by shopping_mall
order by Total_Quantity;


-- Sales contribution % by mall to total sales
with MallSales as(
	select shopping_mall,
	sum(quantity*price) as Mall_Sales 
	from customer 
	group by shopping_mall),
Total as(
select sum(quantity*price) as Total_Sales 
from customer)
select m.shopping_mall, 
concat(round(m.mall_sales/t.total_sales*100,2),' %') as  'contribution to total sales'
from MallSales m
join Total t;







