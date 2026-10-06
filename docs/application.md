# NovaCart: Application Overview for Deployment

Purpose: a single reference for what NovaCart is, what it needs to run, and what must be deployed. Companion to `docs/git-strategy.md`.

Items marked **(proposed)** are suggestions for the team to confirm; everything else comes from the application details provided.

## 0. Repository layout

```
novacart/
  backend/
    app/main.py            FastAPI application (entry point: app.main:app)
    tests/test_api.py      API tests (pytest)
    requirements.txt       Python dependencies
  frontend/
    index.html, app.js, styles.css     static site, no build step
  .env.example             template of environment variables (no real secrets)
  .gitignore
  ONBOARDING.md, README.md
  docs/                    git-strategy.md, application.md
  scripts/                 setup-github.sh, ci/run.sh
  .github/                 workflows, rulesets, PR template, CODEOWNERS
```

- The frontend has **no `package.json` and no bundler**: its files are copied as-is to the web server's document root. There is no frontend build step to deploy.
- The backend must be started **from the `backend/` directory** so that `app.main` resolves.

## 1. Components

| Component | Technology | Notes |
|---|---|---|
| Frontend | JavaScript, HTML, CSS | Static files only; no server-side runtime. Served by the web server. |
| Backend API | Python, FastAPI (run with Uvicorn) | Stateless; listens on port 8000, internal only. |
| Database | PostgreSQL (prod); SQLite (local/dev) | Holds the live catalog and order data. |
| Web server / reverse proxy | Required (e.g. Nginx) | Terminates TLS, serves the static frontend, proxies API calls to the backend. Hides the backend from the internet. |
| Load balancer | Required in front of the web server | Public entry point on 443. |
| Secrets store | Vault | Holds DB credentials. |

## 2. Architecture (target)

```
Internet
   | HTTPS 443
   v
[ Load balancer ]                          public subnet
   |
   v
[ Web server / reverse proxy ]             private subnet
   |  serves static frontend (HTML/CSS/JS)
   |  proxies /api/* ---> HTTP 8000
   v
[ FastAPI (uvicorn) ]                      private subnet
   |  TCP 5432
   v
[ PostgreSQL ]                             private subnet (data tier)

[ Vault ] <--- backend reads DB credentials at startup
```

Only the load balancer is reachable from the internet. The backend and database have no public exposure.

## 3. Runtime and startup

- **Start command (backend), run from `backend/`:**
  `cd backend && python -m uvicorn app.main:app --host 0.0.0.0 --port 8000`
  (install dependencies first: `pip install -r backend/requirements.txt`)
- Binding to `0.0.0.0` is acceptable only because the port is closed to the internet by network rules; the reverse proxy is the sole client.
- **Dependencies:** Python packages from `requirements.txt`; a web server must be in front of the app.
- **(proposed)** Run Uvicorn under a process manager (systemd or a container restart policy) so it restarts on failure.

## 4. Network and ports

| From | To | Port | Purpose |
|---|---|---|---|
| Internet | Load balancer | 443 | Public HTTPS traffic |
| Load balancer | Web server | 443 or 80 (to decide) | Forwarded traffic |
| Web server | FastAPI backend | 8000 | Internal API traffic |
| FastAPI backend | PostgreSQL | 5432 | Database queries |

Rules: allow 5432 **only** from the backend's security group/subnet; allow 8000 **only** from the web server; nothing but the load balancer is public.

## 5. Configuration and secrets

Configuration is supplied through environment variables, never committed to the repository.

| Variable **(proposed names)** | Example / purpose | Sensitive |
|---|---|---|
| `APP_ENV` | `dev` or `prod` | No |
| `DATABASE_URL` | `sqlite:///./dev.db` locally; `postgresql://user:pass@host:5432/novacart` in prod | **Yes** (prod) |
| `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`, `DB_NAME` | Alternative to a single URL | `DB_PASSWORD` is **Yes** |
| `LOG_LEVEL` | `info` | No |

- DB credentials live in **Vault** and are injected at deploy/start time.
- `.env` files for local development must be listed in `.gitignore`; commit only a `.env.example` with fake values.
- Rotate credentials by updating Vault and restarting the backend.

## 6. Data and persistence

- **Persistent data:** PostgreSQL tables (catalog, orders). The catalog is updated live, so the database must be on durable storage with backups.
- **Frontend is static;** the backend is stateless, so both can be redeployed or replaced without data loss.
- **(proposed)** Manage schema changes with migrations (e.g. Alembic) run as a deploy step, never by hand on prod.
- **(proposed)** Daily automated backups with a tested restore; point-in-time recovery if the platform supports it.
- **Risk to address:** SQLite (dev) and PostgreSQL (prod) differ in types, constraints and concurrency. Run the CI test job against a Postgres service container, or use Postgres locally via Docker, so bugs are caught before prod.

## 7. Health and readiness

| Endpoint | Meaning | Checks | Healthy response |
|---|---|---|---|
| `GET /health` | Liveness: the app process is up | No dependencies | `200` |
| `GET /ready` | Readiness: can serve traffic | Opens a DB connection (e.g. `SELECT 1`) | `200` if DB reachable, `503` otherwise |

- The load balancer should probe `/health` for availability, and use `/ready` to decide whether to send traffic.
- `/health` must stay dependency-free so a database outage does not make the platform restart healthy app processes.
- Expose both through the reverse proxy to the load balancer's probes only if needed; otherwise keep them internal.

## 8. Service-to-service communication

- Browser -> load balancer -> reverse proxy -> FastAPI -> PostgreSQL, all synchronous request/response.
- No message queues, caches or third-party service calls were listed. If any exist (payments, email, search), add them to the components and ports tables.

## 9. Components to deploy

1. Load balancer (public, 443, TLS certificate)
2. Private subnets with security groups as in section 4
3. Web server / reverse proxy host(s) with routing config: static files plus `/api` proxy to port 8000
4. FastAPI backend host(s) running the start command
5. PostgreSQL (managed service preferred) with backups
6. Vault integration for DB credentials

## 10. Open decision: how will production be deployed?

Not yet decided: **single server or multi-server**.

| Option | Layout | Good for | Drawbacks |
|---|---|---|---|
| A. Single server | Web server + FastAPI on one host; separate (or managed) Postgres | Launch, low traffic, simplest | Host is a single point of failure; deploys cause brief downtime |
| B. Multi-server | Load balancer -> 2+ web/app hosts -> managed Postgres | Availability, zero-downtime rolling deploys | More cost and moving parts |

**(proposed)** Start with **Option A** behind the load balancer (database on its own managed instance, never on the app host), and keep the backend stateless so moving to Option B means adding a second host to the load balancer. Move to B when uptime requirements demand it. Decide this before building deployment automation.

Other facts still to confirm:
- Database runs as a managed service or self-hosted VM?
- Hosting platform (AWS, Azure, GCP, on-prem)?
- Where TLS terminates (load balancer only, or also on the web server)?
- Expected traffic and acceptable downtime/recovery targets?
- Does `app.js` call the API with relative paths (e.g. `/api/...`) or a hard-coded host? Relative paths are needed for the reverse-proxy design to work without CORS.

## 11. Link to the Git workflow

- CI (`.github/workflows/ci.yml`) runs `lint`, `test`, `build` before anything merges to `main`: `ruff` and `pytest` for `backend/`, a JavaScript syntax check and file checks for `frontend/`.
- `main` is production-ready; deployments are made from `main` (tagged releases).
- Emergency fixes follow the `hotfix/*` path in `docs/git-strategy.md`.

