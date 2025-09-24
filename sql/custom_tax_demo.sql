-- Flink SQL statement demonstrating the CustomTax UDF
-- This creates a sample table and demonstrates how to use the custom tax function

-- Create a sample source table for demonstration
CREATE TABLE orders (
    order_id STRING,
    customer_name STRING,
    location STRING,
    amount DOUBLE,
    order_time TIMESTAMP(3)
) WITH (
    'connector' = 'datagen',
    'rows-per-second' = '10',
    'fields.order_id.kind' = 'random',
    'fields.order_id.length' = '10',
    'fields.customer_name.kind' = 'random',
    'fields.customer_name.length' = '8',
    'fields.location.kind' = 'random',
    'fields.location.length' = '3',
    'fields.amount.min' = '10.0',
    'fields.amount.max' = '1000.0'
);

-- Create a sink table to store results
CREATE TABLE tax_calculations (
    order_id STRING,
    customer_name STRING,
    location STRING,
    amount DOUBLE,
    tax_rate INT,
    tax_amount DOUBLE,
    total_amount DOUBLE,
    order_time TIMESTAMP(3)
) WITH (
    'connector' = 'print'
);

-- Insert data using the CustomTax UDF
INSERT INTO tax_calculations
SELECT 
    order_id,
    customer_name,
    location,
    amount,
    CustomTax(location) AS tax_rate,
    amount * CustomTax(location) / 100.0 AS tax_amount,
    amount + (amount * CustomTax(location) / 100.0) AS total_amount,
    order_time
FROM orders;

-- Alternative query to demonstrate the UDF with different locations
-- This shows how the UDF handles various location inputs
SELECT 
    'USA' AS location,
    CustomTax('USA') AS tax_rate
UNION ALL
SELECT 
    'EU' AS location,
    CustomTax('EU') AS tax_rate
UNION ALL
SELECT 
    'CANADA' AS location,
    CustomTax('CANADA') AS tax_rate
UNION ALL
SELECT 
    'UNKNOWN' AS location,
    CustomTax('UNKNOWN') AS tax_rate;
