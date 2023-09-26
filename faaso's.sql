DROP TABLE IF EXISTS driver;
CREATE TABLE driver (driver_id integer, reg_date date);

INSERT INTO driver (driver_id, reg_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS ingredients;
CREATE TABLE ingredients (ingredients_id integer, ingredients_name varchar(60));

INSERT INTO ingredients (ingredients_id, ingredients_name)
VALUES
  (1, 'BBQ Chicken'),
  (2, 'Chilli Sauce'),
  (3, 'Chicken'),
  (4, 'Cheese'),
  (5, 'Kebab'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Egg'),
  (9, 'Peppers'),
  (10, 'schezwan sauce'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

DROP TABLE IF EXISTS rolls;
CREATE TABLE rolls (roll_id integer, roll_name varchar(30));

INSERT INTO rolls (roll_id, roll_name)
VALUES
  (1, 'Non Veg Roll'),
  (2, 'Veg Roll');

DROP TABLE IF EXISTS rolls_recipes;
CREATE TABLE rolls_recipes (roll_id integer, ingredients varchar(24));

INSERT INTO rolls_recipes (roll_id, ingredients)
VALUES
  (1, '1,2,3,4,5,6,8,10'),
  (2, '4,6,7,9,11,12');

DROP TABLE IF EXISTS driver_order;
CREATE TABLE driver_order (
  order_id integer,
  driver_id integer,
  pickup_time timestamp,
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO driver_order (order_id, driver_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2021-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2021-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2021-01-03 00:12:37', '13.4km', '20 mins', 'NaN'),
  (4, 2, '2021-01-04 13:53:03', '23.4', '40', 'NaN'),
  (5, 3, '2021-01-08 21:10:57', '10', '15', 'NaN'),
  (6, 3, null, null, null, 'Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', null),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', null),
  (9, 2, null, null, null, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', null);

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id integer,
  customer_id integer,
  roll_id integer,
  not_include_items VARCHAR(4),
  extra_items_included VARCHAR(4),
  order_date timestamp
);

INSERT INTO customer_orders (order_id, customer_id, roll_id, not_include_items, extra_items_included, order_date)
VALUES
  (1, 101, 1, '', '', '2021-01-01 18:05:02'),
  (2, 101, 1, '', '', '2021-01-01 19:00:52'),
  (3, 102, 1, '', '', '2021-01-02 23:51:23'),
  (3, 102, 2, '', 'NaN', '2021-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2021-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2021-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2021-01-04 13:23:46'),
  (5, 104, 1, null, '1', '2021-01-08 21:00:29'),
  (6, 101, 2, null, null, '2021-01-08 21:03:13'),
  (7, 105, 2, null, '1', '2021-01-08 21:20:29'),
  (8, 102, 1, null, null, '2021-01-09 23:54:33'),
  (9, 103, 1, '4', '1,5', '2021-01-10 11:22:59'),
  (10, 104, 1, null, null, '2021-01-11 18:34:49'),
  (10, 104, 1, '2,6', '1,4', '2021-01-11 18:34:49');

SELECT * FROM customer_orders;
SELECT * FROM driver_order;
SELECT * FROM ingredients;
SELECT * FROM driver;
SELECT * FROM rolls;
SELECT * FROM rolls_recipes;


--A- matric role
--1 what is total no. of roles ordered?
  select count(*) from customer_orders
-- 2 how many unique customer_order were made?
 select count(distinct(customer_id)) from customer_orders
 
 
 --3 how many sucessful order done by driver?
 select count(distinct(order_id)) from driver_order where cancellation not in ('Cancellation','customer Cancellation')
 group by driver_id
 
 
 -- 4 total no
 
   select roll_id,count(roll_id) from  customer_orders
   where order_id in
 (select order_id from
 (select *,case when cancellation not in ('Cancellation','customer Cancellation') 
 then 'ca' else 'c' end as order_a from 
 driver_order)a
 where  order_a= 'c')
 group by  roll_id
  --5 for how many customers , how many deliverd  roll has changes and many has no changes ?

 with temp_cust_order as
(select *,case when not_include_items is null or not_include_items='' then '0'else not_include_items end as new_not_include_items
,case when extra_items_included is null or extra_items_included='' then '0'else extra_items_included end as new_extra_items_included
from customer_orders)
,
tem_driver_order as(
select *, case when cancellation not in ('Cancellation','customer Cancellation') then 1 else 0 end as order_place from
	driver_order
)
select order_id,no_of_chang,count(order_id) as changes from
(select *, case when not_include_items='0' and extra_items_included='0'then 'no change' else 'cahnge'end as no_of_chang 
from temp_cust_order
where order_id in (select order_id from tem_driver_order
	 where order_place !=0))a
	 group by order_id,no_of_chang
	 
-- 6 what are total no.of rolls ordered for each houre of day?
select hour_t, count(hour_t) from
(select * ,cast(extract(hour from order_date)as varchar)||'-'||cast(extract(hour from order_date)+1 as varchar) hour_t
from customer_orders)a
group by hour_t
 ---7 what was the total no. of order in each day of week?
 
 select day_s, count(day_s) as no_order from
 (select * ,to_char( order_date,'day') as day_s from customer_orders)a
 group by day_s
  
  -- B DRIVER AND CUSTOMER EXPREIENCES
   --1 what is average time in minute it took for each deiver to arrive at fasoos hq to picup the order ?
 select  driver_id , sum(diff)/count(order_id) as avg_time from
(select * from
(select *,row_number()over(partition by order_id order by diff ) as rnk from
(select a.* ,b.pickup_time ,b.driver_id ,b.distance,abs(extract(minute from(a.order_date- b.pickup_time))) as diff
from customer_orders a
join driver_order b on
a.order_id =b.order_id
where pickup_time is not null)q)x
where rnk =1)y
group by driver_id
 
 -- is there any relation between no. of rolles and how long the order takes to prepare?

select order_id ,count(roll_id)cnt,sum(diff)/count(roll_id) tym from
(select a.* ,b.pickup_time ,b.driver_id ,abs(extract(minute from(a.order_date- b.pickup_time))) as diff
from customer_orders a
join driver_order b on
a.order_id =b.order_id
where pickup_time is not null)q
group by order_id

--3 what is average distance tarveled for each customers?
select customer_id,sum(distance)/count(order_id) average_distance from
(select * from
(select *,row_number()over(partition by order_id order by diff ) as rnk from
(select a.* ,b.pickup_time ,b.driver_id ,
 cast(trim(replace(lower(b.distance),'km',''))as decimal(4,2))as distance
 ,abs(extract(minute from(a.order_date- b.pickup_time))) as diff
from customer_orders a
join driver_order b on
a.order_id =b.order_id
where pickup_time is not null)q)x
where rnk =1)c
group by customer_id

-- 4 what is the difference bitween longest and shortest delivery order time among all order ?
select max(duration2)-min(duration2)as difference from
(
select cast(case when duration  like '%min%' then left( duration,position('m'in duration)-1) else duration end as integer )as duration2
from driver_order
where duration is not null)a

--5what is the average speed for each driver for each order ?
select order_id,driver_id, distance/duration2 as speed from
(select order_id,driver_id, cast(case when duration  like '%min%' then left( duration,position('m'in duration)-1) else duration end as integer )
as duration2,cast(trim(replace(lower(distance),'km',''))as decimal(4,2))as distance
from driver_order)x
--what is percentage for successfull deliver for  each order
select driver_id,(s*1.0/t)*100 as return_percent from
(select driver_id,count(driver_id) as t,sum(cen_per) as s from 
(select driver_id,case when lower(cancellation) like '%cancell%' then 0 else 1 end as cen_per from
driver_order)a
group by driver_id)y







