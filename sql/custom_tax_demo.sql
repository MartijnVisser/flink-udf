-- Static SQL statement demonstrating the CustomTax UDF
SELECT 
    f0 AS product,
    f1 AS location,
    f2 * CustomTax(f1) AS tax
FROM VALUES 
    ('Apple', 'USA', 2),
    ('Apple', 'EU', 3)
AS t(f0, f1, f2);