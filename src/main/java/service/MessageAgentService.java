package service;

import model.User;
import org.springframework.stereotype.Service;
import util.AttachmentUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class MessageAgentService {

    private static final Pattern MESSAGE_COMMAND = Pattern.compile(
            "^(?:please\\s+)?(?:send\\s+(?:a\\s+)?message\\s+to|tell)(?:\\s+(.*))?$",
            Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern MESSAGE_LEAD_IN = Pattern.compile(
            "^(?:saying|that says|to say)\\s+",
            Pattern.CASE_INSENSITIVE);

    private final UserService users;
    private final MessageService messages;

    public MessageAgentService(UserService users, MessageService messages) {
        this.users = users;
        this.messages = messages;
    }

    public Optional<String> command(String raw, int senderId) {
        if (raw == null) {
            return Optional.empty();
        }

        Matcher command = MESSAGE_COMMAND.matcher(raw.trim());
        if (!command.matches()) {
            return Optional.empty();
        }

        String recipientAndBody = command.group(1);
        if (recipientAndBody == null || recipientAndBody.isBlank()) {
            return Optional.of("Who should I send the message to?");
        }

        List<User> matches = new ArrayList<>();
        int longestMatch = -1;
        for (User contact : users.contacts(senderId)) {
            String username = contact.getUsername() == null ? "" : contact.getUsername().trim();
            if (!matchesRecipientPrefix(recipientAndBody, username)) {
                continue;
            }

            if (username.length() > longestMatch) {
                matches.clear();
                longestMatch = username.length();
            }
            if (username.length() == longestMatch) {
                matches.add(contact);
            }
        }

        if (matches.isEmpty()) {
            return Optional.of("I couldn't find that person in your workspace contacts. Check the name and try again.");
        }
        if (matches.size() > 1) {
            String names = matches.stream()
                    .map(User::getUsername)
                    .distinct()
                    .reduce((first, second) -> first + ", " + second)
                    .orElse("");
            return Optional.of("I found more than one matching contact (" + names + "). Please use a unique username.");
        }

        User recipient = matches.get(0);
        String body = recipientAndBody.substring(longestMatch).trim();
        body = stripSeparators(body);
        Matcher leadIn = MESSAGE_LEAD_IN.matcher(body);
        if (leadIn.find()) {
            body = body.substring(leadIn.end()).trim();
        }
        body = stripOuterQuotes(body);
        if (body.isBlank()) {
            return Optional.of("What message should I send to " + recipient.getUsername() + "?");
        }

        boolean sent = messages.send(senderId, recipient.getId(), body, (AttachmentUtil.StoredAttachment) null);
        if (!sent) {
            return Optional.of("I couldn't send the message to " + recipient.getUsername() + ". Please try again.");
        }
        return Optional.of("Sent to " + recipient.getUsername() + ": " + body);
    }

    private boolean matchesRecipientPrefix(String commandText, String username) {
        if (username.isBlank() || commandText.length() < username.length()
                || !commandText.regionMatches(true, 0, username, 0, username.length())) {
            return false;
        }
        return commandText.length() == username.length()
                || Character.isWhitespace(commandText.charAt(username.length()))
                || ",:;-".indexOf(commandText.charAt(username.length())) >= 0;
    }

    private String stripSeparators(String value) {
        int start = 0;
        while (start < value.length()) {
            char character = value.charAt(start);
            if (!Character.isWhitespace(character) && ",:;-".indexOf(character) < 0) {
                break;
            }
            start++;
        }
        return value.substring(start).trim();
    }

    private String stripOuterQuotes(String value) {
        if (value.length() >= 2) {
            char first = value.charAt(0);
            char last = value.charAt(value.length() - 1);
            if ((first == '"' && last == '"') || (first == '\'' && last == '\'')) {
                return value.substring(1, value.length() - 1).trim();
            }
        }
        return value;
    }
}
