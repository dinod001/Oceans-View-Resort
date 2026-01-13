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
import com.google.gson.Gson;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "GuestController", urlPatterns = { "/guests" })
public class GuestController extends HttpServlet {

    private GuestService guestService;
    private Gson gson = new Gson();

    @Override
    public void init() throws ServletException {
        ConnectionProvider connectionProvider = DBConnection.getInstance();
        GuestDao guestDao = new GuestDaoImpl(connectionProvider);
        this.guestService = new GuestServiceImpl(guestDao);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Serve JSON for Web Service Requirement
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String searchContact = request.getParameter("searchContact");
        List<Guest> guestList;

        if (searchContact != null && !searchContact.trim().isEmpty()) {
            Guest guest = guestService.getGuestByContactNo(searchContact.trim());
            if (guest != null) {
                guestList = java.util.Arrays.asList(guest);
            } else {
                guestList = java.util.Collections.emptyList();
            }
        } else {
            guestList = guestService.getAllGuests();
        }

        // Return List as JSON
        response.getWriter().write(gson.toJson(guestList));
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
            int guestId = Integer.parseInt(request.getParameter("guestId"));
            Guest guest = parseGuestFromRequest(request);
            guest.setGuestID(guestId);

            if (guestService.updateGuest(guest)) {
                jsonResponse.put("status", "success");
                jsonResponse.put("message", "Guest updated successfully!");
            } else {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Failed to update guest.");
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
            int guestId = Integer.parseInt(request.getParameter("guestId"));
            if (guestService.deleteGuest(guestId)) {
                jsonResponse.put("status", "success");
                jsonResponse.put("message", "Guest deleted successfully!");
            } else {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Failed to delete guest.");
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
            Guest guest = parseGuestFromRequest(request);
            if (guestService.addGuest(guest)) {
                jsonResponse.put("status", "success");
                jsonResponse.put("message", "Guest added successfully!");
            } else {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Failed to add guest.");
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

    // handleResponse method removed as it is no longer used (replaced by JSON
    // responses)

    private Guest parseGuestFromRequest(HttpServletRequest request) {
        String name = request.getParameter("name");
        String address = request.getParameter("address");
        String contactNo = request.getParameter("contactNo");

        return new Guest(name, address, contactNo);
    }
}
