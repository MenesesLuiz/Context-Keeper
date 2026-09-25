# Brain maintenance

A brain without maintenance grows until it is expensive to read, and starts holding stale information that misleads the AI. Maintenance keeps the hot context small and the content trustworthy.

## 1. Run the checker

```bash
bash scripts/brain-lint.sh [brain] [days-until-stale]
```

Without a path, it uses the pointer `~/.context-keeper/config`. It reports:
- a root file or now file larger than recommended (they cost tokens in every session);
- notes without frontmatter;
- notes whose `updated:`/`atualizado:` date is old (default: 60 days);
- Inbox items older than 14 days;
- links (regular Markdown or `[[wikilinks]]`) pointing to notes that do not exist;
- possible secrets (patterns like `api_key`, `password:`, `sk-`, `ghp_`) — only file and line, never the value.

## 2. Judgment checks (what the script cannot see)

- **Duplicate subjects:** two notes about the same thing under different names → propose merging.
- **Contradicting decisions:** a new decision replaces an old one that is not marked as superseded.
- **Stale "Current state":** compare with the recent journal and, if there is one, the project's git history.
- **Conflicting rules in the preferences note:** ask the user which one holds.
- **Stalled projects:** propose moving them to the Archive and out of the now file.
- **Inbox:** for each item, propose a destination (existing note, new note, archive or discard).
- **Old journal:** entries from previous months can be condensed into `YYYY-MM-summary.md`.

## 3. Present and apply

Show a short report in plain language, grouped by priority (what costs tokens or can mislead the AI first). Apply only what the user approves and log the review in the journal.

Suggest a cadence to the user (e.g. monthly) and, if their tool has scheduled tasks, offer to schedule a reminder.
