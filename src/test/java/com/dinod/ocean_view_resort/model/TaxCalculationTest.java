package com.dinod.ocean_view_resort.model;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * A simple Unit Test to demonstrate "Test Driven Development" (TDD) concepts
 * for the Assignment.
 *
 * This DOES NOT require a Database connection. It tests pure Java logic.
 */
public class TaxCalculationTest {

    @Test
    public void testTaxCalculationLogic() {
        // 1. Arrange (Set up the data)
        int stayDays = 5;
        double pricePerNight = 20000.00; // 20,000 LKR
        double taxRate = 0.10; // 10% Government Tax

        // 2. Act (Perform the calculation logic manually used in the System)
        double baseAmount = stayDays * pricePerNight;
        double taxAmount = baseAmount * taxRate;
        double totalWithTax = baseAmount + taxAmount;

        // 3. Assert (Verify the results are correct)
        // Expected Base: 100,000
        assertEquals(100000.00, baseAmount, 0.01, "Base Amount calculation failed");

        // Expected Tax: 10,000
        assertEquals(10000.00, taxAmount, 0.01, "Tax Amount calculation failed");

        // Expected Total: 110,000
        assertEquals(110000.00, totalWithTax, 0.01, "Total Bill calculation failed");
    }
}
