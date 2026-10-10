Application components frontend backend and db(production)
Languages and frameworks python , fastapi
Startup/build commands cd backend && python -m uvicorn app.main:app --host 0.0.0.0 --port 8080
Listening ports 8080
Application dependencies fastapi==0.128.2,uvicorn==0.48.0,psycopg[binary]>=3.2,<4
Configuration and environment variables
DATABASE_URL — Specifies the database connection URL. Defaults to SQLite if the variable is not set.
APP_ENV — Specifies the application environment. Default: development.
API_VERSION — Specifies the API version. Default: v1.
LOG_LEVEL — Specifies the logging level. Default: INFO.
os.getenv() — Reads an environment variable and returns the default value if it is not set.

Secrets or sensitive configuration - The application reads the database connection URL from an environment variable rather than hardcoding it in the source code.
Persistence requirements PostgreSQL requires persistent storage to retain database data when its container is removed or recreated.
Database dependencies PostgreSQL database server image,DATABASE_URL — database connection configuration,Docker volume — for database data persist
Health and readiness behavior
api end points of application /health checks basic application responsiveness and /ready database connectivity.
Service-to-service communication
The frontend sends API requests to Nginx, which forwards /api/ requests to the FastAPI backend. The backend communicates with PostgreSQL using the Psycopg driver and the database connection URL. Docker Compose allows services to communicate using service names over its internal network
Logging behavior Logging behavior is configured through the LOG_LEVEL environment variable, which defaults to INFO
External dependencies, if any - nil
Runtime assumptions
The runtime assumptions for NovaCart include a compatible Python environment, the required application dependencies, valid environment variables, and network connectivity between the frontend, backend, and database. The frontend runs through Nginx on port 8080, and the backend uses Uvicorn on port 8000. Database availability and persistent storage must also be considered, depending on the configured database.
Risks or missing information- nil


Questions you would ask the development team before production deployment
1.What environment variables and secrets are required for production?
2.Does the application support PostgreSQL in production, and how is the database initialized?
3.Is persistent storage configured to prevent database data loss?
4.How does the application handle database connection failures?
5.Are /health and /ready checks sufficient to detect application and database failures?
6.Are there any external APIs or services the application depends on?
7.How are application logs collected, monitored, and retained?
8.Are database backups configured, and has restoration been tested?
9.Does the application require HTTPS, SSL certificates, or specific network rules?
10.Are there any known security vulnerabilities or hardcoded credentials?
11.How are application updates, database migrations, and rollbacks handled?
12.What CPU, memory, and storage resources are required for production?
13.Has the application been tested under expected production traffic?
14.Are there any runtime assumptions or dependencies not documented in the source code?
15.What monitoring and alerting are required after deployment?