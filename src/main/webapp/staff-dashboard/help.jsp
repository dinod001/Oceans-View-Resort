<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
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
            <title>System Help | Staff Dashboard</title>
            <style>
                :root {
                    --primary: #006994;
                    --primary-dark: #005a80;
                    --text: #1f2937;
                    --text-light: #6b7280;
                    --bg: #f3f4f6;
                    --white: #ffffff;
                    --border: #e5e7eb;
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
                    line-height: 1.6;
                }

                .container {
                    max-width: 1000px;
                    margin: 0 auto;
                }

                header {
                    margin-bottom: 2rem;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                }

                h1 {
                    color: var(--primary);
                    font-size: 1.8rem;
                }

                h2 {
                    font-size: 1.25rem;
                    color: var(--primary);
                    margin-bottom: 1rem;
                    border-bottom: 2px solid var(--border);
                    padding-bottom: 0.5rem;
                }

                h3 {
                    font-size: 1.1rem;
                    color: var(--text);
                    margin-top: 1.5rem;
                    margin-bottom: 0.5rem;
                    font-weight: 600;
                }

                p,
                li {
                    color: #374151;
                    margin-bottom: 0.8rem;
                }

                ul,
                ol {
                    padding-left: 1.5rem;
                    margin-bottom: 1.5rem;
                }

                .back-link {
                    text-decoration: none;
                    color: var(--text-light);
                    font-weight: 500;
                    display: flex;
                    align-items: center;
                    gap: 0.5rem;
                    transition: color 0.2s;
                }

                .back-link:hover {
                    color: var(--primary);
                }

                .card {
                    background: var(--white);
                    padding: 2rem;
                    border-radius: 12px;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
                    margin-bottom: 2rem;
                }

                .step-badge {
                    display: inline-block;
                    background: var(--primary);
                    color: white;
                    border-radius: 50%;
                    width: 24px;
                    height: 24px;
                    text-align: center;
                    line-height: 24px;
                    font-size: 0.85rem;
                    margin-right: 0.5rem;
                }

                .nav-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                    gap: 1rem;
                    margin-bottom: 2rem;
                }

                .nav-card {
                    background: var(--white);
                    padding: 1rem;
                    border-radius: 8px;
                    border: 1px solid var(--border);
                    text-decoration: none;
                    color: var(--text);
                    font-weight: 500;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    transition: all 0.2s;
                }

                .nav-card:hover {
                    border-color: var(--primary);
                    color: var(--primary);
                    transform: translateY(-2px);
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
                }

                code {
                    background: #f1f5f9;
                    padding: 0.2rem 0.4rem;
                    border-radius: 4px;
                    font-family: monospace;
                    color: #be185d;
                    font-size: 0.9em;
                }

                .tip {
                    background: #eff6ff;
                    border-left: 4px solid var(--primary);
                    padding: 1rem;
                    border-radius: 0 4px 4px 0;
                    margin: 1rem 0;
                    font-size: 0.95rem;
                }
            </style>
        </head>

        <body>

            <div class="container">
                <header>
                    <div>
                        <h1>Help Guidelines</h1>
                        <p style="color: var(--text-light);">Staff Manual for Resort Reservation System</p>
                    </div>
                    <a href="index.jsp" class="back-link">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none"
                            stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="19" y1="12" x2="5" y2="12"></line>
                            <polyline points="12 19 5 12 12 5"></polyline>
                        </svg>
                        Back to Dashboard
                    </a>
                </header>

                <!-- Quick Navigation -->
                <div class="nav-grid">
                    <a href="#guests" class="nav-card">
                        Manage Guests <span>&darr;</span>
                    </a>
                    <a href="#reservations" class="nav-card">
                        Reservations <span>&darr;</span>
                    </a>
                    <a href="#billing" class="nav-card">
                        Billing & Taxes <span>&darr;</span>
                    </a>
                </div>

                <!-- 1. Guest Management -->
                <div id="guests" class="card">
                    <h2>1. Guest Management</h2>
                    <p>The <strong>Guest</strong> module allows you to register frequent or new visitors before creating
                        a reservation. This enables faster booking flows.</p>

                    <h3>How to register a new guest:</h3>
                    <ol>
                        <li>Navigate to the <strong>Manage Guests</strong> page from the dashboard.</li>
                        <li>Fill in the form on the right side:
                            <ul>
                                <li><strong>Contact Number:</strong> Must be unique. This is used for searching.</li>
                                <li><strong>Name:</strong> Full legal name.</li>
                                <li><strong>Address:</strong> Permanent address (optional but recommended).</li>
                            </ul>
                        </li>
                        <li>Click the <strong>Register Guest</strong> button.</li>
                    </ol>

                    <div class="tip">
                        <strong>Tip:</strong> You can edit a guest's details by searching for their contact number and
                        clicking the "Edit" button next to their name in the list.
                    </div>
                </div>

                <!-- 2. Reservation System -->
                <div id="reservations" class="card">
                    <h2>2. Making Reservations</h2>
                    <p>The <strong>Reservation</strong> module is the core of the system. It handles room availability
                        and booking dates.</p>

                    <h3>Workflow for a new booking:</h3>
                    <ol>
                        <li>Go to <strong>Reservations</strong>.</li>
                        <li><strong>Enter Guest Details:</strong> If the guest is already registered, searching their
                            number might help (future feature). For now, enter their Name and Contact.</li>
                        <li><strong>Select Room:</strong>
                            <ul>
                                <li>The dropdown only shows rooms that are <em>Active</em>.</li>
                                <li>Rooms already booked for specific dates might still appear in the list globally, but
                                    the system validates dates upon submission (logic dependent).</li>
                                <li>Look for the price per night displayed in the dropdown (e.g.,
                                    <code>Room 101 - Deluxe ($150.0)</code>).</li>
                            </ul>
                        </li>
                        <li><strong>Choose Dates:</strong> Select Check-in and Check-out dates.</li>
                        <li>Click <strong>Confirm Booking</strong>.</li>
                    </ol>

                    <h3>Modifying a stay:</h3>
                    <p>Click "Edit" on any reservation in the table. You can change dates or move the guest to a
                        different room. The system will automatically update the total cost calculation when you
                        generate the bill.</p>
                </div>

                <!-- 3. Billing -->
                <div id="billing" class="card">
                    <h2>3. Billing & Invoices</h2>
                    <p>Finalize a guest's stay by generating an official invoice.</p>

                    <h3>Generating a Bill:</h3>
                    <ol>
                        <li>In the <strong>Reservations</strong> table, find the specific reservation.</li>
                        <li>Click the purple <strong>Bill</strong> button in the Actions column.</li>
                        <li>The system will calculate:
                            <ul>
                                <li><strong>Room Charges:</strong> Rate &times; Number of Nights.</li>
                                <li><strong>Tax:</strong> A fixed 10% service tax.</li>
                            </ul>
                        </li>
                        <li>You will be redirected to the <strong>Invoice View</strong>.</li>
                    </ol>

                    <h3>Printing:</h3>
                    <p>On the Invoice page, click the blue <strong>Print Invoice</strong> button. This opens the
                        browser's print dialog. The sidebar and buttons will be hidden automatically on the printed
                        paper.</p>
                </div>

                <!-- Support -->
                <div class="card" style="border-left: 4px solid var(--primary-dark);">
                    <h2>Need Technical Support?</h2>
                    <p>If you encounter database errors, "404 Not Found" issues, or incorrect calculations, please
                        contact the IT Administrator immediately.</p>
                    <p><strong>Admin Contact:</strong> admin@oceanview.com | Ext: 9999</p>
                </div>

            </div>

        </body>

        </html>