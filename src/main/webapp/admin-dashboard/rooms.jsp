<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.dinod.ocean_view_resort.model.Room" %>

<%
// Security: Prevent back button access
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

// Session Check - Admin Only
String username = (String) session.getAttribute("username");
String role = (String) session.getAttribute("role");

if (username == null || !"Admin".equalsIgnoreCase(role)) {
response.sendRedirect("../login.jsp");
return; // Stop executing the rest of the page
}
%>



<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
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
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
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
            border-bottom: 2px solid #e5e7eb;
            padding-bottom: 0.5rem;
        }

        header {
            margin-bottom: 2rem;
        }

        label {
            display: block;
            margin-bottom: 0.4rem;
            font-weight: 600;
            color: #4b5563;
        }

        input,
        select {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            margin-bottom: 1rem;
            font-size: 0.95rem;
        }

        input:focus,
        select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(0, 105, 148, 0.1);
        }

        button {
            width: 100%;
            padding: 0.75rem;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }

        #submitBtn {
            background: var(--primary);
            color: white;
            margin-top: 0.5rem;
        }

        #submitBtn:hover {
            background: var(--primary-dark);
        }

        #cancelBtn {
            background: transparent;
            color: #6b7280;
            border: 1px solid #d1d5db;
            margin-top: 0.5rem;
        }

        #cancelBtn:hover {
            background: #f3f4f6;
        }

        table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
        }

        /* Fix checkbox alignment */
        .checkbox-container {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1rem;
            cursor: pointer;
        }

        /* Remove default block display from checkbox input so it fits in flex */
        .checkbox-container input {
            width: auto;
            margin-bottom: 0;
        }

        /* Ensure table text is visible */
        th,
        td {
            padding: 1rem;
            border-bottom: 1px solid #e5e7eb;
            text-align: left;
            color: #374151;
            /* Dark gray for visibility */
        }

        th {
            background: #f9fafb;
            font-weight: 600;
            color: #111827;
            /* Darker for headers */
        }

        /* ... existing styles ... */
        tr:hover {
            background: #f9fafb;
        }

        .badge-available,
        .badge-booked {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 999px;
            font-size: 0.85rem;
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

        .btn-edit,
        .btn-delete {
            width: auto;
            padding: 0.4rem 0.8rem;
            font-size: 0.85rem;
            margin-right: 0.25rem;
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

        .hidden {
            display: none;
        }

        .search-row {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr 0.8fr 0.8fr auto auto;
            gap: 0.75rem;
            margin-bottom: 1.5rem;
            align-items: end;
        }

        .search-row label {
            font-size: 0.75rem;
            text-transform: uppercase;
            color: #6b7280;
            margin-bottom: 0.25rem;
        }

        .search-row input,
        .search-row select {
            margin-bottom: 0;
            padding: 0.6rem;
        }

        @media(max-width: 900px) {
            .container {
                grid-template-columns: 1fr;
            }

            .search-row {
                grid-template-columns: 1fr 1fr;
            }

            .btn-search,
            .btn-reset {
                grid-column: span 1;
            }
        }

        .btn-search {
            background: var(--primary);
            color: white;
            width: auto;
            padding: 0.6rem 1.5rem;
        }

        .btn-search:hover {
            background: var(--primary-dark);
        }

        .btn-reset {
            background: transparent;
            color: #6b7280;
            border: 1px solid #d1d5db;
            width: auto;
            padding: 0.6rem 1.5rem;
        }

        .btn-reset:hover {
            background: #f3f4f6;
        }
    </style>
</head>

<body>

    <header>
        <h1>Room Management</h1>
        <p>Add, edit and manage resort rooms</p>
    </header>

    <div class="container">

        <!-- ROOM LIST -->
        <div class="card">
            <div
                style="display:flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                <h2>All Rooms</h2>
            </div>

            <div class="search-row">
                <div>
                    <label>Room No</label>
                    <input type="text" id="searchRoomNo" placeholder="No...">
                </div>
                <div>
                    <label>Type</label>
                    <select id="searchType">
                        <option value="All">All Types</option>
                        <option value="Single">Single</option>
                        <option value="Double">Double</option>
                        <option value="Suite">Suite</option>
                        <option value="Deluxe">Deluxe</option>
                    </select>
                </div>
                <div>
                    <label>Status</label>
                    <select id="searchStatus">
                        <option value="All">All Status</option>
                        <option value="Available">Available</option>
                        <option value="Booked">Booked</option>
                    </select>
                </div>
                <div>
                    <label>Min Price</label>
                    <input type="number" id="searchMinPrice" placeholder="Min">
                </div>
                <div>
                    <label>Max Price</label>
                    <input type="number" id="searchMaxPrice" placeholder="Max">
                </div>
                <button class="btn-search" onclick="applyFilters()">Search</button>
                <button class="btn-reset" onclick="resetFilters()">Reset</button>
            </div>

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
                <tbody id="roomTableBody">
                    <tr>
                        <td colspan="5">Loading...</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- FORM -->
        <div class="card">
            <h2 id="formTitle">Add New Room</h2>

            <form id="roomForm" onsubmit="handleRoomSubmit(event)">
                <input type="hidden" id="formAction" name="action" value="add">
                <input type="hidden" id="roomNo" name="roomNo">

                <label>Room Number</label>
                <input type="text" id="roomNoDisplay" disabled value="Auto Generated">

                <label>Room Type</label>
                <select id="roomType" name="roomType">
                    <option value="Single">Single Room</option>
                    <option value="Double">Double Room</option>
                    <option value="Suite">Luxury Suite</option>
                    <option value="Deluxe">Deluxe Room</option>
                </select>

                <label>Price</label>
                <input type="number" id="pricePerNight" name="pricePerNight" step="0.01" required>

                <div class="checkbox-container">
                    <input type="checkbox" id="isAvailable" name="isAvailable" value="true" checked>
                    <label for="isAvailable" style="margin-bottom:0;">Available</label>
                </div>

                <div id="form-msg" class="hidden"></div>

                <button type="submit" id="submitBtn">Create Room</button>
                <button type="button" id="cancelBtn" class="hidden"
                    onclick="resetForm()">Cancel</button>
            </form>
        </div>

    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            loadRooms();

            // Enter key support for search
            const searchInputs = ['searchRoomNo', 'searchMinPrice', 'searchMaxPrice'];
            searchInputs.forEach(id => {
                document.getElementById(id).addEventListener('keypress', function (e) {
                    if (e.key === 'Enter') applyFilters();
                });
            });
        });

        function loadRooms(url) {
            console.log("Loading rooms...");
            var fetchUrl = url || '../rooms';
            fetch(fetchUrl)
                .then(res => {
                    if (!res.ok) throw new Error("Network response was not ok");
                    return res.json();
                })
                .then(data => {
                    console.log("Received Data:", data);

                    const tbody = document.getElementById('roomTableBody');
                    tbody.innerHTML = '';

                    if (!data || data.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;">No rooms found.</td></tr>';
                        return;
                    }

                    data.forEach(r => {
                        const id = r.roomNo || r.id || 0;
                        const type = r.roomType || "Unknown";
                        const price = r.pricePerNight ? parseFloat(r.pricePerNight).toFixed(2) : "0.00";
                        const isAvail = r.isAvailable === true || r.isAvailable === "true";

                        const tr = document.createElement('tr');

                        const badgeClass = isAvail ? 'badge-available' : 'badge-booked';
                        const badgeText = isAvail ? 'Available' : 'Booked';

                        tr.innerHTML = `
                        <td style="font-weight:600">#\${id}</td>
                        <td>\${type}</td>
                        <td>$\${price}</td>
                        <td><span class="\${badgeClass}">\${badgeText}</span></td>
                        <td></td>
                    `;

                        // Action Cell
                        const actionTd = tr.lastElementChild;

                        // Edit Button
                        const editBtn = document.createElement('button');
                        editBtn.className = 'btn-edit';
                        editBtn.textContent = 'Edit';
                        editBtn.dataset.room = JSON.stringify(r);
                        editBtn.onclick = function () {
                            try {
                                const roomData = JSON.parse(this.dataset.room);
                                editRoom(roomData);
                            } catch (e) { console.error("Error parsing room data", e); }
                        };

                        // Delete Button
                        const deleteBtn = document.createElement('button');
                        deleteBtn.className = 'btn-delete';
                        deleteBtn.textContent = 'Delete';
                        deleteBtn.onclick = function () { deleteRoom(id); };

                        actionTd.appendChild(editBtn);
                        actionTd.appendChild(deleteBtn);

                        tbody.appendChild(tr);
                    });
                })
                .catch(err => {
                    console.error("Fetch Error:", err);
                    document.getElementById('roomTableBody').innerHTML = '<tr><td colspan="5" style="color:red; text-align:center;">Error loading data. See Console.</td></tr>';
                });
        }

        function applyFilters() {
            const roomNo = document.getElementById('searchRoomNo').value.trim();
            const type = document.getElementById('searchType').value;
            const status = document.getElementById('searchStatus').value;
            const minPrice = document.getElementById('searchMinPrice').value;
            const maxPrice = document.getElementById('searchMaxPrice').value;

            const params = new URLSearchParams();
            if (roomNo) params.append('roomNo', roomNo);
            if (type !== 'All') params.append('type', type);
            if (status !== 'All') params.append('status', status);
            if (minPrice) params.append('minPrice', minPrice);
            if (maxPrice) params.append('maxPrice', maxPrice);

            loadRooms('../rooms?' + params.toString());
        }

        function resetFilters() {
            document.getElementById('searchRoomNo').value = '';
            document.getElementById('searchType').value = 'All';
            document.getElementById('searchStatus').value = 'All';
            document.getElementById('searchMinPrice').value = '';
            document.getElementById('searchMaxPrice').value = '';
            loadRooms();
        }

        function editRoom(room) {
            // Extract values safely from object
            const roomNo = room.roomNo || room.id;
            const type = room.roomType;
            const price = room.pricePerNight;
            const available = room.isAvailable;

            document.getElementById('formTitle').innerText = 'Edit Room';
            document.getElementById('formAction').value = 'update';
            document.getElementById('roomNo').value = roomNo;
            document.getElementById('roomNoDisplay').value = roomNo;

            const select = document.getElementById('roomType');
            for (let i = 0; i < select.options.length; i++) {
                if (select.options[i].value === type) {
                    select.selectedIndex = i;
                    break;
                }
            }

            document.getElementById('pricePerNight').value = price;
            document.getElementById('isAvailable').checked = (available === true || available === "true");

            document.getElementById('submitBtn').innerText = 'Save Changes';
            document.getElementById('cancelBtn').classList.remove('hidden');

            // Scroll to form
            const card = document.querySelector('.card');
            if (card) card.scrollIntoView({ behavior: 'smooth' });
        }

        function resetForm() {
            document.getElementById('roomForm').reset();
            document.getElementById('formAction').value = 'add';
            document.getElementById('roomNoDisplay').value = 'Auto Generated';
            document.getElementById('submitBtn').innerText = 'Create Room';
            document.getElementById('cancelBtn').classList.add('hidden');
        }

        function handleRoomSubmit(e) {
            e.preventDefault();
            const form = e.target;
            const formData = new URLSearchParams(new FormData(form));

            console.log("Submitting:", formData.toString());

            fetch('../rooms', {
                method: 'POST',
                body: formData
            })
                .then(res => res.json())
                .then(data => {
                    if (data.status === 'success') {
                        alert(data.message);
                        resetForm();
                        loadRooms();
                    } else {
                        alert("Error: " + data.message);
                    }
                })
                .catch(err => {
                    console.error(err);
                    alert("Connection Error");
                });
        }

        function deleteRoom(no) {
            if (!confirm('Delete room ' + no + '?')) return;

            fetch('../rooms', {
                method: 'POST',
                body: new URLSearchParams({ action: 'delete', roomNo: no })
            }).then(() => loadRooms());
        }
    </script>

</body>

</html>