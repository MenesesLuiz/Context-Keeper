<!--
TEMPLATE — the skill fills in the {{...}} fields and removes this comment.
Keep the final file under ~150 lines: it is loaded in EVERY session.
Links: the template uses regular Markdown links with relative paths (default). If the user chose
wikilinks (Obsidian), convert [Text](path/Note.md) into [[Note]] when filling it in.
{{LINK_CONVENTION}}, one of:
- Markdown links with a path relative to the current note: `[Text](../Folder/Note.md)`
- `[[Note-Name]]` links (Obsidian wikilinks)
-->
# {{NAME}}'s Second Brain

This file is the starting point of every session. It says **how to act**, **where things live** and **when to record**. The current state of the work is in [NOW](NOW.md).

## 1. Purpose

Keep what does not fit in the code or in the chat history: decisions and their reasons, the state of each piece of work, discoveries, {{NAME}}'s preferences and ideas. That way no session starts from zero.

- **Read before acting:** this file, then [NOW](NOW.md), then the `Index.md` of the subject at hand.
- **Record after deciding:** see section 5.
- **Don't duplicate:** look for an existing note on the subject and update it.
- **Absolute dates:** always `YYYY-MM-DD`.
- **The brain keeps the why;** code and git keep the how.
- **Never record secrets** (passwords, tokens, keys). If one shows up, warn {{NAME}}.
- **Plain text, no emojis**, in notes and in save notices.

## 2. Rules of conduct

{{RULES_OF_CONDUCT}}
<!-- Example:
1. Plan before doing big tasks; ask for approval.
2. Ask when there is a real doubt instead of assuming.
3. Stay in the requested scope; extra suggestions go as proposals.
4. Language: English.
-->

Detailed preferences: [Preferences](Profile/Preferences.md).

## 3. How to navigate

1. Read this file and [NOW](NOW.md).
2. Identify the subject of the request.
3. Open the subject folder's `Index.md` and read its "Current state" section.
4. Follow the notes' links as needed, without reading whole folders for no reason.
5. If the subject has no folder, record it in `Inbox/` and propose creating one to {{NAME}}.

## 4. Map

<!-- The skill adapts the tree to the chosen structure (By subject or PARA) and removes what does not exist. -->
```
BRAIN.md          rules and map (this file)
NOW.md            current focus, open items, latest decisions
Profile/          About-me.md, Preferences.md
Projects/<Name>/  Index.md (Current state) + Decisions/
Research/         research useful to more than one project
Inbox/            quick captures not yet sorted
Journal/          YYYY-MM-DD.md, one entry per relevant session
Templates/        note templates
Archive/          finished or abandoned work
.context-keeper/  configuration and hook state
```

Conventions: file names without accents, with hyphens instead of spaces (`Overview.md`); {{LINK_CONVENTION}}; frontmatter at the top of each note:

```yaml
---
type: project | area | decision | research | idea | journal
status: idea | planning | in-progress | paused | done
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []
---
```

Note templates are in `Templates/`.

## 5. Feeding protocol

Filter: *"In a new session, a month from now, would this help me act better?"* If yes, record it.

| When | Where |
|---|---|
| A decision was made | `<subject>/Decisions/YYYY-MM-DD-title.md` + "Latest decisions" in [NOW](NOW.md) |
| Something finished or changed status | "Current state" of the subject's `Index.md` |
| {{NAME}} corrected something or stated a preference | [Preferences](Profile/Preferences.md) |
| {{NAME}} said "note this", "remember this" | The right note or `Inbox/` |
| Research produced conclusions | The subject's research note |
| End of session, long conversation or checkpoint request | **Checkpoint** (below) |

Do not record: what is already in code/git, transcripts, information that loses value within hours.

**Autonomy:** {{AUTONOMY}}
<!-- One of:
- Ask before writing any note.
- Write and tell in one line at the end of the answer: "Saved: <what> in <where>".
- Write without telling and list everything only at the checkpoint.
-->

**Checkpoint** — update, in this order: (1) decision notes; (2) "Current state" of the subjects touched, rewriting the section; (3) [NOW](NOW.md), keeping it short; (4) [Preferences](Profile/Preferences.md), if there is something new; (5) a 3–8 line entry in `Journal/YYYY-MM-DD.md`. Update the `updated:` field of the notes touched. If nothing relevant happened, do not create empty entries.

## 6. Decisions

One note per decision, from `Templates/Decision.md`. Superseded decision: set `status: superseded` and link the new one. Never delete.
