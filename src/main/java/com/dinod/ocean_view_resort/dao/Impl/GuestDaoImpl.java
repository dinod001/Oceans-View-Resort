package com.dinod.ocean_view_resort.dao.Impl;

import com.dinod.ocean_view_resort.dao.GuestDao;
import com.dinod.ocean_view_resort.model.Guest;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class GuestDaoImpl implements GuestDao {

    private ConnectionProvider connectionProvider;

    public GuestDaoImpl() {
        this.connectionProvider = DBConnection.getInstance();
    }

    public GuestDaoImpl(ConnectionProvider connectionProvider) {
        this.connectionProvider = connectionProvider;
    }

    @Override
    public boolean addGuest(Guest guest) {
        String query = "INSERT INTO guests (name, address, contact_no, email) VALUES (?, ?, ?, ?)";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, guest.getName());
            ps.setString(2, guest.getAddress());
            ps.setString(3, guest.getContactNo());
            ps.setString(4, guest.getEmail());

            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateGuest(Guest guest) {
        String query = "UPDATE guests SET name = ?, address = ?, contact_no = ?, email = ? WHERE guest_id = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, guest.getName());
            ps.setString(2, guest.getAddress());
            ps.setString(3, guest.getContactNo());
            ps.setString(4, guest.getEmail());
            ps.setInt(5, guest.getGuestID());

            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteGuest(int guestId) {
        String query = "DELETE FROM guests WHERE guest_id = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, guestId);

            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Guest getGuestById(int guestId) {
        String query = "SELECT * FROM guests WHERE guest_id = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, guestId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Guest guest = new Guest();
                guest.setGuestID(rs.getInt("guest_id"));
                guest.setName(rs.getString("name"));
                guest.setAddress(rs.getString("address"));
                guest.setContactNo(rs.getString("contact_no"));
                guest.setEmail(rs.getString("email"));
                return guest;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Guest> getAllGuests() {
        List<Guest> guests = new ArrayList<>();
        String query = "SELECT * FROM guests";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Guest guest = new Guest();
                guest.setGuestID(rs.getInt("guest_id"));
                guest.setName(rs.getString("name"));
                guest.setAddress(rs.getString("address"));
                guest.setContactNo(rs.getString("contact_no"));
                guest.setEmail(rs.getString("email"));
                guests.add(guest);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return guests;
    }

    @Override
    public Guest getGuestByContactNo(String contactNo) {
        String query = "SELECT * FROM guests WHERE contact_no = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, contactNo);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Guest guest = new Guest();
                guest.setGuestID(rs.getInt("guest_id"));
                guest.setName(rs.getString("name"));
                guest.setAddress(rs.getString("address"));
                guest.setContactNo(rs.getString("contact_no"));
                guest.setEmail(rs.getString("email"));
                return guest;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Guest> searchGuests(String query) {
        List<Guest> guests = new ArrayList<>();
        String sql = "SELECT * FROM guests WHERE contact_no LIKE ? OR email LIKE ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            String searchPattern = "%" + query + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Guest guest = new Guest();
                guest.setGuestID(rs.getInt("guest_id"));
                guest.setName(rs.getString("name"));
                guest.setAddress(rs.getString("address"));
                guest.setContactNo(rs.getString("contact_no"));
                guest.setEmail(rs.getString("email"));
                guests.add(guest);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return guests;
    }
}
