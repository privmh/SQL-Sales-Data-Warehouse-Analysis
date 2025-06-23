/*
===============================================================================
Purpose:
    This script explores key dimension tables in the Gold layer of the data 
    warehouse. It is useful for identifying unique values in important 
    attributes for data analysis, validation, and business reporting.

Details:
    - Retrieves distinct countries from the customer dimension.
    - Retrieves unique combinations of category, sub-category, and product name 
      from the product dimension, ordered for clarity.
===============================================================================
*/

-- Explore distinct countries in customer dimension
SELECT DISTINCT
    country
FROM gold.dim_customers;

-- Explore distinct product hierarchy in product dimension
SELECT DISTINCT
    category,
    sub_category,
    product_name
FROM gold.dim_products
ORDER BY 1, 2, 3;
