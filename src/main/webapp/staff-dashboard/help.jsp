<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
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
    <title>Staff Help Section | Ocean View Resort</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        .container {
            max-width: 900px;
            /* Reduced for better readability */
            margin: 0 auto;
            padding: 2.5rem 1rem;
            display: block;
            /* Override global grid */
        }

        .section-card {
            background: var(--card-bg);
            border-radius: var(--radius-lg);
            border: 1px solid var(--border-light);
            margin-bottom: 2.5rem;
            padding: 2.5rem;
            box-shadow: var(--shadow-sm);
            transition: all 0.2s ease;
        }

        .section-card:hover {
            box-shadow: var(--shadow-md);
        }

        .section-header {
            display: flex;
            align-items: center;
            gap: 1.25rem;
            margin-bottom: 2rem;
            padding-bottom: 1.25rem;
            border-bottom: 2px solid var(--border-light);
        }

        .section-header i {
            font-size: 1.8rem;
            color: var(--accent);
        }

        .section-header h2 {
            margin: 0;
            font-size: 1.8rem;
            color: var(--text-dark);
            font-weight: 700;
        }

        h3 {
            font-size: 1.3rem;
            margin-bottom: 1.25rem;
            color: var(--primary);
            font-weight: 600;
        }

        p {
            font-size: 1.05rem;
            line-height: 1.7;
            color: var(--text);
            margin-bottom: 1.5rem;
        }

        ol,
        ul {
            line-height: 1.8;
            padding-left: 2rem;
            margin: 1.5rem 0;
            color: var(--text);
        }

        li {
            margin-bottom: 1rem;
            font-size: 1.05rem;
        }

        code {
            background: var(--border-light);
            color: var(--primary-dark);
            padding: 0.3rem 0.6rem;
            border-radius: 6px;
            font-family: var(--font-mono);
            font-size: 0.9em;
            font-weight: 600;
        }

        .tip {
            background: #f0f7ff;
            border-left: 5px solid var(--accent);
            padding: 1.5rem 2rem;
            margin: 2rem 0;
            border-radius: 0 var(--radius-md) var(--radius-md) 0;
            color: var(--primary-light);
        }

        .tip strong {
            color: var(--accent-dark);
        }

        .danger-tip {
            background: #fff5f5;
            border-left-color: var(--danger);
        }

        .danger-tip strong {
            color: var(--danger);
        }

        .quick-nav {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 3rem;
            justify-content: center;
        }

        .quick-nav a {
            padding: 0.8rem 1.6rem;
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 100px;
            /* Pill style */
            text-decoration: none;
            color: var(--text);
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: var(--shadow-sm);
        }

        .quick-nav a:hover {
            background: var(--accent);
            color: white;
            border-color: var(--accent);
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }

        @media (max-width: 768px) {
            .section-card {
                padding: 1.5rem;
            }

            .section-header h2 {
                font-size: 1.5rem;
            }
        }
    </style>
</head>

<body>

    <header>
        <h1>Staff Help Section</h1>
        <a href="index.jsp" class="back-link">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
    </header>

    <div class="container">

        <!-- Quick Navigation -->
        <div class="quick-nav">
            <a href="#guests"><i class="fas fa-users"></i> Guest Management</a>
            <a href="#reservations"><i class="fas fa-calendar-alt"></i> Reservations</a>
            <a href="#billing"><i class="fas fa-file-invoice"></i> Billing & Checkout</a>
            <a href="#support"><i class="fas fa-tools"></i> Technical Support</a>
        </div>

        <!-- Guest Management -->
        <div id="guests" class="section-card">
            <div class="section-header">
                <i class="fas fa-user-plus"></i>
                <h2>1. Managing Guests</h2>
            </div>
            <p>Efficient guest management is the foundation of our resort's service. Every visitor must be
                registered in the system prior to booking.</p>

            <h3>How to Register a New Guest</h3>
            <ol>
                <li>Navigate to the <strong>Manage Guests</strong> page.</li>
                <li>Complete the registration form on the right side:
                    <ul>
                        <li><strong>Full Name</strong>: Use official identification names.</li>
                        <li><strong>Contact Number</strong>: This is the primary unique identifier.</li>
                        <li><strong>Email & Address</strong>: Recommended for loyalty and billing.</li>
                    </ul>
                </li>
                <li>Click <code>Register Guest</code> to save.</li>
            </ol>

            <div class="tip">
                <strong>Pro Tip:</strong> Use the search bar in the Guest Management table to quickly find
                existing guests by their contact number to avoid duplicate entries.
            </div>
        </div>

        <!-- Reservations -->
        <div id="reservations" class="section-card">
            <div class="section-header">
                <i class="fas fa-calendar-check"></i>
                <h2>2. Handling Reservations</h2>
            </div>
            <p>The reservation system links guests with available rooms. Accuracy in dates ensures optimal
                occupancy and prevents double bookings.</p>

            <h3>Creating a New Booking</h3>
            <ol>
                <li>Go to the <strong>Reservations</strong> dashboard.</li>
                <li><strong>Identify Guest</strong>: Enter their contact number. If they are registered,
                    their details will auto-populate.</li>
                <li><strong>Check Availability</strong>: Click the <code>Check Availability</code> button in
                    the header to use the advanced room finder.</li>
                <li><strong>Select Dates</strong>: Specify check-in and check-out dates carefully.</li>
                <li>Click <code>Confirm Booking</code> to finalize.</li>
            </ol>

            <div class="tip">
                <strong>System Logic:</strong> The system automatically filters out rooms that are already
                "Booked" for the selected criteria, but always double-check dates before confirming.
            </div>
        </div>

        <!-- Billing & Status -->
        <div id="billing" class="section-card">
            <div class="section-header">
                <i class="fas fa-file-invoice-dollar"></i>
                <h2>3. Billing & Status Workflow</h2>
            </div>
            <p>Tracking the financial status of each stay is critical for revenue management.</p>

            <h3>Reservation Statuses</h3>
            <ul>
                <li><span style="color:var(--warning); font-weight:700;">PENDING</span>: Guest has booked
                    but payment is not processed.</li>
                <li><span style="color:var(--success); font-weight:700;">PAID</span>: Bill has been
                    generated and payment confirmed.</li>
                <li><span style="color:var(--danger); font-weight:700;">CANCELLED</span>: The reservation
                    has been voided.</li>
            </ul>

            <h3>Checkout Process</h3>
            <ol>
                <li>Locate the reservation in the list.</li>
                <li>Click the <code>Bill</code> button in the actions column.</li>
                <li>Review the bill details (Room charges + 10% statutory tax).</li>
                <li>Click <code>Print Invoice</code> to provide a physical copy to the guest.</li>
            </ol>
        </div>

        <!-- Technical Support -->
        <div id="support" class="section-card">
            <div class="section-header">
                <i class="fas fa-headset"></i>
                <h2>4. Technical Support</h2>
            </div>
            <p>If you encounter database errors, system lag, or login issues, please contact the IT team
                immediately.</p>

            <div class="tip danger-tip">
                <strong>IT Support Contacts:</strong><br>
                <i class="fas fa-phone"></i> Extension: <strong>501</strong> (Internal Only)<br>
                <i class="fas fa-envelope"></i> Email: <code>support.tech@oceanview.resort</code>
            </div>
        </div>

    </div>

</body>

</html>