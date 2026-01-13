<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.dinod.ocean_view_resort.model.Guest" %>

<%
  // Session Check - Staff Only
  if(session.getAttribute("username") == null || !"Staff".equalsIgnoreCase((String) session.getAttribute("role"))) {
    response.sendRedirect("../login.jsp");
    return;
  }

  // One-time success message
  String successMsg = (String) session.getAttribute("successMessage");
  if(successMsg != null){
    request.setAttribute("successMessage", successMsg);
    session.removeAttribute("successMessage");
  }

  List<Guest> guestList = (List<Guest>) request.getAttribute("guestList");
  Guest guestToEdit = (Guest) request.getAttribute("guestToEdit");
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Manage Guests | Ocean View Resort (Staff)</title>
  <style>
    /* Original CSS preserved */
    :root {--primary:#006994;--primary-dark:#005a80;--text:#1f2937;--bg:#f3f4f6;--white:#ffffff;--danger:#dc2626;--success:#16a34a;--warning:#f59e0b;}
    * {box-sizing:border-box;margin:0;padding:0;}
    body {font-family:'Segoe UI', system-ui, sans-serif;background:var(--bg);padding:2rem;color:var(--text);}
    .container {max-width:1200px;margin:0 auto;display:grid;gap:2rem;grid-template-columns:2fr 1fr;}
    @media(max-width:900px){.container{grid-template-columns:1fr;}}
    .card{background:var(--white);padding:1.5rem;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.05);}
    h1{color:var(--primary);margin-bottom:0.5rem;}
    h2{color:var(--primary);margin-bottom:1.5rem;font-size:1.25rem;border-bottom:2px solid #e5e7eb;padding-bottom:0.5rem;}
    header{margin-bottom:2rem;display:flex;justify-content:space-between;align-items:center;}
    .back-link{text-decoration:none;color:#4b5563;font-weight:500;display:flex;align-items:center;gap:0.5rem;}
    .back-link:hover{color:var(--primary);}
    .form-group{margin-bottom:1rem;}
    label{display:block;margin-bottom:0.5rem;font-weight:600;font-size:0.9rem;color:#374151;}
    input, select, textarea{width:100%;padding:0.75rem;border:1px solid #d1d5db;border-radius:8px;font-size:0.95rem;transition:border-color 0.2s;font-family:inherit;}
    input:focus, select:focus, textarea:focus{outline:none;border-color:var(--primary);box-shadow:0 0 0 3px rgba(0,105,148,0.1);}
    button{width:100%;padding:0.875rem;border:none;border-radius:8px;font-weight:600;cursor:pointer;transition:all 0.2s;font-size:1rem;}
    .btn-primary{background:var(--primary);color:white;margin-top:1rem;}
    .btn-primary:hover{background:var(--primary-dark);transform:translateY(-1px);}
    .btn-cancel{background:transparent;color:#6b7280;border:1px solid #d1d5db;margin-top:0.5rem;padding:0.75rem;display:inline-block;text-align:center;}
    .btn-cancel:hover{background:#f3f4f6;color:#374151;}
    .action-btn{padding:0.4rem 0.8rem;border-radius:6px;text-decoration:none;font-size:0.85rem;font-weight:600;display:inline-block;margin-right:0.25rem;border:none;cursor:pointer;}
    .btn-edit{background:#eff6ff;color:var(--primary);border:1px solid #bfdbfe;}
    .btn-edit:hover{background:#dbeafe;}
    .btn-delete{background:#fef2f2;color:var(--danger);border:1px solid #fecaca;}
    .btn-delete:hover{background:#fee2e2;}
    .table-responsive{overflow-x:auto;}
    table{width:100%;border-collapse:separate;border-spacing:0;}
    th, td{padding:1rem;text-align:left;border-bottom:1px solid #e5e7eb;}
    th{background:#f9fafb;font-weight:600;color:#4b5563;font-size:0.9rem;text-transform:uppercase;letter-spacing:0.05em;}
    th:first-child{border-top-left-radius:8px;}
    th:last-child{border-top-right-radius:8px;}
    tr:last-child td{border-bottom:none;}
    tr:hover{background-color:#f9fafb;}
    .search-bar{display:flex;gap:0.5rem;margin-bottom:1.5rem;}
    .search-bar input{flex:1;}
    .search-bar button{width:auto;background:#4b5563;color:white;}
    .alert{padding:1rem;border-radius:8px;margin-bottom:1.5rem;text-align:center;font-weight:500;}
    .alert-success{background:#d1fae5;color:#065f46;border:1px solid #a7f3d0;}
    .alert-error{background:#fee2e2;color:#991b1b;border:1px solid #fecaca;}
  </style>
</head>
<body>

<header>
  <div>
    <h1>Guest Management (Staff)</h1>
    <p style="color:#6b7280;">Register and manage resort guests</p>
  </div>
  <a href="index.jsp" class="back-link">← Back to Dashboard</a>
</header>

<% if(request.getAttribute("errorMessage") != null){ %>
<div class="alert alert-error"><%= request.getAttribute("errorMessage") %></div>
<% } %>
<% if(request.getAttribute("successMessage") != null){ %>
<div class="alert alert-success"><%= request.getAttribute("successMessage") %></div>
<% } %>

<div class="container">

  <!-- Guest List -->
  <div class="card table-responsive">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem;">
      <h2>All Guests</h2>
      <a href="../guests" style="font-size:0.9rem;color:var(--primary);text-decoration:none;">Show All</a>
    </div>

    <form action="../guests" method="GET" class="search-bar">
      <input type="text" name="searchContact" placeholder="Search by Contact No..."
             value="<%= request.getAttribute("searchContact") != null ? request.getAttribute("searchContact") : "" %>">
      <button type="submit">Search</button>
    </form>

    <table>
      <thead>
      <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Contact No</th>
        <th>Address</th>
        <th>Actions</th>
      </tr>
      </thead>
      <tbody>
      <% if(guestList != null && !guestList.isEmpty()){
        for(Guest g : guestList){ %>
      <tr>
        <td>#<%= g.getGuestID() %></td>
        <td><%= g.getName() %></td>
        <td style="font-family:monospace;"><%= g.getContactNo() %></td>
        <td><%= g.getAddress() %></td>
        <td>
          <div style="display:flex;align-items:center;">
            <a href="../guests?action=edit&id=<%= g.getGuestID() %>" class="action-btn btn-edit">Edit</a>
            <form action="../guests" method="POST" style="margin:0;">
              <input type="hidden" name="action" value="delete">
              <input type="hidden" name="guestId" value="<%= g.getGuestID() %>">
              <button type="submit" class="action-btn btn-delete"
                      onclick="return confirm('Are you sure you want to delete Guest <%= g.getName() %>?');">Delete</button>
            </form>
          </div>
        </td>
      </tr>
      <% } } else { %>
      <tr>
        <td colspan="5" style="text-align:center;padding:2rem;color:#6b7280;">
          No guests found. Add one to get started!
        </td>
      </tr>
      <% } %>
      </tbody>
    </table>
  </div>

  <!-- Add/Edit Form -->
  <div class="card" style="align-self:start; position:sticky; top:2rem;">
    <h2><%= guestToEdit != null ? "Edit Guest" : "Add New Guest" %></h2>

    <form action="../guests" method="POST">
      <input type="hidden" name="action" value="<%= guestToEdit != null ? "update" : "add" %>">

      <div class="form-group">
        <label for="guestId">Guest ID</label>
        <% if(guestToEdit != null){ %>
        <input type="number" id="guestId" name="guestId" value="<%= guestToEdit.getGuestID() %>" readonly style="background:#f3f4f6;cursor:not-allowed;color:#6b7280;">
        <small style="color:#6b7280;font-size:0.8em;">Cannot change ID.</small>
        <% } else { %>
        <input type="text" value="Auto Generated" disabled style="background:#f3f4f6;color:#6b7280;cursor:not-allowed;">
        <% } %>
      </div>

      <div class="form-group">
        <label for="name">Guest Name</label>
        <input type="text" id="name" name="name" required placeholder="Enter guest name" value="<%= guestToEdit != null ? guestToEdit.getName() : "" %>">
      </div>

      <div class="form-group">
        <label for="contactNo">Contact Number</label>
        <input type="text" id="contactNo" name="contactNo" required placeholder="Enter contact number" value="<%= guestToEdit != null ? guestToEdit.getContactNo() : "" %>">
      </div>

      <div class="form-group">
        <label for="address">Address</label>
        <textarea id="address" name="address" rows="3" placeholder="Enter guest address"><%= guestToEdit != null ? guestToEdit.getAddress() : "" %></textarea>
      </div>

      <button type="submit" class="btn-primary"><%= guestToEdit != null ? "Save Changes" : "Register Guest" %></button>

      <% if(guestToEdit != null){ %>
      <a href="../guests" class="btn-cancel">Cancel Edit</a>
      <% } %>
    </form>
  </div>

</div>

</body>
</html>
