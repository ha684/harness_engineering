# Prompt: Generate TASK.md from a feature entry

> **How to use:** Run this as the client, in the project repo, before handing a task to a contractor or a separate agent session. The agent will produce a filled-in `TASK.md` ready to deliver.
>
> **Inputs to have ready:**
> - The feature ID you want to hand off (e.g. "F04")
> - `features.md` (the feature's behavior + verification command)
> - `AGENTS.md` (hard constraints the contractor must follow)
> - `DECISIONS.md` (relevant past decisions)
> - The source code around the area being changed

---

You are generating a `TASK.md` for a task that will be handed to a contractor or separate agent session. The contractor will have **no verbal briefing** and **no access to project history** beyond the files you give them. The TASK.md must be self-contained enough that a skilled contractor can complete the work with zero follow-up questions.

## Step 1 — Gather context

Read the following in this order:

1. `features.md` — find the row for feature ID **[USER: INSERT FEATURE ID HERE]**. Extract the behavior description and verification command.
2. `AGENTS.md` — note hard constraints that apply to this feature area.
3. `DECISIONS.md` — identify active decisions that touch the feature's scope (auth, data model, error handling, testing patterns, etc.). Do NOT include unrelated decisions.
4. Source files in the likely touch zone — read 3-5 files around the area being changed to understand existing patterns (route handler structure, service method signatures, test file organization, etc.).

After reading, produce a one-paragraph summary of what the task is and what context matters. Stop and show this summary before drafting the TASK.md.

## Step 2 — Draft TASK.md

Using `templates/TASK.md` as the structure, draft a filled-in TASK.md. Apply these rules to each section:

**Scope — what to change:**
List specific files and what the change is in each. If new files must be created, name them (do not leave it open-ended). Err on the side of being too specific — a contractor who knows exactly what to touch makes fewer mistakes than one who has to guess.

**Out of scope — do NOT change:**
Be explicit. Common things to forbid:
- Modifying shared infrastructure (auth middleware, database session management, base models)
- Changing existing tests unrelated to this feature
- Upgrading dependencies
- Refactoring code the task does not require to be changed

If you notice an area adjacent to the task scope that a contractor might plausibly (but incorrectly) wander into, add it to out-of-scope explicitly.

**Acceptance criteria:**
Derive from the feature's behavior description in `features.md`. Each criterion must be behavioral (observable from outside the code) and map to something the verification command will check. Do NOT write implementation criteria like "create a UserService method" — write outcome criteria like "POST /api/users returns 201 with the user's ID."

**Verification command:**
Copy from `features.md`. Confirm it is actually runnable by trying it (if possible). If the feature has no verification command yet, stop and ask the user to write one before proceeding — do not invent a command you have not tested.

**Context — decisions affecting this task:**
Pull 2-5 entries from `DECISIONS.md` that are genuinely relevant. For each: "see DECISIONS.md entry `[date]: [title]` — [one sentence on why it matters here]." Do not reference unrelated decisions.

**Context — architecture constraints:**
Pull the hard constraints from `AGENTS.md` that apply to this feature. Add the relevant section of `docs/architecture.md` if the task touches module boundaries.

**Context — relevant files to read first:**
List 3-5 files (with line range hints if useful) that show the patterns the contractor should follow. Choose examples similar in structure to what they need to build.

**Environment notes:**
Note anything the contractor needs to know to run the code locally that is not obvious from `make setup`. Database setup commands, required env vars, service dependencies.

## Step 3 — Self-check before delivering

Walk through this checklist:

- [ ] Can the contractor complete this task without a single verbal question, using only the files they will receive?
- [ ] Is there anything in `DECISIONS.md` that contradicts the task that I forgot to mention?
- [ ] Is the verification command actually runnable right now? (Run it and confirm.)
- [ ] Is the out-of-scope section comprehensive enough to prevent a "helpful" refactor?
- [ ] Does the environment notes section cover everything needed for a clean clone to work?

If any item fails, revise the TASK.md before showing it to the user.

## Step 4 — Present and confirm

Show the complete proposed TASK.md in a code block. Then ask:

1. Is the scope correct — are there files to add or remove?
2. Are the acceptance criteria complete?
3. Is there any decision or constraint I missed?

**Do not write the file until the user approves.** After approval, write to `TASK.md` in the project root (or a designated tasks/ directory if the project uses one).

Then remind the user:

> Before handing off, mark this feature as `active` in `features.md` so no one else picks it up in parallel.

## What to avoid

- **Do not invent acceptance criteria** not implied by the feature description. If the feature says "POST /api/tasks returns 201", do not add "and sends a webhook notification" unless that is stated somewhere.
- **Do not include implementation hints** unless they are necessary to avoid a hard constraint violation. The contractor decides how; the TASK.md specifies what and why.
- **Do not copy-paste entire doc sections.** Point to them. The contractor has access to AGENTS.md and docs/ — they do not need the content duplicated.
- **Do not omit the verification command.** A TASK.md with no runnable verification command is not a contract — it is a wish list.
