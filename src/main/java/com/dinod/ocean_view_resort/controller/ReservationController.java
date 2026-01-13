package com.dinod.ocean_view_resort.controller;

import com.dinod.ocean_view_resort.dao.GuestDao;
import com.dinod.ocean_view_resort.dao.Impl.GuestDaoImpl;
import com.dinod.ocean_view_resort.dao.Impl.ReservationDaoImpl;
import com.dinod.ocean_view_resort.dao.Impl.RoomDaoImpl;
import com.dinod.ocean_view_resort.dao.ReservationDao;
import com.dinod.ocean_view_resort.dao.RoomDao;
import com.dinod.ocean_view_resort.model.Guest;
import com.dinod.ocean_view_resort.model.Reservation;
import com.dinod.ocean_view_resort.model.Room;
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

@WebServlet(name = "ReservationController", urlPatterns = { "/reservations" })
public class ReservationController extends HttpServlet {

    private ReservationService reservationService;
    private RoomService roomService;
    private GuestService guestService;

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
        String action = request.getParameter("action");
        String searchContact = request.getParameter("searchContact");

        // 1. Handle Edit Mode
        if ("edit".equals(action)) {
            try {
                int resNo = Integer.parseInt(request.getParameter("id"));
                Reservation res = reservationService.getReservationById(resNo);
                request.setAttribute("reservationToEdit", res);

                // Fetch the guest details for this reservation to pre-fill the form
                Guest guest = guestService.getGuestById(res.getGuestID());
                request.setAttribute("guestToEdit", guest);

            } catch (NumberFormatException e) {
                // Ignore
            }
        }

        // 2. Load Reservations (Search or All)
        List<Reservation> reservationList;
        if (searchContact != null && !searchContact.trim().isEmpty()) {
            reservationList = reservationService.getReservationsByContactNo(searchContact.trim());
            request.setAttribute("searchContact", searchContact);
        } else {
            reservationList = reservationService.getAllReservations();
        }
        request.setAttribute("reservationList", reservationList);

        // 3. Load Available Rooms (for the Add Form dropdown)
        // In a real app we might filter by dates, but for now we show all available
        // rooms
        // plus the currently booked room if in edit mode (so it doesn't vanish)
        List<Room> allRooms = roomService.getAllRooms();
        // Filter mainly for available rooms, but this logic might be better in UI or
        // Service
        // For simplicity, we pass all rooms and let UI indicate availability
        request.setAttribute("roomList", allRooms);

        request.getRequestDispatcher("staff-dashboard/reservations.jsp").forward(request, response);
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
            // Parse Reservation
            int resNo = Integer.parseInt(request.getParameter("reservationNo"));
            Reservation res = parseReservationFromRequest(request);
            res.setReservationNo(resNo);

            // Fetch Staff ID from Session (Required for FK constraint)
            HttpSession session = request.getSession();
            if (session != null && session.getAttribute("id") != null) {
                int staffId = (Integer) session.getAttribute("id");
                res.setStaffID(staffId);
            } else {
                throw new IllegalStateException("User not logged in or session expired.");
            }

            // Explicitly set the OLD guest ID just in case, logic inside service handles
            // switching
            int currentGuestId = Integer.parseInt(request.getParameter("guestId"));
            res.setGuestID(currentGuestId);

            // Parse Guest Details (for potential update)
            Guest guest = parseGuestFromRequest(request);

            if (reservationService.updateReservation(res, guest)) {
                success = "Reservation updated successfully!";
            } else {
                error = "Failed to update reservation.";
            }

        } catch (IllegalArgumentException | IllegalStateException e) {
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
            int resNo = Integer.parseInt(request.getParameter("reservationNo"));
            if (reservationService.deleteReservation(resNo)) {
                success = "Reservation cancelled successfully!";
            } else {
                error = "Failed to cancel reservation.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            error = "An error occurred during cancellation.";
        }
        handleResponse(request, response, success, error);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String error = null;
        String success = null;
        try {
            Reservation res = parseReservationFromRequest(request);
            Guest guest = parseGuestFromRequest(request);

            // Get Staff ID from Session
            HttpSession session = request.getSession();
            if (session != null && session.getAttribute("id") != null) {
                int staffId = (Integer) session.getAttribute("id");
                res.setStaffID(staffId);
            } else {
                throw new IllegalStateException("User not logged in or session expired.");
            }

            if (reservationService.createReservation(res, guest)) {
                success = "Reservation created successfully!";
            } else {
                error = "Failed to create reservation.";
            }
        } catch (IllegalArgumentException e) {
            error = e.getMessage();
        } catch (Exception e) {
            e.printStackTrace();
            error = "An unexpected error occurred: " + e.getMessage();
        }
        handleResponse(request, response, success, error);
    }

    private void handleResponse(HttpServletRequest request, HttpServletResponse response, String success, String error)
            throws ServletException, IOException {
        if (error != null) {
            request.setAttribute("errorMessage", error);
            // Re-fetch lists for the view
            request.setAttribute("reservationList", reservationService.getAllReservations());
            request.setAttribute("roomList", roomService.getAllRooms());
            request.getRequestDispatcher("staff-dashboard/reservations.jsp").forward(request, response);
        } else {
            request.getSession().setAttribute("successMessage", success);
            response.sendRedirect("reservations");
        }
    }

    private Reservation parseReservationFromRequest(HttpServletRequest request) throws ParseException {
        Reservation res = new Reservation();

        String roomNoStr = request.getParameter("roomNo");
        if (roomNoStr != null && !roomNoStr.isEmpty()) {
            res.setRoomNo(Integer.parseInt(roomNoStr));
        }

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        res.setCheckInDate(sdf.parse(request.getParameter("checkInDate")));
        res.setCheckOutDate(sdf.parse(request.getParameter("checkOutDate")));

        return res;
    }

    private Guest parseGuestFromRequest(HttpServletRequest request) {
        String name = request.getParameter("guestName");
        String contact = request.getParameter("guestContact");
        String address = request.getParameter("guestAddress");
        return new Guest(name, address, contact);
    }
}
