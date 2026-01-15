package com.dinod.ocean_view_resort.dao;

import com.dinod.ocean_view_resort.model.Room;

import java.util.List;

public interface RoomDao {
    // Add new room
    boolean addRoom(Room room);

    // Delete room
    boolean deleteRoom(int roomNo);

    // Update room
    boolean updateRoom(Room room);

    // Get room by id
    Room getRoomById(int roomNo);

    // Get all rooms
    List<Room> getAllRooms();

    // Search rooms with filters
    List<Room> searchRooms(String roomNo, String type, String status, Double minPrice, Double maxPrice);
}
