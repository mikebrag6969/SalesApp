USE [SalesDB]
GO

/****** Object:  StoredProcedure [dbo].[sp_getOrdersByDeliveryStatus]    Script Date: 12/10/2024 20:56:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_getOrdersByDeliveryStatus]
    @DateType NVARCHAR(50),
    @StartDate DATETIME,
    @EndDate DATETIME,
    @DeliveryStatus NVARCHAR(50) -- "Late" or "Early"
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the user wants orders delivered early or late
    IF @DeliveryStatus = 'Late'
    BEGIN
        SELECT TOP 10 
            OrderID, CustomerID, ProductID, Quantity, OrderDate, RequestedDeliveryDate, ActualDeliveryDate,
            DATEDIFF(DAY, RequestedDeliveryDate, ActualDeliveryDate) AS DaysDifference
        FROM Orders
        WHERE ActualDeliveryDate > RequestedDeliveryDate
            AND CASE @DateType 
                    WHEN 'OrderDate' THEN OrderDate
                    WHEN 'RequestedDeliveryDate' THEN RequestedDeliveryDate
                    WHEN 'ActualDeliveryDate' THEN ActualDeliveryDate
                END BETWEEN @StartDate AND @EndDate
        ORDER BY DaysDifference DESC;
    END
    ELSE IF @DeliveryStatus = 'Early'
    BEGIN
        SELECT TOP 10 
            OrderID, CustomerID, ProductID, Quantity, OrderDate, RequestedDeliveryDate, ActualDeliveryDate,
            DATEDIFF(DAY, ActualDeliveryDate, RequestedDeliveryDate) AS DaysDifference
        FROM Orders
        WHERE ActualDeliveryDate < RequestedDeliveryDate
            AND CASE @DateType 
                    WHEN 'OrderDate' THEN OrderDate
                    WHEN 'RequestedDeliveryDate' THEN RequestedDeliveryDate
                    WHEN 'ActualDeliveryDate' THEN ActualDeliveryDate
                END BETWEEN @StartDate AND @EndDate
        ORDER BY DaysDifference DESC;
    END
END
GO






USE [SalesDB]
GO

/****** Object:  StoredProcedure [dbo].[sp_getTopSellingProductsByCity]    Script Date: 12/10/2024 20:57:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author Name>
-- Create date: <Create Date>
-- Description:	Returns the top-selling products across all cities.
-- =============================================
CREATE PROCEDURE [dbo].[sp_getTopSellingProductsByCity]
AS
BEGIN
    SET NOCOUNT ON;
WITH CityProductSales AS (
    -- שלב 1: סיכום מכירות של כל מוצר בכל עיר
    SELECT
        p.ProductName,
        c.City,
        SUM(o.Quantity) AS TotalSales
    FROM Orders o
    INNER JOIN Products p ON o.ProductID = p.ProductID
    INNER JOIN Customers c ON o.CustomerID = c.CustomerID
    GROUP BY p.ProductName, c.City
),
MaxCitySales AS (
    -- שלב 2: מציאת העיר עם הכי הרבה מכירות לכל מוצר
    SELECT
        ProductName,
        City,
        TotalSales,
        RANK() OVER (PARTITION BY ProductName ORDER BY TotalSales DESC) AS CityRank
    FROM CityProductSales
),
TopSalesByCity AS (
    -- שלב 3: בחירת העיר עם הכי הרבה מכירות לכל מוצר
    SELECT
        ProductName,
        City,
        TotalSales
    FROM MaxCitySales
    WHERE CityRank = 1
),
TopThreeProducts AS (
    -- שלב 4: בחירת שלושת המוצרים המובילים בסך המכירות בכל עיר
    SELECT
        ProductName,
        City,
        TotalSales,
        RANK() OVER (ORDER BY TotalSales DESC) AS OverallRank
    FROM TopSalesByCity
)
-- תוצאה סופית: שלושת המוצרים עם הכי הרבה מכירות בערים השונות
SELECT
    ProductName,
    City,
    TotalSales
FROM TopThreeProducts
WHERE OverallRank <= 3
ORDER BY TotalSales DESC;
END
GO




