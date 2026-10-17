<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="model.User,model.Message,model.GroupChat,java.util.List,java.util.Map,util.WebUtil" %>
<%
    jakarta.servlet.http.HttpSession activeSession = request.getSession(false);
    if (activeSession == null || activeSession.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/views/register.jsp");
        return;
    }

    Integer userId = (Integer) activeSession.getAttribute("userId");
    String username = (String) activeSession.getAttribute("username");
    String email = (String) activeSession.getAttribute("email");

    List<User> contacts = (List<User>) request.getAttribute("contacts");
    if (contacts == null) contacts = java.util.Collections.emptyList();

    User activeContact = (User) request.getAttribute("activeContact");

    List<GroupChat> groups = (List<GroupChat>) request.getAttribute("groups");
    if (groups == null) groups = java.util.Collections.emptyList();

    List<Map<String, Object>> notifications = (List<Map<String, Object>>) request.getAttribute("notifications");
    if (notifications == null) notifications = java.util.Collections.emptyList();

    List<Message> messages = (List<Message>) request.getAttribute("messages");
    if (messages == null) messages = java.util.Collections.emptyList();

    int contactCount = request.getAttribute("contactCount") != null
            ? (Integer) request.getAttribute("contactCount")
            : contacts.size();

    int messageCount = request.getAttribute("messageCount") != null
            ? (Integer) request.getAttribute("messageCount")
            : messages.size();

    int activeContactId = activeContact != null ? activeContact.getId() : 0;
    String contextPath = request.getContextPath();

    String activeName = activeContact != null
            ? WebUtil.escapeHtml(activeContact.getUsername())
            : "Select a conversation";

    String activeEmail = activeContact != null
            ? WebUtil.escapeHtml(activeContact.getEmail())
            : "Choose someone from your workspace";

    String messagePlaceholder = activeContactId > 0
            ? "Write a message..."
            : "Select a conversation first";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
<title>TeamConnect â€” Workspace</title>
<script>(function(){try{document.documentElement.dataset.theme=localStorage.getItem("teamconnect-theme")||"blue"}catch(e){}})()</script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,600;9..144,700&family=IBM+Plex+Sans:wght@400;500;600&display=swap" rel="stylesheet">
<style>
:root{--serif:"Fraunces","Iowan Old Style",Georgia,serif;--sans:"IBM Plex Sans","Segoe UI",system-ui,sans-serif;--ease:cubic-bezier(.22,.8,.24,1);--ok:#27a874;--bad:#d9535f;--warn:#dd9a2c;--bg:#f1f6fb;--pn:#fff;--tx:#17283a;--mu:#6b7f93;--ac:#2570c9;--ac2:#52b2f2;--o1:#7cc4f7;--o2:#9aa8ff;--shc:rgba(29,74,122,.14);--onac:#fff;color-scheme:light}
[data-theme=sage]{--bg:#eff7f3;--pn:#fff;--tx:#15302a;--mu:#6a8279;--ac:#1f7a64;--ac2:#5cc1a4;--o1:#8fd8bf;--o2:#d7e59a;--shc:rgba(21,70,56,.14)}
[data-theme=sunrise]{--bg:#fff6ec;--pn:#fffdfa;--tx:#3a2415;--mu:#8d7261;--ac:#c4601f;--ac2:#f0a05a;--o1:#ffc48a;--o2:#ff9aa2;--shc:rgba(120,64,20,.14)}
[data-theme=lavender]{--bg:#f5f3fc;--pn:#fff;--tx:#231d3d;--mu:#7a739b;--ac:#6252c0;--ac2:#a094ee;--o1:#c3b8ff;--o2:#9ad3ff;--shc:rgba(60,45,130,.14)}
[data-theme=arctic]{--bg:#eef8fb;--pn:#fff;--tx:#0f2f3a;--mu:#5f8591;--ac:#0e87a8;--ac2:#4fd3e6;--o1:#8fe6f2;--o2:#a9c4ff;--shc:rgba(14,100,125,.14)}
[data-theme=rose]{--bg:#fdf1f4;--pn:#fffafb;--tx:#3a1722;--mu:#94707c;--ac:#c8365f;--ac2:#f27c9b;--o1:#ffb0c4;--o2:#ffd29a;--shc:rgba(140,30,64,.14)}
[data-theme=midnight]{--bg:#0f1a2b;--pn:#172640;--tx:#eaf3ff;--mu:#8fa6bf;--ac:#66b5f5;--ac2:#8dd0ff;--o1:#2f6fb3;--o2:#5b4bd6;--shc:rgba(0,0,0,.5);--onac:#07192b;color-scheme:dark}
[data-theme=graphite]{--bg:#14181d;--pn:#1e252c;--tx:#eef3f6;--mu:#96a6b3;--ac:#5fcfb9;--ac2:#8ae9d6;--o1:#1f8f7a;--o2:#3b6ea8;--shc:rgba(0,0,0,.5);--onac:#04201a;color-scheme:dark}
[data-theme=forest]{--bg:#0d1512;--pn:#14201b;--tx:#e9f4ee;--mu:#8ea89b;--ac:#54c48a;--ac2:#9bf0bd;--o1:#1f7a52;--o2:#b7a24a;--shc:rgba(0,0,0,.55);--onac:#052013;color-scheme:dark}
[data-theme=aurora]{--bg:#0b0f1f;--pn:#141a33;--tx:#ecf0ff;--mu:#98a3cc;--ac:#7f8cff;--ac2:#5fe3d0;--o1:#5b4bd6;--o2:#1cbfa8;--shc:rgba(0,0,0,.55);--onac:#0a0f2a;color-scheme:dark}
[data-theme=ember]{--bg:#17100d;--pn:#211713;--tx:#fbefe6;--mu:#b09a8b;--ac:#f08a3c;--ac2:#ffc274;--o1:#c2410c;--o2:#9f1239;--shc:rgba(0,0,0,.55);--onac:#231105;color-scheme:dark}
[data-theme=royal]{--bg:#0f1020;--pn:#191a33;--tx:#f1eeff;--mu:#a29fc8;--ac:#e0b457;--ac2:#f6d98c;--o1:#5a3fd1;--o2:#b8860b;--shc:rgba(0,0,0,.55);--onac:#221905;color-scheme:dark}
html,body{--ln:color-mix(in srgb,var(--tx) 11%,transparent);--ln2:color-mix(in srgb,var(--tx) 22%,transparent);--p2:color-mix(in srgb,var(--pn) 94%,var(--tx));--p3:color-mix(in srgb,var(--pn) 87%,var(--tx));--tx2:color-mix(in srgb,var(--tx) 78%,var(--pn));--as:color-mix(in srgb,var(--ac) 14%,transparent);--al:color-mix(in srgb,var(--ac) 38%,transparent);--gl:color-mix(in srgb,var(--ac) 26%,transparent);--ac3:color-mix(in srgb,var(--ac) 78%,#000);--sh:0 14px 40px var(--shc)}
*,*::before,*::after{box-sizing:border-box}
html{height:100%;font-size:clamp(14px,.3vw + 12px,17px);-webkit-text-size-adjust:100%}
body{margin:0;height:100%;overflow:hidden;background:var(--bg);color:var(--tx);font:400 1rem/1.45 var(--sans);-webkit-font-smoothing:antialiased;text-rendering:optimizeLegibility}
html.tt *,html.tt *::before,html.tt *::after{transition:background-color .5s,color .5s,border-color .5s,box-shadow .5s,fill .5s!important}
body::before{content:"";position:fixed;inset:0;pointer-events:none;background-image:linear-gradient(var(--ln) 1px,transparent 1px),linear-gradient(90deg,var(--ln) 1px,transparent 1px);background-size:3.4rem 3.4rem;opacity:.55;-webkit-mask-image:radial-gradient(ellipse at 50% 0,#000,transparent 75%);mask-image:radial-gradient(ellipse at 50% 0,#000,transparent 75%)}
body::after{content:"";position:fixed;top:-12rem;right:-10rem;width:34rem;height:34rem;border-radius:50%;pointer-events:none;background:radial-gradient(circle,var(--o1),transparent 65%);opacity:.38;filter:blur(30px);animation:drift 18s ease-in-out infinite alternate}
.dashboard{position:relative;height:100%;padding:clamp(.45rem,.9vw,1rem);overflow:hidden}
.dashboard::before{content:"";position:absolute;bottom:-12rem;left:-9rem;width:32rem;height:32rem;border-radius:50%;pointer-events:none;background:radial-gradient(circle,var(--o2),transparent 65%);opacity:.3;filter:blur(30px);animation:drift 22s ease-in-out infinite alternate-reverse}
.dashboard-shell{position:relative;z-index:1;width:100%;max-width:112rem;height:100%;margin:0 auto;display:flex;flex-direction:column;gap:clamp(.45rem,.8vw,.9rem)}
.panel{position:relative;min-height:0;background:color-mix(in srgb,var(--pn) 90%,transparent);border:1px solid var(--ln);border-radius:1rem;box-shadow:var(--sh);-webkit-backdrop-filter:blur(18px) saturate(130%);backdrop-filter:blur(18px) saturate(130%);overflow:hidden;animation:rise .75s var(--ease) backwards;transition:border-color .3s,box-shadow .3s,background-color .4s}
.panel::after{content:"";position:absolute;inset:0;border-radius:inherit;pointer-events:none;opacity:0;transition:opacity .35s;background:radial-gradient(22rem circle at var(--mx,50%) var(--my,50%),var(--gl),transparent 70%)}
.panel:hover{border-color:var(--ln2)}.panel:hover::after{opacity:.8}
.topbar{display:flex;align-items:center;justify-content:space-between;gap:1rem;padding:.6rem 1rem;animation-name:drop}
.topbar::before{content:"";position:absolute;left:0;right:0;bottom:0;height:2px;background:linear-gradient(90deg,transparent,var(--ac),var(--ac2),transparent);background-size:200% 100%;animation:flow 6s linear infinite}
.brand{display:flex;align-items:center;gap:.7rem;min-width:0}
.brand-mark{width:2.6rem;height:2.6rem;display:grid;place-items:center;flex:0 0 auto;border-radius:.8rem;color:var(--onac);font-weight:700;letter-spacing:.04em;background:linear-gradient(135deg,var(--ac),var(--ac2));animation:markGlow 3.4s ease-in-out infinite,pop .7s var(--ease) backwards}
.brand h1{margin:0;font:600 1.3rem/1.1 var(--serif);letter-spacing:-.02em}
.brand p{margin:.15rem 0 0;color:var(--mu);font-size:.78rem}
.top-actions{display:flex;align-items:center;justify-content:flex-end;gap:.5rem;flex-wrap:wrap;min-width:0}
#deleteAccountForm{margin:0;display:flex}
.btn,.theme-select{position:relative;overflow:hidden;display:inline-flex;align-items:center;justify-content:center;gap:.4rem;height:2.4rem;padding:0 .9rem;border:1px solid var(--ln2);border-radius:.65rem;background:var(--pn);color:var(--tx2);font:500 .86rem var(--sans);text-decoration:none;cursor:pointer;transition:transform .22s var(--ease),border-color .22s,color .22s,background-color .22s,box-shadow .22s}
.btn:hover,.theme-select:hover{transform:translateY(-2px);border-color:var(--al);color:var(--ac);background:var(--as);box-shadow:0 8px 20px var(--gl)}
.btn:active{transform:scale(.97)}
.theme-select{padding-right:.4rem;max-width:11rem;outline:none}
.theme-select:focus{border-color:var(--ac);box-shadow:0 0 0 3px var(--gl)}
.ai-launch{color:var(--ac);border-color:var(--al);background:var(--as)}
.ai-launch::after{content:"";position:absolute;inset:0;background:linear-gradient(105deg,transparent,color-mix(in srgb,var(--ac2) 45%,transparent),transparent);transform:translateX(-120%);animation:sweep 5s ease-in-out infinite}
.btn-danger{color:var(--bad);border-color:color-mix(in srgb,var(--bad) 35%,transparent);background:color-mix(in srgb,var(--bad) 9%,transparent)}
.btn-danger:hover{color:var(--bad);border-color:var(--bad);background:color-mix(in srgb,var(--bad) 16%,transparent);box-shadow:0 8px 20px color-mix(in srgb,var(--bad) 25%,transparent)}
:is(a,button,input,select,textarea,label.tool-btn):focus-visible{outline:2px solid var(--ac);outline-offset:2px}
.status{display:flex;align-items:center;gap:.45rem;height:2.4rem;padding:0 .8rem;border:1px solid var(--ln);border-radius:.65rem;background:var(--p2);color:var(--tx2);font-size:.82rem;font-variant-numeric:tabular-nums}
.status-dot,.online-label i{display:inline-block;width:.5rem;height:.5rem;border-radius:50%;background:var(--ok);animation:pulse 2.4s infinite}
.account{display:flex;align-items:center;gap:.55rem;min-width:0}
.account-avatar,.avatar{display:grid;place-items:center;flex:0 0 auto;width:2.3rem;height:2.3rem;border-radius:50%;color:var(--ac);background:linear-gradient(135deg,color-mix(in srgb,var(--ac) 26%,var(--pn)),color-mix(in srgb,var(--ac2) 26%,var(--pn)));font-size:.78rem;font-weight:600}
.account-avatar{color:var(--onac);background:linear-gradient(135deg,var(--ac),var(--ac2))}
.account-name{font-size:.86rem;font-weight:600;line-height:1.2}
.account-email{max-width:12rem;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--mu);font-size:.72rem}
.notification-stack{display:grid;gap:.5rem;flex:0 0 auto;max-height:28vh;overflow:auto}
.notification-card{--nc:var(--ac);position:relative;display:flex;align-items:flex-start;gap:.75rem;padding:.75rem 2.4rem .75rem 1rem;border:1px solid color-mix(in srgb,var(--nc) 30%,transparent);border-radius:.8rem;background:color-mix(in srgb,var(--nc) 9%,var(--pn));box-shadow:var(--sh);overflow:hidden;animation:drop .5s var(--ease) both}
.notification-card::before{content:"";position:absolute;inset:0 auto 0 0;width:4px;background:linear-gradient(var(--nc),color-mix(in srgb,var(--nc) 50%,#fff),var(--nc));background-size:100% 200%;animation:flowY 3s linear infinite}
.notification-card.success{--nc:var(--ok)}.notification-card.warning,.notification-card.maintenance{--nc:var(--warn)}
.notification-badge{width:1.9rem;height:1.9rem;display:grid;place-items:center;flex:0 0 auto;border-radius:.6rem;color:var(--nc);background:color-mix(in srgb,var(--nc) 16%,transparent);font-weight:800}
.notification-card strong{display:block;font-size:.85rem}.notification-card p{margin:.15rem 0 0;color:var(--tx2);font-size:.8rem}.notification-card small{display:block;margin-top:.2rem;color:var(--mu);font-size:.7rem}
.notification-dismiss{position:absolute;top:.5rem;right:.6rem;width:1.6rem;height:1.6rem;border:0;border-radius:50%;color:var(--mu);background:transparent;font-size:1.1rem;line-height:1;cursor:pointer;transition:.2s}
.notification-dismiss:hover{color:var(--tx);background:var(--as);transform:rotate(90deg)}
.workspace{min-height:0;flex:1;display:grid;grid-template-columns:clamp(16rem,22vw,23rem) minmax(0,1fr) clamp(13rem,16vw,18rem);gap:clamp(.45rem,.8vw,.9rem)}
.sidebar,.conversation,.insights{min-height:0;display:flex;flex-direction:column}
.sidebar{animation-name:slide;animation-delay:.08s}.conversation{animation-delay:.14s}.insights{animation-name:slideR;animation-delay:.2s}
.section-header,.conversation-header{flex:0 0 auto;padding:.9rem 1.05rem;border-bottom:1px solid var(--ln)}
.section-title{display:flex;align-items:center;justify-content:space-between;gap:.5rem}
.section-title h2,.conversation-header h2,.insights h2{margin:0;font:600 1.08rem/1.2 var(--serif);letter-spacing:-.01em}
.section-title span,.thread-badge{padding:.22rem .6rem;border-radius:99px;color:var(--ac);background:var(--as);font-size:.7rem;font-weight:600;white-space:nowrap}
.section-header p{margin:.2rem 0 0;color:var(--mu);font-size:.78rem}
.search-box{position:relative;flex:0 0 auto;margin:.8rem 1rem .5rem}
.search-box span{position:absolute;left:.7rem;top:50%;display:grid;place-items:center;transform:translateY(-50%);color:var(--mu);pointer-events:none}
.search-box span svg{width:1rem;height:1rem}
.search-box input,.history-input,.ai-form input,textarea{width:100%;border:1px solid var(--ln);border-radius:.65rem;outline:none;background:var(--p2);color:var(--tx);font:inherit;font-size:.88rem;transition:border-color .2s,box-shadow .2s,background-color .3s,transform .2s}
.search-box input{padding:.62rem .75rem .62rem 2.2rem}
.history-input{margin-top:.45rem;padding:.6rem .7rem;font-size:.82rem}
.search-box input:focus,.history-input:focus,.ai-form input:focus,.composer-box:focus-within{border-color:var(--ac);box-shadow:0 0 0 3px var(--gl)}
.search-box input:focus,.history-input:focus,.ai-form input:focus{transform:translateY(-1px);background:var(--pn)}
::placeholder{color:var(--mu);opacity:.85}
.groups-section{flex:0 0 auto;padding:.5rem 1rem .6rem;border-bottom:1px solid var(--ln)}
.groups-head{display:flex;align-items:center;justify-content:space-between;min-height:1.9rem;color:var(--mu);font-size:.78rem}
.new-group{width:1.9rem;height:1.9rem;display:grid;place-items:center;padding:0;border:1px solid var(--al);border-radius:.55rem;color:var(--ac);background:transparent;font-size:1.25rem;line-height:1;cursor:pointer;transition:transform .3s var(--ease),background-color .2s}
.new-group:hover{background:var(--as);transform:rotate(90deg) scale(1.08)}
#groupList{max-height:7.5rem;overflow:auto}
.contact-list{flex:1 1 auto;min-height:0;overflow-x:hidden;overflow-y:auto;padding:.4rem .6rem .8rem}
.contact-item{position:relative;overflow:hidden;display:flex;align-items:flex-start;gap:.65rem;width:100%;min-width:0;margin:.15rem 0;padding:.65rem .55rem;border:1px solid transparent;border-radius:.8rem;background:transparent;color:var(--tx);font:inherit;text-align:left;text-decoration:none;cursor:pointer;animation:slide .55s var(--ease) backwards;animation-delay:calc(var(--i,0)*45ms + .2s);transition:transform .25s var(--ease),background-color .2s,border-color .2s}
.contact-item::before{content:"";position:absolute;left:0;top:22%;bottom:22%;width:3px;border-radius:0 3px 3px 0;background:linear-gradient(var(--ac2),var(--ac));transform:scaleY(0);transition:transform .3s var(--ease)}
.contact-item:hover{background:var(--p2);border-color:var(--ln);transform:translateX(3px)}
.contact-item.active{background:var(--as);border-color:var(--al)}.contact-item.active::before{transform:scaleY(1)}
.contact-item.active .avatar{color:var(--onac);background:linear-gradient(135deg,var(--ac),var(--ac2))}
.contact-copy{display:block;min-width:0;flex:1;overflow:hidden}
.contact-head{display:flex;align-items:center;justify-content:space-between;gap:.5rem;min-width:0}
.contact-head strong{min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:.88rem}
.contact-time{flex:0 0 auto;max-width:45%;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--mu);font-size:.68rem}
.contact-email,.contact-preview{display:block;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--mu);font-size:.74rem}
.contact-preview{margin-top:.1rem;color:var(--tx2)}
.empty-state{display:grid;place-items:center;align-content:center;min-height:14rem;height:100%;padding:2rem;text-align:center;color:var(--mu)}
.empty-state strong{display:block;margin:.9rem 0 .25rem;color:var(--tx);font:600 1.1rem var(--serif)}
.empty-state p{margin:0;font-size:.85rem}
.empty-icon{position:relative;width:3.6rem;height:3.6rem;display:grid;place-items:center;margin:auto;border-radius:1.1rem;color:var(--ac);background:var(--as);animation:floatY 4s ease-in-out infinite}
.empty-icon::after{content:"";position:absolute;inset:0;border-radius:inherit;border:1px solid var(--ac);animation:ring 2.8s ease-out infinite}
.empty-icon svg{width:1.6rem;height:1.6rem}
.conversation-header{display:flex;align-items:center;justify-content:space-between;gap:.8rem}
.chat-person{display:flex;align-items:center;gap:.7rem;min-width:0}
.chat-person h2{font-size:1rem}.chat-person p{margin:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--mu);font-size:.76rem}
.online-label{display:flex;align-items:center;gap:.35rem;color:var(--ok);font-size:.72rem}
.message-stream{flex:1 1 auto;min-height:0;overflow:auto;padding:1.1rem 1.3rem 1.4rem;background:radial-gradient(color-mix(in srgb,var(--tx) 7%,transparent) 1px,transparent 1px) 0 0/1.4rem 1.4rem,color-mix(in srgb,var(--bg) 60%,var(--pn))}
.message-row{display:flex;gap:.6rem;margin:.9rem 0;animation:msg .45s var(--ease) both}
.message-row.mine{flex-direction:row-reverse}
.message-row>div:last-child,.message-row>.bubble{max-width:min(74%,40rem)}
.bubble{position:relative;padding:.7rem .9rem;border:1px solid var(--ln);border-radius:1rem 1rem 1rem .3rem;background:var(--pn);color:var(--tx);font-size:.92rem;box-shadow:0 6px 16px var(--shc);transition:transform .25s var(--ease),box-shadow .25s;outline:none}
.bubble:hover,.bubble:focus-within{transform:translateY(-1px);box-shadow:0 10px 22px var(--shc)}
.mine .bubble{border:0;border-radius:1rem 1rem .3rem 1rem;color:var(--onac);background:linear-gradient(135deg,var(--ac),var(--ac3));box-shadow:0 10px 24px var(--gl)}
.bubble p{margin:0;white-space:pre-wrap;overflow-wrap:anywhere}
.bubble-toolbar{display:flex;justify-content:flex-end;gap:.6rem;min-height:0}
.bubble-actions{display:flex;gap:.5rem;height:0;opacity:0;overflow:hidden;transition:opacity .2s,height .2s}
.bubble:hover .bubble-actions,.bubble:focus-within .bubble-actions{height:1.2rem;opacity:1;margin-bottom:.15rem}
.message-action{border:0;padding:0;background:transparent;color:inherit;opacity:.8;font:500 .7rem var(--sans);cursor:pointer;transition:opacity .2s,transform .2s}
.message-action:hover{opacity:1;transform:translateY(-1px);text-decoration:underline}
.bubble-time{display:block;margin-top:.4rem;color:var(--mu);font-size:.68rem}
.mine .bubble-time{color:color-mix(in srgb,var(--onac) 72%,transparent)}
.attachment-card{margin-top:.5rem;padding:.5rem;border:1px solid color-mix(in srgb,currentColor 20%,transparent);border-radius:.7rem;background:color-mix(in srgb,currentColor 7%,transparent)}
.attachment-thumb{display:block;max-width:100%;max-height:14rem;border-radius:.55rem;object-fit:cover}
.attachment-meta{display:flex;flex-direction:column;margin-top:.35rem;font-size:.78rem}.attachment-meta span{opacity:.7;font-size:.7rem}
.attachment-link{display:none!important}
.message-stream,.bubble,.bubble p,.bubble-time,.attachment-card{-webkit-user-select:none;user-select:none}
.reaction-picker{display:none;position:absolute;z-index:20;right:.55rem;top:-2.8rem;gap:3px;padding:5px 6px;border:1px solid var(--ln2);border-radius:999px;background:var(--pn);box-shadow:0 10px 28px var(--shc);white-space:nowrap;animation:pop .25s var(--ease)}
.bubble:hover .reaction-picker,.bubble:focus-within .reaction-picker,.bubble:focus .reaction-picker{display:flex}
.reaction-button{width:2rem;height:2rem;padding:0;border:0;border-radius:50%;background:transparent;cursor:pointer;font-size:1.15rem;line-height:1;transition:transform .16s,background-color .16s}
.reaction-button:hover,.reaction-button:focus-visible{background:var(--as);transform:scale(1.25) translateY(-2px);outline:none}
.reaction-badge{position:absolute;z-index:6;left:.7rem;bottom:-.75rem;min-width:1.6rem;height:1.6rem;display:grid;place-items:center;padding:0 .4rem;border:2px solid var(--pn);border-radius:999px;background:var(--p2);box-shadow:0 3px 9px var(--shc);font-size:.9rem;animation:pop .3s var(--ease)}
.mine .reaction-badge{left:auto;right:.7rem}
.composer{flex:0 0 auto;padding:.7rem 1.05rem .9rem;border-top:1px solid var(--ln);background:color-mix(in srgb,var(--pn) 92%,transparent)}
.composer-box{padding:.5rem;border:1px solid var(--ln);border-radius:.9rem;background:var(--p2);transition:border-color .2s,box-shadow .2s}
textarea{display:block;min-height:3.6rem;max-height:7rem;resize:vertical;padding:.6rem .7rem;border:0;border-radius:.6rem;background:transparent;font-size:.92rem}
textarea:focus{box-shadow:none;transform:none;background:transparent}
textarea:disabled{cursor:not-allowed;opacity:.6}
.composer-bottom{display:flex;align-items:center;justify-content:space-between;gap:.7rem;padding-top:.4rem}
.composer-tools{display:flex;align-items:center;gap:.45rem;min-width:0}
.tool-btn{width:2.2rem;height:2.2rem;display:grid;place-items:center;flex:0 0 auto;padding:0;border:1px solid var(--ln2);border-radius:.6rem;background:var(--pn);color:var(--tx2);font-size:1rem;cursor:pointer;transition:transform .22s var(--ease),border-color .2s,color .2s,background-color .2s}
.tool-btn:hover{color:var(--ac);border-color:var(--al);background:var(--as);transform:translateY(-2px) rotate(-6deg)}
.tool-btn svg{width:1.05rem;height:1.05rem}
.attachment-input{display:none}
.attachment-chip{max-width:12rem;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--mu);font-size:.74rem}
.attachment-chip.selected{color:var(--ac);font-weight:500}
.attachment-clear{border:0;padding:0 .3rem;color:var(--bad);background:transparent;font-size:1.2rem;cursor:pointer;transition:transform .2s}
.attachment-clear:hover{transform:scale(1.2)}
.send-btn{position:relative;overflow:hidden;height:2.5rem;padding:0 1.2rem;border:0;border-radius:.7rem;color:var(--onac);font:600 .9rem var(--sans);cursor:pointer;background:linear-gradient(110deg,var(--ac),var(--ac2),var(--ac));background-size:220% 100%;box-shadow:0 10px 24px var(--gl);animation:sheen 6s linear infinite;transition:transform .22s var(--ease),box-shadow .22s}
.send-btn::after{content:"";position:absolute;inset:0;background:linear-gradient(105deg,transparent,rgba(255,255,255,.4),transparent);transform:translateX(-120%);animation:sweep 4.5s ease-in-out infinite}
.send-btn:hover{transform:translateY(-2px);box-shadow:0 14px 28px var(--gl)}.send-btn:active{transform:scale(.96)}
.insights{animation-name:slideR}
.insights-content{flex:1 1 auto;min-height:0;overflow:auto;padding:.9rem}
.workspace-status{display:flex;align-items:center;gap:.65rem;padding:.7rem;border:1px solid color-mix(in srgb,var(--ok) 30%,transparent);border-radius:.8rem;background:color-mix(in srgb,var(--ok) 9%,transparent)}
.workspace-status-icon{width:1.9rem;height:1.9rem;display:grid;place-items:center;border-radius:.55rem;color:var(--ok);background:color-mix(in srgb,var(--ok) 18%,transparent);animation:pulse 2.6s infinite}
.workspace-status strong,.workspace-status span{display:block}.workspace-status strong{font-size:.82rem}.workspace-status span{margin-top:.1rem;color:var(--mu);font-size:.72rem}
.metric{padding:.8rem 0;border-bottom:1px solid var(--ln)}
.metric-label{color:var(--mu);font-size:.72rem;letter-spacing:.02em}
.metric-value{margin-top:.25rem;font-size:.9rem;font-weight:600;overflow-wrap:anywhere}
.metric-number{color:var(--ac);font:600 1.5rem/1.1 var(--serif);font-variant-numeric:tabular-nums}
.insight-divider{height:1px;margin:.4rem 0;background:var(--ln)}
.ai-panel{position:fixed;z-index:30;top:clamp(.4rem,1vw,1.1rem);right:clamp(.4rem,1vw,1.1rem);bottom:clamp(.4rem,1vw,1.1rem);width:min(25rem,calc(100vw - .8rem));max-height:46rem;display:flex;flex-direction:column;padding:1.05rem;border:1px solid var(--ln2);border-radius:1.1rem;background:var(--pn);box-shadow:0 30px 80px var(--shc);transform:translateX(125%);transition:transform .45s var(--ease)}
.ai-panel.open{transform:none}
.ai-head{display:flex;align-items:flex-start;gap:.6rem;padding-bottom:.9rem;border-bottom:1px solid var(--ln)}
.ai-head>div{flex:1;min-width:0}
.ai-kicker{color:var(--ac);font-size:.72rem;font-weight:600}
.ai-head h2{margin:.2rem 0;font:600 1.2rem var(--serif)}.ai-head p{margin:0;color:var(--mu);font-size:.78rem}
.ai-close{border:0;background:transparent;color:var(--mu);font-size:1.5rem;line-height:1;cursor:pointer;transition:transform .3s}
.ai-close:hover{color:var(--tx);transform:rotate(90deg)}
.ai-reset{padding:.4rem .6rem;border:1px solid var(--ln2);border-radius:.55rem;color:var(--mu);background:var(--p2);font:inherit;font-size:.72rem;cursor:pointer;transition:.2s}
.ai-reset:hover{color:var(--ac);border-color:var(--al);background:var(--as)}
.ai-suggestions{display:flex;gap:.4rem;flex-wrap:wrap;padding:.8rem 0}
.ai-suggestions button{padding:.4rem .65rem;border:1px solid var(--ln2);border-radius:99px;background:var(--p2);color:var(--tx2);font:inherit;font-size:.74rem;cursor:pointer;transition:transform .2s var(--ease),border-color .2s,color .2s,background-color .2s}
.ai-suggestions button:hover{color:var(--ac);border-color:var(--al);background:var(--as);transform:translateY(-2px)}
.ai-messages{flex:1;min-height:0;overflow:auto;padding:.4rem 0}
.ai-message{margin:.5rem 0;padding:.65rem .8rem;border-radius:.8rem .8rem .8rem .2rem;background:var(--p2);font-size:.84rem;animation:msg .4s var(--ease) both;overflow-wrap:anywhere}
.ai-message.user{margin-left:1.8rem;border-radius:.8rem .8rem .2rem .8rem;color:var(--onac);background:linear-gradient(135deg,var(--ac),var(--ac3))}
.ai-form{display:flex;gap:.45rem;padding-top:.8rem;border-top:1px solid var(--ln)}
.ai-form input{padding:.65rem .75rem}
.ai-form button{padding:0 1rem;border:0;border-radius:.65rem;color:var(--onac);background:linear-gradient(135deg,var(--ac),var(--ac2));font:600 .85rem var(--sans);cursor:pointer;transition:transform .2s,box-shadow .2s}
.ai-form button:hover{transform:translateY(-2px);box-shadow:0 8px 18px var(--gl)}
.ai-scrim{position:fixed;inset:0;z-index:20;background:color-mix(in srgb,var(--bg) 50%,transparent);-webkit-backdrop-filter:blur(3px);backdrop-filter:blur(3px);opacity:0;pointer-events:none;transition:opacity .35s}
.ai-panel.open+.ai-scrim{opacity:1;pointer-events:auto}
*{scrollbar-width:thin;scrollbar-color:var(--ln2) transparent}
@keyframes rise{from{opacity:0;transform:translateY(22px) scale(.99)}}
@keyframes drop{from{opacity:0;transform:translateY(-16px)}}
@keyframes slide{from{opacity:0;transform:translateX(-18px)}}
@keyframes slideR{from{opacity:0;transform:translateX(18px)}}
@keyframes msg{from{opacity:0;transform:translateY(12px) scale(.98)}}
@keyframes pop{from{opacity:0;transform:scale(.6)}}
@keyframes drift{to{transform:translate(-3rem,2rem) scale(1.15)}}
@keyframes flow{to{background-position:200% 0}}
@keyframes flowY{to{background-position:0 200%}}
@keyframes sheen{to{background-position:220% 0}}
@keyframes sweep{0%,45%{transform:translateX(-120%)}75%,100%{transform:translateX(120%)}}
@keyframes pulse{0%{box-shadow:0 0 0 0 color-mix(in srgb,var(--ok) 55%,transparent)}70%{box-shadow:0 0 0 .55rem transparent}100%{box-shadow:0 0 0 0 transparent}}
@keyframes markGlow{0%,100%{box-shadow:0 8px 20px var(--gl)}50%{box-shadow:0 8px 32px var(--ac)}}
@keyframes floatY{0%,100%{transform:translateY(0)}50%{transform:translateY(-8px)}}
@keyframes ring{0%{opacity:.7;transform:scale(.9)}100%{opacity:0;transform:scale(1.5)}}
@media(max-width:1200px){.workspace{grid-template-columns:clamp(15rem,30vw,21rem) minmax(0,1fr)}.insights{display:none}.account-email{max-width:8rem}}
@media(max-width:980px){.account>div:last-child,.brand p{display:none}.theme-select{max-width:9rem}}
@media(max-width:860px){body{overflow-y:auto}.dashboard{height:auto;min-height:100dvh;overflow:visible}.dashboard-shell{height:auto;min-height:calc(100dvh - 1rem)}.topbar{position:sticky;top:.4rem;z-index:12;flex-wrap:wrap}.workspace{display:flex;flex-direction:column;flex:none}.sidebar{max-height:42dvh}.conversation{height:calc(100dvh - 6rem);min-height:30rem}.thread-badge{display:none}.message-stream{padding:1rem .9rem}.message-row>div:last-child,.message-row>.bubble{max-width:88%}.composer{padding:.6rem .6rem .75rem}}
@media(max-width:560px){.top-actions{width:100%;justify-content:flex-start;gap:.4rem}.theme-select{flex:1;max-width:none;min-width:8rem}.btn{padding:0 .7rem}.status span:last-child{display:none}.brand-mark{width:2.3rem;height:2.3rem}.brand h1{font-size:1.1rem}.ai-launch{font-size:0;width:2.4rem;padding:0}.ai-launch::before{content:"âœ¦";font-size:1rem}.attachment-chip{max-width:6.5rem}.ai-panel{top:.4rem;right:.4rem;bottom:.4rem;width:calc(100vw - .8rem);max-height:none}}
@media(max-height:660px) and (min-width:861px){.section-header p{display:none}#groupList{max-height:4.5rem}.metric{padding:.55rem 0}.message-stream{padding-top:.7rem}}
@media(min-width:1900px){.dashboard-shell{max-width:120rem}}
@media(prefers-reduced-motion:reduce){*,*::before,*::after{animation-duration:.01ms!important;animation-delay:0s!important;animation-iteration-count:1!important;transition-duration:.01ms!important;scroll-behavior:auto!important}}
</style>
</head>

<body>

<div
    class="dashboard"
    data-context-path="<%= contextPath %>"
    data-user-id="<%= userId %>"
    data-current-user-name="<%= WebUtil.escapeHtml(username) %>"
    data-current-user-email="<%= WebUtil.escapeHtml(email) %>"
    data-active-contact-id="<%= activeContactId %>"
>

<div class="dashboard-shell">

<header class="panel topbar">

    <div class="brand">
        <div class="brand-mark">TC</div>
        <div>
            <h1>TeamConnect</h1>
            <p>Enterprise communication workspace</p>
        </div>
    </div>

    <div class="top-actions">

        <select class="theme-select" id="themeSelect" aria-label="Choose interface theme">
            <optgroup label="Light themes">
                <option value="blue">Ocean blue</option>
                <option value="sage">Sage green</option>
                <option value="sunrise">Warm sunrise</option>
                <option value="lavender">Soft lavender</option>
                <option value="arctic">Arctic cyan</option>
                <option value="rose">Rose quartz</option>
            </optgroup>
            <optgroup label="Dark themes">
                <option value="midnight">Midnight navy</option>
                <option value="graphite">Graphite teal</option>
                <option value="forest">Forest night</option>
                <option value="aurora">Aurora violet</option>
                <option value="ember">Ember glow</option>
                <option value="royal">Royal gold</option>
            </optgroup>
        </select>

        <button class="btn ai-launch" type="button" onclick="toggleAiPanel()">âœ¦ AI Assistant</button>

        <div class="status">
            <span class="status-dot"></span>
            <span>Live</span>
            <span id="refreshClock">--:--</span>
        </div>

        <div class="account">
            <div class="account-avatar"><%= WebUtil.initials(username) %></div>
            <div>
                <div class="account-name"><%= WebUtil.escapeHtml(username) %></div>
                <div class="account-email"><%= WebUtil.escapeHtml(email) %></div>
            </div>
        </div>

        <a class="btn" href="<%= Boolean.TRUE.equals(session.getAttribute("adminAuthenticated")) ? contextPath + "/admin" : contextPath + "/ems" %>">Back to dashboard</a>

    </div>

</header>

<% if (!notifications.isEmpty()) { %>
<section class="notification-stack" aria-label="Notifications">
    <% for (Map<String, Object> notification : notifications) { String notificationType = String.valueOf(notification.get("type")).toLowerCase(); %>
    <article class="notification-card <%= notificationType %>">
        <div class="notification-badge"><%= "SUCCESS".equalsIgnoreCase(String.valueOf(notification.get("type"))) ? "âœ“" : "!" %></div>
        <div><strong><%= WebUtil.escapeHtml(String.valueOf(notification.get("title"))) %></strong><p><%= WebUtil.escapeHtml(String.valueOf(notification.get("message"))) %></p><small>From <%= WebUtil.escapeHtml(String.valueOf(notification.get("created_by"))) %> Â· <%= notification.get("created_at") %></small></div>
        <button class="notification-dismiss" type="button" aria-label="Dismiss notification" onclick="this.closest('.notification-card').remove()">Ã—</button>
    </article>
    <% } %>
</section>
<% } %>

<section class="workspace">

    <aside class="panel sidebar">

        <div class="section-header">
            <div class="section-title">
                <h2>Conversations</h2>
                <span><%= contactCount %> people</span>
            </div>
            <p>Select a teammate to start chatting.</p>
        </div>

        <div class="search-box">
            <span>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>
            </span>
            <input id="contactSearch" type="search" placeholder="Search people...">
        </div>

        <div class="groups-section">
            <div class="groups-head">
                <strong>Group spaces</strong>
                <button class="new-group" type="button" onclick="createGroup()" title="Create group">+</button>
            </div>
            <div id="groupList">
                <% for (GroupChat group : groups) { %>
                <button
                    type="button"
                    class="contact-item"
                    data-group-id="<%= group.getId() %>"
                    onclick="openGroup(<%= group.getId() %>, '<%= WebUtil.escapeHtml(group.getName()).replace("'", "\\'") %>')"
                >
                    <div class="avatar">#</div>
                    <div class="contact-copy">
                        <strong><%= WebUtil.escapeHtml(group.getName()) %></strong>
                        <span class="contact-preview">Team workspace</span>
                    </div>
                </button>
                <% } %>
            </div>
        </div>

        <div class="contact-list" id="contactList">

            <% if (contacts.isEmpty()) { %>

            <div class="empty-state">
                <div>
                    <div class="empty-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    </div>
                    <strong>No contacts yet</strong>
                    <p>Registered teammates will appear here.</p>
                </div>
            </div>

            <% } else { %>

            <% for (User contact : contacts) { %>

            <button
                type="button"
                class="contact-item <%= activeContact != null && contact.getId() == activeContact.getId() ? "active" : "" %>"
                data-contact-id="<%= contact.getId() %>"
                data-contact-name="<%= WebUtil.escapeHtml(contact.getUsername()) %>"
                data-contact-email="<%= WebUtil.escapeHtml(contact.getEmail()) %>"
                data-contact-preview="<%= WebUtil.escapeHtml(contact.getLastMessagePreview() != null ? contact.getLastMessagePreview() : "") %>"
            >
                <div class="avatar"><%= WebUtil.initials(contact.getUsername()) %></div>
                <div class="contact-copy">
                    <div class="contact-head">
                        <strong><%= WebUtil.escapeHtml(contact.getUsername()) %></strong>
                        <span class="contact-time">
                            <%= contact.getLastMessageAt() != null
                                    ? WebUtil.escapeHtml(
                                        WebUtil.formatTimestamp(
                                            contact.getLastMessageAt()
                                        )
                                    )
                                    : "New" %>
                        </span>
                    </div>
                    <span class="contact-email"><%= WebUtil.escapeHtml(contact.getEmail()) %></span>
                    <span class="contact-preview">
                        <%= contact.getLastMessagePreview() != null
                                ? WebUtil.escapeHtml(
                                    contact.getLastMessagePreview()
                                )
                                : "No messages yet" %>
                    </span>
                </div>
            </button>

            <% } %>

            <% } %>

        </div>

    </aside>

    <section class="panel conversation">

        <div class="conversation-header">

            <div class="chat-person">
                <div class="avatar">
                    <%= activeContact != null
                            ? WebUtil.initials(activeContact.getUsername())
                            : "?" %>
                </div>
                <div>
                    <h2 id="activeContactName"><%= activeName %></h2>
                    <p id="activeContactMeta"><%= activeEmail %></p>
                    <% if (activeContact != null) { %>
                    <div class="online-label"><i></i>Workspace member</div>
                    <% } %>
                </div>
            </div>

            <div class="thread-badge" id="threadHint">
                <%= activeContact != null
                        ? "Conversation active"
                        : "No conversation selected" %>
            </div>

        </div>

        <div class="message-stream" id="messageStream">

            <% if (activeContact == null) { %>

            <div class="empty-state">
                <div>
                    <div class="empty-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H8l-5 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                    </div>
                    <strong>Welcome to TeamConnect</strong>
                    <p>Select a conversation from the sidebar.</p>
                </div>
            </div>

            <% } else if (messages.isEmpty()) { %>

            <div class="empty-state">
                <div>
                    <div class="empty-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="m22 2-7 20-4-9-9-4z"/><path d="M22 2 11 13"/></svg>
                    </div>
                    <strong>Start the conversation</strong>
                    <p>Send the first message to <%= activeName %>.</p>
                </div>
            </div>

            <% } else { %>

            <% for (Message message : messages) { %>

            <% boolean mine = message.getSenderId() == userId; %>

            <div class="message-row <%= mine ? "mine" : "" %>">

                <div
                    class="bubble"
                    tabindex="0"
                    data-message-id="<%= message.getId() %>"
                    data-message-text="<%= WebUtil.escapeHtml(message.getMessage()) %>"
                    data-owned="<%= mine %>"
                >

                    <div class="bubble-toolbar">
                        <div class="bubble-actions">
                            <% if (mine) { %>
                            <button type="button" class="message-action" data-action="edit">Edit</button>
                            <% } %>
                        </div>
                    </div>

                    <% if (
                        message.getMessage() != null &&
                        !message.getMessage().trim().isEmpty()
                    ) { %>
                    <p><%= WebUtil.escapeHtml(message.getMessage()) %></p>
                    <% } %>

                    <% if (message.hasAttachment()) { %>

                    <div class="attachment-card">

                        <% if (
                            util.AttachmentUtil.isImage(
                                message.getAttachmentKind()
                            )
                        ) { %>
                        <img
                            class="attachment-thumb"
                            src="<%= contextPath %><%= util.AttachmentUtil.downloadUrl(message.getId()) %>"
                            alt="<%= WebUtil.escapeHtml(message.getAttachmentName()) %>"
                        >
                        <% } %>

                        <div class="attachment-meta">
                            <strong><%= WebUtil.escapeHtml(message.getAttachmentName()) %></strong>
                            <span><%= WebUtil.humanReadableSize(message.getAttachmentSize()) %></span>
                        </div>

                        <a
                            class="attachment-link"
                            href="<%= contextPath %><%= util.AttachmentUtil.downloadUrl(message.getId()) %>"
                            target="_blank"
                            rel="noopener"
                        >Open attachment</a>

                    </div>

                    <% } %>

                    <span class="bubble-time">
                        <%= WebUtil.escapeHtml(
                            WebUtil.formatTimestamp(
                                message.getSentAt()
                            )
                        ) %>
                    </span>

                </div>

            </div>

            <% } %>

            <% } %>

        </div>

        <form class="composer" id="composerForm" autocomplete="off" enctype="multipart/form-data">

            <input
                type="hidden"
                id="receiverInput"
                name="receiver"
                value="<%= activeContactId > 0
                        ? String.valueOf(activeContactId)
                        : "" %>"
            >

            <input type="hidden" id="hasAttachmentInput" name="hasAttachment" value="0">

            <div class="composer-box">

                <textarea
                    id="messageInput"
                    name="message"
                    placeholder="<%= messagePlaceholder %>"
                    <%= activeContactId > 0 ? "" : "disabled" %>
                ></textarea>

                <div class="composer-bottom">

                    <div class="composer-tools">

                        <input
                            type="file"
                            id="attachmentInput"
                            name="attachment"
                            class="attachment-input"
                            accept="image/*,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.zip,.rar"
                        >

                        <label class="tool-btn" for="attachmentInput" title="Attach file">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m21.44 11.05-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"/></svg>
                        </label>

                        <span class="attachment-chip" id="attachmentLabel">No attachment</span>

                        <button type="button" class="tool-btn" id="pollButton" title="Create poll" aria-label="Create poll">â˜°</button>

                        <button type="button" class="attachment-clear" id="clearAttachmentButton" hidden aria-label="Remove attachment">Ã—</button>

                    </div>

                    <button class="send-btn" id="sendButton" type="submit">Send&nbsp; â†‘</button>

                </div>

            </div>

        </form>

    </section>

    <aside class="panel insights">

        <div class="section-header">
            <div class="section-title">
                <h2>Workspace</h2>
                <span>Insights</span>
            </div>
            <p>Current account and thread information.</p>
        </div>

        <div class="insights-content">

            <div class="workspace-status">
                <div class="workspace-status-icon">âœ“</div>
                <div>
                    <strong>Workspace online</strong>
                    <span>Secure session active</span>
                </div>
            </div>

            <div class="metric">
                <div class="metric-label">Account</div>
                <div class="metric-value"><%= WebUtil.escapeHtml(username) %></div>
            </div>

            <div class="metric">
                <div class="metric-label">Active thread</div>
                <div class="metric-value" id="insightThread">
                    <%= activeContact != null
                            ? WebUtil.escapeHtml(
                                activeContact.getUsername()
                            )
                            : "None selected" %>
                </div>
            </div>

            <div class="metric">
                <div class="metric-label">Messages</div>
                <div class="metric-value metric-number" id="insightCount"><%= messageCount %></div>
            </div>

            <div class="metric">
                <div class="metric-label">Team members</div>
                <div class="metric-value metric-number"><%= contactCount %></div>
            </div>

            <div class="insight-divider"></div>

            <div class="metric">
                <div class="metric-label">History search</div>
                <input id="historySearch" class="history-input" type="search" placeholder="Search messages...">
            </div>

        </div>

    </aside>

</section>

</div>

</div>

<aside class="ai-panel" id="aiPanel" aria-hidden="true">

    <div class="ai-head">

        <div>
            <span class="ai-kicker">Team intelligence</span>
            <h2>AI Assistant</h2>
            <p>Summarize conversations, draft replies, and organize your workspace.</p>
        </div>

        <button type="button" class="ai-reset" onclick="resetAiChat()" title="Clear AI conversation">Reset</button>

        <button type="button" class="ai-close" aria-label="Close assistant" onclick="toggleAiPanel()">Ã—</button>

    </div>

    <div class="ai-suggestions">
        <button type="button" onclick="useAiPrompt('Summarize my current conversation')">Summarize thread</button>
        <button type="button" onclick="useAiPrompt('Draft a professional reply')">Draft reply</button>
        <button type="button" onclick="useAiPrompt('Give me the key action items')">Action items</button>
    </div>

    <div class="ai-messages" id="aiMessages">
        <div class="ai-message assistant">
            AI Assistant is ready.
            <br><br>
            Groq AI is connected through the secure backend configuration.
        </div>
    </div>

    <form class="ai-form" onsubmit="sendAiMessage(event)">
        <input id="aiInput" placeholder="Ask your workspace assistant..." autocomplete="off">
        <button type="submit">Send</button>
    </form>

</aside>

<div class="ai-scrim"></div>

<script>

    function toggleAiPanel() {
        const panel = document.getElementById("aiPanel");
        const isOpen = panel.classList.toggle("open");
        panel.setAttribute("aria-hidden", String(!isOpen));
        if (isOpen) {
            setTimeout(() => {
                const input = document.getElementById("aiInput");
                if (input) input.focus();
            }, 400);
        }
    }

    function useAiPrompt(prompt) {
        const input = document.getElementById("aiInput");
        input.value = prompt;
        input.focus();
    }

    function resetAiChat() {
        const messages = document.getElementById("aiMessages");
        const input = document.getElementById("aiInput");
        if (!messages) return;
        messages.innerHTML = '<div class="ai-message assistant">AI Assistant is ready.<br><br>Groq AI is connected through the secure backend configuration.</div>';
        if (input) {
            input.value = "";
            input.focus();
        }
        messages.scrollTop = 0;
    }

    function sendAiMessage(event) {
        event.preventDefault();
        const input = document.getElementById("aiInput");
        const messages = document.getElementById("aiMessages");
        const value = input.value.trim();
        if (!value) return;
        const userMessage = document.createElement("div");
        userMessage.className = "ai-message user";
        userMessage.textContent = value;
        messages.appendChild(userMessage);
        input.value = "";
        messages.scrollTop = messages.scrollHeight;
    }

    function updateClock() {
        const clock = document.getElementById("refreshClock");
        if (!clock) return;
        clock.textContent = new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
    }

    const themeSelect = document.getElementById("themeSelect");
    const savedTheme = localStorage.getItem("teamconnect-theme") || "blue";
    document.body.dataset.theme = savedTheme;
    document.documentElement.dataset.theme = savedTheme;
    if (themeSelect) {
        themeSelect.value = savedTheme;
        themeSelect.addEventListener("change", function () {
            const root = document.documentElement;
            root.classList.add("tt");
            document.body.dataset.theme = this.value;
            root.dataset.theme = this.value;
            localStorage.setItem("teamconnect-theme", this.value);
            setTimeout(() => root.classList.remove("tt"), 700);
        });
    }

    updateClock();
    setInterval(updateClock, 30000);

    document.querySelectorAll("#groupList .contact-item, #contactList .contact-item").forEach((item, index) => {
        item.style.setProperty("--i", Math.min(index, 14));
    });

    document.querySelectorAll(".panel").forEach(panel => {
        panel.addEventListener("pointermove", event => {
            const box = panel.getBoundingClientRect();
            panel.style.setProperty("--mx", (event.clientX - box.left) + "px");
            panel.style.setProperty("--my", (event.clientY - box.top) + "px");
        });
    });

    const stream = document.getElementById("messageStream");
    if (stream) stream.scrollTop = stream.scrollHeight;

    const contactSearch = document.getElementById("contactSearch");

    if (contactSearch) {
        contactSearch.addEventListener("input", function () {
            const query = this.value.trim().toLowerCase();
            document.querySelectorAll("#contactList .contact-item").forEach(item => {
                const name = (item.dataset.contactName || "").toLowerCase();
                const email = (item.dataset.contactEmail || "").toLowerCase();
                const preview = (item.dataset.contactPreview || "").toLowerCase();
                item.style.display = (name.includes(query) || email.includes(query) || preview.includes(query)) ? "" : "none";
            });
        });
    }

    const historySearch = document.getElementById("historySearch");

    if (historySearch) {
        historySearch.addEventListener("input", function () {
            const query = this.value.trim().toLowerCase();
            document.querySelectorAll("#messageStream .message-row").forEach(row => {
                row.style.display = row.innerText.toLowerCase().includes(query) ? "" : "none";
            });
        });
    }

    const attachmentInput = document.getElementById("attachmentInput");
    const attachmentLabel = document.getElementById("attachmentLabel");
    const clearAttachmentButton = document.getElementById("clearAttachmentButton");

    if (attachmentInput) {
        attachmentInput.addEventListener("change", function () {
            if (!this.files.length) {
                attachmentLabel.textContent = "No attachment";
                clearAttachmentButton.hidden = true;
                return;
            }
            const file = this.files[0];
            attachmentLabel.textContent = file.name;
            clearAttachmentButton.hidden = false;
            attachmentLabel.classList.add("selected");
        });
    }

    if (clearAttachmentButton) {
        clearAttachmentButton.addEventListener("click", function () {
            attachmentInput.value = "";
            attachmentLabel.textContent = "No attachment";
            attachmentLabel.classList.remove("selected");
            this.hidden = true;
        });
    }

    document.addEventListener("keydown", function (event) {
        if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === "k") {
            event.preventDefault();
            if (contactSearch) {
                contactSearch.focus();
                contactSearch.select();
            }
        }
        if (event.key === "Escape") {
            const aiPanel = document.getElementById("aiPanel");
            if (aiPanel && aiPanel.classList.contains("open")) {
                toggleAiPanel();
            }
        }
    });

</script>

<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1.6.1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
<script src="<%= contextPath %>/assets/js/chat.js?v=2" defer></script>

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

