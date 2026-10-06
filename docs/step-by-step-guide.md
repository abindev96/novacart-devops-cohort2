# NovaCart: Step-by-Step Guide

How to set up and use the Git/GitHub workflow described in `docs/git-strategy.md`.

- **Part A**: one-time repository setup (repo admin, about 20 minutes)
- **Part B**: everyday developer workflow
- **Part C**: reviewing a pull request
- **Part D**: emergency fix (hotfix)
- **Part E**: releasing to production
- **Part F**: troubleshooting

---

## Part A: One-time repository setup (admin)

### A1. Prerequisites
- A GitHub account with **Admin** access to the repository.
- Git and the GitHub CLI (`gh`) installed: <https://cli.github.com>
- Python 3.12 (to run the backend tests locally).

### A2. Add the workflow files to the repository
Your repository root should look like this after you add the new folders:

```
novacart/
  backend/  frontend/  .env.example  .gitignore  README.md  ONBOARDING.md
  docs/        git-strategy.md, application.md, step-by-step-guide.md
  scripts/     setup-github.sh, ci/run.sh
  .github/     workflows/ci.yml, rulesets/protect-main.json,
               pull_request_template.md, CODEOWNERS
```

```bash
git clone https://github.com/<owner>/<repo>.git && cd <repo>
# copy docs/, scripts/ and .github/ from the delivered package into the repo root
chmod +x scripts/setup-github.sh scripts/ci/run.sh
git add .
git commit -m "Add Git workflow, CI checks and documentation"
git push origin main
```
Push directly to `main` **now**, before protection is switched on. After step A4, this is no longer possible.

### A3. Confirm CI works
1. Open the repository's **Actions** tab. A workflow named **CI** should have run.
2. Confirm the three jobs **lint**, **test** and **build** are green.
3. If one is red, open it, read the log, fix it, and push again. Do **not** enable protection until all three pass, or no PR will ever be mergeable.
4. You can reproduce CI locally: `bash scripts/ci/run.sh lint`, then `test`, then `build`.

### A4. Apply the repository protections

**Option 1: script (recommended)**
```bash
gh auth login                      # choose GitHub.com, HTTPS, log in via browser
./scripts/setup-github.sh          # or: ./scripts/setup-github.sh <owner>/<repo>
```
The script: allows only squash merges, deletes merged branches, allows auto-merge, creates the ruleset `protect-main`, and creates the `hotfix` label.

**Option 2: manually in the GitHub web UI**
1. **Settings > General > Pull Requests**
   - Tick **Allow squash merging**; untick **merge commits** and **rebase merging**.
   - Tick **Automatically delete head branches**, **Allow auto-merge**, and **Always suggest updating pull request branches**.
2. **Settings > Rules > Rulesets > New ruleset > Import a ruleset**, and upload `.github/rulesets/protect-main.json`. Check that **Enforcement status = Active**.
3. **Issues > Labels > New label**: name `hotfix`, colour red.

> Private repo on a free plan? Rulesets may be unavailable. Use **Settings > Branches > Add branch protection rule** for `main` with: require a pull request, 1 approval, dismiss stale approvals, require status checks `lint`, `test`, `build`, require branches to be up to date, require linear history, and block force pushes and deletions.

### A5. Add the team
1. **Settings > Collaborators and teams > Add people**.
2. Give the five developers **Write** access.
3. Give only 1 or 2 maintainers **Admin** (these are the people who can use the emergency bypass).
4. Optional: edit `.github/CODEOWNERS` with real GitHub handles to auto-request reviewers.

### A6. Verify protection works
Do each test and confirm the expected result.

| Test | Expected result |
|---|---|
| `git push origin main` (any commit) | Rejected: changes must be made through a pull request |
| Open a PR with failing tests | **Merge** button disabled until checks pass |
| Open a passing PR with no approval | Merge disabled until 1 approval |
| Push a new commit to an approved PR | Approval is dismissed; re-review needed |
| Try to merge with the merge-commit option | Only **Squash and merge** is offered |

Check the ruleset from the terminal: `gh api repos/<owner>/<repo>/rulesets`.

> **Solo or practice repo?** You cannot approve your own PR. Either invite a second account as a reviewer, or (as admin) use the bypass described in Part D.

---

## Part B: Everyday developer workflow

### B1. One-time local setup
```bash
git clone https://github.com/<owner>/<repo>.git && cd <repo>
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r backend/requirements.txt pytest httpx ruff
cp .env.example .env                                  # fill in local values; never commit .env
```

### B2. Start a new piece of work
```bash
git switch main
git pull                                    # always start from the latest main
git switch -c feature/short-description     # e.g. feature/cart-discount-codes
```
Branch prefixes: `feature/`, `fix/`, `chore/`, `docs/` (and `hotfix/` for emergencies only).

### B3. Make changes and commit
```bash
# edit code...
git status
git add <files>
git commit -m "Add discount code validation"
```
- Commit small, logical steps with clear messages.
- Add or update tests in `backend/tests/` for backend changes.

### B4. Run the checks locally before pushing
```bash
bash scripts/ci/run.sh lint
bash scripts/ci/run.sh test
bash scripts/ci/run.sh build
```
This catches most failures before CI does.

### B5. Stay up to date with `main`
Do this at least daily, and before opening the PR:
```bash
git fetch origin
git rebase origin/main        # if conflicts: fix files, git add <file>, git rebase --continue
# (use `git merge origin/main` instead if you are unsure about rebasing)
```
After rebasing a branch you already pushed: `git push --force-with-lease` (only on your own feature branch, never on `main`).

### B6. Push and open a pull request
```bash
git push -u origin HEAD
gh pr create --fill            # or use the "Compare & pull request" button on GitHub
```
1. Give the PR a clear title (it becomes the commit message on `main`).
2. Fill in the template: what and why, how to test, checklist.
3. Link the issue: `Closes #123`.
4. Ask a teammate to review (rotate reviewers).
5. Optional: open as **Draft** if you want early feedback.

### B7. Respond to checks and review
1. Watch the **Checks** section on the PR. Fix anything red: push new commits to the same branch.
2. Answer every review comment, then click **Resolve conversation**.
3. Pushing new commits dismisses earlier approvals, so tell the reviewer when you're ready again.

### B8. Merge
1. When there's 1 approval, all checks are green, and the branch is up to date: click **Squash and merge**.
2. Or click **Enable auto-merge** and GitHub merges it as soon as everything passes.
3. The branch is deleted automatically.

### B9. Clean up locally
```bash
git switch main
git pull
git branch -d feature/short-description
```

### Team rules to remember
- Never push to `main`; never force-push shared branches.
- Keep branches under 1-2 days and PRs small (around 400 lines or fewer).
- Unfinished features that must merge go behind a feature flag.
- Reviewers respond within one working day.

---

## Part C: Reviewing a pull request

1. Open the PR and read the description first.
2. **Files changed** tab: check logic, tests, readability and risk (security, data changes, breaking API changes).
3. Run it locally if the change is risky:
   ```bash
   gh pr checkout <number>
   bash scripts/ci/run.sh test
   ```
4. Leave comments on specific lines. Use **Suggest change** for small fixes.
5. Click **Review changes** and choose:
   - **Approve**: good to merge.
   - **Request changes**: must be fixed first.
   - **Comment**: feedback only.
6. After the author's fixes, re-review promptly. Approval is required again after any new push.

---

## Part D: Emergency fix (hotfix)

Use when production is broken or at risk (outage, data problem, security issue).

### D1. Decide: fix or roll back?
If you know the PR that broke production, **reverting it is often faster** (go to D6). Otherwise continue.

### D2. Create the hotfix branch
```bash
git switch main && git pull
git switch -c hotfix/checkout-500-error
```

### D3. Make the smallest possible fix
- Fix only the problem. No refactoring or extra features.
- Add a regression test if you can do it quickly.
- Run `bash scripts/ci/run.sh test` locally.

### D4. Open the PR with the hotfix label
```bash
git push -u origin HEAD
gh pr create --fill --label hotfix
```
In the PR description fill in **Impact** and **Rollback plan**, then post it in the team chat.

### D5. Fast-track review and merge
1. Any available teammate reviews **immediately**; this takes priority over normal work.
2. CI still runs. Wait for green.
3. **Squash and merge**, then follow Part E to deploy a patch release (e.g. `v1.4.1`).

### D6. Alternative: revert the bad change
```bash
gh pr list --state merged --limit 10        # find the offending PR number
gh pr revert <number>                       # or use the "Revert" button on the merged PR
```
This creates a normal PR. Review, merge and deploy it as above.

### D7. Break-glass (last resort, admins only)
Use only if CI itself is broken or no reviewer is available during an outage.
1. Open the hotfix PR as normal.
2. A repository admin clicks **Merge without waiting for requirements to be met (bypass rules)**.
3. Within 24 hours: a teammate does a post-merge review on the PR, and an issue is opened to fix whatever was bypassed.

### D8. After the incident
Write a short blameless note (what broke, why, how to prevent it) in the PR or an issue.

---

## Part E: Releasing to production

`main` is always production-ready; production runs a tagged commit of `main`.

```bash
git switch main && git pull
git tag -a v1.4.0 -m "Release 1.4.0"
git push origin v1.4.0
gh release create v1.4.0 --generate-notes     # optional: release notes from merged PRs
```
Then deploy that tag following `docs/application.md` (backend started from `backend/`, frontend files copied to the web server). Version numbering: `MAJOR.MINOR.PATCH`; hotfixes bump PATCH.

To roll back production: redeploy the previous tag (e.g. `v1.3.2`).

---

## Part F: Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| Push to `main` rejected | Protection is working | Use a branch and PR |
| Merge button disabled: "branch is out of date" | `main` moved on | Click **Update branch**, or `git rebase origin/main` and push |
| Required check "lint/test/build" stays "Expected" | CI never ran, or job names changed | Check the **Actions** tab; job names must match the ruleset |
| CI fails with "No such file backend/requirements.txt" | Wrong folder layout | Keep `backend/` and `frontend/` at the repo root, or edit `scripts/ci/run.sh` |
| Tests pass locally, fail in CI | SQLite vs PostgreSQL, missing env vars, missing dependency | Add the dependency to `backend/requirements.txt`; test against Postgres |
| Can't approve own PR | Authors can't approve their own work | Ask a teammate; solo repo: use admin bypass |
| Approval disappeared | New commits were pushed | Ask for a re-review |
| Rebase conflicts | Same lines changed on `main` | Edit conflicted files, `git add`, `git rebase --continue`; or `git rebase --abort` and ask for help |
| Pushed a secret by mistake | Credential committed | Rotate the secret **immediately**, then remove it from history; don't just delete the line |
| `git push --force-with-lease` rejected | Someone else pushed to your branch | `git fetch`, check what changed, then retry |

## Quick reference

```bash
# New work
git switch main && git pull && git switch -c feature/<name>
# Save and share
git add . && git commit -m "msg" && git push -u origin HEAD && gh pr create --fill
# Stay current
git fetch origin && git rebase origin/main
# Emergency
git switch main && git pull && git switch -c hotfix/<name>   # then PR with label hotfix
```
