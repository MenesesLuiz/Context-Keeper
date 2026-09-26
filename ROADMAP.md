# Roadmap

Current version: **0.2.0 (in development)**

## Decisions (2026-09-25)

- **Name:** `context-keeper`.
- **License:** MIT.
- **Distribution:** Claude Code plugin, with the marketplace in this same repository. The skill folder also works on its own.
- **Language:** English is the main language (skill, `README.md`, docs). `README.pt-BR.md` serves the Brazilian audience, and brains can be built in Portuguese with Portuguese names.
- **Obsidian:** optional. The recommended default is a plain Markdown folder, because the AI reads the files straight from disk.
- **Simplicity:** four modes with short, fixed steps. No emojis in the README or in anything the skill writes.

## Plan

- [x] **Phase 1 — `context-keeper` plugin:** manifests, hooks inside the plugin, `~/.context-keeper/config` pointer, commands.
- [x] **Phase 2 — Optional Obsidian:** interview question, explanation, regular Markdown links by default, checker validates both link styles.
- [x] **Phase 3 — English and simplification:** skill in English with 4 modes and 6 references, templates in `pt-BR/` and `en/`, hook messages in the brain's language, READMEs in English and Portuguese.
- [ ] **Phase 4 — Real tests:**
  - load the plugin in a real session (`claude --plugin-dir .`);
  - adopt a hand-made brain end to end (persona `leo-adota`);
  - run the scenarios in `tests/skill-evals.json` with and without the skill, against the fictional personas from `tests/make-personas.sh` (each test only sees its persona's simulated home);
  - [x] tune the checkpoint trigger with real transcripts: bytes were a poor proxy (a 16x byte growth for a 2x context growth), so the trigger now measures context tokens from the transcript's `usage` (default: 50,000 tokens of growth, `CONTEXT_KEEPER_CHECKPOINT_TOKENS`).
- [ ] **Phase 5 — Release:** GitHub description and topics, tag `v0.2.0`, clean install from the marketplace, optional submission to Anthropic's community marketplace.

## Later (0.3+)

- `UserPromptSubmit` hook that loads a subject's index note when the prompt mentions a known project.
- `SessionEnd` hook that logs sessions that ended without a checkpoint.
- PowerShell versions of the scripts, for machines without bash.
- Scheduled maintenance reminder (monthly) using the tool's scheduled tasks.
- MCP server for the brain (`search`, `read_state`, `record_decision`, `checkpoint`), so any MCP-capable AI can use it with the same rules.
- Tested guides for Cursor, Codex, Gemini CLI and Claude Desktop.
- Dedicated importers: ChatGPT export (`conversations.json`), Notion.
- Local semantic search for large brains.
