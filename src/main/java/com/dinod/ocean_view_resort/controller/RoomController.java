package com.dinod.ocean_view_resort.controller;

import com.dinod.ocean_view_resort.dao.Impl.RoomDaoImpl;
import com.dinod.ocean_view_resort.dao.RoomDao;
import com.dinod.ocean_view_resort.model.Room;
import com.dinod.ocean_view_resort.service.Impl.RoomServiceImpl;
import com.dinod.ocean_view_resort.service.RoomService;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "RoomController", urlPatterns = { "/rooms" })
public class RoomController extends HttpServlet {

    private RoomService roomService;

    @Override
    public void init() throws ServletException {
        ConnectionProvider connectionProvider = DBConnection.getInstance();
        RoomDao roomDao = new RoomDaoImpl(connectionProvider);
        this.roomService = new RoomServiceImpl(roomDao);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("edit".equals(action)) {
            try {
                int roomNo = Integer.parseInt(request.getParameter("id"));
                Room room = roomService.getRoomById(roomNo);
                request.setAttribute("roomToEdit", room);
            } catch (NumberFormatException e) {
                // Ignore invalid ID
            }

        }

        List<Room> roomList = roomService.getAllRooms();
        request.setAttribute("roomList", roomList);
        request.getRequestDispatcher("admin-dashboard/rooms.jsp").forward(request, response);
    }

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action != null) {
            action = action.trim();
        }

        if ("update".equals(action)) {
            doPut(request, response);
        } else if ("delete".equals(action)) {
            doDelete(request, response);
        } else {
            handleAdd(request, response);
        }
    }

    @Override
    public void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String error = null;
        String success = null;
        try {
            // For update, we NEED the ID
            int roomNo = Integer.parseInt(request.getParameter("roomNo"));
            Room room = parseRoomFromRequest(request);
            room.setRoomNo(roomNo);

            if (roomService.updateRoom(room)) {
                success = "Room updated successfully!";
            } else {
                error = "Failed to update room.";
            }
        } catch (IllegalArgumentException e) {
            error = e.getMessage();
        } catch (Exception e) {
            e.printStackTrace();
            error = "An unexpected error occurred.";
        }
        handleResponse(request, response, success, error);
    }

    @Override
    public void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String error = null;
        String success = null;
        try {
            int roomNo = Integer.parseInt(request.getParameter("roomNo"));
            if (roomService.deleteRoom(roomNo)) {
                success = "Room deleted successfully!";
            } else {
                error = "Failed to delete room.";
            }
        } catch (IllegalArgumentException e) {
            error = e.getMessage();
        } catch (Exception e) {
            e.printStackTrace();
            error = "An unexpected error occurred.";
        }
        handleResponse(request, response, success, error);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String error = null;
        String success = null;
        try {
            // For ADD, we ignore ID (it's auto-increment)
            Room room = parseRoomFromRequest(request);
            // roomNo will be 0 by default from helper if we modify helper, or we just
            // ignore it here
            // actually helper parses it, we should modify helper or just pass 0 here.

            if (roomService.addRoom(room)) {
                success = "Room added successfully!";
            } else {
                error = "Failed to add room.";
            }
        } catch (IllegalArgumentException e) {
            error = e.getMessage();
        } catch (Exception e) {
            e.printStackTrace();
            error = "An unexpected error occurred.";
        }
        handleResponse(request, response, success, error);
    }

    private void handleResponse(HttpServletRequest request, HttpServletResponse response, String success, String error)
            throws ServletException, IOException {
        if (error != null) {
            request.setAttribute("errorMessage", error);
            List<Room> roomList = roomService.getAllRooms();
            request.setAttribute("roomList", roomList);
            request.getRequestDispatcher("admin-dashboard/rooms.jsp").forward(request, response);
        } else {
            request.getSession().setAttribute("successMessage", success);
            response.sendRedirect("rooms");
        }
    }

    private Room parseRoomFromRequest(HttpServletRequest request) {

        String roomType = request.getParameter("roomType");
        double price = Double.parseDouble(request.getParameter("pricePerNight"));
        boolean isAvailable = request.getParameter("isAvailable") != null;

        return new Room(0, roomType, price, isAvailable);
    }
}
