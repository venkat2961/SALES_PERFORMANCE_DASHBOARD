-- Sales Performance Dashboard | SQL Server starter script
-- Run in a new database, e.g. SalesPerformanceDB.
-- Import orders.csv, customers.csv, products.csv into matching tables after creating them.

CREATE TABLE dbo.Customers (
    CustomerID VARCHAR(10) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Segment VARCHAR(50),
    Region VARCHAR(30),
    City VARCHAR(50),
    JoinDate DATE
);

CREATE TABLE dbo.Products (
    ProductID VARCHAR(10) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    UnitPrice DECIMAL(12,2),
    BaseMargin DECIMAL(5,4)
);

CREATE TABLE dbo.Orders (
    OrderID VARCHAR(10) PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerID VARCHAR(10) NOT NULL,
    ProductID VARCHAR(10) NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    DiscountPct DECIMAL(5,4) DEFAULT 0,
    Sales DECIMAL(14,2) NOT NULL,
    Cost DECIMAL(14,2) NOT NULL,
    ShippingDays INT,
    PaymentMethod VARCHAR(50),
    OrderStatus VARCHAR(30),
    Profit AS (Sales - Cost) PERSISTED,
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID),
    CONSTRAINT FK_Orders_Products FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID)
);

-- 1. Executive KPIs
SELECT
    SUM(Sales) AS TotalSales,
    SUM(Profit) AS TotalProfit,
    CAST(100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0) AS DECIMAL(6,2)) AS ProfitMarginPct,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS UniqueCustomers,
    SUM(Quantity) AS UnitsSold
FROM dbo.Orders
WHERE OrderStatus = 'Delivered';

-- 2. Monthly sales and profit trend
SELECT YEAR(OrderDate) AS SalesYear, MONTH(OrderDate) AS SalesMonth,
       SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit
FROM dbo.Orders
WHERE OrderStatus = 'Delivered'
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY SalesYear, SalesMonth;

-- 3. Sales by region
SELECT c.Region, SUM(o.Sales) AS TotalSales, SUM(o.Profit) AS TotalProfit
FROM dbo.Orders o
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderStatus = 'Delivered'
GROUP BY c.Region
ORDER BY TotalSales DESC;

-- 4. Category and product performance
SELECT p.Category, p.ProductName, SUM(o.Sales) AS TotalSales,
       SUM(o.Profit) AS TotalProfit, SUM(o.Quantity) AS UnitsSold
FROM dbo.Orders o
JOIN dbo.Products p ON o.ProductID = p.ProductID
WHERE o.OrderStatus = 'Delivered'
GROUP BY p.Category, p.ProductName
ORDER BY TotalSales DESC;

-- 5. Segment performance
SELECT c.Segment, SUM(o.Sales) AS TotalSales, SUM(o.Profit) AS TotalProfit,
       COUNT(DISTINCT o.CustomerID) AS Customers
FROM dbo.Orders o
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderStatus = 'Delivered'
GROUP BY c.Segment
ORDER BY TotalSales DESC;

-- 6. Discount impact
SELECT CASE WHEN DiscountPct = 0 THEN 'No discount'
            WHEN DiscountPct <= 0.05 THEN '1-5%'
            WHEN DiscountPct <= 0.10 THEN '6-10%'
            ELSE 'Above 10%' END AS DiscountBand,
       SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit,
       AVG(DiscountPct) * 100 AS AvgDiscountPct
FROM dbo.Orders
WHERE OrderStatus = 'Delivered'
GROUP BY CASE WHEN DiscountPct = 0 THEN 'No discount'
              WHEN DiscountPct <= 0.05 THEN '1-5%'
              WHEN DiscountPct <= 0.10 THEN '6-10%'
              ELSE 'Above 10%' END
ORDER BY TotalSales DESC;

-- 7. Returned and cancelled orders (operational view)
SELECT OrderStatus, COUNT(*) AS OrderCount, SUM(Sales) AS OrderValue
FROM dbo.Orders
GROUP BY OrderStatus
ORDER BY OrderCount DESC;

-- 8. Top 10 customers by sales
SELECT TOP 10 c.CustomerID, c.CustomerName, c.Segment, c.Region,
       SUM(o.Sales) AS TotalSales, SUM(o.Profit) AS TotalProfit
FROM dbo.Orders o
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderStatus = 'Delivered'
GROUP BY c.CustomerID, c.CustomerName, c.Segment, c.Region
ORDER BY TotalSales DESC;

-- 9. Data quality checks
SELECT COUNT(*) AS NullOrderDates FROM dbo.Orders WHERE OrderDate IS NULL;
SELECT OrderID, Sales, Cost FROM dbo.Orders WHERE Sales < 0 OR Cost < 0;
SELECT CustomerID, COUNT(*) AS DuplicateCount
FROM dbo.Customers GROUP BY CustomerID HAVING COUNT(*) > 1;
