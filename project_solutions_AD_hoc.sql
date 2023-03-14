SELECT * FROM gdb023.dim_customer;

-- 1)  Provide the list of markets in which customer "Atliq Exclusive" operates its
-- business in the APAC region.
use gdb023;
select distinct(Market) from dim_customer where region = "APAC";

# 2) What is the percentage of unique product increase in 2021 vs. 2020? The
#final output contains these fields,
#unique_products_2020
#unique_products_2021
#percentage_chg

with unique_2020 as
(select count(distinct(product_code)) as Unique_products_2020 from fact_sales_monthly
where fiscal_year = 2020),
 unique_2021 as
(select count(distinct(product_code)) as Unique_products_2021 from fact_sales_monthly
where fiscal_year = 2021)

select unique_2020.Unique_products_2020, unique_2021.Unique_products_2021, 
(unique_2021.Unique_products_2021 -  
unique_2020.Unique_products_2020)*100/Unique_products_2020
as pct_change

from unique_2020 cross join
unique_2021;





/* 3. Provide a report with all the unique product counts for each segment and
sort them in descending order of product counts. The final output contains
2 fields,
segment
product_count*/

select count(distinct(product_code)) as count_product_seg, segment from dim_product 
group by segment order by count_product_seg desc;

/* 4. Follow-up: Which segment had the most increase in unique products in
2021 vs 2020? The final output contains these fields,
segment
product_count_2020
product_count_2021
difference*/

with segment_2020 as(
select f.product_code, count(distinct(f.product_code)) as product_count_2020, 
d.segment from fact_sales_monthly f 
join dim_product d
on f.product_code = d.product_code 
where fiscal_year = 2020 group by d.segment  ),
segment_2021 as 
(select f.product_code, count(distinct(f.product_code)) as product_count_2021,
 d.segment from fact_sales_monthly f
 join dim_product d
on f.product_code = d.product_code where fiscal_year = 2021 group by d.segment )
select  segment_2020.segment, segment_2020.product_count_2020, segment_2021.product_count_2021,
  (product_count_2021 - product_count_2020) as difference
 from segment_2020
join segment_2021 on segment_2020.segment = segment_2021.segment
order by difference desc;

/* 5) Get the products that have the highest and lowest manufacturing costs.
The final output should contain these fields,
product_code
product
manufacturing_cost*/

select m.product_code, m.manufacturing_cost, d.product from fact_manufacturing_cost m
join dim_product d on m.product_code = d.product_code
where m.manufacturing_cost = 
(select max(manufacturing_cost) from fact_manufacturing_cost ) or 
m.manufacturing_cost = (select min(manufacturing_cost) from fact_manufacturing_cost);

-- 6) Generate a report which contains the top 5 customers who received an
-- average high pre_invoice_discount_pct for the fiscal year 2021 and in the
-- Indian market. The final output contains these fields,
-- customer_code
-- customer
-- average_discount_percentage



SELECT f.customer_code,  f.pre_invoice_discount_pct as avg_discount_price,  d.customer
 from fact_pre_invoice_deductions f
join dim_customer d on f.customer_code = d.customer_code
where f.pre_invoice_discount_pct > (select avg(pre_invoice_discount_pct)
 from fact_pre_invoice_deductions)
 and f.fiscal_year = (select fiscal_year from fact_pre_invoice_deductions
 where fiscal_year = 2021 limit 1) and d.market = 
 (select market from dim_customer where market = "india" limit 1)
 order by f.pre_invoice_discount_pct desc limit 5 ;
 
 /* Get the complete report of the Gross sales amount for the customer “Atliq
Exclusive” for each month. This analysis helps to get an idea of low and
high-performing months and take strategic decisions.
The final report contains these columns:
Month
Year
Gross sales Amount */ 

select monthname(m.date) as month_ , year(m.date) as year_, 
sum( p.gross_price*m.sold_quantity) as gross_sales
from fact_gross_price p  inner join fact_sales_monthly m
on m.product_code = p.product_code 
join dim_customer d on d.customer_code = m.customer_code
where d.customer = "Atliq Exclusive"
group by month_ , year_  order by year_ ;

/* In which quarter of 2020, got the maximum total_sold_quantity? The final
output contains these fields sorted by the total_sold_quantity,
Quarter
total_sold_quantity */

select case when month(date) in (9, 10, 11) then "q1"
when month(date) in (12, 1, 2) then "Q2"
when month(date) in (3,4,5) then "q3"
when month(date) in (6,7,8) then "q4" 
end as quarter_name, sum(sold_quantity) as total_sold_quantity
from fact_sales_monthly where fiscal_year = 2020
 group by quarter_name order by total_sold_quantity desc limit 1;
 
 
 /* 9. Which channel helped to bring more gross sales in the fiscal year 2021
and the percentage of contribution? The final output contains these fields,
channel
gross_sales_mln
percentage*/