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
        <html>

        <head>
            <title>Staff Dashboard</title>
            <style>
                body {
                    font-family: sans-serif;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    background-color: #f3f4f6;
                }

                .card {
                    background: white;
                    padding: 2rem;
                    border-radius: 8px;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                    text-align: center;
                }

                h1 {
                    color: #006994;
                }
            </style>
        </head>

        <body>
            <div class="card">
                <h1>Welcome, ${sessionScope.username}!</h1>
                <p style="color: #6b7280; margin-bottom: 2rem;">Staff Dashboard</p>

                <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 1rem; text-align: left;">
                        <div style="border: 1px solid #e5e7eb; padding: 1.5rem; border-radius: 8px; transition: all 0.2s;"
                            onmouseover="this.style.borderColor='#006994'; this.style.backgroundColor='#f0f9ff';"
                            onmouseout="this.style.borderColor='#e5e7eb'; this.style.backgroundColor='transparent';">
                            <h3 style="color: #006994; margin: 0 0 0.5rem 0;">Sample Index Page</h3>
                            <p style="font-size: 0.9rem; color: #6b7280; margin: 0;">Under Construction</p>
                        </div>
                </div>

                <br><br>
                <a href="../login.jsp" style="color: #dc2626; text-decoration: none; font-weight: 500;">Logout</a>
            </div>
        </body>

        </html>