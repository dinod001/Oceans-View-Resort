package com.dinod.ocean_view_resort.service.Impl;

import com.dinod.ocean_view_resort.dao.BillingDao;
import com.dinod.ocean_view_resort.dao.Impl.BillingDaoImpl;
import com.dinod.ocean_view_resort.model.Billing;
import com.dinod.ocean_view_resort.model.Guest;
import com.dinod.ocean_view_resort.model.Reservation;
import com.dinod.ocean_view_resort.service.BillingService;
import com.dinod.ocean_view_resort.service.EmailService;
import com.dinod.ocean_view_resort.service.GuestService;
import com.dinod.ocean_view_resort.service.ReservationService;

public class BillingServiceImpl implements BillingService {

    private BillingDao billingDao;
    private EmailService emailService;
    private GuestService guestService;
    private ReservationService reservationService;

    public BillingServiceImpl() {
        this.billingDao = new BillingDaoImpl();
        this.emailService = new EmailServiceImpl();
        this.guestService = new GuestServiceImpl();
        this.reservationService = new ReservationServiceImpl();
    }

    public BillingServiceImpl(BillingDao billingDao) {
        this.billingDao = billingDao;
        this.emailService = new EmailServiceImpl();
        this.guestService = new GuestServiceImpl();
        this.reservationService = new ReservationServiceImpl();
    }

    @Override
    public Billing generateBill(int reservationNo) {
        // 1. Call DAO to execute stored procedure
        billingDao.generateBill(reservationNo);

        // 2. Fetch the newly generated bill to return it
        Billing bill = billingDao.getBillByReservationId(reservationNo);

        // 3. Send invoice email (Business Logic)
        if (bill != null) {
            try {
                Reservation reservation = reservationService.getReservationById(reservationNo);
                if (reservation != null) {
                    Guest guest = guestService.getGuestById(reservation.getGuestID());
                    if (guest != null && guest.getEmail() != null && !guest.getEmail().isEmpty()) {
                        emailService.sendBillingInvoice(bill, reservation, guest);
                        System.out.println("Invoice email sent to: " + guest.getEmail());
                    } else {
                        System.out.println("Invoice email not sent: Guest email not available");
                    }
                }
            } catch (Exception e) {
                // Log error but don't fail the billing if email fails
                System.err.println("Failed to send invoice email: " + e.getMessage());
                e.printStackTrace();
            }
        }

        return bill;
    }

    @Override
    public Billing getBillByReservationId(int reservationNo) {
        return billingDao.getBillByReservationId(reservationNo);
    }
}
