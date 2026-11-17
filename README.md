# TeamConnect

TeamConnect is a Java web application that brings together real-time team messaging and employee management. It combines JSP pages for the browser UI, a Spring Boot application and JSON APIs, MySQL persistence, and a WebSocket/STOMP channel for live collaboration. The employee management workspace (EMS) is integrated with the existing chat product: it reuses TeamConnect accounts, sessions, notifications, and project/department chat spaces.

This README describes the software that is currently in this repository. It is not a standalone, pure-JSP/Tomcat-9 EMS: the application uses Spring Boot 3.4, Java 17, Spring MVC, JPA, and the embedded servlet container configured by Spring Boot.

## Contents

- [What the software does](#what-the-software-does)
- [Panels and roles](#panels-and-roles)
- [End-to-end workflows](#end-to-end-workflows)
- [Feature inventory](#feature-inventory)
- [Architecture and request flow](#architecture-and-request-flow)
- [Routes and API overview](#routes-and-api-overview)
- [Data model](#data-model)
- [Project structure](#project-structure)
- [Run locally](#run-locally)
- [Configuration](#configuration)
- [Database migrations](#database-migrations)
- [Deployment and operations](#deployment-and-operations)
- [Security and current limitations](#security-and-current-limitations)

## What the software does

TeamConnect is a shared workspace for:

- TeamConnect login and session-based access, plus administrator-managed account creation. A registration page is present, but public self-registration is currently disabled.
- One-to-one messaging, group conversations, and message attachments.
- Live presence and collaboration events through WebSockets and STOMP.
- Administration of TeamConnect accounts, notifications, and activity reports.
- An employee directory, role-aware workforce dashboards, attendance, leave, payroll, projects, performance reviews, documents, reports, and settings.
- An optional AI assistant that uses an OpenAI-compatible provider configured through environment variables.

The application is a single deployable web application. Chat and EMS are separate functional areas inside it, not separate services or separate login systems.

## Panels and roles

### TeamConnect member workspace

Logged-in users access the chat workspace at `/chat`. The main application account is stored in `users`. Employee, HR, and manager accounts can also have a linked EMS employee profile through `employees.team_connect_user_id`.

### TeamConnect administrator console

The existing administrator console is at `/admin`, with its own admin login flow and session state. It supports TeamConnect account administration and is also the entry point for administrators to open the EMS operations console at `/ems/admin`.

The administrator console and employee role field are related but distinct: the TeamConnect admin console uses the existing admin authentication, while the EMS employee role is stored on the employee profile.

### EMS employee workspace

Employees sign in through `/ems/login` using their TeamConnect account. After authentication, the account must be linked to an active employee profile. The employee workspace shows personal profile details, leave, attendance, projects, payroll, documents, performance, and announcements. Employees can submit leave requests, upload their own documents, view their own records, and edit selected profile fields.

### EMS HR workspace

HR users sign in through the same `/ems/login` flow and are routed to `/ems/hr`. HR can use the operations console to maintain employee records, departments, projects, attendance, leave, payroll, reviews, documents, and reports. HR cannot assign EMS roles or administer system settings and organization-wide announcements.

### EMS manager workspace

Managers use the employee workspace at `/ems/manager`. They can view their own dashboard. The access service also permits manager access to selected employee-scoped API operations, but the management console is intended for HR and administrators.

### Role summary

| Capability | Employee | Manager | HR | EMS Admin |
|---|---:|---:|---:|---:|
| View own EMS dashboard and profile | Yes | Yes | Yes | Through admin console |
| View own attendance, leave, payroll, projects, documents, reviews | Yes | Yes | Yes | Yes |
| Apply for leave and upload own documents | Yes | Yes | Yes | Yes |
| View/manage employee directory | No | API access is limited by endpoint | Yes | Yes |
| Create/update employee records | No | No | Yes | Yes |
| Assign EMS roles | No | No | No | Yes |
| Manage departments | No | No | Create/update | Full access including delete |
| Manage projects, assignments, and attendance | No | No | Yes | Yes |
| Review leave, process payroll, add performance reviews | No | No | Yes | Yes |
| View reports and employee documents | Own records | Limited by endpoint | Yes | Yes |
| Change system settings and publish announcements | No | No | No | Yes |

Authorization is enforced by the EMS API as well as by the page routes; hiding a page control is not the authorization boundary.

## End-to-end workflows

### Application startup and first database setup

1. Spring Boot starts from `boot.OnlineChatApplication`.
2. Spring configures the MySQL datasource, JPA repositories/entities, MVC/JSP views, and WebSocket/STOMP broker.
3. Flyway applies the database migrations under `src/main/resources/db/migration`.
4. The application serves the JSP pages and HTTP/JSON endpoints.

The database URL defaults to a local `online_chat_app` database. Set database environment variables before starting the application when using another MySQL instance.

### Registration, login, and opening chat

1. A visitor opens the login UI at `/views/register.jsp` (also reachable from the welcome page).
2. The user submits only a username and password; the application validates the credentials through the existing account services and database.
3. On successful login, the application checks the linked employee profile and determines its role internally, then routes the user to the matching employee, manager, or HR workspace. Administrator accounts use the separate `/admin` login.
4. The controller loads the account and conversation context for `/chat`; workforce users can also open their EMS dashboard.
5. Normal chat history and sends use HTTP endpoints and persisted records. Live presence and collaboration events use the WebSocket endpoint.

The same UI includes a registration form, but `POST /register` currently reports that registration is disabled. User accounts are created by the existing administrator/account-management flow.

### Opening the EMS

1. The user opens `/ems/login` and authenticates with the existing TeamConnect account.
2. The application resolves the account's linked employee profile.
3. The profile's active status and EMS role determine access and the role dashboard.
4. HR lands on `/ems/hr`; employees and managers land on their corresponding `/ems/{role}` dashboard.
5. TeamConnect administrators use `/admin` and then select **Employee operations** to open `/ems/admin`.

If an account is not linked to an employee record, the EMS login displays an error rather than creating a profile or using a hardcoded employee credential.

### HR employee and department workflow

1. HR opens the operations console and loads employees and departments from `/api/ems`.
2. HR creates or edits an employee, selects a department, and saves the employee record.
3. HR-created employees receive the `EMPLOYEE` role. EMS role changes are restricted to administrators.
4. Deactivating an employee preserves their historical payroll, attendance, reviews, and other associated data.
5. HR can create/update departments. An administrator can also delete a department; existing employee department references are set to no department by the schema's foreign-key rule.

An employee's TeamConnect account association is optional when creating an employee. To sign in to EMS, the employee must have a valid TeamConnect user ID mapping.

### Projects and team collaboration

1. HR or an administrator creates a project and its dates/status.
2. Employees are assigned to a project through the project membership workflow.
3. An employee's project list is loaded from their project assignments.
4. When a project or department is created, the application attempts to create a related TeamConnect chat group/channel and stores its ID.

Project/department creation is allowed to succeed if the related chat group cannot be created, so the workforce record does not depend on the chat-channel operation.

### Attendance and leave

- HR records one attendance entry per employee and date. Saving an existing employee/date pair updates that entry rather than creating a duplicate.
- Employees view their attendance history on their personal dashboard.
- Employees submit leave requests with a type, dates, and reason.
- HR or administrators approve or reject pending requests. Once reviewed, a request cannot be reviewed again through the status endpoint.
- Leave submission and review can create an in-app notification. Email delivery is optional and requires configuration.
- Administrators can disable attendance and leave through system settings. A disabled module rejects its corresponding API operations.

### Payroll and performance

- HR enters the employee, pay period, payment date, base salary, bonus, and deductions.
- Net salary is calculated as `base salary + bonus - deductions`; deductions cannot produce a negative net amount.
- Legacy clients that submit a net `amount` without the new components remain supported.
- Employees can view their own payroll records; HR/admin can view payroll across employees.
- HR records performance reviews with a rating from 1 to 10, review date, comments, reviewer, and publication status.
- Employees see their own reviews. HR/admin can review records across the workforce.

The V3 database migration adds payroll components while keeping existing salary records valid.

### Documents

- HR/admin can upload a document for an employee from the operations console. Employees can upload to their own profile.
- Files are stored under the configured EMS files directory using a generated storage key; the database stores metadata, not the document bytes.
- Downloads are authorized against the employee profile associated with the document.
- The upload size limit is 20 MB in the EMS endpoint, subject to the configured servlet multipart limits.

Back up the document directory as well as MySQL: database backups alone do not include uploaded EMS files.

### Reports, announcements, and settings

- HR and administrators can view workforce counts, salary statistics, department headcounts, and the five highest-paid employees.
- Administrators can publish announcements to everyone, HR, or managers. The announcement feed filters by audience.
- Administrators can toggle attendance, payroll, leave management, and email notifications.
- Email notifications require both the module setting to be on and SMTP/email configuration to be enabled.

### AI assistant

The chat UI can call `/api/ai/chat`. The server uses the configured AI provider for responses, announcement drafts, review-comment drafts, and read-only summaries of the selected chat thread. A valid provider API key and network access are required for these generated responses. The assistant can also execute a direct message command such as `Send a message to Alex good morning`; it resolves the recipient against active workspace contacts and sends immediately only when the username matches.

The EMS includes weekday attendance reminders and HR anomaly reports, leave triage recommendations, payroll pre-check warnings, onboarding document checklists, announcement drafting, and HR-triggered review-comment drafts. Leave and payroll agents never make HR decisions; performance drafts do not assign ratings, and only administrators can publish announcements. Attendance defaults to a 10:00 weekday check, a 09:30 late threshold, and three late check-ins in 30 days. Payroll flags net-pay changes over 20%. These values can be overridden with `ems.agents.attendance.cron`, `ems.agents.attendance.late-after`, `ems.agents.attendance.late-count`, and `ems.agents.payroll.jump-threshold`.

Payment reconciliation is inactive until a `PaymentGatewayAgentProvider` is supplied by a gateway integration. The provider interface is read-only: it reports account availability and payout mismatches but has no status-sync or payment-approval operation. Its nightly check defaults to 02:00 and can be overridden with `ems.agents.payments.reconciliation-cron`. HR actions and reports are available under `/api/ems/agents/*`.

Additional workspace agents provide chat follow-up drafts with user-confirmed personal tasks, meeting-note summaries with decisions and action items, project briefs based on recorded project metadata, admin-managed policy Q&A, personal employee self-service, a prioritized/deduplicated 24-hour notification digest, HR data-quality findings, and access-controlled keyword search within a selected chat thread. Agent tasks and policy documents are stored by migration `V4__workspace_agent_features.sql`. Policy answers use only active policy-library entries; an administrator must enter and maintain the approved source text.

## Feature inventory

### Messaging and collaboration

- TeamConnect login/logout and account sessions. Public self-registration is disabled; administrators can create accounts.
- One-to-one conversation history and message sending.
- Message editing/deletion operations exposed by the web controller.
- Message attachments with metadata and file retrieval.
- Group creation, group membership operations, and group messages.
- Presence, typing, reaction, poll, and poll-vote events over STOMP.
- A current online-user endpoint at `/api/chat/online`.
- Project and department chat spaces when channel creation succeeds.

### Administration

- Separate administrator login and logout.
- Account create, update, delete, and status operations.
- Administrative notification broadcasts.
- Admin activity log and CSV exports for accounts and activity.
- Admin dashboard statistics and links to employee operations.

### Employee management

- Employee directory, employee profile, role, department, status, and salary information.
- Department and project management with project memberships.
- Employee dashboard with personal workforce records.
- Attendance entry and history.
- Leave request, status, and review workflow.
- Payroll records, salary components, and calculated net pay.
- Performance reviews rated from 1 to 10.
- Employee document upload and authorized downloads.
- Audience-filtered announcements, workforce reports, and module settings.
- Optional email and in-app notification integration.

## Architecture and request flow

TeamConnect uses a layered Spring application with JSP views. Some existing web features are implemented in MVC controllers and services; EMS browser pages are JSPs backed by Spring MVC routes and JSON REST endpoints. It is not a pure-JSP/Model-1 application and does not use Servlets as the only business-logic layer.

```text
Browser
  ├─ JSP pages and static assets
  ├─ HTTP form submissions / JSON API requests
  └─ SockJS + STOMP connection (/ws)
          │
          ▼
Spring Boot application
  ├─ MVC controllers (page routes and chat/admin operations)
  ├─ EMS REST controllers (/api/ems/**)
  ├─ Services (authentication, chat, EMS access/notifications)
  ├─ JPA repositories and selected JDBC operations
  └─ WebSocket message handlers and simple STOMP broker
          │
          ├─ MySQL: accounts, messages, workforce records, metadata
          ├─ EMS file directory: uploaded employee documents
          └─ Optional SMTP and OpenAI-compatible AI provider
```

### Layer responsibilities

| Layer | Responsibility | Examples |
|---|---|---|
| JSP and static assets | Login, chat, admin, employee, and operations interfaces | `src/main/webapp/views/`, `assets/` |
| MVC controllers | Render pages and handle browser-oriented operations | `controller/ApplicationController`, `ems.controller.EmsWebController` |
| REST controllers | Accept/return JSON and multipart requests | `ems.controller.EmsController` |
| Services | Business rules, access checks, notifications, chat behavior | `service/`, `ems.service/` |
| Repositories/DAOs | Read and write persisted records | `repository/`, `dao/`, `ems.repository/` |
| Models/entities | Map persisted rows and request data | `model/`, `ems.model/`, `ems.dto/` |
| WebSocket handlers | Broadcast live collaboration events | `chat/ChatSocketController` |
| Database migrations | Create/update the schema without replacing existing app tables | `src/main/resources/db/migration/` |

### Application and session model

`boot.OnlineChatApplication` scans the existing TeamConnect packages and the EMS packages, and configures entity and repository scanning. Login creates or updates the existing HTTP session. EMS authentication reuses the TeamConnect user identity and resolves it to an employee profile. EMS access checks are centralized in `ems.service.EmsAccessService`.

### Real-time messaging model

The WebSocket/SockJS endpoint is `/ws`; STOMP application messages use the `/app` prefix and the in-memory broker publishes `/topic` and `/queue` destinations. Chat events include join/leave presence, typing, reactions, and polls. Persisted messages continue to use the normal application data layer.

### AI integration

Spring AI is configured for an OpenAI-compatible endpoint. The default configuration targets a Groq-compatible base URL, but the provider URL, model, and API key can be overridden with environment variables.

## Routes and API overview

### Browser routes

| Route | Purpose |
|---|---|
| `/` | Application welcome page |
| `/login`, `/logout` | TeamConnect member login and logout |
| `/register` | Registration endpoint; currently disabled |
| `/chat` | Main messaging workspace |
| `/admin`, `/admin/logout` | Administrator console (the `/admin` page displays the login form when no admin session exists) |
| `POST /admin/login` | Authenticate administrator and establish the admin session |
| `/ems/login` | EMS login using TeamConnect credentials |
| `/ems` | Redirect to the current user's EMS workspace or login |
| `/ems/employee`, `/ems/manager`, `/ems/hr` | Role-specific EMS entry routes |
| `/ems/profile` | Current employee profile editor |
| `/ems/admin` | EMS operations console for TeamConnect administrators |
| `/health` | Lightweight process health response |

### EMS REST API

All EMS JSON endpoints are under `/api/ems`. The API applies session and role checks; individual endpoints are the authoritative permission boundary.

| Resource | Common operations |
|---|---|
| `/employees` | List (HR/admin), create/update, fetch self/authorized profile, deactivate, role assignment (admin) |
| `/employees/me/profile` | Update the current employee's editable contact/profile fields |
| `/departments` | List, create/update, administrator delete |
| `/projects` | List, create/update/delete, add/remove employee membership, list current employee's assigned projects |
| `/attendance` | HR/admin list and mark; employee self history |
| `/leave` | Employee submit and view; HR/admin list and approve/reject pending requests |
| `/payroll` | Employee self history; HR/admin list by employee, all records, and process pay |
| `/performance` | Employee self reviews; HR/admin list and create reviews |
| `/documents` | Employee self list/upload; HR/admin list; authorized download by document ID |
| `/announcements` | View announcements allowed for the current audience; administrator publish |
| `/reports/summary` | HR/admin workforce, department, and salary analytics |
| `/settings` | Administrator list and update supported module toggles |

Chat, account, admin, and AI routes are implemented in the existing application controller. WebSocket message destinations are handled by `chat.ChatSocketController`.

## Data model

The main MySQL schema is in `database.sql`; EMS tables are also versioned in Flyway migrations.

### TeamConnect tables

| Table | Purpose |
|---|---|
| `users` | Registered TeamConnect accounts, account roles/status, and login metadata |
| `admin_accounts` | Separate administrator credentials |
| `admin_activity_logs` | Administrator actions and audit details |
| `admin_notifications` | In-app notifications, including EMS notifications |
| `messages` | One-to-one messages |
| `message_attachments` | Attachment metadata and optional stored file content for chat |
| `chat_groups` | Group chat and collaboration spaces |
| `chat_group_members` | Group membership |
| `group_messages` | Group conversation messages |

### EMS tables

| Table | Purpose |
|---|---|
| `employees` | Employee profile, TeamConnect account link, role, department, and employment information |
| `departments` | Department master and optional related TeamConnect chat channel |
| `employee_user_mapping` | Employee-to-user mapping structure |
| `projects` | Project details and optional chat channel |
| `project_members` | Employee project assignments |
| `attendance` | One employee/date attendance record with status and times |
| `leave_requests` | Employee leave submissions and review state |
| `salary_records` | Payroll amount, pay date, period, and optional base/bonus/deduction components |
| `documents` | Employee file metadata and storage key |
| `performance_reviews` | Employee review rating, comments, date, and status |
| `ems_announcements` | Workforce announcements and audience |
| `system_settings` | EMS feature toggles |

Some data remains stored outside MySQL: employee documents are stored in the configured EMS file directory. Uploaded chat files may use the chat attachment storage behavior in the existing application.

## Project structure

```text
src/
  main/
    java/
      boot/             Spring Boot application entry point
      chat/             WebSocket chat and presence events
      config/           WebSocket and application configuration
      controller/       Main TeamConnect MVC controller and health endpoint
      dao/              Existing chat/account data access helpers
      ems/
        controller/     EMS page controller, REST controller, API error mapping
        dto/            Validated EMS request records
        model/           JPA entities for EMS records
        repository/      EMS Spring Data repositories
        service/         EMS access control, employee logic, notifications
      filter/            Servlet response/security headers
      model/             Existing TeamConnect entities
      repository/        Existing TeamConnect repositories
      service/           Existing TeamConnect services
      util/              Web, database, and attachment helpers
    resources/
      application.properties
      db/migration/      Flyway SQL migrations
    webapp/
      index.jsp
      assets/            CSS and JavaScript
      views/             JSP pages for chat, admin, EMS, and registration
      WEB-INF/
database.sql              MySQL schema
Dockerfile                 Container build
pom.xml                    Maven dependencies and build
render.yaml                Render deployment configuration
```

## Run locally

### Prerequisites

- JDK 17
- Maven 3.8+
- MySQL 8+
- Node.js is optional; it is only needed for any local frontend tooling that may be added separately.

### 1. Configure MySQL

Create a MySQL database and user, or use a local development instance. The default JDBC URL targets `online_chat_app` on `localhost:3306` and can create the database if the MySQL account has permission.

For a new database, the base schema can be imported with:

```bash
mysql -u root -p < database.sql
```

Set `DB_URL`, `DB_USERNAME`, and `DB_PASSWORD` for your local database. Use `.env.example` as a starting point if needed; do not commit real credentials.

### 2. Run the application

From the repository root:

```bash
mvn spring-boot:run
```

The default port is `9090`. Open:

```text
http://localhost:9090/
```

Run the test suite with:

```bash
mvn test
```

Build the deployable WAR with:

```bash
mvn package
```

### 3. Open the panels

- TeamConnect member login: `/views/register.jsp` (public registration is disabled).
- TeamConnect administrator login: `/admin` (the login form is shown when signed out).
- EMS user login: `/ems/login`.
- EMS administrator console: sign in through the existing admin flow and use **Employee operations**.

An EMS account requires an employee record linked to the account's TeamConnect user ID and an active employee status. The repository does not define a universal demo username/password; configure or create accounts using the existing application/admin setup.

## Configuration

Application defaults and environment-variable mappings live in `src/main/resources/application.properties`. Keep secrets in environment variables or a local ignored `.env` file.

### Core settings

| Variable | Purpose | Default/notes |
|---|---|---|
| `DB_URL` | MySQL JDBC URL | Local `online_chat_app` URL |
| `DB_USERNAME` | MySQL account name | `root` for local development |
| `DB_PASSWORD` | MySQL password | Provide locally/deploy-time |
| `CONTEXT_PATH` | Optional application context path | Empty by default |
| `SESSION_TIMEOUT` | HTTP session lifetime | `30m` |
| `GROQ_API_KEY` | AI provider key | Optional; required for AI replies |
| `GROQ_BASE_URL` | OpenAI-compatible API base URL | Defaults to Groq-compatible API |
| `GROQ_MODEL` | AI model name | Defaults in `application.properties` |

### EMS settings

| Variable | Purpose | Default/notes |
|---|---|---|
| `EMS_INTEGRATION_ENABLED` | EMS integration configuration flag | Enabled by default |
| `EMS_FILES_DIRECTORY` | Employee document storage directory | Java temporary directory by default; set a persistent path for deployment |
| `EMS_MAX_FILE_SIZE` | Maximum multipart file size | `20MB` |
| `EMS_MAX_REQUEST_SIZE` | Maximum multipart request size | `22MB` |
| `EMS_MAIL_ENABLED` | Allow EMS email sending | Disabled by default |
| `EMS_MAIL_FROM` | Sender address for email | `no-reply@example.com` |
| `MAIL_HOST` | SMTP server hostname | Required for email |
| `MAIL_PORT` | SMTP server port | `587` by default |
| `MAIL_USERNAME` / `MAIL_PASSWORD` | SMTP account credentials | Configure in secret storage |
| `MAIL_SMTP_AUTH` | SMTP authentication | Enabled by default |
| `MAIL_SMTP_STARTTLS` | SMTP STARTTLS | Enabled by default |

Email notifications are sent only when mail configuration is enabled and `EMAIL_NOTIFICATIONS_ENABLED` is true in EMS settings.

Example deployment environment (replace placeholders; do not commit actual secrets):

```text
DB_URL=jdbc:mysql://<mysql-host>:3306/online_chat_app?useSSL=true&serverTimezone=UTC
DB_USERNAME=<database-user>
DB_PASSWORD=<database-password>
EMS_FILES_DIRECTORY=/var/lib/teamconnect/ems-files
EMS_MAIL_ENABLED=true
MAIL_HOST=<smtp-host>
MAIL_PORT=587
MAIL_USERNAME=<smtp-user>
MAIL_PASSWORD=<smtp-password>
GROQ_API_KEY=<provider-api-key>
```

Spring imports optional `.env` and `.env.local` property files from the process working directory. Ensure these files are excluded from version control.

## Database migrations

Flyway migrations are in `src/main/resources/db/migration/`:

- `V2__employee_management.sql` adds the workforce tables and integration fields.
- `V3__employee_management_features.sql` adds salary component columns and seeds EMS feature settings.

The application is configured to baseline an existing database and use Flyway. Back up the database and test migration behavior against a staging copy before deploying to production. Avoid manually applying a migration and then running Flyway against a database whose schema history does not reflect that operation.

## Deployment and operations

The repository includes a Dockerfile and Render configuration. The Dockerfile builds the WAR with Maven/JDK 17 and runs it in external Tomcat 11 on JDK 21; local `mvn spring-boot:run` uses the Spring Boot-managed embedded server. Configure production database, file storage, email, and AI-provider variables in the deployment platform's secret/configuration store. Use a persistent volume for `EMS_FILES_DIRECTORY`; ephemeral container storage can be lost when an instance is replaced or restarted.

### Health endpoint

`GET /health` returns a lightweight HTTP 200 response when the application process is available. It does not check MySQL or other dependencies. If `CONTEXT_PATH` is set, include it in the URL.

### Optional Render keep-alive workflow

The repository may include `.github/workflows/keep-alive.yml`. To enable it:

1. Add a GitHub Actions repository secret named `TEAM_CONNECT_URL`.
2. Set it to the public Render base URL without `/health`, for example `https://<service>.onrender.com`.
3. Ensure Actions are enabled and the workflow is on the default branch.
4. Use **Actions → Team Connect Keep Alive → Run workflow** to test manually.

The workflow requests the lightweight health endpoint. Scheduled requests do not guarantee that a free-tier service will avoid sleep or cold starts.

## Security and current limitations

- Use the existing TeamConnect authentication; the EMS does not use the hardcoded employee credentials described in the original feature outline.
- EMS API methods validate the session and role for protected operations. Employee self-service endpoints resolve the employee from the current TeamConnect user rather than trusting a client-supplied employee ID.
- Admin-only operations include EMS role assignment, system settings, and announcement publishing. HR can manage employee records and people workflows but cannot grant elevated employee roles.
- Employee removal from the HR console is a soft deactivation so related historical data is preserved.
- Password handling and admin authentication follow the existing TeamConnect account/admin implementation. Do not seed or deploy plaintext credentials; protect credential values in environment/secrets management.
- Uploaded employee documents are stored on disk, not in the database BLOB. Secure the storage directory, use persistent backups, and restrict host filesystem access.
- Configure HTTPS in production and restrict database/network access to trusted services.
- The current WebSocket handler uses an in-memory simple broker and in-process online-user state. This is suitable for a single application instance; multi-instance deployments need shared messaging/presence infrastructure.
- WebSocket messages are live events; do not treat ephemeral presence, typing, reaction, or poll broadcasts as durable records unless a persistence feature is explicitly added.
- AI features require an external provider and may send prompt content to that provider. Configure and use them according to your organization's data policies.
- System feature toggles are stored in `system_settings`; they do not replace endpoint authorization.
- The EMS documents and schema have grown incrementally. Review `database.sql` and Flyway migrations together when changing persistence; migration history is the production schema-upgrade path.

## Troubleshooting

| Symptom | Checks |
|---|---|
| `Communications link failure` or MySQL connection error | Verify MySQL is running and `DB_URL`, port, username, and password are current. |
| `Access denied` from MySQL | Verify the configured database account privileges and password. |
| EMS login says no employee profile is linked | Confirm an `employees` row references the logged-in TeamConnect user ID and is active. |
| EMS operation returns unauthorized/forbidden | Sign in again and verify the user's employee role or admin session. |
| Document upload fails | Check multipart size settings, the 20 MB EMS endpoint limit, and write permissions on `EMS_FILES_DIRECTORY`. |
| Document cannot be downloaded after deployment | Check that the configured file directory is persistent and contains the file identified by its storage key. |
| AI response is unavailable | Check provider key, base URL, model name, outbound network access, and provider limits. |
| Email is not sent | Enable SMTP configuration, `EMS_MAIL_ENABLED`, and the `EMAIL_NOTIFICATIONS_ENABLED` setting. |
| Scheduled health workflow fails | Confirm `TEAM_CONNECT_URL` has no `/health` suffix and that the deployment is publicly reachable. |

## License and use

This repository is intended for educational and demonstration purposes. Review dependency licenses and your organization's security, privacy, and operational requirements before production use.
