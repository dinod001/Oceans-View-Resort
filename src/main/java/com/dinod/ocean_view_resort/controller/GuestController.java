package com.dinod.ocean_view_resort.controller;

import com.dinod.ocean_view_resort.dao.GuestDao;
import com.dinod.ocean_view_resort.dao.Impl.GuestDaoImpl;
import com.dinod.ocean_view_resort.model.Guest;
import com.dinod.ocean_view_resort.service.GuestService;
import com.dinod.ocean_view_resort.service.Impl.GuestServiceImpl;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "GuestController", urlPatterns = { "/guests" })
public class GuestController extends HttpServlet {

    private GuestService guestService;

    @Override
    public void init() throws ServletException {
        ConnectionProvider connectionProvider = DBConnection.getInstance();
        GuestDao guestDao = new GuestDaoImpl(connectionProvider);
        this.guestService = new GuestServiceImpl(guestDao);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("edit".equals(action)) {
            try {
                int guestId = Integer.parseInt(request.getParameter("id"));
                Guest guest = guestService.getGuestById(guestId);
                request.setAttribute("guestToEdit", guest);
            } catch (NumberFormatException e) {
                // Ignore invalid ID
            }
        }

        String searchContact = request.getParameter("searchContact");
        List<Guest> guestList;

        if (searchContact != null && !searchContact.trim().isEmpty()) {
            Guest guest = guestService.getGuestByContactNo(searchContact.trim());
            if (guest != null) {
                guestList = java.util.Arrays.asList(guest);
            } else {
                guestList = java.util.Collections.emptyList();
            }
            request.setAttribute("searchContact", searchContact); // Persist search term
        } else {
            guestList = guestService.getAllGuests();
        }

        request.setAttribute("guestList", guestList);
        request.getRequestDispatcher("staff-dashboard/guest.jsp").forward(request, response);
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
            int guestId = Integer.parseInt(request.getParameter("guestId"));
            Guest guest = parseGuestFromRequest(request);
            guest.setGuestID(guestId);

            if (guestService.updateGuest(guest)) {
                success = "Guest updated successfully!";
            } else {
                error = "Failed to update guest.";
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
            int guestId = Integer.parseInt(request.getParameter("guestId"));
            if (guestService.deleteGuest(guestId)) {
                success = "Guest deleted successfully!";
            } else {
                error = "Failed to delete guest.";
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
            Guest guest = parseGuestFromRequest(request);
            if (guestService.addGuest(guest)) {
                success = "Guest added successfully!";
            } else {
                error = "Failed to add guest.";
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
            List<Guest> guestList = guestService.getAllGuests();
            request.setAttribute("guestList", guestList);
            request.getRequestDispatcher("staff-dashboard/guest.jsp").forward(request, response);
        } else {
            request.getSession().setAttribute("successMessage", success);
            response.sendRedirect("guests");
        }
    }

    private Guest parseGuestFromRequest(HttpServletRequest request) {
        String name = request.getParameter("name");
        String address = request.getParameter("address");
        String contactNo = request.getParameter("contactNo");

        return new Guest(name, address, contactNo);
    }
}
