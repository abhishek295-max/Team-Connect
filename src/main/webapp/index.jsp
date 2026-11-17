<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% String contextPath = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>TeamConnect · One workspace for modern teams</title>
<style>
:root{--ink:#f2fbf8;--muted:#98a6bd;--line:rgba(255,255,255,.12);--em:#398BFF;--cy:#B7C4D8;--vi:#D9A86C;--bg:#080D18;--max:1240px;--f:'Segoe UI',system-ui,-apple-system,Roboto,'Helvetica Neue',Arial,sans-serif}
*{box-sizing:border-box}html{scroll-behavior:smooth}
body{margin:0;background:var(--bg);color:var(--ink);font-family:var(--f);overflow-x:hidden}
a{color:inherit;text-decoration:none}button{font:inherit}
.i{width:1em;height:1em;fill:none;stroke:currentColor;stroke-width:2;stroke-linecap:round;stroke-linejoin:round;vertical-align:-.125em;flex:none}
#scene{position:fixed;inset:0;width:100%;height:100%;z-index:-2;display:block}
.veil{position:fixed;inset:0;z-index:-1;pointer-events:none;background:radial-gradient(ellipse at 50% 40%,transparent 30%,rgba(8,13,24,.75) 100%);transition:background .4s}
body.deep .veil{background:linear-gradient(rgba(8,13,24,.78),rgba(8,13,24,.86))}
/* ===== 3D cinematic loader ===== */
.loader{position:fixed;inset:0;z-index:50;background:linear-gradient(160deg,#1e2c42,#0f1726);overflow:hidden;transition:opacity .9s,visibility .9s}
.loader.hide{opacity:0;visibility:hidden;pointer-events:none}
#tcc{position:absolute;inset:0;width:100%;height:100%;display:block;opacity:0;transition:opacity 1.2s;filter:contrast(1.02) saturate(1.05)}
#tcwm{position:absolute;inset:0;width:100%;height:100%;display:block;pointer-events:none;z-index:3}
#tcfl{position:absolute;left:0;right:0;top:50%;height:90px;margin-top:-45px;z-index:2;pointer-events:none;opacity:0;background:linear-gradient(90deg,transparent,rgba(37,99,235,.2) 20%,rgba(245,158,11,.25) 38%,rgba(245,247,250,.4) 50%,rgba(22,163,106,.25) 62%,transparent);filter:blur(18px)}
.loader::after{content:"";position:absolute;inset:0;pointer-events:none;background:radial-gradient(ellipse at center,transparent 65%,rgba(15,23,38,.35))}
.loader::before{content:"";position:absolute;inset:-50%;z-index:1;pointer-events:none;opacity:.025;background:url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='200' height='200'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='2'/></filter><rect width='100%' height='100%' filter='url(%23n)'/></svg>");animation:gr .5s steps(4) infinite}
.lbar{position:absolute;left:0;right:0;height:7vh;background:#0d1522;z-index:2;transition:transform 1s cubic-bezier(.6,0,.2,1)}
.lbar.t{top:0}
.lbar.b{bottom:0}
#tcmsg{position:absolute;left:0;right:0;bottom:11vh;text-align:center;z-index:3;letter-spacing:.28em;font-size:clamp(11px,1.6vw,15px);color:#F5F7FA;text-shadow:0 2px 14px rgba(13,21,34,.8);text-transform:uppercase;opacity:0;transform:translateY(6px);transition:opacity .6s ease,transform .6s ease;padding:0 16px}
#tcmsg.on{opacity:1;transform:none}
#tcfallback{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:12px;z-index:1;color:#F5F7FA;pointer-events:none;transition:opacity .5s}
#tcfallback strong{font-size:24px;letter-spacing:.3em;color:#F5F7FA;font-weight:800}
#tcfallback span{color:#CBD5E1;font-size:11px;letter-spacing:.24em;text-transform:uppercase}
.loader.ready #tcfallback{opacity:0}
#tcprog{position:absolute;left:50%;bottom:9vh;width:min(240px,50vw);height:3px;border-radius:3px;background:rgba(203,213,225,.25);transform:translateX(-50%);z-index:3;transition:opacity .6s;overflow:hidden}
#tcbar{height:100%;width:0;border-radius:3px;background:linear-gradient(90deg,#2563EB,#16A36A,#F59E0B);box-shadow:0 0 10px rgba(37,99,235,.5);transition:width .3s}
.intro-skip{position:absolute;right:max(16px,env(safe-area-inset-right));top:max(18px,env(safe-area-inset-top));z-index:4;padding:9px 18px;border:1px solid rgba(245,247,250,.6);border-radius:999px;background:rgba(38,54,77,.75);backdrop-filter:blur(8px);-webkit-backdrop-filter:blur(8px);color:#F5F7FA;font:600 11px var(--f);letter-spacing:.15em;text-transform:uppercase;cursor:pointer;transition:background .2s,border-color .2s,transform .2s}
.intro-skip:hover{background:rgba(37,99,235,.8);border-color:#F5F7FA;transform:translateY(-1px)}
/* ===== end loader ===== */
#page{opacity:0;transition:opacity 1s ease}#page.show{opacity:1}
.wrap{width:min(var(--max),calc(100% - 48px));margin:auto}
.navbar{position:fixed;top:16px;left:0;right:0;z-index:30;display:flex;justify-content:center;pointer-events:none}
.nav{pointer-events:auto;width:min(1120px,calc(100% - 32px));height:64px;padding:0 12px 0 18px;display:flex;align-items:center;justify-content:space-between;gap:20px;border-radius:18px;background:rgba(8,13,24,.55);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);border:1px solid rgba(190,215,210,.2);box-shadow:0 10px 40px rgba(0,0,0,.4),inset 0 1px rgba(255,255,255,.08)}
.brand{display:flex;align-items:center;gap:11px;font:800 16px var(--f);letter-spacing:-.02em}
.brand-mark{width:36px;height:36px;border-radius:11px;display:grid;place-items:center;background:linear-gradient(135deg,var(--em),#1f5fc4);color:#F5F7FA;font-size:13px}
.navlinks{display:flex;gap:6px;font-size:13px;color:#B7C4D8}
.navlinks a{position:relative;padding:9px 13px;transition:color .25s}
.navlinks a:after{content:"";position:absolute;left:13px;right:13px;bottom:3px;height:2px;border-radius:2px;background:linear-gradient(90deg,var(--em),var(--cy));transform:scaleX(0);transform-origin:left;transition:transform .3s}
.navlinks a:hover{color:#fff}.navlinks a:hover:after{transform:scaleX(1)}
.nav-actions{display:flex;gap:8px}
.btn{display:inline-flex;align-items:center;justify-content:center;gap:9px;height:44px;padding:0 20px;border:1px solid var(--line);border-radius:12px;color:#F5F7FA;font-size:13px;font-weight:700;letter-spacing:.03em;transition:.3s;cursor:pointer}
.btn:hover{transform:translateY(-3px);border-color:rgba(255,255,255,.35)}
.btn.primary{border:0;color:#F5F7FA;background:linear-gradient(135deg,var(--em),var(--cy));box-shadow:0 0 30px rgba(57,139,255,.3)}
.btn.primary:hover{box-shadow:0 0 48px rgba(57,139,255,.55)}
.btn.subtle{background:rgba(255,255,255,.05)}
.hero{min-height:100vh;position:relative;display:flex;align-items:center;justify-content:center;text-align:center;padding:120px 0 80px}
.hero-inner{max-width:900px;padding:0 20px;opacity:0;transform:translateY(30px);transition:opacity 1.6s ease,transform 1.6s ease}
.hero-inner.on{opacity:1;transform:none}
.eyebrow{display:inline-flex;align-items:center;gap:9px;padding:8px 14px;border:1px solid rgba(57,139,255,.35);border-radius:99px;background:rgba(57,139,255,.08);color:#B7C4D8;font-size:11px;font-weight:700;letter-spacing:.12em;text-transform:uppercase}
.hero h1{font:800 clamp(38px,7vw,86px)/1 var(--f);letter-spacing:-.05em;margin:24px 0 22px;text-transform:uppercase}
.hero h1 em{font-style:normal;background:linear-gradient(100deg,var(--em),var(--cy),var(--vi));-webkit-background-clip:text;background-clip:text;color:transparent}
.hero-copy{max-width:600px;margin:auto;color:#B7C4D8;line-height:1.75;font-size:17px}
.hero-actions{display:flex;gap:12px;justify-content:center;flex-wrap:wrap;margin-top:34px}
.hint{position:absolute;bottom:26px;left:50%;transform:translateX(-50%);color:#8fa0b8;font-size:11px;letter-spacing:.2em;text-transform:uppercase;white-space:nowrap}
.section{padding:120px 0}
.kicker{color:var(--em);font-size:11px;font-weight:700;letter-spacing:.16em;text-transform:uppercase}
.section h2{font:800 clamp(28px,4.6vw,54px)/1.06 var(--f);letter-spacing:-.045em;margin:12px 0 0;max-width:760px;text-transform:uppercase}
.section-head{display:flex;justify-content:space-between;gap:30px;align-items:end;margin-bottom:44px}
.section-head p{color:#8fa0b8;line-height:1.7;max-width:380px;font-size:14px;margin:0}
.panel{position:relative;overflow:hidden;border:1px solid rgba(190,230,220,.14);border-radius:22px;padding:26px;background:linear-gradient(150deg,rgba(20,36,61,.7),rgba(8,13,24,.78));backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px);transition:transform .35s,border-color .35s,box-shadow .35s}
.panel:hover{border-color:rgba(57,139,255,.5);box-shadow:0 24px 60px rgba(0,0,0,.4),0 0 40px rgba(57,139,255,.1)}
.panel:before{content:"";position:absolute;left:0;top:0;right:0;height:1px;background:linear-gradient(90deg,transparent,var(--em),transparent);opacity:.6}
.ico{width:42px;height:42px;border-radius:12px;display:grid;place-items:center;background:rgba(57,139,255,.1);color:var(--em);margin-bottom:22px;font-size:19px}
.panel h3{font:700 19px var(--f);margin:0 0 9px}.panel p{color:#8fa0b8;font-size:13px;line-height:1.7;margin:0}
.panel .more{display:inline-flex;gap:7px;align-items:center;margin-top:18px;color:var(--em);font-weight:700;font-size:12px}
.grid3{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}
.grid3 .panel:nth-child(3n+2) .ico{background:rgba(183,196,216,.1);color:var(--cy)}
.grid3 .panel:nth-child(3n) .ico{background:rgba(217,168,108,.12);color:#D9A86C}
.network{position:relative;height:340px;margin-bottom:16px;border-radius:22px;border:1px solid rgba(190,230,220,.14);background:rgba(8,13,24,.6);overflow:hidden}
.network canvas{width:100%;height:100%;display:block}
.net-label{position:absolute;left:20px;top:16px;font-size:11px;letter-spacing:.14em;text-transform:uppercase;color:#8fa0b8}
.cta{position:relative;overflow:hidden;text-align:center;padding:90px 40px;border-radius:30px;border:1px solid rgba(57,139,255,.3);background:radial-gradient(circle at 50% 0,rgba(57,139,255,.2),transparent 55%),rgba(8,13,24,.7);backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px)}
.cta h2{margin:12px auto 0}.cta p{color:#B7C4D8;max-width:520px;margin:18px auto 26px;line-height:1.7}
.footer{position:relative;padding:60px 0 40px;border-top:1px solid var(--line);display:flex;justify-content:space-between;align-items:center;gap:20px;flex-wrap:wrap;color:#6f819b;font-size:12px}
.footer:before{content:"";position:absolute;top:-1px;left:10%;right:10%;height:1px;background:linear-gradient(90deg,transparent,var(--em),transparent);animation:glow 4s ease-in-out infinite}
@keyframes glow{50%{opacity:.2}}
.footer strong{font:700 15px var(--f);color:#d6e0ee}.footer-links{display:flex;gap:22px}.footer-links a:hover{color:#fff}
.reveal{opacity:0;transform:translateY(30px);transition:opacity .9s cubic-bezier(.2,.8,.2,1),transform .9s cubic-bezier(.2,.8,.2,1)}.reveal.show{opacity:1;transform:none}
@media(max-width:980px){.navlinks{display:none}.grid3{grid-template-columns:1fr 1fr}.section-head{flex-direction:column;align-items:start}}
@media(max-width:650px){.wrap{width:calc(100% - 30px)}.nav-actions .subtle{display:none}.grid3{grid-template-columns:1fr}.section{padding:80px 0}.cta{padding:56px 22px}.footer{flex-direction:column;align-items:flex-start}.network{height:260px}}
@media(prefers-reduced-motion:reduce){*{animation-duration:.01ms!important;transition-duration:.01ms!important;scroll-behavior:auto!important}.reveal,.hero-inner{opacity:1;transform:none}}
</style>
</head>
<body>
<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs>
<symbol id="i-arrow" viewBox="0 0 24 24"><path d="M5 12h14M13 6l6 6-6 6"/></symbol>
<symbol id="i-out" viewBox="0 0 24 24"><path d="M7 17L17 7M8 7h9v9"/></symbol>
<symbol id="i-play" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M10 8l6 4-6 4z"/></symbol>
<symbol id="i-chat" viewBox="0 0 24 24"><path d="M21 12a8 8 0 0 1-11.5 7.2L4 20l1-4.5A8 8 0 1 1 21 12z"/></symbol>
<symbol id="i-shield" viewBox="0 0 24 24"><path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z"/></symbol>
<symbol id="i-check" viewBox="0 0 24 24"><path d="M5 12l5 5 9-10"/></symbol>
<symbol id="i-bolt" viewBox="0 0 24 24"><path d="M13 3L5 14h6l-1 7 8-11h-6z"/></symbol>
<symbol id="i-user" viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/></symbol>
<symbol id="i-users" viewBox="0 0 24 24"><circle cx="9" cy="8" r="3.5"/><path d="M2 20c0-3.5 3-5.5 7-5.5s7 2 7 5.5"/><circle cx="17" cy="9" r="2.5"/><path d="M17 14.5c3 0 5 1.5 5 4"/></symbol>
<symbol id="i-sliders" viewBox="0 0 24 24"><path d="M4 6h8M18 6h2M4 12h2M12 12h8M4 18h10M20 18h0"/><circle cx="15" cy="6" r="2"/><circle cx="9" cy="12" r="2"/><circle cx="17" cy="18" r="2"/></symbol>
<symbol id="i-sync" viewBox="0 0 24 24"><path d="M20 11a8 8 0 0 0-14-4L4 9M4 4v5h5M4 13a8 8 0 0 0 14 4l2-2M20 20v-5h-5"/></symbol>
<symbol id="i-mega" viewBox="0 0 24 24"><path d="M3 11v2a1 1 0 0 0 1 1h3l8 4V6L7 10H4a1 1 0 0 0-1 1zM19 9a4 4 0 0 1 0 6"/></symbol>
<symbol id="i-rocket" viewBox="0 0 24 24"><path d="M5 19c0-3 1-5 3-6l3 3c-1 2-3 3-6 3zM9 13l6-9c3 0 5 2 5 5l-9 6"/></symbol>
<symbol id="i-chart" viewBox="0 0 24 24"><path d="M3 3v18h18M7 15l4-4 3 3 6-7"/></symbol>
</defs></svg>
<canvas id="scene" aria-hidden="true"></canvas><div class="veil" aria-hidden="true"></div>
<div class="loader" id="loader" aria-label="TeamConnect cinematic introduction"><canvas id="tcc"></canvas><div id="tcfallback" aria-hidden="true"><strong>TEAMCONNECT</strong><span>Preparing your experience...</span></div><div class="lbar t"></div><div class="lbar b"></div><div id="tcfl"></div><canvas id="tcwm"></canvas><div id="tcmsg"></div><div id="tcprog"><div id="tcbar"></div></div><button class="intro-skip" id="introSkip" type="button">Skip intro</button></div>
<div id="page">
<div class="navbar"><header class="nav"><a class="brand" href="#top"><div class="brand-mark">TC</div>TeamConnect</a>
<nav class="navlinks"><a href="#top">Home</a><a href="#platform">Platform</a><a href="#roles">For teams</a><a href="#security">Security</a><a href="#about">About</a></nav>
<div class="nav-actions"><a class="btn subtle" href="<%= contextPath %>/views/register.jsp">Sign in</a><a class="btn primary" href="<%= contextPath %>/views/register.jsp">Enter workspace <svg class="i"><use href="#i-out"/></svg></a></div></header></div>
<main id="top">
<section class="hero"><div class="hero-inner" id="heroText"><div class="eyebrow">The modern work operating system</div>
<h1>The future of <em>workforce</em> management</h1>
<p class="hero-copy">Transform how your organization manages people, performance, attendance and productivity through one intelligent enterprise platform.</p>
<div class="hero-actions"><a class="btn primary" href="<%= contextPath %>/views/register.jsp">Get started <svg class="i"><use href="#i-arrow"/></svg></a><a class="btn" href="#platform"><svg class="i"><use href="#i-play"/></svg> Explore platform</a></div></div>
<div class="hint">Scroll to enter</div></section>

<section class="section" id="security"><div class="wrap">
<div class="section-head reveal"><div><div class="kicker">Connected workforce</div><h2>One workforce. One intelligent ecosystem.</h2></div><p>Move from a conversation to a decision, an approval or an employee update without losing context.</p></div>
<div class="network reveal"><div class="net-label">Live workforce graph · illustrative</div><canvas id="netCanvas"></canvas></div>
<div class="grid3">
<article class="panel reveal"><div class="ico"><svg class="i"><use href="#i-shield"/></svg></div><h3>Protected workspace</h3><p>Private by design, with access shaped around every role.</p></article>
<article class="panel reveal"><div class="ico"><svg class="i"><use href="#i-check"/></svg></div><h3>Approvals in context</h3><p>Leave and people requests move forward from the same place the conversation started.</p></article>
<article class="panel reveal"><div class="ico"><svg class="i"><use href="#i-bolt"/></svg></div><h3>Instant updates</h3><p>Announcements reach the right teams as they happen.</p></article></div>
</div></section>

<section class="section" id="platform"><div class="wrap">
<div class="section-head reveal"><div><div class="kicker">Platform</div><h2>Everything your team needs, in one command center.</h2></div><p>Real-time collaboration and people operations in a single connected system.</p></div>
<div class="grid3">
<article class="panel reveal"><div class="ico"><svg class="i"><use href="#i-chat"/></svg></div><h3>Conversations</h3><p>Real-time chat, channels, notifications and files designed around the way teams collaborate.</p></article>
<article class="panel reveal"><div class="ico"><svg class="i"><use href="#i-shield"/></svg></div><h3>Role-aware by default</h3><p>Every role sees the tools and records they need.</p></article>
<article class="panel reveal"><div class="ico"><svg class="i"><use href="#i-sync"/></svg></div><h3>People operations</h3><p>Attendance, leave, payroll and documents stay connected.</p></article>
<article class="panel reveal"><div class="ico"><svg class="i"><use href="#i-mega"/></svg></div><h3>Announcements</h3><p>Share updates with the right teams instantly.</p></article>
<article class="panel reveal"><div class="ico"><svg class="i"><use href="#i-rocket"/></svg></div><h3>Projects</h3><p>Keep project work beside the people doing it.</p></article>
<article class="panel reveal"><div class="ico"><svg class="i"><use href="#i-chart"/></svg></div><h3>Insights</h3><p>Simple insights help leaders act with confidence.</p></article>
</div></div></section>

<section class="section" id="roles"><div class="wrap">
<div class="section-head reveal"><div><div class="kicker">Designed for every role</div><h2>A focused experience for every kind of work.</h2></div><p>Sign in with your role and land exactly where your day begins.</p></div>
<div class="grid3">
<article class="panel reveal"><div class="ico"><svg class="i"><use href="#i-user"/></svg></div><h3>Employee workspace</h3><p>Check your profile, attendance, leave, projects and documents, then open chat without switching context.</p><a class="more" href="<%= contextPath %>/ems/login">Open employee workspace <svg class="i"><use href="#i-arrow"/></svg></a></article>
<article class="panel reveal"><div class="ico"><svg class="i"><use href="#i-users"/></svg></div><h3>HR &amp; manager hub</h3><p>Keep approvals, people updates, projects and team communication moving from one responsive dashboard.</p><a class="more" href="<%= contextPath %>/views/register.jsp">Continue to sign in <svg class="i"><use href="#i-arrow"/></svg></a></article>
<article class="panel reveal"><div class="ico"><svg class="i"><use href="#i-sliders"/></svg></div><h3>Admin command center</h3><p>Manage users, roles, announcements, system settings and operational visibility with confidence.</p><a class="more" href="<%= contextPath %>/views/register.jsp">Admin access <svg class="i"><use href="#i-arrow"/></svg></a></article>
</div></div></section>

<section class="section" id="about" style="padding-top:0"><div class="wrap"><div class="cta reveal"><div class="kicker">Ready when you are</div><h2>Build the future of your workforce.</h2><p>Bring your people, processes and productivity together in one intelligent platform.</p><a class="btn primary" href="<%= contextPath %>/views/register.jsp">Get started today <svg class="i"><use href="#i-arrow"/></svg></a></div></div></section>
</main>
<div class="wrap"><footer class="footer"><div><strong>TeamConnect</strong><br><span>Connected work, beautifully.</span></div><div class="footer-links"><a href="#platform">Platform</a><a href="#roles">Teams</a><a href="#security">Security</a><a href="<%= contextPath %>/views/register.jsp">Sign in</a><a href="#top" id="replayIntro">Replay intro</a></div><span>© 2026 TeamConnect</span></footer></div>
</div>

<!-- ===== 3D loader engine (exposes window.TCIntro; loads three.js on demand) ===== -->
<script>
(function(){
var cancelled=false,api={};
function loadThree(cb){
 if(window.THREE){cb(true);return}
 var settled=false,timer=setTimeout(function(){finish(false)},8000);
 function finish(ok){if(settled)return;settled=true;clearTimeout(timer);cb(ok)}
 var s=document.createElement('script');
 s.src='https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js';
 s.onload=function(){finish(true)};s.onerror=function(){finish(false)};
 document.head.appendChild(s);
}
api.stop=function(){cancelled=true};
api.start=function(onReveal,onFail){
 loadThree(function(ok){
  if(!ok){onFail();return}
  if(cancelled)return;
  boot(onReveal).catch(function(e){console.error(e);onFail()});
 });
};
window.TCIntro=api;

async function boot(onReveal){
const $=s=>document.querySelector(s),cvs=$('#tcc'),msg=$('#tcmsg');
const wait=ms=>new Promise(r=>setTimeout(r,ms)),frame=()=>new Promise(r=>{let d=0;const f=()=>{if(!d){d=1;r()}};requestAnimationFrame(f);setTimeout(f,80)});
const setMsg=t=>{msg.classList.remove('on');setTimeout(()=>{if(t){msg.textContent=t;msg.classList.add('on')}},t?320:0)};
const T3=THREE,small=innerWidth<700;

/* ===== Sophisticated Realistic Corporate Palette ===== */
const C={
 blue:0x2563EB,blueLight:0x3B82F6,blueDark:0x1D4ED8,
 green:0x16A36A,greenLight:0x34D399,greenDark:0x059669,
 white:0xF5F7FA,amber:0xF59E0B,amberLight:0xFBBF24,
 silver:0xCBD5E1,slate:0x26364D,slateDark:0x162234,slateLight:0x384D68,
 wood:0xA87950,woodDark:0x7A5333,woodLight:0xC3966D,
 concrete:0xE3DFD7,steel:0xBAC5D2
};

const R=new T3.WebGLRenderer({canvas:cvs,antialias:!small,powerPreference:'high-performance'});
R.setPixelRatio(Math.min(devicePixelRatio||1,small?1:1.5));
R.outputEncoding=T3.sRGBEncoding;R.toneMapping=T3.ACESFilmicToneMapping;R.toneMappingExposure=1.02;
R.shadowMap.enabled=!small;R.shadowMap.type=T3.PCFSoftShadowMap;

const S=new T3.Scene();
S.background=new T3.Color(0xdde5eb);
S.fog=new T3.FogExp2(0xe5e8e7,0.0045);

const cam=new T3.PerspectiveCamera(45,1,.1,950);
const clamp=(x,a=0,b=1)=>Math.min(b,Math.max(a,x)),sm=x=>(x=clamp(x))*x*(3-2*x),lerp=(a,b,k)=>a+(b-a)*k;
const M=(c,r=.5,m=0,o={})=>new T3.MeshStandardMaterial(Object.assign({color:c,roughness:r,metalness:m,envMapIntensity:.55},o));
const EM=c=>new T3.MeshBasicMaterial({color:c});
const bx=(w,h,d,m,x,y,z,p=S,sh=true)=>{const o=new T3.Mesh(new T3.BoxGeometry(w,h,d),m);o.position.set(x,y,z);o.castShadow=o.receiveShadow=sh;p.add(o);return o};

const cv=(w,h,fn)=>{
 const c=document.createElement('canvas');c.width=w;c.height=h;
 fn(c.getContext('2d'),w,h);
 const t=new T3.CanvasTexture(c);t.encoding=T3.sRGBEncoding;t.anisotropy=small?2:4;
 return t;
};

/* ===== High-End Realistic Materials ===== */
const glass=new T3.MeshPhysicalMaterial({color:0xf0f5f7,roughness:.13,metalness:.04,transparent:true,opacity:.34,depthWrite:false,envMapIntensity:1.15,side:T3.DoubleSide,clearcoat:.32,clearcoatRoughness:.16});
const glassInterior=new T3.MeshPhysicalMaterial({color:0xf2f5f5,roughness:.2,metalness:.02,transparent:true,opacity:.24,depthWrite:false,envMapIntensity:.9,side:T3.DoubleSide});
const steel=M(0xc4c9c8,.34,.72);
const chrome=M(0xe5e7e5,.2,.78);
const concrete=M(0xd9d4ca,.88,.01);
const darkSlate=M(C.slate,.58,.22);
const pure=M(C.white,.75,.02);

const $bar=$('#tcbar'),stages=[];
let rig,twin,reader={},doors=[],gates=[],npcs=[],cars=[],pm;
const mir=new T3.Group();mir.scale.y=-1;S.add(mir);

/* ===== Dynamic Card Scanner Screen ===== */
const rc=document.createElement('canvas');rc.width=280;rc.height=175;
const rg=rc.getContext('2d'),rt=new T3.CanvasTexture(rc);rt.encoding=T3.sRGBEncoding;let rs=-1;
function readerDraw(s,p){
 if(s===rs&&s!==1)return;rs=s;const g=rg;g.textAlign='center';
 if(s===0){
  /* Standby: Subtle Emerald Green Beacon & Clean Corporate Card Target */
  g.fillStyle='#1c2a3d';g.fillRect(0,0,280,175);
  g.strokeStyle='#2e435f';g.lineWidth=2;g.strokeRect(6,6,268,163);
  g.fillStyle='#2563EB';g.fillRect(16,14,248,6);
  g.fillStyle='#F5F7FA';g.font='700 20px Arial,sans-serif';g.fillText('TEAMCONNECT',140,46);
  g.fillStyle='#CBD5E1';g.font='600 11px Arial,sans-serif';g.fillText('ENTERPRISE ACCESS PORTAL',140,64);
  /* Standby pulse ring */
  g.strokeStyle='rgba(22,163,106,0.3)';g.lineWidth=3;g.beginPath();g.arc(140,108,24,0,Math.PI*2);g.stroke();
  g.fillStyle='#16A36A';g.beginPath();g.arc(140,108,16,0,Math.PI*2);g.fill();
  g.fillStyle='#F5F7FA';g.font='700 11px Arial,sans-serif';g.fillText('RFID',140,112);
  g.fillStyle='#CBD5E1';g.font='600 12px Arial,sans-serif';g.fillText('TAP EMPLOYEE ID BADGE',140,150);
 }else if(s===1){
  /* Scanning: Realistic Light Movement Across Card Area */
  g.fillStyle='#162334';g.fillRect(0,0,280,175);
  g.fillStyle='#2563EB';g.fillRect(16,14,248,6);
  g.fillStyle='#F5F7FA';g.font='700 18px Arial,sans-serif';g.fillText('VERIFYING CREDENTIALS...',140,44);
  /* Card silhouette on reader */
  g.strokeStyle='#CBD5E1';g.lineWidth=2;g.strokeRect(70,62,140,84);
  g.fillStyle='rgba(245,247,250,0.08)';g.fillRect(70,62,140,84);
  /* A restrained reader light moves across the badge. */
  const sx=lerp(76,204,clamp(p));
  const q=g.createLinearGradient(sx-8,0,sx+8,0);
  q.addColorStop(0,'rgba(22,163,106,0)');q.addColorStop(.5,'rgba(22,163,106,.55)');q.addColorStop(1,'rgba(22,163,106,0)');
  g.fillStyle=q;g.fillRect(sx-8,62,16,84);
  g.fillStyle='#A7F3D0';g.font='700 12px Arial,sans-serif';g.fillText('READING SECURITY CHIP',140,162);
 }else{
  /* Verified: Vibrant Emerald Green Status, Clear Checkmark, Welcome Message */
  g.fillStyle='#0f3a2c';g.fillRect(0,0,280,175);
  g.fillStyle='#16A36A';g.fillRect(16,14,248,6);
  g.beginPath();g.arc(140,62,28,0,Math.PI*2);g.fillStyle='#16A36A';g.fill();
  g.strokeStyle='#F5F7FA';g.lineWidth=5;g.lineCap='round';g.lineJoin='round';
  g.beginPath();g.moveTo(126,62);g.lineTo(136,73);g.lineTo(156,51);g.stroke();
  g.fillStyle='#F5F7FA';g.font='800 20px Arial,sans-serif';g.fillText('ACCESS VERIFIED',140,114);
  g.fillStyle='#A7F3D0';g.font='600 13px Arial,sans-serif';g.fillText('WELCOME TO TEAMCONNECT',140,135);
  g.fillStyle='#CBD5E1';g.font='500 10px Arial,sans-serif';g.fillText('GATES UNLOCKED · HAVE A GREAT DAY',140,154);
 }
 rt.needsUpdate=true;
}
readerDraw(0,0);

/* ===== Procedural Textures ===== */
/* Modern curtain-wall facade */
const facTex=cv(512,512,(g,w,h)=>{
 const q=g.createLinearGradient(0,0,w,h);
 q.addColorStop(0,'#8299a5');q.addColorStop(.45,'#a8b7b9');q.addColorStop(1,'#718994');
 g.fillStyle=q;g.fillRect(0,0,w,h);
 for(let r=0;r<8;r++){
  for(let c=0;c<8;c++){
   const shade=92+Math.floor(Math.random()*42);
   g.fillStyle='rgba('+shade+','+(shade+24)+','+(shade+28)+','+(.08+Math.random()*.1)+')';
   g.fillRect(c*64+5,r*64+6,54,52);
   if((r+c)%3===0){
    g.fillStyle='rgba(255,224,174,0.09)';
    g.fillRect(c*64+12,r*64+24,40,24);
   }
  }
 }
 g.strokeStyle='rgba(221,230,229,.48)';g.lineWidth=3;
 for(let i=0;i<=8;i++){g.beginPath();g.moveTo(i*64,0);g.lineTo(i*64,h);g.stroke()}
 for(let i=0;i<=8;i++){g.beginPath();g.moveTo(0,i*64);g.lineTo(w,i*64);g.stroke()}
});

/* Skyline window texture */
const winTex=cv(256,512,(g,w,h)=>{
 g.fillStyle='#a9b5b7';g.fillRect(0,0,w,h);
 const P=['#9eafb2','#b9c3c0','#899fa5','#c6ceca','#82989f','#e9d8bd','#d3dbd7'];
 for(let y=6;y<h;y+=30){
  for(let x=6;x<w;x+=30){
   g.fillStyle=P[Math.floor(Math.random()*P.length)];
   g.fillRect(x,y,22,22);
   g.fillStyle='rgba(245,247,250,.22)';g.fillRect(x+2,y+2,18,2);
  }
 }
 g.strokeStyle='rgba(231,237,235,.52)';g.lineWidth=2;
 for(let x=0;x<w;x+=30){g.beginPath();g.moveTo(x,0);g.lineTo(x,h);g.stroke()}
 for(let y=0;y<h;y+=30){g.beginPath();g.moveTo(0,y);g.lineTo(w,y);g.stroke()}
});

/* Natural European oak / walnut wood */
const woodTex=cv(512,512,(g,w,h)=>{
 g.fillStyle='#A87950';g.fillRect(0,0,w,h);
 for(let i=0;i<32;i++){
  g.fillStyle='rgba(75,44,22,'+(.05+Math.random()*.12)+')';
  g.fillRect(i*16,0,2.5,h);
  g.fillStyle='rgba(255,225,185,'+(Math.random()*.09)+')';
  g.fillRect(i*16+4,0,5,h);
 }
});
const wood=M(0xffffff,.48,.03,{map:woodTex});

/* Architectural stone plaza paving */
const plazaTex=cv(512,512,(g,w,h)=>{
 g.fillStyle='#cbd5e1';g.fillRect(0,0,w,h);
 const tiles=4;const sz=w/tiles;
 for(let r=0;r<tiles;r++){
  for(let c=0;c<tiles;c++){
   g.fillStyle=((r+c)%2===0)?'#d8e1eb':'#ccd7e4';
   g.fillRect(c*sz+3,r*sz+3,sz-6,sz-6);
   for(let p=0;p<40;p++){
    g.fillStyle='rgba(255,255,255,'+(Math.random()*.08)+')';
    g.fillRect(c*sz+Math.random()*sz,r*sz+Math.random()*sz,3,3);
   }
  }
 }
 g.strokeStyle='#9aa8ba';g.lineWidth=4;
 for(let i=0;i<=tiles;i++){g.beginPath();g.moveTo(i*sz,0);g.lineTo(i*sz,h);g.stroke();g.beginPath();g.moveTo(0,i*sz);g.lineTo(w,i*sz);g.stroke()}
});
plazaTex.wrapS=plazaTex.wrapT=T3.RepeatWrapping;plazaTex.repeat.set(35,35);
const plazaMat=M(0xffffff,.42,.04,{map:plazaTex});

/* Polished lobby terrazzo / marble floor */
const marbleTex=cv(512,512,(g,w,h)=>{
 g.fillStyle='#F5F7FA';g.fillRect(0,0,w,h);
 for(let i=0;i<600;i++){
  g.fillStyle=['rgba(37,99,235,.03)','rgba(203,213,225,.08)','rgba(245,158,11,.03)','rgba(22,163,106,.03)'][i%4];
  g.fillRect(Math.random()*w,Math.random()*h,4,4);
 }
 g.strokeStyle='rgba(203,213,225,.5)';g.lineWidth=2;
 for(let i=0;i<w;i+=128){g.beginPath();g.moveTo(i,0);g.lineTo(i,h);g.stroke();g.beginPath();g.moveTo(0,i);g.lineTo(w,i);g.stroke()}
});
marbleTex.wrapS=marbleTex.wrapT=T3.RepeatWrapping;marbleTex.repeat.set(6,8);
const marbleMat=M(0xffffff,.34,.025,{map:marbleTex});

/* Helper for repeating textures */
const rep=(t,x,y)=>{t=t.clone();t.needsUpdate=true;t.wrapS=t.wrapT=T3.RepeatWrapping;t.repeat.set(x,y);return t};
const bm=(t,w,h,k,col=0xffffff)=>{
 const x=rep(t,w,h);
 return new T3.MeshStandardMaterial({map:x,color:col,roughness:.5+k*.25,metalness:.12,envMapIntensity:.72});
};

/* Architectural Signage: Clean dimensional metallic letters */
function sign(txt,w,h,gk=1){
 const cw=2048,ch=Math.round(cw*h/w);
 const mk=fill=>{
  const c=document.createElement('canvas');c.width=cw;c.height=ch;const g=c.getContext('2d');
  let s=ch*.78,sp,tw;
  const f=()=>{g.font='800 '+s+'px Arial,Helvetica,sans-serif';sp=s*.1;return[...txt].reduce((a,l)=>a+g.measureText(l).width+sp,-sp)};
  tw=f();if(tw>cw*.94){s*=cw*.94/tw;tw=f()}
  g.textBaseline='middle';let x=(cw-tw)/2;
  g.fillStyle=typeof fill==='function'?fill(g,ch):fill;
  [...txt].forEach(l=>{g.fillText(l,x,ch/2+s*.03);x+=g.measureText(l).width+sp});
  const t=new T3.CanvasTexture(c);t.encoding=T3.sRGBEncoding;return t;
 };
 const mask=mk('#fff');
 const face=mk((g,h)=>{
  const q=g.createLinearGradient(0,0,0,h);
  q.addColorStop(0,'#ffffff');q.addColorStop(.5,'#F5F7FA');q.addColorStop(1,'#CBD5E1');
  return q;
 });
 const G=new T3.Group(),geo=new T3.PlaneGeometry(w,h);
 for(let i=0;i<3;i++){
  const m=new T3.Mesh(geo,new T3.MeshStandardMaterial({map:mask,alphaTest:.5,color:0x9ca9ba,metalness:.85,roughness:.35}));
  m.position.z=i*.02;G.add(m);
 }
 const f=new T3.Mesh(geo,new T3.MeshStandardMaterial({map:face,alphaTest:.5,metalness:.4,roughness:.3,emissive:0xffffff,emissiveMap:face,emissiveIntensity:.14*gk}));
 f.position.z=.07;G.add(f);return G;
}

/* ===== Human Characters (Diverse, Lifelike Professional Corporate Attire) ===== */
function human(o={}){
 const suit=M(o.suit??C.slate,.84),pants=M(o.pants??C.slateDark,.86);
 const shirt=M(o.shirt??C.white,.78),skin=M(o.skin??0xd4a373,.72,0,{envMapIntensity:.28});
 const hair=M(o.hair??0x241c16,.88),shoe=M(0x25231f,.62,.08);
 const tie=M(o.tie??C.amber,.55),wh=M(0xffffff,.6),dk=M(0x161310,.4);

 const g=new T3.Group(),add=(geo,m,p,par=g,rot)=>{
  const e=new T3.Mesh(geo,m);e.position.set(...p);if(rot)e.rotation.set(...rot);
  e.castShadow=true;par.add(e);return e;
 };
 const cy=(a,b,h,s=16)=>new T3.CylinderGeometry(a,b,h,s);
 const torso=new T3.Mesh(new T3.LatheGeometry([
  new T3.Vector2(0,-.32),new T3.Vector2(.14,-.3),new T3.Vector2(.18,-.18),
  new T3.Vector2(.18,.04),new T3.Vector2(.22,.2),new T3.Vector2(.235,.27),
  new T3.Vector2(.16,.31),new T3.Vector2(0,.31)
 ],24),suit);
 torso.position.y=1.22;torso.scale.z=.72;torso.castShadow=true;g.add(torso);
 const leftLapel=new T3.Shape();
 leftLapel.moveTo(-.07,.3);leftLapel.lineTo(-.01,.22);leftLapel.lineTo(-.08,.04);leftLapel.lineTo(-.15,.14);leftLapel.closePath();
 const rightLapel=new T3.Shape();
 rightLapel.moveTo(.07,.3);rightLapel.lineTo(.01,.22);rightLapel.lineTo(.08,.04);rightLapel.lineTo(.15,.14);rightLapel.closePath();
 const lapelMat=M(o.suit??C.slate,.78,0,{envMapIntensity:.35,side:T3.DoubleSide});
 add(new T3.ShapeGeometry(leftLapel),lapelMat,[0,1.22,.14]);
 add(new T3.ShapeGeometry(rightLapel),lapelMat,[0,1.22,.14]);
 if(!o.noTie){
  add(new T3.BoxGeometry(.11,.34,.02),shirt,[0,1.31,.11]);
  add(new T3.BoxGeometry(.038,.28,.012),tie,[0,1.28,.124]);
 }else{
  add(new T3.BoxGeometry(.13,.32,.02),shirt,[0,1.31,.11]);
 }
 add(cy(.048,.052,.11,8),skin,[0,1.57,0]);
 add(cy(.062,.066,.03,10),shirt,[0,1.52,0]);

 const head=new T3.Group();head.position.set(0,1.69,0);g.add(head);
 add(new T3.SphereGeometry(.108,24,18),skin,[0,0,0],head).scale.set(.9,1.14,1);
 add(new T3.SphereGeometry(.116,22,16,0,Math.PI*2,0,Math.PI*.55),hair,[0,.016,-.012],head).scale.set(.94,1.13,1.06);
 if(o.long)add(new T3.BoxGeometry(.2,.32,.08),hair,[0,-.09,-.078],head);
 add(new T3.BoxGeometry(.026,.042,.032),skin,[0,-.01,.108],head);
 add(new T3.BoxGeometry(.052,.009,.01),M(0x945042,.6),[0,-.046,.104],head);

 [-1,1].forEach(s=>{
  add(new T3.SphereGeometry(.019,6,6),skin,[s*.098,0,0],head);
  add(new T3.SphereGeometry(.017,8,6),wh,[s*.037,.01,.096],head);
  add(new T3.SphereGeometry(.01,8,6),dk,[s*.037,.01,.11],head);
  add(new T3.BoxGeometry(.042,.009,.01),hair,[s*.038,.036,.102],head);
  add(new T3.SphereGeometry(.074,10,8),suit,[s*.225,1.47,0]);
 });

 const leg=x=>{
  const hip=new T3.Group();hip.position.set(x,.94,0);g.add(hip);
  add(cy(.088,.074,.47,16),pants,[0,-.235,0],hip);
  const knee=new T3.Group();knee.position.y=-.47;hip.add(knee);
  add(cy(.068,.054,.45,16),pants,[0,-.225,0],knee);
  add(new T3.SphereGeometry(.068,14,10),pants,[0,-.47,0],hip);
  add(new T3.SphereGeometry(1,14,10),shoe,[0,-.48,.075],knee).scale.set(.058,.038,.14);
  return{hip,knee};
 };

 const arm=x=>{
  const sh=new T3.Group();sh.position.set(x,1.46,0);g.add(sh);
  add(cy(.052,.046,.31,14),suit,[0,-.155,0],sh);
  const el=new T3.Group();el.position.y=-.31;sh.add(el);
  add(cy(.045,.038,.29,14),suit,[0,-.145,0],el);
  add(cy(.042,.042,.03,8),shirt,[0,-.29,0],el);
  add(new T3.SphereGeometry(.044,12,10),suit,[0,-.31,0],sh);
  add(new T3.SphereGeometry(.042,10,8),skin,[0,-.32,0],el);
  for(let i=0;i<4;i++)add(new T3.BoxGeometry(.011,.058,.015),skin,[(i-1.5)*.018,-.355,.01],el);
  add(new T3.BoxGeometry(.013,.042,.015),skin,[.042,-.33,.01],el);
  return{sh,el};
 };

 return{g,head,legs:[leg(.1),leg(-.1)],arms:[arm(.25),arm(-.25)]};
}

const sit=h=>{
 h.legs.forEach(l=>{l.hip.rotation.x=-1.52;l.knee.rotation.x=1.52});
 h.arms.forEach(a=>{a.sh.rotation.x=-.92;a.el.rotation.x=-.78});
 h.g.position.y=-.46;
};

const walk=(h,ph,w)=>{
 const s=Math.sin(ph),c=Math.cos(ph);
 h.legs[0].hip.rotation.x=s*.52*w;h.legs[1].hip.rotation.x=-s*.52*w;
 h.legs[0].knee.rotation.x=Math.max(0,-c)*.92*w;h.legs[1].knee.rotation.x=Math.max(0,c)*.92*w;
 h.arms[0].sh.rotation.x=-s*.44*w;h.arms[1].sh.rotation.x=s*.44*w;
 h.arms[0].sh.rotation.z=.05*w;h.arms[1].sh.rotation.z=-.05*w;
 h.arms.forEach(a=>a.el.rotation.x=-.15-.22*w);
 h.head.rotation.x=Math.sin(ph*2)*.014*w;h.head.rotation.y=Math.sin(ph)*.03*w;
};

/* ===== Lush Botanical Plants ===== */
const leafColors=[M(0x16A36A,.75),M(0x10B981,.7),M(0x059669,.8),M(0x15803D,.82)];
function plant(x,z,s=1,pot=C.white,par=S){
 const g=new T3.Group();g.position.set(x,0,z);g.scale.setScalar(s);
 const p=new T3.Mesh(new T3.CylinderGeometry(.28,.22,.54,16),M(pot,.45,.05));
 p.position.y=.27;p.castShadow=true;g.add(p);
 const so=new T3.Mesh(new T3.CylinderGeometry(.26,.26,.04,14),M(0x352317,.95));
 so.position.y=.53;g.add(so);
 for(let i=0;i<10;i++){
  const a=i/10*Math.PI*2,l=new T3.Mesh(new T3.SphereGeometry(.22,8,6),leafColors[i%4]);
  l.scale.set(.5,1.4+Math.random()*.5,.24);
  l.position.set(Math.cos(a)*.15,1.0+Math.random()*.32,Math.sin(a)*.15);
  l.rotation.set(Math.sin(a)*.52,a,Math.cos(a)*.52);
  l.castShadow=true;g.add(l);
 }
 par.add(g);return g;
}

/* =========================================================================
   BUILD STAGES: Architectural World & Corporate Headquarters
   ========================================================================= */

/* Stage 0: Daylight Environment, Warm Sunlight & Atmosphere */
stages.push(()=>{
 pm=new T3.PMREMGenerator(R);
 const es=new T3.Scene();es.background=new T3.Color(0xb5d6f6);
 const pn=(c,k,w,h,x,y,z)=>{
  const m=new T3.Mesh(new T3.PlaneGeometry(w,h),new T3.MeshBasicMaterial({color:new T3.Color(c).multiplyScalar(k),side:2}));
  m.position.set(x,y,z);m.lookAt(0,0,0);es.add(m);
 };
 pn(0xfff5e4,7.5,14,8,-12,14,14);  // Warm sun bounce
 pn(0x7fb2ff,2.6,18,6,14,10,-6);   // Sky bounce
 pn(0xF5F7FA,3.2,26,6,0,22,0);     // Top daylight
 pn(C.green,1.2,16,4,0,-4,10);     // Lush garden ground reflection
 pn(C.wood,1.4,12,4,0,4,-18);      // Wood interior warmth
 S.environment=pm.fromScene(es,.04).texture;
 pm.dispose();

 /* Sky hemisphere: crisp daylight blue sky + warm ground bounce */
 S.add(new T3.HemisphereLight(0xf0f1e9,0x918778,1.05));

 /* Sky sphere */
 const skt=cv(16,512,(g,w,h)=>{
  const q=g.createLinearGradient(0,0,0,h);
  q.addColorStop(0,'#7192aa');q.addColorStop(.25,'#b8cbd1');q.addColorStop(.44,'#f1e7d8');
  q.addColorStop(.5,'#f7f1e7');q.addColorStop(.52,'#b9c1c3');q.addColorStop(1,'#929d9e');
  g.fillStyle=q;g.fillRect(0,0,w,h);
 });
 S.add(new T3.Mesh(new T3.SphereGeometry(390,24,16),new T3.MeshBasicMaterial({map:skt,side:T3.BackSide,fog:false,depthWrite:false})));

 /* Gentle cumulus clouds */
 const ct=cv(256,128,(g,w,h)=>{
  for(let i=0;i<9;i++){
   const x=40+Math.random()*176,y=50+Math.random()*30,r=28+Math.random()*26;
   const q=g.createRadialGradient(x,y,0,x,y,r);
   q.addColorStop(0,'rgba(255,255,255,.85)');q.addColorStop(1,'rgba(255,255,255,0)');
   g.fillStyle=q;g.fillRect(0,0,w,h);
  }
 });
 for(let i=0;i<7;i++){
  const s=new T3.Sprite(new T3.SpriteMaterial({map:ct,fog:false,depthWrite:false,transparent:true,opacity:.75}));
  s.position.set(-250+i*85+Math.random()*30,95+Math.random()*45,-300);
  s.scale.set(130,65,1);S.add(s);
 }

 /* Warm sun disk */
 const sun=cv(128,128,g=>{
  const q=g.createRadialGradient(64,64,0,64,64,64);
  q.addColorStop(0,'rgba(255,250,235,1)');q.addColorStop(.22,'rgba(255,228,175,.75)');q.addColorStop(1,'rgba(255,200,130,0)');
  g.fillStyle=q;g.fillRect(0,0,128,128);
 });
 const sp=new T3.Sprite(new T3.SpriteMaterial({map:sun,fog:false,depthWrite:false,transparent:true,opacity:.42}));
 sp.position.set(-85,75,-300);sp.scale.set(82,82,1);S.add(sp);

 /* Main warm sunlight with crisp soft shadows */
 const d=new T3.DirectionalLight(0xfff3df,1.65);
 d.position.set(-18,34,42);d.castShadow=!small;
 const sc=d.shadow.camera;sc.left=-36;sc.right=36;sc.top=36;sc.bottom=-36;sc.far=145;
 d.shadow.mapSize.set(2048,2048);d.shadow.bias=-.0003;d.shadow.normalBias=.025;
 S.add(d);

 /* Soft daylight fill */
 const dFill=new T3.DirectionalLight(0xe4edf0,0.32);
 dFill.position.set(22,25,-15);S.add(dFill);
});

/* Stage 1: Modern Corporate Plaza & Architectural Landscaping */
stages.push(()=>{
 const f=new T3.Mesh(new T3.PlaneGeometry(300,300),plazaMat);
 f.rotation.x=-Math.PI/2;f.receiveShadow=true;S.add(f);

 const flo=[C.amber,C.white,C.amber,C.white,C.amber,C.white];
 for(const sx of[-1,1]){
  /* Raised architectural concrete planters */
  bx(8.2,.72,1.5,concrete,sx*9,.36,5);
  bx(7.8,.08,1.2,M(0x352317,.95),sx*9,.74,5);
  /* Manicured emerald boxwood hedges */
  for(let i=0;i<5;i++){
   const s=new T3.Mesh(new T3.SphereGeometry(.58,10,8),leafColors[i%4]);
   s.position.set(sx*9+(i-2)*1.45,1.02,5);s.scale.y=.82;s.castShadow=true;S.add(s);
  }
  /* Warm amber & white floral accents */
  for(let i=0;i<6;i++){
   const s=new T3.Mesh(new T3.SphereGeometry(.1,6,6),M(flo[i],.65));
   s.position.set(sx*9+(i-2.5)*1.32,1.45,5.38);S.add(s);
  }
  /* Modern stainless steel security bollards with illuminated LED rings */
  for(let i=0;i<3;i++){
   const bxp=sx*(3.2+i*1.15);
   bx(.22,.92,.22,darkSlate,bxp,.46,6.5);
   bx(.24,.06,.24,steel,bxp,.94,6.5);
   bx(.24,.02,.24,EM(C.amber),bxp,.86,6.5,S,false);
  }
  /* Architectural plaza trees in bespoke natural wood planters */
  const tr=sx*15.5,tz=9;
  bx(2.2,.6,2.2,wood,tr,.3,tz);
  bx(.45,3.2,.45,wood,tr,1.6,tz);
  [[0,4.4,0,1.9,0],[.95,3.9,.4,1.4,1],[-.85,4.0,-.35,1.45,2]].forEach(c=>{
   const s=new T3.Mesh(new T3.SphereGeometry(c[3],12,10),leafColors[c[4]]);
   s.position.set(tr+c[0],c[1],tz+c[2]);s.castShadow=true;S.add(s);
  });
 }
});

/* Stage 2: Background Modern City Skyline */
stages.push(()=>{
 const tints=[0xe2e8f0,0xd5e0ec,0xebe4d8,0xc4d1df,0xdcd6cc,0xedf2f7];
 for(let i=0;i<(small?22:34);i++){
  const w=7+Math.random()*10,h=24+Math.random()*52,d=10;
  let x,z;
  if(i<20){x=(Math.random()-.5)*210;z=-48-Math.random()*60}
  else{x=(Math.random()<.5?-1:1)*(34+Math.random()*30);z=-30+Math.random()*60}
  bx(w,h,d,bm(winTex,w/8,h/8,.06,tints[i%6]),x,h/2,z,S,false);
 }
});

/* Stage 3: Avenue, Modern Vehicles & Lighting */
stages.push(()=>{
 const road=new T3.Mesh(new T3.PlaneGeometry(300,11),M(0x555a59,.94,.01));
 road.rotation.x=-Math.PI/2;road.position.set(0,.02,35);road.receiveShadow=true;S.add(road);

 bx(300,.14,.32,concrete,0,.07,29.8);bx(300,.14,.32,concrete,0,.07,40.3);
 for(let x=-140;x<140;x+=8)bx(3.2,.012,.2,M(C.white,.6),x,.038,35,S,false);

 /* Sleek campus street lighting */
 for(let x=-54;x<=54;x+=18){
  bx(.16,7.2,.16,darkSlate,x,3.6,29);
  bx(1.3,.12,.16,darkSlate,x+.55,7.2,29);
  bx(.55,.14,.32,EM(0xfff4dc),x+1.1,7.12,29,S,false);
 }

 /* Modern executive vehicles in corporate palette */
 const car=(col,v,o,rot,z)=>{
  const g=new T3.Group(),mt=M(col,.25,.75);
  bx(4.3,.72,1.85,mt,0,.68,0,g);
  bx(2.3,.62,1.65,M(0x1a2332,.1,.85),-.2,1.28,0,g);
  [[1.35,.92],[1.35,-.92],[-1.35,.92],[-1.35,-.92]].forEach(w=>{
   const c=new T3.Mesh(new T3.CylinderGeometry(.38,.38,.28,14),M(0x16181d,.8));
   c.rotation.x=Math.PI/2;c.position.set(w[0],.38,w[1]);c.castShadow=true;g.add(c);
  });
  /* LED headlights & taillights */
  bx(.06,.18,.4,EM(0xfff4dc),2.18,.72,.62,g,false);bx(.06,.18,.4,EM(0xfff4dc),2.18,.72,-.62,g,false);
  bx(.06,.15,.4,EM(0xd93830),-2.18,.72,.62,g,false);bx(.06,.15,.4,EM(0xd93830),-2.18,.72,-.62,g,false);
  g.rotation.y=rot;g.position.z=z;S.add(g);cars.push({g,v,o});
 };
 car(C.blue,6,10,0,32.5);
 car(C.silver,5,70,0,32.5);
 car(C.white,-7,30,Math.PI,37.5);
 car(C.amber,-5.5,95,Math.PI,37.5);
});

/* Stage 4: Headquarters Facade, Grand Entrance & Turnstiles */
stages.push(()=>{
 const gl=(w,h)=>bm(facTex,w/12.8,h/14.4,.14,0xffffff);
 const gt=(w,h)=>bm(facTex,w/12.8,h/14.4,.14,0xe6f2ff);

 bx(11,16,16,gl(11,16),-10.5,8,-8);bx(11,16,16,gl(11,16),10.5,8,-8);
 bx(10,11.5,16,gt(10,11.5),0,10.25,-8);
 bx(11,16,16,gl(11,16),-10.5,8,-8,mir,false);bx(11,16,16,gl(11,16),10.5,8,-8,mir,false);
 bx(10,11.5,16,gt(10,11.5),0,10.25,-8,mir,false);

 bx(11.4,.55,16.4,concrete,-10.5,16.25,-8);bx(11.4,.55,16.4,concrete,10.5,16.25,-8);bx(10.4,.55,16.4,concrete,0,16.25,-8);
 bx(11.4,.95,.55,concrete,-10.5,.48,.1);bx(11.4,.95,.55,concrete,10.5,.48,.1);

 /* Vertical emerald green living moss accent panels */
 [-1,1].forEach(s=>bx(.95,4.6,.26,M(C.green,.82),s*5.6,2.3,.26));

 /* Grand cantilevered entrance canopy in Deep Slate & White */
 bx(10.5,.32,3.8,pure,0,4.7,1.9);
 bx(9.8,.05,.12,EM(0xffe8c6),0,4.52,3.4);
 bx(10.5,.62,.32,darkSlate,0,4.6,3.7);

 /* Main Entrance Architectural Signage */
 bx(10.2,2.1,.15,darkSlate,0,7.25,.09);
 [C.blue,C.green,C.amber].forEach((c,i)=>bx(3,.14,.12,M(c,.4),(i-1)*3.1,6.45,.22));
 const sg=sign('TEAMCONNECT',9.2,1.2);sg.position.set(0,7.35,.22);S.add(sg);
 const sg2=sign('TEAMCONNECT',9.2,1.2);sg2.position.set(0,7.35,.22);mir.add(sg2);

 const sl=new T3.PointLight(0xfff2dc,.6,14);sl.position.set(0,6,3.2);S.add(sl);

 /* Large entrance glass curtain walls */
 bx(3.4,4.5,.04,glass,-3.3,2.25,0,S,false);
 bx(3.4,4.5,.04,glass,3.3,2.25,0,S,false);
 bx(3.2,1.3,.04,glass,0,3.85,0,S,false);

 [-5,-3.3,-1.6,1.6,3.3,5].forEach(x=>bx(.08,4.5,.12,steel,x,2.25,.02));
 bx(10,.11,.11,steel,0,3.2,.02);bx(10,.11,.11,steel,0,4.45,.02);

 for(let x=-15.5;x<=15.6;x+=2.2)if(Math.abs(x)>5.2)bx(.14,16,.32,pure,x,8,.14);
 for(let x=-4.4;x<=4.5;x+=1.1)bx(.08,7.8,.32,steel,x,12.2,.14);

 /* Automatic sliding glass entrance doors */
 const door=x=>{
  const g=new T3.Group();
  bx(1.6,3.2,.04,glass,0,1.6,0,g,false);
  bx(1.6,.12,.07,steel,0,.06,0,g);bx(1.6,.12,.07,steel,0,3.14,0,g);
  bx(.05,.95,.06,steel,-Math.sign(x)*.7,1.15,.06,g);
  g.position.set(x,0,.04);g.userData.b=x;S.add(g);doors.push(g);
 };
 door(-.8);door(.8);

 /* Modern access turnstile speed-gates */
 const gate=x=>{
  const g=new T3.Group();
  bx(.9,1,.04,M(0xd6ecfa,.05,.25,{transparent:true,opacity:.36,depthWrite:false}),0,.62,0,g,false);
  bx(.9,.05,.06,steel,0,1.12,0,g);
  g.position.set(x,0,1.6);g.userData.b=x;S.add(g);gates.push(g);
 };
 gate(-.45);gate(.45);

 /* Turnstile housings in deep slate & brushed steel */
 reader.led=new T3.MeshBasicMaterial({color:0x16A36A});
 bx(.72,1.12,.52,M(0x384a62,.3,.75),-1.3,.56,1.6);
 bx(.72,1.12,.52,M(0x384a62,.3,.75),1.3,.56,1.6);
 bx(.72,.035,.035,reader.led,-1.3,1.12,1.86);
 bx(.72,.035,.035,reader.led,1.3,1.12,1.86);
});

/* Stage 5: Realistic Headquarters Lobby, Reception, Workstations, Lounge & Meeting Rooms */
stages.push(()=>{
 /* Terrazzo floor and acoustic coffered ceiling */
 bx(10,.1,14,marbleMat,0,-.03,-7);
 bx(10,.16,14,M(0xf8f6f0,.9),0,4.58,-7);

 /* Side walls and feature back wall */
 bx(.12,4.5,14,pure,-4.95,2.25,-7);bx(.12,4.5,14,pure,4.95,2.25,-7);
 bx(10,4.5,.12,pure,0,2.25,-14);

 /* Back acoustic wood slat feature wall with Emerald Green moss panels */
 bx(5.5,3.3,.05,wood,0,2.2,-13.9);
 bx(2.2,3.3,.05,M(C.green,.82),-3.85,2.2,-13.9);
 bx(2.2,3.3,.05,M(C.blue,.82),3.85,2.2,-13.9);

 const bs=sign('TEAMCONNECT',4.4,.58,.85);bs.position.set(0,2.82,-13.84);S.add(bs);

 /* Recessed warm lighting troughs in ceiling */
 [-3,0,3].forEach(x=>bx(.32,.04,12,EM(0xfff3dc),x,4.48,-7));

 /* Warm interior lights (3200K) */
 [[0,4,-3,18,0xffe8c8,.95],[0,4,-9,18,0xffe8c8,.95],[-3.5,3.6,-12.5,12,0xffe8c8,.85],[0,3.8,1,10,0xffffff,.75]].forEach(p=>{
  const l=new T3.PointLight(p[4],p[5],p[3]);l.position.set(p[0],p[1],p[2]);S.add(l);
 });

 /* Modern sculpted reception desk in Premium White Quartz with Wood accent */
 bx(3.3,1.06,.92,wood,2.2,.53,-10);
 bx(3.5,.06,1.08,M(C.white,.25,.08),2.2,1.07,-10);
 const rs2=sign('TEAMCONNECT',1.7,.24,.65);rs2.position.set(2.2,.6,-9.52);S.add(rs2);
 bx(.52,.32,.04,darkSlate,2.8,1.24,-10.1);bx(.32,.03,.22,M(C.amber,.55),1.5,1.1,-10);

 for(let i=0;i<3;i++){
  const z=-4-i*2;
  bx(.06,2.6,1.2,M(0xb8c4d2,.25,.9),4.88,1.3,z);
  bx(.02,.12,.12,EM(C.amber),4.84,2.8,z);
 }

 /* Frameless Glass Executive Meeting Room */
 const mr=new T3.Group();mr.position.set(-3.1,0,-5);S.add(mr);
 [-1.6,1.6].forEach(x=>bx(.03,2.8,3.2,glassInterior,x,1.4,0,mr,false));
 bx(3.2,2.8,.03,glassInterior,0,1.4,-1.6,mr,false);
 bx(3.2,2.8,.03,glassInterior,0,1.4,1.6,mr,false);

 bx(3.2,.06,.06,steel,0,2.8,1.6,mr);
 bx(1.6,.05,.82,wood,0,.74,0,mr);  // Natural wood conference table
 bx(.08,.7,.08,steel,0,.37,0,mr);
 [C.blue,C.green,C.amber,C.slate].forEach((c,i)=>bx(.46,.08,.46,M(c,.72),(i%2?.8:-.8),.45,(i<2?-.7:.7),mr));

 /* Workstations with Colorful TeamConnect Analytics Dashboards */
 const scr=cv(128,80,(g,w,h)=>{
  g.fillStyle='#F5F7FA';g.fillRect(0,0,w,h);
  g.fillStyle='#2563EB';g.fillRect(0,0,w,14);
  g.fillStyle='#F5F7FA';g.font='700 8px Arial';g.fillText('TEAMCONNECT',6,10);
  g.fillStyle='#16A36A';g.fillRect(8,20,36,6);
  g.fillStyle='#F59E0B';g.fillRect(8,30,24,6);
  g.fillStyle='#CBD5E1';for(let i=0;i<4;i++)g.fillRect(8,42+i*8,52+Math.random()*55,4);
  g.fillStyle='#2563EB';g.fillRect(84,22,9,30);
  g.fillStyle='#16A36A';g.fillRect(96,32,9,20);
  g.fillStyle='#F59E0B';g.fillRect(108,40,9,12);
 });
 const scrM=[steel,steel,steel,steel,new T3.MeshBasicMaterial({map:scr}),steel];

 [[-3.5,C.blue],[-2.2,C.green],[-.9,C.amber]].forEach(a=>{
  const x=a[0];
  bx(1.22,.04,.72,M(C.white,.4),x,.74,-12);
  bx(.05,.72,.62,steel,x-.56,.36,-12);bx(.05,.72,.62,steel,x+.56,.36,-12);
  bx(.56,.34,.02,scrM,x,1.06,-12.1);
  bx(.1,.3,.02,steel,x,.9,-12.1);
  bx(.52,.08,.52,M(a[1],.75),x,.45,-11);
 });

 for(const x of[-3,0,3])for(const z of[-2,-5,-8,-11])bx(.35,.01,.35,EM(0xfff5e6),x,4.49,z,S,false);

 /* Executive Lounge Area: Warm Amber & Slate Seating */
 bx(3.6,.03,2.6,M(C.green,.92),-3.1,.04,-1.9,S,false);
 bx(2.4,.46,.96,M(C.amber,.85),-3.6,.25,-1.8);
 bx(2.4,.52,.22,M(C.amber,.85),-3.6,.6,-2.2);
 bx(.72,.42,.72,wood,-1.9,.21,-1.8);

 /* Digital Enterprise Dashboard Video Wall */
 const vw=new T3.Mesh(new T3.PlaneGeometry(4,1.8),new T3.MeshBasicMaterial({
  color:0xeeeeee,
  map:cv(512,230,(g,w,h)=>{
   g.fillStyle='#1e2b3c';g.fillRect(0,0,w,h);
   g.fillStyle='#2563EB';g.fillRect(0,0,w,46);
   g.fillStyle='#F5F7FA';g.font='700 22px Arial,sans-serif';g.fillText('TEAMCONNECT  |  WHERE EVERY TEAM CONNECTS',20,31);
   g.fillStyle='#CBD5E1';g.font='600 12px Arial,sans-serif';g.fillText('LIVE WORKSPACE · ALL GLOBAL TEAMS OPERATIONAL',20,70);
   [[40,C.blue],[110,C.green],[180,C.amber],[250,C.blue],[320,C.green],[390,C.amber]].forEach((b,i)=>{
    g.fillStyle='#'+b[1].toString(16).padStart(6,'0');
    const bh=45+i*16%60+20;g.fillRect(b[0],200-bh,46,bh);
   });
   g.strokeStyle='#38bdf8';g.lineWidth=3;g.beginPath();
   for(let i=0;i<=22;i++){const y=135-Math.sin(i*.5)*18-i*2;i?g.lineTo(360+i*6,y):g.moveTo(360,y)}
   g.stroke();
  })
 }));
 vw.rotation.y=Math.PI/2;vw.position.set(-4.88,2.4,-9);S.add(vw);

 /* Interior Greenery: Healthy Potted Plants in Designer Planters */
 plant(-4.3,-.8,1.15,C.white);
 plant(4.3,-.8,1.15,C.slate);
 plant(-4.3,-12.9,1.3,C.slate);
 plant(4.3,-12.9,1.3,C.white);
 plant(-4.4,-3.6,.92,C.white);
 plant(4.2,-9.4,.92,C.slate);
});

/* Stage 6: Characters, Card Scanner & ID Card */
stages.push(()=>{
 /* Hero Employee: Tailored Royal Blue jacket, Slate pants, Amber tie, crisp white shirt */
 const hero={suit:C.blueDark,pants:C.slateDark,tie:C.amber,shirt:C.white,skin:0xd4a373};
 const R1=human(hero);R1.g.rotation.y=Math.PI;S.add(R1.g);
 rig=R1;twin=human(hero);mir.add(twin.g);

 /* Realistic, Colorful Employee ID Card */
 const cardFrontTex=cv(340,214,(g,w,h)=>{
  g.fillStyle='#F5F7FA';g.fillRect(0,0,w,h);
  /* Royal Blue Header with TeamConnect Brand */
  g.fillStyle='#2563EB';g.fillRect(0,0,w,64);
  g.fillStyle='#F5F7FA';g.font='800 28px Arial,sans-serif';g.fillText('TEAMCONNECT',20,40);
  g.fillStyle='#A7F3D0';g.font='700 10px Arial,sans-serif';g.fillText('ENTERPRISE IDENTITY PASS',20,54);
  /* Emerald Green Security Band */
  g.fillStyle='#16A36A';g.fillRect(0,64,w,7);
  /* Employee Photo Frame */
  g.fillStyle='#CBD5E1';g.fillRect(20,86,88,102);
  g.fillStyle='#26364D';
  g.beginPath();g.arc(64,122,20,0,Math.PI*2);g.fill();
  g.fillRect(36,148,56,40);
  /* Employee Details */
  g.fillStyle='#26364D';g.font='800 17px Arial,sans-serif';g.fillText('ALEX MORGAN',122,104);
  g.fillStyle='#16A36A';g.font='700 12px Arial,sans-serif';g.fillText('SR. SYSTEMS ARCHITECT',122,122);
  g.fillStyle='#64748B';g.font='600 10px Arial,sans-serif';g.fillText('ID: TC-84920 · PRODUCT & TECH',122,140);
  /* Barcode & Hologram */
  for(let x=122;x<240;x+=4)if(Math.sin(x*13)>-.2){g.fillStyle='#1E293B';g.fillRect(x,152,2.5,24)}
  g.fillStyle='#F59E0B';g.fillRect(256,148,54,34);
  g.fillStyle='#B45309';g.font='800 9px Arial,sans-serif';g.fillText('RFID SECURE',258,168);
 });

 const cardMat=new T3.MeshStandardMaterial({map:cardFrontTex,roughness:.35,metalness:.15});
 const card=new T3.Mesh(new T3.BoxGeometry(.09,.004,.058),[M(C.white),M(C.white),cardMat,cardMat,M(C.white),M(C.white)]);
 card.position.set(0,-.36,0);card.visible=false;
 R1.arms[1].el.add(card);R1.card=card;

 /* Standby Card Scanner Pedestal */
 const rd=new T3.Group();rd.position.set(1.44,0,2.47);S.add(rd);
 bx(.12,1.2,.08,darkSlate,0,.6,0,rd);
 bx(.22,.32,.07,M(0x1d2c43,.35,.6),0,1.4,0,rd);

 const sc=new T3.Mesh(new T3.PlaneGeometry(.18,.11),new T3.MeshBasicMaterial({map:rt}));
 sc.position.set(0,1.42,.036);rd.add(sc);

 reader.ring=bx(.19,.016,.012,new T3.MeshBasicMaterial({color:0x16A36A}),0,1.26,.036,rd,false);
 reader.l=new T3.PointLight(0x16A36A,.25,4);reader.l.position.set(1.44,1.4,2.9);S.add(reader.l);

 /* Friendly Receptionist: Tailored Emerald blazer, neat hairstyle */
 const rp=human({suit:C.greenDark,pants:C.slateDark,skin:0xe8beac,hair:0x3b2314,long:true,noTie:true});
 rp.g.position.set(2.2,0,-10.9);S.add(rp.g);npcs.push({h:rp,k:'stand'});

 /* Colleagues collaborating at workstations */
 [
  [-3.5,{suit:C.blue,skin:0xd0a07c,hair:0x4a3020,tie:C.green}],
  [-2.2,{suit:0xe2e8f0,pants:C.slate,skin:0x8d5a3b,hair:0x15110e,long:true,noTie:true}],
  [-.9,{suit:C.amber,skin:0xf0c8a8,hair:0x8a6a3a,tie:C.white}]
 ].forEach(a=>{
  const h=human(a[1]);h.g.position.set(a[0],0,-11);h.g.rotation.y=Math.PI;sit(h);
  S.add(h.g);npcs.push({h,k:'sit',o:a[0]});
 });

 /* Colleague walking in lobby with executive portfolio */
 const wk=human({suit:C.slateLight,pants:C.slateDark,skin:0xb9825a,hair:0x1a1410,tie:C.blue});
 wk.g.position.set(3.8,0,-3);S.add(wk.g);npcs.push({h:wk,k:'walk'});
});

/* Resource cleanup */
let rz=null,wmRz=null,done=false,rafId=0;
function disposeAll(){
 const geometries=new Set(),materials=new Set(),textures=new Set([rt,plazaTex,marbleTex,woodTex,winTex,facTex]);
 S.traverse(o=>{
  if(o.geometry)geometries.add(o.geometry);
  const list=Array.isArray(o.material)?o.material:o.material?[o.material]:[];
  list.forEach(m=>{
   materials.add(m);
   Object.keys(m).forEach(k=>{
    const v=m[k];
    if(v&&v.isTexture)textures.add(v);
    else if(Array.isArray(v))v.forEach(t=>{if(t&&t.isTexture)textures.add(t)});
   });
  });
 });
 if(S.environment)textures.add(S.environment);
 geometries.forEach(g=>g.dispose());
 materials.forEach(m=>m.dispose());
 textures.forEach(t=>t.dispose());
 if(R.renderLists)R.renderLists.dispose();
 R.dispose();
 if(R.forceContextLoss)R.forceContextLoss();
}
function finish(){if(done)return;done=true;if(rafId)cancelAnimationFrame(rafId);if(rz)removeEventListener('resize',rz);if(wmRz)removeEventListener('resize',wmRz);disposeAll()}

msg.textContent='Welcome to TEAMCONNECT';msg.classList.add('on');
await wait(850);setMsg('Preparing Your Experience...');

for(let i=0;i<stages.length;i++){
 if(cancelled){finish();return}
 await frame();stages[i]();$bar.style.width=((i+1)/stages.length*100)+'%';
}
await wait(350);
if(cancelled){finish();return}

let W=1,H=1;
rz=()=>{
 W=innerWidth;H=innerHeight;
 R.setSize(W,H,false);cam.aspect=W/H;cam.updateProjectionMatrix();
};
rz();addEventListener('resize',rz);

/* ===== Cinematic Camera Sequence (Natural Easing & Glide Transitions) ===== */
const shots=[
 [0,6,[-6,3.2,44],[0,3.5,27],[0,7,0],[0,6.5,0],42,40],        // Shot 0: Campus & Avenue establishing shot
 [6,10.6,[-3.2,1.55,15.5],[-3,1.5,6.7],[1.2,1.1,12],[1.2,1.2,3.2],40,36], // Shot 1: Plaza tracking shot
 [10.6,13.4,[4.2,1.95,7.2],[3.7,1.8,6.4],[1.45,1.25,2.6],[1.45,1.25,2.6],40,38], // Shot 2: Card scanner medium close-up
 [13.4,16.4,[-5.5,1.4,4.5],[-4.5,1.5,2.2],[0,1.2,2],[0,1.2,-1.2],40,40], // Shot 3: Grand Entrance transition
 [16.4,27.4,[.6,1.7,3.2],[.6,1.95,-6.5],[0,1.5,-6],[0,2.3,-14],46,38]   // Shot 4: Grand Corporate Lobby
];

const pose=(sh,t)=>{
 const k0=clamp((t-sh[0])/(sh[1]-sh[0])),k=lerp(k0,sm(k0),.58);
 const m=(a,b)=>a.map((v,i)=>lerp(v,b[i],k));
 return{p:m(sh[2],sh[3]),l:m(sh[4],sh[5]),f:lerp(sh[6],sh[7],k)};
};

/* Employee motion path */
const mp=t=>t<10.4?[1.2,26-t*2.19]:t<13.4?[1.2,3.2]:t<14.8?[lerp(1.2,0,sm((t-13.4)/1.4)),lerp(3.2,1.8,(t-13.4)/1.4)]:t<20.6?[0,lerp(1.8,-9,(t-14.8)/5.8)]:[0,-9];

let T=0,last=performance.now(),dist=0,hd=Math.PI,msgState=0,revealed=false;
const stCol=[0x16A36A,0xF59E0B,0x16A36A],lCol=[0x16A36A,0xF59E0B,0x10B981];

cvs.style.opacity=1;$('#tcprog').style.opacity=0;$('#loader').classList.add('ready');setMsg('');

/* ===== Vibrant Logo Particle Animation & Specular Light Sweep ===== */
const wc=$('#tcwm'),wx=wc.getContext('2d');
const LOGO_PAL=['#2563EB','#2563EB','#16A36A','#16A36A','#CBD5E1','#F5F7FA','#F59E0B'];
let wp=null,WW=0,WH=0,wmD=1,wmFs=0,wmTw=0,wmSp=0;
wmRz=()=>{wp=null};addEventListener('resize',wmRz);

function wmWord(g,fill,ox,oy){
 g.font='800 '+wmFs+'px Arial,Helvetica,sans-serif';
 g.textBaseline='middle';g.fillStyle=fill;
 let x=(WW-wmTw)/2+ox;
 for(const l of'TEAMCONNECT'){
  g.fillText(l,x,WH*.47+oy);
  x+=g.measureText(l).width+wmSp;
 }
}

function wmTag(g,fill,al){
 const s=wmFs*.16,t='WHERE EVERY TEAM CONNECTS',sp=s*.58;
 g.font='600 '+s+'px Arial,Helvetica,sans-serif';
 g.textBaseline='middle';g.fillStyle=fill;g.globalAlpha=al;
 let w=-sp;for(const l of t)w+=g.measureText(l).width+sp;
 let x=(WW-w)/2;
 for(const l of t){
  g.fillText(l,x,WH*.47+wmFs*.84);
  x+=g.measureText(l).width+sp;
 }
 g.globalAlpha=1;
}

function wmPrep(){
 wmD=Math.min(devicePixelRatio||1,2);
 WW=wc.width=Math.round(innerWidth*wmD);
 WH=wc.height=Math.round(innerHeight*wmD);
 wmFs=Math.min(WW*(innerWidth<700?.11:.082),WH*.19);
 wmSp=wmFs*.1;

 const o=document.createElement('canvas');o.width=WW;o.height=WH;
 const g=o.getContext('2d');
 g.font='800 '+wmFs+'px Arial,Helvetica,sans-serif';
 wmTw=[...'TEAMCONNECT'].reduce((a,l)=>a+g.measureText(l).width+wmSp,-wmSp);
 wmWord(g,'#fff',0,0);wmTag(g,'#fff',1);

 const d=g.getImageData(0,0,WW,WH).data;
 const st=Math.max(2,Math.round(wmFs/(small?18:24)));
 const P=[];
 for(let y=0;y<WH;y+=st){
  for(let x=0;x<WW;x+=st){
   if(d[(y*WW+x)*4+3]>140)P.push(x,y);
  }
 }

 const n=P.length/2,F=()=>new Float32Array(n);
 wp={n,tx:F(),ty:F(),sx:F(),sy:F(),dl:F(),dx:F(),dy:F(),ci:new Uint8Array(n)};
 for(let i=0;i<n;i++){
  wp.tx[i]=P[i*2];wp.ty[i]=P[i*2+1];
  wp.sx[i]=WW/2+(Math.random()-.5)*WW*1.4;
  wp.sy[i]=WH/2+(Math.random()-.5)*WH*1.4;
  wp.dl[i]=Math.random();
  wp.dx[i]=(P[i*2]-WW/2)*.35+(Math.random()-.5)*240*wmD;
  wp.dy[i]=(P[i*2+1]-WH/2)*.35-Math.random()*130*wmD;
  wp.ci[i]=Math.floor(Math.random()*LOGO_PAL.length);
 }
}

function wmDraw(t){
 if(t<19.8)return;
 if(t>26.5){if(wp){wx.clearRect(0,0,WW,WH);wp=null}return}
 if(!wp)wmPrep();
 wx.clearRect(0,0,WW,WH);

 const fp=(t-19.8)/2.4,a=sm((t-21.5)/.9),sw=(t-22.3)/1.5,out=sm((t-24)/1.5),D=wmD;

 /* Soft vignette backdrop */
 wx.globalAlpha=1;wx.shadowBlur=0;
 wx.fillStyle='rgba(22,34,52,'+(.34*sm((t-19.8)/1.6)).toFixed(3)+')';
 wx.fillRect(0,0,WW,WH);

 /* Smoothly assembling particles */
 for(let i=0;i<wp.n;i++){
  let e=clamp((fp-wp.dl[i]*.5)/.5);
  e=1-Math.pow(1-e,3);
  let x=lerp(wp.sx[i],wp.tx[i],e),y=lerp(wp.sy[i],wp.ty[i],e);
  if(out>0){x+=wp.dx[i]*out;y+=wp.dy[i]*out}
  wx.globalAlpha=Math.min(1,e*1.4)*(out>0?1-out:1-a*.9);
  wx.fillStyle=LOGO_PAL[wp.ci[i]];
  wx.beginPath();wx.arc(x,y,1.3*D,0,Math.PI*2);wx.fill();
 }

 const sa=a*(1-sm((t-24.2)/.7));
 if(sa>0){
  wx.globalAlpha=sa;
  /* Multi-level 3D depth shadow */
  for(let k=5;k>=1;k--){
   wmWord(wx,'rgb('+(16+k*3)+','+(26+k*4)+','+(42+k*6)+')',k*.8*D,k*.8*D);
  }

  /* Sharp typographic logo with metallic gradient and animated light sweep */
  const x0=(WW-wmTw)/2;
  const gr=wx.createLinearGradient(x0,0,x0+wmTw,0);
  const h=-.25+1.5*clamp(sw);
  gr.addColorStop(0,'#2563EB');
  gr.addColorStop(clamp(h-.18),'#CBD5E1');
  gr.addColorStop(clamp(h-.05),'#EAF1F4');
  gr.addColorStop(clamp(h),'#ffffff');
  gr.addColorStop(clamp(h+.18),'#CBD5E1');
  gr.addColorStop(1,'#16A36A');

  wx.shadowColor='rgba(37,99,235,.22)';wx.shadowBlur=7*D;
  wmWord(wx,gr,0,0);
  wx.shadowBlur=0;

  /* Tagline: WHERE EVERY TEAM CONNECTS */
  wmTag(wx,'#F5F7FA',sa);

  /* Tricolor dynamic gradient accent bar */
  const lw=wmTw*.52*a,bx0=WW/2-lw/2,by=WH*.47+wmFs*.64;
  const ug=wx.createLinearGradient(bx0,0,bx0+lw,0);
  ug.addColorStop(0,'#2563EB');ug.addColorStop(.48,'#16A36A');ug.addColorStop(1,'#F59E0B');
  wx.fillStyle=ug;wx.fillRect(bx0,by,lw,3.5*D);
  wx.globalAlpha=1;
 }
}

/* ===== Animation Loop ===== */
function tick(now){
 rafId=0;
 if(cancelled&&!done)finish();
 if(done)return;
 rafId=requestAnimationFrame(tick);
 const dt=Math.min(.1,(now-last)/1000);last=now;T+=dt*1.35;

 /* Smooth Camera Glide & Blending */
 let si=shots.findIndex(s=>T>=s[0]&&T<s[1]);if(si<0)si=shots.length-1;
 const sh=shots[si];let ps=pose(sh,T);
 if(si<shots.length-1){
  const bw=clamp((T-(sh[1]-.95))/.95);
  if(bw>0){
   const nx=pose(shots[si+1],T),w=sm(bw);
   const mx=(a,b)=>a.map((v,i)=>lerp(v,b[i],w));
   ps={p:mx(ps.p,nx.p),l:mx(ps.l,nx.l),f:lerp(ps.f,nx.f,w)};
  }
 }
 cam.position.set(ps.p[0],ps.p[1],ps.p[2]);
 cam.lookAt(ps.l[0],ps.l[1],ps.l[2]);

 let fv=ps.f;if(W<H)fv=Math.min(95,fv*(1+(H/W-1)*.55));
 cam.position.x+=Math.sin(T*1.7)*.008;
 cam.position.y+=Math.sin(T*2.3+1)*.007;
 cam.rotateZ(Math.sin(T*.8)*.003);
 cam.fov=fv;cam.updateProjectionMatrix();

 /* Employee Locomotion & Turning */
 const p=mp(T),q=mp(T+.04),dx=q[0]-p[0],dz=q[1]-p[1],sp=Math.hypot(dx,dz)/.04;
 if(sp>.05){
  const a=Math.atan2(dx,dz);let d=a-hd;
  d=Math.atan2(Math.sin(d),Math.cos(d));hd+=d*Math.min(1,dt*6);
 }
 const w=clamp(sp/1.2);dist+=sp*dt*1.35;
 const ph=dist*Math.PI/.85;
 rig.g.visible=true;
 rig.g.position.set(p[0],Math.abs(Math.cos(ph))*.03*w,p[1]);
 rig.g.rotation.set(0,hd,Math.sin(ph)*.02*w);
 walk(rig,ph,w);

 /* Card Scan: Natural Arm Raise, Orientation & Lower */
 const swp=T>10.3&&T<13.7?(T<11.3?sm((T-10.3)/1):T<12.9?1:1-sm((T-12.9)/.8)):0;
 const ra=rig.arms[1];
 ra.sh.rotation.x=lerp(ra.sh.rotation.x,-1.28-(T>11.7&&T<12.3?.05*Math.sin((T-11.7)/.6*Math.PI):0),swp);
 ra.el.rotation.x=lerp(ra.el.rotation.x,-.45,swp);
 ra.sh.rotation.z=lerp(ra.sh.rotation.z,-.12,swp);
 rig.card.visible=swp>.02;
 rig.head.rotation.x=lerp(rig.head.rotation.x,.07,swp);

 /* Smooth Gate & Sliding Door Opening */
 const gk=sm((T-12.9)/1.3),dk=sm((T-13.8)/1.4);
 gates.forEach(g=>g.position.x=g.userData.b+Math.sign(g.userData.b)*gk*.55);
 doors.forEach(d=>d.position.x=d.userData.b+Math.sign(d.userData.b)*dk*1.3);

 /* Scanner: Subtle Green Standby, Clean Sweep, Green Verified Status */
 const st=T<11.6?0:T<12.3?1:2;
 readerDraw(st,(T-11.6)/.7);
 const pu=st===0?.5+.5*Math.sin(T*3.2):1;
 reader.ring.material.color.setHex(stCol[st]);
 reader.led.color.setHex(stCol[st]);
 reader.l.color.setHex(lCol[st]);
 reader.l.intensity=st===0?.14+.08*pu:st===1?.5:.95;

 R.toneMappingExposure=lerp(1.02,1.08,sm((T-15)/4));

 /* Interactive NPCs */
 npcs.forEach(n=>{
  if(n.k==='sit'){
   n.h.arms[0].el.rotation.x=-.8+Math.sin(T*9+n.o)*.06;
   n.h.arms[1].el.rotation.x=-.8+Math.cos(T*8+n.o)*.06;
   n.h.head.rotation.x=.05+Math.sin(T*1.1+n.o)*.02;
  }else if(n.k==='walk'){
   const u=(T*.5)%2,z=u<1?-3-u*5:-8+(u-1)*5;
   n.h.g.position.z=z;n.h.g.rotation.y=u<1?Math.PI:0;
   walk(n.h,T*5,1);
  }else{
   n.h.arms.forEach(a=>{a.sh.rotation.x=-.3;a.el.rotation.x=-.5});
   n.h.head.rotation.y=Math.sin(T*.7)*.12;
  }
 });

 const ms=T<2?0:T<14?1:T<22?2:3;
 if(ms!==msgState){
  msgState=ms;
  setMsg(ms===2?'Entering TEAMCONNECT Headquarters...':ms===3?'Your Modern Workspace Awaits':'');
 }

 if(T>24.4){
  const f=sm((T-24.4)/2.6);
  cvs.style.transition='none';
  cvs.style.opacity=1-f;
  cvs.style.transform='scale('+(1+.04*f)+')';
  if(!revealed){
   revealed=true;
   document.querySelectorAll('.lbar').forEach(b=>b.style.transform=b.classList.contains('t')?'translateY(-100%)':'translateY(100%)');
   onReveal();
  }
 }

 twin.g.position.copy(rig.g.position);twin.g.rotation.copy(rig.g.rotation);
 rig.legs.forEach((l,i)=>{twin.legs[i].hip.rotation.x=l.hip.rotation.x;twin.legs[i].knee.rotation.x=l.knee.rotation.x});
 rig.arms.forEach((a,i)=>{twin.arms[i].sh.rotation.x=a.sh.rotation.x;twin.arms[i].el.rotation.x=a.el.rotation.x});

 cars.forEach(c=>{c.g.position.x=((T*c.v+c.o)%160+160)%160-80});

 wmDraw(T);

 const fl=$('#tcfl');
 if(fl){
  const x=sm((T-12.3)/.4)*(1-sm((T-12.7)/1.2));
  fl.style.opacity=x;fl.style.transform='scaleX('+(.4+x*.8)+')';
 }

 R.render(S,cam);
 if(T>27.2)finish();
}

requestAnimationFrame(tick);
}
})();
</script>
<!-- ===== Landing page script (original logic; only the loader hand-off changed) ===== -->
<script>
(function(){
var loader=document.getElementById('loader'),page=document.getElementById('page'),heroText=document.getElementById('heroText');
var reduce=matchMedia('(prefers-reduced-motion: reduce)').matches,small=innerWidth<760,skip=document.getElementById('introSkip'),heroTimer;
var force=false;try{force=localStorage.getItem('tc_force')==='1';localStorage.removeItem('tc_force')}catch(e){}
function revealLanding(instant){
 clearTimeout(heroTimer);
 loader.classList.add('hide');page.classList.add('show');
 if(skip)skip.style.display='none';
 heroTimer=setTimeout(function(){heroText.classList.add('on')},instant||reduce?0:500);
}
function playIntro(){
 if(reduce&&!force){revealLanding(true);return}
 if(!window.TCIntro){revealLanding(true);return}
 TCIntro.start(function(){revealLanding(false)},function(){setTimeout(function(){revealLanding(true)},1200)});
}
skip.addEventListener('click',function(){if(window.TCIntro)TCIntro.stop();revealLanding(true)});
document.getElementById('replayIntro').addEventListener('click',function(event){event.preventDefault();try{localStorage.setItem('tc_force','1')}catch(e){}location.reload()});
if(document.readyState==='complete'){playIntro()}else{window.addEventListener('load',playIntro,{once:true})}
var io=new IntersectionObserver(function(es){es.forEach(function(e){if(e.isIntersecting)e.target.classList.add('show')})},{threshold:.12});
document.querySelectorAll('.reveal').forEach(function(e){io.observe(e)});
if(!reduce&&!small)document.querySelectorAll('.panel').forEach(function(p){p.addEventListener('mousemove',function(e){var r=p.getBoundingClientRect(),x=(e.clientX-r.left)/r.width-.5,y=(e.clientY-r.top)/r.height-.5;p.style.transform='perspective(900px) rotateY('+x*6+'deg) rotateX('+(-y*6)+'deg) translateY(-4px)'});p.addEventListener('mouseleave',function(){p.style.transform=''})});

/* ===== Cinematic night-city scene: dependency-free perspective renderer ===== */
var cv=document.getElementById('scene'),g=cv.getContext('2d'),W,H,F,hy,dpr;
function rs(){dpr=Math.min(devicePixelRatio||1,small?1:1.5);W=innerWidth;H=innerHeight;cv.width=W*dpr;cv.height=H*dpr;g.setTransform(dpr,0,0,dpr,0,0);F=Math.max(H,W*.7)*.9}
rs();
var seed=11;function rnd(){seed=(seed*16807)%2147483647;return seed/2147483647}
function hash(a,b,c){var x=Math.sin(a*127.1+b*311.7+c*74.7)*43758.5453;return x-Math.floor(x)}
var B=[],N=small?60:120,i;
for(i=0;i<N;i++){B.push({x:(i%2?1:-1)*(16+rnd()*36),w:4+rnd()*7,h:10+rnd()*52,z:-rnd()*230,s:i+1})}
B.sort(function(a,b){return a.z-b.z});
var ST=[];for(i=0;i<(small?70:150);i++)ST.push({x:rnd(),y:rnd()*.8,p:rnd()*6});
var TR=[];for(i=0;i<(small?10:22);i++)TR.push({x:(rnd()>.5?1:-1)*(2.5+rnd()*7),z:-rnd()*70,l:3+rnd()*6,v:.2+rnd()*.4,c:rnd()>.5?'#D9A86C':'#B7C4D8'});
var LP=[];for(i=-4;i<4;i++){LP.push({x:-9,z:-i*12});LP.push({x:9,z:-i*12-6})}
var cam={x:0,y:9,z:30};
function P(x,y,z){var d=cam.z-z;if(d<.4)d=.4;var s=F/d;return{x:W/2+(x-cam.x)*s,y:hy-(y-cam.y)*s,s:s,d:d}}
function fog(d){return Math.max(0,Math.min(1,1.15-d/210))}
function face(x1,x2,h,z,sd,hero){
 var p1=P(x1,h,z),p2=P(x2,0,z);if(cam.z-z<1||p2.x<-50||p1.x>W+50)return;
 var f=fog(p1.d),pw=p2.x-p1.x,ph=p2.y-p1.y,gr=g.createLinearGradient(0,p1.y,0,p2.y);
 if(hero){gr.addColorStop(0,'#21457a');gr.addColorStop(.5,'#112548');gr.addColorStop(1,'#0a1a33')}else{gr.addColorStop(0,'#13233b');gr.addColorStop(1,'#080f1d')}
 g.globalAlpha=f;g.fillStyle=gr;g.fillRect(p1.x,p1.y,pw,ph);
 if(pw>12){var cols=Math.max(2,Math.round((x2-x1)/(hero?1.7:2.4))),rows=Math.max(3,Math.round(h/(hero?3.4:3.2))),cw=pw/cols,rh=ph/rows;
  for(var r=0;r<rows;r++)for(var c=0;c<cols;c++){var k=hash(sd,r,c);if(k>(hero?.36:.5)){var q=hash(sd,c+9,r+3);g.fillStyle=q>.72?'#F5F7FA':q>.18?'#D9A86C':'#8fb8ff';g.globalAlpha=f*(.28+k*.6);g.fillRect(p1.x+c*cw+cw*.18,p1.y+r*rh+rh*.22,cw*.6,rh*.5)}}
  if(hero&&pw>60){g.strokeStyle='rgba(183,196,216,.16)';g.lineWidth=1;g.globalAlpha=f;g.beginPath();for(c=0;c<=cols;c++){g.moveTo(p1.x+c*cw,p1.y);g.lineTo(p1.x+c*cw,p2.y)}for(r=0;r<=rows;r++){g.moveTo(p1.x,p1.y+r*rh);g.lineTo(p2.x,p1.y+r*rh)}g.stroke()}}
 /* sky reflection sheen */
 var sh=g.createLinearGradient(p1.x,p1.y,p2.x,p1.y+ph*.6);sh.addColorStop(0,'rgba(57,139,255,'+(hero?.22:.1)+')');sh.addColorStop(1,'rgba(57,139,255,0)');g.globalAlpha=f;g.fillStyle=sh;g.fillRect(p1.x,p1.y,pw,ph);
 /* wet-ground reflection */
 var rf=g.createLinearGradient(0,p2.y,0,p2.y+ph*.5);rf.addColorStop(0,'rgba(217,168,108,'+(hero?.2:.1)+')');rf.addColorStop(1,'rgba(217,168,108,0)');g.fillStyle=rf;g.fillRect(p1.x,p2.y,pw,Math.min(ph*.5,H));g.globalAlpha=1}
function building(b){
 var zf=b.z+b.w/2,zb=b.z-b.w/2,x1=b.x-b.w/2,x2=b.x+b.w/2;if(cam.z-zf<1)return;
 var sx=cam.x<b.x?x1:x2,a=P(sx,b.h,zf),c=P(sx,0,zb),d=P(sx,b.h,zb),e=P(sx,0,zf);
 g.globalAlpha=fog(a.d);g.fillStyle='#060d19';g.beginPath();g.moveTo(a.x,a.y);g.lineTo(d.x,d.y);g.lineTo(c.x,c.y);g.lineTo(e.x,e.y);g.closePath();g.fill();
 face(x1,x2,b.h,zf,b.s,false);
 var t=P(b.x,b.h,zf);g.globalAlpha=fog(t.d)*.45;g.fillStyle='#B7C4D8';g.fillRect(t.x-b.w*t.s/2,t.y-1,b.w*t.s,Math.max(1,t.s*.12));g.globalAlpha=1}
function glow(x,y,r,col,a){var gg=g.createRadialGradient(x,y,0,x,y,r);gg.addColorStop(0,'rgba('+col+','+a+')');gg.addColorStop(1,'rgba('+col+',0)');g.fillStyle=gg;g.fillRect(x-r,y-r,r*2,r*2)}
function hq(t,open){
 var zf=-53,zl=-41,c=P(0,40,zf-5);
 glow(c.x,c.y,c.s*60,'57,139,255',.2);
 face(-10,10,74,zf-2.5,77,true);
 face(-17,17,60,zf,99,true);
 if(cam.z-zf>1){
  [-17,17].forEach(function(x){var a=P(x,60,zf),b=P(x,0,zf);g.fillStyle='#F5F7FA';g.shadowColor='#B7C4D8';g.shadowBlur=12;g.globalAlpha=.85;g.fillRect(a.x-1,a.y,Math.max(2,a.s*.22),b.y-a.y);g.globalAlpha=1;g.shadowBlur=0});
  var an=P(0,74,zf-2.5),at=P(0,88,zf-2.5);g.strokeStyle='#B7C4D8';g.lineWidth=Math.max(1,an.s*.12);g.beginPath();g.moveTo(an.x,an.y);g.lineTo(at.x,at.y);g.stroke();
  if(Math.sin(t*2.2)>0){glow(at.x,at.y,at.s*2.2+8,'217,168,108',.9)}
  for(var e=0;e<3;e++){var y=6+(Math.sin(t*.5+e*2.1)+1)*24,p=P(-1.6+e*1.6,y+2.2,zf+.1),q=P(-.9+e*1.6,y,zf+.1);g.fillStyle='#F5D9A8';g.globalAlpha=.9;g.fillRect(p.x,p.y,q.x-p.x,q.y-p.y);g.globalAlpha=1}}
 face(-21,21,9,zl,55,false);
 if(cam.z-zl>1){
  var d1=P(-6,7,zl),d2=P(6,0,zl),ig=g.createLinearGradient(0,d1.y,0,d2.y);ig.addColorStop(0,'#5a3d1e');ig.addColorStop(1,'#d9a86c');g.fillStyle=ig;g.globalAlpha=.5+open*.45;g.fillRect(d1.x,d1.y,d2.x-d1.x,d2.y-d1.y);g.globalAlpha=1;
  if(open>.3)for(var k=0;k<5;k++){var wx=((t*.7+k*2.7)%12)-6,fp=P(wx,0,zl-.3),hp=P(wx,2.6,zl-.3);g.fillStyle='rgba(8,13,24,.92)';g.beginPath();g.ellipse(fp.x,(fp.y+hp.y)/2+Math.sin(t*5+k)*fp.s*.04,fp.s*.34,(fp.y-hp.y)/2,0,0,6.283);g.fill();g.beginPath();g.arc(hp.x,hp.y-fp.s*.22,fp.s*.27,0,6.283);g.fill()}
  var px=open*3.6;[[-6-px,-px],[px,6+px]].forEach(function(o){var a=P(o[0],7,zl+.1),b=P(o[1],0,zl+.1);g.fillStyle='rgba(183,196,216,.18)';g.fillRect(a.x,a.y,b.x-a.x,b.y-a.y);g.strokeStyle='rgba(245,247,250,.45)';g.lineWidth=1;g.strokeRect(a.x,a.y,b.x-a.x,b.y-a.y)});
  var l1=P(-12,8.6,zl),l2=P(12,8.6,zl);g.fillStyle='#F2C98F';g.shadowColor='#D9A86C';g.shadowBlur=18;g.fillRect(l1.x,l1.y,l2.x-l1.x,Math.max(2,l1.s*.22));g.shadowBlur=0;
  var gb=P(0,0,zl+4);glow(gb.x,gb.y,gb.s*16,'217,168,108',.35);
  [-14,14].forEach(function(x){var u=P(x,0,zl+.5);glow(u.x,u.y,u.s*7,'57,139,255',.5)})}}
var t0=performance.now(),sp=0,mx=0,my=0,run=true,raf,hqDone;
function onScroll(){var m=document.documentElement.scrollHeight-innerHeight;sp=m>0?scrollY/m:0;document.body.classList.toggle('deep',scrollY>innerHeight*.7);if(reduce)draw(99)}
addEventListener('scroll',onScroll,{passive:true});
addEventListener('mousemove',function(e){mx=e.clientX/innerWidth-.5;my=e.clientY/innerHeight-.5},{passive:true});
addEventListener('resize',function(){rs();draw((performance.now()-t0)/1000)});
function ease(x){return x<.5?4*x*x*x:1-Math.pow(-2*x+2,3)/2}
function draw(t){
 var en=reduce?1:Math.min(Math.max((t-.8)/5,0),1),e=ease(en),fade=reduce?1:Math.min(t/2.2,1),open=reduce?1:Math.min(Math.max((t-4)/2.2,0),1);
 cam.x=mx*3;cam.z=30+(-18-30)*e-sp*70;cam.y=9+(3.6-9)*e+sp*6-my;hy=H*(.52+.1*(1-e))-sp*H*.12;
 var sk=g.createLinearGradient(0,0,0,hy);sk.addColorStop(0,'#05080f');sk.addColorStop(.6,'#0b1830');sk.addColorStop(1,'#1a3355');
 g.globalAlpha=1;g.fillStyle=sk;g.fillRect(0,0,W,Math.max(hy,0)+2);
 ST.forEach(function(s){var y=s.y*hy;g.fillStyle='#F5F7FA';g.globalAlpha=(.25+.5*Math.abs(Math.sin(t*.8+s.p)))*(1-y/hy);g.fillRect(s.x*W,y,1.2,1.2)});g.globalAlpha=1;
 var fl=g.createLinearGradient(0,hy,0,H);fl.addColorStop(0,'#13233b');fl.addColorStop(.35,'#0a1424');fl.addColorStop(1,'#04070d');g.fillStyle=fl;g.fillRect(0,hy,W,H-hy);
 /* road edge lines */
 g.strokeStyle='rgba(183,196,216,.22)';g.lineWidth=1;[-5,5].forEach(function(x){var a=P(x,0,-200),b=P(x,0,cam.z-1);g.beginPath();g.moveTo(a.x,a.y);g.lineTo(b.x,b.y);g.stroke()});
 /* vehicle light trails */
 TR.forEach(function(r){if(!reduce){r.z+=r.v;if(r.z>35)r.z=-70}var a=P(r.x,.2,r.z),b=P(r.x,.2,r.z-r.l);if(a.d<1)return;g.strokeStyle=r.c;g.shadowColor=r.c;g.shadowBlur=8;g.globalAlpha=fog(a.d)*.85;g.lineWidth=Math.max(1,a.s*.1);g.beginPath();g.moveTo(a.x,a.y);g.lineTo(b.x,b.y);g.stroke()});
 g.shadowBlur=0;g.globalAlpha=1;
 hqDone=false;
 for(var j=0;j<B.length;j++){if(!hqDone&&B[j].z>-52){hq(t,open);hqDone=true}building(B[j])}
 if(!hqDone)hq(t,open);
 /* atmospheric haze at the horizon */
 var hz=g.createLinearGradient(0,hy-H*.18,0,hy+H*.1);hz.addColorStop(0,'rgba(57,100,170,0)');hz.addColorStop(.6,'rgba(57,100,170,.22)');hz.addColorStop(1,'rgba(20,36,61,0)');g.fillStyle=hz;g.fillRect(0,hy-H*.18,W,H*.28);
 /* street lamps */
 LP.forEach(function(l){var z=l.z+((cam.z>0?0:0));var a=P(l.x,0,z),b=P(l.x,6,z);if(a.d<1.5||a.x<-40||a.x>W+40)return;var f=fog(a.d);g.globalAlpha=f;g.strokeStyle='#2a3a55';g.lineWidth=Math.max(1,a.s*.1);g.beginPath();g.moveTo(a.x,a.y);g.lineTo(b.x,b.y);g.stroke();glow(b.x,b.y,Math.max(8,b.s*3),'217,168,108',.85*f);glow(a.x,a.y,b.s*2.5,'217,168,108',.25*f)});g.globalAlpha=1;
 g.globalAlpha=1-fade;g.fillStyle='#000';g.fillRect(0,0,W,H);g.globalAlpha=1}
function loop(){draw((performance.now()-t0)/1000);if(run)raf=requestAnimationFrame(loop)}
if(reduce)draw(99);else loop();
document.addEventListener('visibilitychange',function(){if(document.hidden){run=false;cancelAnimationFrame(raf)}else if(!reduce){run=true;loop()}});
addEventListener('pagehide',function(){run=false;cancelAnimationFrame(raf)});

/* ===== Workforce network (illustrative nodes only, no business data) ===== */
(function(){
 var c=document.getElementById('netCanvas');if(!c)return;var n=c.getContext('2d'),nodes=[],w,h,vis=false,r2;
 function size(){w=c.width=c.clientWidth;h=c.height=c.clientHeight;nodes=[];for(var i=0;i<(w<600?22:42);i++)nodes.push({x:Math.random()*w,y:Math.random()*h,vx:(Math.random()-.5)*.4,vy:(Math.random()-.5)*.4,c:['#398BFF','#B7C4D8','#D9A86C'][i%3]})}
 function d(){n.clearRect(0,0,w,h);nodes.forEach(function(a,i){if(!reduce){a.x+=a.vx;a.y+=a.vy;if(a.x<0||a.x>w)a.vx*=-1;if(a.y<0||a.y>h)a.vy*=-1}
  for(var j=i+1;j<nodes.length;j++){var b=nodes[j],dd=Math.hypot(a.x-b.x,a.y-b.y);if(dd<130){n.strokeStyle='rgba(183,196,216,'+(1-dd/130)*.35+')';n.beginPath();n.moveTo(a.x,a.y);n.lineTo(b.x,b.y);n.stroke()}}
  n.fillStyle=a.c;n.shadowColor=a.c;n.shadowBlur=10;n.beginPath();n.arc(a.x,a.y,3,0,6.3);n.fill();n.shadowBlur=0});
  if(vis&&!reduce)r2=requestAnimationFrame(d)}
 size();d();addEventListener('resize',function(){size();d()});
 new IntersectionObserver(function(es){vis=es[0].isIntersecting;if(vis&&!reduce)d();else cancelAnimationFrame(r2)}).observe(c);
})();
})();
</script>
</body>
</html>
