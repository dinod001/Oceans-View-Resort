<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.dinod.ocean_view_resort.model.Room" %>
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
    <title>Manage Rooms | Ocean View Resort</title>

    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Page-specific overrides for Standard Dashboard Look */
        .container {
            display: grid;
            grid-template-columns: 1.1fr 1fr;
            gap: 2.5rem;
            padding-top: 1rem;
        }

        .card {
            padding: 1.5rem !important;
            /* Standard padding */
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
        }

        .checkbox-container {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1.25rem;
            cursor: pointer;
        }

        .checkbox-container input {
            width: 1rem !important;
            height: 1rem !important;
            margin-bottom: 0 !important;
        }

        .badge-available {
            background: #dcfce7;
            color: #166534;
            padding: 0.25rem 0.75rem;
            border-radius: 99px;
            font-size: 0.8rem;
            font-weight: 700;
        }

        .badge-booked {
            background: #fee2e2;
            color: #991b1b;
            padding: 0.25rem 0.75rem;
            border-radius: 99px;
            font-size: 0.8rem;
            font-weight: 700;
        }

        /* Professional Left-Aligned Header (Matches Reservations) */
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

        .header-controls {
            display: flex;
            gap: 1rem;
            align-items: center;
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

        /* Professional Filter Bar - Perfect 3-Column Grid */
        .search-bar {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1.5rem;
            margin-bottom: 2.5rem;
            background: #f8fafc;
            padding: 1.75rem;
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            align-items: end;
            /* This makes buttons line up with inputs accurately */
        }

        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 0.6rem;
        }

        .filter-group label {
            font-size: 0.7rem;
            font-weight: 800;
            text-transform: uppercase;
            color: var(--text-light);
            letter-spacing: 0.05em;
            margin-bottom: 2px;
        }

        .search-bar input,
        .search-bar select {
            width: 100%;
            height: 42px;
            padding: 0 1rem;
            border: 1.5px solid var(--border);
            border-radius: var(--radius-md);
            background: white;
            font-size: 0.95rem;
            transition: all 0.2s;
            color: var(--text);
        }

        .filter-actions {
            display: flex;
            gap: 0.75rem;
            justify-content: flex-end;
            /* Align buttons to the right of the slot */
        }

        .search-bar .btn {
            width: 44px;
            /* Force square for alignment */
            height: 42px;
            padding: 0;
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            transition: all 0.2s;
        }

        /* Standard Table Spacing */
        table th,
        table td {
            padding: 0.85rem 1rem !important;
            font-size: 0.9rem;
        }

        /* Tablet/Mobile Breakpoints */
        @media (max-width: 1100px) {
            .container {
                grid-template-columns: 1fr !important;
                gap: 2.5rem;
            }
        }

        @media (max-width: 768px) {

            /* Mobile Header - Centered & Stacked (Matches Reservations) */
            header {
                flex-direction: column !important;
                text-align: center !important;
                padding: 2rem 1.5rem !important;
            }

            header h1 {
                font-size: 1.75rem !important;
            }

            .header-controls {
                flex-direction: column;
                width: 100%;
                gap: 0.75rem;
            }

            .back-link {
                width: 100%;
                justify-content: center;
            }

            /* Filter Bar - 2 columns on tablets */
            .search-bar {
                grid-template-columns: 1fr 1fr;
                gap: 1.25rem;
            }
        }

        @media (max-width: 500px) {
            .search-bar {
                grid-template-columns: 1fr;
                /* 1 column on mobile */
                gap: 1rem;
            }

            .filter-actions {
                justify-content: stretch;
                /* Full width buttons on mobile */
            }

            .search-bar .btn {
                flex: 1;
                /* Buttons take equal space */
            }
        }
    </style>
</head>

<body>

    <header>
        <h1>Room Management</h1>
        <div class="header-controls">
            <a href="./index.jsp" class="back-link">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
        </div>
    </header>

    <div class="container">

        <!-- ROOM LIST -->
        <div class="card table-responsive">
            <div
                style="display:flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                <h2>All Rooms</h2>
            </div>

            <!-- Search Bar (Grouped Filter Row) -->
            <div class="search-bar">
                <div class="filter-group">
                    <label>Room No</label>
                    <input type="text" id="searchRoomNo" placeholder="Search...">
                </div>
                <div class="filter-group">
                    <label>Type</label>
                    <select id="searchType">
                        <option value="">All Types</option>
                        <option value="Single">Single</option>
                        <option value="Double">Double</option>
                        <option value="Deluxe">Deluxe</option>
                        <option value="Suite">Suite</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Status</label>
                    <select id="searchStatus">
                        <option value="">All Status</option>
                        <option value="Available">Available</option>
                        <option value="Booked">Booked</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>Min Price</label>
                    <input type="number" id="searchMinPrice" placeholder="Min">
                </div>
                <div class="filter-group">
                    <label>Max Price</label>
                    <input type="number" id="searchMaxPrice" placeholder="Max">
                </div>
                <div class="filter-actions">
                    <button onclick="applyFilters()" class="btn btn-primary" title="Apply Filters">
                        <i class="fas fa-search"></i>
                    </button>
                    <button onclick="resetFilters()" class="btn btn-outline" title="Reset Filters">
                        <i class="fas fa-sync"></i>
                    </button>
                </div>
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
        <div class="card" style="align-self:start; position:sticky; top:2rem;">
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

                <button type="submit" id="submitBtn" class="btn btn-primary">
                    <i class="fas fa-plus"></i> Add Room
                </button>
                <button type="button" id="cancelBtn" class="btn btn-outline hidden"
                    onclick="resetForm()">
                    Cancel
                </button>
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
                        editBtn.className = 'action-btn btn-edit';
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
                        deleteBtn.className = 'action-btn btn-delete';
                        deleteBtn.textContent = 'Delete';
                        deleteBtn.onclick = function () { deleteRoom(id); };

                        const flexDiv = document.createElement('div');
                        flexDiv.style.display = 'flex';
                        flexDiv.style.gap = '0.25rem';
                        flexDiv.appendChild(editBtn);
                        flexDiv.appendChild(deleteBtn);
                        actionTd.appendChild(flexDiv);

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