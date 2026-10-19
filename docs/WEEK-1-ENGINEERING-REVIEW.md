1. Source Control
1. How does your Git workflow operate?
Developers work independently on feature branches, commit changes, and create pull requests . this will trigger the ci pipeline and will check the required details and needed a reviewer to merge to main
2. How is main protected?
CI checks and PR rulesets
3. How are changes reviewed and validated?
CI pipeline which triggered during the pull request will check the changes . if it passes a reviewer need to verify the changes and give permissions for merge to main
4. How would an emergency fix be handled?
Create a hotfix branch from main, implement the urgent fix, run validation, and merge it through a reviewed pull request after required checks pass.



2. Runtime & Application
1. How is the application packaged?
The frontend and backend are packaged as separate Docker images, allowing each service to be built and managed independently.
2. How are frontend, backend, and PostgreSQL started?
The starting order - PG db,backend and finally frontend
3. How do services discover and communicate with each other?
The frontend communicates with the backend through its service name, and the backend connects to PostgreSQL using db:5432.
4. How is runtime configuration supplied?
Environment variables supply settings such as DATABASE_URL, application environment, log level, and database credentials. Compose can use variable substitution to configure these values.
5. Where does persistent data live?
PostgreSQL data is stored in the named Docker volume postgres-data, allowing database files to persist when containers are recreated.
6. How are health and readiness verified?
PostgreSQL uses pg_isready; the backend health check calls /ready. Compose waits for PostgreSQL to become healthy before starting the backend, and for the backend to become healthy before starting the frontend. After that curl to localhost will tell the application is ready or not.




3. CI
1. What happens when a pull request is created?
The GitHub Actions CI workflow triggers automatically for pull requests targeting main.
2. What does CI validate?
CI validates Python code using Ruff, checks frontend JavaScript syntax using Node.js, installs backend dependencies, runs automated tests, and performs the configured build checks.
3. What happens when validation fails?
The merge will fail. The CI job fails, reports the error, and the changes should be corrected before merging when the check is required.
4. Which checks are required before merge?
The branch protection ruleset specifies the required checks: lint, test, and build. Confirm that these names match the actual GitHub Actions check names.





4. Production Readiness — Top Five Risks
1.Default database credentials are defined for local development
2.CI does not yet establish complete security and integration validation.
3.The Compose stack is a local deployment and does not provide a complete production high-availability design.
4.Backend scaling and Nginx load distribution have not been fully verified.
