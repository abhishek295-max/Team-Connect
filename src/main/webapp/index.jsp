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
    <title>TeamConnect - Premium Real-Time Messaging Platform</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap');

        :root {
            --bg:         #E5E7EB;
            --surface:    #DDE1E6;
            --surface-2:  #D4D8DE;

            --border:     rgba(17,24,39,.08);
            --border-2:   rgba(17,24,39,.12);

            --text:       #111827;
            --text-dim:   #4B5563;
            --text-mute:  #6B7280;

            --primary:    #2563EB;
            --primary-d:  #1E40AF;
            --accent:     #60A5FA;

            --green:      #10B981;

            --shadow-sm:  0 2px 4px rgba(17,24,39,.04);
            --shadow-md:  0 8px 20px rgba(17,24,39,.06);
            --shadow-lg:  0 20px 42px rgba(17,24,39,.08);

            --radius:     20px;
            --container:  1200px;
        }

        * { box-sizing: border-box; }
        html { scroll-behavior: smooth; }
        html, body {
            margin: 0; min-height: 100%;
            font-family: 'Inter', -apple-system, 'Segoe UI', sans-serif;
            color: var(--text);
            background: var(--bg);
        }
        body {
            position: relative;
            background:
                    radial-gradient(ellipse 900px 500px at 15% -10%, rgba(59,130,246,0.06) 0%, transparent 60%),
                    radial-gradient(ellipse 700px 500px at 100% 20%, rgba(96,165,250,0.05) 0%, transparent 55%),
                    var(--bg);
        }
        a { color: inherit; text-decoration: none; }
        img { max-width: 100%; display: block; }
        ::selection { background: rgba(59,130,246,0.18); }

        /* ── LOADER ─────────────────────────────────── */
        #loader {
            position: fixed; inset: 0; z-index: 999;
            background: #09090B;
            display: flex; align-items: center; justify-content: center;
            transition: opacity .5s ease, visibility .5s ease;
        }
        #loader.hide { opacity: 0; visibility: hidden; }
        .loader-inner { display: flex; flex-direction: column; align-items: center; gap: 22px; }
        .loader-mark {
            width: 56px; height: 56px; border-radius: 16px;
            background: linear-gradient(145deg, var(--primary), var(--accent));
            display: grid; place-items: center;
            color: #fff; font-weight: 800; font-size: 18px; font-family: 'Manrope', sans-serif;
            animation: loaderPulse 1.4s ease-in-out infinite;
        }
        @keyframes loaderPulse {
            0%, 100% { transform: scale(1); opacity: 1; }
            50% { transform: scale(0.94); opacity: 0.85; }
        }
        .loader-dots { display: flex; gap: 6px; }
        .loader-dots span {
            width: 6px; height: 6px; border-radius: 50%;
            background: #71717A;
            animation: loaderDot 1.2s ease-in-out infinite;
        }
        .loader-dots span:nth-child(2) { animation-delay: .15s; }
        .loader-dots span:nth-child(3) { animation-delay: .3s; }
        @keyframes loaderDot {
            0%, 60%, 100% { transform: translateY(0); opacity: .4; }
            30% { transform: translateY(-5px); opacity: 1; }
        }
        .loader-text { color: #A1A1AA; font-size: 13px; font-weight: 500; letter-spacing: 0.01em; }

        body.loading { overflow: hidden; }
        #page-content { opacity: 0; transform: translateY(8px); transition: opacity .6s ease, transform .6s ease; }
        #page-content.show { opacity: 1; transform: translateY(0); }

        .wrap { width: min(var(--container), calc(100% - 40px)); margin: 0 auto; position: relative; z-index: 2; }
        .page { min-height: 100vh; padding: 16px 0 0; }

        /* ── TOPBAR ─────────────────────────────────── */
        /* ===========================================
   PREMIUM MINIMAL TOPBAR
   Apple + Linear + Slack + Arc Style
=========================================== */

        .topbar {
            position: sticky;
            top: 18px;
            z-index: 999;

            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;

            width: 100%;
            padding: 14px 22px;

            background: rgba(221, 225, 230, 0.82);
            backdrop-filter: blur(18px) saturate(180%);
            -webkit-backdrop-filter: blur(18px) saturate(180%);

            border: 1px solid rgba(255,255,255,.35);

            border-radius: 18px;

            box-shadow:
                    0 8px 24px rgba(17,24,39,.05),
                    0 1px 1px rgba(255,255,255,.35) inset;

            transition:
                    background .35s ease,
                    box-shadow .35s ease,
                    transform .35s ease;

            overflow: hidden;
        }

        /* Soft glossy highlight */

        .topbar::before{
            content:"";
            position:absolute;
            inset:0;
            border-radius:inherit;
            pointer-events:none;

            background:
                    linear-gradient(
                            180deg,
                            rgba(255,255,255,.30),
                            transparent 45%
                    );

            opacity:.9;
        }

        /* Scroll Effect */

        .topbar.scrolled{

            background:rgba(212,216,222,.94);

            transform:translateY(-2px);

            box-shadow:
                    0 18px 40px rgba(17,24,39,.08),
                    0 1px 0 rgba(255,255,255,.45) inset;
        }

        /* ===========================
                Brand
        =========================== */

        .brand{
            display:flex;
            align-items:center;
            gap:14px;
            min-width:0;
        }

        .brand-mark{

            width:44px;
            height:44px;

            display:grid;
            place-items:center;

            border-radius:14px;

            background:
                    linear-gradient(
                            135deg,
                            var(--primary),
                            var(--accent)
                    );

            color:#fff;

            font-weight:800;
            font-size:15px;

            font-family:"Manrope",sans-serif;

            flex-shrink:0;

            box-shadow:
                    0 10px 24px rgba(37,99,235,.24);

            transition:.3s ease;
        }

        .brand:hover .brand-mark{

            transform:rotate(-6deg) scale(1.06);

            box-shadow:
                    0 16px 34px rgba(37,99,235,.30);
        }

        .brand-copy strong{

            display:block;

            font-family:"Manrope",sans-serif;

            font-size:17px;

            font-weight:800;

            color:var(--text);

            line-height:1.2;
        }

        .brand-copy span{

            display:block;

            margin-top:2px;

            color:var(--text-mute);

            font-size:12px;

            letter-spacing:.3px;
        }

        /* ===========================
                Navigation
        =========================== */

        .nav{

            display:flex;
            align-items:center;
            gap:10px;
            flex-wrap:wrap;
        }

        /* ===========================
                Buttons
        =========================== */

        .button{

            position:relative;

            display:inline-flex;
            align-items:center;
            justify-content:center;

            height:42px;

            padding:0 20px;

            border-radius:12px;

            border:1px solid transparent;

            cursor:pointer;

            font-family:"Inter",sans-serif;
            font-size:14px;
            font-weight:600;

            text-decoration:none;

            transition:
                    transform .25s ease,
                    background .25s ease,
                    border-color .25s ease,
                    box-shadow .25s ease,
                    color .25s ease;
        }

        .button:hover{

            transform:translateY(-2px);
        }

        .button:active{

            transform:scale(.98);
        }

        /* Ghost */

        .button-ghost{

            background:transparent;

            color:var(--text-dim);

            border-color:transparent;
        }

        .button-ghost:hover{

            background:rgba(255,255,255,.45);

            border-color:var(--border);

            color:var(--text);

            box-shadow:0 4px 12px rgba(17,24,39,.05);
        }

        /* Primary */

        .button-primary{

            background:
                    linear-gradient(
                            135deg,
                            var(--primary),
                            var(--primary-d)
                    );

            color:#fff;

            border:none;

            box-shadow:
                    0 10px 24px rgba(37,99,235,.22);
        }

        .button-primary:hover{

            background:
                    linear-gradient(
                            135deg,
                            var(--primary-d),
                            var(--primary)
                    );

            box-shadow:
                    0 18px 34px rgba(37,99,235,.28);
        }

        /* ===========================
            Navigation Indicator
        =========================== */

        .nav a{

            position:relative;
        }

        .nav a::after{

            content:"";

            position:absolute;

            left:50%;

            bottom:-7px;

            width:0;

            height:3px;

            transform:translateX(-50%);

            border-radius:30px;

            background:var(--primary);

            transition:.25s ease;
        }

        .nav a:hover::after{

            width:22px;
        }

        /* ===========================
                Reveal Animation
        =========================== */

        .reveal{

            opacity:0;

            transform:translateY(18px);

            transition:
                    opacity .7s cubic-bezier(.22,1,.36,1),
                    transform .7s cubic-bezier(.22,1,.36,1);
        }

        .reveal.show{

            opacity:1;

            transform:translateY(0);
        }

        /* ===========================
                Responsive
        =========================== */

        @media (max-width:768px){

            .topbar{

                flex-direction:column;

                align-items:flex-start;

                padding:16px;
            }

            .nav{

                width:100%;

                justify-content:flex-start;
            }

            .button{

                flex:1;
            }
        }

        /* ── HERO ────────────────────────────────────── */
        .hero { padding: 56px 0 20px; }
        .hero-grid { display: grid; grid-template-columns: 1.05fr 0.95fr; gap: 28px; align-items: center; }
        .badge {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 7px 14px; border-radius: 999px;
            background: var(--surface-2); color: var(--text-dim);
            font-size: 13px; width: fit-content;
            border: 1px solid var(--border); font-weight: 500;
        }
        .badge .dot { width: 6px; height: 6px; border-radius: 999px; background: var(--green); flex: 0 0 auto; }

        h1 {
            margin: 20px 0 0;
            font-size: clamp(40px, 5vw, 72px);
            line-height: 1.04; letter-spacing: -0.03em;
            max-width: 14ch;
            font-family: 'Manrope', sans-serif; font-weight: 800;
            color: var(--text);
        }
        h1 .accent { color: var(--primary); }

        .hero-copy { max-width: 560px; margin: 20px 0 0; color: var(--text-dim); font-size: 16px; line-height: 1.7; }
        .hero-copy strong, .section-text strong, .feature span strong, .timeline-item span strong { color: var(--text); font-weight: 600; }
        .hero-actions { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 28px; }
        .hero-stats { display: grid; grid-template-columns: repeat(3, minmax(0,1fr)); gap: 12px; margin-top: 40px; max-width: 480px; }
        .stat { padding: 0; border-left: 1px solid var(--border); padding-left: 14px; }
        .stat:first-child { border-left: none; padding-left: 0; }
        .stat span { display: block; color: var(--text-mute); font-size: 12px; font-weight: 500; }
        .stat strong { display: block; margin-top: 4px; font-size: 16px; font-family: 'Manrope', sans-serif; font-weight: 700; color: var(--text); }

        /* ── CHAT MOCKUP ──────────────────────────────── */
        .chat-mock { border: 1px solid var(--border); border-radius: var(--radius); background: var(--surface); box-shadow: var(--shadow-lg); overflow: hidden; }
        .chat-mock-top { display: flex; align-items: center; justify-content: space-between; padding: 14px 18px; border-bottom: 1px solid var(--border); }
        .chat-mock-who { display: flex; align-items: center; gap: 10px; }
        .chat-avatar {
            width: 34px; height: 34px; border-radius: 50%;
            background: linear-gradient(145deg, var(--primary), var(--accent));
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-weight: 700; font-size: 13px; font-family: 'Manrope', sans-serif;
            position: relative; flex: 0 0 auto;
        }
        .status-dot { width: 9px; height: 9px; border-radius: 50%; background: var(--green); position: absolute; right: -1px; bottom: -1px; border: 2px solid var(--surface); }
        .chat-mock-who strong { display: block; font-size: 13.5px; font-weight: 600; }
        .chat-mock-who span { display: block; font-size: 12px; color: var(--text-mute); margin-top: 1px; }
        .chat-mock-icons { display: flex; gap: 12px; color: var(--text-mute); font-size: 14px; }
        .chat-mock-body { padding: 18px; display: flex; flex-direction: column; gap: 12px; min-height: 300px; }
        .msg-row { display: flex; gap: 8px; max-width: 82%; }
        .msg-row.me { align-self: flex-end; flex-direction: row-reverse; }
        .msg-avatar {
            width: 26px; height: 26px; border-radius: 50%; flex: 0 0 auto;
            background: var(--surface-2); border: 1px solid var(--border);
            display: flex; align-items: center; justify-content: center;
            font-size: 10px; font-weight: 700; color: var(--text-dim);
        }
        .msg-bubble { padding: 10px 14px; border-radius: 14px; font-size: 13.5px; line-height: 1.5; background: var(--surface-2); color: var(--text); }
        .msg-row.me .msg-bubble { background: var(--primary); color: #fff; border-bottom-right-radius: 4px; }
        .msg-row:not(.me) .msg-bubble { border-bottom-left-radius: 4px; }
        .msg-time { font-size: 10.5px; color: var(--text-mute); margin-top: 4px; display: block; }
        .typing-row { display: flex; align-items: center; gap: 8px; }
        .typing-bubble { padding: 10px 14px; border-radius: 14px; border-bottom-left-radius: 4px; background: var(--surface-2); display: flex; gap: 4px; align-items: center; }
        .typing-bubble span { width: 5px; height: 5px; border-radius: 50%; background: var(--text-mute); animation: typingDot 1.2s ease-in-out infinite; }
        .typing-bubble span:nth-child(2) { animation-delay: .15s; }
        .typing-bubble span:nth-child(3) { animation-delay: .3s; }
        @keyframes typingDot {
            0%, 60%, 100% { transform: translateY(0); opacity: .4; }
            30% { transform: translateY(-3px); opacity: 1; }
        }
        .chat-mock-input {
            display: flex; align-items: center; gap: 10px;
            margin: 0 18px 18px; padding: 10px 14px;
            border: 1px solid var(--border-2); border-radius: 12px;
            color: var(--text-mute); font-size: 13px; background: var(--surface);
        }
        .chat-mock-input i { color: var(--text-mute); font-size: 13px; }

        /* ── CONVERSATION LIST ─────────────────────────── */
        .convo-item { display: flex; align-items: center; gap: 12px; padding: 12px; border-radius: 12px; transition: background .18s ease; }
        .convo-item.active { background: var(--surface-2); border: 1px solid var(--border); }
        .convo-avatar {
            width: 38px; height: 38px; border-radius: 50%; flex: 0 0 auto; position: relative;
            background: linear-gradient(145deg, #A78BFA, #818CF8);
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-weight: 700; font-size: 13px; font-family: 'Manrope', sans-serif;
        }
        .convo-item:nth-child(2) .convo-avatar { background: linear-gradient(145deg, #34D399, #10B981); }
        .convo-item:nth-child(3) .convo-avatar { background: linear-gradient(145deg, var(--primary), var(--accent)); }
        .convo-main { flex: 1; min-width: 0; }
        .convo-top-row { display: flex; justify-content: space-between; gap: 8px; }
        .convo-main strong { font-size: 13.5px; font-weight: 600; }
        .convo-main span.time { font-size: 11px; color: var(--text-mute); flex: 0 0 auto; }
        .convo-preview { display: flex; justify-content: space-between; gap: 8px; margin-top: 2px; }
        .convo-preview span { font-size: 12.5px; color: var(--text-mute); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .unread-badge {
            min-width: 18px; height: 18px; padding: 0 5px; border-radius: 999px;
            background: var(--primary); color: #fff; font-size: 10.5px; font-weight: 700;
            display: flex; align-items: center; justify-content: center; flex: 0 0 auto;
        }

        .panel { border: 1px solid var(--border); border-radius: var(--radius); background: var(--surface); box-shadow: var(--shadow-md); }
        .glass-box { padding: 28px; }
        .section-title { margin: 0; font-size: clamp(28px, 3.4vw, 40px); line-height: 1.15; font-family: 'Manrope', sans-serif; font-weight: 800; color: var(--text); }
        .section-text { margin: 14px 0 0; color: var(--text-dim); line-height: 1.7; font-size: 15px; }

        .feature-list { display: grid; gap: 8px; margin-top: 16px; }
        .feature { padding: 14px; border-radius: 14px; background: var(--surface-2); border: 1px solid transparent; transition: border-color .2s ease, transform .2s ease; display: flex; gap: 14px; align-items: flex-start; }
        .feature:hover { border-color: var(--border-2); transform: translateY(-2px); }
        .feature-ico { width: 36px; height: 36px; border-radius: 10px; flex: 0 0 auto; background: var(--surface); border: 1px solid var(--border); display: flex; align-items: center; justify-content: center; color: var(--primary); font-size: 14px; }
        .feature strong { display: block; margin-bottom: 3px; font-size: 13.5px; font-weight: 600; color: var(--text); }
        .feature span { color: var(--text-dim); font-size: 12.5px; line-height: 1.5; }

        .status-card { padding: 26px; }
        .status-top { display: flex; justify-content: space-between; gap: 10px; align-items: center; }
        .status-top span { color: var(--text-mute); font-size: 12px; font-weight: 500; }
        .status-top strong { font-size: 15.5px; font-weight: 700; font-family: 'Manrope', sans-serif; display: flex; align-items: center; gap: 8px; }
        .pulse-bar { height: 6px; margin-top: 18px; border-radius: 999px; background: var(--surface-2); position: relative; overflow: hidden; }
        .pulse-bar::after { content: ""; position: absolute; left: 0; top: 0; bottom: 0; width: 72%; border-radius: 999px; background: var(--primary); }
        .meta-grid { display: grid; grid-template-columns: repeat(2, minmax(0,1fr)); gap: 10px; margin-top: 18px; }
        .meta { padding: 14px; border-radius: 12px; background: var(--surface-2); }
        .meta span { display: block; font-size: 11px; color: var(--text-mute); font-weight: 500; }
        .meta strong { display: block; margin-top: 6px; font-size: 15px; font-weight: 700; font-family: 'Manrope', sans-serif; }
        .spotlight { display: grid; gap: 8px; margin-top: 18px; }
        .spot-card { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 12px 14px; border-radius: 12px; background: var(--surface-2); }
        .spot-card em { font-style: normal; color: var(--text-mute); font-size: 11px; font-weight: 500; }
        .spot-card strong { display: block; font-size: 12.5px; font-weight: 600; margin: 3px 0 0; line-height: 1.4; color: var(--text); }
        .mini-bars { display: flex; align-items: end; gap: 3px; height: 20px; }
        .mini-bars span { width: 4px; border-radius: 999px; background: var(--primary); opacity: 0.7; }
        .mini-bars span:nth-child(1) { height: 8px; }
        .mini-bars span:nth-child(2) { height: 14px; }
        .mini-bars span:nth-child(3) { height: 18px; }
        .mini-bars span:nth-child(4) { height: 10px; }
        .mini-bars span:nth-child(5) { height: 16px; }
        .mini-bars span:nth-child(6) { height: 6px; }

        /* ── FEATURES SHOWCASE ────────────────────────── */
        .features-section { padding: 100px 0 0; }
        .section-head { display: flex; justify-content: space-between; align-items: end; gap: 16px; margin-bottom: 8px; }
        .section-head p { margin: 0; color: var(--text-dim); max-width: 420px; line-height: 1.6; font-size: 14.5px; }
        .features-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 16px; margin-top: 32px; }
        .feature-card {
            padding: 28px; border-radius: var(--radius); background: var(--surface); border: 1px solid var(--border);
            box-shadow: var(--shadow-sm); transition: transform .22s ease, box-shadow .22s ease, border-color .22s ease;
            display: flex; flex-direction: column; gap: 12px; height: 100%;
        }
        .feature-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-md); border-color: var(--border-2); }
        .feature-icon { width: 44px; height: 44px; border-radius: 12px; background: var(--surface-2); color: var(--primary); display: flex; align-items: center; justify-content: center; font-size: 18px; }
        .feature-card h3 { margin: 0; font-size: 16px; font-weight: 700; font-family: 'Manrope', sans-serif; color: var(--text); }
        .feature-card p { margin: 0; color: var(--text-dim); line-height: 1.6; font-size: 13.5px; }

        /* ── LIVE / DEVICE SECTION ─────────────────────── */
        .live-section { padding: 100px 0 0; }
        .live-grid { display: grid; grid-template-columns: 0.9fr 1.1fr; gap: 40px; align-items: center; }
        .device-frame { width: 300px; margin: 0 auto; background: #111113; border-radius: 36px; padding: 10px; box-shadow: var(--shadow-lg); }
        .device-screen { border-radius: 28px; overflow: hidden; background: var(--surface); display: flex; flex-direction: column; }
        .device-status-bar { display: flex; justify-content: space-between; padding: 14px 18px 4px; font-size: 12px; font-weight: 600; color: var(--text); }
        .device-body { padding: 12px 14px 16px; display: flex; flex-direction: column; gap: 10px; }
        .live-features { display: grid; gap: 20px; }
        .live-feature { display: flex; gap: 16px; align-items: flex-start; }
        .live-feature .feature-icon { flex: 0 0 auto; }
        .live-feature strong { display: block; margin-bottom: 4px; font-size: 15px; font-weight: 700; color: var(--text); }
        .live-feature span { color: var(--text-dim); font-size: 13.5px; line-height: 1.5; }

        .stats-section { padding: 100px 0 0; }
        .stats-showcase { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 1px; background: var(--border); border: 1px solid var(--border); border-radius: var(--radius); overflow: hidden; }
        .stat-item { text-align: center; display: flex; flex-direction: column; gap: 6px; padding: 34px 20px; background: var(--surface); }
        .stat-number { font-size: 34px; font-weight: 800; font-family: 'Manrope', sans-serif; color: var(--text); }
        .stat-label { color: var(--text-mute); font-size: 12px; font-weight: 600; }

        .testimonials-section { padding: 100px 0 0; }
        .testimonial-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 16px; margin-top: 32px; }
        .testimonial-card {
            padding: 26px; border-radius: var(--radius); background: var(--surface); border: 1px solid var(--border);
            box-shadow: var(--shadow-sm); transition: transform .2s ease, box-shadow .2s ease; display: flex; flex-direction: column; gap: 14px;
        }
        .testimonial-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-md); }
        .testimonial-stars { color: #F5A623; font-size: 13px; letter-spacing: 2px; }
        .testimonial-text { color: var(--text-dim); line-height: 1.7; font-size: 14.5px; margin: 0; }
        .testimonial-author { display: flex; gap: 12px; margin-top: 4px; align-items: center; }
        .author-avatar {
            width: 40px; height: 40px; border-radius: 50%; background: linear-gradient(145deg, var(--primary), var(--accent));
            display: flex; align-items: center; justify-content: center; font-weight: 700; color: white; font-size: 15px;
            font-family: 'Manrope', sans-serif; flex: 0 0 auto;
        }
        .author-info strong { display: block; font-size: 13.5px; font-weight: 700; }
        .author-info span { display: block; color: var(--text-mute); font-size: 12px; margin-top: 2px; }

        .comparison-section { padding: 100px 0 0; }
        .comparison-table { width: 100%; border-collapse: collapse; background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); overflow: hidden; box-shadow: var(--shadow-sm); }
        .comparison-table th { background: var(--surface-2); padding: 18px 20px; border-bottom: 1px solid var(--border); font-weight: 700; color: var(--text); text-align: left; font-size: 14px; }
        .comparison-table td { padding: 18px 20px; border-bottom: 1px solid var(--border); color: var(--text-dim); font-size: 13.5px; }
        .comparison-table tr:last-child td { border-bottom: 0; }
        .check-icon { color: var(--green); font-weight: 700; }
        .cross-icon { color: var(--text-mute); opacity: 0.6; }

        .divider { margin: 100px 0 0; height: 1px; background: var(--border); }

        .cta-section { padding: 100px 0 0; }
        .cta-container { background: linear-gradient(160deg, #0F0F13, #1C1C22); border-radius: var(--radius); padding: 64px 32px; text-align: center; }
        .cta-content h2 { margin: 0 0 12px; font-size: clamp(26px, 3vw, 34px); font-family: 'Manrope', sans-serif; font-weight: 800; color: #fff; }
        .cta-content p { margin: 0 0 28px; color: #A1A1AA; max-width: 520px; margin-left: auto; margin-right: auto; line-height: 1.6; font-size: 15px; }
        .cta-buttons { display: flex; gap: 14px; justify-content: center; flex-wrap: wrap; }
        .cta-container .button-ghost { border-color: rgba(255,255,255,0.16); color: #E4E4E7; }
        .cta-container .button-ghost:hover { background: rgba(255,255,255,0.06); border-color: rgba(255,255,255,0.28); color: #fff; }

        .about { padding: 100px 0 60px; }
        .about-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-top: 32px; }
        .about-card { padding: 30px; }
        .about-card h3 { margin: 0 0 10px; font-size: 16px; font-family: 'Manrope', sans-serif; font-weight: 700; color: var(--text); }
        .about-card p { margin: 0; color: var(--text-dim); line-height: 1.65; font-size: 13.5px; }
        .chips { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 20px; }
        .chip { padding: 7px 14px; border-radius: 999px; background: var(--surface-2); border: 1px solid var(--border); font-size: 12.5px; font-weight: 600; color: var(--text-dim); display: inline-flex; align-items: center; gap: 6px; }
        .timeline { display: grid; gap: 0; margin-top: 6px; }
        .timeline-item { display: flex; gap: 14px; align-items: flex-start; padding: 14px 0; border-top: 1px solid var(--border); }
        .timeline-item:first-child { border-top: 0; padding-top: 0; }
        .timeline-item b { min-width: 76px; color: var(--text-mute); font-size: 11px; text-transform: uppercase; letter-spacing: 0.06em; font-weight: 700; }
        .timeline-item span { color: var(--text-dim); line-height: 1.55; font-size: 13.5px; }
        .developer { display: flex; flex-direction: column; justify-content: space-between; }
        .developer strong { display: block; margin-top: 24px; font-size: 15.5px; font-weight: 700; font-family: 'Manrope', sans-serif; color: var(--text); }

        @media (max-width: 1100px) { .hero-grid, .about-grid, .live-grid { grid-template-columns: 1fr; } }
        @media (max-width: 760px) {
            .wrap { width: calc(100% - 28px); }
            .topbar { flex-direction: column; align-items: stretch; gap: 12px; }
            .nav { justify-content: flex-start; }
            .glass-box, .about-card { padding: 22px; }
            .hero-stats, .meta-grid { grid-template-columns: 1fr; }
            .section-head { flex-direction: column; align-items: flex-start; gap: 10px; }
            .stats-showcase { grid-template-columns: repeat(2, 1fr); }
            .comparison-table { font-size: 12.5px; }
            .comparison-table th, .comparison-table td { padding: 12px; }
            .cta-container { padding: 40px 22px; }
            .cta-buttons { flex-direction: column; }
            .cta-buttons .button { width: 100%; }
            .divider { margin: 64px 0 0; }
            .features-section, .live-section, .stats-section, .testimonials-section, .comparison-section, .cta-section { padding-top: 64px; }
            .about { padding: 64px 0 40px; }
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
<body class="loading">

<div id="loader">
    <div class="loader-inner">
        <div class="loader-mark">TC</div>
        <div class="loader-dots"><span></span><span></span><span></span></div>
        <div class="loader-text">Loading TeamConnect...</div>
    </div>
</div>

<div id="page-content">
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
                    <section class="reveal">
                        <div class="badge"><span class="dot"></span> Real-time messaging platform for instant conversations</div>
                        <h1>Chat smarter.<br><span class="accent">Connect faster.</span></h1>
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

                    <aside class="reveal">
                        <div class="chat-mock">
                            <div class="chat-mock-top">
                                <div class="chat-mock-who">
                                    <div class="chat-avatar">RS<span class="status-dot"></span></div>
                                    <div>
                                        <strong>Riya Sharma</strong>
                                        <span>Online now</span>
                                    </div>
                                </div>
                                <div class="chat-mock-icons">
                                    <i class="fa-solid fa-magnifying-glass"></i>
                                    <i class="fa-solid fa-ellipsis"></i>
                                </div>
                            </div>
                            <div class="chat-mock-body">
                                <div class="msg-row">
                                    <div class="msg-avatar">RS</div>
                                    <div>
                                        <div class="msg-bubble">Hey! Did you check the new dashboard update?</div>
                                        <span class="msg-time">9:41 AM</span>
                                    </div>
                                </div>
                                <div class="msg-row me">
                                    <div>
                                        <div class="msg-bubble">Yep, looks great. Syncing feels instant now.</div>
                                        <span class="msg-time">9:42 AM</span>
                                    </div>
                                </div>
                                <div class="msg-row">
                                    <div class="msg-avatar">RS</div>
                                    <div>
                                        <div class="msg-bubble">Sharing the file now 📎 project-brief.pdf</div>
                                        <span class="msg-time">9:43 AM</span>
                                    </div>
                                </div>
                                <div class="typing-row">
                                    <div class="msg-avatar">RS</div>
                                    <div class="typing-bubble"><span></span><span></span><span></span></div>
                                </div>
                            </div>
                            <div class="chat-mock-input"><i class="fa-regular fa-face-smile"></i> Type a message... <i class="fa-solid fa-paper-plane" style="margin-left:auto;"></i></div>
                        </div>
                    </aside>
                </div>
            </main>

            <!-- ═══ FEATURES SHOWCASE ═══════════════════════════════════ -->
            <section class="features-section reveal">
                <div class="section-head">
                    <div>
                        <div class="badge">
                            <span class="dot"></span>
                            ✨ Premium Features
                        </div>
                        <h2 class="section-title" style="margin-top: 14px;">
                            🚀 Everything you need for seamless collaboration
                        </h2>
                    </div>

                    <p>
                        TeamConnect packs powerful tools into an intuitive interface,
                        designed for teams that value both productivity and user experience.
                    </p>
                </div>

                <div class="features-grid">

                    <div class="feature-card reveal">
                        <div class="feature-icon">
                            <i class="fa-solid fa-bolt"></i>
                        </div>
                        <h3>⚡ Lightning-Fast Sync</h3>
                        <p>
                            Real-time message synchronization across all devices.
                            See updates instantly without any lag or delays.
                        </p>
                    </div>

                    <div class="feature-card reveal">
                        <div class="feature-icon">
                            <i class="fa-solid fa-lock"></i>
                        </div>
                        <h3>🔒 Enterprise Security</h3>
                        <p>
                            End-to-end encryption, secure session management,
                            and role-based access control for your conversations.
                        </p>
                    </div>

                    <div class="feature-card reveal">
                        <div class="feature-icon">
                            <i class="fa-solid fa-cloud-arrow-up"></i>
                        </div>
                        <h3>☁️ Cloud Storage</h3>
                        <p>
                            Unlimited file and media sharing with automatic backup.
                            Find any file you've shared in seconds.
                        </p>
                    </div>

                    <div class="feature-card reveal">
                        <div class="feature-icon">
                            <i class="fa-solid fa-users"></i>
                        </div>
                        <h3>👥 Team Management</h3>
                        <p>
                            Organize conversations by teams, projects,
                            or departments with granular permission controls.
                        </p>
                    </div>

                    <div class="feature-card reveal">
                        <div class="feature-icon">
                            <i class="fa-solid fa-bell"></i>
                        </div>
                        <h3>🔔 Smart Notifications</h3>
                        <p>
                            Customizable alerts and notification preferences ensure
                            you never miss important messages.
                        </p>
                    </div>

                    <div class="feature-card reveal">
                        <div class="feature-icon">
                            <i class="fa-solid fa-chart-line"></i>
                        </div>
                        <h3>📊 Analytics Dashboard</h3>
                        <p>
                            Track engagement metrics, message history,
                            and team activity with comprehensive reporting tools.
                        </p>
                    </div>

                </div>
            </section>
            <!-- ═══ LIVE / DEVICE SECTION ═══════════════════════════════ -->
            <section class="live-section reveal">
                <div class="section-head">
                    <div>
                        <div class="badge"><span class="dot"></span> Always Connected</div>
                        <h2 class="section-title" style="margin-top: 14px;">Chat anywhere, anytime</h2>
                    </div>
                </div>
                <div class="live-grid" style="margin-top: 32px;">
                    <div class="device-frame reveal">
                        <div class="device-screen">
                            <div class="device-status-bar"><span>9:41</span><span><i class="fa-solid fa-signal"></i></span></div>
                            <div class="device-body">
                                <div class="convo-item active">
                                    <div class="convo-avatar">RS</div>
                                    <div class="convo-main">
                                        <div class="convo-top-row"><strong>Riya Sharma</strong><span class="time">9:43</span></div>
                                        <div class="convo-preview"><span>Sharing the file now 📎</span><span class="unread-badge">2</span></div>
                                    </div>
                                </div>
                                <div class="convo-item">
                                    <div class="convo-avatar">DP</div>
                                    <div class="convo-main">
                                        <div class="convo-top-row"><strong>Dev Patel</strong><span class="time">9:12</span></div>
                                        <div class="convo-preview"><span>Sounds good, see you then</span></div>
                                    </div>
                                </div>
                                <div class="convo-item">
                                    <div class="convo-avatar">Team</div>
                                    <div class="convo-main">
                                        <div class="convo-top-row"><strong>Design Team</strong><span class="time">Yesterday</span></div>
                                        <div class="convo-preview"><span>Aisha: Updated the mockups</span></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="live-features reveal">
                        <div class="live-feature">
                            <div class="feature-icon"><i class="fa-solid fa-mobile-screen"></i></div>
                            <div>
                                <strong>Mobile Optimized</strong>
                                <span>A perfect experience on every device, from phone to desktop, with no compromise on speed or clarity.</span>
                            </div>
                        </div>
                        <div class="live-feature">
                            <div class="feature-icon"><i class="fa-solid fa-bolt"></i></div>
                            <div>
                                <strong>Lightning Speed</strong>
                                <span>Messages deliver instantly, with read receipts and typing indicators that keep conversations flowing.</span>
                            </div>
                        </div>
                        <div class="live-feature">
                            <div class="feature-icon"><i class="fa-solid fa-shield-halved"></i></div>
                            <div>
                                <strong>Secure & Private</strong>
                                <span>Session-based authentication and encrypted storage keep every conversation protected.</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- ═══ STATS SHOWCASE ═════════════════════════════════════ -->
            <section class="stats-section reveal">
                <div class="section-head">
                    <div>
                        <div class="badge"><span class="dot"></span> By The Numbers</div>
                        <h2 class="section-title" style="margin-top: 14px;">Trusted by teams worldwide</h2>
                    </div>
                </div>
                <div class="stats-showcase" style="margin-top: 32px;">
                    <div class="stat-item">
                        <div class="stat-number counter" data-target="50">0</div>
                        <div class="stat-label">Teams Active</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number counter" data-target="500">0</div>
                        <div class="stat-label">Messages Daily</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number counter" data-target="99" data-suffix="%">0</div>
                        <div class="stat-label">Uptime</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number counter" data-target="24">0</div>
                        <div class="stat-label">Hour Support</div>
                    </div>
                </div>
            </section>

            <!-- ═══ TESTIMONIALS ═══════════════════════════════════════ -->
            <section class="testimonials-section reveal">
                <div class="section-head">
                    <div>
                        <div class="badge"><span class="dot"></span> Social Proof</div>
                        <h2 class="section-title" style="margin-top: 14px;">Loved by teams and professionals</h2>
                    </div>
                    <p>See what people are saying about TeamConnect and how it's transforming workplace communication.</p>
                </div>
                <div class="testimonial-grid">
                    <div class="testimonial-card reveal">
                        <div class="testimonial-stars">★★★★★</div>
                        <p class="testimonial-text">"TeamConnect has completely changed how our team communicates. The interface is intuitive, the features are robust, and the support is exceptional."</p>
                        <div class="testimonial-author">
                            <div class="author-avatar">SJ</div>
                            <div class="author-info">
                                <strong>Sarah Johnson</strong>
                                <span>Product Manager, Tech Innovations Inc.</span>
                            </div>
                        </div>
                    </div>
                    <div class="testimonial-card reveal">
                        <div class="testimonial-stars">★★★★★</div>
                        <p class="testimonial-text">"We switched from our previous platform and haven't looked back. The security features are top-notch, and file sharing makes our workflow seamless."</p>
                        <div class="testimonial-author">
                            <div class="author-avatar">MK</div>
                            <div class="author-info">
                                <strong>Michael Khan</strong>
                                <span>CTO, Digital Solutions Ltd.</span>
                            </div>
                        </div>
                    </div>
                    <div class="testimonial-card reveal">
                        <div class="testimonial-stars">★★★★★</div>
                        <p class="testimonial-text">"As a distributed team spanning multiple time zones, TeamConnect ensures everyone stays connected. The real-time synchronization is flawless."</p>
                        <div class="testimonial-author">
                            <div class="author-avatar">EA</div>
                            <div class="author-info">
                                <strong>Emma Anderson</strong>
                                <span>Operations Lead, Global Ventures</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <div class="divider"></div>

            <!-- ═══ COMPARISON TABLE ═══════════════════════════════════ -->
            <section class="comparison-section reveal">
                <div class="section-head">
                    <div>
                        <div class="badge"><span class="dot"></span> Why Choose TeamConnect</div>
                        <h2 class="section-title" style="margin-top: 14px;">Superior to the competition</h2>
                    </div>
                    <p>See how TeamConnect stacks up against other messaging platforms with a feature-rich comparison.</p>
                </div>
                <div style="overflow-x: auto; margin-top: 32px;">
                    <table class="comparison-table">
                        <thead>
                        <tr>
                            <th>Feature</th>
                            <th>TeamConnect</th>
                            <th>Competitor A</th>
                            <th>Competitor B</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td><strong>Real-time Messaging</strong></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="check-icon">✓</span></td>
                        </tr>
                        <tr>
                            <td><strong>End-to-End Encryption</strong></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="cross-icon">✗</span></td>
                        </tr>
                        <tr>
                            <td><strong>File Sharing (100MB+)</strong></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="cross-icon">✗</span></td>
                            <td><span class="check-icon">✓</span></td>
                        </tr>
                        <tr>
                            <td><strong>Search History</strong></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="check-icon">✓</span></td>
                        </tr>
                        <tr>
                            <td><strong>Team Analytics</strong></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="cross-icon">✗</span></td>
                            <td><span class="cross-icon">✗</span></td>
                        </tr>
                        <tr>
                            <td><strong>Free Tier Available</strong></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="cross-icon">✗</span></td>
                        </tr>
                        <tr>
                            <td><strong>24/7 Support</strong></td>
                            <td><span class="check-icon">✓</span></td>
                            <td><span class="cross-icon">✗</span></td>
                            <td><span class="check-icon">✓</span></td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- ═══ CTA SECTION ════════════════════════════════════════ -->
            <section class="cta-section reveal">
                <div class="cta-container">
                    <div class="cta-content">
                        <h2>Ready to transform your team communication?</h2>
                        <p>Join hundreds of teams already using TeamConnect for seamless, secure, and scalable messaging. Get started in minutes.</p>
                        <div class="cta-buttons">
                            <a href="<%= contextPath %>/views/register.jsp" class="button button-primary" style="min-height: 46px; font-size: 15px; padding: 0 30px;">
                                Start Free Trial
                            </a>
                            <a href="#about" class="button button-ghost" style="min-height: 46px; font-size: 15px; padding: 0 30px;">
                                Learn More
                            </a>
                        </div>
                    </div>
                </div>
            </section>

            <section class="about" id="about">
                <div class="section-head reveal">
                    <div>
                        <div class="badge"><span class="dot"></span> About TeamConnect</div>
                        <h2 class="section-title" style="margin-top:14px;">A complete messaging platform, built end to end</h2>
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
                                Abhishek Samadhiya built TeamConnect with modern JSP and Servlet technology. The goal
                                is a premium workspace with clear conversation hierarchy, sophisticated visual separation, and a
                                presentation that feels deliberate, polished, and enterprise-ready.
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
                                <span>A calm, restrained blue-on-white palette inspired by premium SaaS products like Linear and Stripe.</span>
                            </div>
                            <div class="timeline-item">
                                <b>Workflow</b>
                                <span>Dashboard-first layout with intuitive message threading, advanced search, and elegant attachment handling.</span>
                            </div>
                            <div class="timeline-item">
                                <b>Motion</b>
                                <span>Subtle fade-up reveals and micro-interactions that enhance the interface without compromising clarity.</span>
                            </div>
                            <div class="timeline-item">
                                <b>Reliability</b>
                                <span>Built on proven enterprise technologies with robust error handling and always-on availability.</span>
                            </div>
                        </div>
                    </section>
                </div>
            </section>
        </div>
    </div>
</div>

<script>
    window.addEventListener('load', function () {
        setTimeout(function () {
            document.getElementById('loader').classList.add('hide');
            document.body.classList.remove('loading');
            document.getElementById('page-content').classList.add('show');
        }, 900);
    });

    var topbar = document.getElementById('topbar');
    window.addEventListener('scroll', function () {
        if (window.scrollY > 30) { topbar.classList.add('scrolled'); }
        else { topbar.classList.remove('scrolled'); }
    });

    var reveals = document.querySelectorAll('.reveal');
    var observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (entry.isIntersecting) { entry.target.classList.add('show'); }
        });
    }, { threshold: 0.12 });
    reveals.forEach(function (el) { observer.observe(el); });

    var countersStarted = false;
    function animateCounters() {
        if (countersStarted) return;
        countersStarted = true;
        var counters = document.querySelectorAll('.counter');
        counters.forEach(function (counter) {
            var target = parseInt(counter.getAttribute('data-target'));
            var suffix = counter.getAttribute('data-suffix') || '';
            var current = 0;
            var increment = Math.ceil(target / 40);
            var interval = setInterval(function () {
                current += increment;
                if (current >= target) { current = target; clearInterval(interval); }
                counter.textContent = current + suffix;
            }, 30);
        });
    }
    var statsSection = document.querySelector('.stats-section');
    if (statsSection) {
        var statsObserver = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) { animateCounters(); statsObserver.unobserve(entry.target); }
            });
        }, { threshold: 0.4 });
        statsObserver.observe(statsSection);
    }
</script>
</body>
</html>
