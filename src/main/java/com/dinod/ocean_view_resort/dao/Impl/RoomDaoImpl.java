package com.dinod.ocean_view_resort.dao.Impl;

import com.dinod.ocean_view_resort.dao.RoomDao;
import com.dinod.ocean_view_resort.model.Room;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RoomDaoImpl implements RoomDao {

    private ConnectionProvider connectionProvider;

    public RoomDaoImpl() {
        this.connectionProvider = DBConnection.getInstance();
    }

    public RoomDaoImpl(ConnectionProvider connectionProvider) {
        this.connectionProvider = connectionProvider;
    }

    @Override
    public boolean addRoom(Room room) {
        String query = "INSERT INTO rooms (room_type, price_per_night, is_available) VALUES (?, ?, ?)";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, room.getRoomType());
            ps.setDouble(2, room.getPricePerNight());
            ps.setBoolean(3, room.isAvailable());

            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteRoom(int roomNo) {
        String query = "DELETE FROM rooms WHERE room_no = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, roomNo);

            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateRoom(Room room) {
        String query = "UPDATE rooms SET room_type = ?, price_per_night = ?, is_available = ? WHERE room_no = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setString(1, room.getRoomType());
            ps.setDouble(2, room.getPricePerNight());
            ps.setBoolean(3, room.isAvailable());
            ps.setInt(4, room.getRoomNo());

            int result = ps.executeUpdate();
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Room getRoomById(int roomNo) {
        String query = "SELECT * FROM rooms WHERE room_no = ?";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query)) {

            ps.setInt(1, roomNo);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Room room = new Room();
                room.setRoomNo(rs.getInt("room_no"));
                room.setRoomType(rs.getString("room_type"));
                room.setPricePerNight(rs.getDouble("price_per_night"));
                room.setAvailable(rs.getBoolean("is_available"));
                return room;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Room> getAllRooms() {
        List<Room> rooms = new ArrayList<>();
        String query = "SELECT * FROM rooms";
        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Room room = new Room();
                room.setRoomNo(rs.getInt("room_no"));
                room.setRoomType(rs.getString("room_type"));
                room.setPricePerNight(rs.getDouble("price_per_night"));
                room.setAvailable(rs.getBoolean("is_available"));
                rooms.add(room);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    @Override
    public List<Room> searchRooms(String roomNo, String type, String status, Double minPrice, Double maxPrice) {
        List<Room> rooms = new ArrayList<>();
        StringBuilder queryBuilder = new StringBuilder("SELECT * FROM rooms WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (roomNo != null && !roomNo.trim().isEmpty()) {
            queryBuilder.append(" AND room_no LIKE ?");
            params.add("%" + roomNo.trim() + "%");
        }
        if (type != null && !"All".equalsIgnoreCase(type) && !type.trim().isEmpty()) {
            queryBuilder.append(" AND room_type = ?");
            params.add(type.trim());
        }
        if (status != null && !"All".equalsIgnoreCase(status) && !status.trim().isEmpty()) {
            queryBuilder.append(" AND is_available = ?");
            params.add("Available".equalsIgnoreCase(status));
        }

        // Price Filtering
        if (minPrice != null) {
            queryBuilder.append(" AND price_per_night >= ?");
            params.add(minPrice);
        }
        if (maxPrice != null) {
            queryBuilder.append(" AND price_per_night <= ?");
            params.add(maxPrice);
        }

        try (Connection con = connectionProvider.createConnection();
                PreparedStatement ps = con.prepareStatement(queryBuilder.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Room room = new Room();
                    room.setRoomNo(rs.getInt("room_no"));
                    room.setRoomType(rs.getString("room_type"));
                    room.setPricePerNight(rs.getDouble("price_per_night"));
                    room.setAvailable(rs.getBoolean("is_available"));
                    rooms.add(room);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }
}
