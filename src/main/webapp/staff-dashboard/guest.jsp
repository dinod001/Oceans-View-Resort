<%@ page contentType="text/html;charset=UTF-8" language="java" %>
  <%@ page import="java.util.List" %>
    <%@ page import="com.dinod.ocean_view_resort.model.Guest" %>

      <% // Session Check - Staff Only
        if (session.getAttribute("username")==null || !"Staff".equalsIgnoreCase((String)
        session.getAttribute("role"))) { response.sendRedirect("../login.jsp"); return; } String successMsg=(String)
        session.getAttribute("successMessage"); if (successMsg !=null) { request.setAttribute("successMessage",
        successMsg); session.removeAttribute("successMessage"); } %>

        <!DOCTYPE html>
        <html lang="en">

        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Manage Guests | Ocean View Resort (Staff)</title>

          <style>
            /* ===== ORIGINAL CSS (UNCHANGED) ===== */
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

            .hidden {
              display: none;
            }

            .container {
              max-width: 1200px;
              margin: 0 auto;
              display: grid;
              gap: 2rem;
              grid-template-columns: 2fr 1fr;
            }

            @media(max-width:900px) {
              .container {
                grid-template-columns: 1fr;
              }
            }

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
            }

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
            textarea {
              width: 100%;
              padding: 0.75rem;
              border: 1px solid #d1d5db;
              border-radius: 8px;
              font-size: 0.95rem;
            }

            input:focus,
            textarea:focus {
              outline: none;
              border-color: var(--primary);
              box-shadow: 0 0 0 3px rgba(0, 105, 148, 0.1);
            }

            button {
              width: 100%;
              padding: 0.875rem;
              border: none;
              border-radius: 8px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.2s;
            }

            .btn-primary {
              background: var(--primary);
              color: white;
              margin-top: 1rem;
            }

            .btn-primary:hover {
              background: var(--primary-dark);
              transform: translateY(-1px);
              box-shadow: 0 4px 12px rgba(0, 105, 148, 0.3);
            }

            .btn-cancel {
              background: transparent;
              color: #6b7280;
              border: 1px solid #d1d5db;
              margin-top: 0.5rem;
            }

            .btn-cancel:hover {
              background: #f3f4f6;
            }

            .action-btn {
              padding: 0.5rem 1rem;
              border-radius: 6px;
              font-size: 0.85rem;
              font-weight: 600;
              border: none;
              cursor: pointer;
              display: inline-block;
              margin-right: 0.5rem;
              transition: all 0.2s;
              text-decoration: none;
            }

            .btn-edit {
              background: #eff6ff;
              color: var(--primary);
              border: 1px solid #bfdbfe;
            }

            .btn-edit:hover {
              background: #dbeafe;
              transform: translateY(-1px);
              box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
            }

            .btn-delete {
              background: #fef2f2;
              color: var(--danger);
              border: 1px solid #fecaca;
            }

            .btn-delete:hover {
              background: #fee2e2;
              transform: translateY(-1px);
              box-shadow: 0 2px 8px rgba(220, 38, 38, 0.3);
            }

            table {
              width: 100%;
              border-collapse: separate;
              border-spacing: 0;
            }

            th,
            td {
              padding: 1rem;
              border-bottom: 1px solid #e5e7eb;
              text-align: left;
              color: #374151;
            }

            th {
              background: #f9fafb;
              font-size: 0.9rem;
              text-transform: uppercase;
              font-weight: 600;
              color: #4b5563;
            }

            tr:hover {
              background-color: #f9fafb;
            }

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
              border: 1px solid #6ee7b7;
            }

            .alert-error {
              background: #fee2e2;
              color: #991b1b;
              border: 1px solid #fca5a5;
            }
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

          <div class="container">

            <!-- Guest List -->
            <div class="card">
              <h2>All Guests</h2>

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
                  <label>Address</label>
                  <textarea name="address" rows="3"></textarea>
                </div>

                <div id="form-msg" class="alert hidden"></div>

                <button class="btn-primary" id="submitBtn">Register Guest</button>
                <button type="button" class="btn-cancel hidden" id="cancelBtn" onclick="resetForm()">Cancel
                  Edit</button>
              </form>
            </div>

          </div>

          <script>
            document.addEventListener('DOMContentLoaded', loadGuests);

            function loadGuests() {
              fetch('../guests')
                .then(r => r.json())
                .then(data => {
                  var tbody = document.getElementById('guestTableBody');
                  tbody.innerHTML = '';

                  if (data.length === 0) {
                    tbody.innerHTML =
                      '<tr><td colspan="5" style="text-align:center;">No guests found</td></tr>';
                    return;
                  }

                  data.forEach(function (g) {
                    var row =
                      '<tr>' +
                      '<td>#' + g.guestID + '</td>' +
                      '<td>' + g.name + '</td>' +
                      '<td>' + g.contactNo + '</td>' +
                      '<td>' + g.address + '</td>' +
                      '<td>' +
                      '<button class="action-btn btn-edit" onclick="editGuest(' +
                      g.guestID + ', \'' +
                      g.name + '\', \'' +
                      g.contactNo + '\', \'' +
                      g.address.replace(/'/g, "\\'") +
                      '\')">Edit</button> ' +
                      '<button class="action-btn btn-delete" onclick="deleteGuest(' +
                      g.guestID + ', \'' + g.name +
                      '\')">Delete</button>' +
                      '</td>' +
                      '</tr>';

                    tbody.insertAdjacentHTML('beforeend', row);
                  });
                });
            }

            function editGuest(id, name, contact, address) {
              var form = document.getElementById('guestForm');
              document.getElementById('formTitle').innerText = 'Edit Guest';

              form.elements['action'].value = 'update';
              form.guestId.value = id;
              form.name.value = name;
              form.contactNo.value = contact;
              form.address.value = address;

              document.getElementById('submitBtn').innerText = 'Save Changes';
              document.getElementById('cancelBtn').classList.remove('hidden');
            }

            function resetForm() {
              var form = document.getElementById('guestForm');
              form.reset();
              form.elements['action'].value = 'add';

              document.getElementById('formTitle').innerText = 'Add New Guest';
              document.getElementById('submitBtn').innerText = 'Register Guest';
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