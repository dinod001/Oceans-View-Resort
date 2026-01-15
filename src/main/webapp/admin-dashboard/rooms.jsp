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

    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Page-specific overrides or additions */
        .checkbox-container {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1rem;
            cursor: pointer;
        }

        .checkbox-container input {
            width: auto;
            margin-bottom: 0;
        }

        .badge-available {
            background: #dcfce7;
            color: #166534;
        }

        .badge-booked {
            background: #fee2e2;
            color: #991b1b;
        }

        /* Page-specific overrides for the multi-column search grid */
        .search-grid {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr 0.8fr 0.8fr auto auto;
            gap: 0.75rem;
            margin-bottom: 2rem;
            align-items: flex-end;
        }

        .search-grid .form-group {
            margin-bottom: 0;
        }

        @media(max-width: 900px) {
            .search-grid {
                grid-template-columns: 1fr 1fr;
            }
        }
    </style>
</head>

<body>

    <header>
        <h1>Room Management</h1>
        <a href="./index.jsp" class="back-link">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
    </header>

    <div class="container">

        <!-- ROOM LIST -->
        <div class="card">
            <div
                style="display:flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                <h2>All Rooms</h2>
            </div>

            <div class="search-grid">
                <div class="form-group">
                    <label>Room No</label>
                    <input type="text" id="searchRoomNo" placeholder="e.g. 101"
                        onkeyup="if(event.key==='Enter') applyFilters()">
                </div>
                <div class="form-group">
                    <label>Type</label>
                    <select id="searchType">
                        <option value="">All Types</option>
                        <option value="Single">Single</option>
                        <option value="Double">Double</option>
                        <option value="Deluxe">Deluxe</option>
                        <option value="Suite">Suite</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select id="searchStatus">
                        <option value="">All Status</option>
                        <option value="Available">Available</option>
                        <option value="Booked">Booked</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Min Price</label>
                    <input type="number" id="searchMinPrice" placeholder="Min"
                        onkeyup="if(event.key==='Enter') applyFilters()">
                </div>
                <div class="form-group">
                    <label>Max Price</label>
                    <input type="number" id="searchMaxPrice" placeholder="Max"
                        onkeyup="if(event.key==='Enter') applyFilters()">
                </div>
                <button onclick="applyFilters()" class="btn btn-primary">
                    <i class="fas fa-search"></i>
                </button>
                <button onclick="resetFilters()" class="btn btn-outline">
                    <i class="fas fa-sync"></i>
                </button>
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

                <button type="submit" id="submitBtn" class="btn btn-primary">
                    <i class="fas fa-plus"></i> Add Room
                </button>
                <button type="button" id="cancelBtn" class="btn btn-outline hidden" onclick="resetForm()">
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