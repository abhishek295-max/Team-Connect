<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session != null && session.getAttribute("userId") != null) {
        response.sendRedirect(request.getContextPath() + "/chat");
        return;
    }

    String error = request.getParameter("error");
    String registered = request.getParameter("registered");
    String noticeText = null;
    if ("1".equals(registered)) {
        noticeText = "Registration completed successfully. You can sign in now.";
    } else if ("invalid".equals(error) || "1".equals(error)) {
        noticeText = "Invalid username or password.";
    }
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | TeamConnect</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap');

        :root {
            --bg:            #020818;
            --bg-2:          #030E22;
            --text:          #F1F5F9;
            --muted:         #94A3B8;
            --muted-dim:     #64748B;
            --border:        rgba(59, 130, 246, 0.16);
            --shadow:        0 28px 72px rgba(0, 0, 0, 0.65);
            --blue:          #2563EB;
            --blue-mid:      #3B82F6;
            --blue-light:    #60A5FA;
            --blue-glow:     #93C5FD;
            --silver:        #CBD5E1;
            --silver-dim:    #94A3B8;
            --silver-bright: #F1F5F9;
            --success:       #34D399;
            --danger:        #F87171;
            --grad-text:     linear-gradient(120deg, #F1F5F9 10%, #93C5FD 50%, #60A5FA 90%);
        }

        * { box-sizing: border-box; }

        html, body {
            margin: 0; min-height: 100%;
            font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
            color: var(--text);
            background: var(--bg);
            overflow-x: hidden;
        }

        body {
            min-height: 100vh;
            background:
                    radial-gradient(ellipse 90% 60% at 8% -10%, rgba(37,99,235,0.26) 0%, transparent 52%),
                    radial-gradient(ellipse 70% 55% at 94%  8%, rgba(96,165,250,0.15) 0%, transparent 48%),
                    radial-gradient(ellipse 75% 55% at 50% 112%, rgba(59,130,246,0.11) 0%, transparent 55%),
                    linear-gradient(180deg, #020818 0%, #030D20 55%, #020818 100%);
        }

        /* Aurora */
        body::before {
            content: ""; position: fixed; inset: 0; z-index: 0; pointer-events: none;
            background:
                    radial-gradient(ellipse 680px 400px at 12% 22%, rgba(37,99,235,0.09) 0%, transparent 70%),
                    radial-gradient(ellipse 540px 360px at 88% 78%, rgba(96,165,250,0.07) 0%, transparent 70%);
            animation: auroraShift 22s ease-in-out infinite alternate;
        }
        @keyframes auroraShift {
            0%   { transform: translate(0,0) scale(1); }
            50%  { transform: translate(-28px,18px) scale(1.05); }
            100% { transform: translate(22px,-26px) scale(0.97); }
        }

        /* Grid */
        body::after {
            content: ""; position: fixed; inset: 0; z-index: 0; pointer-events: none;
            background-image:
                    linear-gradient(rgba(59,130,246,0.045) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(59,130,246,0.045) 1px, transparent 1px);
            background-size: 70px 70px;
            mask-image: radial-gradient(ellipse 85% 75% at 50% 50%, black 15%, transparent 80%);
        }

        a { color: inherit; text-decoration: none; }

        .page { min-height: 100vh; padding: 18px; position: relative; z-index: 1; }

        .shell {
            width: min(1180px, 100%);
            min-height: calc(100vh - 36px);
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1.05fr 0.95fr;
            gap: 20px;
        }

        .panel {
            border: 1px solid var(--border);
            border-radius: 28px;
            background: rgba(3, 10, 28, 0.74);
            backdrop-filter: blur(26px) saturate(160%);
            -webkit-backdrop-filter: blur(26px) saturate(160%);
            box-shadow: 0 0 0 1px rgba(255,255,255,0.028) inset, var(--shadow);
            overflow: hidden;
            position: relative;
        }
        /* gradient border ring */
        .panel::before {
            content: ""; position: absolute; inset: -1px; border-radius: inherit; padding: 1px;
            background: linear-gradient(135deg, rgba(37,99,235,0.45), rgba(148,163,184,0.18) 45%, rgba(96,165,250,0.3) 100%);
            mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
            -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
            -webkit-mask-composite: xor; mask-composite: exclude; pointer-events: none;
            z-index: 0;
        }

        .left {
            padding: 36px;
            display: flex; flex-direction: column; justify-content: space-between; gap: 24px;
            position: relative; z-index: 1;
        }

        /* glow orb behind left panel */
        .left::after {
            content: ""; position: absolute; bottom: -80px; right: -80px;
            width: 360px; height: 360px;
            background: conic-gradient(from 200deg, rgba(37,99,235,0.28), rgba(96,165,250,0.22), rgba(203,213,225,0.14), rgba(37,99,235,0.28));
            border-radius: 50%; filter: blur(68px); opacity: 0.45;
            animation: float 13s ease-in-out infinite; pointer-events: none;
        }
        @keyframes float {
            0%, 100% { transform: translate3d(0,0,0) rotate(0deg); }
            50%       { transform: translate3d(-16px,-12px,0) rotate(5deg); }
        }

        .brand-row { display: flex; align-items: center; gap: 14px; }
        .brand-badge {
            width: 50px; height: 50px; border-radius: 16px;
            display: grid; place-items: center;
            font-weight: 900; font-size: 14px; color: #fff;
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(145deg, var(--blue), var(--blue-light));
            box-shadow: 0 10px 28px rgba(37,99,235,0.5), 0 0 0 1px rgba(255,255,255,0.1) inset;
            position: relative; overflow: hidden; flex: 0 0 auto;
        }
        .brand-badge::after {
            content: ""; position: absolute; inset: 0;
            background: linear-gradient(135deg, transparent 0 35%, rgba(255,255,255,0.28) 36%, transparent 37% 100%);
            transform: translateX(-100%); animation: sheen 5s ease infinite;
        }
        @keyframes sheen {
            0% { transform: translateX(-100%); }
            28%, 100% { transform: translateX(220%); }
        }
        .brand-row strong {
            display: block; font-size: 18px; font-family: 'Poppins', sans-serif; font-weight: 800;
            background: var(--grad-text); -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .brand-row span { display: block; margin-top: 3px; color: var(--muted-dim); font-size: 12px; }

        .hero { max-width: 640px; }

        .eyebrow {
            display: inline-flex; align-items: center; gap: 10px;
            padding: 8px 14px; width: fit-content; border-radius: 999px;
            background: rgba(37,99,235,0.1);
            border: 1px solid rgba(59,130,246,0.24);
            color: var(--blue-glow); font-size: 13px; font-weight: 500;
        }
        .eyebrow i {
            width: 8px; height: 8px; border-radius: 999px;
            background: var(--silver-bright);
            box-shadow: 0 0 0 0 rgba(241,245,249,0.5);
            animation: pulse 2s infinite; flex: 0 0 auto;
        }

        h1 {
            margin: 20px 0 0;
            font-size: clamp(38px, 4.8vw, 62px);
            line-height: 0.97; letter-spacing: -0.03em;
            font-family: 'Poppins', sans-serif; font-weight: 800;
            background: var(--grad-text);
            background-size: 200% auto;
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            animation: shine 9s linear infinite;
        }
        @keyframes shine { to { background-position: 200% center; } }

        .hero p {
            margin: 16px 0 0; color: var(--muted); line-height: 1.78; font-size: 15px;
        }

        .metrics {
            display: grid; grid-template-columns: repeat(2, minmax(0,1fr));
            gap: 12px; margin-top: 22px;
        }
        .metric {
            padding: 16px; border-radius: 20px;
            background: rgba(37,99,235,0.05);
            border: 1px solid rgba(59,130,246,0.13);
            transition: transform .3s ease, border-color .3s ease;
        }
        .metric:hover { transform: translateY(-4px); border-color: rgba(96,165,250,0.35); }
        .metric span { display: block; color: var(--muted-dim); font-size: 12px; text-transform: uppercase; letter-spacing: 0.07em; font-weight: 500; }
        .metric strong {
            display: block; margin-top: 8px; font-size: 20px;
            font-family: 'Poppins', sans-serif; font-weight: 700;
            background: linear-gradient(120deg, var(--silver), var(--blue-glow));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }

        /* ── RIGHT / AUTH ─────────────────────────────── */
        .auth-right {
            padding: 28px; display: flex; align-items: center;
            position: relative; z-index: 1;
        }

        .auth-card {
            width: 100%; padding: 32px; border-radius: 22px;
            background: rgba(2, 8, 22, 0.72);
            border: 1px solid rgba(59,130,246,0.18);
            box-shadow: 0 16px 48px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.025) inset;
            position: relative; overflow: hidden;
        }
        .auth-card::before {
            content: ""; position: absolute; top: -60px; right: -60px;
            width: 200px; height: 200px;
            background: radial-gradient(circle, rgba(37,99,235,0.2), transparent 70%);
            pointer-events: none;
        }

        .auth-card h2 {
            margin: 0; font-size: 28px;
            font-family: 'Poppins', sans-serif; font-weight: 700;
            background: var(--grad-text); -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .auth-card > p { margin: 10px 0 0; color: var(--muted); line-height: 1.7; font-size: 14px; }

        .notice {
            margin-top: 18px; padding: 12px 16px; border-radius: 14px;
            border: 1px solid rgba(52,211,153,0.22);
            background: rgba(52,211,153,0.08);
            color: var(--success); font-size: 14px; font-weight: 500;
        }
        .notice.error {
            border-color: rgba(248,113,113,0.22);
            background: rgba(248,113,113,0.08);
            color: var(--danger);
        }

        .form { display: grid; gap: 14px; margin-top: 24px; }

        .field { display: grid; gap: 8px; }
        .field label {
            color: var(--silver-dim); font-size: 12px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.07em;
        }
        .field input {
            width: 100%; min-height: 50px;
            border-radius: 14px; padding: 0 16px;
            border: 1px solid rgba(59,130,246,0.18);
            background: rgba(37,99,235,0.06);
            color: var(--text); outline: none; font-size: 15px;
            font-family: 'Inter', sans-serif;
            transition: border-color .2s ease, box-shadow .2s ease, background .2s ease;
        }
        .field input::placeholder { color: var(--muted-dim); }
        .field input:focus {
            border-color: rgba(96,165,250,0.6);
            background: rgba(37,99,235,0.1);
            box-shadow: 0 0 0 4px rgba(37,99,235,0.14), 0 0 20px rgba(37,99,235,0.1);
        }

        .button {
            display: inline-flex; align-items: center; justify-content: center;
            min-height: 50px; border: 0; border-radius: 14px; cursor: pointer;
            transition: transform .2s ease, box-shadow .2s ease;
            white-space: nowrap; font-weight: 600; font-size: 15px;
            font-family: 'Inter', sans-serif; position: relative; overflow: hidden;
        }
        .button:hover { transform: translateY(-2px); }
        .button:active { transform: translateY(0); }

        .button-primary {
            background: linear-gradient(135deg, var(--blue) 0%, var(--blue-light) 100%);
            color: #fff; width: 100%;
            box-shadow: 0 10px 28px rgba(37,99,235,0.42);
            border: 1px solid rgba(255,255,255,0.08);
        }
        .button-primary:hover {
            box-shadow: 0 14px 36px rgba(37,99,235,0.58);
        }
        .button-primary::after {
            content: ""; position: absolute; inset: 0;
            background: linear-gradient(105deg, transparent 30%, rgba(255,255,255,0.16) 50%, transparent 70%);
            transform: translateX(-100%); transition: transform .45s ease;
        }
        .button-primary:hover::after { transform: translateX(100%); }

        .button-ghost {
            background: rgba(37,99,235,0.07);
            color: var(--silver); width: 100%;
            border: 1px solid rgba(59,130,246,0.22);
        }
        .button-ghost:hover {
            border-color: rgba(96,165,250,0.45);
            background: rgba(37,99,235,0.13);
            color: #fff;
            box-shadow: 0 0 22px rgba(37,99,235,0.15);
        }

        .action-row { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 14px; }

        .micro { margin-top: 18px; color: var(--muted-dim); line-height: 1.7; font-size: 13px; }
        .micro a { color: var(--blue-glow); text-decoration: underline; text-underline-offset: 3px; }
        .micro a:hover { color: #fff; }

        .feature-list { display: grid; gap: 10px; margin-top: 24px; }
        .feature {
            padding: 16px; border-radius: 16px;
            background: rgba(37,99,235,0.05);
            border: 1px solid rgba(59,130,246,0.12);
            transition: transform .3s ease, border-color .3s ease, background .3s ease;
        }
        .feature:hover {
            transform: translateY(-3px);
            border-color: rgba(96,165,250,0.35);
            background: rgba(37,99,235,0.09);
        }
        .feature strong { display: block; margin-bottom: 6px; font-size: 14px; font-weight: 600; color: var(--silver-bright); }
        .feature span { color: var(--muted); font-size: 14px; line-height: 1.58; }

        .pulse-bar {
            height: 3px; border-radius: 999px; margin-top: 20px;
            background: linear-gradient(90deg, var(--blue) 0%, var(--silver) 50%, var(--blue-light) 100%);
            background-size: 200% 100%;
            animation: sweep 2.8s linear infinite;
            position: relative;
        }
        .pulse-bar::after {
            content: ""; position: absolute; inset: -3px; border-radius: 999px;
            background: inherit; filter: blur(5px); opacity: 0.5;
        }

        @keyframes pulse {
            0%   { box-shadow: 0 0 0 0   rgba(241,245,249,0.55); }
            70%  { box-shadow: 0 0 0 10px rgba(241,245,249,0); }
            100% { box-shadow: 0 0 0 0   rgba(241,245,249,0); }
        }
        @keyframes sweep { from { background-position: 0 50%; } to { background-position: 200% 50%; } }

        @media (max-width: 1040px) {
            .shell { grid-template-columns: 1fr; }
        }
        @media (max-width: 680px) {
            .page { padding: 12px; }
            .shell {
                min-height: auto;
                gap: 12px;
            }

            .left {
                display: none;
            }

            .auth-right {
                padding: 0;
                align-items: stretch;
            }

            .auth-card {
                padding: 20px;
                border-radius: 22px;
            }

            .auth-card h2 {
                font-size: 24px;
            }

            .auth-card > p,
            .micro {
                font-size: 12px;
                line-height: 1.6;
            }

            .action-row {
                margin-top: 12px;
            }

            .action-row .button {
                width: 100%;
            }

            .field input,
            .button {
                min-height: 48px;
            }

            .metrics { grid-template-columns: 1fr; }
            .form { gap: 12px; margin-top: 18px; }
        }
        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after {
                animation-duration: 0.01ms !important;
                animation-iteration-count: 1 !important;
                transition-duration: 0.01ms !important;
            }
        }
    </style>
</head>
<body>
<script>
    if ("scrollRestoration" in history) {
        history.scrollRestoration = "manual";
    }
    window.addEventListener("load", function () {
        window.scrollTo(0, 0);
    });
</script>
<div class="page">
    <div class="shell">
        <section class="panel left">
            <div>
                <div class="brand-row">
                    <div class="brand-badge">TC</div>
                    <div>
                        <strong>TeamConnect</strong>
                        <span>Secure team collaboration with real-time messaging</span>
                    </div>
                </div>

                <div class="hero">
                    <div class="eyebrow"><i></i> Secure access to your workspace</div>
                    <h1>Welcome back to the conversation.</h1>
                    <p>
                        Log in to continue your threaded chat experience with fast contact switching, live polling,
                        and a clean dashboard that keeps the conversation in focus.
                    </p>

                    <div class="metrics">
                        <div class="metric">
                            <span>Thread refresh</span>
                            <strong>Auto</strong>
                        </div>
                        <div class="metric">
                            <span>Interface style</span>
                            <strong>Glass</strong>
                        </div>
                    </div>
                </div>
            </div>

            <div>
                <div class="feature-list">
                    <div class="feature">
                        <strong>Professional session flow</strong>
                        <span>Jump from login into the dashboard without extra clutter or extra screens.</span>
                    </div>
                    <div class="feature">
                        <strong>Responsive by design</strong>
                        <span>The layout collapses cleanly on smaller screens and keeps the fields readable.</span>
                    </div>
                </div>
                <div class="pulse-bar"></div>
            </div>
        </section>

        <aside class="panel auth-right">
            <div class="auth-card">
                <h2>Login</h2>
                <p>Use your account details to open the chat dashboard.</p>

                <% if (noticeText != null) { %>
                <div class="notice <%= "1".equals(registered) ? "" : "error" %>"><%= noticeText %></div>
                <% } %>

                <form class="form" action="<%= contextPath %>/login" method="post">
                    <div class="field">
                        <label for="username">Username</label>
                        <input id="username" type="text" name="username" autocomplete="username" required>
                    </div>

                    <div class="field">
                        <label for="password">Password</label>
                        <input id="password" type="password" name="password" autocomplete="current-password" required>
                    </div>

                    <button class="button button-primary" type="submit">Login to Dashboard</button>
                </form>

                <div class="action-row">
                    <a class="button button-ghost" href="<%= contextPath %>/views/register.jsp">Create account</a>
                </div>

                <p class="micro">New here? <a href="<%= contextPath %>/views/register.jsp">Register now</a> and enter the workspace.</p>
            </div>
        </aside>
    </div>
</div>
</body>
</html>
