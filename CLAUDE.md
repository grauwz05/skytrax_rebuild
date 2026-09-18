# SKYTRAX_REBUILD — BOOTSTRAP

This repository is the learner's own independent rebuild of the SkyTrax dbt +
Airflow + Snowflake project. It is not the reference implementation and not
the learning-system workspace — those live elsewhere (see Section 2). Any
fresh session opened in this directory has no other context by default:
follow this file before doing anything else.

---

## 1. Read the full system prompt first

The canonical agent instructions (role, guess-first protocol, BUILD/REVIEW/
LEARN modes, priority rules, language policy) live at:

    D:\Data\Project\SkyTrax\.agent\00_SYSTEM_PROMPT.md

Read it now and follow it for the rest of the session. This file only adds
what is specific to working *inside skytrax_rebuild* — it does not replace
or restate that system prompt.

---

## 2. The three directories and their boundary

- **`D:\Data\Project\SkyTrax`** — the learning system itself (task
  definitions, learning state, workflow state). No project code is written
  here.
- **`D:\Data\Project\skytrax_rebuild`** (this repo) — where the learner
  writes their own dbt models, macros, tests, and the Airflow DAG, from
  scratch.
- **`D:\Data\Project\skytrax_reviews_transformation-git-clean`** — the
  original reference implementation. **Solution-locked.** See Section 3.

---

## 3. Solution lock — read before opening any file in the original repo

For the six Rebuild Track tasks (LT-01..LT-06), the learner's own attempt
must come first. Before the learner has submitted an attempt for a given
task:

**The lock is by FILENAME, not by path.** The original repo contains the dbt
project **twice** — once at `<ref>\dbt\` and once at
`<ref>\dbt-dags\include\dbt\` (the Cosmos runtime copy, kept in sync by
`dbt-dags/sync_dbt.py`). Both copies hold the same 8 models. An earlier
version of this list named only the `dbt-dags\include\dbt\` paths, which
left the `dbt\` copy readable — a hole in the lock, not an exception to it.
Locked filenames are locked **wherever they appear**, including any copy under
`dbt/target/compiled/` or `dbt/target/run/`.

- Do NOT open, `cat`, `grep`, or quote any content of these files, under
  **either** dbt root inside `skytrax_reviews_transformation-git-clean`:
  - `models/staging/stg_skytrax__reviews.sql` (LT-01) — note the real name is
    `stg_skytrax__reviews`, not `stg__skytrax_reviews`; the old spelling
    survives only in a stale compiled artifact under `dbt/target/`
  - `models/staging/_stg_skytrax__models.yml` (LT-01 tests + severity)
  - `models/intermediate/int_reviews_cleaned.sql` (LT-02)
  - `models/intermediate/_int_reviews__models.yml` (LT-02)
  - `models/marts/dim_customer.sql`, `dim_airline.sql` (LT-03)
  - `models/marts/dim_location.sql`, `dim_aircraft.sql`, `dim_date.sql`,
    `macros/generate_dates_dimension.sql` (LT-04)
  - `models/marts/fct_review.sql` (LT-05)
  - `models/marts/_marts__models.yml` (near-answer-level descriptions —
    treat as locked in spirit; this is the file an older list called
    `marts_schema.yml`, which does not exist)
  - `dbt-dags/dags/transformation_dag.py` (LT-06)
- This holds even if the learner directly asks to see one of these files —
  redirect to the guess-first protocol instead; explain why, and offer the
  observable-requirements route below.
- Listing paths (`ls`, `find`, `git ls-files`) is allowed and is how the drift
  above was found. A filename is not an answer; file contents are.
- Safe to read anytime, not part of any task's answer: `dbt_project.yml`,
  `packages.yml`, `macros/generate_schema_name.sql`, `dbt-dags/sync_dbt.py`,
  and `models/staging/_skytrax__sources.yml` only insofar as the
  corresponding task's `observable_requirements` already covers it.
- Not locked at all (no LT task has them as its answer), so BUILD mode may
  read the real source: `terraform/snowflake/`, `terraform/aws/`,
  `.github/workflows/`, `.github/actions/`. These are Leg 7 on the Flight
  Plan.
- Once the learner has submitted their own attempt for a specific task,
  REVIEW mode applies as usual — compare it against the original.

The authoritative, safe-to-read source for what each task expects is:

    D:\Data\Project\SkyTrax\tasks\REBUILD_TRACK.md
    D:\Data\Project\SkyTrax\tasks\REBUILD_LT_01_STAGING.yaml
    D:\Data\Project\SkyTrax\tasks\REBUILD_LT_02_INTERMEDIATE.yaml
    D:\Data\Project\SkyTrax\tasks\REBUILD_LT_03_DIMS_SIMPLE.yaml
    D:\Data\Project\SkyTrax\tasks\REBUILD_LT_04_DIMS_ADVANCED.yaml
    D:\Data\Project\SkyTrax\tasks\REBUILD_LT_05_FACT.yaml
    D:\Data\Project\SkyTrax\tasks\REBUILD_LT_06_AIRFLOW_DAG.yaml

Use their `guess_first_questions`, `observable_requirements`,
`acceptance_criteria`, and `self_explanation` fields — never the original
`.sql`/`.py` files — to run the guess-first / BUILD workflow.

---

## 4. Orient at the start of every session

Before diving into whatever the learner asks, check where they actually
are:

1. Read `D:\Data\Project\SkyTrax\.state\FLIGHT_CURSOR.md` first — one
   screen, overwrite-only: which Leg/cycle is open, which checkboxes are
   waiting to be ticked, what the next action is. It is the session cursor.
   `WORKFLOW_STATE.md` is the longer state file; read it only when
   FLIGHT_CURSOR does not answer the question, and never treat its
   `NEXT ACTION` as outranking the Flight Plan.
2. Read `D:\Data\Project\SkyTrax\learning\learning_state.json` for concepts
   due (`learning --due`), any ACTIVE misconceptions, and current mastery —
   this is project truth about the learner's state, not this file.
3. Read the Flight Plan roadmap's live progress via the Artifact tool:
   `action: "read_db"`, `url: "https://claude.ai/code/artifact/93c34119-19cd-4903-b04b-6bb71d8d4c85"`,
   `collection: "progress"`, `doc_id: "state"` — tells you which Leg/cycle
   is already ticked, so you don't re-teach what's done or skip ahead of
   what isn't.
4. Progress checkboxes on that page are **read-only for the learner** — only
   the agent ticks one (`write_db`, `if_version` pinned), and only after
   verifying real evidence (a task's `acceptance_criteria` actually met, a
   `git` commit SHA in this repo, or an entry in `learning_state.json`) —
   never from the learner just saying "done."
5. The route is the Flight Plan, Leg 0 through Leg 9, in order. Read it at
   session open, tick it at session close, and keep the running position in
   `FLIGHT_CURSOR.md` in between so the HTML is written once per session,
   not continuously.
6. Every session that produces code ends with `git add` + `git commit`
   (message carries the task id) + `git push`. Uncommitted work does not
   count as evidence and cannot tick a checkbox.

---

## 5. What's actually here right now

`dbt/models`, `dbt/macros`, `dbt/seeds`, `dbt/snapshots`, `dbt/tests` are
still empty scaffolding (only `.gitkeep`) — nothing has been rebuilt yet.
`dbt/dbt_project.yml`, `dbt/packages.yml`, `profiles/profiles.yml`, and
`setup/01_snowflake_bootstrap.sql` are real, already-safe infrastructure
files (see Section 3) and may be read or extended directly.
