package com.dinod.ocean_view_resort.service.Impl;

import com.dinod.ocean_view_resort.dao.Impl.RoomDaoImpl;
import com.dinod.ocean_view_resort.dao.RoomDao;
import com.dinod.ocean_view_resort.model.Room;
import com.dinod.ocean_view_resort.service.RoomService;

import java.util.List;

public class RoomServiceImpl implements RoomService {

    private RoomDao roomDao;

    public RoomServiceImpl() {
        this.roomDao = new RoomDaoImpl();
    }

    public RoomServiceImpl(RoomDao roomDao) {
        this.roomDao = roomDao;
    }

    @Override
    public boolean addRoom(Room room) {
        if (room == null) {
            throw new IllegalArgumentException("Room object cannot be null.");
        }
        // Room ID is auto-generated, so we don't validate it here.
        if (room.getRoomType() == null || room.getRoomType().trim().isEmpty()) {
            throw new IllegalArgumentException("Room Type cannot be empty.");
        }
        if (room.getPricePerNight() < 0) {
            throw new IllegalArgumentException("Price per night cannot be negative.");
        }

        // DAO call
        return roomDao.addRoom(room);
    }

    @Override
    public boolean deleteRoom(int roomNo) {
        if (roomNo <= 0) {
            throw new IllegalArgumentException("Invalid Room Number.");
        }
        return roomDao.deleteRoom(roomNo);
    }

    @Override
    public boolean updateRoom(Room room) {
        if (room == null || room.getRoomNo() <= 0) {
            throw new IllegalArgumentException("Invalid Room data for update.");
        }
        if (room.getPricePerNight() < 0) {
            throw new IllegalArgumentException("Price per night cannot be negative.");
        }
        return roomDao.updateRoom(room);
    }

    @Override
    public Room getRoomById(int roomNo) {
        return roomDao.getRoomById(roomNo);
    }

    @Override
    public List<Room> getAllRooms() {
        return roomDao.getAllRooms();
    }

    @Override
    public List<Room> searchRooms(String roomNo, String type, String status, Double minPrice, Double maxPrice) {
        return roomDao.searchRooms(roomNo, type, status, minPrice, maxPrice);
    }
}
