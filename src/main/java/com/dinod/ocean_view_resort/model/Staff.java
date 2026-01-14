package com.dinod.ocean_view_resort.model;

public class Staff extends User {
    private String designation;

    public Staff() {
        super();
        this.setRole("Staff");
    }

    public Staff(int id, String userName, String password, String designation) {
        super(id, userName, password, "Staff");
        this.designation = designation;
    }

    public Staff(String userName, String password, String designation) {
        super(userName, password, "Staff");
        this.designation = designation;
    }

    public String getDesignation() {
        return designation;
    }

    public void setDesignation(String designation) {
        this.designation = designation;
    }

    // Wrapper methods for compatibility with previous version
    public int getStaffID() {
        return getId();
    }

    public void setStaffID(int staffID) {
        setId(staffID);
    }
}
