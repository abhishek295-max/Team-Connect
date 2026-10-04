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



</body>
</html>
