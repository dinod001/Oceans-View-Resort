package com.dinod.ocean_view_resort.controller;

import com.dinod.ocean_view_resort.dao.Impl.UserDaoImpl;
import com.dinod.ocean_view_resort.dao.UserDao;
import com.dinod.ocean_view_resort.model.User;
import com.dinod.ocean_view_resort.service.Impl.UserServiceImpl;
import com.dinod.ocean_view_resort.service.UserService;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "AuthController", urlPatterns = { "/auth" })
public class AuthController extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        ConnectionProvider connectionProvider = DBConnection.getInstance();
        UserDao userDao = new UserDaoImpl(connectionProvider);
        this.userService = new UserServiceImpl(userDao);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("login".equalsIgnoreCase(action)) {
            handleLogin(request, response);
        } else if ("register".equalsIgnoreCase(action)) {
            handleRegister(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        String uname = request.getParameter("username");
        String pass = request.getParameter("password");

        User user = userService.authenticate(uname, pass);
        HttpSession session = request.getSession();

        if (user != null) {
            session.setAttribute("id", user.getId());
            session.setAttribute("username", user.getUserName());
            session.setAttribute("role", user.getRole());

            String redirectUrl = getRedirectPath(user.getRole());
            response.sendRedirect(redirectUrl);
        } else {
            request.setAttribute("errorMessage", "Invalid credentials");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
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

        try {
            if (userService.validateCredentials(user)) {
                request.setAttribute("successMessage", "User registered successfully");
                request.getRequestDispatcher("admin-dashboard/register.jsp").forward(request, response);
            } else {
                request.setAttribute("errorMessage", "Registration failed: Database error");
                request.getRequestDispatcher("admin-dashboard/register.jsp").forward(request, response);
            }
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("admin-dashboard/register.jsp").forward(request, response);
        }
    }
}
