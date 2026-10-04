# NovaCart Application Discovery

## 1. Application Overview

NovaCart is a compact commerce demonstration application.

The application consists of:

- A browser-based frontend.
- A Python FastAPI backend API.
- A database used for product and order persistence.

The frontend provides product browsing, cart management, promo code handling, checkout, test order creation, and saved order history.

The backend provides product and order APIs and handles database persistence.

---

## 2. Application Components

### Frontend

The frontend is a static browser-based application consisting of:

- `frontend/index.html` — UI structure.
- `frontend/app.js` — client-side application behavior and API communication.
- `frontend/styles.css` — UI styling and responsive layout.

The initial local run does not require a separate frontend development or web server. The `index.html` file can be opened directly in a browser.

### Backend

The backend is located under:

`backend/`

The application entrypoint is:

`backend/app/main.py`

The backend is implemented using Python and FastAPI and is served using Uvicorn.

### Database

The application supports SQLite and PostgreSQL.

For the cohort environment, PostgreSQL is expected.

For local development, the application has a SQLite fallback.

---

## 3. Languages and Frameworks

The application uses:

- Python
- FastAPI
- Uvicorn
- Pydantic
- JavaScript
- HTML
- CSS
- SQLite for the local fallback database
- PostgreSQL for the expected cohort database

The backend dependency file contains:

- `fastapi==0.128.2`
- `uvicorn==0.48.0`
- `psycopg[binary]>=3.2,<4`

---

## 4. Startup and Build Commands

### Backend startup

From the `backend` directory:

```bash
python -m uvicorn app.main:app --host 0.0.0.0 --port 8080
The backend was successfully started locally using this command.
The application reported successful startup and database initialization.
Frontend startup
The initial local run does not require a frontend development server.
Open:
frontend/index.html

directly in a browser using the file:// protocol.
No separate frontend development server is required for the initial local run.
5. Listening Ports
The backend listens on:
TCP 8080

The application was successfully started with:
--host 0.0.0.0 --port 8080

During runtime testing, Uvicorn reported:
Uvicorn running on http://0.0.0.0:8080

The local browser successfully accessed the backend through:
http://localhost:8080

6. Application Dependencies
The backend dependencies are defined in:
backend/requirements.txt

Current dependencies:
fastapi==0.128.2
uvicorn==0.48.0
psycopg[binary]>=3.2,<4

The Python environment successfully installed these dependencies and started the application.
## 7. Configuration and Environment Variables
The application reads the following environment variables:
Variable	Purpose	Default / Example
DATABASE_URL	Database connection configuration	sqlite:///./novacart.db
APP_ENV	Application environment	development
API_VERSION	API version	v1
LOG_LEVEL	Application log level	INFO


The repository also provides .env.example containing an example PostgreSQL configuration:
APP_ENV=development
API_VERSION=v1
DATABASE_URL=postgresql://novacart:change-me@localhost:5432/novacart

The application uses SQLite when DATABASE_URL is not configured with a non-SQLite database URL.
8. Secrets or Sensitive Configuration
DATABASE_URL may contain database authentication credentials.
The .env.example file contains:
change-me

as a placeholder password.
This must not be treated as a production credential.
A real production database password should not be committed to source control and should be provided through an appropriate secure runtime configuration or secret-management mechanism.
9. Persistence Requirements
The application requires database persistence for:
- Products
- Orders
- Order items
The backend creates the required database schema during application startup.
For SQLite, the default database file is:
novacart.db

The application creates tables for:
- products
- orders
- order_items
Products are seeded when the products table is empty.
During local runtime testing, a test order was successfully created and saved to the database.
The saved order was subsequently retrieved and displayed in the frontend order history.
Therefore, database persistence is required for order history and application data.
10. Database Dependencies
The application supports two database engines:
SQLite
SQLite is the default local development fallback.
The application uses the Python sqlite3 module for SQLite connections.
PostgreSQL
PostgreSQL is expected for the cohort environment.
The application uses psycopg for PostgreSQL connectivity.
The example PostgreSQL configuration uses:
Host: localhost
Port: 5432
Database: novacart
User: novacart

The actual production PostgreSQL server, credentials, availability, backup strategy, and high-availability requirements are not defined in the current application handover information.
11. Health and Readiness Behavior
The application provides two operational endpoints.
Health endpoint
GET /health

This endpoint confirms that the application is responding.
During local runtime testing it returned:
{
  "status": "ok",
  "environment": "development",
  "checked_at": "..."
}

Readiness endpoint
GET /ready

This endpoint verifies database connectivity by opening a database connection and executing a test query.
During local runtime testing it returned:
{
  "status": "ready"
}

If the database is unavailable, the readiness endpoint returns HTTP 503.
Therefore:
/health = application health
/ready  = application + database readiness

12. Service-to-Service Communication
The frontend communicates with the FastAPI backend over HTTP.
When the frontend is opened directly using file://, the default API base URL is:
http://localhost:8080/api

The frontend supports the following backend API operations:
Product retrieval
GET /api/products

Used to retrieve products displayed by the browser.
Order history
GET /api/orders?limit=5

Used to retrieve recently saved orders.
Order creation
POST /api/orders

Used to create and persist a test order.
The frontend also supports a window.NOVACART_API_BASE override for the API base URL.
When the frontend is served using a non-file: protocol, the default API base is /api.
13. Logging Behavior
The backend uses Python logging.
Logs are configured to:
- Use the configured LOG_LEVEL.
- Write to standard output (stdout).
- Include timestamp, log level, logger name, and message.
The application logs:
- Application startup.
- Application startup failures.
- HTTP request completion.
- HTTP request failures.
- Order rejection.
- Order creation.
- Readiness failures.
HTTP request logs include:
- HTTP method.
- Request path.
- HTTP status code.
- Request duration.
This makes stdout suitable as the primary application log stream in a containerized runtime, subject to the production logging platform design.
14. External Dependencies
The application has the following runtime dependencies:
- Python runtime.
- FastAPI.
- Uvicorn.
- Pydantic.
- PostgreSQL when PostgreSQL is configured.
- Browser for the frontend.
No external third-party API integration was identified during the application source inspection.
The application uses the local filesystem for the SQLite database when the SQLite fallback is active.
15. Runtime Assumptions
The application currently assumes:
- A compatible Python 3 runtime is available.
- Backend dependencies from requirements.txt are installed.
- Uvicorn is available to run the FastAPI application.
- Port 8080 is available for the backend.
- A database is available.
- PostgreSQL is expected in the cohort environment.
- SQLite can be used as a local development fallback.
- The frontend can access the backend API.
- Database storage must be persistent when the application is deployed.
The application was successfully tested locally using Python 3.13 with SQLite.
16. Risks or Missing Information
The following items should be addressed before production deployment:
Database
The production PostgreSQL deployment details are not defined.
Missing information includes:
- PostgreSQL server/managed database location.
- Database credentials.
- Connection security requirements.
- Backup and restore requirements.
- High-availability requirements.
- Database monitoring requirements.
Secrets
The example configuration contains a database password placeholder.
Production credentials must be supplied securely rather than committed to source control.
Frontend API configuration
The local file:// frontend uses:
http://localhost:8080/api

For production deployment, the API base URL and frontend/backend routing strategy must be explicitly defined.
CORS
The backend currently allows all origins:
allow_origins=["*"]

Although this is suitable for the current demo/local setup, the production CORS policy should be reviewed and restricted to the required trusted origins.
SQLite
SQLite is useful as a local fallback but should not be assumed to be the production database for the cohort environment because PostgreSQL is explicitly expected there.
TLS / HTTPS
The current handover documentation does not define the production TLS/HTTPS termination architecture.
Backup and recovery
Database backup, restore, retention, and disaster-recovery requirements are not defined.
Observability
The application provides stdout logging and health/readiness endpoints, but production monitoring, alerting, metrics, and log retention requirements are not defined.