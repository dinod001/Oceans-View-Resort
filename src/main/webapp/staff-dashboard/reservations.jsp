<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.dinod.ocean_view_resort.model.Reservation" %>
<%@ page import="com.dinod.ocean_view_resort.model.Room" %>
<%@ page import="com.dinod.ocean_view_resort.model.Guest" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Session Check - Staff Only
    if (session.getAttribute("username") == null ||
            !"Staff".equalsIgnoreCase((String) session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Success Message
    String successMsg = (String) session.getAttribute("successMessage");
    if (successMsg != null) {
        request.setAttribute("successMessage", successMsg);
        session.removeAttribute("successMessage");
    }

    // Data from Controller
    List<Reservation> reservationList = (List<Reservation>) request.getAttribute("reservationList");
    List<Room> roomList = (List<Room>) request.getAttribute("roomList");

    Reservation resToEdit = (Reservation) request.getAttribute("reservationToEdit");
    Guest guestToEdit = (Guest) request.getAttribute("guestToEdit");

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Reservations | Staff Dashboard</title>

    <!-- ORIGINAL CSS -->
    <style>
        /* Your full original CSS here – unchanged */
        :root { --primary: #006994; --primary-dark: #005a80; --text: #1f2937; --bg: #f3f4f6; --white: #ffffff; --danger: #dc2626; --success: #16a34a; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', system-ui, sans-serif; background: var(--bg); padding: 2rem; color: var(--text); }
        .container { max-width: 1400px; margin: 0 auto; display: grid; gap: 2rem; grid-template-columns: 3fr 1fr; }
        @media(max-width:1100px){.container{grid-template-columns:1fr;}}
        .card{background:var(--white);padding:1.5rem;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);}
        h1,h2,h3{color:var(--primary);margin-bottom:1rem;}
        h2{font-size:1.25rem;border-bottom:2px solid #e5e7eb;padding-bottom:0.5rem;}
        h3{font-size:1rem;color:#4b5563;margin-top:1rem;margin-bottom:0.5rem;}
        header{margin-bottom:2rem;display:flex;justify-content:space-between;align-items:center;}
        .back-link{text-decoration:none;color:#4b5563;font-weight:500;display:flex;align-items:center;gap:0.5rem;}
        .back-link:hover{color:var(--primary);}
        .form-row{display:grid;grid-template-columns:1fr 1fr;gap:1rem;}
        .form-group{margin-bottom:1rem;}
        label{display:block;margin-bottom:0.5rem;font-weight:600;font-size:0.9rem;color:#374151;}
        input,select,textarea{width:100%;padding:0.75rem;border:1px solid #d1d5db;border-radius:8px;font-size:0.95rem;}
        input:focus,select:focus{outline:none;border-color:var(--primary);box-shadow:0 0 0 3px rgba(0,105,148,0.1);}
        button{width:100%;padding:0.875rem;border:none;border-radius:8px;font-weight:600;cursor:pointer;transition:all 0.2s;}
        .btn-primary{background:var(--primary);color:white;margin-top:1rem;}
        .btn-primary:hover{background:var(--primary-dark);}
        .btn-cancel{background:transparent;color:#6b7280;border:1px solid #d1d5db;margin-top:0.5rem;}
        .btn-cancel:hover{background:#f3f4f6;}
        .table-responsive{overflow-x:auto;}
        table{width:100%;border-collapse:separate;border-spacing:0;min-width:800px;}
        th,td{padding:1rem;text-align:left;border-bottom:1px solid #e5e7eb;}
        th{background:#f9fafb;font-weight:600;color:#4b5563;font-size:0.9rem;text-transform:uppercase;}
        tr:hover{background-color:#f9fafb;}
        .action-btn{padding:0.4rem 0.8rem;border-radius:6px;text-decoration:none;font-size:0.85rem;font-weight:600;display:inline-block;margin-right:0.25rem;border:none;cursor:pointer;}
        .btn-edit{background:#eff6ff;color:var(--primary);border:1px solid #bfdbfe;}
        .btn-delete{background:#fef2f2;color:var(--danger);border:1px solid #fecaca;}
        .search-bar{display:flex;gap:0.5rem;margin-bottom:1.5rem;}
        .search-bar input{flex:1;}
        .search-bar button{width:auto;background:#4b5563;color:white;}
        .alert{padding:1rem;border-radius:8px;margin-bottom:1.5rem;text-align:center;font-weight:500;}
        .alert-success{background:#d1fae5;color:#065f46;border:1px solid #a7f3d0;}
        .alert-error{background:#fee2e2;color:#991b1b;border:1px solid #fecaca;}
        .badge{padding:0.25rem 0.5rem;border-radius:4px;font-size:0.75rem;font-weight:700;text-transform:uppercase;}
        .badge-booked{background:#fee2e2;color:#991b1b;}
        .badge-avail{background:#dcfce7;color:#166534;}
    </style>
</head>
<body>

<header>
    <div>
        <h1>Reservations</h1>
        <p style="color: #6b7280;">Book rooms and manage guests</p>
    </div>
    <a href="index.jsp" class="back-link">Back to Dashboard</a>
</header>

<% if(request.getAttribute("errorMessage") != null){ %>
<div class="alert alert-error"><%= request.getAttribute("errorMessage") %></div>
<% } %>

<% if(request.getAttribute("successMessage") != null){ %>
<div class="alert alert-success"><%= request.getAttribute("successMessage") %></div>
<% } %>

<div class="container">

    <!-- RESERVATIONS LIST -->
    <div class="card table-responsive">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem;">
            <h2>All Reservations</h2>
            <a href="../reservations" style="font-size:0.9rem;color:var(--primary); text-decoration:none;">Show All</a>
        </div>

        <form action="../reservations" method="GET" class="search-bar">
            <input type="text" name="searchContact" placeholder="Search by Guest Contact No..."
                   value="<%= request.getAttribute("searchContact") != null ? request.getAttribute("searchContact") : "" %>">
            <button type="submit">Search</button>
        </form>

        <table>
            <thead>
            <tr>
                <th>Res. ID</th>
                <th>Guest</th>
                <th>Mobile</th>
                <th>Room</th>
                <th>Rate</th>
                <th>Dates</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <% if(reservationList != null && !reservationList.isEmpty()){
                for(Reservation r : reservationList){ %>
            <tr>
                <td>#<%= r.getReservationNo() %></td>
                <td>
                    <div style="font-weight:600;"><%= r.getGuestName() != null ? r.getGuestName() : "" %></div>
                    <div style="font-size:0.8em; color:#6b7280;">ID: <%= r.getGuestID() %></div>
                </td>
                <td><%= r.getGuestContact() != null ? r.getGuestContact() : "" %></td>
                <td><strong style="color:var(--primary);">Room <%= r.getRoomNo() %></strong><br>
                    <span style="font-size:0.85em; color:#6b7280;"><%= r.getRoomType() %></span>
                </td>
                <td>$<%= String.format("%.2f", r.getPricePerNight()) %></td>
                <td style="white-space:nowrap;">
                    <div style="color:#059669;">In: <%= sdf.format(r.getCheckInDate()) %></div>
                    <div style="color:#dc2626;">Out: <%= sdf.format(r.getCheckOutDate()) %></div>
                </td>
                <td>
                    <div style="display:flex; gap:0.5rem; align-items:center;">
                        <a href="../reservations?action=edit&id=<%= r.getReservationNo() %>" class="action-btn btn-edit">Edit</a>

                        <form action="../billing" method="POST" style="margin:0;">
                            <input type="hidden" name="action" value="generate">
                            <input type="hidden" name="reservationNo" value="<%= r.getReservationNo() %>">
                            <button type="submit" class="action-btn" style="background:#8b5cf6; color:white; border:1px solid #7c3aed;">Bill</button>
                        </form>

                        <form action="../reservations" method="POST" style="margin:0;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="reservationNo" value="<%= r.getReservationNo() %>">
                            <button type="submit" class="action-btn btn-delete" onclick="return confirm('Cancel Reservation #<%= r.getReservationNo() %>?');">X</button>
                        </form>
                    </div>
                </td>
            </tr>
            <%  }
            } else { %>
            <tr><td colspan="7" style="text-align:center; padding:2rem; color:#6b7280;">No reservations found.</td></tr>
            <% } %>
            </tbody>
        </table>
    </div>

    <!-- BOOKING FORM -->
    <div class="card" style="align-self:start; position:sticky; top:2rem;">
        <h2><%= resToEdit != null ? "Edit Booking" : "New Booking" %></h2>

        <form action="../reservations" method="POST">
            <input type="hidden" name="action" value="<%= resToEdit != null ? "update" : "add" %>">

            <% if(resToEdit != null){ %>
            <input type="hidden" name="reservationNo" value="<%= resToEdit.getReservationNo() %>">
            <input type="hidden" name="guestId" value="<%= resToEdit.getGuestID() %>">
            <% } %>

            <h3>1. Guest Details</h3>
            <div class="form-group">
                <label>Contact Number (Required)</label>
                <input type="text" name="guestContact" required value="<%= guestToEdit != null ? guestToEdit.getContactNo() : "" %>">
            </div>
            <div class="form-group">
                <label>Full Name</label>
                <input type="text" name="guestName" required value="<%= guestToEdit != null ? guestToEdit.getName() : "" %>">
            </div>
            <div class="form-group">
                <label>Address</label>
                <input type="text" name="guestAddress" value="<%= guestToEdit != null ? guestToEdit.getAddress() : "" %>">
            </div>

            <h3>2. Room & Dates</h3>
            <div class="form-group">
                <label>Select Room</label>
                <select name="roomNo" required>
                    <option value="" disabled selected>-- Choose Available Room --</option>
                    <% if(roomList != null){
                        for(Room room : roomList){
                            boolean isCurrent = resToEdit != null && resToEdit.getRoomNo() == room.getRoomNo();
                            boolean isAvailable = room.isAvailable();
                            if(isAvailable || isCurrent){ %>
                    <option value="<%= room.getRoomNo() %>" <%= isCurrent ? "selected" : "" %>>
                        Room <%= room.getRoomNo() %> - <%= room.getRoomType() %> ($<%= room.getPricePerNight() %>) <%= isCurrent ? "(Current)" : "" %>
                    </option>
                    <%      } else { %>
                    <option value="<%= room.getRoomNo() %>" disabled style="color:#ccc;">
                        Room <%= room.getRoomNo() %> - <%= room.getRoomType() %> (Booked)
                    </option>
                    <%      }
                    }
                    } %>
                </select>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Check-in</label>
                    <input type="date" name="checkInDate" required value="<%= resToEdit != null && resToEdit.getCheckInDate() != null ? sdf.format(resToEdit.getCheckInDate()) : "" %>">
                </div>
                <div class="form-group">
                    <label>Check-out</label>
                    <input type="date" name="checkOutDate" required value="<%= resToEdit != null && resToEdit.getCheckOutDate() != null ? sdf.format(resToEdit.getCheckOutDate()) : "" %>">
                </div>
            </div>

            <button type="submit" class="btn-primary"><%= resToEdit != null ? "Update Reservation" : "Confirm Booking" %></button>
            <% if(resToEdit != null){ %>
            <a href="../reservations"><button type="button" class="btn-cancel">Cancel Edit</button></a>
            <% } %>
        </form>
    </div>

</div>
</body>
</html>
