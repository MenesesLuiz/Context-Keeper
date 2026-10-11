---
description: Sync the second brain with its private GitHub repository now (pull, then push)
---

Use the `context-keeper` skill in **Mode 6 — Sync**:

1. Run `bash "${CLAUDE_PLUGIN_ROOT}/skills/context-keeper/scripts/sync.sh" both`. It finds the brain through `~/.context-keeper/config`; pass the brain path as an argument if there is no pointer.
2. If sync is off or not set up, offer to set it up (Setup → integrations, "Sync with GitHub") instead of running anything else.
3. If it reports a conflict, show me the two versions of each conflicting note and let me decide; never pick one on your own. If it blocked a possible secret, show me the file and line, and wait for me to remove it.
4. Tell me in 1–3 lines what happened.

$ARGUMENTS
