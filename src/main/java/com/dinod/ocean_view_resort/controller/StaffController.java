package com.dinod.ocean_view_resort.controller;

import com.dinod.ocean_view_resort.model.User;
import com.dinod.ocean_view_resort.service.StaffService;
import com.dinod.ocean_view_resort.service.Impl.StaffServiceImpl;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/staff-mgmt")
public class StaffController extends HttpServlet {

    private final StaffService staffService = new StaffServiceImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String query = request.getParameter("query");
            String type = request.getParameter("type");
            List<User> list;

            if (query != null && !query.trim().isEmpty()) {
                list = staffService.searchStaff(query.trim(), type);
            } else {
                list = staffService.getAllStaff();
            }

            String json = gson.toJson(list);
            byte[] responseBytes = json.getBytes(StandardCharsets.UTF_8);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.setContentLength(responseBytes.length);

            response.getOutputStream().write(responseBytes);
            response.getOutputStream().flush();

        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Server processing error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        Map<String, String> jsonResponse = new HashMap<>();

        try {
            if ("add".equalsIgnoreCase(action)) {
                handleAdd(request, jsonResponse);
            } else if ("update".equalsIgnoreCase(action)) {
                handleUpdate(request, jsonResponse);
            } else if ("delete".equalsIgnoreCase(action)) {
                handleDelete(request, jsonResponse);
            } else {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Invalid action.");
            }
        } catch (IllegalArgumentException e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Unexpected error: " + e.getMessage());
        }

        byte[] responseBytes = gson.toJson(jsonResponse).getBytes(StandardCharsets.UTF_8);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setContentLength(responseBytes.length);
        response.getOutputStream().write(responseBytes);
        response.getOutputStream().flush();
    }

    private void handleAdd(HttpServletRequest request, Map<String, String> jsonResponse) {
        User user = parseUserFromRequest(request);
        String designation = request.getParameter("designation");
        if (staffService.addStaff(user, designation)) {
            jsonResponse.put("status", "success");
            jsonResponse.put("message", "User registered successfully!");
        } else {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Registration failed. Check logs.");
        }
    }

    private void handleUpdate(HttpServletRequest request, Map<String, String> jsonResponse) {
        int userId = Integer.parseInt(request.getParameter("userId"));
        User user = parseUserFromRequest(request);
        user.setId(userId);
        String designation = request.getParameter("designation");
        if (staffService.updateStaff(user, designation)) {
            jsonResponse.put("status", "success");
            jsonResponse.put("message", "Details updated successfully!");
        } else {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Update failed.");
        }
    }

    private void handleDelete(HttpServletRequest request, Map<String, String> jsonResponse) {
        int userId = Integer.parseInt(request.getParameter("userId"));
        if (staffService.deleteStaff(userId)) {
            jsonResponse.put("status", "success");
            jsonResponse.put("message", "User removed successfully.");
        } else {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Deletion failed.");
        }
    }

    private User parseUserFromRequest(HttpServletRequest request) {
        User user = new User();
        user.setUserName(request.getParameter("username"));
        user.setEmail(request.getParameter("email"));
        user.setPassword(request.getParameter("password"));
        user.setContactNo(request.getParameter("contactNo"));
        user.setAddress(request.getParameter("address"));
        user.setRole(request.getParameter("role"));
        return user;
    }

    private void sendError(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        Map<String, String> error = new HashMap<>();
        error.put("status", "error");
        error.put("message", message);
        byte[] bytes = gson.toJson(error).getBytes(StandardCharsets.UTF_8);
        response.setContentType("application/json");
        response.setContentLength(bytes.length);
        response.getOutputStream().write(bytes);
        response.getOutputStream().flush();
    }
}
