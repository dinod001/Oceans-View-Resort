package com.dinod.ocean_view_resort.model;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

public class GuestModelTest {

    @Test
    public void testGuestCreation() {
        // Arrange
        String name = "Kasun Perera";
        String email = "kasun@example.com";
        String contact = "0771234567";

        // Act - Using valid constructor: Guest(String name, String address, String
        // contactNo, String email)
        Guest guest = new Guest(name, "Colombo", contact, email);

        // Assert
        assertNotNull(guest, "Guest object should be created");
        assertEquals(name, guest.getName(), "Name mismatch");
        assertEquals(email, guest.getEmail(), "Email mismatch");
    }
}
