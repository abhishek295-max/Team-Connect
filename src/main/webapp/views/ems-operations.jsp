<%@ page contentType="text/html;charset=UTF-8" %><%
String role=String.valueOf(request.getAttribute("emsRole")).toUpperCase(java.util.Locale.ROOT);
String ctx=request.getContextPath();
boolean admin="ADMIN".equals(role);
%>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Workforce operations · TeamConnect</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap">
<style>
:root{--white:#fff;--cloud:#f3f5f8;--silver:#dce2eb;--blue:#2455d6;--deep:#142b55;--slate:#66758d;--text:#18243a;--ok:#198754;--warn:#d99b32;--err:#d9534f;--line:#dce2eb;--muted:#66758d;--card:#fff;--side:248px;--r:14px;font:14px/1.5 Inter,system-ui,-apple-system,"Segoe UI",sans-serif;color:var(--text);background:var(--cloud)}
*{box-sizing:border-box}body{margin:0;background:radial-gradient(900px 400px at 85% -5%,#dfe8fb,transparent),var(--cloud)}
a{color:inherit}.muted{color:var(--muted)}
/* sidebar */
.side{position:fixed;inset:0 auto 0 0;width:var(--side);background:linear-gradient(180deg,#fff,#eef1f6);border-right:1px solid var(--line);padding:18px 12px;z-index:30;display:flex;flex-direction:column;gap:4px;transition:width .3s,transform .3s;overflow:auto}
.logo{display:flex;align-items:center;gap:10px;padding:4px 8px 16px;font-weight:800;letter-spacing:.5px;color:var(--deep)}
.logo i{display:grid;place-items:center;width:34px;height:34px;border-radius:10px;background:linear-gradient(135deg,var(--blue),#5c8bf0);color:#fff;box-shadow:0 6px 14px #2455d655;flex:none}
.side a.l{display:flex;align-items:center;gap:12px;padding:10px 12px;border-radius:10px;text-decoration:none;color:#33455e;white-space:nowrap;position:relative;transition:background .2s,color .2s,transform .2s}
.side a.l i{width:20px;text-align:center;transition:transform .25s}.side a.l:hover{background:#e6edfb;color:var(--blue)}.side a.l:hover i{transform:scale(1.2)}
.side a.l.on{background:linear-gradient(90deg,#dfe8fb,#eef3fd);color:var(--blue);font-weight:600}.side a.l.on:before{content:"";position:absolute;left:-12px;top:8px;bottom:8px;width:4px;border-radius:0 4px 4px 0;background:var(--blue)}
.side .out{margin-top:auto}body.collapsed{--side:72px}body.collapsed .side span{display:none}body.collapsed .side a.l{justify-content:center}
body.collapsed .side a.l:hover:after{content:attr(data-tip);position:absolute;left:62px;background:var(--deep);color:#fff;padding:4px 9px;border-radius:6px;font-size:12px}
.wrap{margin-left:var(--side);transition:margin .3s}
.top{position:sticky;top:0;z-index:20;display:flex;gap:12px;align-items:center;padding:12px 3vw;background:#ffffffd9;backdrop-filter:blur(12px);border-bottom:1px solid var(--line)}
.top h1{font-size:17px;margin:0;line-height:1.2}.top small{color:var(--muted)}.sp{flex:1}
.btn,.top a.b{border:1px solid var(--line);border-radius:9px;padding:8px 12px;background:#fff;color:#203047;text-decoration:none;cursor:pointer;font:inherit;transition:transform .15s,box-shadow .15s,background .2s}
.btn:hover,.top a.b:hover{transform:translateY(-1px);box-shadow:0 6px 14px #1f3a6a1a}.btn.primary,.top a.primary{background:var(--blue);color:#fff;border-color:var(--blue)}.top a.primary{padding:8px 12px;border-radius:9px;text-decoration:none}
.gs{max-width:260px;width:100%;border:1px solid var(--line);border-radius:9px;padding:8px 12px;font:inherit;background:#fff}
.burger{display:inline-grid;place-items:center;width:38px;height:36px}
main{max-width:1500px;margin:auto;padding:22px 3vw 60px}
.hero{position:relative;overflow:hidden;padding:34px;border-radius:20px;color:#fff;background:linear-gradient(115deg,rgba(20,43,85,.96),rgba(36,85,214,.88)),repeating-linear-gradient(45deg,#fff1 0 2px,transparent 2px 22px),#142b55;box-shadow:0 20px 50px #142b5535}
.hero:after{content:"";position:absolute;right:-60px;top:-80px;width:320px;height:320px;border-radius:50%;background:radial-gradient(circle,#ffffff40,transparent 70%);animation:drift 9s ease-in-out infinite alternate}
@keyframes drift{to{transform:translate(-40px,30px)}}
.hero h2{margin:0 0 6px;font-size:28px;font-weight:800;animation:up .7s both}.hero p{margin:0;color:#dbe7ff;max-width:620px;animation:up .7s .12s both}.hero .date{font-size:12px;letter-spacing:.8px;text-transform:uppercase;color:#bcd1ff;margin-bottom:8px}
.hero .qa{display:flex;gap:10px;flex-wrap:wrap;margin-top:18px;animation:up .7s .24s both}.hero .qa a{padding:9px 14px;border-radius:10px;background:#ffffff22;border:1px solid #ffffff45;color:#fff;text-decoration:none;transition:.2s}.hero .qa a:hover{background:#fff;color:var(--deep)}
@keyframes up{from{opacity:0;transform:translateY(14px)}}
.stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:14px;margin:18px 0;perspective:900px}
.card{background:var(--card);border:1px solid var(--line);border-radius:var(--r);padding:18px;box-shadow:0 8px 24px #1f3a6a0d;transition:transform .25s,box-shadow .25s}
.stat{display:flex;gap:14px;align-items:center;animation:up .6s both}.stat:hover{transform:translateY(-4px) rotateX(4deg);box-shadow:0 16px 30px #1f3a6a22}
.stat .ic{width:46px;height:46px;border-radius:12px;display:grid;place-items:center;color:#fff;background:linear-gradient(135deg,var(--blue),#6c97f5);box-shadow:0 8px 16px #2455d640;flex:none}
.stat strong{display:block;font-size:26px;line-height:1.1;font-weight:800;color:var(--deep)}.stat span{color:var(--muted);font-size:13px}
.stat:nth-child(2){animation-delay:.05s}.stat:nth-child(3){animation-delay:.1s}.stat:nth-child(4){animation-delay:.15s}.stat:nth-child(5){animation-delay:.2s}.stat:nth-child(6){animation-delay:.25s}
.section{scroll-margin-top:80px;margin-top:20px}.section h2{font-size:18px;margin:0 0 12px;color:var(--deep)}.section h3{font-size:15px;margin:14px 0 8px}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(380px,1fr));gap:16px}
.form{display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:10px;align-items:end;margin-bottom:6px}.form label{display:grid;gap:5px;font-weight:600;font-size:12px;color:#33455e}
.form input,.form select,.form textarea{width:100%;border:1px solid var(--line);border-radius:9px;padding:9px;font:inherit;background:#fff;color:var(--text);transition:border .2s,box-shadow .2s}
.form input:focus,.form select:focus,.form textarea:focus,.gs:focus{outline:0;border-color:var(--blue);box-shadow:0 0 0 3px #2455d626}.form textarea{min-height:40px}.form .wide{grid-column:1/-1}
.table-wrap{overflow:auto;margin-top:12px;border-radius:10px}table{width:100%;border-collapse:collapse;min-width:620px}th,td{text-align:left;padding:10px;border-bottom:1px solid var(--line)}th{font-size:12px;color:var(--muted);background:#f7f9fc;position:sticky;top:0}tbody tr{transition:background .15s}tbody tr:hover{background:#f3f7ff}td .btn{padding:5px 8px;font-size:12px}
.badge{display:inline-block;padding:3px 9px;border-radius:20px;background:#e8effd;color:#2455d6;font-size:11px;font-weight:600}.actions{display:flex;gap:6px;flex-wrap:wrap}.danger{color:var(--err)!important}.note{font-size:12px;color:var(--muted);margin:7px 0}
.avatar{display:inline-grid;place-items:center;width:28px;height:28px;border-radius:50%;background:linear-gradient(135deg,var(--blue),#7ba2f7);color:#fff;font-size:11px;font-weight:700;margin-right:8px;vertical-align:middle}
.toast{position:fixed;right:20px;bottom:20px;background:var(--deep);color:#fff;padding:12px 16px;border-radius:10px;z-index:50;opacity:0;transform:translateY(12px);pointer-events:none;transition:.3s}.toast.show{opacity:1;transform:none}
/* 3D HQ */
.hq{display:grid;grid-template-columns:minmax(300px,1.1fr) 1fr;gap:18px;align-items:center}
.stage{height:420px;perspective:1300px;display:grid;place-items:center;border-radius:12px;background:radial-gradient(ellipse at 50% 85%,#dfe8fb,transparent 65%),linear-gradient(#f9fbff,#eef2f8);cursor:grab;touch-action:none;user-select:none;overflow:hidden}.stage:active{cursor:grabbing}
.bld{position:relative;width:190px;height:0;transform-style:preserve-3d;transform:scale(var(--z,1)) rotateX(-18deg) rotateY(var(--ry,-30deg));transition:transform .15s}
.fl{position:absolute;left:-95px;width:190px;height:44px;transform-style:preserve-3d;cursor:pointer}
.fl div{position:absolute;width:190px;height:44px;border:1px solid #fff9;background:repeating-linear-gradient(90deg,#cfe0ff88 0 14px,#fff6 14px 18px),linear-gradient(135deg,#e4ecf8,#aebcd2);display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;color:var(--deep);backface-visibility:hidden;transition:background .25s}
.fl .f{transform:translateZ(95px)}.fl .k{transform:rotateY(180deg) translateZ(95px)}.fl .r{transform:rotateY(90deg) translateZ(95px)}.fl .lf{transform:rotateY(-90deg) translateZ(95px)}
.fl:hover div,.fl.sel div{background:repeating-linear-gradient(90deg,#fff5 0 14px,#fff3 14px 18px),linear-gradient(135deg,#5c8bf0,var(--blue));color:#fff}
.roof{position:absolute;left:-95px;width:190px;height:190px;background:linear-gradient(135deg,#c3cddd,#8e9db6);transform:rotateX(90deg);transform-origin:top}
.ctl{display:flex;gap:8px;margin-top:10px}.ctl .btn{width:38px;padding:7px 0;text-align:center}
.info h3{margin:0 0 4px;font-size:20px;color:var(--deep)}.mini{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin:14px 0}.mini div{padding:12px;border-radius:10px;background:var(--cloud);text-align:center}.mini b{display:block;font-size:22px;color:var(--blue)}
.bar{display:grid;grid-template-columns:130px 1fr 40px;gap:10px;align-items:center;margin:7px 0;font-size:13px}.bar i{display:block;height:10px;border-radius:6px;background:linear-gradient(90deg,var(--blue),#7ba2f7);width:0;transition:width .9s cubic-bezier(.2,.8,.2,1)}.bar .tr{background:#edf1f7;border-radius:6px;overflow:hidden}
.dots{display:flex;flex-wrap:wrap;gap:6px;margin-top:10px}.dots span{width:12px;height:12px;border-radius:50%;background:var(--blue);box-shadow:0 2px 4px #2455d644;animation:pop .4s both}.dots span.off{background:var(--silver);box-shadow:none}@keyframes pop{from{transform:scale(0)}}
.report-dashboard{display:grid;grid-template-columns:minmax(0,1.35fr) minmax(280px,.65fr);align-items:start;gap:16px}
.report-overview{grid-row:span 2}
.report-heading,.report-chart-heading{display:flex;align-items:center;justify-content:space-between;gap:12px}
.report-heading{margin-bottom:18px}
.report-heading h2{margin:0}
.report-kicker{margin:0 0 4px;color:var(--blue);font-size:10px;font-weight:800;letter-spacing:.13em;text-transform:uppercase}
.report-live{display:inline-flex;align-items:center;gap:7px;padding:7px 10px;border:1px solid #19875430;border-radius:99px;background:#1987540d;color:var(--ok);font-size:11px;font-weight:700;white-space:nowrap}
.report-live i{width:7px;height:7px;border-radius:50%;background:var(--ok);box-shadow:0 0 0 4px #19875418}
.report-metrics{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:10px}
.report-metric{min-width:0;padding:13px;border:1px solid var(--line);border-radius:12px;background:linear-gradient(145deg,#fff,var(--cloud))}
.report-metric span{display:block;color:var(--muted);font-size:11px;line-height:1.35}
.report-metric strong{display:block;margin-top:7px;color:var(--deep);font-size:20px;line-height:1.15;overflow-wrap:anywhere}
.report-chart-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px;margin-top:14px}
.report-chart-card{min-width:0;padding:16px;border:1px solid var(--line);border-radius:13px;background:linear-gradient(145deg,#fff,#f8faff)}
.report-chart-heading h3{margin:0;font-size:14px}
.report-chart-heading p,.report-description{margin:4px 0 0;color:var(--muted);font-size:11px}
.pie-layout{display:flex;align-items:center;gap:18px;min-height:180px;padding:12px 0 2px}
.pie-chart{position:relative;display:grid;place-items:center;flex:0 0 142px;width:142px;aspect-ratio:1;border-radius:50%;background:conic-gradient(var(--pie-stops));filter:drop-shadow(0 8px 14px #142b551c);animation:pieIn .7s ease-out both}
.pie-chart:before{content:"";position:absolute;inset:23%;border:1px solid var(--line);border-radius:50%;background:var(--card);box-shadow:inset 0 2px 8px #142b550b}
.pie-chart:after{content:attr(data-total) "\A" attr(data-caption);position:absolute;white-space:pre;text-align:center;color:var(--deep);font-size:20px;font-weight:800;line-height:1.2}
.pie-legend{display:grid;gap:9px;min-width:0;flex:1}
.pie-legend-item{display:grid;grid-template-columns:10px minmax(0,1fr) auto;align-items:center;gap:8px;font-size:11px}
.pie-legend-item i{width:9px;height:9px;border-radius:3px;background:var(--slice-color)}
.pie-legend-item span{min-width:0;color:var(--muted);overflow-wrap:anywhere}
.pie-legend-item strong{color:var(--text);font-size:11px}
.salary-report-card{min-width:0}
.salary-report-card .report-heading{margin-bottom:4px}
.salary-list{display:grid;gap:12px;margin-top:16px}
.salary-item{min-width:0}
.salary-item-head{display:flex;justify-content:space-between;align-items:baseline;gap:10px}
.salary-item-head strong{min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:12px}
.salary-item-head span{flex:none;color:var(--deep);font-size:12px;font-weight:800}
.salary-item small{display:block;margin-top:2px;color:var(--muted);font-size:10px}
.salary-track{height:5px;margin-top:7px;overflow:hidden;border-radius:99px;background:#e8edf5}
.salary-track i{display:block;height:100%;border-radius:inherit;background:linear-gradient(90deg,var(--blue),#7ba2f7);transform-origin:left;animation:salaryIn .65s ease-out both}
@keyframes pieIn{from{opacity:.5;transform:scale(.88) rotate(-18deg)}to{opacity:1;transform:scale(1) rotate(0)}}
@keyframes salaryIn{from{transform:scaleX(0)}to{transform:scaleX(1)}}
@media(max-width:900px){.side{transform:translateX(-100%)}body.nav-open .side{transform:none;width:248px}body.nav-open .side span{display:inline}.wrap{margin-left:0}.hq{grid-template-columns:1fr}.grid{grid-template-columns:1fr}.top .hide-s{display:none}}
@media(max-width:1000px){.report-dashboard{grid-template-columns:1fr}.report-overview{grid-row:auto}}
@media(max-width:620px){.report-metrics{grid-template-columns:repeat(2,minmax(0,1fr))}.report-chart-grid{grid-template-columns:1fr}.pie-layout{justify-content:flex-start}.report-live{font-size:0;padding:8px}.report-live i{margin:0}}
@media(prefers-reduced-motion:reduce){*{animation:none!important;transition:none!important}}
</style>
</head>
<body>
<aside class="side" id="side">
<div class="logo"><i class="fa-solid fa-link"></i><span>TEAMCONNECT</span></div>
<a class="l on" href="#overview" data-tip="Overview"><i class="fa-solid fa-gauge-high"></i><span>Overview</span></a>
<a class="l" href="#employees" data-tip="Employees"><i class="fa-solid fa-users"></i><span>Employees</span></a>
<a class="l" href="#departments" data-tip="Departments"><i class="fa-solid fa-building"></i><span>Departments</span></a>
<a class="l" href="#projects" data-tip="Projects"><i class="fa-solid fa-diagram-project"></i><span>Projects</span></a>
<a class="l" href="#attendance" data-tip="Attendance"><i class="fa-solid fa-calendar-check"></i><span>Attendance</span></a>
<a class="l" href="#leave" data-tip="Leave"><i class="fa-solid fa-plane-departure"></i><span>Leave</span></a>
<a class="l" href="#payroll" data-tip="Payroll"><i class="fa-solid fa-wallet"></i><span>Payroll</span></a>
<a class="l" href="#performance" data-tip="Performance"><i class="fa-solid fa-chart-line"></i><span>Performance</span></a>
<a class="l" href="#documents" data-tip="Documents"><i class="fa-solid fa-folder-open"></i><span>Documents</span></a>
<a class="l" href="#reports" data-tip="Reports"><i class="fa-solid fa-chart-pie"></i><span>Reports</span></a>
<% if(admin){ %><a class="l" href="#settings" data-tip="Settings"><i class="fa-solid fa-gear"></i><span>Settings</span></a><a class="l" href="#announcements" data-tip="Announcements"><i class="fa-solid fa-bullhorn"></i><span>Announcements</span></a><% } %>
<a class="l out" href="<%=ctx%>/logout" data-tip="Sign out"><i class="fa-solid fa-right-from-bracket"></i><span>Sign out</span></a>
</aside>
<div class="wrap">
<header class="top"><button class="btn burger" id="burger" aria-label="Toggle menu"><i class="fa-solid fa-bars"></i></button><div><h1>Workforce operations</h1><small>TeamConnect · <%=role%> access</small></div><div class="sp"></div><input class="gs hide-s" id="gsearch" placeholder="Search employees…" aria-label="Search employees"><div class="actions"><a class="b" href="<%=ctx%>/ems">My workforce home</a><a class="b hide-s" href="<%=ctx%>/ems/profile">My profile</a><a class="b hide-s" href="<%=ctx%>/chat">Team chat</a><a class="primary" href="<%=ctx%>/logout">Sign out</a></div></header>
<main>
<section class="hero" id="overview"><div class="date" id="today"></div><h2>Welcome to TEAMCONNECT</h2><p>Your people. Your organization. One connected workspace.</p><div class="qa"><a href="#employees"><i class="fa-solid fa-user-plus"></i> Add employee</a><a href="#leave"><i class="fa-solid fa-check-double"></i> Approve leave</a><a href="#reports"><i class="fa-solid fa-chart-column"></i> View reports</a></div></section>
<section class="stats">
<div class="card stat"><div class="ic"><i class="fa-solid fa-users"></i></div><div><strong id="employeesCount">—</strong><span>Employees</span></div></div><div class="card stat"><div class="ic"><i class="fa-solid fa-user-tie"></i></div><div><strong id="managersCount">—</strong><span>Managers</span></div></div><div class="card stat"><div class="ic"><i class="fa-solid fa-building"></i></div><div><strong id="departmentsCount">—</strong><span>Departments</span></div></div><div class="card stat"><div class="ic"><i class="fa-solid fa-diagram-project"></i></div><div><strong id="projectsCount">—</strong><span>Projects</span></div></div><div class="card stat"><div class="ic"><i class="fa-solid fa-hourglass-half"></i></div><div><strong id="pendingCount">—</strong><span>Pending leave</span></div></div><div class="card stat"><div class="ic"><i class="fa-solid fa-user-check"></i></div><div><strong id="presentCount">—</strong><span>Present today</span></div></div>
</section>
<section class="section card"><h2>Interactive headquarters</h2><div class="hq"><div><div class="stage" id="stage"><div class="bld" id="bld"></div></div><div class="ctl"><button class="btn" id="zin" title="Zoom in"><i class="fa-solid fa-plus"></i></button><button class="btn" id="zout" title="Zoom out"><i class="fa-solid fa-minus"></i></button><button class="btn" id="rot" title="Rotate"><i class="fa-solid fa-rotate"></i></button><span class="note">Drag to rotate · click a floor</span></div></div>
<div class="info" id="hqInfo"><p class="muted">Loading departments…</p></div></div></section>
<section class="section grid"><div class="card"><h2>Workforce by department</h2><div id="chartDept"></div></div><div class="card"><h2>Leave &amp; attendance</h2><div id="chartLeave"></div><h3>Attendance records by status</h3><div id="chartAtt"></div></div></section>
<section class="section card" id="employees"><h2>Employee management</h2><form class="form" id="employeeForm">
<input type="hidden" name="id"><label>Name<input name="name" maxlength="160" required></label><label>Email<input name="email" type="email" maxlength="255" required></label><label>Phone<input name="phone" maxlength="40"></label><label>Gender<input name="gender" maxlength="40"></label><label>Job title<input name="jobTitle" maxlength="160"></label><label>Hire date<input name="hireDate" type="date"></label><label>Salary<input name="salary" type="number" step=".01" min="0"></label><label>Department<select name="departmentId" id="employeeDepartment"><option value="">No department</option></select></label><label>TeamConnect user ID<input name="teamConnectUserId" type="number" min="1"></label><label>Address<input name="address" maxlength="500"></label>
<% if(admin){ %><label>Role<select name="role"><option>EMPLOYEE</option><option>MANAGER</option><option>HR</option><option>ADMIN</option></select></label><% } else { %><input type="hidden" name="role" value="EMPLOYEE"><% } %>
<label>Status<select name="status"><option>ACTIVE</option><option>INACTIVE</option></select></label><div class="actions"><button class="btn primary" type="submit">Save employee</button><button class="btn" type="reset" id="employeeCancel">Clear</button></div></form><p class="note">Deactivation preserves payroll and attendance history. HR can maintain employee records; only administrators can change roles.</p>
<div class="table-wrap"><table><thead><tr><th>Name</th><th>Email</th><th>Department</th><th>Role</th><th>Status</th><th>Actions</th></tr></thead><tbody id="employeeRows"></tbody></table></div></section>
<section class="section grid" id="departments"><div class="card"><h2>Departments</h2><form class="form" id="departmentForm"><input type="hidden" name="id"><label>Name<input name="name" maxlength="160" required></label><label>Description<input name="description" maxlength="500"></label><button class="btn primary">Save department</button><button type="reset" class="btn">Clear</button></form><div class="table-wrap"><table><thead><tr><th>Department</th><th>Description</th><th>Actions</th></tr></thead><tbody id="departmentRows"></tbody></table></div></div>
<div class="card" id="projects"><h2>Project management</h2><form class="form" id="projectForm"><input type="hidden" name="id"><label>Project name<input name="projectName" maxlength="180" required></label><label>Status<select name="status"><option>ACTIVE</option><option>PLANNED</option><option>COMPLETED</option><option>ON_HOLD</option></select></label><label>Start date<input name="startDate" type="date"></label><label>End date<input name="endDate" type="date"></label><label class="wide">Description<textarea name="description" maxlength="5000"></textarea></label><button class="btn primary">Save project</button><button type="reset" class="btn">Clear</button></form><div class="table-wrap"><table><thead><tr><th>Project</th><th>Dates</th><th>Status</th><th>Actions</th></tr></thead><tbody id="projectRows"></tbody></table></div><form class="form" id="projectMemberForm"><label>Project<select name="projectId" id="memberProject"></select></label><label>Employee<select name="employeeId" id="memberEmployee"></select></label><button class="btn">Assign employee</button></form></div></section>
<section class="section grid" id="attendance"><div class="card"><h2>Mark attendance</h2><form class="form" id="attendanceForm"><label>Employee<select name="employeeId" class="employeeSelect" required></select></label><label>Date<input name="date" type="date" required></label><label>Status<select name="status"><option>PRESENT</option><option>ABSENT</option><option>LEAVE</option></select></label><label>Check in<input name="checkIn" type="time"></label><label>Check out<input name="checkOut" type="time"></label><label>Notes<input name="notes" maxlength="500"></label><button class="btn primary">Save attendance</button></form></div><div class="card"><h2>Recent attendance</h2><div class="table-wrap"><table><thead><tr><th>Employee</th><th>Date</th><th>Status</th><th>Hours</th></tr></thead><tbody id="attendanceRows"></tbody></table></div></div></section>
<section class="section card" id="leave"><h2>Leave management</h2><div id="leaveSummary" class="note"></div><div class="table-wrap"><table><thead><tr><th>Employee</th><th>Dates</th><th>Type / reason</th><th>Status</th><th>Decision</th></tr></thead><tbody id="leaveRows"></tbody></table></div></section>
<section class="section grid" id="payroll"><div class="card"><h2>Process payroll</h2><form class="form" id="payrollForm"><label>Employee<select name="employeeId" class="employeeSelect" required></select></label><label>Period<input name="periodLabel" maxlength="80" placeholder="2026-11" required></label><label>Payment date<input name="paymentDate" type="date" required></label><label>Base salary<input name="baseSalary" type="number" min="0" step=".01" required></label><label>Bonus<input name="bonus" type="number" min="0" step=".01" value="0"></label><label>Deductions<input name="deductions" type="number" min="0" step=".01" value="0"></label><label>Status<select name="status"><option>PROCESSED</option><option>PENDING</option></select></label><label class="wide">Notes<input name="notes" maxlength="500"></label><button class="btn primary">Process salary</button></form><p class="note">Net salary is calculated as base salary + bonus − deductions.</p></div><div class="card"><h2>Payroll records</h2><div id="payrollSummary" class="note"></div><div class="table-wrap"><table><thead><tr><th>Employee</th><th>Period</th><th>Net</th><th>Date</th><th>Status</th></tr></thead><tbody id="payrollRows"></tbody></table></div></div></section>
<section class="section grid" id="performance"><div class="card"><h2>Add performance review</h2><form class="form" id="reviewForm"><label>Employee<select name="employeeId" class="employeeSelect" required></select></label><label>Review date<input name="reviewDate" type="date" required></label><label>Rating (1–10)<input name="rating" type="number" min="1" max="10" step=".1" required></label><label>Reviewer employee ID<input name="reviewerEmployeeId" type="number" min="1"></label><label>Status<select name="status"><option>PUBLISHED</option><option>DRAFT</option></select></label><label class="wide">Comments<textarea name="reviewContent" maxlength="10000"></textarea></label><button class="btn primary">Save review</button></form></div><div class="card"><h2>Recent reviews</h2><div class="table-wrap"><table><thead><tr><th>Employee</th><th>Date</th><th>Rating</th><th>Comments</th></tr></thead><tbody id="reviewRows"></tbody></table></div></div></section>
<section class="section card" id="documents"><h2>Employee documents</h2><form class="form" id="documentUploadForm"><label>Employee<select name="employeeId" class="employeeSelect" required></select></label><label>Choose document<input type="file" name="file" required></label><button class="btn primary">Upload document</button></form><p class="note">Maximum upload size: 20 MB.</p><div id="documentSummary" class="note"></div><div class="table-wrap"><table><thead><tr><th>Employee ID</th><th>File</th><th>Size</th><th>Uploaded</th><th>Download</th></tr></thead><tbody id="documentRows"></tbody></table></div></section>
<section class="section report-dashboard" id="reports"><div class="card report-overview"><div class="report-heading"><div><p class="report-kicker">Live workforce insights</p><h2>Reports & analytics</h2></div><span class="report-live"><i></i> Connected to EMS data</span></div><div id="reportSummary" class="report-metrics"><p class="muted">Loading workforce reports…</p></div><div class="report-chart-grid"><article class="report-chart-card"><div class="report-chart-heading"><div><h3>Workforce status</h3><p>Active and inactive employee records</p></div></div><div id="workforceChart" class="pie-layout"><p class="muted">Loading chart…</p></div></article><article class="report-chart-card"><div class="report-chart-heading"><div><h3>Department headcount</h3><p>Employees by department</p></div></div><div id="departmentReport" class="pie-layout"><p class="muted">Loading chart…</p></div></article></div></div><div class="card salary-report-card"><div class="report-heading"><div><p class="report-kicker">Compensation overview</p><h2>Top-paid employees</h2></div></div><p class="report-description">Highest salaries from current employee records.</p><div id="salaryReport" class="salary-list"><p class="muted">Loading salary data…</p></div></div></section>
<% if(admin){ %><section class="section grid"><div class="card" id="settings"><h2>System settings</h2><div id="settingsList"></div></div><div class="card" id="announcements"><h2>Publish announcement</h2><form class="form" id="announcementForm"><label>Title<input name="title" maxlength="180" required></label><label>Audience<select name="audience"><option>ALL</option><option>HR</option><option>MANAGERS</option></select></label><label class="wide">Message<textarea name="body" maxlength="3000" required></textarea></label><button class="btn primary">Publish announcement</button></form><div id="announcementList"></div></div></section><% } %>
</main></div><div class="toast" id="toast"></div>
<script>
const ctx='<%=ctx%>',admin=<%=admin%>,toastEl=document.getElementById('toast'),$=id=>document.getElementById(id);
let people=[],departments=[],projects=[],leave=[],names={},att=[],selDept=null,ry=-30,zoom=1;
const esc=x=>String(x??'—').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const toast=m=>{toastEl.textContent=m;toastEl.classList.add('show');setTimeout(()=>toastEl.classList.remove('show'),2800)};
async function api(path,options={}){const response=await fetch(ctx+path,options);if(!response.ok){let msg='Request failed';try{const body=await response.json();msg=body.error||msg}catch{}throw Error(msg)}if(response.status===204)return null;return response.json()}
const json=(method,data)=>({method,headers:{'Content-Type':'application/json'},body:JSON.stringify(data)});
const rows=(id,data,render)=>$(id).innerHTML=data.length?data.map(render).join(''):'<tr><td class="muted" colspan="6">No records found.</td></tr>';
const employeeOptions=()=>'<option value="">Select employee</option>'+people.filter(e=>e.status==='ACTIVE').map(e=>'<option value="'+e.id+'">'+esc(e.name)+' · #'+e.id+'</option>').join('');
const reduce=matchMedia('(prefers-reduced-motion:reduce)').matches;
function countTo(el,n){n=Number(n)||0;if(reduce||n===0){el.textContent=n;return}const t0=performance.now();(function s(t){const p=Math.min(1,(t-t0)/700);el.textContent=Math.round(n*(1-Math.pow(1-p,3)));if(p<1)requestAnimationFrame(s)})(t0)}
const initials=n=>String(n||'?').trim().split(/\s+/).slice(0,2).map(w=>w[0]).join('').toUpperCase();
function drawEmployees(){rows('employeeRows',people,e=>'<tr><td><span class="avatar">'+esc(initials(e.name))+'</span>'+esc(e.name)+'</td><td>'+esc(e.email)+'</td><td>'+esc(e.department?.name||'—')+'</td><td>'+esc(e.role)+'</td><td><span class="badge">'+esc(e.status)+'</span></td><td><div class="actions"><button class="btn" onclick="editEmployee('+e.id+')">Edit</button>'+(admin?'<button class="btn" onclick="setRole('+e.id+')">Role</button>':'')+'<button class="btn danger" onclick="deactivateEmployee('+e.id+')">Deactivate</button></div></td></tr>');filterEmployees()}
function filterEmployees(){const q=$('gsearch').value.trim().toLowerCase();document.querySelectorAll('#employeeRows tr').forEach(r=>r.style.display=!q||r.textContent.toLowerCase().includes(q)?'':'none')}
$('gsearch').oninput=()=>{filterEmployees();if($('gsearch').value)location.hash='employees'};
function editEmployee(id){const e=people.find(x=>x.id===id),f=$('employeeForm');if(!e)return;for(const k of ['name','email','phone','gender','jobTitle','hireDate','salary','address','role','status','teamConnectUserId'])if(f.elements[k])f.elements[k].value=e[k]??'';f.elements.departmentId.value=e.department?.id||'';f.elements.id.value=e.id;location.hash='employees'}
async function setRole(id){const role=prompt('Assign role: ADMIN, HR, MANAGER or EMPLOYEE');if(!role)return;try{await api('/api/ems/employees/'+id+'/role?role='+encodeURIComponent(role),{method:'PATCH'});toast('Role updated');await load()}catch(e){toast(e.message)}}
async function deactivateEmployee(id){if(!confirm('Deactivate this employee? Their records will be retained.'))return;try{await api('/api/ems/employees/'+id,{method:'DELETE'});toast('Employee deactivated');await load()}catch(e){toast(e.message)}}
function fillSelects(){const opts=employeeOptions();document.querySelectorAll('.employeeSelect').forEach(x=>x.innerHTML=opts);$('memberEmployee').innerHTML=opts;$('employeeDepartment').innerHTML='<option value="">No department</option>'+departments.map(d=>'<option value="'+d.id+'">'+esc(d.name)+'</option>').join('');$('memberProject').innerHTML=projects.map(p=>'<option value="'+p.id+'">'+esc(p.projectName)+'</option>').join('')}
/* ---- 3D HQ + analytics (real data only) ---- */
const todayStr=()=>new Date().toLocaleDateString('en-CA');
function deptStats(d){const m=people.filter(e=>e.department?.id===d.id),ids=new Set(m.map(e=>e.id));const present=att.filter(a=>a.date===todayStr()&&a.status==='PRESENT'&&ids.has(a.employeeId)).length;return{members:m,active:m.filter(e=>e.status==='ACTIVE').length,present}}
function drawHQ(){const b=$('bld'),list=departments.slice(0,10);if(!list.length){b.innerHTML='';$('hqInfo').innerHTML='<p class="muted">Add departments to build your headquarters. Each department becomes a floor.</p>';return}
 if(selDept==null||!list.some(d=>d.id===selDept))selDept=list[0].id;const H=44,total=list.length*H;
 b.style.top='0';b.innerHTML='<div class="roof" style="top:'+(-total/2)+'px"></div>'+list.slice().reverse().map((d,i)=>{const c=deptStats(d).members.length,t=esc(d.name)+' · '+c,y=-total/2+i*H;return'<div class="fl'+(d.id===selDept?' sel':'')+'" data-id="'+d.id+'" style="top:'+y+'px"><div class="f">'+t+'</div><div class="k">'+t+'</div><div class="r">'+esc(d.name)+'</div><div class="lf">'+esc(d.name)+'</div></div>'}).join('');
 const d=list.find(x=>x.id===selDept),s=deptStats(d);
 $('hqInfo').innerHTML='<h3>'+esc(d.name)+'</h3><p class="muted">'+esc(d.description||'No description')+'</p><div class="mini"><div><b>'+s.members.length+'</b>Employees</div><div><b>'+s.active+'</b>Active</div><div><b>'+s.present+'</b>Present today</div></div><div class="dots">'+s.members.slice(0,60).map(e=>'<span title="'+esc(e.name)+'" class="'+(e.status==='ACTIVE'?'':'off')+'"></span>').join('')+'</div><p class="note">Each dot is an employee (grey = inactive).</p><button class="btn primary" onclick="openDept('+d.id+')">Open department</button>'}
function openDept(id){editDepartment(id);location.hash='departments'}
$('bld').addEventListener('click',e=>{const f=e.target.closest('.fl');if(f){selDept=Number(f.dataset.id);drawHQ()}});
(function(){const s=$('stage');let x=null,moved=0;const set=()=>{$('bld').style.setProperty('--ry',ry+'deg');$('bld').style.setProperty('--z',zoom)};
 s.onpointerdown=e=>{x=e.clientX;moved=0};addEventListener('pointerup',()=>x=null);
 s.onpointermove=e=>{if(x==null)return;ry+=(e.clientX-x)*.6;x=e.clientX;set()};
 $('zin').onclick=()=>{zoom=Math.min(1.8,zoom+.15);set()};$('zout').onclick=()=>{zoom=Math.max(.6,zoom-.15);set()};$('rot').onclick=()=>{ry+=45;set()};set()})();
function bars(id,items){const max=Math.max(1,...items.map(i=>i[1]));$(id).innerHTML=items.length?items.map(i=>'<div class="bar"><span>'+esc(i[0])+'</span><div class="tr"><i data-w="'+(i[1]/max*100)+'"></i></div><b>'+esc(i[1])+'</b></div>').join(''):'<p class="muted">No data yet.</p>';requestAnimationFrame(()=>document.querySelectorAll('#'+id+' i').forEach(i=>i.style.width=i.dataset.w+'%'))}
function drawCharts(){bars('chartDept',departments.map(d=>[d.name,people.filter(e=>e.department?.id===d.id).length]));
 bars('chartLeave',['PENDING','APPROVED','REJECTED'].map(s=>[s,leave.filter(x=>x.status===s).length]));
 const c={};att.forEach(a=>c[a.status]=(c[a.status]||0)+1);bars('chartAtt',Object.entries(c));
 $('presentCount').textContent=att.filter(a=>a.date===todayStr()&&a.status==='PRESENT').length}
async function load(){
  try{
    [people,departments,projects,leave]=await Promise.all([api('/api/ems/employees'),api('/api/ems/departments'),api('/api/ems/projects'),api('/api/ems/leave')]);
    names=Object.fromEntries(people.map(e=>[e.id,e.name]));
    countTo($('employeesCount'),people.length);
    countTo($('managersCount'),people.filter(e=>e.role==='MANAGER').length);
    countTo($('departmentsCount'),departments.length);
    countTo($('projectsCount'),projects.length);
    countTo($('pendingCount'),leave.filter(x=>x.status==='PENDING').length);
    $('leaveSummary').textContent='Total: '+leave.length+' · Pending: '+leave.filter(x=>x.status==='PENDING').length+' · Approved: '+leave.filter(x=>x.status==='APPROVED').length+' · Rejected: '+leave.filter(x=>x.status==='REJECTED').length;
    fillSelects();drawEmployees();drawHQ();drawCharts();
    rows('departmentRows',departments,d=>'<tr><td>'+esc(d.name)+'</td><td>'+esc(d.description)+'</td><td><div class="actions"><button class="btn" onclick="editDepartment('+d.id+')">Edit</button>'+(admin?'<button class="btn danger" onclick="deleteDepartment('+d.id+')">Delete</button>':'')+'</div></td></tr>');
    rows('projectRows',projects,p=>'<tr><td>'+esc(p.projectName)+'</td><td>'+esc(p.startDate||'—')+' – '+esc(p.endDate||'—')+'</td><td>'+esc(p.status)+'</td><td><div class="actions"><button class="btn" onclick="editProject('+p.id+')">Edit</button><button class="btn danger" onclick="deleteProject('+p.id+')">Delete</button></div></td></tr>');
    rows('leaveRows',leave,l=>'<tr><td>'+esc(names[l.employeeId]||('#'+l.employeeId))+'</td><td>'+esc(l.startDate)+' – '+esc(l.endDate)+'</td><td>'+esc(l.leaveType)+' · '+esc(l.reason||'—')+'</td><td>'+esc(l.status)+'</td><td>'+(l.status==='PENDING'?'<button class="btn" data-review="'+l.id+'" data-status="APPROVED">Approve</button> <button class="btn danger" data-review="'+l.id+'" data-status="REJECTED">Reject</button>':'—')+'</td></tr>');
    document.querySelectorAll('#leaveRows tr').forEach((row,index)=>{const cell=row.lastElementChild;if(cell&&!cell.querySelector('[data-triage]')&&leave[index]){const button=document.createElement('button');button.type='button';button.className='btn';button.dataset.triage=String(leave[index].id);button.textContent='AI triage';cell.prepend(button);cell.prepend(document.createTextNode(' '))}});
    await Promise.all([loadAttendance(),loadPayroll(),loadReviews(),loadDocuments(),loadReports()]);
    if(admin)await Promise.all([loadSettings(),loadAnnouncements()]);
  }catch(e){toast('Could not load operations: '+e.message)}
}
$('leaveRows').onclick=e=>{const b=e.target.closest('[data-review]');if(b)reviewLeave(Number(b.dataset.review),b.dataset.status)};
$('leaveRows').addEventListener('click',async e=>{const b=e.target.closest('[data-triage]');if(!b)return;try{const result=await api('/api/ems/agents/leave-triage/'+b.dataset.triage);toast(result.recommendation+': '+result.reasons.join(' '))}catch(x){toast(x.message)}});
async function loadAttendance(){const data=await api('/api/ems/attendance');att=data;rows('attendanceRows',data.slice(0,30),x=>'<tr><td>'+esc(names[x.employeeId]||('#'+x.employeeId))+'</td><td>'+esc(x.date)+'</td><td>'+esc(x.status)+'</td><td>'+esc(x.checkIn||'—')+' – '+esc(x.checkOut||'—')+'</td></tr>');drawCharts();drawHQ()}
async function loadPayroll(){const all=await api('/api/ems/payroll');all.forEach(x=>x.employeeName=names[x.employeeId]||('#'+x.employeeId));all.sort((a,b)=>String(b.paymentDate).localeCompare(String(a.paymentDate)));$('payrollSummary').textContent='Records: '+all.length+' · Base: ₹'+all.reduce((n,x)=>n+Number(x.baseSalary||x.amount||0),0).toFixed(2)+' · Bonus: ₹'+all.reduce((n,x)=>n+Number(x.bonus||0),0).toFixed(2)+' · Net paid: ₹'+all.filter(x=>x.status==='PROCESSED').reduce((n,x)=>n+Number(x.amount||0),0).toFixed(2);rows('payrollRows',all.slice(0,30),x=>'<tr><td>'+esc(x.employeeName)+'</td><td>'+esc(x.periodLabel)+'</td><td>₹'+esc(x.amount)+'</td><td>'+esc(x.paymentDate)+'</td><td>'+esc(x.status)+'</td></tr>')}
async function loadReviews(){const data=await api('/api/ems/performance');rows('reviewRows',data.slice(0,30),x=>'<tr><td>'+esc(names[x.employeeId]||('#'+x.employeeId))+'</td><td>'+esc(x.reviewDate)+'</td><td><strong style="color:'+(x.rating>=8?'#198754':x.rating>=5?'#d99b32':'#d9534f')+'">'+esc(x.rating)+'/10</strong></td><td>'+esc(x.reviewContent||'—')+'</td></tr>')}
async function loadDocuments(){const data=await api('/api/ems/documents'),employeesWithDocs=new Set(data.map(x=>x.employeeId));$('documentSummary').textContent='Documents: '+data.length+' · Employees with files: '+employeesWithDocs.size+' · Last upload: '+(data[0]?.uploadedAt||'—');rows('documentRows',data.slice(0,30),x=>'<tr><td>'+esc(names[x.employeeId]||('#'+x.employeeId))+'</td><td>'+esc(x.originalName)+'</td><td>'+Math.ceil(x.fileSize/1024)+' KB</td><td>'+esc(x.uploadedAt||'—')+'</td><td><a href="'+ctx+'/api/ems/documents/'+encodeURIComponent(x.id)+'/download">Download</a></td></tr>')}
$('documentUploadForm').onsubmit=async e=>{e.preventDefault();try{await api('/api/ems/documents',{method:'POST',body:new FormData(e.target)});e.target.reset();toast('Document uploaded');await loadDocuments()}catch(x){toast(x.message)}};
function reportNumber(value){const number=Number(value);return Number.isFinite(number)?number:0}
function reportCount(value){return new Intl.NumberFormat().format(reportNumber(value))}
function reportMoney(value){return '₹'+new Intl.NumberFormat('en-IN',{maximumFractionDigits:2}).format(reportNumber(value))}
function renderPie(target,items,caption,emptyMessage){
 const values=items.map((item,index)=>({label:item.label,value:Math.max(0,reportNumber(item.value)),color:item.color||['#2455d6','#10b981','#7c3aed','#06b6d4','#d9a86c','#e25d70','#64748b'][index%7]}));
 const total=values.reduce((sum,item)=>sum+item.value,0);
 if(!values.length||total<=0){target.innerHTML='<p class="muted">'+esc(emptyMessage)+'</p>';return}
 let end=0;
 const stops=values.map(item=>{const start=end;end+=item.value/total*100;return item.color+' '+start.toFixed(2)+'% '+end.toFixed(2)+'%'}).join(',');
 const chart='<div class="pie-chart" role="img" aria-label="'+esc(caption+': '+values.map(item=>item.label+' '+reportCount(item.value)).join(', '))+'" data-total="'+esc(reportCount(total))+'" data-caption="'+esc(caption)+'" style="--pie-stops:'+stops+'"></div>';
 const legend='<div class="pie-legend">'+values.map(item=>'<div class="pie-legend-item"><i style="--slice-color:'+item.color+'"></i><span>'+esc(item.label)+'</span><strong>'+esc(reportCount(item.value))+'</strong></div>').join('')+'</div>';
 target.innerHTML=chart+legend
}
async function loadReports(){
 const r=await api('/api/ems/reports/summary');
 const metrics=[
  ['Total employees',r.employees],['Active employees',r.activeEmployees],['Departments',r.departments],
  ['Projects',r.projects],['Leave requests',r.leaveRequests],['Attendance records',r.attendanceRecords],
  ['Documents',r.documents],['Performance reviews',r.performanceReviews],
  ['Average salary',reportMoney(r.averageSalary)],['Highest salary',reportMoney(r.maximumSalary)],['Lowest salary',reportMoney(r.minimumSalary)]
 ];
 $('reportSummary').innerHTML=metrics.map(([label,value])=>'<div class="report-metric"><span>'+esc(label)+'</span><strong>'+esc(typeof value==='string'?value:reportCount(value))+'</strong></div>').join('');
 const employees=reportNumber(r.employees),active=Math.min(employees,reportNumber(r.activeEmployees));
 renderPie($('workforceChart'),[{label:'Active',value:active,color:'#10b981'},{label:'Inactive',value:Math.max(0,employees-active),color:'#94a3b8'}],'employees','No employee records to chart.');
 renderPie($('departmentReport'),(r.departmentCounts||[]).map(item=>({label:item.name,value:item.employees})), 'employees','No department headcount data to chart.');
 const salaries=r.topPaidEmployees||[],maxSalary=Math.max(0,...salaries.map(item=>reportNumber(item.salary)));
 $('salaryReport').innerHTML=salaries.map(item=>'<div class="salary-item"><div class="salary-item-head"><strong>'+esc(item.name)+'</strong><span>'+esc(reportMoney(item.salary))+'</span></div><small>'+esc(item.department)+'</small><div class="salary-track"><i style="width:'+(maxSalary>0?Math.max(0,Math.min(100,reportNumber(item.salary)/maxSalary*100)):0)+'%"></i></div></div>').join('')||'<p class="muted">No salary data available.</p>'
}
async function loadSettings(){const a=await api('/api/ems/settings');$('settingsList').innerHTML=a.map(s=>'<label class="note"><input type="checkbox" data-setting="'+esc(s.key)+'" '+(s.value==='true'?'checked':'')+'> '+esc(s.key.replaceAll('_',' ').toLowerCase())+'</label>').join('')}
$('settingsList')?.addEventListener('change',e=>{const input=e.target.closest('[data-setting]');if(input)saveSetting(input.dataset.setting,input.checked)});
async function loadAnnouncements(){const a=await api('/api/ems/announcements');$('announcementList').innerHTML=a.map(x=>'<div class="note"><strong>'+esc(x.title)+'</strong> · '+esc(x.audience)+'<br>'+esc(x.body)+'</div>').join('')||'<p class="muted">No announcements yet.</p>'}
async function saveSetting(key,value){try{await api('/api/ems/settings/'+encodeURIComponent(key)+'?value='+value,{method:'PUT'});toast('Setting saved')}catch(e){toast(e.message)}}
async function reviewLeave(id,status){try{await api('/api/ems/leave/'+id+'/status?status='+status,{method:'PATCH'});toast('Leave '+status.toLowerCase());await load()}catch(e){toast(e.message)}}
function editDepartment(id){const d=departments.find(x=>x.id===id),f=$('departmentForm');f.elements.id.value=d.id;f.elements.name.value=d.name;f.elements.description.value=d.description||''}
async function deleteDepartment(id){if(!confirm('Delete this department? Employee records will remain.'))return;try{await api('/api/ems/departments/'+id,{method:'DELETE'});toast('Department deleted');await load()}catch(e){toast(e.message)}}
function editProject(id){const p=projects.find(x=>x.id===id),f=$('projectForm');for(const k of ['projectName','description','startDate','endDate','status'])f.elements[k].value=p[k]||'';f.elements.id.value=p.id}
async function deleteProject(id){if(!confirm('Delete this project and its assignments?'))return;try{await api('/api/ems/projects/'+id,{method:'DELETE'});toast('Project deleted');await load()}catch(e){toast(e.message)}}
$('employeeForm').onsubmit=async e=>{e.preventDefault();const f=e.target,d=Object.fromEntries(new FormData(f));const id=d.id;delete d.id;d.salary=d.salary?Number(d.salary):null;d.departmentId=d.departmentId?Number(d.departmentId):null;d.teamConnectUserId=d.teamConnectUserId?Number(d.teamConnectUserId):null;try{await api('/api/ems/employees'+(id?'/'+id:''),json(id?'PUT':'POST',d));f.reset();f.elements.id.value='';toast('Employee saved');await load()}catch(x){toast(x.message)}};
$('employeeCancel').onclick=()=>{$('employeeForm').elements.id.value=''};
$('departmentForm').onsubmit=async e=>{e.preventDefault();const f=e.target,d=Object.fromEntries(new FormData(f)),id=d.id;delete d.id;try{await api('/api/ems/departments'+(id?'/'+id:''),json(id?'PUT':'POST',d));f.reset();toast('Department saved');await load()}catch(x){toast(x.message)}};
$('projectForm').onsubmit=async e=>{e.preventDefault();const f=e.target,d=Object.fromEntries(new FormData(f)),id=d.id;delete d.id;try{await api('/api/ems/projects'+(id?'/'+id:''),json(id?'PUT':'POST',d));f.reset();toast('Project saved');await load()}catch(x){toast(x.message)}};
$('projectMemberForm').onsubmit=async e=>{e.preventDefault();const d=Object.fromEntries(new FormData(e.target));try{await api('/api/ems/projects/'+d.projectId+'/members/'+d.employeeId,{method:'POST'});toast('Employee assigned to project')}catch(x){toast(x.message)}};
$('attendanceForm').onsubmit=async e=>{e.preventDefault();const d=Object.fromEntries(new FormData(e.target));for(const k of ['checkIn','checkOut'])if(!d[k])d[k]=null;try{await api('/api/ems/attendance',json('POST',d));toast('Attendance saved');await loadAttendance()}catch(x){toast(x.message)}};
$('payrollForm').onsubmit=async e=>{e.preventDefault();const d=Object.fromEntries(new FormData(e.target));for(const k of ['employeeId','baseSalary','bonus','deductions'])d[k]=Number(d[k]||0);try{await api('/api/ems/payroll',json('POST',d));e.target.reset();toast('Payroll processed');await loadPayroll()}catch(x){toast(x.message)}};
$('reviewForm').onsubmit=async e=>{e.preventDefault();const d=Object.fromEntries(new FormData(e.target));d.employeeId=Number(d.employeeId);d.rating=Number(d.rating);d.reviewerEmployeeId=d.reviewerEmployeeId?Number(d.reviewerEmployeeId):null;try{await api('/api/ems/performance',json('POST',d));e.target.reset();toast('Review saved');await loadReviews()}catch(x){toast(x.message)}};
if(admin){$('announcementForm').onsubmit=async e=>{e.preventDefault();try{await api('/api/ems/announcements',json('POST',Object.fromEntries(new FormData(e.target))));e.target.reset();toast('Announcement published')}catch(x){toast(x.message)}}}
/* ---- shell: sidebar, active link, date ---- */
$('today').textContent=new Date().toLocaleDateString(undefined,{weekday:'long',day:'numeric',month:'long',year:'numeric'});
$('burger').onclick=()=>{innerWidth>900?document.body.classList.toggle('collapsed'):document.body.classList.toggle('nav-open')};
document.querySelectorAll('.side a.l').forEach(a=>a.addEventListener('click',()=>document.body.classList.remove('nav-open')));
const links=[...document.querySelectorAll('.side a.l[href^="#"]')];
const io=new IntersectionObserver(es=>es.forEach(en=>{if(en.isIntersecting)links.forEach(l=>l.classList.toggle('on',l.getAttribute('href')==='#'+en.target.id))}),{rootMargin:'-30% 0px -60% 0px'});
links.forEach(l=>{const t=document.querySelector(l.getAttribute('href'));if(t)io.observe(t)});
load();
</script>
<section class="section card" id="agent-controls">
<h2>AI agent actions</h2>
<p class="note">Automated checks are advisory. HR reviews recommendations; only administrators can publish announcements.</p>
<div class="actions">
<button class="btn" type="button" id="attendanceAgentButton">Run attendance check</button>
<button class="btn" type="button" id="onboardingButton">Refresh onboarding checklist</button>
<button class="btn" type="button" id="dataQualityButton">Check data quality</button>
<button class="btn" type="button" id="payrollPrecheckButton">Pre-check payroll form</button>
<button class="btn" type="button" id="reconciliationButton">Check payment reconciliation</button>
</div>
<div id="agentOutput" class="note" aria-live="polite"></div>
<label>Project brief<select id="projectBriefSelect"></select></label>
<button class="btn" type="button" id="projectBriefButton">Draft project status brief</button>
<div id="projectBriefOutput" class="note" aria-live="polite"></div>
<form class="form" id="announcementDraftForm">
<label class="wide">Announcement topic and details<textarea name="request" maxlength="4000" required placeholder="For example: remind staff that payroll cut-off is Friday"></textarea></label>
<button class="btn primary">Draft announcement</button>
</form>
<div id="announcementDraftOutput" class="note" aria-live="polite"></div>
<% if(admin){ %><form class="form" id="policyForm">
<h3>Approved policy library</h3>
<label>Policy title<input name="title" maxlength="180" required></label>
<label>Source<input name="source" maxlength="255" placeholder="Policy handbook, section 4"></label>
<label class="wide">Policy text<textarea name="content" maxlength="100000" required></textarea></label>
<button class="btn primary">Add approved policy</button>
</form><div id="policyList" class="note"></div><% } %>
<p class="note">Review assistant: select an employee in the performance review form, then use the draft-comments button. The assistant does not assign ratings.</p>
</section>
<script>
const reviewDraftButton=document.createElement('button');reviewDraftButton.type='button';reviewDraftButton.className='btn';reviewDraftButton.id='reviewDraftButton';reviewDraftButton.textContent='Draft comments from work data';$('reviewForm').appendChild(reviewDraftButton);
function fillProjectBriefSelect(){const select=$('projectBriefSelect');if(select)select.innerHTML=projects.map(p=>'<option value="'+p.id+'">'+esc(p.projectName)+'</option>').join('')||'<option value="">No projects</option>'}
fillProjectBriefSelect();
document.getElementById('attendanceAgentButton').onclick=async()=>{try{const data=await api('/api/ems/agents/attendance/anomalies');$('agentOutput').textContent=data.length?data.map(x=>x.employeeName+': '+x.reason).join(' | '):'No attendance anomalies found.'}catch(e){toast(e.message)}};
document.getElementById('onboardingButton').onclick=async()=>{try{const data=await api('/api/ems/agents/onboarding');$('agentOutput').textContent=data.length?data.map(x=>x.employeeName+': '+(x.missingDocuments.length?'missing '+x.missingDocuments.join(', '):'documents complete')).join(' | '):'No recent onboarding records.'}catch(e){toast(e.message)}};
document.getElementById('dataQualityButton').onclick=async()=>{try{const data=await api('/api/ems/agents/data-quality');$('agentOutput').textContent=data.length?data.map(x=>x.recordType+' #'+x.recordId+': '+x.issue).join(' | '):'No data quality issues found.'}catch(e){toast(e.message)}};
document.getElementById('projectBriefButton').onclick=async()=>{fillProjectBriefSelect();const id=$('projectBriefSelect').value;if(!id)return;try{const result=await api('/api/ems/agents/projects/'+id+'/brief');$('projectBriefOutput').textContent=result.brief}catch(e){toast(e.message)}};
document.getElementById('payrollPrecheckButton').onclick=async()=>{const f=$('payrollForm');const d=Object.fromEntries(new FormData(f));for(const k of ['employeeId','baseSalary','bonus','deductions'])d[k]=Number(d[k]||0);try{const r=await api('/api/ems/agents/payroll/precheck',json('POST',d));$('agentOutput').textContent=r.warnings.length?'Payroll warnings: '+r.warnings.join(' | '):'No payroll pre-check warnings.'}catch(e){toast(e.message)}};
document.getElementById('reconciliationButton').onclick=async()=>{try{const r=await api('/api/ems/agents/payment-reconciliation');$('agentOutput').textContent=Array.isArray(r)?(r.length?r.map(x=>x.employeeName+': '+x.explanation).join(' | '):'No payout mismatches reported.'):(r.message||'Payment integration is not configured.')}catch(e){toast(e.message)}};
document.getElementById('announcementDraftForm').onsubmit=async e=>{e.preventDefault();try{const r=await api('/api/ems/agents/announcement-draft',json('POST',{request:e.target.elements.request.value}));$('announcementDraftOutput').textContent=r.title+(r.body?'\n'+r.body:'');if(admin&&$('announcementForm')){$('announcementForm').elements.title.value=r.title;$('announcementForm').elements.body.value=r.body}toast('Draft ready. Review it before publishing.')}catch(x){toast(x.message)}};
document.getElementById('reviewDraftButton').onclick=async()=>{const id=Number($('reviewForm').elements.employeeId.value);if(!id){toast('Select an employee first.');return}try{const r=await api('/api/ems/agents/performance-draft/'+id,{method:'POST'});$('reviewForm').elements.reviewContent.value=r.draft;toast('Draft added. Edit comments and choose the rating.')}catch(e){toast(e.message)}};
if(admin&&$('policyForm')){$('policyForm').onsubmit=async e=>{e.preventDefault();try{await api('/api/ems/agents/policies',json('POST',Object.fromEntries(new FormData(e.target))));e.target.reset();toast('Policy added to approved library');await loadPolicies()}catch(x){toast(x.message)}};window.loadPolicies=async()=>{const data=await api('/api/ems/agents/policies');$('policyList').replaceChildren();data.forEach(policy=>{const row=document.createElement('div');row.className='note';const toggle=document.createElement('button');toggle.className='btn';toggle.type='button';toggle.textContent=policy.active?'Deactivate':'Activate';toggle.onclick=async()=>{try{await api('/api/ems/agents/policies/'+policy.id+'?active='+(!policy.active),{method:'PATCH'});await loadPolicies()}catch(e){toast(e.message)}};row.textContent=policy.title+' · '+(policy.source||'No source')+' · '+(policy.active?'Active':'Inactive')+' ';row.appendChild(toggle);$('policyList').appendChild(row)})};window.loadPolicies()};
$('payrollForm').onsubmit=async e=>{e.preventDefault();const f=e.target,d=Object.fromEntries(new FormData(f));for(const k of ['employeeId','baseSalary','bonus','deductions'])d[k]=Number(d[k]||0);try{const check=await api('/api/ems/agents/payroll/precheck',json('POST',d));if(check.warnings.length){$('agentOutput').textContent='Payroll warnings: '+check.warnings.join(' | ');toast('Payroll pre-check found warnings; payroll will continue.')}}catch(x){$('agentOutput').textContent='Payroll pre-check unavailable: '+x.message+' Payroll will continue.'}try{await api('/api/ems/payroll',json('POST',d));f.reset();toast('Payroll processed');await loadPayroll()}catch(x){toast(x.message)}};
</script>
</body></html>
