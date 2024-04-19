select * from credit_card_trans

--drop table credit_card_trans

alter table credit_card_trans Rename column index to transaction_id

1---Write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

with cte as
(select top 5 city,sum(amount) as spend
from credit_card_trans
group by city
order by spend desc),
cte2 as
(select sum(amount) as total_spend from credit_card_trans)

select cte.* ,round(spend*1.0/total_spend*100,2) as percentage
from cte join cte2 on 1=1
order by spend desc


2-- Write a query to print highest spend month and amount spent in that month for each card type

select * from credit_card_trans

with cte as
(select datepart(year,date) as year ,datepart(Month,date) as month,card_type,sum(amount)as spend
from credit_card_trans
group by datepart(year,date),datepart(month,date),card_type
),
cte2 as
(select *,rank()over(partition by card_type order by spend desc) as rn from cte)

select card_type,year,month,spend from cte2
where rn=1

3--write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
with cte as
(select *,sum(amount) over(partition by card_type order by date,transaction_id) as spend
from credit_card_trans
),
cte2 as 
(select *,rank()over(partition by card_type order by spend asc)as rn from cte
where spend>=1000000)

select * from cte2
where rn=1

4) --Write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

with cte as
(Select city,exp_type,sum(amount)as spend
from credit_card_trans
group by city,exp_type)

select city,
max(case when highest_rn=1 then exp_type end) as highest_expense,
max(case when lowest_rn=1 then exp_type end) as lowest_expense
from
(select *,rank()over(partition by city order by spend desc) as highest_rn,
rank() over(partition by city order by spend asc)as lowest_rn
from cte)a
group by city

5) --Write a query to find percentage contribution of spends by females for each expense type

select * from credit_card_trans


select exp_type,
sum(case when gender='F' then amount else 0 end)/sum(amount) as percentage_contribution
from credit_card_trans
group by exp_type


6) which card and expense type combination saw highest month over month growth in Jan-2014

with cte as
(select datepart(year,date) as year, datepart(month,date) as month, card_type,exp_type,sum(amount) as spend from credit_card_trans
group by datepart(year,date), datepart(month,date),card_type,exp_type)

select top 1 *,(spend-rn)*1.0/rn  as mom_growth from
(select *,lag(spend,1) over(partition by card_type,exp_type order by year,month) rn from cte)a
where a.year=2014 and a.month=1 and a.rn is not null
order by mom_growth desc

7) During weekends which city has highest total spend to total no of transcations ratio 

select top 1 city,sum(amount)*1.0/count(*) as transac_ratio from credit_card_trans
where datepart(weekday,date) in (1,7)
group by city
order by transac_ratio desc








