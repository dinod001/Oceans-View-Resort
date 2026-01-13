package com.dinod.ocean_view_resort.service.Impl;

import com.dinod.ocean_view_resort.dao.Impl.ReservationDaoImpl;
import com.dinod.ocean_view_resort.dao.ReservationDao;
import com.dinod.ocean_view_resort.model.Guest;
import com.dinod.ocean_view_resort.model.Reservation;
import com.dinod.ocean_view_resort.model.Room;
import com.dinod.ocean_view_resort.service.GuestService;
import com.dinod.ocean_view_resort.service.ReservationService;
import com.dinod.ocean_view_resort.service.RoomService;

import java.util.List;

public class ReservationServiceImpl implements ReservationService {

    private ReservationDao reservationDao;
    private GuestService guestService;
    private RoomService roomService;

    public ReservationServiceImpl() {
        this.reservationDao = new ReservationDaoImpl();
        this.guestService = new GuestServiceImpl();
        this.roomService = new RoomServiceImpl();
    }

    public ReservationServiceImpl(ReservationDao reservationDao, GuestService guestService, RoomService roomService) {
        this.reservationDao = reservationDao;
        this.guestService = guestService;
        this.roomService = roomService;
    }

    @Override
    public boolean createReservation(Reservation reservation, Guest guestDetails) {
        if (reservation == null || guestDetails == null) {
            throw new IllegalArgumentException("Reservation and Guest details are required.");
        }

        if (reservation.getCheckInDate() == null || reservation.getCheckOutDate() == null) {
            throw new IllegalArgumentException("Check-in and Check-out dates are required.");
        }
        if (!reservation.getCheckOutDate().after(reservation.getCheckInDate())) {
            throw new IllegalArgumentException("Check-out date must be after Check-in date.");
        }

        // 1. Handle Guest Logic
        String contact = guestDetails.getContactNo();
        if (contact == null || contact.trim().isEmpty()) {
            throw new IllegalArgumentException("Guest contact number is required.");
        }

        Guest existingGuest = guestService.getGuestByContactNo(contact);
        if (existingGuest != null) {
            // Guest exists: Use their ID. Do NOT overwrite their details (as per
            // requirement).
            reservation.setGuestID(existingGuest.getGuestID());
        } else {
            // Guest does not exist: Create new guest
            boolean guestAdded = guestService.addGuest(guestDetails);
            if (!guestAdded) {
                throw new RuntimeException("Failed to register new guest.");
            }
            // Fetch the newly created guest to get the auto-generated ID
            Guest newGuest = guestService.getGuestByContactNo(contact);
            if (newGuest == null) {
                throw new RuntimeException("Failed to retrieve new guest ID.");
            }
            reservation.setGuestID(newGuest.getGuestID());
        }

        // 2. Validate Room Availability & Data
        Room room = roomService.getRoomById(reservation.getRoomNo());
        if (room == null) {
            throw new IllegalArgumentException("Invalid Room Number.");
        }
        if (!room.isAvailable()) {
            throw new IllegalArgumentException("Room " + room.getRoomNo() + " is already booked.");
        }

        // 3. Populate Reservation with Trustworthy Room Data
        reservation.setRoomType(room.getRoomType());
        reservation.setPricePerNight(room.getPricePerNight());

        // 4. Save Reservation
        // Note: DB Trigger 'after_reservation_insert' will set room.is_available =
        // FALSE
        return reservationDao.addReservation(reservation);
    }

    @Override
    public boolean updateReservation(Reservation reservation, Guest guestDetails) {
        if (reservation == null || guestDetails == null) {
            throw new IllegalArgumentException("Details required.");
        }

        if (reservation.getCheckInDate() == null || reservation.getCheckOutDate() == null) {
            throw new IllegalArgumentException("Check-in and Check-out dates are required.");
        }
        if (!reservation.getCheckOutDate().after(reservation.getCheckInDate())) {
            throw new IllegalArgumentException("Check-out date must be after Check-in date.");
        }

        // 1. Handle Guest Update Logic
        // We have the *current* guest ID in reservation.getGuestID() (from the
        // form/hidden field ideally)
        // But we must check if the contact number provided points to a DIFFERENT guest.

        String newContact = guestDetails.getContactNo();
        Guest uniqueCheck = guestService.getGuestByContactNo(newContact);

        if (uniqueCheck != null && uniqueCheck.getGuestID() != reservation.getGuestID()) {
            // The contact number belongs to SOMEONE ELSE.
            // Requirement implied: switch reservation to that user ("we have access...
            // according to that we can update")
            // Logic: Switch this reservation to point to the *existing* user who owns this
            // contact info.
            reservation.setGuestID(uniqueCheck.getGuestID());
        } else {
            // The contact number is either new (null) OR belongs to the current guest (IDs
            // match).
            // In this case, we update the CURRENT guest's details (Name, Address, maybe
            // Contact typo fix).
            // guestDetails passed here might lack the ID if it came purely from a form, so
            // ensure ID is set.
            guestDetails.setGuestID(reservation.getGuestID());
            boolean guestUpdated = guestService.updateGuest(guestDetails);
            if (!guestUpdated) {
                // Log warning but proceed? Or fail? Let's fail safety.
                // throw new RuntimeException("Failed to update guest details.");
                // Actually, updateGuest returns false if ID invalid.
            }
        }

        // 2. Room Data Refresh (if room changed)
        Room room = roomService.getRoomById(reservation.getRoomNo());
        if (room != null) {
            reservation.setRoomType(room.getRoomType());
            reservation.setPricePerNight(room.getPricePerNight());
        }

        return reservationDao.updateReservation(reservation);
    }

    public boolean deleteReservation(int reservationNo) {
        // Note: The DB Trigger 'after_reservation_delete' handles setting is_available
        // = TRUE
        // for the associated room automatically upon deletion.
        return reservationDao.deleteReservation(reservationNo);
    }

    @Override
    public Reservation getReservationById(int reservationNo) {
        return reservationDao.getReservationById(reservationNo);
    }

    @Override
    public List<Reservation> getAllReservations() {
        return reservationDao.getAllReservations();
    }

    @Override
    public List<Reservation> getReservationsByContactNo(String contactNo) {
        return reservationDao.getReservationsByContactNo(contactNo);
    }
}
