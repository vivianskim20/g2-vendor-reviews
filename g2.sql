CREATE OR REPLACE TABLE RAW.PUBLIC."temp" (
	JSON_DATA VARIANT
);

SELECT * FROM "temp";


CREATE OR REPLACE TABLE raw.PUBLIC.vendor_rating AS

SELECT
    SUBSTR(g2_flat.value['input']['company_name'], 1, LENGTH(g2_flat.value['input']['company_name'])) AS vendor_name,
    CAST(g2_flat.value['number_of_reviews'] AS INT) AS number_of_reviews,
    CAST(g2_flat.value['number_of_stars'] AS DOUBLE) AS number_of_stars,
    g2_flat.value['categories_on_g2'] AS category_list
FROM (
    SELECT $1 json_data
    FROM "temp"
    ) g2,
    LATERAL FLATTEN(input => g2.json_data) g2_flat

    UNION
    
SELECT
    SUBSTR(g2_flat_competitors.value['competitor_name'], 1, LENGTH(g2_flat_competitors.value['competitor_name'])) AS vendor_name,
    CAST(g2_flat_competitors.value['number_of_reviews'] AS INT) AS number_of_reviews,
    CAST(g2_flat_competitors.value['number_of_stars'] AS DOUBLE) AS number_of_stars,
    g2_flat_competitors.value['product_category'] AS category_list
FROM (
    SELECT $1 json_data
    FROM "temp"
    ) g2,
    LATERAL FLATTEN(input => g2.json_data) g2_flat,
    LATERAL FLATTEN(input => g2_flat.value['top_10_competitors']) g2_flat_competitors
;

SELECT * FROM raw.PUBLIC.vendor_rating;


CREATE OR REPLACE TABLE raw.PUBLIC.vendor_competitor_rating AS

SELECT
    SUBSTR(g2_flat.value['input']['company_name'], 1, LENGTH(g2_flat.value['input']['company_name'])) AS vendor_name,
    SUBSTR(g2_flat_competitors.value['competitor_name'], 1, LENGTH(g2_flat_competitors.value['competitor_name'])) AS competitor_name,
    CAST(g2_flat_competitors.value['number_of_reviews'] AS INT) AS number_of_reviews,
    CAST(g2_flat_competitors.value['number_of_stars'] AS DOUBLE) AS number_of_stars
FROM (
    SELECT $1 json_data
    FROM "temp"
    ) g2,
    LATERAL FLATTEN(input => g2.json_data) g2_flat,
    LATERAL FLATTEN(input => g2_flat.value['top_10_competitors']) g2_flat_competitors
;

SELECT * FROM raw.PUBLIC.vendor_competitor_rating;


CREATE OR REPLACE TABLE raw.PUBLIC.vendor_category AS

SELECT
    SUBSTR(g2_flat.value['input']['company_name'], 1, LENGTH(g2_flat.value['input']['company_name'])) AS vendor_name,
    category_flat.value AS product_category
FROM (
    SELECT $1 json_data
    FROM "temp"
    ) g2,
    LATERAL FLATTEN(input => g2.json_data) g2_flat,
    LATERAL FLATTEN(input => g2_flat.value['categories_on_g2']) category_flat

    UNION
    
SELECT
    SUBSTR(g2_flat_competitors.value['competitor_name'], 1, LENGTH(g2_flat_competitors.value['competitor_name'])) AS vendor_name,
    competitor_category.value AS product_category
FROM (
    SELECT $1 json_data
    FROM "temp"
    ) g2,
    LATERAL FLATTEN(input => g2.json_data) g2_flat,
    LATERAL FLATTEN(input => g2_flat.value['top_10_competitors']) g2_flat_competitors,
    LATERAL FLATTEN(input => g2_flat_competitors.value['product_category']) competitor_category
;

CREATE OR REPLACE TABLE raw.PUBLIC.vendor_category_rating AS

SELECT
    SUBSTR(product_category, 1, LENGTH(product_category)) AS product_category,
    SUM(t1.number_of_reviews * t1.number_of_stars) * 1.0 / SUM(t1.number_of_reviews) AS num_stars_category
FROM raw.PUBLIC.vendor_rating t1
JOIN raw.PUBLIC.vendor_category t2
    ON t1.vendor_name = t2.vendor_name
GROUP BY
    1
;

CREATE OR REPLACE TABLE raw.PUBLIC.vendor_category_comparison AS

SELECT
    t2.vendor_name,
    number_of_stars,
    num_stars_category,
    t1.product_category
FROM vendor_category_rating t1
JOIN vendor_category t2
    ON t1.product_category = t2.product_category
JOIN vendor_rating t3
    ON t2.vendor_name = t3.vendor_name
GROUP BY
    1, 2, 3, 4;

SELECT * FROM vendor_category_comparison;

-- Three tables to export
SELECT * FROM vendor_rating;
SELECT * FROM vendor_competitor_rating;
SELECT * FROM vendor_category_comparison;
