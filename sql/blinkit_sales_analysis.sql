-- =====================================================
-- BLINKIT SALES & OUTLET PERFORMANCE ANALYSIS
-- SQL PROJECT
-- Database: blinkit_analytics
-- Dataset Records: 8,523
-- Tools: MySQL
-- Analysis: Sales, Products, Outlets & Business Insights

-- =====================================================
-- STEP 1: DATABASE & TABLE SETUP
-- =====================================================

-- 1. Create Database
CREATE DATABASE blinkit_analytics;

-- 2. Select Database
USE blinkit_analytics;

-- 3. Create Main Sales Table
CREATE TABLE blinkit_sales (
    item_fat_content VARCHAR(20),
    item_identifier VARCHAR(20),
    item_type VARCHAR(50),
    outlet_establishment_year INT,
    outlet_identifier VARCHAR(20),
    outlet_location_type VARCHAR(20),
    outlet_size VARCHAR(20),
    outlet_type VARCHAR(50),
    item_visibility DECIMAL(10,6),
    sales DECIMAL(12,4),
    rating DECIMAL(3,2)
);

-- 4. Check Table Structure
DESCRIBE blinkit_sales;

-- 5. Check Initial Record Count
SELECT COUNT(*) AS total_records
FROM blinkit_sales;

-- =====================================================
-- STEP 2: DATA CLEANING & VALIDATION
-- =====================================================

-- 1. Missing Values Check
SELECT
    SUM(item_fat_content IS NULL OR TRIM(item_fat_content) = '') AS fat_content_missing,
    SUM(item_identifier IS NULL OR TRIM(item_identifier) = '') AS identifier_missing,
    SUM(item_type IS NULL OR TRIM(item_type) = '') AS type_missing,
    SUM(outlet_establishment_year IS NULL) AS year_missing,
    SUM(outlet_identifier IS NULL OR TRIM(outlet_identifier) = '') AS outlet_id_missing,
    SUM(outlet_location_type IS NULL OR TRIM(outlet_location_type) = '') AS location_missing,
    SUM(outlet_size IS NULL OR TRIM(outlet_size) = '') AS size_missing,
    SUM(outlet_type IS NULL OR TRIM(outlet_type) = '') AS outlet_type_missing,
    SUM(item_visibility IS NULL) AS visibility_missing,
    SUM(sales IS NULL) AS sales_missing,
    SUM(rating IS NULL) AS rating_missing
FROM blinkit_sales;

-- 2. Duplicate Records CheckDONE

SELECT
    COUNT(*) - COUNT(DISTINCT
        CONCAT_WS('|',
            item_fat_content,
            item_identifier,
            item_type,
            outlet_establishment_year,
            outlet_identifier,
            outlet_location_type,
            outlet_size,
            outlet_type,
            item_visibility,
            sales,
            rating
        )
    ) AS duplicate_records
FROM blinkit_sales;

-- 3. Numeric Range Validation
-- Check invalid Sales values
SELECT COUNT(*) AS invalid_sales
FROM blinkit_sales
WHERE sales <= 0;

-- Check invalid Rating values
SELECT COUNT(*) AS invalid_ratings
FROM blinkit_sales
WHERE rating < 1 OR rating > 5;

-- Check invalid Item Visibility values
SELECT COUNT(*) AS invalid_visibility
FROM blinkit_sales
WHERE item_visibility < 0;

-- Check invalid Establishment Years
SELECT COUNT(*) AS invalid_establishment_year
FROM blinkit_sales
WHERE outlet_establishment_year < 2000;

-- 4. Categorical Value Validation

-- Item Fat Content
SELECT item_fat_content, COUNT(*) AS record_count
FROM blinkit_sales
GROUP BY item_fat_content
ORDER BY record_count DESC;

-- Outlet Location Type
SELECT outlet_location_type, COUNT(*) AS record_count
FROM blinkit_sales
GROUP BY outlet_location_type
ORDER BY record_count DESC;

-- Outlet Size
SELECT outlet_size, COUNT(*) AS record_count
FROM blinkit_sales
GROUP BY outlet_size
ORDER BY record_count DESC;

-- Outlet Type
SELECT outlet_type, COUNT(*) AS record_count
FROM blinkit_sales
GROUP BY outlet_type
ORDER BY record_count DESC;

-- 5. Standardize Item Fat Content

SET SQL_SAFE_UPDATES = 0;

UPDATE blinkit_sales
SET item_fat_content = CASE
    WHEN LOWER(TRIM(item_fat_content)) IN ('lf', 'low fat')
        THEN 'Low Fat'
    WHEN LOWER(TRIM(item_fat_content)) = 'reg'
        THEN 'Regular'
    ELSE TRIM(item_fat_content)
END;

SET SQL_SAFE_UPDATES = 1;


-- 6. Validate Standardized Values

SELECT
    item_fat_content,
    COUNT(*) AS record_count
FROM blinkit_sales
GROUP BY item_fat_content
ORDER BY record_count DESC;

-- 7. Final Data Quality Check

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT item_identifier) AS unique_products,
    COUNT(DISTINCT item_type) AS product_categories,
    COUNT(DISTINCT outlet_identifier) AS total_outlets,
    COUNT(DISTINCT outlet_type) AS outlet_types,
    COUNT(DISTINCT outlet_location_type) AS location_tiers
FROM blinkit_sales;


-- 8. Final Missing Value Check

SELECT
    COUNT(*) AS total_records,
    SUM(
        item_fat_content IS NULL
        OR item_identifier IS NULL
        OR item_type IS NULL
        OR outlet_establishment_year IS NULL
        OR outlet_identifier IS NULL
        OR outlet_location_type IS NULL
        OR outlet_size IS NULL
        OR outlet_type IS NULL
        OR item_visibility IS NULL
        OR sales IS NULL
        OR rating IS NULL
    ) AS rows_with_missing_values
FROM blinkit_sales;

-- =====================================================
-- STEP 3: KPI ANALYSIS
-- =====================================================

-- 1. Total Sales
SELECT
    ROUND(SUM(sales), 2) AS total_sales
FROM blinkit_sales;

-- 2. Average Sales per Record
SELECT
    ROUND(AVG(sales), 2) AS average_sales_per_record
FROM blinkit_sales;


-- 3. Average Rating
SELECT
    ROUND(AVG(rating), 2) AS average_rating
FROM blinkit_sales;


-- 4. Average Item Visibility
SELECT
    ROUND(AVG(item_visibility), 4) AS average_item_visibility
FROM blinkit_sales;


-- 5. Unique Products
SELECT
    COUNT(DISTINCT item_identifier) AS unique_products
FROM blinkit_sales;


-- 6. Product Categories
SELECT
    COUNT(DISTINCT item_type) AS product_categories
FROM blinkit_sales;


-- 7. Total Outlets
SELECT
    COUNT(DISTINCT outlet_identifier) AS total_outlets
FROM blinkit_sales;


-- 8. Outlet Types
SELECT
    COUNT(DISTINCT outlet_type) AS outlet_types
FROM blinkit_sales;


-- 9. Location Tiers
SELECT
    COUNT(DISTINCT outlet_location_type) AS location_tiers
FROM blinkit_sales;

-- 10. Consolidated KPI Summary

SELECT
    COUNT(*) AS total_records,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales_per_record,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(item_visibility), 4) AS average_item_visibility,
    COUNT(DISTINCT item_identifier) AS unique_products,
    COUNT(DISTINCT item_type) AS product_categories,
    COUNT(DISTINCT outlet_identifier) AS total_outlets,
    COUNT(DISTINCT outlet_type) AS outlet_types,
    COUNT(DISTINCT outlet_location_type) AS location_tiers
FROM blinkit_sales;

-- =====================================================
-- STEP 4: PRODUCT / CATEGORY ANALYSIS
-- =====================================================

-- 1. Sales by Item Type

SELECT
    item_type,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(*) AS record_count,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY item_type
ORDER BY total_sales DESC;

-- 2. Top 10 Products by Total Sales

SELECT
    item_identifier,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(*) AS record_count,
    ROUND(AVG(rating), 2) AS average_rating
FROM blinkit_sales
GROUP BY item_identifier
ORDER BY total_sales DESC
LIMIT 10;

-- 3. Top 10 Products with Category

SELECT
    item_identifier,
    item_type,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(*) AS record_count,
    ROUND(AVG(rating), 2) AS average_rating
FROM blinkit_sales
GROUP BY item_identifier, item_type
ORDER BY total_sales DESC
LIMIT 10;

-- 4. Sales Contribution by Item Category

SELECT
    item_type,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(
        SUM(sales) * 100.0 /
        (SELECT SUM(sales) FROM blinkit_sales),
        2
    ) AS sales_contribution_percentage
FROM blinkit_sales
GROUP BY item_type
ORDER BY sales_contribution_percentage DESC;

-- 5. Top 3 Categories Sales Contribution

WITH category_sales AS (
    SELECT
        item_type,
        SUM(sales) AS total_sales
    FROM blinkit_sales
    GROUP BY item_type
),
top_3_categories AS (
    SELECT
        item_type,
        total_sales
    FROM category_sales
    ORDER BY total_sales DESC
    LIMIT 3
)
SELECT
    ROUND(SUM(total_sales), 2) AS top_3_sales,
    ROUND(
        SUM(total_sales) * 100.0 /
        (SELECT SUM(sales) FROM blinkit_sales),
        2
    ) AS top_3_sales_contribution_percentage
FROM top_3_categories;

-- 6. Sales by Item Fat Content

SELECT
    item_fat_content,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(*) AS record_count,
    ROUND(AVG(sales), 2) AS average_sales,
    ROUND(
        SUM(sales) * 100.0 /
        (SELECT SUM(sales) FROM blinkit_sales),
        2
    ) AS sales_contribution_percentage
FROM blinkit_sales
GROUP BY item_fat_content
ORDER BY total_sales DESC;

-- 7. Sales Performance by Rating Band

SELECT
    CASE
        WHEN rating < 3 THEN 'Below 3'
        WHEN rating < 4 THEN '3–3.99'
        WHEN rating < 4.5 THEN '4–4.49'
        ELSE '4.5–5'
    END AS rating_band,
    COUNT(*) AS record_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY
    CASE
        WHEN rating < 3 THEN 'Below 3'
        WHEN rating < 4 THEN '3–3.99'
        WHEN rating < 4.5 THEN '4–4.49'
        ELSE '4.5–5'
    END
ORDER BY total_sales DESC;

-- 8. Sales Performance by Item Visibility Band

SELECT
    CASE
        WHEN item_visibility = 0 THEN '0%'
        WHEN item_visibility < 0.05 THEN '0–5%'
        WHEN item_visibility < 0.10 THEN '5–10%'
        WHEN item_visibility < 0.20 THEN '10–20%'
        ELSE '20%+'
    END AS visibility_band,
    COUNT(*) AS record_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY
    CASE
        WHEN item_visibility = 0 THEN '0%'
        WHEN item_visibility < 0.05 THEN '0–5%'
        WHEN item_visibility < 0.10 THEN '5–10%'
        WHEN item_visibility < 0.20 THEN '10–20%'
        ELSE '20%+'
    END
ORDER BY average_sales DESC;

-- 9. Average Sales by Item Type

SELECT
    item_type,
    COUNT(*) AS record_count,
    ROUND(AVG(sales), 2) AS average_sales,
    ROUND(SUM(sales), 2) AS total_sales
FROM blinkit_sales
GROUP BY item_type
ORDER BY average_sales DESC;

-- 10. Product Analysis Summary Check

SELECT
    COUNT(DISTINCT item_type) AS product_categories,
    COUNT(DISTINCT item_identifier) AS unique_products,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS overall_average_sales
FROM blinkit_sales;

-- =====================================================
-- STEP 5: OUTLET ANALYSIS
-- =====================================================

-- 1. Sales by Outlet Type

SELECT
    outlet_type,
    COUNT(*) AS record_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY outlet_type
ORDER BY total_sales DESC;

-- 2. Average Sales by Outlet Type

SELECT
    outlet_type,
    COUNT(*) AS record_count,
    ROUND(AVG(sales), 2) AS average_sales,
    ROUND(SUM(sales), 2) AS total_sales
FROM blinkit_sales
GROUP BY outlet_type
ORDER BY average_sales DESC;

-- 3. Sales by Outlet Location Tier

SELECT
    outlet_location_type,
    COUNT(*) AS record_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY outlet_location_type
ORDER BY total_sales DESC;

-- 4. Sales by Outlet Size

SELECT
    outlet_size,
    COUNT(*) AS record_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY outlet_size
ORDER BY total_sales DESC;

-- 5. Sales by Outlet Type and Location Tier

SELECT
    outlet_type,
    outlet_location_type,
    COUNT(*) AS record_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY
    outlet_type,
    outlet_location_type
ORDER BY total_sales DESC;

-- 6. Outlet Performance Summary

SELECT
    outlet_identifier,
    outlet_type,
    outlet_location_type,
    outlet_size,
    COUNT(*) AS record_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales,
    ROUND(AVG(rating), 2) AS average_rating
FROM blinkit_sales
GROUP BY
    outlet_identifier,
    outlet_type,
    outlet_location_type,
    outlet_size
ORDER BY total_sales DESC;

-- 7. Outlet Ranking by Total Sales

WITH outlet_sales AS (
    SELECT
        outlet_identifier,
        outlet_type,
        outlet_location_type,
        ROUND(SUM(sales), 2) AS total_sales
    FROM blinkit_sales
    GROUP BY
        outlet_identifier,
        outlet_type,
        outlet_location_type
)

SELECT
    outlet_identifier,
    outlet_type,
    outlet_location_type,
    total_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM outlet_sales
ORDER BY sales_rank;

-- 8. Top Performing Outlet in Each Location Tier

WITH outlet_sales AS (
    SELECT
        outlet_identifier,
        outlet_type,
        outlet_location_type,
        ROUND(SUM(sales), 2) AS total_sales
    FROM blinkit_sales
    GROUP BY
        outlet_identifier,
        outlet_type,
        outlet_location_type
),
ranked_outlets AS (
    SELECT
        outlet_identifier,
        outlet_type,
        outlet_location_type,
        total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY outlet_location_type
            ORDER BY total_sales DESC
        ) AS tier_rank
    FROM outlet_sales
)

SELECT
    outlet_identifier,
    outlet_type,
    outlet_location_type,
    total_sales
FROM ranked_outlets
WHERE tier_rank = 1
ORDER BY outlet_location_type;

-- 9. Outlet Sales Contribution Percentage

SELECT
    outlet_identifier,
    outlet_type,
    outlet_location_type,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(
        SUM(sales) * 100.0 /
        (SELECT SUM(sales) FROM blinkit_sales),
        2
    ) AS sales_contribution_percentage
FROM blinkit_sales
GROUP BY
    outlet_identifier,
    outlet_type,
    outlet_location_type
ORDER BY total_sales DESC;

-- 10. Final Outlet Analysis Summary

SELECT
    COUNT(DISTINCT outlet_identifier) AS total_outlets,
    COUNT(DISTINCT outlet_type) AS outlet_types,
    COUNT(DISTINCT outlet_location_type) AS location_tiers,
    COUNT(*) AS total_records,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales_per_record
FROM blinkit_sales;

-- =====================================================
-- STEP 6: BUSINESS INSIGHTS
-- =====================================================

-- 1. Sales Performance by Outlet Establishment Year

SELECT
    outlet_establishment_year,
    COUNT(*) AS record_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY outlet_establishment_year
ORDER BY outlet_establishment_year;

-- 2. Establishment Year Sales Ranking

WITH yearly_sales AS (
    SELECT
        outlet_establishment_year,
        COUNT(*) AS record_count,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(AVG(sales), 2) AS average_sales
    FROM blinkit_sales
    GROUP BY outlet_establishment_year
)

SELECT
    outlet_establishment_year,
    record_count,
    total_sales,
    average_sales,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM yearly_sales
ORDER BY sales_rank;

-- 3. Establishment Year by Average Sales

SELECT
    outlet_establishment_year,
    COUNT(*) AS record_count,
    ROUND(AVG(sales), 2) AS average_sales,
    ROUND(SUM(sales), 2) AS total_sales
FROM blinkit_sales
GROUP BY outlet_establishment_year
ORDER BY average_sales DESC;

-- 4. Product Category Performance by Outlet Type

SELECT
    item_type,
    outlet_type,
    COUNT(*) AS record_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY
    item_type,
    outlet_type
ORDER BY total_sales DESC
LIMIT 15;

-- 5. Top Product Category in Each Location Tier

WITH category_location_sales AS (
    SELECT
        outlet_location_type,
        item_type,
        ROUND(SUM(sales), 2) AS total_sales
    FROM blinkit_sales
    GROUP BY
        outlet_location_type,
        item_type
),
ranked_categories AS (
    SELECT
        outlet_location_type,
        item_type,
        total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY outlet_location_type
            ORDER BY total_sales DESC
        ) AS tier_rank
    FROM category_location_sales
)

SELECT
    outlet_location_type,
    item_type,
    total_sales
FROM ranked_categories
WHERE tier_rank = 1
ORDER BY outlet_location_type;

-- 6. Sales Performance by Rating Band

SELECT
    CASE
        WHEN rating < 3 THEN 'Below 3'
        WHEN rating < 4 THEN '3–3.99'
        WHEN rating < 4.5 THEN '4–4.49'
        ELSE '4.5–5'
    END AS rating_band,
    COUNT(*) AS record_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY
    CASE
        WHEN rating < 3 THEN 'Below 3'
        WHEN rating < 4 THEN '3–3.99'
        WHEN rating < 4.5 THEN '4–4.49'
        ELSE '4.5–5'
    END
ORDER BY average_sales DESC;

-- 7. Top 10 Products with Overall Sales Contribution

SELECT
    item_identifier,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(*) AS record_count,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(
        SUM(sales) * 100.0 /
        (SELECT SUM(sales) FROM blinkit_sales),
        2
    ) AS sales_contribution_percentage
FROM blinkit_sales
GROUP BY item_identifier
ORDER BY total_sales DESC
LIMIT 10;

-- 8. Top 3 Product Categories by Sales Contribution

WITH category_sales AS (
    SELECT
        item_type,
        SUM(sales) AS total_sales
    FROM blinkit_sales
    GROUP BY item_type
),
ranked_categories AS (
    SELECT
        item_type,
        total_sales,
        RANK() OVER (ORDER BY total_sales DESC) AS category_rank
    FROM category_sales
)

SELECT
    item_type,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(
        total_sales * 100.0 /
        (SELECT SUM(sales) FROM blinkit_sales),
        2
    ) AS sales_contribution_percentage,
    category_rank
FROM ranked_categories
WHERE category_rank <= 3
ORDER BY category_rank;

-- 9. Top Performing Product Category

SELECT
    item_type,
    COUNT(*) AS record_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales
FROM blinkit_sales
GROUP BY item_type
ORDER BY total_sales DESC
LIMIT 1;

-- 10. Final Business Summary

SELECT
    COUNT(*) AS total_records,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS average_sales_per_record,
    ROUND(AVG(item_visibility), 4) AS average_item_visibility,
    ROUND(AVG(rating), 2) AS average_rating,
    COUNT(DISTINCT item_identifier) AS unique_products,
    COUNT(DISTINCT item_type) AS product_categories,
    COUNT(DISTINCT outlet_identifier) AS total_outlets,
    COUNT(DISTINCT outlet_type) AS outlet_types,
    COUNT(DISTINCT outlet_location_type) AS location_tiers
FROM blinkit_sales;

