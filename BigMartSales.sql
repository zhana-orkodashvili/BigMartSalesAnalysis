/*

Big Mart Sales Analysis (Data Exploration)
Using: Converting Data Types, Aggregate Functions, Joins, Views, Temp Tables

*/


select * from sales


-- Data Cleaning


-- modifing data types

ALTER TABLE sales
ALTER COLUMN Item_Weight float

ALTER TABLE sales
ALTER COLUMN Item_Outlet_Sales float

ALTER TABLE sales
ALTER COLUMN Item_Visibility float

ALTER TABLE sales
ALTER COLUMN Item_MRP float


-- searching for null values 


-- items weight 

select * from sales
where Item_Weight=0


-- average Item Weight for each Item Type

create view ItemTypeWeight as 
select Item_Type, avg(Item_Weight) as AverageWeight
from sales
group by Item_Type

select * from ItemTypeWeight


-- filling the missing values with average values according to each item type

update sales
set Item_Weight=case Item_Type
when 'Snack Foods' then (select AverageWeight from ItemTypeWeight where Item_Type='Snack Foods')
when 'Seafood' then (select AverageWeight from ItemTypeWeight where Item_Type='Seafood')
when 'Breads' then (select AverageWeight from ItemTypeWeight where Item_Type='Breads')
when 'Canned' then (select AverageWeight from ItemTypeWeight where Item_Type='Canned')
when 'Dairy' then (select AverageWeight from ItemTypeWeight where Item_Type='Dairy')
when 'Baking Goods' then (select AverageWeight from ItemTypeWeight where Item_Type='Baking Goods')
when 'Others' then (select AverageWeight from ItemTypeWeight where Item_Type='Others')
when 'Breakfast' then (select AverageWeight from ItemTypeWeight where Item_Type='Breakfast')
when 'Fruits and Vegetables' then (select AverageWeight from ItemTypeWeight where Item_Type='Fruits and Vegetables')
when 'Frozen Foods' then (select AverageWeight from ItemTypeWeight where Item_Type='Frozen Foods')
when 'Health and Hygiene' then (select AverageWeight from ItemTypeWeight where Item_Type='Health and Hygiene')
when 'Meat' then (select AverageWeight from ItemTypeWeight where Item_Type='Meat')
when 'Starchy Foods' then (select AverageWeight from ItemTypeWeight where Item_Type='Starchy Foods')
when 'Soft Drinks' then (select AverageWeight from ItemTypeWeight where Item_Type='Soft Drinks')
when 'Hard Drinks' then (select AverageWeight from ItemTypeWeight where Item_Type='Hard Drinks')
when 'Household' then (select AverageWeight from ItemTypeWeight where Item_Type='Household')
end
where Item_Weight = 0



-- outlet sizes

select * from sales
where Outlet_Size=''

select Outlet_Size, count(*) as ItemAmount
from sales
group by Outlet_Size
order by count(*) desc


-- replacing missing values with mode

update sales
set Outlet_Size=
(select top(1) Outlet_Size
from sales
group by Outlet_Size
order by count(*) desc)
where Outlet_Size=''


-- item fat content

select distinct Item_Fat_Content
from sales

-- removing the alternating names and changing into two main ones

update sales
set Item_Fat_Content = 'Regular'
where Item_Fat_Content = 'reg'

update sales
set Item_Fat_Content = 'Low Fat'
where Item_Fat_Content = 'low fat' or Item_Fat_Content = 'LF'





-- EXPLORATORY DATA ANALYSIS

-- categorical features


-- item type vs total sales

select Item_Type, sum(Item_Outlet_Sales) as TotalSales
from sales
group by Item_Type
order by TotalSales desc


-- what percent of total sales is taken by each item type

select Item_Type, 100*sum(Item_Outlet_Sales)/(select SUM(Item_Outlet_Sales) FROM sales) as PercentOfTotalSales
from sales
group by Item_Type
order by PercentOfTotalSales desc


-- item fat content vs total sales

select Item_Fat_Content, sum(Item_Outlet_Sales) as TotalSales
from sales
group by Item_Fat_Content
order by TotalSales desc


-- each outlet store sales

select Outlet_Identifier, sum(Item_Outlet_Sales) as TotalSales
from sales
group by Outlet_Identifier
order by TotalSales desc


-- outlet establishement year vs sales

select Outlet_Establishment_Year, sum(Item_Outlet_Sales) as TotalSales
from sales
group by Outlet_Establishment_Year
order by TotalSales desc


-- outlet size vs sales

select Outlet_Size, sum(Item_Outlet_Sales) as TotalSales
from sales
group by Outlet_Size
order by TotalSales desc


-- outlet location vs sales

select Outlet_Location_Type, sum(Item_Outlet_Sales) as TotalSales
from sales
group by Outlet_Location_Type
order by TotalSales desc


-- outlet type vs sales

select Outlet_Type, sum(Item_Outlet_Sales) as TotalSales
from sales
group by Outlet_Type
order by TotalSales desc


-- location type and most sold item type in each of them
-- shows us which type of item is sold the most in each area

select Outlet_Location_Type, Item_Type, sum([Item_Outlet_Sales]) as TotalSales into #LocSales
from sales
group by Outlet_Location_Type, Item_Type


select [Outlet_Location_Type], max(TotalSales) as MaxSale into #LocMaxSales
from #LocSales
group by Outlet_Location_Type


select ls.Outlet_Location_Type, Item_Type, TotalSales
from #LocSales ls inner join #LocMaxSales lms on ls.Outlet_Location_Type=lms.Outlet_Location_Type
where TotalSales=MaxSale