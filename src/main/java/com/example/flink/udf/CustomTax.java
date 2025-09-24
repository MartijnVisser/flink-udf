package com.example.flink.udf;

import org.apache.flink.table.functions.ScalarFunction;

/**
 * A scalar function that calculates a custom tax based on the provided location.
 * This UDF can be used in Flink SQL queries to determine tax rates for different regions.
 */
public class CustomTax extends ScalarFunction {
    
    /**
     * Evaluates the custom tax rate for a given location.
     * 
     * @param location The location string (e.g., "USA", "EU")
     * @return The tax rate as an integer percentage
     */
    public int eval(String location) {
        if (location == null) {
            return 0;
        }
        
        switch (location.toUpperCase()) {
            case "USA":
                return 10;
            case "EU":
                return 5;
            case "CANADA":
                return 8;
            case "UK":
                return 7;
            default:
                return 0;
        }
    }
}
