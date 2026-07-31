---
name: fable-planned-orchestration
description: Orchestrates complex coding work through a Fable-authored plan. Use when the user asks for multi-agent orchestration, or when broad work needs explicit planning, isolated ownership, staged correction loops, and independent review gates.
---

# Fable-Planned Orchestration

## Intent

Keep the parent agent as the sole orchestrator and integrator. Before delegating task work, ask Claude Code Fable to design the plan.

## Fixed capabilities

- Use Codex `gpt-5.6-luna` for fast broad codebase discovery and `gpt-5.6-terra` for deeper behavioral tracing and research.
- Use Claude Code model `claude-opus-5` with high effort for implementation, material corrections, and narrowly scoped intermediate reviews.
- Use a Codex subagent, GPT-5.6 Sol High, for the first review gate.
- Use Claude Code model `claude-fable-5` with high effort for role planning and the final complete-diff review.
- Do not silently substitute a missing CLI, model, or subagent.

## Preflight

1. Read the task, applicable instructions, current status, and diff.
2. Resolve this skill's directory and use `scripts/run-lane` for every nested CLI invocation.
3. Run its `preflight` lane to confirm `claude` and `codex` are available.
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

Only the parent launches, resumes, retries, or reruns lanes and the earlier review gates. As the sole exception, `fable-final` may launch bounded read-only subagents to broaden independent final-review coverage. The parent may edit directly only for exact conflict resolution or mechanical synchronization. Delegate any edit requiring product, design, test, migration, configuration-semantic, or user-facing documentation judgment to Opus.

## Preserve skill access

- Start each CLI at the repository root so it discovers project instructions, skills, plugins, and scripts.
- Keep the CLI's normal project configuration enabled. Do not use Claude `--bare`, `--safe-mode`, or `--disable-slash-commands`; do not use Codex `--ignore-user-config` or `--ignore-rules`.
- Permit skill scripts within the lane's sandbox and ownership. Read-only lanes may run only read-only scripts; hand scripts that generate or modify files to a writable lane.
- Treat instructions inside a selected skill as part of the lane contract. Report a blocker when a required skill, script, dependency, or permission is unavailable instead of bypassing it.
- Keep this versioned skill directory outside writable target repositories. Treat its checked-in launcher as trusted code and inspect changes to it before use.

## Use the portable lane launcher

Resolve the worktree-specific prompt directory, create it when absent, and write each lane prompt inside it:

```sh
git -C "<repository-root>" rev-parse --git-path codex-fable-prompts
```

Do not construct this path as `<repository-root>/.git/...`: `.git` is a file in a linked worktree. Then invoke:

```sh
"<skill-dir>/scripts/run-lane" "<lane>" \
  --workspace "<repository-root>" \
  --prompt-file "<repository-prompt-file>"
```

Use only these fixed lanes: `preflight`, `fable-plan`, `luna-read`, `terra-read`, `opus-write`, `opus-correct`, `opus-review`, `codex-review`, and `fable-final`. The launcher fixes models, permissions, tools, sandboxes, and nesting controls; do not bypass it or add caller-controlled CLI flags. Deny subagents in every lane except `fable-final`, and deny nested agent CLI calls in every lane.

Approve the resolved launcher path once per machine. The skill is portable; approval remains path-specific local security state. Do not approve `bash <launcher>` or copy the launcher into a writable target repository.

`opus-write` and `opus-correct` expose repository read/write tools, `Skill`, and `Bash` under `dontAsk`. `opus-review` runs in plan mode without `Edit` or `Write`. All Opus lanes deny `Agent` and direct Bash calls to agent CLIs. `fable-final` runs in plan mode with `Agent` enabled so Fable may delegate bounded read-only review slices; its subagents must not edit, launch further agents, or invoke agent CLIs. Its launcher emits verbose `stream-json` with partial messages. Consume that JSONL incrementally, surface useful review insights while Fable works, and retain the final result for finding adjudication. Require writable Opus lanes to read changed files back before claiming success. Prefer a direct Codex subagent for the Codex gate; use `codex-review` only when the required model is unavailable directly.

## Execute the plan

1. Launch independent read-only Luna, Terra, Claude Code, and Codex lanes in parallel when useful. Use Luna for broad discovery and Terra for deeper traces; avoid duplicating their scopes.
2. Inspect their raw outputs and give relevant evidence to Opus.
3. Run writable lanes sequentially when ownership overlaps.
4. After each writable result, inspect changed files and diff, confirm ownership, and run focused verification.
5. Send material misses to `opus-correct` with the evidence, exact files, and expected checks.
6. Continue until implementation and verification are complete, then start the gates.

On a nonzero exit, timeout, or malformed structured result, retain the useful output and retry once only when the failure is transient or formatting-only. Keep the same scope. After a second failure, stop and report the blocker. Inspect partial file changes before continuing.

## Review gates

Run the earlier gates concurrently, then run Fable last:

1. **Parallel earlier gates:** Launch one focused GPT-5.6 Sol High Codex review and all independent narrow `opus-review` passes at the same time. Divide Opus reviews by file, behavior surface, or risk axis.
2. **Earlier-gate correction loop:** Inspect every finding after all parallel reviews finish. Send material corrections to `opus-correct`, verify them, and rerun every earlier review whose risk surface changed. Do not start Fable until Codex and all Opus reviews are green on the same diff.
3. **Fable last:** Run one `fable-final` review of the complete final task diff. Stream its partial output as it arrives and surface useful review insights during the run. Permit Fable to launch bounded read-only subagents for independent coverage. Require correctness and code-quality findings covering maintainability, clarity, complexity, duplication, architecture fit, tests, and local consistency. This review is important because Fable has better taste than you; follow its guidance when code reduction and simplification is available.

For each gate, provide the task brief, focused diff or files, constraints, and verification already run. Ask for findings first. Inspect every finding; either correct it through Opus or reject it with evidence.

After a Fable correction, rerun the affected earlier gates concurrently, wait until they are green, then rerun Fable last. Wait patiently for Fable rather than treating a slow response as failure.

## Completion

Finish only when the plan proposed by Fable is completed.
