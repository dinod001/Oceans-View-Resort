<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.dinod.ocean_view_resort.model.Guest" %>

<%
  // Security: Prevent back button access
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);

  // Session Check - Staff Only
  String username = (String) session.getAttribute("username");
  String role = (String) session.getAttribute("role");

  if (username == null || !"Staff".equalsIgnoreCase(role)) {
    // Redirect unauthorized users to login page
    response.sendRedirect("../login.jsp");
    return; // Stop executing the rest of the page
  }
%>

<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Manage Guests | Ocean View Resort (Staff)</title>
  <link rel="stylesheet" href="../css/style.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    /* Page-specific overrides */
    .search-row {
      display: flex;
      gap: 0.5rem;
      margin-bottom: 2rem;
    }

    .search-row input {
      flex: 1;
      height: 42px;
    }

    .search-row .btn {
      width: 42px;
      height: 42px;
      padding: 0;
      border-radius: var(--radius-md);
      flex-shrink: 0;
    }

    /* Table Column Sizing */
    th:first-child,
    td:first-child {
      min-width: 150px;
    }

    /* Name */
    th:nth-child(2),
    td:nth-child(2) {
      width: 120px;
    }

    /* Contact */
    th:nth-child(3),
    td:nth-child(3) {
      min-width: 180px;
    }

    /* Email */
    th:nth-child(4),
    td:nth-child(4) {
      width: auto;
    }

    /* Address (flexible) */
    th:last-child,
    td:last-child {
      width: 100px;
      text-align: center;
    }
  </style>
</head>

<body>

<header>
  <h1>Guest Management (Staff)</h1>
  <a href="index.jsp" class="back-link">
    <i class="fas fa-arrow-left"></i> Back to Dashboard
  </a>
</header>

<div class="container">
  <!-- Guest List -->
  <div class="card">
    <div style="display:flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
      <h2>All Guests</h2>
    </div>

    <div class="search-row">
      <input type="text" id="searchInput" placeholder="Search by contact number or email...">
      <button class="btn btn-primary" onclick="searchGuests()" title="Search">
        <i class="fas fa-search"></i>
      </button>
      <button class="btn btn-outline" onclick="resetSearch()" title="Refresh">
        <i class="fas fa-sync"></i>
      </button>
    </div>

    <table>
      <thead>
      <tr>
        <th>Name</th>
        <th>Contact No</th>
        <th>Email</th>
        <th>Address</th>
        <th>Actions</th>
      </tr>
      </thead>
      <tbody id="guestTableBody">
      <tr>
        <td colspan="5" style="text-align:center;">Loading guests...</td>
      </tr>
      </tbody>
    </table>
  </div>

  <!-- Add/Edit Form -->
  <div class="card">
    <h2 id="formTitle">Add New Guest</h2>

    <form id="guestForm" onsubmit="handleGuestSubmit(event)">
      <input type="hidden" name="action" value="add">
      <input type="hidden" name="guestId">

      <div class="form-group">
        <label>Guest Name</label>
        <input type="text" name="name" required>
      </div>

      <div class="form-group">
        <label>Contact Number</label>
        <input type="text" name="contactNo" required>
      </div>

      <div class="form-group">
        <label>Email Address</label>
        <input type="email" name="email" placeholder="guest@example.com">
      </div>

      <div class="form-group">
        <label>Address</label>
        <textarea name="address" rows="3"></textarea>
      </div>

      <div id="form-msg" class="alert hidden"></div>

      <button class="btn btn-primary" id="submitBtn">
        <i class="fas fa-user-plus"></i> Register Guest
      </button>
      <button type="button" class="btn btn-outline hidden" id="cancelBtn" onclick="resetForm()">
        Cancel
      </button>
    </form>
  </div>
</div>

<script>
  document.addEventListener('DOMContentLoaded', function () {
    loadGuests();

    // Enter key support for search
    document.getElementById('searchInput').addEventListener('keypress', function (e) {
      if (e.key === 'Enter') searchGuests();
    });
  });

  function loadGuests(url) {
    var fetchUrl = url || '../guests';
    fetch(fetchUrl)
            .then(r => r.json())
            .then(data => {
              var tbody = document.getElementById('guestTableBody');
              tbody.innerHTML = '';

              if (data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;">No guests found</td></tr>';
                return;
              }

              data.forEach(function (g) {
                var row = '<tr>' +
                        '<td>' + g.name + '</td>' +
                        '<td>' + g.contactNo + '</td>' +
                        '<td>' + (g.email || 'N/A') + '</td>' +
                        '<td>' + g.address + '</td>' +
                        '<td>' +
                        '<div style="display:flex; gap:0.25rem;">' +
                        '<button class="action-btn btn-edit" onclick="editGuest(' +
                        g.guestID + ', \'' +
                        g.name + '\', \'' +
                        g.contactNo + '\', \'' +
                        (g.email || '').replace(/'/g, "\\'") + '\', \'' +
                        g.address.replace(/'/g, "\\'") +
                        '\')">Edit</button> ' +
                        '<button class="action-btn btn-delete" onclick="deleteGuest(' +
                        g.guestID + ', \'' + g.name +
                        '\')">Del</button>' +
                        '</div>' +
                        '</td>' +
                        '</tr>';

                tbody.insertAdjacentHTML('beforeend', row);
              });
            });
  }

  function searchGuests() {
    const query = document.getElementById('searchInput').value.trim();
    loadGuests('../guests?query=' + encodeURIComponent(query));
  }

  function resetSearch() {
    document.getElementById('searchInput').value = '';
    loadGuests();
  }

  function editGuest(id, name, contact, email, address) {
    var form = document.getElementById('guestForm');
    document.getElementById('formTitle').innerText = 'Edit Guest';

    form.elements['action'].value = 'update';
    form.guestId.value = id;
    form.name.value = name;
    form.contactNo.value = contact;
    form.email.value = email || '';
    form.address.value = address;

    document.getElementById('submitBtn').innerHTML = '<i class="fas fa-save"></i> Save Changes';
    document.getElementById('cancelBtn').classList.remove('hidden');
  }

  function resetForm() {
    var form = document.getElementById('guestForm');
    form.reset();
    form.elements['action'].value = 'add';

    document.getElementById('formTitle').innerText = 'Add New Guest';
    document.getElementById('submitBtn').innerHTML = '<i class="fas fa-user-plus"></i> Register Guest';
    document.getElementById('cancelBtn').classList.add('hidden');
  }

  function handleGuestSubmit(e) {
    e.preventDefault();
    var form = e.target;
    var params = new URLSearchParams(new FormData(form));

    fetch('../guests', { method: 'POST', body: params })
            .then(r => r.json())
            .then(data => {
              alert(data.message);
              if (data.status === 'success') {
                resetForm();
                loadGuests();
              }
            });
  }

  function deleteGuest(id, name) {
    if (!confirm('Delete guest ' + name + '?')) return;

    var params = new URLSearchParams();
    params.append('action', 'delete');
    params.append('guestId', id);

    fetch('../guests', { method: 'POST', body: params })
            .then(r => r.json())
            .then(data => {
              alert(data.message);
              if (data.status === 'success') loadGuests();
            });
  }
</script>

</body>

</html>