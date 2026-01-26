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
        return;
    }
%>


<!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <title>Resort Invoice | Loading...</title>
            <link rel="stylesheet" href="../css/style.css">
            <style>
                body {
                    background-color: var(--bg);
                    margin: 0;
                    padding: 4rem 0;
                }

                .invoice-card {
                    background: white;
                    width: 850px;
                    margin: 0 auto;
                    padding: 4rem;
                    box-shadow: var(--shadow-xl);
                    border-radius: var(--radius-lg);
                    color: #2d3748;
                }

                .invoice-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    border-bottom: 2px solid #edf2f7;
                    padding-bottom: 2rem;
                    margin-bottom: 3rem;
                }

                .brand-logo {
                    font-size: 2rem;
                    font-weight: 800;
                    color: var(--primary);
                    text-transform: uppercase;
                    letter-spacing: 1px;
                }

                .invoice-title {
                    text-align: right;
                }

                .invoice-title h2 {
                    margin: 0;
                    color: #a0aec0;
                    font-weight: 400;
                    font-size: 1.5rem;
                }

                .details-grid {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 2rem;
                    margin-bottom: 4rem;
                }

                .detail-item strong {
                    display: block;
                    color: #718096;
                    font-size: 0.75rem;
                    text-transform: uppercase;
                    letter-spacing: 0.05em;
                    margin-bottom: 0.5rem;
                }

                .detail-item span {
                    font-size: 1.1rem;
                    font-weight: 600;
                }

                .summary-table {
                    width: 100%;
                    border-collapse: collapse;
                    margin-bottom: 3rem;
                }

                .summary-table th,
                .summary-table td {
                    text-align: right;
                    padding: 1.25rem;
                    border-bottom: 1px solid #edf2f7;
                }

                .summary-table th {
                    text-align: left;
                    background-color: #f7fafc;
                    color: #4a5568;
                    font-weight: 700;
                    font-size: 0.875rem;
                    text-transform: uppercase;
                }

                .summary-table td:first-child {
                    text-align: left;
                }

                .total-row td {
                    font-size: 1.75rem;
                    font-weight: 800;
                    color: var(--primary);
                    border-top: 2px solid #2d3748;
                    padding-top: 1.5rem;
                }

                .actions {
                    display: flex;
                    justify-content: flex-end;
                    gap: 1rem;
                    margin-top: 4rem;
                }

                .actions .btn {
                    width: auto;
                }

                @media print {
                    body {
                        background: white;
                        padding: 0;
                    }

                    .invoice-card {
                        box-shadow: none;
                        width: 100%;
                        padding: 0;
                        border-radius: 0;
                    }

                    .actions {
                        display: none;
                    }
                }

                /* Mobile Responsive Fix */
                @media screen and (max-width: 900px) {
                    .invoice-card {
                        width: 95%;
                        padding: 1.5rem;
                        margin: 1rem auto;
                    }

                    .invoice-header {
                        flex-direction: column;
                        text-align: center;
                        gap: 1rem;
                    }

                    .invoice-title {
                        text-align: center;
                    }

                    .details-grid {
                        grid-template-columns: 1fr;
                        gap: 1rem;
                        text-align: center;
                    }

                    .detail-item,
                    .detail-item[style] {
                        text-align: center !important;
                    }

                    .summary-table th,
                    .summary-table td {
                        padding: 0.75rem;
                    }

                    .actions {
                        flex-direction: column;
                    }

                    .actions .btn {
                        width: 100%;
                    }
                }
            </style>
        </head>

        <body>

            <div class="invoice-card" id="invoiceCard">
                <div class="invoice-header">
                    <div class="brand-logo">Ocean View Resort</div>
                    <div class="invoice-title">
                        <h2>INVOICE</h2>
                        <p id="billId">#000000</p>
                    </div>
                </div>

                <div class="details-grid">
                    <div class="detail-item">
                        <strong>Billed To Reservation</strong>
                        <span id="reservationId">#---</span>
                    </div>
                    <div class="detail-item" style="text-align: right;">
                        <strong>Date Generated</strong>
                        <span id="date">...</span>
                    </div>
                </div>

                <table class="summary-table">
                    <thead>
                        <tr>
                            <th>Description</th>
                            <th>Amount (LKR)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Room Charges (Calculated via Stay Duration)</td>
                            <td id="roomAmount">0.00</td>
                        </tr>
                        <tr>
                            <td>Tax (10%)</td>
                            <td id="taxAmount">0.00</td>
                        </tr>
                        <tr class="total-row">
                            <td>TOTAL DUE</td>
                            <td id="totalAmount">LKR 0.00</td>
                        </tr>
                    </tbody>
                </table>

                <div style="text-align: center; color: var(--text-muted); font-size: 0.9rem; margin-top: 50px;">
                    <p>Thank you for choosing Ocean View Resort!</p>
                    <p>Contact us: info@oceanviewresort.com | +94 77 123 4567</p>
                </div>

                <div class="actions">
                    <a href="reservations.jsp" class="btn btn-outline">
                        <i class="fas fa-arrow-left"></i> Back to Dashboard
                    </a>
                    <button onclick="window.print()" class="btn btn-primary">
                        <i class="fas fa-print"></i> Print Invoice
                    </button>
                </div>
            </div>

            <!-- Hidden form for generate request if opened via POST emulation by fetch isn't applicable -->

            <script>
                document.addEventListener('DOMContentLoaded', () => {
                    // Logic:
                    // 1. If URL has ?id=..., load that bill.
                    // 2. If came from generating a bill (via localStorage? URL param?), load it.
                    // Actually, existing flow was POST -> Forward to JSP.
                    // New flow: User clicks "Bill" button on reservations.jsp -> calls API -> gets success -> redirects here with ?id=... or passes data.
                    // Let's assume the new flow is:
                    // 1. reservations.jsp: clicks 'Bill'
                    // 2. fetch POST /billing?action=generate...
                    // 3. API returns JSON { status: 'success', data: { billID: 123, ... } }
                    // 4. JS redirects to bill.jsp?id=123

                    const urlParams = new URLSearchParams(window.location.search);
                    const billId = urlParams.get('id');

                    if (billId) {
                        fetch(`../billing?action=view&id=\${billId}`)
                            .then(res => res.json())
                            .then(data => {
                                if (data.status === 'error') {
                                    document.body.innerHTML = `<h1 class="error-msg">\${data.message}</h1>`;
                                    return;
                                }
                                // If direct object returned
                                renderBill(data);
                            })
                            .catch(e => {
                                console.error(e);
                                document.body.innerHTML = `<h1 class="error-msg">Failed to load bill</h1>`;
                            });
                    } else {
                        document.body.innerHTML = `<h1 class="error-msg">No Bill ID specified</h1>`;
                    }
                });

                function renderBill(bill) {
                    document.title = `Resort Invoice | Bill #\${bill.billID}`;
                    document.getElementById('billId').textContent = '#' + String(bill.billID).padStart(6, '0');
                    document.getElementById('reservationId').textContent = '#' + bill.resNo;
                    document.getElementById('date').textContent = new Date().toDateString(); // Or bill date if available in model

                    const amount = parseFloat(bill.totalAmount);
                    const tax = parseFloat(bill.tax);
                    const total = amount + tax;

                    document.getElementById('roomAmount').textContent = amount.toFixed(2);
                    document.getElementById('taxAmount').textContent = tax.toFixed(2);
                    document.getElementById('totalAmount').textContent = 'LKR ' + total.toFixed(2);
                }
            </script>
        </body>

        </html>