const authContainer = document.getElementById("authContainer");

function showRegister() {
    if (authContainer) authContainer.classList.add("register-active");
}

function showLogin() {
    if (authContainer) authContainer.classList.remove("register-active");
}

const query = new URLSearchParams(window.location.search);
if (query.has("error") || query.has("registered") || query.has("deleted")) showLogin();