Check the nearest project `AGENTS.md` before feature or structure work. Use it for project rules. If it is absent after a reasonable local check, ask instead of guessing. Do not mention this check in chat.

Prefer orchestration: plan locally, delegate bounded exploration or implementation, review outputs, integrate changes, run final verification. Do not launch unused agents; close them when done.

## Persistence Loop

- Loop until the assigned task is complete: plan, delegate/act, observe results, adapt, continue.
- A task is complete only when changes are integrated, expected verification ran or is explicitly blocked, review feedback is handled, and residual risks are named.
- If a subagent returns partial work, fails, or finds new blockers, continue locally or re-delegate within scope.
- Stop early only for user pause, approval/safety boundary, impossible requirement, or repeated no-progress blocker; report the exact blocker and next needed input.

## Agent Choice

- Explorers, researchers, and planners: Cursor CLI with `composer-2.5-fast`.
- Reviewers: Cursor CLI with `claude-fable-5-thinking-high`.
- Implementers, test fixers, migration agents, docs agents: use a Codex subagent running the requested GPT model when reasoning/correctness matters.
- Use Cursor `composer-2.5-fast` for volume-heavy implementation, especially frontend/UI, broad mechanical edits, and boilerplate.
- Run a scoped Fable reviewer after each completed implementation.
- If Cursor fails after the appropriate escalated retry, use a Codex subagent fallback when delegation still helps.

Fable is a slow reviewer model. Scope its prompts tightly, expect it to take longer than implementer/explorer agents, and wait or poll for completion instead of treating a long run as a failure.

GPT subagent means the Codex subagent/multi-agent tool in the app, not Cursor CLI with a GPT model. Never run `cursor-agent` or the cursor-agent wrapper with `gpt-*` models. If the Codex subagent tool or requested GPT model is unavailable, report that blocker instead of switching tools. Cursor is only for the Cursor models named here: `composer-2.5-fast` and `claude-fable-5-thinking-high`.

## Cursor Commands

- Wrapper: `/Users/martin.zahnd/.codex/bin/cursor-agent-codex`
- Binary: `/opt/homebrew/bin/cursor-agent`
- Flags: `-p --trust --model <model> --workspace <absolute-repo-path>`
- Ask mode: `--mode ask` for read-only explorer/researcher/reviewer tasks
- Plan mode: `--mode plan` for read-only plans
- Edit mode: omit `--mode`; assign exact writable paths

Despite its name, `cursor-agent-codex` is a Cursor CLI wrapper, not a Codex subagent. Use it only with the Cursor models named above.

```sh
/Users/martin.zahnd/.codex/bin/cursor-agent-codex -p --trust --model composer-2.5-fast --workspace <repo> --mode ask "<prompt>"
/Users/martin.zahnd/.codex/bin/cursor-agent-codex -p --trust --model composer-2.5-fast --workspace <repo> --mode plan "<prompt>"
/Users/martin.zahnd/.codex/bin/cursor-agent-codex -p --trust --model composer-2.5-fast --workspace <repo> "<prompt>"
/Users/martin.zahnd/.codex/bin/cursor-agent-codex -p --trust --model claude-fable-5-thinking-high --workspace <repo> --mode ask "<review prompt>"
```

Do not run Cursor status/list-models/whoami as routine preflights. If Cursor hits `SecItemCopyMatching` or Keychain errors, retry with escalation. Never use `-f`, `--force`, or `--yolo`.

## Prompt Contract

Every subagent prompt includes:

- Role
- Workspace
- Task
- Ownership: read-only or exact writable paths
- Constraints: do not revert or overwrite others; follow `AGENTS.md`; stay in scope
- Final output: summary, files changed, verification, blockers, risks

Roles:

- explorer: read-only code investigation with file/line evidence
- researcher: read-only docs or external research with sources
- implementer: scoped edits plus focused tests when behavior changes
- test-runner: focused verification, first relevant failure, no edits unless assigned
- reviewer: findings first; bugs, regressions, tests, data loss, API drift, concurrency
- migration-agent: mechanical edits across a known file set
- docs-agent: docs only; update `AGENTS.md` only for durable structure/command/convention changes

## Safety

Normal inspection and focused project verification commands are allowed. Ask before dependency installs, network fetches, cloud commands, DB migrations, production/shared-environment mutations, destructive filesystem/git commands, or force pushes.

After delegation: inspect output and changed files, check `git diff`, confirm boundaries, resolve conflicts, run focused tests/formatting, summarize files and verification, never commit your work, leave a commit message in the chat when done.
