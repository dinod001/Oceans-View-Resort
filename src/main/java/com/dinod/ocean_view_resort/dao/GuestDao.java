package com.dinod.ocean_view_resort.dao;

import com.dinod.ocean_view_resort.model.Guest;

import java.util.List;

public interface GuestDao {
    boolean addGuest(Guest guest);

    boolean updateGuest(Guest guest);

    boolean deleteGuest(int guestId);

    Guest getGuestById(int guestId);

    List<Guest> getAllGuests();

    Guest getGuestByContactNo(String contactNo);
}
