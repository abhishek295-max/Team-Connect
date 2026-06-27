<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="model.User,model.Message,java.util.List,util.WebUtil" %>
<%
    jakarta.servlet.http.HttpSession activeSession = request.getSession(false);
    if (activeSession == null || activeSession.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }

    Integer userId = (Integer) activeSession.getAttribute("userId");
    String username = (String) activeSession.getAttribute("username");
    String email = (String) activeSession.getAttribute("email");

    List<User> contacts = (List<User>) request.getAttribute("contacts");
    if (contacts == null) {
        contacts = java.util.Collections.emptyList();
    }

    User activeContact = (User) request.getAttribute("activeContact");

    List<Message> messages = (List<Message>) request.getAttribute("messages");
    if (messages == null) {
        messages = java.util.Collections.emptyList();
    }

    int contactCount = request.getAttribute("contactCount") != null
            ? (Integer) request.getAttribute("contactCount")
            : contacts.size();
    int messageCount = request.getAttribute("messageCount") != null
            ? (Integer) request.getAttribute("messageCount")
            : messages.size();

    int activeContactId = activeContact != null ? activeContact.getId() : 0;
    String contextPath = request.getContextPath();
    String messagePlaceholder = activeContactId > 0
            ? "Write a message..."
            : "Select a contact first";
    String threadHintText = activeContact != null
            ? "Messages refresh automatically while this thread is open."
            : "Choose a contact from the left panel.";
    String activeContactNameText = activeContact != null
            ? WebUtil.escapeHtml(activeContact.getUsername())
            : "Select a contact";
    String activeContactMetaText = activeContact != null
            ? WebUtil.escapeHtml(activeContact.getEmail())
            : "Pick a contact to begin a thread";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | Online Chat System</title>
    <style>
        :root {
            --bg-a: #17131a;
            --bg-b: #241a18;
            --glass: rgba(255, 255, 255, 0.08);
            --glass-strong: rgba(255, 255, 255, 0.14);
            --border: rgba(255, 255, 255, 0.16);
            --text: #fff7f0;
            --muted: rgba(255, 247, 240, 0.72);
            --accent: #f4b860;
            --accent-2: #44d8c0;
            --accent-3: #ff7d6b;
            --success: #3fe09a;
            --danger: #ff7e7e;
            --shadow: 0 24px 70px rgba(0, 0, 0, 0.28);
        }

        * { box-sizing: border-box; }

        html, body {
            margin: 0;
            min-height: 100%;
            font-family: "Segoe UI", Arial, sans-serif;
            color: var(--text);
            background:
                linear-gradient(135deg, rgba(244, 184, 96, 0.14), transparent 35%),
                linear-gradient(225deg, rgba(68, 216, 192, 0.12), transparent 30%),
                linear-gradient(180deg, var(--bg-a), var(--bg-b));
        }

        body { min-height: 100vh; }

        a { color: inherit; text-decoration: none; }
        button, input, textarea { font: inherit; }

        .dashboard {
            min-height: 100vh;
            padding: 18px;
        }

        .dashboard::before {
            content: "";
            position: fixed;
            inset: 0;
            background:
                radial-gradient(circle at 18% 18%, rgba(244, 184, 96, 0.10), transparent 28%),
                radial-gradient(circle at 82% 16%, rgba(68, 216, 192, 0.08), transparent 24%),
                radial-gradient(circle at 72% 82%, rgba(255, 125, 107, 0.08), transparent 28%);
            pointer-events: none;
        }

        .dashboard-shell {
            width: min(1480px, 100%);
            margin: 0 auto;
            display: grid;
            gap: 16px;
            grid-template-rows: auto auto 1fr;
            position: relative;
            z-index: 1;
        }

        .panel {
            border: 1px solid var(--border);
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            box-shadow: var(--shadow);
        }

        .topbar {
            padding: 16px 18px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            position: sticky;
            top: 16px;
            z-index: 8;
        }

        .brand-inline {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }

        .brand-mark {
            width: 46px;
            height: 46px;
            border-radius: 16px;
            display: grid;
            place-items: center;
            font-weight: 800;
            color: #06131f;
            background: linear-gradient(145deg, var(--accent-2), var(--accent));
            box-shadow: 0 12px 28px rgba(68, 216, 192, 0.22);
            flex: 0 0 auto;
        }

        .brand-inline h2 {
            margin: 0;
            font-size: 18px;
            line-height: 1.2;
        }

        .brand-inline .muted {
            margin-top: 4px;
            color: var(--muted);
            font-size: 13px;
            line-height: 1.5;
        }

        .topbar-meta {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .chip {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 12px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.12);
            color: var(--muted);
            font-size: 13px;
        }

        .chip strong {
            color: var(--text);
        }

        .chip-live {
            background: rgba(63, 224, 154, 0.10);
            border-color: rgba(63, 224, 154, 0.16);
        }

        .live-dot {
            width: 9px;
            height: 9px;
            border-radius: 999px;
            background: var(--success);
            animation: pulse 1.8s infinite;
        }

        .stats-row {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 12px;
        }

        .stat-card {
            padding: 18px;
            min-height: 92px;
        }

        .stat-card span {
            display: block;
            color: var(--muted);
            font-size: 13px;
        }

        .stat-card strong {
            display: block;
            margin-top: 10px;
            font-size: 28px;
            line-height: 1;
        }

        .workspace {
            min-height: 0;
            display: grid;
            grid-template-columns: 320px minmax(0, 1fr) 300px;
            gap: 16px;
        }

        .sidebar,
        .conversation-panel,
        .insights-panel {
            min-height: 0;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .panel-header {
            padding: 18px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.10);
        }

        .panel-header h3 {
            margin: 0;
            font-size: 17px;
        }

        .panel-header p {
            margin: 8px 0 0;
            color: var(--muted);
            font-size: 13px;
            line-height: 1.5;
        }

        .search {
            padding: 14px 18px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.10);
        }

        .search input {
            width: 100%;
            min-height: 46px;
            border-radius: 14px;
            border: 1px solid rgba(255, 255, 255, 0.14);
            background: rgba(255, 255, 255, 0.07);
            color: var(--text);
            padding: 0 14px;
            outline: none;
            transition: border-color 0.18s ease, box-shadow 0.18s ease;
        }

        .search input:focus {
            border-color: rgba(244, 184, 96, 0.65);
            box-shadow: 0 0 0 4px rgba(244, 184, 96, 0.10);
        }

        .contact-list {
            min-height: 0;
            overflow: auto;
            padding: 10px;
            display: grid;
            gap: 8px;
        }

        .contact-item {
            width: 100%;
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            border-radius: 18px;
            border: 1px solid transparent;
            background: transparent;
            cursor: pointer;
            text-align: left;
            color: var(--text);
            transition: transform 0.18s ease, background 0.18s ease, border-color 0.18s ease;
        }

        .contact-item:hover,
        .contact-item.active {
            background: rgba(255, 255, 255, 0.08);
            border-color: rgba(255, 255, 255, 0.12);
        }

        .contact-item:hover {
            transform: translateX(2px);
        }

        .avatar {
            width: 44px;
            height: 44px;
            border-radius: 14px;
            flex: 0 0 auto;
            display: grid;
            place-items: center;
            font-weight: 700;
            color: #06131f;
            background: linear-gradient(145deg, rgba(68, 216, 192, 0.95), rgba(244, 184, 96, 0.95));
            box-shadow: 0 12px 24px rgba(244, 184, 96, 0.14);
        }

        .contact-copy {
            min-width: 0;
            flex: 1;
        }

        .contact-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
        }

        .contact-copy strong {
            display: block;
            font-size: 14px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .contact-copy span {
            display: block;
            color: var(--muted);
            font-size: 12px;
            margin-top: 4px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .contact-email {
            color: rgba(255, 247, 240, 0.86);
        }

        .contact-preview {
            margin-top: 5px !important;
        }

        .contact-time {
            flex: 0 0 auto;
            font-size: 11px;
            color: var(--muted);
        }

        .history-search {
            padding: 16px 18px 0;
        }

        .history-search input {
            width: 100%;
            min-height: 46px;
            border-radius: 14px;
            border: 1px solid rgba(255, 255, 255, 0.14);
            background: rgba(255, 255, 255, 0.07);
            color: var(--text);
            padding: 0 14px;
            outline: none;
        }

        .history-search input:focus {
            border-color: rgba(244, 184, 96, 0.65);
            box-shadow: 0 0 0 4px rgba(244, 184, 96, 0.10);
        }

        .history-note {
            padding: 12px 18px 0;
            color: var(--muted);
            font-size: 12px;
            line-height: 1.5;
        }

        .conversation-panel {
            background: rgba(255, 255, 255, 0.06);
        }

        .conversation-header {
            padding: 18px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.10);
            display: flex;
            justify-content: space-between;
            gap: 16px;
            align-items: center;
        }

        .conversation-header h3 {
            margin: 0;
            font-size: 18px;
        }

        .conversation-header p {
            margin: 6px 0 0;
            color: var(--muted);
            font-size: 13px;
            line-height: 1.5;
        }

        .message-stream {
            min-height: 0;
            overflow: auto;
            flex: 1;
            padding: 18px;
            display: flex;
            flex-direction: column;
            gap: 12px;
            background:
                linear-gradient(180deg, rgba(244, 184, 96, 0.05), transparent 22%),
                transparent;
        }

        .empty-state {
            min-height: 260px;
            display: grid;
            place-items: center;
            text-align: center;
            color: var(--muted);
            padding: 24px;
        }

        .empty-state strong {
            display: block;
            color: var(--text);
            margin-bottom: 8px;
            font-size: 16px;
        }

        .message-row {
            display: flex;
            animation: fadeUp 0.18s ease-out;
        }

        .message-row.mine {
            justify-content: flex-end;
        }

        .bubble {
            position: relative;
            max-width: min(78%, 760px);
            padding: 12px 14px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.10);
            border: 1px solid rgba(255, 255, 255, 0.12);
            box-shadow: 0 10px 18px rgba(17, 30, 54, 0.08);
            transition: transform 0.18s ease, box-shadow 0.18s ease;
        }

        .bubble:hover {
            transform: translateY(-1px);
            box-shadow: 0 14px 24px rgba(17, 30, 54, 0.10);
        }

        .mine .bubble {
            background: linear-gradient(145deg, rgba(244, 184, 96, 0.98), rgba(68, 216, 192, 0.88));
            color: #06131f;
            border-color: transparent;
        }

        .bubble p {
            margin: 0;
            white-space: pre-wrap;
            word-break: break-word;
            line-height: 1.55;
        }

        .bubble-time {
            display: block;
            margin-top: 8px;
            font-size: 11px;
            color: inherit;
            opacity: 0.74;
        }

        .message-content {
            display: grid;
            gap: 10px;
        }

        .attachment-card {
            display: grid;
            gap: 10px;
            padding: 12px;
            border-radius: 16px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.12);
        }

        .attachment-card.image {
            grid-template-columns: minmax(0, 1fr);
        }

        .attachment-thumb {
            width: 100%;
            max-height: 260px;
            object-fit: cover;
            border-radius: 12px;
            display: block;
        }

        .attachment-meta {
            display: grid;
            gap: 4px;
        }

        .attachment-meta strong {
            font-size: 14px;
            word-break: break-word;
        }

        .attachment-meta span {
            font-size: 12px;
            color: var(--muted);
        }

        .attachment-link {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 40px;
            padding: 0 12px;
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.10);
            color: inherit;
            width: fit-content;
        }

        .composer-tools {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-bottom: 10px;
            flex-wrap: wrap;
            position: relative;
        }

        .attachment-input {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
            border: 0;
        }

        .attach-button {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            min-height: 40px;
            padding: 0 14px;
            border-radius: 999px;
            border: 1px solid rgba(255, 255, 255, 0.14);
            background: rgba(255, 255, 255, 0.08);
            color: var(--text);
            cursor: pointer;
        }

        .attachment-chip {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.10);
            color: var(--muted);
            font-size: 12px;
        }

        .attachment-chip.selected {
            color: var(--text);
            border-color: rgba(93, 214, 255, 0.35);
            background: rgba(93, 214, 255, 0.10);
        }

        .attachment-clear {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            border-radius: 999px;
            border: 1px solid rgba(255, 255, 255, 0.14);
            background: rgba(255, 255, 255, 0.08);
            color: var(--text);
            cursor: pointer;
            font-size: 18px;
            line-height: 1;
        }

        .attachment-clear[hidden] {
            display: none;
        }

        .bubble-toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 10px;
        }

        .bubble-actions {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            opacity: 0;
            transition: opacity 0.16s ease;
        }

        .bubble:hover .bubble-actions,
        .bubble:focus-within .bubble-actions {
            opacity: 1;
        }

        .message-action {
            border: 0;
            background: rgba(255, 255, 255, 0.10);
            color: inherit;
            border-radius: 999px;
            padding: 7px 10px;
            font-size: 11px;
            cursor: pointer;
            transition: transform 0.16s ease, background 0.16s ease;
        }

        .message-action:hover {
            transform: translateY(-1px);
            background: rgba(255, 255, 255, 0.18);
        }

        .message-action.danger {
            background: rgba(255, 126, 126, 0.12);
        }

        .composer {
            padding: 14px 18px;
            border-top: 1px solid rgba(255, 255, 255, 0.10);
            display: flex;
            gap: 12px;
            align-items: flex-end;
            background: rgba(7, 17, 31, 0.32);
        }

        .composer textarea {
            flex: 1;
            min-height: 58px;
            max-height: 180px;
            resize: vertical;
            border-radius: 16px;
            border: 1px solid rgba(255, 255, 255, 0.14);
            background: rgba(255, 255, 255, 0.07);
            padding: 14px 15px;
            color: var(--text);
            outline: none;
            transition: border-color 0.18s ease, box-shadow 0.18s ease;
        }

        .composer textarea:focus {
            border-color: rgba(244, 184, 96, 0.65);
            box-shadow: 0 0 0 4px rgba(244, 184, 96, 0.10);
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 46px;
            padding: 0 18px;
            border-radius: 14px;
            border: 1px solid transparent;
            cursor: pointer;
            transition: transform 0.18s ease, opacity 0.18s ease, box-shadow 0.18s ease;
            white-space: nowrap;
        }

        .btn:hover {
            transform: translateY(-1px);
        }

        .btn-primary {
            background: linear-gradient(145deg, var(--accent), var(--accent-3));
            color: #06131f;
            font-weight: 700;
            box-shadow: 0 14px 26px rgba(244, 184, 96, 0.18);
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.06);
            color: var(--text);
            border-color: rgba(255, 255, 255, 0.14);
        }

        .btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .insights-body {
            padding: 18px;
            display: grid;
            gap: 14px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: center;
            font-size: 14px;
        }

        .detail-row span {
            color: var(--muted);
        }

        .detail-row strong {
            text-align: right;
            word-break: break-word;
        }

        .scrollbar,
        .contact-list,
        .message-stream {
            scrollbar-color: rgba(255, 255, 255, 0.28) transparent;
            scrollbar-width: thin;
        }

        ::-webkit-scrollbar {
            width: 10px;
            height: 10px;
        }

        ::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.22);
            border-radius: 999px;
        }

        ::-webkit-scrollbar-track {
            background: transparent;
        }

        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(63, 224, 154, 0.34); }
            70% { box-shadow: 0 0 0 10px rgba(63, 224, 154, 0); }
            100% { box-shadow: 0 0 0 0 rgba(63, 224, 154, 0); }
        }

        @keyframes fadeUp {
            from {
                opacity: 0;
                transform: translateY(8px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @media (max-width: 1180px) {
            .workspace {
                grid-template-columns: 290px minmax(0, 1fr);
            }

            .insights-panel {
                grid-column: 1 / -1;
            }
        }

        @media (max-width: 860px) {
            .dashboard {
                padding: 12px;
            }

            .topbar,
            .conversation-header,
            .composer {
                flex-direction: column;
                align-items: stretch;
            }

            .stats-row,
            .workspace {
                grid-template-columns: 1fr;
            }

            .bubble {
                max-width: 100%;
            }

            .btn {
                width: 100%;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
                animation-duration: 0.01ms !important;
                animation-iteration-count: 1 !important;
                transition-duration: 0.01ms !important;
            }
        }
    </style>
</head>
<body>
<div class="dashboard"
     data-context-path="<%= contextPath %>"
     data-user-id="<%= userId %>"
     data-current-user-name="<%= WebUtil.escapeHtml(username) %>"
     data-current-user-email="<%= WebUtil.escapeHtml(email) %>"
     data-active-contact-id="<%= activeContactId %>">

    <div class="dashboard-shell">
        <header class="panel topbar">
            <div class="brand-inline">
                <div class="brand-mark">OC</div>
                <div>
                    <h2>Online Chat System</h2>
                    <div class="muted">Glassmorphism dashboard with live thread refresh</div>
                </div>
            </div>

            <div class="topbar-meta">
                <div class="chip chip-live">
                    <span class="live-dot"></span>
                    <strong>Live sync</strong>
                    <span id="refreshClock">--:--</span>
                </div>
                <div class="chip">
                    <strong><%= WebUtil.escapeHtml(username) %></strong>
                    <span><%= WebUtil.escapeHtml(email) %></span>
                </div>
                <a class="btn btn-secondary" href="<%= contextPath %>/logout">Logout</a>
            </div>
        </header>

        <section class="stats-row">
            <div class="panel stat-card">
                <span>Contacts</span>
                <strong id="contactStat"><%= contactCount %></strong>
            </div>
            <div class="panel stat-card">
                <span>Messages in thread</span>
                <strong id="messageStat"><%= messageCount %></strong>
            </div>
            <div class="panel stat-card">
                <span>Status</span>
                <strong id="focusStat"><%= activeContactId > 0 ? "Live" : "Idle" %></strong>
            </div>
        </section>

        <section class="workspace">
            <aside class="panel sidebar">
                <div class="panel-header">
                    <h3>Contacts</h3>
                    <p>Search and open a conversation.</p>
                </div>

                <div class="search">
                    <input id="contactSearch" type="search" placeholder="Search contacts">
                </div>

                <div class="contact-list" id="contactList">
                    <% if (contacts.isEmpty()) { %>
                    <div class="empty-state" style="min-height: 180px;">
                        <div>
                            <strong>No contacts yet</strong>
                            <p>The list fills automatically when other users register.</p>
                        </div>
                    </div>
                    <% } else { %>
                    <% for (User contact : contacts) { %>
                    <button type="button"
                            class="contact-item <%= activeContact != null && contact.getId() == activeContact.getId() ? "active" : "" %>"
                            data-contact-id="<%= contact.getId() %>"
                            data-contact-name="<%= WebUtil.escapeHtml(contact.getUsername()) %>"
                            data-contact-email="<%= WebUtil.escapeHtml(contact.getEmail()) %>"
                            data-contact-preview="<%= WebUtil.escapeHtml(contact.getLastMessagePreview() != null ? contact.getLastMessagePreview() : "") %>">
                        <div class="avatar"><%= WebUtil.initials(contact.getUsername()) %></div>
                        <div class="contact-copy">
                            <div class="contact-head">
                                <strong><%= WebUtil.escapeHtml(contact.getUsername()) %></strong>
                                <span class="contact-time">
                                    <%= contact.getLastMessageAt() != null
                                            ? WebUtil.escapeHtml(WebUtil.formatTimestamp(contact.getLastMessageAt()))
                                            : "New" %>
                                </span>
                            </div>
                            <span class="contact-email"><%= WebUtil.escapeHtml(contact.getEmail()) %></span>
                            <span class="contact-preview">
                                <%= contact.getLastMessagePreview() != null
                                        ? WebUtil.escapeHtml(contact.getLastMessagePreview())
                                        : "No messages yet" %>
                            </span>
                        </div>
                    </button>
                    <% } %>
                    <% } %>
                </div>
            </aside>

            <section class="panel conversation-panel">
                <div class="conversation-header">
                    <div>
                        <h3 id="activeContactName"><%= activeContactNameText %></h3>
                        <p id="activeContactMeta"><%= activeContactMetaText %></p>
                    </div>
                    <div class="chip" id="threadHint"><%= threadHintText %></div>
                </div>

                <div class="message-stream" id="messageStream">
                    <% if (activeContact == null) { %>
                    <div class="empty-state">
                        <div>
                            <strong>No conversation selected</strong>
                            <p>Choose a contact to load the message history.</p>
                        </div>
                    </div>
                    <% } else if (messages.isEmpty()) { %>
                    <div class="empty-state">
                        <div>
                            <strong>No messages yet</strong>
                            <p>Send the first message to start this thread.</p>
                        </div>
                    </div>
                    <% } else { %>
                    <% for (Message message : messages) { %>
                    <% boolean mine = message.getSenderId() == userId; %>
                    <div class="message-row <%= mine ? "mine" : "" %>">
                        <div class="bubble" data-message-id="<%= message.getId() %>" data-message-text="<%= WebUtil.escapeHtml(message.getMessage()) %>" data-owned="<%= mine %>">
                            <div class="bubble-toolbar">
                                <div class="bubble-actions">
                                    <button type="button" class="message-action" data-action="copy">Copy</button>
                                    <% if (mine) { %>
                                    <button type="button" class="message-action" data-action="edit">Edit</button>
                                    <button type="button" class="message-action danger" data-action="delete">Delete</button>
                                    <% } %>
                                </div>
                            </div>
                            <div class="message-content">
                                <% if (message.getMessage() != null && !message.getMessage().trim().isEmpty()) { %>
                                <p><%= WebUtil.escapeHtml(message.getMessage()) %></p>
                                <% } %>
                                <% if (message.hasAttachment()) { %>
                                <div class="attachment-card <%= util.AttachmentUtil.isImage(message.getAttachmentKind()) ? "image" : "file" %>">
                                    <% if (util.AttachmentUtil.isImage(message.getAttachmentKind())) { %>
                                    <img class="attachment-thumb" src="<%= contextPath %><%= util.AttachmentUtil.downloadUrl(message.getId()) %>" alt="<%= WebUtil.escapeHtml(message.getAttachmentName()) %>">
                                    <% } %>
                                    <div class="attachment-meta">
                                        <strong><%= WebUtil.escapeHtml(message.getAttachmentName()) %></strong>
                                        <span><%= WebUtil.humanReadableSize(message.getAttachmentSize()) %></span>
                                    </div>
                                    <a class="attachment-link" href="<%= contextPath %><%= util.AttachmentUtil.downloadUrl(message.getId()) %>" target="_blank" rel="noopener">Open Attachment</a>
                                </div>
                                <% } %>
                            </div>
                            <span class="bubble-time"><%= WebUtil.escapeHtml(WebUtil.formatTimestamp(message.getSentAt())) %></span>
                        </div>
                    </div>
                    <% } %>
                    <% } %>
                </div>

                <form class="composer" id="composerForm" autocomplete="off" enctype="multipart/form-data">
                    <input type="hidden" id="receiverInput" name="receiver" value="<%= activeContactId > 0 ? String.valueOf(activeContactId) : "" %>">
                    <input type="hidden" id="hasAttachmentInput" name="hasAttachment" value="0">
                    <div style="flex:1; min-width:0;">
                        <div class="composer-tools">
                            <input type="file"
                                   id="attachmentInput"
                                   name="attachment"
                                   class="attachment-input"
                                   accept="image/*,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.zip,.rar">
                            <label class="attach-button" for="attachmentInput">Attach File or Photo</label>
                            <span class="attachment-chip" id="attachmentLabel">No attachment selected</span>
                            <button type="button" class="attachment-clear" id="clearAttachmentButton" hidden aria-label="Remove attachment">&times;</button>
                        </div>
                        <textarea id="messageInput"
                                  name="message"
                                  placeholder="<%= messagePlaceholder %>"
                                  <%= activeContactId > 0 ? "" : "disabled" %>></textarea>
                    </div>
                    <button class="btn btn-primary" id="sendButton" type="submit">Send Message</button>
                </form>
            </section>

            <aside class="panel insights-panel">
                <div class="panel-header">
                    <h3>Workspace</h3>
                    <p>Quick details about the signed-in account and active thread.</p>
                </div>

                <div class="history-search">
                    <input id="historySearch" type="search" placeholder="Search history">
                </div>
                <div class="history-note">
                    Search filters the loaded conversation history, including attachment names.
                </div>

                <div class="insights-body">
                    <div class="detail-row">
                        <span>Account</span>
                        <strong id="insightUser"><%= WebUtil.escapeHtml(username) %><% if (email != null && !email.isEmpty()) { %> | <%= WebUtil.escapeHtml(email) %><% } %></strong>
                    </div>
                    <div class="detail-row">
                        <span>Thread</span>
                        <strong id="insightThread"><%= activeContact != null ? WebUtil.escapeHtml(activeContact.getUsername()) : "No thread selected" %></strong>
                    </div>
                    <div class="detail-row">
                        <span>Messages</span>
                        <strong id="insightCount"><%= messageCount %></strong>
                    </div>
                    <div class="detail-row">
                        <span>Contacts</span>
                        <strong><%= contactCount %></strong>
                    </div>
                    <div class="detail-row">
                        <span>Refresh</span>
                        <strong>Auto polling on</strong>
                    </div>
                </div>
            </aside>
        </section>
    </div>
</div>

<script src="<%= contextPath %>/assets/js/chat.js" defer></script>
</body>
</html>
