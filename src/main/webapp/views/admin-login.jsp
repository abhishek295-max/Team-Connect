<%@ page contentType="text/html;charset=UTF-8" %>
<% String contextPath = request.getContextPath(); %>
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>TeamConnect Admin</title>
<script>(function(){var r=document.documentElement,t;try{t=localStorage.getItem('adminTheme')}catch(e){}if(!t)t=matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';r.dataset.theme=t})()</script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,700&family=IBM+Plex+Sans:wght@400;500;600&display=swap" rel="stylesheet">
<style>
:root{--bg:#eef3f9;--s:#ffffffcc;--in:#f5f8fc;--line:#d8e2ee;--tx:#0f2236;--mu:#62778c;--b1:#1f6feb;--b2:#33b5f5;--bd:#d6434f;--sh:0 30px 80px #1d4a7a26;--glow:#1f6feb33;--ui:"IBM Plex Sans","Segoe UI",system-ui,sans-serif;--se:"Fraunces",Georgia,serif;color-scheme:light}
[data-theme=dark]{--bg:#020818;--s:#0a1630cc;--in:#081228;--line:#1a2d52;--tx:#e7eefb;--mu:#8ca1c1;--b1:#4d8fff;--b2:#5fd3ff;--bd:#ff6b78;--sh:0 30px 80px #000000a0;--glow:#4d8fff40;color-scheme:dark}
*{box-sizing:border-box;margin:0}
body{position:relative;min-height:100vh;display:grid;place-items:center;padding:24px;overflow-x:hidden;background:var(--bg);color:var(--tx);font:400 14px/1.5 var(--ui);transition:background-color .4s,color .4s}
body::before,body::after{content:"";position:fixed;z-index:0;border-radius:50%;filter:blur(70px);pointer-events:none;opacity:.42}
body::before{width:540px;height:540px;top:-200px;right:-140px;background:radial-gradient(circle,var(--b2),transparent 65%);animation:drift 16s ease-in-out infinite alternate}
body::after{width:500px;height:500px;bottom:-220px;left:-120px;background:radial-gradient(circle,var(--b1),transparent 65%);animation:drift 20s ease-in-out infinite alternate-reverse}
[data-theme=dark] body::before,[data-theme=dark] body::after{opacity:.3}
.gridbg{position:fixed;inset:0;z-index:0;pointer-events:none;opacity:.35;background-image:linear-gradient(var(--line) 1px,transparent 1px),linear-gradient(90deg,var(--line) 1px,transparent 1px);background-size:46px 46px;-webkit-mask-image:radial-gradient(ellipse at 50% 40%,#000,transparent 72%);mask-image:radial-gradient(ellipse at 50% 40%,#000,transparent 72%)}
.i{width:18px;height:18px;flex:0 0 auto;fill:none;stroke:currentColor;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
.shell{position:relative;z-index:1;width:min(1000px,100%);height:min(680px,calc(100vh - 48px));min-height:540px;display:grid;grid-template-columns:1.05fr .95fr;border:1px solid var(--line);border-radius:26px;background:var(--s);box-shadow:var(--sh);backdrop-filter:blur(22px) saturate(130%);-webkit-backdrop-filter:blur(22px) saturate(130%);overflow:hidden;animation:enter .8s cubic-bezier(.2,.8,.2,1) both}
.vis{position:relative;display:flex;flex-direction:column;min-height:0;padding:34px 40px 28px;color:#fff;overflow:hidden;background:linear-gradient(145deg,#0a2a5e 0%,#1b64d6 58%,#38b6f7 100%)}
[data-theme=dark] .vis{background:linear-gradient(145deg,#030d24 0%,#0a2559 58%,#0f4a90 100%)}
.vis::before{content:"";position:absolute;inset:0;background:linear-gradient(105deg,transparent 30%,#ffffff1f 48%,transparent 66%);transform:translateX(-110%);animation:sweep 8s ease-in-out infinite}
.vis>*{position:relative}
.live{display:inline-flex;align-items:center;gap:8px;padding:6px 12px;border:1px solid #ffffff45;border-radius:99px;background:#ffffff1c;font-size:12px;font-weight:500}
.live i,.ld{width:8px;height:8px;border-radius:50%;background:#59f0b6;animation:ping 1.9s infinite}
.vis h2{margin:18px 0 8px;max-width:380px;font:600 clamp(24px,4.6vh,40px)/1.07 var(--se);letter-spacing:-.02em}
.vis p{max-width:330px;color:#d6e8fb;font-size:14px}
.scene{display:block;flex:1 1 0;min-height:0;width:100%;height:auto;margin:4px 0 0;overflow:visible}
.vs{display:flex;gap:30px;margin-top:10px}.vs strong{display:block;font:600 20px var(--se)}.vs span{display:block;color:#c1ddf4;font-size:12px}
.orb{transform-origin:230px 180px}.o1{animation:rot 26s linear infinite}.o2{animation:rot 40s linear infinite reverse}
.ring{fill:none;stroke:#ffffff40;stroke-width:1;stroke-dasharray:3 7}
.dotn{fill:#fff}.dotg{fill:#7ee8c7}
.shield{fill:#ffffff24;stroke:#fff;stroke-width:2.2;animation:glowS 3.4s ease-in-out infinite}
.chk{fill:none;stroke:#7ee8c7;stroke-width:5;stroke-linecap:round;stroke-linejoin:round;stroke-dasharray:80;animation:draw 4.5s ease-in-out infinite}
.lnk{fill:none;stroke:#ffffff66;stroke-width:1.3;stroke-dasharray:4 6;animation:dash 1.2s linear infinite}
.bub{fill:#ffffff26;stroke:#ffffff59}.bub.me{fill:#e8f6ff;stroke:none}
.ln1{fill:#ffffffb3}.me .ln1,.bub.me~.ln1{fill:#2a5a8c}
.tx1{fill:#fff;font:500 11px var(--ui)}.tx2{fill:#17446e;font:500 11px var(--ui)}
.fl1{animation:fl 6s ease-in-out infinite}.fl2{animation:fl 7s ease-in-out -2s infinite}.fl3{animation:fl 5s ease-in-out -3s infinite}
.ty circle{fill:#bfe6fb;animation:ty 1.2s infinite}.ty circle:nth-child(2){animation-delay:.15s}.ty circle:nth-child(3){animation-delay:.3s}
.form{position:relative;display:flex;flex-direction:column;justify-content:center;min-height:0;overflow:auto;padding:48px 50px}
.tg{position:absolute;top:18px;right:18px;width:40px;height:40px;display:grid;place-items:center;padding:0;border:1px solid var(--line);border-radius:12px;background:var(--in);color:var(--tx);cursor:pointer;transition:transform .2s,box-shadow .2s,border-color .2s}
.tg:hover{transform:translateY(-2px);border-color:var(--b1);box-shadow:0 10px 24px var(--glow)}
.tg svg{position:absolute;transition:transform .55s cubic-bezier(.2,.8,.2,1),opacity .3s}
.tg .sun{opacity:0;transform:rotate(-90deg) scale(.4)}
[data-theme=dark] .tg .sun{opacity:1;transform:none}[data-theme=dark] .tg .moon{opacity:0;transform:rotate(90deg) scale(.4)}
.brand{display:flex;align-items:center;gap:12px;margin-bottom:34px}
.mk{width:44px;height:44px;display:grid;place-items:center;border-radius:13px;color:#fff;font:700 16px var(--ui);background:linear-gradient(135deg,var(--b1),var(--b2));animation:mg 3.2s ease-in-out infinite}
.brand strong{display:block;font-size:17px;font-weight:600}.brand span{display:block;color:var(--mu);font-size:12px}
.form h1{margin-bottom:8px;font:600 32px/1.1 var(--se);letter-spacing:-.02em}
.form .sub{margin-bottom:22px;color:var(--mu)}
.error{display:flex;align-items:center;gap:8px;margin-bottom:14px;padding:10px 12px;border:1px solid var(--bd);border-radius:10px;color:var(--bd);background:var(--in);font-size:13px;animation:shake .5s}
.field{display:block;margin:14px 0;color:var(--mu);font-size:13px;font-weight:500}
.field input{display:block;width:100%;margin-top:7px;padding:12px 14px;border:1px solid var(--line);border-radius:11px;outline:0;background:var(--in);color:var(--tx);font:400 14px var(--ui);transition:border-color .2s,box-shadow .2s,transform .2s,background-color .3s}
.field input:hover{border-color:var(--b2)}.field input:focus{border-color:var(--b1);box-shadow:0 0 0 4px var(--glow);transform:translateY(-1px)}
.pw{position:relative;display:block}.pw input{padding-right:46px}
.eye{position:absolute;right:6px;bottom:5px;width:34px;height:34px;display:grid;place-items:center;padding:0;border:0;border-radius:9px;background:transparent;color:var(--mu);cursor:pointer;transition:color .2s,background-color .2s}
.eye:hover{color:var(--b1);background:var(--glow)}
.submit{position:relative;overflow:hidden;width:100%;min-height:48px;margin-top:12px;border:0;border-radius:11px;color:#fff;font:600 14px var(--ui);cursor:pointer;background:linear-gradient(110deg,var(--b1),var(--b2),var(--b1));background-size:220% 100%;box-shadow:0 12px 26px var(--glow);animation:sheen 6s linear infinite;transition:transform .2s,box-shadow .2s}
.submit:hover{transform:translateY(-2px);box-shadow:0 16px 30px var(--glow)}.submit:active{transform:scale(.98)}
.submit::after{content:"";position:absolute;inset:0;background:linear-gradient(110deg,transparent,#ffffff55,transparent);transform:translateX(-110%);animation:shine 4s ease-in-out infinite}
.submit.busy{pointer-events:none;opacity:.85}.submit.busy::before{content:"";display:inline-block;width:14px;height:14px;margin-right:8px;vertical-align:-2px;border:2px solid #fff6;border-top-color:#fff;border-radius:50%;animation:rot .7s linear infinite}
.note{display:flex;align-items:center;gap:8px;margin-top:20px;color:var(--mu);font-size:12px}
.note .ld{background:var(--b2)}
:is(a,button,input):focus-visible{outline:2px solid var(--b2);outline-offset:2px}
.st>*{animation:rise .7s cubic-bezier(.2,.8,.2,1) backwards}
.st>:nth-child(1){animation-delay:.25s}.st>:nth-child(2){animation-delay:.32s}.st>:nth-child(3){animation-delay:.39s}.st>:nth-child(4){animation-delay:.46s}.st>:nth-child(5){animation-delay:.53s}.st>:nth-child(6){animation-delay:.6s}.st>:nth-child(7){animation-delay:.67s}
@keyframes enter{from{opacity:0;transform:translateY(24px) scale(.98)}}
@keyframes rise{from{opacity:0;transform:translateY(16px)}}
@keyframes drift{to{transform:translate(60px,36px) scale(1.15)}}
@keyframes sweep{0%,45%{transform:translateX(-110%)}75%,100%{transform:translateX(110%)}}
@keyframes ping{0%{box-shadow:0 0 0 0 #59f0b680}70%{box-shadow:0 0 0 8px #59f0b600}100%{box-shadow:0 0 0 0 #59f0b600}}
@keyframes rot{to{transform:rotate(360deg)}}
@keyframes dash{to{stroke-dashoffset:-20}}
@keyframes draw{0%{stroke-dashoffset:80}30%,80%{stroke-dashoffset:0}100%{stroke-dashoffset:-80}}
@keyframes glowS{0%,100%{filter:drop-shadow(0 0 6px #7ee8c755)}50%{filter:drop-shadow(0 0 18px #7ee8c7aa)}}
@keyframes fl{0%,100%{transform:translateY(0)}50%{transform:translateY(-9px)}}
@keyframes ty{0%,60%,100%{opacity:.35;transform:translateY(0)}30%{opacity:1;transform:translateY(-3px)}}
@keyframes mg{0%,100%{box-shadow:0 10px 24px var(--glow)}50%{box-shadow:0 10px 34px var(--b1)}}
@keyframes sheen{to{background-position:220% 0}}
@keyframes shine{0%,45%{transform:translateX(-110%)}70%,100%{transform:translateX(110%)}}
@keyframes shake{20%,60%{transform:translateX(-6px)}40%,80%{transform:translateX(6px)}}
@media(max-height:700px){.vis p{display:none}.brand{margin-bottom:22px}.form{padding-top:40px;padding-bottom:28px}}
@media(max-width:860px){.shell{grid-template-columns:1fr;height:auto}.scene{flex:none;max-height:260px}.vis{padding:28px 28px 20px}.vs{display:none}.vis p{display:none}.scene{max-width:420px;margin:0 auto}.form{padding:44px 28px 32px}}
@media(prefers-reduced-motion:reduce){*,*::before,*::after{animation-duration:.01ms!important;animation-iteration-count:1!important;transition-duration:.01ms!important}}
</style>
</head>
<body>
<div class="gridbg"></div>
<main class="shell">
<section class="vis">
    <span class="live"><i></i>Secure control center</span>
    <h2>Your workspace, governed with care.</h2>
    <p>Manage people, access and account operations from one focused enterprise console.</p>
    <svg class="scene" viewBox="0 -10 460 350" preserveAspectRatio="xMidYMid meet" aria-hidden="true">
        <defs><radialGradient id="halo"><stop offset="0" stop-color="#7ee8c7" stop-opacity=".35"/><stop offset="1" stop-color="#7ee8c7" stop-opacity="0"/></radialGradient></defs>
        <circle cx="230" cy="165" r="110" fill="url(#halo)"/>
        <g class="orb o1"><circle class="ring" cx="230" cy="180" r="118"/><circle class="dotg" cx="348" cy="180" r="5"/><circle class="dotn" cx="171" cy="282" r="4"/><circle class="dotn" cx="171" cy="78" r="4"/></g>
        <g class="orb o2"><circle class="ring" cx="230" cy="180" r="158"/><circle class="dotn" cx="388" cy="180" r="4"/><circle class="dotg" cx="151" cy="317" r="5"/><circle class="dotn" cx="151" cy="43" r="3"/></g>
        <path id="l1" class="lnk" d="M96 66 Q160 90 215 150"/><path id="l2" class="lnk" d="M372 258 Q300 240 250 200"/><path id="l3" class="lnk" d="M366 56 Q300 90 250 140"/>
        <circle r="3.5" fill="#7ee8c7"><animateMotion dur="2.8s" repeatCount="indefinite"><mpath href="#l1"/></animateMotion></circle>
        <circle r="3.5" fill="#fff"><animateMotion dur="3.2s" begin="-1s" repeatCount="indefinite"><mpath href="#l2"/></animateMotion></circle>
        <circle r="3.5" fill="#7ee8c7"><animateMotion dur="3s" begin="-2s" repeatCount="indefinite"><mpath href="#l3"/></animateMotion></circle>
        <circle cx="230" cy="180" r="40" fill="none" stroke="#7ee8c7"><animate attributeName="r" values="40;86" dur="3s" repeatCount="indefinite"/><animate attributeName="opacity" values=".7;0" dur="3s" repeatCount="indefinite"/></circle>
        <path class="shield" d="M230 132 L278 150 V190 C278 220 258 240 230 249 C202 240 182 220 182 190 V150 Z"/>
        <path class="chk" d="M207 190 l17 17 l30 -34"/>
        <g class="fl1"><rect class="bub" x="22" y="34" width="150" height="54" rx="14"/><circle cx="44" cy="55" r="11" fill="#fff"/><text x="44" y="59" text-anchor="middle" style="fill:#1b64d6;font:700 9px var(--ui)">TC</text><text class="tx1" x="64" y="52">New account</text><text class="tx1" x="64" y="68" style="opacity:.8">provisioned</text><g class="ty"><circle cx="40" cy="78" r="2.2"/><circle cx="48" cy="78" r="2.2"/><circle cx="56" cy="78" r="2.2"/></g></g>
        <g class="fl2"><rect class="bub me" x="290" y="262" width="150" height="40" rx="14"/><text class="tx2" x="365" y="286" text-anchor="middle">Access rules synced</text></g>
        <g class="fl3"><rect class="bub" x="320" y="30" width="118" height="36" rx="12"/><circle cx="340" cy="48" r="4.5" fill="#59f0b6"/><text class="tx1" x="352" y="52">Live delivery</text></g>
    </svg>
    <div class="vs"><div><strong>24/7</strong><span>Workspace control</span></div><div><strong>Secure</strong><span>Admin session</span></div></div>
</section>
<section class="form">
    <button class="tg" id="themeToggle" type="button" aria-label="Toggle light and dark mode"><svg class="i moon" viewBox="0 0 24 24"><path d="M20 14.5A8.5 8.5 0 0 1 9.5 4 8.5 8.5 0 1 0 20 14.5z"/></svg><svg class="i sun" viewBox="0 0 24 24"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2M5 5l1.5 1.5M17.5 17.5L19 19M5 19l1.5-1.5M17.5 6.5L19 5"/></svg></button>
    <div class="st">
        <div class="brand"><div class="mk">TC</div><div><strong>TeamConnect</strong><span>Administrator access</span></div></div>
        <h1>Admin sign in</h1>
        <p class="sub">Manage registered accounts from the protected administration area.</p>
        <% if ("1".equals(request.getParameter("error"))) { %><div class="error"><svg class="i" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 7v6M12 16.5v.5"/></svg>Invalid administrator credentials.</div><% } %>
        <form method="post" action="<%= contextPath %>/admin/login" id="loginForm">
            <label class="field">Username<input name="username" autocomplete="username" required></label>
            <label class="field">Password<span class="pw"><input type="password" name="password" autocomplete="current-password" required><button class="eye" id="eye" type="button" aria-label="Show password"><svg class="i" viewBox="0 0 24 24"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg></button></span></label>
            <button class="submit" type="submit">Sign in to admin panel</button>
        </form>
        <div class="note"><i class="ld"></i>Systems online and protected</div>
    </div>
</section>
</main>
<script>
(function () {
    var d = document, r = d.documentElement;
    var tg = d.getElementById('themeToggle');
    tg.setAttribute('aria-pressed', r.dataset.theme === 'dark');
    tg.addEventListener('click', function () {
        var t = r.dataset.theme === 'dark' ? 'light' : 'dark';
        r.dataset.theme = t;
        tg.setAttribute('aria-pressed', t === 'dark');
        try { localStorage.setItem('adminTheme', t); } catch (e) {}
    });
    var eye = d.getElementById('eye'), pw = d.querySelector('input[name=password]');
    eye.addEventListener('click', function () {
        var show = pw.type === 'password';
        pw.type = show ? 'text' : 'password';
        eye.setAttribute('aria-label', show ? 'Hide password' : 'Show password');
        pw.focus();
    });
    d.getElementById('loginForm').addEventListener('submit', function () {
        d.querySelector('.submit').classList.add('busy');
    });
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
        var s = d.querySelector('.scene');
        if (s && s.pauseAnimations) s.pauseAnimations();
    }
})();
</script>
</body>
</html>
