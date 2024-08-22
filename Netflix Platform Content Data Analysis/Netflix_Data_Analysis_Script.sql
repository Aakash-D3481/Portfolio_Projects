-- For table Referencing

select * from [Netflix Data];

-- Cleaning Data Before Analysis

--1. Checking for Nulls in the dataset

SELECT
    COUNT(CASE WHEN show_id IS NULL THEN 1 END) AS showid_nulls,
    COUNT(CASE WHEN n.type IS NULL THEN 1 END) AS type_nulls,
    COUNT(CASE WHEN title IS NULL THEN 1 END) AS title_nulls,
    COUNT(CASE WHEN director IS NULL THEN 1 END) AS director_nulls,
    COUNT(CASE WHEN country IS NULL THEN 1 END) AS country_nulls,
    COUNT(CASE WHEN date_added IS NULL THEN 1 END) AS date_added_nulls,
    COUNT(CASE WHEN release_year IS NULL THEN 1 END) AS release_year_nulls,
    COUNT(CASE WHEN rating IS NULL THEN 1 END) AS rating_nulls,
    COUNT(CASE WHEN duration IS NULL THEN 1 END) AS duration_nulls,
    COUNT(CASE WHEN listed_in IS NULL THEN 1 END) AS listed_in_nulls
FROM [Netflix Data] n;

-- With this query we can conclude that there are no nulls in the dataset.

-----------------------------------------------------------------------------

-- 2. Fixing the date_added column


alter table [Netflix Data]
add date_added_fixed date

UPDATE [Netflix Data]
SET date_added_fixed = Convert(date, Parse(date_added as date))

-- Checking whether the issue is fixed
select date_added, date_added_fixed
from [Netflix Data]


-------------------------------------------------------------------------

-- 3. Removing Columns That are not useful for analysis

alter table [Netflix Data]
drop column listed_in

select *
from [Netflix Data]

------------------------------------------------------------------------

-- Analysis and Creating Views for Visualizations

-- 1. Understanding the Distribution of Title type

select e.Content_Type, e.total, e.Total_content,
(e.total/e.Total_content) as perc
from(
	select distinct(type) as Content_Type, count(type) as total,
	sum(count(type)) over() as Total_content
	from [Netflix Data]
	group by type) e

-----------------------------------------------------------------------

-- 2. Understanding the number of contents by country

select country as Country, type as Content_Type, count(*) as No_of_Titles,
sum(count(*)) over(Partition by Country) as Total_Titles
from [Netflix Data]
group by country, type
order by country;

-----------------------------------------------------------------------------

-- 3. See the Number of content added each year


select year(date_added_fixed) as years, 
count(*) as total_titles_added_during_the_year
from [Netflix Data]
group by year(date_added_fixed)
order by years;

--------------------------------------------------------------------------

-- 4. What are the top ratings on the platform


select e.Content_rating, e.total, e.Total_content
from(
	select distinct(rating) as Content_rating, count(type) as total,
	sum(count(type)) over() as Total_content
	from [Netflix Data]
	group by rating) e
order by total desc

------------------------------------------------------------------------

-- 5. Oldest Tv show by release year on the platform

Select * from [Netflix Data]

select type, title, release_year
from [Netflix Data]
order by release_year

------------------------------------------------------------------------

-- 6. Top Directors on the Platform with the most content

select director as Directors_Name, count(*) as Total_Content_made
from [Netflix Data]
where director <> 'Not Given'
group by director 
order by Total_Content_made desc;

-------------------------------------------------------------------------

-- Creating Views of the above queries for Building a dashboard

Create view Dist_of_content_type
as 
select e.Content_Type, e.total, e.Total_content
from(
	select distinct(type) as Content_Type, count(type) as total,
	sum(count(type)) over() as Total_content
	from [Netflix Data]
	group by type) e

select * from Dist_of_content_type;

-------------------------------------------------------------------------

Create view num_of_content_by_country
as
select country as Country, type as Content_Type, count(*) as No_of_Titles,
sum(count(*)) over(Partition by Country) as Total_Titles
from [Netflix Data]
group by country, type
--order by country;

select * from num_of_content_by_country;

-----------------------------------------------------------------------------

create view Content_each_year
as
select year(date_added_fixed) as years, 
count(*) as total_titles_added_during_the_year
from [Netflix Data]
group by year(date_added_fixed)
--order by years;

select * from Content_each_year;

------------------------------------------------------------------------

create view highest_of_rated_shows
as
select e.Content_rating, e.total, e.Total_content
from(
	select distinct(rating) as Content_rating, count(type) as total,
	sum(count(type)) over() as Total_content
	from [Netflix Data]
	group by rating) e
--order by total desc

select * from highest_of_rated_shows;

------------------------------------------------------------------------

create view oldest_show_on_platform
as
select type, title, release_year
from [Netflix Data]
--order by release_year

select * from oldest_show_on_platform

------------------------------------------------------------------------

create view Top_directors
as
select director as Directors_Name, count(*) as Total_Content_made
from [Netflix Data]
where director <> 'Not Given'
group by director 
--order by Total_Content_made desc;

select * from Top_directors;

--===========================================================================