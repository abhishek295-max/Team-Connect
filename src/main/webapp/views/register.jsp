<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session != null && session.getAttribute("userId") != null) {
        response.sendRedirect(request.getContextPath() + "/chat");
        return;
    }

    String error = request.getParameter("error");
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register | Online Chat System</title>
    <style>
        :root {
            --bg-a: #17131a;
            --bg-b: #241a18;
            --glass: rgba(255, 255, 255, 0.08);
            --glass-strong: rgba(255, 255, 255, 0.14);
            --border: rgba(255, 255, 255, 0.16);
            --text: #fff7f0;
            --muted: rgba(255, 247, 240, 0.72);
            --accent: #f4b860;
            --accent-2: #44d8c0;
            --accent-3: #ff7d6b;
            --success: #3fe09a;
            --danger: #ff7e7e;
            --shadow: 0 24px 70px rgba(0, 0, 0, 0.32);
        }

        * { box-sizing: border-box; }

        html, body {
            margin: 0;
            min-height: 100%;
            font-family: "Segoe UI", Arial, sans-serif;
            color: var(--text);
            background:
                linear-gradient(135deg, rgba(244, 184, 96, 0.14), transparent 35%),
                linear-gradient(225deg, rgba(68, 216, 192, 0.12), transparent 30%),
                linear-gradient(180deg, var(--bg-a), var(--bg-b));
        }

        body { min-height: 100vh; }

        a { color: inherit; text-decoration: none; }

        .page {
            min-height: 100vh;
            padding: 18px;
        }

        .shell {
            width: min(1180px, 100%);
            min-height: calc(100vh - 36px);
            margin: 0 auto;
            display: grid;
            grid-template-columns: 0.96fr 1.04fr;
            gap: 18px;
        }

        .panel {
            border: 1px solid var(--border);
            border-radius: 28px;
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        .left {
            padding: 34px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            gap: 24px;
        }

        .brand-row {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .brand-badge {
            width: 50px;
            height: 50px;
            border-radius: 16px;
            display: grid;
            place-items: center;
            font-weight: 800;
            color: #06131f;
            background: linear-gradient(145deg, var(--accent-2), var(--accent));
            box-shadow: 0 12px 28px rgba(68, 216, 192, 0.22);
        }

        .brand-row strong {
            display: block;
            font-size: 18px;
        }

        .brand-row span {
            display: block;
            margin-top: 3px;
            color: var(--muted);
            font-size: 13px;
        }

        .hero {
            max-width: 620px;
        }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 9px 14px;
            width: fit-content;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.14);
            color: var(--muted);
            font-size: 13px;
        }

        .eyebrow i {
            width: 8px;
            height: 8px;
            border-radius: 999px;
            background: var(--accent-2);
            animation: pulse 1.8s infinite;
        }

        h1 {
            margin: 18px 0 0;
            font-size: clamp(40px, 5vw, 62px);
            line-height: 0.98;
        }

        .hero p {
            margin: 16px 0 0;
            color: var(--muted);
            line-height: 1.75;
            font-size: 16px;
        }

        .metrics {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
            margin-top: 22px;
        }

        .metric {
            padding: 16px;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255, 255, 255, 0.12);
        }

        .metric span {
            display: block;
            color: var(--muted);
            font-size: 13px;
        }

        .metric strong {
            display: block;
            margin-top: 8px;
            font-size: 21px;
        }

        .auth-right {
            padding: 28px;
            display: flex;
            align-items: center;
        }

        .auth-card {
            width: 100%;
            padding: 30px;
            border-radius: 24px;
            background: rgba(7, 17, 31, 0.45);
            border: 1px solid rgba(255, 255, 255, 0.12);
        }

        .auth-card h2 {
            margin: 0;
            font-size: 28px;
        }

        .auth-card p {
            margin: 10px 0 0;
            color: var(--muted);
            line-height: 1.7;
        }

        .notice {
            margin-top: 18px;
            padding: 12px 14px;
            border-radius: 16px;
            border: 1px solid rgba(255, 126, 126, 0.18);
            background: rgba(255, 126, 126, 0.09);
            color: var(--danger);
        }

        .form {
            display: grid;
            gap: 14px;
            margin-top: 22px;
        }

        .field {
            display: grid;
            gap: 8px;
        }

        .field label {
            color: var(--muted);
            font-size: 13px;
            font-weight: 600;
        }

        .field input {
            width: 100%;
            min-height: 48px;
            border-radius: 14px;
            padding: 0 14px;
            border: 1px solid rgba(255, 255, 255, 0.15);
            background: rgba(255, 255, 255, 0.07);
            color: var(--text);
            outline: none;
            transition: border-color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease;
        }

        .field input:focus {
            border-color: rgba(244, 184, 96, 0.65);
            box-shadow: 0 0 0 4px rgba(244, 184, 96, 0.12);
        }

        .button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 48px;
            border: 0;
            border-radius: 14px;
            cursor: pointer;
            transition: transform 0.18s ease, box-shadow 0.18s ease, opacity 0.18s ease;
            white-space: nowrap;
        }

        .button:hover {
            transform: translateY(-1px);
        }

        .button-primary {
            background: linear-gradient(145deg, var(--accent), var(--accent-3));
            color: #06131f;
            font-weight: 700;
            box-shadow: 0 14px 26px rgba(244, 184, 96, 0.18);
        }

        .button-ghost {
            background: rgba(255, 255, 255, 0.06);
            color: var(--text);
            border: 1px solid rgba(255, 255, 255, 0.14);
        }

        .action-row {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-top: 18px;
        }

        .micro {
            margin-top: 18px;
            color: var(--muted);
            line-height: 1.7;
        }

        .micro a {
            color: #ffffff;
            text-decoration: underline;
            text-underline-offset: 2px;
        }

        .feature-list {
            display: grid;
            gap: 12px;
            margin-top: 24px;
        }

        .feature {
            padding: 16px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255, 255, 255, 0.10);
        }

        .feature strong {
            display: block;
            margin-bottom: 6px;
            font-size: 14px;
        }

        .feature span {
            color: var(--muted);
            font-size: 14px;
            line-height: 1.55;
        }

        .pulse-bar {
            height: 10px;
            border-radius: 999px;
            margin-top: 18px;
            background:
                linear-gradient(90deg, rgba(244, 184, 96, 0.35), rgba(68, 216, 192, 0.9), rgba(244, 184, 96, 0.35));
            background-size: 200% 100%;
            animation: sweep 3s linear infinite;
        }

        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(68, 216, 192, 0.34); }
            70% { box-shadow: 0 0 0 10px rgba(68, 216, 192, 0); }
            100% { box-shadow: 0 0 0 0 rgba(68, 216, 192, 0); }
        }

        @keyframes sweep {
            from { background-position: 0 50%; }
            to { background-position: 200% 50%; }
        }

        @media (max-width: 1040px) {
            .shell {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 680px) {
            .page {
                padding: 12px;
            }

            .left,
            .auth-right,
            .auth-card {
                padding: 20px;
            }

            .metrics {
                grid-template-columns: 1fr;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
                animation-duration: 0.01ms !important;
                animation-iteration-count: 1 !important;
                transition-duration: 0.01ms !important;
            }
        }
    </style>
</head>
<body>
<div class="page">
    <div class="shell">
        <section class="panel left">
            <div>
                <div class="brand-row">
                    <div class="brand-badge">OC</div>
                    <div>
                        <strong>Online Chat System</strong>
                        <span>Glassmorphism registration and onboarding</span>
                    </div>
                </div>

                <div class="hero">
                    <div class="eyebrow"><i></i> Create your account in one step</div>
                    <h1>Build your chat profile.</h1>
                    <p>
                        Register once to open the dashboard, pick contacts, and start threaded conversations with a
                        polished interface that feels close to a real product.
                    </p>

                    <div class="metrics">
                        <div class="metric">
                            <span>Security</span>
                            <strong>Hashed</strong>
                        </div>
                        <div class="metric">
                            <span>Experience</span>
                            <strong>Modern</strong>
                        </div>
                    </div>
                </div>
            </div>

            <div>
                <div class="feature-list">
                    <div class="feature">
                        <strong>Quick onboarding</strong>
                        <span>Get in, create an account, and move directly to the dashboard.</span>
                    </div>
                    <div class="feature">
                        <strong>Clean interface</strong>
                        <span>Glass panels, clear spacing, and responsive inputs keep the form readable.</span>
                    </div>
                </div>
                <div class="pulse-bar"></div>
            </div>
        </section>

        <aside class="panel auth-right">
            <div class="auth-card">
                <h2>Register</h2>
                <p>Create your account to enter the chat workspace.</p>

                <% if ("1".equals(error)) { %>
                <div class="notice">Registration failed. Check the details and try again.</div>
                <% } %>

                <form class="form" action="<%= contextPath %>/register" method="post">
                    <div class="field">
                        <label for="username">Username</label>
                        <input id="username" type="text" name="username" autocomplete="username" required>
                    </div>

                    <div class="field">
                        <label for="email">Email</label>
                        <input id="email" type="email" name="email" autocomplete="email" required>
                    </div>

                    <div class="field">
                        <label for="password">Password</label>
                        <input id="password" type="password" name="password" autocomplete="new-password" required>
                    </div>

                    <button class="button button-primary" type="submit">Create account</button>
                </form>

                <div class="action-row">
                    <a class="button button-ghost" href="<%= contextPath %>/views/login.jsp">Back to login</a>
                </div>

                <p class="micro">Already have an account? <a href="<%= contextPath %>/views/login.jsp">Login here</a>.</p>
            </div>
        </aside>
    </div>
</div>
</body>
</html>


