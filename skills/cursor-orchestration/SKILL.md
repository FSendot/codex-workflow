---
name: cursor-orchestration
description: Coordinates multi-stage coding work with Composer exploration, Grok implementation and scoped review, Codex verification, and final Fable review while keeping the parent context focused. Use when the user asks to orchestrate or delegate, or when a task has multiple bounded workstreams, requires staged implementation and correction loops, or is broad enough to risk overloading one context.
---

# Cursor Orchestration

## Intent

Use the parent agent's judgment to choose useful delegation boundaries. Keep material implementation and correction work delegated after that lane is opened; use the parent context for planning, prompts, inspection, integration checks, and final synthesis. Define each delegation from its task and ownership.

## Model routing

- Use Cursor model `composer-2.5-fast` for codebase exploration and research.
- Use Cursor model `grok-4.5-fast-xhigh` for implementation and material correction passes.
- Use a Codex subagent (not Cursor with a GPT model) for the first review gate.
- Use Cursor model `grok-4.5-fast-xhigh` for the scoped intermediate review gate.
- Use Cursor model `claude-fable-5-thinking-high` for the final review gate.
- Invoke `cursor-agent` directly as Cursor CLI.
- If a required model or Codex subagent is unavailable, stop and report the blocker rather than silently substituting another model.

## Workflow

1. Read the task, applicable instructions, and current diff; plan the smallest useful delegation boundaries.
2. Delegate bounded exploration to Composer to reduce context load, and delegate material implementation to Grok.
3. Include workspace, task, exact ownership, constraints, expected output, verification, blockers, and risks in every prompt.
4. Launch a 5.6 Terra subagent model to inspect every result: read changed files, review the diff, confirm ownership boundaries, and run focused verification.
5. If the subagent reports misses a material requirement from the delegated work, send Grok a tighter correction prompt with the evidence, exact files, and expected checks.
6. Continue until implementation and verification are complete, then run the review pipeline.

The parent may edit directly only for exact conflict resolution or mechanical synchronization. Any edit that requires product, design, test, migration, config-semantic, or user-facing documentation judgment is material and must go to Grok. Any code changed by GPT-5.6, including those integration edits, remains part of every applicable review scope.

## Delegation discipline

- Give writable agents exact path ownership and prohibit unrelated rewrites or reversions.
- Use read-only delegation for discovery and review; use scoped writable delegation for implementation and corrections.
- Do not launch agents with vague repository-wide tasks or for tiny work that does not reduce risk or context load.
- Only the parent task starts and reruns Codex, Grok, and Fable review gates. No delegated task may launch nested Codex, Composer, or Fable reviews.
- After interruption or context compaction, inspect the diff and last result before choosing the next bounded task.

## Review pipeline

Run each gate only after the previous gate is green:

1. **Codex:** Run one focused Codex subagent (5.6 Sol xHigh) review. For material findings, delegate corrections to Grok, verify, and rerun Codex until green.
2. **Grok:** Run multiple very scoped `grok-4.5-fast-xhigh` reviews split by file, behavior surface, or risk axis. For material findings, delegate corrections to Grok, verify, and rerun the affected Grok reviews until all are green.
3. **Fable:** Run one `claude-fable-5-thinking-high` review of the complete final diff for the task, focused on the changed surface. Require both correctness and code-quality findings: maintainability, clarity, unnecessary complexity, duplication, architecture fit, tests, and consistency with local patterns. Fable must evaluate all changed code regardless of author. For material findings, delegate corrections to Grok, verify, and rerun Fable until green. If a Fable correction changes a risk surface already reviewed by Codex or Composer, rerun the affected earlier gate before Fable.

For every review:

- Provide the task brief, focused diff or files, constraints, and verification already run.
- Ask for findings first: bugs, regressions, missing tests, data loss, API drift, concurrency, safety, and relevant code-quality risks.
- Inspect each finding; for material fixes, delegate to Grok through the active correction loop, or reject with evidence.
- Keep Grok reviews narrow. Keep Fable focused on the changed surface of the complete final diff, but do not omit GPT-5.6-authored lines.
- Fable is expensive and slow. Wait or poll patiently instead of assuming it is stuck.

## Completion

Finish only after changes are integrated, verification ran or is explicitly blocked, every review gate is green or consciously accepted, the diff is scope-clean, and the final response names verification, blockers, and residual risks. Do not commit unless asked.
