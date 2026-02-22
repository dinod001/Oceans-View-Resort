package com.dinod.ocean_view_resort.service.Impl;

import com.dinod.ocean_view_resort.model.Guest;
import com.dinod.ocean_view_resort.model.Reservation;
import com.dinod.ocean_view_resort.service.EmailService;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.text.SimpleDateFormat;
import java.util.Properties;

public class EmailServiceImpl implements EmailService {

    private final String fromEmail;
    private final String password;
    private final Properties properties;

    public EmailServiceImpl() {
        String emailConfig = null;
        String passConfig = null;

        try {
            emailConfig = System.getProperty("FROM_EMAIL");
            passConfig = System.getProperty("APP_PASSWORD");
        } catch (Exception e) {
            System.err.println("Warning: Could not load email config from system properties");
        }

        this.fromEmail = (emailConfig != null) ? emailConfig : "oceanviewresort@gmail.com";
        this.password = (passConfig != null) ? passConfig : "your-app-password";

        properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");
        properties.put("mail.smtp.ssl.trust", "smtp.gmail.com");
    }

    public EmailServiceImpl(String fromEmail, String password, String smtpHost, String smtpPort) {
        this.fromEmail = fromEmail;
        this.password = password;

        properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", smtpHost);
        properties.put("mail.smtp.port", smtpPort);
        properties.put("mail.smtp.ssl.trust", smtpHost);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Reservation Confirmation
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    public boolean sendReservationConfirmation(Reservation reservation, Guest guest) {
        if (guest == null || guest.getEmail() == null || guest.getEmail().isEmpty()) {
            System.err.println("Guest email is not available. Cannot send confirmation.");
            return false;
        }

        SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
        String subject = "✅ Reservation Confirmed – Ocean View Resort";

        String html = "<!DOCTYPE html>" +
                "<html lang='en'><head><meta charset='UTF-8'>" +
                "<meta name='viewport' content='width=device-width,initial-scale=1'>" +
                "<title>Reservation Confirmed</title></head>" +
                "<body style='margin:0;padding:0;background:#f0f4f8;font-family:Arial,sans-serif;'>" +

                // ── Wrapper
                "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f0f4f8;padding:40px 0;'>" +
                "<tr><td align='center'>" +
                "<table width='600' cellpadding='0' cellspacing='0' style='background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.10);'>"
                +

                // ── Header
                "<tr><td style='background:linear-gradient(135deg,#1a6e8e 0%,#0d3d52 100%);padding:40px 40px 30px;text-align:center;'>"
                +
                "<p style='margin:0 0 6px;font-size:13px;color:#a8d8ea;letter-spacing:3px;text-transform:uppercase;'>Ocean View Resort</p>"
                +
                "<h1 style='margin:0;color:#ffffff;font-size:28px;font-weight:700;'>Reservation Confirmed</h1>" +
                "<p style='margin:10px 0 0;color:#cce8f4;font-size:14px;'>Your seaside escape is all set ✦</p>" +
                "</td></tr>" +

                // ── Greeting
                "<tr><td style='padding:36px 40px 8px;'>" +
                "<p style='margin:0;font-size:16px;color:#333;'>Dear <strong>" + guest.getName() + "</strong>,</p>" +
                "<p style='margin:12px 0 0;font-size:15px;color:#555;line-height:1.7;'>" +
                "Thank you for choosing <strong>Ocean View Resort</strong>! We are delighted to confirm your upcoming stay. "
                +
                "Below are your reservation details for your records." +
                "</p></td></tr>" +

                // ── Booking Details Card
                "<tr><td style='padding:24px 40px;'>" +
                "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f7fbff;border:1px solid #d6eaf8;border-radius:10px;overflow:hidden;'>"
                +
                "<tr><td colspan='2' style='background:#1a6e8e;padding:12px 20px;'>" +
                "<p style='margin:0;color:#ffffff;font-size:13px;font-weight:700;letter-spacing:1.5px;text-transform:uppercase;'>Booking Details</p>"
                +
                "</td></tr>" +
                buildRow("Room Number", String.valueOf(reservation.getRoomNo())) +
                buildRow("Room Type", reservation.getRoomType()) +
                buildRow("Check-in Date", sdf.format(reservation.getCheckInDate())) +
                buildRow("Check-out Date", sdf.format(reservation.getCheckOutDate())) +
                buildRow("Price per Night", String.format("LKR %.2f", reservation.getPricePerNight())) +
                "</table></td></tr>" +

                // ── CTA Notice
                "<tr><td style='padding:8px 40px 32px;'>" +
                "<table width='100%' cellpadding='0' cellspacing='0' style='background:#eaf6ff;border-left:4px solid #1a6e8e;border-radius:4px;padding:16px 20px;'>"
                +
                "<tr><td style='font-size:14px;color:#1a6e8e;line-height:1.6;padding:16px 20px;'>" +
                "🌊 Need to make changes? Contact us at least <strong>48 hours</strong> before your check-in date." +
                "</td></tr></table></td></tr>" +

                // ── Footer
                buildFooter() +

                "</table>" +
                "</td></tr></table>" +
                "</body></html>";

        return sendHtmlEmail(guest.getEmail(), subject, html);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Billing Invoice
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    public boolean sendBillingInvoice(com.dinod.ocean_view_resort.model.Billing billing,
            Reservation reservation, Guest guest) {
        if (guest == null || guest.getEmail() == null || guest.getEmail().isEmpty()) {
            System.err.println("Guest email is not available. Cannot send invoice.");
            return false;
        }

        SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
        String subject = "🧾 Invoice #" + billing.getBillID() + " – Ocean View Resort";

        double subtotal = billing.getTotalAmount();
        double tax = billing.getTax();
        double grandTotal = subtotal + tax;

        String html = "<!DOCTYPE html>" +
                "<html lang='en'><head><meta charset='UTF-8'>" +
                "<meta name='viewport' content='width=device-width,initial-scale=1'>" +
                "<title>Invoice</title></head>" +
                "<body style='margin:0;padding:0;background:#f0f4f8;font-family:Arial,sans-serif;'>" +

                "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f0f4f8;padding:40px 0;'>" +
                "<tr><td align='center'>" +
                "<table width='600' cellpadding='0' cellspacing='0' style='background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.10);'>"
                +

                // ── Header
                "<tr><td style='background:linear-gradient(135deg,#1a6e8e 0%,#0d3d52 100%);padding:40px 40px 30px;text-align:center;'>"
                +
                "<p style='margin:0 0 6px;font-size:13px;color:#a8d8ea;letter-spacing:3px;text-transform:uppercase;'>Ocean View Resort</p>"
                +
                "<h1 style='margin:0;color:#ffffff;font-size:28px;font-weight:700;'>Invoice #" + billing.getBillID()
                + "</h1>" +
                "<p style='margin:10px 0 0;color:#cce8f4;font-size:14px;'>Thank you for your stay ✦</p>" +
                "</td></tr>" +

                // ── Greeting
                "<tr><td style='padding:36px 40px 8px;'>" +
                "<p style='margin:0;font-size:16px;color:#333;'>Dear <strong>" + guest.getName() + "</strong>,</p>" +
                "<p style='margin:12px 0 0;font-size:15px;color:#555;line-height:1.7;'>" +
                "We hope you had a wonderful time at <strong>Ocean View Resort</strong>. " +
                "Please find your invoice summary below." +
                "</p></td></tr>" +

                // ── Stay Details
                "<tr><td style='padding:24px 40px 12px;'>" +
                "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f7fbff;border:1px solid #d6eaf8;border-radius:10px;overflow:hidden;'>"
                +
                "<tr><td colspan='2' style='background:#1a6e8e;padding:12px 20px;'>" +
                "<p style='margin:0;color:#ffffff;font-size:13px;font-weight:700;letter-spacing:1.5px;text-transform:uppercase;'>Stay Summary</p>"
                +
                "</td></tr>" +
                buildRow("Guest Name", guest.getName()) +
                buildRow("Room Number", String.valueOf(reservation.getRoomNo())) +
                buildRow("Room Type", reservation.getRoomType()) +
                buildRow("Check-in Date", sdf.format(reservation.getCheckInDate())) +
                buildRow("Check-out Date", sdf.format(reservation.getCheckOutDate())) +
                "</table></td></tr>" +

                // ── Payment Breakdown
                "<tr><td style='padding:12px 40px 24px;'>" +
                "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f7fbff;border:1px solid #d6eaf8;border-radius:10px;overflow:hidden;'>"
                +
                "<tr><td colspan='2' style='background:#0d3d52;padding:12px 20px;'>" +
                "<p style='margin:0;color:#ffffff;font-size:13px;font-weight:700;letter-spacing:1.5px;text-transform:uppercase;'>Payment Breakdown</p>"
                +
                "</td></tr>" +
                buildRow("Subtotal", String.format("LKR %.2f", subtotal)) +
                buildRow("Tax (10%)", String.format("LKR %.2f", tax)) +
                // Grand total highlight row
                "<tr style='background:#e8f5e9;'>" +
                "<td style='padding:14px 20px;font-size:15px;font-weight:700;color:#1b5e20;'>Total Charged</td>" +
                "<td style='padding:14px 20px;font-size:15px;font-weight:700;color:#1b5e20;text-align:right;'>" +
                String.format("LKR %.2f", grandTotal) + "</td></tr>" +
                "</table></td></tr>" +

                // ── Footer
                buildFooter() +

                "</table>" +
                "</td></tr></table>" +
                "</body></html>";

        return sendHtmlEmail(guest.getEmail(), subject, html);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Generic sendEmail (plain text – kept for compatibility)
    // ─────────────────────────────────────────────────────────────────────────
    @Override
    public boolean sendEmail(String to, String subject, String body) {
        if (to == null || to.isEmpty()) {
            System.err.println("Recipient email is empty.");
            return false;
        }
        // Wrap plain text body in a minimal HTML shell so it still looks acceptable
        String html = "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;color:#333;padding:24px;'>" +
                "<pre style='white-space:pre-wrap;font-family:inherit;'>" + body + "</pre></body></html>";
        return sendHtmlEmail(to, subject, html);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Internal: send HTML email
    // ─────────────────────────────────────────────────────────────────────────
    private boolean sendHtmlEmail(String to, String subject, String htmlBody) {
        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setContent(htmlBody, "text/html; charset=utf-8");

            Transport.send(message);
            System.out.println("Email sent successfully to: " + to);
            return true;

        } catch (MessagingException e) {
            System.err.println("Failed to send email: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────

    /** Alternating zebra-stripe table row */
    private static int rowCounter = 0;

    private static String buildRow(String label, String value) {
        rowCounter++;
        String bg = (rowCounter % 2 == 0) ? "#eaf4fb" : "#f7fbff";
        return "<tr style='background:" + bg + ";'>" +
                "<td style='padding:12px 20px;font-size:14px;color:#555;font-weight:600;width:45%;'>" + label + "</td>"
                +
                "<td style='padding:12px 20px;font-size:14px;color:#222;text-align:right;'>" + value + "</td>" +
                "</tr>";
    }

    private static String buildFooter() {
        return "<tr><td style='background:#0d3d52;padding:28px 40px;text-align:center;'>" +
                "<p style='margin:0 0 6px;color:#a8d8ea;font-size:13px;'>🌊 <strong style='color:#ffffff;'>Ocean View Resort</strong></p>"
                +
                "<p style='margin:0;color:#7fb3c8;font-size:12px;'>info@oceanviewresort.com &nbsp;|&nbsp; +94 77 123 4567</p>"
                +
                "<p style='margin:10px 0 0;color:#4a7f96;font-size:11px;'>© 2025 Ocean View Resort. All rights reserved.</p>"
                +
                "</td></tr>";
    }
}
