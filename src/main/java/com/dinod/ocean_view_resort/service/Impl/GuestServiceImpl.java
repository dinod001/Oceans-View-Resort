package com.dinod.ocean_view_resort.service.Impl;

import com.dinod.ocean_view_resort.dao.GuestDao;
import com.dinod.ocean_view_resort.dao.Impl.GuestDaoImpl;
import com.dinod.ocean_view_resort.model.Guest;
import com.dinod.ocean_view_resort.service.GuestService;

import java.util.List;

public class GuestServiceImpl implements GuestService {

    private GuestDao guestDao;

    public GuestServiceImpl() {
        this.guestDao = new GuestDaoImpl();
    }

    public GuestServiceImpl(GuestDao guestDao) {
        this.guestDao = guestDao;
    }

    @Override
    public boolean addGuest(Guest guest) {
        if (guest == null) {
            throw new IllegalArgumentException("Guest Details cannot be empty");
        }
        if (guest.getName() == null || guest.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Guest Name is required");
        }
        if (guest.getContactNo() == null || guest.getContactNo().trim().isEmpty()) {
            throw new IllegalArgumentException("Contact Number is required");
        }

        // Check for duplicate contact number
        Guest existingGuest = guestDao.getGuestByContactNo(guest.getContactNo());
        if (existingGuest != null) {
            throw new IllegalArgumentException("A guest with this contact number already exists.");
        }

        return guestDao.addGuest(guest);
    }

    @Override
    public boolean updateGuest(Guest guest) {
        if (guest == null || guest.getGuestID() <= 0) {
            throw new IllegalArgumentException("Invalid Guest ID.");
        }
        if (guest.getName() == null || guest.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Guest Name is required");
        }
        if (guest.getContactNo() == null || guest.getContactNo().trim().isEmpty()) {
            throw new IllegalArgumentException("Contact Number is required");
        }

        // Check duplicate check excluding current guest
        Guest existingGuest = guestDao.getGuestByContactNo(guest.getContactNo());
        if (existingGuest != null && existingGuest.getGuestID() != guest.getGuestID()) {
            throw new IllegalArgumentException("This contact number is already used by another guest.");
        }

        return guestDao.updateGuest(guest);
    }

    @Override
    public boolean deleteGuest(int guestId) {
        if (guestId <= 0) {
            throw new IllegalArgumentException("Invalid Guest ID.");
        }
        // Could check for active reservations here in future
        return guestDao.deleteGuest(guestId);
    }

    @Override
    public Guest getGuestById(int guestId) {
        return guestDao.getGuestById(guestId);
    }

    @Override
    public List<Guest> getAllGuests() {
        return guestDao.getAllGuests();
    }

    @Override
    public Guest getGuestByContactNo(String contactNo) {
        return guestDao.getGuestByContactNo(contactNo);
    }

    @Override
    public List<Guest> searchGuests(String query) {
        return guestDao.searchGuests(query);
    }
}
