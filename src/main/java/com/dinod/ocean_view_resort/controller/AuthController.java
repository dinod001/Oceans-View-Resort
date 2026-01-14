package com.dinod.ocean_view_resort.controller;

import com.dinod.ocean_view_resort.dao.Impl.UserDaoImpl;
import com.dinod.ocean_view_resort.dao.UserDao;
import com.dinod.ocean_view_resort.model.User;
import com.dinod.ocean_view_resort.service.Impl.UserServiceImpl;
import com.dinod.ocean_view_resort.service.UserService;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "AuthController", urlPatterns = { "/auth" })
public class AuthController extends HttpServlet {

    private UserService userService;
    private Gson gson = new Gson();

    @Override
    public void init() throws ServletException {
        ConnectionProvider connectionProvider = DBConnection.getInstance();
        UserDao userDao = new UserDaoImpl(connectionProvider);
        this.userService = new UserServiceImpl(userDao);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        // Set response type to JSON for Distributed Web Service requirement
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if ("login".equalsIgnoreCase(action)) {
            handleLogin(request, response);
        } else if ("register".equalsIgnoreCase(action)) {
            handleRegister(request, response);
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            Map<String, String> error = new HashMap<>();
            error.put("status", "error");
            error.put("message", "Invalid action");
            response.getWriter().write(gson.toJson(error));
        }
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        String uname = request.getParameter("username");
        String pass = request.getParameter("password");

        User user = userService.authenticate(uname, pass);
        Map<String, String> jsonResponse = new HashMap<>();

        if (user != null) {
            request.getSession().setAttribute("id", user.getId());
            request.getSession().setAttribute("username", user.getUserName());
            request.getSession().setAttribute("role", user.getRole());

            String redirectUrl = getRedirectPath(user.getRole());

            jsonResponse.put("status", "success");
            jsonResponse.put("redirectUrl", redirectUrl);
        } else {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Invalid credentials");
        }
        response.getWriter().write(gson.toJson(jsonResponse));
    }

    private String getRedirectPath(String role) {
        if ("Admin".equalsIgnoreCase(role)) {
            return "admin-dashboard/register.jsp";
        } else if ("Staff".equalsIgnoreCase(role)) {
            return "staff-dashboard/index.jsp";
        } else {
            return "index.jsp";
        }
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        String uname = request.getParameter("username");
        String pass = request.getParameter("password");
        String role = request.getParameter("role");

        User user = new User(uname, pass, role);
        Map<String, String> jsonResponse = new HashMap<>();

        try {
            if (userService.validateCredentials(user)) {
                jsonResponse.put("status", "success");
                jsonResponse.put("message", "User registered successfully");
            } else {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "Registration failed: Database error");
            }
        } catch (IllegalArgumentException e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", e.getMessage());
        }
        response.getWriter().write(gson.toJson(jsonResponse));
    }
}
