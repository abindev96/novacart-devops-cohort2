#!/usr/bin/env bash
# Single entry point for CI steps: lint | test | build
# Matches the NovaCart layout:
#   backend/   Python (FastAPI): app/, tests/, requirements.txt
#   frontend/  static HTML/CSS/JS (no package.json, no bundler)
# Run locally from the repo root:  bash scripts/ci/run.sh test
set -euo pipefail
step="${1:?usage: run.sh lint|test|build}"

fail() { echo "::error::$*"; exit 1; }

[ -f backend/requirements.txt ] || fail "backend/requirements.txt not found; update scripts/ci/run.sh"
[ -d frontend ] || fail "frontend/ not found; update scripts/ci/run.sh"

backend_setup() {
  python -m pip install --upgrade pip
  pip install -r backend/requirements.txt
}

case "$step" in
  lint)
    echo "== Backend lint (ruff) =="
    pip install ruff
    (cd backend && ruff check .)
    echo "== Frontend lint (JavaScript syntax check) =="
    for f in frontend/*.js; do
      [ -e "$f" ] || continue
      node --check "$f"
    done
    ;;

  test)
    echo "== Backend tests (pytest) =="
    backend_setup
    pip install pytest httpx
    # Run from backend/ so `import app` resolves. `python -m pytest` adds cwd to sys.path.
    (cd backend && python -m pytest tests -v)
    ;;

  build)
    echo "== Backend: compile + import the app =="
    backend_setup
    (cd backend && python -m compileall -q app && python -c "import app.main")
    echo "== Frontend: static files present and referenced assets exist =="
    [ -f frontend/index.html ] || fail "frontend/index.html missing"
    for asset in app.js styles.css; do
      [ -f "frontend/$asset" ] || fail "frontend/$asset missing"
    done
    # If a frontend/package.json is added later, build it here.
    if [ -f frontend/package.json ]; then
      (cd frontend && { if [ -f package-lock.json ]; then npm ci; else npm install; fi; } && npm run build --if-present)
    fi
    ;;

  *) fail "unknown step: $step (use lint|test|build)" ;;
esac
