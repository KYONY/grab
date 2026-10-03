#!/usr/bin/env bash
# Fails if Grab/Localizable.xcstrings lacks a translated "uk" entry for any key,
# or if a required source string is missing.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
import json, sys
required = [
    "Grab needs Accessibility access",
    "Grab uses the Accessibility permission to read the text you select. Turn it on for Grab in System Settings.",
    "Open System Settings",
    "Enabled",
    "Settings…",
    "Quit",
    "Excluded apps",
    "Choose app…",
    "Launch at login",
]
strings = json.load(open("Grab/Localizable.xcstrings", encoding="utf-8")).get("strings", {})
bad = [f"missing key: {k}" for k in required if k not in strings]
for k, v in strings.items():
    unit = v.get("localizations", {}).get("uk", {}).get("stringUnit", {})
    if unit.get("state") != "translated" or not unit.get("value"):
        bad.append(f"uk not translated: {k}")
if bad:
    print("Localization check FAILED:\n  " + "\n  ".join(bad))
    sys.exit(1)
print(f"Localization check OK ({len(strings)} keys)")
PY
