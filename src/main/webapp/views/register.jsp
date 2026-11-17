<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
if (session != null && Boolean.TRUE.equals(session.getAttribute("adminAuthenticated"))) { response.sendRedirect(request.getContextPath() + "/admin"); return; }
if (session != null && session.getAttribute("userId") != null) { response.sendRedirect(request.getContextPath() + "/chat"); return; }
String contextPath=request.getContextPath(), error=request.getParameter("error"), registered=request.getParameter("registered"), deleted=request.getParameter("deleted");
String message=null; boolean messageIsError=false;
if ("1".equals(registered)) message="Registration completed successfully. You can sign in now.";
else if ("1".equals(deleted)) message="Account deleted successfully.";
else if ("invalid".equals(error)||"1".equals(error)) {message="Invalid username or password.";messageIsError=true;}
else if ("username_exists".equals(error)) {message="That username is already in use.";messageIsError=true;}
else if ("email_exists".equals(error)) {message="That email address is already registered.";messageIsError=true;}
else if ("admin_login_route".equals(error)) {message="Administrator accounts must sign in from the separate /admin panel.";messageIsError=true;}
else if ("ems_link_missing".equals(error)) {message="Your TeamConnect account is not linked to an employee profile yet.";messageIsError=true;}
else if (error!=null) {message="The request could not be completed. Please try again.";messageIsError=true;}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Get Started</title>
<style>
:root{--ink:#F5F7FA;--silver:#B7C4D8;--blue:#398BFF;--amber:#D9A86C;--navy:#14243D;--bg:#080D18;--f:'Segoe UI',system-ui,-apple-system,Roboto,Arial,sans-serif}
*{box-sizing:border-box}html,body{margin:0}
body{min-height:100vh;background:radial-gradient(ellipse at 40% 20%,#14243D,#080D18 70%);color:var(--ink);font-family:var(--f);overflow-x:hidden}
a{color:inherit}
#scene{position:fixed;inset:0;width:100%;height:100%;display:block;z-index:0}
body.noscene #scene{display:none}
.shell{position:relative;z-index:2;min-height:100vh;display:flex;align-items:center;justify-content:flex-end;padding:24px 5vw}
.panel{width:min(430px,100%);padding:34px 32px 30px;border-radius:24px;background:linear-gradient(160deg,rgba(20,36,61,.78),rgba(8,13,24,.82));border:1px solid rgba(183,196,216,.24);backdrop-filter:blur(18px) saturate(120%);-webkit-backdrop-filter:blur(18px) saturate(120%);box-shadow:0 30px 80px rgba(0,0,0,.55),inset 0 1px rgba(255,255,255,.1),0 0 0 1px rgba(57,139,255,.08);transition:opacity .9s cubic-bezier(.2,.8,.2,1),transform .9s cubic-bezier(.2,.8,.2,1),visibility .9s}
.panel:before{content:"";position:absolute;left:24px;right:24px;top:0;height:1px;background:linear-gradient(90deg,transparent,var(--blue),transparent)}
.panel.intro-hidden{opacity:0;transform:translateX(30px) scale(.98);visibility:hidden;pointer-events:none}
.top{display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:22px}
.logo{width:44px;height:44px;border-radius:13px;display:grid;place-items:center;background:linear-gradient(135deg,#4b9bff,#1f5fc4);font-weight:800;font-size:17px;box-shadow:0 10px 26px rgba(57,139,255,.35)}
.chip{display:inline-flex;align-items:center;gap:8px;padding:6px 11px;border:1px solid rgba(183,196,216,.25);border-radius:99px;font-size:11px;color:var(--silver);letter-spacing:.04em}
.chip i{width:7px;height:7px;border-radius:50%;background:var(--blue);box-shadow:0 0 10px var(--blue)}
.chip.deny i{background:var(--amber);box-shadow:0 0 10px var(--amber)}
h1{font-size:30px;letter-spacing:-.02em;margin:0 0 6px}
.sub{margin:0 0 20px;color:#8fa0b8;font-size:14px}
.msg{padding:11px 13px;border-radius:11px;font-size:13px;margin-bottom:16px;border:1px solid rgba(57,139,255,.4);background:rgba(57,139,255,.1);color:#cfe1ff}
.msg.error{border-color:rgba(217,168,108,.6);background:rgba(217,168,108,.12);color:#f3d9b4}
.msg[hidden]{display:none}
.hint{font-size:12px;color:#8fa0b8;line-height:1.6;margin:0 0 18px}.hint a{color:var(--silver)}
.field{margin-bottom:15px}
.field label{display:block;font-size:12px;font-weight:600;color:var(--silver);margin-bottom:7px;letter-spacing:.04em}
.inp{position:relative}
.inp input[type=text],.inp input[type=password]{width:100%;height:50px;padding:0 15px;border-radius:12px;border:1px solid rgba(183,196,216,.25);background:rgba(8,13,24,.55);color:var(--ink);font:inherit;font-size:14px;outline:0;transition:border-color .25s,box-shadow .25s,background .25s}
.inp input::placeholder{color:#62738d}
.inp input:focus{border-color:var(--blue);box-shadow:0 0 0 4px rgba(57,139,255,.18);background:rgba(8,13,24,.8)}
.eye{position:absolute;right:6px;top:6px;height:38px;padding:0 11px;border:0;border-radius:9px;background:transparent;color:var(--silver);font-size:12px;font-weight:600;cursor:pointer}
.eye:hover,.eye:focus-visible{background:rgba(255,255,255,.08);outline:0}
.pw input{padding-right:70px!important}
.opts{display:flex;justify-content:space-between;align-items:center;margin:4px 0 20px;font-size:13px;color:#9fb0c8}
.opts label{display:flex;gap:8px;align-items:center;cursor:pointer}.opts input{accent-color:var(--blue);width:16px;height:16px}
.opts a{color:var(--silver);font-weight:600;text-decoration:none}.opts a:hover{color:#fff}
.go{width:100%;height:52px;border:0;border-radius:13px;background:linear-gradient(135deg,#4b9bff,#2a66d8);color:#fff;font:inherit;font-size:15px;font-weight:700;letter-spacing:.02em;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:10px;box-shadow:0 14px 34px rgba(57,139,255,.35);transition:transform .25s,box-shadow .25s,opacity .25s}
.go:hover{transform:translateY(-2px);box-shadow:0 18px 42px rgba(57,139,255,.5)}.go:focus-visible,.opts a:focus-visible,.skip:focus-visible{outline:2px solid var(--amber);outline-offset:3px}
.go[disabled]{opacity:.75;cursor:progress;transform:none}
.spin{width:16px;height:16px;border-radius:50%;border:2px solid rgba(255,255,255,.35);border-top-color:#fff;animation:sp .8s linear infinite;display:none}.go.load .spin{display:block}
@keyframes sp{to{transform:rotate(360deg)}}
.note{position:fixed;left:5vw;bottom:22px;z-index:3;max-width:440px;font-size:11px;line-height:1.6;color:#8fa0b8;opacity:0;transition:opacity 1.2s}.note.on{opacity:1}
.skip{position:fixed;left:5vw;top:22px;z-index:4;padding:9px 15px;border-radius:99px;border:1px solid rgba(183,196,216,.3);background:rgba(8,13,24,.55);backdrop-filter:blur(8px);color:var(--silver);font:inherit;font-size:12px;letter-spacing:.06em;cursor:pointer}
.skip:hover{color:#fff;border-color:#fff}.skip[hidden]{display:none}
.sr{position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0 0 0 0)}
@media(max-width:900px){.shell{align-items:flex-end;justify-content:center;padding:calc(47vh) 14px 16px}.panel{padding:26px 22px 22px}h1{font-size:26px}.note{display:none}}
@media(prefers-reduced-motion:reduce){*{animation-duration:.01ms!important;transition-duration:.01ms!important}}
</style>
</head>
<body>
<canvas id="scene" aria-hidden="true"></canvas>
<button class="skip" id="skip" type="button">Skip intro</button>
<main class="shell">
<section class="panel intro-hidden" id="panel" aria-labelledby="ttl">
 <div class="top"><div class="logo" aria-hidden="true">TC</div><div class="chip" id="chip" role="status" aria-live="polite"><i></i><span id="statusTxt">Scanner idle</span></div></div>
 <h1 id="ttl">Welcome back</h1>
 <p class="sub">Sign in to your TeamConnect workspace.</p>
 <% if (message != null) { %><div class="msg<%= messageIsError ? " error" : "" %>" id="msg" role="alert"><%= message %></div><% } else { %><div class="msg" id="msg" role="alert" hidden></div><% } %>
 <form id="loginForm" method="post" action="<%= contextPath %>/login">
  <p class="hint">Your workspace is selected automatically from your account role. Administrators use the separate <a href="<%= contextPath %>/admin">Admin Console</a>.</p>
  <div class="field"><label for="username">Username</label><div class="inp"><input type="text" id="username" name="username" placeholder="Enter your username" autocomplete="username" required></div></div>
  <div class="field"><label for="password">Password</label><div class="inp pw"><input type="password" id="password" name="password" placeholder="Enter your password" autocomplete="current-password" required><button type="button" class="eye" id="eye" aria-label="Show password" aria-pressed="false">Show</button></div></div>
  <div class="opts"><label><input type="checkbox"> Remember me</label><a href="#" class="forgot">Forgot password?</a></div>
  <button type="submit" class="go" id="signin"><span class="spin" aria-hidden="true"></span><span id="goTxt">Sign in</span></button>
 </form>
 <div hidden id="registerPage"><form method="post" action="/register"><input type="text" name="username"><input type="email" name="email"><input type="password" name="password"></form></div>
</section>
</main>
<p class="note" id="note">The fingerprint sequence is a visual animation only. Access is granted only after the server verifies your username and password.</p>

<script>
(function(){
var $=function(i){return document.getElementById(i)},reduce=matchMedia('(prefers-reduced-motion: reduce)').matches;
var cv=$('scene'),g=cv.getContext?cv.getContext('2d'):null,panel=$('panel'),form=$('loginForm'),msg=$('msg'),btn=$('signin'),skip=$('skip'),note=$('note'),chip=$('chip');
var S={phase:'approach',pt:0,x:-9,dir:1,wp:0,amp:1,raise:0,scan:0,term:'idle',door:0,zoom:1,cx:0,office:0,nav:null,fade:0},sceneOn=!!g,t0=performance.now();
var MSG={invalid:'Invalid username or password.',1:'Invalid username or password.',username_exists:'That username is already in use.',email_exists:'That email address is already registered.',admin_login_route:'Administrator accounts must sign in from the separate /admin panel.',ems_link_missing:'Your TeamConnect account is not linked to an employee profile yet.'};
function status(t,deny){$('statusTxt').textContent=t;chip.classList.toggle('deny',!!deny)}
function showMsg(t,err){msg.hidden=false;msg.textContent=t;msg.className='msg'+(err?' error':'')}
function showForm(){panel.classList.remove('intro-hidden');note.classList.add('on');skip.textContent='Skip intro';skip.hidden=true;status('Scanner ready · visual only');setTimeout(function(){if(!form.username.value)form.username.focus({preventScroll:true})},800)}
/* password toggle */
$('eye').addEventListener('click',function(){var p=form.password,s=p.type==='password';p.type=s?'text':'password';this.textContent=s?'Hide':'Show';this.setAttribute('aria-pressed',s);this.setAttribute('aria-label',s?'Hide password':'Show password')});
/* real authentication: the existing /login endpoint decides everything */
function loading(on){btn.disabled=on;btn.classList.toggle('load',on);$('goTxt').textContent=on?'Verifying…':'Sign in'}
function go(url){location.assign(url)}
function granted(url){
 status('Access granted');S.nav=url;
 if(!sceneOn||reduce){setTimeout(function(){go(url)},500);return}
 panel.classList.add('intro-hidden');skip.hidden=false;skip.textContent='Skip';S.phase='granted';S.pt=performance.now();S.term='granted'}
function denied(code){
 loading(false);showMsg(MSG[code]||'The request could not be completed. Please try again.',true);status('Not verified',true);S.term='denied';S.dtime=performance.now();
 form.password.value='';form.password.focus()}
form.addEventListener('submit',function(e){
 e.preventDefault();if(!form.reportValidity())return;
 loading(true);msg.hidden=true;status('Verifying credentials…');S.term='verify';
 var started=Date.now(),body=new URLSearchParams(new FormData(form));
 fetch(form.action,{method:'POST',body:body,credentials:'same-origin',redirect:'follow',headers:{'Content-Type':'application/x-www-form-urlencoded'}}).then(function(r){
  var u=new URL(r.url,location.href),err=u.searchParams.get('error'),wait=Math.max(0,900-(Date.now()-started));
  setTimeout(function(){if(err)denied(err);else if(r.redirected)granted(r.url);else form.submit()},wait)
 }).catch(function(){form.submit()})});
skip.addEventListener('click',function(){
 if(S.nav){go(S.nav);return}
 if(S.phase==='approach'||S.phase==='scan'){S.x=3.62;S.raise=0;S.amp=0;S.phase='form';S.term='ready';showForm()}});

/* ===== Cinematic entrance (2D canvas, no libraries) ===== */
if(!sceneOn){document.body.classList.add('noscene');showForm();return}
var W,H,u,gy,ox,small,dpr,sky,seed=5,TX=4.2,PADX=4.07,STOP=3.62;
function rnd(){seed=(seed*16807)%2147483647;return seed/2147483647}
function ease(x){return x<.5?4*x*x*x:1-Math.pow(-2*x+2,3)/2}
function X(m){return ox+m*u}function Y(m){return gy-m*u}
function buildSky(){sky=document.createElement('canvas');sky.width=Math.ceil(W*1.5);sky.height=Math.ceil(gy);var c=sky.getContext('2d');seed=5;if('filter' in c)c.filter='blur(1.3px)';var x=0;
 while(x<sky.width){var w=40+rnd()*80,h=gy*(.15+rnd()*.45);c.fillStyle='#0c1830';c.fillRect(x,gy-h,w,h);for(var y=gy-h+8;y<gy-6;y+=11)for(var xx=x+6;xx<x+w-8;xx+=10)if(rnd()>.62){c.fillStyle=rnd()>.7?'#F5F7FA':'#D9A86C';c.globalAlpha=.25+rnd()*.5;c.fillRect(xx,y,4,5)}c.globalAlpha=1;x+=w+rnd()*10}}
function rs(){small=innerWidth<900;dpr=Math.min(devicePixelRatio||1,small?1.5:2);W=innerWidth;H=innerHeight;cv.width=W*dpr;cv.height=H*dpr;g.setTransform(dpr,0,0,dpr,0,0);u=small?Math.min(W/9,H*.075):Math.min(H/7.5,W/17);gy=small?H*.42:H*.78;ox=W*.3;buildSky()}
rs();
function hash(a,b){var x=Math.sin(a*127.1+b*311.7)*43758.5453;return x-Math.floor(x)}
function ik(sx,sy,tx,ty,l1,l2,bend){var dx=tx-sx,dy=ty-sy,d=Math.max(.05,Math.min(Math.hypot(dx,dy),l1+l2-.002)),a=Math.atan2(dy,dx),c=(l1*l1+d*d-l2*l2)/(2*l1*d),th=Math.acos(Math.max(-1,Math.min(1,c)))*bend;return{ex:sx+Math.cos(a+th)*l1,ey:sy+Math.sin(a+th)*l1,hx:sx+Math.cos(a)*d,hy:sy+Math.sin(a)*d}}
function seg(x1,y1,x2,y2,w,col){g.strokeStyle=col;g.lineWidth=w*u;g.lineCap='round';g.beginPath();g.moveTo(X(x1),Y(y1));g.lineTo(X(x2),Y(y2));g.stroke()}
function glow(x,y,r,rgb,a){var q=g.createRadialGradient(x,y,0,x,y,r);q.addColorStop(0,'rgba('+rgb+','+a+')');q.addColorStop(1,'rgba('+rgb+',0)');g.fillStyle=q;g.fillRect(x-r,y-r,r*2,r*2)}
function man(x,d,al){
 var A=S.amp,hipY=.95+Math.abs(Math.cos(S.wp))*.012*A,shY=hipY+.52;g.globalAlpha=al;
 function leg(ph,col){var sn=Math.sin(S.wp+ph),cs=Math.cos(S.wp+ph),fx=x+d*sn*.3*A,fy=.08+Math.max(0,cs)*.13*A,k=ik(x,hipY,fx,fy,.47,.47,d);seg(x,hipY,k.ex,k.ey,.15,col);seg(k.ex,k.ey,k.hx,k.hy,.105,col);g.fillStyle='#07090f';g.beginPath();g.ellipse(X(k.hx+d*.07),Y(.045),.13*u,.05*u,0,0,6.283);g.fill()}
 function arm(ph,col,rz){var sn=Math.sin(S.wp+ph),tx=x+d*sn*.22*A,ty=shY-.6+Math.abs(sn)*.03*A;if(rz>0){tx+=(PADX-x-d*sn*.22*A)*rz;ty+=(1.12-ty)*rz}
  var k=ik(x,shY-.03,tx,ty,.32,.3,-d);seg(x,shY-.03,k.ex,k.ey,.095,col);seg(k.ex,k.ey,k.hx,k.hy,.08,col);
  g.fillStyle='#c79776';g.beginPath();g.arc(X(k.hx),Y(k.hy),.045*u,0,6.283);g.fill();if(rz>.5){seg(k.hx,k.hy,k.hx+d*.07,k.hy+.005,.025,'#c79776')}}
 leg(Math.PI,'#0f1730');arm(0,'#141d36',0);
 var tg=g.createLinearGradient(X(x-.2),0,X(x+.2),0);tg.addColorStop(0,'#26365a');tg.addColorStop(1,'#121a30');
 g.fillStyle=tg;g.strokeStyle='#18233f';g.lineWidth=.05*u;g.lineJoin='round';g.beginPath();g.moveTo(X(x-.17),Y(shY));g.lineTo(X(x+.17),Y(shY));g.lineTo(X(x+.15),Y(hipY-.08));g.lineTo(X(x-.15),Y(hipY-.08));g.closePath();g.fill();g.stroke();
 g.fillStyle='#F5F7FA';g.beginPath();g.moveTo(X(x+d*.01),Y(shY));g.lineTo(X(x+d*.11),Y(shY));g.lineTo(X(x+d*.06),Y(shY-.22));g.closePath();g.fill();
 seg(x+d*.06,shY-.02,x+d*.06,shY-.3,.03,'#14243D');
 leg(0,'#16203a');
 seg(x,shY,x+d*.01,shY+.1,.09,'#b98563');
 var hg=g.createLinearGradient(X(x-.1),0,X(x+.1),0);hg.addColorStop(0,d>0?'#b98563':'#dba982');hg.addColorStop(1,d>0?'#dba982':'#b98563');
 g.fillStyle=hg;g.beginPath();g.ellipse(X(x+d*.025),Y(shY+.2),.095*u,.12*u,0,0,6.283);g.fill();
 g.fillStyle='#16110e';g.beginPath();g.ellipse(X(x+d*.0),Y(shY+.27),.1*u,.07*u,0,Math.PI,6.283);g.fill();g.fillRect(X(x-d*.095)-(d>0?0:-0),Y(shY+.27),.04*u*d*-1,.1*u);
 g.fillStyle='#0b0f1a';g.beginPath();g.arc(X(x+d*.075),Y(shY+.21),.009*u,0,6.283);g.fill();
 arm(Math.PI,'#1c2a49',S.raise);
 g.globalAlpha=1}
function terminal(t){
 var x=X(TX),y=Y(1.5),w=.5*u,h=.62*u;
 var pg=g.createLinearGradient(x-.13*u,0,x+.2*u,0);pg.addColorStop(0,'#3a4558');pg.addColorStop(1,'#10182a');g.fillStyle=pg;g.fillRect(x-.12*u,Y(1.0),.24*u,1.0*u);
 g.fillStyle='#1b2438';g.beginPath();g.moveTo(x-.3*u,y);g.lineTo(x+.22*u,y-.06*u);g.lineTo(x+.22*u,y+h);g.lineTo(x-.3*u,y+h+.04*u);g.closePath();g.fill();
 g.strokeStyle='rgba(183,196,216,.5)';g.lineWidth=1;g.stroke();
 var sx=x-.27*u,sy=y+.03*u,sw=.46*u,sh=.5*u,tm=S.term,c=g.createLinearGradient(0,sy,0,sy+sh);c.addColorStop(0,'#0e2040');c.addColorStop(1,'#07101f');g.fillStyle=c;g.fillRect(sx,sy,sw,sh);
 var col=tm==='denied'?'217,168,108':'57,139,255';glow(sx+sw/2,sy+sh/2,sw*1.6,col,tm==='idle'?.12:.3);
 var cx=sx+sw/2,cy=sy+sh*.42,r=sw*.28,pr=tm==='scan'?S.scan:tm==='verify'?(t*.9)%1:tm==='ready'||tm==='granted'?1:0;
 g.strokeStyle='rgba('+col+','+(tm==='idle'?.5:.95)+')';g.lineWidth=Math.max(1,u*.012);
 if(tm==='granted'){g.strokeStyle='#F5F7FA';g.lineWidth=Math.max(2,u*.03);g.lineCap='round';g.beginPath();g.moveTo(cx-r*.7,cy);g.lineTo(cx-r*.15,cy+r*.55);g.lineTo(cx+r*.8,cy-r*.55);g.stroke()}
 else if(tm==='denied'){g.lineWidth=Math.max(2,u*.03);g.beginPath();g.moveTo(cx-r*.5,cy-r*.5);g.lineTo(cx+r*.5,cy+r*.5);g.moveTo(cx+r*.5,cy-r*.5);g.lineTo(cx-r*.5,cy+r*.5);g.stroke()}
 else{for(var k=1;k<=5;k++){g.beginPath();g.ellipse(cx,cy,r*k/5*.85,r*k/5,0,Math.PI*1.1,Math.PI*2.1);g.stroke()}
  if(tm==='scan'||tm==='verify'){var ly=cy-r+((t*1.4)%1)*r*2;g.fillStyle='rgba(57,139,255,.85)';g.shadowColor='#398BFF';g.shadowBlur=8;g.fillRect(cx-r,ly,r*2,Math.max(1,u*.01));g.shadowBlur=0}}
 g.fillStyle='rgba(183,196,216,.2)';g.fillRect(sx+sw*.12,sy+sh*.82,sw*.76,Math.max(2,u*.022));g.fillStyle=tm==='denied'?'#D9A86C':'#398BFF';g.fillRect(sx+sw*.12,sy+sh*.82,sw*.76*pr,Math.max(2,u*.022));
 g.fillStyle='rgba(245,247,250,.8)';g.font=Math.max(6,u*.05)+'px sans-serif';g.textAlign='center';
 g.fillText(tm==='granted'?'ACCESS GRANTED':tm==='denied'?'NOT VERIFIED':tm==='verify'?'VERIFYING':tm==='scan'?'SCANNING':tm==='ready'?'SCAN COMPLETE':'PLACE FINGER',cx,sy+sh*.74);
 /* scanner pad */
 var pad=g.createRadialGradient(X(PADX),Y(1.12),0,X(PADX),Y(1.12),.07*u);pad.addColorStop(0,tm==='scan'?'#8fc0ff':'#1d3558');pad.addColorStop(1,'#0b1424');g.fillStyle=pad;g.beginPath();g.ellipse(X(PADX),Y(1.12),.05*u,.06*u,0,0,6.283);g.fill();if(tm==='scan')glow(X(PADX),Y(1.12),.45*u,'57,139,255',.55)}
function facade(){
 var x0=X(-40),w=56*u,h=16*u,top=Y(16),f=g.createLinearGradient(0,top,0,gy);f.addColorStop(0,'#254b82');f.addColorStop(.45,'#10213f');f.addColorStop(1,'#0a1426');g.fillStyle=f;g.fillRect(x0,top,w,h);
 /* lit floors */
 for(var fl=0;fl<4;fl++){var y1=5.4+fl*3.3;for(var r=0;r<12;r++){var rx=-40+r*4.7,k=hash(fl,r);if(k>.35){var px=X(rx);if(px>W+50||px+4.4*u<-50)continue;var lg=g.createLinearGradient(0,Y(y1+2.8),0,Y(y1));lg.addColorStop(0,k>.7?'rgba(245,247,250,.55)':'rgba(217,168,108,.55)');lg.addColorStop(1,'rgba(217,168,108,.15)');g.fillStyle=lg;g.fillRect(px+.15*u,Y(y1+2.8),4.4*u,2.7*u);
  g.fillStyle='rgba(8,13,24,.55)';g.fillRect(px+.5*u,Y(y1+.8),1.3*u,.06*u);g.fillRect(px+2.4*u,Y(y1+.8),1.3*u,.06*u);g.fillStyle='rgba(57,139,255,.7)';g.fillRect(px+.9*u,Y(y1+1.1),.4*u,.28*u);g.fillRect(px+2.8*u,Y(y1+1.1),.4*u,.28*u);
  g.fillStyle='rgba(8,13,24,.7)';g.beginPath();g.arc(px+1.1*u,Y(y1+1.35),.12*u,0,6.283);g.arc(px+3*u,Y(y1+1.35),.12*u,0,6.283);g.fill()}}}
 /* lobby */
 var lb=g.createLinearGradient(0,Y(5),0,gy);lb.addColorStop(0,'#6b4a26');lb.addColorStop(1,'#e8c48c');g.fillStyle=lb;g.globalAlpha=.9;g.fillRect(x0,Y(5),w,5*u);g.globalAlpha=1;
 g.fillStyle='rgba(8,13,24,.6)';g.fillRect(X(-18),Y(1.1),5*u,1.1*u);for(var p=0;p<4;p++){var px2=-9-p*2.3;g.fillStyle='rgba(8,13,24,.55)';g.beginPath();g.arc(X(px2),Y(1.62),.1*u,0,6.283);g.fill();g.fillRect(X(px2)-.16*u,Y(1.5),.32*u,1.5*u)}
 g.fillStyle='rgba(255,236,200,.9)';for(var d=-30;d<14;d+=3){g.beginPath();g.arc(X(d),Y(4.8),.06*u,0,6.283);g.fill()}
 /* glass overlay + mullions */
 var sh=g.createLinearGradient(x0,top,x0+w*.5,gy);sh.addColorStop(0,'rgba(57,139,255,.2)');sh.addColorStop(.6,'rgba(57,139,255,0)');g.fillStyle=sh;g.fillRect(x0,top,w,h);
 g.strokeStyle='rgba(183,196,216,.2)';g.lineWidth=1;g.beginPath();for(var m=-40;m<=16;m+=1.6){g.moveTo(X(m),top);g.lineTo(X(m),gy)}for(var s=5;s<16;s+=3.3){g.moveTo(x0,Y(s));g.lineTo(x0+w,Y(s))}g.stroke();
 /* entrance door */
 g.fillStyle='#e9c995';var dg=g.createLinearGradient(0,Y(3.2),0,gy);dg.addColorStop(0,'#8a6234');dg.addColorStop(1,'#ffe6b8');g.fillStyle=dg;g.fillRect(X(-1.7),Y(3.3),3.4*u,3.3*u);
 var o=S.door*1.6;[[-1.6-o,-0],[0+o,0]].forEach(function(a,i){var px=X(i?o:-1.6-o);g.fillStyle='rgba(183,196,216,.2)';g.fillRect(px,Y(3.2),1.6*u,3.2*u);g.strokeStyle='rgba(245,247,250,.6)';g.lineWidth=1.2;g.strokeRect(px,Y(3.2),1.6*u,3.2*u)});
 g.strokeStyle='#B7C4D8';g.lineWidth=.08*u;g.strokeRect(X(-1.7),Y(3.3),3.4*u,3.3*u);
 g.fillStyle='#1a2338';g.fillRect(X(-4.5),Y(3.65),9*u,.3*u);g.fillStyle='#F2C98F';g.shadowColor='#D9A86C';g.shadowBlur=22;g.fillRect(X(-4.4),Y(3.4),8.8*u,.06*u);g.shadowBlur=0;
 /* security checkpoint */
 var cx=X(-6.6);g.fillStyle='#10192d';g.fillRect(cx-.9*u,Y(1.05),1.8*u,1.05*u);g.fillStyle='#B7C4D8';g.fillRect(cx-.95*u,Y(1.08),1.9*u,.06*u);
 g.fillStyle='#0b1220';g.beginPath();g.arc(cx,Y(1.62),.1*u,0,6.283);g.fill();g.fillRect(cx-.17*u,Y(1.52),.34*u,.5*u);glow(cx+.55*u,Y(1.2),.5*u,'217,168,108',.5)}
function office(a,t){
 g.globalAlpha=a;var f=g.createLinearGradient(0,0,0,H);f.addColorStop(0,'#10213d');f.addColorStop(.55,'#0b172b');f.addColorStop(1,'#050a14');g.fillStyle=f;g.fillRect(0,0,W,H);
 var wy=H*.12,wh=H*.34;g.drawImage(sky,0,sky.height*.45,W,sky.height*.55,0,wy,W,wh);g.fillStyle='rgba(20,36,61,.5)';g.fillRect(0,wy,W,wh);
 g.strokeStyle='rgba(183,196,216,.25)';for(var m=0;m<W;m+=W/8){g.beginPath();g.moveTo(m,wy);g.lineTo(m,wy+wh);g.stroke()}
 for(var l=0;l<7;l++){var lx=W*(l+.5)/7;g.fillStyle='rgba(245,247,250,.9)';g.shadowColor='#F5F7FA';g.shadowBlur=18;g.fillRect(lx-W*.04,H*.07,W*.08,4);g.shadowBlur=0}
 var fy=H*.62,fl=g.createLinearGradient(0,fy,0,H);fl.addColorStop(0,'#1a2c49');fl.addColorStop(1,'#060b15');g.fillStyle=fl;g.fillRect(0,fy,W,H-fy);
 for(var row=0;row<3;row++){var sc=.55+row*.3,by=fy+row*H*.1+H*.02,dw=W*.16*sc,n=Math.ceil(W/(dw*1.5))+1;for(var i=0;i<n;i++){var dx=i*dw*1.5+(row%2)*dw*.6;g.fillStyle='#0c1424';g.fillRect(dx,by-H*.04*sc,dw,H*.04*sc);g.fillStyle='#1a2640';g.fillRect(dx,by,dw,H*.012*sc);
  g.fillStyle='#0a0f1a';g.fillRect(dx+dw*.3,by-H*.1*sc,dw*.4,H*.06*sc);g.fillStyle=hash(row,i)>.5?'rgba(57,139,255,.75)':'rgba(183,196,216,.7)';g.fillRect(dx+dw*.33,by-H*.095*sc,dw*.34,H*.05*sc);glow(dx+dw*.5,by-H*.07*sc,dw*.7,'57,139,255',.18);
  if(hash(i,row+3)>.3){var px=dx+dw*.5,py=by-H*.13*sc,hs=H*.012*sc*2.4;g.fillStyle='#0b0f1a';g.beginPath();g.arc(px,py,hs*.6,0,6.283);g.fill();g.fillRect(px-hs,py+hs*.6,hs*2,hs*2.4)}}}
 var mx=W*.66,my=H*.22,mw=W*.3,mh=H*.34;g.strokeStyle='rgba(183,196,216,.55)';g.lineWidth=2;g.strokeRect(mx,my,mw,mh);g.fillStyle='rgba(183,196,216,.07)';g.fillRect(mx,my,mw,mh);g.fillStyle='#1d2a44';g.fillRect(mx+mw*.15,my+mh*.7,mw*.7,mh*.08);for(var q=0;q<4;q++){g.fillStyle='#0b0f1a';var qx=mx+mw*(.2+q*.2);g.beginPath();g.arc(qx,my+mh*.52,mh*.06,0,6.283);g.fill();g.fillRect(qx-mh*.08,my+mh*.58,mh*.16,mh*.12)}
 glow(mx+mw/2,my+mh*.1,mw*.5,'217,168,108',.3);g.globalAlpha=1}
var raf,run=true,last=performance.now();
function frame(now){
 var dt=Math.min((now-last)/1000,.05);last=now;var t=(now-t0)/1000;
 /* ---- state machine ---- */
 if(S.phase==='approach'){if(t>.8){S.x+=1.9*dt;S.wp+=dt*7.4}if(S.x>=STOP){S.x=STOP;S.amp=0;S.phase='scan';S.pt=now}}
 else if(S.phase==='scan'){var s=(now-S.pt)/1000;S.raise=ease(Math.min(s/.9,1));if(s>1.1){S.term='scan';S.scan=Math.min((s-1.1)/2.2,1)}if(s>3.5){S.term='ready';S.phase='form';S.pt=now;showForm()}}
 else if(S.phase==='form'){var s2=(now-S.pt)/1000;S.raise=Math.max(0,S.raise-dt*1.2);if(S.term==='denied'&&S.dtime&&now-S.dtime>2200){S.term='ready'}}
 else if(S.phase==='granted'){var s3=(now-S.pt)/1000;S.raise=Math.max(0,S.raise-dt*1.5);S.door=ease(Math.min(Math.max((s3-.6)/1.4,0),1));
  if(s3>1.2){S.dir=-1;S.amp=1;S.x-=1.5*dt;S.wp+=dt*6.2}
  if(s3>1.6)S.zoom=1+ease(Math.min((s3-1.6)/2.6,1))*.9;
  if(s3>4.2){S.phase='office';S.pt=now}}
 else if(S.phase==='office'){var s4=(now-S.pt)/1000;S.office=Math.min(s4/1.1,1);if(s4>2.8&&S.nav){S.phase='done';go(S.nav)}}
 if(S.phase==='scan'||S.phase==='form'||S.phase==='granted'){if(S.phase!=='granted'){S.amp=0}}
 var camX=S.phase==='granted'||S.phase==='office'?Math.max(S.x*.5,-1)*1:(S.x-1.5)*.3;S.cx+=(camX-S.cx)*Math.min(dt*2,1);
 /* ---- draw ---- */
 var sk=g.createLinearGradient(0,0,0,gy);sk.addColorStop(0,'#05080f');sk.addColorStop(.6,'#0d1a33');sk.addColorStop(1,'#1c355a');g.fillStyle=sk;g.fillRect(0,0,W,H);
 for(var i=0;i<70;i++){var sx=hash(i,1)*W,sy=hash(i,2)*gy*.6;g.fillStyle='#F5F7FA';g.globalAlpha=.2+.5*Math.abs(Math.sin(t*.7+i));g.fillRect(sx,sy,1.2,1.2)}g.globalAlpha=1;
 g.drawImage(sky,-W*.1-S.cx*u*.15,0,sky.width,sky.height);
 g.save();g.translate(ox,gy-3*u);g.scale(S.zoom,S.zoom);g.translate(-ox-S.cx*u*.5*(S.zoom>1?1:.0)-(S.zoom===1?-S.cx*u*0:0),-(gy-3*u));g.translate(-S.cx*u*.4,0);
 facade();
 var fgr=g.createLinearGradient(0,gy,0,H);fgr.addColorStop(0,'#162843');fgr.addColorStop(.3,'#0a1425');fgr.addColorStop(1,'#04070d');g.fillStyle=fgr;g.fillRect(X(-60),gy,200*u,H-gy+200);
 g.strokeStyle='rgba(183,196,216,.07)';g.lineWidth=1;for(var k=1;k<9;k++){var yy=gy+Math.pow(k,1.6)*.045*u*1.6;g.beginPath();g.moveTo(X(-60),yy);g.lineTo(X(60),yy);g.stroke()}
 var rg=g.createLinearGradient(0,gy,0,gy+5*u);rg.addColorStop(0,'rgba(240,200,140,.45)');rg.addColorStop(1,'rgba(240,200,140,0)');g.fillStyle=rg;g.fillRect(X(-3),gy,6*u,5*u);
 var rg2=g.createLinearGradient(0,gy,0,gy+3*u);rg2.addColorStop(0,'rgba(57,139,255,.35)');rg2.addColorStop(1,'rgba(57,139,255,0)');g.fillStyle=rg2;g.fillRect(X(TX)-.6*u,gy,1.2*u,3*u);
 terminal(t);
 var al=S.phase==='granted'||S.phase==='office'?Math.max(0,Math.min(1,(S.x+4.5)/2.3)):1;
 if(al>0){g.save();g.translate(0,2*gy);g.scale(1,-1);man(S.x,S.dir,.14*al);g.restore();
  var bw=Math.sin(t*1.6)*.004;man(S.x,S.dir,al)}
 glow(X(0),Y(1.5),5*u,'240,200,140',.12);
 g.restore();
 if(S.office>0)office(S.office,t);
 /* letterbox, vignette, fade-in */
 var vg=g.createRadialGradient(W/2,H/2,Math.min(W,H)*.35,W/2,H/2,Math.max(W,H)*.75);vg.addColorStop(0,'rgba(0,0,0,0)');vg.addColorStop(1,'rgba(2,4,9,.6)');g.fillStyle=vg;g.fillRect(0,0,W,H);
 if(!small){g.fillStyle='#000';g.fillRect(0,0,W,H*.045);g.fillRect(0,H*.955,W,H*.045)}
 if(!reduce&&t<2){g.globalAlpha=1-t/2;g.fillStyle='#000';g.fillRect(0,0,W,H);g.globalAlpha=1}
 if(run&&!reduce)raf=requestAnimationFrame(frame)}
if(reduce){S.x=STOP;S.amp=0;S.phase='form';S.term='ready';showForm();frame(performance.now()+3000);addEventListener('resize',function(){rs();frame(performance.now()+3000)})}
else{skip.hidden=false;raf=requestAnimationFrame(frame);addEventListener('resize',rs);
 document.addEventListener('visibilitychange',function(){if(document.hidden){run=false;cancelAnimationFrame(raf)}else{run=true;last=performance.now();raf=requestAnimationFrame(frame)}});
 addEventListener('pagehide',function(){run=false;cancelAnimationFrame(raf)})}
})();
</script>
</body>
</html>
