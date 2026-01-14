package com.dinod.ocean_view_resort.controller;

import com.dinod.ocean_view_resort.dao.Impl.RoomDaoImpl;
import com.dinod.ocean_view_resort.dao.RoomDao;
import com.dinod.ocean_view_resort.model.Room;
import com.dinod.ocean_view_resort.service.Impl.RoomServiceImpl;
import com.dinod.ocean_view_resort.service.RoomService;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "RoomController", urlPatterns = { "/rooms" })
public class RoomController extends HttpServlet {

    private RoomService roomService;
    private Gson gson = new Gson();

    @Override
    public void init() throws ServletException {
        ConnectionProvider connectionProvider = DBConnection.getInstance();
        RoomDao roomDao = new RoomDaoImpl(connectionProvider);
        this.roomService = new RoomServiceImpl(roomDao);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if ("getById".equals(action)) {
            try {
                int roomNo = Integer.parseInt(request.getParameter("id"));
                Room room = roomService.getRoomById(roomNo);
                if (room != null) {
                    response.getWriter().write(gson.toJson(room));
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    Map<String, String> error = new HashMap<>();
                    error.put("status", "error");
                    error.put("message", "Room not found");
                    response.getWriter().write(gson.toJson(error));

                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                Map<String, String> error = new HashMap<>();
                error.put("status", "error");
                error.put("message", "Invalid ID");
                response.getWriter().write(gson.toJson(error));
            }
        } else {
            List<Room> roomList = roomService.getAllRooms();
            response.getWriter().write(gson.toJson(roomList));
        }

    }

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action != null) {
            action = action.trim();
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

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
        Map<String, String> jsonResponse = new HashMap<>();
        try {
            int roomNo = Integer.parseInt(request.getParameter("roomNo"));
            Room room = parseRoomFromRequest(request);
            room.setRoomNo(roomNo);

            if (roomService.updateRoom(room)) {
                jsonResponse.put("status", "success");
                jsonResponse.put("message", "Room updated successfully!");
            } else {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Failed to update room.");
            }
        } catch (IllegalArgumentException e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "An unexpected error occurred.");
        }
        response.getWriter().write(gson.toJson(jsonResponse));
    }

    @Override
    public void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, String> jsonResponse = new HashMap<>();
        try {
            int roomNo = Integer.parseInt(request.getParameter("roomNo"));
            if (roomService.deleteRoom(roomNo)) {
                jsonResponse.put("status", "success");
                jsonResponse.put("message", "Room deleted successfully!");
            } else {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Failed to delete room.");
            }
        } catch (IllegalArgumentException e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "An unexpected error occurred.");
        }
        response.getWriter().write(gson.toJson(jsonResponse));
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, String> jsonResponse = new HashMap<>();
        try {
            Room room = parseRoomFromRequest(request);
            if (roomService.addRoom(room)) {
                jsonResponse.put("status", "success");
                jsonResponse.put("message", "Room added successfully!");
            } else {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Failed to add room.");
            }
        } catch (IllegalArgumentException e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "An unexpected error occurred.");
        }
        response.getWriter().write(gson.toJson(jsonResponse));
    }

    // handleResponse method removed as it is no longer used

    private Room parseRoomFromRequest(HttpServletRequest request) {

        String roomType = request.getParameter("roomType");
        double price = Double.parseDouble(request.getParameter("pricePerNight"));
        boolean isAvailable = request.getParameter("isAvailable") != null; // checkbox sends "on" or null usually, or we
                                                                           // can check simple check

        // In JSP checkbox value="true", so if checked sends "true".
        // If not checked, nothing is sent.
        // So checking != null is usually enough if value is present.

        return new Room(0, roomType, price, isAvailable);
    }
}
