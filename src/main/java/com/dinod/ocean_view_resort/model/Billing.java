package com.dinod.ocean_view_resort.model;

public class Billing {
    private int billID;
    private int resNo;
    private double totalAmount;
    private double tax;
    private String status; // PAID, CANCELLED

    public Billing(int billID, int resNo, double totalAmount, double tax) {
        this.billID = billID;
        this.resNo = resNo;
        this.totalAmount = totalAmount;
        this.tax = tax;
        this.status = "PAID"; // Default status
    }

    public Billing(int resNo, double totalAmount, double tax) {
        this.resNo = resNo;
        this.totalAmount = totalAmount;
        this.tax = tax;
        this.status = "PAID"; // Default status
    }

    public Billing() {
    }

    public int getBillID() {
        return billID;
    }

    public void setBillID(int billID) {
        this.billID = billID;
    }

    public int getResNo() {
        return resNo;
    }

    public void setResNo(int resNo) {
        this.resNo = resNo;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public double getTax() {
        return tax;
    }

    public void setTax(double tax) {
        this.tax = tax;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
