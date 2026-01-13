<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Resort Invoice | Loading...</title>
    <style>
        :root {
            --primary-color: #0d6efd;
            --text-dark: #212529;
            --text-muted: #6c757d;
            --bg-light: #f8f9fa;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #e9ecef;
            color: var(--text-dark);
            margin: 0;
            padding: 40px 0;
        }

        .invoice-card {
            background: white;
            width: 800px;
            margin: 0 auto;
            padding: 50px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
        }

        .invoice-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid var(--bg-light);
            padding-bottom: 20px;
            margin-bottom: 30px;
        }

        .brand-logo {
            font-size: 28px;
            font-weight: bold;
            color: var(--primary-color);
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        .invoice-title {
            text-align: right;
        }

        .invoice-title h2 {
            margin: 0;
            color: var(--text-muted);
            font-weight: 300;
        }

        .details-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 40px;
        }

        .detail-item strong {
            display: block;
            color: var(--text-muted);
            font-size: 0.85rem;
            text-transform: uppercase;
            margin-bottom: 5px;
        }

        .detail-item span {
            font-size: 1.1rem;
            font-weight: 500;
        }

        .summary-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }

        .summary-table th,
        .summary-table td {
            text-align: right;
            padding: 15px;
            border-bottom: 1px solid var(--bg-light);
        }

        .summary-table th {
            text-align: left;
            background-color: var(--bg-light);
            color: var(--text-muted);
            font-weight: 600;
        }

        .summary-table td:first-child {
            text-align: left;
        }

        .total-row td {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--primary-color);
            border-top: 2px solid var(--text-dark);
        }

        .actions {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 50px;
        }

        .btn {
            padding: 10px 25px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            border: none;
        }

        .btn-primary {
            background-color: var(--primary-color);
            color: white;
        }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }

        .btn:hover {
            opacity: 0.9;
        }

        .error-msg {
            color: red;
            text-align: center;
            font-weight: bold;
            margin-top: 20px;
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
            }

            .actions {
                display: none;
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
            <a href="reservations.jsp" class="btn btn-secondary">Back to Dashboard</a>
            <button onclick="window.print()" class="btn btn-primary">Print Invoice</button>
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