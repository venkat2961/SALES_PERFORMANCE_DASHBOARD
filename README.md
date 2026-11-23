# Sales Performance Dashboard — End-to-End Portfolio Project

## Project goal
Build a business-ready sales dashboard using Excel, SQL, and Power BI. This starter project contains synthetic sample data for 2024–2025. It is for learning and portfolio demonstration, not real company data.

## Files
- `orders.csv` — 2,600 order-line records with dates, quantities, discounts, sales, costs, profit, shipping, payment method, and status.
- `customers.csv` — 220 customer records with segment, region, city, and join date.
- `products.csv` — 14 product records with category, price, and base margin.
- `sales_queries.sql` — SQL Server table definitions, KPI queries, performance analysis, and data quality checks.
- `powerbi_dax_measures.txt` — DAX measures and Date table setup.

## Business questions
1. What are total sales, profit, profit margin, orders, and units sold?
2. How do sales and profit change month over month and year over year?
3. Which regions, categories, products, and customer segments perform best?
4. Which customers contribute the most sales and profit?
5. How do discounts relate to profitability?
6. How many orders are delivered, returned, or cancelled?

## Recommended end-to-end workflow

### Phase 1 — Excel data inspection and cleaning
1. Open each CSV in Excel (Data → From Text/CSV is preferred).
2. Confirm data types: dates as Date; quantity/shipping days as whole numbers; sales/cost/price as currency; discount as percentage.
3. Check blanks, duplicate IDs, negative values, and unexpected statuses.
4. Verify `Profit = Sales - Cost` and `Sales = Quantity × UnitPrice × (1 - DiscountPct)` (allow for rounding).
5. Create an Excel table for each dataset and use PivotTables to explore sales by month, region, category, and segment.
6. Record cleaning decisions in your README; do not silently delete records.

### Phase 2 — SQL analysis (SQL Server)
1. Create a database named `SalesPerformanceDB`.
2. Create tables using `sales_queries.sql`.
3. Import CSVs into `Customers`, `Products`, and `Orders` in that order (to respect foreign keys). If your import wizard cannot load the computed `Profit` column, do not map a CSV Profit field into it; the SQL column is computed.
4. Run each query and save screenshots of results for GitHub.
5. Explain 3–5 findings from query outputs in plain business language.

### Phase 3 — Power BI data model
1. Power BI Desktop → Get Data → Text/CSV; load all three CSV files.
2. In Power Query, set correct data types, check errors/nulls, and rename tables exactly `Orders`, `Customers`, `Products`.
3. Create a Date table using the DAX expression in `powerbi_dax_measures.txt`.
4. Create relationships:
   - `Customers[CustomerID]` (1) → `Orders[CustomerID]` (*)
   - `Products[ProductID]` (1) → `Orders[ProductID]` (*)
   - `Date[Date]` (1) → `Orders[OrderDate]` (*)
5. Mark `Date` as the date table using `Date[Date]`.
6. Add the DAX measures from the supplied file. Format Sales/Profit/AOV as currency, margin/change as percentage, orders/units as whole numbers.
7. Use single-direction relationships from dimension tables to Orders unless you have a justified reason to change them.

### Phase 4 — Dashboard pages

**Page 1: Executive Overview**
- KPI cards: Total Sales, Total Profit, Profit Margin %, Total Orders, Unique Customers, Average Order Value.
- Line chart: Total Sales by Date[Year Month].
- Clustered bar chart: Total Sales and Total Profit by Region.
- Donut chart: Total Sales by Category.
- Slicers: Date, Region, Segment, Category.
- Add a subtitle noting that core KPIs include delivered orders only.

**Page 2: Product & Region Analysis**
- Bar chart: Total Sales by ProductName (Top N = 10).
- Matrix: Category → ProductName with Total Sales, Total Profit, Profit Margin % and Units Sold.
- Map or bar chart: Sales by City/Region (a bar chart is easier to interpret).
- Scatter chart: Total Sales vs Total Profit by product; use product as details.
- Slicers: Date, Region, Category.

**Page 3: Customer & Order Analysis**
- Bar chart: Total Sales by Segment.
- Table: Top customers with sales and profit.
- Column chart: Returned Orders and Cancelled Orders (these are separate operational metrics, not part of delivered-order sales).
- Column chart: Total Sales by PaymentMethod.
- Slicers: Segment, Region, OrderStatus, Date.

## Suggested design
- Canvas: 16:9 widescreen.
- Keep a consistent theme, 2–3 main colors, clear titles, readable labels, and enough whitespace.
- Use currency formatting consistently (₹ if presenting as an India-focused portfolio).
- Use meaningful tooltips and synced slicers.
- Add alt text where practical and test the report at normal laptop size.

## Important modeling note
The sample dataset is at order-line level (one product per order ID in this simplified dataset). Core sales/profit KPIs filter to `Delivered`. Returned/cancelled counts are shown separately. State these assumptions in the report. For real datasets, agree with stakeholders on whether returned orders should be netted from sales and how discounts, shipping, tax, and returns are recorded.

## Phase 5 — Validate
- Reconcile Power BI Total Sales/Profit with SQL results for delivered orders.
- Select one region and verify visuals respond to slicers.
- Check monthly trend sorting; do not sort month labels alphabetically.
- Test date slicers across both years.
- Confirm no blank customer/product relationships and no unexpected negative sales.
- Compare a few records manually against the CSV.


## Suggested GitHub repository structure
```
sales-performance-dashboard/
├── data/
│   ├── orders.csv
│   ├── customers.csv
│   └── products.csv
├── sql/
│   └── sales_queries.sql
├── powerbi/
│   ├── sales_performance_dashboard.pbix   # add your finished file
│   └── screenshots/
├── docs/
│   └── dashboard-notes.md
└── README.md
```
