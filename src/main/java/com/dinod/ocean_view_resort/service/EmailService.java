package com.dinod.ocean_view_resort.service;

import com.dinod.ocean_view_resort.model.Reservation;
import com.dinod.ocean_view_resort.model.Guest;
import com.dinod.ocean_view_resort.model.Billing;

public interface EmailService {

    /**
     * Sends a reservation confirmation email to the guest
     * 
     * @param reservation The reservation details
     * @param guest       The guest information
     * @return true if email was sent successfully, false otherwise
     */
    boolean sendReservationConfirmation(Reservation reservation, Guest guest);

    /**
     * Sends a billing invoice email to the guest
     * 
     * @param billing     The billing details
     * @param reservation The reservation details
     * @param guest       The guest information
     * @return true if email was sent successfully, false otherwise
     */
    boolean sendBillingInvoice(Billing billing, Reservation reservation, Guest guest);

    /**
     * Sends a generic email
     * 
     * @param to      Recipient email address
     * @param subject Email subject
     * @param body    Email body content
     * @return true if email was sent successfully, false otherwise
     */
    boolean sendEmail(String to, String subject, String body);
}
