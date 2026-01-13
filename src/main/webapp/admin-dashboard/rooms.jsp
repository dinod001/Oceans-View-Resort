<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="java.util.List" %>
        <%@ page import="com.dinod.ocean_view_resort.model.Room" %>

<%
    // Session Check - Admin Only
    if (session.getAttribute("username") == null ||
            !"Admin".equalsIgnoreCase((String) session.getAttribute("role"))) {

        response.sendRedirect("../login.jsp");
        return;
    }

    // Retrieve One-Time Success Message from Session
    String successMsg = (String) session.getAttribute("successMessage");
    if (successMsg != null) {
        request.setAttribute("successMessage", successMsg);
        session.removeAttribute("successMessage");
    }

    // Get attributes from controller
    List<Room> roomList = (List<Room>) request.getAttribute("roomList");
    Room roomToEdit = (Room) request.getAttribute("roomToEdit");
%>






<!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Manage Rooms | Ocean View Resort</title>
                        <style>
                            :root {
                                --primary: #006994;
                                --primary-dark: #005a80;
                                --text: #1f2937;
                                --bg: #f3f4f6;
                                --white: #ffffff;
                                --danger: #dc2626;
                                --success: #16a34a;
                                --warning: #f59e0b;
                            }

                            * {
                                box-sizing: border-box;
                                margin: 0;
                                padding: 0;
                            }

                            body {
                                font-family: 'Segoe UI', system-ui, sans-serif;
                                background: var(--bg);
                                padding: 2rem;
                                color: var(--text);
                            }

                            .container {
                                max-width: 1200px;
                                margin: 0 auto;
                                display: grid;
                                gap: 2rem;
                                grid-template-columns: 2fr 1fr;
                                /* List takes more space */
                            }

                            @media(max-width: 900px) {
                                .container {
                                    grid-template-columns: 1fr;
                                }
                            }

                            /* Card Styles */
                            .card {
                                background: var(--white);
                                padding: 1.5rem;
                                border-radius: 12px;
                                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
                            }

                            h1 {
                                color: var(--primary);
                                margin-bottom: 0.5rem;
                            }

                            h2 {
                                color: var(--primary);
                                margin-bottom: 1.5rem;
                                font-size: 1.25rem;
                                border-bottom: 2px solid #e5e7eb;
                                padding-bottom: 0.5rem;
                            }

                            header {
                                margin-bottom: 2rem;
                                display: flex;
                                justify-content: space-between;
                                align-items: center;
                            }

                            .back-link {
                                text-decoration: none;
                                color: #4b5563;
                                font-weight: 500;
                                display: flex;
                                align-items: center;
                                gap: 0.5rem;
                            }

                            .back-link:hover {
                                color: var(--primary);
                            }

                            /* Form */
                            .form-group {
                                margin-bottom: 1rem;
                            }

                            label {
                                display: block;
                                margin-bottom: 0.5rem;
                                font-weight: 600;
                                font-size: 0.9rem;
                                color: #374151;
                            }

                            input,
                            select {
                                width: 100%;
                                padding: 0.75rem;
                                border: 1px solid #d1d5db;
                                border-radius: 8px;
                                font-size: 0.95rem;
                                transition: border-color 0.2s;
                            }

                            input:focus,
                            select:focus {
                                outline: none;
                                border-color: var(--primary);
                                box-shadow: 0 0 0 3px rgba(0, 105, 148, 0.1);
                            }

                            .checkbox-group {
                                display: flex;
                                align-items: center;
                                gap: 0.75rem;
                                padding: 0.5rem 0;
                            }

                            .checkbox-group input {
                                width: auto;
                                width: 1.2rem;
                                height: 1.2rem;
                            }

                            .checkbox-group label {
                                margin: 0;
                                cursor: pointer;
                            }

                            button {
                                width: 100%;
                                padding: 0.875rem;
                                border: none;
                                border-radius: 8px;
                                font-weight: 600;
                                cursor: pointer;
                                transition: all 0.2s;
                                font-size: 1rem;
                            }

                            .btn-primary {
                                background: var(--primary);
                                color: white;
                                margin-top: 1rem;
                            }

                            .btn-primary:hover {
                                background: var(--primary-dark);
                                transform: translateY(-1px);
                            }

                            .btn-cancel {
                                background: transparent;
                                color: #6b7280;
                                border: 1px solid #d1d5db;
                                margin-top: 0.5rem;
                            }

                            .btn-cancel:hover {
                                background: #f3f4f6;
                                color: #374151;
                            }

                            /* Action Buttons in Table */
                            .action-btn {
                                padding: 0.4rem 0.8rem;
                                border-radius: 6px;
                                text-decoration: none;
                                font-size: 0.85rem;
                                font-weight: 600;
                                display: inline-block;
                                margin-right: 0.25rem;
                                border: none;
                                cursor: pointer;
                            }

                            .btn-edit {
                                background: #eff6ff;
                                color: var(--primary);
                                border: 1px solid #bfdbfe;
                            }

                            .btn-edit:hover {
                                background: #dbeafe;
                            }

                            .btn-delete {
                                background: #fef2f2;
                                color: var(--danger);
                                border: 1px solid #fecaca;
                            }

                            .btn-delete:hover {
                                background: #fee2e2;
                            }

                            /* Table */
                            .table-responsive {
                                overflow-x: auto;
                            }

                            table {
                                width: 100%;
                                border-collapse: separate;
                                border-spacing: 0;
                            }

                            th,
                            td {
                                padding: 1rem;
                                text-align: left;
                                border-bottom: 1px solid #e5e7eb;
                            }

                            th {
                                background: #f9fafb;
                                font-weight: 600;
                                color: #4b5563;
                                font-size: 0.9rem;
                                text-transform: uppercase;
                                letter-spacing: 0.05em;
                            }

                            th:first-child {
                                border-top-left-radius: 8px;
                            }

                            th:last-child {
                                border-top-right-radius: 8px;
                            }

                            tr:last-child td {
                                border-bottom: none;
                            }

                            tr:hover {
                                background-color: #f9fafb;
                            }

                            .badge {
                                display: inline-flex;
                                align-items: center;
                                padding: 0.25rem 0.75rem;
                                border-radius: 999px;
                                font-size: 0.8rem;
                                font-weight: 600;
                            }

                            .badge-available {
                                background: #dcfce7;
                                color: #166534;
                            }

                            .badge-booked {
                                background: #fee2e2;
                                color: #991b1b;
                            }

                            /* Alerts */
                            .alert {
                                padding: 1rem;
                                border-radius: 8px;
                                margin-bottom: 1.5rem;
                                text-align: center;
                                font-weight: 500;
                            }

                            .alert-success {
                                background: #d1fae5;
                                color: #065f46;
                                border: 1px solid #a7f3d0;
                            }

                            .alert-error {
                                background: #fee2e2;
                                color: #991b1b;
                                border: 1px solid #fecaca;
                            }
                        </style>
                    </head>

                    <body>

                        <header>
                            <div>
                                <h1>Room Management</h1>
                                <p style="color: #6b7280;">Add, edit and manage resort rooms</p>
                            </div>
                            <a href="register.jsp" class="back-link">
                                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                                    fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                    stroke-linejoin="round">
                                    <line x1="19" y1="12" x2="5" y2="12"></line>
                                    <polyline points="12 19 5 12 12 5"></polyline>
                                </svg>
                                Back to Dashboard
                            </a>
                        </header>

                        <%-- Messages --%>
                            <% if(request.getAttribute("errorMessage") !=null) { %>
                                <div class="alert alert-error">
                                    <%= request.getAttribute("errorMessage") %>
                                </div>
                                <% } %>
                                    <% if(request.getAttribute("successMessage") !=null) { %>
                                        <div class="alert alert-success">
                                            <%= request.getAttribute("successMessage") %>
                                        </div>
                                        <% } %>

                                            <div class="container">
                                                <!-- List Rooms (Left Side) -->
                                                <div class="card table-responsive">
                                                    <h2>All Rooms</h2>
                                                    <table>
                                                        <thead>
                                                            <tr>
                                                                <th>No</th>
                                                                <th>Type</th>
                                                                <th>Price</th>
                                                                <th>Status</th>
                                                                <th>Actions</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <% if (roomList !=null && !roomList.isEmpty()) { for(Room r
                                                                : roomList) { %>
                                                                <tr>
                                                                    <td style="font-weight: 600; color: #374151;">#<%=
                                                                            r.getRoomNo() %>
                                                                    </td>
                                                                    <td>
                                                                        <%= r.getRoomType() %>
                                                                    </td>
                                                                    <td
                                                                        style="font-family: monospace; font-size: 1.1em;">
                                                                        $<%= String.format("%.2f", r.getPricePerNight())
                                                                            %>
                                                                    </td>
                                                                    <td>
                                                                        <% if(r.isAvailable()) { %>
                                                                            <span
                                                                                class="badge badge-available">Available</span>
                                                                            <% } else { %>
                                                                                <span
                                                                                    class="badge badge-booked">Booked</span>
                                                                                <% } %>
                                                                    </td>
                                                                    <td>
                                                                        <div
                                                                            style="display: flex; align-items: center;">
                                                                            <a href="../rooms?action=edit&id=<%= r.getRoomNo() %>"
                                                                                class="action-btn btn-edit">Edit</a>

                                                                            <form action="../rooms" method="POST"
                                                                                style="margin:0;">
                                                                                <input type="hidden" name="action"
                                                                                    value="delete">
                                                                                <input type="hidden" name="roomNo"
                                                                                    value="<%= r.getRoomNo() %>">
                                                                                <button type="submit"
                                                                                    class="action-btn btn-delete"
                                                                                    onclick="return confirm('Are you sure you want to delete Room <%= r.getRoomNo() %>?');">
                                                                                    Delete
                                                                                </button>
                                                                            </form>
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                                <% }} else { %>
                                                                    <tr>
                                                                        <td colspan="5"
                                                                            style="text-align:center; padding: 2rem; color: #6b7280;">
                                                                            No rooms found. Add one to get started!
                                                                        </td>
                                                                    </tr>
                                                                    <% } %>
                                                        </tbody>
                                                    </table>
                                                </div>

                                                <!-- Add/Edit Form (Right Side) -->
                                                <div class="card"
                                                    style="align-self: start; position: sticky; top: 2rem;">
                                                    <h2>
                                                        <%= roomToEdit !=null ? "Edit Room" : "Add New Room" %>
                                                    </h2>

                                                    <form action="../rooms" method="POST">
                                                        <input type="hidden" name="action"
                                                            value="<%= roomToEdit != null ? " update" : "add" %>">

                                                        <div class="form-group">
                                                            <label for="roomNo">Room Number</label>
                                                            <% if (roomToEdit !=null) { %>
                                                                <input type="number" id="roomNo" name="roomNo"
                                                                    value="<%= roomToEdit.getRoomNo() %>" readonly
                                                                    style="background: #f3f4f6; cursor: not-allowed; color: #6b7280;">
                                                                <small style="color: #6b7280; font-size: 0.8em;">Cannot
                                                                    change Room No.</small>
                                                                <% } else { %>
                                                                    <input type="text" value="Auto Generated" disabled
                                                                        style="background: #f3f4f6; color: #6b7280; cursor: not-allowed;">
                                                                    <% } %>
                                                        </div>

                                                        <div class="form-group">
                                                            <label for="roomType">Room Type</label>
                                                            <select id="roomType" name="roomType">
                                                                <option value="Single" <%=roomToEdit !=null && "Single"
                                                                    .equals(roomToEdit.getRoomType()) ? "selected" : ""
                                                                    %>>Single Room</option>
                                                                <option value="Double" <%=roomToEdit !=null && "Double"
                                                                    .equals(roomToEdit.getRoomType()) ? "selected" : ""
                                                                    %>>Double Room</option>
                                                                <option value="Suite" <%=roomToEdit !=null && "Suite"
                                                                    .equals(roomToEdit.getRoomType()) ? "selected" : ""
                                                                    %>>Luxury Suite</option>
                                                                <option value="Deluxe" <%=roomToEdit !=null && "Deluxe"
                                                                    .equals(roomToEdit.getRoomType()) ? "selected" : ""
                                                                    %>>Deluxe Room</option>
                                                            </select>
                                                        </div>

                                                        <div class="form-group">
                                                            <label for="pricePerNight">Price Per Night ($)</label>
                                                            <input type="number" id="pricePerNight" name="pricePerNight"
                                                                step="0.01" required min="0" placeholder="0.00"
                                                                value="<%= roomToEdit != null ? roomToEdit.getPricePerNight() : "" %>">
                                                        </div>

                                                        <div class="checkbox-group">
                                                            <input type="checkbox" id="isAvailable" name="isAvailable"
                                                                value="true" <%=(roomToEdit==null ||
                                                                roomToEdit.isAvailable()) ? "checked" : "" %>>
                                                            <label for="isAvailable">Room is Available</label>
                                                        </div>

                                                        <button type="submit" class="btn-primary">
                                                            <%= roomToEdit !=null ? "Save Changes" : "Create Room" %>
                                                        </button>

                                                        <% if(roomToEdit !=null) { %>
                                                            <a href="../rooms">
                                                                <button type="button" class="btn-cancel">Cancel
                                                                    Edit</button>
                                                            </a>
                                                            <% } %>
                                                    </form>
                                                </div>
                                            </div>

                    </body>

                    </html>