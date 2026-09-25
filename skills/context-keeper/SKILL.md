---
name: context-keeper
description: Builds, feeds and maintains a local "second brain" for AI — a folder of Markdown notes the AI loads at the start of every session and updates on its own, so context survives across conversations and after compaction. Interviews the user, proposes an action plan with options for them to choose, and only then creates the structure, rules and automation (Claude Code hooks, instruction files for Cursor/Codex/Gemini). Use whenever the user mentions a second brain ("segundo cérebro"), persistent or long-term memory for AI, "the AI forgets everything" ("a IA esquece tudo"), losing context between sessions, organizing notes for Claude, moving from Obsidian/Notion to something the AI can use, or asks to save, record or checkpoint what was decided "in the brain" ("salva no cérebro") — even if they never say "second brain".
---

# Context Keeper

This skill builds a second brain **made for the AI to read and write**, not just for a human to browse. Compared with a plain Obsidian vault, it adds three things:

1. **A fixed entry point** the AI loads automatically in every session.
2. **Feeding rules**: when and what the AI records, without the user having to ask.
3. **Automation**: hooks that reload context after compaction and ask for a checkpoint before it is lost.

The AI reads the files straight from disk, so the brain does not need Obsidian. A plain folder is the recommended default; Obsidian is an optional viewer for the human.

## Principles

When a case is not covered by the steps below, decide from these.

- **The user chooses, you propose.** Nothing is created before the user approves a plan. Files outside the brain folder are touched only with explicit consent and after a backup. The one exception, agreed in the plan, is the pointer `~/.context-keeper/config` that this skill creates.
- **Layered memory, so it fits in context.**
  - *Hot* (loaded every session, under ~2,000 tokens total): the root file (rules and map) and the now file (current focus, open items).
  - *Warm* (loaded when a subject comes up): each subject's index note, with its "Current state" section.
  - *Cold* (read only when needed): decisions, research, older journal entries, archive.
- **The brain keeps the why; code and git keep the how.** Do not copy into the brain what the code, README or git history already hold.
- **The brain works without this skill.** All feeding rules are written inside the brain's root file, so any AI can operate it.
- **Update instead of duplicating**, use **absolute dates** (`YYYY-MM-DD`), and **never store secrets** (passwords, tokens, API keys).
- **Plain text, no emojis**, in notes and in messages about the brain.
- **Language.** Run the interview and build the brain in the user's language. Use `assets/templates/pt-BR/` for Portuguese and `assets/templates/en/` for English. For any other language, start from `en/`, translate file and folder names, and record them in `.context-keeper/config.json` → `files`.

## Pick the mode

| The user wants to | Mode |
|---|---|
| Create a second brain, "I want the AI to remember things", adopt an existing brain or notes folder, change the automation level or add another AI tool | **1. Setup** |
| "Save this to the brain", "checkpoint", end of a long session, `/context-keeper:checkpoint`, or the Stop hook asked for it | **2. Checkpoint** |
| Bring in notes from Obsidian/Notion, documents, a repository or exported conversations | **3. Import** |
| "Review/clean up my brain", stale notes, a messy brain, `/context-keeper:review` | **4. Review** |

---

## Mode 1 — Setup

Six steps. Never skip step 3: the plan approval is what keeps the user in charge.

1. **Detect, silently.** Find out what you can before asking anything:
   - operating system and home folder;
   - AI tools present (`~/.claude/`, `~/.claude/CLAUDE.md`, `~/.codex/`, `~/.gemini/`, Cursor);
   - an existing brain: first `~/.context-keeper/config`, then folders with `BRAIN.md`, `CEREBRO.md`, `Claude.md`, `AGENTS.md` or `.context-keeper/config.json`;
   - an Obsidian vault (a folder with `.obsidian/`);
   - `bash` (needed for the hooks; on Windows it ships with Git for Windows, which Claude Code already requires).

   If a brain exists, switch to **adopt**: keep everything the user made, map it to this skill's concepts (e.g. their `Claude.md` acts as the root file) and propose only what is missing. If it was created by this skill, read `.context-keeper/config.json` and ask what they want to change. Never overwrite existing notes.

2. **Interview.** Follow `references/interview.md`. Offer the quick path (5 questions) or the full one, ask at most 3–4 questions per round, and use `AskUserQuestion` when available.

3. **Plan.** Build the plan with the format at the end of `references/interview.md`, using `references/architectures.md` for the options. Present it and **wait for the user's choices**. Adjust and present again as many times as needed.

4. **Build**, in this order, reporting progress:
   1. **Folders**: only the core ones and those that will have content now. Empty folders confuse the AI and the user.
   2. **Core files** from the language's template set: root file, now file, `Profile/About-me.md` (or the localized name) and the preferences file from the interview answers, the note templates copied into `Templates/`, and `.context-keeper/config.json` from `assets/templates/config.json`. Keep the root file under ~150 lines: it loads every session.
   3. **Pointer**: write `~/.context-keeper/config` with the line `brain_path=<brain path, forward slashes>`. The hooks and the checker find the brain through it. If it already points elsewhere, ask before replacing it.
   4. **Integrations** for the chosen level: follow `references/integrations.md`.
   5. **Git** (if chosen): `git init`, `.gitignore` with `.context-keeper/state/`, first commit. For a remote, recommend a **private** repository.

5. **Seed.** An empty brain helps nobody:
   - an index note for each active subject the user mentioned, with "Current state" filled in;
   - the now file with the current focus and open items;
   - imports the user asked for (Mode 3);
   - the first journal entry recording the setup and the choices made, and the approved plan saved to `.context-keeper/setup-plan.md`.

6. **Verify and hand off.**
   1. Run `bash scripts/brain-lint.sh <brain>` (from this skill's folder) and fix what it reports.
   2. At level 3, run the start hook without the brain path, to test the pointer too: `echo '{"source":"startup"}' | bash scripts/session-start.sh`. The output must contain the now file and stay under 8,000 characters.
   3. Give the user a **one-screen guide**: where the brain lives, what happens automatically, 3–4 useful phrases ("save this to the brain", "what's in NOW?", "review the brain") and, if they chose Obsidian, how to open the folder as a vault.
   4. Suggest a real test: open a new session and ask "what was I working on?".

## Mode 2 — Checkpoint

Follow the *Checkpoint* section of `references/feeding-protocol.md`:

1. Read the root file and the now file.
2. List what is worth keeping since the last checkpoint: decisions (with the reason), state changes, open items, discoveries, new preferences.
3. Update decision notes, the "Current state" of each subject touched, the now file, the preferences file and the journal.
4. Tell the user in 2–4 lines what was saved and where. If nothing relevant happened, say so instead of creating empty notes.

## Mode 3 — Import

Follow `references/importing.md`. Importing is not copying:

1. Take an inventory of the source, without changing anything.
2. Triage each part: bring and reorganize, summarize, only link to it, or leave out.
3. Present the triage as a table and wait for approval.
4. Copy into the brain (never move or delete the source) and log the import in the journal.

## Mode 4 — Review

Follow `references/maintenance.md`:

1. Run `scripts/brain-lint.sh`.
2. Add the checks that need judgment (duplicates, contradicting decisions, stale "Current state").
3. Present a short report in plain language, most costly problems first.
4. Apply only what the user approves and log the review in the journal.

---

## Files

| File | When to read |
|---|---|
| `references/interview.md` | Setup steps 2–3 (questions, defaults and the plan format) |
| `references/architectures.md` | Setup step 3 (folder structures, plain folder vs Obsidian, link style, automation levels) |
| `references/integrations.md` | Setup step 4 (Claude Code, Claude Desktop, Cursor, Codex, Gemini, ChatGPT) |
| `references/feeding-protocol.md` | Writing the root file's feeding rules, and Mode 2 |
| `references/importing.md` | Mode 3 |
| `references/maintenance.md` | Mode 4 |
| `assets/templates/pt-BR/`, `assets/templates/en/` | Brain files per language |
| `assets/templates/config.json` | The brain's `.context-keeper/config.json` |
| `assets/hooks/claude-settings.json` | Hooks for `~/.claude/settings.json` (level 3, standalone install only) |
| `scripts/lib.sh` | Shared by the scripts: finds the brain, its file names and language |
| `scripts/session-start.sh` | Hook: loads the hot context at session start and after compaction |
| `scripts/checkpoint-stop.sh` | Hook: asks for a checkpoint when the conversation grew a lot since the last one |
| `scripts/brain-lint.sh` | Health check of the brain |
