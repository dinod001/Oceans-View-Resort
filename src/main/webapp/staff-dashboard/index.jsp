<%@ page contentType="text/html;charset=UTF-8" language="java" %>

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
    <title>Staff Dashboard | Ocean View Resort</title>
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
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
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

        .icon-res {
            background: #eff6ff;
            color: #3b82f6;
        }

        /* Blue */
        .icon-rooms {
            background: #f0fdf4;
            color: #10b981;
        }

        /* Green */
        .icon-guests {
            background: #fff7ed;
            color: #f59e0b;
        }

        /* Orange */

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

        /* Mobile Breakpoints */
        @media (max-width: 768px) {
            .container {
                margin: 1rem auto;
                padding: 0 1rem;
            }

            .welcome-section h2 {
                font-size: 1.75rem;
            }

            .welcome-section p {
                font-size: 1rem;
            }

            .stats-grid {
                grid-template-columns: 1fr;
                gap: 1rem;
            }

            .stat-card {
                padding: 1.5rem;
            }

            .nav-grid {
                grid-template-columns: 1fr;
                gap: 1.5rem;
            }

            .nav-card-body {
                padding: 1.5rem;
            }

            .nav-card-footer {
                padding: 1rem 1.5rem;
            }
        }
    </style>
</head>

<body>

    <header>
        <h1>Ocean View Resort | Staff Portal</h1>
        <div class="header-controls">
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
            <h2>Operational Hub</h2>
            <p>Monitor guest arrivals, room availability, and resort operations. Your efficiency drives our
                excellence.</p>
        </div>

        <!-- Stats Section -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon icon-res">
                    <i class="fas fa-concierge-bell"></i>
                </div>
                <div class="stat-info">
                    <h3>Active Reservations</h3>
                    <div id="resCount" class="stat-value">--</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon icon-rooms">
                    <i class="fas fa-key"></i>
                </div>
                <div class="stat-info">
                    <h3>Available Rooms</h3>
                    <div id="roomCount" class="stat-value">--</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon icon-guests">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-info">
                    <h3>Registered Guests</h3>
                    <div id="guestCount" class="stat-value">--</div>
                </div>
            </div>
        </div>

        <!-- Navigation Grid -->
        <div class="nav-grid">
            <a href="reservations.jsp" class="nav-card">
                <div class="nav-card-body">
                    <div class="nav-card-icon"><i class="fas fa-calendar-alt"></i></div>
                    <h4>Manage Reservations</h4>
                    <p>Process check-ins and check-outs, create new bookings, and manage the reservation
                        schedule.</p>
                </div>
                <div class="nav-card-footer">
                    Manage Front Desk <i class="fas fa-chevron-right"></i>
                </div>
            </a>

            <a href="guest.jsp" class="nav-card">
                <div class="nav-card-body">
                    <div class="nav-card-icon"><i class="fas fa-address-book"></i></div>
                    <h4>Guest Directory</h4>
                    <p>Lookup guest profiles, update contact information, and review guest history for
                        personalized service.</p>
                </div>
                <div class="nav-card-footer">
                    Manage Profiles <i class="fas fa-chevron-right"></i>
                </div>
            </a>

            <a href="help.jsp" class="nav-card">
                <div class="nav-card-body">
                    <div class="nav-card-icon"><i class="fas fa-question-circle"></i></div>
                    <h4>Help & Support</h4>
                    <p>Access the staff manual, troubleshooting guides, and system documentation for operational
                        support.</p>
                </div>
                <div class="nav-card-footer">
                    View Documentation <i class="fas fa-chevron-right"></i>
                </div>
            </a>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            fetchStats();
        });

        async function fetchStats() {
            // 1. Fetch Reservations
            fetch('../reservations')
                .then(res => res.json())
                .then(data => {
                    document.getElementById('resCount').textContent = data.length;
                })
                .catch(err => {
                    console.error('Error fetching reservations:', err);
                    document.getElementById('resCount').textContent = 'N/A';
                });

            // 2. Fetch Rooms (Filtering for Available)
            fetch('../rooms')
                .then(res => res.json())
                .then(data => {
                    const available = data.filter(r => r.isAvailable === true || r.isAvailable === "true");
                    document.getElementById('roomCount').textContent = available.length;
                })
                .catch(err => {
                    console.error('Error fetching rooms:', err);
                    document.getElementById('roomCount').textContent = 'N/A';
                });

            // 3. Fetch Guests
            fetch('../guests')
                .then(res => res.json())
                .then(data => {
                    document.getElementById('guestCount').textContent = data.length;
                })
                .catch(err => {
                    console.error('Error fetching guests:', err);
                    document.getElementById('guestCount').textContent = 'N/A';
                });
        }
    </script>

</body>

</html>