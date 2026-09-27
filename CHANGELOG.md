# Changelog

All notable changes to this project are documented here. Dates use `YYYY-MM-DD`.

## [0.2.0] — 2026-09-25

First public release.

### Added
- **Claude Code plugin** with its own marketplace: install with `/plugin marketplace add MenesesLuiz/Context-Keeper` and `/plugin install context-keeper@context-keeper`.
- **Hooks shipped with the plugin**, inactive until a brain exists:
  - `SessionStart` loads the now file and the latest journal entry at session start and right after every compaction;
  - `Stop` asks for a checkpoint when the context has grown by 50,000 tokens since the last one (`CONTEXT_KEEPER_CHECKPOINT_TOKENS`), measured from the transcript's real token usage.
- **Commands** `/context-keeper:checkpoint` and `/context-keeper:review`.
- **Brain pointer** `~/.context-keeper/config`, so hooks and the checker find the brain without editing `settings.json`.
- **Templates in English and Portuguese** (`BRAIN.md`/`NOW.md`/`Journal/` and `CEREBRO.md`/`AGORA.md`/`Diario/`), including an about-me note and a projects map. Hook messages follow the brain's language.
- **Project organization advice:** the skill recommends keeping each complete project in its own folder under `Projects/`, with its context notes, and shows the exact moves. It never moves the user's files itself.
- **Root `CLAUDE.md`** that imports the brain's rules, so Claude Code loads them in any folder inside the brain.
- **Test personas** (`tests/make-personas.sh`): fictional users with simulated home folders, used to test the skill without touching real data.

### Changed
- The skill is now in English, with 4 modes (Setup, Checkpoint, Import, Review) and 6 references. The interview still runs in the user's language.
- Obsidian is optional. A plain folder is the recommended default, and regular Markdown links with relative paths replace `[[wikilinks]]` as the default link style.
- Detection only looks in the user's home folder and in paths the user mentions.
- An Obsidian vault is treated as material to import into a lean brain; adopting it in place is only offered for small, well-organized vaults.
- The interview goes straight to at most 4 questions per round; the automation level is chosen inside the plan.

### Fixed
- `brain-lint.sh` no longer writes temporary files outside the brain. Before, a missing temp folder made the broken-link check skip silently.
- `brain-lint.sh` ignores project code kept inside the brain (nested git repositories, `node_modules`, build folders) and checks secrets only in Markdown notes.

## [0.1.0] — 2026-09-25

Initial draft of the skill, in Portuguese, as a standalone skill folder.
