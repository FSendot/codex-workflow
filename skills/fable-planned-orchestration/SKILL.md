---
name: fable-planned-orchestration
description: Orchestrates complex coding work through a Fable-authored plan. Use when the user asks for multi-agent orchestration, or when broad work needs explicit planning, isolated ownership, staged correction loops, and independent review gates.
---

# Fable-Planned Orchestration

## Intent

Keep the parent agent as the sole orchestrator and integrator. Before delegating task work, ask Cursor Fable to design the plan.

## Fixed capabilities

- Use `composer-2.5-fast` and  `cursor-grok-4.5-high-fast` for codebase exploration and research.
- Use Claude Code model `claude-opus-5` with high effort for implementation, material corrections, and narrowly scoped intermediate reviews.
- Use a Codex subagent, GPT-5.6 Sol High, for the first review gate.
- Use Claude Code model `claude-fable-5` with high effort for role planning and the final complete-diff review.
- Do not silently substitute a missing CLI, model, or subagent.

## Preflight

1. Read the task, applicable instructions, current status, and diff.
2. Resolve this skill's directory and use `scripts/run-lane` for every nested CLI invocation.
3. Run its `preflight` lane to confirm `cursor-agent`, `claude`, and `codex` are available.
4. Inspect `claude --help` only when changing the checked-in launcher. Use only flags supported by the installed version.
5. Establish the user-approved mutation boundary before launching writable lanes.

## Ask Fable to plan the orchestration

Run one read-only Fable pass before exploration or implementation. Give it:

- task brief and acceptance criteria;
- applicable instructions and initial diff/status;
- mutation and path constraints;
- available models and CLIs;
- required verification and review gates.

Validate the plan before execution. Remove overlapping write ownership, make dependencies explicit, keep reviews read-only, and reject any plan that changes fixed roles or gates. Record material deviations and revalidate the affected lanes.

## Delegate without nesting

Give every lane the workspace, task, exact ownership, constraints, expected output, verification, blockers, and risks. Writable agents must have exact path ownership and must not rewrite or revert unrelated work.

Only the parent launches, resumes, retries, or reruns agents and review gates. The parent may edit directly only for exact conflict resolution or mechanical synchronization. Delegate any edit requiring product, design, test, migration, configuration-semantic, or user-facing documentation judgment to Opus.

## Preserve skill access

- Start each CLI at the repository root so it discovers project instructions, skills, plugins, and scripts.
- Keep the CLI's normal project configuration enabled. Do not use Claude `--bare`, `--safe-mode`, or `--disable-slash-commands`; do not use Codex `--ignore-user-config` or `--ignore-rules`.
- Permit skill scripts within the lane's sandbox and ownership. Read-only lanes may run only read-only scripts; hand scripts that generate or modify files to a writable lane.
- Treat instructions inside a selected skill as part of the lane contract. Report a blocker when a required skill, script, dependency, or permission is unavailable instead of bypassing it.
- Keep this versioned skill directory outside writable target repositories. Treat its checked-in launcher as trusted code and inspect changes to it before use.

## Use the portable lane launcher

Write each lane prompt under `<repository-root>/.git/codex-fable-prompts/`, then invoke:

```sh
"<skill-dir>/scripts/run-lane" "<lane>" \
  --workspace "<repository-root>" \
  --prompt-file "<repository-prompt-file>"
```

Use only these fixed lanes: `preflight`, `fable-plan`, `composer-read`, `grok-read`, `opus-write`, `opus-correct`, `opus-review`, `codex-review`, and `fable-final`. The launcher fixes models, permissions, tools, sandboxes, and no-nesting controls; do not bypass it or add caller-controlled CLI flags. Every prompt must tell the CLI not to launch subagents or other agent CLIs.

Approve the resolved launcher path once per machine. The skill is portable; approval remains path-specific local security state. Do not approve `bash <launcher>` or copy the launcher into a writable target repository.

Opus lanes expose repository read/write tools, `Skill`, and `Bash` under `dontAsk`, while denying `Agent` and direct Bash calls to agent CLIs. Require Opus to read changed files back before claiming success. Prefer a direct Codex subagent for the Codex gate; use `codex-review` only when the required model is unavailable directly.

## Execute the plan

1. Launch independent read-only Composer, Claude Code, and Codex lanes in parallel when useful.
2. Inspect their raw outputs and give relevant evidence to Opus.
3. Run writable lanes sequentially when ownership overlaps.
4. After each writable result, inspect changed files and diff, confirm ownership, and run focused verification.
5. Send material misses to `opus-correct` with the evidence, exact files, and expected checks.
6. Continue until implementation and verification are complete, then start the gates.

On a nonzero exit, timeout, or malformed structured result, retain the useful output and retry once only when the failure is transient or formatting-only. Keep the same scope. After a second failure, stop and report the blocker. Inspect partial file changes before continuing.

## Review gates

Run each gate only after the previous gate is green:

1. **Codex:** Run one focused GPT-5.6 Sol High review. Send material corrections to Opus, verify, and rerun Codex until green.
2. **Opus:** Run multiple narrow `opus-review` passes divided by file, behavior surface, or risk axis. Send material corrections to `opus-correct`, verify, and rerun affected reviews until green.
3. **Fable:** Run one Claude Code `fable` review of the complete final task diff. Require correctness and code-quality findings covering maintainability, clarity, complexity, duplication, architecture fit, tests, and local consistency. This review is important because Fable has better taste than you, follow its guidelines when code reduction and simplification is available.

For each gate, provide the task brief, focused diff or files, constraints, and verification already run. Ask for findings first. Inspect every finding; either correct it through Opus or reject it with evidence.

After a Fable correction, rerun every earlier gate whose risk surface changed, then rerun Fable. Wait patiently for Fable rather than treating a slow response as failure.

## Completion

Finish only when the plan proposed by Fable is completed.
