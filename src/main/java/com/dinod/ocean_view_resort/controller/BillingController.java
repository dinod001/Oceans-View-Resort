package com.dinod.ocean_view_resort.controller;

import com.dinod.ocean_view_resort.dao.BillingDao;
import com.dinod.ocean_view_resort.dao.Impl.BillingDaoImpl;
import com.dinod.ocean_view_resort.model.Billing;
import com.dinod.ocean_view_resort.service.BillingService;
import com.dinod.ocean_view_resort.service.Impl.BillingServiceImpl;
import com.dinod.ocean_view_resort.utills.ConnectionProvider;
import com.dinod.ocean_view_resort.utills.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

import com.google.gson.Gson;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "BillingController", urlPatterns = { "/billing" })
public class BillingController extends HttpServlet {

    private BillingService billingService;
    private final Gson gson = new Gson();

    @Override
    public void init() throws ServletException {
        // Manual Dependency Injection Wiring
        ConnectionProvider connectionProvider = DBConnection.getInstance();
        BillingDao billingDao = new BillingDaoImpl(connectionProvider);
        this.billingService = new BillingServiceImpl(billingDao);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String action = request.getParameter("action");

        if ("generate".equals(action)) {
            handleGenerateBill(request, response, out);
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print(gson.toJson(createResponse("error", "Unknown action")));
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String action = request.getParameter("action");
        if ("view".equals(action)) {
            try {
                int resNo = Integer.parseInt(request.getParameter("id"));
                Billing bill = billingService.getBillByReservationId(resNo);

                if (bill != null) {
                    out.print(gson.toJson(bill));
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print(gson.toJson(createResponse("error", "Bill not found")));
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print(gson.toJson(createResponse("error", "Invalid ID")));
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print(gson.toJson(createResponse("error", e.getMessage())));
            }
        }
    }

    private void handleGenerateBill(HttpServletRequest request, HttpServletResponse response, PrintWriter out) {
        try {
            int resNo = Integer.parseInt(request.getParameter("reservationNo"));

            // Generate the bill (calls Stored Procedure internally)
            // Email sending is now handled inside BillingServiceImpl.generateBill()
            Billing bill = billingService.generateBill(resNo);

            if (bill != null) {
                out.print(gson.toJson(createResponse("success", "Bill generated successfully!", bill)));
            } else {
                out.print(gson.toJson(createResponse("error", "Failed to generate bill. Ensure reservation exists.")));
            }

        } catch (NumberFormatException e) {
            out.print(gson.toJson(createResponse("error", "Invalid Reservation ID.")));
        } catch (Exception e) {
            e.printStackTrace();
            out.print(gson.toJson(createResponse("error", "System error generating bill: " + e.getMessage())));
        }
    }

    // Helper for Java 8 Compatibility (No Map.of)
    private Map<String, Object> createResponse(String status, String message) {
        Map<String, Object> map = new HashMap<>();
        map.put("status", status);
        map.put("message", message);
        return map;
    }

    private Map<String, Object> createResponse(String status, String message, Object data) {
        Map<String, Object> map = new HashMap<>();
        map.put("status", status);
        map.put("message", message);
        map.put("data", data);
        return map;
    }
}
