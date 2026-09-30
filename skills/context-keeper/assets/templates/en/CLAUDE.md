<!--
TEMPLATE — the skill fills in the {{...}} fields and removes this comment.
Keep the final file under ~150 lines: it is loaded in EVERY session.
Links: the template uses regular Markdown links with relative paths (default). If the user chose
wikilinks (Obsidian), convert [Text](path/Note.md) into [[Note]] when filling it in.
-->
# {{NAME}}'s second brain: global scope

This file is the starting point of every session. It says **how to act**, **how to navigate** and **where everything is**. It is neutral on purpose: it does not describe or favor any subject. The context of each area or project lives inside its folder and only comes into play when that subject is being worked on.

## 1. Purpose

Keep what does not fit in the code or in the chat history: decisions and their reasons, the state of each piece of work, discoveries, {{NAME}}'s preferences and ideas. That way no session starts from zero.

- **Read before acting:** this file, then the main note (`Index.md`) of the subject at hand.
- **Record after deciding:** see section 6.
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

1. **Start here.** Read this file.
2. **Identify the subject** of the request: which area, project or idea?
3. **Find its folder in the map** (section 4). Do not search the disk for folders: the map says where everything is.
4. **Enter the folder and read its main note** (`Index.md`). Only then take that subject's context into account.
5. **Follow the main note's links** as needed, without reading the whole folder for no reason.
6. **"What was I working on?"** Read [NOW](NOW.md) and the latest `Journal/` entry.
7. **When done,** update the notes affected (section 6).

If the subject has no folder, record it in `Inbox/` and propose creating one to {{NAME}}. Every new folder, created by the AI or by {{NAME}}, goes into the map right away.

## 4. Map

### Current

Built from the real folders: do not edit by hand between the markers. To update it, use `/context-keeper:map` or ask "update the map". Each folder's description comes from the `description:` field of its `Index.md`.

<!-- context-keeper:map:start -->
```
(the map appears here at the first update)
```
<!-- context-keeper:map:end -->

### Planned

{{PLANNED_STRUCTURE_OR_REMOVE_THIS_SECTION}}

Create each folder only when there is content for it. Each project lives in its own folder under `Projects/`, with its `Index.md`, its `Decisions/` and the project's own files (code in a subfolder).

## 5. Conventions

- File and folder names without accents, with hyphens instead of spaces (`Overview.md`).
- Links between notes: {{LINK_CONVENTION}}.
- One note per subject. A note that grows too large is split and the parts are linked.
- Frontmatter at the top of each note:

```yaml
---
type: area | project | decision | research | idea | journal
status: idea | planning | in-progress | paused | done
description: what this folder is, in one neutral line (only in Index.md)
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []
---
```

Note templates are in `Templates/`.

## 6. Feeding protocol

Filter: *"In a new session, a month from now, would this help me act better?"* If yes, record it.

| When | Where |
|---|---|
| A decision was made | `<subject>/Decisions/YYYY-MM-DD-title.md` |
| Something finished or changed status | "Current state" of the subject's `Index.md` + [NOW](NOW.md) |
| A folder was created (by the AI or by {{NAME}}) | The map (section 4) + `Index.md` with `description:` |
| {{NAME}} corrected something or stated a preference | [Preferences](Profile/Preferences.md) |
| {{NAME}} said "note this", "remember this" | The right note or `Inbox/` |
| A project's files live outside the brain | "Where things are" in its `Index.md` + suggest moving it under `Projects/` ({{NAME}} moves it, never the AI) |
| End of session, long conversation or checkpoint request | **Checkpoint** (below) |

Do not record: what is already in code/git, transcripts, information that loses value within hours.

**Autonomy:** {{AUTONOMY}}
<!-- One of:
- Ask before writing any note.
- Write and tell in one line at the end of the answer: "Saved: <what> in <where>".
- Write without telling and list everything only at the checkpoint.
-->

**Checkpoint** — update, in this order: (1) decision notes; (2) "Current state" of the subjects touched, rewriting the section; (3) [NOW](NOW.md), keeping it short; (4) [Preferences](Profile/Preferences.md), if there is something new; (5) a 3–8 line entry in `Journal/YYYY-MM-DD.md`. Update the `updated:` field of the notes touched. If nothing relevant happened, do not create empty entries.

## 7. Decisions

One note per decision, from `Templates/Decision.md`: context, options considered, choice, reason and consequences. Superseded decision: set `status: superseded` and link the new one. Never delete.
