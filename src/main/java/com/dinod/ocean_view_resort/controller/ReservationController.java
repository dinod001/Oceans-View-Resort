package com.dinod.ocean_view_resort.controller;

import com.dinod.ocean_view_resort.dao.GuestDao;
import com.dinod.ocean_view_resort.dao.Impl.GuestDaoImpl;
import com.dinod.ocean_view_resort.dao.Impl.ReservationDaoImpl;
import com.dinod.ocean_view_resort.dao.Impl.RoomDaoImpl;
import com.dinod.ocean_view_resort.dao.ReservationDao;
import com.dinod.ocean_view_resort.dao.RoomDao;
import com.dinod.ocean_view_resort.model.Guest;
import com.dinod.ocean_view_resort.model.Reservation;
import com.dinod.ocean_view_resort.service.GuestService;
import com.dinod.ocean_view_resort.service.Impl.GuestServiceImpl;
import com.dinod.ocean_view_resort.service.Impl.ReservationServiceImpl;
import com.dinod.ocean_view_resort.service.Impl.RoomServiceImpl;
import com.dinod.ocean_view_resort.service.ReservationService;
import com.dinod.ocean_view_resort.service.RoomService;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "ReservationController", urlPatterns = { "/reservations" })
public class ReservationController extends HttpServlet {

    private ReservationService reservationService;
    private RoomService roomService;
    private GuestService guestService;
    private final Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd").create();

    @Override
    public void init() throws ServletException {
        // Dependency Injection
        ConnectionProvider connectionProvider = DBConnection.getInstance();

        ReservationDao reservationDao = new ReservationDaoImpl(connectionProvider);
        GuestDao guestDao = new GuestDaoImpl(connectionProvider);
        RoomDao roomDao = new RoomDaoImpl(connectionProvider);

        this.guestService = new GuestServiceImpl(guestDao);
        this.roomService = new RoomServiceImpl(roomDao);

        this.reservationService = new ReservationServiceImpl(reservationDao, this.guestService, this.roomService);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String action = request.getParameter("action");
        String searchContact = request.getParameter("searchContact");

        try {
            if ("edit".equals(action)) {
                // Return specific reservation for editing
                int resNo = Integer.parseInt(request.getParameter("id"));
                Reservation res = reservationService.getReservationById(resNo);

                // Also fetch the guest details for this reservation
                Guest guest = guestService.getGuestById(res.getGuestID());

                // Combine into a transient object or map for the response
                Map<String, Object> data = new HashMap<>();
                data.put("reservation", res);
                data.put("guest", guest);

                out.print(gson.toJson(data));

            } else {
                // List Mode
                List<Reservation> reservationList;
                if (searchContact != null && !searchContact.trim().isEmpty()) {
                    reservationList = reservationService.getReservationsByContactNo(searchContact.trim());
                } else {
                    reservationList = reservationService.getAllReservations();
                }
                out.print(gson.toJson(reservationList));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(createResponse("error", e.getMessage())));
        }
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
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // Parse Reservation
            int resNo = Integer.parseInt(request.getParameter("reservationNo"));
            Reservation res = parseReservationFromRequest(request);
            res.setReservationNo(resNo);

            // Fetch Staff ID from Session
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("id") != null) {
                int staffId = (Integer) session.getAttribute("id");
                res.setStaffID(staffId);
            } else {
                throw new IllegalStateException("User not logged in or session expired.");
            }

            // Explicitly set the OLD guest ID
            String guestIdParam = request.getParameter("guestId");
            if (guestIdParam != null && !guestIdParam.isEmpty()) {
                res.setGuestID(Integer.parseInt(guestIdParam));
            }

            // Parse Guest Details
            Guest guest = parseGuestFromRequest(request);

            if (reservationService.updateReservation(res, guest)) {
                out.print(gson.toJson(createResponse("success", "Reservation updated successfully!")));
            } else {
                out.print(gson.toJson(createResponse("error", "Failed to update reservation.")));
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print(gson.toJson(createResponse("error", "Error: " + e.getMessage())));
        }
    }

    @Override
    public void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            int resNo = Integer.parseInt(request.getParameter("reservationNo"));
            if (reservationService.deleteReservation(resNo)) {
                out.print(gson.toJson(createResponse("success", "Reservation cancelled successfully!")));
            } else {
                out.print(gson.toJson(createResponse("error", "Failed to cancel reservation.")));
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print(gson.toJson(createResponse("error", "Error: " + e.getMessage())));
        }
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            Reservation res = parseReservationFromRequest(request);
            Guest guest = parseGuestFromRequest(request);

            // Get Staff ID from Session
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("id") != null) {
                int staffId = (Integer) session.getAttribute("id");
                res.setStaffID(staffId);
            } else {
                throw new IllegalStateException("User not logged in or session expired.");
            }

            if (reservationService.createReservation(res, guest)) {
                out.print(gson.toJson(createResponse("success", "Reservation created successfully!")));
            } else {
                out.print(gson.toJson(createResponse("error", "Failed to create reservation.")));
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print(gson.toJson(createResponse("error", "Error: " + e.getMessage())));
        }
    }

    private Map<String, Object> createResponse(String status, String message) {
        Map<String, Object> map = new HashMap<>();
        map.put("status", status);
        map.put("message", message);
        return map;
    }

    private Reservation parseReservationFromRequest(HttpServletRequest request) throws ParseException {
        Reservation res = new Reservation();

        String roomNoStr = request.getParameter("roomNo");
        if (roomNoStr != null && !roomNoStr.isEmpty()) {
            res.setRoomNo(Integer.parseInt(roomNoStr));
        }

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String checkIn = request.getParameter("checkInDate");
        String checkOut = request.getParameter("checkOutDate");

        if (checkIn != null && !checkIn.isEmpty())
            res.setCheckInDate(sdf.parse(checkIn));
        if (checkOut != null && !checkOut.isEmpty())
            res.setCheckOutDate(sdf.parse(checkOut));

        return res;
    }

    private Guest parseGuestFromRequest(HttpServletRequest request) {
        String name = request.getParameter("guestName");
        String contact = request.getParameter("guestContact");
        String address = request.getParameter("guestAddress");
        return new Guest(name, address, contact);
    }
}
