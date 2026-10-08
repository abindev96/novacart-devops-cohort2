# NovaCart Runtime Packaging

## 1. Objective

The goal is to package the NovaCart frontend and backend as two independent Docker images and run them as two separate containers.

The implementation provides:

- A separate Docker image for the backend.
- A separate Docker image for the frontend.
- Independent build and runtime of both components.
- Runtime configuration through environment variables.
- Persistent SQLite storage using a Docker volume.
- Nginx inside the frontend container.
- Backend communication through a dedicated Docker network.
- No requirement for Python, Nginx, or application dependencies on the host.
- Non-root execution for the frontend container.
- Health and readiness verification.

---

## 2. Application Structure

The relevant application structure is:

```text
novacart/
├── backend/
│   ├── app/
│   │   └── main.py
│   ├── tests/
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .dockerignore
│
└── frontend/
    ├── index.html
    ├── app.js
    ├── styles.css
    ├── Dockerfile
    ├── .dockerignore
    └── docker/
        ├── nginx.conf.template
        └── entrypoint.sh
3. Docker Images Selected
3.1 Backend Image
The backend uses:
FROM python:3.12-slim-bookworm

Why this image was selected
- The NovaCart backend is a Python application.
- Python 3.12 provides the required Python runtime.
- The slim-bookworm variant is smaller than the full Python image.
- It provides the required environment for FastAPI and Uvicorn.
- It works well with a multi-stage Docker build.
The backend image is built using a multi-stage Dockerfile.
3.2 Frontend Image
The frontend uses:
FROM nginxinc/nginx-unprivileged:1.27-alpine

Why this image was selected
The NovaCart frontend consists of static:
- HTML
- CSS
- JavaScript
There is no Node.js build process or frontend package installation required for the current application.
Therefore, a full Node.js build image is unnecessary.
Nginx was selected because it can:
- Serve the static frontend files.
- Listen on port 8080.
- Reverse proxy /api/* requests to the backend.
- Provide frontend health and readiness endpoints.
The nginx-unprivileged image was selected so that the frontend can run without root privileges.
The running container was verified with:
uid=101(nginx) gid=101(nginx) groups=101(nginx)

4. Backend Dockerfile
The backend Dockerfile is located at:
novacart/backend/Dockerfile

The backend uses a multi-stage build.
Builder stage
The builder stage:
1. Uses Python 3.12.
2. Creates a virtual environment at /opt/venv.
3. Installs dependencies from requirements.txt.
Runtime stage
The runtime stage:
1. Uses a clean Python 3.12 slim image.
2. Copies the prepared virtual environment from the builder stage.
3. Copies the application code.
4. Runs the application using Uvicorn.
5. Exposes port 8000.
6. Includes a Docker healthcheck.
The backend application starts with:
uvicorn main:app --host 0.0.0.0 --port 8000

5. Frontend Dockerfile
The frontend Dockerfile is located at:
novacart/frontend/Dockerfile

The frontend uses a single-stage Nginx image because the application is already static and does not require a separate frontend build toolchain.
The Dockerfile:
- Copies index.html, app.js, and styles.css.
- Copies the Nginx configuration template.
- Copies the runtime entrypoint script.
- Makes the entrypoint executable.
- Exposes port 8080.
- Runs the container as UID 101.
6. Nginx Configuration
The Nginx template is located at:
novacart/frontend/docker/nginx.conf.template

The configuration provides the following routes:
Route	Purpose
/	Serves the NovaCart frontend
/health	Frontend health endpoint
/ready	Proxies readiness check to the backend
/api/*	Proxies API requests to the backend


The backend address is configured through:
BACKEND_URL

Example:
BACKEND_URL=http://novacart-backend:8000

The backend URL is therefore provided at runtime instead of being hard-coded into the frontend image.
7. Frontend Entrypoint
The entrypoint script is located at:
novacart/frontend/docker/entrypoint.sh

At container startup it:
1. Checks that BACKEND_URL is defined.
2. Validates that the URL starts with http:// or https://.
3. Uses envsubst to replace ${BACKEND_URL} in the Nginx template.
4. Generates the final Nginx configuration.
5. Starts Nginx.
Runtime flow:
Container starts
      |
      v
entrypoint.sh
      |
      v
Validate BACKEND_URL
      |
      v
Generate Nginx configuration
      |
      v
Start Nginx

8. Runtime Architecture
A dedicated Docker network named:
novacart-net

was created.
The backend and frontend containers are attached to this network.
The runtime architecture is:
                    Host
                     |
                     | 127.0.0.1:8080
                     v
            +-------------------+
            | Frontend Container|
            |      Nginx        |
            |       :8080       |
            +---------+---------+
                      |
                      | /api/*
                      |
                      v
            +-------------------+
            | Backend Container |
            |     FastAPI       |
            |       :8000       |
            +---------+---------+
                      |
                      v
              /data/novacart.db
                      |
                      v
              Docker Volume
              novacart-data

9. Port Exposure
The frontend is published to the host:
127.0.0.1:8080 -> 8080

The backend is not published to the host.
The backend only exposes:
8000/tcp

inside the Docker network.
This allows the frontend to communicate with:
http://novacart-backend:8000

without directly exposing the backend service on the host.
10. Runtime Configuration
Backend
The backend uses:
DATABASE_URL

The application supports the DATABASE_URL environment variable.
For the standalone Docker runtime, SQLite is configured as:
DATABASE_URL=sqlite:////data/novacart.db

Frontend
The frontend uses:
BACKEND_URL

Example:
BACKEND_URL=http://novacart-backend:8000

Runtime configuration is therefore supplied when the container is started.
No environment-specific application source modification is required.
11. SQLite Persistence
A Docker volume was created:
novacart-data

The volume is mounted into the backend container:
novacart-data:/data

The database is stored at:
/data/novacart.db

The configured database URL is:
sqlite:////data/novacart.db

The volume keeps the database outside the container writable layer.
Therefore, stopping and starting the backend container does not remove the database data.
The current standalone setup uses SQLite and is intended for a single backend instance.
12. Build Commands
Build backend
docker build -t novacart-backend:local .\novacart\backend\

Build frontend
docker build -t novacart-frontend:local .\novacart\frontend\

Both images were successfully built.
13. Docker Network
Create the Docker network:
docker network create novacart-net

The network allows the frontend container to resolve the backend container using its Docker container name.
14. Docker Volume
Create the SQLite data volume:
docker volume create novacart-data

The volume is mounted at:
/data

inside the backend container.
15. Run the Backend
The backend container was started with:
docker run -d `
  --name novacart-backend `
  --network novacart-net `
  -e "DATABASE_URL=sqlite:////data/novacart.db" `
  -v novacart-data:/data `
  novacart-backend:local

Important characteristics:
- Container name: novacart-backend
- Network: novacart-net
- Database: SQLite
- Database path: /data/novacart.db
- Persistent volume: novacart-data
- Host port: not published
16. Run the Frontend
The frontend container was started with:
docker run -d `
  --name novacart-frontend `
  --network novacart-net `
  -e "BACKEND_URL=http://novacart-backend:8000" `
  -p 127.0.0.1:8080:8080 `
  novacart-frontend:local

Important characteristics:
- Container name: novacart-frontend
- Network: novacart-net
- Backend URL: http://novacart-backend:8000
- Host address: 127.0.0.1
- Host port: 8080
- Container port: 8080
17. Runtime Verification
17.1 Backend Container
The backend container was verified using:
docker ps --filter "name=novacart-backend"

Result:
Up ... (healthy)

The Docker healthcheck successfully reported the backend as healthy.
17.2 Frontend Container
The frontend container was verified using:
docker ps --filter "name=novacart"

The frontend was running with:
127.0.0.1:8080->8080/tcp

17.3 Frontend Health
Command:
curl.exe http://127.0.0.1:8080/health

Result:
ok

This confirms that the frontend Nginx health endpoint is working.
17.4 Frontend to Backend Communication
Command:
curl.exe http://127.0.0.1:8080/api/health

Result:
{
  "status": "ok",
  "environment": "development",
  "checked_at": "..."
}

This confirms the complete communication path:
Host
  |
  v
Frontend :8080
  |
  v
Nginx /api/*
  |
  v
Backend :8000
  |
  v
FastAPI /health

17.5 Readiness Check
Command:
curl.exe http://127.0.0.1:8080/ready

Result:
{
  "status": "ready"
}

This confirms that the readiness endpoint is working.
17.6 Frontend Static Content
Command:
curl.exe http://127.0.0.1:8080/

The request returned the NovaCart HTML page, including:
<title>NovaCart</title>

This confirms that Nginx is serving the frontend application correctly.
17.7 Non-Root Verification
Command:
docker exec novacart-frontend id

Result:
uid=101(nginx) gid=101(nginx) groups=101(nginx)

Therefore, the frontend container is running as a non-root user.
18. Docker Ignore Files
A .dockerignore file was added for both components.
Backend
novacart/backend/.dockerignore

The file excludes:
__pycache__/
*.py[cod]
.pytest_cache/
.ruff_cache/
.venv/
venv/
novacart.db
.git/
.gitignore
tests/

This prevents local caches, the local database, tests, and Git metadata from being included in the backend build context.
Frontend
novacart/frontend/.dockerignore

The file excludes:
.git/
.gitignore
*.log
.DS_Store

19. Build-Time vs Runtime Responsibilities
Build time
The Docker build is responsible for:
- Installing backend dependencies.
- Creating the backend virtual environment.
- Copying application code.
- Copying frontend static files.
- Packaging Nginx configuration templates.
- Packaging the frontend entrypoint script.
Runtime
Container startup is responsible for:
- Providing DATABASE_URL.
- Providing BACKEND_URL.
- Mounting persistent SQLite storage.
- Generating the runtime Nginx configuration.
- Starting the backend application.
- Starting Nginx.
- Connecting frontend and backend through the Docker network.
This separation keeps environment-specific configuration out of the application image.
20. Security Controls Verified
The following controls were verified during the local implementation:
- Frontend runs as a non-root user.
- Backend port 8000 is not published to the host.
- Frontend is bound to 127.0.0.1:8080.
- Runtime configuration is supplied through environment variables.
- .dockerignore files are present for both build contexts.
- Backend uses a multi-stage Docker build.
Security Scan Limitation
A full vulnerability/CVE scan of the Docker images was not performed during this implementation.
Image signing verification and a comprehensive container security scan were also not performed.
Therefore, this implementation should not be described as having passed every possible security check.
21. Repository Changes
The following files were added or created for the runtime packaging implementation:
novacart/backend/Dockerfile
novacart/backend/.dockerignore

novacart/frontend/Dockerfile
novacart/frontend/.dockerignore

novacart/frontend/docker/nginx.conf.template
novacart/frontend/docker/entrypoint.sh

The required documentation is:
docs/runtime-packaging.md

22. Final Verification Summary
Requirement	Status
Separate backend Docker image	PASS
Separate frontend Docker image	PASS
Backend independently runnable	PASS
Frontend independently runnable	PASS
Backend healthcheck	PASS
Frontend health endpoint	PASS
Frontend-to-backend communication	PASS
Readiness endpoint	PASS
Frontend static content	PASS
SQLite volume configured	PASS
Backend host port not published	PASS
Frontend localhost port published	PASS
Frontend non-root execution	PASS
Runtime DATABASE_URL	PASS
Runtime BACKEND_URL	PASS
Backend .dockerignore	PASS
Frontend .dockerignore	PASS
Full vulnerability scan	NOT PERFORMED


## 23. Conclusion

NovaCart has been packaged into two independent Docker images:

`novacart-backend:local`

`novacart-frontend:local`

The backend uses a multi-stage Python Docker build.

The frontend uses an unprivileged Nginx Alpine image because the current frontend is already static and does not require a separate JavaScript build stage.

Both containers run independently on the `novacart-net` Docker network.

The frontend is exposed to the host through:

`127.0.0.1:8080`

The backend remains accessible only through the Docker network on:

`novacart-backend:8000`

Runtime configuration is supplied using `DATABASE_URL` and `BACKEND_URL`.

SQLite data is persisted through the `novacart-data` Docker volume.

Health, readiness, frontend serving, frontend-to-backend communication, and non-root frontend execution were successfully verified.