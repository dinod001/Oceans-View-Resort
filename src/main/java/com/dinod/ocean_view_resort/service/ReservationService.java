package com.dinod.ocean_view_resort.service;

import com.dinod.ocean_view_resort.model.Guest;
import com.dinod.ocean_view_resort.model.Reservation;

import java.util.List;

public interface ReservationService {

    // Handles the logic of checking guest existence/creation before booking
    boolean createReservation(Reservation reservation, Guest guest);

    // Handles updating reservation and optionally guest details
    boolean updateReservation(Reservation reservation, Guest guest);

    boolean deleteReservation(int reservationNo);

    Reservation getReservationById(int reservationNo);

    List<Reservation> getAllReservations();

    List<Reservation> getReservationsByContactNo(String contactNo);

    boolean updateReservationStatus(int reservationNo, String status);
}
