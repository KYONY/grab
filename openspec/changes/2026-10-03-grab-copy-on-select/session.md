---
id: osdd-dc457344
change_name: "2026-10-03-grab-copy-on-select"   # YYYY-MM-DD-<slug>; THE directory name under openspec/changes/. Derived once in Phase 0, never recomputed.
slug: "grab-copy-on-select"                 # undated kebab-case slug; Phase 0 step 1b finds an existing run by this, never by feature text
spec_language: "uk"            # uk | en (`--english`); language of spec prose — see references/phase-2-spec.md "Language"
project: "grab"    # used by osdd-metrics.py to filter provider logs; defaults to cwd basename if empty
feature: "Grab — copy-on-select menu bar app"
status: in-progress
current_phase: 2.5
next_phase: 4
spec: ""
plan: ".claude/plans/2026-10-03-grab-copy-on-select.md"
base_commit: ""
scope_authority: "S1"        # source id (in sources.md) that defines in-scope items; "" = none
sources: "sources.md"       # source manifest path; "" = none
ground_status: "human-checkpoint"           # grounded | blocked | human-checkpoint | not-run | no-op
created: "2026-10-03T09:18:38Z"
updated: "2026-10-03T09:18:38Z"
metrics:
  steps_total: 9
  steps_completed: 0
  steps_first_pass: 0
  reworks: 0
  reflect_cycles: 0
  facts_verified: 0          # facts checked against a source at GROUND
  facts_unsourced: 0         # facts the user had to ratify as assumptions
  out_of_scope_blocked: 0    # items blocked by the scope set-diff
  phase_times: {}
---

# OSDD Session: Grab — copy-on-select menu bar app

## Decisions Log

<!-- Append key decisions as they happen -->

## Phase Outputs

<!-- Each phase appends its summary here -->

### Entry: `/osdd .claude/plans/2026-10-03-grab-copy-on-select.md.` (2026-10-03)
Argument is a plan path, not feature text → treated as `execute <plan>` (cold start). Phases 1–3 skipped: discovery was the grill session; the plan is the user-reviewed PDD plan.
Engine: `check-openspec-pin.sh` exit 5 (openspec 1.11.0 on pin, change did not exist yet) → static artifact order; irrelevant for execute.
Base commit: none — repository root is `/Volumes/RnD/RnD/Development/macOS` (parent, no commits, sibling projects). Pending user decision.

### Phase 2.5 GROUND (pre-execute)
- ground-lint on plan: exit 1, 21 candidates, 0 blocked. All dismissed as noise: 7 rows are the `## Sources` table itself, 13 are `## Acceptance Checklist` rows (criteria, not facts), 1 is a verbatim user quote in `## Out of Scope`.
- Scope set-diff: plan items vs `scope-authority-S1.md` in-scope set → 0 extra features. Implementation-only decisions (NSEvent monitor, 60/150 ms delays, Hardened Runtime, folder-synced groups, localization check script) add no user-visible scope.
- Provenance: S2–S4 + plan ASSUMPTIONs sent to researcher; S1/S6/S7 human-only → human checkpoint.
- Provenance (researcher): S2, S3, S4 SUPPORTED; Ghostty/iTerm2/1Password bundle IDs SUPPORTED → S8; settings deep link SUPPORTED for macOS 13+ → S9; NSEvent global mouse monitor needs no Accessibility trust (key events only) — consistent with Step 6 design. Plan ASSUMPTIONs converted to FACTs.
