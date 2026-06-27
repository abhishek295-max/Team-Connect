(function () {
    const shell = document.querySelector("[data-context-path]");
    if (!shell) {
        return;
    }

    const contextPath = shell.dataset.contextPath || "";
    const currentUserId = Number(shell.dataset.userId || 0);

    const contactList = document.getElementById("contactList");
    const contactSearch = document.getElementById("contactSearch");
    const messageStream = document.getElementById("messageStream");
    const composerForm = document.getElementById("composerForm");
    const messageInput = document.getElementById("messageInput");
    const receiverInput = document.getElementById("receiverInput");
    const attachmentInput = document.getElementById("attachmentInput");
    const attachmentLabel = document.getElementById("attachmentLabel");
    const clearAttachmentButton = document.getElementById("clearAttachmentButton");
    const sendButton = document.getElementById("sendButton");
    const activeContactName = document.getElementById("activeContactName");
    const activeContactMeta = document.getElementById("activeContactMeta");
    const threadHint = document.getElementById("threadHint");
    const messageStat = document.getElementById("messageStat");
    const contactStat = document.getElementById("contactStat");
    const focusStat = document.getElementById("focusStat");
    const threadCount = document.getElementById("threadCount");
    const insightUser = document.getElementById("insightUser");
    const insightThread = document.getElementById("insightThread");
    const insightCount = document.getElementById("insightCount");
    const refreshClock = document.getElementById("refreshClock");
    const historySearch = document.getElementById("historySearch");

    let activeContactId = Number(shell.dataset.activeContactId || 0);
    let pollTimer = null;

    function draftKey(contactId) {
        return `chatDraft:${currentUserId}:${contactId}`;
    }

    function currentAttachment() {
        return attachmentInput && attachmentInput.files && attachmentInput.files.length > 0
            ? attachmentInput.files[0]
            : null;
    }

    function persistCurrentDraft() {
        if (!messageInput || !activeContactId) {
            return;
        }

        const value = messageInput.value || "";
        if (value.trim().length === 0) {
            localStorage.removeItem(draftKey(activeContactId));
            return;
        }

        localStorage.setItem(draftKey(activeContactId), value);
    }

    function updateSendButtonState() {
        if (!sendButton) {
            return;
        }

        const hasText = messageInput && messageInput.value.trim().length > 0;
        const hasFile = Boolean(currentAttachment());
        sendButton.disabled = !activeContactId || (!hasText && !hasFile);
    }

    function clearAttachmentSelection() {
        if (attachmentInput) {
            attachmentInput.value = "";
        }
        updateAttachmentChip();
        updateSendButtonState();
    }

    function updateAttachmentChip() {
        if (!attachmentLabel) {
            return;
        }

        const file = currentAttachment();
        if (!file) {
            attachmentLabel.textContent = "No attachment selected";
            attachmentLabel.classList.remove("selected");
            if (clearAttachmentButton) {
                clearAttachmentButton.hidden = true;
            }
            return;
        }

        attachmentLabel.textContent = `${file.name} · ${Math.ceil(file.size / 1024)} KB`;
        attachmentLabel.classList.add("selected");
        if (clearAttachmentButton) {
            clearAttachmentButton.hidden = false;
        }
    }

    function restoreDraftForContact(contactId) {
        if (!messageInput || !contactId) {
            return;
        }

        const draft = localStorage.getItem(draftKey(contactId)) || "";
        messageInput.value = draft;
        if (attachmentInput) {
            attachmentInput.value = "";
        }
        updateAttachmentChip();
        updateSendButtonState();

        if (sendButton) {
            updateSendButtonState();
        }

        if (threadHint) {
            threadHint.textContent = draft.trim().length > 0
                ? "Draft restored for this thread."
                : (activeContactId
                    ? "Messages refresh automatically while you keep this thread open."
                    : "Choose a conversation from the left panel to start.");
        }
    }

    function postForm(url, values) {
        const payload = new URLSearchParams();
        Object.entries(values).forEach(([key, value]) => {
            payload.set(key, String(value));
        });

        return fetch(url, {
            method: "POST",
            headers: {
                "X-Requested-With": "XMLHttpRequest",
                "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
            },
            body: payload.toString()
        }).then((response) => {
            if (response.status === 401) {
                window.location.href = `${contextPath}/views/login.jsp`;
                return null;
            }

            if (!response.ok) {
                throw new Error("Request failed");
            }

            return response.json();
        });
    }

    function postMultipart(url, values, files = {}) {
        const payload = new FormData();
        const fileEntry = Object.values(files).find(Boolean) || null;

        Object.entries(values).forEach(([key, value]) => {
            payload.append(key, String(value));
        });
        payload.append("hasAttachment", fileEntry ? "1" : "0");

        Object.entries(files).forEach(([key, file]) => {
            if (file) {
                payload.append(key, file, file.name || "attachment");
            }
        });

        return fetch(url, {
            method: "POST",
            headers: {
                "X-Requested-With": "XMLHttpRequest"
            },
            body: payload
        }).then(async (response) => {
            if (response.status === 401) {
                window.location.href = `${contextPath}/views/login.jsp`;
                return null;
            }

            const data = await response.json().catch(() => ({}));
            if (!response.ok || !data.success) {
                throw new Error(data.error || "Request failed");
            }

            return data;
        });
    }

    function setStatusText(contactName, contactEmail) {
        if (activeContactName) {
            activeContactName.textContent = contactName || "Select a conversation";
        }

        if (activeContactMeta) {
            activeContactMeta.textContent = contactEmail
                ? contactEmail
                : "Pick a contact to begin a thread";
        }

        if (threadHint) {
            threadHint.textContent = contactName
                ? "Messages refresh automatically while you keep this thread open."
                : "Choose a conversation from the left panel to start.";
        }

        if (insightThread) {
            insightThread.textContent = contactName || "No thread selected";
        }

        if (receiverInput) {
            receiverInput.value = activeContactId > 0 ? String(activeContactId) : "";
        }

        if (messageInput) {
            messageInput.disabled = !activeContactId;
            messageInput.placeholder = activeContactId
                ? "Write a message..."
                : "Select a contact first";
        }

        if (sendButton) {
            updateSendButtonState();
        }
    }

    function updateStatCards(messageCount) {
        if (messageStat) {
            messageStat.textContent = String(messageCount ?? 0);
        }

        if (contactStat) {
            contactStat.textContent = String(
                contactList ? contactList.querySelectorAll(".contact-item").length : 0
            );
        }

        if (focusStat) {
            focusStat.textContent = activeContactId ? "Live" : "Idle";
        }

        if (threadCount) {
            threadCount.textContent = String(messageCount ?? 0);
        }

        if (insightCount) {
            insightCount.textContent = String(messageCount ?? 0);
        }

        if (refreshClock) {
            refreshClock.textContent = new Date().toLocaleTimeString([], {
                hour: "2-digit",
                minute: "2-digit"
            });
        }
    }

    function scrollToBottom() {
        if (messageStream) {
            messageStream.scrollTop = messageStream.scrollHeight;
        }
    }

    function renderMessages(messages, contact) {
        if (!messageStream) {
            return;
        }

        messageStream.innerHTML = "";

        if (!messages || messages.length === 0) {
            const empty = document.createElement("div");
            empty.className = "empty-state";

            const content = document.createElement("div");
            const title = document.createElement("strong");
            title.textContent = contact
                ? "No messages yet"
                : "No conversation selected";
            const body = document.createElement("p");
            body.textContent = contact
                ? "Send the first message to open this thread."
                : "Choose a contact from the list to load the thread.";

            content.append(title, body);
            empty.append(content);
            messageStream.append(empty);
            scrollToBottom();
            return;
        }

        messages.forEach((message) => {
            const row = document.createElement("div");
            const isMine = Number(message.senderId) === currentUserId;
            row.className = "message-row" + (isMine ? " mine" : "");

            const bubble = document.createElement("div");
            bubble.className = "bubble";
            bubble.dataset.messageId = message.id || "";
            bubble.dataset.messageText = message.message || "";
            bubble.dataset.attachmentName = message.attachmentName || "";
            bubble.dataset.attachmentKind = message.attachmentKind || "";
            bubble.dataset.attachmentUrl = message.attachmentUrl || "";
            bubble.dataset.owned = String(isMine);

            const toolbar = document.createElement("div");
            toolbar.className = "bubble-toolbar";

            const actions = document.createElement("div");
            actions.className = "bubble-actions";

            const copyButton = document.createElement("button");
            copyButton.type = "button";
            copyButton.className = "message-action";
            copyButton.dataset.action = "copy";
            copyButton.textContent = "Copy";
            actions.append(copyButton);

            if (isMine) {
                const editButton = document.createElement("button");
                editButton.type = "button";
                editButton.className = "message-action";
                editButton.dataset.action = "edit";
                editButton.textContent = "Edit";

                const deleteButton = document.createElement("button");
                deleteButton.type = "button";
                deleteButton.className = "message-action danger";
                deleteButton.dataset.action = "delete";
                deleteButton.textContent = "Delete";

                actions.append(editButton, deleteButton);
            }

            toolbar.append(actions);

            const content = document.createElement("div");
            content.className = "message-content";

            if (message.message && String(message.message).trim().length > 0) {
                const text = document.createElement("p");
                text.textContent = message.message || "";
                content.append(text);
            }

            if (message.attachmentUrl) {
                const attachmentCard = document.createElement("div");
                attachmentCard.className = `attachment-card ${message.attachmentKind === "image" ? "image" : "file"}`;

                if (message.attachmentKind === "image") {
                    const image = document.createElement("img");
                    image.className = "attachment-thumb";
                    image.src = `${contextPath}${message.attachmentUrl}`;
                    image.alt = message.attachmentName || "Attachment";
                    attachmentCard.append(image);
                }

                const meta = document.createElement("div");
                meta.className = "attachment-meta";

                const name = document.createElement("strong");
                name.textContent = message.attachmentName || "attachment";

                const size = document.createElement("span");
                size.textContent = message.attachmentSize
                    ? `${message.attachmentSize} bytes`
                    : "shared file";

                meta.append(name, size);
                attachmentCard.append(meta);

                const link = document.createElement("a");
                link.className = "attachment-link";
                link.href = `${contextPath}${message.attachmentUrl}`;
                link.target = "_blank";
                link.rel = "noopener";
                link.textContent = "Open Attachment";
                attachmentCard.append(link);

                content.append(attachmentCard);
            }

            const time = document.createElement("span");
            time.className = "bubble-time";
            time.textContent = message.sentAt || "";

            bubble.append(toolbar, content, time);
            row.append(bubble);
            messageStream.append(row);
        });

        scrollToBottom();
    }

    function setActiveContact(contactId, contactName, contactEmail, options = {}) {
        activeContactId = Number(contactId) || 0;

        document.querySelectorAll(".contact-item").forEach((button) => {
            button.classList.toggle(
                "active",
                Number(button.dataset.contactId) === activeContactId
            );
        });

        setStatusText(contactName, contactEmail);

        if (options.restoreDraft !== false) {
            restoreDraftForContact(activeContactId);
        }
    }

    function loadConversation(contactId, options = {}) {
        if (!contactId) {
            renderMessages([], null);
            updateStatCards(0);
            setStatusText("", "");
            return Promise.resolve();
        }

        const preserveScroll = Boolean(options.preserveScroll);
        const url = `${contextPath}/conversation?contactId=${encodeURIComponent(contactId)}`;

        return fetch(url, {
            headers: {
                Accept: "application/json"
            }
        })
            .then((response) => {
                if (response.status === 401) {
                    window.location.href = `${contextPath}/views/login.jsp`;
                    return null;
                }

                if (!response.ok) {
                    throw new Error("Unable to load conversation");
                }

                return response.json();
            })
            .then((data) => {
                if (!data) {
                    return;
                }

                const contact = data.contact || null;
                if (contact) {
                    const sameContact = Number(contact.id) === activeContactId;
                    if (sameContact && preserveScroll) {
                        setStatusText(contact.username, contact.email);
                    } else {
                        setActiveContact(contact.id, contact.username, contact.email);
                    }
                }

                renderMessages(data.messages || [], contact);
                updateStatCards(data.messageCount || 0);

                if (contact) {
                    const latestMessage = Array.isArray(data.messages) && data.messages.length > 0
                        ? data.messages[data.messages.length - 1]
                        : null;
                    syncContactCard(contact, latestMessage);
                }

                applyHistoryFilter();

                if (insightUser) {
                    insightUser.textContent = contact
                        ? `${contact.username} | ${contact.email}`
                        : "No contact selected";
                }

                if (!preserveScroll) {
                    scrollToBottom();
                }
            })
            .catch(() => {
                if (threadHint) {
                    threadHint.textContent = "Conversation could not be loaded.";
                }
            });
    }

    function refreshActiveConversation() {
        if (!activeContactId) {
            return;
        }

        loadConversation(activeContactId, { preserveScroll: true });
    }

    function applyContactFilter() {
        if (!contactSearch || !contactList) {
            return;
        }

        const query = contactSearch.value.trim().toLowerCase();

        contactList.querySelectorAll(".contact-item").forEach((button) => {
            const label = (button.dataset.contactName || "").toLowerCase();
            const email = (button.dataset.contactEmail || "").toLowerCase();
            const preview = (button.dataset.contactPreview || "").toLowerCase();
            const match = !query || label.includes(query) || email.includes(query) || preview.includes(query);
            button.style.display = match ? "" : "none";
        });
    }

    function applyHistoryFilter() {
        if (!historySearch || !messageStream) {
            return;
        }

        const query = historySearch.value.trim().toLowerCase();
        const rows = Array.from(messageStream.querySelectorAll(".message-row"));

        rows.forEach((row) => {
            const bubble = row.querySelector(".bubble");
            if (!bubble) {
                return;
            }

            const text = (bubble.dataset.messageText || "").toLowerCase();
            const attachment = (bubble.dataset.attachmentName || "").toLowerCase();
            const visible = !query || text.includes(query) || attachment.includes(query);
            row.style.display = visible ? "" : "none";
        });
    }

    function syncContactCard(contact, latestMessage) {
        if (!contactList || !contact) {
            return;
        }

        const card = contactList.querySelector(
            `.contact-item[data-contact-id="${contact.id}"]`
        );
        if (!card) {
            return;
        }

        const preview = latestMessage && latestMessage.message
            ? latestMessage.message
            : latestMessage && latestMessage.attachmentName
                ? `${latestMessage.attachmentKind === "image" ? "Photo" : "File"}: ${latestMessage.attachmentName}`
                : "No messages yet";
        const previewTime = latestMessage && latestMessage.sentAt
            ? latestMessage.sentAt
            : "New";

        card.dataset.contactPreview = preview;

        const previewEl = card.querySelector(".contact-preview");
        if (previewEl) {
            previewEl.textContent = preview;
        }

        const timeEl = card.querySelector(".contact-time");
        if (timeEl) {
            timeEl.textContent = previewTime;
        }

        if (contactList.firstElementChild !== card) {
            contactList.prepend(card);
        }
    }

    async function handleMessageAction(button) {
        const action = button.dataset.action;
        const bubble = button.closest(".bubble");
        const messageId = Number(bubble?.dataset.messageId || 0);
        const originalText = bubble?.dataset.messageText || "";

        if (!messageId) {
            return;
        }

        if (action === "copy") {
            try {
                await navigator.clipboard.writeText(originalText);
                if (threadHint) {
                    threadHint.textContent = "Message copied to clipboard.";
                }
            } catch (error) {
                if (threadHint) {
                    threadHint.textContent = "Copy failed.";
                }
            }
            return;
        }

        if (action === "edit") {
            const updated = window.prompt("Edit message", originalText);
            if (updated === null) {
                return;
            }

            const trimmed = updated.trim();
            if (!trimmed) {
                return;
            }

            const result = await postForm(`${contextPath}/editMessage`, {
                messageId,
                message: trimmed
            });

            if (result && result.success) {
                await loadConversation(activeContactId, { preserveScroll: true });
            }
            return;
        }

        if (action === "delete") {
            if (!window.confirm("Delete this message?")) {
                return;
            }

            const result = await postForm(`${contextPath}/deleteMessage`, {
                messageId
            });

            if (result && result.success) {
                await loadConversation(activeContactId, { preserveScroll: true });
            }
        }
    }

    if (contactList) {
        contactList.addEventListener("click", (event) => {
            const button = event.target.closest(".contact-item");
            if (!button) {
                return;
            }

            const contactId = Number(button.dataset.contactId || 0);
            if (!contactId) {
                return;
            }

            persistCurrentDraft();
            setActiveContact(
                contactId,
                button.dataset.contactName || "",
                button.dataset.contactEmail || "",
                { restoreDraft: true }
            );
            loadConversation(contactId);
        });
    }

    if (messageStream) {
        messageStream.addEventListener("click", (event) => {
            const actionButton = event.target.closest(".message-action");
            if (!actionButton) {
                return;
            }

            const bubble = actionButton.closest(".bubble");
            if (!bubble) {
                return;
            }

            const owned = bubble.dataset.owned === "true";
            const action = actionButton.dataset.action;

            if (action === "copy") {
                handleMessageAction(actionButton);
                return;
            }

            if (!owned) {
                return;
            }

            handleMessageAction(actionButton).catch(() => {
                if (threadHint) {
                    threadHint.textContent = "Could not process the message action.";
                }
            });
        });
    }

    if (contactSearch) {
        contactSearch.addEventListener("input", applyContactFilter);
    }

    if (historySearch) {
        historySearch.addEventListener("input", applyHistoryFilter);
    }

    if (attachmentInput) {
        attachmentInput.addEventListener("change", () => {
            updateAttachmentChip();
            updateSendButtonState();

            if (threadHint && currentAttachment()) {
                threadHint.textContent = "Attachment ready to send.";
            }
        });
    }

    if (clearAttachmentButton) {
        clearAttachmentButton.addEventListener("click", () => {
            clearAttachmentSelection();
            if (threadHint) {
                threadHint.textContent = activeContactId
                    ? "Messages refresh automatically while you keep this thread open."
                    : "Choose a conversation from the left panel to start.";
            }
        });
    }

    if (composerForm) {
        composerForm.addEventListener("submit", (event) => {
            event.preventDefault();

            if (!activeContactId || !messageInput) {
                return;
            }

            const text = messageInput.value.trim();
            const file = currentAttachment();
            if (!text && !file) {
                messageInput.focus();
                return;
            }

            if (sendButton) {
                sendButton.disabled = true;
                sendButton.textContent = "Sending...";
            }

            // Update hidden field so servlet receives hasAttachment flag
            const hasAttachmentInput = document.getElementById('hasAttachmentInput');
            if (hasAttachmentInput) {
                hasAttachmentInput.value = file ? '1' : '0';
            }

            postMultipart(`${contextPath}/sendMessage`, {
                receiver: activeContactId,
                message: text
            }, {
                attachment: file
            })
                .then((data) => {
                    if (!data || !data.success) {
                        if (threadHint) {
                            threadHint.textContent = file
                                ? "File could not be sent. Try again or choose a smaller file."
                                : "Message could not be sent.";
                        }
                        return;
                    }

                    messageInput.value = "";
                    if (attachmentInput) {
                        attachmentInput.value = "";
                    }
                    updateAttachmentChip();
                    persistCurrentDraft();
                    return loadConversation(activeContactId);
                })
                .finally(() => {
                    if (sendButton) {
                        updateSendButtonState();
                        sendButton.textContent = "Send Message";
                    }
                })
                .catch((error) => {
                    if (threadHint) {
                        threadHint.textContent = error && error.message
                            ? error.message
                            : "Message could not be sent.";
                    }
                });
        });
    }

    if (messageInput) {
        messageInput.addEventListener("input", () => {
            persistCurrentDraft();

            if (!threadHint) {
                return;
            }

            const length = messageInput.value.trim().length;
            updateSendButtonState();

            if (!activeContactId) {
                threadHint.textContent = "Choose a contact before typing.";
                return;
            }

            threadHint.textContent = length > 0
                ? `${length} characters ready to send.`
                : "Messages refresh automatically while you keep this thread open.";
        });

        messageInput.addEventListener("keydown", (event) => {
            if (event.key === "Enter" && !event.shiftKey) {
                event.preventDefault();
                composerForm?.requestSubmit();
            }
        });
    }

    if (insightUser) {
        const currentUserName = shell.dataset.currentUserName || "You";
        const currentUserEmail = shell.dataset.currentUserEmail || "";
        insightUser.textContent = currentUserEmail
            ? `${currentUserName} | ${currentUserEmail}`
            : currentUserName;
    }

    if (!activeContactId) {
        const firstContact = contactList?.querySelector(".contact-item");
        if (firstContact) {
            activeContactId = Number(firstContact.dataset.contactId || 0);
            setStatusText(
                firstContact.dataset.contactName || "",
                firstContact.dataset.contactEmail || ""
            );
            restoreDraftForContact(activeContactId);
            loadConversation(activeContactId);
        } else {
            setStatusText("", "");
            renderMessages([], null);
            updateStatCards(0);
        }
    } else {
        const activeButton = contactList?.querySelector(
            `.contact-item[data-contact-id="${activeContactId}"]`
        );
        if (activeButton) {
            setStatusText(
                activeButton.dataset.contactName || "",
                activeButton.dataset.contactEmail || ""
            );
            restoreDraftForContact(activeContactId);
        }
        loadConversation(activeContactId);
    }

    pollTimer = window.setInterval(refreshActiveConversation, 5000);

    window.addEventListener("beforeunload", () => {
        if (pollTimer) {
            window.clearInterval(pollTimer);
        }
    });
})();
