create database bike_sharing;

use bike_sharing;

create table hours(
instant	int,
dteday text,
season int,
yr int,
mnth int,
hr int,
holiday int,
weekday int,
workingday int,
weathersit int,
temp decimal(5,4),
atemp decimal(5,4),
hum decimal(5,4),
windspeed decimal(5,4),
casual int,
registered int,
cnt int)

/*Dataset characteristics
=========================================	
Both hour.csv and day.csv have the following fields, except hr which is not available in day.csv
	
	- instant: record index
	- dteday : date
	- season : season (1:spring, 2:summer, 3:fall, 4:winter)
	- yr : year (0: 2011, 1:2012)
	- mnth : month ( 1 to 12)
	- hr : hour (0 to 23)
	- holiday : weather day is holiday or , 0 =  holiday,(extracted from http://dchr.dc.gov/page/holiday-schedule)
	- weekday : day of the week
	- workingday : if day is neither weekend nor holiday is 1, otherwise is 0.
	+ weathersit : 
		- 1: Clear, Few clouds, Partly cloudy, Partly cloudy
		- 2: Mist + Cloudy, Mist + Broken clouds, Mist + Few clouds, Mist
		- 3: Light Snow, Light Rain + Thunderstorm + Scattered clouds, Light Rain + Scattered clouds
		- 4: Heavy Rain + Ice Pallets + Thunderstorm + Mist, Snow + Fog
	- temp : Normalized temperature in Celsius. The values are divided to 41 (max)
	- atemp: Normalized feeling temperature in Celsius. The values are divided to 50 (max)
	- hum: Normalized humidity. The values are divided to 100 (max)
	- windspeed: Normalized wind speed. The values are divided to 67 (max)
	- casual: count of casual users
	- registered: count of registered users
	- cnt: count of total rental bikes including both casual and registered*/
    
/*Demand Analysis
1.What are the peak hours for bike rentals
-  Helps optimize fleet availability during high-demand hours.*/
select 
	hr as Peak_Hours,
    sum(registered) as Total_Bikes_Booked
from hours
group by hr
order by Total_Bikes_Booked desc;

/*2.How do bike rentals vary across seasons?
- Essential for planning seasonal marketing strategies & fleet adjustments.*/
select 
	case
		when season = "1" then "Spring"
		when season = "2" then "Summer"
		when season = "3" then "Fall"
		when season = "4" then "Winter"
    end as Seasons,
        sum(registered) as Total_Bikes_Booked
from hours
group by seasons
order by Total_Bikes_Booked desc;

/*3.Which days of the week have the highest rentals?
- Provides insights into workday vs. leisure-based bike usage*/
select 
case
	when weekday between 0 and 4  Then "Weekday"
    else "Weekend"
    end as Weekday_Name,
sum(registered) as Total_Bikes_Booked
from day
group by weekday_Name
order by Total_Bikes_Booked desc;

/*Customer Behavior
/*4.Do casual users rent more on holidays compared to working days?
- Helps in planning holiday promotions and pricing strategies.*/
select case
	when holiday = 0 then "Holiday"
    when holiday = 1 then "Working Day"
    end as Holiday_WorkingDay,
sum(casual) as Total_Casual_Bookings
from day
group by Holiday_WorkingDay
order by Total_Casual_Bookings;

/*5.What is the impact of temperature on rentals
- Check if higher temperatures lead to more bike rentals
- Helps in understanding weather-based demand fluctuations.*/
select case
   WHEN temp > 0.18 THEN 'Very Hot'
        WHEN temp BETWEEN 0.16 AND 0.18 THEN 'Hot'
        WHEN temp BETWEEN 0.21 AND 0.30 THEN 'Warm'
        WHEN temp BETWEEN 0.10 AND 0.20 THEN 'Cool'
        ELSE 'Cold'
    end as Temperature_Range,
sum(cnt) as Total_Bookings
from day
group by Temperature_Range
order by Total_Bookings desc;    

/*6.Does wind speed affect the number of rentals?
- Useful for adjusting fleet supply based on weather conditions*/
select 
case
	when (windspeed*(67-0))+0 between 0 and 5 then "Calm"
    when (windspeed*(67-0))+0 between 6 and 20 then "Light Breeze"
    when (windspeed*(67-0))+0 between 21 and 40 then "Moderate Wind"
    when (windspeed*(67-0))+0 between 41 and 60 then "Strong Wind"
    else "Very Strong"
    end as Wind_Category,
sum(cnt) as Total_Bookings
from hours
group by Wind_Category
order by Total_Bookings desc ;

/*Business Optimization
7.Which months generate the highest  rentals?
- Guides inventory & workforce management throughout the year.*/
select
	case
	when mnth = 1 then "January"
    when mnth = 2 then "February"
    when mnth = 3 then "March"
    when mnth = 4 then "April"
    when mnth = 5 then "May"
    when mnth = 6 then "June"
    when mnth = 7 then "July"
    when mnth = 8 then "August"
    when mnth = 9 then "September"
    when mnth = 10 then "October"
    when mnth = 11 then "November"
    when mnth = 12 then "December"
end as Months,
	   sum(registered) as Total_Registerd_Bikes
from hours
group by Months;

/*Revenue & Growth Opportunities
/*8.What is the rental trend over the years(YOY)?
-  Measures business expansion and adoption trends.*/
select 
	sum(case when yr = 0 then cnt else 0 end) as Total_Bookings_Of_Year2011,
    sum(case when yr = 1 then cnt else 0 end) as Total_Bookings_Of_Year2012,
    (sum(case when yr = 1 then casual + registered end)-
     sum(case when yr = 0 then casual + registered end))/
     sum(case when yr = 0 then casual + registered end) * 100  as Growth_Percentage
from hours;

/*9.Finding the Busiest Rental Time per Season
What is the peak hour for bike rentals in each season?
- Why? Helps identify when to allocate more bikes based on seasonal trends.*/
select hr as Hour,
	sum(case when season = 1 then cnt else 0 end) as Spring,
    sum(case when season = 2 then cnt else 0 end) as Summer,
    sum(case when season = 3 then cnt else 0 end) as Fall,
    sum(case when season = 4 then cnt else 0 end) as Winter
    from hours
group by Hour;

/*10.Weather Impact Analysis (JOIN + Aggregation)
How does bad weather impact casual vs registered users?
- Why? Helps determine if bad weather discourages casual users more than registered users.
- Provides insights for discount offers & subscription models.*/
select 
	case
        when weathersit = 1 then "Clean Day"
		when weathersit = 2 then "Cloudy Day"
		when weathersit = 3 then "Rainy Day"
	end as Weather_Status,
sum(casual) as Total_Casual_Bookings,
sum(registered) as Total_Registered_Bookings
from day
group by Weather_Status
order by Total_Casual_Bookings,Total_Registered_Bookings;

/*11.dentifying Growth Trends (Window Functions)
What is the monthly trend of total rentals, with a moving average?
- Why? A moving average smooths out fluctuations to reveal real trends.
- Helps in long-term demand forecasting.
- using over rows between preceeding and curreent row*/
select
	case
	when mnth = 1 then "January"
    when mnth = 2 then "February"
    when mnth = 3 then "March"
    when mnth = 4 then "April"
    when mnth = 5 then "May"
    when mnth = 6 then "June"
    when mnth = 7 then "July"
    when mnth = 8 then "August"
    when mnth = 9 then "September"
    when mnth = 10 then "October"
    when mnth = 11 then "November"
    when mnth = 12 then "December"
end as Months,
 sum(cnt) as Total_Rentals,
 round(avg(sum(cnt))over(order by mnth rows between 2 preceding and current row),2)
as MovingAvg_Rental
from  day
group by mnth
order by mnth;

/*12. Finding the Best Marketing Time (Combination of Factors)
What time and conditions have the highest rentals?
- Why? Pinpoints ideal times for promotions and discounts.
- Determines ideal promotional slots for advertisements & discounts
These queries can help with business decisions like fleet expansion, pricing models, marketing timing, and demand forecasting.*/
select 
	case
        when weathersit = 1 then "Clean Day"
		when weathersit = 2 then "Cloudy Day"
		when weathersit = 3 then "Rainy Day"
	end as Weather_Status,
hr as Hour_Of_Day,sum(registered) as Total_Registered_Bookings
from hours
group by Weather_Status,Hour_Of_Day
order by Total_Registered_Bookings desc
limit 1;

/*13.Bike Utilization Efficiency
What percentage of total available bikes were used per day?
(Assuming 10,000 bikes are available) 
- Why? Ensures optimal fleet usage without oversupply/shortages.*/
select date_format(str_to_date(dteday,"%Y-%m-%d"),"%d-%m-%Y") as Day,cnt,
round(cnt/10000,2) as Estimated_Usage
from day
order by Estimated_Usage desc; -- change it

/*14.Find out which day had the highest bike rentals on a working day.
- Helps in planning corporate & commuter subscription programs*/
select 
	case -- 2nd case 
		when weekday = 0 then "Monday"
		when weekday = 1 Then "Tuesday"
		when weekday = 2 Then "Wednesday"
		when weekday = 3 Then "Thursday"
		when weekday = 4 Then "Friday"
		when weekday = 5 Then "Saturday"
		when weekday = 6 Then "Sunday"    
	end as Weekday,
sum(cnt) as Total_rentals
from day
where workingday = 1
group by weekday
order by Total_rentals;

/*Operational Efficiency
/*15.When is the highest number bookings recorded compared to weekdays,weekend and Holiday*/
select 
	sum(case when holiday = 0 then cnt else 0 end) as Holiday,
	sum(case when weekday between 1 and 5 then cnt else 0 end) as Weekday,
    sum(case when weekday between 6 and 7 then cnt else 0 end) as Weekend
from day;






