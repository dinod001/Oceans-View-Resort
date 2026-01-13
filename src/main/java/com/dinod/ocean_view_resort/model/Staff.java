package com.dinod.ocean_view_resort.model;

public class Staff extends User {
    private int staffID;
    private String designation;

    public Staff() {
        super();
    }

    public Staff(String userName, String password, int staffID, String designation) {
        super(userName, password, "Staff");
        this.staffID = staffID;
        this.designation = designation;
    }

    public int getStaffID() {
        return staffID;
    }

    public void setStaffID(int staffID) {
        this.staffID = staffID;
    }

    public String getDesignation() {
        return designation;
    }

    public void setDesignation(String designation) {
        this.designation = designation;
    }
}
