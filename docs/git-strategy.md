# NovaCart Git Strategy

**Status:** adopted · **Team size:** 5 developers · **Applies to:** this repository

## 1. The workflow we chose: GitHub Flow with a protected `main`

- `main` is the only long-lived branch. It is always **production-ready**.
- All work happens on short-lived branches cut from `main`.
- Every change reaches `main` through a **pull request (PR)** that has been **reviewed** and has **passed automated checks**.
- Merges are **squash merges**, so `main` has one clean commit per PR.
- Production is released from `main` (tag `vX.Y.Z` when you ship).

### Why this fits NovaCart

| Project reality | Consequence |
|---|---|
| 5 developers, one team | Little need for parallel release trains; one shared trunk is easy to keep in sync. |
| Everyone works at the same time | Short-lived branches + small PRs keep merge conflicts small. |
| Unfinished work must not reach production code | Work lives on a branch until reviewed and green; incomplete features hidden behind a flag if they must merge early. |
| Need to be simple and followed consistently | One long-lived branch, one rule: *branch, PR, review, green, squash*. |

### Why not Git Flow (`develop` + `release/*` + `hotfix/*`)?
Git Flow solves problems we do not have: multiple supported versions in production and scheduled release cycles. For five people it adds a second long-lived branch, back-merges, and constant "which branch do I target?" mistakes. Every extra branch is another place for code to drift and for protections to be forgotten.

### Why not commit directly to trunk (pure trunk-based)?
It needs very mature test coverage and feature-flag discipline, and it removes the review gate the team explicitly requires.

## 2. How developers contribute

### Branch naming
`<type>/<short-description>`, with types: `feature/`, `fix/`, `chore/`, `docs/`, and `hotfix/` (emergencies only, see section 4).
Examples: `feature/cart-discount-codes`, `fix/checkout-rounding`.

### Day-to-day steps
```bash
git switch main && git pull                  # 1. start from latest main
git switch -c feature/cart-discount-codes    # 2. branch
# ...commit small, meaningful changes...
git fetch origin && git rebase origin/main   # 3. stay current (or merge main in)
git push -u origin HEAD                      # 4. push
gh pr create --fill                          # 5. open a PR (template auto-fills)
```
6. CI runs (`lint`, `test`, `build`). Fix anything red.
7. One teammate reviews. Address comments by pushing new commits.
8. When approved and green, **squash and merge** (or enable auto-merge). The branch is deleted automatically.

### Team rules
- **Keep branches short-lived:** aim to merge within 1-2 days; split big work into several PRs.
- **Keep PRs small** (ideally under ~400 changed lines) so reviews are fast and meaningful.
- **Unfinished but mergeable work** goes behind a feature flag or stays unreachable from the UI/API.
- **Never push to `main`** (it is blocked anyway) and never force-push shared branches.
- **Reviewers respond within one working day.** Rotate reviewers; do not always ask the same person.
- **PR title = future commit message.** Write it clearly, e.g. `Add discount codes to cart`.
- The author cannot approve their own PR.

### Review expectations
Reviewers check: does it do what the PR says, is it tested, is it readable, does it avoid risky side effects. Resolve all conversations before merge.

## 3. How production-ready code is protected

Protection is enforced by GitHub, not by good intentions. It is defined in `.github/rulesets/protect-main.json` and applied by `scripts/setup-github.sh`.

### Branch ruleset on `main`
| Setting | Value | Purpose |
|---|---|---|
| Require pull request | on | No direct pushes. |
| Required approvals | 1 | Every change is reviewed. |
| Dismiss stale approvals on new push | on | Approval cannot be earned and then followed by unreviewed code. |
| Require approval of most recent push | on | The last pusher can't be the sole approver. |
| Require conversation resolution | on | Review comments can't be ignored. |
| Required status checks | `lint`, `test`, `build` | Broken code cannot merge. |
| Require branch up to date before merge | on (strict) | Checks run against what `main` will actually become. |
| Linear history | on | Clean, bisectable history. |
| Block force pushes | on | History cannot be rewritten. |
| Block deletion | on | `main` cannot be deleted. |
| Allowed merge method | squash only | One commit per PR. |
| Bypass | Repository admins, **pull-request-only** | Break-glass for emergencies (section 4); still goes through a PR and is audited. |

### Repository merge settings
Allow squash merging **only** (merge commits and rebase merging off), **automatically delete head branches**, allow auto-merge, allow "Update branch" button.

### Automated checks
`.github/workflows/ci.yml` runs three jobs on every PR and on `main`:
- `lint`, `test`, `build`, each delegating to `scripts/ci/run.sh`, which knows NovaCart's layout (`backend/` Python/FastAPI, `frontend/` static JavaScript).
  - `lint`: `ruff` on the backend; `node --check` on each frontend `.js` file.
  - `test`: `pytest` in `backend/tests`.
  - `build`: backend compiles and imports; required frontend files exist.
- It **fails if the expected folders or files are missing**, so the required checks can never pass vacuously.
- Developers can run the same checks locally: `bash scripts/ci/run.sh test`.

### Setting it up
One-time, by a repository admin:
```bash
gh auth login
./scripts/setup-github.sh            # or: ./scripts/setup-github.sh owner/novacart
```
Or manually: **Settings > Rules > Rulesets > New branch ruleset**, import `.github/rulesets/protect-main.json`; and **Settings > General > Pull Requests** apply the merge settings above.

Verify: open a throwaway PR; the merge button must stay disabled until checks pass and one approval exists, and `git push origin main` must be rejected.

### Settings that cannot live in the repo (do these in GitHub)
- Settings > Rules: ruleset imported and **Enforcement = Active**.
- Settings > General > Pull Requests: squash only, auto-delete branches, auto-merge allowed.
- Settings > Collaborators: developers get **Write**; only 1-2 maintainers get **Admin** (they hold the bypass).
- Optional: Settings > Code security: enable Dependabot alerts and secret scanning; enable a **merge queue** in the ruleset if merges start colliding.
- Plan limits: rulesets on private repos need GitHub Pro/Team or higher. If unavailable, the equivalent is classic *Settings > Branches > Branch protection rule* with the same options.
- Solo/cohort repo note: with a single account, you cannot approve your own PR. Add a second collaborator (or a reviewer account), or use the admin bypass while practising.

## 4. Emergency fixes

Goal: restore production fast **without** abandoning the safety net.

1. **Branch from `main`:** `git switch -c hotfix/<what-is-broken>`. Because `main` is always production-ready (and production runs `main`), no special branch or back-merge is needed.
2. **Make the smallest possible fix**, plus a regression test if feasible. No refactors.
3. **Open a PR** with the `hotfix` label; fill in *Impact* and *Rollback plan* in the template. Notify the team in chat.
4. **Fast-track review:** any available teammate reviews immediately; this takes priority over normal work. CI still runs. It is intentionally fast.
5. **Merge (squash)** once green and approved, then deploy/tag a patch release (e.g. `v1.4.1`).
6. **Roll back instead if quicker:** revert the offending PR (`gh pr revert` or GitHub's *Revert* button), which is itself a normal PR.

### Break-glass (true last resort)
If CI is itself broken or no reviewer exists (e.g. outage, outside working hours), a repository admin may merge the hotfix PR using the ruleset **bypass**. Rules:
- It still goes through a PR (bypass is *pull-request only*), so there is a record.
- Within 24 hours: a teammate does a **post-merge review** on the PR, and the team opens a follow-up issue to fix whatever was bypassed.
- Bypass is for emergencies only, never for convenience or deadlines.

### After the incident
Write a short blameless note (what broke, why, how to prevent it) in the PR or an issue.

## 5. Trade-offs of this approach

**Benefits**
- Very little to learn or get wrong; one trunk, one path to production.
- Protections are enforced in code, so they apply the same to everyone.
- Small PRs and quick reviews give fast feedback and few conflicts.
- Hotfixes reuse the normal path, so urgent changes get the same checks.

**Costs and limitations**
- **`main` must stay green and deployable**, so we depend on decent automated tests. Weak tests mean weak protection.
- **Review is a bottleneck**; with 5 people, one slow reviewer stalls others. Mitigated by the one-day response rule and rotation.
- **Strict "up to date" requirement** can force re-running CI when several PRs are merged back to back (a merge queue is the upgrade path).
- **Squash merging** loses per-commit history inside a PR and makes stacked/dependent branches harder.
- **No staging branch:** pre-production testing must happen via CI, preview deploys, or flags, not by merging to a `develop` branch.
- **Single supported version:** if NovaCart later must support several released versions in parallel, add `release/*` branches then. We deliberately do not pay that cost now.
- **Admin bypass is a trust-based escape hatch**; keep the admin list tiny and review its use.

## 6. When to revisit
Revisit this document if the team grows beyond ~10 developers, if releases need QA freezes or multiple supported versions, or if merge collisions or CI time become a regular complaint.

## 7. Files that implement this strategy
| File | Purpose |
|---|---|
| `.github/rulesets/protect-main.json` | Branch protection for `main` |
| `scripts/setup-github.sh` | Applies the ruleset, merge settings and `hotfix` label |
| `.github/workflows/ci.yml` | Required `lint`, `test`, `build` checks |
| `scripts/ci/run.sh` | Commands for the checks, tailored to the `backend/` and `frontend/` layout |
| `.github/pull_request_template.md` | Consistent PRs, hotfix fields |
| `.github/CODEOWNERS` | Optional automatic reviewer requests |
| `docs/step-by-step-guide.md` | Setup and day-to-day how-to, with commands |
