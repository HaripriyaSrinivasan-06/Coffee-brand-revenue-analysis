select * from project.[dbo].[sales]
select * from project.[dbo].[products]
select * from project.[dbo].[city]
select * from project.[dbo].[customers]

-- #data cleaning

alter table project.[dbo].[customers] 
add constraint fr_k foreign key(city_ID) references city(city_ID)

alter table project.[dbo].[sales]
alter column product_ID  tinyint 

alter table project.[dbo].[sales]
alter column customer_ID smallint

alter table project.dbo.sales
add constraint f_k foreign key (product_ID) references products(product_ID)

alter table project.dbo.sales
add constraint fo_k foreign key(customer_ID) references customers(customer_ID)

select * from project.[dbo].[sales]
select * from project.[dbo].[products]
select * from project.[dbo].[city]
select * from project.[dbo].[customers]

--# data exploration

--calculating number of people estimated to consume coffee considering 50% of population does

select *,(population *0.25) as people_count
from project.[dbo].[city]

--total revenue sales in 2023-last quarter
select c.city_name,sum(a.total) as total_revenue 
from project.[dbo].[sales] a
join project.dbo.customers b
on a.customer_id=b.customer_id
join project.dbo.city c
on b.city_id = c.city_id
--where year(a.sale_date)=2023 
group by c.city_name
order by 2 desc

--Sales count for each product

select a.product_id,b.product_name,count(a.product_id) as sales_count
from project.[dbo].sales a
left join project.[dbo].products b
on a.product_id=b.product_id
group by a.product_id,b.product_name
order by 1

--average sale amount per city
select b.city_id,c.city_name,avg(a.total) as avg_sales
from  project.[dbo].sales a
join  project.[dbo].customers b
on a.customer_id=b.customer_id
join  project.[dbo].city c
on b.city_id=c.city_id
group by b.city_id,c.city_name
order by 3

--average sale amount per city per customer

--#average sale per city
select c.city_id,c.city_name,sum(a.total) as total_revenue ,count(distinct b.customer_name) as no_of_customers,
sum(a.total)/count(distinct b.customer_id) as average_amount
from project.[dbo].[sales] a
 join project.dbo.customers b
on a.customer_id=b.customer_id
 join project.dbo.city c
on b.city_id = c.city_id
group by c.city_id,c.city_name
order by 5 desc

--#no.of.customers per city
select a.city_id,a.city_name,count(b.customer_name) as no_of_customers
from project.[dbo].city a
join project.dbo.customers b
on a.city_id=b.city_id
group by a.city_id,a.city_name
order by 2

--city and their estimated coffee consumers along with current customers

select a.city_id,a.city_name,round((a.population *0.25)/1000000,2) as customer_count,count(distinct b.customer_id)
from project.[dbo].[city] a
join project.[dbo].[customers] b
on a.city_id=b.city_id
group by a.city_id,a.city_name,(a.population *0.25) 

--Top 3 selling products by city
with CTE as 
(
select a.city_name,d.product_name,count(c.sale_id) as sales_count,
dense_rank() over (partition by a.city_name order by count(c.sale_id)desc) as rank
from project.[dbo].city a
join project.[dbo].customers b
on a.city_id=b.city_id
join project.[dbo].sales c
on b.customer_id=c.customer_id
join project.[dbo].products d
on c.product_id=d.product_id
group by a.city_name,d.product_name
)

select * from CTE
where rank<=3
order by 1

--unique customers in each city
select a.city_name,count(distinct b.customer_id) as customers_city
from project.[dbo].city a
join project.[dbo].customers b
on a.city_id=b.city_id
join project.[dbo].sales c
on b.customer_id=c.customer_id
join project.[dbo].products d
on c.product_id=d.product_id
where d.product_id<=14
group by a.city_name


--city,average sale per customer , avg rent per customer
select a.city_id,a.city_name,sum(c.total) as total_revenue ,count(distinct b.customer_name) as no_of_customers,
sum(c.total)/count(distinct b.customer_id) as average_amount,(a.estimated_rent/count(distinct b.customer_id) )as average_rent
from project.[dbo].city a
join project.[dbo].customers b
on a.city_id=b.city_id
join project.[dbo].sales c
on b.customer_id=c.customer_id
join project.[dbo].products d
on c.product_id=d.product_id
group by a.city_id,a.city_name,a.estimated_rent

select * from project.[dbo].[sales]
select * from project.[dbo].[products]
select * from project.[dbo].[city]
select * from project.[dbo].[customers]

--monthly sales growth
--each month growth in sales
with aa as 
(
select 
c.city_name,month(a.sale_date) as month_name,year(a.sale_date) as year_name,sum(a.total) as sale
from project.[dbo].[sales] a
join project.[dbo].[customers] b
on a.customer_id=b.customer_id
join project.[dbo].city c
on b.city_id=c.city_id
group by c.city_name,month(a.sale_date),year(a.sale_date)
),
cc as(
select *,
lag(sale,1) over(partition by city_name order by year_name,month_name) as last_sale
from aa 
)
select *,cast((sale-last_sale) as int) , cast((last_sale) as int),
(cast((sale-last_sale) as int)/cast((last_sale) as int)) * 100 as ratio
from cc

select * from project.[dbo].[sales]
select * from project.[dbo].[products]
select * from project.[dbo].[city]
select * from project.[dbo].[customers]

--#potential analysis
--top 3 sales based on highest sales with city name,total sale,total rent,total customer,estimated coffee consumer
with CTE as 
(
select c.city_name,c.population,sum(a.total) as total_sale,sum(c.estimated_rent) as Total_rent,count(distinct b.customer_id)
as total_consumer ,round((c.population *0.25)/1000000,2) as people_count_in_M,
Dense_rank() over(partition by city_name order by sum(total) desc) as rank
from project.[dbo].[sales] a
join project.[dbo].[customers] b
on a.customer_id=b.customer_id
join project.[dbo].city c
on b.city_id=c.city_id
group by c.city_name,c.population,a.total
)

select * from CTE
where rank <=3

--

select a.city_id,a.city_name,sum(c.total) as total_revenue ,count(distinct b.customer_name) as no_of_customers,
sum(c.total)/count(distinct b.customer_id) as average_amount,(a.estimated_rent/count(distinct b.customer_id) )as average_rent,a.estimated_rent,
round((a.population *0.25)/1000000,2) as people_count_in_M
from project.[dbo].city a
join project.[dbo].customers b
on a.city_id=b.city_id
join project.[dbo].sales c
on b.customer_id=c.customer_id
join project.[dbo].products d
on c.product_id=d.product_id
group by a.city_id,a.city_name,a.estimated_rent,a.population
order by 3 desc