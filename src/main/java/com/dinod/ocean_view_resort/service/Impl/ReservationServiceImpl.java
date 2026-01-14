package com.dinod.ocean_view_resort.service.Impl;

import com.dinod.ocean_view_resort.dao.Impl.ReservationDaoImpl;
import com.dinod.ocean_view_resort.dao.ReservationDao;
import com.dinod.ocean_view_resort.dao.BillingDao;
import com.dinod.ocean_view_resort.dao.Impl.BillingDaoImpl;
import com.dinod.ocean_view_resort.model.Guest;
import com.dinod.ocean_view_resort.model.Reservation;
import com.dinod.ocean_view_resort.model.Room;
import com.dinod.ocean_view_resort.service.EmailService;
import com.dinod.ocean_view_resort.service.GuestService;
import com.dinod.ocean_view_resort.service.ReservationService;
import com.dinod.ocean_view_resort.service.RoomService;

import java.util.List;

public class ReservationServiceImpl implements ReservationService {

    private ReservationDao reservationDao;
    private BillingDao billingDao;
    private GuestService guestService;
    private RoomService roomService;
    private EmailService emailService;

    public ReservationServiceImpl() {
        this.reservationDao = new ReservationDaoImpl();
        this.billingDao = new BillingDaoImpl();
        this.guestService = new GuestServiceImpl();
        this.roomService = new RoomServiceImpl();
        this.emailService = new EmailServiceImpl();
    }

    public ReservationServiceImpl(ReservationDao reservationDao, GuestService guestService, RoomService roomService) {
        this.reservationDao = reservationDao;
        this.billingDao = new BillingDaoImpl(); // Default to impl if not provided
        this.guestService = guestService;
        this.roomService = roomService;
        this.emailService = new EmailServiceImpl();
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

        // Validate 10-digit phone number
        String cleanedContact = contact.replaceAll("[^0-9]", ""); // Remove non-digits
        if (cleanedContact.length() != 10) {
            throw new IllegalArgumentException("Contact number must be exactly 10 digits.");
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
        boolean reservationCreated = reservationDao.addReservation(reservation);

        // 5. Send Email Confirmation (if reservation successful and guest has email)
        if (reservationCreated) {
            try {
                // Fetch the complete guest details with email
                Guest completeGuest = guestService.getGuestById(reservation.getGuestID());
                if (completeGuest != null && completeGuest.getEmail() != null && !completeGuest.getEmail().isEmpty()) {
                    emailService.sendReservationConfirmation(reservation, completeGuest);
                    System.out.println("Reservation confirmation email sent to: " + completeGuest.getEmail());
                } else {
                    System.out.println("Email not sent: Guest email not available");
                }
            } catch (Exception e) {
                // Log error but don't fail the reservation if email fails
                System.err.println("Failed to send confirmation email: " + e.getMessage());
                e.printStackTrace();
            }
        }

        return reservationCreated;
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

        // Get current reservation to check for changes
        Reservation currentReservation = getReservationById(reservation.getReservationNo());
        if (currentReservation == null) {
            throw new IllegalArgumentException("Reservation not found.");
        }

        // 1. Handle Guest Update Logic
        String newContact = guestDetails.getContactNo();
        Guest uniqueCheck = guestService.getGuestByContactNo(newContact);

        if (uniqueCheck != null && uniqueCheck.getGuestID() != reservation.getGuestID()) {
            reservation.setGuestID(uniqueCheck.getGuestID());
        } else {
            guestDetails.setGuestID(reservation.getGuestID());
            boolean guestUpdated = guestService.updateGuest(guestDetails);
            if (!guestUpdated) {
                // Log warning but proceed
            }
        }

        // 2. Room Data Refresh (if room changed)
        Room room = roomService.getRoomById(reservation.getRoomNo());
        if (room != null) {
            reservation.setRoomType(room.getRoomType());
            reservation.setPricePerNight(room.getPricePerNight());
        }

        // 3. Update the reservation
        boolean updated = reservationDao.updateReservation(reservation);

        // 4. If reservation was PAID and dates/room changed, regenerate bill
        if (updated && "PAID".equalsIgnoreCase(currentReservation.getStatus())) {
            boolean datesChanged = !currentReservation.getCheckInDate().equals(reservation.getCheckInDate())
                    || !currentReservation.getCheckOutDate().equals(reservation.getCheckOutDate());
            boolean roomChanged = currentReservation.getRoomNo() != reservation.getRoomNo();

            if (datesChanged || roomChanged) {
                try {
                    // Cancel old bill
                    billingDao.updateBillStatus(reservation.getReservationNo(), "CANCELLED");

                    // Generate new bill (this will also set status back to PAID)
                    BillingServiceImpl billingService = new BillingServiceImpl();
                    billingService.generateBill(reservation.getReservationNo());

                    System.out.println("Bill regenerated for Reservation #" + reservation.getReservationNo()
                            + " due to " + (datesChanged ? "date" : "room") + " change.");
                } catch (Exception e) {
                    System.err.println("Failed to regenerate bill: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        }

        return updated;
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

    @Override
    public boolean updateReservationStatus(int reservationNo, String newStatus) {
        Reservation reservation = getReservationById(reservationNo);
        if (reservation == null)
            return false;

        String currentStatus = reservation.getStatus();

        // 1. Business Logic: Cancel bill if transitioning from PAID to PENDING or
        // CANCELLED
        if ("PAID".equalsIgnoreCase(currentStatus)) {
            if ("PENDING".equalsIgnoreCase(newStatus) || "CANCELLED".equalsIgnoreCase(newStatus)) {
                billingDao.updateBillStatus(reservationNo, "CANCELLED");
                System.out.println("Bill cancelled for Reservation #" + reservationNo
                        + " (Status: PAID -> " + newStatus + ")");
            }
        }

        // 2. Business Logic: Update Room Availability based on Status
        // Logic removed: Now handled by DB Trigger 'after_reservation_update'

        return reservationDao.updateReservationStatus(reservationNo, newStatus);
    }
}
