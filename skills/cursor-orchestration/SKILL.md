---
name: cursor-orchestration
description: Keeps coding work in a coordinator workflow using cursor-agent delegation, scoped implementers, Codex follow-up agents, and Fable reviews. Use when the user asks to orchestrate or delegate code work, mentions cursor-agent, Fable, subagents, context-window bloat, or wants stronger adherence to the AGENTS.md delegation workflow.
---

# Cursor Orchestration

## Purpose

Keep the main agent in the coordinator role for nontrivial coding work: plan, delegate bounded tasks, review outputs, integrate, verify, and report residual risk.

This skill does not define command syntax. Use the active `AGENTS.md` for exact cursor-agent commands, model choices, safety boundaries, and project rules. If those instructions are missing or unclear, ask instead of inventing them.

## Default workflow

1. Read the nearest applicable `AGENTS.md` and project-local instructions before feature, structure, or workflow changes.
2. Plan locally and identify the smallest useful delegation boundary.
3. Delegate bounded exploration, implementation, test repair, migration, docs, or review work when it prevents main-context bloat.
4. Keep prompts explicit: role, workspace, task, ownership, constraints, expected output, verification, blockers, and risks.
5. Inspect every subagent result before trusting it: read changed files, review diffs, check boundaries, and run focused verification.
6. Continue the loop until the task is complete or blocked by a real user, safety, or environment boundary.

## Delegation rules

- Use explorer or researcher agents for broad read-only discovery.
- Use implementer, migration, docs, or test-runner agents for scoped writable work.
- Give writable agents exact path ownership and tell them not to revert or overwrite unrelated changes.
- Avoid launching agents with vague ownership or prompts that require them to rediscover the whole repository.
- Do not launch new subagents for tiny tasks where delegation adds process without reducing risk or context load.

## Missed work

When a delegated implementer misses something material:

1. Do not quietly finish the missed implementation in the main context.
2. Write a tighter follow-up prompt with the missed requirement, evidence, exact files, and expected verification.
3. Delegate the correction to a Codex implementer subagent.
4. Verify the follow-up output yourself with a diff review and focused tests.

The main agent may still make minimal coordination edits, conflict resolutions, or documentation tweaks when they are clearly smaller than a new delegation and do not require broad code reasoning.

## Reviews

Run a Fable reviewer after implementation work that changes behavior, structure, tests, migrations, or docs with durable project policy.

Prefer scoped reviews because Fable is expensive:

- Review the changed files or focused diff, not the entire repository.
- Ask for findings first: bugs, regressions, missing tests, data loss, API drift, concurrency, and safety risks.
- Provide the task brief, relevant constraints, and verification already run.
- Treat the review as input, not authority; inspect findings and either fix, delegate fixes, or explicitly reject with evidence.

## Completion

A task is not complete until:

- Changes are integrated.
- Relevant verification ran, or the blocker is explicit.
- Review findings are handled or consciously accepted.
- The working-tree diff was checked for unrelated edits.
- The final response names changed files, verification, blockers, residual risks, and does not commit unless the user asked.
