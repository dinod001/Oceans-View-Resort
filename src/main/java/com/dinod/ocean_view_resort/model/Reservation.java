package com.dinod.ocean_view_resort.model;

import java.util.Date;

public class Reservation {
    private int reservationNo;
    private int guestID;
    private int roomNo;
    private int staffID;
    private String roomType;
    private double pricePerNight;
    private Date checkInDate;
    private Date checkOutDate;
    private String status; // PENDING, PAID, CANCELLED

    // Transient fields for display purposes
    private String guestName;
    private String guestContact;

    public Reservation(int reservationNo, int guestID, int roomNo, int staffID, String roomType, double pricePerNight,
            Date checkInDate, Date checkOutDate) {
        this.reservationNo = reservationNo;
        this.guestID = guestID;
        this.roomNo = roomNo;
        this.staffID = staffID;
        this.roomType = roomType;
        this.pricePerNight = pricePerNight;
        this.checkInDate = checkInDate;
        this.checkOutDate = checkOutDate;
        this.status = "PENDING"; // Default status
    }

    public Reservation(int guestID, int roomNo, int staffID, String roomType, double pricePerNight, Date checkInDate,
            Date checkOutDate) {
        this.guestID = guestID;
        this.roomNo = roomNo;
        this.staffID = staffID;
        this.roomType = roomType;
        this.pricePerNight = pricePerNight;
        this.checkInDate = checkInDate;
        this.checkOutDate = checkOutDate;
        this.status = "PENDING"; // Default status
    }

    public Reservation() {
    }

    public int getReservationNo() {
        return reservationNo;
    }

    public void setReservationNo(int reservationNo) {
        this.reservationNo = reservationNo;
    }

    public int getGuestID() {
        return guestID;
    }

    public void setGuestID(int guestID) {
        this.guestID = guestID;
    }

    public int getRoomNo() {
        return roomNo;
    }

    public void setRoomNo(int roomNo) {
        this.roomNo = roomNo;
    }

    public int getStaffID() {
        return staffID;
    }

    public void setStaffID(int staffID) {
        this.staffID = staffID;
    }

    public String getRoomType() {
        return roomType;
    }

    public void setRoomType(String roomType) {
        this.roomType = roomType;
    }

    public double getPricePerNight() {
        return pricePerNight;
    }

    public void setPricePerNight(double pricePerNight) {
        this.pricePerNight = pricePerNight;
    }

    public Date getCheckInDate() {
        return checkInDate;
    }

    public void setCheckInDate(Date checkInDate) {
        this.checkInDate = checkInDate;
    }

    public Date getCheckOutDate() {
        return checkOutDate;
    }

    public void setCheckOutDate(Date checkOutDate) {
        this.checkOutDate = checkOutDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getGuestName() {
        return guestName;
    }

    public void setGuestName(String guestName) {
        this.guestName = guestName;
    }

    public String getGuestContact() {
        return guestContact;
    }

    public void setGuestContact(String guestContact) {
        this.guestContact = guestContact;
    }
}
