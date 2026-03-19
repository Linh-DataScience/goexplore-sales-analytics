-- ============================================================
-- GoExplore Sales Analytics – BigQuery Queries
-- Dataset: GoExplore_data
-- Period:  Jan 2015 – Jul 2018
-- ============================================================


-- ------------------------------------------------------------
-- 1. MASTER VIEW
--    Joins all source tables into one clean analysis layer
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW `GoExplore_data.vw_master` AS

SELECT
  s.Date,
  EXTRACT(YEAR  FROM s.Date)          AS Year,
  EXTRACT(MONTH FROM s.Date)          AS Month,
  FORMAT_DATE('%Y-%m', s.Date)        AS YearMonth,

  p.Product,
  p.Product_line,
  p.Product_type,
  p.Product_brand,

  r.Retailer_name,
  r.Type                              AS Retailer_type,
  r.Country,

  m.Order_method_type,

  s.Quantity,
  s.Unit_sale_price,
  s.Unit_price,
  p.Unit_cost,

  -- calculated fields
  s.Quantity * s.Unit_sale_price                        AS Revenue,
  s.Quantity * p.Unit_cost                              AS COGS,
  (s.Quantity * s.Unit_sale_price)
    - (s.Quantity * p.Unit_cost)                        AS Gross_Profit,
  SAFE_DIVIDE(
    s.Unit_sale_price - s.Unit_price,
    s.Unit_price)                                       AS Discount_pct

FROM `GoExplore_data.daily_sales`  s
LEFT JOIN `GoExplore_data.products`  p ON s.Product_number   = p.Product_number
LEFT JOIN `GoExplore_data.retailers` r ON s.Retailer_code    = r.Retailer_code
LEFT JOIN `GoExplore_data.methods`   m ON s.Order_method_code = m.Order_method_code;


-- ------------------------------------------------------------
-- 2. EXECUTIVE KPIs
--    High-level summary metrics for the full period
-- ------------------------------------------------------------

SELECT
  ROUND(SUM(Revenue), 0)                              AS Total_Revenue,
  ROUND(SUM(Gross_Profit), 0)                         AS Total_Gross_Profit,
  ROUND(SAFE_DIVIDE(
    SUM(Gross_Profit), SUM(Revenue)) * 100, 1)        AS Gross_Margin_Pct,
  SUM(Quantity)                                       AS Total_Units_Sold,
  COUNT(*)                                            AS Total_Transactions,
  COUNT(DISTINCT Country)                             AS Active_Countries,
  COUNT(DISTINCT Retailer_name)                       AS Active_Retailers,
  ROUND(AVG(ABS(Discount_pct)) * 100, 1)             AS Avg_Discount_Pct
FROM `GoExplore_data.vw_master`;


-- ------------------------------------------------------------
-- 3. YEAR-OVER-YEAR PERFORMANCE
-- ------------------------------------------------------------

SELECT
  Year,
  ROUND(SUM(Revenue), 0)                              AS Revenue,
  ROUND(SUM(Gross_Profit), 0)                         AS Gross_Profit,
  ROUND(SAFE_DIVIDE(
    SUM(Gross_Profit), SUM(Revenue)) * 100, 1)        AS Gross_Margin_Pct,
  SUM(Quantity)                                       AS Units_Sold,
  COUNT(*)                                            AS Transactions
FROM `GoExplore_data.vw_master`
GROUP BY Year
ORDER BY Year;


-- ------------------------------------------------------------
-- 4. MONTHLY REVENUE TREND
-- ------------------------------------------------------------

SELECT
  YearMonth,
  Year,
  Month,
  ROUND(SUM(Revenue), 0)       AS Revenue,
  ROUND(SUM(Gross_Profit), 0)  AS Gross_Profit,
  SUM(Quantity)                AS Units_Sold
FROM `GoExplore_data.vw_master`
GROUP BY YearMonth, Year, Month
ORDER BY YearMonth;


-- ------------------------------------------------------------
-- 5. REVENUE BY PRODUCT LINE
-- ------------------------------------------------------------

SELECT
  Product_line,
  ROUND(SUM(Revenue), 0)                              AS Revenue,
  ROUND(SUM(Gross_Profit), 0)                         AS Gross_Profit,
  ROUND(SAFE_DIVIDE(
    SUM(Gross_Profit), SUM(Revenue)) * 100, 1)        AS Gross_Margin_Pct,
  SUM(Quantity)                                       AS Units_Sold,
  ROUND(SAFE_DIVIDE(
    SUM(Revenue),
    SUM(SUM(Revenue)) OVER ()) * 100, 1)              AS Revenue_Share_Pct
FROM `GoExplore_data.vw_master`
GROUP BY Product_line
ORDER BY Revenue DESC;


-- ------------------------------------------------------------
-- 6. TOP 10 PRODUCTS BY REVENUE
-- ------------------------------------------------------------

SELECT
  p.Product,
  p.Product_brand,
  p.Product_line,
  ROUND(SUM(s.Revenue), 0)                            AS Revenue,
  ROUND(SUM(s.Gross_Profit), 0)                       AS Gross_Profit,
  ROUND(SAFE_DIVIDE(
    SUM(s.Gross_Profit), SUM(s.Revenue)) * 100, 1)    AS Gross_Margin_Pct,
  SUM(s.Quantity)                                     AS Units_Sold
FROM `GoExplore_data.vw_master` s
JOIN `GoExplore_data.products`  p USING (Product_number)
GROUP BY p.Product, p.Product_brand, p.Product_line
ORDER BY Revenue DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 7. REVENUE BY COUNTRY
-- ------------------------------------------------------------

SELECT
  Country,
  ROUND(SUM(Revenue), 0)                              AS Revenue,
  ROUND(SUM(Gross_Profit), 0)                         AS Gross_Profit,
  SUM(Quantity)                                       AS Units_Sold,
  COUNT(DISTINCT Retailer_name)                       AS Num_Retailers,
  ROUND(SAFE_DIVIDE(
    SUM(Revenue),
    SUM(SUM(Revenue)) OVER ()) * 100, 1)              AS Revenue_Share_Pct
FROM `GoExplore_data.vw_master`
GROUP BY Country
ORDER BY Revenue DESC;


-- ------------------------------------------------------------
-- 8. REVENUE BY ORDER CHANNEL
-- ------------------------------------------------------------

SELECT
  Order_method_type,
  ROUND(SUM(Revenue), 0)                              AS Revenue,
  SUM(Quantity)                                       AS Units_Sold,
  COUNT(*)                                            AS Transactions,
  ROUND(SAFE_DIVIDE(
    SUM(Revenue),
    SUM(SUM(Revenue)) OVER ()) * 100, 1)              AS Revenue_Share_Pct
FROM `GoExplore_data.vw_master`
GROUP BY Order_method_type
ORDER BY Revenue DESC;


-- ------------------------------------------------------------
-- 9. TOP 10 RETAILERS
-- ------------------------------------------------------------

SELECT
  Retailer_name,
  Country,
  Retailer_type,
  ROUND(SUM(Revenue), 0)       AS Revenue,
  SUM(Quantity)                AS Units_Sold,
  COUNT(*)                     AS Transactions
FROM `GoExplore_data.vw_master`
GROUP BY Retailer_name, Country, Retailer_type
ORDER BY Revenue DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 10. REVENUE BY RETAILER TYPE
-- ------------------------------------------------------------

SELECT
  Retailer_type,
  ROUND(SUM(Revenue), 0)                              AS Revenue,
  ROUND(SAFE_DIVIDE(
    SUM(Gross_Profit), SUM(Revenue)) * 100, 1)        AS Gross_Margin_Pct,
  COUNT(DISTINCT Retailer_name)                       AS Num_Retailers,
  ROUND(SAFE_DIVIDE(
    SUM(Revenue),
    SUM(SUM(Revenue)) OVER ()) * 100, 1)              AS Revenue_Share_Pct
FROM `GoExplore_data.vw_master`
GROUP BY Retailer_type
ORDER BY Revenue DESC;
