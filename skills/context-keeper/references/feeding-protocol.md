# Feeding protocol

This is the heart of the second brain: the rules that make the AI record valuable information without the user asking. A short version of this protocol goes **inside the brain's root file** (see the root template in `assets/templates/<language>/`), adapted to the autonomy level the user chose.

## What is worth keeping

The filter question: **"If I open a new session a month from now, without this conversation, would this help me act better?"**

Worth keeping:
- **Decisions and their reasons**, including the discarded options. The reason is what gets lost most and what saves the most rework.
- **The state of each piece of work**: what was done, what is left, where it stopped, what is blocked.
- **Discoveries**: something that took effort to find out (the cause of a strange bug, an API limit, a research finding with its source).
- **The user's preferences and corrections**: "don't use X", "I prefer short answers", "always run the tests first".
- **Stable context**: who is who, deadlines, constraints.
- **Loose ideas** the user mentioned in passing (they go to the Inbox).

Not worth keeping:
- What is already in the code, the README or git (the *how*).
- Transcripts or long summaries of the conversation: keep the conclusion, not the path.
- Information that loses its value within hours.
- **Secrets** of any kind.

## Triggers: when to write

| Trigger | Where to record |
|---|---|
| A decision was made | `<subject>/Decisions/YYYY-MM-DD-title.md` + one line in "Latest decisions" of the now file |
| A task or stage finished or changed status | "Current state" of the subject's index note |
| The user corrected the AI or stated a preference | The preferences note |
| The user said "note this", "remember this" | The right note if obvious, otherwise the Inbox |
| Research produced conclusions | A research note in the subject (or in `Research/` if it serves several) |
| A new subject came up | Inbox + propose a new folder to the user |
| A new project appeared, or a project's files were found outside the brain | A line in the projects map, "Where things are" in its index note, and a one-line suggestion to move it under `Projects/` (the user moves it, never you) |
| A project changed status, started or finished | Its line in the projects map |
| End of session, long context, or the hook asked | Full **checkpoint** (below) |

## Write autonomy

The user picked one of these in the interview; write only the chosen one into the root file:
- **Ask first:** "May I record decision X in `Y`?" — and write only after a yes.
- **Write and tell (default):** write, then say in one plain-text line at the end of the answer: `Saved: decision X in Projects/Y/Decisions/...` (pt-BR: `Registrado: ...`).
- **Silent:** write without telling; list everything only at the checkpoint.

## Checkpoint

The checkpoint consolidates the session into the brain. It is what saves context before a compaction or the end of the conversation.

1. Read the root file and the now file (if they are not in context).
2. Review the conversation since the last checkpoint and list: decisions, state changes, new or resolved open items, discoveries, preferences.
3. Update, in this order:
   1. decision notes (new ones, or with a changed status);
   2. the "Current state" of each subject touched — rewrite the section, do not pile up history in it (history goes to the journal);
   3. the now file — focus, open items and latest decisions; keep it short by removing what went stale;
   4. the preferences note, if there is something new;
   5. the journal (`<journal folder>/YYYY-MM-DD.md`) — append a 3–8 line entry: subject, what was done, decisions (with links), next step.
4. Update the `updated:` field (pt-BR: `atualizado:`) in the frontmatter of the notes touched.
5. Tell the user in 2–4 lines what was recorded.

If nothing relevant happened since the last checkpoint, do not create empty entries — just say there is nothing to record.

## "Current state" format

Keep this shape, so any AI can read it quickly (translated in pt-BR brains: "Estado atual", "Fase", "Feito recentemente", "Próximo passo", "Bloqueios / dúvidas em aberto"):

```markdown
## Current state
*Updated YYYY-MM-DD*

- **Phase:** <idea | planning | in progress | paused | done>
- **Recently done:** <1–3 items>
- **Next step:** <the next concrete action>
- **Blockers / open questions:** <items or "none">
```
