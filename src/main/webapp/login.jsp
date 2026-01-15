<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
// Security: Prevent back button access
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ocean View Resort | Login</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            margin: 0;
            padding: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: url('https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&q=80&w=1920') no-repeat center center fixed;
            background-size: cover;
            position: relative;
            overflow: hidden;
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
        }

        body::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(2, 6, 23, 0.85) 0%, rgba(2, 6, 23, 0.45) 100%);
            z-index: 1;
        }

        .login-card {
            position: relative;
            z-index: 10;
            width: 90%;
            max-width: 440px;
            padding: 3rem 2.5rem;
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: var(--radius-lg);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.6);
            animation: fadeInScale 0.6s cubic-bezier(0.16, 1, 0.3, 1);
            text-align: center;
        }

        @keyframes fadeInScale {
            from {
                opacity: 0;
                transform: scale(0.95) translateY(10px);
            }

            to {
                opacity: 1;
                transform: scale(1) translateY(0);
            }
        }

        .login-header {
            margin-bottom: 2.5rem;
        }

        .logo-box {
            width: 64px;
            height: 64px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            color: var(--accent);
            font-size: 1.75rem;
        }

        .login-header h1 {
            color: white;
            font-size: 1.875rem;
            font-weight: 800;
            letter-spacing: -0.025em;
            margin-bottom: 0.5rem;
        }

        .login-header p {
            color: rgba(255, 255, 255, 0.5);
            font-size: 1.05rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
            text-align: left;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.6rem;
            color: rgba(255, 255, 255, 0.85);
            font-size: 0.875rem;
            font-weight: 600;
            margin-left: 0.25rem;
        }

        .input-wrapper {
            position: relative;
        }

        .input-wrapper i {
            position: absolute;
            left: 1.15rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--accent);
            transition: all 0.3s;
            pointer-events: none;
        }

        .input-wrapper input {
            width: 100%;
            padding: 0.875rem 1.15rem 0.875rem 3.15rem;
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: var(--radius-md);
            color: white;
            font-size: 1rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            outline: none;
        }

        .input-wrapper input::placeholder {
            color: rgba(255, 255, 255, 0.25);
        }

        .input-wrapper input:focus {
            background: rgba(255, 255, 255, 0.08);
            border-color: var(--accent);
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.15);
        }

        .input-wrapper input:focus+i {
            color: var(--accent);
            transform: translateY(-50%) scale(1.1);
        }

        .btn-submit {
            width: 100%;
            padding: 1rem;
            background: var(--accent);
            color: white;
            border: none;
            border-radius: var(--radius-md);
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            margin-top: 1.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.75rem;
            letter-spacing: 0.025em;
        }

        .btn-submit:hover {
            background: #2563eb;
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(37, 99, 235, 0.3);
        }

        .btn-submit:active {
            transform: translateY(0);
        }

        .btn-submit:disabled {
            opacity: 0.65;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        #error-msg {
            background: rgba(239, 68, 68, 0.15);
            border: 1px solid rgba(239, 68, 68, 0.3);
            color: #fca5a5;
            padding: 0.875rem;
            border-radius: var(--radius-md);
            margin-bottom: 2rem;
            font-size: 0.9rem;
            display: none;
            text-align: center;
            animation: shake 0.4s cubic-bezier(.36, .07, .19, .97) both;
        }

        @keyframes shake {

            10%,
            90% {
                transform: translate3d(-1px, 0, 0);
            }

            20%,
            80% {
                transform: translate3d(2px, 0, 0);
            }

            30%,
            50%,
            70% {
                transform: translate3d(-3px, 0, 0);
            }

            40%,
            60% {
                transform: translate3d(3px, 0, 0);
            }
        }

        .footer-note {
            margin-top: 2.5rem;
            color: rgba(255, 255, 255, 0.35);
            font-size: 0.8rem;
            letter-spacing: 0.05em;
            text-transform: uppercase;
        }
    </style>
</head>

<body>

    <div class="login-card">
        <div class="login-header">
            <div class="logo-box">
                <i class="fas fa-umbrella-beach"></i>
            </div>
            <h1>Ocean View</h1>
            <p>Resource Management Portal</p>
        </div>

        <% if(request.getAttribute("errorMessage") !=null) { %>
            <div class="error-static"
                style="background: rgba(239, 68, 68, 0.15); border: 1px solid rgba(239, 68, 68, 0.3); color: #fca5a5; padding: 0.875rem; border-radius: var(--radius-md); margin-bottom: 2rem; font-size: 0.9rem; text-align: center;">
                <%= request.getAttribute("errorMessage") %>
            </div>
            <% } %>

                <div id="error-msg"></div>

                <form id="loginForm" onsubmit="handleLogin(event)">
                    <div class="form-group">
                        <label for="login-username">Username</label>
                        <div class="input-wrapper">
                            <input type="text" id="login-username" name="username" required
                                placeholder="system.admin" autocomplete="username">
                            <i class="fas fa-user-shield"></i>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="login-password">Password</label>
                        <div class="input-wrapper">
                            <input type="password" id="login-password" name="password" required
                                placeholder="••••••••" autocomplete="current-password">
                            <i class="fas fa-lock"></i>
                        </div>
                    </div>

                    <button type="submit" class="btn-submit" id="loginBtn">
                        <span>Sign In to Dashboard</span>
                        <i class="fas fa-chevron-right"></i>
                    </button>
                </form>

                <div class="footer-note">
                    Authorized Access Only
                </div>
    </div>

    <script>
        function handleLogin(event) {
            event.preventDefault();
            const form = event.target;
            const errorDiv = document.getElementById('error-msg');
            const staticError = document.querySelector('.error-static');
            const btn = document.getElementById('loginBtn');
            const btnText = btn.querySelector('span');
            const btnIcon = btn.querySelector('i');

            // Reset UI
            if (staticError) staticError.style.display = 'none';
            errorDiv.style.display = 'none';
            errorDiv.textContent = '';
            btn.disabled = true;
            btnText.textContent = 'Verifying...';
            btnIcon.className = 'fas fa-circle-notch fa-spin';

            const params = new URLSearchParams();
            params.append('action', 'login');
            params.append('username', form.username.value);
            params.append('password', form.password.value);

            fetch('auth', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: params
            })
                .then(response => response.json())
                .then(data => {
                    if (data.status === 'success') {
                        btnText.textContent = 'Redirecting...';
                        window.location.href = data.redirectUrl;
                    } else {
                        errorDiv.textContent = data.message || 'Authentication Failed';
                        errorDiv.style.display = 'block';
                        btn.disabled = false;
                        btnText.textContent = 'Sign In to Dashboard';
                        btnIcon.className = 'fas fa-chevron-right';
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    errorDiv.textContent = 'Network error. Please try again.';
                    errorDiv.style.display = 'block';
                    btn.disabled = false;
                    btnText.textContent = 'Sign In to Dashboard';
                    btnIcon.className = 'fas fa-chevron-right';
                });
        }
    </script>

</body>

</html>