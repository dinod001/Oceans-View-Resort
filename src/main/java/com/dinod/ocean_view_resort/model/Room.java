package com.dinod.ocean_view_resort.model;

public class Room {
    private int roomNo;
    private String roomType;
    private double pricePerNight;
    private boolean isAvailable;

    public Room(int roomNo, String roomType, double pricePerNight, boolean isAvailable) {
        this.roomNo = roomNo;
        this.roomType = roomType;
        this.pricePerNight = pricePerNight;
        this.isAvailable = isAvailable;
    }

    public Room() {
    }

    public Room(String roomType, double pricePerNight, boolean isAvailable) {
        this.roomType = roomType;
        this.pricePerNight = pricePerNight;
        this.isAvailable = isAvailable;
    }

    public int getRoomNo() {
        return roomNo;
    }

    public void setRoomNo(int roomNo) {
        this.roomNo = roomNo;
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

    public boolean isAvailable() {
        return isAvailable;
    }

    public void setAvailable(boolean available) {
        isAvailable = available;
    }
}
