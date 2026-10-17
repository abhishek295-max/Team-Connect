<%@ page contentType="text/html;charset=UTF-8" import="java.util.List,java.util.Map,util.WebUtil" %>
<% String contextPath = request.getContextPath(); List<Map<String,Object>> accounts = (List<Map<String,Object>>) request.getAttribute("accounts"); if (accounts == null) accounts = java.util.Collections.emptyList(); Map<String,Object> stats = (Map<String,Object>) request.getAttribute("stats"); if (stats == null) stats = java.util.Collections.emptyMap(); List<Map<String,Object>> recentAccounts = (List<Map<String,Object>>) request.getAttribute("recentAccounts"); if (recentAccounts == null) recentAccounts = java.util.Collections.emptyList(); List<Map<String,Object>> activityLogs = (List<Map<String,Object>>) request.getAttribute("activityLogs"); if (activityLogs == null) activityLogs = java.util.Collections.emptyList(); List<Map<String,Object>> messageTrend = (List<Map<String,Object>>) request.getAttribute("messageTrend"); if (messageTrend == null) messageTrend = java.util.Collections.emptyList(); int trendMax = 1; for (Map<String,Object> point : messageTrend) { trendMax = Math.max(trendMax, ((Number) point.get("total")).intValue()); } int usersTotal = ((Number) stats.getOrDefault("users", 0)).intValue(); int messagesTotal = ((Number) stats.getOrDefault("messages", 0)).intValue(); int groupsTotal = ((Number) stats.getOrDefault("groups", 0)).intValue(); int attachmentsTotal = ((Number) stats.getOrDefault("attachments", 0)).intValue(); int activityTotal = Math.max(1, usersTotal + messagesTotal + groupsTotal + attachmentsTotal); int userPct = usersTotal * 100 / activityTotal; int messagePct = messagesTotal * 100 / activityTotal; int groupPct = groupsTotal * 100 / activityTotal; int filePct = Math.max(0, 100 - userPct - messagePct - groupPct); %>
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>TeamConnect Admin Dashboard</title>
<script>(function(){var r=document.documentElement,t;r.classList.add('js');try{t=localStorage.getItem('adminTheme')}catch(e){}if(!t)t=matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';r.dataset.theme=t})()</script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,700&family=IBM+Plex+Sans:wght@400;500;600&display=swap" rel="stylesheet">
<style>
:root{--bg:#eef3f9;--s:#ffffffb8;--s2:#fff;--in:#f5f8fc;--line:#d8e2ee;--tx:#0f2236;--mu:#62778c;--b1:#1f6feb;--b2:#33b5f5;--ok:#17a673;--wn:#e59a2f;--bd:#d6434f;--sv:#8a9bb8;--sh:0 18px 45px #1d4a7a1a;--glow:#1f6feb2e;--ui:"IBM Plex Sans","Segoe UI",system-ui,sans-serif;--se:"Fraunces",Georgia,serif;color-scheme:light}
[data-theme=dark]{--bg:#020818;--s:#0a1630b8;--s2:#0d1b38;--in:#081228;--line:#1a2d52;--tx:#e7eefb;--mu:#8ca1c1;--b1:#4d8fff;--b2:#5fd3ff;--ok:#3ddba0;--wn:#f3b457;--bd:#ff6b78;--sv:#9fb0cc;--sh:0 20px 50px #00000066;--glow:#4d8fff3d;color-scheme:dark}
*{box-sizing:border-box;margin:0}
html{scroll-behavior:smooth}
body{position:relative;min-height:100vh;overflow-x:hidden;background:var(--bg);color:var(--tx);font:400 14px/1.5 var(--ui);transition:background-color .4s,color .4s}
body::before,body::after{content:"";position:fixed;z-index:0;border-radius:50%;filter:blur(70px);pointer-events:none;opacity:.4}
body::before{width:520px;height:520px;top:-190px;right:-130px;background:radial-gradient(circle,var(--b2),transparent 65%);animation:drift 18s ease-in-out infinite alternate}
body::after{width:480px;height:480px;bottom:-210px;left:12%;background:radial-gradient(circle,var(--b1),transparent 65%);animation:drift 22s ease-in-out infinite alternate-reverse}
[data-theme=dark] body::before,[data-theme=dark] body::after{opacity:.28}
.gridbg{position:fixed;inset:0;z-index:0;pointer-events:none;opacity:.35;background-image:linear-gradient(var(--line) 1px,transparent 1px),linear-gradient(90deg,var(--line) 1px,transparent 1px);background-size:46px 46px;-webkit-mask-image:radial-gradient(ellipse at 50% 0,#000,transparent 72%);mask-image:radial-gradient(ellipse at 50% 0,#000,transparent 72%)}
.i{width:18px;height:18px;flex:0 0 auto;fill:none;stroke:currentColor;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
.app{position:relative;z-index:1;display:flex;min-height:100vh}
.side{position:sticky;top:0;width:250px;height:100vh;padding:20px 14px;display:flex;flex-direction:column;gap:6px;border-right:1px solid var(--line);background:var(--s);backdrop-filter:blur(22px);-webkit-backdrop-filter:blur(22px);transition:background-color .4s,border-color .4s}
.sb{display:flex;align-items:center;gap:11px;padding:4px 8px 22px}
.mk{width:40px;height:40px;display:grid;place-items:center;border-radius:12px;color:#fff;font:700 15px var(--ui);background:linear-gradient(135deg,var(--b1),var(--b2));box-shadow:0 10px 24px var(--glow);animation:markGlow 3.2s ease-in-out infinite}
.sb strong{display:block;font-size:15px;font-weight:600}.sb span{display:block;color:var(--mu);font-size:12px}
.nav{display:grid;gap:3px}
.nav a{position:relative;display:flex;align-items:center;gap:11px;padding:10px 12px;border-radius:10px;color:var(--mu);font-weight:500;text-decoration:none;transition:color .2s,background-color .2s,transform .2s}
.nav a:hover{color:var(--tx);background:var(--in);transform:translateX(3px)}
.nav a.on{color:var(--b1);background:var(--in)}
.nav a.on::before{content:"";position:absolute;left:-14px;top:9px;bottom:9px;width:3px;border-radius:0 4px 4px 0;background:linear-gradient(var(--b2),var(--b1));animation:barIn .4s ease both}
.spot{margin:18px 4px 0;padding:14px;border:1px solid var(--line);border-radius:14px;background:var(--in)}
.spot strong{display:block;font-size:13px;font-weight:600}.spot p{margin:4px 0 12px;color:var(--mu);font-size:12px}
.meter{height:5px;border-radius:9px;background:var(--line);overflow:hidden}.meter i{display:block;height:100%;width:var(--w,80%);border-radius:inherit;background:linear-gradient(90deg,var(--ok),var(--b2));transform-origin:left;animation:fillX 1.3s cubic-bezier(.2,.8,.2,1) both}
.pf{display:flex;align-items:center;gap:10px;margin-top:auto;padding:12px 8px 0;border-top:1px solid var(--line)}
.av{width:34px;height:34px;display:grid;place-items:center;flex:0 0 auto;border-radius:10px;color:#fff;font:600 12px var(--ui);background:linear-gradient(135deg,var(--b1),var(--b2))}
.pf strong{display:block;font-size:13px;font-weight:600}.pf span{display:block;color:var(--mu);font-size:12px}
.main{flex:1;min-width:0;max-width:1500px;padding:20px 24px 40px}
.card{position:relative;overflow:hidden;padding:22px;border:1px solid var(--line);border-radius:16px;background:var(--s);box-shadow:var(--sh);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);transition:transform .3s,box-shadow .3s,border-color .3s,background-color .4s}
.card::after{content:"";position:absolute;inset:0;border-radius:inherit;pointer-events:none;opacity:0;transition:opacity .3s;background:radial-gradient(280px circle at var(--mx,50%) var(--my,50%),var(--glow),transparent 70%)}
.card:hover::after{opacity:1}
.card h2{font-size:17px;font-weight:600;margin-bottom:3px}.card .sub{color:var(--mu);font-size:13px;margin-bottom:18px}
html.js .rv:not(.in){opacity:0}
.rv.in{animation:rise .75s cubic-bezier(.2,.8,.2,1) backwards;animation-delay:var(--d,0s)}
.top{position:sticky;top:12px;z-index:30;display:flex;align-items:center;justify-content:space-between;gap:14px;flex-wrap:wrap;padding:12px 16px;margin-bottom:18px}
.top h1{font-size:16px;font-weight:600}.top small{display:block;color:var(--mu);font-size:12px;font-variant-numeric:tabular-nums}
.tools{display:flex;align-items:center;gap:8px;flex-wrap:wrap}
.btn{position:relative;overflow:hidden;display:inline-flex;align-items:center;justify-content:center;gap:8px;padding:9px 14px;border:1px solid var(--line);border-radius:10px;background:var(--s2);color:var(--tx);font:500 13px var(--ui);text-decoration:none;cursor:pointer;transition:transform .2s,box-shadow .2s,border-color .2s,color .2s}
.btn:hover{transform:translateY(-2px);border-color:var(--b1);box-shadow:0 10px 24px var(--glow)}.btn:active{transform:scale(.97)}
.btn.pri{border:0;color:#fff;background:linear-gradient(110deg,var(--b1),var(--b2),var(--b1));background-size:220% 100%;animation:sheen 6s linear infinite;box-shadow:0 10px 24px var(--glow)}
.btn.dg:hover{border-color:var(--bd);color:var(--bd);box-shadow:0 10px 24px #d6434f26}
.btn.sm{padding:7px 11px;font-size:12px}
:is(a,button,input,select,textarea):focus-visible{outline:2px solid var(--b2);outline-offset:2px}
.tg{position:relative;width:40px;height:40px;padding:0;border-radius:12px}
.tg svg{position:absolute;transition:transform .55s cubic-bezier(.2,.8,.2,1),opacity .3s}
.tg .sun{opacity:0;transform:rotate(-90deg) scale(.4)}
[data-theme=dark] .tg .sun{opacity:1;transform:none}[data-theme=dark] .tg .moon{opacity:0;transform:rotate(90deg) scale(.4)}
.hero{position:relative;display:grid;grid-template-columns:1.05fr .95fr;gap:18px;align-items:center;margin-bottom:18px;padding:38px 42px;border-radius:22px;overflow:hidden;color:#fff;background:linear-gradient(125deg,#0a2a5e 0%,#1b64d6 55%,#38b6f7 100%);box-shadow:0 26px 60px #1b64d63d}
[data-theme=dark] .hero{background:linear-gradient(125deg,#030d24 0%,#0a2559 55%,#0f4a90 100%);box-shadow:0 26px 60px #00000080,0 0 0 1px var(--line)}
.hero::before{content:"";position:absolute;inset:0;background:linear-gradient(105deg,transparent 30%,#ffffff1f 48%,transparent 66%);transform:translateX(-110%);animation:sweep 8s ease-in-out infinite}
.hero>*{position:relative}
.live{display:inline-flex;align-items:center;gap:8px;padding:6px 12px;border:1px solid #ffffff45;border-radius:99px;background:#ffffff1c;font-size:12px;font-weight:500}
.live i,.dot{width:8px;height:8px;border-radius:50%;background:#59f0b6;animation:ping 1.9s infinite}
.hero h1{max-width:560px;margin:18px 0 12px;font:600 clamp(30px,3.6vw,50px)/1.05 var(--se);letter-spacing:-.02em}
.hero p{max-width:470px;color:#d6e8fb;font-size:14px}
.hero .btn{border-color:#ffffff55;background:#ffffffee;color:#0e3a6b}.hero .btn.gh{background:#ffffff1c;color:#fff}
.hero .acts{display:flex;gap:10px;flex-wrap:wrap;margin-top:24px}
.hero svg{width:100%;height:auto;max-height:260px;overflow:visible}
.ln{fill:none;stroke:#ffffff66;stroke-width:1.4;stroke-dasharray:4 6;animation:dash 1.2s linear infinite}
.nd{fill:#fff}.nl{fill:#d6e8fb;font:500 11px var(--ui)}.core{fill:#ffffff26;stroke:#ffffffcc;stroke-width:1.5}.ct{fill:#fff;font:600 12px var(--ui)}
.stats{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:18px}
.stat{padding:18px 20px}.stat:hover{transform:translateY(-4px)}
.stat .ic{width:38px;height:38px;display:grid;place-items:center;margin-bottom:14px;border-radius:11px;color:#fff;background:linear-gradient(135deg,var(--b1),var(--b2))}
.stat:nth-child(2) .ic{background:linear-gradient(135deg,#17a673,#5ee0b0)}.stat:nth-child(3) .ic{background:linear-gradient(135deg,#e08a1e,#f6c36a)}.stat:nth-child(4) .ic{background:linear-gradient(135deg,#6f86ad,#b5c4de)}
.stat span.l{display:block;color:var(--mu);font-size:13px}
.stat b{display:block;margin:2px 0 12px;font:600 34px/1.1 var(--se);font-variant-numeric:tabular-nums}
.two{display:grid;grid-template-columns:1.25fr .75fr;gap:18px;margin-bottom:18px}
.ch{display:flex;justify-content:space-between;align-items:flex-start;gap:12px;margin-bottom:12px}
.ch h3{font-size:16px;font-weight:600}.ch span{color:var(--mu);font-size:12px}
.bars{height:210px;display:flex;align-items:flex-end;gap:12px;padding:26px 6px 0;border-bottom:1px solid var(--line)}
.bar{position:relative;flex:1;min-width:14px;height:var(--h);border-radius:8px 8px 3px 3px;background:linear-gradient(180deg,var(--b2),var(--b1));box-shadow:0 8px 18px var(--glow);transform-origin:bottom;animation:grow 1s cubic-bezier(.2,.8,.2,1) backwards,bob 4s ease-in-out infinite;animation-delay:calc(var(--i)*80ms),calc(1s + var(--i)*80ms);transition:filter .2s}
.bar:hover{filter:brightness(1.18)}
.bar::after{content:attr(data-v);position:absolute;top:-22px;left:50%;transform:translateX(-50%);color:var(--mu);font-size:11px;font-variant-numeric:tabular-nums}
.bl{display:flex;gap:12px;padding:8px 6px 0}.bl span{flex:1;text-align:center;color:var(--mu);font-size:11px}
.dw{display:flex;align-items:center;justify-content:center;gap:24px;flex-wrap:wrap;min-height:210px}
.db{position:relative;width:150px;height:150px}
.donut{width:100%;height:100%;border-radius:50%;-webkit-mask:radial-gradient(circle,transparent 57%,#000 58%);mask:radial-gradient(circle,transparent 57%,#000 58%);animation:spin 1.3s cubic-bezier(.2,.8,.2,1) backwards}
.dc{position:absolute;inset:0;display:grid;place-content:center;text-align:center}.dc b{font:600 24px/1 var(--se)}.dc span{margin-top:4px;color:var(--mu);font-size:11px}
.lg{display:grid;gap:10px}.lg span{display:flex;align-items:center;gap:8px;color:var(--mu);font-size:13px}.lg i{width:10px;height:10px;border-radius:3px}
.lg b{margin-left:auto;padding-left:12px;color:var(--tx);font-weight:600;font-variant-numeric:tabular-nums}
.field{display:block;margin:12px 0;color:var(--mu);font-size:13px;font-weight:500}
input,select,textarea{display:block;width:100%;margin-top:6px;padding:10px 12px;border:1px solid var(--line);border-radius:10px;outline:0;background:var(--in);color:var(--tx);font:400 14px var(--ui);transition:border-color .2s,box-shadow .2s,background-color .3s,transform .2s}
input:hover,select:hover,textarea:hover{border-color:var(--b2)}
input:focus,select:focus,textarea:focus{border-color:var(--b1);box-shadow:0 0 0 4px var(--glow);transform:translateY(-1px)}
textarea{resize:vertical}
.nf{display:grid;grid-template-columns:minmax(0,1fr) 190px;gap:12px}
.nh{display:flex;align-items:flex-start;justify-content:space-between;gap:14px}
.ni{width:38px;height:38px;display:grid;place-items:center;flex:0 0 auto;border-radius:11px;color:var(--b1);background:var(--in);animation:ring 5s ease-in-out infinite;transform-origin:50% 10%}
.aud{display:flex;align-items:center;gap:18px;flex-wrap:wrap;margin:6px 0 12px;color:var(--mu);font-size:13px}
.aud strong{color:var(--tx);font-weight:600}.aud label{display:flex;align-items:center;gap:7px;cursor:pointer}.aud input{display:inline-block;width:auto;margin:0;accent-color:var(--b1)}
.rl{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:8px;max-height:0;overflow:hidden;opacity:0;margin-bottom:0;transition:max-height .45s ease,opacity .3s ease,margin .3s}
.rl.enabled{max-height:200px;overflow:auto;opacity:1;margin-bottom:14px}
.rc{display:flex;align-items:center;gap:10px;padding:9px 11px;border:1px solid var(--line);border-radius:10px;background:var(--in);cursor:pointer;transition:border-color .2s,transform .2s}
.rc:hover{border-color:var(--b2);transform:translateY(-1px)}.rc input{display:inline-block;width:auto;margin:0;accent-color:var(--b1)}
.rc span{min-width:0}.rc strong,.rc small{display:block;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.rc strong{font-size:13px;font-weight:600}.rc small{color:var(--mu);font-size:12px}
.ok{display:flex;align-items:center;gap:8px;margin:10px 0 14px;padding:10px 12px;border:1px solid var(--ok);border-radius:10px;color:var(--ok);background:var(--in);font-size:13px;animation:rise .5s both}
.hp{display:grid;grid-template-columns:1.2fr .8fr;gap:18px;margin:18px 0}
.hl{display:grid;grid-template-columns:repeat(3,1fr);gap:10px}
.hi{padding:14px;border:1px solid var(--line);border-radius:12px;background:var(--in)}
.hi strong{display:flex;align-items:center;gap:8px;font-size:13px;font-weight:600}.hi span{display:block;margin-top:6px;color:var(--mu);font-size:12px}
.hi .dot{width:8px;height:8px;background:var(--ok)}
.hr{display:flex;flex-direction:column;align-items:center;gap:12px;text-align:center;color:var(--mu);font-size:12px}
.ring{position:relative;width:128px;height:128px;border-radius:50%;background:conic-gradient(var(--b2),var(--b1) 92%,var(--line) 0);-webkit-mask:radial-gradient(circle,transparent 62%,#000 63%);mask:radial-gradient(circle,transparent 62%,#000 63%);animation:spin 1.4s cubic-bezier(.2,.8,.2,1) backwards}
.rw{position:relative}.rw b{position:absolute;inset:0;display:grid;place-items:center;font:600 24px var(--se)}
.cols{display:grid;grid-template-columns:340px minmax(0,1fr);gap:18px}
.cols .full{grid-column:1/-1}
.cnt{margin-left:8px;padding:2px 10px;border-radius:99px;color:var(--b1);background:var(--in);font-size:12px;font-weight:600}
.rcl{display:grid;gap:8px}
.rr{display:flex;align-items:center;gap:12px;padding:10px 12px;border:1px solid var(--line);border-radius:12px;background:var(--in);transition:transform .25s,border-color .25s}
.rr:hover{transform:translateX(4px);border-color:var(--b2)}
.rr div:nth-child(2){min-width:0}.rr strong{display:block;font-size:13px;font-weight:600}.rr span{display:block;color:var(--mu);font-size:12px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.rr .dot{margin-left:auto;flex:0 0 auto}
.ah{display:flex;justify-content:space-between;align-items:flex-start;gap:12px;flex-wrap:wrap}.ah input{width:240px;margin:0}
.tw{overflow:auto}
.table{width:100%;min-width:720px;border-collapse:collapse;font-size:13px}
.table th{padding:10px;text-align:left;color:var(--mu);font-size:12px;font-weight:500;border-bottom:1px solid var(--line)}
.table td{padding:10px;border-bottom:1px solid var(--line);vertical-align:middle}
.table tbody tr{transition:background-color .2s}.table tbody tr:hover{background:var(--in)}
.table input{min-width:120px;margin:0;padding:8px 10px;font-size:13px}
.acts2{display:flex;gap:6px}
.empty{padding:30px;text-align:center;color:var(--mu)}
.sec{display:grid;grid-template-columns:1fr 1fr;gap:18px;margin-top:18px}.sec .card{min-width:0}
.sl{display:grid;gap:8px;max-height:420px;overflow:auto;padding-right:2px}
.sr{display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;padding:11px 12px;border:1px solid var(--line);border-radius:12px;transition:border-color .2s}
.sr:hover{border-color:var(--b2)}
.sr strong{font-size:13px;font-weight:600}.sr small{display:block;margin-top:2px;color:var(--mu);font-size:12px}
.sr form{display:flex;gap:6px;align-items:center}.sr select{width:auto;margin:0;padding:7px 9px;font-size:12px}
.lgs{max-height:420px;overflow:auto}
.lr{position:relative;padding:11px 0 11px 18px;border-bottom:1px solid var(--line)}
.lr::before{content:"";position:absolute;left:0;top:17px;width:8px;height:8px;border-radius:50%;background:var(--b1);box-shadow:0 0 0 4px var(--glow)}
.lr strong{font-size:13px;font-weight:600}.lr span{display:block;margin-top:2px;color:var(--mu);font-size:12px}
.about{display:grid;grid-template-columns:1.1fr .9fr;gap:18px;margin-top:18px;padding:24px}
.dev{display:flex;align-items:center;gap:16px;padding:18px;border:1px solid var(--line);border-radius:14px;background:var(--in)}
.dev .av{width:64px;height:64px;border-radius:18px;font-size:19px;animation:markGlow 3.2s ease-in-out infinite}
.dev h3{font:600 18px var(--se)}.dev p{margin-top:5px;color:var(--mu);font-size:13px}
.tags{display:flex;gap:6px;flex-wrap:wrap;margin-top:10px}.tags span{padding:4px 10px;border-radius:99px;color:var(--b1);background:var(--s2);border:1px solid var(--line);font-size:12px;font-weight:500}
.am{display:grid;grid-template-columns:1fr 1fr;gap:10px}
.am div{padding:14px;border:1px solid var(--line);border-radius:12px;background:var(--in)}
.am strong{display:block;color:var(--b1);font:600 20px var(--se)}.am span{display:block;margin-top:3px;color:var(--mu);font-size:12px}
@keyframes rise{from{opacity:0;transform:translateY(22px)}}
@keyframes drift{to{transform:translate(70px,40px) scale(1.18)}}
@keyframes sheen{to{background-position:220% 0}}
@keyframes sweep{0%,45%{transform:translateX(-110%)}75%,100%{transform:translateX(110%)}}
@keyframes dash{to{stroke-dashoffset:-20}}
@keyframes ping{0%{box-shadow:0 0 0 0 #59f0b680}70%{box-shadow:0 0 0 8px #59f0b600}100%{box-shadow:0 0 0 0 #59f0b600}}
@keyframes grow{from{transform:scaleY(0)}}
@keyframes bob{0%,100%{transform:scaleY(1)}50%{transform:scaleY(.96)}}
@keyframes spin{from{transform:rotate(-120deg) scale(.6);opacity:0}}
@keyframes fillX{from{transform:scaleX(0)}}
@keyframes barIn{from{transform:scaleY(0)}}
@keyframes markGlow{0%,100%{box-shadow:0 10px 24px var(--glow)}50%{box-shadow:0 10px 34px var(--b1)}}
@keyframes ring{0%,88%,100%{transform:rotate(0)}91%{transform:rotate(14deg)}94%{transform:rotate(-12deg)}97%{transform:rotate(8deg)}}
@media(max-width:1100px){.stats{grid-template-columns:repeat(2,1fr)}}
@media(max-width:980px){.side{width:72px;padding:18px 10px}.sb{justify-content:center;padding:4px 0 20px}.sb div:not(.mk),.nav .tx,.spot,.pf div{display:none}.nav a{justify-content:center;padding:11px}.pf{justify-content:center}.main{padding:14px}}
@media(max-width:850px){.hero{grid-template-columns:1fr;padding:28px}.two,.cols,.sec,.about,.hp{grid-template-columns:1fr}.hl{grid-template-columns:1fr 1fr}.nf{grid-template-columns:1fr}}
@media(max-width:700px){.app{display:block}.side{position:relative;width:100%;height:auto;flex-direction:row;align-items:center;padding:8px 10px;overflow:auto}.sb{padding:0 6px 0 0}.nav{display:flex}.pf{display:none}.top{position:relative;top:0}}
@media(max-width:520px){.stats,.hl,.am{grid-template-columns:1fr}.ah input{width:100%}.dev{flex-direction:column;align-items:flex-start}}
@media(prefers-reduced-motion:reduce){*,*::before,*::after{animation-duration:.01ms!important;animation-iteration-count:1!important;transition-duration:.01ms!important}html{scroll-behavior:auto}}
</style>
</head>
<body>
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
<symbol id="i-home" viewBox="0 0 24 24"><path d="M3 11l9-8 9 8v9a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/></symbol>
<symbol id="i-chart" viewBox="0 0 24 24"><path d="M4 20v-8M10 20V4M16 20v-6M22 20H2"/></symbol>
<symbol id="i-users" viewBox="0 0 24 24"><circle cx="9" cy="8" r="3.5"/><path d="M2.5 20c.6-3.6 3.2-5.5 6.5-5.5s5.9 1.9 6.5 5.5M16 4.8a3.5 3.5 0 0 1 0 6.4M18 14.8c2 .6 3.3 2.3 3.6 5.2"/></symbol>
<symbol id="i-bell" viewBox="0 0 24 24"><path d="M6 16v-5a6 6 0 0 1 12 0v5l1.5 2h-15zM10 21h4"/></symbol>
<symbol id="i-pulse" viewBox="0 0 24 24"><path d="M3 12h4l2-6 4 12 2-6h6"/></symbol>
<symbol id="i-shield" viewBox="0 0 24 24"><path d="M12 3l8 3v6c0 4.5-3.2 7.8-8 9-4.8-1.2-8-4.5-8-9V6z"/><path d="M8.5 12l2.5 2.5 4.5-5"/></symbol>
<symbol id="i-info" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 11v6M12 7.5v.5"/></symbol>
<symbol id="i-sun" viewBox="0 0 24 24"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M2 12h2M20 12h2M5 5l1.5 1.5M17.5 17.5L19 19M5 19l1.5-1.5M17.5 6.5L19 5"/></symbol>
<symbol id="i-moon" viewBox="0 0 24 24"><path d="M20 14.5A8.5 8.5 0 0 1 9.5 4 8.5 8.5 0 1 0 20 14.5z"/></symbol>
<symbol id="i-dl" viewBox="0 0 24 24"><path d="M12 4v11M7 11l5 5 5-5M4 20h16"/></symbol>
<symbol id="i-chat" viewBox="0 0 24 24"><path d="M4 5h16v11H9l-5 4z"/></symbol>
<symbol id="i-out" viewBox="0 0 24 24"><path d="M10 4H5v16h5M15 8l4 4-4 4M19 12H9"/></symbol>
<symbol id="i-check" viewBox="0 0 24 24"><path d="M5 12.5l4.5 4.5L19 7.5"/></symbol>
<symbol id="i-msg" viewBox="0 0 24 24"><path d="M4 4h16v12H8l-4 4z"/><path d="M8 9h8M8 12h5"/></symbol>
<symbol id="i-grp" viewBox="0 0 24 24"><circle cx="12" cy="7" r="3"/><circle cx="5" cy="17" r="2.5"/><circle cx="19" cy="17" r="2.5"/><path d="M10 9.5L6.5 15M14 9.5l3.5 5.5M8 17h8"/></symbol>
<symbol id="i-file" viewBox="0 0 24 24"><path d="M6 3h8l4 4v14H6z"/><path d="M14 3v4h4"/></symbol>
</svg>
<div class="gridbg"></div>
<div class="app">
<aside class="side">
    <div class="sb"><div class="mk">TC</div><div><strong>TeamConnect</strong><span>Admin console</span></div></div>
    <nav class="nav">
        <a class="on" href="#overview"><svg class="i"><use href="#i-home"/></svg><b class="tx">Overview</b></a>
        <a href="#analytics"><svg class="i"><use href="#i-chart"/></svg><b class="tx">Analytics</b></a>
        <a href="#notifications"><svg class="i"><use href="#i-bell"/></svg><b class="tx">Broadcasts</b></a>
        <a href="#health"><svg class="i"><use href="#i-pulse"/></svg><b class="tx">System health</b></a>
        <a href="#accounts"><svg class="i"><use href="#i-users"/></svg><b class="tx">Accounts</b></a>
        <a href="#security"><svg class="i"><use href="#i-shield"/></svg><b class="tx">Security</b></a>
        <a href="#about"><svg class="i"><use href="#i-info"/></svg><b class="tx">About</b></a>
    </nav>
    <div class="spot"><strong>All services running</strong><p>Database, messaging and security checks are responding normally.</p><div class="meter"><i style="--w:92%"></i></div></div>
    <div class="pf"><div class="av">TC</div><div><strong>TCadmin</strong><span>Super administrator</span></div></div>
</aside>
<div class="main">
    <header class="top card rv">
        <div><h1>Account administration</h1><small id="clock"></small></div>
        <div class="tools">
            <a class="btn sm" href="<%= contextPath %>/chat"><svg class="i"><use href="#i-chat"/></svg>Open workspace chat</a>
            <a class="btn sm" href="<%= contextPath %>/ems/admin">Employee operations</a>
            <a class="btn sm" href="<%= contextPath %>/admin/export/accounts.csv"><svg class="i"><use href="#i-dl"/></svg>Export accounts CSV</a>
            <a class="btn sm" href="<%= contextPath %>/admin/export/activity.csv"><svg class="i"><use href="#i-dl"/></svg>Export activity CSV</a>
            <button class="btn tg" id="themeToggle" type="button" aria-label="Toggle light and dark mode"><svg class="i moon"><use href="#i-moon"/></svg><svg class="i sun"><use href="#i-sun"/></svg></button>
            <a class="btn sm dg" href="<%= contextPath %>/admin/logout"><svg class="i"><use href="#i-out"/></svg>Log out</a>
        </div>
    </header>

    <section class="hero rv" id="overview">
        <div>
            <span class="live"><i></i>Workspace live</span>
            <h1>Every conversation, under control.</h1>
            <p>Monitor activity, manage accounts and send announcements to your team from one place.</p>
            <div class="acts"><a class="btn" href="#accounts">Manage accounts</a><a class="btn gh" href="#notifications">Send a broadcast</a></div>
        </div>
        <svg viewBox="0 0 420 250" aria-hidden="true">
            <path id="p1" class="ln" d="M60 62 Q130 72 210 125"/><path id="p2" class="ln" d="M360 52 Q290 72 210 125"/><path id="p3" class="ln" d="M70 196 Q140 176 210 125"/><path id="p4" class="ln" d="M352 190 Q282 174 210 125"/><path id="p5" class="ln" d="M210 22 L210 125"/>
            <circle class="nd" cx="60" cy="62" r="7"/><circle class="nd" cx="360" cy="52" r="7"/><circle class="nd" cx="70" cy="196" r="7"/><circle class="nd" cx="352" cy="190" r="7"/><circle class="nd" cx="210" cy="22" r="7"/>
            <text class="nl" x="60" y="46" text-anchor="middle">Users</text><text class="nl" x="360" y="36" text-anchor="middle">Groups</text><text class="nl" x="70" y="220" text-anchor="middle">Files</text><text class="nl" x="352" y="214" text-anchor="middle">Messages</text><text class="nl" x="210" y="10" text-anchor="middle">Admin</text>
            <circle cx="210" cy="125" r="28" fill="none" stroke="#7ee8c7"><animate attributeName="r" values="28;54" dur="2.6s" repeatCount="indefinite"/><animate attributeName="opacity" values=".75;0" dur="2.6s" repeatCount="indefinite"/></circle>
            <circle class="core" cx="210" cy="125" r="28"/><text class="ct" x="210" y="129" text-anchor="middle">Live</text>
            <circle r="3.5" fill="#7ee8c7"><animateMotion dur="2.8s" repeatCount="indefinite"><mpath href="#p1"/></animateMotion></circle>
            <circle r="3.5" fill="#fff"><animateMotion dur="3.4s" begin="-1s" repeatCount="indefinite" keyPoints="1;0" keyTimes="0;1" calcMode="linear"><mpath href="#p2"/></animateMotion></circle>
            <circle r="3.5" fill="#7ee8c7"><animateMotion dur="3s" begin="-2s" repeatCount="indefinite"><mpath href="#p3"/></animateMotion></circle>
            <circle r="3.5" fill="#fff"><animateMotion dur="2.6s" begin="-.5s" repeatCount="indefinite" keyPoints="1;0" keyTimes="0;1" calcMode="linear"><mpath href="#p4"/></animateMotion></circle>
            <circle r="3.5" fill="#7ee8c7"><animateMotion dur="2.2s" begin="-1.4s" repeatCount="indefinite"><mpath href="#p5"/></animateMotion></circle>
        </svg>
    </section>

    <section class="stats" id="stats">
        <div class="card stat rv"><div class="ic"><svg class="i"><use href="#i-users"/></svg></div><span class="l">Total accounts</span><b data-n="<%= usersTotal %>"><%= usersTotal %></b><div class="meter"><i style="--w:<%= Math.max(4, userPct) %>%"></i></div></div>
        <div class="card stat rv"><div class="ic"><svg class="i"><use href="#i-msg"/></svg></div><span class="l">Messages</span><b data-n="<%= messagesTotal %>"><%= messagesTotal %></b><div class="meter"><i style="--w:<%= Math.max(4, messagePct) %>%"></i></div></div>
        <div class="card stat rv"><div class="ic"><svg class="i"><use href="#i-grp"/></svg></div><span class="l">Active groups</span><b data-n="<%= groupsTotal %>"><%= groupsTotal %></b><div class="meter"><i style="--w:<%= Math.max(4, groupPct) %>%"></i></div></div>
        <div class="card stat rv"><div class="ic"><svg class="i"><use href="#i-file"/></svg></div><span class="l">Shared files</span><b data-n="<%= attachmentsTotal %>"><%= attachmentsTotal %></b><div class="meter"><i style="--w:<%= Math.max(4, filePct) %>%"></i></div></div>
    </section>

    <section class="two" id="analytics">
        <div class="card rv">
            <div class="ch"><div><h3>Message activity</h3><span>Database activity over the last 7 days</span></div><span><%= messagesTotal %> total</span></div>
            <% if (messageTrend.isEmpty()) { %><div class="empty">No message activity recorded yet.</div><% } else { %>
            <div class="bars"><% int bi = 0; for (Map<String,Object> point : messageTrend) { int pv = ((Number) point.get("total")).intValue(); bi++; %><div class="bar" style="--h:<%= Math.max(6, pv * 100 / trendMax) %>%;--i:<%= bi %>" data-v="<%= pv %>"></div><% } %></div>
            <div class="bl"><% for (int li = 1; li <= messageTrend.size(); li++) { %><span><%= li %></span><% } %></div>
            <% } %>
        </div>
        <div class="card rv">
            <div class="ch"><div><h3>Workspace mix</h3><span>Live database distribution</span></div></div>
            <div class="dw">
                <div class="db"><div class="donut" style="background:conic-gradient(var(--b1) 0 <%= userPct %>%,var(--ok) <%= userPct %>% <%= userPct + messagePct %>%,var(--wn) <%= userPct + messagePct %>% <%= userPct + messagePct + groupPct %>%,var(--sv) <%= userPct + messagePct + groupPct %>% 100%)"></div><div class="dc"><b><%= usersTotal + messagesTotal + groupsTotal + attachmentsTotal %></b><span>records</span></div></div>
                <div class="lg"><span><i style="background:var(--b1)"></i>Accounts<b><%= usersTotal %></b></span><span><i style="background:var(--ok)"></i>Messages<b><%= messagesTotal %></b></span><span><i style="background:var(--wn)"></i>Groups<b><%= groupsTotal %></b></span><span><i style="background:var(--sv)"></i>Files<b><%= attachmentsTotal %></b></span></div>
            </div>
        </div>
    </section>

    <section class="card rv" id="notifications">
        <div class="nh"><div><h2>Broadcast notification</h2><p class="sub">Send an in-app alert to every active user or selected accounts.</p></div><span class="ni"><svg class="i"><use href="#i-bell"/></svg></span></div>
        <% if (request.getParameter("notificationSent") != null) { %><div class="ok"><svg class="i"><use href="#i-check"/></svg><span>Notification delivered to <strong><%= request.getParameter("notificationSent") %></strong> user(s).</span></div><% } %>
        <form method="post" action="<%= contextPath %>/admin/notifications/send" class="notification-form">
            <div class="nf"><label class="field">Title<input name="title" maxlength="160" placeholder="System update" required></label><label class="field">Type<select name="type"><option value="INFO">Information</option><option value="SUCCESS">Success</option><option value="WARNING">Warning</option><option value="MAINTENANCE">Maintenance</option></select></label></div>
            <label class="field">Message<textarea name="message" maxlength="1000" rows="3" placeholder="Write the announcement for your team..." required></textarea></label>
            <div class="aud"><strong>Audience</strong><label><input type="radio" name="audience" value="all" checked onchange="toggleRecipients(false)"> All active users</label><label><input type="radio" name="audience" value="selected" onchange="toggleRecipients(true)"> Selected users</label></div>
            <div class="rl" id="recipientList"><% for (Map<String,Object> account : accounts) { %><label class="rc"><input type="checkbox" name="recipients" value="<%= account.get("id") %>" disabled><span><strong><%= WebUtil.escapeHtml(String.valueOf(account.get("username"))) %></strong><small><%= WebUtil.escapeHtml(String.valueOf(account.get("email"))) %></small></span></label><% } %></div>
            <button class="btn pri" type="submit">Send notification</button>
        </form>
    </section>

    <section class="hp" id="health">
        <div class="card rv"><div class="nh"><div><h2>System health</h2><p class="sub">Live operational snapshot of the TeamConnect workspace.</p></div><span class="dot"></span></div><div class="hl"><div class="hi"><strong><i class="dot"></i>Database</strong><span>Connected and responsive</span></div><div class="hi"><strong><i class="dot"></i>Messaging</strong><span>Delivery pipeline stable</span></div><div class="hi"><strong><i class="dot"></i>Security</strong><span>Policies running normally</span></div></div></div>
        <div class="card rv hr"><div class="rw"><div class="ring"></div><b>92%</b></div><div>Workspace reliability score<br><strong>All services operational</strong></div></div>
    </section>

    <main class="cols" id="accounts">
        <section class="card rv">
            <h2>Register account</h2><p class="sub">Create a new user account directly from the admin panel.</p>
            <form method="post" action="<%= contextPath %>/admin/accounts/create">
                <label class="field">Username<input name="username" required maxlength="80"></label>
                <label class="field">Email<input type="email" name="email" required maxlength="160"></label>
                <label class="field">Password<input type="password" name="password" required minlength="6"></label>
                <label class="field">Workforce role<select name="role" required><option value="EMPLOYEE">Employee</option><option value="HR">HR</option><option value="MANAGER">Manager</option><option value="ADMIN">Admin</option></select></label>
                <p class="sub">Employee, HR and Manager accounts are automatically linked to the EMS dashboard. Admin accounts use the separate Admin Console login.</p>
                <button class="btn pri" type="submit" style="width:100%">Create account</button>
            </form>
        </section>
        <section class="card rv"><h2>Recent accounts</h2><p class="sub">Latest users added to the workspace.</p><div class="rcl"><% for (Map<String,Object> account : recentAccounts) { %><div class="rr"><div class="av"><%= String.valueOf(account.get("username")).substring(0, Math.min(2, String.valueOf(account.get("username")).length())).toUpperCase() %></div><div><strong><%= WebUtil.escapeHtml(String.valueOf(account.get("username"))) %></strong><span><%= WebUtil.escapeHtml(String.valueOf(account.get("email"))) %></span></div><i class="dot"></i></div><% } %><% if (recentAccounts.isEmpty()) { %><div class="empty">No recent accounts.</div><% } %></div></section>
        <section class="card rv full">
            <div class="ah"><div><h2>Registered accounts <span class="cnt"><%= accounts.size() %></span></h2><p class="sub">View, edit, reset passwords, or delete user accounts.</p></div><input id="accountSearch" type="search" placeholder="Search accounts..."></div>
            <div class="tw"><table class="table"><thead><tr><th>ID</th><th>Username</th><th>Email</th><th>New password</th><th>Actions</th></tr></thead><tbody>
            <% if (accounts.isEmpty()) { %><tr><td class="empty" colspan="5">No accounts found.</td></tr><% } %>
            <% for (Map<String,Object> account : accounts) { %>
                <% String rowId = "account-" + account.get("id"); %>
                <tr><td><%= account.get("id") %></td><td><input form="<%= rowId %>" name="username" value="<%= WebUtil.escapeHtml(String.valueOf(account.get("username"))) %>" required></td><td><input form="<%= rowId %>" type="email" name="email" value="<%= WebUtil.escapeHtml(String.valueOf(account.get("email"))) %>" required></td><td><input form="<%= rowId %>" type="password" name="password" placeholder="Keep current"></td><td><div class="acts2"><form id="<%= rowId %>" method="post" action="<%= contextPath %>/admin/accounts/update"><input type="hidden" name="id" value="<%= account.get("id") %>"><button class="btn sm" type="submit">Save</button></form><form method="post" action="<%= contextPath %>/admin/accounts/delete" onsubmit="return confirm('Delete this account permanently?');"><input type="hidden" name="id" value="<%= account.get("id") %>"><button class="btn sm dg" type="submit">Delete</button></form></div></td></tr>
            <% } %>
            </tbody></table></div>
        </section>
    </main>

    <section class="sec" id="security">
        <section class="card rv"><h2>Roles and access</h2><p class="sub">Control account permissions and availability.</p><div class="sl"><% for (Map<String,Object> account : accounts) { %><div class="sr"><div><strong><%= WebUtil.escapeHtml(String.valueOf(account.get("username"))) %></strong><small>ID <%= account.get("id") %> Â· <%= account.get("last_login_at") == null ? "Never signed in" : "Last active " + account.get("last_login_at") %></small></div><form method="post" action="<%= contextPath %>/admin/accounts/state"><input type="hidden" name="id" value="<%= account.get("id") %>"><select name="role"><option value="USER" <%= "USER".equals(account.get("role")) ? "selected" : "" %>>User</option><option value="MODERATOR" <%= "MODERATOR".equals(account.get("role")) ? "selected" : "" %>>Moderator</option><option value="ADMIN" <%= "ADMIN".equals(account.get("role")) ? "selected" : "" %>>Admin</option></select><select name="status"><option value="ACTIVE" <%= "ACTIVE".equals(account.get("status")) ? "selected" : "" %>>Active</option><option value="SUSPENDED" <%= "SUSPENDED".equals(account.get("status")) ? "selected" : "" %>>Suspended</option><option value="DISABLED" <%= "DISABLED".equals(account.get("status")) ? "selected" : "" %>>Disabled</option></select><button class="btn sm" type="submit">Apply</button></form></div><% } %></div></section>
        <section class="card rv"><h2>Admin activity</h2><p class="sub">Recent security and account administration events.</p><div class="lgs"><% for (Map<String,Object> log : activityLogs) { %><div class="lr"><strong><%= WebUtil.escapeHtml(String.valueOf(log.get("action"))) %></strong><span><%= WebUtil.escapeHtml(String.valueOf(log.get("admin_username"))) %> Â· target <%= log.get("target_id") == null ? "system" : log.get("target_id") %> Â· <%= log.get("created_at") %></span></div><% } %><% if (activityLogs.isEmpty()) { %><div class="empty">No activity recorded yet.</div><% } %></div></section>
    </section>

    <section class="card about rv" id="about">
        <div class="dev"><div class="av">AS</div><div><h3>Built by Abhishek Samadhiya</h3><p>TeamConnect is an enterprise-ready communication workspace designed with a focus on secure collaboration, clear administration and a polished user experience.</p><div class="tags"><span>JSP</span><span>Spring Boot</span><span>MySQL</span><span>Real-time Chat</span></div></div></div>
        <div class="am"><div><strong>24/7</strong><span>Workspace availability</span></div><div><strong>Secure</strong><span>Admin-first governance</span></div><div><strong>Live</strong><span>Message synchronization</span></div><div><strong>v1.0</strong><span>TeamConnect platform</span></div></div>
    </section>
</div>
</div>
<script>
(function () {
    var d = document, r = d.documentElement, rm = matchMedia('(prefers-reduced-motion: reduce)').matches;

    var tg = d.getElementById('themeToggle');
    tg.setAttribute('aria-pressed', r.dataset.theme === 'dark');
    tg.addEventListener('click', function () {
        var t = r.dataset.theme === 'dark' ? 'light' : 'dark';
        r.dataset.theme = t;
        tg.setAttribute('aria-pressed', t === 'dark');
        try { localStorage.setItem('adminTheme', t); } catch (e) {}
    });

    var search = d.getElementById('accountSearch');
    if (search) search.addEventListener('input', function () {
        var q = this.value.trim().toLowerCase();
        d.querySelectorAll('.table tbody tr').forEach(function (row) {
            var text = row.textContent.toLowerCase();
            row.querySelectorAll('input:not([type=password]):not([type=hidden])').forEach(function (i) { text += ' ' + i.value.toLowerCase(); });
            row.style.display = text.indexOf(q) > -1 ? '' : 'none';
        });
    });

    var items = d.querySelectorAll('.rv');
    items.forEach(function (e, i) { e.style.setProperty('--d', Math.min(i, 9) * 70 + 'ms'); });
    if (rm || !('IntersectionObserver' in window)) {
        items.forEach(function (e) { e.classList.add('in'); });
    } else {
        var io = new IntersectionObserver(function (es) {
            es.forEach(function (x) { if (x.isIntersecting) { x.target.classList.add('in'); io.unobserve(x.target); } });
        }, { threshold: .06 });
        items.forEach(function (e) { io.observe(e); });
    }

    d.querySelectorAll('[data-n]').forEach(function (e) {
        var n = +e.dataset.n;
        if (rm || !n) return;
        var t0 = performance.now();
        e.textContent = '0';
        (function f(t) {
            var p = Math.min(1, (t - t0) / 1300), k = 1 - Math.pow(1 - p, 3);
            e.textContent = Math.round(n * k).toLocaleString();
            if (p < 1) requestAnimationFrame(f);
        })(t0);
    });

    d.querySelectorAll('.card').forEach(function (c) {
        c.addEventListener('pointermove', function (e) {
            var b = c.getBoundingClientRect();
            c.style.setProperty('--mx', (e.clientX - b.left) + 'px');
            c.style.setProperty('--my', (e.clientY - b.top) + 'px');
        });
    });

    var links = [].slice.call(d.querySelectorAll('.nav a'));
    if ('IntersectionObserver' in window) {
        var so = new IntersectionObserver(function (es) {
            es.forEach(function (x) {
                if (x.isIntersecting) links.forEach(function (l) { l.classList.toggle('on', l.getAttribute('href') === '#' + x.target.id); });
            });
        }, { rootMargin: '-35% 0px -55% 0px' });
        links.forEach(function (l) { var t = d.querySelector(l.getAttribute('href')); if (t) so.observe(t); });
    }

    var clock = d.getElementById('clock');
    function tick() { clock.textContent = new Date().toLocaleString([], { weekday: 'short', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit', second: '2-digit' }); }
    tick(); setInterval(tick, 1000);

    if (rm) d.querySelectorAll('svg').forEach(function (s) { if (s.pauseAnimations) s.pauseAnimations(); });
})();

function toggleRecipients(enabled) {
    document.querySelectorAll('#recipientList input').forEach(function (input) {
        input.disabled = !enabled;
        if (!enabled) input.checked = false;
    });
    document.getElementById('recipientList').classList.toggle('enabled', enabled);
}
</script>
<style id="tc-premium-ui">
:root{--tc-ease:cubic-bezier(.2,.8,.2,1)}
body{transition:background .6s ease,color .45s ease}
body:not(.dashboard):before{transition:opacity .6s,transform .6s}
button,a,input,select,textarea{transition:transform .28s var(--tc-ease),box-shadow .28s,border-color .28s,background .45s,color .3s}
button:hover,a:hover{transform:translateY(-2px)}
button:active,a:active{transform:scale(.97)}
input:hover,select:hover,textarea:hover{border-color:color-mix(in srgb,var(--accent,#4c9bff) 55%,#fff0)}
input:focus,select:focus,textarea:focus{outline:0;transform:translateY(-2px);box-shadow:0 0 0 4px color-mix(in srgb,var(--accent,#4c9bff) 18%,transparent),0 12px 28px #1d64aa16}
.card,.panel,.auth-page,.auth-wrapper,.shell,.form-section,.image-section,.sidebar,.conversation,.insights,.workspace-card{transition:transform .4s var(--tc-ease),box-shadow .4s,border-color .4s,background .5s}
.card:hover,.panel:hover,.workspace-card:hover{transform:translateY(-6px);box-shadow:0 24px 60px color-mix(in srgb,var(--accent,#4c9bff) 15%,transparent)}
.reveal,.section,.auth-page,.tile,.role{animation:tcEnter .72s var(--tc-ease) both}
@keyframes tcEnter{from{opacity:0;transform:translateY(18px) scale(.985)}to{opacity:1;transform:none}}
@keyframes tcShimmer{from{transform:translateX(-130%)}to{transform:translateX(130%)}}
@keyframes tcPulse{50%{box-shadow:0 0 0 8px color-mix(in srgb,var(--accent,#4c9bff) 10%,transparent)}}
::-webkit-scrollbar{width:10px;height:10px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:linear-gradient(var(--accent,#4c9bff),var(--cyan,#6de0bd));border:3px solid transparent;background-clip:padding-box;border-radius:99px}
body.theme-changing:after{content:"";position:fixed;inset:0;z-index:999;background:radial-gradient(circle at 50% 0,color-mix(in srgb,var(--accent,#4c9bff) 28%,transparent),transparent 55%);pointer-events:none;animation:tcTheme .7s ease both}
@keyframes tcTheme{from{opacity:0;transform:scale(.8)}45%{opacity:1}to{opacity:0;transform:scale(1.15)}}
@media(max-width:700px){button:hover,a:hover{transform:none}.card:hover,.panel:hover,.workspace-card:hover{transform:translateY(-3px)}}
@media(prefers-reduced-motion:reduce){*,*:before,*:after{animation:none!important;transition:none!important;transform:none!important}}
</style><script id="tc-premium-behavior">
(function(){function animateTheme(){document.body.classList.remove("theme-changing");void document.body.offsetWidth;document.body.classList.add("theme-changing");setTimeout(function(){document.body.classList.remove("theme-changing")},700)}["theme","themeToggle","themeSelect"].forEach(function(id){var e=document.getElementById(id);if(e)e.addEventListener("click",animateTheme)});var r=document.querySelectorAll(".card,.panel,.tile,.role,.section,.auth-page");r.forEach(function(e,i){e.style.animationDelay=Math.min(i*.045,.5)+"s"});})();
</script></body>
</html>

