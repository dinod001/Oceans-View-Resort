<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Ocean View Resort | Access</title>
        <style>
            :root {
                --primary: #006994;
                --primary-dark: #004e70;
                --accent: #00a8cc;
                --white: #ffffff;
                --gray-100: #f3f4f6;
                --gray-200: #e5e7eb;
                --text-main: #1f2937;
                --text-muted: #6b7280;
            }

            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            }

            body {
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                background: linear-gradient(135deg, #e0f7fa 0%, #80deea 100%);
                background-image: url('https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&q=80');
                background-size: cover;
                background-position: center;
                background-blend-mode: overlay;
            }

            .container {
                width: 100%;
                max-width: 400px;
                padding: 2rem;
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(10px);
                border-radius: 16px;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
                transform: translateY(0);
                transition: transform 0.3s ease;
            }

            .header {
                text-align: center;
                margin-bottom: 2rem;
            }

            .header h1 {
                color: var(--primary);
                font-size: 2rem;
                font-weight: 700;
                margin-bottom: 0.5rem;
            }

            .header p {
                color: var(--text-muted);
                font-size: 0.95rem;
            }

            .form-group {
                margin-bottom: 1.25rem;
            }

            .form-group label {
                display: block;
                margin-bottom: 0.5rem;
                color: var(--text-main);
                font-weight: 500;
                font-size: 0.9rem;
            }

            .form-group input,
            .form-group select {
                width: 100%;
                padding: 0.75rem 1rem;
                border: 1px solid var(--gray-200);
                border-radius: 8px;
                font-size: 1rem;
                transition: all 0.2s;
                outline: none;
            }

            .form-group input:focus,
            .form-group select:focus {
                border-color: var(--accent);
                box-shadow: 0 0 0 3px rgba(0, 168, 204, 0.1);
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
                transition: background 0.2s;
            }

            .btn:hover {
                background: var(--primary-dark);
            }

            .toggle-text {
                text-align: center;
                margin-top: 1.5rem;
                color: var(--text-muted);
                font-size: 0.9rem;
            }

            .toggle-text a {
                color: var(--primary);
                text-decoration: none;
                font-weight: 600;
                cursor: pointer;
            }

            .toggle-text a:hover {
                text-decoration: underline;
            }

            .hidden {
                display: none;
            }

            #error-msg,
            #success-msg {
                padding: 0.75rem;
                border-radius: 8px;
                margin-bottom: 1rem;
                font-size: 0.9rem;
                text-align: center;
            }

            .error {
                background-color: #fee2e2;
                color: #991b1b;
                border: 1px solid #fecaca;
            }

            .success {
                background-color: #d1fae5;
                color: #065f46;
                border: 1px solid #a7f3d0;
            }
        </style>
    </head>

    <body>

        <div class="container">
            <!-- Login Form -->
            <div id="login-section">
                <div class="header">
                    <h1>Welcome Back</h1>
                    <p>Sign in to access your dashboard</p>
                </div>

                <%-- Display Messages --%>
                    <% if(request.getAttribute("errorMessage") !=null) { %>
                        <div class="error"
                            style="padding: 0.75rem; border-radius: 8px; margin-bottom: 1rem; text-align: center; background-color: #fee2e2; color: #991b1b; border: 1px solid #fecaca;">
                            <%= request.getAttribute("errorMessage") %>
                        </div>
                        <% } %>

                            <form action="auth" method="post">
                                <input type="hidden" name="action" value="login">

                                <div class="form-group">
                                    <label for="login-username">Username</label>
                                    <input type="text" id="login-username" name="username" required
                                        placeholder="Enter your username">
                                </div>
                                <div class="form-group">
                                    <label for="login-password">Password</label>
                                    <input type="password" id="login-password" name="password" required
                                        placeholder="Enter your password">
                                </div>
                                <button type="submit" class="btn">Sign In</button>
                            </form>
            </div>
        </div>

    </body>

    </html>