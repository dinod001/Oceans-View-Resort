package com.dinod.ocean_view_resort.service;

import com.dinod.ocean_view_resort.model.Room;

import java.util.List;

public interface RoomService {

    boolean addRoom(Room room);

    boolean deleteRoom(int roomNo);

    boolean updateRoom(Room room);

    Room getRoomById(int roomNo);

    List<Room> getAllRooms();
}
