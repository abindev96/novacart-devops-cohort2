workflow triggers: PR targeting main, push to main, and GitHub Merge Queue events trigger the CI workflow.

validation stages: Three jobs run—application validation, Gitleaks secret scanning, and Docker image build validation.

what is tested or built:Python lint and backend tests, JavaScript syntax, required frontend files, dependency checks, backend/frontend Docker images, and Docker Compose configuration are validated.

what happens when a check fails:The failed step/job is marked as failed, and the workflow reports failure; other independent jobs may continue running.

how the workflow integrates with the pull request process:CI runs automatically for PRs targeting main; configured required status checks and branch protection can block merging when checks fail.

how secrets or credentials are handled:Gitleaks scans Git history for leaked secrets, while GITHUB_TOKEN is provided through GitHub Actions; PostgreSQL values are placeholders for configuration validation.

limitations or checks you would add before using this workflow for production:vulnerability and dependency scans, secure secret management