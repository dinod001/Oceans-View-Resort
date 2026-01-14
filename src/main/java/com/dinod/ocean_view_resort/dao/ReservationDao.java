package com.dinod.ocean_view_resort.dao;

import com.dinod.ocean_view_resort.model.Reservation;

import java.util.List;

public interface ReservationDao {
    boolean addReservation(Reservation reservation);

    boolean updateReservation(Reservation reservation);

    boolean deleteReservation(int reservationNo);

    Reservation getReservationById(int reservationNo);

    List<Reservation> getAllReservations();

    List<Reservation> getReservationsByContactNo(String contactNo);

    boolean updateReservationStatus(int reservationNo, String status);
}
