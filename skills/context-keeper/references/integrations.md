# Integrations per tool

General rule for any file outside the brain:
1. If the file exists, **read it** and back it up (`<file>.bak-YYYY-MM-DD`).
2. **Append** the brain block between markers, without deleting what is there:
   ```
   <!-- context-keeper:start -->
   ...
   <!-- context-keeper:end -->
   ```
   The markers let a later Setup run update or remove the block.
3. Record the changed file in `.context-keeper/config.json` → `integrations`.

Tool paths and menus change often. If something below does not match what you find on the user's machine, check the tool's current documentation before going on.

Use `/` in paths even on Windows (e.g. `D:/Notes/Brain`), because the scripts run in bash.

In the blocks below, `<BRAIN>` is the brain path and `<ROOT>` is its root file name (`CLAUDE.md`, or the adopted one). Write the block text in the user's language.

---

## Claude Code

### Level 2 — global import
In `~/.claude/CLAUDE.md` (loaded in every session, in any folder):

```markdown
<!-- context-keeper:start -->
# Second brain
My second brain lives at `<BRAIN>`. Its rules are below; follow them in every session.
@<BRAIN>/<ROOT>
<!-- context-keeper:end -->
```

The `@path` line imports the file into context. To check it worked, the user can run `/memory` in a new Claude Code session and see the root file listed.

> Without this import, the root file only loads when Claude Code is opened inside the brain folder or any folder under it (Claude Code reads `CLAUDE.md` from parent folders). If the user always works inside the brain — the recommended organization — the import is optional; offer it for people who also open Claude Code elsewhere. With both, the file may load twice, which only costs a few extra tokens.

### Level 3 — hooks

Level 3 always includes level 2: set up the global import above first. Then make sure the pointer `~/.context-keeper/config` exists (`brain_path=<BRAIN>`). Then it depends on how the skill was installed:

**As a plugin (recommended).** The `context-keeper` plugin ships the hooks in `hooks/hooks.json`. They stay inactive until the pointer exists and start working in the next session. Do not edit `~/.claude/settings.json`.

The hooks run with `bash`: on macOS and Linux it is built in; on Windows it is the Git Bash from Git for Windows, a prerequisite of this skill.

**Turn on auto-update for this plugin (recommended, with consent).** Marketplaces from third parties do not update on their own: without this, the user keeps the version they installed and never receives fixes. Propose it in the plan as a change outside the brain, then, after approval and a backup of `~/.claude/settings.json`:
- if `extraKnownMarketplaces` already has a `context-keeper` entry (Claude Code writes one when the marketplace is added), add `"autoUpdate": true` to it;
- otherwise add the entry:
  ```json
  "extraKnownMarketplaces": {
    "context-keeper": {
      "source": { "source": "git", "url": "https://github.com/MenesesLuiz/Context-Keeper.git" },
      "autoUpdate": true
    }
  }
  ```
Keep every other key in the file untouched. Tell the user that updates arrive a few minutes after the first message of a session, and that they can force one with `claude plugin marketplace update context-keeper`.

**As a standalone skill.**
1. Copy the skill's `scripts/*.sh` (including `lib.sh`) to `<BRAIN>/.context-keeper/scripts/`.
2. Merge `assets/hooks/claude-settings.json` into `~/.claude/settings.json`, replacing `<BRAIN>` with the real path. If hooks already exist for the same events, **append** entries to the array instead of replacing it.

**Test (both cases):** feed `{"source":"compact"}` to the start hook and check that the output is short and contains the now file:
```bash
echo '{"source":"compact"}' | bash "<scripts folder>/session-start.sh"
```

What each hook does:
- **SessionStart** (`session-start.sh`): runs when a session starts, resumes, is cleared or is **compacted**. Every time, it rebuilds the map in `CLAUDE.md` from the real folders (`update-map.sh`); if the map changed, it prints the new map, because Claude Code may have loaded the old file already. After a **compaction** it also prints the now file and the latest journal entry, so the AI resumes the work in progress. At a normal start with an up-to-date map it prints nothing: the neutral `CLAUDE.md` is the only entry point. Claude Code accepts up to 10,000 characters of hook output; the script cuts at 8,000.
- **Stop** (`checkpoint-stop.sh`): runs when the AI finishes an answer. It reads the current context size in tokens from the transcript (the last response's `usage`). If the context grew more than the limit (default 50,000 tokens) since the last checkpoint, it returns an `additionalContext` asking the AI to run a checkpoint before stopping. The user sees it as "Stop hook feedback", not as an error. It has loop protection (`stop_hook_active`), fires again only after new growth, and follows the context down after a compaction. The limit can be changed with `CONTEXT_KEEPER_CHECKPOINT_TOKENS`.

File names and the hook messages' language come from `.context-keeper/config.json` (`files`, `language`), so the scripts work in any language and in adopted brains (e.g. a `Claude.md` root).

---

## Claude Desktop (chat app) and claude.ai

- **Claude Desktop** (menus checked on 2026-09-30):
  1. *Settings > Extensions*: install the **Filesystem** extension by Anthropic from the directory (if it is not installed yet), make sure it is enabled, and add the brain folder under **Allowed Directories**. Only the brain folder is needed.
  2. *Settings > Instructions for Claude* (account-wide, applies to every conversation): paste the text below. For a single context, a Project's instructions work the same way, but only inside that Project.
     > I have a second brain at `<BRAIN>`. At the start of every conversation, read `<ROOT>` in that folder and follow its rules. Use the map in `<ROOT>` to find folders; do not search the disk for them.
  3. There are no hooks and no bash here: the AI keeps the map up to date by editing it in `<ROOT>` itself, following the rule "every new folder goes into the map right away". Tell the user they can ask "update the map" at any time.
- **claude.ai on the web:** cannot read local files. One option is a Project with the root file, the now file and the profile uploaded as project knowledge — but it is a static copy that must be re-uploaded when it changes. Make this limit clear to the user.

## Cursor

- **Global:** Cursor Settings → Rules → *User Rules*: paste the same text as for Claude Desktop (Cursor's AI reads files by absolute path). This step is manual; list it in the plan as a task for the user.
- **Per project:** Cursor also reads `AGENTS.md` at the project root and rules in `.cursor/rules/`. Only create files in the user's repositories if they ask.

## OpenAI Codex CLI

Global file `~/.codex/AGENTS.md`: append the marked block pointing to `<BRAIN>/<ROOT>` and asking the AI to read it at the start of the session.

## Gemini CLI

Global file `~/.gemini/GEMINI.md`: same block as for Codex.

## GitHub Copilot

Instructions are per repository (`.github/copilot-instructions.md`). Only set it up if the user asks, one repository at a time.

## ChatGPT (web/app)

Cannot read local files. All options are manual:
- Paste the profile and preferences notes into the custom instructions.
- In important conversations, paste the now file at the start and, at the end, ask for a checkpoint-style summary to paste into the brain (or ask an AI with file access to record it).

Be honest with the user: in these tools the brain works at level 1.
