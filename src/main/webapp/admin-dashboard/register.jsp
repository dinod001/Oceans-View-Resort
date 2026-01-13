<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Session Check - Admin Only
    if (session.getAttribute("username") == null ||
            !"Admin".equalsIgnoreCase((String) session.getAttribute("role"))) {

        response.sendRedirect("../login.jsp");
        return;
    }
%>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Admin Dashboard | Register User</title>
            <style>
                :root {
                    --primary: #006994;
                    --primary-dark: #004e70;
                    --white: #ffffff;
                    --gray-100: #f3f4f6;
                    --text-main: #1f2937;
                }

                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                    font-family: 'Segoe UI', system-ui, sans-serif;
                }

                body {
                    background-color: var(--gray-100);
                    min-height: 100vh;
                    padding: 2rem;
                    display: flex;
                    justify-content: center;
                    align-items: flex-start;
                }

                .container {
                    width: 100%;
                    max-width: 500px;
                    background: var(--white);
                    padding: 2rem;
                    border-radius: 12px;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                }

                h2 {
                    color: var(--primary);
                    margin-bottom: 1.5rem;
                    text-align: center;
                }

                .form-group {
                    margin-bottom: 1.25rem;
                }

                .form-group label {
                    display: block;
                    margin-bottom: 0.5rem;
                    color: var(--text-main);
                    font-weight: 500;
                }

                .form-group input,
                .form-group select {
                    width: 100%;
                    padding: 0.75rem;
                    border: 1px solid #e5e7eb;
                    border-radius: 8px;
                    font-size: 1rem;
                }

                .btn {
                    width: 100%;
                    padding: 0.875rem;
                    background: var(--primary);
                    color: var(--white);
                    border: none;
                    border-radius: 8px;
                    font-size: 1rem;
                    font-weight: 600;
                    cursor: pointer;
                }

                .btn:hover {
                    background: var(--primary-dark);
                }

                .alert {
                    padding: 1rem;
                    border-radius: 8px;
                    margin-bottom: 1rem;
                    text-align: center;
                }

                .alert-success {
                    background-color: #d1fae5;
                    color: #065f46;
                }

                .alert-error {
                    background-color: #fee2e2;
                    color: #991b1b;
                }
            </style>
        </head>

        <body>

            <div class="container">
                <h2>Register New User</h2>

                <%-- Display Messages --%>
                    <% if(request.getAttribute("successMessage") !=null) { %>
                        <div class="alert alert-success">
                            <%= request.getAttribute("successMessage") %>
                        </div>
                        <% } %>

                            <% if(request.getAttribute("errorMessage") !=null) { %>
                                <div class="alert alert-error">
                                    <%= request.getAttribute("errorMessage") %>
                                </div>
                                <% } %>

                                    <form action="${pageContext.request.contextPath}/auth" method="post">
                                        <input type="hidden" name="action" value="register">

                                        <div class="form-group">
                                            <label for="username">Username</label>
                                            <input type="text" id="username" name="username" required
                                                placeholder="Enter username">
                                        </div>

                                        <div class="form-group">
                                            <label for="password">Password</label>
                                            <input type="password" id="password" name="password" required
                                                placeholder="Enter password">
                                        </div>

                                        <div class="form-group">
                                            <label for="role">Role</label>
                                            <select id="role" name="role">
                                                <option value="Staff">Staff</option>
                                                <option value="Admin">Admin</option>
                                            </select>
                                        </div>

                                        <button type="submit" class="btn">Register User</button>
                                    </form>
            </div>

        </body>

        </html>