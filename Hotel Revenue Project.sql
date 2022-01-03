/*
Hotel Revenue Data Cleaning, and Exploration
Skills used: Converting Data Types, CTE's, Aggregate Functions, Joins
*/


--Look at the data. Combine for easier use.

SELECT *
FROM ProjectsPortfolio..HotelRevenue2018
UNION
SELECT *
FROM ProjectsPortfolio..HotelRevenue2019
UNION
SELECT *
FROM ProjectsPortfolio..HotelRevenue2020


--Convert reservation_status_date from DateTime to Date

ALTER TABLE	ProjectsPortfolio..HotelRevenue2018
ADD ReservationDate Date

UPDATE ProjectsPortfolio..HotelRevenue2018
SET ReservationDate = CONVERT(date, reservation_status_date)


ALTER TABLE	ProjectsPortfolio..HotelRevenue2019
ADD ReservationDate Date

UPDATE ProjectsPortfolio..HotelRevenue2019
SET ReservationDate = CONVERT(date, reservation_status_date)


ALTER TABLE	ProjectsPortfolio..HotelRevenue2020
ADD ReservationDate Date

UPDATE ProjectsPortfolio..HotelRevenue2020
SET ReservationDate = CONVERT(date, reservation_status_date)


--Is revenue growing year over year across all hotel types?
--Use CTE to query total revenue

WITH TotalHotel AS
	(
	SELECT *
	FROM ProjectsPortfolio..HotelRevenue2018
	UNION
	SELECT *
	FROM ProjectsPortfolio..HotelRevenue2019
	UNION
	SELECT *
	FROM ProjectsPortfolio..HotelRevenue2020
	)
SELECT hotel, arrival_date_year, SUM((stays_in_weekend_nights + stays_in_week_nights) * adr) AS TotalHotelRevenue
FROM TotalHotel
GROUP BY arrival_date_year, hotel
--Revenue grows from 2018 to 2019, but drops slightly in 2020.


--How much in meal discounts were given?

WITH TotalHotel AS
	(
	SELECT *
	FROM ProjectsPortfolio..HotelRevenue2018
	UNION
	SELECT *
	FROM ProjectsPortfolio..HotelRevenue2019
	UNION
	SELECT *
	FROM ProjectsPortfolio..HotelRevenue2020
	)
SELECT TotalHotel.market_segment, Discount AS DiscountRate, SUM(Cost*Discount) AS TotalDiscountsGiven
FROM TotalHotel
	LEFT JOIN HotelMealCost
		ON TotalHotel.meal = HotelMealCost.meal
	LEFT JOIN HotelMarketSegment
		ON TotalHotel.market_segment = HotelMarketSegment.market_segment
GROUP BY TotalHotel.market_segment, Discount
ORDER BY TotalDiscountsGiven DESC


--Which country do guests come from?

WITH TotalHotel AS
	(
	SELECT *
	FROM ProjectsPortfolio..HotelRevenue2018
	UNION
	SELECT *
	FROM ProjectsPortfolio..HotelRevenue2019
	UNION
	SELECT *
	FROM ProjectsPortfolio..HotelRevenue2020
	)
SELECT country, SUM(adults) AS Guests
FROM TotalHotel
GROUP BY country
ORDER BY Guests DESC