(function () {
    const dialog = document.getElementById("chatDialog");
    const dialogTitle = document.getElementById("chatDialogTitle");
    const dialogMessage = document.getElementById("chatDialogMessage");
    const dialogInputWrap = document.getElementById("dialogInputWrap");
    const dialogConfirmButton = document.getElementById("dialogConfirmButton");
    const dialogCancelButton = document.getElementById("dialogCancelButton");
    let activeDialogHandler = null;

    function closeProfessionalDialog() {
        if (!dialog) {
            return;
        }

        dialog.classList.add("hidden");
        dialog.setAttribute("aria-hidden", "true");
        if (dialogInputWrap) {
            dialogInputWrap.innerHTML = "";
        }
        if (dialogMessage) {
            dialogMessage.textContent = "";
        }
        activeDialogHandler = null;
    }

    function openProfessionalDialog({
        title,
        message = "",
        inputLabel = "",
        inputValue = "",
        confirmText = "Confirm",
        onConfirm = null,
        variant = "primary"
    }) {
        if (!dialog || !dialogTitle || !dialogConfirmButton) {
            return null;
        }

        dialogTitle.textContent = title || "Action";
        if (dialogMessage) {
            dialogMessage.textContent = message || "";
        }

        if (dialogInputWrap) {
            dialogInputWrap.innerHTML = "";
            if (inputLabel) {
                const label = document.createElement("label");
                label.className = "dialog-field";

                const labelText = document.createElement("span");
                labelText.textContent = inputLabel;

                const input = document.createElement("textarea");
                input.id = "dialogInput";
                input.rows = 4;
                input.value = inputValue || "";

                label.append(labelText, input);
                dialogInputWrap.appendChild(label);
            }
        }

        dialogConfirmButton.textContent = confirmText;
        dialogConfirmButton.dataset.variant = variant;
        dialogConfirmButton.classList.toggle("danger", variant === "danger");
        activeDialogHandler = onConfirm || null;

        dialog.classList.remove("hidden");
        dialog.setAttribute("aria-hidden", "false");

        setTimeout(() => {
            const focusTarget = dialog.querySelector("textarea, button, input");
            focusTarget && focusTarget.focus();
        }, 10);

        return dialog;
    }

    if (dialog) {
        dialog.addEventListener("click", (event) => {
            if (event.target === dialog) {
                closeProfessionalDialog();
            }
        });

        dialogCancelButton?.addEventListener("click", closeProfessionalDialog);
        dialogConfirmButton?.addEventListener("click", async () => {
            if (typeof activeDialogHandler === "function") {
                await activeDialogHandler();
            }
            closeProfessionalDialog();
        });
    }

    window.createGroup = async function () {
        const contacts = [...document.querySelectorAll("#contactList [data-contact-id]")];
        if (!contacts.length) {
            window.alert("Add contacts before creating a group.");
            return;
        }

        const overlay = document.createElement("div");
        overlay.style.cssText = "position:fixed;inset:0;z-index:1000;display:grid;place-items:center;background:rgba(15,28,42,.42);padding:20px";
        const box = document.createElement("div");
        box.style.cssText = "width:min(420px,100%);max-height:80vh;overflow:auto;padding:24px;border-radius:16px;background:var(--panel,#fff);color:var(--text,#1c2b3a);box-shadow:0 24px 70px rgba(0,0,0,.25)";
        box.innerHTML = '<h2 style="margin:0 0 6px">Create group</h2><p style="margin:0 0 16px;color:var(--muted,#718397)">Choose members for the new group.</p><input id="newGroupName" placeholder="Group name" style="width:100%;padding:11px;border:1px solid var(--line,#d4dfe9);border-radius:9px;margin-bottom:14px;font:inherit">';
        const list = document.createElement("div");
        contacts.forEach(card => {
            const label = document.createElement("label");
            label.style.cssText = "display:flex;gap:10px;align-items:center;padding:9px 0;cursor:pointer";
            label.innerHTML = `<input type="checkbox" value="${card.dataset.contactId}"> <span>${card.dataset.contactName || card.textContent.trim()}</span>`;
            list.appendChild(label);
        });
        box.appendChild(list);
        const actions = document.createElement("div");
        actions.style.cssText = "display:flex;justify-content:flex-end;gap:8px;margin-top:18px";
        actions.innerHTML = '<button type="button" data-cancel>Cancel</button><button type="button" data-create>Create group</button>';
        box.appendChild(actions);
        overlay.appendChild(box);
        document.body.appendChild(overlay);
        box.querySelector("[data-cancel]").onclick = () => overlay.remove();
        box.querySelector("[data-create]").onclick = async () => {
            const name = box.querySelector("#newGroupName").value.trim();
            const selected = [...box.querySelectorAll("input[type=checkbox]:checked")].map(input => input.value);
            if (!name || !selected.length) {
                window.alert("Enter a group name and select at least one contact.");
                return;
            }
            const body = new URLSearchParams({ name });
            selected.forEach(id => body.append("memberIds", id));
            const response = await fetch(`${contextPath}/groupChat/create`, { method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" }, body });
            const result = await response.json().catch(() => ({}));
            if (response.ok && !result.error) window.location.reload();
            else window.alert(result.error || "Group could not be created.");
        };
    };

    window.openGroup = async function (id, name) {
        const response = await fetch(`${contextPath}/groupChat/${id}`);
        if (!response.ok) return;
        const rows = await response.json();
        const stream = document.getElementById("messageStream");
        if (!stream) return;
        activeGroupId = Number(id);
        activeContactId = 0;
        if (receiverInput) receiverInput.value = "";
        if (messageInput) { messageInput.disabled = false; messageInput.placeholder = `Message ${name}...`; }
        if (activeContactName) activeContactName.textContent = name;
        if (activeContactMeta) activeContactMeta.textContent = "Group workspace";
        fetch(`${contextPath}/groupChat/${id}/members`)
            .then(response => response.ok ? response.json() : [])
            .then(members => {
                if (!activeContactMeta || !Array.isArray(members)) return;
                const names = members.map(member => member.username).filter(Boolean);
                activeContactMeta.textContent = `${names.length} members · ${names.join(", ")}`;
            })
            .catch(() => {
                if (activeContactMeta) activeContactMeta.textContent = "Group workspace";
            });
        const esc = value => String(value ?? '').replace(/[&<>\"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','\"':'&quot;',"'":'&#39;'}[c]));
        stream.innerHTML = rows.map(row => {
            const mine = Number(row.sender_id) === currentUserId;
            return `<div class="message-row${mine ? ' mine' : ''}"><div class="avatar">${esc(String(row.username || '?').slice(0, 2).toUpperCase())}</div><div class="bubble" tabindex="0" data-message-id="${Number(row.id) || 0}" data-message-text="${esc(row.message)}"><div class="bubble-toolbar"><strong>${esc(row.username)}</strong></div><p>${esc(row.message)}</p><span class="bubble-time">${esc(row.sent_at || '')}</span></div></div>`;
        }).join('');
        const hint = document.getElementById("threadHint"); if (hint) hint.textContent = `Group space: ${name}`;
        bindEmojiReactions();
    };

    window.toggleAiPanel = function () { const panel=document.getElementById('aiPanel'); if(!panel)return; const open=panel.classList.toggle('open'); panel.setAttribute('aria-hidden',String(!open)); if(open) document.getElementById('aiInput')?.focus(); };
    window.useAiPrompt = function (text) { const input=document.getElementById('aiInput'); if(input){input.value=text;input.focus();} };
    window.sendAiMessage = async function (event) { event.preventDefault(); const input=document.getElementById('aiInput'); const text=input?.value.trim(); if(!text)return; const box=document.getElementById('aiMessages'); const user=document.createElement('div'); user.className='ai-message user'; user.textContent=text; box.appendChild(user); input.value=''; try { const response=await fetch(`${document.querySelector('[data-context-path]').dataset.contextPath}/api/ai/chat`,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({message:text})}); const data=await response.json(); const item=document.createElement('div'); item.className='ai-message assistant'; item.textContent=data.reply||'No response available.'; box.appendChild(item); box.scrollTop=box.scrollHeight; } catch(e) { const item=document.createElement('div'); item.className='ai-message assistant'; item.textContent='Assistant is temporarily unavailable.'; box.appendChild(item); } };

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
    const pollButton = document.getElementById("pollButton");

    let activeContactId = Number(shell.dataset.activeContactId || 0);
    let activeGroupId = 0;

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
                    ? "Messages load when you switch contacts or send a message."
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
                window.location.href = `../../views/register.jsp`;
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
                window.location.href = `${contextPath}/views/register.jsp`;
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
                ? "Messages load when you switch contacts or send a message."
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
            title.textContent = contact ? "No messages yet" : "No conversation selected";
            const body = document.createElement("p");
            body.textContent = contact ? "Send the first message to open this thread." : "Choose a contact from the list to load the thread.";

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
                    window.location.href = `${contextPath}/views/register.jsp`;
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

        if (action === "edit") {
            openProfessionalDialog({
                title: "Edit message",
                inputLabel: "Update your message",
                inputValue: originalText,
                confirmText: "Save changes",
                onConfirm: async () => {
                    const input = document.getElementById("dialogInput");
                    const updated = input?.value?.trim();
                    if (!updated) {
                        return;
                    }

                    const result = await postForm(`${contextPath}/editMessage`, {
                        messageId,
                        message: updated
                    });

                    if (result && result.success) {
                        await loadConversation(activeContactId, { preserveScroll: true });
                    }
                }
            });
            return;
        }

        if (action === "delete") {
            openProfessionalDialog({
                title: "Delete message",
                message: "This message will be removed from the conversation permanently.",
                confirmText: "Delete message",
                variant: "danger",
                onConfirm: async () => {
                    const result = await postForm(`${contextPath}/deleteMessage`, {
                        messageId
                    });

                    if (result && result.success) {
                        await loadConversation(activeContactId, { preserveScroll: true });
                    }
                }
            });
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
                    ? "Messages load when you switch contacts or send a message."
                    : "Choose a conversation from the left panel to start.";
            }
        });
    }

    if (composerForm) {
        composerForm.addEventListener("submit", (event) => {
            event.preventDefault();

            if ((!activeContactId && !activeGroupId) || !messageInput) {
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

            const hasAttachmentInput = document.getElementById('hasAttachmentInput');
            if (hasAttachmentInput) {
                hasAttachmentInput.value = file ? '1' : '0';
            }

            const sendRequest = activeGroupId
                ? fetch(`${contextPath}/groupChat/${activeGroupId}/message`, {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: new URLSearchParams({ message: text })
                }).then(response => response.json())
                : postMultipart(`${contextPath}/sendMessage`, { receiver: activeContactId, message: text }, { attachment: file });

            sendRequest
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
                    return activeGroupId
                        ? window.openGroup(activeGroupId, activeContactName?.textContent || "Group")
                        : loadConversation(activeContactId);
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
                : "Messages load when you switch contacts or send a message.";
            sendTypingStatus(length > 0);
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

    const wsState = {
        socket: null,
        client: null,
        connected: false,
        typingTimer: null,
        lastTypingStatus: null
    };

    function formatLastSeen(value) {
        if (!value) return "Active now";
        try {
            const when = new Date(value);
            return `Last seen ${when.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;
        } catch (e) {
            return "Active now";
        }
    }

    function updatePresenceLabelForContact(contactId, status, lastSeenValue) {
        if (!contactList) return;
        const card = contactList.querySelector(`.contact-item[data-contact-id="${contactId}"]`);
        if (!card) return;
        const statusNode = card.querySelector(".presence-pill");
        if (!statusNode) return;
        statusNode.textContent = status === "online" ? "Online" : formatLastSeen(lastSeenValue);
        statusNode.classList.toggle("online", status === "online");
    }

    function initWebSocket() {
        if (!window.SockJS || !window.Stomp || !currentUserId) return;
        const socket = new SockJS(`${contextPath}/ws`);
        const client = Stomp.over(socket);
        wsState.client = client;
        client.connect({}, () => {
            wsState.connected = true;
            client.subscribe('/topic/presence', (message) => {
                const data = JSON.parse(message.body);
                if (!data || !data.userId) return;
                updatePresenceLabelForContact(Number(data.userId), data.status, data.lastSeen || null);
            });
            client.subscribe('/topic/typing', (message) => {
                const data = JSON.parse(message.body);
                if (!data || !data.userId) return;
                const target = Number(data.targetId || 0);
                if (target && Number(target) === currentUserId && data.status === 'typing') {
                    if (threadHint) {
                        threadHint.textContent = 'Typing...';
                    }
                }
            });
            client.subscribe('/topic/reactions', (message) => {
                const data = JSON.parse(message.body);
                if (!data || !data.messageId) return;
                const bubble = document.querySelector(`.bubble[data-message-id="${data.messageId}"]`);
                if (!bubble) return;
                const reactionNode = bubble.querySelector('.reaction-badge');
                if (reactionNode) {
                    reactionNode.textContent = `${reactionNode.textContent || ''}${data.emoji}`.trim();
                } else {
                    const pill = document.createElement('span');
                    pill.className = 'reaction-badge';
                    pill.textContent = data.emoji;
                    bubble.appendChild(pill);
                }
            });
            client.subscribe('/topic/polls', (message) => {
                const data = JSON.parse(message.body);
                if (!data || data.type !== 'poll') return;
                const pollBox = document.createElement('div');
                pollBox.className = 'poll-card';
                pollBox.innerHTML = `<strong>${data.question}</strong>` +
                    (Array.isArray(data.options) ? data.options.map((opt, idx) => `<button type="button" data-poll-index="${idx}" class="poll-option">${opt}</button>`).join('') : '');
                if (messageStream) {
                    messageStream.appendChild(pollBox);
                }
            });
            client.send('/app/chat.join', {}, JSON.stringify({ userId: currentUserId, username: shell.dataset.currentUserName || 'You' }));
        }, (error) => {
            console.warn('WebSocket connection error:', error);
        });
    }

    function sendTypingStatus(isTyping) {
        if (!wsState.client || !activeContactId || !currentUserId) return;
        const state = isTyping ? 'typing' : 'idle';
        if (wsState.lastTypingStatus === state) return;
        wsState.lastTypingStatus = state;
        wsState.client.send('/app/chat.typing', {}, JSON.stringify({
            userId: currentUserId,
            targetId: activeContactId,
            type: state
        }));
    }

    function addEmojiReaction(messageId, emoji) {
        if (!wsState.client || !messageId) return;
        wsState.client.send('/app/chat.reaction', {}, JSON.stringify({
            userId: currentUserId,
            messageId,
            emoji
        }));
    }

    function createPoll(question, options) {
        if (!wsState.client) return;
        wsState.client.send('/app/chat.poll', {}, JSON.stringify({
            pollId: Date.now(),
            question,
            options,
            userId: currentUserId
        }));
    }

    const emojiSet = ['👍', '❤️', '😂', '🎉', '😮'];
    function bindEmojiReactions() {
        document.querySelectorAll('.bubble').forEach((bubble) => {
            if (bubble.dataset.reactionBound === 'true') return;
            bubble.dataset.reactionBound = 'true';
            const reactionWrap = document.createElement('div');
            reactionWrap.className = 'reaction-picker';
            emojiSet.forEach((emoji) => {
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'reaction-button';
                btn.textContent = emoji;
                btn.addEventListener('click', () => addEmojiReaction(Number(bubble.dataset.messageId || 0), emoji));
                reactionWrap.appendChild(btn);
            });
            bubble.appendChild(reactionWrap);
            bubble.addEventListener("keydown", (event) => {
                const index = Number(event.key) - 1;
                if (index >= 0 && index < emojiSet.length) {
                    event.preventDefault();
                    addEmojiReaction(Number(bubble.dataset.messageId || 0), emojiSet[index]);
                }
            });
        });
    }

    if (messageStream) {
        const observer = new MutationObserver(() => bindEmojiReactions());
        observer.observe(messageStream, { childList: true, subtree: true });
        bindEmojiReactions();
    }

    if (messageInput) {
        messageInput.addEventListener('input', () => {
            sendTypingStatus(messageInput.value.trim().length > 0);
        });
    }

    if (messageInput) {
        messageInput.addEventListener('blur', () => sendTypingStatus(false));
    }

    initWebSocket();

    if (contactList) {
        const cards = contactList.querySelectorAll('.contact-item');
        cards.forEach((card) => {
            const pid = card.dataset.contactId;
            if (!pid) return;
            const pill = document.createElement('span');
            pill.className = 'presence-pill';
            pill.textContent = 'Offline';
            card.appendChild(pill);
        });
    }

    const createQuickPoll = () => {
        openProfessionalDialog({
            title: "Create live poll",
            inputLabel: "Ask a question and list options separated by commas",
            inputValue: "What should we prioritize next? | Design, Build, QA",
            confirmText: "Share poll",
            onConfirm: async () => {
                const input = document.getElementById("dialogInput");
                const raw = input?.value?.trim();
                if (!raw) return;
                const [questionPart, optionsPart] = raw.split("|");
                const question = (questionPart || "Live poll").trim();
                const options = (optionsPart || questionPart || "Yes,No").split(",").map(part => part.trim()).filter(Boolean);
                if (!options.length) return;
                createPoll(question, options);
                if (threadHint) {
                    threadHint.textContent = "Poll shared with the team.";
                }
            }
        });
    };

    if (pollButton) {
        pollButton.addEventListener("click", createQuickPoll);
    }

    document.addEventListener("copy", (event) => {
        if (event.target.closest(".message-stream")) {
            event.preventDefault();
        }
    });

    document.addEventListener("cut", (event) => {
        if (event.target.closest(".message-stream")) {
            event.preventDefault();
        }
    });

    document.addEventListener("contextmenu", (event) => {
        if (event.target.closest(".message-stream")) {
            event.preventDefault();
        }
    });

    document.addEventListener("keydown", (event) => {
        if (!(event.ctrlKey || event.metaKey)) return;
        if (["c", "s", "p", "u"].includes(event.key.toLowerCase())) {
            event.preventDefault();
        }
    });

})();


