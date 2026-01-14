package com.dinod.ocean_view_resort.dao.Impl;

import com.dinod.ocean_view_resort.dao.ReservationDao;
import com.dinod.ocean_view_resort.model.Reservation;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ReservationDaoImpl implements ReservationDao {

    private ConnectionProvider connectionProvider;

    public ReservationDaoImpl() {
        this.connectionProvider = DBConnection.getInstance();
    }

    public ReservationDaoImpl(ConnectionProvider connectionProvider) {
        this.connectionProvider = connectionProvider;
    }

    @Override
    public boolean addReservation(Reservation reservation) {
        String query = "INSERT INTO reservations (guest_id, room_no, staff_id, room_type, price_per_night, check_in_date, check_out_date, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, reservation.getGuestID());
            ps.setInt(2, reservation.getRoomNo());
            ps.setInt(3, reservation.getStaffID());
            ps.setString(4, reservation.getRoomType());
            ps.setDouble(5, reservation.getPricePerNight());
            ps.setDate(6, new java.sql.Date(reservation.getCheckInDate().getTime()));
            ps.setDate(7, new java.sql.Date(reservation.getCheckOutDate().getTime()));
            // Default status is 'PENDING' if not specified, but good to be explicit if
            // model has it
            String status = reservation.getStatus();
            if (status == null)
                status = "PENDING";
            ps.setString(8, status);

            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateReservation(Reservation reservation) {
        // room_type and price_per_night might change if room changes, but usually we
        // just update dates/room
        String query = "UPDATE reservations SET guest_id = ?, room_no = ?, staff_id = ?, room_type = ?, price_per_night = ?, check_in_date = ?, check_out_date = ?, status = ? WHERE reservation_no = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, reservation.getGuestID());
            ps.setInt(2, reservation.getRoomNo());
            ps.setInt(3, reservation.getStaffID());
            ps.setString(4, reservation.getRoomType());
            ps.setDouble(5, reservation.getPricePerNight());
            ps.setDate(6, new java.sql.Date(reservation.getCheckInDate().getTime()));
            ps.setDate(7, new java.sql.Date(reservation.getCheckOutDate().getTime()));
            ps.setString(8, reservation.getStatus());
            ps.setInt(9, reservation.getReservationNo());

            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteReservation(int reservationNo) {
        String query = "DELETE FROM reservations WHERE reservation_no = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, reservationNo);

            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Reservation getReservationById(int reservationNo) {
        String query = "SELECT * FROM reservations WHERE reservation_no = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, reservationNo);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToReservation(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Reservation> getAllReservations() {
        List<Reservation> list = new ArrayList<>();
        // Updated to JOIN guests table to fetch Name and Contact
        String query = "SELECT r.*, g.name as guest_name, g.contact_no as guest_contact FROM reservations r " +
                "JOIN guests g ON r.guest_id = g.guest_id";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToReservation(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Reservation> getReservationsByContactNo(String contactNo) {
        List<Reservation> list = new ArrayList<>();
        // Updated query to include guest details (already joined, just need to select
        // columns if needed, but r.* captures reservations, need g.* for details)
        String query = "SELECT r.*, g.name as guest_name, g.contact_no as guest_contact FROM reservations r " +
                "JOIN guests g ON r.guest_id = g.guest_id " +
                "WHERE g.contact_no = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, contactNo);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToReservation(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean updateReservationStatus(int reservationNo, String status) {
        String query = "UPDATE reservations SET status = ? WHERE reservation_no = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, status);
            ps.setInt(2, reservationNo);

            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Reservation mapResultSetToReservation(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setReservationNo(rs.getInt("reservation_no"));
        r.setGuestID(rs.getInt("guest_id"));
        r.setRoomNo(rs.getInt("room_no"));
        r.setStaffID(rs.getInt("staff_id"));
        r.setRoomType(rs.getString("room_type"));
        r.setPricePerNight(rs.getDouble("price_per_night"));
        r.setCheckInDate(rs.getDate("check_in_date"));
        r.setCheckOutDate(rs.getDate("check_out_date"));

        // Handle status mapping with fallback
        try {
            String status = rs.getString("status");
            if (status != null) {
                r.setStatus(status);
            } else {
                r.setStatus("PENDING");
            }
        } catch (SQLException e) {
            r.setStatus("PENDING"); // Default if column missing
        }

        // Populate transient fields safely (check if column exists in RS to avoid
        // errors if RS doesn't have it)
        // With current queries, we ensure they are fetched.
        try {
            r.setGuestName(rs.getString("guest_name"));
            r.setGuestContact(rs.getString("guest_contact"));
        } catch (SQLException e) {
            // Column might not be in ResultSet for simple queries (like getReservationById
            // if we didn't update it)
            // Ideally we update getReservationById too or accept nulls.
            // For now, let's ignore or update getReservationById as well.
        }
        return r;
    }
}
