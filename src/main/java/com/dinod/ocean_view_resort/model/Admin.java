package com.dinod.ocean_view_resort.model;

public class Admin extends User {
    private int adminID;

    public Admin() {
        super();
    }

    public Admin(String userName, String password, int adminID) {
        super(userName, password, "Admin");
        this.adminID = adminID;
    }

    public int getAdminID() {
        return adminID;
    }

    public void setAdminID(int adminID) {
        this.adminID = adminID;
    }
}
