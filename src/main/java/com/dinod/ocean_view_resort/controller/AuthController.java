package com.dinod.ocean_view_resort.controller;

import com.dinod.ocean_view_resort.dao.Impl.AuthDaoImpl;
import com.dinod.ocean_view_resort.dao.AuthDao;
import com.dinod.ocean_view_resort.model.User;
import com.dinod.ocean_view_resort.service.Impl.AuthServiceImpl;
import com.dinod.ocean_view_resort.service.AuthService;
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
import java.util.Map;

@WebServlet(name = "AuthController", urlPatterns = { "/auth" })
public class AuthController extends HttpServlet {

    private AuthService authService;
    private Gson gson = new Gson();

    @Override
    public void init() throws ServletException {
        ConnectionProvider connectionProvider = DBConnection.getInstance();
        AuthDao authDao = new AuthDaoImpl(connectionProvider);
        this.authService = new AuthServiceImpl(authDao);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        // Set response type to JSON for Distributed Web Service requirement
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if ("login".equalsIgnoreCase(action)) {
            handleLogin(request, response);
        } else if ("logout".equalsIgnoreCase(action)) {
            handleLogout(request, response);
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            Map<String, String> error = new HashMap<>();
            error.put("status", "error");
            error.put("message", "Invalid action");
            response.getWriter().write(gson.toJson(error));
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("logout".equalsIgnoreCase(action)) {
            handleLogout(request, response);
        } else {
            response.sendRedirect("login.jsp");
        }
    }

    private void handleLogout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.getSession().invalidate();

        // Security: Prevent back button access
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String contextPath = request.getContextPath();
        response.sendRedirect(contextPath + "/login.jsp");
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        String uname = request.getParameter("username");
        String pass = request.getParameter("password");

        User user = authService.authenticate(uname, pass);
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
            return "admin-dashboard/index.jsp";
        } else if ("Staff".equalsIgnoreCase(role)) {
            return "staff-dashboard/index.jsp";
        } else {
            return "index.jsp";
        }
    }
}
