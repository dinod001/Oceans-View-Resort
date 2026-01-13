package com.dinod.ocean_view_resort.model;

public class Guest {
    private int guestID;
    private String name;
    private String address;
    private String contactNo;

    public Guest(int guestID, String name, String address, String contactNo) {
        this.guestID = guestID;
        this.name = name;
        this.address = address;
        this.contactNo = contactNo;
    }

    public Guest(String name, String address, String contactNo) {
        this.name = name;
        this.address = address;
        this.contactNo = contactNo;
    }

    public Guest() {
    }

    public int getGuestID() {
        return guestID;
    }

    public void setGuestID(int guestID) {
        this.guestID = guestID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getContactNo() {
        return contactNo;
    }

    public void setContactNo(String contactNo) {
        this.contactNo = contactNo;
    }
}
