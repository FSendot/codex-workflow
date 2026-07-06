---
name: cursor-orchestration
description: Keeps coding work in a coordinator workflow using cursor-agent delegation, scoped Codex follow-up work, and staged Codex/Composer/Fable reviews. Use when the user asks to orchestrate or delegate code work, mentions cursor-agent, Fable, Composer, subagents, context-window bloat, or wants stronger adherence to the AGENTS.md delegation workflow.
---

# Cursor Orchestration

## Purpose

Keep the main agent in the coordinator role for nontrivial coding work: plan, delegate bounded tasks, review outputs, integrate, verify, and report residual risk. Once implementation is delegated, the main agent stays out of the implementation lane.

This skill does not define command syntax. Use the active `AGENTS.md` for exact cursor-agent commands, model choices, safety boundaries, and project rules. If those instructions are missing or unclear, ask instead of inventing them.

## Default workflow

1. Read the nearest applicable `AGENTS.md` and project-local instructions before feature, structure, or workflow changes.
2. Plan locally and identify the smallest useful delegation boundary.
3. Delegate bounded exploration, implementation, test repair, migration, docs, or review work when it prevents main-context bloat.
4. Keep prompts explicit: workspace, task, ownership, constraints, expected output, verification, blockers, and risks.
5. Inspect every subagent result before trusting it: read changed files, review diffs, check boundaries, and run focused verification.
6. If more code, docs, tests, migrations, or config edits remain, delegate the next bounded slice instead of picking up the implementation directly.
7. Continue the loop until the task is complete or blocked by a real user, safety, or environment boundary.

## Loop guard

After every observe, verification, review, interruption, or context-compaction checkpoint, re-establish the coordinator state before acting:

1. Check the current diff and the last completed delegation.
2. Name the remaining work as one or more bounded tasks.
3. Delegate remaining implementation work to the appropriate subagent.
4. Keep the main context focused on prompts, review, integration checks, and final synthesis.

Do not continue with direct "I'm adding", "I'm updating", or "I'm fixing" implementation steps after a delegated loop has finished. If the next step would edit product code, tests, migrations, config, or user-facing docs, make it a follow-up delegation unless it is explicitly a tiny coordination edit.

Tiny coordination edits are limited to conflict markers, exact mechanical syncs, prompt/doc wording, or copying an already-reviewed artifact. When in doubt, delegate.

## Delegation rules

- Use read-only delegation for broad discovery, planning, research, or review work.
- Use scoped writable delegation for implementation, test repair, migrations, docs, or mechanical edits.
- Give writable agents exact path ownership and tell them not to revert or overwrite unrelated changes.
- Avoid launching agents with vague ownership or prompts that require them to rediscover the whole repository.
- Do not launch new subagents for tiny tasks where delegation adds process without reducing risk or context load.

## Model boundary

- Cursor-agent is only for the Cursor models allowed by the active `AGENTS.md`.
- The `cursor-agent-codex` wrapper is still Cursor CLI, not a Codex subagent.
- GPT-backed delegated work for implementation, test repair, migration, or docs means a Codex subagent, not cursor-agent with a `gpt-*` model.
- Never run cursor-agent or its wrapper with `gpt-*` models. If no Codex subagent is available for GPT work, report that blocker instead of switching tools.

## Missed work

When delegated implementation work misses something material:

1. Do not quietly finish the missed implementation in the main context.
2. Write a tighter follow-up prompt with the missed requirement, evidence, exact files, and expected verification.
3. Delegate the correction to a Codex subagent.
4. Verify the follow-up output yourself with a diff review and focused tests.

The main agent may still make only tiny coordination edits when they are clearly smaller than a new delegation and do not require broad code reasoning. Do not use this exception for user-facing docs, config, tests, migrations, or product code.

## Reviews

Run staged reviews after each completed implementation.

The review pipeline is coordinator-owned. Delegated agents do not launch Codex, Composer, or Fable reviewers unless their prompt explicitly assigns review-gate work. Agents doing implementation, test repair, migration, or docs work report changes, verification, blockers, and risks; the parent coordinator runs review gates after integrating their output.

1. Codex reviewer first: run one Codex subagent review. If it finds material issues, delegate corrections, verify, and rerun Codex until green.
2. Composer reviewers second: run multiple very scoped `composer-2.5-fast` reviewers, split by file, behavior surface, or risk axis. If any find material issues, delegate corrections, verify, and rerun the relevant Composer review set until all are green.
3. Fable reviewer last: run one scoped `claude-fable-5-thinking-high` review only after Codex and Composer are green. If it finds material issues, delegate corrections, verify, and rerun Fable until green.

Review prompts stay narrow:

- Review the changed files or focused diff, not the entire repository.
- Ask for findings first: bugs, regressions, missing tests, data loss, API drift, concurrency, and safety risks.
- Provide the task brief, relevant constraints, and verification already run.
- Treat each review as input, not authority; inspect findings and either fix, delegate fixes, or explicitly reject with evidence.
- Fable is expensive and slow; wait or poll instead of assuming the final review is stuck.

## Completion

A task is not complete until:

- Changes are integrated.
- Relevant verification ran, or the blocker is explicit.
- Review findings are handled or consciously accepted.
- The working-tree diff was checked for unrelated edits.
- The final response names changed files, verification, blockers, residual risks, and does not commit unless the user asked.
