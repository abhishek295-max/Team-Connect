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
else if ("role_mismatch".equals(error)) {message="This account is not assigned to the selected workforce role.";messageIsError=true;}
else if ("role_required".equals(error)) {message="Select Employee, HR, or Manager before signing in.";messageIsError=true;}
else if ("ems_link_missing".equals(error)) {message="Your TeamConnect account is not linked to an employee profile yet.";messageIsError=true;}
else if (error!=null) {message="The request could not be completed. Please try again.";messageIsError=true;}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">


    <title>Get Started</title>


    <style>
       * {
           margin: 0;
           padding: 0;
           box-sizing: border-box;
           font-family: "Segoe UI", Arial, sans-serif;
       }

       body {
           min-height: 100vh;
           display: flex;
           justify-content: center;
           align-items: center;
           background: #f3f5f8;
           padding: 20px;
       }



       .auth-container {
           width: 950px;
           height: 570px;
           background: #ffffff;
           border-radius: 22px;
           overflow: hidden;
           position: relative;
           box-shadow: 0 20px 60px rgba(0, 0, 0, 0.12);
       }



       .auth-wrapper {
           width: 200%;
           height: 100%;
           display: flex;
           transition: transform 0.75s cubic-bezier(0.65, 0, 0.35, 1);
       }

       .auth-container.register-active .auth-wrapper {
           transform: translateX(-50%);
       }



       .auth-page {
           width: 50%;
           height: 100%;
           display: flex;
           flex-shrink: 0;
       }



       .image-section {
           width: 50%;
           height: 100%;
           position: relative;
           overflow: hidden;
           background: #222;
       }

        .auth-page:first-child .image-section {
            background: #222 url("https://images.unsplash.com/photo-1497366811353-6870744d04b2?auto=format&fit=crop&w=1200&q=85") center / cover no-repeat;
        }

        .auth-page:first-child .image-section img {
            visibility: hidden !important;
        }

        .auth-page:not(:first-child) .image-section img {
            visibility: visible;
        }

        .image-section img {
            display: block;
            width: 100%;
            height: 100%;
            object-fit: cover;
            object-position: center;

            transition:
                    transform 1s ease,
                    filter 0.8s ease;
        }

        .auth-container.register-active
        .auth-page:first-child
        .image-section img {
           transform: scale(1.06);
           filter: brightness(0.85);
       }

        .image-overlay {
            position: absolute;
            inset: 0;

            background:
                    linear-gradient(
                            180deg,
                            rgba(0, 0, 0, 0.05),
                            rgba(0, 0, 0, 0.40)
                    );

           display: flex;
           flex-direction: column;
           justify-content: flex-end;

           padding: 45px;
           color: white;
       }

       .image-overlay h1 {
           font-size: 38px;
           font-weight: 600;
           margin-bottom: 12px;
       }

       .image-overlay p {
           font-size: 15px;
           line-height: 1.6;
           max-width: 330px;
           color: rgba(255, 255, 255, 0.85);
       }



       .form-section {
           width: 50%;
           height: 100%;

           display: flex;
           justify-content: center;
           align-items: center;

           padding: 45px;
       }

       .form-content {
           width: 100%;
           max-width: 350px;

           animation: formAppear 0.8s ease;
       }

       @keyframes formAppear {
           from {
               opacity: 0;
               transform: translateY(15px);
           }

           to {
               opacity: 1;
               transform: translateY(0);
           }
       }

       .logo {
           width: 45px;
           height: 45px;

           border-radius: 12px;

           display: flex;
           justify-content: center;
           align-items: center;

           background: #111827;
           color: white;

           font-size: 20px;
           font-weight: 600;

           margin-bottom: 22px;
       }

       .form-content h2 {
           font-size: 30px;
           color: #171717;
           margin-bottom: 8px;
       }

       .subtitle {
           color: #777;
           font-size: 14px;
           margin-bottom: 28px;
       }

       /* =========================
          INPUTS
       ========================= */

       .input-group {
           margin-bottom: 17px;
       }

       .input-group label {
           display: block;
           font-size: 13px;
           font-weight: 600;
           color: #444;
           margin-bottom: 7px;
       }

       .input-group input {
           width: 100%;
           height: 48px;

           padding: 0 15px;

           border: 1px solid #ddd;
           border-radius: 9px;

           outline: none;

           font-size: 14px;
           color: #222;

           transition: 0.25s ease;
       }

       .input-group input:focus {
           border-color: #222;

           box-shadow:
                   0 0 0 3px rgba(0, 0, 0, 0.05);
       }



       .form-options {
           display: flex;
           justify-content: space-between;
           align-items: center;

           margin: 4px 0 22px;

           font-size: 13px;
       }

       .remember {
           display: flex;
           align-items: center;
           gap: 7px;
           color: #666;
       }

       .remember input {
           accent-color: #111;
       }

       .forgot {
           color: #222;
           text-decoration: none;
           font-weight: 600;
       }



       .submit-btn {
           width: 100%;
           height: 48px;

           border: none;
           border-radius: 9px;

           background: #111827;
           color: white;

           font-size: 15px;
           font-weight: 600;

           cursor: pointer;

           transition:
                   transform 0.2s ease,
                   box-shadow 0.2s ease,
                   background 0.2s ease;
       }

       .submit-btn:hover {
           background: #000;
           transform: translateY(-2px);

           box-shadow:
                   0 8px 20px rgba(0, 0, 0, 0.15);
       }

       .submit-btn:active {
           transform: translateY(0);
       }



       .switch-text {
           text-align: center;
           margin-top: 23px;

           font-size: 13px;
           color: #777;
       }

       .switch-text button {
           border: none;
           background: none;

           color: #111827;

           font-weight: 700;
           cursor: pointer;

           margin-left: 4px;
       }

       .switch-text button:hover {
           text-decoration: underline;
       }



       .register-page {
           flex-direction: row-reverse;
       }



       @media (max-width: 800px) {

           body {
               padding: 15px;
           }

           .auth-container {
               height: auto;
               min-height: 600px;
           }

           .auth-page {
               flex-direction: column;
               height: 100%;
           }

           .image-section {
               width: 100%;
               height: 220px;
           }

           .form-section {
               width: 100%;
               min-height: 400px;
               padding: 35px 25px;
           }

           .image-overlay {
               padding: 25px;
           }

           .image-overlay h1 {
               font-size: 27px;
           }

           .image-overlay p {
               display: none;
           }
       }

       @media (max-width: 500px) {

           .auth-container {
               border-radius: 15px;
           }

           .image-section {
               height: 180px;
           }

           .form-section {
               padding: 30px 22px;
           }

           .form-content h2 {
               font-size: 26px;
           }

           .form-options {
               font-size: 12px;
           }
       }


       .auth-page.register-page{display:none!important}.auth-page:first-child .switch-text{display:none!important}
    .auth-container{animation:authIn .8s cubic-bezier(.2,.8,.2,1) both}.image-section img{animation:heroZoom 12s ease-in-out infinite alternate}.form-content>*{animation:fieldIn .55s both}.form-content>*:nth-child(2){animation-delay:.08s}.form-content>*:nth-child(3){animation-delay:.14s}.input-group input,.input-group select,.input-group textarea{transition:border-color .2s,box-shadow .2s,transform .2s,background-color .25s}.input-group input:hover,.input-group select:hover{transform:translateY(-1px);border-color:#9db8d3}.input-group input:focus,.input-group select:focus{transform:translateY(-2px);box-shadow:0 0 0 4px #316fe01a,0 10px 24px #223b5914}.submit-btn{transition:transform .2s,box-shadow .25s,background-color .25s}.submit-btn:hover{transform:translateY(-3px);box-shadow:0 14px 28px #1118272b}.submit-btn:active{transform:translateY(-1px) scale(.98)}.switch-text button,.forgot{transition:color .2s,transform .2s}.switch-text button:hover,.forgot:hover{transform:translateX(2px)}@keyframes authIn{from{opacity:0;transform:translateY(20px) scale(.98)}to{opacity:1;transform:none}}@keyframes heroZoom{from{transform:scale(1)}to{transform:scale(1.06)}}@keyframes fieldIn{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:none}}@media(prefers-reduced-motion:reduce){*,*:before,*:after{animation:none!important;transition:none!important}}
    </style>


</head>

<body>


<div class="auth-container" id="authContainer">

    <div th:if="${loginError}" th:text="${loginError}" class="auth-message error"></div>
    <div th:if="${registerError}" th:text="${registerError}" class="auth-message error"></div>
    <div th:if="${success}" th:text="${success}" class="auth-message success"></div>

    <div class="auth-wrapper">




        <div class="auth-page">



            <div class="image-section">

                <img
                        src="https://images.unsplash.com/photo-1497366811353-6870744d04b2?auto=format&fit=crop&w=1000&q=80"
                        alt="Workspace"
                >

                <div class="image-overlay">

                    <h1>Welcome back.</h1>

                    <p>
                        Sign in to continue to your account
                        and stay connected with your workspace.
                    </p>

                </div>

            </div>




            <div class="form-section">

                <div class="form-content">

                    <div class="logo">
                        TC
                    </div>

                    <h2>Sign in</h2>

                    <p class="subtitle">
                        Welcome back! Please enter your details.
                    </p>


                    <form method="post" action="/login">

                        <div class="input-group">
                            <label for="workspace">Sign in to</label>
                            <select id="workspace" name="workspace" style="width:100%;padding:13px 14px;border:1px solid #d8e1ed;border-radius:12px;background:#fff;color:#1f3045;font:inherit">
                                <option value="employee">Employee Dashboard</option>
                                <option value="hr">HR Dashboard</option>
                                <option value="manager">Manager Dashboard</option>
                            </select>
                            <small style="display:block;margin-top:6px;color:#708198">Administrators use the separate secure <a href="/admin">Admin Console</a>.</small>
                        </div>

                        <div class="input-group">

                            <label>Username</label>

                            <input
                                    type="text"
                                    name="username"
                                    placeholder="Enter your username"
                                    required
                            >

                        </div>


                        <div class="input-group">

                            <label>Password</label>

                            <input
                                    type="password"
                                    name="password"
                                    placeholder="Enter your password"
                                    required
                            >

                        </div>


                        <div class="form-options">

                            <label class="remember">

                                <input type="checkbox">

                                Remember me

                            </label>

                            <a href="#" class="forgot">
                                Forgot password?
                            </a>

                        </div>


                        <button type="submit" class="submit-btn">
                            Sign in
                        </button>

                    </form>


                    <div class="switch-text">

                        Don't have an account?

                        <button
                                type="button"
                                onclick="showRegister()"
                        >
                            Create account
                        </button>

                    </div>

                </div>

            </div>

        </div>




        <div class="auth-page register-page" id="registerPage">



            <div class="image-section">

                <img
                        src="https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=1000&q=80"
                        alt="Team collaboration"
                >

                <div class="image-overlay">

                    <h1>Join the team.</h1>

                    <p>
                        Create your account and start
                        collaborating with your team.
                    </p>

                </div>

            </div>




            <div class="form-section">

                <div class="form-content">

                    <div class="logo">
                        A
                    </div>

                    <h2>Create account</h2>

                    <p class="subtitle">
                        Get started by creating your account.
                    </p>


                    <form method="post" action="/register">

                        <div class="input-group">

                            <label>Full name</label>

                            <input
                                    type="text"
                                    name="username"
                                    placeholder="Enter your full name"
                                    required
                            >

                        </div>


                        <div class="input-group">

                            <label>Email</label>

                            <input
                                    type="email"
                                    name="email"
                                    placeholder="Enter your email"
                                    required
                            >

                        </div>


                        <div class="input-group">

                            <label>Password</label>

                            <input
                                    type="password"
                                    name="password"
                                    placeholder="Create a password"
                                    required
                            >

                        </div>


                        <button type="submit" class="submit-btn">
                            Create account
                        </button>

                    </form>


                    <div class="switch-text">

                        Already have an account?

                        <button
                                type="button"
                                onclick="showLogin()"
                        >
                            Sign in
                        </button>

                    </div>

                </div>

            </div>

        </div>

    </div>

</div>

<script src="/assets/js/auth.js"></script>



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
</script><style>
#registerTheme{position:fixed;right:24px;top:22px;z-index:50;width:42px;height:42px;border:1px solid #dce6f1;border-radius:12px;background:#ffffffdd;color:#18263b;cursor:pointer;box-shadow:0 10px 26px #1b47701c}
html[data-theme=dark] body{background:#070d1a!important;color:#edf4ff!important}html[data-theme=dark] .auth-container{background:radial-gradient(circle at 15% 10%,#1b396655,transparent 35rem),#070d1a!important}html[data-theme=dark] .auth-wrapper,html[data-theme=dark] .form-section,html[data-theme=dark] .auth-page{background:#0d1930!important;color:#edf4ff!important;border-color:#263c5d!important}html[data-theme=dark] .subtitle,html[data-theme=dark] .switch-text,html[data-theme=dark] label{color:#a7b8d0!important}html[data-theme=dark] input,html[data-theme=dark] select{background:#101f39!important;color:#edf4ff!important;border-color:#2a4165!important}html[data-theme=dark] .input-group input::placeholder{color:#8193b0!important}
</style>
<button id="registerTheme" type="button" aria-label="Toggle theme"><i class="fa-solid fa-moon"></i></button>
<script>(function(){var b=document.getElementById("registerTheme"),r=document.documentElement,t=localStorage.getItem("tcRegisterTheme")||"light";r.dataset.theme=t;function sync(){var d=r.dataset.theme==="dark";b.innerHTML=d?"<i class=\\"fa-solid fa-sun\\"></i>":"<i class=\\"fa-solid fa-moon\\"></i>"}sync();b.onclick=function(){r.dataset.theme=r.dataset.theme==="dark"?"light":"dark";localStorage.setItem("tcRegisterTheme",r.dataset.theme);document.body.classList.add("theme-changing");sync();setTimeout(function(){document.body.classList.remove("theme-changing")},700)}})();</script></body>
</html>


