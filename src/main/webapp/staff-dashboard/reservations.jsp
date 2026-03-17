<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<%
// Security: Prevent back button access
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

// Session check – Staff only
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
    <title>Manage Reservations | Staff Dashboard</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Page-specific overrides */
        .container {
            grid-template-columns: 1.5fr 1fr;
            gap: 2.5rem;
        }

        .header-controls {
            display: flex;
            gap: 1rem;
            align-items: center;
        }

        @media (max-width: 900px) {
            .container {
                grid-template-columns: 1fr !important;
                /* Force stack on mobile */
            }

            .header-controls {
                flex-direction: column;
                width: 100%;
            }

            .btn-check-avail-header,
            .back-link {
                width: 100%;
                justify-content: center;
            }
        }

        .search-bar {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 2rem;
        }

        .search-bar input {
            flex: 1;
            height: 42px;
        }

        .search-bar .btn {
            width: 42px;
            height: 42px;
            padding: 0;
            flex-shrink: 0;
            border-radius: var(--radius-md);
        }

        /* MODAL STYLES (Refined) */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(8px);
        }

        .modal-content {
            background-color: var(--card-bg);
            margin: 5% auto;
            padding: 2.5rem;
            border-radius: var(--radius-lg);
            width: 95%;
            max-width: 1000px;
            max-height: 85vh;
            overflow-y: auto;
            box-shadow: var(--shadow-xl);
            position: relative;
            border: 1px solid var(--border);
        }

        .close-modal {
            position: absolute;
            right: 1.5rem;
            top: 1rem;
            font-size: 1.5rem;
            cursor: pointer;
            color: var(--text-light);
            transition: color 0.2s;
        }

        .close-modal:hover {
            color: var(--danger);
        }

        .modal-search-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
            background: rgba(0, 0, 0, 0.02);
            padding: 1.5rem;
            border-radius: var(--radius-md);
            align-items: end;
            border: 1px solid var(--border-light);
        }

        .modal-search-row label {
            display: block;
            margin-bottom: 0.5rem;
            font-size: 0.8rem;
            font-weight: 700;
            color: var(--text-light);
            text-transform: uppercase;
        }

        .modal-search-row input,
        .modal-search-row select {
            height: 42px;
            background: white;
            border: 1.5px solid var(--border);
        }

        .btn-modal-search {
            height: 42px;
            background: var(--accent);
            color: white;
            border: none;
            border-radius: var(--radius-md);
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s;
            padding: 0 1.5rem;
        }

        .btn-modal-search:hover {
            background: var(--accent-dark);
            transform: translateY(-1px);
        }

        .btn-modal-reset {
            height: 42px;
            background: transparent;
            color: var(--text-light);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            padding: 0 1.25rem;
        }

        .btn-modal-reset:hover {
            background: var(--bg);
            color: var(--text);
        }

        /* Result Table Refinement */
        .results-table {
            width: 100%;
            border-collapse: collapse;
        }

        .results-table th {
            text-align: left;
            padding: 0.875rem 1rem;
            background: #f8fafc;
            color: var(--text-light);
            font-size: 0.75rem;
            text-transform: uppercase;
            font-weight: 700;
            border-bottom: 2px solid var(--border);
        }

        .results-table td {
            padding: 1rem;
            border-bottom: 1px solid var(--border-light);
            font-size: 0.95rem;
            color: var(--text);
        }

        .btn-select-room {
            background: #eff6ff;
            color: var(--accent);
            border: 1px solid #bfdbfe;
            padding: 0.5rem 1rem;
            border-radius: var(--radius-sm);
            font-size: 0.8rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-select-room:hover {
            background: var(--accent);
            color: white;
            border-color: var(--accent);
        }

        .badge-available {
            display: inline-block;
            background: #ecfdf5;
            color: #059669;
            padding: 0.25rem 0.75rem;
            border-radius: 99px;
            font-size: 0.75rem;
            font-weight: 700;
            border: 1px solid #d1fae5;
        }

        .badge-booked {
            display: inline-block;
            background: #fef2f2;
            color: #dc2626;
            padding: 0.25rem 0.75rem;
            border-radius: 99px;
            font-size: 0.75rem;
            font-weight: 700;
            border: 1px solid #fecaca;
        }

        .btn-check-avail-header {
            background: transparent;
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.3);
            padding: 0.6rem 1.2rem;
            border-radius: var(--radius-md);
            font-weight: 600;
            font-size: 0.85rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.2s;
        }

        .btn-check-avail-header:hover {
            background: rgba(255, 255, 255, 0.1);
            border-color: white;
        }
    </style>
</head>

<body>

    <header>
        <h1>Reservations</h1>
        <div class="header-controls">
            <button type="button" class="btn-check-avail-header" onclick="openRoomPicker()">
                <i class="fas fa-search"></i> Check Availability
            </button>
            <a href="index.jsp" class="back-link">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
        </div>
    </header>

    <div class="container">

        <!-- RESERVATIONS LIST -->
        <div class="card table-responsive">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
                <h2>All Reservations</h2>
            </div>

            <div class="search-bar">
                <input type="text" id="searchInput" placeholder="Search by Guest Contact No...">
                <button class="btn btn-primary" onclick="searchReservations()" title="Search">
                    <i class="fas fa-search"></i>
                </button>
                <button class="btn btn-outline" onclick="loadReservations()" title="Reset">
                    <i class="fas fa-sync"></i>
                </button>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Res. ID</th>
                        <th>Guest</th>
                        <th>Status</th>
                        <th>Room</th>
                        <th>Rate</th>
                        <th>Dates</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="resTableBody">
                    <tr>
                        <td colspan="7" style="text-align:center;">Loading...</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- BOOKING FORM -->
        <div class="card" style="align-self:start; position:sticky; top:2rem;">
            <h2 id="formTitle">New Booking</h2>

            <form id="resForm" onsubmit="handleResSubmit(event)">
                <input type="hidden" id="formAction" name="action" value="add">
                <input type="hidden" id="reservationNo" name="reservationNo" value="">
                <!-- Store guest ID if editing -->
                <input type="hidden" id="guestId" name="guestId" value="">

                <h3>1. Guest Details</h3>
                <div class="form-group">
                    <label>Contact Number (Required)</label>
                    <input type="text" id="guestContact" name="guestContact" required>
                </div>
                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" id="guestName" name="guestName" required>
                </div>
                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" id="guestEmail" name="guestEmail" placeholder="guest@example.com">
                </div>
                <div class="form-group">
                    <label>Address</label>
                    <input type="text" id="guestAddress" name="guestAddress">
                </div>

                <h3>2. Room & Dates</h3>
                <div class="form-group">
                    <label>Select Room</label>
                    <select id="roomNo" name="roomNo" required>
                        <option value="" disabled selected>Loading Rooms...</option>
                    </select>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Check-in</label>
                        <input type="date" id="checkInDate" name="checkInDate" required>
                    </div>
                    <div class="form-group">
                        <label>Check-out</label>
                        <input type="date" id="checkOutDate" name="checkOutDate" required>
                    </div>
                </div>

                <button type="submit" id="submitBtn" class="btn btn-primary">
                    <i class="fas fa-check-circle"></i> Confirm Booking
                </button>
                <button type="button" id="cancelBtn" class="btn btn-outline hidden" onclick="resetForm()">
                    Cancel
                </button>
            </form>
        </div>
    </div>

    <script>
        let isInitialLoad = true;
        let reloadTimeout = null;

        document.addEventListener('DOMContentLoaded', () => {
            loadReservations();
            loadRooms();
            isInitialLoad = false;
        });

        // Debounced reload function to prevent rapid-fire requests
        function scheduleReload() {
            if (reloadTimeout) {
                clearTimeout(reloadTimeout);
            }
            reloadTimeout = setTimeout(() => {
                console.log("Reloading data after navigation");
                loadRooms();
                loadReservations();
            }, 300); // 300ms debounce
        }

        // Detect when page becomes visible (handles back button navigation)
        document.addEventListener('visibilitychange', () => {
            if (!document.hidden && !isInitialLoad) {
                scheduleReload();
            }
        });

        // Backup: Also handle pageshow event (for bfcache)
        window.addEventListener('pageshow', (event) => {
            if (event.persisted && !isInitialLoad) {
                scheduleReload();
            }
        });

        // Load Rooms for Dropdown
        function loadRooms() {
            fetch('../rooms?t=' + new Date().getTime())
                .then(res => res.json())
                .then(rooms => {
                    const select = document.getElementById('roomNo');
                    select.innerHTML = '<option value="" disabled selected>-- Choose Available Room --</option>';

                    rooms.forEach(r => {
                        const rNo = r.roomNo || r.id;
                        const rType = r.roomType;
                        const rPrice = r.pricePerNight;
                        const isAvail = r.isAvailable === true || r.isAvailable === "true";

                        const option = document.createElement('option');
                        option.value = rNo;
                        option.textContent = 'Room ' + rNo + ' - ' + rType + ' (Rs.' + parseFloat(rPrice).toFixed(2) + ') ' + (isAvail ? '' : '(Booked)');

                        if (!isAvail) {
                            option.style.color = '#ccc';
                        }

                        select.appendChild(option);
                    });
                })
                .catch(err => console.error("Error loading rooms:", err));
        }

        // Load Reservations List
        function loadReservations(query = '') {
            let url = '../reservations?t=' + new Date().getTime(); // Anti-cache
            if (query) {
                url += '&searchContact=' + encodeURIComponent(query);
            }

            fetch(url)
                .then(res => res.json())
                .then(data => {
                    const tbody = document.getElementById('resTableBody');
                    tbody.innerHTML = '';

                    if (!data || data.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; padding:2rem; color:#6b7280;">No reservations found.</td></tr>';
                        return;
                    }

                    data.forEach(r => {
                        const tr = document.createElement('tr');

                        const checkIn = new Date(r.checkInDate).toLocaleDateString();
                        const checkOut = new Date(r.checkOutDate).toLocaleDateString();
                        const status = r.status || 'PENDING';

                        let billBtn = '';
                        if (status === 'PAID') {
                            billBtn = '<button class="action-btn btn-bill" onclick="viewBill(' + r.reservationNo + ')">View Bill</button>';
                        } else if (status === 'CANCELLED') {
                            billBtn = '';
                        } else {
                            billBtn = '<button class="action-btn btn-bill" onclick="generateBill(' + r.reservationNo + ')">Bill</button>';
                        }

                        const isPaid = status === 'PAID';
                        const statusOptions =
                            '<select onchange="updateStatus(' + r.reservationNo + ', this.value, \'' + status + '\')" style="padding:0.2rem; font-size:0.85rem; border-radius:4px; ' + getStatusColor(status) + '">' +
                            '<option value="PENDING" ' + (status === 'PENDING' ? 'selected' : '') + '>PENDING</option>' +
                            '<option value="PAID" ' + (status === 'PAID' ? 'selected' : '') + ' ' + (!isPaid ? 'disabled' : '') + '>PAID</option>' +
                            '<option value="CANCELLED" ' + (status === 'CANCELLED' ? 'selected' : '') + '>CANCELLED</option>' +
                            '</select>';

                        tr.innerHTML =
                            '<td>#' + r.reservationNo + '</td>' +
                            '<td>' +
                            '<div style="font-weight:600;">' + (r.guestName || 'Unknown') + '</div>' +
                            '<div style="font-size:0.8em; color:#6b7280;">ID: ' + r.guestID + '</div>' +
                            '</td>' +
                            '<td>' + statusOptions + '</td>' +
                            '<td>' +
                            '<strong style="color:var(--primary);">Room ' + r.roomNo + '</strong><br>' +
                            '<span style="font-size:0.85em; color:#6b7280;">' + (r.roomType || '') + '</span>' +
                            '</td>' +
                            '<td>Rs.' + parseFloat(r.pricePerNight).toFixed(2) + '</td>' +
                            '<td style="white-space:nowrap;">' +
                            '<div style="color:#059669;">In: ' + checkIn + '</div>' +
                            '<div style="color:#dc2626;">Out: ' + checkOut + '</div>' +
                            '</td>' +
                            '<td>' +
                            '<div style="display:flex; gap:0.25rem; align-items:center;">' +
                            '<button class="action-btn btn-edit" onclick="editRes(' + r.reservationNo + ')">Edit</button>' +
                            ' ' + billBtn + ' ' +
                            '<button class="action-btn btn-delete" onclick="deleteRes(' + r.reservationNo + ')">Del</button>' +
                            '</div>' +
                            '</td>';
                        tbody.appendChild(tr);
                    });
                })
                .catch(err => {
                    console.error(err);
                    document.getElementById('resTableBody').innerHTML = '<tr><td colspan="7" style="text-align:center; color:red;">Error loading data.</td></tr>';
                });
        }

        function getStatusColor(status) {
            if (status === 'PAID') return 'background:#dcfce7; color:#166534; border:1px solid #bbf7d0;';
            if (status === 'CANCELLED') return 'background:#fee2e2; color:#991b1b; border:1px solid #fecaca;';
            return 'background:#fef3c7; color:#92400e; border:1px solid #fde68a;'; // PENDING
        }

        function updateStatus(id, newStatus, currentStatus) {
            if (currentStatus === 'PAID' && newStatus === 'PENDING') {
                if (!confirm("Warning: Reverting to PENDING will CANCEL the existing bill. Continue?")) {
                    loadReservations();
                    return;
                }
            }

            fetch('../reservations', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=updateStatus&reservationNo=' + id + '&status=' + newStatus
            })
                .then(res => res.json())
                .then(data => {
                    if (data.status === 'success') {
                        loadReservations();
                        loadRooms();
                    } else {
                        alert("Error: " + data.message);
                        loadReservations();
                    }
                })
                .catch(err => {
                    alert("Connection Error");
                    loadReservations();
                });
        }

        function generateBill(id) {
            if (!confirm('Generate Bill for Reservation #' + id + '?')) return;

            fetch('../billing?action=generate&reservationNo=' + id, { method: 'POST' })
                .then(res => res.json())
                .then(data => {
                    if (data.status === 'success') {
                        window.location.href = 'bill.jsp?id=' + id;
                    } else {
                        alert("Error: " + data.message);
                    }
                })
                .catch(err => alert("Connection Error"));
        }

        function viewBill(id) {
            window.location.href = 'bill.jsp?id=' + id;
        }

        function searchReservations() {
            const q = document.getElementById('searchInput').value;
            loadReservations(q);
        }

        function editRes(id) {
            fetch('../reservations?action=edit&id=' + id)
                .then(res => res.json())
                .then(data => {
                    const r = data.reservation;
                    const g = data.guest;

                    document.getElementById('formTitle').textContent = 'Edit Booking';
                    document.getElementById('formAction').value = 'update';
                    document.getElementById('reservationNo').value = r.reservationNo;
                    document.getElementById('guestId').value = r.guestID;

                    document.getElementById('guestContact').value = g.contactNo;
                    document.getElementById('guestName').value = g.name;
                    document.getElementById('guestEmail').value = g.email || '';
                    document.getElementById('guestAddress').value = g.address || '';

                    document.getElementById('roomNo').value = r.roomNo;

                    if (r.checkInDate) document.getElementById('checkInDate').value = r.checkInDate;
                    if (r.checkOutDate) document.getElementById('checkOutDate').value = r.checkOutDate;

                    document.getElementById('submitBtn').innerHTML = '<i class="fas fa-save"></i> Update Reservation';
                    document.getElementById('cancelBtn').classList.remove('hidden');

                    window.scrollTo({ top: 0, behavior: 'smooth' });
                })
                .catch(err => alert("Error fetching details: " + err));
        }

        function resetForm() {
            document.getElementById('resForm').reset();
            document.getElementById('formAction').value = 'add';
            document.getElementById('reservationNo').value = '';
            document.getElementById('guestId').value = '';
            document.getElementById('formTitle').textContent = 'New Booking';
            document.getElementById('submitBtn').innerHTML = '<i class="fas fa-check-circle"></i> Confirm Booking';
            document.getElementById('cancelBtn').classList.add('hidden');
        }

        function handleResSubmit(e) {
            e.preventDefault();
            const form = e.target;
            const formData = new URLSearchParams(new FormData(form));

            fetch('../reservations', {
                method: 'POST',
                body: formData
            })
                .then(res => res.json())
                .then(data => {
                    if (data.status === 'success') {
                        alert(data.message);
                        resetForm();
                        loadReservations();
                        loadRooms();
                    } else {
                        alert("Error: " + data.message);
                    }
                })
                .catch(err => {
                    alert("Connection Error");
                    console.error(err);
                });
        }

        function deleteRes(id) {
            if (!confirm('Cancel Reservation #' + id + '? This cannot be undone.')) return;

            fetch('../reservations', {
                method: 'POST',
                body: new URLSearchParams({ action: 'delete', reservationNo: id })
            })
                .then(res => res.json())
                .then(data => {
                    if (data.status === 'success') {
                        alert(data.message);
                        loadReservations();
                        loadRooms();
                    } else {
                        alert("Error: " + data.message);
                    }
                });
        }

        function openRoomPicker() {
            document.getElementById('roomPickerModal').style.display = 'block';
            searchRoomsInPicker();
        }

        function closeRoomPicker() {
            document.getElementById('roomPickerModal').style.display = 'none';
        }

        function searchRoomsInPicker() {
            const roomNo = document.getElementById('modalRoomNo').value.trim();
            const type = document.getElementById('modalRoomType').value;
            const status = document.getElementById('modalRoomStatus').value;
            const minPrice = document.getElementById('modalMinPrice').value;
            const maxPrice = document.getElementById('modalMaxPrice').value;

            const params = new URLSearchParams();
            if (roomNo) params.append('roomNo', roomNo);
            if (type !== 'All') params.append('type', type);
            if (status !== 'All') params.append('status', status);
            if (minPrice) params.append('minPrice', minPrice);
            if (maxPrice) params.append('maxPrice', maxPrice);

            const tbody = document.getElementById('modalResultsBody');
            tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;">Searching...</td></tr>';

            fetch('../rooms?' + params.toString())
                .then(res => res.json())
                .then(data => {
                    tbody.innerHTML = '';
                    if (!data || data.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;">No rooms found.</td></tr>';
                        return;
                    }

                    data.forEach(r => {
                        const id = r.roomNo || r.id;
                        const isAvail = r.isAvailable === true || r.isAvailable === "true";
                        const badgeClass = isAvail ? 'badge-available' : 'badge-booked';
                        const badgeText = isAvail ? 'Available' : 'Booked';

                        const tr = document.createElement('tr');
                        tr.innerHTML =
                            '<td><strong>#' + id + '</strong></td>' +
                            '<td>' + r.roomType + '</td>' +
                            '<td>Rs.' + parseFloat(r.pricePerNight).toFixed(2) + '</td>' +
                            '<td><span class="' + badgeClass + '">' + badgeText + '</span></td>' +
                            '<td><button class="btn-select-room" onclick="selectRoomFromPicker(' + id + ')">Select</button></td>';
                        tbody.appendChild(tr);
                    });
                })
                .catch(err => {
                    console.error(err);
                    tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:var(--danger);">Error loading rooms.</td></tr>';
                });
        }

        function selectRoomFromPicker(id) {
            const select = document.getElementById('roomNo');
            let found = false;
            for (let i = 0; i < select.options.length; i++) {
                if (select.options[i].value == id) {
                    select.selectedIndex = i;
                    found = true;
                    break;
                }
            }

            if (!found) {
                alert("Error: Selected room not found in list. It might have been deleted.");
            } else {
                closeRoomPicker();
            }
        }

        function resetRoomPickerFilters() {
            document.getElementById('modalRoomNo').value = '';
            document.getElementById('modalRoomType').value = 'All';
            document.getElementById('modalRoomStatus').value = 'Available';
            document.getElementById('modalMinPrice').value = '';
            document.getElementById('modalMaxPrice').value = '';
            searchRoomsInPicker();
        }

        window.onclick = function (event) {
            const modal = document.getElementById('roomPickerModal');
            if (event.target == modal) {
                closeRoomPicker();
            }
        }
    </script>

    <!-- ROOM PICKER MODAL HTML -->
    <div id="roomPickerModal" class="modal">
        <div class="modal-content">
            <span class="close-modal" onclick="closeRoomPicker()">&times;</span>
            <h2>Find Room</h2>
            <p style="margin-bottom: 1.5rem; color: #6b7280; font-size: 0.9rem;">Search for available rooms to
                add to this reservation.</p>

            <div class="modal-search-row">
                <div>
                    <label>Room No</label>
                    <input type="text" id="modalRoomNo" placeholder="e.g. 101"
                        onkeypress="if(event.key==='Enter') searchRoomsInPicker()">
                </div>
                <div>
                    <label>Type</label>
                    <select id="modalRoomType">
                        <option value="All">All Types</option>
                        <option value="Single">Single</option>
                        <option value="Double">Double</option>
                        <option value="Suite">Suite</option>
                        <option value="Deluxe">Deluxe</option>
                    </select>
                </div>
                <div>
                    <label>Status</label>
                    <select id="modalRoomStatus">
                        <option value="Available" selected>Available Only</option>
                        <option value="Booked">Booked Only</option>
                        <option value="All">All Rooms</option>
                    </select>
                </div>
                <div>
                    <label>Min Price</label>
                    <input type="number" id="modalMinPrice" placeholder="Min"
                        onkeypress="if(event.key==='Enter') searchRoomsInPicker()">
                </div>
                <div>
                    <label>Max Price</label>
                    <input type="number" id="modalMaxPrice" placeholder="Max"
                        onkeypress="if(event.key==='Enter') searchRoomsInPicker()">
                </div>
                <button class="btn-modal-search" onclick="searchRoomsInPicker()">Search</button>
                <button class="btn-modal-reset" onclick="resetRoomPickerFilters()">Reset</button>
            </div>

            <div class="table-responsive">
                <table class="results-table">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th>Type</th>
                            <th>Price</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="modalResultsBody">
                        <!-- Results will be injected here -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</body>

</html>