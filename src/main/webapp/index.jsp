<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session != null && session.getAttribute("userId") != null) {
        response.sendRedirect(request.getContextPath() + "/chat");
        return;
    }

    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TeamConnect</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap');

        :root {
            --bg:            #020818;
            --bg-2:          #030E22;
            --bg-3:          #041228;
            --text:          #F1F5F9;
            --muted:         #94A3B8;
            --muted-dim:     #64748B;
            --border:        rgba(59, 130, 246, 0.14);
            --shadow:        0 32px 80px rgba(0,0,0,0.7);
            --blue:          #2563EB;
            --blue-mid:      #3B82F6;
            --blue-light:    #60A5FA;
            --blue-glow:     #93C5FD;
            --silver:        #CBD5E1;
            --silver-dim:    #94A3B8;
            --silver-bright: #F1F5F9;
            --grad-primary:  linear-gradient(135deg, #2563EB, #60A5FA);
            --grad-silver:   linear-gradient(135deg, #94A3B8, #F1F5F9, #94A3B8);
            --grad-text:     linear-gradient(120deg, #F1F5F9 10%, #93C5FD 50%, #60A5FA 90%);
        }

        * { box-sizing: border-box; }
        html { scroll-behavior: smooth; }
        html, body {
            margin: 0; min-height: 100%;
            font-family: 'Inter', 'Segoe UI', Arial, sans-serif;
            color: var(--text);
            background: var(--bg);
            overflow-x: hidden;
            cursor: default;
        }
        body {
            min-height: 100vh;
            position: relative;
            background:
                    radial-gradient(ellipse 100% 65% at 5% -12%, rgba(37,99,235,0.28) 0%, transparent 55%),
                    radial-gradient(ellipse 75%  55% at 95%  8%, rgba(96,165,250,0.16) 0%, transparent 50%),
                    radial-gradient(ellipse 80%  55% at 50% 115%, rgba(59,130,246,0.12) 0%, transparent 55%),
                    linear-gradient(180deg, #020818 0%, #030D20 50%, #020818 100%);
        }
        a { color: inherit; text-decoration: none; }

        /* Aurora */
        body::before {
            content: ""; position: fixed; inset: 0; z-index: 0; pointer-events: none;
            background:
                    radial-gradient(ellipse 700px 420px at 15% 25%, rgba(37,99,235,0.1)  0%, transparent 70%),
                    radial-gradient(ellipse 550px 380px at 85% 75%, rgba(96,165,250,0.08) 0%, transparent 70%),
                    radial-gradient(ellipse 400px 300px at 50% 50%, rgba(148,194,251,0.04) 0%, transparent 70%);
            animation: auroraShift 22s ease-in-out infinite alternate;
        }
        @keyframes auroraShift {
            0%   { transform: translate(0,0) scale(1); }
            50%  { transform: translate(-32px,20px) scale(1.06); }
            100% { transform: translate(24px,-30px) scale(0.97); }
        }

        /* Grid */
        body::after {
            content: ""; position: fixed; inset: 0; z-index: 0; pointer-events: none;
            background-image:
                    linear-gradient(rgba(59,130,246,0.05) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(59,130,246,0.05) 1px, transparent 1px);
            background-size: 70px 70px;
            mask-image: radial-gradient(ellipse 85% 75% at 50% 50%, black 15%, transparent 80%);
        }

        canvas#fxCanvas { position: fixed; inset: 0; z-index: 0; pointer-events: none; opacity: 0.5; }
        .cursor-glow {
            position: fixed; width: 540px; height: 540px; border-radius: 50%;
            background: radial-gradient(circle, rgba(37,99,235,0.1), transparent 70%);
            pointer-events: none; z-index: 0; transform: translate(-50%,-50%);
            transition: left .22s ease, top .22s ease;
        }

        .wrap { width: min(1280px, calc(100% - 40px)); margin: 0 auto; position: relative; z-index: 1; }
        .page { min-height: 100vh; padding: 20px 0 72px; position: relative; overflow: hidden; }

        /* ── TOPBAR ─────────────────────────────────── */
        .topbar {
            display: flex; align-items: center; justify-content: space-between; gap: 16px;
            padding: 14px 22px;
            border: 1px solid rgba(59,130,246,0.18);
            border-radius: 20px;
            background: rgba(2,8,24,0.78);
            backdrop-filter: blur(28px) saturate(180%);
            -webkit-backdrop-filter: blur(28px) saturate(180%);
            box-shadow: 0 0 0 1px rgba(255,255,255,0.04) inset, var(--shadow);
            position: sticky; top: 16px; z-index: 20;
            transition: padding .3s ease, background .3s ease, box-shadow .3s ease;
        }
        .topbar.scrolled {
            padding: 10px 22px;
            background: rgba(2,8,24,0.97);
            box-shadow: 0 8px 40px rgba(0,0,0,0.65), 0 0 0 1px rgba(59,130,246,0.14) inset;
        }

        .brand { display: flex; align-items: center; gap: 13px; min-width: 0; }
        .brand-mark {
            width: 48px; height: 48px; border-radius: 15px; display: grid; place-items: center;
            background: linear-gradient(145deg, var(--blue), var(--blue-light));
            color: #fff; font-weight: 900; font-size: 15px; font-family: 'Poppins', sans-serif;
            box-shadow: 0 8px 28px rgba(37,99,235,0.5), 0 0 0 1px rgba(255,255,255,0.1) inset;
            flex: 0 0 auto; position: relative; overflow: hidden;
        }
        .brand-mark::after {
            content: ""; position: absolute; inset: 0;
            background: linear-gradient(135deg, transparent 0 35%, rgba(255,255,255,0.3) 36%, transparent 37% 100%);
            transform: translateX(-100%); animation: sheen 5s ease infinite;
        }
        @keyframes sheen {
            0% { transform: translateX(-100%); }
            30%, 100% { transform: translateX(220%); }
        }
        .brand-copy strong {
            display: block; font-size: 18px; line-height: 1.15;
            font-family: 'Poppins', sans-serif; font-weight: 800;
            background: var(--grad-text);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .brand-copy span { display: block; margin-top: 3px; color: var(--muted-dim); font-size: 12px; }

        .nav { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; justify-content: flex-end; }
        .button {
            display: inline-flex; align-items: center; justify-content: center; min-height: 42px;
            padding: 0 20px; border-radius: 12px; border: 1px solid transparent;
            transition: transform .2s ease, box-shadow .2s ease, background .2s ease, border-color .2s ease;
            white-space: nowrap; font-weight: 600; font-size: 14px;
            font-family: 'Inter', sans-serif; cursor: pointer; position: relative; overflow: hidden;
        }
        .button:hover { transform: translateY(-2px); }
        .button:active { transform: translateY(0); }

        .button-ghost {
            background: rgba(59,130,246,0.06);
            border-color: rgba(59,130,246,0.22);
            color: var(--silver);
        }
        .button-ghost:hover {
            border-color: rgba(96,165,250,0.5);
            background: rgba(59,130,246,0.12);
            box-shadow: 0 0 24px rgba(37,99,235,0.15), 0 0 0 1px rgba(96,165,250,0.1) inset;
            color: #fff;
        }
        .button-primary {
            background: linear-gradient(135deg, var(--blue) 0%, var(--blue-light) 100%);
            color: #fff;
            box-shadow: 0 8px 28px rgba(37,99,235,0.45);
            border-color: rgba(255,255,255,0.1);
        }
        .button-primary:hover {
            box-shadow: 0 14px 36px rgba(37,99,235,0.6), 0 0 0 1px rgba(255,255,255,0.12) inset;
        }
        /* silver shimmer on primary */
        .button-primary::after {
            content: ""; position: absolute; inset: 0;
            background: linear-gradient(105deg, transparent 30%, rgba(255,255,255,0.18) 50%, transparent 70%);
            transform: translateX(-100%);
            transition: transform .45s ease;
        }
        .button-primary:hover::after { transform: translateX(100%); }

        /* ── HERO ────────────────────────────────────── */
        .hero { padding: 44px 0 32px; }
        .hero-grid { display: grid; grid-template-columns: 1.1fr 0.9fr; gap: 22px; align-items: stretch; }

        .panel {
            border: 1px solid var(--border);
            border-radius: 28px;
            background: rgba(3,10,28,0.74);
            backdrop-filter: blur(26px) saturate(160%);
            -webkit-backdrop-filter: blur(26px) saturate(160%);
            box-shadow: 0 0 0 1px rgba(255,255,255,0.028) inset, var(--shadow);
            position: relative;
        }
        /* gradient border ring */
        .panel::before {
            content: ""; position: absolute; inset: -1px; border-radius: inherit; padding: 1px;
            background: linear-gradient(135deg, rgba(37,99,235,0.45), rgba(148,163,184,0.18) 45%, rgba(96,165,250,0.3) 100%);
            mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
            -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
            -webkit-mask-composite: xor; mask-composite: exclude; pointer-events: none;
        }

        .hero-main {
            padding: 42px; min-height: 645px;
            display: flex; flex-direction: column; justify-content: space-between; gap: 28px;
            overflow: hidden;
        }
        .hero-main::after {
            content: ""; position: absolute; bottom: -100px; right: -100px;
            width: 420px; height: 420px;
            background: conic-gradient(from 200deg,
            rgba(37,99,235,0.32),
            rgba(96,165,250,0.28),
            rgba(203,213,225,0.18),
            rgba(37,99,235,0.32));
            border-radius: 50%; filter: blur(72px); opacity: 0.5;
            animation: float 13s ease-in-out infinite; pointer-events: none;
        }
        .hero-main::before {
            content: ""; position: absolute; inset: 22px; border-radius: 20px;
            background: linear-gradient(180deg, rgba(255,255,255,0.018), transparent 28%);
            pointer-events: none;
        }

        .badge {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 8px 15px; border-radius: 999px;
            background: rgba(37,99,235,0.1); color: var(--blue-glow);
            font-size: 13px; width: fit-content;
            border: 1px solid rgba(59,130,246,0.24); font-weight: 500;
        }
        .badge i {
            width: 8px; height: 8px; border-radius: 999px;
            background: var(--silver-bright);
            box-shadow: 0 0 0 0 rgba(241,245,249,0.5);
            animation: pulse 2s infinite; flex: 0 0 auto;
        }

        h1 {
            margin: 22px 0 0;
            font-size: clamp(44px, 5.4vw, 82px);
            line-height: 0.94; letter-spacing: -0.035em;
            max-width: 13ch; text-wrap: balance;
            font-family: 'Poppins', sans-serif; font-weight: 900;
            background: var(--grad-text);
            background-size: 200% auto;
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            animation: shine 9s linear infinite;
        }
        @keyframes shine { to { background-position: 200% center; } }

        .hero-copy {
            max-width: 640px; margin: 18px 0 0;
            color: var(--muted); font-size: 16px; line-height: 1.82;
        }
        .hero-copy strong, .section-text strong,
        .feature span strong, .timeline-item span strong { color: #fff; font-weight: 600; }

        .hero-actions { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 30px; }

        .hero-stats { display: grid; grid-template-columns: repeat(3, minmax(0,1fr)); gap: 12px; }
        .stat {
            padding: 18px; border-radius: 20px;
            background: rgba(37,99,235,0.05);
            border: 1px solid rgba(59,130,246,0.13);
            transition: transform .3s ease, border-color .3s ease, box-shadow .3s ease;
        }
        .stat:hover {
            transform: translateY(-5px);
            border-color: rgba(96,165,250,0.4);
            box-shadow: 0 12px 42px rgba(37,99,235,0.14);
        }
        .stat span {
            display: block; color: var(--muted-dim); font-size: 11px;
            text-transform: uppercase; letter-spacing: 0.08em; font-weight: 500;
        }
        .stat strong {
            display: block; margin-top: 8px; font-size: 22px;
            font-family: 'Poppins', sans-serif; font-weight: 700;
            font-variant-numeric: tabular-nums;
            background: linear-gradient(120deg, var(--silver), var(--blue-glow));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }

        .side-stack { display: grid; gap: 22px; }
        .glass-box { padding: 28px; }

        .section-title {
            margin: 0; font-size: 22px; line-height: 1.2;
            font-family: 'Poppins', sans-serif; font-weight: 700;
        }
        .section-text { margin: 12px 0 0; color: var(--muted); line-height: 1.76; font-size: 15px; }
        .section-subtle {
            display: inline-flex; align-items: center; gap: 8px;
            color: var(--blue-glow); font-size: 11px; margin-top: 8px;
            font-weight: 600; text-transform: uppercase; letter-spacing: 0.09em;
        }
        .section-subtle::before {
            content: ""; width: 32px; height: 1px;
            background: linear-gradient(90deg, rgba(96,165,250,0.9), transparent);
        }

        .feature-list { display: grid; gap: 10px; margin-top: 18px; }
        .feature {
            padding: 16px; border-radius: 16px;
            background: rgba(37,99,235,0.04);
            border: 1px solid rgba(59,130,246,0.11);
            transition: transform .3s ease, border-color .3s ease, background .3s ease, box-shadow .3s ease;
        }
        .feature:hover {
            transform: translateY(-4px);
            border-color: rgba(96,165,250,0.4);
            background: rgba(37,99,235,0.08);
            box-shadow: 0 8px 32px rgba(37,99,235,0.12);
        }
        .feature strong { display: block; margin-bottom: 6px; font-size: 14px; font-weight: 600; color: var(--silver-bright); }
        .feature span { color: var(--muted); font-size: 14px; line-height: 1.62; }

        /* ── STATUS CARD ──────────────────────────────── */
        .status-card {
            padding: 26px; border-radius: 26px;
            background:
                    linear-gradient(145deg, rgba(3,9,25,0.97), rgba(5,14,36,0.95)),
                    radial-gradient(ellipse 60% 50% at 90% 10%, rgba(37,99,235,0.18), transparent);
            border: 1px solid rgba(59,130,246,0.2);
            box-shadow: 0 28px 70px rgba(0,0,0,0.55);
            position: relative; overflow: hidden;
        }
        .status-card::before {
            content: ""; position: absolute; inset: -1px; border-radius: inherit; padding: 1px;
            background: linear-gradient(135deg, rgba(37,99,235,0.65), rgba(148,163,184,0.25) 50%, rgba(96,165,250,0.55));
            mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
            -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
            -webkit-mask-composite: xor; mask-composite: exclude; pointer-events: none;
        }
        .status-card::after {
            content: ""; position: absolute; top: -70px; right: -70px;
            width: 240px; height: 240px;
            background: radial-gradient(circle, rgba(37,99,235,0.22), transparent 70%);
            pointer-events: none;
        }

        .status-top { display: flex; justify-content: space-between; gap: 10px; align-items: center; }
        .status-top span { opacity: 0.65; font-size: 12px; font-weight: 500; color: var(--silver-dim); }
        .status-top strong { font-size: 17px; font-weight: 700; font-family: 'Poppins', sans-serif; }

        .pulse-bar {
            height: 3px; margin-top: 20px; border-radius: 999px;
            background: linear-gradient(90deg, var(--blue) 0%, var(--silver) 50%, var(--blue-light) 100%);
            background-size: 200% 100%;
            animation: sweep 2.8s linear infinite;
            position: relative;
        }
        .pulse-bar::after {
            content: ""; position: absolute; inset: -3px; border-radius: 999px;
            background: inherit; filter: blur(5px); opacity: 0.55;
        }

        .meta-grid { display: grid; grid-template-columns: repeat(2, minmax(0,1fr)); gap: 12px; margin-top: 18px; }
        .meta {
            padding: 16px; border-radius: 16px;
            background: rgba(37,99,235,0.06);
            border: 1px solid rgba(59,130,246,0.13);
        }
        .meta span {
            display: block; font-size: 11px; color: var(--muted-dim);
            text-transform: uppercase; letter-spacing: 0.08em; font-weight: 500;
        }
        .meta strong { display: block; margin-top: 8px; font-size: 17px; font-weight: 700; font-family: 'Poppins', sans-serif; }

        /* ── ABOUT ────────────────────────────────────── */
        .about { padding: 24px 0 0; }
        .section-head { display: flex; justify-content: space-between; align-items: end; gap: 16px; margin-bottom: 22px; }
        .section-head p { margin: 0; color: var(--muted); max-width: 680px; line-height: 1.76; font-size: 15px; }

        .about-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 22px; }
        .about-card {
            padding: 32px; min-height: 300px; overflow: hidden;
            transition: transform .35s ease, box-shadow .35s ease;
        }
        .about-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 40px 80px rgba(0,0,0,0.6), 0 0 0 1px rgba(59,130,246,0.22) inset;
        }
        .about-card::before { display: none; }
        .about-card h3 { margin: 0 0 12px; font-size: 18px; font-family: 'Poppins', sans-serif; font-weight: 700; }
        .about-card p { margin: 0; color: var(--muted); line-height: 1.76; font-size: 15px; }

        .chips { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 18px; }
        .chip {
            padding: 7px 14px; border-radius: 999px;
            background: rgba(37,99,235,0.09);
            border: 1px solid rgba(59,130,246,0.22);
            font-size: 13px; font-weight: 500; color: var(--blue-glow);
            transition: all .25s ease;
        }
        .chip:hover {
            border-color: rgba(96,165,250,0.55);
            background: rgba(37,99,235,0.18);
            color: var(--silver-bright);
            box-shadow: 0 0 14px rgba(37,99,235,0.18);
        }

        .timeline { display: grid; gap: 0; margin-top: 18px; }
        .timeline-item {
            display: flex; gap: 14px; align-items: flex-start;
            padding: 14px 0; border-top: 1px solid rgba(59,130,246,0.1);
        }
        .timeline-item:first-child { border-top: 0; padding-top: 0; }
        .timeline-item b {
            min-width: 80px; color: var(--blue-glow); font-size: 12px;
            text-transform: uppercase; letter-spacing: 0.07em; font-weight: 600;
        }
        .timeline-item span { color: var(--muted); line-height: 1.65; font-size: 14px; }

        .developer { display: flex; flex-direction: column; justify-content: space-between; }
        .developer strong {
            display: block; margin-top: 20px; font-size: 17px; font-weight: 700;
            font-family: 'Poppins', sans-serif;
            background: var(--grad-text); -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .developer p { margin: 10px 0 0; color: var(--muted); line-height: 1.76; font-size: 15px; }

        .spotlight { display: grid; gap: 10px; margin-top: 18px; }
        .spot-card {
            display: flex; align-items: center; justify-content: space-between; gap: 12px;
            padding: 14px 16px; border-radius: 16px;
            background: rgba(37,99,235,0.05);
            border: 1px solid rgba(59,130,246,0.12);
            transition: border-color .25s ease, background .25s ease, box-shadow .25s ease;
        }
        .spot-card:hover {
            border-color: rgba(96,165,250,0.35);
            background: rgba(37,99,235,0.09);
            box-shadow: 0 4px 24px rgba(37,99,235,0.1);
        }
        .spot-card em { font-style: normal; color: var(--muted-dim); font-size: 11px; text-transform: uppercase; letter-spacing: 0.07em; font-weight: 500; }
        .spot-card strong { display: block; font-size: 13px; font-weight: 600; margin: 4px 0 0; line-height: 1.4; }

        .mini-bars { display: flex; align-items: end; gap: 3px; height: 22px; }
        .mini-bars span {
            width: 5px; border-radius: 999px;
            background: linear-gradient(180deg, var(--silver-bright), var(--blue-mid));
            animation: wave 1.6s ease-in-out infinite;
        }
        .mini-bars span:nth-child(1) { height: 10px; animation-delay: 0.00s; }
        .mini-bars span:nth-child(2) { height: 16px; animation-delay: 0.12s; }
        .mini-bars span:nth-child(3) { height: 20px; animation-delay: 0.24s; }
        .mini-bars span:nth-child(4) { height: 12px; animation-delay: 0.36s; }
        .mini-bars span:nth-child(5) { height: 18px; animation-delay: 0.48s; }
        .mini-bars span:nth-child(6) { height:  8px; animation-delay: 0.60s; }

        /* ── REVEAL ───────────────────────────────────── */
        .reveal { opacity: 0; transform: translateY(32px); transition: opacity .9s cubic-bezier(.22,1,.36,1), transform .9s cubic-bezier(.22,1,.36,1); }
        .reveal.show { opacity: 1; transform: translateY(0); }

        /* ── KEYFRAMES ────────────────────────────────── */
        @keyframes pulse {
            0%   { box-shadow: 0 0 0 0   rgba(241,245,249,0.55); }
            70%  { box-shadow: 0 0 0 10px rgba(241,245,249,0); }
            100% { box-shadow: 0 0 0 0   rgba(241,245,249,0); }
        }
        @keyframes sweep { from { background-position: 0 50%; } to { background-position: 200% 50%; } }
        @keyframes float {
            0%, 100% { transform: translate3d(0,0,0) rotate(0deg); }
            50%       { transform: translate3d(-18px,-14px,0) rotate(5deg); }
        }
        @keyframes wave {
            0%, 100% { transform: scaleY(0.45); opacity: 0.55; }
            50%       { transform: scaleY(1.45); opacity: 1; }
        }

        /* ── RESPONSIVE ───────────────────────────────── */
        @media (max-width: 1100px) {
            .hero-grid, .about-grid { grid-template-columns: 1fr; }
            .hero-main { min-height: auto; }
        }
        @media (max-width: 760px) {
            .wrap { width: calc(100% - 28px); }
            .topbar { flex-direction: column; align-items: stretch; }
            .nav { justify-content: flex-start; }
            .hero-main, .glass-box, .about-card { padding: 22px; }
            .hero-stats, .meta-grid { grid-template-columns: 1fr; }
            .section-head { flex-direction: column; align-items: flex-start; }
            .cursor-glow { display: none; }
            h1 { font-size: 40px; }
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
<canvas id="fxCanvas"></canvas>
<div class="cursor-glow" id="glow"></div>

<div class="page">
    <div class="wrap">
        <header class="topbar" id="topbar">
            <div class="brand">
                <div class="brand-mark">TC</div>
                <div class="brand-copy">
                    <strong>TeamConnect</strong>
                    <span>Secure team collaboration with real-time messaging</span>
                </div>
            </div>
            <nav class="nav">
                <a href="#about" class="button button-ghost">About</a>
                <a href="<%= contextPath %>/views/login.jsp" class="button button-ghost">Login</a>
                <a href="<%= contextPath %>/views/register.jsp" class="button button-primary">Get Started</a>
            </nav>
        </header>

        <main class="hero">
            <div class="hero-grid">
                <section class="panel hero-main reveal">
                    <div>
                        <div class="badge"><i></i> Real-time messaging platform for instant conversations</div>
                        <h1>Chat smarter. Connect faster.</h1>
                        <p class="hero-copy">
                            TeamConnect is a complete messaging platform built with JSP and Servlet technology.
                            Create an account, add contacts, and start chatting instantly with live message delivery,
                            photo and file sharing, searchable chat history, and a dashboard that keeps every
                            conversation organized in one place.
                        </p>
                        <div class="hero-actions">
                            <a href="<%= contextPath %>/views/login.jsp" class="button button-primary">Login to Dashboard</a>
                            <a href="<%= contextPath %>/views/register.jsp" class="button button-ghost">Create Account</a>
                        </div>
                    </div>

                    <div class="hero-stats">
                        <div class="stat">
                            <span>Threaded chat</span>
                            <strong id="statSync">Live sync</strong>
                        </div>
                        <div class="stat">
                            <span>Attachments</span>
                            <strong>Files + Photos</strong>
                        </div>
                        <div class="stat">
                            <span>History</span>
                            <strong>Searchable</strong>
                        </div>
                    </div>
                </section>

                <aside class="side-stack">
                    <section class="panel glass-box reveal">
                        <h2 class="section-title">What it does</h2>
                        <div class="section-subtle">Core features at a glance</div>
                        <p class="section-text">
                            Every account gets a personal dashboard to manage contacts, view active conversations,
                            and send messages in real time. Conversations stay synced automatically, so you always
                            see the latest reply without refreshing the page.
                        </p>
                        <div class="feature-list">
                            <div class="feature">
                                <strong>Live messaging</strong>
                                <span>Messages are delivered and updated instantly, with read status and timestamps for every conversation.</span>
                            </div>
                            <div class="feature">
                                <strong>Photo &amp; file sharing</strong>
                                <span>Send images and documents directly inside a chat thread without switching tools or tabs.</span>
                            </div>
                            <div class="feature">
                                <strong>Searchable history</strong>
                                <span>Find any past message or shared file quickly using built-in conversation search.</span>
                            </div>
                        </div>
                    </section>

                    <section class="status-card reveal">
                        <div class="status-top">
                            <div>
                                <span>System status</span>
                                <strong>Online and ready</strong>
                            </div>
                            <span>JSP + Servlet + MySQL</span>
                        </div>
                        <div class="pulse-bar"></div>
                        <div class="spotlight">
                            <div class="spot-card">
                                <div>
                                    <em>Account security</em>
                                    <strong>Encrypted login with session-based access control</strong>
                                </div>
                                <div class="mini-bars" aria-hidden="true">
                                    <span></span><span></span><span></span><span></span><span></span><span></span>
                                </div>
                            </div>
                            <div class="spot-card">
                                <div>
                                    <em>Storage</em>
                                    <strong>Messages and files backed by a MySQL database</strong>
                                </div>
                                <span class="button button-ghost" style="min-height:34px;padding:0 12px;">Reliable</span>
                            </div>
                        </div>
                        <div class="meta-grid">
                            <div class="meta">
                                <span>Devices</span>
                                <strong>Mobile &amp; Desktop</strong>
                            </div>
                            <div class="meta">
                                <span>Login</span>
                                <strong>Secure</strong>
                            </div>
                        </div>
                    </section>
                </aside>
            </div>
        </main>

        <section class="about" id="about">
            <div class="section-head reveal">
                <div>
                    <div class="badge"><i></i> About TeamConnect</div>
                    <h2 class="section-title" style="margin-top:12px;">A complete messaging platform, built end to end</h2>
                </div>
                <p>
                    TeamConnect covers everything a real chat application needs — secure registration and
                    login, a contact list, real-time conversations, file sharing, and an admin-friendly structure
                    that's easy to extend. Built and maintained by Abhishek Samadhiya.
                </p>
            </div>

            <div class="about-grid">
                <section class="panel about-card developer reveal">
                    <div>
                        <h3>Developer profile</h3>
                        <p>
                            Abhishek Samadhiya built TeamConnect with JSP and Servlet technology. The goal
                            is a modern workspace with clear conversation hierarchy, strong visual separation, and a
                            presentation that feels deliberate rather than generic.
                        </p>
                        <div class="chips">
                            <span class="chip">JSP</span>
                            <span class="chip">Servlet</span>
                            <span class="chip">MySQL</span>
                            <span class="chip">File Sharing</span>
                            <span class="chip">Secure UI</span>
                        </div>
                    </div>
                    <strong>Abhishek Samadhiya</strong>
                </section>

                <section class="panel about-card reveal">
                    <h3>Project focus</h3>
                    <div class="timeline">
                        <div class="timeline-item">
                            <b>Design</b>
                            <span>Electric blue and silver on deep navy — a palette that feels corporate-premium, like Microsoft Fluent meets Linear.</span>
                        </div>
                        <div class="timeline-item">
                            <b>Workflow</b>
                            <span>Dashboard-first layout, message history search, and attachment sharing in one clean flow.</span>
                        </div>
                        <div class="timeline-item">
                            <b>Motion</b>
                            <span>Layered glass, silver-blue glow edges, drifting particles, and animated accents create a dynamic impression without breaking readability.</span>
                        </div>
                    </div>
                </section>
            </div>
        </section>
    </div>
</div>

<script>
    var canvas = document.getElementById('fxCanvas');
    var ctx = canvas.getContext('2d');
    var particles = [];
    var count = 60;
    function resize(){ canvas.width = window.innerWidth; canvas.height = window.innerHeight; }
    resize();
    window.addEventListener('resize', resize);
    function Particle(){
        this.x = Math.random() * canvas.width;
        this.y = Math.random() * canvas.height;
        this.r = Math.random() * 1.6 + 0.4;
        this.vx = (Math.random() - 0.5) * 0.25;
        this.vy = (Math.random() - 0.5) * 0.25;
        this.hue = Math.random() > 0.5 ? '59,130,246' : '203,213,225';
        this.alpha = Math.random() * 0.45 + 0.15;
    }
    for(var i=0;i<count;i++){ particles.push(new Particle()); }
    function loop(){
        ctx.clearRect(0,0,canvas.width,canvas.height);
        for(var i=0;i<particles.length;i++){
            var p = particles[i];
            p.x += p.vx; p.y += p.vy;
            if(p.x<0) p.x=canvas.width; if(p.x>canvas.width) p.x=0;
            if(p.y<0) p.y=canvas.height; if(p.y>canvas.height) p.y=0;
            ctx.beginPath();
            ctx.arc(p.x,p.y,p.r,0,Math.PI*2);
            ctx.fillStyle='rgba('+p.hue+','+p.alpha+')';
            ctx.fill();
        }
        for(var a=0;a<particles.length;a++){
            for(var b=a+1;b<particles.length;b++){
                var dx=particles[a].x-particles[b].x;
                var dy=particles[a].y-particles[b].y;
                var dist=Math.sqrt(dx*dx+dy*dy);
                if(dist<100){
                    ctx.beginPath();
                    ctx.moveTo(particles[a].x,particles[a].y);
                    ctx.lineTo(particles[b].x,particles[b].y);
                    ctx.strokeStyle='rgba(96,165,250,'+(0.1*(1-dist/100))+')';
                    ctx.lineWidth=1;
                    ctx.stroke();
                }
            }
        }
        requestAnimationFrame(loop);
    }
    loop();

    var glow = document.getElementById('glow');
    document.addEventListener('mousemove', function(e){
        glow.style.left = e.clientX+'px';
        glow.style.top  = e.clientY+'px';
    });

    var topbar = document.getElementById('topbar');
    window.addEventListener('scroll', function(){
        if(window.scrollY>30){ topbar.classList.add('scrolled'); }
        else { topbar.classList.remove('scrolled'); }
    });

    var reveals = document.querySelectorAll('.reveal');
    var observer = new IntersectionObserver(function(entries){
        entries.forEach(function(entry){
            if(entry.isIntersecting){ entry.target.classList.add('show'); }
        });
    },{ threshold: 0.12 });
    reveals.forEach(function(el){ observer.observe(el); });
</script>
</body>
</html>
