package com.dinod.ocean_view_resort.model;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

public class ReservationModelTest {

    @Test
    public void testReservationCreation() {
        // This tests "Requirement 2: Add New Reservation" data integrity

        // Arrange
        Reservation res = new Reservation();
        res.setReservationNo(101);
        res.setRoomNo(505);
        res.setStatus("PENDING");

        // Act & Assert
        assertEquals(101, res.getReservationNo(), "Reservation ID mismatch");
        assertEquals(505, res.getRoomNo(), "Room No mismatch");
        assertEquals("PENDING", res.getStatus(), "Status mismatch");

        // Verify Enum integrity (simulated)
        assertNotNull(res.toString(), "Reservation object should be valid");
    }
}
