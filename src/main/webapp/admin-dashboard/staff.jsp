<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="java.util.List" %>
        <%@ page import="com.dinod.ocean_view_resort.model.User" %>
            <% /* Session Check - Admin Only */ if (session.getAttribute("username")==null ||
                !"Admin".equalsIgnoreCase((String) session.getAttribute("role"))) {
                response.sendRedirect("../login.jsp"); return; } %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Staff Management | Ocean View Resort (Admin)</title>
                    <style>
                        :root {
                            --primary: #0f172a;
                            --primary-light: #1e293b;
                            --accent: #3b82f6;
                            --bg: #f8fafc;
                            --card-bg: #ffffff;
                            --text: #1e293b;
                            --text-light: #64748b;
                            --border: #e2e8f0;
                            --success: #10b981;
                            --danger: #ef4444;
                        }

                        * {
                            margin: 0;
                            padding: 0;
                            box-sizing: border-box;
                            font-family: 'Inter', system-ui, sans-serif;
                        }

                        body {
                            background-color: var(--bg);
                            color: var(--text);
                            line-height: 1.6;
                        }

                        .container {
                            max-width: 1200px;
                            margin: 2rem auto;
                            padding: 0 1rem;
                            display: grid;
                            grid-template-columns: 1.5fr 1fr;
                            gap: 2rem;
                        }

                        header {
                            background: var(--primary);
                            color: white;
                            padding: 1.5rem 2rem;
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
                        }

                        header h1 {
                            font-size: 1.5rem;
                            font-weight: 700;
                            letter-spacing: -0.025em;
                        }

                        .back-link {
                            color: #94a3b8;
                            text-decoration: none;
                            font-size: 0.9rem;
                            transition: color 0.2s;
                        }

                        .back-link:hover {
                            color: white;
                        }

                        .card {
                            background: var(--card-bg);
                            border-radius: 12px;
                            padding: 1.5rem;
                            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
                            border: 1px solid var(--border);
                        }

                        .card h2 {
                            font-size: 1.25rem;
                            margin-bottom: 1.25rem;
                            color: var(--primary);
                            border-bottom: 2px solid var(--bg);
                            padding-bottom: 0.5rem;
                        }

                        .form-group {
                            margin-bottom: 1.25rem;
                        }

                        label {
                            display: block;
                            font-size: 0.875rem;
                            font-weight: 600;
                            margin-bottom: 0.5rem;
                            color: var(--primary-light);
                        }

                        input,
                        select,
                        textarea {
                            width: 100%;
                            padding: 0.625rem;
                            border: 1.5px solid var(--border);
                            border-radius: 8px;
                            font-size: 0.95rem;
                            transition: all 0.2s;
                        }

                        input:focus {
                            outline: none;
                            border-color: var(--accent);
                            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
                        }

                        .btn-primary {
                            background: var(--accent);
                            color: white;
                            border: none;
                            padding: 0.75rem 1.5rem;
                            border-radius: 8px;
                            font-weight: 600;
                            cursor: pointer;
                            transition: all 0.2s;
                            width: 100%;
                        }

                        .btn-primary:hover {
                            background: #2563eb;
                            transform: translateY(-1px);
                        }

                        .btn-primary:disabled {
                            background: #94a3b8;
                            cursor: not-allowed;
                            transform: none;
                        }

                        .btn-cancel {
                            background: #f1f5f9;
                            color: var(--text);
                            border: none;
                            padding: 0.75rem;
                            border-radius: 8px;
                            font-weight: 500;
                            cursor: pointer;
                            margin-top: 0.5rem;
                            width: 100%;
                            display: block;
                            text-align: center;
                        }

                        .btn-cancel:hover {
                            background: #e2e8f0;
                        }

                        table {
                            width: 100%;
                            border-collapse: collapse;
                            margin-top: 1rem;
                        }

                        th {
                            text-align: left;
                            padding: 1rem;
                            background: #f8fafc;
                            color: var(--text-light);
                            font-size: 0.8rem;
                            text-transform: uppercase;
                            font-weight: 600;
                            border-bottom: 2px solid var(--border);
                        }

                        td {
                            padding: 1rem;
                            border-bottom: 1px solid var(--border);
                            font-size: 0.95rem;
                        }

                        .badge {
                            padding: 0.25rem 0.625rem;
                            border-radius: 9999px;
                            font-size: 0.75rem;
                            font-weight: 600;
                        }

                        .badge-admin {
                            background: #fee2e2;
                            color: #991b1b;
                        }

                        .badge-staff {
                            background: #dcfce7;
                            color: #166534;
                        }

                        .action-btn {
                            padding: 0.4rem 0.75rem;
                            border-radius: 6px;
                            border: 1px solid var(--border);
                            background: white;
                            cursor: pointer;
                            font-size: 0.8rem;
                            margin-right: 0.25rem;
                        }

                        .btn-edit:hover {
                            border-color: var(--accent);
                            color: var(--accent);
                        }

                        .btn-delete:hover {
                            border-color: var(--danger);
                            color: var(--danger);
                        }

                        .search-row {
                            display: flex;
                            gap: 0.75rem;
                            margin-bottom: 1.5rem;
                        }

                        .search-row input {
                            flex: 2;
                        }

                        .search-row select {
                            flex: 1;
                            max-width: 140px;
                        }

                        .btn-search {
                            background: var(--primary);
                            color: white;
                            border: none;
                            padding: 0 1.25rem;
                            border-radius: 8px;
                            cursor: pointer;
                        }

                        .hidden {
                            display: none;
                        }
                    </style>
                </head>

                <body>

                    <header>
                        <div>
                            <h1>Staff Management</h1>
                            <p style="color:#94a3b8; font-size: 0.85rem;">System User Directory & Controls</p>
                        </div>
                        <a href="index.jsp" class="back-link">← Dashboard</a>
                    </header>

                    <div class="container">
                        <!-- List Panel -->
                        <div class="card">
                            <h2>User Directory</h2>
                            <div class="search-row">
                                <input type="text" id="searchInput" placeholder="Search by name, email or contact...">
                                <select id="searchType">
                                    <option value="name">Name</option>
                                    <option value="email">Email</option>
                                    <option value="contact">Contact</option>
                                </select>
                                <button class="btn-search" onclick="searchStaff()">Search</button>
                                <button class="action-btn" onclick="refreshList()">Reset</button>
                            </div>

                            <div style="overflow-x: auto;">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>User Basics</th>
                                            <th>Role & Info</th>
                                            <th>Contact</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody id="staffTableBody">
                                        <tr>
                                            <td colspan="5"
                                                style="text-align:center; padding: 3rem; color: var(--text-light);">
                                                Initializing user list...
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Form Panel -->
                        <div class="card">
                            <h2 id="formTitle">Manage User</h2>
                            <form id="staffForm" onsubmit="handleStaffSubmit(event)">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="userId" id="userId">

                                <div class="form-group">
                                    <label>Username</label>
                                    <input type="text" name="username" id="usernameInput" required>
                                </div>

                                <div class="form-group">
                                    <label>Email Address</label>
                                    <input type="email" name="email" id="emailInput" required>
                                </div>

                                <div class="form-group" id="passwordGroup">
                                    <label>Access Password</label>
                                    <input type="password" name="password" id="passwordInput">
                                    <small style="color:var(--text-light); font-size: 0.75rem;">Only required for new
                                        users.</small>
                                </div>

                                <div class="form-group">
                                    <label>System Role</label>
                                    <select name="role" id="roleSelect" onchange="toggleDesignation()" required>
                                        <option value="Staff">Staff Member</option>
                                        <option value="Admin">Administrator</option>
                                    </select>
                                </div>

                                <div class="form-group" id="designationGroup">
                                    <label>Designation</label>
                                    <input type="text" name="designation" id="designationInput"
                                        placeholder="e.g. Receptionist">
                                </div>

                                <div class="form-group">
                                    <label>Contact Number</label>
                                    <input type="text" name="contactNo" id="contactInput">
                                </div>

                                <div class="form-group">
                                    <label>Mailing Address</label>
                                    <textarea name="address" id="addressInput" rows="2"></textarea>
                                </div>

                                <button class="btn-primary" type="submit" id="submitBtn">Register User</button>
                                <button type="button" class="btn-cancel hidden" id="cancelBtn"
                                    onclick="resetForm()">Cancel Edit</button>
                            </form>
                        </div>
                    </div>

                    <script>
                        let currentUsers = [];
                        document.addEventListener('DOMContentLoaded', () => refreshList());

                        function refreshList() {
                            const input = document.getElementById('searchInput');
                            if (input) input.value = '';
                            loadStaffData('../staff-mgmt');
                        }

                        function searchStaff() {
                            const query = document.getElementById('searchInput').value.trim();
                            const type = document.getElementById('searchType').value;
                            loadStaffData('../staff-mgmt?query=' + encodeURIComponent(query) + '&type=' + type);
                        }

                        function loadStaffData(url) {
                            const tbody = document.getElementById('staffTableBody');
                            fetch(url)
                                .then(r => {
                                    if (!r.ok) return r.text().then(t => { throw new Error(t || r.statusText) });
                                    return r.json();
                                })
                                .then(users => {
                                    currentUsers = users;
                                    tbody.innerHTML = '';
                                    if (!users || users.length === 0) {
                                        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding: 2rem;">No users found.</td></tr>';
                                        return;
                                    }
                                    users.forEach((u, i) => {
                                        const isS = (u.role || '').toLowerCase() === 'staff';
                                        let row = '<tr>' +
                                            '<td>#' + u.id + '</td>' +
                                            '<td>' +
                                            '<div style="font-weight:600;">' + (u.userName || 'N/A') + '</div>' +
                                            '<div style="font-size:0.8rem; color:var(--text-light);">' + (u.email || '') + '</div>' +
                                            '</td>' +
                                            '<td>' +
                                            '<span class="badge ' + (isS ? 'badge-staff' : 'badge-admin') + '">' + u.role + '</span>' +
                                            '<div style="font-size:0.8rem; margin-top:0.2rem;">' + (isS ? (u.designation || 'Staff') : 'Admin') + '</div>' +
                                            '</td>' +
                                            '<td>' +
                                            '<div>' + (u.contactNo || 'N/A') + '</div>' +
                                            '<div style="font-size:0.8rem; color:var(--text-light);">' + (u.address || '') + '</div>' +
                                            '</td>' +
                                            '<td>' +
                                            '<button class="action-btn btn-edit" onclick="handleEdit(' + i + ')">Edit</button>' +
                                            '<button class="action-btn btn-delete" onclick="deleteUser(' + u.id + ', \'' + (u.userName || '').replace(/'/g, "\\'") + '\')">Del</button>' +
                                            '</td>' +
                                            '</tr>';
                                        tbody.insertAdjacentHTML('beforeend', row);
                                    });
                                })
                                .catch(err => {
                                    console.error(err);
                                    tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding: 2rem; color:red;">Load failed: ${err.message}</td></tr>`;
                                });
                        }

                        function handleEdit(index) {
                            const u = currentUsers[index];
                            if (!u) return;
                            const form = document.getElementById('staffForm');
                            document.getElementById('formTitle').innerText = 'Editing: ' + u.userName;
                            form.elements['action'].value = 'update';
                            document.getElementById('userId').value = u.id;
                            document.getElementById('usernameInput').value = u.userName;
                            document.getElementById('usernameInput').disabled = true;
                            document.getElementById('emailInput').value = u.email;
                            document.getElementById('roleSelect').value = u.role;
                            document.getElementById('designationInput').value = u.designation || '';
                            document.getElementById('contactInput').value = u.contactNo || '';
                            document.getElementById('addressInput').value = u.address || '';
                            document.getElementById('passwordInput').required = false;
                            document.getElementById('submitBtn').innerText = 'Update User';
                            document.getElementById('cancelBtn').classList.remove('hidden');
                            toggleDesignation();
                        }

                        function resetForm() {
                            const form = document.getElementById('staffForm');
                            form.reset();
                            form.elements['action'].value = 'add';
                            document.getElementById('usernameInput').disabled = false;
                            document.getElementById('passwordInput').required = true;
                            document.getElementById('formTitle').innerText = 'Manage User';
                            document.getElementById('submitBtn').innerText = 'Register User';
                            document.getElementById('cancelBtn').classList.add('hidden');
                            toggleDesignation();
                        }

                        function handleStaffSubmit(e) {
                            e.preventDefault();
                            const btn = document.getElementById('submitBtn');
                            const userF = document.getElementById('usernameInput');
                            const wasD = userF.disabled;
                            if (wasD) userF.disabled = false;
                            const params = new URLSearchParams(new FormData(e.target));
                            if (wasD) userF.disabled = true;

                            btn.disabled = true;
                            fetch('../staff-mgmt', { method: 'POST', body: params })
                                .then(r => r.json())
                                .then(d => {
                                    alert(d.message);
                                    if (d.status === 'success') { resetForm(); refreshList(); }
                                })
                                .catch(err => alert("Error: " + err.message))
                                .finally(() => btn.disabled = false);
                        }

                        function deleteUser(id, name) {
                            if (!confirm(`Permanently delete user ${name}?`)) return;
                            const p = new URLSearchParams();
                            p.append('action', 'delete');
                            p.append('userId', id);
                            fetch('../staff-mgmt', { method: 'POST', body: p })
                                .then(r => r.json())
                                .then(d => { alert(d.message); if (d.status === 'success') refreshList(); })
                                .catch(err => alert("Error: " + err.message));
                        }

                        function toggleDesignation() {
                            const role = document.getElementById('roleSelect').value;
                            document.getElementById('designationGroup').style.display = (role === 'Staff') ? 'block' : 'none';
                        }
                    </script>
                </body>

                </html>