<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | Ocean View Resort</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .container {
            max-width: 1200px;
            margin: 2rem auto;
            display: block;
            /* Override global grid for index */
        }

        .welcome-section {
            margin-bottom: 3rem;
            text-align: center;
        }

        .welcome-section h2 {
            font-size: 2.25rem;
            color: var(--primary);
            margin-bottom: 0.5rem;
            font-weight: 800;
            letter-spacing: -0.025em;
        }

        .welcome-section p {
            color: var(--text-light);
            font-size: 1.1rem;
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 3rem;
        }

        .stat-card {
            background: var(--card-bg);
            padding: 2rem;
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-sm);
            display: flex;
            align-items: center;
            gap: 1.5rem;
            transition: transform 0.2s;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-md);
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }

        .icon-rooms {
            background: #eff6ff;
            color: #3b82f6;
        }

        .icon-staff {
            background: #f0fdf4;
            color: #10b981;
        }

        .icon-res {
            background: #fff7ed;
            color: #f59e0b;
        }

        .stat-info h3 {
            font-size: 0.875rem;
            text-transform: uppercase;
            color: var(--text-light);
            margin-bottom: 0.25rem;
            letter-spacing: 0.05em;
        }

        .stat-value {
            font-size: 1.75rem;
            font-weight: 800;
            color: var(--primary);
        }

        /* Navigation Grid */
        .nav-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 2rem;
        }

        .nav-card {
            background: var(--card-bg);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            overflow: hidden;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            text-decoration: none;
            display: flex;
            flex-direction: column;
            position: relative;
        }

        .nav-card:hover {
            border-color: var(--accent);
            box-shadow: var(--shadow-lg);
            transform: translateY(-4px);
        }

        .nav-card-body {
            padding: 2.5rem;
        }

        .nav-card-icon {
            font-size: 2.5rem;
            color: var(--accent);
            margin-bottom: 1.5rem;
        }

        .nav-card h4 {
            font-size: 1.5rem;
            color: var(--primary);
            margin-bottom: 1rem;
            font-weight: 700;
        }

        .nav-card p {
            color: var(--text-light);
            line-height: 1.6;
            margin-bottom: 1.5rem;
        }

        .nav-card-footer {
            padding: 1.25rem 2.5rem;
            background: var(--bg);
            border-top: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-weight: 600;
            color: var(--accent);
            transition: background 0.2s;
        }

        .nav-card:hover .nav-card-footer {
            background: #eff6ff;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            background: #f0fdf4;
            color: #166534;
            border-radius: 9999px;
            font-size: 0.85rem;
            font-weight: 600;
            margin-top: 1rem;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            background: #22c55e;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% {
                transform: scale(0.95);
                box-shadow: 0 0 0 0 rgba(34, 197, 94, 0.7);
            }

            70% {
                transform: scale(1);
                box-shadow: 0 0 0 10px rgba(34, 197, 94, 0);
            }

            100% {
                transform: scale(0.95);
                box-shadow: 0 0 0 0 rgba(34, 197, 94, 0);
            }
        }
    </style>
</head>

<body>

    <header>
        <h1>Ocean View Resort | Admin Control</h1>
        <div style="display:flex; gap:1rem; align-items:center;">
            <span style="font-size:0.9rem; color:#94a3b8;">Welcome, <strong>
                    <%= username %>
                </strong></span>
            <a href="../auth?action=logout" class="back-link">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </header>

    <div class="container">
        <div class="welcome-section">
            <h2>Administrator Overview</h2>
            <p>Manage resort infrastructure and staff operations from a central interface.</p>
        </div>

        <!-- Stats Section -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon icon-rooms">
                    <i class="fas fa-door-open"></i>
                </div>
                <div class="stat-info">
                    <h3>Total Rooms</h3>
                    <div id="roomCount" class="stat-value">--</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon icon-staff">
                    <i class="fas fa-user-shield"></i>
                </div>
                <div class="stat-info">
                    <h3>Active Staff</h3>
                    <div id="staffCount" class="stat-value">--</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon icon-res">
                    <i class="fas fa-calendar-check"></i>
                </div>
                <div class="stat-info">
                    <h3>Reservations</h3>
                    <div id="resCount" class="stat-value">--</div>
                </div>
            </div>
        </div>

        <!-- Navigation Grid -->
        <div class="nav-grid">
            <a href="rooms.jsp" class="nav-card">
                <div class="nav-card-body">
                    <div class="nav-card-icon"><i class="fas fa-bed"></i></div>
                    <h4>Room Management</h4>
                    <p>Configure room types, pricing, and availability. Monitor guest stays and room maintenance
                        status.</p>
                </div>
                <div class="nav-card-footer">
                    Manage Infrastructure <i class="fas fa-chevron-right"></i>
                </div>
            </a>

            <a href="staff.jsp" class="nav-card">
                <div class="nav-card-body">
                    <div class="nav-card-icon"><i class="fas fa-users-cog"></i></div>
                    <h4>Staff Control</h4>
                    <p>Manage employee accounts, assign roles, and monitor system access. Add or remove staff
                        members.</p>
                </div>
                <div class="nav-card-footer">
                    Manage Access <i class="fas fa-chevron-right"></i>
                </div>
            </a>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            fetchStats();
        });

        async function fetchStats() {
            // Fetch Rooms
            fetch('../rooms')
                .then(res => res.json())
                .then(data => {
                    document.getElementById('roomCount').textContent = data.length;
                })
                .catch(err => {
                    console.error('Error fetching rooms:', err);
                    document.getElementById('roomCount').textContent = 'N/A';
                });

            // Fetch Staff (Corrected endpoint)
            fetch('../staff-mgmt')
                .then(res => res.json())
                .then(data => {
                    document.getElementById('staffCount').textContent = data.length;
                })
                .catch(err => {
                    console.error('Error fetching staff:', err);
                    document.getElementById('staffCount').textContent = 'N/A';
                });

            // Fetch Reservations
            fetch('../reservations')
                .then(res => res.json())
                .then(data => {
                    document.getElementById('resCount').textContent = data.length;
                })
                .catch(err => {
                    console.error('Error fetching reservations:', err);
                    document.getElementById('resCount').textContent = 'N/A';
                });
        }
    </script>

</body>

</html>