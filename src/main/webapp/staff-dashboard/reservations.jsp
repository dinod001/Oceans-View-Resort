<%@ page contentType="text/html;charset=UTF-8" language="java" %>



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
<title>Manage Reservations | Staff Dashboard</title>
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
        max-width: 1400px;
        margin: 0 auto;
        display: grid;
        gap: 2rem;
        grid-template-columns: 3fr 1fr;
    }

    @media(max-width:1100px) {
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

    h1,
    h2,
    h3 {
        color: var(--primary);
        margin-bottom: 1rem;
    }

    h2 {
        font-size: 1.25rem;
        border-bottom: 2px solid #e5e7eb;
        padding-bottom: 0.5rem;
    }

    h3 {
        font-size: 1rem;
        color: #4b5563;
        margin-top: 1rem;
        margin-bottom: 0.5rem;
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

    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 1rem;
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
    select {
        width: 100%;
        padding: 0.75rem;
        border: 1px solid #d1d5db;
        border-radius: 8px;
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

    .hidden {
        display: none;
    }

    .table-responsive {
        overflow-x: auto;
    }

    table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        min-width: 800px;
    }

    th,
    td {
        padding: 1rem;
        text-align: left;
        border-bottom: 1px solid #e5e7eb;
        color: #374151;
    }

    th {
        background: #f9fafb;
        font-weight: 600;
        color: #4b5563;
        font-size: 0.9rem;
        text-transform: uppercase;
    }

    tr:hover {
        background-color: #f9fafb;
    }

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

    .btn-delete {
        background: #fef2f2;
        color: var(--danger);
        border: 1px solid #fecaca;
    }

    .btn-bill {
        background: #8b5cf6;
        color: white;
        border: 1px solid #7c3aed;
    }

    .search-bar {
        display: flex;
        gap: 0.5rem;
        margin-bottom: 1.5rem;
    }

    .search-bar input {
        flex: 1;
    }

    .search-bar button {
        width: auto;
        background: #4b5563;
        color: white;
    }

    /* MODAL STYLES */
    .modal {
        display: none;
        position: fixed;
        z-index: 1000;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5);
        backdrop-filter: blur(4px);
    }

    .modal-content {
        background-color: var(--white);
        margin: 5% auto;
        padding: 2rem;
        border-radius: 12px;
        width: 80%;
        max-width: 900px;
        max-height: 80vh;
        overflow-y: auto;
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
        position: relative;
    }

    .close-modal {
        position: absolute;
        right: 1.5rem;
        top: 1rem;
        font-size: 1.5rem;
        cursor: pointer;
        color: #6b7280;
    }

    .modal-search-row {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr 0.8fr 0.8fr auto auto;
        gap: 1rem;
        margin-bottom: 1.5rem;
        background: #f9fafb;
        padding: 1rem;
        border-radius: 8px;
        align-items: end;
    }

    .modal-search-row input,
    .modal-search-row select {
        margin-bottom: 0;
        padding: 0.6rem;
    }

    .modal-search-row label {
        font-size: 0.75rem;
        text-transform: uppercase;
        margin-bottom: 0.25rem;
    }

    .btn-modal-search {
        background: var(--primary);
        color: white;
        width: auto;
        padding: 0.6rem 1.5rem;
    }

    .btn-modal-reset {
        background: transparent;
        color: #6b7280;
        border: 1px solid #d1d5db;
        width: auto;
        padding: 0.6rem 1.5rem;
    }

    .btn-modal-reset:hover {
        background: #f3f4f6;
    }

    .results-table {
        width: 100%;
        margin-top: 1rem;
    }

    .results-table th {
        background: #f3f4f6;
    }

    .btn-select-room {
        background: var(--success);
        color: white;
        padding: 0.3rem 0.8rem;
        font-size: 0.8rem;
        width: auto;
    }

    .btn-select-room:hover {
        background: #15803d;
    }

    .btn-check-avail-header {
        background: var(--white);
        color: var(--primary);
        border: 1.5px solid var(--primary);
        padding: 0.5rem 1rem;
        border-radius: 8px;
        font-weight: 600;
        font-size: 0.85rem;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        width: auto;
        white-space: nowrap;
    }

    .btn-check-avail-header:hover {
        background: #f0f7ff;
        border-color: var(--primary-dark);
        color: var(--primary-dark);
    }

    .btn-quick-search {
        background: #f3f4f6;
        color: #4b5563;
        border: 1px solid #d1d5db;
        padding: 0.75rem;
        border-radius: 8px;
        font-weight: 600;
        font-size: 0.9rem;
        margin-bottom: 1.5rem;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 0.5rem;
        width: 100%;
    }

    .btn-quick-search:hover {
        background: #e5e7eb;
        color: #1f2937;
    }
</style>
</head>

<body>

<header>
    <div>
        <h1>Reservations</h1>
        <p style="color: #6b7280;">Book rooms and manage guests</p>
    </div>
    <div style="display:flex; gap:1rem; align-items:center;">
        <button type="button" class="btn-check-avail-header" onclick="openRoomPicker()">
            🔍 Check Availability
        </button>
        <a href="index.jsp" class="back-link">Back to Dashboard</a>
    </div>
</header>

<div class="container">

    <!-- RESERVATIONS LIST -->
    <div class="card table-responsive">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem;">
            <h2>All Reservations</h2>
            <button onclick="loadReservations()"
                style="width:auto; background:none; color:var(--primary); font-size:0.9rem;">Refresh
                List</button>
        </div>

        <div class="search-bar">
            <input type="text" id="searchInput" placeholder="Search by Guest Contact No...">
            <button onclick="searchReservations()">Search</button>
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

            <button type="submit" id="submitBtn" class="btn-primary">Confirm Booking</button>
            <button type="button" id="cancelBtn" class="btn-cancel hidden" onclick="resetForm()">Cancel
                Edit</button>
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
        // Add timestamp to prevent caching
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
                    option.textContent = `Room \${rNo} - \${rType} ($\${parseFloat(rPrice).toFixed(2)}) \${isAvail ? '' : '(Booked)'}`;

                    // Disable booked rooms (optional, but good UX)
                    // If implementing dates check, this logic is more complex.
                    // For now, we allow selecting booked rooms only if editing (handled in logic)
                    if (!isAvail) {
                        option.style.color = '#ccc';
                        // option.disabled = true; // Uncomment to strictly enforce
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
            url += `&searchContact=\${encodeURIComponent(query)}`;
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

                    // Logic for Bill Button
                    let billBtn = '';
                    if (status === 'PAID') {
                        billBtn = `<button class="action-btn btn-bill" onclick="viewBill(\${r.reservationNo})">View Bill</button>`;
                    } else if (status === 'CANCELLED') {
                        billBtn = ''; // No bill button for cancelled
                    } else {
                        billBtn = `<button class="action-btn btn-bill" onclick="generateBill(\${r.reservationNo})">Bill</button>`;
                    }

                    // Logic for Status Dropdown
                    // Prevent selecting PAID manually if currently PENDING or CANCELLED
                    const isPaid = status === 'PAID';
                    const statusOptions = `
<select onchange="updateStatus(\${r.reservationNo}, this.value, '\${status}')" style="padding:0.2rem; font-size:0.85rem; border-radius:4px; \${getStatusColor(status)}">
<option value="PENDING" \${status === 'PENDING' ? 'selected' : ''}>PENDING</option>
<option value="PAID" \${status === 'PAID' ? 'selected' : ''} \${!isPaid ? 'disabled' : ''}>PAID</option>
<option value="CANCELLED" \${status === 'CANCELLED' ? 'selected' : ''}>CANCELLED</option>
</select>
`;

                    tr.innerHTML = `
<td>#\${r.reservationNo}</td>
<td>
<div style="font-weight:600;">\${r.guestName || 'Unknown'}</div>
<div style="font-size:0.8em; color:#6b7280;">ID: \${r.guestID}</div>
</td>
<td>\${statusOptions}</td>
<td>
<strong style="color:var(--primary);">Room \${r.roomNo}</strong><br>
<span style="font-size:0.85em; color:#6b7280;">\${r.roomType || ''}</span>
</td>
<td>$\${parseFloat(r.pricePerNight).toFixed(2)}</td>
<td style="white-space:nowrap;">
<div style="color:#059669;">In: \${checkIn}</div>
<div style="color:#dc2626;">Out: \${checkOut}</div>
</td>
<td>
<div style="display:flex; gap:0.5rem; align-items:center;">
<button class="action-btn btn-edit" onclick="editRes(\${r.reservationNo})">Edit</button>
\${billBtn}
<button class="action-btn btn-delete" onclick="deleteRes(\${r.reservationNo})">X</button>
</div>
</td>
`;
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
                loadReservations(); // Reset dropdown
                return;
            }
        }

        fetch('../reservations', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `action=updateStatus&reservationNo=\${id}&status=\${newStatus}`
        })
            .then(res => res.json())
            .then(data => {
                if (data.status === 'success') {
                    // alert(data.message); // Optional: less spammy to just reload
                    loadReservations();
                    loadRooms(); // Refresh rooms to update booking availability
                } else {
                    alert("Error: " + data.message);
                    loadReservations(); // Reset on error
                }
            })
            .catch(err => {
                alert("Connection Error");
                loadReservations();
            });
    }

    function generateBill(id) {
        if (!confirm(`Generate Bill for Reservation #\${id}?`)) return;

        fetch(`../billing?action=generate&reservationNo=\${id}`, { method: 'POST' })
            .then(res => res.json())
            .then(data => {
                if (data.status === 'success') {
                    // Redirect to the bill view page using the Reservation ID
                    // The backend 'view' action expects a Reservation ID (getBillByReservationId)
                    window.location.href = `bill.jsp?id=\${id}`;
                } else {
                    alert("Error: " + data.message);
                }
            })
            .catch(err => alert("Connection Error"));
    }

    function viewBill(id) {
        // Directly navigate to bill page for PAID reservations
        window.location.href = `bill.jsp?id=\${id}`;
    }

    function searchReservations() {
        const q = document.getElementById('searchInput').value;
        loadReservations(q);
    }

    function editRes(id) {
        fetch(`../reservations?action=edit&id=\${id}`)
            .then(res => res.json())
            .then(data => {
                // data = { reservation: {...}, guest: {...} }
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

                // Room Select
                document.getElementById('roomNo').value = r.roomNo;

                // Dates - The API returns "yyyy-MM-dd", which works directly with input type="date"
                // No need for complex parsing or timezone adjustments
                if (r.checkInDate) document.getElementById('checkInDate').value = r.checkInDate;
                if (r.checkOutDate) document.getElementById('checkOutDate').value = r.checkOutDate;

                document.getElementById('submitBtn').textContent = 'Update Reservation';
                document.getElementById('cancelBtn').classList.remove('hidden');

                // Scroll up
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
        document.getElementById('submitBtn').textContent = 'Confirm Booking';
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
                    loadRooms(); // Refresh rooms to update booking status
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
        if (!confirm(`Cancel Reservation #\${id}? This cannot be undone.`)) return;

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

    // ROOM PICKER MODAL LOGIC
    function openRoomPicker() {
        document.getElementById('roomPickerModal').style.display = 'block';
        searchRoomsInPicker(); // Initial search for all available rooms
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
                    tr.innerHTML = `
<td><strong>#\${id}</strong></td>
<td>\${r.roomType}</td>
<td>$\${parseFloat(r.pricePerNight).toFixed(2)}</td>
<td><span class="\${badgeClass}">\${badgeText}</span></td>
<td><button class="btn-select-room" onclick="selectRoomFromPicker(\${id})">Select</button></td>
`;
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

        // Check if room exists in dropdown
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

    // Close modal when clicking outside
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
            add
            to this reservation.</p>

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