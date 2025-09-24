package com.example.flink.udf;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for the CustomTax UDF
 */
public class CustomTaxTest {
    
    private CustomTax customTax;
    
    @BeforeEach
    void setUp() {
        customTax = new CustomTax();
    }
    
    @Test
    void testUSATaxRate() {
        assertEquals(10, customTax.eval("USA"));
        assertEquals(10, customTax.eval("usa")); // Test case insensitive
    }
    
    @Test
    void testEUTaxRate() {
        assertEquals(5, customTax.eval("EU"));
        assertEquals(5, customTax.eval("eu")); // Test case insensitive
    }
    
    @Test
    void testCanadaTaxRate() {
        assertEquals(8, customTax.eval("CANADA"));
        assertEquals(8, customTax.eval("canada")); // Test case insensitive
    }
    
    @Test
    void testUKTaxRate() {
        assertEquals(7, customTax.eval("UK"));
        assertEquals(7, customTax.eval("uk")); // Test case insensitive
    }
    
    @Test
    void testUnknownLocation() {
        assertEquals(0, customTax.eval("UNKNOWN"));
        assertEquals(0, customTax.eval("JAPAN"));
        assertEquals(0, customTax.eval("AUSTRALIA"));
    }
    
    @Test
    void testNullLocation() {
        assertEquals(0, customTax.eval(null));
    }
    
    @Test
    void testEmptyLocation() {
        assertEquals(0, customTax.eval(""));
    }
}
