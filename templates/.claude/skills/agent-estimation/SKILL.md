---
name: agent-estimation
description: Accurately estimate AI agent work effort using the agent's own operational units (tool-call rounds) instead of human time. Use when asked to estimate, scope, plan, or evaluate how long a coding task will take. Covers greenfield and brownfield work — including rounds spent reading and understanding existing code — plus tests, review, and documentation. Prevents the common failure mode where agents anchor to human developer timelines and massively overestimate, and the opposite failure where they stop the estimate at "the code compiles". Outputs a structured breakdown with round counts, risk factors, and a final wallclock conversion.
---

# Agent Work Estimation Skill

> Fork of [ZhangHanDong/agent-estimation](https://github.com/ZhangHanDong/agent-estimation),
> extended with **Step 3 (comprehension)** and **Step 4 (quality: test / review / docs)**.

## Problem

AI coding agents systematically overestimate task duration because they anchor to human developer timelines absorbed from training data. A task an agent can complete in 30 minutes gets estimated as "2-3 days" because that's what a human developer forum post would say.

The mirror-image failure is just as common: the agent estimates only up to "the code runs", ignoring that it first had to *find* the code, and still has to test, fix review findings, and document it.

## Solution

Force the agent to estimate from its own operational units — **tool-call rounds** — and only convert to human wallclock time at the very end. Count every round the agent will actually spend: understanding, building, proving, and handing off.

## Core Units

| Unit | Definition | Scale |
|------|-----------|-------|
| **Round** | One tool-call cycle: think → act → observe → decide | ~2-4 min wallclock |
| **Module** | A functional unit built from multiple rounds until usable | 2-15 rounds |
| **Wave** | A batch of modules with no mutual dependencies, executable in parallel | 1-N modules |
| **Project** | All waves sequentially + integration + debugging | Sum of waves |

A **Round** is the atomic unit. It maps directly to one iteration of:
1. Agent reasons about what to do
2. Agent acts — reads code, writes code, or runs a command
3. Agent reads the output
4. Agent decides if it needs another pass (if yes → next round)

Note the generalisation: a round spent `grep`-ing to locate a call site costs the same as a round spent writing a function. Both are one think-act-observe cycle. This is why comprehension is counted in rounds, not hand-waved.

## Estimation Procedure

When asked to estimate a task, follow these steps in order.

### Step 1: Decompose into Modules

Break the task into functional modules. Each module should be independently buildable and testable. Ask yourself: "What are the distinct pieces I would build one at a time?"

### Step 2: Estimate Implementation Rounds per Module

For each module, estimate the rounds needed to make the code work, using these anchors:

| Pattern | Typical Rounds | Examples |
|---------|---------------|----------|
| **Boilerplate / known pattern** | 1-2 | CRUD endpoint, config file, standard API client |
| **Moderate complexity** | 3-5 | Custom UI layout, state management, data pipeline |
| **Exploratory / under-documented** | 5-10 | Unfamiliar framework, platform-specific APIs, complex integrations |
| **High uncertainty** | 8-15 | Undocumented behavior, novel algorithms, multi-system debugging |

Key calibration rules:
- If you can generate the code in one shot and it will likely run → **1 round**
- If you'll need to generate, run, see an error, and fix → **2-3 rounds**
- If the library/framework has sparse docs and you'll be guessing → **5+ rounds**
- If it involves platform permissions, OS-level APIs, or environment-specific behavior the user must manually verify → add **2-3 rounds**

This step measures uncertainty about **the technology**. Step 3 measures uncertainty about **this codebase**. They are different axes — estimate them separately.

### Step 3: Add Comprehension Rounds (brownfield)

> **New in this fork.** The upstream anchors assume you write every line. Most real work is
> modifying code that already exists, where *finding and understanding it* dominates the cost.

Before you can change existing code you must locate it, learn the local conventions, and work out what else breaks. Each of those is a real think-act-observe cycle.

| Codebase situation | Comprehension rounds |
|--------------------|---------------------|
| **Greenfield** — you write every line | 0 |
| **Hot context** — you already read this area earlier in the session | 0-1 |
| **Known repo, new area** | 1-2 |
| **Large or unfamiliar repo** — must locate the touch points first | 2-4 |
| **Legacy / no docs** — implicit conventions, wide blast radius, behaviour only discoverable by running it | 4-8 |

A comprehension round is spent on one of:
1. **Locating** — grep/glob/read to find where the behaviour actually lives
2. **Convention-learning** — naming, error handling, DI wiring, test style, so the change looks native
3. **Blast-radius mapping** — who calls this, what else reads this table/flag/config
4. **Assumption-checking** — running the thing to confirm what the code *actually* does, not what it appears to do

Rules that keep this honest:

- **Pay per area, not per module.** If three modules touch the same file or subsystem, put the comprehension rounds on the first one and 0 on the rest. Double-charging shared context is the most common way this step inflates a bogus number.
- **Add a one-time orientation cost** for a repo the agent has never seen: **2-5 rounds** at project level, for build system, how to run tests, where config lives, house conventions. Charge it once per project, not per module.
- **Assumption-checking beats reading.** Rounds that *run* the system to verify behaviour are worth more than rounds that only read it. When behaviour is surprising or undocumented, bias toward the higher end of the range.
- **Sanity check:** on a mature codebase, comprehension is typically **30-50% of total rounds**. If your comprehension figure is under 20% of implementation on brownfield work, you are almost certainly underestimating.
- **Reading is not free just because it's fast.** A 200-file repo scan is still rounds. Do not zero this out because "I'll just look quickly".

### Step 4: Add Quality Rounds — Test, Review, Documentation

> **New in this fork.** Upstream lists "Tests" as a module in its calibration examples but gives
> no criteria for sizing it, and never mentions review or docs at all.

Implementation rounds get you to *"it runs on my machine"*. Quality rounds get you to *shippable*. Decide the **Definition of Done** first, because it changes the number by up to 2x:

| Definition of Done | Includes | Quality add-on |
|--------------------|----------|----------------|
| **Spike / throwaway** | it runs, that's it | +0% |
| **Working feature** | happy-path test, self-review | +20-30% |
| **Production** (default) | unit + integration tests, review fixes, docs updated | +40-60% |
| **Critical path / regulated** | above + edge cases, security review, ADR or runbook | +70-100% |

State the chosen DoD in the output. If the requester hasn't said, assume **Production** and say so.

Then size the three buckets. Use the percentages above as a cross-check on the sum, not as a substitute for the anchors below.

**Test rounds**

| Test scope | Rounds |
|------------|--------|
| Happy-path unit test on a pure function | 1 |
| Unit tests needing mocks or fixtures | 2-3 |
| Integration test needing real infra (DB, broker, container) | 3-6 |
| E2E / browser / device / manual verification loop | 5-10 |
| Test that reveals a real bug | +1-3 implementation rounds per bug |

The last row is the one agents forget. **Tests spawn work.** On non-trivial modules, budget roughly **one real bug per 3 test rounds** — that's the whole point of writing them. A test suite that finds nothing was either trivial or not exercising the risk.

**Review rounds**

| Review type | Rounds |
|-------------|--------|
| Self-review pass: lint, typecheck, formatter, analyzers | 1 |
| Fixing automated gate failures (CI, security scan, coverage) | 1-3 |
| Applying findings from one human review pass | 2-4 |

**Human review latency is not a round.** A PR sitting four hours waiting for a reviewer is four hours of wallclock that no round count captures. Report it as **blocked time** on a separate line — never inflate round counts to represent waiting, and never hide it either.

**Documentation rounds**

| Artifact | Rounds |
|----------|--------|
| Inline comments / docstrings | 0 — part of writing the code |
| README or usage snippet update | 1 |
| API / integration doc for another team | 2-4 |
| ADR or design doc with alternatives considered | 2-3 |
| Migration guide or ops runbook | 2-4 |

Docs that must be *accurate about behaviour you just wrote* are cheap. Docs that must be accurate about behaviour you had to reverse-engineer inherit Step 3's uncertainty — size them accordingly.

### Step 5: Assign Risk Coefficients

Each module gets a risk coefficient that inflates its round count:

| Risk Level | Coefficient | When to Apply |
|------------|------------|---------------|
| **Low** | 1.0 | Mature ecosystem, clear docs, agent has strong pattern match |
| **Medium** | 1.3 | Minor unknowns, may need 1-2 extra debug rounds |
| **High** | 1.5 | Sparse docs, platform quirks, integration unknowns |
| **Very High** | 2.0 | Possible dead ends, may need to change approach entirely |

**On the 2.0 ceiling:** a genuine dead end is not a 2x event — it is a long-tail one. Toolchain bugs, an API that cannot do what you need, a design that has to be thrown away: these can cost 5-10x the module estimate. The coefficient cannot express that. When a module has a plausible dead end, keep the 2.0 **and** name it explicitly under *Biggest Risks* with the fallback plan. The risk register carries what the multiplier can't.

### Step 6: Construct Waves (optional — for parallel / multi-agent scenarios)

If the task will be executed by multiple agents or the user asks for fastest completion:

1. **Map dependencies**: For each module, list which other modules it depends on
2. **Group into waves**:
   - Wave 1: All modules with zero dependencies
   - Wave 2: Modules whose dependencies are all in Wave 1
   - Wave N: Modules whose dependencies are all in previous waves
3. **Note agent count**: How many agents can run in parallel within each wave

Watch the interaction with Step 3: **parallel agents cannot share comprehension.** Two agents touching the same subsystem each pay their own comprehension rounds. Either duplicate that cost per agent, or add a handoff round where the first agent writes down what it learned.

Skip this step for:
- Single-agent sequential execution
- Projects with < 3 modules
- Tightly coupled modules where parallelism gains are negligible

### Step 7: Calculate Totals

**Sequential mode** (single agent, default):
```
Module effective  = (implementation + comprehension + quality) × risk coefficient
Project rounds    = orientation
                  + Σ(module effective rounds)
                  + integration rounds
Integration rounds = 10-20% of Σ(implementation base)   ← scale with module count, see below
```

Integration is where modules that each worked alone stop working together. Use **10%** for 2-3 loosely coupled modules and **20%+** for 8 or more, or for anything sharing mutable state, a schema, or a wire format — connections grow faster than module count.

**Wave mode** (multi-agent):
```
Wave duration    = max(effective rounds of modules in wave)
Project rounds   = orientation
                 + Σ(wave durations)
                 + coordination rounds
                 + integration rounds
Coordination rounds = 2-3 rounds upfront (contract definition between agents)
```

### Step 8: Convert to Wallclock Time

Only at the very end, convert to human time:

```
Wallclock time = project rounds × minutes_per_round
```

Default `minutes_per_round` = **3 minutes** (includes agent generation time + user review time).

Adjust this parameter based on context:
- Fast iteration, user barely reviews → 2 min/round
- Complex domain, user carefully reviews each step → 4 min/round
- User needs to manually test (mobile, hardware, permissions) → 5 min/round

**Also adjust for command latency, not just review depth.** The 2-4 min round assumes a fast feedback loop. If the verify step in each round is slow, the round is slow:

| Verify step per round | minutes_per_round |
|-----------------------|-------------------|
| Unit test / script / hot reload | 2-3 |
| Compile a medium project | 3-4 |
| Full build of a large solution, or a test suite in minutes | 5-8 |
| Container image build, CI round-trip, deploy | 10-20 |

A CI-gated task is not "slow because it's hard" — it's slow because each round costs a pipeline. Report those separately from complexity, or the estimate looks like a competence problem when it's a latency problem.

Finally, report **blocked time** (human review, approvals, external dependencies) as its own line. Round-derived wallclock and blocked wallclock add up to elapsed time, but only the first is agent effort.

## Output Format

Always output the estimation in this exact structure:

```markdown
### Task: [task name]
**Definition of Done**: [Spike | Working feature | Production | Critical path]
**Codebase**: [greenfield | brownfield — familiarity level]

#### Module Breakdown

| # | Module | Impl | Comp | Test | Rev | Doc | Risk | Effective | Notes |
|---|--------|------|------|------|-----|-----|------|-----------|-------|
| 1 | ...    | N    | N    | N    | N   | N   | 1.x  | M         | why   |
| 2 | ...    | N    | N    | N    | N   | N   | 1.x  | M         | why   |

#### Summary

- **Orientation** (one-time, new repo): X rounds
- **Implementation base**: X rounds
- **Comprehension**: X rounds  (Y% of total — expect 30-50% on brownfield)
- **Quality** (test / review / docs): X rounds  (Y% — cross-check against DoD table)
- **Integration**: +X rounds
- **Risk-adjusted total**: Z rounds
- **Sequential wallclock**: A – B minutes (at N min/round — justify if not 3)
- **Blocked time** (human review, approvals): C minutes — not agent effort

**Wave Execution** (if applicable):
- Wave 1: [modules] → max M rounds
- Wave 2: [modules] → max M rounds
- Coordination overhead: +C rounds
- Duplicated comprehension across agents: +C rounds
- **Parallel wallclock**: A – B minutes (at N min/round, K agents)
- **Speedup vs sequential**: ~X%

#### Biggest Risks
1. [specific risk, what could blow up the estimate, and the fallback]
2. [...]
```

## Anti-Patterns to Avoid

These are the failure modes this skill exists to prevent:

1. **Human-time anchoring**: "A developer would take about 2 weeks..." → NO. Start from rounds.
2. **Padding by vibes**: Adding time "just to be safe" without specific risk rationale → NO. Use risk coefficients.
3. **Confusing complexity with volume**: 500 lines of boilerplate ≠ hard. One line of CGEvent API ≠ easy. Estimate by uncertainty, not line count.
4. **Forgetting integration cost**: Modules work alone but break together. Always add integration rounds.
5. **Ignoring user-side bottlenecks**: If the user must manually grant permissions, restart an app, or test on a device, that's extra round time. Adjust `minutes_per_round`, don't add phantom rounds.
6. **Assuming parallelism is free**: Multi-agent wave execution has coordination cost (contract definition, conflict resolution). Always add coordination rounds.
7. **Assuming greenfield**: Estimating as if writing from scratch when the real work is finding and understanding code that already exists → NO. Run Step 3.
8. **Treating "it compiles" as done**: An estimate that ends at first successful run, with no tests, no review fixes, no docs, is an estimate for a different task than the one requested → NO. Run Step 4 and state the DoD.
9. **Charging comprehension twice**: The same subsystem touched by five modules is understood once. Pay it once.
10. **Booking human review latency as rounds**: Waiting is wallclock, not agent effort. Separate line, always.
11. **Ignoring round latency**: 40 rounds behind a 10-minute CI pipeline is not 2 hours. Set `minutes_per_round` from the actual verify step.

## Calibration Reference

Upstream examples (small CLI ≈ 8 rounds, medium REST API ≈ 26 rounds) live in
[`calibration-examples.md`](https://github.com/ZhangHanDong/agent-estimation/blob/main/calibration-examples.md);
eval prompts in [`evals.json`](https://github.com/ZhangHanDong/agent-estimation/blob/main/evals.json).
Note those examples are **greenfield** — they do not exercise Step 3.

### Brownfield example (observed, not hypothetical)

Adding a Dockerfile + docker-compose service + CI job to an existing .NET modular monolith
(25+ projects, unfamiliar repo, no prior containerisation):

| Module | Impl | Comp | Test | Risk | Effective | Notes |
|--------|------|------|------|------|-----------|-------|
| Orientation (build system, props, health checks, conventions) | – | 6 | – | 1.0 | 6 | one-time; slnx layout, Directory.Build.props, DotNetEnv behaviour |
| Dockerfile for API | 2 | 1 | 3 | 2.0 | 12 | **dead end**: `dotnet publish` silently no-ops on SDK 10.0.400 — ~8 rounds to diagnose, had to switch to `dotnet build` |
| compose service + profiles | 2 | 1 | 2 | 1.0 | 5 | profile wiring, healthcheck, host.docker.internal |
| CI job (dind, wait-for-healthy) | 3 | 1 | 1 | 1.5 | 7 | cannot fully verify without pushing |
| Docs (README, .env.example) | 2 | 0 | 0 | 1.0 | 2 | |
| **Total** | **9** | **9** | **6** | | **32** | |

Two lessons this example encodes:
- **Comprehension equalled implementation** (9 vs 9). A greenfield-shaped estimate would have said ~9 rounds and been wrong by 3.5x.
- **The 2.0 coefficient did not cover the dead end.** A toolchain bug in `dotnet publish` cost ~8 rounds against a 2-round base — 4x on that module alone, and it was only survivable because the fallback (`dotnet build` + copy) existed. This is exactly the long-tail case Step 5 warns about: the multiplier under-predicted, the risk register is what should have caught it.
- Round latency was high (container builds, 30s+ solution builds), so `minutes_per_round` ≈ 6-8, not 3.
