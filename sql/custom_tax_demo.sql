SELECT product, location, CustomTax(location)
   FROM (VALUES ('Apple', 'USA', 2), ('Apple', 'EU', 3))
   AS t (product, location, tax);