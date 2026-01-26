<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.dinod.ocean_view_resort.model.User" %>
<%
// Security: Prevent back button access
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

// Session check – Admin only
String username = (String) session.getAttribute("username");
String role = (String) session.getAttribute("role");

if (username == null || !"Admin".equalsIgnoreCase(role)) {
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
    <title>Staff Management | Ocean View Resort (Admin)</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Professional Left-Aligned Header (Matches Reservations & Rooms) */
        header {
            display: flex !important;
            flex-direction: row !important;
            justify-content: space-between !important;
            align-items: center !important;
            gap: 1.5rem !important;
            padding: 1.5rem 2rem !important;
            background: #0f172a !important;
            box-shadow: var(--shadow-md);
        }

        header h1 {
            margin: 0 !important;
            font-size: 1.5rem !important;
            font-weight: 700 !important;
            letter-spacing: -0.025em !important;
            color: white;
        }

        .back-link {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            text-decoration: none;
            color: rgba(255, 255, 255, 0.9);
            padding: 0.65rem 1.25rem;
            border-radius: var(--radius-md);
            border: 1px solid rgba(255, 255, 255, 0.2);
            font-weight: 600;
            background: rgba(255, 255, 255, 0.05);
            transition: all 0.2s;
        }

        .back-link:hover {
            background: rgba(255, 255, 255, 0.1);
            border-color: white;
            color: white;
            transform: translateY(-1px);
        }

        /* Page-specific overrides or additions */
        .password-container {
            position: relative;
        }

        .password-toggle {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: var(--text-light);
            transition: color 0.2s;
            z-index: 5;
        }

        .password-toggle:hover {
            color: var(--primary);
        }

        #passwordInput,
        #confirmPasswordInput {
            padding-right: 40px;
        }

        .error-msg {
            color: var(--danger);
            font-size: 0.75rem;
            margin-top: 0.25rem;
            display: none;
        }

        .search-row select {
            max-width: 140px;
        }

        /* Responsive Container Layout */
        .container {
            display: grid;
            grid-template-columns: 1.2fr 1fr;
            gap: 2rem;
            padding: 2rem;
            max-width: 1400px;
            margin: 0 auto;
        }

        /* Mobile Breakpoints */
        @media (max-width: 1100px) {

            /* Stack cards vertically on tablets */
            .container {
                grid-template-columns: 1fr !important;
                gap: 2rem;
            }
        }

        @media (max-width: 768px) {

            /* Mobile Header - Centered & Stacked */
            header {
                flex-direction: column !important;
                text-align: center !important;
                padding: 2rem 1.5rem !important;
            }

            header h1 {
                font-size: 1.75rem !important;
            }

            .back-link {
                width: 100%;
                justify-content: center;
            }

            /* Mobile Container - Reduce padding */
            .container {
                padding: 1rem;
                gap: 1.5rem;
            }

            /* Mobile Table - Horizontal scroll */
            .card {
                overflow-x: auto;
            }
        }
    </style>
</head>

<body>

    <header>
        <h1>Staff Management</h1>
        <a href="./index.jsp" class="back-link">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
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
                <button class="btn btn-primary" onclick="searchStaff()">
                    <i class="fas fa-search"></i>
                </button>
                <button class="btn btn-outline" onclick="refreshList()">
                    <i class="fas fa-sync"></i>
                </button>
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
                    <div class="password-container">
                        <input type="password" name="password" id="passwordInput">
                        <i class="fas fa-eye password-toggle"
                            onclick="togglePassword('passwordInput', this)"></i>
                    </div>
                    <small id="passwordHint"
                        style="color:var(--text-light); font-size: 0.75rem; display: block; line-height: 1.3; margin-top: 0.25rem;">
                        Min 8 chars, include an uppercase letter, a number, and a special character
                        (@$!%*?&).
                    </small>
                </div>

                <div class="form-group" id="confirmPasswordGroup">
                    <label>Confirm Password</label>
                    <div class="password-container">
                        <input type="password" id="confirmPasswordInput">
                        <i class="fas fa-eye password-toggle"
                            onclick="togglePassword('confirmPasswordInput', this)"></i>
                    </div>
                    <small id="matchError" class="error-msg">Passwords do not match!</small>
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
                    <select name="designation" id="designationInput">
                        <option value="Receptionist">Receptionist</option>
                        <option value="General Staff">General Staff</option>
                        <option value="Manager">Hotel Manager</option>
                        <option value="Housekeeping">Housekeeping</option>
                        <option value="Chef">Chef / Kitchen Staff</option>
                        <option value="Security">Security</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Contact Number</label>
                    <input type="text" name="contactNo" id="contactInput">
                </div>

                <div class="form-group">
                    <label>Mailing Address</label>
                    <textarea name="address" id="addressInput" rows="2"></textarea>
                </div>

                <button class="btn btn-primary" type="submit" id="submitBtn">
                    <i class="fas fa-user-plus"></i> Register User
                </button>
                <button type="button" class="btn btn-outline hidden" id="cancelBtn"
                    onclick="resetForm()">Cancel</button>
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
                            '<div style="display:flex; gap:0.25rem;">' +
                            '<button class="action-btn btn-edit" onclick="handleEdit(' + i + ')">Edit</button>' +
                            '<button class="action-btn btn-delete" onclick="deleteUser(' + u.id + ', \'' + (u.userName || '').replace(/'/g, "\\'") + '\')">Del</button>' +
                            '</div>' +
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

            // Handle Designation Dropdown
            const desigSelect = document.getElementById('designationInput');
            desigSelect.value = u.designation || 'General Staff';

            document.getElementById('contactInput').value = u.contactNo || '';
            document.getElementById('addressInput').value = u.address || '';
            document.getElementById('passwordInput').value = '';
            document.getElementById('confirmPasswordInput').value = '';
            document.getElementById('passwordInput').required = false;
            document.getElementById('confirmPasswordInput').required = false;
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
            document.getElementById('confirmPasswordInput').required = true;
            document.getElementById('formTitle').innerText = 'Manage User';
            document.getElementById('submitBtn').innerText = 'Register User';
            document.getElementById('cancelBtn').classList.add('hidden');
            document.getElementById('matchError').style.display = 'none';
            toggleDesignation();
        }

        function handleStaffSubmit(e) {
            e.preventDefault();
            const form = e.target;
            const btn = document.getElementById('submitBtn');
            const userF = document.getElementById('usernameInput');
            const passInput = document.getElementById('passwordInput');
            const confirmInput = document.getElementById('confirmPasswordInput');
            const action = form.elements['action'].value;
            const matchError = document.getElementById('matchError');

            matchError.style.display = 'none';

            // Client-side Password Validation
            if (action === 'add' || (action === 'update' && passInput.value.trim() !== "")) {
                const pass = passInput.value;
                const confirmPass = confirmInput.value;

                // Policy check
                const regex = /^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
                if (!regex.test(pass)) {
                    alert("Password must be at least 8 characters, with 1 uppercase, 1 number, and 1 special char (@$!%*?&).");
                    return;
                }

                // Matching check
                if (pass !== confirmPass) {
                    matchError.style.display = 'block';
                    confirmInput.focus();
                    return;
                }
            }

            const wasD = userF.disabled;
            if (wasD) userF.disabled = false;
            const params = new URLSearchParams(new FormData(form));
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

        function togglePassword(inputId, icon) {
            const input = document.getElementById(inputId);
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }
    </script>
</body>

</html>