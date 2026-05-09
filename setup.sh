#!/usr/bin/env bash
set -euo pipefail

cat <<'MESSAGE'
This is the W1 scaffold placeholder for manim-agentic-interface-playground.

No setup/render proof is claimed from this script yet.

W2 owns the final setup behavior:
  - Python 3.11+ probe
  - canonical Manim virtual environment
  - pinned Manim version discovery from MAI
  - TTS sibling-checkout engine install/remediation

W3 owns the MAI CLI/resource machinery this script will call:
  - setup --venv
  - pinned-manim-version
  - preflight
  - dump-skills
  - first clean clone + setup + render proof

Until W2/W3 land, this placeholder exits without mutating the machine.
MESSAGE

exit 69
