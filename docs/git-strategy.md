Git strategy: Simplified Trunk-Based Development Strategy with Feature and Hotfix Branches

Working condition
. Small/medium team(5 devs)
. Frequent or regular releases
. No parallel development is needed
. Simple workflow preferred
. Make Git history clean and simple
. Automated testing and code review in place


Workflow

1.Normal workflow: Feature/<feature name> branch → PR → review+ PR ruleset check(lint, test, build) → squash and merge to main
2.Urgent production issues: Hotfix/* branch from main → fix the issue → PR → review + PR ruleset check → Squash and Merge into main→ Deploy the fix.


Developer Contribution Workflow:

Clone repository → Pull latest main → Create feature branch → Make code changes → Run lint, test, build → Commit and push changes → Create PR → Code review + PR ruleset checks → Squash and Merge into main


how main branch is protected
Enabled GitHub branch protection/rulesets to require PR reviews, successful PR ruleset checks (lint, test, build),block direct pushes and force pushes to main, and allow only Squash and Merge.

Drawback / Trade-off of this strategy

1.No dedicated develop branch:Developers integrate changes into main through PRs.Incomplete features must remain outside main
2. Squash and Merge loses commit detail on main: Individual commits from a feature branch are combined into one commit, so the detailed development history is less visible on main.
3.Release management is less structured:There is no dedicated release branch by default. Projects needing a long testing or stabilization period may need additional release branches.
4.CI checks can slow down merging
5.Review dependency:If a reviewer is unavailable, a PR may remain blocked. This is especially relevant when only a few developers can approve changes.
6.Requires disciplined PRs: Small, focused PRs are important. Large PRs are harder to review, test, and revert safely.