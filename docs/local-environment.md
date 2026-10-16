1.Start/stop of complete environment
docker compose up -d --build - starts and build images for frontend, backend and pg DB
docker compose down - Stop and remove the containers and Compose network

2.Individual service restart
docker compose restart frontend
docker compose restart backend
docker compose restart db

3.How does the frontend container run as part of the Compose stack?
The frontend uses an NGINX web server packaged in its Docker image. NGINX serves the static frontend files, including index.html, app.js, and styles.css.
The frontend runs as a Compose service, so it starts and stops alongside the backend and database. NGINX also forwards API requests to the backend through its configured reverse-proxy rules.

4. How do services discover and communicate with each other?
Frontend communicates with the backend using backend:8080.
Backend can communicate with PostgreSQL using db:5432.
The frontend serves requests from the host through its published port 80.

5. How is runtime configuration supplied?
Runtime configuration is supplied through the Docker Compose service configuration, including environment variables where configured.

6. How is database persistence handled?
PostgreSQL stores its database files inside /var/lib/postgresql/data (Docker volumes) and data wil not be lost even after restarting db container

7. How are service health and readiness determined?
Backend: The Dockerfile checks the backend health endpoint, such as /health. A successful response indicates that the endpoint is responding.
Database: PostgreSQL can use pg_isready to verify database readiness.
Frontend: NGINX can be checked through an HTTP endpoint to confirm that the web server is responding.

8. What happens when an individual service restarts?
Frontend restarts: NGINX stops temporarily and starts again. The backend and database generally continue running.
Backend restarts: API requests may fail temporarily. The frontend remains running, but requests cannot succeed until the backend is available again.
Database restarts: Database connections may temporarily fail, affecting backend operations. The backend may need to reconnect after PostgreSQL becomes available

9. Which services and ports are accessible from the host?
Frontend is accessed from port 80 and backend and db are not directly accessed from host

10.assumptions, trade-offs, and limitations
Port 80 must be available on host machine and also must be opened in firewall.