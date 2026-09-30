---
description: Read the brain's folders and update the map in its CLAUDE.md
---

Use the `context-keeper` skill in **Mode 5 — Map**:

1. Run the map script. It finds the brain through `~/.context-keeper/config`; pass the brain path as an argument if there is no pointer.
   - With the Bash tool: `bash "${CLAUDE_PLUGIN_ROOT}/skills/context-keeper/scripts/update-map.sh"`
   - On Windows with the PowerShell tool: `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/skills/context-keeper/scripts/update-map.ps1"`
2. If it reports that the root file has no map markers, show me where you would add them and wait for my approval before editing.
3. For each folder listed as "without description", propose a one-line, neutral description (what the folder is, not its status) and, after my approval, write it in the `descricao:`/`description:` field of the folder's index note, creating the index note from the template if it does not exist. Then run the script again.
4. Tell me in 2–4 lines what changed in the map.

$ARGUMENTS
