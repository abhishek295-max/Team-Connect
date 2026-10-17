# TeamConnect

TeamConnect is a full-stack Java chat application built with Spring Boot, JSP, MySQL, and WebSocket technology. It is designed as an enterprise-style communication platform where users can chat in real time, share attachments, manage accounts, and use an AI-powered assistant from within the app.

## Project Summary

This project combines:
- Java backend with Spring Boot
- JSP-based front-end UI
- MySQL database persistence
- real-time communication using WebSockets
- admin panel for account management and reporting
- AI assistant integration through Spring AI / OpenAI-compatible API

It is a practical project for learning modern Java web application architecture, layered design, database integration, and real-time messaging.

---

## Features

### User Features
- Secure login and logout
- User registration flow
- Session-based authenticated access
- One-to-one chat messaging
- Real-time online/offline presence
- Typing indicators
- Message reactions
- File upload and attachment sending
- Attachment storage and retrieval
- User profile/account context in session

### Admin Features
- Admin login
- Account creation, update, and deletion
- User role and status management
- Activity logs tracking
- Admin notifications to users
- CSV export for account reports
- CSV export for admin activity reports
- Dashboard statistics and recent activity

### Group Chat Features
- Group creation
- Adding group members
- Group message sending
- Membership validation
- Group chat structure prepared in models/services/repository

### AI Assistant Features
- Chat endpoint `/api/ai/chat`
- AI assistant integrated using Spring AI and OpenAI-compatible model
- Default system prompt for assistant behavior
- Restricted to logged-in users
- Error handling for unauthorized access and failed AI requests

### Real-Time Communication
- WebSocket-based presence events
- Typing status events
- Reaction events
- Poll event support
- Live updates through STOMP topics

---

## Tech Stack

### Backend
- Java 17
- Spring Boot 3.4
- Spring Web MVC
- Spring Data JPA
- Spring WebSocket
- Spring Security Crypto
- Jakarta Servlet API
- Spring AI (OpenAI-compatible client)

### Frontend
- JSP
- HTML5
- CSS3
- JavaScript
- AJAX

### Database
- MySQL 8+

### Tools
- Maven
- Docker
- Tomcat embedded / external server configuration
- Render / Railway deployment support

---

## Project Structure

```text
Online_Chat_App/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   ├── boot/
│   │   │   │   └── OnlineChatApplication.java
│   │   │   ├── chat/
│   │   │   │   ├── ChatPresenceListener.java
│   │   │   │   └── ChatSocketController.java
│   │   │   ├── config/
│   │   │   │   └── WebSocketConfig.java
│   │   │   ├── controller/
│   │   │   │   └── ApplicationController.java
│   │   │   ├── dao/
│   │   │   │   ├── MessageDAO.java
│   │   │   │   └── UserDAO.java
│   │   │   ├── filter/
│   │   │   │   └── SecurityFilter.java
│   │   │   ├── model/
│   │   │   │   ├── GroupChat.java
│   │   │   │   ├── Message.java
│   │   │   │   ├── MessageAttachment.java
│   │   │   │   └── User.java
│   │   │   ├── repository/
│   │   │   │   ├── GroupChatRepository.java
│   │   │   │   ├── JpaUserRepository.java
│   │   │   │   ├── MessageRepository.java
│   │   │   │   └── UserRepository.java
│   │   │   ├── service/
│   │   │   │   ├── AdminService.java
│   │   │   │   ├── GroupChatService.java
│   │   │   │   ├── MessageService.java
│   │   │   │   └── UserService.java
│   │   │   └── util/
│   │   │       ├── AttachmentStorageListener.java
│   │   │       ├── AttachmentUtil.java
│   │   │       ├── DBConnection.java
│   │   │       ├── JsonUtil.java
│   │   │       └── WebUtil.java
│   │   ├── resources/
│   │   │   └── application.properties
│   │   └── webapp/
│   │       ├── index.jsp
│   │       ├── assets/
│   │       ├── views/
│   │       │   ├── admin-login.jsp
│   │       │   ├── admin.jsp
│   │       │   ├── chat.jsp
│   │       │   └── register.jsp
│   │       └── WEB-INF/
│   └── ...
├── database.sql
├── pom.xml
├── Dockerfile
├── README.md
├── render.yaml
├── conf/
├── logs/
├── target/
├── temp/
├── webapps/
├── work/
├── .env
└── .gitignore
```

---

## Database Schema

The project uses MySQL and a schema defined in `database.sql`.

Main tables:
- `users`
- `admin_accounts`
- `admin_activity_logs`
- `admin_notifications`
- `messages`
- `message_attachments`
- `chat_groups`
- `chat_group_members`
- `group_messages`

### Example schema

```sql
CREATE TABLE IF NOT EXISTS users (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL,
    last_login_ip VARCHAR(64) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_users_username (username),
    UNIQUE KEY uk_users_email (email)
) ENGINE=InnoDB;
```

---

## Configuration

Main app settings are in:

`src/main/resources/application.properties`

```properties
spring.mvc.view.prefix=/
spring.mvc.view.suffix=.jsp
server.port=9090

app.database.url=${DB_URL:jdbc:mysql://localhost:3306/online_chat_app?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC}
app.database.username=${DB_USERNAME:root}
app.database.password=${DB_PASSWORD:<secret-from-environment>}

spring.datasource.url=${app.database.url}
spring.datasource.username=${app.database.username}
spring.datasource.password=${app.database.password}
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.database-platform=org.hibernate.dialect.MySQLDialect

spring.ai.openai.api-key=${GROQ_API_KEY:}
spring.ai.openai.base-url=${GROQ_BASE_URL:https://api.groq.com/openai}
spring.ai.openai.chat.options.model=${GROQ_MODEL:openai/gpt-oss-120b}
spring.ai.openai.chat.options.temperature=0.4
```

This file controls:
- database connection
- server port
- JPA behavior
- AI assistant provider and model settings

---

## How the App Works

### 1. App Startup
Application starts from `OnlineChatApplication.java`:

```java
@SpringBootApplication(scanBasePackages = {"boot", "controller", "filter", "util", "dao", "model", "service", "repository", "config", "chat"})
@EntityScan(basePackages = "model")
@EnableJpaRepositories(basePackages = "repository")
public class OnlineChatApplication {
    public static void main(String[] args) {
        SpringApplication.run(OnlineChatApplication.class, args);
    }
}
```

### 2. HTTP Requests
Requests are handled in `ApplicationController.java`, including:
- `/login`
- `/register`
- `/logout`
- `/chat`
- `/admin`
- `/admin/login`
- `/api/ai/chat`

### 3. Service Layer
Business logic is in:
- `UserService`
- `MessageService`
- `GroupChatService`
- `AdminService`

These services coordinate validation, business rules, and DB actions.

### 4. Persistence Layer
Database access is handled through:
- JPA repositories in `repository/`
- DAO classes in `dao/`
- JPA entities in `model/`

### 5. Real-Time Features
WebSocket logic is managed in:
- `WebSocketConfig.java`
- `ChatSocketController.java`
- `ChatPresenceListener.java`

This powers:
- online presence
- typing indicators
- reactions
- live event broadcasting

### 6. AI Assistant
The AI assistant is connected in the controller using `ChatClient`:

```java
this.aiChatClient = chatClientBuilder
    .defaultSystem("You are the helpful TeamConnect workspace assistant. Keep responses clear and concise.")
    .build();
```

And then called via:

```java
String reply = aiChatClient.prompt()
    .user(message.trim())
    .call()
    .content();
```

This allows the app to receive user requests and return AI-generated replies through the `/api/ai/chat` endpoint.

---

## Main Files and Responsibilities

### Entry Points
- `src/main/java/boot/OnlineChatApplication.java` – application bootstrap
- `src/main/java/controller/ApplicationController.java` – main web controller

### Core Logic
- `service/UserService.java` – user login, registration, account operations
- `service/MessageService.java` – chat message handling
- `service/AdminService.java` – admin dashboards and activity logs
- `service/GroupChatService.java` – group conversations

### Models
- `model/User.java` – user entity
- `model/Message.java` – message entity
- `model/GroupChat.java` – group chat entity
- `model/MessageAttachment.java` – attachment metadata entity

### Real-Time Layer
- `config/WebSocketConfig.java` – WebSocket configuration
- `chat/ChatSocketController.java` – live events and presence logic

### Utility Layer
- `util/AttachmentUtil.java` – file attachment handling
- `util/DBConnection.java` – database connection utility
- `util/JsonUtil.java` – JSON helper methods
- `util/WebUtil.java` – web helper methods

---

## Setup Instructions

### Prerequisites
- Java 17+
- Maven
- MySQL 8+
- Git

### 1. Clone the repository

```bash
git clone <project-url>
cd Online_Chat_App
```

### 2. Create the database

```sql
CREATE DATABASE online_chat_app;
```

Then import the schema:

```bash
mysql -u root -p online_chat_app < database.sql
```

### 3. Configure environment variables

Update `application.properties` or set environment variables such as:

```properties
DB_URL=jdbc:mysql://localhost:3306/online_chat_app
DB_USERNAME=root
DB_PASSWORD=your_password
GROQ_API_KEY=your_ai_key
```

### 4. Build and run

```bash
mvn clean install
mvn spring-boot:run
```

Then open the app in browser:

```text
http://localhost:9090/
```

---

## Example Flow

### Login Flow
```text
Browser
  -> /login
  -> ApplicationController.login()
  -> UserService.authenticate()
  -> MySQL users table
  -> session created
  -> redirect to /chat
```

### AI Chat Flow
```text
Browser
  -> /api/ai/chat
  -> ApplicationController.ai()
  -> ChatClient prompt
  -> AI model (Groq/OpenAI compatible)
  -> JSON response with reply
```

---

## Security Notes

The project includes several security-aware patterns:
- session-based authentication
- separate admin login flow
- user access checks in controller methods
- unauthorized user protection for AI endpoint
- activity logging for admin actions

---

## Future Improvements

This project is already structured for extension with:
- enhanced validation and sanitization
- stronger role-based access control
- better UI responsiveness
- notifications and push support
- REST API layer
- richer group chat features
- improved mobile UX

---

## Summary

TeamConnect is a practical full-stack enterprise chat application that merges:
- Java backend architecture
- MVC pattern
- MySQL integration
- JPA data persistence
- WebSocket real-time updates
- admin reporting features
- AI assistant integration

It is a good project for learning how enterprise-style communication systems are built using Java and Spring Boot.

---

## Employee Management Workspace

The EMS functionality is integrated into the existing TeamConnect application. Existing chat, WebSocket, session, and TeamConnect admin routes remain available.

### Role entry points

- Employee, HR, and manager workspace: `/ems/login`
- Role dashboard: `/ems/{role}`
- Existing TeamConnect administrator console: `/admin`
- EMS REST API: `/api/ems/**`

The EMS login reuses TeamConnect authentication. The employee record linked to the authenticated TeamConnect user controls the EMS role. Administrator access remains separate through the existing TeamConnect admin session.

### EMS capabilities

The integrated API supports employees, departments, projects, project and department chat channels, project members, attendance, leave, payroll, documents, performance reviews, announcements, in-app notifications, secure file downloads, optional email notifications, and authenticated AI commands.

Useful secure chat commands include:

```text
/my-profile
/my-attendance
/my-leave
/my-payroll
/my-projects
/apply-leave
```

### Deployment configuration

Set these environment variables in every deployed environment:

```properties
DB_URL=jdbc:mysql://host:3306/online_chat_app?useSSL=true&serverTimezone=UTC
DB_USERNAME=teamconnect_app
DB_PASSWORD=<secret>
EMS_INTEGRATION_ENABLED=true
EMS_FILES_DIRECTORY=/var/lib/teamconnect/ems-files
EMS_MAIL_ENABLED=true
EMS_MAIL_FROM=no-reply@example.com
MAIL_HOST=smtp.example.com
MAIL_PORT=587
MAIL_USERNAME=<smtp-user>
MAIL_PASSWORD=<smtp-secret>
MAIL_SMTP_AUTH=true
MAIL_SMTP_STARTTLS=true
GROQ_API_KEY=<secret>
```

The database migration is located at `src/main/resources/db/migration/V2__employee_management.sql`. Flyway is configured to baseline an existing TeamConnect database and add EMS tables without deleting existing records. Configure a backup and run the migration against a staging database before production deployment.

Spring imports the project `.env` automatically when running from the project directory. If startup reports `UnknownHostException`, `Communications link failure`, or `Access denied`, update `.env` with the current MySQL host, port, username, and password. The previous Aiven hostname is no longer resolvable and cannot be repaired by application code. Use `.env.example` as the template and never commit the real `.env` file.

## License

This project is intended for educational and demonstration purposes.
